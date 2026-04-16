---
description: Debug with swarm verification - multiple agents confirm root cause
---

You are debugging: $ARGUMENTS

Your goal is to identify the root cause, verify it independently, and resolve.

## Investigate

Start by understanding the system. Read AGENTS.md or CLAUDE.md if they exist.
Identify which modules or components are involved.

Dissect the error message or logs. They often contain direct clues - file names,
line numbers, stack traces, variable values. Extract everything useful.

Read the relevant code. Trace how data flows through the system — if data flows
A -> B -> C -> D, read ALL FOUR files. Quote exact code (file:line) at each step.

The root cause is not where the error appears - it's where the incorrect
behavior originates. Keep tracing backwards until you find it.

Document your hypothesis before proceeding to verification.

## Verify

Spawn 2 verifier agents via Swarm MCP using DIFFERENT model providers
(e.g., one codex, one gemini). Both in plan mode (read-only).

Each verifier prompt MUST include:
1. **System context** - what the app/component does, its architecture
2. **What the user observes** - exact symptoms, error messages, behavior
3. **Why it's problematic** - the UX or business impact, not just "it errors"
4. **Code paths to read** - specific files and directories to investigate
5. **The question** - "What is the root cause? How would fixing it resolve these symptoms?"

Each verifier prompt MUST NOT include:
- Your root cause hypothesis
- Your proposed fix
- Leading questions that hint at the answer
- Any framing that biases toward a specific conclusion

The goal is independent analysis. If you share your answer, you get confirmation
bias instead of verification. Two agents agreeing with you because you told them
the answer proves nothing.

### Convergence

After verifiers complete:
- **All agree** - high confidence, proceed to fix
- **Agree on area, differ on specifics** - read the disputed lines, determine who's right
- **Fundamentally different** - your investigation missed something. Re-read files the other agents flagged. Do NOT default to your original hypothesis.

## Resolve

Once the root cause is verified, propose fixes. Consider different approaches:
minimal fix, defensive fix, architectural fix. Evaluate tradeoffs.

## Output

### Bug
What's broken. What should happen vs what happens. UX impact.

### Evidence Chain
File-by-file trace with exact quotes (file:line).

### Root Cause
The specific location and explanation of WHY it causes the bug.
Include a diagram showing the flow from trigger to failure.

### Verification
What each verifier agent concluded. Did they converge?
Note any disagreements and how they were resolved.

### Fixes
Recommended fix first. For each fix: what to change, how it addresses
the root cause, and any tradeoffs.

### Tests
List relevant tests to run. If none exist, note what should be added.
