---
name: debug
description: "Debug issues with independent root cause verification. Triggers on: bug investigation, test failures, unexpected behavior, 'debug', 'root cause', 'why is this broken', or when an agent encounters errors during implementation."
---

# Debug

Systematic root cause analysis with independent verification. Do not guess. Do not patch symptoms.

## When This Applies

- You encounter an error, test failure, or unexpected behavior
- A user reports a bug or regression
- Something works locally but fails in production/CI
- You're about to add a fallback or "just in case" code path (stop — debug instead)

## Phase 1: Investigate

### Trace the Full Data Path

If data flows A -> B -> C -> D, read ALL FOUR files. Not two. Not three. All of them.

1. Start at the symptom (where the error appears)
2. Trace backwards through every file in the path
3. At each file, quote the exact code (file:line) that handles the data
4. Build an evidence chain: each quote links to the next

The root cause is NOT where the error appears. It's where correct behavior diverges from actual behavior. Keep tracing until you find that divergence point.

### Extract Everything From Errors

Error messages contain direct clues. Before reading any code:
- File names and line numbers from stack traces
- Variable values or state at time of failure
- Error codes or classification strings
- Timestamps and sequence of events

### Document Your Hypothesis

After investigation, write down:
- **What's broken**: expected vs actual behavior
- **Root cause**: the specific location (file:line) and explanation
- **Evidence chain**: the quotes from each file that prove it
- **Why it matters to users**: not just "it errors" but the UX impact

## Phase 2: Verify Independently

Before implementing any fix, verify your root cause with independent agents. This prevents confirmation bias — you've been staring at the code and may have tunnel vision.

### Spawn Verifiers via Swarm MCP

Spawn 2 agents using DIFFERENT model providers (e.g., one Codex, one Gemini):

```
mcp__Swarm__Spawn(
  task_name: "debug-verify-{short-description}",
  agent_type: "codex",  // or "gemini"
  mode: "plan",          // read-only, no code changes
  prompt: "<see template below>"
)
```

### Verifier Prompt Template

The verifier prompt MUST include:

1. **System context** — what the app/component does, its architecture
2. **What the user observes** — exact symptoms, screenshots if available
3. **Why it's problematic** — the UX impact, not just technical failure
4. **Code paths to read** — specific files and directories involved
5. **The question** — "What is the root cause? How would fixing it resolve the symptoms?"

The verifier prompt MUST NOT include:

- Your root cause hypothesis
- Your proposed fix
- Leading questions that hint at the answer
- Any framing that biases toward a specific file or function

### Example Verifier Prompt

```
You are investigating a bug in a desktop Electron app (Rush).

## The App
Rush is an Agent OS — a desktop app where AI agents run tasks. It uses
Electron + React, with OAuth sign-in via Supabase for Google accounts.

## What the User Sees
When clicking "Sign In with Google", a window opens with a blank email
field. The user has to type their full email and password from scratch,
even though they're signed into Google in Chrome with saved accounts
and autofill.

## Why This Is a Problem
Every other desktop app (Slack, VS Code, Spotify) opens Google sign-in
in the user's default browser where their accounts are saved. One click
to pick an account. Here, the user faces a login wall that feels like
2010. For a consumer app, this friction kills conversion.

## Code to Read
- electron/main.js — look for OAuth/auth window handling (around line 4700+)
- src/stores/auth.ts — look for callback URL construction
- The Supabase signInWithOAuth configuration

## Your Task
1. Read the code paths above
2. Identify the root cause of WHY the sign-in window has no access to
   the user's saved Google accounts
3. Explain how fixing that root cause would resolve the symptoms
4. Note any secondary issues you find
```

### Convergence Analysis

After verifiers complete:

- **All agree on root cause** — high confidence, proceed to fix
- **Agree on area but differ on specifics** — read the specific lines they disagree on, determine who's right
- **Fundamentally different diagnoses** — your investigation missed something. Re-read the files the other agents flagged. Do NOT default to your original hypothesis.

## Phase 3: Fix

Only after verification converges:

1. **Minimal fix** — target the root cause, not the symptoms
2. **No fallbacks** — if data can come two ways, standardize at source
3. **Test** — run existing tests, write new ones for the bug
4. **Verify end-to-end** — trigger the real flow, see the real output

## Output Format

When reporting debug results:

### Bug
What's broken. Expected vs actual behavior. UX impact.

### Evidence Chain
File-by-file trace with exact quotes (file:line).

### Root Cause
Where the divergence happens and why.

### Verification
Did independent agents converge? Summarize their conclusions.
Note any disagreements and how they were resolved.

### Fix
What to change, how it addresses root cause, tradeoffs.

### Tests
What to run, what to add.
