#!/bin/sh
# Tests for 08-register-session-pid.sh — exercises the real script against each
# agent's documented SessionStart delivery shape.
#
# Strategy: the test process pre-writes a registry entry keyed by its OWN pid
# (simulating the `ag run` launcher's Layer-1 write), then runs the hook as a
# child. The hook walks its ancestor chain, finds the test's registry file, and
# must enrich it with the session id — exactly the launcher-then-enrich flow.

HERE="$(cd "$(dirname "$0")" && pwd)"
HOOK="$HERE/08-register-session-pid.sh"
REG="$HOME/.agents/.cache/terminals/by-pid"
SELF=$$
FILE="$REG/$SELF.json"
mkdir -p "$REG"

fail=0
seed() { printf '%s' "$1" > "$FILE"; }
sid_of() { python3 -c 'import json,sys;print(json.load(open(sys.argv[1])).get("sessionId",""))' "$FILE" 2>/dev/null; }
field()  { python3 -c 'import json,sys;print(json.load(open(sys.argv[1])).get(sys.argv[2],""))' "$FILE" "$1" 2>/dev/null; }
check()  { if [ "$2" = "$3" ]; then echo "ok   - $1"; else echo "FAIL - $1: expected [$3] got [$2]"; fail=1; fi; }

# T1: stdin session_id (Claude/Codex/Kimi/Antigravity) enriches the launcher entry
seed '{"pid":'"$SELF"',"agent":"codex","cwd":"/orig","tmuxPane":"%9"}'
echo '{"session_id":"sid-stdin","cwd":"/ignored"}' | sh "$HOOK"
check "stdin session_id recorded"        "$(sid_of)"        "sid-stdin"
check "launcher agent preserved on merge" "$(field agent)"  "codex"
check "launcher cwd preserved on merge"   "$(field cwd)"    "/orig"

# T2: Grok delivers the id only via env
seed '{"pid":'"$SELF"',"agent":"grok"}'
GROK_SESSION_ID="sid-grok" sh "$HOOK" < /dev/null
check "grok env session id recorded"      "$(sid_of)"        "sid-grok"
check "grok agent preserved"              "$(field agent)"   "grok"

# T3: no id anywhere -> must NOT invent one, entry left without a sessionId
seed '{"pid":'"$SELF"',"agent":"codex"}'
printf '' | sh "$HOOK"
check "empty stdin leaves no sessionId"   "$(sid_of)"        ""

# T4: malformed JSON -> exit 0, no sessionId
seed '{"pid":'"$SELF"',"agent":"codex"}'
echo 'not json {{' | sh "$HOOK"
check "malformed json leaves no sessionId" "$(sid_of)"       ""

# T5: no prior entry (agent not launched via ag run) — hook creates a fresh
# entry keyed by the parent pid and infers the agent from the env source. The
# new file is keyed by an ephemeral pid, so find it by before/after diff.
rm -f "$FILE"
ls "$REG" 2>/dev/null | sort > /tmp/reg-before.$$
GROK_SESSION_ID="sid-g2" sh "$HOOK" < /dev/null
ls "$REG" 2>/dev/null | sort > /tmp/reg-after.$$
newf="$(comm -13 /tmp/reg-before.$$ /tmp/reg-after.$$ | head -1)"
rm -f /tmp/reg-before.$$ /tmp/reg-after.$$
NEW="$REG/$newf"
check "no prior entry: grok inferred"     "$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1])).get("agent",""))' "$NEW" 2>/dev/null)"     "grok"
check "no prior entry: id recorded"       "$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1])).get("sessionId",""))' "$NEW" 2>/dev/null)" "sid-g2"
[ -n "$newf" ] && rm -f "$NEW"

rm -f "$FILE"
[ "$fail" = 0 ] && echo "ALL PASS" || echo "SOME FAILED"
exit "$fail"
