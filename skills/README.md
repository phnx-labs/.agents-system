# Skills

Skills give agents domain expertise they can load on demand. Each skill is a directory with a `SKILL.md` file containing instructions, workflows, and context for a specific capability.

## How Skills Work

When you invoke a skill (e.g., `/browser`) or when an agent detects relevant context (e.g., you ask to generate an image), the skill's instructions load into the agent's context. Skills can include:

- **Instructions** in `SKILL.md` - the core knowledge
- **Scripts** (`.sh` files) - automations the skill can invoke
- **References** - example content, datasets, style guides

Skills differ from commands: a command is a one-shot prompt expansion, while a skill stays loaded and provides ongoing capability.

## Environment Injection

Skills often need machine-specific values (hostnames, paths, credentials). We solve this with environment injection:

```markdown
## Environment

!`${CLAUDE_SKILL_DIR}/env.sh block`
```

The `!` syntax executes the script and injects its output into the skill at load time. The `env.sh` script sources `~/.agents/.environment` (gitignored) and prints the resolved values.

**Why this matters for sharing:** You can publish skills publicly without exposing sensitive data. Each machine has its own `.environment` file with local values. The skill references variables; the environment provides values.

Example `.environment`:
```bash
BROWSER_SSH_USER=myuser
BROWSER_SSH_HOST=my-server.local
API_KEY_REF=keychain:my-api-key
```

Example `env.sh`:
```bash
source ~/.agents/.environment 2>/dev/null
USER="${BROWSER_SSH_USER:-default}"
HOST="${BROWSER_SSH_HOST:-localhost}"
echo "SSH target: ${USER}@${HOST}"
```

## Creating Skills

A minimal skill:

```
skills/my-skill/
  SKILL.md     # Required
```

The `SKILL.md` frontmatter:

```yaml
---
name: my-skill
description: "One line - when should Claude load this?"
allowed-tools: Bash(pattern*)   # Optional: tools this skill can use
user-invocable: true            # Can user type /my-skill?
---
```

Keep skills focused. One capability per skill. A "do everything" skill is less effective than three focused ones.

## Learning from Others

The agent skills ecosystem is evolving fast. Some notable collections:

- **[gstack](https://github.com/garrytan/gstack)** - Garry Tan's opinionated setup with persona-based skills (CEO review, design review, QA). Notable for its "forcing function" patterns that surface hidden assumptions.
- **[awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)** - Curated list of skill repositories, hooks, and orchestrators
- **[Trail of Bits Security Skills](https://github.com/trailofbits)** - Professional security-focused skills for static analysis and code review

Key patterns emerging in the community:

1. **Persona-based skills** - Each skill embodies a specialist role (security officer, QA lead, design reviewer)
2. **Pipeline chaining** - Skills write artifacts that downstream skills consume
3. **Forcing functions** - Skills that surface assumptions through structured questions
4. **Risk budgets** - Limiting how much a skill can change in one pass

## Challenges with Sharing Skills

When publishing skills, watch for:

1. **Embedded credentials** - API keys, hostnames, paths hardcoded in SKILL.md
2. **Machine-specific assumptions** - Paths like `/Users/yourname/` or `~/my-project`
3. **Implicit dependencies** - Scripts that assume certain CLIs are installed

The environment injection pattern solves (1) and (2). For (3), document dependencies in SKILL.md or add setup scripts.

## Skills in This Repo

Each subdirectory is a self-contained skill with its own `SKILL.md`. Invoke with `/skill-name` or let the agent auto-detect from context.

### Content & Creative

| Skill | What It Does |
|-------|-------------|
| `brain-scan/` | Neural engagement analysis using Meta TRIBE v2 brain simulation. Predicts how a human brain responds to text, audio, or video content across Language, Attention, Emotion, Memory, and Default Mode regions. |
| `creative-analysis/` | Multi-dimensional creative analysis for any medium. Combines subjective craft analysis (visual, composition, prose, word choice) with neural data from brain-scan. |
| `image-craft/` | Expert prompt engineering for image generation across styles: editorial photography, logos, posters, product shots, illustrations. |
| `memician/` | Create culturally resonant memes and viral social content. Compresses cultural tensions into minimal words. |
| `visual-styles/` | Visual style reference library for consistent image generation. |
| `writer/` | Professional writing craft across formats: product launches, landing pages, essays, blog posts, social posts, newsletters. |

### Productivity & Ops

| Skill | What It Does |
|-------|-------------|
| `browser/` | Drive websites via remote browser relay (OpenClaw) or local Chrome (agent-browser). Tab isolation, screenshots, form filling. |
| `linear/` | Task management CLI for AI agent teams. Query work queues, update status, manage sprints via Linear. |
| `mq/` | Query large markdown, HTML, and PDF files without reading entire documents. Probe structure first, extract surgically. |
| `openclaw/` | Manage OpenClaw agents on remote machines. Configure workspaces, cron jobs, heartbeats, and Telegram gateway. |
| `sessions/` | List and load named sessions across agent versions. |

### Agent Infrastructure

| Skill | What It Does |
|-------|-------------|
| `agents-cli/` | Manage AI coding agent CLIs. Install versions, sync configs, switch between agents, manage MCP servers. |
| `mcporter/` | MCP server CLI for managing Model Context Protocol servers. |
| `skill-creator/` | Meta-skill for creating and improving other skills. Documents SKILL.md structure, env injection, and sync workflow. |
| `reflect/` | Recall all feedback, corrections, and constraints from the current conversation before rewriting. Prevents iterative drift. |

### Growth & Outreach

| Skill | What It Does |
|-------|-------------|
| `twitter-warmup/` | Warm up a new Twitter/X account from zero to credible. Stateful phase tracking across sessions. |
| `higgsfield/` | Generate images and videos via Higgsfield AI using browser automation. |

### Escalation

| Skill | What It Does |
|-------|-------------|
| `phone-call/` | Last-resort escalation. Call the human when critically blocked. |

## Further Reading

- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
- [Essential Claude Code Skills and Commands](https://batsov.com/articles/2026/03/11/essential-claude-code-skills-and-commands/)
- [A Practical Guide to AI Dotfiles](https://engineersmeetai.substack.com/p/a-practical-guide-to-ai-dotfiles)
