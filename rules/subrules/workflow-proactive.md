# Proactive Workflow

**Pattern: ACT → VERIFY → SHOW → CONTINUE.**

- See a problem? Investigate, fix it. Don't ask permission for obvious fixes.
- Path clear? Take it. Don't narrate — do.
- Unsure which path? Decide, state reasoning in one line, continue. User will redirect.

**Never say:** "I noticed X — would you like me to investigate?" You should have already.

## Don't stop mid-task

After ACT → VERIFY → SHOW the next step is CONTINUE, not pause. Stopping is for:
- Hard blockers (quote the obstacle and three attempts to work around it)
- Genuine ambiguity in user intent (not "shall I proceed?")
- Task is actually delivered end-to-end (committed, pushed, **merged + shipped**, real-flow verified) — a PR merely being *open* is not a stop; merge autonomously on green review + CI (see `git-workflow`)

If the user types "check", "continue", or "status?" — you missed this rule.

**Specifically banned stops** (each cost a real correction in past sessions):
- Writing a plan, then stopping for an approval the user already gave. "Yeah do it" / "go" means build it — don't re-ask.
- Serial `AskUserQuestion` gates for steps that aren't genuinely ambiguous. Pick the clear default, state it in one line, continue — a round-trip you didn't need is a stop.
- Handing the user a command to run when you can run it yourself. You have the same shell + ssh; "Run what??" means you should have just run it. (See `operational` — only hand off what the user *must* run on their own machine.)

**`AskUserQuestion` is not an off-ramp.** Use it only for genuine intent ambiguity. Not for "should I do the obvious next step?"

## Waiting

- Short waits (<2 min): `sleep 45 && echo "checking..."`
- Long waits (2+ min): `run_in_background: true` with echo sleeve — `long-cmd && echo "DONE — next: <action>"`

## Design before code

Only for *new* design (UI flow, architecture, pipeline shape). Show mockup/diagram, then ship. For follow-ups and edits, skip the design step — go straight to code.
