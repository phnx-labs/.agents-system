#!/bin/sh
# gh-merge-guard/merge-guard.sh — PreToolUse(Bash) guard.
#
# Blocks `gh pr merge ... --admin`. Admin bypass merges past branch protection
# and required reviews; in the retro it was used to self-merge an agent's own
# PR. Merging when authorized is fine via a normal merge — only the bypass is
# blocked, so branch protections still decide.
#
# Reads the hook JSON from stdin, extracts .tool_input.command via jq.
# Exits 0 (allow) or 2 (deny, message on stderr).
input=$(cat)

# Fast path: ignore anything that isn't a gh pr merge.
case "$input" in
  *"gh pr merge"*) ;;
  *) exit 0 ;;
esac

cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || cmd=""
[ -n "$cmd" ] || exit 0

case "$cmd" in
  *"gh pr merge"*)
    case "$cmd" in
      *"--admin"*)
        printf '%s\n' "Blocked: 'gh pr merge --admin' bypasses branch protection (used in the retro to self-merge an own PR). Get explicit user authorization, then merge WITHOUT --admin so required reviews and checks still apply." >&2
        exit 2
        ;;
    esac
    ;;
esac
exit 0
