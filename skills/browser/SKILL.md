---
name: browser
description: Drive a browser to automate websites — fill forms, click buttons, take screenshots, scrape pages. Picks among direct CDP, the browser-harness Python lib, the agent-browser CLI, or a remote browser relay depending on what the project has set up.
argument-hint: "[url]"
allowed-tools: Bash(agent-browser*), Bash(python3*), Bash(node*), Bash(sleep*)
user-invocable: true
---

# Browser Automation

Several ways to drive a browser. Pick whichever the project already has set up — they all end up speaking CDP to a real Chrome.

## Pick a tool

| Tool | When |
|------|------|
| **OpenClaw** (Recommended) | Default choice. Use `openclaw browser` commands with `--browser-profile` for per-agent isolation. Best for teams and shared relays. |
| **CDP directly** (Playwright / Puppeteer / raw websocket) | Project already uses Playwright or Puppeteer. Fewest moving parts, full API surface. |
| **[browser-harness](https://github.com/browser-use/browser-harness)** | Preferred for agent-driven workflows. Tiny Python core (~600 lines) on top of CDP, plus an `agent-workspace/` where the agent writes its own site-specific helpers as it learns. Self-healing. |
| **[agent-browser](https://github.com/phnx-labs/agent-browser)** | Single-file CLI wrapper. Good for quick shell-driven tasks; one process per command. |

**Default order to try:** OpenClaw → CDP directly → browser-harness → agent-browser. Stop at the first one the project supports.

Headless vs headed is a per-task choice (passed as a flag or option), not a property of the skill. Pick headed when you need to see the page, watch a flow, or debug; headless for unattended scrapes and CI.

## Account Credentials

Before navigating to any site that requires a login, load the `browser-accounts` bundle:

```bash
eval "$(agents secrets export browser-accounts --plaintext)"
```

This injects credentials as shell variables. Known accounts:

| Service | Username variable | Password variable |
|---------|------------------|------------------|
| Grafana (getrush.grafana.net) | `$GRAFANA_USERNAME` | `$GRAFANA_PASSWORD` |
| Cloudflare | `$CLOUDFLARE_USERNAME` | `$CLOUDFLARE_PASSWORD` |
| Supabase | `$SUPABASE_USERNAME` | `$SUPABASE_PASSWORD` |

Always snapshot the page first — if the session is still alive in the profile, skip login entirely. Only log in when you land on a login wall.

```bash
eval "$(agents secrets export browser-accounts --plaintext)"
openclaw browser open 'https://grafana.com/auth/sign-in' --browser-profile claude-infra
# focus, snapshot, then:
openclaw browser type <email-ref> "$GRAFANA_USERNAME"
openclaw browser type <password-ref> "$GRAFANA_PASSWORD"
openclaw browser press Enter
```

## OpenClaw (Recommended)

OpenClaw provides a browser relay with per-agent profile isolation. Each agent gets its own browser process, cookies, and login sessions.

```bash
# Check if OpenClaw is available
which openclaw

# Basic usage
openclaw browser open <url> --browser-profile <your-profile>
openclaw browser snapshot --labels
openclaw browser click <ref>
openclaw browser type <ref> 'text'
openclaw browser screenshot
openclaw browser close <targetId>
```

**Always use `--browser-profile <your-profile>`** on every command. Each agent has a dedicated profile with its own login sessions. Omitting the flag uses the default profile, which may not have the required logins.

**Tab discipline for teams:**
- `open` a new tab; never `navigate` (it replaces whatever tab is active and trashes another agent's state).
- `focus` your tab before every interaction.
- `close` your tab when you're done.

## Direct CDP (Playwright / Puppeteer)

If the repo has Playwright or Puppeteer in `package.json` / `requirements.txt`, just use it.

```python
# Playwright (Python)
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)   # headless=False to watch
    page = browser.new_page()
    page.goto("https://example.com")
    page.screenshot(path="out.png")
    browser.close()
```

```javascript
// Playwright (Node)
const { chromium } = require('playwright');
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
await page.goto('https://example.com');
await page.screenshot({ path: 'out.png' });
await browser.close();
```

Use this when the project already standardizes on it. Don't introduce Playwright/Puppeteer just for an ad-hoc task.

## browser-harness

[browser-use/browser-harness](https://github.com/browser-use/browser-harness) — tiny CDP harness designed to be driven by an LLM. Install per its README. Once set up:

- Core lives in `src/browser_harness/` (don't edit).
- The agent writes site-specific helpers into `agent-workspace/agent_helpers.py` and `agent-workspace/domain-skills/<site>/`.
- Each helper captures a real browser workflow with the actual selectors observed at runtime.
- `SKILL.md` in the harness repo has the standard usage patterns.

When using it, follow the harness's own SKILL.md for command shape — that file is the source of truth, and it evolves.

## agent-browser CLI

[phnx-labs/agent-browser](https://github.com/phnx-labs/agent-browser) — a single-binary CLI for one-shot browser steps from the shell.

```bash
# Open and interact (headless by default; pass --headed when you need to see it)
agent-browser open <url>
agent-browser snapshot --labels             # element refs for click/type
agent-browser click <ref>
agent-browser type <ref> 'text'
agent-browser screenshot                    # capture viewport
agent-browser eval --fn '() => document.title'
agent-browser wait --text "Done"
```

Profiles persist cookies/logins between runs — name the profile after the skill that drives it:

```bash
agent-browser \
  --profile ~/.agent-browser/profiles/<skill-name> \
  open "<URL>"
```

For sites that block default Chromium, point at real Chrome:

```bash
--executable-path "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
```

## Remote browser relay (optional)

Some teams run a relay so the browser lives on a server (persistent sessions, shared logins, Cloudflare-friendly IP). The interface looks the same — `open`, `focus`, `snapshot`, `click`, `screenshot` — but tab discipline matters because multiple agents share one browser:

- `open` a new tab; never `navigate` (it replaces whatever tab is active and trashes another agent's state).
- `focus` your tab before every interaction.
- `close` your tab when you're done.

Only use a relay if the project documents one. Don't reach for it as a default.

## Workflow pattern (any tool)

1. **Open** the target URL.
2. **Snapshot** to see structure and get refs.
3. **Click / type / select** using refs from the snapshot.
4. **Re-snapshot** after every action — refs are ephemeral.
5. **Screenshot** liberally; screenshots are your eyes.
6. Close the tab/browser when done.

## Rich text editors

`type` typically fails on contenteditable / ProseMirror. Use `execCommand('insertText')` via the tool's eval / evaluate primitive:

```bash
# agent-browser
agent-browser eval --fn '() => document.execCommand("insertText", false, "your text")'
```

```python
# Playwright
page.evaluate('() => document.execCommand("insertText", false, "your text")')
```

## Site-specific skills first

If a skill exists for the target site (e.g. `linear`, `higgsfield`, etc.), read it before driving the page raw — it'll already encode the selectors and known quirks.
