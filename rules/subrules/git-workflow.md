# Agentic Git Workflow

PR-bound work runs in an isolated worktree, never in the user's checkout.

- **Use a worktree, not a branch in place.** PR work goes in `<repo>/.agents/worktrees/<slug>/`. Don't create a branch in place, don't switch the user's checkout, don't ask the user to run git. `checkout`/`switch`/`branch`/`reset` are on the `git-readonly` deny list; `git worktree add -b` is the allowed, isolated branch-creation path.
- **Base off the real default branch.** Don't `checkout main` or `git pull` first — `pull` mutates the checkout. `git fetch`, resolve the default branch dynamically (`git symbolic-ref refs/remotes/origin/HEAD`) — never hardcode `main` — and create the worktree from `origin/<default-branch>`.
- **End-to-end inside `$WT`.** Implement → test → verify the real flow (core-hard-lines #1) → commit → push → open PR, all in the worktree. The deny list still applies (`reset`/`rebase`/`stash` off-limits).
- **PR open is not "done."** Post the URL, ask via `AskUserQuestion` (merge / request changes / iterate). Don't remove the worktree or delete the branch until merge.

Full recipe — worktree creation, PR, after-merge cleanup: the `git-workflow` skill.
