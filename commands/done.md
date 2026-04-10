---
description: Verify work is truly done end-to-end, run missing tests, close tasks, then pick up next work
---

You are checking whether the current work is actually done. Context: $ARGUMENTS

Do NOT skip steps. Do NOT claim done until every check passes.

## Step 1: Recall What Was Asked

Re-read the conversation from the beginning. Build a checklist of every goal, requirement, and commitment you made:

- What did the user originally ask for?
- What did you agree to do along the way?
- Were there follow-up requests or scope changes?

Write the checklist out explicitly. Every item needs a verdict: DONE, NOT DONE, or PARTIALLY DONE.

## Step 2: Verify the Code

For every file you changed:

```bash
git diff --name-only  # what changed?
git status            # anything uncommitted?
```

- Read the changed files. Is the implementation complete? No TODOs, no placeholder logic, no half-finished branches?
- Does the code do what was asked, or did you solve a slightly different problem?
- Any obvious bugs, missing error handling on critical paths, or broken imports?

If anything is incomplete, fix it now. Do not proceed to Step 3.

## Step 3: Test

This is the most important step. "It compiles" and "unit tests pass" are not done.

**Figure out what testing is appropriate:**
- Was this a bug fix? Reproduce the original bug scenario and confirm it's fixed.
- Was this a new feature? Trigger the real flow end-to-end and see real output.
- Was this a refactor? Run the full test suite. Confirm behavior is unchanged.
- Was this configuration/infra? Execute it. See the real effect.

**Check what testing was already done in this session:**
- Did you run any tests? What were the results?
- Did you trigger the actual feature/flow, or just verify the code looks right?
- Did you see real output from the thing you built?

**If E2E testing has NOT been done, do it now.** Find a way to exercise the real path:
- Run the command, hit the endpoint, trigger the flow, execute the script
- If a blocker prevents testing, work around it -- override config, reduce scope, run manually
- Show the actual output

If tests are needed and don't exist, write them before proceeding.

## Step 4: Update Task Management

Check if there's a Linear task for this work:

```bash
LINEAR=$(find ~/.agents/versions -name linear -path '*/skills/linear/scripts/*' -type f 2>/dev/null | head -1)
$LINEAR tasks
```

If a task is In Progress for this work:
- Confirm the task scope matches what was done
- Mark it done: `$LINEAR update <ID> --done`
- Add a brief comment if the implementation has notable decisions

Check TODO.md at the repo root -- mark off any related items.

## Step 5: Commit if Needed

If there are uncommitted changes that represent completed work:
- Stage and commit with a clear message
- Do NOT commit incomplete work

## Step 6: Verdict

Present a clear summary:

```
DONE:
- [list of completed items from Step 1 checklist]

TESTED:
- [what was tested and how]

REMAINING:
- [anything not done -- be honest]
```

If everything is done and tested, ask the user:

Use `AskUserQuestion` with options:
1. "Pick up next task" -- run /next
2. "Done for now" -- stop here
3. "There's more to do" -- user will clarify

If anything is NOT done, state what remains and keep working. Do not ask -- just fix it.
