# Permissions

Canonical permission rules for AI coding agents. Written once in YAML, installed to Claude, OpenCode, and Codex via `agents permissions add`.

## How it works

1. Group files in `groups/` are YAML fragments
2. `build.sh` concatenates them (alphabetically) into `default.yaml`
3. `agents permissions add` reads `default.yaml` and converts it to each agent's native format

The canonical format is Claude's syntax. `agents-cli` handles the translation:

| Canonical (YAML) | Claude (settings.json) | OpenCode (opencode.jsonc) | Codex (config.toml) |
|---|---|---|---|
| `"Bash(git status:*)"` | Same | `{ "git status *": "allow" }` | Inferred mode |
| `"Read"` | Same | N/A (no read gating) | N/A |
| `"WebFetch(domain:x.com)"` | Same | N/A | `network_access: true` |
| `deny: "Bash(sudo:*)"` | Same | `{ "sudo *": "deny" }` | N/A |

Codex uses coarse-grained modes (`approval_policy`, `sandbox_mode`) rather than per-command rules. `agents-cli` infers the best fit from the permission set.

## Rule syntax

```yaml
# Blanket allow -- permits ALL uses of a tool
- "Bash"
- "Read"

# Prefix match -- command must start with the prefix
- "Bash(git status:*)"       # matches: git status, git status --short
- "Bash(npm run:*)"          # matches: npm run build, npm run test

# Path rules -- glob patterns for file tools
- "Write(~/.claude/*)"       # single level
- "Edit(~/.agents/**)"       # recursive

# Domain rules
- "WebFetch(domain:docs.rs)"

# MCP tools -- exact tool name
- "mcp__Swarm__Spawn"
```

Deny rules use the same syntax but go under the `deny:` section. Deny takes precedence over allow.

## Group files

Files are concatenated alphabetically. The numbering controls order:

| Range | Purpose | Examples |
|---|---|---|
| `00-*` | Header + local overrides | `00-header.yaml` (YAML header), `00-local.yaml` (gitignored, machine-specific) |
| `01-18` | Reserved for future non-blanket Bash rules | Currently empty (blanket `"Bash"` covers all) |
| `16` | MCP server tools | `mcp__Swarm__Spawn`, etc. |
| `20-29` | WebFetch domain allowlists | Dev docs, cloud providers, social, misc |
| `30` | Blanket allows + Write/Edit paths | `"Bash"`, `"Read"`, dotdir write rules |
| `99` | Deny list | Dangerous commands, sensitive paths |

## Structure

```
permissions/
  groups/
    00-header.yaml       # name, description, allow: directive
    00-local.yaml        # Machine-specific (gitignored)
    16-mcp.yaml          # MCP tool permissions
    20-webfetch-dev.yaml # Developer docs/tools domains
    21-webfetch-cloud.yaml
    22-webfetch-social.yaml
    25-webfetch-misc.yaml
    30-paths.yaml        # Blanket Bash/Read + Write/Edit paths
    99-deny.yaml         # Deny list
  build.sh               # Concatenates groups/ -> default.yaml
  default.yaml           # Auto-generated output
  AGENTS.md              # This file
```

## Local permissions (00-local.yaml)

This file is **gitignored**. Use it for anything specific to your machine:

- Absolute paths (`/Users/yourname/...`, `/opt/homebrew/...`)
- Custom tools only installed on your machine
- Write/Edit paths outside standard dotdirs

```yaml
  # Example local permissions
  - "Write(/Users/me/projects/*)"
  - "Write(/Users/me/projects/**)"
  - "Edit(/Users/me/projects/*)"
  - "Edit(/Users/me/projects/**)"
```

## Rules for checked-in files

- Use `~` for home directory, never `/Users/username` or `/home/username`
- Use tool names, not absolute paths to binaries
- If a rule only makes sense on your machine, it goes in `00-local.yaml`

## Workflow

```bash
# Edit a group file
vim permissions/groups/30-paths.yaml

# Rebuild
bash permissions/build.sh

# Install to all Claude versions
agents permissions add permissions/default.yaml -a claude --all -y

# Install to a specific agent
agents permissions add permissions/default.yaml -a opencode --all -y
```
