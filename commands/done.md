---
description: Verify work is truly done end-to-end, test, release if needed, then close or create tickets
---

You are checking whether the current work is actually done. Context: $ARGUMENTS

Do NOT skip steps. Do NOT claim done until every check passes.

> **`/done` vs `/finish`** — `/done` is the **closing checklist + ship gate**: verify end-to-end, then commit → PR → *optionally cut a package release* → close/create tickets, ending by reporting and asking what's next. If instead you're *stalling mid-task* (stopped at a recap, a blocker, or a partial handoff) and need to be driven to completion without stopping, use **`/finish`**. `/done` checks-and-ships; `/finish` refuses-to-stop. (For driving a queue of tickets/branches all the way to merged, that's `/code:loop`.)

## Step 1: Recall What Was Asked

Re-read the conversation from the beginning. Build a checklist of every goal, requirement, and commitment you made:

- What did the user originally ask for?
- What did you agree to do along the way?
- Were there follow-up requests or scope changes?

Write the checklist out explicitly. Every item needs a verdict: DONE, NOT DONE, or PARTIALLY DONE.

## Step 2: Verify the Code

For every file you changed:

```bash
git diff --name-only
git status
```

- Read the changed files. Is the implementation complete? No TODOs, no placeholder logic, no half-finished branches?
- Does the code do what was asked, or did you solve a slightly different problem?
- Any obvious bugs, missing error handling on critical paths, or broken imports?

If anything is incomplete, fix it now. Do not proceed to Step 3.

## Step 3: Test

This is the most important step. "It compiles" and "unit tests pass" are not done.

**Figure out what testing is appropriate:**
- Bug fix? Reproduce the original bug scenario and confirm it's fixed.
- New feature? Trigger the real flow end-to-end and see real output.
- Refactor? Run the full test suite. Confirm behavior is unchanged.
- Configuration/infra? Execute it. See the real effect.

**Check what testing was already done in this session:**
- Did you run any tests? What were the results?
- Did you trigger the actual feature/flow, or just verify the code looks right?
- Did you see real output from the thing you built?

**If E2E testing has NOT been done, do it now.** Find a way to exercise the real path:
- Run the command, hit the endpoint, trigger the flow, execute the script
- If a blocker prevents testing, work around it — override config, reduce scope, run manually
- Show the actual output

If tests are needed and don't exist, write them before proceeding.

## Step 4: Update Docs

If the work added a new module, command, flag, config setting, data flow, or user-visible behavior, the docs that describe those things need to move with the code. Stale docs are worse than no docs.

**Walk every changed file and ask: did this change anything a human reader would look up?** Check each surface that applies:

- **`AGENTS.md` / `CLAUDE.md` / `GEMINI.md`** (root or affected subdirectory) — these are the canonical map files. If you added a new module, new top-level area, new gotcha, or a new file-locations pointer, add a one-line entry. Keep entries short (these are maps, not territory). `CLAUDE.md` / `GEMINI.md` are typically symlinks to `AGENTS.md` — edit the real file.
- **`README.md`** — if user-facing setup/usage/installation/quickstart changed (new flag, new env var, new install step, new command), update it.
- **`docs/*.md`** (or `docs/` subtree) — if you changed an architectural flow that has a design doc (e.g. lifecycle, state machine, sequence diagram), update it. Don't write new design docs unless asked — extend the existing one.
- **`CHANGELOG.md`** (if the repo has one) — add a line for the user-visible change under the next-version section.
- **Help text / `--help` output** — if you added/renamed/removed a CLI flag, a slash command argument, a config key, or a tool parameter, update the help string in code AND any examples in docs that show the old usage.
- **In-code descriptions** — `package.json` `contributes.*.description` (VS Code extension settings/commands), CLI usage strings, config-schema descriptions, JSDoc on exported types if user-facing.
- **Comments at the entry points** you changed (the top of the file or function) — if the contract changed, the comment changed.

**What does NOT need a docs update:**
- Bug fixes (the code IS the doc — commit message captures the why)
- Internal refactors with no behavior change
- Test-only changes
- Small renames where the new name is self-evident

**Anti-patterns to avoid:**
- Don't create a new `.md` file when an existing one already covers the area. Extend it.
- Don't write tutorial-length prose in `AGENTS.md` — that file is a map (one line per area, pointer to code).
- Don't duplicate. If the keybindings live in `package.json`, the doc says "see `package.json`", not the actual binding list.
- Don't add a doc bullet you couldn't immediately point at the new code from.

If you skip this step, justify it explicitly in the Step 9 recap (e.g. "docs unchanged: pure bug fix, no user-visible surface").

## Step 5: Commit and PR

If there are uncommitted changes that represent completed work:

```bash
git status
git diff --staged
```

- Stage and commit with a clear message describing what was done
- Do NOT commit incomplete or broken work

**If on a feature branch and work is complete, open a PR:**

```bash
# Check if on a feature branch (not main/master)
git rev-parse --abbrev-ref HEAD
```

If on a feature branch:

1. Push the branch: `git push -u origin HEAD`
2. Create PR with summary of changes:
   ```bash
   gh pr create --title "..." --body "..."
   ```
3. Export session and attach as a SECRET gist (never `--public` by default — transcripts can leak repo internals; only use `--public` if the target repo is itself public AND you've reviewed the transcript):
   ```bash
   agents sessions --last 50 --markdown > /tmp/session-export.md
   GIST_URL=$(gh gist create /tmp/session-export.md --desc "Session transcript for PR" | tail -1)
   gh pr comment --body "## Session Context
   [Session transcript]($GIST_URL)"
   ```

This creates an audit trail linking the PR to the reasoning that produced it.

## Step 6: Release (if applicable)

Check if this work involves a publishable package:

```bash
[ -f package.json ] && echo "npm package found"
[ -f Cargo.toml ] && echo "rust crate found"
[ -f pyproject.toml ] && echo "python package found"
[ -f scripts/release.sh ] && echo "release script found"
```

If a release is needed:

1. Run the build: `scripts/build.sh` or equivalent
2. Run the full test suite: `scripts/test.sh` or `bun test` / `npm test` / `cargo test`
3. If tests pass, use `AskUserQuestion` to confirm release:
   - "Release v{version} to {registry}?" with options: Yes / No / Skip release

4. If confirmed, run release: `scripts/release.sh --confirm` or equivalent
5. Verify the release landed (check the registry, not just the script output)

## Step 7: Update Task Management

Check if there's an active task for this work using the `/tickets` skill or project tracker:

- If a task is In Progress for this work, mark it done with proof (PR link, release version, etc.)
- Check TODO.md at the repo root — mark off any related items

## Step 8: Handle Remaining Items

If anything from Step 1 is NOT DONE or PARTIALLY DONE:

1. Use `AskUserQuestion` to clarify requirements for each remaining item:
   - "How should we handle {item}?" with options based on context
   - "Is {item} still needed?" — Yes, create ticket / No, skip / Defer to later

2. For items that need tickets, create them via `/tickets` skill with:
   - Clear title describing the remaining work
   - Context from this session (what was attempted, what blocked it)
   - Acceptance criteria

## Step 9: Recap and Verdict

**First, summarize the session in 2-3 sentences:**
- What was the original task/request?
- What was accomplished?
- Any notable decisions or tradeoffs made along the way?

**Then present the checklist:**

```
ORIGINAL TASK:
[One sentence describing what the user asked for]

ACCOMPLISHED:
- [completed items with file:line references]

TESTED:
- [what was tested and how — actual commands run, output seen]

PR:
- [PR URL with session gist attached, or "N/A" if on main]

RELEASED:
- [version published, or "N/A" if not a package]

TICKETS CREATED:
- [any new tickets for remaining work, or "None"]

REMAINING:
- [anything deferred — be honest, or "None"]
```

If everything is done and tested, use `AskUserQuestion`:
- "Pick up next task" — check the issue tracker for next priority
- "Done for now" — stop here

If critical items are NOT done, do not ask — just fix them.
