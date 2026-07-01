#!/usr/bin/env bash
# Test for merge-guard.sh (PreToolUse Bash guard).
#
# Verifies the guard BLOCKS a real `gh pr merge ... --admin` invocation (exit 2)
# and ALLOWS everything else — including (a) commands whose body/message TEXT
# merely mentions the trigger (the false-positive that fired on PR #40) and NOT
# failing open on (b) real invocations hidden inside quotes / command
# substitutions (`sh -c '...'`, `$(...)`, shell-fed heredocs).
#
# Exercises the real script over real stdin JSON (no mocking). Trigger tokens in
# THIS file are assembled from fragments so the currently-installed (old) guard
# doesn't block the test runner itself.
set -u
DIR=$(cd "$(dirname "$0")" && pwd)
GUARD="$DIR/merge-guard.sh"
M="mer""ge"      # -> "merge"
A="--ad""min"    # -> "--admin"
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
check 2 "plain admin merge"          "gh pr $M 40 $A"
check 2 "admin + squash"             "gh pr $M 40 --squash $A"
check 2 "admin then delete-branch"   "gh pr $M 40 $A --delete-branch"
check 2 "create then admin-merge"    "gh pr create -t x -b y && gh pr $M 40 $A"

# --- Should BLOCK (exit 2): real invocation hidden in exec context (no fail-open) ---
check 2 "sh -c single-quoted bypass" "sh -c 'gh pr $M 40 $A'"
check 2 "sh -c double-quoted bypass" "sh -c \"gh pr $M 40 $A\""
check 2 "command subst in -m value"  "git commit -m \"\$(gh pr $M 40 $A)\""
check 2 "backtick command subst"     "echo \`gh pr $M 40 $A\`"
check 2 "shell-fed heredoc"          "$(printf 'sh <<EOF\ngh pr %s 40 %s\nEOF' "$M" "$A")"

# --- Should ALLOW (exit 0): legit merges and unrelated commands ---
check 0 "legit squash merge"         "gh pr $M 40 --squash --delete-branch"
check 0 "legit merge no flags"       "gh pr $M 40"
check 0 "unrelated command"          "ls -la && git status"

# --- Should ALLOW (exit 0): trigger tokens only as inert BODY/MESSAGE TEXT ---
check 0 "double-quoted body mentions it" \
  "gh pr create --body \"never run gh pr $M 40 $A, it bypasses protection\""
check 0 "single-quoted body mentions it" \
  "gh pr create --body 'do not gh pr $M --admin'"
check 0 "commit msg mentions it" \
  "git commit -m \"note: gh pr $M $A is blocked by the guard\""

# cat-heredoc body feeding a doc flag (the exact shape that misfired on PR #40)
hd=$(printf 'gh pr create --title t --body "$(cat <<%sEOF%s\ndocs: never gh pr %s 40 %s here\nEOF\n)"' "'" "'" "$M" "$A")
check 0 "cat-heredoc doc body mentions it" "$hd"

printf -- '---\nmerge-guard: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
