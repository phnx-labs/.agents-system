---
name: git-workflow
description: "Run PR-bound work in an isolated git worktree instead of mutating the user's checkout. The full worktree lifecycle — create a branch under <repo>/.agents/worktrees/<slug>/ from the real default branch, implement and verify end-to-end inside it, open a PR, wait for review, then clean up after merge. Use whenever a task will produce a pull request, or when you need to create a branch/worktree. Triggers on: open a PR, create a worktree, PR-bound work, branch for a feature, ship a change as a PR."
argument-hint: "[task-slug]"
allowed-tools: Bash(git*), Bash(gh*)
user-invocable: true
---

# Agentic Git Workflow

PR-bound work runs in an **isolated worktree**, never in the user's checkout. The
behavioral invariants live in the always-on `git-workflow` rule; this skill is the
procedure that backs them.

## Why a worktree (not a branch in place)

`checkout`, `switch`, `branch`, `reset` are on the `git-readonly` deny list — fast,
irreversible, and the cause of real agent-driven data loss. `git worktree add` is the
**allowed** branch-creation path and it's isolated: it never touches the user's working
tree. So you get a fresh branch without `checkout`/`branch`.

Do **not** `checkout main` or `git pull` first — `pull` mutates the current checkout.
Refresh remote state with `git fetch` and base the worktree on `origin/<default-branch>`.

## 1. Create the worktree

**Slug:** kebab-case from the task (`fix-auth-refresh`); doubles as the branch name.
Resolve the default branch dynamically — never hardcode `main` (repos use `master`,
`trunk`, etc.).

```bash
REPO=$(git rev-parse --show-toplevel)
SLUG=fix-auth-refresh
WT="$REPO/.agents/worktrees/$SLUG"
git -C "$REPO" remote set-head origin --auto
BASE=$(git -C "$REPO" symbolic-ref --short refs/remotes/origin/HEAD | sed 's#^origin/##')
git -C "$REPO" fetch origin "$BASE"
git -C "$REPO" worktree add -b "$SLUG" "$WT" "origin/$BASE"
```

## 2. Work end-to-end inside `$WT`

Implement → test → verify the real flow (per core-hard-lines #1) → commit → push — all
inside `$WT`. Don't bounce back to the primary checkout. The deny list still applies
here: no `reset` / `rebase` / `stash`.

```bash
# edit, then:
git -C "$WT" add -A
git -C "$WT" commit -m "…"
git -C "$WT" push -u origin "$SLUG"
```

## 3. Open the PR

```bash
gh -R <owner/repo> pr create --base "$BASE" --head "$SLUG" --title "…" --body "…"
```

PR open is **not** "done." Post the URL and ask via `AskUserQuestion`
(merge / request changes / iterate). Iterate inside the same `$WT`. Don't remove the
worktree or delete the branch until merge.

## 4. After merge — clean up

```bash
git -C "$REPO" worktree remove "$WT"
git -C "$REPO" branch -D "$SLUG"
git -C "$REPO" fetch --prune
```

## Boundaries

- Worktrees live **only** under `<repo>/.agents/worktrees/`. Never elsewhere.
- Never dodge the `git-readonly` deny list inside `$WT`.
- To attach the session transcript to the PR, see the `sessions` skill.
