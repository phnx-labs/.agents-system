# git plugin

Pure git plumbing commands that aren't tied to code logic. Branch and worktree pruning, tag releases, anything that touches the git object store without caring about what's *in* the code.

The code-aware loop (`/commit` with code-organization heuristics, `/review` with a code-quality rubric, `/sprint` for multi-track pushes) lives in the [`code`](../code/) plugin — those are coding-workflow concerns that happen to talk to git. This plugin is the opposite: it doesn't reason about code at all.

## Requirements

- [`agents-cli`](https://github.com/phnx-labs/agents-cli) installed and on `$PATH`.
- At least one supported coding agent (Claude Code, Codex, Gemini, Cursor, OpenCode).
- `git` ≥ 2.20 (for `worktree` porcelain output).

## Commands

| Command | What it does |
| --- | --- |
| `/git:cleanup` | Deletes merged branches and worktrees locally and on `origin`, with hard data-loss guards: never removes a worktree that has uncommitted changes, stashes, unmerged commits, a lock, or detached HEAD. Always shows the plan and asks before acting. Uses `git rev-list --count origin/$MAIN..HEAD == 0` as the load-bearing "nothing to lose" check — strictly stricter than `git branch --merged`. |

## Safety bar

`/git:cleanup` follows one hard line: **data loss is the only failure that matters**. A worktree that lingers an extra day is a 5-second inconvenience. A worktree removed with unpushed commits or uncommitted edits is hours of irrecoverable work. The command defaults to skipping any worktree where the safety probes can't return a definitive "nothing to lose," and never uses `--force` on branch deletes or worktree removes.
