#!/usr/bin/env bash
set -euo pipefail

TARGETS_FILE="$HOME/.twitter-warmup/targets.yaml"

if [ ! -f "$TARGETS_FILE" ]; then
  echo "TARGETS: No targets file. Run init.sh first."
  exit 0
fi

target_count=$(grep -c '^\s*- handle:' "$TARGETS_FILE" 2>/dev/null || echo "0")
if [ "$target_count" -eq 0 ]; then
  echo "TARGETS: Empty. Seed 5+ accounts in $TARGETS_FILE before starting."
  exit 0
fi

now_epoch=$(date "+%s")

# Parse targets into blocks and evaluate due status
# Output: tier 1 due, tier 2 due, tier 3 (always optional)
tier1_due=""
tier2_due=""
tier3_list=""
tier1_count=0
tier2_count=0
tier3_count=0

current_handle=""
current_name=""
current_tier=""
current_topics=""
current_last=""

flush_target() {
  if [ -z "$current_handle" ]; then return; fi

  days_since="never"
  is_due=true

  if [ -n "$current_last" ] && [ "$current_last" != "null" ]; then
    last_epoch=$(date -j -f "%Y-%m-%d" "$current_last" "+%s" 2>/dev/null || echo "")
    if [ -n "$last_epoch" ]; then
      days_since=$(( (now_epoch - last_epoch) / 86400 ))
      case "$current_tier" in
        1) [ "$days_since" -le 2 ] && is_due=false ;;
        2) [ "$days_since" -le 4 ] && is_due=false ;;
        3) is_due=true ;;  # always optional
      esac
      days_since="${days_since}d ago"
    fi
  fi

  line="  $current_handle | $current_name | topics: $current_topics | last: $days_since"

  case "$current_tier" in
    1) if $is_due; then tier1_due="${tier1_due}${line}\n"; tier1_count=$((tier1_count+1)); fi ;;
    2) if $is_due; then tier2_due="${tier2_due}${line}\n"; tier2_count=$((tier2_count+1)); fi ;;
    3) tier3_list="${tier3_list}${line}\n"; tier3_count=$((tier3_count+1)) ;;
  esac

  current_handle=""
  current_name=""
  current_tier=""
  current_topics=""
  current_last=""
}

while IFS= read -r line; do
  # New target block
  if echo "$line" | grep -qE '^\s*- handle:'; then
    flush_target
    current_handle=$(echo "$line" | sed 's/.*handle:\s*//' | tr -d '"' | tr -d "'")
  elif echo "$line" | grep -qE '^\s*name:'; then
    current_name=$(echo "$line" | sed 's/.*name:\s*//' | tr -d '"' | tr -d "'")
  elif echo "$line" | grep -qE '^\s*tier:'; then
    current_tier=$(echo "$line" | sed 's/.*tier:\s*//' | tr -d '"' | tr -d "'")
  elif echo "$line" | grep -qE '^\s*topics:'; then
    current_topics=$(echo "$line" | sed 's/.*topics:\s*//' | tr -d '[]"' | tr -d "'")
  elif echo "$line" | grep -qE '^\s*last_engaged:'; then
    current_last=$(echo "$line" | sed 's/.*last_engaged:\s*//' | tr -d '"' | tr -d "'")
  fi
done < "$TARGETS_FILE"
flush_target

total=$((tier1_count + tier2_count + tier3_count))
echo "DUE FOR ENGAGEMENT ($total targets):"
echo ""

if [ "$tier1_count" -gt 0 ]; then
  echo "TIER 1 — engage this session ($tier1_count):"
  printf "$tier1_due"
  echo ""
fi

if [ "$tier2_count" -gt 0 ]; then
  echo "TIER 2 — engage if time ($tier2_count):"
  printf "$tier2_due"
  echo ""
fi

if [ "$tier3_count" -gt 0 ]; then
  echo "TIER 3 — monitor, engage if natural ($tier3_count):"
  printf "$tier3_list"
fi

if [ "$total" -eq 0 ]; then
  echo "(all targets recently engaged — discover new ones this session)"
fi
