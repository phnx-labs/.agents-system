---
name: skill-creator
description: Create skills that extend AI coding agents (Claude, Codex, Gemini, Cursor). Use when building new skills or improving existing ones.
---

# Skill Creator

Skills are modular folders that give AI agents specialized knowledge, workflows, and tools. This skill teaches you how to build them.

## Structure

```
skills/{name}/
├── SKILL.md          # Required: frontmatter + instructions
├── references/       # Optional: detailed docs loaded as-needed
├── scripts/          # Optional: reusable executable code
└── assets/           # Optional: templates, images, files for output
```

## SKILL.md Format

Every skill needs a SKILL.md with YAML frontmatter:

```markdown
---
name: my-skill
description: What it does and WHEN to use it. This is the trigger - be specific.
---

# My Skill

Instructions here...
```

**Critical**: The `description` field determines when agents invoke the skill. Include:
- What the skill does
- Specific triggers ("Use when...", "Triggers on...")
- Example contexts

## Core Principles

### 1. Context is Expensive

The context window is shared. Every token in your skill competes with conversation history, other skills, and the actual task.

- Only include what agents don't already know
- Prefer concise examples over verbose explanations
- Challenge each paragraph: "Does this justify its token cost?"

### 2. Progressive Disclosure

```
Level 1: Frontmatter (name + description)  → Always loaded (~50 tokens)
Level 2: SKILL.md body                     → Loaded when skill triggers
Level 3: references/, scripts/, assets/    → Loaded only when needed
```

Keep SKILL.md under 500 lines. Split detailed content into `references/` files.

### 3. Match Specificity to Fragility

| Task Type | Freedom Level | Format |
|-----------|---------------|--------|
| Multiple valid approaches | High | Text instructions |
| Preferred pattern exists | Medium | Pseudocode, examples |
| Fragile, must be exact | Low | Scripts, strict steps |

## When to Use Each Resource Type

### references/
Documentation the agent reads while working.

```
references/
├── api.md        # API documentation
├── schema.md     # Database schemas
└── patterns.md   # Common patterns
```

Reference from SKILL.md: "For API details, see [references/api.md](references/api.md)"

### scripts/
Executable code for repetitive or fragile operations.

```
scripts/
├── validate.py   # Validation logic
└── transform.sh  # Data transformation
```

Use when: Same code rewritten repeatedly, deterministic reliability needed.

### assets/
Files used in output (not loaded into context).

```
assets/
├── template.html  # Boilerplate
└── logo.png       # Brand assets
```

## Writing Good Descriptions

**Bad** (too vague):
```yaml
description: Helps with deployment
```

**Good** (specific triggers):
```yaml
description: Deploy applications to AWS. Use when deploying to EC2, ECS, Lambda, or S3. Triggers on "deploy to AWS", "push to production", or AWS service mentions.
```

## Anti-Patterns

| Don't | Do |
|-------|-----|
| Explain what agents already know | Focus on domain-specific knowledge |
| Put "when to use" in body | Put triggers in frontmatter description |
| Create README.md, CHANGELOG.md | Keep only essential files |
| Nest references deeply | Link all references from SKILL.md |
| Duplicate info across files | Single source of truth |

## Quick Checklist

- [ ] YAML frontmatter with `name` and `description`
- [ ] Description explains WHEN to trigger, not just WHAT it does
- [ ] Body under 500 lines
- [ ] Large content split into `references/`
- [ ] No redundant documentation files
- [ ] Examples are concise and practical
