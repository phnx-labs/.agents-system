#!/usr/bin/env bash
# Test for main-branch-guard.sh (PreToolUse guard on file tools + Bash).
#
# Exercises the real script over real stdin JSON against REAL throwaway git
# repos (no mocking): a repo on its default branch (deny), a repo on a feature
# branch (allow), a cloned repo whose default is `trunk` via origin/HEAD (deny),
# and a non-git dir (allow). Verifies both the Write/Edit/NotebookEdit path and
# the `git commit|add` Bash path.
set -u
DIR=$(cd "$(dirname "$0")" && pwd)
GUARD="$DIR/main-branch-guard.sh"
pass=0
fail=0

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
export GIT_CONFIG_NOSYSTEM=1
export HOME="$TMP/home"; mkdir -p "$HOME"   # isolate from user gitconfig

git_q() { git -c user.email=t@t.dev -c user.name=t -c init.defaultBranch=main "$@" >/dev/null 2>&1; }

# 1. Repo on default branch `main` (no remote -> exercises main/master fallback).
MAIN_REPO="$TMP/main_repo"
mkdir -p "$MAIN_REPO"; git_q -C "$MAIN_REPO" init
git_q -C "$MAIN_REPO" commit --allow-empty -m init
mkdir -p "$MAIN_REPO/sub"; echo x > "$MAIN_REPO/tracked.txt"

# 2. Repo on a feature branch (no remote -> not main/master -> allow).
FEAT_REPO="$TMP/feat_repo"
mkdir -p "$FEAT_REPO"; git_q -C "$FEAT_REPO" init
git_q -C "$FEAT_REPO" commit --allow-empty -m init
git_q -C "$FEAT_REPO" checkout -b feat/x
echo x > "$FEAT_REPO/tracked.txt"

# 3. Cloned repo whose default branch is `trunk` (exercises origin/HEAD path).
BARE="$TMP/origin.git"
git_q init --bare -b trunk "$BARE"
CLONE="$TMP/clone"
git_q clone "$BARE" "$CLONE"
git_q -C "$CLONE" commit --allow-empty -m init
git_q -C "$CLONE" push -u origin trunk
git_q -C "$CLONE" remote set-head origin trunk
echo x > "$CLONE/tracked.txt"
# feature branch inside the same clone (default is trunk, so this must allow)
CLONE_FEAT="$TMP/clone_feat"
git_q clone "$BARE" "$CLONE_FEAT"
git_q -C "$CLONE_FEAT" remote set-head origin trunk
git_q -C "$CLONE_FEAT" checkout -b feat/y

# 4. Plain non-git directory.
NOGIT="$TMP/plain"; mkdir -p "$NOGIT"; echo x > "$NOGIT/file.txt"

# 5. A REAL linked worktree off MAIN_REPO, on a feature branch (allow).
WT_LINK="$TMP/wt_link"
git_q -C "$MAIN_REPO" worktree add -b wt-feat "$WT_LINK"
echo x > "$WT_LINK/tracked.txt"

# 6. Clone whose default is `trunk` (origin/HEAD) but checked out on a local
#    `main` branch — must be protected by the main/master clause (stale/mispointed
#    origin/HEAD must never expose main).
CLONE_MAIN="$TMP/clone_main"
git_q clone "$BARE" "$CLONE_MAIN"
git_q -C "$CLONE_MAIN" remote set-head origin trunk
git_q -C "$CLONE_MAIN" checkout -b main

# run_guard <want_exit> <desc> <json>
run_guard() {
  want=$1; desc=$2; json=$3
  printf '%s' "$json" | "$GUARD" >/dev/null 2>&1
  got=$?
  if [ "$got" -eq "$want" ]; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    printf 'FAIL: %s (want exit %s, got %s)\n' "$desc" "$want" "$got"
  fi
}

