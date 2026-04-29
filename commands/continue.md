---
description: Resume a previous task - load context via agents sessions, assess state, then continue working
---

Resume previous work: $ARGUMENTS

You are picking up where a previous session left off. Typically called as `/continue <session-id>` (UUID or short prefix) — the invocation you see when resuming from the `agents sessions` picker across versions. The argument may also be a name, a topic, or empty.

## Step 1: Load the prior session

Pick the loader based on what the user passed.

| Input | Command |
|------|---------|
| Session ID (UUID or short prefix) | `agents sessions <id>` |
| Only a topic / name / keyword | `agents sessions "<query>"` to pick an ID, then `agents sessions <id>` |
| Nothing | `agents sessions` (interactive picker) — abort if no TTY and ask the user |

The default render is a concise summary: header, original prompt, tool-call groupings, final response. That's enough 90% of the time. Only escalate to `agents sessions <id> --markdown` if the summary leaves a real gap (e.g. you need a specific mid-session message). Narrow with `--include user,assistant` or `--last 5` if the full conversation is too long.

## Step 2: Assess current state

The transcript shows what the previous session *intended*. Verify what actually landed.

- `git status`, `git log --oneline -20`, `git diff` — what's committed, what's in flight
- Read the files the session touched and confirm the changes are still there
- Check for TODOs, FIXMEs, half-edited functions, failing tests
- If the session referenced an issue (Linear / GitHub / Jira / etc.), check its current state via `/issues` or the relevant tracker skill

Quote file:line evidence when summarizing — don't paraphrase from memory.

## Step 3: Present and align

One short block:

- **Done:** what landed (with file paths)
- **Remaining:** what's unfinished or broken (with specifics)
- **Drift:** anything that changed since the session ended
- **Next:** concrete next step

Use `AskUserQuestion` only if the next step is genuinely ambiguous. If the path is obvious, just state it and start.

## Step 4: Continue working

Pick up exactly where things left off. Don't redo completed work. Follow ACT -> VERIFY -> SHOW -> CONTINUE.

## Anti-patterns

- Do not ask "what were you working on?" — load the transcript first
- Do not dump raw transcript output at the user — synthesize it
- Do not start coding before verifying the prior work is still intact
- Do not use the older `/sessions` skill or hand-traverse `~/.agents/versions/.../projects/` — `agents sessions` is the canonical tool
