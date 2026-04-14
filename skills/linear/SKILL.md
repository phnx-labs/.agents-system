---
name: linear
description: Task management CLI for AI agent teams - query work queues, update status, manage sprints via Linear
allowed-tools:
  - shell
---

# Linear - Task Management for Agent Teams

CLI for managing Linear tasks across a team of AI agents. Each agent can query its work queue, pick up tasks, report progress, and see the full team board.

## Binary Location

The `linear` CLI is at `~/.agents/skills/linear/scripts/linear`. It is NOT in PATH. Always invoke by full path:

```bash
~/.agents/skills/linear/scripts/linear <command>
```

## Setup

```bash
~/.agents/skills/linear/scripts/linear setup
```

Stores config in `~/.agents/linear.json`. Discovers your team, caches workflow states, and sets a default agent identity.

Credentials resolve in order: config file > `$LINEAR_API_KEY` env var > macOS Keychain (`linear-api-key`).

## Commands

### tasks - List, view, or board

```bash
~/.agents/skills/linear/scripts/linear tasks                          # All open tasks in active cycle
~/.agents/skills/linear/scripts/linear tasks --agent codex            # Codex's tasks only
~/.agents/skills/linear/scripts/linear tasks --label today            # Filter by any label
~/.agents/skills/linear/scripts/linear tasks --status todo            # Filter by status
~/.agents/skills/linear/scripts/linear tasks --cycle next             # Next cycle instead of active
~/.agents/skills/linear/scripts/linear tasks --board                  # Team board grouped by agent
~/.agents/skills/linear/scripts/linear tasks GR-42                    # Detail view for a specific issue
~/.agents/skills/linear/scripts/linear tasks --json                   # Machine-readable output
```

### update - Modify an issue

```bash
~/.agents/skills/linear/scripts/linear update GR-42 --pickup                     # Mark In Progress
~/.agents/skills/linear/scripts/linear update GR-42 --todo                        # Mark Todo
~/.agents/skills/linear/scripts/linear update GR-42 --status "In Review"          # Any state by name
~/.agents/skills/linear/scripts/linear update GR-42 --comment "Completed the research phase"
~/.agents/skills/linear/scripts/linear update GR-42 --label agent:claude            # Add label(s)
```

### Marking done (proof required)

`--done` requires at least one `--proof`. The CLI will reject `--done` without proof. Each `--proof` is repeatable and auto-detected:

- **File path** -- uploaded to Linear, embedded as image (png/jpg) or file link
- **URL** -- embedded as a clickable link
- **Plain text** -- inlined as-is (metrics, counts, summaries)

```bash
# Screenshot proof
~/.agents/skills/linear/scripts/linear update GR-42 --done \
  --proof /tmp/tests-passing.png \
  --comment "All 14 assertions pass"

# URL proof
~/.agents/skills/linear/scripts/linear update GR-42 --done \
  --proof https://getrush.ai/blog/comparison \
  --comment "Published and live"

# Metric proof
~/.agents/skills/linear/scripts/linear update GR-42 --done \
  --proof "Sent 15/30 outreach emails, 3 replies, 1 demo booked"

# Multiple proofs
~/.agents/skills/linear/scripts/linear update GR-42 --done \
  --proof /tmp/screenshot.png \
  --proof https://github.com/org/repo/commit/abc123 \
  --proof "Deploy verified on production" \
  --comment "Feature shipped end-to-end"
```

**What counts as proof:**

| Task type | Acceptable proof |
|-----------|-----------------|
| Engineering | Screenshot of tests passing, deploy URL, commit URL |
| Growth | Screenshot of published post, URL of live content, outreach metrics ("sent X/Y, Z replies") |

### create - New issue

```bash
~/.agents/skills/linear/scripts/linear create "Fix login redirect bug"
~/.agents/skills/linear/scripts/linear create "Add retry logic" --priority 2 --label agent:codex
~/.agents/skills/linear/scripts/linear create "Research competitors" --description "Deep dive on..." --status backlog
```

## Agent Workflow

Agents follow this pattern each session:

1. `~/.agents/skills/linear/scripts/linear tasks --agent marc` - see your queue
2. `~/.agents/skills/linear/scripts/linear update GR-42 --pickup` - claim the highest priority task
3. Do the work
4. `~/.agents/skills/linear/scripts/linear update GR-42 --done --proof <evidence> --comment "Summary"` - proof is REQUIRED
5. Repeat

## Label Convention for Agent Assignment

Tasks are assigned to agents via labels: `agent:claude`, `agent:codex`, `agent:sergey`, etc.

`linear tasks` shows all tasks by default. Use `--agent <name>` to filter to a specific agent's queue.
