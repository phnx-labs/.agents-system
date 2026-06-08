#!/bin/sh
# git-guard — PreToolUse hook on Bash.
#
# Blocks destructive git ops regardless of how the command is dressed:
# `git -C <path>`, `--git-dir=`, `--work-tree=`, leading env-var assignments
# (FOO=bar git …), chain operators (&&, ||, ;, |, newline), `sh -c "..."` and
# `bash -c "..."` wrappers, absolute path (`/usr/bin/git`), and quoted first
# token (`'git'` / `"git"`).
#
# Also gates `git worktree remove`: allowed when the target tree is clean AND
# has no unpushed commits; denied otherwise (including --force).
#
# Exits 0 (allow) or 2 (deny, message on stderr).
#
# Limitations (intentionally out of scope — these are runtime obfuscation that
# only a sandbox can stop):
#   - `eval "<computed string>"` with the destructive op in the runtime string
#   - `xargs git ...` reading args from stdin
#   - base64-decoded / pipe-built command strings
#   - aliases or shell functions defined elsewhere
#   - `$(...)` / backtick subshells (single-level recursion not implemented)

set -eu

# Fast path: if the raw JSON doesn't even contain the substring "git", there
# is nothing for this hook to police. Skip jq + parse entirely. Cuts ~7 ms
# off every non-git Bash call, which is >80% of them.
input=$(cat)
case "$input" in *git*) ;; *) exit 0 ;; esac

# Extract .tool_input.command from the buffered JSON. Use jq because it
# properly unescapes \n / \t / \" / \\ — without that, real multi-line
# commands look like one long line with literal backslash-n and pass through
# chain-splitting unsplit.
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || cmd=""
[ -z "$cmd" ] && exit 0

deny_reason=""

# Detect `sh|bash -c <inner>` at the raw string level (BEFORE token split) so
# that quoted args like `sh -c "git reset --hard"` stay intact. Naive
# `set -- $seg` would split `"git` away from `reset --hard"` and miss the
# git subcommand entirely. Sets _dash_c_inner on match. Returns 0 on match.
extract_sh_c_inner() {
  _raw=$1
  _raw=$(printf '%s' "$_raw" | sed 's/^[[:space:]]*//')
  # Strip leading VAR=value assignments (POSIX env-var prefix).
  while :; do
    _pre=$_raw
    _raw=$(printf '%s' "$_raw" | sed 's/^[A-Za-z_][A-Za-z_0-9]*=[^[:space:]]*[[:space:]][[:space:]]*//')
    [ "$_raw" = "$_pre" ] && break
  done
  # First word must be sh / bash / absolute path to one.
  case "$_raw" in
    sh\ *|bash\ *|/bin/sh\ *|/bin/bash\ *|/usr/bin/sh\ *|/usr/bin/bash\ *) ;;
    *) return 1 ;;
  esac
  # Find first occurrence of " -c " anywhere after the shell name.
  case "$_raw" in
    *" -c "*) ;;
    *) return 1 ;;
  esac
  _inner=${_raw#* -c }
  _inner=$(printf '%s' "$_inner" | sed 's/^[[:space:]]*//')
  # Strip a single layer of wrapping quotes.
  case "$_inner" in
    \"*\") _inner=${_inner#\"}; _inner=${_inner%\"} ;;
    \'*\') _inner=${_inner#\'}; _inner=${_inner%\'} ;;
  esac
  _dash_c_inner=$_inner
  return 0
}

