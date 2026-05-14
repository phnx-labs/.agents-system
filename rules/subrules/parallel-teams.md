# Parallel Work via `agents teams`

Default to teams for changes touching more than two independent surfaces. Single-threaded editing is the failure mode.

**When:** multi-file change with separable boundaries; audit/ship-readiness/parity check; anything queueing 4+ sequential edits.

**Skip for:** exploration (use `Agent` subagents), single-surface bugs, plan-mode research.

## Boundary contracts are mandatory

Before spawning, present a distribution plan and get approval. Each teammate needs:

- **Owns** — explicit files (with line ranges where helpful).
- **Must NOT touch** — files owned by others.
- **Shared deps** — one canonical owner; everyone else imports.

**Independence test:** if A waits on B's output to start, the split is wrong. Re-cut, or sequence with `--after`.

## Pattern

```bash
agents teams create my-feature
agents teams add my-feature claude "Owns: src/auth/*. Not: src/ui/*. Implement OAuth refresh." --name auth
agents teams add my-feature codex  "Owns: src/ui/login.tsx. Not: src/auth/*. Wire login UI." --name ui --after auth
agents teams start my-feature --watch
```

`--mode plan` for read-only; `--mode edit` (default) for code.

## Briefing each teammate

Every prompt includes: **Mission**, **Full scope** (so each has the big picture), **Your assignment** (files owned), **Boundary contract** (files NOT to touch), **Pattern** (concrete code inline), **Success criteria**.

End every brief with the line from core-hard-lines #8.

## After

- Verify with `grep` — `files_modified: []` may mean a different approach was used, not failure.
- Run tests for affected paths.
- Don't re-run the whole team for one teammate's failure.

The `swarm` slash command (`~/.claude/commands/swarm.md`) is the long-form playbook with templates.
