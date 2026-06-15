# Parallel Work via `agents teams`

Default to teams for changes touching 3+ independent surfaces. Single-threaded editing is the failure mode.

**Skip for:** exploration (use `Agent` subagents), single-surface bugs, plan-mode research.

## Boundary contracts are mandatory

Before spawning, present a distribution plan. Each teammate needs:

- **Owns** — explicit files.
- **Must NOT touch** — files owned by others.
- **Shared deps** — one canonical owner; everyone else imports.

If A waits on B's output to start, the split is wrong. Re-cut, or sequence with `--after`.

## Pattern

```bash
agents teams create my-feature
agents teams add my-feature claude "Owns: src/auth/*. Not: src/ui/*. ..." --name auth
agents teams add my-feature codex  "Owns: src/ui/*. Not: src/auth/*. ..." --name ui --after auth
agents teams start my-feature --watch
```

Every brief includes Mission, Full scope, Owns, Must NOT touch, concrete code pattern, success criteria, and ends with the line from core-hard-lines #8. The `/teams` command is the long-form playbook.
