#!/usr/bin/env bash
set -euo pipefail

# State management for claude-dev plugin
# Usage:
#   state.sh read                    - Print current state
#   state.sh set <key> <value>       - Set a state field
#   state.sh archive                 - Archive current state
#   state.sh delete                  - Delete current state

DATA_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugin-data/claude-dev}"
STATE_FILE="$DATA_DIR/active.json"
HISTORY_DIR="$DATA_DIR/history"

cmd="${1:-read}"

case "$cmd" in
  read)
    if [ ! -f "$STATE_FILE" ]; then
      echo "NO ACTIVE FEATURE. Use /claude-dev:feature to start."
      exit 0
    fi
    python3 -c "
import json
with open('$STATE_FILE') as f:
    state = json.load(f)
phase = state.get('phase', 'unknown')
feature = state.get('feature', 'unknown')
reviewers = 'yes' if state.get('reviewers_spawned') else 'no'
reviews = 'yes' if state.get('reviews_received') else 'no'
fixes = 'yes' if state.get('fixes_applied') else 'no'
tests = 'yes' if state.get('tests_passed') else 'no'
print(f'FEATURE: {feature}')
print(f'PHASE: {phase}')
print(f'GATES: reviewers_spawned={reviewers} reviews_received={reviews} fixes_applied={fixes} tests_passed={tests}')
"
    ;;

  set)
    key="${2:?'key required'}"
    value="${3:?'value required'}"
    mkdir -p "$DATA_DIR"
    python3 -c "
import json, sys
state_path = '$STATE_FILE'
try:
    with open(state_path) as f:
        state = json.load(f)
except FileNotFoundError:
    print('ERROR: No active state file. Run init.sh first.', file=sys.stderr)
    sys.exit(1)
val = '$value'
if val == 'true':
    val = True
elif val == 'false':
    val = False
state['$key'] = val
with open(state_path, 'w') as f:
    json.dump(state, f, indent=2)
print('OK: $key = $value')
"
    ;;

  archive)
    if [ ! -f "$STATE_FILE" ]; then
      echo "Nothing to archive."
      exit 0
    fi
    mkdir -p "$HISTORY_DIR"
    slug=$(python3 -c "
import json
with open('$STATE_FILE') as f:
    print(json.load(f).get('slug', 'unknown'))
")
    ts=$(date +%Y%m%d-%H%M%S)
    mv "$STATE_FILE" "$HISTORY_DIR/${slug}-${ts}.json"
    echo "Archived: ${slug}-${ts}.json"
    ;;

  delete)
    rm -f "$STATE_FILE"
    echo "State deleted."
    ;;

  *)
    echo "Unknown command: $cmd"
    echo "Usage: state.sh [read|set|archive|delete]"
    exit 1
    ;;
esac
