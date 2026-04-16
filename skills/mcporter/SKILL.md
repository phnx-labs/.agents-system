---
name: mcporter
description: "Use the mcporter CLI to list, configure, and call MCP servers/tools directly from the command line."
---
# mcporter — MCP Server CLI

Use the mcporter CLI to list, configure, and call MCP servers/tools directly from the command line.

## When to Use

- When you need to call tools on external MCP servers (Swarm, Linear, etc.)
- When spawning subagents via the Swarm MCP server
- When listing available MCP servers and their tools

## Commands

### List servers

```bash
# List all configured MCP servers
mcporter list

# List with tool schemas
mcporter list --schema

# JSON output
mcporter list --json

# List tools for a specific server
mcporter list swarm --schema
```

### Call tools

```bash
# Call a tool: mcporter call <server>.<tool> key=value ...
mcporter call swarm.Spawn task_name=my-task agent_type=codex prompt="Fix the bug" mode=edit
mcporter call swarm.Status task_name=my-task
mcporter call swarm.Stop task_name=my-task
mcporter call swarm.Tasks
```

### Configuration

```bash
# View config
mcporter config list

# Add a server
mcporter config add <name> --command <cmd> --args <args...>

# Remove a server
mcporter config remove <name>
```

## Available Servers

### Swarm (`@swarmify/agents-mcp`)

Spawn parallel AI coding agents (Claude, Codex, Gemini, Cursor, OpenCode).

**Tools:**

| Tool | Description |
|------|-------------|
| `Spawn` | Spawn an agent: `task_name`, `agent_type` (codex/cursor/gemini/claude/opencode), `prompt`, `mode` (plan/edit/ralph/cloud), `cwd`, `effort` (fast/default/detailed) |
| `Status` | Get agent status, files changed, commands run, last messages. Use `since` for delta updates. |
| `Stop` | Stop all agents in a task, or one by `agent_id` |
| `Tasks` | List all tasks sorted by recent activity |

**Modes:**
- `plan` — read-only (default). Research, code review.
- `edit` — read+write. Implementation, fixes.
- `ralph` — autonomous. Works through RALPH.md tasks until done.
- `cloud` — runs on cloud infra (claude/codex only). Creates PR when done.

**Agent selection (preference order):**
1. `codex` — fast, cheap. Self-contained features.
2. `cursor` — debugging, bug fixes, tracing.
3. `gemini` — complex multi-system, architectural changes.
4. `claude` — max capability, research, exploration.
5. `opencode` — open source, provider-agnostic.

**Example workflow:**
```bash
# Spawn two agents in parallel
mcporter call swarm.Spawn task_name=auth-fix agent_type=codex prompt="Fix login validation" mode=edit cwd=/path/to/repo
mcporter call swarm.Spawn task_name=auth-fix agent_type=gemini prompt="Add OAuth2 flow" mode=edit cwd=/path/to/repo

# Wait 2+ minutes, then check
mcporter call swarm.Status task_name=auth-fix

# Stop when done
mcporter call swarm.Stop task_name=auth-fix
```

## Config Location

`~/.mcporter/mcporter.json` — global config with server definitions.

## Install

```bash
npm install -g mcporter
```
