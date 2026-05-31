---
description: Delete merged branches and worktrees locally and on origin. Conservative — never removes work that could be lost.
---

Clean up merged branches and worktrees. Arguments (optional): $ARGUMENTS

## Safety first

This command is allowed to be conservative. It is NOT allowed to lose work. A worktree that lingers another day is a trivial inconvenience. A worktree removed with unpushed commits, uncommitted edits, or a stash is hours of lost work that may not be recoverable.

**Default to skip. Only remove when you have positive proof that nothing in the worktree could be lost.**

A worktree may be removed only when ALL of these are true:

1. It is not the main worktree (the one this command is running from).
2. It is not `locked` (per `git worktree list --porcelain`).
3. It is not on a detached HEAD.
4. `git -C <path> status --porcelain` produces empty output.
5. `git -C <path> stash list` produces empty output.
6. `git -C <path> rev-list --count origin/$MAIN..HEAD` returns exactly `0` — every commit reachable from HEAD is already in `origin/$MAIN`.

If any check is uncertain — command fails, output is ambiguous — skip the worktree. The cost of skipping is zero; being wrong is irreversible.

A `prunable` worktree (working directory already gone) is the one exception — by definition nothing is left to lose. Run `git worktree prune` for it.

## Goal

- Locally: only `main` (or `master`) plus the current branch remain. Every other branch has been merged and is gone.
- On `origin`: same.
- Worktrees: only the main worktree and any worktree still in active use remain.
- Remotes: only `origin` is touched. Other remotes are left alone (warn but don't act).

## Process

### 1. Orient

Run in parallel:

- `git remote` — list remotes.
- `git branch -a` — list local and remote-tracking branches.
- `git status` — confirm working tree is clean (warn but don't stop if not).
- `git worktree list --porcelain` — every worktree with its branch, lock state, prunable flag.

Detect the default branch: check whether `main` exists; fall back to `master`. Call it `$MAIN`.

If `origin` is absent, stop and tell the user. If extra remotes exist, list them and warn — "I will only touch `origin`."

Parse worktrees into records: `{path, head, branch, locked, prunable, detached}`. The first record is the main worktree — never a removal candidate.

### 2. Sync

```bash
git fetch --prune origin
```

This deletes remote-tracking refs for branches already gone on the server.

### 3. Find merged branches

In parallel:

```bash
git branch --merged origin/$MAIN
git branch -r --merged origin/$MAIN
```

Filter out from both lists:

- `main`, `master`, `develop`, `HEAD`, and their `origin/` counterparts.
- Any branch currently checked out in any worktree (it cannot be `-d`-deleted while checked out, and we don't use `-D`).

Call the resulting set `merged_local_branches`.

### 4. Classify worktrees

Walk every worktree record except the main one. Apply checks in order; stop at the first match.

```
if record.locked:        skip — "locked: <reason>"
if record.prunable:      add to to_prune (working dir gone)
if record.detached:      skip — "detached HEAD"

# Live probes — if any command fails, treat as uncertain and skip.

run: git -C <path> status --porcelain
  command failed → skip "status check failed"
  non-empty      → skip "uncommitted changes: <first line>"

run: git -C <path> stash list
  command failed → skip "stash check failed"
  non-empty      → skip "stash present"

run: git -C <path> rev-list --count origin/$MAIN..HEAD
  command failed → skip "rev-list failed"
  not exactly 0  → skip "<N> commits not in origin/$MAIN (would be lost)"

all probes passed → add to to_remove
```

Build three lists: `to_remove[]`, `to_prune[]`, `to_skip[]`. For each entry record path, branch (if any), HEAD SHA (short), and the skip reason where applicable.

The `rev-list --count origin/$MAIN..HEAD == 0` check is the load-bearing one. It is strictly stricter than `--merged` — it catches squash-merged branches as "not safe to remove" (the original commits aren't byte-identical in main), which is the conservative direction. Don't weaken it.

### 5. Show the plan — do not act yet

Print a clear summary using a markdown layout (no ASCII boxes — they break on long paths):

```markdown
**Local branches to delete (merged into $MAIN):**
- feature/oauth-refresh
- fix/payment-null

**Remote branches to delete on origin:**
- origin/feature/oauth-refresh
- origin/fix/payment-null

**Worktrees to remove** (every commit already in origin/$MAIN):

| Path                            | Branch              | HEAD       | Ahead | Dirty | Stashes |
|---------------------------------|---------------------|------------|-------|-------|---------|
| /Users/.../worktrees/feature-a  | feature/a           | a97ae40    | 0     | no    | 0       |

**Worktrees to prune** (working dir missing):
- /private/tmp/old-worktree

**Worktrees skipped:**
- /Users/.../worktrees/agent-x — locked: agent running (pid 20923)
- /Users/.../worktrees/m1 — uncommitted changes: M src/main.go
- /Users/.../worktrees/b5 — 3 commits not in origin/$MAIN (would be lost)
```

Omit any section whose list is empty. If everything is empty, say "Nothing to clean up — already tidy." and stop.

### 6. Confirm

Use `AskUserQuestion` with two options:

- "Yes, delete them all"
- "Cancel"

Phrase with concrete counts: "Delete N branches and M worktrees (and prune P stale entries)?"

### 7. Execute

Order matters — a branch cannot be deleted while checked out in another worktree, so worktrees come first.

**7a. Remove worktrees on merged branches.** For each entry in `to_remove`:

```bash
git worktree remove <path>   # no --force — safe-fail leaves it for next run
```

**7b. Prune stale worktree admin files.** If `to_prune` is non-empty or any removal succeeded:

```bash
git worktree prune
```

**7c. Delete local merged branches:**

```bash
git branch -d <branch>   # safe delete — fails if unmerged, which shouldn't happen here
```

**7d. Delete remote merged branches** (strip `origin/` prefix):

```bash
git push origin --delete <branch>
```

If any individual operation fails, log it and continue with the rest.

### 8. Final prune and report

In parallel:

```bash
git remote prune origin
git branch -a
git worktree list
```

Report what was deleted, removed, pruned, skipped (with reasons), and what (if anything) failed.

## Safety rules

- Never delete `main`, `master`, `develop`, or `HEAD` — locally or remotely.
- Never delete the currently checked-out branch.
- Never force-delete (`git branch -D`). Only `-d`. If `-d` fails, skip.
- Never push `--force` or `--force-with-lease`.
- Never touch remotes other than `origin`.
- Never `git worktree remove --force`.
- Never remove a locked, detached, dirty, or unpushed worktree.
- Never substitute the data-loss probes (status, stash, rev-list) with a name lookup or "this looks merged." Run the commands and quote the output.

## Don'ts

- Don't skip the confirmation step, even if `$ARGUMENTS` contains "yes" or "force".
- Don't rebase, reset, or modify commit history.
- Don't delete branches not confirmed merged.
- Don't run `git worktree prune` before `git worktree remove` — order keeps the report honest.
- Don't try to "rescue" uncommitted changes by stashing or committing on behalf of the user. Skip and report.
