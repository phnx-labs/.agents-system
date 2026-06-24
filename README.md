# .agents-system

> The **system repo** for [agents-cli](https://www.npmjs.com/package/@swarmify/agents-cli) — npm-shipped defaults for commands, skills, hooks, rules, and permissions.

<p align="center">
  <img src=".assets/claude.png" height="60" alt="Claude" style="margin: 0 10px;">
  <img src=".assets/cursor.png" height="60" alt="Cursor" style="margin: 0 10px;">
  <img src=".assets/gemini.png" height="60" alt="Gemini" style="margin: 0 10px;">
</p>

## What this is

`agents-cli` uses layered configuration. Repos with the same shape but different roles:

| Repo | Role | Edited by |
|---|---|---|
| `<project>/.agents/` | **Project** — repo-specific overrides | Project maintainers |
| `~/.agents/` | **User** — your personal additions and overrides | You |
| `~/.agents-<alias>/` | **Extras** — optional opinionated bundles (opt-in) | Bundle authors |
| `~/.agents-system/` (this one) | **System** — npm-shipped defaults | Upstream PRs |

Resources resolve **project > user > extras > system**. Same-named resource at a higher layer wins, everything else unions.

## Quick start

```bash
npm install -g @swarmify/agents-cli
agents view          # show what's installed
```

## What's tracked

```
.agents-system/
  commands/        # slash commands (/plan, /debug, /done, ...)
  skills/          # capabilities (agents-cli, browser, teams, ...)
  plugins/         # bundled plugins (code, git, ...) — registered in .claude-plugin/marketplace.json
  hooks/           # lifecycle scripts + hooks.yaml manifest
  rules/           # AGENTS.md + modular rule fragments
  permissions/     # permission groups + presets
```

Each directory has its own README.

## Commands

Slash commands are prompt templates. `commands/<name>.md` becomes `/<name>`.

| Command | Purpose |
|---------|---------|
| `/plan` | Plan with research, code reading, artifacts, optional team review |
| `/debug` | Root-cause analysis with full evidence chain |
| `/clean` | Remove tech debt, consolidate duplicates |
| `/test` | Test critical paths with parallel validation |
| `/recap` | Summarize state — facts first, hypotheses grounded |
| `/commit` | Stage, conventional commit, push in background |
| `/review` | Review every PR the session opened, then merge / request-changes per verdict |
| `/done` | Verify work is complete, test, release, create tickets for remaining |
| `/finish` | Drive the current task to completion end-to-end instead of stopping at a recap, blocker, or partial handoff |
| `/prune` | Delete merged branches and worktrees, locally and on origin (conservative) |
| `/continue` | Resume previous session with context recovery |
| `/tickets` | Work with issue tracker (auto-detects Linear/GitHub/Jira) |
| `/teams` | Spawn parallel agents for a task |

Several commands use `agents teams` for complex scopes (debug, plan, clean, test, recap, review).

## Skills

Skills are richer than commands — multi-file capabilities with persistent context. The full set ships in [`skills/`](skills/); highlights:

| Skill | Purpose |
|-------|---------|
| `agents-cli` | Manage agent CLIs, versions, config |
| `browser` | Drive browsers for automation |
| `computer` | Drive native macOS apps (screenshot, click, type) |
| `teams` | Organize agents into parallel teams |
| `run` / `routines` | Dispatch a single agent / schedule recurring agents |
| `sessions` | Search and read prior agent transcripts |
| `secrets` | Keychain-backed env-var bundles |
| `docs` / `release` / `reflect` | Write docs / publish packages / recall feedback |

See [`skills/README.md`](skills/README.md) for the complete table. Invoke with `/skillname` or let Claude invoke when relevant.

## Plugins

Plugins bundle related skills, commands, hooks, and subagents into one installable unit. The system layer ships lightweight, no-paid-key plugins by default; heavier or key-gated plugins live in `.agents-extras`. Registered in [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json), synced per agent version.

| Plugin | Purpose |
|--------|---------|
| `code` | Coding-workflow loop — `/code:loop`, `/code:dispatch`, `/code:verify`, `/code:review`, `/code:sprint`, `/code:quality`, `/commit` |
| `git` | Pure git plumbing (no code logic) — `/git:cleanup` prunes merged branches and worktrees with hard data-loss guards |

## Rules

`rules/AGENTS.md` is the canonical instruction file. Synced as `CLAUDE.md`, `GEMINI.md`, `.cursorrules` per agent. Modular fragments in `rules/subrules/` for composition.

## Hooks

`hooks.yaml` registers scripts against agent lifecycle events (`SessionStart`, `UserPromptSubmit`, `Stop`). Key hooks:
- Expand `#shortcut` tokens via `promptcuts.yaml`
- Execute inline `! cmd` bang commands
- Inject context at session start

User overrides go in `~/.agents/agents.yaml` under the `hooks:` section.

## Local-only (gitignored)

Runtime state written to this directory but never committed:
- `versions/`, `shims/` — installed CLIs
- `sessions/`, `teams/`, `swarm/` — execution state
- `agents.yaml`, `*.log`, `*.pid` — local config and logs

## Going further: extras bundles

This repo is the lean, universal default. Heavier opt-in workflows — parallel coding
loops, branded media generation — ship as separate **extras** bundles you
layer in with one command (they slot in above system, below your user repo):

```bash
agents repo add gh:phnx-labs/.agents-extras   # /loop, /sprint, /dispatch, /verify, /animate, /image, /compose, /design
agents repo list                              # confirm it registered
```

Extras are kept out of system on purpose — they carry heavier dependencies and paid API
keys, so the default install stays fast and works on any OS without setup. Disable
anytime with `agents repo disable <alias>`.

## Customization

Fork this repo, make changes, set as upstream:

```bash
agents repo set gh:your-handle/.agents-system
agents pull
```

Or just add overrides to `~/.agents/` — same structure, user layer wins.

## License

MIT
