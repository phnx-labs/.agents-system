---
name: browser
description: Drive any website via agent-browser CLI or OpenClaw browser relay. Use when automating browser interactions, filling forms, clicking buttons, or taking screenshots.
argument-hint: "[url]"
allowed-tools: Bash(agent-browser*), Bash(sleep*), Bash(ssh*), Bash(openclaw*), Bash(*/env.sh*)
user-invocable: true
---

# Browser Automation

Two browser tools available. Choose based on where the browser runs.

| Scenario | Tool | Why |
|----------|------|-----|
| Browser on **remote server** | OpenClaw browser | Stable relay, persistent sessions, bypasses Cloudflare |
| Browser on **local machine** | agent-browser | Direct CDP control, local Chrome profiles |
| Need auth tokens from browser | agent-browser | Can eval JS to extract tokens from page context |

**Default: OpenClaw browser.** More stable, avoids Cloudflare blocks, relay persists across sessions.

## Environment

!`${CLAUDE_SKILL_DIR}/env.sh block`

## OpenClaw Browser (Preferred)

### Command Pattern

Use the **command prefix** from the environment block above, followed by the openclaw browser subcommand. Example:

```bash
ssh <user>@<host> "PATH=<pathprefix>:$PATH openclaw browser <command>"
```

### Tab Isolation (CRITICAL)

The browser is shared across multiple agents. **NEVER use `navigate`** — it replaces the active tab and destroys another agent's in-progress work.

**Three rules:**

1. **`open`, never `navigate`** — start every task with `openclaw browser open <url>`. This creates a new tab and returns a target ID. Save it.
2. **`focus` before interact** — before screenshot/click/type, always `openclaw browser focus <targetId>` first.
3. **`close` when done** — clean up with `openclaw browser close <targetId>`.

```bash
# CORRECT: isolated tab workflow
openclaw browser open 'https://example.com'       # returns target ID, e.g. 3EB5FF70...
openclaw browser focus 3EB5FF70                    # focus YOUR tab (prefix match works)
openclaw browser snapshot --labels                 # snapshot YOUR tab
openclaw browser click e42                         # interact with YOUR tab
openclaw browser screenshot                        # screenshot YOUR tab
openclaw browser close 3EB5FF70                    # cleanup when done

# WRONG: hijacks whatever tab is active
openclaw browser navigate 'https://example.com'    # NEVER DO THIS
```

**Why:** If Agent A is waiting for image generation on Higgsfield and Agent B runs `navigate`, Agent A's tab is replaced and the generation is lost.

### Core Commands

```bash
# Tab management
openclaw browser open <url>              # open URL in NEW tab (returns target ID)
openclaw browser tabs                    # list all open tabs with IDs
openclaw browser focus <targetId>        # switch to tab (prefix match)
openclaw browser close <targetId>        # close tab

# Page interaction (always focus your tab first)
openclaw browser snapshot --labels       # get element refs for clicking/typing
openclaw browser click <ref>             # click element by ref
openclaw browser type <ref> 'text'       # type into element by ref
openclaw browser select <ref> 'Option'   # select dropdown option
openclaw browser press Enter             # press key
openclaw browser press 'Meta+a'          # key combo

# Capture
openclaw browser screenshot              # screenshot active tab (MEDIA: path)
openclaw browser evaluate --fn '(el) => el.textContent' --ref 7

# Wait
openclaw browser wait --text "Done"      # wait for text to appear

# Download
openclaw browser download <ref>          # click ref and save download
```

### Workflow Pattern

1. `open` target URL (save the target ID)
2. `focus` your target ID
3. `snapshot --labels` to see page structure and get refs
4. `click` / `type` / `select` using refs from snapshot
5. `snapshot --labels` again after actions (refs change!)
6. `close` your target ID when done

### Key Behaviors

- **Refs are ephemeral** — they change after every page mutation. Always re-snapshot before clicking if the page has changed.
- **Contenteditable fields** — `type` works via the relay. If typing doesn't work, try `click` first to focus, then `type`.
- **Page navigation on click** — some SPAs navigate on click. If URL changes unexpectedly, re-open and re-snapshot.

### Troubleshooting

```bash
# If commands timeout, restart the daemon
openclaw daemon restart

# If relay is disconnected, restart browser
openclaw browser stop && openclaw browser start

# Check if relay extension is connected
openclaw browser tabs    # should list open tabs
```

## agent-browser (Local Fallback)

For local browser automation when OpenClaw isn't needed.

### Always Use Real Chrome + Headed Mode

Never use default Chromium — many sites block it. Always pass `--executable-path` to real Chrome and `--headed`.

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
