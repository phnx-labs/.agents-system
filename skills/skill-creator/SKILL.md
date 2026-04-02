---
name: skill-creator
description: Create or improve skills for AI agents. Triggers on 'create a skill', 'build a skill', 'write SKILL.md', or extending agent capabilities with new knowledge.
argument-hint: "[skill name or description]"
user-invocable: true
---

# Skill Creator

You create and improve skills (SKILL.md + supporting files) for AI coding agents.

## Skill Location

Skills live in `~/.agents/skills/<skill-name>/`. Each skill has:

- `SKILL.md` — main file (frontmatter + instructions)
- Optional supporting files: scripts (`env.sh`, `generate.sh`), reference docs, datasets

## SKILL.md Structure

```markdown
---
name: <skill-name>
description: <one-line description — used for trigger matching>
argument-hint: "[hint for arguments]"
allowed-tools: Bash(command-pattern*), Bash(other-pattern*)
user-invocable: true
---

# Skill Title

Instructions, patterns, commands, etc.
```

### Frontmatter Fields

| Field | Required | Purpose |
|-------|----------|---------|
| `name` | Yes | Skill identifier, matches directory name |
| `description` | Yes | Trigger matching — agent loads skill when user request matches this |
| `argument-hint` | No | Shown to user as placeholder |
| `allowed-tools` | No | Bash patterns auto-approved when skill is active |
| `user-invocable` | Yes | `true` = user can trigger with `/skill-name` |

### allowed-tools Patterns

Glob-style matching against Bash commands:

```yaml
allowed-tools: Bash(ssh*), Bash(openclaw*), Bash(*/env.sh*)
```

- `Bash(ssh*)` — any command starting with `ssh`
- `Bash(*/env.sh*)` — any path ending in `env.sh` with any args
- Multiple patterns comma-separated

## Dynamic Environment Injection

### The Problem

Skills often need machine-specific values (SSH targets, paths, API keys). Hardcoding breaks portability. Different machines need different values.

### The Solution: `!` Backtick Injection

Claude Code preprocesses `!` backtick commands in SKILL.md at load time, replacing them with the command's stdout.

```markdown
## Environment

!`${CLAUDE_SKILL_DIR}/env.sh block`
```

At load time, `${CLAUDE_SKILL_DIR}` expands to the skill's absolute path, `env.sh block` runs, and the output replaces the `!` backtick expression.

### Critical Constraints

1. **One injection per line** — only the FIRST `!` backtick on each line resolves. Subsequent ones on the same line are left as literal text.

   ```markdown
   # BROKEN: second injection won't resolve
   - SSH: !`env.sh USER`@!`env.sh HOST`

   # CORRECT: single call that outputs everything
   !`${CLAUDE_SKILL_DIR}/env.sh block`
   ```

2. **Must match allowed-tools** — the `!` backtick command goes through Bash permission checking. Add a matching pattern to `allowed-tools`:

   ```yaml
   allowed-tools: Bash(*/env.sh*)
   ```

3. **`${CLAUDE_SKILL_DIR}` is the only magic variable** — expands to the skill's absolute directory path. Use it to reference scripts within the skill.

4. **Non-Claude runtimes ignore `!` backticks** — Codex, Gemini, OpenClaw agents see the raw `!` backtick text. The skill should still be readable with defaults visible in the script.

### env.sh Pattern

Standard helper script supporting both single-var and block modes:

```bash
#!/bin/bash
source ~/.agents/.environment 2>/dev/null

if [ "$1" = "block" ]; then
  USER="${BROWSER_SSH_USER:-muqsit}"
  HOST="${BROWSER_SSH_HOST:-mac-mini}"
  PATHPFX="${BROWSER_SSH_PATH:-/opt/homebrew/bin}"
  BROWSER_CMD="${BROWSER_CMD:-openclaw browser}"
  cat <<EOF
- SSH target: ${USER}@${HOST}
- PATH prefix: ${PATHPFX}
- Browser command: ${BROWSER_CMD}
- Command prefix: ssh ${USER}@${HOST} "PATH=${PATHPFX}:\$PATH ${BROWSER_CMD}"
EOF
else
  key="$1"
  default="$2"
  val="${!key:-$default}"
  echo -n "$val"
fi
```

- `env.sh block` — outputs full environment section (for `!` backtick injection)
- `env.sh VAR_NAME default` — outputs single variable (for scripting)
- Sources `~/.agents/.environment` — machine-specific, gitignored
- Defaults baked in so the skill works even without `.environment`

### .environment File

Each machine gets its own `~/.agents/.environment` (gitignored):

```bash
# Agent environment — machine-specific values
OPENCLAW_USER=muqsit
OPENCLAW_HOST=mac-mini
OPENCLAW_PATH=/opt/homebrew/bin:/Users/muqsit/.agents/shims
TELEGRAM_CHAT_ID=6078999250
```

## Sync Workflow

### Local (Claude Code)

```bash
# Install/update skill for Claude
agents skills add ~/.agents/skills/<skill-name> --agents claude -y
```

This copies to `~/.claude/skills/<skill-name>/` where Claude Code reads it.

### Remote (mac-mini / OpenClaw agents)

```bash
# 1. Commit and push from local
cd ~/.agents && git add skills/<name> && git commit -m "feat: ..." && git push

# 2. Pull on mac-mini
ssh muqsit@mac-mini "cd ~/.agents && git pull"

# 3. Install to target agent
ssh muqsit@mac-mini "PATH=...:$PATH agents skills add ~/.agents/skills/<name> --agents codex -y"
```

## Writing Good Skills

### Content Principles

- **Command patterns over prose** — agents need exact commands, not explanations
- **Show the workflow** — numbered steps with actual commands
- **Document quirks** — things that break, timing issues, workarounds
- **One skill per tool/site** — browser is general, higgsfield is site-specific

### Anti-Patterns

- Hardcoded machine-specific values (use env injection)
- Overly long descriptions (agents have limited context)
- Missing allowed-tools (commands get blocked at runtime)
- Testing instructions (skills are operational, not educational)

### Skill Size

Keep skills focused. If a SKILL.md exceeds ~150 lines, consider:
- Moving reference material to separate files in the skill directory
- Splitting into a general skill + site-specific skill (e.g. browser + higgsfield)
