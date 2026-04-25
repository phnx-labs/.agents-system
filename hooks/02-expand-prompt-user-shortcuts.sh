#!/bin/bash
# Expands prompt shortcuts defined in ~/.agents/promptcuts.yaml
#
# Per-agent protocol:
#   claude  — prints <user-prompt-submit-hook> wrapper; REPLACES prompt
#   codex   — prints JSON with additionalContext; APPENDS (token stays)
#   gemini  — prints JSON with additionalContext; APPENDS (token stays)
#
# Replace-mode is claude-only by design: codex/gemini hooks can only
# append context, never rewrite the submitted prompt.
#
# Central file at ~/.agents/promptcuts.yaml survives agents-cli version
# upgrades (which replace per-agent config dirs).

PROMPTCUTS_FILE="$HOME/.agents/promptcuts.yaml"

INPUT_JSON=$(cat)
[ ! -f "$PROMPTCUTS_FILE" ] && exit 0

python3 - "$INPUT_JSON" <<'PY'
import json, os, sys, yaml

try:
    data = json.loads(sys.argv[1])
except Exception:
    sys.exit(0)

prompt = data.get("prompt", "")
event = data.get("hook_event_name", "")
if not prompt:
    sys.exit(0)

path = os.path.expanduser("~/.agents/promptcuts.yaml")
try:
    with open(path) as f:
        shortcuts = (yaml.safe_load(f) or {}).get("shortcuts", {}) or {}
except Exception:
    sys.exit(0)

matched = None
for token, expansion in shortcuts.items():
    if token in prompt:
        matched = (token, expansion.strip())
        break
if not matched:
    sys.exit(0)

token, expansion = matched

# Claude: replace prompt via wrapper (CLAUDE_PROJECT_DIR is set by claude).
if os.environ.get("CLAUDE_PROJECT_DIR"):
    replaced = prompt.replace(token, expansion)
    print("<user-prompt-submit-hook>")
    print(replaced)
    print("</user-prompt-submit-hook>")
    sys.exit(0)

# Codex + Gemini: append as additionalContext. Event name differs
# (UserPromptSubmit vs BeforeAgent), but the output shape is identical.
event_name = event or "UserPromptSubmit"
context = f"Shortcut `{token}` expands to:\n\n{expansion}"
out = {
    "hookSpecificOutput": {
        "hookEventName": event_name,
        "additionalContext": context,
    }
}
print(json.dumps(out))
PY

exit 0
