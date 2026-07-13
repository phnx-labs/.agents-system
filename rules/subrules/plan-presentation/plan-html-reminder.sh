#!/bin/sh
# plan-html-reminder — PreToolUse hook on ExitPlanMode.
#
# Enforces the plan-presentation rule: a plan must be RENDERED as a self-contained
# HTML doc (plan-render skill) before it is presented, so the user reviews it in the
# browser — skinned in the product's brand, light/dark, opened on the Mac they sit at.
#
# Mechanism: the moment an agent goes to present a plan (ExitPlanMode), check whether a
# fresh plan HTML was written this session. If yes -> allow. If no -> block ONCE (exit 2)
# with a reminder; the agent renders `/tmp/plan-<slug>.html`, opens it, and re-calls
# ExitPlanMode, which now finds the file and passes. Self-terminating; never loops.
#
# The gate is on the RENDER (a file we can detect). Opening on the Mac and theming are
# driven by the always-on rule text — a headless fleet still renders the file (allowed)
# even when it cannot open a browser.
#
# Exits 0 (allow) or 2 (block, message on stderr). Only gates the AGENT's tool call;
# the user's own actions are unaffected.

set -eu

input=$(cat)

# Matcher already scopes us to the plan-exit tool, but confirm defensively — this
# is a REMINDER hook, so it must ONLY ever fire on a genuine plan-exit and fail
# OPEN (allow) for anything else. Read the tool name across harnesses: Claude Code
# sends snake_case .tool_name = "ExitPlanMode"; Grok CLI sends camelCase
# .toolName = "exit_plan_mode".
#
# The gate runs ONLY when the tool is a recognized plan-exit tool. If the name is
# empty (unknown/unparsed harness) or anything else, exit 0 — a reminder must
# never block an unrelated tool call. (The old `-n && != ExitPlanMode` test
# fell THROUGH on an empty name and blocked EVERY tool call in a Grok session
# whenever no fresh plan HTML existed — the exact bug this fixes.)
tool=$(printf '%s' "$input" | jq -r '(.tool_name // .toolName) // empty' 2>/dev/null) || tool=""
case "$tool" in
  ExitPlanMode|exit_plan_mode) ;;   # recognized plan-exit -> run the render gate below
  *) exit 0 ;;                       # empty / unknown / any other tool -> allow
esac

# A fresh plan HTML rendered in the last 90 min satisfies the gate. Covers both the
# canonical `/tmp/plan-<slug>.html` and the `<slug>-plan.html` scratchpad convention.
# Scan root is /tmp (where the recipe renders); overridable for tests.
# -L: follow symlinks. On macOS /tmp is a symlink to /private/tmp, and BSD find
# will NOT descend a symlinked start path without -L — so the gate could never
# detect a rendered plan on a Mac and blocked ExitPlanMode indefinitely.
scan_root="${PLAN_HTML_SCAN_ROOT:-/tmp}"
if find -L "$scan_root" -maxdepth 6 \( -name 'plan-*.html' -o -name '*-plan.html' \) -mmin -90 \
     -print -quit 2>/dev/null | grep -q .; then
  exit 0
fi

# No fresh render — remind, and block this one presentation.
cat >&2 <<'MSG'
Present this plan as browser-ready HTML before finishing (plan-presentation rule).

Load the `plan-render` skill and:
  1. Render a self-contained HTML plan to /tmp/plan-<slug>.html — house structure
     (hero, TOC, >=1 hand-authored inline-SVG diagram, callouts, tagged tables),
     skinned in the target product's brand (dark+light editorial fallback + toggle).
     Start from the skill's template.html; example.html is the gold reference.
  2. Open it on the user's default browser on the online macOS device (Host & Fleet):
     scp /tmp/plan-<slug>.html <host>:/tmp/ && agents ssh <host> 'open /tmp/plan-<slug>.html'
     (resolve the host from `agents devices` — never hardcode one).
  3. Then call ExitPlanMode again — this check passes once the HTML exists.

Headless fleet with no reachable browser host: still render the HTML (that clears this
gate); just say you could not open it.
MSG
exit 2
