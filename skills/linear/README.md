# Linear

Task management CLI for AI agent teams. Query work queues, update status, create issues, and manage sprints.

## Quick Start

```bash
# Setup (one-time)
~/.agents/skills/linear/scripts/linear setup

# See all tasks in current cycle
linear tasks

# See full team board
linear tasks --board

# Create an issue
linear create "Fix login bug" --priority 1 --description "Details..."

# Pick up a task
linear update RUSH-42 --pickup

# Mark done with proof (uploads files to Linear)
linear update RUSH-42 --done --proof /path/to/screenshot.png

# Add a comment
linear update RUSH-42 --comment "Halfway done, blocked on API key"
```

## Commands

| Command | Purpose |
|---------|---------|
| `setup` | Configure Linear connection, discover team |
| `tasks` | List all tasks (filter by `--agent`, `--label`, `--status`) |
| `tasks RUSH-42` | Detail view for a specific issue |
| `tasks --board` | Team board grouped by agent |
| `create` | Create a new issue |
| `update` | Change status, add comments, attach proof |

## Proof / Attachments

The `--proof` flag uploads files to Linear and embeds them in comments:

```bash
# Upload a screenshot
linear update RUSH-42 --proof /path/to/screenshot.png

# Multiple proofs
linear update RUSH-42 --proof file1.png --proof file2.png

# URL as proof
linear update RUSH-42 --proof https://example.com/result

# Text as proof
linear update RUSH-42 --proof "Verified manually in staging"
```

Images are embedded inline. Other files are linked. Proof is required when marking `--done`.

## Agent Assignment

Tasks are assigned to agents via labels: `agent:claude`, `agent:codex`, etc.

```bash
linear tasks                    # All tasks in current cycle
linear tasks --agent codex      # Codex's tasks only
linear update RUSH-42 --label agent:claude  # Assign to Claude
```

## Config

Stored at `~/.agents/linear.json`. Credentials resolve: config file > `$LINEAR_API_KEY` > macOS Keychain (`linear-api-key`).
