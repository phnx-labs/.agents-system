---
name: feature
description: "Quality dev workflow with independent code review. Guides through Plan, Implement, Review, Fix, Test phases. Spawns Codex/Gemini reviewers to catch bugs. Use when implementing a non-trivial feature."
disable-model-invocation: true
---

# Feature Development Workflow

You are implementing a feature with enforced quality gates. A Stop hook will block you from claiming "done" until reviewers have been spawned, findings processed, and tests run.

## Current State

!`${CLAUDE_PLUGIN_ROOT}/scripts/state.sh read`

## Phase 0: Initialize

If no active feature exists, initialize one:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/init.sh "$ARGUMENTS"
```

## Phase 1: Planning

Assess complexity of the feature:

- **Simple** (1-3 files, well-understood pattern, no new abstractions): Skip to Phase 2.
- **Complex** (4+ files, cross-cutting, new patterns, concurrency, security, data model changes): Plan first.

For complex features:
1. Read relevant code. Identify all touch points and dependencies.
2. Spawn a planning agent for an independent perspective:
   ```
   mcp__Swarm__Spawn(
     task_name: "plan-<slug>",
     agent_type: "codex",
     mode: "plan",
     effort: "detailed",
     prompt: "Plan the implementation of: <feature description>. Read the codebase, identify files to change, propose approach, flag edge cases. Do NOT implement -- just plan."
   )
   ```
3. Compare their plan with yours. Synthesize the best approach.
4. Present the plan to the user. Get approval before proceeding.

Transition to implementing:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/state.sh set phase implementing
```

## Phase 2: Implementing

Build the feature. Follow existing project patterns.

Rules:
- Read existing code before writing new code
- Search for existing abstractions before creating new ones
- Keep changes minimal and surgical
- Track which files you modify

When all code is written and you have no known gaps, transition immediately to review. DO NOT tell the user you are "done" -- you are NOT done yet.

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/state.sh set phase reviewing
```

## Phase 3: Review (mandatory)

Spawn exactly 2 reviewer agents using DIFFERENT agent types.

### Step 1: Gather context

Collect:
- `git diff` of all changes (staged + unstaged)
- List of files modified with brief description of each change
- The feature description and any design decisions made

### Step 2: Read the reviewer prompt template

Read `${CLAUDE_PLUGIN_ROOT}/skills/feature/references/reviewer-prompt.md` and construct the prompt by replacing placeholders with the actual context gathered above.

### Step 3: Spawn reviewers

```
mcp__Swarm__Spawn(
  task_name: "review-<slug>",
  agent_type: "codex",
  mode: "plan",
  effort: "detailed",
  prompt: <constructed reviewer prompt>
)

mcp__Swarm__Spawn(
  task_name: "review-<slug>",
  agent_type: "gemini",
  mode: "plan",
  effort: "detailed",
  prompt: <constructed reviewer prompt>
)
```

After spawning both, update state:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/state.sh set reviewers_spawned true
${CLAUDE_PLUGIN_ROOT}/scripts/state.sh set review_task "review-<slug>"
```

### Step 4: Wait and poll

Wait at least 2 minutes, then check:
```
mcp__Swarm__Status(task_name: "review-<slug>")
```

### Step 5: Process findings

When both reviewers complete, present a consolidated summary:

**Overlapping concerns** (both reviewers flagged -- high confidence):
- [issues]

**Codex-only findings:**
- [issues]

**Gemini-only findings:**
- [issues]

Update state:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/state.sh set reviews_received true
```

If reviewers found 0 actionable issues, skip to Phase 5.
Otherwise, transition to fixing:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/state.sh set phase fixing
```

## Phase 4: Fixing

Address each reviewer finding:
1. Fix the issue, OR
2. Explain with evidence why it's not applicable

After all issues are addressed:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/state.sh set fixes_applied true
${CLAUDE_PLUGIN_ROOT}/scripts/state.sh set phase testing
```

## Phase 5: Testing

1. Run existing test suites relevant to the changes
2. Write new tests for:
   - Happy path of the new feature
   - Edge cases identified during review
   - Error/failure paths
3. Use REAL data and fixtures -- not synthetic test helpers
4. Run all tests and report results

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/state.sh set tests_passed true
${CLAUDE_PLUGIN_ROOT}/scripts/state.sh set phase done
```

## Phase 6: Done

Archive state and report summary:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/state.sh archive
```

Present to the user:
- What was built
- Review summary (issues found, issues fixed)
- Test results
- Files changed

## Escape Hatches

If the user says "skip review", "just ship it", "cancel", or similar:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/state.sh set phase done
${CLAUDE_PLUGIN_ROOT}/scripts/state.sh archive
```
Tell the user: "Review skipped per your request. State archived."

If you need to abandon entirely:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/state.sh delete
```
