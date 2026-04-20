---
name: rush-cli
description: "Dispatch coding tasks to Rush Cloud (Factory Floor) — agents clone the repo, plan, implement, test, and open a PR. Triggers on: 'rush cloud', 'dispatch to cloud', 'send to cloud agent', 'run on factory floor', 'rush cloud run', or when the user wants to offload an engineering task to a remote agent instead of running it locally."
author: muqsitnawaz
version: 1.0.0
---

# rush-cli

Dispatch engineering tasks to coding agents (Claude, Codex) running in ephemeral sandbox pods on Rush Cloud (Yosemite k8s cluster, Factory Floor). The remote agent clones the repo, plans, implements, writes tests, and opens a PR.

Use this skill when the user wants to:
- Offload a task instead of doing it locally
- Run multiple agent jobs in parallel without blocking the local session
- Hand a Linear issue to an agent for end-to-end execution
- Spin up Claude/Codex on a repo from the terminal without SSH/mac-mini

## Command

```bash
rush cloud run <agent> <owner/repo> --prompt "<task prompt>" [--mode plan|exec]
```

| Flag | Meaning |
|------|---------|
| `agent` | `claude` or `codex` |
| `owner/repo` | GitHub repo (must be in your Prix Cloud GitHub App installation) |
| `-p, --prompt` | Task prompt — see structure below (required) |
| `-m, --mode` | `plan` (explore + write plan only) or `exec` (default — plan then implement + PR) |

The CLI streams agent output live until the run terminates. Auth: `rush login` + Prix Cloud GitHub App installed on the repo's account. Installation ID is auto-discovered.

## Prompt Structure (REQUIRED)

The remote agent gets your prompt verbatim. It does not have your conversation context. The prompt must be self-contained and prescriptive. Always include these six blocks in this order:

1. **Goal** — one sentence
2. **Plan first** — instruct it to run `/plan` before touching code
3. **Scope** — exact deliverables, file paths, what to change
4. **Files to read first** — context the agent needs before writing
5. **Testing** — explicit "write tests for critical areas, run them, report counts"
6. **Delivery** — branch + PR rules (never push to main)
7. **Reflect** — after the PR is open, run `/reflect` and post follow-up ideas

Do NOT include an "Out of scope" block. It encourages the agent to declare too much off-limits and ship a thinner result than you wanted. State the scope precisely instead, and trust the agent not to wander.

### Template

```
## Goal
<one sentence — what success looks like>

## Plan first
Run `/plan` before writing any code. Read the relevant files, produce a concrete
plan (mockups for UI, system diagrams for architecture, before/after for refactors).
You may split work across subagents using the swarm/spawn commands when the task
has independent parallelizable pieces, but every subagent must follow the same
testing + delivery rules below.

## Scope
1. <deliverable 1 — exact file paths and behavior>
2. <deliverable 2>

## Files to read first
- `path/to/file.ts` — why it matters
- `path/to/other.ts` — why

## Testing (mandatory)
Write tests for CRITICAL areas — the ones often missed or that could regress
silently. You do NOT need comprehensive coverage. Focus on:
  - State transitions and merge logic
  - Error paths and edge cases
  - Anything that touches persistence, auth, or external APIs
Run the full test suite. Report exact counts in the PR body
(e.g. "47 pass, 0 fail, 2 pre-existing skips").

## Delivery
- Create your own branch — NEVER push to `main`.
- Branch name: `agent/<short-slug>` (e.g. `agent/role-filter`).
- Open a PR with this structure:
    ## Summary
    - bullet per change with file:line reference
    ## Test plan
    - [x] checklist of what you verified
    - [x] `bun test` (or `go test`, etc.) — N pass, M fail
- For UI/web changes: use the `browser` skill to take before/after screenshots
  and embed them in the PR body.
- Maintain a running checklist as you work — tick items as you go.

## Reflect (after PR is open)
Run `/reflect` on everything you touched. Look for:
  - Adjacent improvements you noticed but didn't ship (cleanup, dead code,
    weak tests, missing error handling near the changed code)
  - Natural follow-ups (next features, refactors unblocked by this PR,
    perf wins, doc gaps)
  - Risks or unverified assumptions worth a second pass
Then:
  1. Post a single comment on the PR titled "Follow-up ideas" listing them
     (use `gh pr comment <pr-number> --body "..."`).
  2. For any item meaty enough to be its own task, create a Linear issue via
     the `linear` skill and link the issue URL inside the PR comment next to
     that item. Skip Linear for tiny nits — those just live in the comment.
Only mark the run complete after: tests pass + PR opened + checklist green +
reflect comment posted.
```

## Examples

### Simple bugfix
```bash
rush cloud run claude muqsitnawaz/agents-cli --prompt "$(cat <<'EOF'
## Goal
Fix the off-by-one in `src/lib/session/parse.ts:142` that drops the last event
of every Codex JSONL session.

## Plan first
Run `/plan`. Read `parse.ts` end-to-end and the matching test file.

## Scope
1. Fix the loop bound at `parse.ts:142`.
2. Add a regression test covering a 3-event Codex session.

## Files to read first
- `src/lib/session/parse.ts`
- `src/lib/session/parse.test.ts`

## Testing (mandatory)
Write a regression test that fails before the fix and passes after.
Run `bun test src/lib/session/parse.test.ts`. Report counts in PR body.

## Delivery
Branch: `agent/codex-parse-off-by-one`. Open PR. Never push to main.

## Reflect
After the PR is open, run `/reflect` on the parser code. Post a "Follow-up
ideas" comment on the PR; create Linear tasks for anything substantive and
link them in the comment.
EOF
)"
```

