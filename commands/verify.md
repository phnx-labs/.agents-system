---
description: Verify changes work - run tests, build, execute e2e checks
---

Verify: $ARGUMENTS

## Process

1. **Identify what changed**
   - Review conversation context for recent edits
   - If unclear, check git diff or ask user

2. **Determine verification method based on change type:**

   | Change Type | Verification Approach |
   |-------------|----------------------|
   | Code logic | Run relevant test suite |
   | Build/config | Execute build command |
   | API endpoint | Make test request |
   | UI component | Build and check for errors |
   | Script | Execute with test input |
   | Documentation | Validate links/formatting |

3. **Find project-specific commands:**
   - Check package.json scripts, Makefile, justfile, or similar
   - Look for test/build patterns in project CLAUDE.md or README
   - Use language-appropriate defaults (pytest, go test, npm test, etc.)

4. **Execute and report:**
   - Run the verification
   - PASS: State what was tested and evidence of success
   - FAIL: Show error output and suggest fix

## Guidelines

- Prefer existing project test infrastructure over ad-hoc verification
- Run minimal scope needed (specific test file > entire suite)
- If no tests exist, verify via build + manual smoke test
- Always show command output as evidence
