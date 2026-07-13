#!/usr/bin/env bash
# Tests for 08-inject-repo-inflight.sh — the SessionStart in-flight injection.
# gh and agents are stubbed via PATH shims; no network, no real session state.

HERE="$(cd "$(dirname "$0")" && pwd)"
HOOK="$HERE/08-inject-repo-inflight.sh"

SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT

fail=0
check_contains() { if printf '%s' "$2" | grep -qF "$3"; then echo "ok   - $1"; else echo "FAIL - $1: output missing [$3]"; fail=1; fi; }
check_empty()    { if [ -z "$2" ]; then echo "ok   - $1"; else echo "FAIL - $1: expected empty output, got [$2]"; fail=1; fi; }

run_hook() {   # $1 = cwd to report
  printf '{"cwd": "%s"}' "$1" | bash "$HOOK" 2>/dev/null
}

# --- stubs -------------------------------------------------------------------
mkdir -p "$SANDBOX/bin"
cat > "$SANDBOX/bin/gh" <<'STUB'
#!/usr/bin/env bash
printf -- '- #12 fix the frobnicator (fix-frob)\n- #13 [draft] new dashboard (dash-v2)\n'
STUB
cat > "$SANDBOX/bin/agents" <<'STUB'
#!/usr/bin/env bash
# Two directory blocks: one for the test repo, one for a sibling whose path
# has the repo path as a string prefix (the agents vs agents-cli collision).
cat <<EOF
  ${FAKE_REPO}-cli (2)  2 idle
    aaaa1111 claude   tmux     idle     other repo session
  ${FAKE_REPO} (1)  1 running
    bbbb2222 claude   tmux     working  this repo session
EOF
STUB
chmod +x "$SANDBOX/bin/gh" "$SANDBOX/bin/agents"
export PATH="$SANDBOX/bin:$PATH"

# --- 1. non-git cwd: silent -----------------------------------------------
mkdir -p "$SANDBOX/plain-dir"
out=$(run_hook "$SANDBOX/plain-dir")
check_empty "non-git cwd stays silent" "$out"

# --- 2. git repo with open PRs: injects the block ---------------------------
REPO="$SANDBOX/repo"
mkdir -p "$REPO"
git -C "$REPO" init -q
# The hook resolves the repo via `git rev-parse --show-toplevel`, which returns
# the physical path (/private/var/... on macOS, not the /var/... symlink the
# sandbox path carries). The stub's headers must use the same form.
REPO="$(git -C "$REPO" rev-parse --show-toplevel)"
export FAKE_REPO="$REPO"
out=$(run_hook "$REPO")
check_contains "header present" "$out" "In-flight in this repo"
check_contains "PR list injected" "$out" "#12 fix the frobnicator"
check_contains "draft marker preserved" "$out" "[draft] new dashboard"
check_contains "this repo's session listed" "$out" "bbbb2222"
if printf '%s' "$out" | grep -qF "aaaa1111"; then
  echo "FAIL - prefix-collision: sibling repo session leaked in"; fail=1
else
  echo "ok   - sibling repo (path-prefix collision) excluded"
fi

# --- 3. gh absent, no active sessions: silent, exit 0 -------------------------
rm "$SANDBOX/bin/gh"
cat > "$SANDBOX/bin/agents" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
out=$(run_hook "$REPO"); rc=$?
[ "$rc" = "0" ] && echo "ok   - missing gh exits 0" || { echo "FAIL - missing gh rc=$rc"; fail=1; }
check_empty "missing gh with no sessions stays silent" "$out"

exit $fail
