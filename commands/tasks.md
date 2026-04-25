---
description: Pull and display Linear tasks assigned to this agent from the active sprint
---

Fetch the current agent's Linear task queue and present it for action.

## Steps

1. Run the Linear CLI to get your tasks:

```bash
~/.agents/skills/linear/scripts/linear tasks
```

2. If there are tasks, present them clearly:
   - Sorted by priority (Urgent > High > Medium > Low)
   - Show identifier, title, status, and priority
   - For any task with a description, show the first 2-3 lines

3. Pick the highest-priority task that is in Todo (not already In Progress) and announce:
   - What the task is
   - Your plan to complete it
   - Then mark it In Progress and start working:

```bash
~/.agents/skills/linear/scripts/linear update <ID> --pickup
```

4. If a task is already In Progress, resume that one first instead of picking a new one.

5. If no tasks are found, say so and ask the user what they'd like to work on.

## Arguments

If `$ARGUMENTS` contains a task ID (like `GR-42`), show the detail view for that specific task instead:

```bash
~/.agents/skills/linear/scripts/linear tasks $ARGUMENTS
```

Then start working on it.
