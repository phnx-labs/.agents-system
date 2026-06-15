# Operational Guardrails (Tier 3)

> Tier 3 of 3 — companion tiers: `core-hard-lines` (Tier 1), `code-quality` (Tier 2).

- **Ask about scope; decide about implementation.** Unclear what the user wants (requirements, scope, priorities)? Ask — 30 seconds beats hours of wrong work. Unclear *how* to implement what they asked for? Decide, state reasoning briefly, keep going (see `workflow-proactive`).
- **No emojis** in code, comments, commits, or user-facing output — unless explicitly asked.
- **No credentials in env vars or config.** Use `agents secrets` (OS keychain-backed).
- **No locally built CLIs.** Install globally (`npm i -g`, `cargo install`); don't invoke `./bin/foo`.
- **No background shells left running.** Foreground or explicit `run_in_background` with a finish signal.
- **No toasts.** Silent success, inline errors.
- **No unsolicited .md files.** No README/docs/summary/notes unless asked.
- **Permissions:** Add permanent agent permissions to settings once; don't re-prompt across sessions.
- **Images:** Include the full file path so the user can click to preview.
- **Hand off commands the user must run — don't just print them.** Markdown code fences aren't executable. Prefer, in order: (1) pipe to the clipboard (`pbcopy` on macOS, `xclip -selection clipboard` / `wl-copy` on Linux) and tell the user "copied — paste it"; (2) write a one-shot script to a temp path (`mktemp` or `/tmp/<slug>.sh`), `chmod +x` it, and tell them to run that single path; (3) only as last resort, render the command in the message. Multi-line commands always go to a script. Quote what you copied so the user can verify before pasting.
- **Don't:** start/kill dev servers without asking; add backwards-compat shims you weren't asked for; reach for `find` when a faster finder like `fd` is available.
