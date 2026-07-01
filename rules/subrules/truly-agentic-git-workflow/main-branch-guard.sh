#!/bin/sh
# main-branch-guard — PreToolUse hook on Write / Edit / MultiEdit / NotebookEdit
# and Bash.
#
# Enforces the Truly Agentic Git Workflow: no agent tool call may create, update,
# or delete a file, or `git add` / `git commit`, while a repository is checked out
# on its DEFAULT branch (main / master / trunk / whatever origin/HEAD points at).
# All work goes through an isolated worktree + PR. Worktrees (feature branches)
# and non-git paths (/tmp, scratchpad, loose files) are unaffected.
#
# Fires on:
#   - Write / Edit / MultiEdit / NotebookEdit -> inspects .tool_input.file_path
#     (or .notebook_path); resolves its enclosing repo and current branch.
#   - Bash -> inspects `git commit|add|stage` segments; resolves the target repo
#     from `-C <path>` or the session cwd.
#
# Exits 0 (allow) or 2 (deny, message on stderr).
#
# No exceptions, no escape hatch — by design. This hook only gates the AGENT's
# tool calls: the user's own editor, `!`-prefixed session commands, and git's
# internal hooks are unaffected.
#
# Limitations (intentionally out of scope — runtime obfuscation only a sandbox
# can stop): `eval`/`xargs`/`$(...)` subshells feeding a git command string,
# base64-decoded commands. The file-write block already prevents an agent from
# authoring the content those would commit, so the commit gate is defense in
# depth, not the sole barrier.

set -eu

input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null) || tool=""
[ -z "$tool" ] && exit 0

cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null) || cwd=""

deny_reason=""

# on_default_branch <dir> — return 0 (protected) if <dir> is inside a git
# work-tree whose current branch IS the repo's default branch. Return 1 (allow)
# for: not a git repo, detached HEAD, or a non-default (feature/worktree) branch.
# Sets _top / _cur / _def for the caller's deny message.
on_default_branch() {
  _top=$(git -C "$1" rev-parse --show-toplevel 2>/dev/null) || return 1
  _cur=$(git -C "$_top" symbolic-ref --short -q HEAD 2>/dev/null) || _cur=""
  [ -z "$_cur" ] && return 1
  _def=$(git -C "$_top" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##') || _def=""
  if [ -n "$_def" ]; then
    [ "$_cur" = "$_def" ] && return 0
    return 1
  fi
  # No origin/HEAD recorded — fall back to the conventional default names.
  case "$_cur" in
    main|master) return 0 ;;
    *) return 1 ;;
  esac
}

