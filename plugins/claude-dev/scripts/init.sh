#!/usr/bin/env bash
set -euo pipefail

# Initialize state for a new feature
# Usage: init.sh "<feature description>"

FEATURE_DESC="${1:?'Feature description required'}"
DATA_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugin-data/claude-dev}"
STATE_FILE="$DATA_DIR/active.json"

if [ -f "$STATE_FILE" ]; then
  echo "ERROR: Active feature already exists:"
  python3 -c "
import json
with open('$STATE_FILE') as f:
    state = json.load(f)
print(f'  Feature: {state.get(\"feature\", \"unknown\")}')
print(f'  Phase: {state.get(\"phase\", \"unknown\")}')
"
  echo ""
  echo "Archive or delete it first:"
  echo "  ${CLAUDE_PLUGIN_ROOT:-~/.agents/plugins/claude-dev}/scripts/state.sh archive"
  echo "  ${CLAUDE_PLUGIN_ROOT:-~/.agents/plugins/claude-dev}/scripts/state.sh delete"
  exit 1
fi

mkdir -p "$DATA_DIR"

# Generate slug from description
SLUG=$(echo "$FEATURE_DESC" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-' | head -c 50)

python3 -c "
import json
from datetime import datetime, timezone

state = {
    'feature': '''${FEATURE_DESC}''',
    'slug': '$SLUG',
    'phase': 'planning',
    'started_at': datetime.now(timezone.utc).isoformat(),
    'reviewers_spawned': False,
    'reviews_received': False,
    'review_task': None,
    'fixes_applied': False,
    'tests_passed': False,
}

with open('$STATE_FILE', 'w') as f:
    json.dump(state, f, indent=2)

print(f'Initialized: {state[\"feature\"]}')
print(f'Slug: {state[\"slug\"]}')
print(f'Phase: {state[\"phase\"]}')
"
