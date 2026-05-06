---
description: Arrange agents into teams for parallel execution
---

You are organizing a team for: $ARGUMENTS

Load the `/teams` skill and use `agents teams` to coordinate agents.

## Quick Team Creation

```bash
agents teams create my-team
agents teams add my-team claude "$ARGUMENTS" --name task1
agents teams start my-team --watch
```

## Key Concepts

- **Create** → Start a new team
- **Add** → Assign tasks to agents (claude, codex, gemini, cursor)
- **Start** → Launch pending agents
- **Status** → Check who is working
- **Disband** → Clean up when done

## Modes

- `--mode plan` — Read-only (research, audit, analysis)
- `--mode edit` — Read+write (implementation, fixes)

## Dependencies

Use `--after` for sequential dependencies:
```bash
agents teams add my-team codex "Build API" --name backend
agents teams add my-team claude "Build UI" --name frontend --after backend
```

Load the skill for full documentation on team management.
