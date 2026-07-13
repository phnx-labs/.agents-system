#!/usr/bin/env bash
# SessionStart hook: inject the repo's in-flight state — open PRs and other
# active agent sessions in this checkout — so an agent sees what is already
# owned before it spawns teammates, adopts work, or opens a PR.
#
# AX-by-injection: the doctrine checkpoint "check before you take work" is
# delivered as state at session start instead of an instruction the agent
# has to remember to follow. Prevents the observed failure modes:
#   - two agents opening duplicate PRs for the same scope
#   - taking over a surface another live session is mid-flight on
#
# Fail-open everywhere: no git repo, no gh, no agents CLI, network down,
# timeouts — all exit 0 silently. stdout becomes injected session context.
set -euo pipefail

# Portable timeout: macOS ships neither `timeout` nor `gtimeout` by default.
# Fall back to running the command bare — the manifest-level hook timeout is
# the real backstop; this helper only tightens individual network calls.
_to() {
  if command -v timeout >/dev/null 2>&1; then timeout "$@"
  elif command -v gtimeout >/dev/null 2>&1; then gtimeout "$@"
  else shift; "$@"
  fi
}

input="$(cat)"

cwd="$(printf '%s' "$input" | python3 -c 'import json,sys
try:
    print(json.load(sys.stdin).get("cwd","") or "")
except Exception:
    print("")' 2>/dev/null || true)"
[ -z "$cwd" ] && exit 0
[ -d "$cwd" ] || exit 0

command -v git >/dev/null 2>&1 || exit 0
repo="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || true)"
[ -z "$repo" ] && exit 0

prs=""
if command -v gh >/dev/null 2>&1; then
  prs="$(cd "$repo" 2>/dev/null && _to 4 gh pr list --state open --limit 10 \
    --json number,title,headRefName,isDraft \
    --template '{{range .}}- #{{.number}} {{if .isDraft}}[draft] {{end}}{{.title}} ({{.headRefName}}){{"\n"}}{{end}}' \
    2>/dev/null || true)"
fi

# Other active agent sessions working in this checkout (incl. its worktrees).
# `agents sessions --active` groups sessions under directory headers; capture
# the blocks whose header contains this repo's path (absolute or ~-relative).
sessions=""
if command -v agents >/dev/null 2>&1; then
  repo_tilde="${repo/#$HOME/\~}"
  sessions="$(_to 5 agents sessions --active 2>/dev/null | awk -v abs="$repo" -v til="$repo_tilde" '
    # Header lines start with a path token. Match on path BOUNDARIES so that
    # repo "…/agents" does not swallow "…/agents-cli": exact match, or the
    # header path continues with "/" (a worktree or subdir of this repo).
    /^[[:space:]]*[~\/]/ {
      p = $1
      inblock = (p == abs || p == til || index(p, abs "/") == 1 || index(p, til "/") == 1)
      if (inblock) print
      next
    }
    inblock && /^[[:space:]]+[0-9a-f-]/ { print; next }
    /^[^[:space:]]/ { inblock = 0 }
  ' | head -12 || true)"
fi

[ -z "$prs" ] && [ -z "$sessions" ] && exit 0

echo "## In-flight in this repo (auto-injected)"
echo
echo "Work that already exists here. Before opening a PR, spawning agents, or"
echo "adopting a task: don't duplicate an open PR's scope, and don't take over"
echo "a live session's surface without checking what it is doing."
if [ -n "$prs" ]; then
  echo
  echo "Open PRs:"
  printf '%s\n' "$prs"
fi
if [ -n "$sessions" ]; then
  echo
  echo "Active sessions in this checkout:"
  printf '%s\n' "$sessions"
fi

exit 0
