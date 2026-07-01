#!/bin/sh
# no-pr-footer/footer-guard.sh — PreToolUse(Bash) guard.
#
# Blocks `gh pr create|edit`, `gh issue create|edit`, and `git commit` whose
# inline body carries the "Generated with Claude Code" promo footer. Muqsit's
# standing rule: that line is garbage and must never reach a PR/issue/commit.
#
# Reads the hook JSON from stdin, extracts .tool_input.command via jq.
# Exits 0 (allow) or 2 (deny, message on stderr). Only inline bodies are seen;
# a footer injected via --body-file is invisible here (acceptable — the common
# failure mode in the retro was an inline --body heredoc).
input=$(cat)

# Fast path: ignore anything that isn't a gh pr/issue or git commit command.
case "$input" in
  *"gh pr "*|*"gh issue "*|*"git commit"*) ;;
  *) exit 0 ;;
esac

cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || cmd=""
[ -n "$cmd" ] || exit 0

# Only the body-bearing subcommands.
case "$cmd" in
  *"gh pr create"*|*"gh pr edit"*|*"gh issue create"*|*"gh issue edit"*|*"git commit"*) ;;
  *) exit 0 ;;
esac

# Detect the promo footer in any of its forms.
case "$cmd" in
  *"Generated with"*"Claude Code"*|*"claude.com/claude-code"*|*"claude.ai/code"*|*"🤖 Generated"*)
    printf '%s\n' 'Blocked: remove the "Generated with Claude Code" footer from the body. Muqsit'\''s standing rule — that promo line is garbage and must never appear in PR/issue/commit bodies. Delete the line and retry.' >&2
    exit 2
    ;;
esac
exit 0
