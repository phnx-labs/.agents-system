---
name: browser
description: Drive a browser to automate websites — fill forms, click buttons, take screenshots, scrape pages. Uses the built-in `browser` command (or `agents browser`).
argument-hint: "[url]"
allowed-tools: Bash(browser*), Bash(agents browser*), Bash(sleep*)
user-invocable: true
---

# Browser Automation

The `browser` command (shorthand for `agents browser`) provides CDP-based browser automation with profile and task management.

## Quick Start

```bash
# Create a profile (one-time setup)
browser profiles create my-profile -b chrome -e cdp://localhost:9222

# Start a task (auto-launches browser if needed)
browser start my-task --profile my-profile

# Navigate and interact
browser navigate my-task https://example.com
browser refs my-task              # Get clickable element refs
browser click my-task <tabId> <ref>
browser type my-task <tabId> <ref> "hello"
browser screenshot my-task
browser stop my-task
```

## Profiles

Profiles define browser type and connection endpoint. Create once, reuse across tasks.

```bash
# Local Chrome
browser profiles create local -b chrome -e cdp://localhost:9222

# Remote browser via SSH tunnel
browser profiles create mac-mini -b comet -e ssh://mac-mini?port=9333

# List profiles
browser profiles list
```

Supported browsers: `chrome`, `comet`, `chromium`, `brave`, `edge`

## Tasks

Tasks are browser sessions. Each task gets its own tabs and state.

```bash
browser start [task-name] --profile <profile>   # auto-generates name if omitted
browser tasks                                    # list active tasks
browser stop <task>                              # close task and its tabs
```

## Navigation & Tabs

```bash
browser navigate <task> <url>          # open URL in new tab
browser tabs <task>                    # list open tabs
browser close <task> [tabId]           # close specific tab or all
```

## DOM Interaction

```bash
browser refs <task> [tabId]                    # get interactive element refs
browser click <task> <tabId> <ref>             # click element
browser type <task> <tabId> <ref> "text"       # type into element
browser press <task> <tabId> Enter             # press key (Enter, Tab, Escape)
browser hover <task> <tabId> <ref>             # hover over element
```

## Screenshots & Evaluation

```bash
browser screenshot <task> [tabId]              # capture to ~/.agents-system/browser/sessions/<task>/
browser evaluate <task> <tabId> "document.title"   # run JS, return result
```

## Account Credentials

Before navigating to sites that require login, load credentials:

```bash
eval "$(agents secrets export browser-accounts --plaintext)"
```

Known accounts (configure in `browser-accounts` bundle):

| Service | Username variable | Password variable |
|---------|------------------|------------------|
| Grafana | `$GRAFANA_USERNAME` | `$GRAFANA_PASSWORD` |
| Cloudflare | `$CLOUDFLARE_USERNAME` | `$CLOUDFLARE_PASSWORD` |

Always screenshot first — if the session is still alive in the profile, skip login.

## Workflow Pattern

1. **Start** a task with a profile
2. **Navigate** to target URL
3. **Refs** to see clickable elements with their ref numbers
4. **Click / type / press** using refs
5. **Refs** again after each action — refs are ephemeral
6. **Screenshot** liberally — screenshots are your eyes
7. **Stop** the task when done

## Rich Text Editors

`type` may fail on contenteditable / ProseMirror. Use evaluate:

```bash
browser evaluate <task> <tabId> 'document.execCommand("insertText", false, "your text")'
```

## Remote Browsers (SSH)

For browsers on remote machines:

```bash
# Create profile with SSH endpoint
browser profiles create remote-mac -b comet -e ssh://user@hostname?port=9222

# Use normally — SSH tunnel is automatic
browser start task --profile remote-mac
browser navigate task https://example.com
```

The SSH driver launches the browser on the remote host and tunnels CDP back.
