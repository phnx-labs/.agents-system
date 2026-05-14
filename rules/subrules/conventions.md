# Conventions

- **Memory file:** `AGENTS.md` is canonical. `CLAUDE.md` and `GEMINI.md` are symlinks (or synced copies).
- **Project scripts:** Deployable projects keep a `scripts/` directory — invoke the `scripts` skill when touching `scripts/`, `release.sh`, `build.sh`, or deploy/publish flows.
- **Tickets:** Linear context is injected at session start by the linear hook — read it before starting work, update tickets as you go, close only with proof.
- **Parallel work:** Multi-surface changes use `agents teams` — see `parallel-teams`.
