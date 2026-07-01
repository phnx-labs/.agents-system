#!/bin/sh
# gh-merge-guard/merge-guard.sh — PreToolUse(Bash) guard.
#
# Blocks an actual `gh pr merge ... --admin` invocation. Admin bypass merges
# past branch protection and required reviews; in the retro it was used to
# self-merge an agent's own PR. A normal authorized merge is fine — only the
# --admin bypass is blocked, so branch protections still decide.
#
# The hard part is telling a real INVOCATION from body/message TEXT that merely
# mentions the tokens (a `gh pr create` / `git commit` whose --body or -m
# documents the guard, as this repo's own rules do — that false-positive fired
# on a `gh pr create` during PR #40). We remove only genuinely INERT text
# before matching:
#   * values of documentation flags (--body/-b/--title/-t/-m/--message/...),
#     which gh/git pass as data and never execute; but a value that embeds a
#     command substitution ($( or `) is KEPT visible, since that executes;
#   * heredoc bodies feeding a NON-shell command (cat/gh/git ...), which are
#     data; a heredoc piped into sh/bash/eval is KEPT visible, since it runs.
# Everything else — `sh -c '...'`, `$(...)`, backticks, bare invocations — is
# left intact, so a real bypass merge is always still seen. If the stripper
# (perl) is unavailable we fall back to the raw substring match: it over-blocks
# in rare cases but never fails open on a genuine bypass.
#
# Reads the hook JSON from stdin, extracts .tool_input.command via jq.
# Exits 0 (allow) or 2 (deny, message on stderr).
input=$(cat)

# Fast path: text that never even mentions a pr merge can't be a bypass merge.
case "$input" in
  *"gh pr merge"*) ;;
  *) exit 0 ;;
esac

cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || cmd=""
[ -n "$cmd" ] || exit 0

if command -v perl >/dev/null 2>&1; then
  scan=$(printf '%s' "$cmd" | perl -0777 -pe '
    # 1. A heredoc body is inert ONLY when it feeds a known data-sink command
    #    (cat/tee/gh/git — they treat it as text, never as shell). Then drop the
    #    body. Anything else — a shell interpreter, ". file"/"source", or any
    #    command we do not recognise — KEEPS the body visible, so a heredoc
    #    piped into execution is still matched. Default-safe: unknown => keep.
    s{
      (^|[\n;&|(`])([^\n]*?)<<[-~]?[ \t]*(["\x27]?)([A-Za-z_]\w*)\3
      (.*?)\n[ \t]*\4[ \t]*(?=\n|$)
    }{
      my ($b,$pre,$tag,$body)=($1,$2,$4,$5);
      $pre =~ /(?:^|[;&|(`]|\$\()[ \t]*(?:cat|tee|gh|git)\b[^;&|`]*$/
        ? "$b$pre"
        : "$b$pre<<$tag\n$body\n$tag";
    }gemsx;

    # 2. Value of a documentation flag is inert TEXT -> drop it, UNLESS it
    #    embeds a command substitution ($( or backtick), which executes.
    s{
      ((?:--body|--title|--message|--notes|--subject|--body-text|-b|-t|-m)(?:=|[ \t]+))
      ("(?:\\.|[^"\\])*"|\x27[^\x27]*\x27)
    }{
      my ($flag,$val)=($1,$2);
      $val =~ /[\$`]/ ? "$flag$val" : "$flag ";
    }gex;
  ') || scan=$cmd
else
  scan=$cmd
fi

case "$scan" in
  *"gh pr merge"*)
    case "$scan" in
      *"--admin"*)
        printf '%s\n' "Blocked: 'gh pr merge --admin' bypasses branch protection (used in the retro to self-merge an own PR). Get explicit user authorization, then merge WITHOUT --admin so required reviews and checks still apply." >&2
        exit 2
        ;;
    esac
    ;;
esac
exit 0
