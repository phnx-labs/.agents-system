---
description: Debug an issue with systematic root cause analysis, then an automatic blinded independent-review panel
---

You are debugging: $ARGUMENTS

## The Discipline

The root cause is NEVER where the error appears. It's upstream. Your job is to trace backwards until you find it — yourself, first. You do the full analysis. Only once YOU have a committed root cause do you spin up an independent panel to test it.

**The #1 debugging mistake: reading 2 files and guessing.** If data flows A -> B -> C -> D and the error shows in D, you MUST read A, B, C, AND D. Not "the important ones." ALL of them. Skipping files is how you misdiagnose, propose wrong fixes, and introduce new bugs.

**The #2 mistake: outsourcing the thinking.** The independent panel in Phase 5 is there to *corroborate or break* a root cause you already found — not to do the investigation for you. Do not spawn it until Phases 1-4 are done and you can name a file:line.

## Phase 1: Extract Clues (Start from Zero)

**Do NOT trust the user's diagnosis.** They may be wrong about what's broken, where it broke, or why. Start your own investigation from scratch.

Dissect every piece of evidence available:
- Error messages, stack traces, log output — extract file names, line numbers, variable values.
- **Read the existing logs YOURSELF, first, before forming any theory.** Every log file, every line, every timestamp. Do not skip "irrelevant" logs. Do not wait to be told where they are — find them (`*.log`, the project's log dir, `~/.rush/sessions/*/`, journal/stdout captures). The clue you need is often where you least expect it. A theory formed before you've read the logs is a guess.
- Reproduce it yourself if you can. Quote the actual command and the actual output.
- Screenshots or user descriptions — what did they see vs what should they see?
- When did it start? What changed recently? (`git log --oneline -20` if relevant.)
- What has the user already tried? (Don't assume it was correct — verify it yourself.)

Write down: **What should happen** vs **What actually happens.**

**Rule:** If you find yourself saying "the user said it's X," stop. Verify X yourself by reading the code and logs. Users are often wrong about root causes.

## Phase 2: Map the Data Path

Before reading any code, map the full path data takes from origin to where the error appears:

```
Input/Trigger -> [Component A] -> [Component B] -> [Component C] -> Error
```

Identify EVERY file in this path. You will read ALL of them.

## Phase 3: Read EVERY File in the Path

This is non-negotiable. For each file in the data path:

1. Read it.
2. Find the relevant function/handler.
3. Quote the exact code with file:line.
4. Note what it receives, what it does, what it passes downstream.

Build an evidence chain:
```
file_a.ts:45 — receives X, transforms to Y, passes to B
file_b.ts:120 — receives Y, but expects Z <-- MISMATCH HERE
file_c.ts:30 — never reached because B throws
```

The bug is where the evidence chain breaks.

## Phase 4: Commit to a Root Cause (Gate)

Before going further, lock in a root cause YOU can defend. Verify:
- Can you explain WHY this specific input produces this specific error?
- Can you explain why it USED to work (if it did)?
- Does your theory account for ALL symptoms, not just the main one?
- Can you point to the exact file:line where the chain breaks?

If you can't answer all four, you haven't found the root cause yet. Keep reading. **Do not advance to Phase 5 without a committed root cause** — the panel exists to test your answer, not to invent one.

## Phase 5: Independent Blind Review (automatic for non-trivial bugs)

Now pressure-test your root cause against agents who have never seen it. Run this **automatically** — do NOT stop to ask the user whether to verify. The whole point is to see whether independent agents, given only the symptom and where to look, reach the *same* root cause you did.

**Skip ONLY if the bug is trivial** — single file, obvious fix, evidence chain is one hop. Say so in one line and go straight to Phase 7. Everything else (multiple files, multiple services, architectural layers, anything that took real tracing) gets a panel.

### Spawn the panel with `agents teams`, read-only

```bash
# 1. See which vendor agents are actually installed.
agents teams doctor

# 2. Create the team.
agents teams create debug-<slug>

# 3. Add reviewers — VARIETY of vendors, each read-only (--mode plan).
agents teams add debug-<slug> codex  "<blind brief>" --name r1 --mode plan
agents teams add debug-<slug> gemini "<blind brief>" --name r2 --mode plan
agents teams add debug-<slug> cursor "<blind brief>" --name r3 --mode plan

# 4. Run them in parallel and watch.
agents teams start debug-<slug> --watch

# 5. Read each verdict, then wind the team down.
agents teams logs debug-<slug> r1
agents teams logs debug-<slug> r2
agents teams logs debug-<slug> r3
agents teams disband debug-<slug>
```

**Variety is the point — pick a MIX of vendors, not N copies of one.** Different agents (`codex`, `gemini`, `cursor`, `claude`) have different blind spots; three `claude` reviewers will all miss the same thing. Choose from whatever `agents teams doctor` reports installed, spreading across vendors. If only one vendor is available, vary the entry point you hand each reviewer instead.

**How many: your judgment, not a fixed number.** Scale to the bug's breadth — a two-service bug might need 2 reviewers, a cross-stack architectural one 3-4. More surface area, more reviewers. Don't pad a simple bug; don't under-staff a sprawling one.

### The blind brief (SHARE / WITHHOLD)

Each reviewer gets the SAME two-part brief. Getting the split right is the entire exercise — leak your hypothesis and you've just measured your own bias.

**SHARE — give them enough to start, and where to look:**
- The symptom: **what should happen** vs **what actually happens**.
- The verbatim error message / stack trace / failing log lines.
- The exact reproduction command (and how to run it), if there is one.
- *Where to look* — the entry-point file(s), the relevant directories, the log locations, "start from `<file>` / the `<X>` flow." Point them at the haystack; don't point at the needle.

**WITHHOLD — never include these (naming them so you don't slip):**
- Your root cause or the file:line where you think the chain breaks.
- The data path you mapped.
- Your hypothesis, your suspicion, your "I think it's…".
- Your proposed fix.
- Any framing that pre-loads the answer ("the bug is probably in the auth layer").

Each brief ends with: **"Investigate independently and report your OWN root cause. Return file:line quotes for every claim. Do NOT paraphrase. If you can't quote it, don't claim it."**

Brief template to fill in per reviewer:
```
Mission: Independently find the root cause of this bug. Report YOUR finding — do not
assume any prior diagnosis is correct.

Symptom:
  Expected: <what should happen>
  Actual:   <what actually happens>

Error / logs (verbatim):
  <paste exact error + relevant log lines>

Reproduce:
  <exact command, or "no clean repro — here is how it surfaces: …">

Where to look:
  <entry-point files, directories, log locations — the haystack, NOT the needle>

Return, in this order:
  1. ROOT CAUSE — one file:line and why this input produces this error.
  2. EVIDENCE CHAIN — each file in the path, quoted with file:line, marking where it breaks.
  3. FIX — what to change, where, and why it fixes the source (not the symptom).

Investigate independently and report your OWN root cause. Return file:line quotes for
every claim. Do NOT paraphrase. If you can't quote it, don't claim it.
```

## Phase 6: Reconcile & Strengthen

Read every reviewer's verdict via `agents teams logs` and build a convergence matrix against YOUR Phase 4 root cause:

```
Reviewer  | Vendor | Root cause they found        | vs mine
----------|--------|------------------------------|------------------
r1        | codex  | build.sh:47 bun install      | SAME
r2        | gemini | postinstall fails on CLT Mac | SAME (downstream framing)
r3        | cursor | missing xcbuild guard        | NEW — I missed this
```

Then act on the shape of the agreement:

- **Converge** (they independently land on your root cause) → report it with high confidence and *say so*: "corroborated by N/N independent reviewers." Independent agreement from blinded agents is the strongest signal you can get.
- **Diverge** (a reviewer names a different root cause) → do NOT dismiss it because it isn't yours. Re-read the disputed file:line yourself. Your own theory is not privileged just because you found it first. Resolve the disagreement with code, then report which theory survived and why.
- **New finding** (a reviewer surfaces something you missed — a second cause, a compounding factor, a wrong fix) → fold it into your data path, evidence chain, and fix. This is the panel earning its cost.

The final report must be **improved** by the panel, not merely rubber-stamped by it. If the panel changed nothing, say that explicitly — and double-check you actually blinded them (a panel that always agrees may have been fed your hypothesis).

## Phase 7: Fix

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

### Confidence
One line: corroborated by N/N independent reviewers (converged) / divergence found and re-investigated — surviving theory is X / panel skipped (trivial, single-file).

### Independent Review
One line per reviewer: vendor, the root cause it reached independently, and SAME / DIVERGENT / NEW-FINDING vs yours. Note anything the panel added that you folded in.

### Fix
What to change, where (file:line), and why this fixes the root cause (not just the symptom).

### Tests
What tests to write that would catch this bug. Focus on the specific data path that broke.
