---
name: rdev
description: "Dispatch engineering tasks to coding agents (Claude, Codex) on mac-mini. Triggers on 'rdev', 'dev', 'dispatch', 'spawn agent', 'send to claude/codex', 'run agent on issue', or when user wants a coding agent to work on a Linear issue."
---

# rdev -- Rush Dev Pipeline

Dispatch engineering tasks to coding agents on mac-mini. Agents work in isolated git worktrees. The full pipeline runs automatically: implement, review, fix if needed, label when ready.

## Pipeline

```
/rdev RUSH-167
  |
  v
[1. Dev Agent] -- implements feature, writes tests, pushes branch, opens PR
  |
  v
[2. Review Agent] -- separate Claude session, runs tests, reviews code,
  |                   posts comment on PR via gh pr comment
  v
[3. Fix-if-needed Agent] -- reads review comment, decides:
  |   clean? --> adds ux-ready label, done
  |   issues? --> fixes them, pushes, adds ux-ready label, done
  v
Human merges
```

Each step is a separate Claude `--print` session with its own `--session-id`. No looping. The fix agent gets a summary of what the dev agent did (via `read-session.py --summary`) and reads the review comment itself.

## Dispatch Methods

### Via Linear label (webhook-driven)

Add `agent:claude` or `agent:codex` label to a Linear issue. The webhook handler in halo-proxy picks it up and SSHes to mac-mini.

```bash
# Label IDs
# agent:claude = c24d97e2-7891-4e54-8972-263f1e9f28a0
# agent:codex  = fd0646d1-751f-4a39-ab26-cc48a813dbf7
```

### Via direct SSH

Skip Linear. SSH to mac-mini and run agent-runner directly:

```bash
ssh muqsit@mac-mini "nohup bash ~/src/github.com/muqsitnawaz/agents/scripts/agent-runner.sh \
  'linear' \
  '{\"issueId\":\"UUID\",\"title\":\"Title\",\"description\":\"Desc\",\"url\":\"URL\",\"teamKey\":\"RUSH\",\"number\":123}' \
  'claude' \
  > /tmp/agent-dispatch-$(date +%s).log 2>&1 & disown"
```

### Via review trigger (review + fix only, no implementation)

Test the review pipeline on an existing PR:

```bash
ssh muqsit@mac-mini "nohup bash ~/src/github.com/muqsitnawaz/agents/scripts/agent-runner.sh \
  'review' \
  '{\"prNumber\":30,\"branch\":\"agent/RUSH-167\"}' \
  'claude' \
  > /tmp/agent-review-$(date +%s).log 2>&1 & disown"
```

## Monitor

```bash
# Find latest log
ssh muqsit@mac-mini "ls -lt /tmp/agent-*.log | head -5"

# Tail a running agent
ssh muqsit@mac-mini "tail -f /tmp/agent-claude-linear-*.log"

# Check if process is alive
ssh muqsit@mac-mini "ps aux | grep agent-runner | grep -v grep"

# Get live summary of what the agent is doing (while running)
ssh muqsit@mac-mini "python3 ~/.agents/skills/sessions/read-session.py \
  \$(ls -t ~/.claude/projects/-private-tmp-agent-*/*.jsonl | head -1) --summary"
```

## Session Summarizer

`read-session.py` at `~/.agents/skills/sessions/read-session.py` reads Claude session JSONL files:

```bash
# Conversation only
python3 ~/.agents/skills/sessions/read-session.py <session.jsonl>

# With tool calls as one-liners
python3 ~/.agents/skills/sessions/read-session.py <session.jsonl> --tools

# Activity fingerprint (files + commands, no reasoning)
python3 ~/.agents/skills/sessions/read-session.py <session.jsonl> --summary

# Full verbose output
python3 ~/.agents/skills/sessions/read-session.py <session.jsonl> --full
```

The `--summary` mode is what the fix-if-needed agent receives as context about what the dev agent did.

## Writing Good Issue Descriptions

Agents work best with explicit scope:

```markdown
## Goal
One sentence.

## Scope
### 1. First deliverable
- Exact details, file paths

### 2. Second deliverable
- Exact details

## Out of scope
- Things the agent should NOT touch

## Files to read first
- `path/to/file.ts` -- why

## Files to create/modify
- `path/to/new-file.yml`
- `path/to/existing-file.ts` -- what to change
```

## Pipeline Architecture

| File | Purpose |
|------|---------|
| `scripts/agent-runner.sh` | Worktree lifecycle, 3-step pipeline (dev, review, fix) |
| `halo/proxy/src/hooks/linear.ts` | Linear webhook, extracts agent from label |
| `halo/proxy/src/hooks/github.ts` | GitHub push webhook, triggers QA agent |
| `halo/proxy/src/hooks/spawn.ts` | SSH spawner, fires agent-runner on mac-mini |
| `~/.agents/skills/sessions/read-session.py` | Session JSONL reader + summarizer |

## GitHub Actions Fallback

The `claude-code-review.yml` workflow is disabled (`if: false`) since reviews run locally on mac-mini. Re-enable it in `.github/workflows/claude-code-review.yml` if mac-mini is unreachable:

```yaml
# Remove this line to re-enable:
if: false  # Disabled: review runs locally on mac-mini
```

## Auth

- `CLAUDE_CODE_OAUTH_TOKEN` in `~/.zshenv` on mac-mini
- `gh` CLI needs periodic re-auth for PR creation and comments
- Codex uses its own auth (`codex login`)

## Cleanup Stale Worktrees

```bash
ssh muqsit@mac-mini "cd ~/src/github.com/muqsitnawaz/agents && \
  git worktree list | grep '/tmp/agent-' | awk '{print \$1}' | \
  while read wt; do git worktree remove --force \"\$wt\" 2>/dev/null; done"
```
