#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="$HOME/.twitter-warmup"
STATE_FILE="$STATE_DIR/state.yaml"
TARGETS_FILE="$STATE_DIR/targets.yaml"

if [ ! -f "$STATE_FILE" ]; then
  echo "STATE: Not initialized. Run: \${CLAUDE_SKILL_DIR}/scripts/init.sh"
  exit 0
fi

# Parse state.yaml (flat YAML, line-based parsing)
get_val() {
  grep -E "^[[:space:]]*$1:" "$STATE_FILE" | head -1 | sed "s/.*$1:[[:space:]]*//" | tr -d '"' | tr -d "'" | xargs
}

handle=$(get_val "handle")
created_at=$(get_val "created_at")
premium=$(get_val "premium")
profile_complete=$(get_val "profile_complete")
api_access=$(get_val "api_access")
phase=$(get_val "phase")
cooldown_active=$(get_val "active")
last_session=$(get_val "last_session")

# Phase name
case "$phase" in
  1) phase_name="Observer & Reply-Guy" ;;
  2) phase_name="Voice & Identity" ;;
  3) phase_name="Earned Promotion" ;;
  *) phase_name="Unknown" ;;
esac

# Days since account creation
day_num="?"
if [ -n "$created_at" ] && [ "$created_at" != "null" ] && [ "$created_at" != "" ]; then
  created_epoch=$(date -j -f "%Y-%m-%d" "$created_at" "+%s" 2>/dev/null || echo "")
  if [ -n "$created_epoch" ]; then
    now_epoch=$(date "+%s")
    day_num=$(( (now_epoch - created_epoch) / 86400 ))
  fi
fi

# Target count
target_count=0
if [ -f "$TARGETS_FILE" ]; then
  target_count=$(grep -c '^\s*- handle:' "$TARGETS_FILE" 2>/dev/null || echo "0")
fi

# Prereqs
fmt_bool() { [ "$1" = "true" ] && echo "YES" || echo "NO"; }

# Days since last session
last_session_str="never"
if [ -n "$last_session" ] && [ "$last_session" != "null" ]; then
  ls_epoch=$(date -j -f "%Y-%m-%d" "$last_session" "+%s" 2>/dev/null || echo "")
  if [ -n "$ls_epoch" ]; then
    days_ago=$(( ($(date "+%s") - ls_epoch) / 86400 ))
    if [ "$days_ago" -eq 0 ]; then
      last_session_str="today"
    elif [ "$days_ago" -eq 1 ]; then
      last_session_str="yesterday"
    else
      last_session_str="${days_ago} days ago"
    fi
  fi
fi

# Cooldown
cooldown_str="NO"
[ "$cooldown_active" = "true" ] && cooldown_str="YES"

# Today's theme
day_of_week=$(date "+%A" | tr '[:upper:]' '[:lower:]')
TOPICS_FILE="$STATE_DIR/topics.yaml"
theme_name=""
if [ -f "$TOPICS_FILE" ]; then
  theme_name=$(grep -A1 "^\s*${day_of_week}:" "$TOPICS_FILE" 2>/dev/null | grep "name:" | sed 's/.*name:\s*//' | tr -d '"' | tr -d "'" || echo "")
fi

# Handle display
handle_display="${handle:-<not set>}"

echo "ACCOUNT: $handle_display | Phase $phase ($phase_name) | Day $day_num"
echo "PREREQS: Premium=$(fmt_bool "$premium") | Profile=$(fmt_bool "$profile_complete") | API=$(fmt_bool "$api_access") | Targets=$target_count"
echo "LAST SESSION: $last_session_str | Cooldown: $cooldown_str"
if [ -n "$theme_name" ]; then
  day_cap="$(echo "${day_of_week:0:1}" | tr '[:lower:]' '[:upper:]')${day_of_week:1}"
  echo "TODAY: $day_cap — $theme_name"
fi
