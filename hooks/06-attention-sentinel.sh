#!/usr/bin/env bash
# Notification / Stop / UserPromptSubmit hook: maintain a per-session "attention"
# sentinel so the agents-cli menu bar can show which LOCAL sessions are blocked
# waiting for the user (a permission prompt, a question, idle-waiting).
#
#   Notification            -> agent needs you      -> write sentinel
#   Stop / UserPromptSubmit  -> you engaged/resumed  -> clear sentinel
#
# Sentinel file: ~/.agents/.cache/state/attention/<session_id>  (empty; presence
# is the signal). The menu-bar helper (LocalState.attentionSessionIds) reads this
# dir; without it, "NEEDS YOU" only reflects cloud tasks + failed routines.
#
# session_id and hook_event_name arrive on stdin as JSON (Claude/Codex/Gemini).
set -euo pipefail

input="$(cat)"

parsed="$(printf '%s' "$input" | python3 -c 'import json,sys
try:
    d = json.load(sys.stdin)
    print(d.get("session_id","") or "")
    print(d.get("hook_event_name","") or "")
except Exception:
    print(""); print("")' 2>/dev/null || printf '\n\n')"

sid="$(printf '%s' "$parsed" | sed -n 1p)"
event="$(printf '%s' "$parsed" | sed -n 2p)"
[ -z "$sid" ] && exit 0

dir="$HOME/.agents/.cache/state/attention"

case "$event" in
  Notification)
    mkdir -p "$dir"
    : > "$dir/$sid"
    ;;
  Stop|UserPromptSubmit)
    rm -f "$dir/$sid" 2>/dev/null || true
    ;;
esac

# These events inject stdout into context on some agents — stay silent.
exit 0
