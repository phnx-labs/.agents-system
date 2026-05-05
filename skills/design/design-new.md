# New Major UX Design

For designing new features, screens, or flows from scratch.

## When to Use This Mode

- The user wants a new feature designed
- The user wants a new screen or page
- The user wants a new user flow
- The design does not exist yet

## Workflow

### Step 1: Understand the Problem

Before any design work:
1. What is the user here to DO?
2. What's the single most important action or outcome?
3. What's noise that can be eliminated?
4. What's the simplest version that delivers value?

### Step 2: Research and Context

- Read `AGENTS.md` or `CLAUDE.md` for design language
- Read `harness-ui/README.md` for component patterns
- Look at existing related screens for consistency
- Search the web for current best practices (anchor with current year)

### Step 3: Use the Claude Design Tool

For new major designs, use the Claude design tool in the browser:

1. Open the design tool via OpenClaw browser
2. Generate visual mockups and prototypes
3. Iterate based on feedback
4. Export final designs

```bash
# Example workflow
openclaw browser open <design-tool-url> --browser-profile claude
```

### Step 4: Produce design.md

Create a `design.md` file documenting:
- Design principles used
- Screen specifications
- Interaction patterns
- Component inventory
- Responsive behavior
- Accessibility considerations

### Step 5: Present to User

Show the designs and design.md file. Wait for approval before implementation.

## Output

1. Visual designs (from design tool)
2. `design.md` file with full specification
3. Component inventory
4. Interaction specifications
