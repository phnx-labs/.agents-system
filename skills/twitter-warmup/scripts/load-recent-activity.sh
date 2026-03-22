#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="$HOME/.twitter-warmup/log"
DAYS="${1:-7}"

if [ ! -d "$LOG_DIR" ]; then
  echo "ACTIVITY: No log directory. Run init.sh first."
  exit 0
fi

# Collect log files for the last N days
log_files=""
for i in $(seq 0 $((DAYS - 1))); do
  day=$(date -v"-${i}d" "+%Y-%m-%d" 2>/dev/null || date -d "-${i} days" "+%Y-%m-%d" 2>/dev/null || continue)
  file="$LOG_DIR/${day}.yaml"
  if [ -f "$file" ]; then
    log_files="$file $log_files"
  fi
done

if [ -z "$log_files" ]; then
  echo "ACTIVITY (last ${DAYS} days): No logged sessions yet."
  exit 0
fi

total_replies=0
total_standalone=0
total_qrts=0
total_likes=0
total_new_followers=0
days_active=0

echo "ACTIVITY (last ${DAYS} days):"
echo ""

for file in $log_files; do
  day=$(basename "$file" .yaml)

  # Count entries
  replies=$(grep -c '^\s*- to:' "$file" 2>/dev/null || echo "0")
  standalone=$(grep -c '^\s*- tweet_url:' "$file" 2>/dev/null || echo "0")
  # Standalone section items also have tweet_url, subtract replies that have tweet_url
  # Better: count items under standalone: section
  standalone_section=$(sed -n '/^standalone:/,/^[a-z]/p' "$file" 2>/dev/null | grep -c '^\s*- tweet_url:' || echo "0")
  qrts=$(sed -n '/^quote_tweets:/,/^[a-z]/p' "$file" 2>/dev/null | grep -c '^\s*- ' || echo "0")

  likes=$(grep 'likes_received:' "$file" 2>/dev/null | sed 's/.*likes_received:\s*//' | tr -d '"' || echo "0")
  new_followers=$(grep 'new_followers:' "$file" 2>/dev/null | sed 's/.*new_followers:\s*//' | tr -d '"' || echo "0")

  engaged=$(grep '^\s*-\s*"@\|^\s*- "@' "$file" 2>/dev/null | sed -n '/targets_engaged/,/^[a-z]/p' | tr -d '[]"' | tr ',' '\n' | sed 's/^\s*//' | grep -c '@' || echo "0")
  engaged_list=$(sed -n '/^targets_engaged:/,/^[a-z]/p' "$file" 2>/dev/null | grep '@' | tr -d '[]"' | tr ',' ' ' | sed 's/^\s*//' || echo "")

  echo "  $day: ${replies} replies, ${standalone_section} standalone, ${qrts} QRTs | likes: ${likes} | new followers: ${new_followers}"
  [ -n "$engaged_list" ] && echo "    engaged: $engaged_list"

  total_replies=$((total_replies + replies))
  total_standalone=$((total_standalone + standalone_section))
  total_qrts=$((total_qrts + qrts))
  total_likes=$((total_likes + likes))
  total_new_followers=$((total_new_followers + new_followers))
  days_active=$((days_active + 1))
done

echo ""
echo "TOTALS ($days_active active days): ${total_replies} replies, ${total_standalone} standalone, ${total_qrts} QRTs"
echo "ENGAGEMENT: ${total_likes} likes received, ${total_new_followers} new followers"
