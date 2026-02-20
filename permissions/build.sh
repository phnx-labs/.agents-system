#!/bin/bash
# Build default.yaml from group files
# Groups are processed in alphabetical order (00-, 01-, etc.)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GROUPS_DIR="$SCRIPT_DIR/groups"
OUTPUT="$SCRIPT_DIR/default.yaml"

if [ ! -d "$GROUPS_DIR" ]; then
  echo "Error: groups directory not found at $GROUPS_DIR"
  exit 1
fi

# Concatenate all group files in order
cat "$GROUPS_DIR"/*.yaml > "$OUTPUT"

# Count entries
ALLOW_COUNT=$(grep -c '^\s*-\s*"' "$OUTPUT" 2>/dev/null || echo 0)
echo "Built $OUTPUT with $ALLOW_COUNT permission entries"
