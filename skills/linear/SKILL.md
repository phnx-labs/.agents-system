---
name: linear
description: Task management CLI for AI agent teams - query work queues, update status, manage sprints via Linear
allowed-tools:
  - shell
---

# Linear - Task Management for Agent Teams

CLI for managing Linear tasks across a team of AI agents. Each agent can query its work queue, pick up tasks, report progress, and see the full team board.

## Binary Location

The `linear` CLI is at `${CLAUDE_SKILL_DIR}/scripts/linear`. It is NOT in PATH. Always invoke by full path:

```bash
${CLAUDE_SKILL_DIR}/scripts/linear <command>
```

## Setup

```bash
${CLAUDE_SKILL_DIR}/scripts/linear setup
```

Stores config in `~/.agents/linear.json`. Discovers your team, caches workflow states, and sets a default agent identity.

Credentials resolve in order: config file > `$LINEAR_API_KEY` env var > macOS Keychain (`linear-api-key`).

## Commands

### tasks - List, view, or board

```bash
${CLAUDE_SKILL_DIR}/scripts/linear tasks                          # My tasks (uses default agent identity)
${CLAUDE_SKILL_DIR}/scripts/linear tasks --all                    # All open tasks in active cycle
${CLAUDE_SKILL_DIR}/scripts/linear tasks --agent codex            # Codex's tasks
${CLAUDE_SKILL_DIR}/scripts/linear tasks --label today            # Filter by any label
${CLAUDE_SKILL_DIR}/scripts/linear tasks --status todo            # Filter by status
${CLAUDE_SKILL_DIR}/scripts/linear tasks --cycle next             # Next cycle instead of active
${CLAUDE_SKILL_DIR}/scripts/linear tasks --board                  # Team board grouped by agent
${CLAUDE_SKILL_DIR}/scripts/linear tasks GR-42                    # Detail view for a specific issue
${CLAUDE_SKILL_DIR}/scripts/linear tasks --json                   # Machine-readable output
```

### update - Modify an issue

```bash
${CLAUDE_SKILL_DIR}/scripts/linear update GR-42 --pickup                     # Mark In Progress
${CLAUDE_SKILL_DIR}/scripts/linear update GR-42 --done                        # Mark Done
${CLAUDE_SKILL_DIR}/scripts/linear update GR-42 --todo                        # Mark Todo
${CLAUDE_SKILL_DIR}/scripts/linear update GR-42 --status "In Review"          # Any state by name
${CLAUDE_SKILL_DIR}/scripts/linear update GR-42 --comment "Completed the research phase"
${CLAUDE_SKILL_DIR}/scripts/linear update GR-42 --done --comment "Shipped"    # Both at once
```

### create - New issue

```bash
${CLAUDE_SKILL_DIR}/scripts/linear create "Fix login redirect bug"
${CLAUDE_SKILL_DIR}/scripts/linear create "Add retry logic" --priority 2 --label agent:codex
${CLAUDE_SKILL_DIR}/scripts/linear create "Research competitors" --description "Deep dive on..." --status backlog
```

## Agent Workflow

Agents follow this pattern each session:

1. `${CLAUDE_SKILL_DIR}/scripts/linear tasks` - see your queue
2. `${CLAUDE_SKILL_DIR}/scripts/linear update GR-42 --pickup` - claim the highest priority task
3. Do the work
4. `${CLAUDE_SKILL_DIR}/scripts/linear update GR-42 --done --comment "Summary of what was done"`
5. Repeat

## Label Convention for Agent Assignment

Tasks are assigned to agents via labels: `agent:claude`, `agent:codex`, `agent:sergey`, etc.

When an agent runs `${CLAUDE_SKILL_DIR}/scripts/linear tasks` with a configured default identity, it automatically filters to its own queue. Use `--all` to see everything.
