# .agents

> You don't need a coding agent. You need a team.

<p align="center">
  <img src=".assets/claude.png" height="60" alt="Claude" style="margin: 0 10px;">
  <img src=".assets/cursor.png" height="60" alt="Cursor" style="margin: 0 10px;">
  <img src=".assets/gemini.png" height="60" alt="Gemini" style="margin: 0 10px;">
</p>

**Dotfiles for AI coding agents.** Version-control your entire agent setup—slash commands, MCP servers, skills, hooks, and settings—across Claude Code, Codex, Gemini, and Cursor.

## What Gets Synced

| Resource | Description |
|----------|-------------|
| Agent CLIs | Which version of each agent to install |
| Commands | `/debug`, `/plan`, `/swarm`, custom prompts |
| MCP servers | Tools your agents can use (filesystem, memory, etc.) |
| Skills | Reusable agent capabilities and best practices |
| Hooks | Pre/post execution scripts for prompt preprocessing |

## Why Multiple Agents?

One model can't juggle research, implementation, testing, and debugging in one pass. Different models have different strengths:

| Agent | Strengths | Best For |
|-------|-----------|----------|
| Claude | Built-in planning, synthesis, multi-step reasoning | Complex exploration, architecture |
| Codex | Fast, cheap, surgical changes | Self-contained features, rapid iteration |
| Gemini | Deep analysis, verification | Architectural changes, research |
| Cursor | Debugging, tracing | Bug fixes, root cause analysis |

Running them in parallel means each does what it's best at. Results get synthesized by an orchestrator.

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

## Structure

```
.agents/
  agents.yaml           # CLI versions, MCP servers, defaults
  claude/commands/      # Claude-specific (.md)
  codex/prompts/        # Codex-specific (.md)
  gemini/commands/      # Gemini-specific (.toml)
  cursor/commands/      # Cursor-specific (.md)
  claude/hooks/         # Prompt preprocessing
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
