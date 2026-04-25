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

## Step 4: Commit and Push

Run `git status` and `git diff` (staged + unstaged) in parallel.

If there are uncommitted changes that represent completed work, follow `/commit` conventions:

1. **Group the changes.** Cluster files that belong together into logical groups. Each group = one commit. Unrelated changes must NOT be lumped into a single commit.
2. **Safety check:** if a sensitive file is present (`.env`, `credentials.json`, `*.key`, `*.pem`, `id_rsa*`), warn the user and stop.
3. For each group:
    - `git add <files-in-group>` (explicit paths, not `-A`)
    - Conventional-commit message: `<type>: <description>`. Under 72 chars. Lowercase. Imperative mood. No emojis, no scope prefix, no Co-Authored-By, no trailers.
    - `git commit -m "<message>"`
4. After all commits: `git push` with `run_in_background: true`.
5. Do NOT commit incomplete work -- if it's half-done, say so in Step 6.

If the tree is clean, move on.

## Step 5: Close Tickets and Report Results

Check if there's a Linear task for this work:

```bash
~/.agents/skills/linear/scripts/linear tasks
```

If a task is In Progress or Todo for this work:
- Confirm the task scope matches what was actually done (not what was planned)
- **Add a comment with evidence of completion:** screenshots of the working feature, terminal output showing test results, commit hashes, or other concrete proof. The comment should let anyone reviewing the ticket understand what was done and verify it without reading code.
- Mark it done: `~/.agents/skills/linear/scripts/linear update <ID> --done`

If the task is only partially done, do NOT mark it done. Instead:
- Update the status to reflect current state
- Add a comment describing what was completed, what's left, and any blockers
- Include whatever evidence you have for the completed portion

Check TODO.md at the repo root -- mark off any related items.

## Step 6: Verdict

Present a clear summary:

```
DONE:
- [list of completed items from Step 1 checklist]

TESTED:
- [what was tested and how]

COMMITTED:
- [commit hash + message, or "already clean"]

REMAINING:
- [anything not done -- be honest]
```

**If everything is done and tested**, ask the user with `AskUserQuestion`:
1. "Pick up next task" -- run /next
2. "Done for now" -- stop here
3. "There's more to do" -- user will clarify

**If anything is NOT fully done**, do not ask. Instead:
1. State clearly what remains and why
2. Propose a concrete plan: what you will do next, in what order, and what the expected outcome is
3. Then keep working. Do not stop.
