# MCP servers

One YAML file per MCP server. `agents-cli` reads these and registers each server with whichever agents are installed (Claude, Codex, Gemini, etc.).

## File format

```yaml
name: <server-name>          # logical name; becomes mcp__<name>__<tool>
transport: stdio | http      # stdio launches a process, http calls a URL
command: <executable>        # for stdio
args: [...]                  # CLI args
env:                         # optional env injection
  KEY: value
url: https://...             # for http transport
```

The `name` is what shows up as the tool prefix (e.g. `mcp__Swarm__Spawn`). Pick something short and stable.

## Adding a server

1. Create `mcp/<name>.yaml` with the fields above.
2. Run `agents mcp add <name>` (or `agents pull` if syncing from git).

## Local-only secrets

Don't commit API keys here. Reference them by env var:

```yaml
env:
  GITHUB_TOKEN: ${GITHUB_TOKEN}
```

Set the value in `~/.agents-system/.environment` (gitignored) or your shell profile.
