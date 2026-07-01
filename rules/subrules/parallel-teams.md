# Parallel Work via `agents teams`

Default to teams for changes touching 3+ independent surfaces. Single-threaded editing is the failure mode.

**Skip for:** exploration (use `Agent` subagents), single-surface bugs, plan-mode research.

## Boundary contracts are mandatory

Before spawning, present a distribution plan. Each teammate needs:

- **Owns** — explicit files.
- **Must NOT touch** — files owned by others.
- **Shared deps** — one canonical owner; everyone else imports.

If A waits on B's output to start, the split is wrong. Re-cut, or sequence with `--after`.

## Isolate every edit-mode teammate in its own worktree

For edit-mode teams, give each teammate its **own** git worktree — never let parallel teammates share one checkout. A shared working tree means every teammate mutates the same index and files at once: cross-writes, stale reads, and merge chaos, and it only gets worse the more parallel the work is. One worktree per teammate (i.e. per teammate *type* / independent surface) keeps them truly parallel.

- `agents teams create <team> --enable-worktrees` — turns on per-teammate isolation for the team.
- `agents teams add ... --worktree <role>` — dedicated worktree at `.agents/worktrees/<role>` on branch `agents/<role>`, branched from HEAD. **The name must be unique per teammate** — two teammates cannot share one worktree name (the second `git worktree add` fails).
- Name the worktree after the surface the teammate owns (`--worktree auth`, `--worktree ui`) so it lines up with the boundary contract.
- Teammates that genuinely must co-edit the same files aren't independent — collapse them into **one** teammate; don't split then re-share. (A team-wide `--use-worktree <path>` makes *all* teammates share one existing checkout — that reintroduces the contention this rule avoids, so reach for it only when every teammate must build against one tree.)
- **Skip for plan-mode** (read-only) teams — no writes, no contention, no worktree needed.

## Pattern

```bash
agents teams create my-feature --enable-worktrees
agents teams add my-feature claude "Owns: src/auth/*. Not: src/ui/*. ..." --name auth --worktree auth --mode edit
agents teams add my-feature codex  "Owns: src/ui/*. Not: src/auth/*. ..." --name ui   --worktree ui   --mode edit --after auth
agents teams start my-feature --watch
```

Every brief includes Mission, Full scope, Owns, Must NOT touch, concrete code pattern, success criteria, and ends with the line from core-hard-lines #8. The `/teams` command is the long-form playbook.
