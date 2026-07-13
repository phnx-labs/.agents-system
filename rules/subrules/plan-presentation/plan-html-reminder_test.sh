#!/bin/sh
# Tests for plan-html-reminder.sh — the ExitPlanMode plan-render gate.
# Run: sh plan-html-reminder_test.sh   (no mocks; drives the real hook via stdin)
set -eu

DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
HOOK="$DIR/plan-html-reminder.sh"
SCAN=$(mktemp -d)
trap 'rm -rf "$SCAN"' EXIT
export PLAN_HTML_SCAN_ROOT="$SCAN"

pass=0; fail=0
# run <expected-rc> <label> <json>
run() {
  want=$1; label=$2; json=$3
  got=0
  printf '%s' "$json" | sh "$HOOK" >/dev/null 2>&1 || got=$?
  if [ "$got" = "$want" ]; then
    pass=$((pass+1)); echo "ok   — $label (rc=$got)"
  else
    fail=$((fail+1)); echo "FAIL — $label (want rc=$want, got rc=$got)"
  fi
}

EPM='{"tool_name":"ExitPlanMode","tool_input":{"plan":"x"}}'

# 1. ExitPlanMode with an empty scan root -> BLOCK (exit 2).
rm -f "$SCAN"/*.html 2>/dev/null || true
run 2 "ExitPlanMode, no rendered plan -> block" "$EPM"

# 2. ExitPlanMode after a fresh /tmp/plan-<slug>.html -> ALLOW (exit 0).
: > "$SCAN/plan-my-feature.html"
run 0 "ExitPlanMode, canonical plan-<slug>.html present -> allow" "$EPM"

# 3. ExitPlanMode with the scratchpad <slug>-plan.html convention (nested) -> ALLOW.
rm -f "$SCAN"/*.html
mkdir -p "$SCAN/a/b/scratchpad"
: > "$SCAN/a/b/scratchpad/remote-run-plan.html"
run 0 "ExitPlanMode, nested <slug>-plan.html present -> allow" "$EPM"

# 4. A stale render (>90 min old) does NOT satisfy the gate -> block.
rm -rf "$SCAN"/* 2>/dev/null || true
: > "$SCAN/plan-old.html"
touch -d '2 hours ago' "$SCAN/plan-old.html" 2>/dev/null || touch -t 200001010000 "$SCAN/plan-old.html"
run 2 "ExitPlanMode, only a stale plan html -> block" "$EPM"

# 5. A non-ExitPlanMode tool is never gated -> allow, even with an empty root.
rm -f "$SCAN"/*.html 2>/dev/null || true
run 0 "Write tool -> allow (not gated)" '{"tool_name":"Write","tool_input":{"file_path":"/x"}}'

# --- Harness portability: Grok CLI camelCase payloads ---
# Grok sends camelCase `toolName` and names plan-exit `exit_plan_mode`.

# 6. Grok exit_plan_mode with an empty scan root -> BLOCK (the gate must still fire).
rm -f "$SCAN"/*.html 2>/dev/null || true
run 2 "Grok exit_plan_mode, no rendered plan -> block" \
  '{"toolName":"exit_plan_mode","toolInput":{"plan":"x"}}'

# 7. Grok exit_plan_mode after a fresh render -> ALLOW.
: > "$SCAN/plan-grok.html"
run 0 "Grok exit_plan_mode, fresh plan html -> allow" \
  '{"toolName":"exit_plan_mode","toolInput":{"plan":"x"}}'

# 8. THE BUG: a Grok camelCase NON-plan tool with NO fresh plan HTML must ALLOW.
# The old `-n && != ExitPlanMode` test fell through on an empty resolved name and
# exited 2, blocking EVERY tool call in a Grok session. A reminder must fail OPEN.
rm -f "$SCAN"/*.html 2>/dev/null || true
run 0 "Grok camelCase run_terminal_command, no plan html -> allow (not blocked)" \
  '{"toolName":"run_terminal_command","toolInput":{"command":"npm test"}}'

echo "----"
echo "pass=$pass fail=$fail"
[ "$fail" = 0 ]
