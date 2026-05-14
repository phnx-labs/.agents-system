# Rules

> Layered with `~/.agents/rules/`. Same name in your user repo wins; everything else unions in.

This directory stores the persistent instruction files that agents-cli syncs into each agent runtime.

Files and folders:
- `AGENTS.md`: flat instruction file (canonical when no subrules are loaded). Synced as `CLAUDE.md`, `GEMINI.md`, `.cursorrules`, or `AGENTS.md` depending on the agent.
- `rules.yaml`: declares the `default` preset and which subrules it includes.
- `subrules/`: small focused rule fragments composed by `rules.yaml`.

How it works:
- The `default` preset in `rules.yaml` is the active combination. Edit it to add/remove subrules.
- Each subrule lives in `subrules/<name>.md` and is loaded by name.
- User-repo subrules at `~/.agents/rules/subrules/<name>.md` override system ones with the same name; new names union in.
- Agents that don't support native `@imports` get a compiled copy at sync time.
