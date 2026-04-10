# Browser Skill

> Drive any website via CDP — open tabs, click elements, fill forms, take screenshots, download files.

## Architecture

```
Agent (LLM)
  |
  | exec: "openclaw browser open https://example.com --browser-profile paul"
  v
OpenClaw Gateway (Node.js)
  |
  | chromium.connectOverCDP("http://127.0.0.1:18805")
  v
playwright-core (CDP client library)
  |
  | Chrome DevTools Protocol over WebSocket
  v
Chromium-based Browser (e.g. Chrome, Brave, Comet)
  launched with --remote-debugging-port=18805
  user-data-dir per profile
```

**Key distinction:** playwright-core is the CDP client, not the browser. The actual browser is whatever Chromium-based executable is configured (Chrome, Brave, Edge, or any fork). Playwright never downloads or bundles its own browser — it connects to an already-running instance via CDP WebSocket.

## How It Works

### 1. Browser Launch

OpenClaw launches the configured browser executable with CDP flags:

```
/path/to/browser \
  --remote-debugging-port=18805 \
  --user-data-dir=~/.openclaw/browser/paul/user-data
```

This is a real browser in normal mode — not headless, not test mode. Login sessions, cookies, and extensions persist across restarts.

### 2. CDP Connection

When an agent issues a browser command, the gateway connects via playwright-core:

```typescript
import { chromium } from "playwright-core";

const browser = await chromium.connectOverCDP("http://127.0.0.1:18805");
```

The connection is cached and reused. If it drops, the next command reconnects automatically.

### 3. Element Interaction

Agents interact with pages through snapshot-based refs:

1. `snapshot --labels` — returns an accessibility tree with refs like `e1`, `e2`, `e3`
2. `click e5` — resolves the ref to a Playwright role-based locator and clicks it
3. Refs are ephemeral — they change after any page mutation, so agents must re-snapshot before interacting with updated content

### 4. Tab Isolation

Each command targets a specific tab via `targetId` (a CDP target identifier). The workflow:

```bash
openclaw browser open 'https://example.com'    # returns targetId
openclaw browser focus <targetId>               # activate tab
openclaw browser snapshot --labels              # read page
openclaw browser click e3                       # interact
openclaw browser close <targetId>               # cleanup
```

`navigate` is never used because it replaces the active tab — dangerous when multiple workflows run concurrently within the same browser profile.

## Multi-Agent Profile Isolation

The most important architectural decision: **each agent gets its own browser profile**, which means its own browser process, CDP port, and user-data directory.

### The Problem

When multiple agents share a single browser instance, they share tabs. Agent A opens a page, Agent B runs `navigate` or `close`, and Agent A's in-progress work is destroyed. Agents can't reliably track which tabs belong to them because CDP target IDs are ephemeral and tab ordering is nondeterministic.

### The Solution

Assign each agent a dedicated browser profile in `openclaw.json`:

```json
{
  "browser": {
    "executablePath": "/path/to/chrome",
    "profiles": {
      "agent-a": { "cdpPort": 18802 },
      "agent-b": { "cdpPort": 18803 },
      "agent-c": { "cdpPort": 18804 }
    }
  }
}
```

Each profile gets:
- **Its own OS process** — separate PID, separate memory, separate crash domain
- **Its own CDP port** — no WebSocket contention
- **Its own user-data directory** — `~/.openclaw/browser/<profile>/user-data`
- **Its own login sessions** — one agent logging out of a site doesn't affect others

Agents pass `--browser-profile <name>` on every command to target their instance.

### Impact

Before profile isolation, multi-agent browser work was fragile — agents would close each other's tabs, trigger navigations on the wrong tab, and corrupt each other's sessions. With per-agent profiles, each agent operates in complete isolation. The only shared resource is the executable binary itself.

## Observed Reliability

Production metrics from a deployment running multiple concurrent browser-using agents:

| Metric | Value |
|--------|-------|
| Total browser commands | 457 |
| Sessions with browser use | 36 |
| Success rate | **87%** |
| CDP/connection failures | **0** |

Command distribution (from heaviest agent, 431 commands):

| Command | Count | Notes |
|---------|-------|-------|
| `snapshot` | 124 | Most frequent — agents read the page constantly |
| `screenshot` | 70 | Visual verification and polling |
| `evaluate` | 60 | JS evaluation for data extraction |
| `focus` | 35 | Tab switching within the agent's browser |
| `click` | 34 | Element interaction |
| `open` | 32 | New tab creation |
| `close` | 14 | Tab cleanup |
| `download` | 8 | File downloads |
| `wait` | 8 | Waiting for elements/text |
| `type` | 6 | Text input |

### Failure Analysis

All 56 failures (13%) were agent-side usage errors, not transport failures:

- **Stale element refs** — agent clicked `e26` without re-snapshotting after a page mutation
- **Wrong syntax** — `too many arguments for 'snapshot'`
- **Tab not found** — targeting a tab that was already closed

Zero CDP disconnects. Zero connection refused. Zero timeouts at the transport layer. The protocol is stable — failures come from agents not re-snapshotting before interacting with mutated pages.

## Two Modes

The skill supports two browser backends:

| Mode | When to Use |
|------|-------------|
| **Remote browser (OpenClaw)** | Default. Persistent sessions, per-agent profiles, survives agent restarts |
| **Local browser (agent-browser)** | Fallback for local automation without a gateway |

### Remote Browser (OpenClaw)

Commands run via SSH to a gateway host:

```bash
ssh user@gateway "PATH=/opt/homebrew/bin:$PATH openclaw browser open 'https://example.com' --browser-profile agent-a"
```

The gateway manages browser lifecycle, profile routing, and CDP connections. Browser processes persist independently of agent sessions.

### Local Browser (agent-browser)

A daemon-based CLI for local automation:

```bash
agent-browser --executable-path "/path/to/chrome" --profile ~/.agent-browser/profiles/my-skill open "https://example.com" --headed
```

Uses Unix sockets (`~/.agent-browser/*.sock`) for IPC between CLI and daemon. The daemon manages a single browser instance via playwright-core.

## Transport Modes

OpenClaw supports two transport modes, determined by profile configuration:

| Transport | Driver | How It Connects |
|-----------|--------|-----------------|
| **CDP** | `openclaw` (default) | playwright-core connects via `chromium.connectOverCDP()` to the browser's debugging port |
| **Chrome MCP** | `existing-session` | Attaches to an already-running browser via Chrome DevTools MCP server |

Most deployments use CDP transport — it's simpler and gives full control over the browser lifecycle. Chrome MCP is for attaching to a browser you already have open (e.g., your personal Chrome session with existing logins).

## Why This Works Well

**Real browser, not headless.** Sites see a normal browser with normal user agents, cookies, and TLS fingerprints. No Cloudflare blocks, no bot detection.

**Persistent profiles.** Login sessions survive across agent runs. An agent that authenticated to Higgsfield yesterday doesn't need to log in again today.

**Daemon model.** The browser process outlives any individual agent session. No cold-start penalty per command — the WebSocket connection is cached and reused.

**Snapshot-based interaction.** Instead of brittle CSS selectors or XPaths, agents read an accessibility tree and interact via semantic role refs. More resilient to UI changes.

**Profile isolation.** Per-agent browser processes eliminate the entire class of cross-agent interference bugs. Each agent is fully independent.

## Files

```
skills/browser/
  SKILL.md      # Agent-facing instructions (injected into context)
  env.sh        # Environment loader (SSH target, PATH, command prefix)
  README.md     # This file (architecture documentation)
```
