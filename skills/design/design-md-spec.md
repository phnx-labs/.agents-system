# design.md Specification

A `design.md` file documents the design of a feature, screen, or application. It serves as the single source of truth for design decisions.

## File Location

Place `design.md` in the root of the feature directory or in a `docs/` folder:
- `src/features/auth/design.md`
- `docs/design.md` (for app-wide design)

## File Structure

```markdown
# Design: [Feature Name]

## Overview
One paragraph describing what this is and who it's for.

## Design Principles
- Principle 1: [description]
- Principle 2: [description]

## Screens

### [Screen Name]

#### Purpose
What the user is here to do.

#### Layout
ASCII diagram or reference to design file.

#### Components
| Component | Source | Notes |
|-----------|--------|-------|
| Button | Existing | Use primary variant |
| Input | Existing | With validation |
| NewWidget | NEW | See spec below |

#### Interactions
| Element | Trigger | Result |
|---------|---------|--------|
| Submit button | Click | Validate, submit, show success |
| Input field | Blur | Validate inline |

#### States
- Default
- Loading
- Success
- Error
- Empty

#### New Components
For any NEW components, specify:
- Dimensions and spacing
- Color values
- Typography (size, weight, color)
- All states (default, hover, active, disabled, error)

## Flows

### [Flow Name]
```
[Screen A] --action--> [Screen B] --action--> [Screen C]
```

## Decisions

### [Decision Name]
**Context:** [why this decision was needed]
**Options Considered:**
- Option A: [description] — [pros/cons]
- Option B: [description] — [pros/cons]
**Decision:** [which option was chosen]
**Rationale:** [why]

## Accessibility
- Keyboard navigation
- Screen reader support
- Color contrast
- Focus indicators

## Responsive Behavior
- Desktop: [behavior]
- Tablet: [behavior]
- Mobile: [behavior]

## Open Questions
- [Question 1]
- [Question 2]
```

## Guidelines

- Keep it focused: one design.md per major feature
- Update it when designs change
- Reference it during implementation
- Use it for onboarding new team members
- Include ASCII diagrams for clarity
- Be specific about colors, spacing, and typography
