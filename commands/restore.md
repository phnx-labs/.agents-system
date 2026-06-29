---
description: Re-open agent sessions that were killed by a crash/reboot — detect the interrupted ones and relaunch them as Ghostty windows resuming each
argument-hint: "[repo path or keyword to scope | 'all' | empty = auto-detect last crash]"
---

You are restoring agent work that was lost when the machine crashed, rebooted,
or the terminal was killed — re-opening those sessions so they resume exactly
where they stopped. Scope: $ARGUMENTS (empty = auto-detect the most recent crash).

This is NOT `/continue` (which resumes context in *this* session). `/restore`
re-launches the *other* sessions that were abruptly shut down, each in its own
terminal, resuming its real transcript.

## 1. Find the crash boundary

- Last boot / crash time: `sysctl -n kern.boottime`. An unexpected reboot ≈ the
  crash moment. Sessions active just before it are the casualties.
- Raw transcripts are the source of truth (not the search index). Claude writes
  one JSONL per session under EACH installed version's home:
  `~/.agents/.history/versions/claude/*/home/.claude/projects/<encoded-cwd>/<id>.jsonl`
  (the encoded-cwd replaces `/` with `-`). Terminals may be pinned to different
  versions, so sweep ALL version homes, not just the one `~/.claude` points at.
- Scope by $ARGUMENTS when given (a repo path → its encoded project dir(s);
  a keyword → grep first user prompts). Empty → all projects.

## 2. Triage each candidate (don't restore blindly)

For every session whose mtime sits shortly before the crash boundary, read the
TAIL of its JSONL and classify:

- **Interrupted mid-task** — last entry is an assistant `tool_use` with no
  matching `tool_result`, or a user/tool message with no assistant reply, or the
  file is truncated. THESE are the ones worth restoring.
- **Completed & idle** — last assistant turn finished cleanly (answered, "Done",
  PR opened). Re-opening only reloads a finished thread; list it but don't
  default to restoring it.
- Note each session's `cwd`, its version (the home dir it lives in), its first
  real user prompt (the topic), and a one-line state.

Nothing is lost either way — the JSONL is intact on disk; `--resume` replays it.

## 3. Present the triage, then restore the chosen ones

Show a short table: id · version · cwd · topic · interrupted? Recommend the
interrupted set. **Ask which to open and how many** unless $ARGUMENTS already
said `all` — opening many live agents at once is exactly the load that causes
the crash you're recovering from.

Restore each chosen session as a Ghostty window (macOS has no CLI to launch
Ghostty directly — go through `open`), resuming with the VERSION-PINNED binary
in the session's own cwd, staggered so you never flood:

```bash
open -na Ghostty.app --args -e zsh -lc \
  "cd <CWD> && exec claude@<VERSION> --resume <SESSION_ID>"
sleep 1   # stagger between launches
```

- **Tabs instead of windows** (one window, many tabs): Ghostty has no CLI for
  that — drive it via the `computer` skill (focus Ghostty → ⌘T → type the
  resume command → Enter), repeating per session.
- **VS Code / Codium**: `code <cwd>` / `codium <cwd>` opens the folder, but a
  CLI cannot spawn an integrated-terminal tab running a command — that needs the
  agent-terminals extension. Offer the folder-open; don't claim tab automation.

## Guardrails

- Never auto-open more than a couple of live sessions without confirming the count.
- Verify each `open` returned exit 0; a Ghostty window should appear.
- Codex resumes with `codex@<ver> resume <id>`; Gemini/OpenCode have their own
  flags — `agents sessions` builds the correct per-agent resume command if unsure.
