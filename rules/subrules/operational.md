# Operational Guardrails (Tier 3)

> Tier 3 of 3 — companion tiers: `core-hard-lines` (Tier 1), `code-quality` (Tier 2).

- **Ask about scope; decide about implementation.** Unclear what the user wants (requirements, scope, priorities)? Ask — 30 seconds beats hours of wrong work. Unclear *how* to implement what they asked for? Decide, state reasoning briefly, keep going (see `workflow-proactive`).
- **No emojis** in code, comments, commits, or user-facing output — unless explicitly asked.
- **No credentials in env vars or config.** Use `agents secrets` (macOS Keychain).
- **No locally built CLIs.** Install globally (`npm i -g`, `cargo install`); don't invoke `./bin/foo`.
- **No background shells left running.** Foreground or explicit `run_in_background` with a finish signal.
- **No toasts.** Silent success, inline errors.
- **No unsolicited .md files.** No README/docs/summary/notes unless asked.
- **Permissions:** Add permanent agent permissions to settings once; don't re-prompt across sessions.
- **Images:** Include the full file path so the user can click to preview.
- **Don't:** start/kill dev servers without asking; add backwards-compat shims you weren't asked for; use `find` on macOS (use `fd`).
