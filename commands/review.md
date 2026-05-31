---
description: Recap the session's goal, list every PR it opened, review each in parallel, then merge / request-changes / close-as-duplicate per verdict.
---

Review the PRs this session produced and decide what ships. Arguments (optional): $ARGUMENTS

- Default: review every PR opened in this session, score against the session's stated goal, act on the verdicts.
- Pass an explicit PR list (e.g. `#412 #413`) in `$ARGUMENTS` to review only those.
- Pass `dry-run` to print the plan and stop.
- Pass `no-merge` to comment verdicts but never merge (request-changes and close-as-duplicate still execute).

## Two principles to hold throughout

**1. Don't merge without evidence the thing runs.** A PR that "looks correct" is not the same as a PR demonstrated to work. Before merging, you need one of:

- A green CI run on the PR's head SHA (`gh pr checks <pr>`).
- A quoted command + output from this session showing the changed path executing end-to-end (curl response, test run, log line, screenshot — quoted, not paraphrased).
- An explicit user approval that overrides this gate. "Ship it" or selecting "Yes, merge" counts. "It looks good" does not.

If none apply, the verdict is **request-changes**, not merge. State the missing evidence in the comment.

**2. No over-review.** The review subagents are not here to find every possible improvement. They answer five questions and stop:

1. **Goal:** Does this PR meet the session goal it was opened for?
2. **Evidence:** Is there proof the changed path runs?
3. **Quality:** Any concrete bugs, dead branches, obvious defects?
4. **Cleanup:** Does it remove what it replaces, or leave parallel implementations?
5. **Scope:** Did it stay in its lane, or sprawl into unrelated changes?

Subagents must NOT comment on:

- Style nits enforced by lint/format.
- Hypothetical future requirements ("what if we later want…?").
- Naming preferences absent concrete confusion.
- Test coverage for trivial guards / constants.
- Suggestions to add abstractions or helpers "for flexibility."
- Documentation suggestions unless a brand-new user-facing surface has no docs at all.

The output is a terse verdict with file:line evidence, not an essay.

## Process

### 1. Recap the session goal

Reconstruct intent before looking at any PR. Sources:

- The user's first substantive message in this conversation — quote it.
- Any plan confirmed (look for plan-mode exits or explicit "let's do X, Y, Z" approval).
- Issue tracker tickets opened or referenced.
- Any teams/parallel-agent distribution plan from this session.

Present the recap as:

```
Session goal: <one or two sentences, quoted or tightly paraphrased>
Confirmed by:  <message timestamp, "plan approved", or ticket ID>
Subgoals:
  - <subgoal 1>          → expected surface: <files/dirs>
  - <subgoal 2>          → expected surface: <files/dirs>
```

If you can't ground the goal in something the user said in this session, stop and ask via `AskUserQuestion` for a one-sentence goal before continuing. Reviewing without a goal is theater.

### 2. Discover the PRs

In parallel:

```bash
gh pr list --author "@me" --state open --limit 50 --json number,title,headRefName,baseRefName,createdAt,url,isDraft,mergeable,mergeStateStatus,statusCheckRollup
git log --oneline --since="6 hours ago" --all
git branch -a --sort=-committerdate | head -40
```

Build the candidate set from:

- PRs whose `createdAt` is inside this session's window.
- PRs whose head branch was created in this session.
- PRs explicitly named in `$ARGUMENTS` (these override the auto-detect).
- PRs opened by parallel-agent runs started in this session.

If the result is empty, say so and stop.

### 3. Build the dependency graph

For each candidate PR, record `{number, title, head, base, draft, ci_state, mergeable, url}`. Then construct the stack graph:

- If PR B's `baseRefName` equals PR A's `headRefName`, B is **stacked on** A.
- PRs sharing the same base (e.g. `main`) are **independent**.
- A chain `A → B → C` must merge in order A, then B, then C. After A merges, B's base may auto-retarget — or you may need `gh pr edit <B> --base main`.

Validate with `gh pr view <n> --json baseRefName,headRefName` — don't trust stale cached output.

### 4. Print the recap and table

**Use a GitHub-flavored markdown table — not ASCII box-drawing.** Markdown tables auto-size; box-drawing breaks the moment a title is wider than the placeholder.

