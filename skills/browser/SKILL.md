---
name: browser
description: Drive any website via agent-browser CLI or a remote browser relay (e.g. OpenClaw). Use when automating browser interactions, filling forms, clicking buttons, or taking screenshots.
argument-hint: "[url]"
allowed-tools: Bash(agent-browser*), Bash(sleep*), Bash(ssh*), Bash(openclaw*), Bash(*/env.sh*)
user-invocable: true
---

# Browser Automation

Two browser tools available. Choose based on where the browser runs.

| Scenario | Tool | Why |
|----------|------|-----|
| Browser on **remote server** | Remote browser relay | Stable relay, persistent sessions, bypasses Cloudflare |
| Browser on **local machine** | agent-browser | Direct CDP control, local Chrome profiles |
| Need auth tokens from browser | agent-browser | Can eval JS to extract tokens from page context |

**Default: Remote browser relay.** More stable, avoids Cloudflare blocks, relay persists across sessions.

## Environment

!`${CLAUDE_SKILL_DIR}/env.sh block`

## Remote Browser (Preferred)

### Command Pattern

Use the **command prefix** from the environment block above, followed by the browser subcommand. Example:

```bash
ssh <user>@<host> "PATH=<pathprefix>:$PATH ${BROWSER_CMD} <command>"
```

### Tab Isolation (CRITICAL)

The browser is shared across multiple agents. **NEVER use `navigate`** — it replaces the active tab and destroys another agent's in-progress work.

**Three rules:**

1. **`open`, never `navigate`** — start every task with `${BROWSER_CMD} open <url>`. This creates a new tab and returns a target ID. Save it.
2. **`focus` before interact** — before screenshot/click/type, always `${BROWSER_CMD} focus <targetId>` first.
3. **`close` when done** — clean up with `${BROWSER_CMD} close <targetId>`.

```bash
# CORRECT: isolated tab workflow
${BROWSER_CMD} open 'https://example.com'       # returns target ID, e.g. 3EB5FF70...
${BROWSER_CMD} focus 3EB5FF70                    # focus YOUR tab (prefix match works)
${BROWSER_CMD} snapshot --labels                 # snapshot YOUR tab
${BROWSER_CMD} click e42                         # interact with YOUR tab
${BROWSER_CMD} screenshot                        # screenshot YOUR tab
${BROWSER_CMD} close 3EB5FF70                    # cleanup when done

# WRONG: hijacks whatever tab is active
${BROWSER_CMD} navigate 'https://example.com'    # NEVER DO THIS
```

**Why:** If Agent A is waiting for image generation and Agent B runs `navigate`, Agent A's tab is replaced and the generation is lost.

### Core Commands

```bash
# Tab management
${BROWSER_CMD} open <url>              # open URL in NEW tab (returns target ID)
${BROWSER_CMD} tabs                    # list all open tabs with IDs
${BROWSER_CMD} focus <targetId>        # switch to tab (prefix match)
${BROWSER_CMD} close <targetId>        # close tab

# Page interaction (always focus your tab first)
${BROWSER_CMD} snapshot --labels       # get element refs for clicking/typing
${BROWSER_CMD} click <ref>             # click element by ref
${BROWSER_CMD} type <ref> 'text'       # type into element by ref
${BROWSER_CMD} select <ref> 'Option'   # select dropdown option
${BROWSER_CMD} press Enter             # press key
${BROWSER_CMD} press 'Meta+a'          # key combo

# Capture
${BROWSER_CMD} screenshot              # screenshot active tab (MEDIA: path)
${BROWSER_CMD} evaluate --fn '(el) => el.textContent' --ref 7

# Wait
${BROWSER_CMD} wait --text "Done"      # wait for text to appear

# Download
${BROWSER_CMD} download <ref>          # click ref and save download
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
${BROWSER_CMD} stop && ${BROWSER_CMD} start

# Check if relay extension is connected
${BROWSER_CMD} tabs    # should list open tabs
```

## agent-browser (Local Fallback)

For local browser automation when the remote relay isn't needed.

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
