---
name: test
description: "Test critical paths with a swarm — split the scope into testable areas, fan parallel agents across them, then synthesize cross-cutting tests that span areas. Use when a change is wide enough that one agent can't hold every critical path at once. Triggers on: 'swarm test', 'test critical paths', 'parallel test plan', 'cover this with tests'."
argument-hint: "[feature, surface, or scope to test]"
allowed-tools: Bash(agents teams*), Bash(agents run*), Bash(rg*), Bash(fd*), Bash(ls*), Read(*), Grep(*), Glob(*)
user-invocable: true
---

# swarm:test — parallel agents cover different critical paths, you synthesize the seams

> Read `swarm:orchestrate` first for fan-out mechanics. This skill is the **test mode**: divide the scope into areas, cover each in parallel, then find the cross-cutting tests no single area would catch.

You are testing: **$ARGUMENTS**

The point of a swarm here is coverage breadth plus the integration tests that only appear when you look *across* areas. Per the project's testing bar: real services (no mocking), tests that catch real bugs (skip ceremony), and unit tests are necessary but not sufficient — verify the real end-to-end flow.

## 1. Identify areas

Break the scope into testable areas — e.g. auth/permissions, data persistence & integrity, API endpoints & contracts, UI/UX critical paths, error handling & edges. **Size the swarm by judgment** (per `swarm:orchestrate` — no fixed table): roughly one agent per coherent area, collapsing to a single agent for a narrow scope and widening only where the surface genuinely splits into independent areas.

## 2. Fan out

Via `agents teams` (mechanics in `swarm:orchestrate`), spawn one agent per area across the **signed-in providers** (`agents teams doctor` / `agents view --json` first), mixing models for diverse coverage, **`--mode plan`** (you're producing a test plan, not editing yet). Each brief gives the area, system context, and the focus: critical paths, failure scenarios, state verification, boundary conditions. Ask each to:
1. Identify the critical paths in their area.
2. Plan tests (unit, integration, e2e) — real critical path, no mocks.
3. Note what would spoil UX if it broke.

## 3. Synthesize the cross-cutting tests

After agents report, find what no single area owns:
- Integration points between areas (auth + persistence).
- Shared state multiple flows depend on.
- Error-handling/formatting contracts that must stay consistent app-wide.
- End-to-end flows that span several areas.

These cross-cutting tests are the swarm's real value — surface them explicitly.

## Output

### Summary
Areas tested, agents used, overall coverage.

### Test plan by area
For each area (with its agent):
- **Critical paths** — the flows that matter most.
- **Tests** — existing to run, new to add, failure scenarios, boundary conditions, e2e.

### Cross-cutting tests
Each: the end-to-end flow, the areas it touches, and the contract/integration it validates.

### Execution plan
Consolidated run order (order matters where tests have dependencies). Tests live in the codebase next to their source (1:1 file mapping), fixtures in `testdata/` — never in `/tmp`.
