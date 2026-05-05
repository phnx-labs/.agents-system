---
description: Test critical paths - parallel validation for complex scopes
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

Estimate complexity:
- Simple (1-2 flows): Test directly yourself
- Medium (3-5 flows): Test directly, but document thoroughly
- Complex (6+ flows or full app): Use parallel team validation

## Direct Testing

For simple to medium scope, test directly:
1. Identify critical paths in each area
2. Run existing tests
3. Plan new tests for gaps
4. Note failure scenarios and boundary conditions

## Parallel Validation (Complex Scope)

For complex scopes, distribute testing across a team:

1. Create a team with `agents teams create test-<topic>`
2. Add one teammate per major area
3. Give each:
   - Their area to focus on
   - Context about the system
   - Focus: Critical paths, failure scenarios, state verification, boundary conditions
4. Start the team
5. After completion, synthesize cross-cutting concerns:
   - Integration points between areas
   - Shared state dependencies
   - Consistent error handling patterns
   - End-to-end flows spanning multiple areas

## Output

### Summary
What areas were tested, how many agents used (if any), overall coverage.

### Test Plan by Area

For each area, show what was planned:

#### [Area Name]

**Critical Paths**
What flows matter most in this area.

**Tests**
- Existing tests to run
- New tests to add
- Failure scenarios
- Boundary conditions

### Cross-Cutting Tests
Tests that span multiple areas:
- Flow: the end-to-end scenario
- Areas touched: which areas this involves
- Verifies: what contract or integration this validates

### Execution Plan
Consolidated plan for running all tests. Order matters if tests have dependencies.
