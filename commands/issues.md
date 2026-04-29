---
description: Work with the project's issue tracker (Linear, GitHub Issues, Jira, etc.) — auto-detects whichever skill or CLI is available.
---

You're being asked to do something with the project's issue tracker: $ARGUMENTS

(If `$ARGUMENTS` is empty, default to "show me what's on my plate right now.")

## Step 1: Find the available tracker

Check in this order. Stop at the first one that's actually present.

1. **Skill-level integration.** Look for a skill in this loaded session whose name or description matches an issue-management system. Common names: `linear`, `github`, `jira`, `gitlab`, `shortcut`, `asana`. If one exists, read its `SKILL.md` and follow it — that file is the contract.

2. **Repo-level signal.** No matching skill? Check the repo:
   - `git remote -v` → if origin is `github.com`, GitHub Issues is the likely tracker. Use `gh issue list`, `gh issue view`, etc.
   - Look for `.linear/`, `linear.config.*`, or env vars like `LINEAR_API_KEY` / `LINEAR_TEAM_KEY`.
   - Look for Jira/Atlassian config (`.jira-cli.yml`, `JIRA_URL` in env).

3. **Ask.** If nothing's detectable, ask the user where issues live (Linear team key, GitHub repo, Jira project, etc.) — once. Save the answer to memory if it'll keep coming up.

## Step 2: Do the thing

Map the user's intent onto the tracker's primitives:

| Intent | What to do |
|---|---|
| "what's on my plate" / "my queue" | List issues assigned to the current user, scoped to the active sprint/cycle/milestone if the tracker has one. |
| "pick up X" / "claim X" | Move the issue to In Progress (or equivalent) and assign it to the current user. |
| "comment X: ..." | Append a comment. |
| "close X" / "done with X" | Move to Done with proof — link a PR, paste a screenshot, attach a deploy URL, or quote a metric. Don't close without evidence. |
| "create X" | New issue with title (and description if provided). Default priority Medium unless told otherwise. |
| "search X" | Free-text search; show top matches with status + assignee. |

If the skill (Step 1) gives you specific commands for these, **use them verbatim** — don't paraphrase the skill's CLI invocations.

## Step 3: Report concisely

After doing the action, report:
- What you did (one line)
- Issue ID + title (so the user can click through)
- Anything blocking (auth missing, ambiguous match, etc.)

## Anti-patterns

- Don't assume Linear. The system repo doesn't ship a Linear skill — that's intentional. Detect first.
- Don't bypass the skill. If a `linear` (or `github`, etc.) skill is loaded, its SKILL.md is the source of truth — its commands are usually richer than what you'd reinvent (proof attachments, agent-lane labels, etc.).
- Don't close issues without proof. Engineering: PR URL or commit URL or screenshot of tests passing. Growth/content: published URL or metric.
- Don't create duplicates. Quick search before creating a new issue.
