#!/bin/sh
# gh-merge-guard/merge-guard.sh — PreToolUse(Bash) guard.
#
# Blocks an actual `gh pr merge ... --admin` invocation. Admin bypass merges
# past branch protection and required reviews; in the retro it was used to
# self-merge an agent's own PR. A normal authorized merge is fine — only the
# --admin bypass is blocked, so branch protections still decide.
#
# The trigger tokens ("gh pr merge", "--admin") must appear as REAL command
# tokens, not as text inside a quoted string or heredoc body. Otherwise a
# `gh pr create` / `git commit` whose body merely *documents* the guard (as
# this very repo's rules do) gets falsely blocked. We strip heredoc bodies and
# quoted spans before matching. If the stripper (perl) is unavailable we fall
# back to the raw substring check: it over-blocks in rare cases but never fails
# open on a genuine bypass.
#
# Reads the hook JSON from stdin, extracts .tool_input.command via jq.
# Exits 0 (allow) or 2 (deny, message on stderr).
input=$(cat)

# Fast path: nothing that never even mentions a pr merge can be a bypass merge.
case "$input" in
  *"gh pr merge"*) ;;
  *) exit 0 ;;
esac

cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || cmd=""
[ -n "$cmd" ] || exit 0

# Strip heredoc bodies + quoted spans so tokens inside --body/-m/heredoc text
# don't trip the guard. Fall back to the raw command if perl is missing.
if command -v perl >/dev/null 2>&1; then
  scan=$(printf '%s' "$cmd" | perl -0777 -pe '
    s/<<[-~]?\s*(["\x27]?)([A-Za-z_]\w*)\1.*?^\s*\2\s*$//gms; # heredoc bodies
    s/\x27[^\x27]*\x27//g;                                    # single-quoted spans
    s/"(?:\\.|[^"\\])*"//g;                                   # double-quoted spans
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
