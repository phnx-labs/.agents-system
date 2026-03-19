---
description: Debug an issue with systematic root cause analysis
---

You are debugging: $ARGUMENTS

## The Discipline

The root cause is NEVER where the error appears. It's upstream. Your job is to trace backwards until you find it.

**The #1 debugging mistake: reading 2 files and guessing.** If data flows A -> B -> C -> D and the error shows in D, you MUST read A, B, C, AND D. Not "the important ones." ALL of them. Skipping files is how you misdiagnose, propose wrong fixes, and introduce new bugs.

## Phase 1: Extract Clues

Dissect every piece of evidence available:
- Error messages, stack traces, log output — extract file names, line numbers, variable values
- Screenshots or user descriptions — what did they see vs what should they see?
- When did it start? What changed recently? (`git log --oneline -20` if relevant)

Write down: **What should happen** vs **What actually happens.**

## Phase 2: Map the Data Path

Before reading any code, map the full path data takes from origin to where the error appears:

```
Input/Trigger -> [Component A] -> [Component B] -> [Component C] -> Error
```

Identify EVERY file in this path. You will read ALL of them.

## Phase 3: Read EVERY File in the Path

This is non-negotiable. For each file in the data path:

1. Read it
2. Find the relevant function/handler
3. Quote the exact code with file:line
4. Note what it receives, what it does, what it passes downstream

Build an evidence chain:
```
file_a.ts:45 — receives X, transforms to Y, passes to B
file_b.ts:120 — receives Y, but expects Z <-- MISMATCH HERE
file_c.ts:30 — never reached because B throws
```

The bug is where the evidence chain breaks.

## Phase 4: Confirm Root Cause

Before proposing ANY fix, verify:
- Can you explain WHY this specific input produces this specific error?
- Can you explain why it USED to work (if it did)?
- Does your theory account for ALL symptoms, not just the main one?

If you can't answer all three, you haven't found the root cause yet. Keep reading.

## Phase 5: Fix

Propose the fix at the SOURCE, not at the symptom. If data arrives in the wrong format, fix where it's created — don't add a transformer where it's consumed.

## Output

### Bug
What's broken. Expected vs actual behavior.

### Data Path
The full chain of files/functions from trigger to error.

### Evidence Chain
For EACH file in the path, quote the relevant code with file:line. Mark where the chain breaks.

### Root Cause
The specific location (file:line) and explanation of WHY. Include a diagram:
```
[Trigger] -> [A: does X] -> [B: expects Y but gets X] -> ERROR
                                    ^^ root cause
```

### Fix
What to change, where (file:line), and why this fixes the root cause (not just the symptom).

### Tests
What tests to write that would catch this bug. Focus on the specific data path that broke.
