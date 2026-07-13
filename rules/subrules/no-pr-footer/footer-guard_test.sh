#!/usr/bin/env bash
# Test for footer-guard.sh (PreToolUse Bash guard).
#
# Verifies the guard BLOCKS a gh pr/issue create|edit or git commit whose inline
# body carries the "Generated with Claude Code" promo footer (exit 2), and ALLOWS
# everything else (exit 0) — across BOTH harness payload shapes: Claude Code
# snake_case (.tool_input.command) and Grok CLI camelCase (.toolInput.command).
# The old snake_case-only extraction resolved empty under Grok, so the footer
# block silently vanished there.
#
# Exercises the real script over real stdin JSON (no mocking). The footer token
# in THIS file is assembled from fragments so the currently-installed guard does
# not block the test runner or its own editing.
set -u
DIR=$(cd "$(dirname "$0")" && pwd)
GUARD="$DIR/footer-guard.sh"
FOOT="Generated with ""Claude Code"   # -> the promo line, unsplit at runtime
pass=0
fail=0

# check <want_exit> <field> <description> <command>
#   <field> = tool_input (Claude snake_case) or toolInput (Grok camelCase)
check() {
  want=$1; field=$2; desc=$3; cmd=$4
  json=$(printf '%s' "$cmd" | jq -Rs --arg f "$field" '{($f):{command:.}}')
  printf '%s' "$json" | "$GUARD" >/dev/null 2>&1
  got=$?
  if [ "$got" -eq "$want" ]; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    printf 'FAIL: %s (want exit %s, got %s)\n  cmd: %s\n' "$desc" "$want" "$got" "$cmd"
  fi
}

# --- BLOCK (exit 2): footer in an inline body, snake_case (Claude Code) ---
check 2 tool_input "snake_case pr create with footer" \
  "gh pr create -t x -b \"real change. $FOOT\""
check 2 tool_input "snake_case git commit with footer" \
  "git commit -m \"fix things. $FOOT\""
check 2 tool_input "snake_case footer url form" \
  "gh pr create -t x -b \"see https://claude.com/claude-code\""

# --- BLOCK (exit 2): footer in an inline body, camelCase (Grok CLI) ---
check 2 toolInput "camelCase pr create with footer" \
  "gh pr create -t x -b \"real change. $FOOT\""
check 2 toolInput "camelCase git commit with footer" \
  "git commit -m \"fix things. $FOOT\""
check 2 toolInput "camelCase issue create with footer" \
  "gh issue create -t x -b \"bug report. $FOOT\""

# --- ALLOW (exit 0): no footer, both shapes ---
check 0 tool_input "snake_case clean pr create"  "gh pr create -t x -b \"just a real change\""
check 0 toolInput  "camelCase clean pr create"   "gh pr create -t x -b \"just a real change\""
check 0 tool_input "snake_case clean git commit" "git commit -m \"fix the bug\""
check 0 toolInput  "camelCase clean git commit"  "git commit -m \"fix the bug\""
# Unrelated command with footer text but not a body-bearing subcommand -> allow.
check 0 toolInput  "camelCase non-target echo"   "echo '$FOOT'"

printf -- '---\nfooter-guard: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
