#!/bin/sh
# 08-register-session-pid.sh — SessionStart hook (Claude / Codex / Kimi / Grok /
# Antigravity).
#
# Records the live session id of THIS agent process into the per-pid registry
# (~/.agents/.cache/terminals/by-pid/<pid>.json) so `ag sessions --active` can
# map a ps-discovered pid to its EXACT session instead of guessing the newest
# transcript in the cwd — the guess that collapses N co-located agents onto one
# row on hosts with no terminal extension.
#
# Complements the `ag run` launcher write in agents-cli: the launcher records
# {agent,cwd,tmuxPane} at spawn (and the sessionId for Claude, which it assigns
# via --session-id). This hook fills in the real sessionId for agents whose id
# is generated INTERNALLY — Codex, Kimi, Grok, Antigravity — by updating the
# launcher's entry once the agent knows its own id at SessionStart.
#
# Session id delivery differs per agent (verified against each vendor's hook
# docs): stdin SessionStart JSON `session_id` for Claude / Codex / Kimi /
# Antigravity; `$GROK_SESSION_ID` env for Grok; `$GEMINI_SESSION_ID` /
# `$CLAUDE_SESSION_ID` as further env fallbacks.
#
# PLATFORM: the ancestor-pid resolution reads /proc (Linux). This hook exists
# for headless / no-extension hosts (SSH/tmux) — exactly where the collapse
# happens. On macOS the terminal extension already writes live-terminals.json
# with each session's real id, so `ag sessions` needs no hook there; without
# /proc the ancestor walk simply no-ops (fails safe), which is correct.
#
# BLAST RADIUS: runs on every agent session start. It must never abort or delay
# the session. No `set -e`; all failures exit 0 with no output; the only side
# effect is a best-effort registry write.

# SessionStart payloads are small and bounded (session_id, transcript_path,
# cwd, event name — well under 1KB), so passing it as a single argv is safe and
# keeps the script quote-agnostic (a `-c` string would break on any apostrophe
# in a comment).
input="$(cat 2>/dev/null || true)"

python3 - "$input" <<'PY' 2>/dev/null || true
import json, os, sys, time

raw = sys.argv[1] if len(sys.argv) > 1 else ""
sid, cwd = "", ""
try:
    d = json.loads(raw) if raw.strip() else {}
    if isinstance(d, dict):
        sid = d.get("session_id") or ""
        cwd = d.get("cwd") or ""
except Exception:
    pass

# Env fallbacks — Grok delivers the id only via env; the others expose one too.
if not sid:
    for k in ("GROK_SESSION_ID", "GEMINI_SESSION_ID", "CLAUDE_SESSION_ID"):
        if os.environ.get(k):
            sid = os.environ[k]
            break

if not sid:
    sys.exit(0)  # no id to record — stay silent, never break the session

if not cwd:
    cwd = os.environ.get("GEMINI_CWD") or os.getcwd()

reg_dir = os.path.join(os.path.expanduser("~"), ".agents", ".cache", "terminals", "by-pid")

def ppid_of(pid):
    # Linux /proc: ppid is field 4; comm (field 2) may contain spaces/parens,
    # so split on the LAST ')'.
    try:
        with open("/proc/%d/stat" % pid) as f:
            after = f.read().rsplit(")", 1)[1].split()
        return int(after[1])
    except Exception:
        return 0

# Resolve the AGENT process pid: walk ancestors and prefer the first that
# already has a launcher-written registry file (that IS the agent process).
# Fall back to our immediate parent when none is found (agent not run via ag run).
agent_pid = os.getppid()
cur, seen = agent_pid, 0
while cur and cur > 1 and seen < 25:
    if os.path.exists(os.path.join(reg_dir, "%d.json" % cur)):
        agent_pid = cur
        break
    cur = ppid_of(cur)
    seen += 1

path = os.path.join(reg_dir, "%d.json" % agent_pid)
entry = {
    "pid": agent_pid,
    "agent": "",
    "sessionId": sid,
    "cwd": cwd,
    "tmuxPane": os.environ.get("TMUX_PANE", ""),
    "startedAtMs": int(time.time() * 1000),
}
# Merge over the launcher's entry: the launcher's agent/cwd/tmuxPane/startedAtMs
# are authoritative (recorded at spawn) and WIN — sessionId is the only field
# this hook owns. So the agent cd-ing after start can't rewrite the registry cwd
# that active.ts uses to locate the transcript.
try:
    with open(path) as f:
        prev = json.load(f)
    if isinstance(prev, dict):
        for k in ("agent", "cwd", "tmuxPane", "startedAtMs"):
            if prev.get(k):
                entry[k] = prev[k]
except Exception:
    pass
# If we still have no agent label, infer from which env var carried the id.
if not entry["agent"]:
    if os.environ.get("GROK_SESSION_ID"):
        entry["agent"] = "grok"
    elif os.environ.get("CLAUDE_SESSION_ID"):
        entry["agent"] = "claude"

try:
    os.makedirs(reg_dir, exist_ok=True)
    tmp = path + ".tmp"
    with open(tmp, "w") as f:
        json.dump(entry, f)
    os.replace(tmp, path)
except Exception:
    pass
PY
exit 0
