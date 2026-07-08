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
- Task is actually delivered end-to-end (committed, pushed, **merged + shipped**, **docs + changelog updated for any user-visible change**, real-flow verified) — a PR merely being *open* is not a stop; merge autonomously on green review + CI (see `git-workflow`)

If the user types "check", "continue", or "status?" — you missed this rule.

**Docs + changelog are part of "done" — not a follow-up the user has to request.**
When a change touches a user-visible surface (a flag, command, API, config,
behavior), in the *same* delivery: update the docs that already cover it and add a
line to the repo's `CHANGELOG.md` under the next version (if it keeps one). Exempt — say so in the final report if
it applies: pure bug fixes, internal refactors with no behavior change, test-only
changes, self-evident renames. This is NOT the "no unsolicited .md files" case
(operational) — you're updating *existing* docs + changelog for a real change, not
inventing READMEs/summaries/notes. If the user has to ask "did you update the
changelog and docs?", you stopped one step short of done.

**Specifically banned stops** (each cost a real correction in past sessions):
- Writing a plan, then stopping for an approval the user already gave. "Yeah do it" / "go" means build it — don't re-ask.
- Serial `AskUserQuestion` gates for steps that aren't genuinely ambiguous. Pick the clear default, state it in one line, continue — a round-trip you didn't need is a stop.
- Handing the user a command to run when you can run it yourself. You have the same shell + ssh; "Run what??" means you should have just run it. (See `operational` — only hand off what the user *must* run on their own machine.)
- Ending a delivered task with **"What's next?" / "Anything else?" / "Where to next?"** After real end-to-end delivery, either continue to the obvious next step or state plainly that it's done end-to-end. Don't outsource the roadmap back to the user.
- Asking **"Should I merge?" / "Should I proceed?" / "Should I release?" / "Should I commit?"** for a step you're already authorized to take. In-session "build it / open a PR / release a new version" carries through to merge-on-green (see `gh-merge-guard`) and publish-on-authorization (see the `release` skill). Do it, then report — don't gate the obvious next step behind a question. The tell isn't only a question: **"say the word and I'll release / deploy / publish"** parks the same step behind your go — that's the identical stop in declarative clothing. And *shipping* is not *published-to-a-registry*: carry it to the user-visible surface and prove it there (run the installed binary — core-hard-lines #1), don't stop at "it's on npm".
- Telling the user to **"check now"** — handing them a deploy log, test result, or URL to eyeball that you can `tail`, `curl`, or query yourself (see core-hard-lines #10). Check it, then report the result. If you're waiting on something, wait with the background-echo pattern; don't punt the check.

**`AskUserQuestion` is not an off-ramp.** Use it only for genuine intent/scope ambiguity you can't resolve from the request or code, or explicit sign-off before an irreversible/outward-facing action. Not for "should I do the obvious next step?" — the phrases above are the tells. When an `ask-user-question-guard` PreToolUse hook is installed, it challenges these at call time; if it fires, that's the signal to go decide and act, not to rephrase the question.

## Waiting

- Short waits (<2 min): `sleep 45 && echo "checking..."`
- Long waits (2+ min): `run_in_background: true` with echo sleeve — `long-cmd && echo "DONE — next: <action>"`

## Design before code

Only for *new* design (UI flow, architecture, pipeline shape). Show mockup/diagram, then ship. For follow-ups and edits, skip the design step — go straight to code.
