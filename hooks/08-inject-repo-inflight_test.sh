#!/usr/bin/env bash
# Tests for 08-inject-repo-inflight.sh — the SessionStart in-flight injection.
# gh and agents are stubbed via PATH shims; no network, no real session state.
# The agents stub emits the real `agents sessions --active --json` row shape.

HERE="$(cd "$(dirname "$0")" && pwd)"
HOOK="$HERE/08-inject-repo-inflight.sh"

SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT

fail=0
check_contains() { if printf '%s' "$2" | grep -qF "$3"; then echo "ok   - $1"; else echo "FAIL - $1: output missing [$3]"; fail=1; fi; }
check_absent()   { if printf '%s' "$2" | grep -qF "$3"; then echo "FAIL - $1: output contains [$3]"; fail=1; else echo "ok   - $1"; fi; }
check_empty()    { if [ -z "$2" ]; then echo "ok   - $1"; else echo "FAIL - $1: expected empty output, got [$2]"; fail=1; fi; }

run_hook() {   # $1 = cwd to report, $2 = session_id of the starting session
  printf '{"cwd": "%s", "session_id": "%s"}' "$1" "${2:-}" | bash "$HOOK" 2>/dev/null
}

# --- stubs -------------------------------------------------------------------
mkdir -p "$SANDBOX/bin"
cat > "$SANDBOX/bin/gh" <<'STUB'
#!/usr/bin/env bash
printf -- '- #12 fix the frobnicator (fix-frob)\n- #13 [draft] new dashboard (dash-v2)\n'
STUB
# JSON rows: this repo, one of its worktrees, the sibling whose path has the
# repo path as a string prefix (agents vs agents-cli), an unrelated repo, and
# the session that is itself starting (must be dropped).
cat > "$SANDBOX/bin/agents" <<'STUB'
#!/usr/bin/env bash
case "$*" in
  *--json*--local*|*--local*--json*) : ;;
  *) echo "stub: expected --json --local, got: $*" >&2; exit 1 ;;
esac
cat <<EOF
[
  {"sessionId": "aaaa1111-0000", "kind": "claude", "cwd": "${FAKE_REPO}-cli", "status": "running", "activity": "idle", "topic": "sibling repo session"},
  {"sessionId": "bbbb2222-0000", "kind": "claude", "cwd": "${FAKE_REPO}", "status": "running", "activity": "working", "topic": "this repo session"},
  {"sessionId": "cccc3333-0000", "kind": "codex", "cwd": "${FAKE_REPO}/.agents/worktrees/feat-x", "status": "running", "activity": "working", "topic": "worktree session"},
  {"sessionId": "dddd4444-0000", "kind": "claude", "cwd": "/somewhere/else", "status": "running", "activity": "idle", "topic": "unrelated repo"},
  {"sessionId": "self0000-0000", "kind": "claude", "cwd": "${FAKE_REPO}", "status": "running", "activity": "working", "topic": "the session being started"}
]
EOF
STUB
chmod +x "$SANDBOX/bin/gh" "$SANDBOX/bin/agents"
export PATH="$SANDBOX/bin:$PATH"

# --- 1. non-git cwd: silent -----------------------------------------------
mkdir -p "$SANDBOX/plain-dir"
out=$(run_hook "$SANDBOX/plain-dir")
check_empty "non-git cwd stays silent" "$out"

# --- 2. git repo with open PRs + sessions: injects the block -----------------
REPO="$SANDBOX/repo"
mkdir -p "$REPO"
git -C "$REPO" init -q
# The hook resolves the repo via `git rev-parse --show-toplevel`, which returns
# the physical path (/private/var/... on macOS, not the /var/... symlink the
# sandbox path carries). The stub's session cwds must use the same form.
REPO="$(git -C "$REPO" rev-parse --show-toplevel)"
export FAKE_REPO="$REPO"
out=$(run_hook "$REPO" "self0000-0000")
check_contains "header present" "$out" "In-flight in this repo"
check_contains "PR list injected" "$out" "#12 fix the frobnicator"
check_contains "draft marker preserved" "$out" "[draft] new dashboard"
check_contains "this repo's session listed" "$out" "bbbb2222"
check_contains "worktree session listed" "$out" "cccc3333"
check_absent   "sibling repo (path-prefix collision) excluded" "$out" "aaaa1111"
check_absent   "unrelated repo excluded" "$out" "dddd4444"
check_absent   "the starting session itself excluded" "$out" "self0000"

# --- 3. gh absent, no active sessions: silent, exit 0 -------------------------
rm "$SANDBOX/bin/gh"
cat > "$SANDBOX/bin/agents" <<'STUB'
#!/usr/bin/env bash
echo "[]"
STUB
chmod +x "$SANDBOX/bin/agents"
out=$(run_hook "$REPO"); rc=$?
[ "$rc" = "0" ] && echo "ok   - missing gh exits 0" || { echo "FAIL - missing gh rc=$rc"; fail=1; }
check_empty "missing gh with no sessions stays silent" "$out"

exit $fail