```markdown
Session goal: <quoted>

PRs opened this session: N

| PR    | Title                              | Base          | Head            | CI      | Mergeable | Notes               |
|-------|------------------------------------|---------------|-----------------|---------|-----------|---------------------|
| #412  | feat: add oauth refresh            | main          | auth-refresh    | green   | clean     |                     |
| #413  | feat: wire login UI                | auth-refresh  | login-ui        | pending | clean     | stacked on #412     |
| #414  | test: add login flow e2e           | login-ui      | login-e2e       | —       | unknown   | possible duplicate? |

Stack graph:
  main ← #412 ← #413 ← #414     (merge order: 412, 413, 414)

Independents: none.
```

Rules for the table:

- One row per PR; never split across lines (markdown tables fail silently if `|` counts mismatch).
- Truncate Title to ~50 chars; the PR number is the unambiguous identifier.
- Single-line cells. No `<br>`, no nested content.
- Use Notes for "stacked on #X", "draft", "conflicts", "possible duplicate" — not extra rows.
- Empty cells use `—`.

Flag any PR that looks like a duplicate or already-merged-elsewhere in Notes — confirm with `git rev-list --count <head>..origin/main` and `git log origin/main --grep "<title>"` before claiming it.

### 5. Spawn review subagents in parallel

Use the `Agent` tool. **One subagent per PR, dispatched in a single message** so they run concurrently. Set the model explicitly — don't let it default.

Each subagent gets this brief — fill in the bracketed parts:

```
Mission: Review PR #<N> and return a terse verdict.

Session goal: "<quoted session goal>"
This PR's stated purpose: "<quoted>"
Stacked context: <"depends on #X" | "independent">

Read these:
  - The PR diff:    gh pr diff <N>
  - The PR body:    gh pr view <N> --json title,body,headRefName,baseRefName,statusCheckRollup
  - CI status:      gh pr checks <N>
  - For any non-trivial change, the full touched file (not just the hunk).

Answer EXACTLY these five questions, in order, with file:line evidence quoted from the diff:

1. GOAL: Does this meet the session goal? Quote the goal. Quote the diff lines that satisfy it. (YES / PARTIAL / NO)
2. EVIDENCE: Is there proof the path runs? Quote CI, test output, or commands from the PR description. (YES / MISSING)
3. QUALITY: Any concrete bugs, dead branches, defects? Quote file:line. ("clean" is valid.)
4. CLEANUP: Does it remove what it replaces? If a sibling old path remains, quote it. (CLEAN / DUPLICATES <path>)
5. SCOPE: Did it stay in its lane? List files outside the stated purpose. (TIGHT / SPRAWL: <files>)

Then give ONE verdict:
  - SHIP — all five good. State why this is safe to merge in one sentence.
  - REQUEST_CHANGES — 1-5 bullets, each with file:line and the exact change needed. No prose around them.
  - CLOSE_DUPLICATE — work already in main (quote the commit) or another open PR (quote the #).

Do NOT propose abstractions, renames, doc additions, test additions for trivial code, naming preferences, or "what if later." Do NOT relitigate lint/format. Bar is "reasonable and meets the goal," not "perfect."

Return file:line quotes for every claim. Do NOT paraphrase. If you can't quote it, don't claim it.
```

### 6. Show the verdict matrix

```markdown
**Verdicts:**

- #412 — SHIP — auth refresh complete, CI green, replaces old middleware.
- #413 — REQUEST_CHANGES — 3 asks: session token location, missing error handling, dead import.
- #414 — CLOSE_DUPLICATE — e2e already covered by tests/login.e2e.ts (commit a97ae40 in main).

**Merge plan (stack order):**

1. #412 — merge (squash)
2. #413 — pending fixes; do not merge yet
3. #414 — close as duplicate of a97ae40
```

If any PR is REQUEST_CHANGES, the stack pauses at that point — do not merge anything stacked on top.

### 7. Confirm before write actions

Use `AskUserQuestion` with concrete counts: "Merge N PRs, request changes on M, close C as duplicate?" Options:

- "Yes — execute the plan"
- "Just comment, don't merge" (equivalent to `no-merge`)
- "Show me one verdict's evidence first"

If `$ARGUMENTS` contains `dry-run`, skip this and stop after printing the plan.

### 8. Execute the verdicts

Process PRs in stack order (base → tip).

**8a. SHIP — comment + merge.**

Post a brief approval comment stating the safety case (2-4 lines max):

```bash
gh pr comment <N> --body "$(cat <<'EOF'
Reviewed against session goal: <one-line goal>.

Safe to merge:
- Meets goal: <one-line, file:line>
- Evidence: CI green on <SHA> / <quoted output if applicable>
- Cleanup: removed <old thing> at <file:line>
- Scope: stayed within <surface>
EOF
)"
```

