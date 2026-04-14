---
name: hermes
description: "Deploy, configure, and manage Hermes Agent gateway and Workspace. Triggers on: setting up Hermes, deploying Hermes on k8s, configuring Hermes gateway, creating Hermes agents, Hermes Workspace issues, or any Hermes Agent question."
---

# Hermes Agent — Gateway & Workspace Management

Hermes Agent is an open-source AI agent framework by Nous Research. It provides a gateway for messaging platforms (Telegram, Discord, Slack, etc.), an OpenAI-compatible API server, skills, memory, and cron scheduling.

**Official docs:** https://hermes-agent.nousresearch.com/docs/
**Official repo:** https://github.com/NousResearch/hermes-agent
**Enhanced fork (required for full Workspace):** https://github.com/outsourc-e/hermes-agent
**Workspace repo:** https://github.com/outsourc-e/hermes-workspace

**Before making any changes, check the official docs.** Hermes changes fast — verify commands, env vars, and image tags against current documentation.

## Architecture Overview

Hermes has two main components:

1. **Hermes Gateway** — the agent runtime. Handles LLM calls, tool execution, messaging platforms, cron jobs, skills, and memory. Exposes an OpenAI-compatible API server on port 8642.
2. **Hermes Workspace** — a separate web UI that connects to the gateway. Provides chat, file browser, terminal, skills browser, memory editor, and session management.

```
Browser --> Hermes Workspace (Node.js, port 3000)
                |
                | HERMES_API_URL + HERMES_API_TOKEN
                v
            Hermes Gateway (Python, port 8642)
                |
                | OPENROUTER_API_KEY / ANTHROPIC_API_KEY / etc.
                v
            LLM Provider (OpenRouter, Anthropic, OpenAI Codex, etc.)
```

## Critical: Which Image to Use

| Image | What | Enhanced APIs |
|-------|------|--------------|
| `nousresearch/hermes-agent:latest` | Official image. Chat + messaging + cron work. | NO — Skills, Memory, Sessions, Config pages show "not available" in Workspace |
| `outsourc-e/hermes-agent` (build from source) | Enhanced fork. Full Workspace support. | YES — all Workspace features work |

**If you want the Workspace to fully work (Skills, Memory, Sessions, Config), you MUST use the `outsourc-e/hermes-agent` fork.** The official image only supports "portable mode" (basic chat).

### Building the Enhanced Image

No pre-built Docker image exists for the fork. Build from source:

```dockerfile
FROM python:3.11-slim
RUN apt-get update && apt-get install -y curl git && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/outsourc-e/hermes-agent.git /app
WORKDIR /app
RUN pip install --no-cache-dir -e .
EXPOSE 8642
CMD ["hermes", "gateway", "run"]
```

### Building the Workspace Image

No pre-built Docker image exists. Download and build:

```bash
curl -sL https://github.com/outsourc-e/hermes-workspace/archive/refs/heads/main.tar.gz | tar xz
cd hermes-workspace-main
docker build -t hermes-workspace:latest .
```

## Gateway Configuration

### Environment Variables

| Env Var | Required | Purpose |
|---------|----------|---------|
| `API_SERVER_ENABLED` | Yes | Must be `true` to start the HTTP API server |
| `API_SERVER_HOST` | Yes | `0.0.0.0` for network access (default: `127.0.0.1`) |
| `API_SERVER_KEY` | Yes (when HOST=0.0.0.0) | Bearer token for API auth. Gateway REFUSES to start without it when binding to non-loopback |
| `API_SERVER_PORT` | No | Default: `8642` |
| `API_SERVER_CORS_ORIGINS` | No | Comma-separated CORS origins |
| `OPENROUTER_API_KEY` | One LLM key required | OpenRouter API key |
| `ANTHROPIC_API_KEY` | One LLM key required | Anthropic API key |

### Model Configuration

Models are configured in `~/.hermes/config.yaml` inside the container, NOT via env vars:

```yaml
model:
  provider: "openrouter"      # openrouter, anthropic, openai-codex, gemini, etc.
  default: "moonshotai/kimi-k2.5"  # model ID (no provider prefix when using openrouter)
```

**`LLM_MODEL` and similar env vars do NOT work for the main model.** Config.yaml is the only way.

### OpenAI Codex Authentication

To use `openai-codex` as the provider (requires ChatGPT Pro/Plus account):

```bash
hermes auth add openai-codex --type oauth --no-browser --timeout 300
```

