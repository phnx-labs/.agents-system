# Permissions

Permission rules for AI coding agents. Built from group files and installed via `agents permissions add`.

## Structure

```
permissions/
  groups/          # YAML fragments concatenated by build.sh
    00-header.yaml     # YAML header (name, description, allow:)
    00-local.yaml      # Machine-specific rules (gitignored)
    16-mcp.yaml        # MCP server tool permissions
    20-webfetch-*.yaml # WebFetch domain allowlists
    30-paths.yaml      # Blanket Bash/Read + Write/Edit path rules
    99-deny.yaml       # Deny list (dangerous commands)
  build.sh         # Concatenates groups/ into default.yaml
  default.yaml     # Built output (auto-generated, do not edit)
```

## Blanket allows

`30-paths.yaml` grants blanket `"Bash"` and `"Read"` permissions. All bash commands are allowed unless explicitly denied in `99-deny.yaml`. This eliminates prompts for compound commands, for-loops, pipes, and any command that doesn't start with a recognized prefix.

## Local permissions (00-local.yaml)

This file is **gitignored** and never checked into the repo. Use it for anything specific to your machine:

- Absolute paths (`/Users/yourname/...`, `/opt/homebrew/...`)
- Custom tools only installed on your machine
- Project-specific write/edit paths outside standard dotdirs
- `additionalDirectories` entries for directories you frequently work in

Example:
```yaml
  # My machine-specific permissions
  - "Bash(/opt/homebrew/bin/my-custom-tool:*)"
  - "Write(/Users/me/projects/*)"
  - "Write(/Users/me/projects/**)"
  - "Edit(/Users/me/projects/*)"
  - "Edit(/Users/me/projects/**)"
```

## Adding rules to the repo

Only add rules to checked-in group files if they are **portable** (work on any machine):
- Use `~` for home directory, never `/Users/username`
- Use tool names, not absolute paths to binaries
- WebFetch domains go in the appropriate `20-25` group file

## Workflow

```bash
# Edit a group file
vim permissions/groups/30-paths.yaml

# Rebuild
bash permissions/build.sh

# Install to all Claude versions
agents permissions add permissions/default.yaml -a claude --all -y
```
