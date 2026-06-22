---
description: Test critical paths — parallel validation for complex scopes
---

You are testing: $ARGUMENTS

Your goal is to identify critical paths and validate them.

## Identify Areas

Break down the scope into testable areas:
- Auth/permissions flows
- Data persistence and integrity
- API endpoints and contracts
- UI/UX critical paths
- Error handling and edge cases

Estimate whether it's worth splitting for speed:
- Simple (1-2 flows): write the tests directly yourself.
- Medium (3-5 flows): write directly, but document thoroughly.
- Large (6+ independent flows, or a surface that splits into many separate test files):
  parallelize the *authoring* across a team to cut wall-clock — see below.

## Direct Testing

For simple to medium scope, write tests directly:
1. Identify critical paths in each area.
2. Run existing tests.
3. Write new tests for the gaps.
4. Note failure scenarios and boundary conditions.
5. Run the suite. Report real pass/fail counts — "written" is not "passing."

## Parallel Test Authoring (Large Scope)

The goal here is **throughput, not review**: split the test surface so multiple agents
*write* tests at the same time, cutting the total wall-clock to land the suite. This is not
a verification panel — the agents author tests; the lead integrates and runs them.

### 1. Decompose for non-collision (the load-bearing step)

Split the surface into slices that map to **separate test files**, so no two agents ever
edit the same file. Slice by area, by module, or by flow:

```
slice auth     -> tests/auth.test.ts        (login, refresh, logout)
slice billing  -> tests/billing.test.ts     (checkout, webhook, quota)
slice api       -> tests/api-contract.test.ts (endpoint contracts)
```

If a clean split would still force two agents into one file, the split is wrong — re-cut it.

### 2. Write boundary contracts

Each slice gets the `parallel-teams` contract (see `commands/teams.md`):

- **Owns** — the explicit test file(s) it creates/extends.
- **Must NOT touch** — files owned by other slices.
- **Shared fixtures** — one canonical owner writes shared helpers / `testdata`; everyone
  else imports. If slice A needs B's fixture first, sequence with `--after`.

### 3. Spawn the authors (edit mode, in parallel)

```bash
agents teams create test-<topic>
agents teams add test-<topic> codex  "<brief: Owns tests/auth.test.ts; Must NOT touch billing/api; cover login/refresh/logout critical paths + failure + boundary cases>" --name auth    --mode edit
agents teams add test-<topic> claude "<brief: Owns tests/billing.test.ts; …>"                                                                                                            --name billing --mode edit
agents teams add test-<topic> codex  "<brief: Owns tests/api-contract.test.ts; …>"                                                                                                       --name api     --mode edit
agents teams start test-<topic> --watch
```

Pick agents by fit for throughput (e.g. `codex` for straightforward suites) — vendor
**variety is not the goal here**; parallel slices are. Each brief names the critical paths,
failure scenarios, and boundary conditions for that slice, and ends with the success
criterion (tests compile and the slice's paths are covered).

### 4. Integrate (mandatory — the lead owns this)

After the authors finish, the lead pulls it together — do NOT claim done on "tests written":

1. Read each slice via `agents teams logs test-<topic> <slice>`.
2. **Run the full suite yourself** and report real pass/fail counts.
3. Fix cross-cutting / integration gaps the slices missed:
   - Integration points between areas, shared state dependencies.
   - End-to-end flows spanning multiple slices (no single author owned these).
   - Inconsistent error-handling or fixture conventions across slices.
   - Duplicate coverage where two slices tested the same path — dedup.
4. `agents teams disband test-<topic>` when the suite is green.

## Output

### Summary
What was tested, whether authoring was split across agents (and into how many slices), and
the final suite result with real pass/fail counts.

### Slices (if parallelized)

For each slice that was authored in parallel:

#### [Slice Name] — owned by [agent]

**Owns** — the test file(s) it created/extended.
**Critical Paths** — the flows it covered.
**Tests added** — what was written (failure scenarios + boundary conditions included).

### Cross-Cutting Tests
The end-to-end flows that span multiple slices — written/fixed by the lead during
integration (no single author owned these):
- Flow: the end-to-end scenario.
- Slices touched: which areas this involves.
- Verifies: what contract or integration this validates.

### Suite Result
The actual command run and its output: total tests, passed, failed, and any gaps still
open. "Written" is not "passing" — this section quotes the real run.
