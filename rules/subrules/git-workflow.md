# Agentic Git Workflow

## Start work in a worktree, not the current checkout

When you start a task that will produce a PR, create a **worktree**. Don't create a branch in place, don't switch the current checkout, don't ask the user to do it.

**Where worktrees live:** `<repo>/.agents/worktrees/<slug>/`. `.agents/` is the standard agent-state directory and is the only sanctioned location — never `/tmp`, never sibling dirs (`../repo.worktree-foo`), never ad-hoc parent paths.

**Slug:** short kebab-case derived from the task (`fix-auth-refresh`, `feat-tunnel-picker`). It doubles as the branch name — the branch is metadata, the worktree is the thing.

**Why a worktree:**
- `checkout`, `switch`, `branch`, `reset` are on the [[git-readonly]] deny list — agents can't run them without prompting.
- `git worktree add` is allowed and creates an isolated working directory at HEAD without touching the user's primary checkout.

### Recipe

```bash
REPO=$(git rev-parse --show-toplevel)
SLUG=fix-auth-refresh
WT=$REPO/.agents/worktrees/$SLUG

# One-time per repo: make sure .agents/worktrees/ won't pollute git/tooling.
grep -q '^\.agents/worktrees/' $REPO/.gitignore 2>/dev/null \
  || echo '.agents/worktrees/' >> $REPO/.gitignore

git -C $REPO fetch origin main
git -C $REPO worktree add -b $SLUG $WT origin/main

# Work inside $WT for the entire task — edit, build, test, commit there.
git -C $WT add <files>
git -C $WT commit -m "<conventional message>"
git -C $WT push -u origin $SLUG
gh -R <owner/repo> pr create --base main --head $SLUG --title "…" --body "…"
```

## Work end-to-end inside the worktree

The worktree is your workspace for the whole task. Implement → test → verify end-to-end (see core-hard-lines #1) → commit → push → open PR — all inside `$WT`. Don't stop early, don't bounce back to the primary checkout mid-task, don't hand it off.

## After PR is open: ask for review, do not clean up

The PR being open is **not** "done." Until merge:

- Post the PR URL and summarize what changed.
- Ask the user for review with `AskUserQuestion` (e.g. `merge / request changes / iterate`).
- If review asks for changes, iterate inside the same `$WT` — additional commits, `git push`.
- Do **not** remove the worktree. Do **not** delete the branch. Do **not** claim the task is done.

## After merge: only then, close it out

Once the PR is merged, the worktree is disposable:

```bash
git -C $REPO worktree remove $WT
git -C $REPO branch -D $SLUG     # merged-branch deletion is allowed
git -C $REPO fetch --prune
```

Cleanup happens **after merge confirmation**, never before.

## Don't

- Don't fall back to "please run `git checkout -b` for me." `worktree add` works — use it.
- Don't put worktrees in `/tmp`, sibling dirs, or anywhere except `<repo>/.agents/worktrees/`.
- Don't delete the worktree before merge — the reviewer may ask for changes.
- Don't use the worktree to dodge the deny list for `reset`/`rebase`/`stash` — those are still off-limits inside `$WT` too.

## Session export on PRs

Every PR includes a session transcript as a SECRET GitHub Gist.

```bash
agents sessions --last 50 --markdown > /tmp/session-export.md
gh gist create /tmp/session-export.md --desc "Session transcript for PR"
```

Never `--public` by default — transcripts can leak repo internals, tool output, infra details. Only `--public` when the target repo is public AND the transcript is reviewed.

Attach the gist URL in the PR description:

```
## Session Context
[Session transcript](https://gist.github.com/...)
```

Secret gists are URL-only access — not indexed, not discoverable. Creates an audit trail linking code to reasoning.
