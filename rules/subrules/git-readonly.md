# Git: Read-only + Commit/Push Only

Allowed: `status`, `diff`, `log`, `show`, `remote`, `ls-files`, `cat-file`, `rev-parse`, `describe`, `shortlog`, `blame`, `tag`, `check-ignore`, `config --get`, `ls-tree`, `add`, `commit`, `push`, `clone`.

Off-limits without explicit user ask: `checkout`, `branch`, `stash`, `reset`, `rebase`, `cherry-pick`, `revert`, `merge --abort`, `clean`, `reflog`, `filter-branch`, `gc`, `prune`, `fsck`, `config` (write), force push.

**Why:** autonomous agents have caused real data loss with `git reset --hard`, `git checkout -- .`, and force pushes. Fast, irreversible, hard to audit.

**On obstacles** (merge conflict, lock file, unexpected state): investigate and resolve at the source. Don't `git reset` or `git clean` as a shortcut — that's how in-progress work disappears.
