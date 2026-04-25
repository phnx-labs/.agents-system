#!/bin/bash
# PreToolUse hook: block git pull/rebase/autostash when working tree is dirty.
# Fast path uses pure-bash pattern matching (no forks) so non-git Bash calls
# add ~2ms. Only git-ish commands pay for jq + git status.

IFS= read -rd '' input

case "$input" in
  *'"command":"git '*|*'--autostash'*) ;;
  *) exit 0 ;;
esac

cmd=$(jq -r '.tool_input.command' <<< "$input")

case "$cmd" in
  "git pull"*|"git rebase"*|*" git pull"*|*" git rebase"*|*"--autostash"*) ;;
  *) exit 0 ;;
esac

cwd=$(jq -r '.cwd // empty' <<< "$input")
[ -n "$cwd" ] && cd "$cwd" 2>/dev/null

[ -z "$(git status --porcelain 2>/dev/null)" ] && exit 0

echo "Blocked: working tree is dirty. git pull/rebase/autostash on a dirty tree can destroy uncommitted work. Commit (or manually stash) first, then retry." >&2
exit 2
