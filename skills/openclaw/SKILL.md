---
name: openclaw
description: "Manage OpenClaw agents on mac-mini (~/.openclaw/). Triggers on: configuring agents, editing workspace files, setting up cron jobs, fixing heartbeat, creating new agents, or any OpenClaw gateway question."
---

# OpenClaw — Agent Gateway Management

OpenClaw is open-source software (docs: https://docs.openclaw.ai) running on **mac-mini** (`ssh muqsit@mac-mini`). It is a self-hosted gateway that connects AI agents to chat channels (Telegram, WhatsApp, Discord, etc.) and runs them on schedules.

**Before making any changes, check the official docs.** OpenClaw changes fast.

## Architecture

```
~/.openclaw/
├── openclaw.json              # Main gateway config (agents, channels, bindings, skills, hooks)
├── cron/
│   └── jobs.json              # Cron job store (gateway-managed — don't edit manually)
├── agents/{agentId}/agent/    # Agent-specific auth/credentials
├── skills/
│   └── {skill}/SKILL.md       # Managed skills (available to all agents)
└── {agentId}/                 # Agent workspace (one per agent)
    ├── AGENTS.md              # Operating instructions — injected every session
    ├── SOUL.md                # Persona, tone, boundaries — injected every session
    ├── IDENTITY.md            # Name, role, emoji — injected every session
    ├── USER.md                # Info about the human — injected every session
    ├── TOOLS.md               # Environment-specific notes (SSH hosts, devices, etc.)
    ├── HEARTBEAT.md           # Lightweight checklist for heartbeat monitoring runs
    ├── MEMORY.md              # Long-term curated memory (main session only)
    ├── BOOT.md                # Startup checklist (runs once at gateway restart via boot-md hook)
    ├── memory/
    │   └── YYYY-MM-DD.md      # Daily memory logs
    └── tasks/                 # Task files
```

**All agents run on mac-mini.** Always SSH to read/edit:
```bash
ssh muqsit@mac-mini "cat ~/.openclaw/{agentId}/AGENTS.md"
```


## Workspace Files — What Each Does

| File | Injected? | Purpose |
|------|-----------|---------|
| `AGENTS.md` | Every session | Operating instructions, memory system, safety rules, session startup sequence |
| `SOUL.md` | Every session | Persona, communication style, values, boundaries |
| `IDENTITY.md` | Every session | Name, role, emoji, what agent does and doesn't do |
| `USER.md` | Every session | Who the human is, their name, timezone, context, preferences |
| `TOOLS.md` | Every session | Environment-specific notes (not tool availability — that's skills) |
| `HEARTBEAT.md` | Every session | Monitoring checklist for heartbeat runs. **Empty = skip heartbeat API call** |
| `MEMORY.md` | Main session only | Long-term curated memory. Never loaded in group chats (privacy) |
| `BOOT.md` | On gateway restart | Startup checklist, runs via `boot-md` internal hook |
| `memory/YYYY-MM-DD.md` | Not injected | Daily logs, read by agent manually at session start |

**Size limits:** 20,000 chars per file, 150,000 chars total across all injected files. Large files are truncated with a warning.


## Heartbeat vs. Cron — Critical Distinction

### Heartbeat
**What it is:** Periodic agent turn in the **main session**. Agent wakes up, checks `HEARTBEAT.md`, returns `HEARTBEAT_OK` if nothing needs attention, or sends a message if something does.

**What it's for:** Lightweight batched monitoring. Checking multiple things in one turn (email + calendar + metrics). Awareness, not task execution.

**What it is NOT for:** Running autonomous tasks, delivering output independently, precise scheduling.

**Config in `openclaw.json`:**
```json
"heartbeat": {
  "every": "30m",
  "target": "last",
  "activeHours": { "start": "07:00", "end": "00:00", "timezone": "America/Los_Angeles" },
  "accountId": "agentName",
  "to": "TELEGRAM_CHAT_ID",
  "lightContext": true
}
```

**`HEARTBEAT.md`** should be a SHORT checklist (< 20 lines). Empty file = heartbeat is skipped entirely.

### Cron Jobs
**What it is:** Gateway-managed scheduler. Runs agent turns at precise times in **isolated sessions** (separate from main chat history).

**What it's for:** Autonomous task execution on a schedule. Output delivered directly to Telegram. Precise timing. Independent of main session.

**Create via CLI on mac-mini:**
```bash
PATH=/Users/muqsit/.agents/shims:$PATH openclaw cron add \
  --name "sergey-hourly" \
  --cron "10 * * * *" \
  --tz "America/Los_Angeles" \
  --session isolated \
  --agent sergey \
  --message "Check your HEARTBEAT.md and do your hourly tasks." \
  --no-deliver
```

**Note on `--announce` / delivery:** There is a known bug (issue #14743) where `--announce` delivery to Telegram silently fails. Use `--no-deliver` and instruct the agent to message Muqsit directly in the prompt.

**Manage cron jobs:**
```bash
PATH=/Users/muqsit/.agents/shims:$PATH openclaw cron list
PATH=/Users/muqsit/.agents/shims:$PATH openclaw cron run <jobId>   # Force run now
PATH=/Users/muqsit/.agents/shims:$PATH openclaw cron remove <jobId>
```

**Cron job store:** `~/.openclaw/cron/jobs.json` — managed by gateway, do not edit manually.


## Agent Config in openclaw.json

Each agent in `agents.list`:
```json
{
  "id": "sergey",
  "name": "sergey",
  "workspace": "/Users/muqsit/.openclaw/sergey",
  "agentDir": "/Users/muqsit/.openclaw/agents/sergey/agent",
  "model": "openrouter/moonshotai/kimi-k2.5",
  "heartbeat": {
    "every": "60m",
    "target": "telegram",
    "activeHours": { "start": "07:00", "end": "00:00", "timezone": "America/Los_Angeles" },
    "accountId": "sergey",
    "to": "6078999250"
  }
}
```

**Key heartbeat fields:**
- `every`: interval (`0m` = disabled)
- `target`: `"none"` (run silently), `"last"` (last active channel), `"telegram"` (deliver to Telegram)
- `accountId`: which Telegram bot account to use
- `to`: Telegram chat ID to deliver to
- `lightContext`: if `true`, only injects `HEARTBEAT.md` (cheaper, faster)


## Channel Binding

Connects inbound messages to a specific agent:
```json
"bindings": [
  { "agentId": "sergey", "match": { "channel": "telegram", "accountId": "sergey" } }
]
```

Each Telegram bot account needs its own `botToken` under `channels.telegram.accounts`.


## Creating a New Agent (Correct Process)

1. **Add to `openclaw.json`** under `agents.list`
2. **Create workspace directory:**
   ```bash
   ssh muqsit@mac-mini "mkdir -p ~/.openclaw/newagent/{memory,tasks}"
   ```
3. **Create required workspace files** (all must exist, even if minimal):
   - `AGENTS.md` — use the official template from `openclaw setup` or copy from another agent
   - `SOUL.md` — persona and values
   - `IDENTITY.md` — name, role, emoji
   - `USER.md` — who Muqsit is, his context
   - `TOOLS.md` — environment-specific notes
   - `HEARTBEAT.md` — monitoring checklist (or empty to skip)
   - `MEMORY.md` — start empty with headings so dashboard doesn't warn
   - `BOOT.md` — startup checklist (optional)
4. **Add Telegram binding** if agent needs its own bot
5. **Add cron job** for autonomous hourly work
6. **Restart daemon:**
   ```bash
   ssh muqsit@mac-mini "PATH=/Users/muqsit/.agents/shims:$PATH openclaw daemon restart"
   ```


## Which File to Edit for Each Change

| Goal | File to Edit |
|------|-------------|
| Agent's role, what it does | `~/.openclaw/{agentId}/IDENTITY.md` |
| Agent's personality, tone | `~/.openclaw/{agentId}/SOUL.md` |
| Agent's workflows, instructions | `~/.openclaw/{agentId}/AGENTS.md` |
| What the agent knows about Muqsit | `~/.openclaw/{agentId}/USER.md` |
| Monitoring checklist (heartbeat) | `~/.openclaw/{agentId}/HEARTBEAT.md` |
| Long-term memory | `~/.openclaw/{agentId}/MEMORY.md` |
| Startup behavior | `~/.openclaw/{agentId}/BOOT.md` |
| Environment-specific tool notes | `~/.openclaw/{agentId}/TOOLS.md` |
| Agent's model or heartbeat interval | `~/.openclaw/openclaw.json` |
| Telegram bot binding | `~/.openclaw/openclaw.json` (bindings + channels.telegram.accounts) |
| Scheduled autonomous tasks | `openclaw cron add ...` |


## Our Setup (mac-mini)

### Agents
| Agent ID | Bot | Role | Workspace |
|----------|-----|------|-----------|
| `main` | @JeffTrpBot | Chief of Staff (Jeff) | `~/.openclaw/workspace` |
| `sergey` | @SergeyTrpBot | Scout — Reddit/social scanning | `~/.openclaw/sergey` |
| `paul` | @PaulTrpBot | Writer — blog posts for getrush.ai | `~/.openclaw/paul-workspace` |
| `emma` | @EmmaTrpBot | Voice — social engagement, brand copy | `~/.openclaw/emma` |
| `marc` | @MarcTrpBot | Closer — VC outreach, prospect research | `~/.openclaw/marc` |

### Telegram Chat ID
Muqsit's Telegram chat ID: `6078999250`

### Restart Daemon
```bash
ssh muqsit@mac-mini "PATH=/Users/muqsit/.agents/shims:$PATH openclaw daemon restart"
```

### Check Logs
```bash
ssh muqsit@mac-mini "tail -100 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log | python3 -c \"
import sys, json
for line in sys.stdin:
    try:
        d = json.loads(line)
        print(d.get('time',''), str(d.get('1', d.get('0','')))[:120])
    except: pass
\""
```

### Check Channel Status
```bash
ssh muqsit@mac-mini "PATH=/Users/muqsit/.agents/shims:$PATH openclaw channels status --probe"
```


## Common Mistakes to Avoid

- **Using heartbeat for task execution** — heartbeat is monitoring only. Use cron for autonomous tasks.
- **Setting `target: "none"`** — this is the default and means heartbeat runs silently, never delivered. Must set `target: "telegram"` to deliver.
- **`--announce` with cron to Telegram** — known silent bug. Use `--no-deliver` instead and have the agent message directly.
- **Editing `cron/jobs.json` manually** — always use `openclaw cron` CLI.
- **Not reading docs before changing config** — OpenClaw changes fast. Always check https://docs.openclaw.ai first.
- **`MEMORY.md` empty/missing** — dashboard warns if `MEMORY.md` is absent or has no content. Create it with at least section headers.
