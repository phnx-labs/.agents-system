# Rules

> Layered with `~/.agents/rules/`. Same name in your user repo wins; everything else unions in.

This directory stores the persistent instruction files that agents-cli syncs into each agent runtime.

Files and folders:
- AGENTS.md: Canonical root rules file. Synced as CLAUDE.md, GEMINI.md, .cursorrules, or AGENTS.md depending on the agent.
- presets/: Optional bundles of reusable rule fragments.
- rules/: Optional reusable rule fragments imported from AGENTS.md or a preset.

How it works:
- Keep AGENTS.md if you want one flat instruction file.
- Use @presets/proactive.md or @rules/some-rule.md if you want modular composition.
- Agents that do not support native @imports get a compiled copy at sync time.
