# Agentic Git Workflow

## Use worktrees for PR work

PR-bound work goes in `<repo>/.agents/worktrees/<slug>/`. Don't create a branch in place. Don't switch the user's checkout. Don't ask the user to run git for you. Normal branch commands are denied; create the task branch only as part of `git worktree add -b` into this directory.

**Why:** `checkout`, `switch`, `branch`, `reset` are on the `git-readonly` deny list. `git worktree add` is the allowed branch-creation path, and it is isolated. Do not `checkout main` or `git pull` before creating the worktree; `pull` mutates the current checkout. Refresh remote state with `git fetch` and create the worktree from `origin/<default-branch>`.

**Slug:** kebab-case from the task (`fix-auth-refresh`). Doubles as the branch name.

```bash
REPO=$(git rev-parse --show-toplevel)
SLUG=fix-auth-refresh
WT="$REPO/.agents/worktrees/$SLUG"
git -C "$REPO" remote set-head origin --auto
BASE=$(git -C "$REPO" symbolic-ref --short refs/remotes/origin/HEAD | sed 's#^origin/##')
git -C "$REPO" fetch origin "$BASE"
git -C "$REPO" worktree add -b "$SLUG" "$WT" "origin/$BASE"
# work, commit, push inside $WT
git -C "$WT" push -u origin "$SLUG"
gh -R <owner/repo> pr create --base "$BASE" --head "$SLUG" --title "…" --body "…"
```

## End-to-end inside the worktree

Implement → test → verify (real flow per core-hard-lines #1) → commit → push → open PR — all inside `$WT`. Don't bounce back to the primary checkout.

## After PR: wait for review

PR open is **not** "done." Post the URL, ask via `AskUserQuestion` (merge / request changes / iterate). Iterate inside the same `$WT`. Don't remove the worktree or delete the branch until merge.

## After merge

```bash
git -C $REPO worktree remove $WT
git -C $REPO branch -D $SLUG
git -C $REPO fetch --prune
```

**Don't:** put worktrees outside `<repo>/.agents/worktrees/`. Don't dodge the deny list inside `$WT` (`reset`/`rebase`/`stash` still off-limits). For PR session-gist export, see the `git-session-export` skill.