wj() { # write-tool json: <tool> <field> <path> [cwd]
  jq -n --arg t "$1" --arg f "$2" --arg p "$3" --arg cwd "${4:-}" \
    '{tool_name:$t, cwd:$cwd, tool_input:{($f):$p}}'
}
bj() { # bash json: <cmd> [cwd]
  jq -n --arg c "$1" --arg cwd "${2:-}" '{tool_name:"Bash", cwd:$cwd, tool_input:{command:$c}}'
}

# --- File tools: DENY on default branch (exit 2) ---
run_guard 2 "Write tracked file on main"        "$(wj Write file_path "$MAIN_REPO/tracked.txt")"
run_guard 2 "Write NEW file in new subdir on main" "$(wj Write file_path "$MAIN_REPO/sub/new/deep.txt")"
run_guard 2 "Edit file on main"                  "$(wj Edit file_path "$MAIN_REPO/tracked.txt")"
run_guard 2 "NotebookEdit on main"               "$(wj NotebookEdit notebook_path "$MAIN_REPO/nb.ipynb")"
run_guard 2 "Write on cloned trunk default"      "$(wj Write file_path "$CLONE/tracked.txt")"
run_guard 2 "Write relative path, cwd on main"   "$(wj Write file_path "tracked.txt" "$MAIN_REPO")"

# --- File tools: ALLOW off default branch / non-git (exit 0) ---
run_guard 0 "Write on feature branch"            "$(wj Write file_path "$FEAT_REPO/tracked.txt")"
run_guard 0 "Write on clone feature branch"      "$(wj Write file_path "$CLONE_FEAT/z.txt")"
run_guard 0 "Write in non-git dir"               "$(wj Write file_path "$NOGIT/file.txt")"
run_guard 0 "Write to /tmp scratch"              "$(wj Write file_path "$TMP/loose.txt")"

# --- Bash git commit/add: DENY on default branch (exit 2) ---
run_guard 2 "git -C main commit"                 "$(bj "git -C $MAIN_REPO commit -m x")"
run_guard 2 "git commit, cwd on main"            "$(bj "git commit -m x" "$MAIN_REPO")"
run_guard 2 "git add, cwd on main"               "$(bj "git add ." "$MAIN_REPO")"
run_guard 2 "git -C clone(trunk) commit"         "$(bj "git -C $CLONE commit -m x")"
run_guard 2 "sh -c wrapped commit on main"       "$(bj "sh -c \"git -C $MAIN_REPO commit -m x\"")"
run_guard 2 "chained cd/commit on main"          "$(bj "echo hi && git commit -m x" "$MAIN_REPO")"

# --- Bash git commit/add: ALLOW off default branch / non-gated ops (exit 0) ---
run_guard 0 "git -C feat commit"                 "$(bj "git -C $FEAT_REPO commit -m x")"
run_guard 0 "git commit on clone feature branch" "$(bj "git commit -m x" "$CLONE_FEAT")"
run_guard 0 "git status on main (not gated)"     "$(bj "git status" "$MAIN_REPO")"
run_guard 0 "git push on main (not gated here)"  "$(bj "git push" "$MAIN_REPO")"
run_guard 0 "git commit in non-git cwd"          "$(bj "git commit -m x" "$NOGIT")"
run_guard 0 "non-git bash on main (fast path)"   "$(bj "echo hello" "$MAIN_REPO")"
run_guard 0 "ls with no git token"               "$(bj "ls -la" "$MAIN_REPO")"

# --- Extra edge cases (from review) ---
run_guard 0 "Write in real linked worktree (feat)" "$(wj Write file_path "$WT_LINK/tracked.txt")"
run_guard 0 "git commit in real linked worktree"   "$(bj "git commit -m x" "$WT_LINK")"
run_guard 2 "git -C <relative> commit, cwd=TMP"    "$(bj "git -C main_repo commit -m x" "$TMP")"
run_guard 2 "local 'main' under trunk-default clone" "$(bj "git commit -m x" "$CLONE_MAIN")"
run_guard 2 "Write on local 'main' under trunk default" "$(wj Write file_path "$CLONE_MAIN/f.txt")"

printf -- '---\nmain-branch-guard: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
