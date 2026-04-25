---
description: Verify current task is done end-to-end, then pick up the next task from Linear
---

Finish current work and move to next task. Context: $ARGUMENTS

## Step 1: Verify Current Task is Complete

Before moving on, confirm the current task is actually done:

**Code verification:**
- Read the files you changed -- is the implementation complete? No TODOs, no half-finished logic?
- Check `git diff` and `git status` -- anything uncommitted?

**Testing:**
- Run the relevant test suite (`bun test`, `go test`, or manual verification)
- Tests must cover the critical path that was changed -- not just "it compiles"
- If no tests exist for what you changed, write them before moving on

**Related cleanup:**
- Check if TODO.md has items related to this task -- mark them done
- Any Linear ticket in progress? Update its status:

```bash
~/.agents/skills/linear/scripts/linear update <ID> --done
```

Use `AskUserQuestion` to confirm: "Current task [X] verified complete. Tests pass. Move to next?"

## Step 2: Probe the Board

Pull the current task queue from Linear:

```bash
~/.agents/skills/linear/scripts/linear tasks
```

Before picking the next task, check for:
- Related tasks that should be grouped (same feature area, same component)
- Notes or comments on tickets that add context
- Dependencies between tasks (one must land before another)

## Step 3: Rule Out Duplicate Work

Before starting on anything, verify nobody else is already on it. If you skip this, you'll duplicate another agent's work and waste a turn.

**Check open PRs on GitHub:**

```bash
gh pr list --state open --limit 30
```

Scan titles and branches for anything matching the Linear tickets you're considering. Common patterns:
- `agent/RUSH-XXX` branches — someone is actively working the ticket
- `task-<shortid>` branches — a cloud/factory-floor agent spawned work
- PR titles that mention the exact fix you'd write ("fix(X): Y" where Y matches the ticket)

If a matching PR exists, **do not pick up that ticket** — either skip to the next one, or review the open PR instead.

**Check active Rush cloud / factory-floor runs:**

```bash
rush cloud list 2>/dev/null
```

Cloud agents clone the repo and open PRs autonomously. A ticket may look unassigned in Linear but already be in flight on the Factory Floor. If you see an active run whose prompt matches the ticket, skip it.

**Check recent commits on main:**

```bash
git log --oneline --since="24 hours ago"
```

Another agent may have already landed the fix straight to main. If the fix is already merged, close out the Linear ticket instead of re-implementing.

## Step 4: Pick Up Next Task

Select the highest-priority task that is in Todo (not In Progress) **and has no matching PR or active cloud run**. Prefer:
1. Tasks related to what you just finished (context is warm)
2. Urgent/High priority over Medium/Low
3. Tasks with clear scope over ambiguous ones

Announce what you're picking up, mark it In Progress:

```bash
~/.agents/skills/linear/scripts/linear update <ID> --pickup
```

Then start working. Read the relevant code, understand the problem, plan, execute. Standard pattern: ACT -> SHOW -> CONTINUE.