# Check one already-split segment.
check_segment() {
  _seg=$1

  # sh|bash -c wrapper detection must happen BEFORE naive token splitting,
  # because the -c argument is typically a quoted string the naive split
  # would shred.
  if extract_sh_c_inner "$_seg"; then
    if ! check_command_string "$_dash_c_inner"; then return 1; fi
    return 0
  fi

  # Restore default IFS so `set -- $1` actually splits on space/tab/newline.
  # The caller flipped IFS to newline-only to iterate chain segments.
  unset IFS
  # shellcheck disable=SC2086
  set -- $_seg

  # Skip leading VAR=value assignments.
  while [ $# -gt 0 ]; do
    case "$1" in
      *=*) shift ;;
      *) break ;;
    esac
  done
  [ $# -eq 0 ] && return 0

  # First token may be: git | /path/to/git | "git" | 'git'
  # Strip enclosing single or double quotes.
  first=$1
  case "$first" in
    \"*\") first=$(printf '%s' "$first" | sed 's/^"\(.*\)"$/\1/') ;;
    \'*\') first=$(printf '%s' "$first" | sed "s/^'\(.*\)'$/\1/") ;;
  esac

  # Accept first token == git OR */git (absolute or relative path).
  case "$first" in
    git|*/git) ;;
    *) return 0 ;;
  esac
  shift

  # Peel git's global flags before the subcommand.
  while [ $# -gt 0 ]; do
    case "$1" in
      -C)            shift; [ $# -gt 0 ] && shift ;;
      --git-dir=*|--work-tree=*|--namespace=*) shift ;;
      --git-dir|--work-tree|--namespace)      shift; [ $# -gt 0 ] && shift ;;
      -c)            shift; [ $# -gt 0 ] && shift ;;
      --no-pager|--paginate|--no-replace-objects|--bare|--exec-path=*|--literal-pathspecs|--no-optional-locks)
                     shift ;;
      -*)            shift ;;
      *)             break ;;
    esac
  done
  [ $# -eq 0 ] && return 0

  sub=$1
  shift

  case "$sub" in
    reset|checkout|stash|rebase|cherry-pick|revert|clean|reflog|filter-branch|gc|prune|fsck)
      deny_reason="git $sub is denied (rewrites history or destroys work). Use a worktree-based flow instead."
      return 1
      ;;
    branch)
      for a in "$@"; do
        case "$a" in
          -D|-d|-m|-M|--delete|--force-delete|--move|--force-move)
            deny_reason="git branch $a is denied (deletes/renames a ref). Branch creation/listing is fine."
            return 1 ;;
        esac
      done
      return 0
      ;;
    config)
      for a in "$@"; do
        case "$a" in
          --get|--get-all|--get-regexp|-l|--list|--show-origin|--show-scope|-h|--help)
            return 0 ;;
        esac
      done
      deny_reason="git config write is denied. Use --get for reads."
      return 1
      ;;
    push)
      for a in "$@"; do
        case "$a" in
          --force|-f)
            deny_reason="git push --force is denied. Use --force-with-lease."
            return 1 ;;
        esac
      done
      return 0
      ;;
    merge)
      for a in "$@"; do
        case "$a" in
          --abort)
            deny_reason="git merge --abort is denied."
            return 1 ;;
        esac
      done
      return 0
      ;;
    worktree)
      [ $# -lt 1 ] && return 0
      [ "$1" != "remove" ] && return 0
      shift
      forced=0
      target=""
      while [ $# -gt 0 ]; do
        case "$1" in
          --force|-f) forced=1; shift ;;
          --) shift; target=${1:-}; break ;;
          -*) shift ;;
          *) target=$1; break ;;
        esac
      done
      [ -z "$target" ] && return 0
      [ ! -d "$target" ] && return 0

      if dirty=$(git -C "$target" status --porcelain 2>/dev/null) && [ -n "$dirty" ]; then
        deny_reason="git worktree remove $target denied — worktree has uncommitted changes:
$(printf '%s\n' "$dirty" | head -5)"
        return 1
      fi
      if upstream=$(git -C "$target" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null); then
        ahead=$(git -C "$target" rev-list --count "$upstream..HEAD" 2>/dev/null || echo 0)
        if [ "${ahead:-0}" -gt 0 ]; then
          deny_reason="git worktree remove $target denied — $ahead unpushed commit(s) on $(git -C "$target" rev-parse --abbrev-ref HEAD). Push or merge first."
          return 1
        fi
      fi
      if [ "$forced" = "1" ]; then
        deny_reason="git worktree remove --force denied — drop --force; clean removal is allowed when work is preserved."
        return 1
      fi
      return 0
      ;;
  esac
  return 0
}

# Top-level: split a command string on chain operators AND newlines, then
# check each segment. Also called recursively for sh -c inner strings.
check_command_string() {
  _input=$1
  # Restore POSIX-default IFS before reading it — check_segment may have
  # unset IFS, and `OLDIFS=$IFS` under `set -u` would error on unset.
  IFS=$(printf ' \t\n.'); IFS=${IFS%.}
  # Split on chain operators AND real newlines. The actual newline is inserted
  # via shell quoting — `\n` in sed replacement is a GNU/BSD extension that's
  # reliable enough on the macOS sed we target.
  _chains=$(printf '%s' "$_input" | sed 's/&&/\
/g; s/||/\
/g; s/;/\
/g; s/|/\
/g')

  OLDIFS=$IFS
  IFS='
'
  for seg in $_chains; do
    seg=$(printf '%s' "$seg" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    [ -z "$seg" ] && continue
    if ! check_segment "$seg"; then
      IFS=$OLDIFS
      return 1
    fi
  done
  IFS=$OLDIFS
  return 0
}

if ! check_command_string "$cmd"; then
  printf '%s\n' "$deny_reason" >&2
  exit 2
fi
exit 0
