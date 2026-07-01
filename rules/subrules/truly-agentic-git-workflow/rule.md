# Truly Agentic Git Workflow

**The default branch is untouchable. Every change is a worktree + PR. Always.**

Never create, edit, or delete a file with the agent's file tools
(Write/Edit/NotebookEdit), and never `git add`/`git commit`, while a repo is on its
default branch (`main`/`master`/whatever `origin/HEAD` points at). This is
**mechanically enforced** by the bundled `main-branch-guard` (PreToolUse). The
commit gate is the choke point: even a file changed by raw shell (`>`, `sed -i`,
`git rm`) on the default branch can never be *committed* there — so nothing lands
on the default branch outside a worktree + PR. No exceptions, no escape hatch.
Worktrees (feature branches) and non-git paths (`/tmp`, scratchpad) are
unaffected. The guard gates only the agent's tool calls — the user's own editor
and `!`-prefixed session commands are never blocked.

If you catch yourself about to edit a file in a checkout that's on `main`, stop
and make a worktree first (recipe below).

## Allowed vs off-limits git ops

Allowed: `status`, `diff`, `log`, `show`, `remote`, `ls-files`, `cat-file`,
`rev-parse`, `describe`, `shortlog`, `blame`, `tag`, `check-ignore`,
`config --get`, `ls-tree`, `add`, `commit`, `push`, `clone`, `fetch`,
`worktree list`, `worktree add`, `worktree remove`. (`add`/`commit` only off the
default branch — see above.)

Off-limits without an explicit user ask: `checkout`, `switch`, `branch`, `stash`,
`reset`, `rebase`, `cherry-pick`, `revert`, `merge --abort`, `clean`, `reflog`,
`filter-branch`, `gc`, `prune`, `fsck`, `config` (write), force push.

**Why:** autonomous agents have caused real data loss with `git reset --hard`,
`git checkout -- .`, and force pushes — fast, irreversible, hard to audit. The
`git-guard` hook blocks these on the agent's own shell.

**On obstacles** (merge conflict, lock file, unexpected state): investigate and
resolve at the source. Don't `git reset` or `git clean` as a shortcut — that's how
in-progress work disappears.

## Worktree recipe

PR-bound work runs in an isolated worktree, never in the user's checkout. Don't
create a branch in place, don't switch the user's checkout, don't ask the user to
run git — `git worktree add -b` is the allowed, isolated branch-creation path.

1. **Always fetch first, base off the freshly-fetched default branch** so the
   worktree carries the latest remote changes. Never `git pull` the checkout
   (`pull` mutates it); `fetch` + base-off-`origin/<default>` gets latest without
   touching the user's tree. Never hardcode `main` — resolve the default:
   ```
   REPO=$(git rev-parse --show-toplevel)
   git -C "$REPO" fetch origin
   git -C "$REPO" remote set-head origin --auto
   BASE=$(git -C "$REPO" symbolic-ref --short refs/remotes/origin/HEAD | sed 's#^origin/##')
   git -C "$REPO" worktree add -b <slug> "$REPO/.agents/worktrees/<slug>" "origin/$BASE"
   ```
   Worktrees live **only** under `<repo>/.agents/worktrees/<slug>/`. The
   `origin/<default>` base is **mechanically enforced** — `main-branch-guard`
   denies `git worktree add -b/-B` with an implicit (current-HEAD) or local-branch
   base, so a new branch can never fork off a stale local commit. Pass an explicit
   `origin/<default>` (a raw commit SHA or tag is allowed for the rare deliberate
   case).
2. **End-to-end inside `$WT`:** implement → test → verify the real flow → commit →
   push → open PR, all in the worktree.
3. **Worktree integrity (multi-agent safe).** Create worktrees **foreground**,
   never as a background task — a backgrounded `git worktree add` races other
   agents' index writes into a corrupted, half-populated checkout. After
   `git worktree add`, verify the checkout is complete before building:
   `git -C "$WT" status --short | grep '^ D'` must be empty. In a shared checkout,
   commit with an explicit pathspec — `git commit <path>`, never
   `git add <file> && git commit` — so a concurrent agent's staged files aren't
   swept into your commit. Reproduce CI/build failures in the clean worktree, not
   a dirty checkout (a dirty tree yields false-positive failures).

Full recipe — worktree creation, PR, after-merge cleanup: the `git-workflow` skill.

## PR open is NOT done — actively wait, never make the user ping

Opening a PR is not a stopping point. After `gh pr create`, **actively wait for
CI** with the background-command + finish-echo pattern (never `Monitor`,
`ScheduleWakeup`, or `until` loops — they fail silently), then review and merge:

```
(gh pr checks <pr> --watch --fail-fast; echo "CI settled rc=$? — next: non-author review, then merge on green")
```
run with `run_in_background: true` — the harness re-invokes you the moment checks
settle. If the PR has no checks configured, go straight to review. A non-author
review **and** green CI = squash-merge without asking (see `gh-merge-guard`); fall
back to `AskUserQuestion` only when the review finds problems, tests fail, or the
merge conflicts. Don't remove the worktree or delete the branch until merge.
Never stop with a limp "okay, I'll wait" — that just makes the user ping you.

## Reconcile with rebase; never `reset --hard`; never stash

**Never stash — commit instead.** Uncommitted working-tree changes get committed
properly via the `/code:commit` skill (maximum small logical commits), never
`git stash`. Stash hides work somewhere easy to lose; a commit is durable,
reviewable, recoverable.

**Uncommitted changes on `main` → commit on a branch + WIP PR.** If the main
working tree has uncommitted changes, don't leave them dirty and don't commit
straight to `main`: move them to a worktree/branch and open a **WIP pull request**.

**Reconcile with rebase — `reset --hard` is never run.** To bring a behind/diverged
branch up to its upstream, use `git pull --rebase` / `git rebase origin/<branch>`:
it replays local commits and drops only those already upstream (patch-id match),
preserving genuinely unique work. **Never run `git reset --hard`, period** — it
discards commits unconditionally and irrecoverably. `rebase` needs explicit user
OK and the `git-guard` hook blocks it on the agent's shell — so hand a rebase to
the user via the `!` session prefix (`!git -C <repo> rebase origin/<branch>`),
which bypasses the agent hook.
