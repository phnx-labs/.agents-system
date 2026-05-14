# Browser Use — Web Automation

CDP-based automation for websites and web apps.

## Quick Start

```bash
# Create a profile (one-time)
agents browser profiles create my-profile -b chrome -e cdp://localhost:9222

# Start a task — sets AGENTS_BROWSER_TASK for the session
export AGENTS_BROWSER_TASK=$(agents browser start --profile my-profile)

# Navigate and interact
agents browser tab add https://example.com
agents browser refs
agents browser click <ref>
agents browser type <ref> "hello"
agents browser screenshot
agents browser done
```

## Profiles

Profiles define browser type and connection endpoint. Create once, reuse across tasks.

```bash
agents browser profiles create local    -b chrome -e cdp://localhost:9222
agents browser profiles create mac-mini -b comet  -e ssh://mac-mini?port=9333
agents browser profiles list
agents browser profiles show <name>
agents browser profiles doctor <name>   # diagnose binary / port / user-data-dir
```

Supported browsers: `chrome`, `comet`, `chromium`, `brave`, `edge`

## Session Lifecycle

```bash
# Start — stdout is the resolved task name; export it so no per-call --task is needed
export AGENTS_BROWSER_TASK=$(agents browser start --profile <profile>)

agents browser status        # list running tasks
agents browser done          # complete task, close tabs, save to history
agents browser stop          # stop without saving to history
```

## Tabs

```bash
agents browser tab add <url>        # open URL in new tab (becomes current)
agents browser tabs                 # list open tabs
agents browser tab focus <tabId>    # switch to tab (by ID, prefix, or URL substring)
agents browser tab close [tabId]    # close specific tab, or all if omitted
agents browser navigate <url>       # navigate current tab in place (no new tab)
```

## DOM Interaction

```bash
agents browser refs                       # interactive element refs for current tab
agents browser refs -t <tabId>            # refs for a specific tab
agents browser click <ref>                # click element
agents browser click <ref> -t <tabId>     # click in specific tab
agents browser type  <ref> "text"         # type into element
agents browser press Enter                # press key (Enter, Tab, Escape, …)
agents browser hover <ref>                # hover over element
agents browser scroll <deltaX> <deltaY>   # scroll page
```

Refs are ephemeral — re-run `refs` after every action.

## Screenshots & Evaluation

```bash
agents browser screenshot                      # capture current tab
agents browser screenshot -t <tabId>           # specific tab
agents browser screenshot -o /tmp/out.png      # save to path

agents browser evaluate "document.title"       # run JS in current tab, return result
agents browser evaluate "..." -t <tabId>       # specific tab
```

`evaluate` calls `Runtime.evaluate` with `awaitPromise: true` — async IIFEs work.

## Console & Errors

```bash
agents browser console                    # all console logs
agents browser console --level error      # only errors
agents browser errors                     # uncaught exceptions
```

## Network Requests

```bash
agents browser requests                         # list captured requests
agents browser requests --filter api            # filter by URL substring
agents browser responsebody "api/data"          # wait for and read a response body
```

## Wait Conditions

```bash
agents browser wait --selector ".loaded"        # wait for element
agents browser wait --url "**/dashboard*"       # wait for URL match
agents browser wait --fn "window.APP_READY"     # wait for JS condition
agents browser wait --state networkidle         # wait for network quiet
agents browser wait --time 2000                 # wait N ms
```

## Downloads

```bash
agents browser download --path /tmp/downloads   # set download directory
agents browser waitdownload                      # wait for download to complete
```

## Viewport

```bash
agents browser set viewport 1280 720            # set viewport size
agents browser set device "iPhone 14"           # emulate device
agents browser devices                           # list available presets
```

## Account Credentials

```bash
eval "$(agents secrets export browser-accounts --plaintext)"
```

Always screenshot first — if the session is still alive in the profile, skip login.

## Rich Text Editors

`type` may fail on contenteditable / ProseMirror. Use evaluate:

```bash
agents browser evaluate 'document.execCommand("insertText", false, "your text")'
```

## Remote Browsers (SSH)

```bash
agents browser profiles create remote-mac -b comet -e ssh://user@hostname?port=9222
export AGENTS_BROWSER_TASK=$(agents browser start --profile remote-mac)
agents browser tab add https://example.com
```

The SSH driver launches the browser on the remote host and tunnels CDP back.

## Workflow Pattern

1. **Create profile** (one-time): `agents browser profiles create …`
2. **Start**: `export AGENTS_BROWSER_TASK=$(agents browser start --profile <name>)`
3. **Open tab**: `agents browser tab add <url>`
4. **Wait** for page to load (`--state networkidle` or `--selector`)
5. **Refs** to see clickable elements
6. **Click / type / press** using refs
7. **Refs** again after each action — refs are ephemeral
8. **Screenshot** liberally — screenshots are your eyes
9. **Console/errors** if something seems wrong
10. **Done**: `agents browser done`
