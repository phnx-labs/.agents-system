#!/usr/bin/env bash
# SessionStart hook: inject the live session id (+ transcript path) into the
# agent's OWN context, so the model can reference its session without reading
# any file. Claude-first — covers Claude Code and every Claude-harness profile
# (e.g. the `kimi` / `deepseek` ANTHROPIC_MODEL presets, which are Claude Code
# with a swapped model endpoint), gated to `claude` in agents.yaml.
#
# This is the deliberate OPPOSITE of the two neighbouring SessionStart hooks:
#   - 04-capture-session-start-metadata.sh writes a silent state file.
#   - 05-session-start-autosync.sh runs a detached sync and stays silent.
# Both keep stdout empty to avoid leaking into the prompt. This hook WRITES to
# stdout on purpose: Claude appends SessionStart `additionalContext` to the
# model context verbatim (proven empirically — sentinel round-trip + negative
# control), so the injected id is real content, not an attention bet.
#
# BLAST RADIUS: this runs on EVERY Claude session start. It must NEVER abort or
# delay session start. Therefore:
#   - No `set -e`: a failing command must not propagate a non-zero exit.
#   - Every early return is `exit 0` (empty stdin, unparseable JSON, missing
#     session_id) — a malformed payload yields no context, not a broken turn.
#   - The only thing ever written to stdout is well-formed JSON (or nothing).

# Read the SessionStart payload. Real Claude stdin shape:
#   {"session_id":"...","transcript_path":"...","cwd":"...",
#    "hook_event_name":"SessionStart","source":"startup"}
input="$(cat 2>/dev/null || true)"

# Nothing on stdin (e.g. hook invoked out of band) -> emit nothing, succeed.
[ -z "$input" ] && exit 0

# Parse and emit entirely inside Python so a malformed payload can only ever
# cause a silent exit 0 (via the except), never a broken/partial line on stdout.
printf '%s' "$input" | python3 -c '
import json, sys

try:
    data = json.load(sys.stdin)
except Exception:
    # Unparseable / truncated stdin: stay silent, do not break the session.
    sys.exit(0)

if not isinstance(data, dict):
    sys.exit(0)

sid = data.get("session_id") or ""
transcript = data.get("transcript_path") or ""

# No session id -> nothing meaningful to inject. Stay silent.
if not sid:
    sys.exit(0)

context = f"Your current session id is {sid}."
if transcript:
    context += f" Session transcript: {transcript}"

# The additionalContext shape Claude injects into the model context, verified
# working against a live session (sentinel + real UUID round-trip).
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": context,
    }
}))
' 2>/dev/null || true

# Always succeed: even if python3 is missing or the pipeline failed, session
# start must proceed unimpeded.
exit 0