### Feature (multi-file)
```bash
rush cloud run claude muqsitnawaz/agents-cli --prompt "$(cat <<'EOF'
## Goal
Add `agents sessions --role <user|assistant|thinking|tools>` filter.

## Plan first
Run `/plan`. Map the data flow from CLI option → renderSession → format renderers.
You may spawn subagents for the unit tests in parallel with the implementation.

## Scope
1. Add `--role` to `src/commands/sessions.ts` option list and SessionsOptions type.
2. Add `filterByRole(events, role)` helper in `src/lib/session/render.ts` and call
   it before any format renderer.
3. Validate input — exit 1 on unknown role with a clear error.

## Files to read first
- `src/commands/sessions.ts`
- `src/lib/session/render.ts`
- `src/lib/session/__tests__/render.test.ts`

## Testing (mandatory)
Write unit tests in `src/lib/session/__tests__/render.test.ts` covering each role
value, the empty-match case, and invalid input. Run `bun test`. Report counts.
End-to-end: pick a real session ID, run `agents sessions <id> --role user --json`,
confirm only user messages return.

## Delivery
Branch: `agent/role-filter`. Open PR with file:line references in the Summary.
Never push to main.

## Reflect
After the PR is open, run `/reflect` on the sessions render pipeline. Post a
"Follow-up ideas" comment on the PR (e.g. composing role with other filters,
multi-role select, picker integration). Create Linear tasks for the substantive
ones and link them in the comment.
EOF
)" --mode exec
```

### Web/UI change (with screenshots)
```bash
rush cloud run claude muqsitnawaz/halo --prompt "$(cat <<'EOF'
## Goal
Fix the misaligned "Sign in" button on `/login` (currently overflows on mobile).

## Plan first
Run `/plan`. Use the `browser` skill to load the current `/login` page at 375px
width, take a baseline screenshot, and embed it in the plan.

## Scope
1. Constrain the button container at `app/login/page.tsx`.
2. Verify on iPhone 14 viewport (390x844) and iPad mini (768x1024).

## Files to read first
- `app/login/page.tsx`
- Any shared button/container component imported there

## Testing (mandatory)
After the fix, take after-screenshots at both viewports using the `browser` skill.
Embed before/after pairs in the PR body. Run `bun test` on changed files.

## Delivery
Branch: `agent/login-button-mobile`. Open PR with embedded screenshots.
Never push to main.

## Reflect
After the PR is open, run `/reflect` on the login page. Post a "Follow-up ideas"
comment covering any other responsive issues spotted, accessibility gaps, or
component-extraction opportunities. Create Linear tasks for substantive items
and link them in the comment.
EOF
)"
```

## What the Sandbox Has

Each run gets a fresh ephemeral pod from a warm pool with:
- Claude Code CLI (or Codex CLI) installed via agents-cli
- Shared config from `gh:muqsitnawaz/.agents` (skills, hooks, MCP, permissions, slash commands like `/plan`)
- Git, curl, python3, jq, chromium, Playwright (system Chromium) — browser automation works
- Push access via Prix Cloud GitHub App installation token (1h TTL)
- Resource limits: 500m–2 CPU, 1Gi–4Gi RAM, ephemeral storage

Commits use identity `Prix Cloud Agent <bot@getrush.ai>`.

## Lifecycle

```
dispatching → allocating → running → {completed | needs_review | failed | cancelled}
```

- **completed** — exit 0 AND a PR URL was parsed from output
- **needs_review** — exit 0 but no PR (plan-only / exploratory)
- **failed** — non-zero exit or pod lost
- **cancelled** — operator cancelled

After the run terminates, the pod is reaped. Stream cuts off. Final PR URL is in the streamed output and on `cloud_executions.pr_url`.

## Verifying the Run

The CLI streams output. When the agent prints the PR URL, open it and check:

1. Branch is `agent/*` (not `main`)
2. PR body has `## Summary` and `## Test plan` sections
3. Test plan checklist shows test counts (`N pass, M fail`)
4. For web changes: screenshots embedded
5. CI is green (or failure is explained in the PR body)
6. A "Follow-up ideas" comment exists on the PR (from the reflect step), with Linear links where applicable

If any of those is missing, comment on the PR and re-dispatch with a tighter prompt.

## Rules

- **Never** put credentials in the prompt — the sandbox already has GitHub auth.
- **Never** ask the agent to push to `main`. The prompt template forbids it; if you remove that line you own the consequences.
- **Never** add an "Out of scope" block — it makes agents lazy and they declare too much off-limits. State scope precisely instead.
- **Always** specify the exact branch name in `Delivery` so PR review is consistent.
- **Always** include "Testing (mandatory)" and "Reflect" — without them, agents skip tests and ship without follow-up notes.
- For multi-step or open-ended work, prefer dispatching `--mode plan` first, reviewing the plan comment, then dispatching `--mode exec` with the approved plan referenced in the prompt.
- For Linear-driven work, use the `rdev` skill instead — it handles the full Plan → Doing → Review state machine via Linear webhooks. `rush-cli` is for ad-hoc dispatches not tied to a Linear issue.

## Reference

- Cloud runs design: `infra/sandbox/docs/02-cloud-runs.md`
- CLI source: `rush/cli/internal/cli/cloud.go`
- Sandbox image: `infra/sandbox/Dockerfile`
- Factory Floor router: `infra/sandbox/service/src/router.ts`
