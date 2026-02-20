---
name: agents-cli
description: "Manage AI coding agent CLIs with agents-cli. Triggers on: 'agents add', 'agents use', 'agents pull', 'agents push', installing agent versions, syncing agent config, switching between agent versions, managing MCP servers, or when user mentions the agents-cli tool."
author: muqsitnawaz
version: 1.0.0
---

# agents-cli

A version manager and config sync tool for AI coding agent CLIs (Claude, Codex, Gemini, Cursor, OpenCode).

## Core Concepts

- `~/.agents/` is the user's git repo (source of truth for config)
- Shims in `~/.agents/shims/` enable automatic version switching when in PATH
- Each installed version has isolated HOME at `~/.agents/versions/{agent}/{version}/home/`
- Resources (commands, skills, hooks, memory) symlinked from central `~/.agents/` to version homes

## Essential Commands

```bash
# Version management
agents add claude@latest       # Install latest version
agents add claude@1.5.0        # Install specific version
agents use claude@1.5.0        # Set as default
agents view                    # Show all installed
agents view claude             # Show versions for agent
agents upgrade                 # Upgrade all to latest

# Config sync
agents pull gh:user/agents     # Restore config from GitHub
agents push                    # Backup config to GitHub
agents fork                    # Fork system repo for customization

# Resources
agents commands list           # List slash commands
agents skills list             # List skills
agents mcp list                # List MCP servers
agents mcp add <name> <cmd>    # Register MCP server
```

## Common Workflows

**First-time setup:**
```bash
agents add claude@latest
agents use claude
# Add shims to PATH: export PATH="$HOME/.agents/shims:$PATH"
```

**Sync config to new machine:**
```bash
agents pull gh:username/agents
# Select versions to install when prompted
```

**Switch between versions:**
```bash
agents use claude@1.4.0        # Global default
agents use claude@1.5.0 -p     # Project-specific (in .agents/agents.yaml)
```

## File Structure

| Path | Purpose |
|------|---------|
| `~/.agents/agents.yaml` | Global state (default versions, repos) |
| `~/.agents/skills/` | Shared skills (git-tracked) |
| `~/.agents/commands/` | Shared commands (git-tracked) |
| `~/.agents/versions/` | Installed CLI versions (local-only) |
| `~/.agents/shims/` | Version switching scripts (local-only) |

## Important Rules

- Only `agents use` can set the global default version
- Project manifest (`.agents/agents.yaml`) overrides global default
- Resources are symlinked, not copied (except Gemini which needs TOML conversion)
