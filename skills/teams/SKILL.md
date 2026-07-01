---
name: teams
description: "Organize AI coding agents into teams that collaborate on a shared task. Create teams, add teammates, start them, monitor progress, and collect results. Use this skill when you need parallel agent execution. For single-agent dispatch, use `agents run` instead."
argument-hint: "[create|add|start|status|disband]"
allowed-tools: Bash(agents teams*), Bash(agents run*)
user-invocable: true
---

# Teams Skill

Organize AI coding agents into teams for parallel collaboration. This skill teaches you how to use the `agents teams` CLI.

## Single Agent vs Teams

- **Single agent**: Use `agents run <agent> "prompt" --mode edit` for one-off tasks
- **Multiple agents**: Use `agents teams` when you need parallel execution

## Quick Start

```bash
# Create a team
agents teams create my-feature

# Add teammates
agents teams add my-feature claude "Implement the auth middleware" --name auth
agents teams add my-feature codex "Build the login UI" --name frontend

# Start the team
agents teams start my-feature --watch
```

## Commands

| Command | Description | Example |
|---------|-------------|---------|
| `create` | Start a new team | `agents teams create my-team` |
| `add` | Add a teammate | `agents teams add my-team claude "Task" --name role` |
| `start` | Launch pending teammates | `agents teams start my-team --watch` |
| `status` | Check who's working | `agents teams status my-team` |
| `logs` | Read teammate output | `agents teams logs my-team frontend` |
| `remove` | Remove a teammate | `agents teams remove my-team frontend` |
| `disband` | Stop all and remove | `agents teams disband my-team` |
| `doctor` | Check installed agents | `agents teams doctor` |

## DAG Dependencies

Use `--after` to create dependencies:

```bash
# Backend first
agents teams add my-feature claude "Build API" --name backend

# Frontend waits for backend
agents teams add my-feature codex "Build UI" --name frontend --after backend

# QA waits for both
agents teams add my-feature claude "Run tests" --name qa --after backend,frontend

# Start drains the DAG automatically
agents teams start my-feature --watch
```

## Modes

| Mode | Use When |
|------|----------|
| `plan` (default) | Read-only work: research, audit, analysis |
| `edit` | Code changes: implementation, refactoring |

Always use `--mode plan` for security audits, research, and analysis.

## Worktree Isolation (edit-mode teams)

By default all teammates share the current checkout. For parallel **edit** work, give each teammate its **own** git worktree so they don't collide on one working tree — one worktree per teammate type / independent surface.

```bash
# Turn on per-teammate isolation for the team
agents teams create my-feature --enable-worktrees

# Each teammate gets a dedicated worktree (.agents/worktrees/<name>, branch agents/<name>)
agents teams add my-feature claude "Owns: src/auth/*" --name auth --worktree auth --mode edit
agents teams add my-feature codex  "Owns: src/ui/*"   --name ui   --worktree ui   --mode edit
agents teams start my-feature --watch
```

- **Name the worktree after the surface** the teammate owns; the name must be **unique per teammate** (two teammates can't share one worktree name).
- `--cwd <dir>` sets a plain working directory for a teammate when you don't want a worktree.
- `--use-worktree <path>` on `create` makes **all** teammates share one existing checkout — the opposite of isolation; use only when every teammate must build against one tree.
- **Skip worktrees for `--mode plan`** teams — read-only, no contention.
- Worktrees are cleaned up on `stop`/`disband` when clean, and kept if they have uncommitted changes.

## Monitoring

```bash
# Check status
agents teams status my-feature

# Delta poll (efficient)
agents teams status my-feature --since 2026-04-24T09:00:00-07:00

# Read one teammate's log
agents teams logs my-feature frontend
```

## Best Practices

- **Mix agents** if available — different agents have different blind spots
- **Use `--mode plan`** for read-only work (audits, research)
- **Give full context** — each teammate needs the big picture plus their specific task
- **Demand evidence** — end prompts with: `Return file:line quotes for every claim`
- **Run in parallel** — most tasks don't depend on each other
- **Name teammates** with `--name` for easy reference
- **Isolate edit-mode teammates** — `--enable-worktrees` on create + `--worktree <name>` per teammate, so parallel edits don't collide on one checkout

## Short Aliases

```
teams c  = create    teams a  = add       teams s  = status
teams rm = remove    teams d  = disband   teams ls = list
```
