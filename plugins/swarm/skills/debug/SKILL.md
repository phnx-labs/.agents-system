---
name: debug
description: "Debug with swarm verification — trace the data path, form a root-cause hypothesis, then have independent agents (different model providers, blind to your hypothesis) confirm it before any fix. Use for non-obvious bugs where a wrong diagnosis is expensive. Triggers on: 'swarm debug', 'root cause with verification', 'confirm the bug', 'why is this happening', 'independent debug'."
argument-hint: "[bug, error, or symptom to root-cause]"
allowed-tools: Bash(agents teams*), Bash(agents run*), Bash(rg*), Bash(fd*), Bash(ls*), Bash(git log*), Bash(git diff*), Bash(git show*), Read(*), Grep(*), Glob(*), WebSearch(*), WebFetch(*)
user-invocable: true
---

# swarm:debug — root-cause, then have the swarm confirm it blind

> Read `swarm:orchestrate` first for fan-out mechanics and the blinded-verification rule. This skill is the **debug mode**: trace the path, prove the root cause, and only fix once independent agents converge on the same cause.

You are debugging: **$ARGUMENTS**

The root cause is **not** where the error surfaces — it's where the incorrect behavior originates. No fix ships until the cause is proven and independently confirmed. No fallbacks, no "just in case" guards, no symptom patching — fix the root cause or fix nothing.

## 1. Investigate (no lazy debugging)

Read `AGENTS.md` / `CLAUDE.md` if present. Dissect the error/logs — file names, line numbers, stack traces, variable values are direct clues; extract everything.

Then trace the data path. If data flows A → B → C → D, **read all four files** and quote exact code (file:line) at each step. Skipping the middle is how you misdiagnose. Keep tracing backwards until you find where the behavior first goes wrong. Document your hypothesis before verifying.

If the bug could involve external behavior (a library version's quirk, an API contract, a runtime change), **WebSearch with the current year** and quote the authoritative source — don't guess from stale memory.

## 2. Verify — blinded, scaled to the bug

Fan out via `agents teams` (mechanics in `swarm:orchestrate`). First check who's available (`agents teams doctor` / `agents view --json`), then **mix different model providers** — the diversity is the whole point; two of the same model agreeing proves nothing.

**Scale the verifier count to the bug, by judgment** (not a fixed number):
- Trivial / single-file → 1 independent check, or skip the swarm and just prove it yourself.
- Normal cross-module bug → 2 verifiers on different providers.
- Gnarly, cross-stack, or high-stakes → 3+ verifiers on as many distinct providers as are signed in.

All verifiers run **`--mode plan`** (read-only).

Each verifier prompt MUST include:
1. **System context** — what the component does, its architecture.
2. **Observed symptoms** — exact errors/behavior the user sees.
3. **Why it's problematic** — the UX/business impact, not just "it errors."
4. **Code paths to read** — specific files/dirs to investigate.
5. **The question** — "What is the root cause, and how would fixing it resolve these symptoms?"

Each verifier prompt MUST NOT include: your hypothesis, your proposed fix, leading questions, or any framing that biases toward a conclusion. Independent analysis only — confirmation isn't verification.

### Convergence
- **All agree** → high confidence, proceed to fix.
- **Agree on area, differ on specifics** → read the disputed lines, determine who's right.
- **Fundamentally different** → your investigation missed something. Re-read the files the others flagged. Do NOT default back to your original hypothesis.

## 3. Resolve

Once the cause is verified, propose fixes — minimal, defensive, architectural — and weigh tradeoffs. Recommend one.

## Output

### Bug
What's broken. Expected vs actual. UX impact.

### Evidence chain
File-by-file trace with exact quotes (file:line) at every hop.

### Root cause
The specific location and WHY it causes the bug. A small diagram from trigger → failure.

### Verification
What each verifier concluded and whether they converged. Note disagreements and how you resolved them with evidence (not majority vote).

### Fixes
Recommended fix first. For each: what changes, how it addresses the root cause, tradeoffs.

### Tests
Tests to run; what regression test should be added so this can't recur.
