---
description: Search and browse agent conversation transcripts
---

You are looking for: $ARGUMENTS

Load the `/sessions` skill and use `agents sessions` to find relevant conversations.

## Quick Search Patterns

```bash
# List recent sessions
agents sessions | head -20

# Search by topic
agents sessions "$ARGUMENTS"

# Read a specific session
agents sessions --markdown $ARGUMENTS

# Find active sessions
agents sessions --active
```

## Tips

- Use `--since 1h` for recent activity
- Use `--project myapp` to filter by project
- Use `--markdown` to render as readable text
- Combine filters: `agents sessions --project myapp --since 1d --agent claude`

Load the skill for full documentation on session management.
