# Conventions

- **Memory file:** `AGENTS.md` is the source of truth. `CLAUDE.md` and `GEMINI.md` should be symlinks to it (or copies synced by agents-cli).
- **Project scripts:** Deployable projects keep a `scripts/` directory with standard scripts (`build.sh`, `install.sh`, `publish.sh`). Check `scripts/` first before reverse-engineering a deploy.
- **Permissions:** Add permanent agent permissions to settings once. Don't re-prompt for the same action across sessions.
- **Images:** When discussing images, include the full file path so the user can click it.
- **Don't:** run or kill dev servers without asking; add backwards-compatibility shims you weren't asked for; use `find` on macOS (use `fd` or the agent's native search tool).
