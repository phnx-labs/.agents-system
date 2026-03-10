# .agents

> Dotfiles for AI coding agents.

<p align="center">
  <img src=".assets/claude.png" height="60" alt="Claude" style="margin: 0 10px;">
  <img src=".assets/cursor.png" height="60" alt="Cursor" style="margin: 0 10px;">
  <img src=".assets/gemini.png" height="60" alt="Gemini" style="margin: 0 10px;">
</p>

**This is a config repo.** It holds slash commands, MCP servers, skills, hooks, memory files, and permissions for your AI coding agents. Fork it, customize it, sync it across machines.

Two tools consume this repo:
- **[agents-cli](https://www.npmjs.com/package/@swarmify/agents-cli)** — Syncs this config to Claude, Codex, Gemini, Cursor, OpenCode
- **[Swarmify](https://github.com/muqsitnawaz/swarmify)** — VS Code extension + MCP server for multi-agent orchestration

## Quick Start

```bash
# Install the CLI
npm install -g @swarmify/agents-cli

# Pull default config (clones this repo to ~/.agents)
agents pull

# Or use your own fork
agents pull gh:yourname/.agents
```

That's it. Your commands, skills, MCP servers, and memory files are now synced to all your agents.

## What's In Here

```
.agents/
  commands/        # Slash commands (/debug, /plan, /swarm, etc.)
  skills/          # Reusable capabilities (image-craft, writer, etc.)
  mcp/             # MCP server configurations
  hooks/           # Prompt preprocessing scripts
  memory/          # Agent instructions (CLAUDE.md, GEMINI.md)
  permissions/     # Permission presets for sandboxed execution
```

| Resource | What It Does |
|----------|--------------|
| Commands | `/debug` does root cause analysis, `/swarm` spawns parallel agents |
| Skills | Domain expertise — writing, image generation, codebase exploration |
| MCP servers | Tools agents can use (filesystem, memory, GitHub, etc.) |
| Memory | Instructions that shape agent behavior across sessions |
| Permissions | Pre-approved tool patterns for specific workflows |

## Why Multiple Agents?

Different models have different strengths:

| Agent | Best For |
|-------|----------|
| Claude | Planning, synthesis, multi-step reasoning |
| Codex | Fast implementation, surgical edits |
| Gemini | Research depth, multi-system analysis |
| Cursor | Debugging, tracing through codebases |

Running them in parallel means each does what it's best at. The `/swarm` command orchestrates this.

## Commands

### Single-Agent

| Command | Purpose |
|---------|---------|
| `/plan` | Design features and plan implementation |
| `/debug` | Systematic root cause analysis |
| `/clean` | Remove technical debt, consolidate code |
| `/test` | Write tests for critical paths |
| `/ship` | Pre-launch verification (security, perf, QA) |

### Swarm (Multi-Agent)

Spawn independent agents to verify findings or work in parallel:

| Command | Purpose |
|---------|---------|
| `/splan` | Planning with swarm consensus |
| `/sdebug` | 2-3 agents independently verify root cause |
| `/sconfirm` | Lightweight verification of findings |
| `/sclean` | Parallel cleanup across different areas |
| `/stest` | Parallel testing (auth, data, API, UI, errors) |
| `/sship` | Independent pre-launch assessment |

Swarm commands require [agents-mcp](https://www.npmjs.com/package/@swarmify/agents-mcp) for orchestration.

## Quick Start

```bash
# Install agents-cli
npm install -g @swarmify/agents-cli

# Pull default config (auto-clones on first run)
agents pull

# Check what's installed
agents status
```

To use your own config, fork this repo then:

```bash
agents repo add gh:username/.agents
agents pull
```

## Project-Level Version Pinning

Pin agent CLI versions per-project with `.agents-version`:

```yaml
# .agents-version
claude: 2.0.65
codex: 0.98.0
```

When you run `claude` in that directory, the shim:
1. Finds `.agents-version` (walks up to root)
2. Uses the pinned version
3. Auto-installs if not present

Falls back to your global default if no `.agents-version` found.

**Multiple versions:**
```yaml
claude:
  - 2.0.65   # default
  - 2.1.37
```

## Structure

```
.agents/
  commands/             # Slash commands (.md)
  skills/               # Reusable agent capabilities
  hooks/                # Prompt preprocessing
  memory/               # Agent instructions (CLAUDE.md, etc.)
  permissions/          # Permission presets
  .githooks/            # Pre-commit validation
```

Local-only (gitignored):
```
  meta.yaml             # User defaults, installed versions
  agents.yaml           # Local state
  versions/             # Installed CLI binaries
  shims/                # Version-switching shims
```

Commands are calibrated per model. Codex needs explicit planning phases. Claude leverages built-in reasoning. Gemini optimized for analysis.

## Ecosystem

This repo is the prompts layer. Full stack:

| Layer | Component | Purpose |
|-------|-----------|---------|
| Orchestration | [agents-mcp](https://www.npmjs.com/package/@swarmify/agents-mcp) | MCP server for spawning sub-agents |
| IDE | [agents-ext](https://marketplace.visualstudio.com/items?itemName=swarmify.swarm-ext) | Full-screen agent tabs in VS Code |
| Config | [agents-cli](https://www.npmjs.com/package/@swarmify/agents-cli) | Sync commands, MCP servers, skills |
| Prompts | This repo | Model-calibrated slash commands |

## Customization

Fork this repo, edit commands, sync across machines:

```bash
vim ~/.agents/claude/commands/debug.md
cd ~/.agents && git commit -am "customize debug" && git push

# On another machine
agents pull
```

See [AGENTS.md](./AGENTS.md) for command structure and framework detection.

## Hooks

Prompt preprocessing in `claude/hooks/`:

- `expand-promptcuts.sh` - Text shortcuts from `promptcuts.yaml`
- `expand-bang-commands.py` - Execute `` `! command` `` inline

## License

MIT
