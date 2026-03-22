---
name: browser
description: Drive any website via agent-browser CLI or OpenClaw browser relay. Use when automating browser interactions, filling forms, clicking buttons, or taking screenshots.
argument-hint: "[url]"
allowed-tools: Bash(agent-browser*), Bash(sleep*), Bash(ssh*), Bash(openclaw*)
user-invocable: true
---

# Browser Automation

Two browser automation tools are available. Choose based on where the browser runs.

## Tool Selection

| Scenario | Tool | Why |
|----------|------|-----|
| Browser on **mac-mini** (remote) | OpenClaw browser | Stable relay via Chrome extension, no CDP flakiness, persistent sessions |
| Browser on **local machine** | agent-browser | Direct CDP control, local Chrome profiles |
| Site blocks Cloudflare/bot detection | OpenClaw browser on mac-mini | Extension relay = real user traffic, undetectable |
| Need to grab auth tokens from browser | agent-browser | Can eval JS to extract tokens from page context |

**Default: OpenClaw browser on mac-mini.** It's more stable, avoids Cloudflare blocks, and the relay persists across sessions. Only use agent-browser locally when you specifically need local Chrome or JS eval for token extraction.

## OpenClaw Browser (Preferred)

Runs on mac-mini via Chrome extension relay. All commands go through SSH.

### Command Pattern

```bash
# All commands need the PATH prefix
ssh muqsit@mac-mini "PATH=/opt/homebrew/bin:/Users/muqsit/.agents/shims:\$PATH openclaw browser <command>"
```

### Core Commands

```bash
# Start browser / ensure relay is connected
openclaw browser start

# Navigate to URL
openclaw browser navigate 'https://example.com'

# Snapshot page (get element refs for clicking/typing)
openclaw browser snapshot --labels

# Click element by ref
openclaw browser click e42

# Type into element by ref
openclaw browser type e15 'text here'

# Select dropdown option
openclaw browser select e9 'OptionA'

# Press key
openclaw browser press Enter
openclaw browser press 'Meta+a'

# Screenshot (returns MEDIA: path)
openclaw browser screenshot

# Evaluate JS on page or element
openclaw browser evaluate --fn '(el) => el.textContent' --ref 7

# Tabs
openclaw browser tabs
openclaw browser focus <targetId>
openclaw browser close <targetId>

# Wait for text to appear
openclaw browser wait --text "Done"

# Download file triggered by clicking a ref
openclaw browser download <ref>
```

### Workflow Pattern

1. `navigate` to the target URL
2. `snapshot --labels` to see the page structure and get refs
3. `click` / `type` / `select` using refs from snapshot
4. `snapshot --labels` again after actions (refs change!)

### Key Behaviors

- **Refs are ephemeral** — they change after every page mutation. Always re-snapshot before clicking if the page has changed.
- **Aspect ratio dropdowns** — click the current aspect button to open dropdown, snapshot to find options, click the option. The dropdown must be open to see options.
- **Contenteditable fields** — `type` works via the relay (unlike agent-browser where you need execCommand). If typing doesn't work, try `click` first to focus, then `type`.
- **Page navigation on click** — some SPAs navigate when you click elements. If the URL changes unexpectedly after a click, re-navigate and re-snapshot.

### Troubleshooting

```bash
# If commands timeout, restart the daemon
openclaw daemon restart

# If relay is disconnected, restart browser
openclaw browser stop && openclaw browser start

# Check if relay extension is connected
openclaw browser tabs  # Should list open tabs
```

## agent-browser (Local Fallback)

For local browser automation when OpenClaw isn't needed.

### Always Use Real Chrome + Headed Mode

Never use the default Chromium — many sites block it. Always pass `--executable-path` to real Chrome and `--headed`.

### Profile = Skill Name

Profiles persist logins: `~/.agent-browser/profiles/<skill-name>`

### Launch Template

```bash
agent-browser \
  --executable-path "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --profile ~/.agent-browser/profiles/<skill-name> \
  open "<URL>" --headed 2>&1
```

### Set Viewport After Launch

```bash
agent-browser set viewport 1440 900 2>&1
```

### Rich Text Editors

Standard `fill`/`type` commands fail on contenteditable / ProseMirror editors. Use `execCommand('insertText')` via `agent-browser eval`.

### Read Site-Specific Skills First

If a skill exists for the target site (e.g. `/higgsfield`), read it before doing anything.

### Screenshots Are Your Eyes

Always screenshot after navigation, after submitting, and while waiting for generation.