Then merge. Default to **squash** for feature/fix PRs (clean main history), **merge commit** for stacked PRs where the per-PR boundary matters. Use `--auto` only if CI is still running.

```bash
gh pr merge <N> --squash --delete-branch
# or for stacked work:
gh pr merge <N> --merge --delete-branch
```

For stacked PRs: after merging the base, the next PR's base may auto-retarget; if not, run `gh pr edit <next> --base main` and confirm `mergeStateStatus` becomes `clean`.

**8b. REQUEST_CHANGES — comment with concrete asks.**

Bullets, each `file:line — exact change — why`. No padding, no "great work overall":

```bash
gh pr comment <N> --body "$(cat <<'EOF'
Blocking, in order:

- src/auth/login.ts:42 — store via `setSession()` from auth/session.ts, not `localStorage.setItem('token', ...)`. Plaintext-token-in-localStorage was the bug fixed in #401 — this reintroduces it.
- src/auth/refresh.ts:18 — the `if (!res.ok)` branch returns without logging; the original handler in auth/legacy.ts:88 emits a structured error. Add the same.
- src/auth/refresh.ts:3 — `import { unused } from './helpers'` is dead; remove.

Not blocking — leave for follow-up if you want:
- (nothing)
EOF
)"
```

Don't auto-request formal review (`gh pr review --request-changes`) unless `$ARGUMENTS` contains `formal-review` — a comment is enough and avoids notification noise.

**8c. CLOSE_DUPLICATE — comment + close.**

```bash
gh pr comment <N> --body "Closing as duplicate — this work is already in main as <SHA> (\"<commit subject>\") merged at <date>. The diff between this branch and main is empty modulo whitespace."
gh pr close <N> --delete-branch
```

If the duplicate is another open PR rather than already-merged work, link both ways:

```bash
gh pr comment <N> --body "Closing in favor of #<other>, which covers the same change and is further along."
gh pr comment <other> --body "Folded in scope from #<N> (closed)."
gh pr close <N> --delete-branch
```

### 9. Verify and report

In parallel:

```bash
gh pr list --state all --search "<the PR numbers we acted on>" --json number,state,mergedAt,closedAt
git fetch --prune origin
```

Final table — what merged, what got request-changes, what closed, what failed. For each merge quote the merge commit SHA. For each close quote the duplicate reference. If any merge or close failed, surface it.

## Stacked-PR rules

A stack is `main ← A ← B ← C`. The rules:

- **Review order:** any (subagents run in parallel; verdicts come back independent).
- **Merge order:** strictly root-up. A, then B, then C. Never merge a child before its parent.
- **If a parent is REQUEST_CHANGES, every PR stacked on top is BLOCKED**, even if their own verdict was SHIP.
- **After merging A, retarget B's base to `main`** if GitHub didn't already: `gh pr edit <B> --base main`. Then re-check mergeability.
- **If B has merge conflicts after A lands**, don't rebase/force-push on the author's behalf. Comment on B explaining the conflict and stop the chain.

## Duplicate detection

A PR is a duplicate only when one of these is true — verify before claiming:

1. **Already in main:** the head adds nothing — `git rev-list --count <head>..origin/main` returns the same count as `git rev-list --count <base>..origin/main`, and `git diff origin/main..<head>` is empty/whitespace-only.
2. **Squashed-merged elsewhere:** subsumed by a recent main commit — `git log origin/main --oneline --since="14 days ago" | grep -i "<keyword>"` finds it; confirm by hand.
3. **Open elsewhere:** another open PR touches a strict superset of the same files for the same goal.

If you can't run one of these and get a definitive answer, the verdict is REQUEST_CHANGES with "needs human triage: possible duplicate of <SHA/#>", not CLOSE_DUPLICATE.

## Don'ts

- Don't merge a REQUEST_CHANGES verdict because it "looks mostly fine."
- Don't merge without green CI, a quoted run, or explicit user override.
- Don't post comments demanding abstractions, naming changes, or speculative future-proofing.
- Don't merge stacked PRs out of order.
- Don't force-push, rebase the author's branch, or amend their commits to "help."
- Don't auto-request formal review unless `$ARGUMENTS` contains `formal-review`.
- Don't summarize PRs with prose like "Overall this is a solid change that…". Verdicts are terse. Evidence is quoted.
- Don't fabricate a session goal because you can't find one. Ask in one sentence and continue.
