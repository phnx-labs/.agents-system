#!/usr/bin/env bash
# SessionStart hook: inject the live session id (+ transcript path) into the
# agent's OWN context, so the model can reference its session without having to
# read any file. Claude-first (covers Claude Code and all Claude-harness
# profiles, e.g. the `kimi`/`deepseek` ANTHROPIC_MODEL presets).
#
# Deliberately the OPPOSITE of 04-capture (silent state-file write) and
# 05-autosync (silent): this hook WRITES to stdout on purpose. SessionStart
# `additionalContext` is injected into the model context on Claude — verified
# empirically (sentinel round-trip + negative control), not just assumed.
set -euo pipefail

input="$(cat)"
[ -z "$input" ] && exit 0

printf '%s' "$input" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
sid = d.get("session_id") or ""
tp = d.get("transcript_path") or ""
if not sid:
    sys.exit(0)
ctx = f"Your current session id is {sid}."
if tp:
    ctx += f" Session transcript: {tp}"
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": ctx,
    }
}))
'
exit 0
