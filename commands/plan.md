---
description: Plan with grounded design - identify context, audit codebase, then create artifacts
---

You are planning: $ARGUMENTS

## CRITICAL: Identify Context Before Touching Code

Do NOT start reading files randomly. First understand WHAT you're planning and WHY.

### Step 1: Topic/Context Identification

Before reading any code, clarify:

1. **What is the user asking for?** — Restate the request in your own words. If ambiguous, ask for clarification.
2. **What is the goal?** — What problem does this solve? Who benefits?
3. **What is the scope?** — Is this a new feature, a refactor, a bug fix, or an integration?
4. **What are the constraints?** — Time, resources, dependencies, backwards compatibility?

If the request is vague or could mean multiple things, use `AskUserQuestion` with 2-3 specific interpretations. Let the user pick.

### Step 2: Codebase Audit

Now that you know the topic, find what's relevant. Do NOT read everything. Target your search.

**Search strategy:**
- Search for keywords related to the feature in filenames: `glob "**/*auth*"`, `glob "**/*login*"`
- Search for keywords in file contents: `grep "authentication" src/`
- Look at the project structure: `ls src/` or `ls app/`
- Check existing patterns: How do similar features work? What files do they touch?

**Identify:**
- **Entry points** — Where does this feature live? (routes, controllers, handlers)
- **Data layer** — What models, schemas, or types are involved?
- **UI layer** — What components or screens need changes?
- **Shared logic** — What utilities, hooks, or services are relevant?
- **Tests** — Where are existing tests? What new tests are needed?

**Output a list of files and directories the agent should examine:**

```
Relevant paths identified:
- src/features/auth/login.tsx (UI entry point)
- src/lib/auth.ts (auth logic)
- src/types/auth.d.ts (types)
- tests/auth.test.ts (existing tests)
```

### Step 3: Read Code

Read ONLY the files identified in the audit. For each file:
1. Note the file path and line numbers
2. Quote relevant code snippets
3. Understand how it connects to other files

Do NOT guess. Do NOT speculate. Read code, then speak.

## For EACH Feature

### Step 4: Create Artifacts

After reading code, create concrete artifacts. Do NOT discuss design without artifacts.

For UI changes - ASCII mockup REQUIRED:
```
+----------------------------------+
| Header                           |
+----------------------------------+
| [ Input field          ] [Save]  |
|                                  |
| Current: value                   |
+----------------------------------+
```

For API endpoints - request/response examples REQUIRED:
```
PATCH /api/v1/orgs/:id
Request:  { "name": "New Name", "domain": "newdomain.com" }
Response: { "id": "...", "name": "New Name", "domain": "newdomain.com" }
Error:    { "error": "domain_taken", "message": "Domain already in use" }
```

For state changes - state diagram REQUIRED:
```
[Created] --enable_sso--> [SSO Configured] --require_sso--> [SSO Required]
    |                           |                                |
    v                           v                                v
 (any auth)              (SSO or OAuth)                    (SSO only)
```

For data flow - sequence diagram REQUIRED:
```
User -> API -> DB: updateOrg(id, {name})
              DB -> API: updated org
         API -> AuditLog: orgSettingsChanged
API -> User: 200 OK
```

For behavior with multiple scenarios - table REQUIRED:
```
| Scenario                  | Input              | Result              |
|---------------------------|--------------------|---------------------|
| Valid name change         | {name: "New"}      | 200, name updated   |
| Domain already taken      | {domain: "taken"}  | 400, domain_taken   |
| Not admin                 | any                | 403, forbidden      |
```

### Step 5: Design Questions

Only AFTER creating artifacts, list design questions. Each question must reference the artifact and explain what changes based on the answer.

For genuinely ambiguous decisions, use `AskUserQuestion` with 2-3 concrete options. Let the user pick rather than guessing.

## Validation (Optional)

For large features or architectural changes, validate your plan before finalizing:

1. Create a team with `agents teams create plan-<topic>`
2. Add 1-2 teammates in `--mode plan` with different agent types
3. Share the feature description and key files — do NOT share your proposed approach
4. Compare their independent plans with yours
5. Incorporate any edge cases, simpler approaches, or missed touch points they identified

Skip this for small, well-understood changes.

## Output Format

### Context
What is being planned, why, and what constraints exist.

### Codebase Audit
What files and paths were identified as relevant, and why.

### Feature: [Name]

**Code Read:** List files read with line numbers

**Artifact:**
[The mockup, diagram, or table - MANDATORY]

**Implementation:**
- File: path/to/file.ts
  - Function: existingFunction() - modify to add X
  - New function: newFunction() - does Y

**Design Questions:** (only if genuinely ambiguous)
1. Question - impacts [which part of artifact]

### Summary Table

| Feature | Files Modified | New Functions | Complexity |
|---------|----------------|---------------|------------|
| ...     | ...            | ...           | Low/Med/Hi |

## Constraints

- No time estimates
- No "nice to have" additions
- No backwards compatibility unless asked
- No abstract discussion without artifacts
- Every feature needs at least one visual artifact
- Use AskUserQuestion for ambiguous decisions — don't guess
