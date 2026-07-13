#!/usr/bin/env bash
# Tests for the open-PR abandonment gate in 00-agent-verify-work-complete.sh.
# The gate must block a Stop when the session created a PR that is still OPEN
# and the final message has no explicit handoff — and allow everything else.
#
# gh is stubbed via a PATH shim so no network is touched; the stub's reported
# PR state is driven by $FAKE_GH_STATE.

HERE="$(cd "$(dirname "$0")" && pwd)"
HOOK="$HERE/00-agent-verify-work-complete.sh"

SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT

# --- gh stub ---------------------------------------------------------------
mkdir -p "$SANDBOX/bin"
cat > "$SANDBOX/bin/gh" <<'STUB'
#!/usr/bin/env bash
# Minimal gh stub: `gh pr view <url> --json state --jq .state`
echo "${FAKE_GH_STATE:-OPEN}"
STUB
chmod +x "$SANDBOX/bin/gh"
export PATH="$SANDBOX/bin:$PATH"

fail=0
check() { if [ "$2" = "$3" ]; then echo "ok   - $1"; else echo "FAIL - $1: expected exit [$3] got [$2]"; fail=1; fi; }

# Build a transcript with enough assistant turns to pass the Q&A skip, a
# substantive first user message, and a gh pr create tool result carrying the
# PR URL on its own line (the created-PR signal the gate keys on).
mk_transcript() {   # $1 = include pr create (yes/no)
  local t="$SANDBOX/transcript-$RANDOM.jsonl"
  {
    echo '{"role":"user","content":"Please implement the widget feature and open a PR for it"}'
    echo '{"role":"assistant","content":"Working on it"}'
    if [ "$1" = "yes" ]; then
      echo '{"role":"tool","content":"$ gh pr create --title widget\nhttps://github.com/acme/widgets/pull/42\n"}'
    else
      echo '{"role":"tool","content":"reviewing https://github.com/acme/widgets/pull/42 for someone else"}'
    fi
    echo '{"role":"assistant","content":"step 2"}'
    echo '{"role":"assistant","content":"step 3"}'
  } > "$t"
  echo "$t"
}

run_hook() {   # $1 transcript, $2 last message, $3 stop_hook_active
  python3 - "$1" "$2" "$3" <<'PY' | bash "$HOOK" >/dev/null 2>"$SANDBOX/stderr"
import json, sys
print(json.dumps({
    "transcript_path": sys.argv[1],
    "last_assistant_message": sys.argv[2],
    "stop_hook_active": sys.argv[3] == "true",
}))
PY
  echo $?
}

# 1. Created PR, still OPEN, no handoff -> block (exit 2)
T=$(mk_transcript yes)
rc=$(FAKE_GH_STATE=OPEN run_hook "$T" "CI is green, waiting for the reviewer." false)
check "open PR without handoff blocks" "$rc" "2"
grep -q "STOP GATE" "$SANDBOX/stderr" && echo "ok   - block message names the gate" || { echo "FAIL - no gate message"; fail=1; }

# 2. Created PR, MERGED -> allow
rc=$(FAKE_GH_STATE=MERGED run_hook "$T" "All merged and verified." false)
check "merged PR allows stop" "$rc" "0"

# 3. Created PR, OPEN, but explicit handoff in final message -> allow
rc=$(FAKE_GH_STATE=OPEN run_hook "$T" "PR #42 is handed off to the release watcher, which owns the PR from here." false)
check "open PR with explicit handoff allows stop" "$rc" "0"

# 4. stop_hook_active -> allow (no loops)
rc=$(FAKE_GH_STATE=OPEN run_hook "$T" "still waiting" true)
check "stop_hook_active bypasses gate" "$rc" "0"

# 5. PR URL mentioned but session never ran pr create (review-only) -> allow
T2=$(mk_transcript no)
rc=$(FAKE_GH_STATE=OPEN run_hook "$T2" "Review finished, feedback posted." false)
check "reviewing someone else's PR does not block" "$rc" "0"

exit $fail
