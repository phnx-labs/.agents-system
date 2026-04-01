---
description: Resume a previous task - load context, assess state, then continue working
---

Resume previous work: $ARGUMENTS

You are picking up where a previous session left off. The user may provide a summary, a session name/ID, or just a vague description of what they were working on. Your job is to rebuild full context and keep going.

## Step 1: Load Prior Context

Based on what the user provided, use the best source:

| User Provides | Action |
|--------------|--------|
| Session name/ID | Use `/sessions <id>` to load the transcript |
| Summary or description | Search the codebase for related recent changes |
| Nothing specific | Check `git log --oneline -20` and recent file modifications |

Also check:
- `TODO.md` at repo root for tracked work items
- Recent git history: `git log --oneline --since="3 days ago"`
- Any in-progress branches or uncommitted changes

## Step 2: Assess Current State

Build a clear picture of what's done and what's not. Read the actual files -- don't guess from commit messages alone.

For each piece of prior work, verify:
- Does the code exist and look complete?
- Are there TODOs, FIXMEs, or half-finished implementations?
- Do tests exist? Do they pass?
- Are there any obvious gaps between what was intended and what was shipped?

## Step 3: Present Findings and Align

Use `AskUserQuestion` to confirm your understanding and get direction:

- State what you found (completed work, remaining work, blockers)
- Propose what to tackle next, ordered by priority
- Offer options if the path isn't obvious

Keep this concise -- the user wants to get back to work, not read an essay.

## Step 4: Continue Working

Once aligned, start executing. Follow the standard pattern: ACT -> SHOW -> CONTINUE.

Don't re-do work that's already done. Pick up exactly where things left off.

## Anti-Patterns

- Don't ask "what were you working on?" if you can figure it out from git/code
- Don't dump a wall of git log output -- synthesize it
- Don't start coding before confirming you understand the remaining work
- Don't re-explain what the user already knows about their own project
