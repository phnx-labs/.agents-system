# Git: Read-only + Commit/Push Only

Allowed: `status`, `diff`, `log`, `show`, `remote`, `ls-files`, `cat-file`, `rev-parse`, `describe`, `shortlog`, `blame`, `tag`, `check-ignore`, `config --get`, `ls-tree`, `add`, `commit`, `push`, `clone`, `fetch`, `worktree list`, `worktree add`, `worktree remove`.

Off-limits without explicit user ask: `checkout`, `switch`, `branch`, `stash`, `reset`, `rebase`, `cherry-pick`, `revert`, `merge --abort`, `clean`, `reflog`, `filter-branch`, `gc`, `prune`, `fsck`, `config` (write), force push.

**Why:** autonomous agents have caused real data loss with `git reset --hard`, `git checkout -- .`, and force pushes. Fast, irreversible, hard to audit.

**On obstacles** (merge conflict, lock file, unexpected state): investigate and resolve at the source. Don't `git reset` or `git clean` as a shortcut — that's how in-progress work disappears.

**Never stash — commit instead.** Uncommitted working-tree changes get committed properly via the `/code:commit` skill (maximum small logical commits), never `git stash`. Stash hides work somewhere easy to lose or forget; a commit is durable, reviewable, and recoverable.

**Uncommitted changes on `main` → commit + WIP PR.** If the `main` branch or the main working tree has uncommitted changes, don't leave them dirty and don't commit straight to `main`: commit them (via `/code:commit` or the relevant skill) on a branch/worktree and open a **WIP pull request**. In-progress work belongs in a reviewable PR, never as a dirty working tree or a direct-to-`main` commit.

**Reconcile with rebase — `reset --hard` is never run.** To bring a behind/diverged local branch up to its upstream, use `git pull --rebase` / `git rebase origin/<branch>`: it replays local commits and drops only those already upstream (patch-id match), preserving any genuinely unique work. **Never run `git reset --hard`, period** — it discards commits unconditionally and irrecoverably. `rebase` still needs explicit user OK per the deny list above, and the `git-guard` hook blocks it on the agent's own shell — so hand a rebase to the user to run via the `!` session prefix (`!git -C <repo> rebase origin/<branch>`), which bypasses the agent hook.
