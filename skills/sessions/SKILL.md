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

### `load <query>` (also: "resume", "read", "open", "continue")

Find a named session, read its transcript, and be ready to continue the work.

**"Resume" means: read context, scan current state, present a plan. In one shot. No asking.**

**Steps:**

1. Collect all named sessions (same as `list` step 1-3).

2. Fuzzy match `<query>` against:
   - Session name (from `/rename` display field, stripped of `/rename ` prefix)
   - Session ID (full or short prefix)

   Match strategy: substring match, case-insensitive. If query matches multiple, show all matches and ask user to pick.

3. Once a session is identified, find the JSONL file:
   - Encode the project path (replace `/` with `-`)
   - Build the path: `~/.agents/versions/<agent>/<version>/home/.<agent>/projects/<encoded-path>/<session-id>.jsonl`

4. Read the FULL session transcript (read in chunks if needed — don't stop at 200 lines):
   ```bash
   python3 ~/.agents/skills/sessions/read-session.py <path-to-session.jsonl> --tools | head -200
   # If there's more, keep reading:
   python3 ~/.agents/skills/sessions/read-session.py <path-to-session.jsonl> --tools | tail -n +201 | head -200
   # Continue until you have the full picture
   ```

   ALWAYS use `--tools` — it shows tool calls as one-liners which gives context for what files were touched and what work was done.

5. **Immediately after reading** (no waiting for user input):
   - Scan the relevant files/dirs mentioned in the transcript to see current state
   - Check for any existing plans, TODOs, or partial implementations
   - Identify what was completed vs what's left

6. Present a single summary to the user:
   - **Done:** What was completed in that session
   - **Remaining:** What's unfinished, with specifics (files, features, tests)
   - **Current state:** Quick scan of whether the completed work is still intact or has been modified since
   - **Proposed plan:** Concrete next steps to finish the remaining work

   Then start working. Don't ask "want to proceed?" — the user said resume, so resume.

## Agent Detection

Detect which agents are installed by checking which directories exist under `~/.agents/versions/`:

- `claude` -> history at `home/.claude/history.jsonl`, resume with `claude -r <id> --continue`
- `codex` -> history at `home/.codex/history.jsonl` (if it has `/rename` entries), resume with `codex -r <id>`

Codex uses a different history format (`session_id`, `ts`, `text` fields instead of `display`, `timestamp`, `sessionId`). Only Claude's history has structured `/rename` entries. For codex, skip rename scanning unless the format changes.

## Edge Cases

- **No named sessions found:** "No named sessions found across any version."
- **Session JSONL missing:** The rename entry exists but the file was deleted. Skip it, note "(file missing)".
- **Multiple matches for load query:** Show all matches in a numbered list, ask user to pick.
- **Long sessions:** Read in chunks until you have the full picture. Don't stop at 200 lines and ask — keep going.
