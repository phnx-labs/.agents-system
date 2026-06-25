---
description: Alias for /code:review — recap the session's goal, list every PR it opened, review each in parallel with anti-overengineering guardrails, then merge / request-changes / close-as-duplicate per verdict.
---

**`/review` is an alias of `/code:review`.** There is one session-review command, defined once in the `code` plugin; this is the convenience short name.

Apply the full `/code:review` procedure to `$ARGUMENTS`. In brief:

- Default: review every PR opened in this session, score each against the session's stated goal, act on the verdicts (merge / request-changes / close-as-duplicate). Stack-aware: respects PR dependency/merge order.
- `$ARGUMENTS` flags: an explicit PR list (`#412 #413`) reviews only those; `dry-run` prints the plan and stops; `no-merge` comments verdicts but never merges.
- **Never merge without evidence the changed path runs** — green CI on the head SHA (`gh pr checks <pr>`), a quoted command+output, or explicit user approval. Otherwise the verdict is request-changes.
- **No over-review.** Each per-PR reviewer answers a fixed rubric (goal / evidence / quality / cleanup / scope) plus a security pass on risk-touching diffs — and stops. No style or speculative feedback.

The canonical, authoritative definition (including the per-PR reviewer brief and the security pass) lives at `plugins/code/commands/review.md` and the `code:review` skill. Make behavior changes **there**, not here — this file only forwards.
