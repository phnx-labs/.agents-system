# .agents-system

> The **system repo** for [agents-cli](https://www.npmjs.com/package/@swarmify/agents-cli) — defines the system-level, core, built-in skills, commands, hooks, rules, MCP configs, permissions, and profiles that ship with the tool.

<p align="center">
  <img src=".assets/claude.png" height="60" alt="Claude" style="margin: 0 10px;">
  <img src=".assets/cursor.png" height="60" alt="Cursor" style="margin: 0 10px;">
  <img src=".assets/gemini.png" height="60" alt="Gemini" style="margin: 0 10px;">
</p>

## What this is

`agents-cli` is layered. There are two repos with the same shape but different roles:

| Repo | Role | Owner | Edited by |
|---|---|---|---|
| `~/.agents-system/` (this one) | **System** — core/built-in resources shipped and curated by `agents-cli`. The defaults every install gets. | Maintainers | Upstream PRs |
| `~/.agents/` | **User** — your personal additions and overrides. | You | You, synced via `agents push`/`pull` |

Resources resolve in this order at sync time: **project > user > system**. So anything you put in `~/.agents/commands/foo.md` overrides `~/.agents-system/commands/foo.md`, and a project-local `agents.yaml` overrides both.

`agents-cli` clones this repo to `~/.agents-system/` and symlinks the resolved resources into each agent's home (`~/.claude/`, `~/.codex/`, `~/.gemini/`, etc.).

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
  commands/        # slash commands  (/debug, /plan, /audit, ...)
  skills/          # persistent capabilities (image-craft, writer, debug, ...)
  rules/           # AGENTS.md + reusable rule fragments and presets
  hooks/           # prompt preprocessing + lifecycle scripts (+ hooks.yaml)
  mcp/             # MCP server configurations (one YAML per server)
  permissions/     # permission groups + sets for sandboxed execution
  profiles/        # host-CLI + endpoint + model bundles (Kimi, DeepSeek, ...)
  hooks/promptcuts.yaml  # shortcut tokens expanded inline by hooks (system defaults)
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
| `/test` | Test critical paths — parallel validation for complex scopes |
| `/continue` | Resume previous work with context recovery |
| `/commit` | Stage, conventional commit, push in background |
| `/spawn` | Single subagent with full context |
| `/audit` | Multi-perspective security audit |
| `/issues` | Work with the project's issue tracker (Linear, GitHub Issues, Jira, etc.) |
| `/image` | Generate images via the image-craft skill |
| `/mq` | Query large docs without reading everything |
| `/reflect` | Recall feedback and constraints before rewriting |
| `/secrets` | Manage named bundles of environment variables (Keychain-backed) |
| `/sessions` | Search and browse agent conversation transcripts |
| `/teams` | Arrange agents into teams for parallel execution |

### Team augmentation

Several commands automatically use `agents teams` when the scope is complex:

- `/debug` — Verifies root cause with independent teammates for multi-service bugs
- `/plan` — Validates approach with independent planners for large features
- `/clean` — Parallelizes scanning across areas for large codebases
- `/test` — Distributes testing across areas for complex scopes
- `/recap` — Spawns teams for actionable items instead of listing them
- `/audit` — Always uses teams; each teammate plays a different threat perspective

Run `agents teams --help` for team management commands.

## Rules

`rules/AGENTS.md` is the canonical instruction file. `agents-cli` syncs it as `CLAUDE.md`, `GEMINI.md`, `.cursorrules`, or `AGENTS.md` per agent. `rules/presets/` and `rules/default/` hold modular fragments for `@import`-style composition. See `rules/README.md`.

## Hooks

`hooks.yaml` registers scripts in `hooks/` against agent lifecycle events (`SessionStart`, `UserPromptSubmit`, etc.). The two most visible hooks expand `#shortcut` tokens (via `hooks/promptcuts.yaml`) and execute inline `` `! cmd` `` bang commands. The user repo can override or disable any system-shipped hook by adding the same key to `~/.agents/hooks.yaml` — `enabled: false` disables it entirely. See `hooks/README.md`.

## Project-level version pinning

Pin agent CLI versions per project with an `agents.yaml` at the repo root:

```yaml
agents:
  claude: 2.1.118
  codex: 0.98.0
```

Shims in `~/.agents-system/shims/` walk up from the cwd, resolve the version, and exec the right binary. Falls back to the user default in `~/.agents/agents.yaml`.

## Customization

Fork, edit, push, pull on the next machine:

```bash
vim ~/.agents-system/commands/debug.md
cd ~/.agents-system && git commit -am "customize debug" && git push
agents pull   # on the other machine
```

## License

MIT
