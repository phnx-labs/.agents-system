---
description: Plan with grounded design - mockups and diagrams BEFORE feature discussion
---

You are planning: $ARGUMENTS

## CRITICAL: Ground First, Then Discuss

Do NOT discuss features abstractly. For EVERY feature:
1. Read the relevant code FIRST
2. Create concrete artifacts (mockups, diagrams, state machines) FIRST
3. THEN discuss design questions

If you discuss a feature without showing a concrete artifact, you have failed.

## Understand the System

Read AGENTS.md or CLAUDE.md if they exist. Search for keywords related to the task.
Read the actual code - trace data flow, identify touch points, understand patterns.

Do NOT guess. Do NOT speculate. Read code, then speak.

## For EACH Feature

### Step 1: Read Code
Read the specific files involved. Note line numbers. Quote relevant code snippets.

### Step 2: Create Artifacts

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

### Step 3: Design Questions

Only AFTER creating artifacts, list design questions. Each question must reference
the artifact and explain what changes based on the answer.

## Output Format

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
