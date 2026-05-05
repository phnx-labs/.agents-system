---
name: mcporter
description: "Use the mcporter CLI to list, configure, and call MCP servers/tools directly from the command line."
---
# mcporter — MCP Server CLI

Use the mcporter CLI to list, configure, and call MCP servers/tools directly from the command line.

## When to Use

- When you need to call tools on external MCP servers (Linear, etc.)
- When listing available MCP servers and their tools
- When configuring new MCP servers

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
mcporter list <server-name> --schema
```

### Call tools

```bash
# Call a tool: mcporter call <server>.<tool> key=value ...
mcporter call <server>.<tool> key=value ...
mcporter call <server>.Tasks
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

> **Note:** For spawning parallel agents, use `agents teams` instead of MCP servers. See the `teams` skill for details.

## Config Location

`~/.mcporter/mcporter.json` — global config with server definitions.

## Install

```bash
npm install -g mcporter
```
