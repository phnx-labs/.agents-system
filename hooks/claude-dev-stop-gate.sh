#!/usr/bin/env bash
set -euo pipefail

# Stop hook for claude-dev plugin
# Exit 0 = allow stop (normal)
# Exit 2 = block stop, stderr becomes feedback to Claude

DATA_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugin-data/claude-dev}"
STATE_FILE="$DATA_DIR/active.json"

# No active feature session -> don't interfere
if [ ! -f "$STATE_FILE" ]; then
  exit 0
fi

# Read phase
phase=$(python3 -c "
import json, sys
try:
    with open('$STATE_FILE') as f:
        state = json.load(f)
    print(state.get('phase', 'idle'))
except Exception:
    print('idle')
" 2>/dev/null)

# Phases that don't need gating
case "$phase" in
  idle|done|planning)
    exit 0
    ;;
esac

# Read the last assistant message from stdin
INPUT_JSON=$(cat)
last_msg=$(echo "$INPUT_JSON" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get('last_assistant_message', ''))
except Exception:
    print('')
" 2>/dev/null)

# Check if Claude is claiming completion
is_claiming_done=$(python3 -c "
import sys
msg = sys.stdin.read().lower()
done_signals = [
    'implementation is complete',
    'feature is complete',
    'all done',
    'that completes',
    'i have finished',
    'everything is working',
    'changes are complete',
    'the feature is ready',
    'successfully implemented',
    'implementation is done',
    'all changes have been made',
    'feature is done',
    'work is complete',
    'that should do it',
    'ready for use',
]
for signal in done_signals:
    if signal in msg:
        print('yes')
        sys.exit(0)
print('no')
" <<< "$last_msg" 2>/dev/null)

# If Claude is NOT claiming done, let it continue normally
if [ "$is_claiming_done" != "yes" ]; then
  exit 0
fi

# Claude IS claiming done. Check if gates are satisfied.
gate_result=$(python3 -c "
import json, sys

with open('$STATE_FILE') as f:
    state = json.load(f)

phase = state.get('phase', 'idle')
reviewers_spawned = state.get('reviewers_spawned', False)
reviews_received = state.get('reviews_received', False)
fixes_applied = state.get('fixes_applied', False)
tests_passed = state.get('tests_passed', False)

if phase == 'implementing':
    if not reviewers_spawned:
        print('BLOCK:You claimed done but have NOT spawned reviewers. You MUST spawn 2 reviewer agents (Codex + Gemini) via mcp__Swarm__Spawn before this feature can be complete. Read the reviewer prompt template at \${CLAUDE_PLUGIN_ROOT}/skills/feature/references/reviewer-prompt.md and follow Phase 3.')
    elif not reviews_received:
        print('BLOCK:Reviewers were spawned but results have not been processed. Check status with mcp__Swarm__Status, read their findings, and address issues before claiming done.')
    else:
        print('OK')
elif phase == 'reviewing':
    if not reviews_received:
        print('BLOCK:Still in review phase. Check reviewer status with mcp__Swarm__Status, process their findings, then address issues.')
    else:
        print('OK')
elif phase == 'fixing':
    if not tests_passed:
        print('BLOCK:You applied fixes but have NOT run tests. Write and run real tests before claiming done. Follow Phase 5.')
    else:
        print('OK')
elif phase == 'testing':
    if not tests_passed:
        print('BLOCK:Tests are not passing yet. Fix failing tests before claiming done.')
    else:
        print('OK')
else:
    print('OK')
" 2>/dev/null)

if [[ "$gate_result" == BLOCK:* ]]; then
  feedback="${gate_result#BLOCK:}"
  echo "$feedback" >&2
  exit 2
fi

exit 0
