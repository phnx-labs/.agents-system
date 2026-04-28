# .agents-system

> Curated upstream config for [agents-cli](https://www.npmjs.com/package/@swarmify/agents-cli).

<p align="center">
  <img src=".assets/claude.png" height="60" alt="Claude" style="margin: 0 10px;">
  <img src=".assets/cursor.png" height="60" alt="Cursor" style="margin: 0 10px;">
  <img src=".assets/gemini.png" height="60" alt="Gemini" style="margin: 0 10px;">
</p>

This repo holds the slash commands, skills, hooks, MCP server configs, instruction rules, permission groups, and model profiles that `agents-cli` syncs into Claude, Codex, Gemini, Cursor, and OpenCode.

`agents-cli` clones it to `~/.agents-system/` and symlinks the resources into each agent's home (`~/.claude/`, `~/.codex/`, `~/.gemini/`, etc.).

## Quick start

```bash
npm install -g @swarmify/agents-cli
agents pull          # clones this repo to ~/.agents-system on first run
agents view          # show what's installed
```

To use your own fork, set the upstream and re-pull:

```bash
agents repo add gh:your-handle/.agents-system
agents pull
```

## What's tracked

```
.agents-system/
  commands/        # slash commands  (/debug, /plan, /swarm, ...)
  skills/          # persistent capabilities (image-craft, writer, debug, ...)
  rules/           # AGENTS.md + reusable rule fragments and presets
  hooks/           # prompt preprocessing + lifecycle scripts (+ hooks.yaml)
  mcp/             # MCP server configurations (one YAML per server)
  permissions/     # permission groups + sets for sandboxed execution
  profiles/        # host-CLI + endpoint + model bundles (Kimi, DeepSeek, ...)
  promptcuts.yaml  # shortcut tokens expanded inline by hooks
  scripts/         # repo maintenance scripts
  .githooks/       # pre-commit validation
```

Each directory has its own README explaining what lives there.

## Local-only (gitignored)

`agents-cli` writes a lot of state into `~/.agents-system/` that should never be committed. The `.gitignore` excludes:

- `agents.yaml`, `meta.yaml`, `config.json`, `aliases.json`, `prompts.json` — local state
- `versions/`, `shims/`, `repos/`, `packages/`, `agents/` — installed CLIs and resolvers
- `sessions/`, `cron/`, `jobs/`, `runs/`, `routines/`, `swarm/`, `swarmify/`, `cloud/`, `ledger/`, `teams/`, `drive/`, `drives/`, `cache/`, `backups/`, `logs/` — runtime state
- `secrets/`, `.environment` — machine-specific credentials and host info
- Private skills (e.g. `skills/rush-*`, `skills/dispatch/`, `skills/proof-loop/`)
- `*.log`, `*.pid`, OS files (`.DS_Store`)

Anything not in those buckets is tracked and synced.

## Commands

Slash commands are prompt templates. `commands/<name>.md` becomes `/<name>`, with `$ARGUMENTS` replaced by whatever the user typed after the slash. See `commands/README.md` for the full list and authoring guide.

### Single-agent

| Command | Purpose |
|---------|---------|
| `/plan` | Plan a feature with mockups, diagrams, evidence before code |
| `/debug` | Root-cause analysis with full evidence chain |
| `/design` / `/redesign` | UX design with ASCII mockups; before/after for existing screens |
| `/product` | User-value framing over technical elegance |
| `/recap` | Summarize state — facts first, hypotheses grounded |
| `/clean` | Remove tech debt, consolidate duplicates |
| `/done` / `/next` / `/continue` | Verify task complete; pick up next; resume work |
| `/tasks` | Pull active Linear tasks |
| `/commit` | Stage, conventional commit, push in background |
| `/spawn` | Single subagent with full context |
| `/security` | Multi-perspective security audit |
| `/rdev` | Dispatch a Linear issue to a remote coding agent |
| `/image-nbp` / `/video-k3z` / `/simagine` | Visual asset generation entry points |

### Swarm (multi-agent)

Spawn independent agents in parallel for verification or distribution.

| Command | Purpose |
|---------|---------|
| `/swarm` | Distribute tasks across parallel agents |
| `/splan` | Planning with swarm consensus |
| `/sdebug` | Independent root-cause verification |
| `/sconfirm` | Lightweight cross-check of findings |
| `/sclean` | Parallel cleanup across areas |
| `/stest` | Parallel testing by category |
| `/srecap` | Multiple agents gather evidence before handoff |

Swarm commands require [`@swarmify/agents-mcp`](https://www.npmjs.com/package/@swarmify/agents-mcp).

## Rules

`rules/AGENTS.md` is the canonical instruction file. `agents-cli` syncs it as `CLAUDE.md`, `GEMINI.md`, `.cursorrules`, or `AGENTS.md` per agent. `rules/presets/` and `rules/rules/` hold modular fragments for `@import`-style composition. See `rules/README.md`.

## Hooks

`hooks.yaml` registers scripts in `hooks/` against agent lifecycle events (`SessionStart`, `UserPromptSubmit`, etc.). The two most visible hooks expand `#shortcut` tokens (via `promptcuts.yaml`) and execute inline `` `! cmd` `` bang commands. See `hooks/README.md`.

## Project-level version pinning

Pin agent CLI versions per project with an `agents.yaml` at the repo root:

```yaml
agents:
  claude: 2.1.118
  codex: 0.98.0
```

Shims in `~/.agents-system/shims/` walk up from the cwd, resolve the version, and exec the right binary. Falls back to the user default in `~/.agents-system/agents.yaml`.

## Customization

Fork, edit, push, pull on the next machine:

```bash
vim ~/.agents-system/commands/debug.md
cd ~/.agents-system && git commit -am "customize debug" && git push
agents pull   # on the other machine
```

## License

MIT
