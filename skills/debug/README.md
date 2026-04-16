# Debug Skill

Systematic root cause analysis with independent verification via Swarm.

## Pipeline

```
                          agent-runner.sh debug '{...}'
                                    |
                                    v
                    +-------------------------------+
                    |     Phase 1: Investigate       |
                    |                               |
                    |  Trace full data path          |
                    |  A -> B -> C -> D              |
                    |  (read ALL files, quote        |
                    |   exact code at file:line)     |
                    |                               |
                    |  Output: hypothesis +          |
                    |  evidence chain                |
                    +-------------------------------+
                                    |
                                    v
                    +-------------------------------+
                    |  Phase 2: Verify (Swarm MCP)  |
                    |                               |
                    |  Spawn 2 agents (plan mode):  |
                    |                               |
                    |  +--------+    +--------+     |
                    |  | Codex  |    | Gemini |     |
                    |  +--------+    +--------+     |
                    |                               |
                    |  Each receives:               |
                    |   - System context            |
                    |   - Symptoms + UX impact      |
                    |   - Code paths to read        |
                    |                               |
                    |  Each does NOT receive:        |
                    |   - Your hypothesis            |
                    |   - Your proposed fix          |
                    +-------------------------------+
                                    |
                                    v
                    +-------------------------------+
                    |   Phase 3: Converge           |
                    |                               |
                    |  All agree ──> fix            |
                    |  Partial ────> read disputed  |
                    |                lines, decide  |
                    |  Disagree ───> re-investigate |
                    |                (don't default |
                    |                 to yours)     |
                    +-------------------------------+
                                    |
                              (convergence)
                                    |
                                    v
                    +-------------------------------+
                    |     Phase 4: Fix              |
                    |                               |
                    |  Minimal fix at root cause    |
                    |  Run tests                    |
                    |  Commit + push                |
                    |  Post structured report       |
                    +-------------------------------+
```

## Trigger

```bash
# Via agent-runner.sh
agent-runner.sh debug '{"description":"...","symptoms":"...","affectedFiles":["path/to/file.ts"],"prNumber":"123","branch":"agent/fix-123"}'

# Interactive (slash command)
/sdebug <description of bug>
```

## Context JSON

| Field | Required | Description |
|-------|----------|-------------|
| `description` | yes | What's broken |
| `symptoms` | no | What the user observes |
| `affectedFiles` | no | Files to start investigating |
| `prNumber` | no | PR number (posts report as comment) |
| `branch` | no | Branch to check out (defaults to main) |
| `issueId` | no | For dedup when triggered via webhook |

## Distribution

```
.agents repo (source of truth)
  └── skills/debug/SKILL.md
        |
        | agents pull
        v
  ~/.agents/skills/debug/          (live config)
        |
        | symlink
        v
  ~/.claude/skills/debug/          (agent-specific)
  ~/.codex/skills/debug/
  ~/.gemini/skills/debug/
```
