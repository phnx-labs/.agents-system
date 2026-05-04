# Scripts

Repo-maintenance and operator helpers. These are NOT synced into agent runtimes — they're for the human managing this repo.

| Script | What it does |
|--------|--------------|
| `sync.sh` | Pre-`agents-cli` sync helper: diffs and copies command files between `~/.agents-system/{commands,prompts}` and the per-agent system dirs (`~/.claude/commands`, `~/.codex/prompts`, etc.). Mostly superseded by `agents pull` / `agents push`; still handy for ad-hoc inspection. Run with `--confirm` to actually move bytes. |

## Adding a script

Drop it here, make it executable (`chmod +x`), document it in the table above. Keep them self-contained — one purpose, one file.
