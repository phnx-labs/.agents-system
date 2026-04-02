# Commands

Slash commands are prompt templates. Type `/debug the auth flow` and the command file expands into a full debugging methodology prompt, with your text replacing `$ARGUMENTS`.

## How Commands Work

Each `.md` file in this directory becomes a slash command. The file content is a prompt template:

```markdown
---
description: Debug an issue with systematic root cause analysis
---

You are debugging: $ARGUMENTS

## The Discipline

The root cause is NEVER where the error appears...
```

When you type `/debug the login is broken`, Claude receives the full prompt with "the login is broken" substituted for `$ARGUMENTS`.

## Commands vs Skills

Commands are **one-shot prompt expansions** - they fire once and are done.

Skills are **persistent capabilities** - they load into context and stay active, often with supporting scripts and reference files.

Use a command when you want a specific methodology applied once. Use a skill when you need ongoing capability with tools and context.

## Single-Agent Commands

These run in your current session:

**Planning & Design**
- `/plan` - Feature planning with mandatory artifacts (mockups, diagrams, state machines). Forces grounded discussion.
- `/design` - UX design with ASCII mockups and interaction flows
- `/redesign` - Improve existing screens with before/after proposals
- `/product` - Think like a product engineer - user value over technical elegance

**Debugging & Maintenance**
- `/debug` - Systematic root cause analysis. Maps the full data path, reads every file in the chain, builds evidence.
- `/clean` - Remove tech debt, consolidate duplicate code, clean up patterns
- `/recap` - Summarize current situation with facts, hypotheses (grounded in evidence), and next steps

**Task Management**
- `/tasks` - Pull Linear tasks assigned to you in the current sprint
- `/next` - Verify current task is done, then pick up next from Linear
- `/continue` - Resume a previous task with context recovery

**Delegation**
- `/spawn` - Spawn a single subagent with full context for one task

## Swarm Commands

These spawn multiple agents in parallel:

- `/swarm` - Distribute tasks across agents. Shows plan, waits for approval, then spawns.
- `/splan` - Planning with swarm consensus (2-3 agents verify approach)
- `/sdebug` - Independent root cause verification (agents debug separately, compare findings)
- `/sconfirm` - Lightweight verification of findings
- `/sclean` - Parallel cleanup across different code areas
- `/stest` - Parallel testing by category (auth, data, API, UI, errors)
- `/srecap` - Multiple agents gather evidence before handoff
- `/simagine` - Parallel creative exploration for visual assets

Swarm commands require the [Swarm MCP server](https://www.npmjs.com/package/@swarmify/agents-mcp) for orchestration.

## Creating Commands

1. Create `commands/<name>.md`
2. Add frontmatter with a `description`
3. Use `$ARGUMENTS` where user input should appear
4. Commit and sync (`agents pull` on other machines)

Keep prompts focused. One methodology per command. If you need scripts or reference files, make it a skill instead.

## Patterns Worth Noting

**Forcing functions** - Commands like `/plan` require artifacts before discussion. You can't hand-wave; you must draw the mockup first.

**Evidence chains** - `/debug` builds explicit chains: "file_a.ts:45 receives X, transforms to Y, passes to B" - making reasoning visible and verifiable.

**Grounded hypotheses** - `/recap` distinguishes facts from hypotheses, and requires evidence for each hypothesis.

These patterns prevent the most common failure mode: talking about code without reading it.
