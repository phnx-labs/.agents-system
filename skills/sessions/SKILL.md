---
name: sessions
description: "List and load named sessions across agent versions. Triggers on: '/sessions', 'list sessions', 'find session', 'load session', 'resume session', 'read session', switching versions and losing sessions."
---

# Sessions

Discover and read named sessions across all installed agent versions. When users switch versions via `agents use`, their named sessions from previous versions become invisible. This skill finds them.

## Architecture

Sessions are stored per-version:
```
~/.agents/versions/<agent>/<version>/home/.<agent>/
  history.jsonl          # Contains /rename entries mapping names to session IDs
  projects/<encoded-path>/<session-id>.jsonl   # Actual session data
```

The encoded path replaces `/` with `-` (e.g., `/Users/muqsit/src/foo` becomes `-Users-muqsit-src-foo`).

## Reader Script

A Python script at `~/.agents/skills/sessions/read-session.py` reads session JSONL files and outputs clean conversation transcripts, stripping tool call noise.

```bash
# Conversation only (user messages + assistant text)
python3 ~/.agents/skills/sessions/read-session.py <session.jsonl>

# Include tool calls as one-liners
python3 ~/.agents/skills/sessions/read-session.py <session.jsonl> --tools

# Full tool inputs and outputs (verbose)
python3 ~/.agents/skills/sessions/read-session.py <session.jsonl> --full
```

Use this script whenever loading/reading a session. Do NOT cat the raw JSONL — it's 90%+ tool result noise.

## Commands

### `list` (default)

Scan all versions of all agents for named sessions.

**Steps:**

1. Find all agent types by listing `~/.agents/versions/`:
   ```bash
   ls ~/.agents/versions/
   ```

2. For each agent (e.g., `claude`), list versions:
   ```bash
   ls ~/.agents/versions/claude/
   ```

3. For each version, extract `/rename` entries from history:
   ```bash
   grep '/rename' ~/.agents/versions/claude/<version>/home/.claude/history.jsonl
   ```
   Each line is JSON with fields: `display` (contains `/rename <name>`), `timestamp`, `project`, `sessionId`.

4. Determine the current version:
   ```bash
   cat ~/.agents-version 2>/dev/null
   ```
   Parse the YAML to find the version for the current agent. If no `.agents-version`, check the global default.

5. For each named session, check if the JSONL file exists:
   ```bash
   # Encode project path: replace / with -
   # e.g., /Users/muqsit/src/github.com/muqsitnawaz/agents -> -Users-muqsit-src-github-com-muqsitnawaz-agents
   ls ~/.agents/versions/claude/<version>/home/.claude/projects/<encoded-path>/<session-id>.jsonl
   ```

6. Present results grouped by version:

```
Sessions (claude)

  v2.1.62 (current)
    fix-tests              0ce808fc  Mar 1   agents
    fix-ratings-tables     98ee34f9  Mar 2   agents

  v2.0.65
    finish-channels-impl   8775cb84  Feb 28  agents
    agent-skill-labels     5ee19088  Feb 28  agents
```

Format: `name  short-id  date  project-basename`

Mark the current version. Show session count per version.

### `load <query>`

Find a named session by fuzzy matching, then read it using the reader script.

**Steps:**

1. Collect all named sessions (same as `list` step 1-3).

2. Fuzzy match `<query>` against:
   - Session name (from `/rename` display field, stripped of `/rename ` prefix)
   - Session ID (full or short prefix)

   Match strategy: substring match, case-insensitive. If query matches multiple, show all matches and ask user to pick.

3. Once a session is identified, find the JSONL file:
   - Encode the project path (replace `/` with `-`)
   - Build the path: `~/.agents/versions/<agent>/<version>/home/.<agent>/projects/<encoded-path>/<session-id>.jsonl`

4. Read the session using the reader script:
   ```bash
   python3 ~/.agents/skills/sessions/read-session.py <path-to-session.jsonl> --tools
   ```

   This outputs a clean transcript: user messages, assistant text, and tool call summaries. Pipe through `head -200` if the session is very long, then ask the user if they want more.

5. After reading, tell the user:
   - Session name, version it's from, project
   - If they want to resume it: `claude -r <session-id> --continue` (same version only)
   - If cross-version resume is needed: they'd need to symlink the JSONL into the current version's projects dir first

### `resume <query>` (optional)

If the user explicitly wants to resume (not just read), follow these steps after finding the session:

**Same version as current:** Resume directly.
```bash
claude -r <session-id> --continue
```

**Different version:** Symlink the JSONL into the current version's projects dir, then resume.
```bash
mkdir -p ~/.agents/versions/claude/<current>/home/.claude/projects/<encoded-path>/
ln -s <old-jsonl-path> <current-projects-dir>/<session-id>.jsonl
# Also symlink session directory if it exists alongside the JSONL
claude -r <session-id> --continue
```

## Agent Detection

Detect which agents are installed by checking which directories exist under `~/.agents/versions/`:

- `claude` -> history at `home/.claude/history.jsonl`, resume with `claude -r <id> --continue`
- `codex` -> history at `home/.codex/history.jsonl` (if it has `/rename` entries), resume with `codex -r <id>`

Codex uses a different history format (`session_id`, `ts`, `text` fields instead of `display`, `timestamp`, `sessionId`). Only Claude's history has structured `/rename` entries. For codex, skip rename scanning unless the format changes.

## Edge Cases

- **No named sessions found:** "No named sessions found across any version."
- **Session JSONL missing:** The rename entry exists but the file was deleted. Skip it, note "(file missing)".
- **Symlink already exists:** If target already has the JSONL (same file or existing symlink), skip linking.
- **Multiple matches for load query:** Show all matches in a numbered list, ask user to pick.
- **Long sessions:** Pipe reader output through `head -N` and offer to show more.
