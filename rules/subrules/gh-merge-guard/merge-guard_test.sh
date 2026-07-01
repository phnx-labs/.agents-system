#!/usr/bin/env bash
# Test for merge-guard.sh (PreToolUse Bash guard).
#
# Verifies the guard BLOCKS a real `gh pr merge ... --admin` invocation (exit 2)
# and ALLOWS everything else — crucially including commands whose body/message
# TEXT merely mentions the trigger tokens (the false-positive regression that
# blocked a `gh pr create` documenting the guard).
#
# Exercises the real script over real stdin JSON (no mocking).
set -u
DIR=$(cd "$(dirname "$0")" && pwd)
GUARD="$DIR/merge-guard.sh"
pass=0
fail=0

# check <want_exit> <description> <command>
check() {
  want=$1
  desc=$2
  cmd=$3
  json=$(printf '%s' "$cmd" | jq -Rs '{tool_input:{command:.}}')
  printf '%s' "$json" | "$GUARD" >/dev/null 2>&1
  got=$?
  if [ "$got" -eq "$want" ]; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    printf 'FAIL: %s (want exit %s, got %s)\n  cmd: %s\n' "$desc" "$want" "$got" "$cmd"
  fi
}

# --- Should BLOCK (exit 2): a genuine --admin bypass merge ---
check 2 "plain admin merge"          'gh pr merge 40 --admin'
check 2 "admin + squash"             'gh pr merge 40 --squash --admin'
check 2 "admin= form"                'gh pr merge 40 --admin --delete-branch'
check 2 "create then admin-merge"    'gh pr create -t x -b y && gh pr merge 40 --admin'

# --- Should ALLOW (exit 0): legit merges and unrelated commands ---
check 0 "legit squash merge"         'gh pr merge 40 --squash --delete-branch'
check 0 "legit merge no flags"       'gh pr merge 40'
check 0 "unrelated command"          'ls -la && git status'

# --- Should ALLOW (exit 0): trigger tokens only as BODY TEXT (regression) ---
check 0 "double-quoted body mentions it" \
  'gh pr create --body "never run gh pr merge --admin, it bypasses protection"'
check 0 "commit msg mentions it" \
  'git commit -m "note: gh pr merge --admin is blocked by the guard"'

# heredoc body mentioning the tokens (the exact shape that misfired)
hd=$'gh pr create --title t --body "$(cat <<\'EOF\'\ndocs: never gh pr merge --admin here\nEOF\n)"'
check 0 "heredoc body mentions it" "$hd"

printf -- '---\nmerge-guard: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
