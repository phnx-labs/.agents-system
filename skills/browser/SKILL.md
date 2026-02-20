---
name: browser
description: Drive any website via agent-browser CLI. Use when automating browser interactions, filling forms, clicking buttons, or taking screenshots.
argument-hint: "[url]"
allowed-tools: Bash(agent-browser*), Bash(sleep*)
user-invocable: true
---

# Browser Automation via agent-browser

You automate websites using the `agent-browser` CLI. Run `agent-browser --help` for the full command reference.

## Guidelines

### Always Use Real Chrome + Headed Mode

Never use the default Chromium — many sites block it (especially Google OAuth). Always pass `--executable-path` to real Chrome and `--headed`.

### Profile = Skill Name

Profiles persist logins across sessions. They live at `~/.agent-browser/profiles/` and are named after the corresponding skill:

- `/kimi` skill → `--profile ~/.agent-browser/profiles/kimi`
- `/perplexity` skill → `--profile ~/.agent-browser/profiles/perplexity`
- `/higgsfield` skill → `--profile ~/.agent-browser/profiles/higgsfield`

Always use the matching profile. If it doesn't exist yet, create it — the user will need to log in manually once.

### Launch Template

```bash
agent-browser \
  --executable-path "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --profile ~/.agent-browser/profiles/<skill-name> \
  open "<URL>" --headed 2>&1
```

### Set Viewport After Launch

Always set the viewport to a standard macOS resolution immediately after opening the browser. This prevents sites from blocking requests due to unusual window sizes.

```bash
agent-browser set viewport 1440 900 2>&1
```

### Read Site-Specific Skills First

If a skill exists for the target site (e.g. `/kimi`), read it before doing anything. It documents input quirks, submission methods, and pitfalls specific to that site.

### Rich Text Editors

Standard `fill`/`type` commands fail silently on contenteditable / ProseMirror editors. When typing produces nothing, use `execCommand('insertText')` via `agent-browser eval`.

### Waiting for Results

Pages load asynchronously. Use `sleep N && agent-browser screenshot` to wait and verify. Start short (3-5s), increase if content hasn't appeared.

### Screenshots Are Your Eyes

Always screenshot after navigation, after submitting, and while waiting for generation. Read the screenshot files to understand page state.
