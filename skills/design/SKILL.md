---
name: design
description: "Design UX and interfaces — from first principles to final specification. Handles new designs (via browser-based design tools) and existing design improvements (via ASCII mockups and design.md files). Load this skill when the user asks for design work."
argument-hint: "[new|existing] what to design"
allowed-tools: Bash(openclaw*), Bash(agent-browser*), Read(*), Write(*)
user-invocable: true
---

# Design Skill

A multi-file skill for UX and interface design. This skill handles both new designs and improvements to existing ones.

## How to Use This Skill

The skill has two modes based on what the user needs:

### Mode 1: New Major UX Design

When the user wants to design something new and significant (a new feature, a new screen, a new flow):

1. Load `design-new.md` for the workflow
2. Use the Claude design tool in the browser to generate visual assets
3. Produce a `design.md` file documenting the design

### Mode 2: Existing Design Improvement

When the user wants to improve something that already exists:

1. Load `design-existing.md` for the workflow
2. Use ASCII mockups and structured proposals
3. Update or create a `design.md` file if one exists

### Mode 3: Design System / Design.md File

When the user needs a `design.md` file (Google's design.md format or similar):

1. Load `design-md-spec.md` for the specification
2. Produce the file according to the spec

## Decision Tree

```
User asks for design work
├── New feature/screen/flow? → Load design-new.md
├── Improve existing screen? → Load design-existing.md
├── Need a design.md file? → Load design-md-spec.md
└── Unclear? → Ask for clarification
```

## Core Principles (All Modes)

- **Mac feel** — Silent success, inline errors, no toasts, no loading unless critical
- **Needs not wants** — What does user actually need here?
- **Intention over convention** — Don't add because "others have it"
- **Typography-driven state** — Font weight and opacity, not colored dots
- **Simpler is better** — One action per screen when possible
