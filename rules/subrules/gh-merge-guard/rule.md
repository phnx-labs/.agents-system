# Merge & Admin-Bypass Guard

Irreversible, shared-state actions need explicit user authorization **in the current session** — an earlier "open a PR" does not authorize a merge.

- **Never `gh pr merge --admin`.** Admin bypass merges past branch protection and required reviews. The bundled `merge-guard.sh` (PreToolUse) blocks it. When the user authorizes a merge, merge *without* `--admin` so protections still apply.
- **Never merge a PR the user didn't explicitly ask you to merge.** "Investigate", "run the tests", "open a PR" are not "merge it." Opening a PR is the end of the task — then ask (`AskUserQuestion`: merge / iterate / close).
- **Never self-approve your own PR.** Reviewing and approving code you wrote, then merging it, is not review.
- **Never transfer credentials or auth files** (tokens, `~/.rush/user.yaml`, keychain exports) to another host or VM without explicit authorization. Don't attempt the transfer first and surface a question only after a guard blocks you.
