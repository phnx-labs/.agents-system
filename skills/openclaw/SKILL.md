---
name: openclaw
description: Manage OpenClaw agents (~/.openclaw/). Triggers on: editing AGENTS.md/SOUL.md/IDENTITY.md, checking HEARTBEAT.md, configuring openclaw.json, or creating new agents.
---

# OpenClaw Skill: Agent Management

OpenClaw runs autonomous AI agents that wake on a schedule (heartbeat), maintain persistent memory, and can use tools. This skill teaches you how to configure and manage them.

## File Structure

```
~/.openclaw/
|- openclaw.json              # Main config (agent list, models, channel bindings)
|- agents/{agent}/agent/      # Agent-specific auth/credentials
|- {agent}/                   # Agent workspace
|   |- IDENTITY.md            # Who: name, role, personality
|   |- SOUL.md                # Core beliefs, boundaries, vibe
|   |- TOOLS.md               # Available tools and usage
|   |- AGENTS.md              # Full instructions (main file to edit)
|   |- HEARTBEAT.md           # Auto-updated activity log
|   |- memory/                # Persistent memory
|   |- tasks/                 # Task tracking
|- skills/
    |- {skill}/SKILL.md       # Shared skills available to all agents
```

## Quick Reference

### Read Agent Instructions

```bash
cat ~/.openclaw/{agent}/AGENTS.md
cat ~/.openclaw/{agent}/SOUL.md
cat ~/.openclaw/{agent}/IDENTITY.md
```

### Check Agent Activity

```bash
# Recent activity log
cat ~/.openclaw/{agent}/HEARTBEAT.md

# Memory files
ls ~/.openclaw/{agent}/memory/
cat ~/.openclaw/{agent}/memory/recent.md

# Active tasks
ls ~/.openclaw/{agent}/tasks/
```

### Modify Agent Instructions

```bash
# Read current
cat ~/.openclaw/{agent}/AGENTS.md

# Edit with your preferred method, or append:
cat >> ~/.openclaw/{agent}/AGENTS.md << 'EOF'

## New Section
Content here
EOF
```

### Check Main Config

```bash
cat ~/.openclaw/openclaw.json
```

## Which File to Edit

| Change | File |
|--------|------|
| Agent's full behavior/workflow | `~/.openclaw/{agent}/AGENTS.md` |
| Agent's personality/voice | `~/.openclaw/{agent}/SOUL.md` |
| Agent's role definition | `~/.openclaw/{agent}/IDENTITY.md` |
| Agent's available tools | `~/.openclaw/{agent}/TOOLS.md` |
| Agent's model | `~/.openclaw/openclaw.json` (agents.list) |
| Channel binding (Telegram, etc.) | `~/.openclaw/openclaw.json` (bindings + channels) |
| Add a new skill | `~/.openclaw/skills/{skill}/SKILL.md` |

## Creating a New Agent

1. **Add to config** (`~/.openclaw/openclaw.json`):
```json
{
  "agents": {
    "list": [
      {
        "id": "myagent",
        "name": "myagent",
        "workspace": "~/.openclaw/myagent",
        "agentDir": "~/.openclaw/agents/myagent/agent",
        "model": "openrouter/anthropic/claude-sonnet-4",
        "heartbeat": {
          "every": "30m",
          "activeHours": { "start": "08:00", "end": "00:00", "timezone": "America/Los_Angeles" }
        }
      }
    ]
  }
}
```

2. **Create workspace**:
```bash
mkdir -p ~/.openclaw/myagent/{memory,tasks}
```

3. **Create required files**:
- `IDENTITY.md` - Who the agent is (name, role, personality)
- `SOUL.md` - Core beliefs and boundaries
- `TOOLS.md` - Available tools and how to use them
- `AGENTS.md` - Full instructions and workflows

4. **Add channel binding** (optional, for Telegram/Discord/etc.):
```json
{
  "bindings": [
    { "agentId": "myagent", "match": { "channel": "telegram", "accountId": "myagent" } }
  ],
  "channels": {
    "telegram": {
      "accounts": {
        "myagent": {
          "name": "MyAgent",
          "enabled": true,
          "dmPolicy": "allowlist",
          "botToken": "YOUR_BOT_TOKEN",
          "allowFrom": ["YOUR_TELEGRAM_ID"],
          "groupPolicy": "allowlist",
          "streamMode": "partial"
        }
      }
    }
  }
}
```

## Heartbeat Configuration

Agents wake on a schedule defined by `heartbeat`:

```json
{
  "heartbeat": {
    "every": "30m",
    "activeHours": {
      "start": "08:00",
      "end": "00:00",
      "timezone": "America/Los_Angeles"
    }
  }
}
```

Options for `every`: `5m`, `15m`, `30m`, `1h`, `2h`, `4h`, `daily`

## Model Selection

Set in `openclaw.json` under each agent's config:

```json
{
  "model": "openrouter/anthropic/claude-sonnet-4"
}
```

Common models:
- `openrouter/anthropic/claude-sonnet-4` - Balanced capability
- `openrouter/anthropic/claude-opus-4` - Maximum capability
- `openrouter/openai/gpt-4o` - Fast, good at structured output
- `openrouter/google/gemini-2.5-pro` - Large context, good reasoning

## Anti-Patterns

**Bad**: Editing files without reading them first
```bash
# Don't do this - you might overwrite important content
echo 'new content' > ~/.openclaw/myagent/AGENTS.md
```

**Good**: Read, understand, then edit
```bash
cat ~/.openclaw/myagent/AGENTS.md  # Read first
# Then make targeted edits
```

## Remote Agents

If agents run on a remote machine, prefix all commands with SSH:

```bash
ssh user@hostname "cat ~/.openclaw/myagent/AGENTS.md"
ssh user@hostname "cat ~/.openclaw/myagent/HEARTBEAT.md"
```

Remember: local `~/.openclaw/` is different from remote `~/.openclaw/`.
