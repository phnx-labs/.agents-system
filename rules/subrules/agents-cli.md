# agents-cli

- **Agent home dirs are symlinks.** `~/.claude/`, `~/.codex/`, etc. point into `~/.agents/versions/{agent}/{version}/home/`. Source of truth for shared config (commands, skills, hooks, memory, MCP) is `~/.agents/` — go there to inspect or modify.
- **Recall prior work with `agents sessions`.** Search by topic/repo before starting. Use `--include`/`--exclude` to filter roles. `agents sessions --help` for full flags.
- **Check active agents before spawning new ones.** `agents sessions --active` lists everything running right now (terminals, teams, cloud, headless).