This prints a device code URL + code. Open the URL in your browser, enter the code. OpenAI rate-limits the device code endpoint aggressively — don't retry more than once every 5 minutes.

### Command Syntax

The enhanced fork may not accept `["hermes", "gateway", "run"]` as a direct container command array. Use a shell wrapper instead:

```yaml
command: ["/bin/sh", "-c", "hermes gateway run"]
```

## Workspace Configuration

### Environment Variables

| Env Var | Required | Purpose |
|---------|----------|---------|
| `HERMES_API_URL` | Yes | Gateway URL (e.g., `http://hermes-gateway:8642`) |
| `HERMES_API_TOKEN` | Yes (if gateway has API_SERVER_KEY) | Bearer token. **MUST match gateway's `API_SERVER_KEY`** |
| `HERMES_PASSWORD` | No | Password to protect the Workspace web UI |
| `PORT` | No | Default: `3000` |

**CRITICAL:** The env var is `HERMES_API_TOKEN`, NOT `OPENAI_API_KEY`, NOT `API_SERVER_KEY`, NOT `BEARER_TOKEN`. Only `HERMES_API_TOKEN` works. Defined in Workspace source at `src/server/gateway-capabilities.ts`.

## Workspace Connection Modes

The Workspace probes the gateway at startup and determines the mode:

| Mode | APIs Available | What Works |
|------|---------------|------------|
| `disconnected` | None | Nothing — setup screen shown |
| `portable` | health, chatCompletions, models, streaming | Chat only. Skills/Memory/Sessions show "not available" |
| `enhanced-hermes` | All above + sessions, enhancedChat, skills, memory, config, jobs | Everything works |

**To get `enhanced-hermes` mode, you MUST use the `outsourc-e/hermes-agent` fork.**

## Nginx Reverse Proxy

### For Workspace (NO WebSocket headers)

The Workspace is a standard Node.js HTTP server. Do NOT add WebSocket `Upgrade`/`Connection` headers — Node.js `undici` crashes with `invalid connection header` when receiving forwarded hop-by-hop headers.

```nginx
server {
    server_name hermes.example.com;
    location / {
        proxy_pass http://<workspace-ip>:<port>;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### For Gateway (direct access, if exposed)

If exposing the gateway directly behind nginx, WebSocket headers are fine since the gateway handles them natively.

## Kubernetes Deployment Notes

### Use Recreate Strategy

Always use `strategy: Recreate` for Hermes deployments with persistent volumes. `RollingUpdate` with RWO (ReadWriteOnce) volumes causes a deadlock: the new pod waits for the volume, the old pod holds the volume until the new pod is ready.

### Volume Considerations

- Use `emptyDir` if you don't need persistent data across restarts (skills, sessions, memory reset on restart)
- Use a PVC with `Recreate` strategy if you want persistent data
- If using Longhorn or similar CSI with RWO volumes, expect Multi-Attach errors during rollouts — `Recreate` strategy avoids this

### Private Registry Images

Images built with Docker aren't automatically available to containerd (used by k8s). Either:
- Push to a registry all nodes can pull from
- Import directly: `docker save <image> | sudo ctr -n k8s.io images import -`
- Use `imagePullPolicy: IfNotPresent` and schedule on the node that has the image

## Gotchas

1. **API_SERVER_KEY is required for 0.0.0.0** — Gateway refuses to start the API server without a key when binding to non-loopback. Fails silently (logs a warning, skips API server).

2. **`HERMES_API_TOKEN` not `OPENAI_API_KEY`** — The Workspace reads `HERMES_API_TOKEN` specifically. Other env var names do nothing.

3. **Config.yaml is the only way to set the model** — No env var works for the main model.

4. **OpenRouter model IDs have no prefix** — Use `moonshotai/kimi-k2.5`, not `openrouter/moonshotai/kimi-k2.5`.

5. **Enhanced fork command syntax** — Use `["/bin/sh", "-c", "hermes gateway run"]` instead of `["hermes", "gateway", "run"]`.

6. **Nginx WebSocket headers crash the Workspace** — Node.js undici rejects `Connection: upgrade` forwarded headers. Don't add WebSocket config to the Workspace nginx block.

7. **Workspace setup screen shows "HTTP 401"** — This means either: (a) `HERMES_API_TOKEN` is not set or doesn't match `API_SERVER_KEY`, or (b) the gateway API server isn't running (check logs for "Refusing to start").

8. **"Skills not available" in Workspace** — You're using the official `nousresearch/hermes-agent` image which only supports portable mode. Switch to the `outsourc-e/hermes-agent` fork.
