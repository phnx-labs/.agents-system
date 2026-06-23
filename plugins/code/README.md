# code plugin

Coding-workflow plugin. Sub-skills for the manager/router engineering loop: scope a task, pick the delivery path, dispatch, verify end-to-end.

## Skills

| Skill | Use when |
| --- | --- |
| `code:dispatch` | A new task arrives (free-form or RUSH-XXX). Triages scope, picks a bucket (inline / single-agent / autodev / sprint) and venue (local laptop or Rush Cloud), sets up the workspace, briefs the agent. Defaults to Rush Cloud for clear / well-scoped tasks (~80%) and stays local for fuzzy / interactive work. The manager's entry point — call this first instead of guessing. |
| `code:verify` | An agent claims a dispatch is done, or a branch / PR is ready. Identifies changed surfaces, runs the canonical `sandbox.sh test` for each, hits health endpoints on deploys, screenshots UI if rush/app touched. Returns PASS / FAIL with quoted evidence — the closing gate for the "done means end-to-end" hard line. |
| `code:sprint` | A multi-hour window and 3+ independent surfaces (e.g. "ship Rush feature X, close linear-cli loops, fix agents-cli bug"). Opus planner → user confirms → fan out via `agents teams` → real-flow verification per track. Use this when scope clearly exceeds `code:dispatch`'s autodev / single-agent paths. |
| `code:quality` | A read-only diagnostic across four orthogonal categories: **architecture & design** (inline auth where middleware exists, etc.), **code health** (`go vet`, `tsc`, `staticcheck`, `biome` — only if on PATH), **context quality** (docs vs code drift, doc-asserted invariants, identifier cross-reference), and **patterns** (parallel implementations by behavioral signature). Scope-flexible (`HEAD~1` default; `--commits N`, `--since`, `#PR`, path overrides). Emits an HTML report opened in the browser with per-finding clipboard actions (copy as `/code:dispatch`, copy Linear ticket cmd, copy `file:line`). Never modifies code. |

## The manager loop

1. New task arrives → `/dispatch <task or RUSH-XXX>` picks the delivery path and briefs the agent.
2. Agent runs (single `agents run`, autodev, or sprint).
3. Agent claims done → `/verify <branch or PR>` runs the canonical tests and quotes evidence.
4. PASS → hand to user for review and merge. FAIL → file the failing line back to the agent.

`/quality` runs outside this loop — invoke it any time as a read-only health snapshot. Common moments: after landing a multi-commit branch, before opening a PR, on a fresh checkout of someone else's surface, or as a recurring sanity check.

## Conventions

- All sub-skills assume `agents-cli` is installed and on PATH.
- Sub-skills default to the `Plan` sub-agent type with `model: "opus"` for planning, and to a mix of `claude`/`codex` for implementation tracks.
- Every sub-skill ends with a real verification step — no "code written = done." See `code:verify` for the canonical gate.
- Worktrees live in `<repo>/.agents/worktrees/<slug>/` per the project CLAUDE.md hard line.
