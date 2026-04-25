# Operational Guardrails

- **Ask, don't guess.** Unsure about anything? Ask. A clarifying question costs 30 seconds; a wrong guess costs hours. Spawn subagents to verify if needed.
- **No user credentials in env vars or config files.** Use the OS keychain or encrypted config.
- **No background shells left running.** Foreground or explicit `run_in_background` with a finish signal. No orphan processes.
- **No toasts.** Silent success, inline errors.
- **No summary files, no unsolicited `.md` files.** Tell the user verbally. Don't create README, docs, notes, or summary files unless explicitly asked.
- **No emojis** in code, comments, commits, or user-facing output — unless the user explicitly asks.
