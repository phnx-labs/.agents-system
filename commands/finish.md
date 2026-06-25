---
description: Finish the current task end-to-end instead of stopping at a recap, blocker, or partial handoff
---

You are finishing the current task. Context: $ARGUMENTS

This command is not a recap command. It is an execution intervention: recover the original goal, identify what remains, take the next concrete action, verify the real flow, and keep going until the task is truly delivered or a hard external blocker is proven.

> **`/finish` vs `/done`** — `/finish` is the **anti-stopping driver**: its whole job is to refuse to stop at a recap/blocker/partial handoff and push the current task to delivered. It does *not* run a release step. When the work is already delivered and you want the **closing checklist + ship gate** (E2E verify → commit → PR → optional package release → close tickets), use **`/done`**. For draining a *queue* of tickets/branches all the way to merged, use `/code:loop`.

## Step 1 - Recover The Contract

Re-read the conversation from the start and write a short working checklist:

- **Original ask:** what the user asked you to deliver
- **Scope changes:** follow-up requests or constraints added later
- **Commitments made:** actions you said you would do
- **Current state:** what is already done, in progress, or not started

Every checklist item needs a verdict: DONE, IN FLIGHT, NOT STARTED, or BLOCKED.

Do not trust memory. Back each DONE or BLOCKED verdict with fresh evidence: file:line, command output, test result, PR/deploy URL, HTTP response, ticket state, or the exact error.

## Step 2 - Convert Status Into Actions

For every IN FLIGHT, NOT STARTED, or BLOCKED item, choose the next executable action.

Before you call something blocked, make three distinct attempts to move it forward:

- Try the direct path.
- Try the canonical project script, CLI, browser automation, remote machine, or service-specific tool.
- Reduce scope to verify the critical path manually.

Quote the result of each attempt. If you cannot quote it, do not claim it.

If there are two or more independent actionable workstreams, start parallel work with the project's agent/team mechanism instead of queueing the tasks one by one. Give each teammate a clear boundary contract and require file:line quotes for every claim.

## Step 3 - Take The Next Action Now

Pick the smallest remaining item that advances delivery and execute it immediately.

Do not ask the user to choose between continuing and stopping. Do not hand back a mechanical command for the user to run when you can run it, drive it through a browser, use a remote box, call an API, or request the exact permission needed.

Allowed user questions are only for true forks that require human judgment, credentials, payments, public posting, destructive operations, or explicit production authorization. Use `AskUserQuestion` with forward-moving options. The first option should be the recommended action.

## Step 4 - Verify End-To-End

"Done" requires real output from the real path.

Choose verification based on the task:

- Code change: run the relevant tests and exercise the affected flow.
- Bug fix: reproduce the original failure or closest available case, then show the fixed behavior.
- CLI/script change: run the command and quote the output.
- API change: call the endpoint and quote the response.
- UI change: open the real screen and verify it behaves correctly.
- Deploy/release: run the canonical deploy/release script, then health-check or fetch the deployed artifact. Script completion alone is not proof.

If unrelated pre-existing failures block a full suite, prove that they are unrelated with a baseline run, touched-path tests, and file/commit evidence. Then use the project's documented narrower verification or deployment path if one exists. Do not hide behind a full-suite failure that is outside the task's blast radius.

## Step 5 - Ship The Finished Work

After verification:

- Check `git status`.
- Inspect every changed file in the diff.
- Commit completed work if the project workflow expects agent commits.
- Open or update the PR if that is the delivery path.
- Deploy or release if the project rules say changed deployable surfaces must ship.
- Update the issue tracker only with proof: commit, PR, deploy URL, test output, or health-check response.

Do not create docs, tickets, or summary files unless the task or project workflow requires them.

## Step 6 - Final Report

Only report after you have acted.

Use this shape:

```
Goal:
- [one sentence]

Delivered:
- [completed item] - proof: [file:line / command output / URL / response]

Verified:
- [test or real-flow command] - result: [actual result]

Remaining:
- None
```

If anything remains, it must be one of:

- A proven external blocker with three quoted attempts.
- A user-only action such as payment, credentials, destructive approval, public posting, or strategic judgment.
- A deliberately created follow-up ticket with acceptance criteria and proof that the current task's shippable slice is complete.

Forbidden endings:

- "Pick one and I'll continue."
- "Let me know if you want me to proceed."
- "The remaining sequence is mechanical."
- "I can stop here."
- Any status-only recap that does not take the next action first.
