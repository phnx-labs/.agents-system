# Existing Design Improvement

For improving screens, features, or flows that already exist.

## When to Use This Mode

- The user is unhappy with an existing screen
- The user wants to improve an existing feature
- The user wants to redesign something specific
- The design already exists and needs refinement

## Workflow

### Step 1: Audit the Current State

If the user provided a screenshot, READ IT carefully. Study every element.

For every element on the screen, ask:
1. What is the most important thing on this screen?
2. What's noise? (elements that don't serve the primary action)
3. What's the information hierarchy?
4. Is anything unnecessarily complicated?
5. Does it respect the user's intelligence?

Write down your diagnosis. Be specific.

### Step 2: Internal Consistency Check

Before looking outside the app, look INSIDE it:
- Read `AGENTS.md` or `CLAUDE.md` for design language
- Read `harness-ui/README.md` for component patterns
- Find the actual source code of the screen being redesigned
- Read 2-3 neighboring screens for comparison

Note discrepancies: "The main app uses X pattern but this screen uses Y instead."

### Step 3: External Research

Search the web for how well-designed apps handle this same pattern:
- Apps known for great design (Linear, Raycast, Arc, Notion, Figma)
- Specific patterns relevant to what's being redesigned
- macOS-native patterns if desktop app

Summarize 2-3 interesting patterns. Don't dump links — describe what they do and why it works.

### Step 4: BEFORE Diagram (MANDATORY)

Draw the current screen as ASCII art. Be accurate.

```
BEFORE: [Screen Name]
+------------------------------------------+
|  ...exact layout of current screen...    |
+------------------------------------------+
```

List the problems below the diagram.

### Step 5: AFTER Proposals (MANDATORY - exactly 2-3 options)

For EACH proposal, draw a complete ASCII diagram showing the full screen.

```
OPTION A: [Name] - [One-line philosophy]

+------------------------------------------+
|  ...complete screen layout...            |
+------------------------------------------+

Why this works:
- Solves [problem] by [approach]
- Feels like [quality] because [reason]

Data needed: [what this option requires]
```

Each option should represent a genuinely different approach.

### Step 6: Comparison Table

| Aspect | Option A | Option B | Option C |
|--------|----------|----------|----------|
| Solves main pain? | ... | ... | ... |
| Personality/warmth | ... | ... | ... |
| Implementation effort | Easy/Medium/Hard | ... | ... |
| Data requirements | ... | ... | ... |
| Risk | ... | ... | ... |

### Step 7: Let the User Pick

After presenting options, STOP. Wait for the user to pick one or ask for modifications.

If the user wants to combine elements from different options, sketch the hybrid as a new ASCII diagram before proceeding.

### Step 8: Update design.md

If a `design.md` file exists for this screen/feature, update it with the new design.

## Constraints

- EVERY proposal MUST have a full ASCII diagram
- Show the COMPLETE screen in each diagram
- Do NOT discuss implementation details during design phase
- Do NOT propose more than 3 options
- Do NOT propose fewer than 2 options
- Do NOT add features that weren't asked for
- Do NOT skip the BEFORE diagram
- Diagrams should show realistic content, not "Lorem ipsum"