set_deny_reason() {
  # $1 = what is blocked (e.g. the file path or "git commit"); uses _top/_cur.
  deny_reason="Blocked: $1 on the default branch '$_cur' of $_top.

Direct file/commit changes on the default branch are not allowed — all work goes
through an isolated worktree + PR (the Truly Agentic Git Workflow). No exceptions.

Create a worktree off the freshly-fetched default branch, then work there:
  REPO=$_top
  git -C \"\$REPO\" fetch origin
  BASE=\$(git -C \"\$REPO\" symbolic-ref --short refs/remotes/origin/HEAD | sed 's#^origin/##')
  git -C \"\$REPO\" worktree add -b <slug> \"\$REPO/.agents/worktrees/<slug>\" \"origin/\$BASE\"
then edit under \$REPO/.agents/worktrees/<slug>/, commit there, push, and open a PR."
}

# --- File-tool branch ------------------------------------------------------
case "$tool" in
  Write|Edit|MultiEdit|NotebookEdit)
    fp=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null) || fp=""
    [ -z "$fp" ] && exit 0
    # Resolve a relative path against the session cwd.
    case "$fp" in
      /*) ;;
      *) [ -n "$cwd" ] && fp="$cwd/$fp" ;;
    esac
    # Nearest existing ancestor directory (a Write may be creating a new file).
    d=$(dirname "$fp")
    while [ ! -d "$d" ]; do
      _nd=$(dirname "$d")
      [ "$_nd" = "$d" ] && break
      d=$_nd
    done
    [ -d "$d" ] || exit 0
    if on_default_branch "$d"; then
      set_deny_reason "editing '$fp'"
      printf '%s\n' "$deny_reason" >&2
      exit 2
    fi
    exit 0
    ;;
  Bash) ;;
  *) exit 0 ;;
esac

# --- Bash branch: gate `git commit|add|stage` on the default branch --------
# Fast path: no "git" anywhere -> nothing to police.
case "$input" in *git*) ;; *) exit 0 ;; esac
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || cmd=""
[ -z "$cmd" ] && exit 0

# Detect `sh|bash -c <inner>` at raw-string level (mirrors git-guard.sh) so a
# quoted inner command isn't shredded by naive token splitting.
extract_sh_c_inner() {
  _raw=$1
  _raw=$(printf '%s' "$_raw" | sed 's/^[[:space:]]*//')
  while :; do
    _pre=$_raw
    _raw=$(printf '%s' "$_raw" | sed 's/^[A-Za-z_][A-Za-z_0-9]*=[^[:space:]]*[[:space:]][[:space:]]*//')
    [ "$_raw" = "$_pre" ] && break
  done
  case "$_raw" in
    sh\ *|bash\ *|/bin/sh\ *|/bin/bash\ *|/usr/bin/sh\ *|/usr/bin/bash\ *) ;;
    *) return 1 ;;
  esac
  case "$_raw" in *" -c "*) ;; *) return 1 ;; esac
  _inner=${_raw#* -c }
  _inner=$(printf '%s' "$_inner" | sed 's/^[[:space:]]*//')
  case "$_inner" in
    \"*\") _inner=${_inner#\"}; _inner=${_inner%\"} ;;
    \'*\') _inner=${_inner#\'}; _inner=${_inner%\'} ;;
  esac
  _dash_c_inner=$_inner
  return 0
}

# Resolve the repo dir a git segment operates on: the `-C <path>` argument if
# present (relative resolves against cwd), else the session cwd.
resolve_repo_dir() {
  _cpath=$1
  if [ -n "$_cpath" ]; then
    case "$_cpath" in
      /*) printf '%s' "$_cpath" ;;
      *)  printf '%s' "${cwd:-.}/$_cpath" ;;
    esac
  else
    printf '%s' "${cwd:-.}"
  fi
}

check_segment() {
  _seg=$1

  if extract_sh_c_inner "$_seg"; then
    if ! check_command_string "$_dash_c_inner"; then return 1; fi
    return 0
  fi

  unset IFS
  # shellcheck disable=SC2086
  set -- $_seg

  while [ $# -gt 0 ]; do
    case "$1" in
      *=*) shift ;;
      *) break ;;
    esac
  done
  [ $# -eq 0 ] && return 0

  first=$1
  case "$first" in
    \"*\") first=$(printf '%s' "$first" | sed 's/^"\(.*\)"$/\1/') ;;
    \'*\') first=$(printf '%s' "$first" | sed "s/^'\(.*\)'$/\1/") ;;
  esac
  case "$first" in
    git|*/git) ;;
    *) return 0 ;;
  esac
  shift

  # Peel git global flags before the subcommand; capture -C <path>.
  cpath=""
  while [ $# -gt 0 ]; do
    case "$1" in
      -C)            shift; [ $# -gt 0 ] && { cpath=$1; shift; } ;;
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
  case "$sub" in
    commit|add|stage) ;;
    *) return 0 ;;
  esac

  _repo=$(resolve_repo_dir "$cpath")
  if on_default_branch "$_repo"; then
    set_deny_reason "\`git $sub\`"
    return 1
  fi
  return 0
}

check_command_string() {
  _input=$1
  IFS=$(printf ' \t\n.'); IFS=${IFS%.}
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
