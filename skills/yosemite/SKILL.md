---
name: yosemite
description: "Deploy and manage OpenClaw agent instances on the Yosemite k8s cluster (427yosemite.com). Triggers on: new employee OpenClaw setup, k8s agent deployment, yosemite cluster, per-engineer agent, or adding a new OpenClaw instance."
---

# Yosemite -- Per-Engineer OpenClaw Deployments

Internal playbook for deploying OpenClaw agent instances on the Yosemite k8s cluster. Every employee gets their own OpenClaw -- their own Telegram bot, browser, workspace, and model.

For OpenClaw configuration and workspace file management, see the `openclaw` skill. This skill covers the infrastructure side: k8s resources, DNS, TLS, browser sidecar, and first-boot setup.

- - -

## What Each Employee Gets

An OpenClaw instance is a personal AI agent gateway. It gives each team member:

- **Telegram bot** -- a dedicated bot they message to interact with their agent
- **Headless browser** -- Chrome sidecar for web research, form filling, screenshots
- **Persistent workspace** -- AGENTS.md, SOUL.md, IDENTITY.md, memory, skills on a PVC
- **LLM access** -- model of their choice (OpenAI Codex, OpenRouter, etc.)
- **Custom skills** -- 42+ company skills loaded onto their instance

### What They Can Hand Off to Their Agent

| Category | Examples |
|----------|---------|
| Research | Look up a company, person, technology. Summarize a paper. Find competitors. |
| Writing | Draft emails, blog posts, LinkedIn posts, docs. Edit and refine copy. |
| Browsing | Fill out forms, check websites, take screenshots, monitor pages. |
| Analysis | Compare options, summarize data, evaluate tradeoffs. |
| Code help | Explain code, suggest fixes, review PRs (read-only). |
| Coordination | Check Linear tasks, summarize status, draft updates. |
| Content | Create outreach emails, cold email research, social media drafts. |

The agent runs 24/7 on k8s. They message it on Telegram whenever they need something done.

- - -

## Architecture

```
Internet -> Cloudflare (proxied CNAME)
         -> yosemite-m0 nginx (TLS termination, Let's Encrypt)
         -> k8s LoadBalancer IP (MetalLB, LAN)
         -> Pod: [OpenClaw container + Chrome sidecar]
                  |
                  +-- PVC: workspace, skills, memory, auth
                  +-- ConfigMap: openclaw.json
                  +-- Secret: API keys
```

**Domain pattern:** `openclaw-{name}.427yosemite.com`

All instances share the same Cloudflare zone (`427yosemite.com`), same nginx host (`yosemite-m0`), and same k8s cluster (`spark`). Each gets its own:
- k8s Deployment + Service + PVC + ConfigMap + Secret
- DNS CNAME record
- Nginx server block + Let's Encrypt cert
- Telegram bot
- MetalLB LoadBalancer IP (auto-assigned from `home-pool`)

- - -

## Existing Instances

| Owner | Domain | Bot | LB IP |
|-------|--------|-----|-------|
| Company (Phoenix) | openclaw.427yosemite.com | @XavierTrpBot | 192.168.1.245 |
| Muqsit | openclaw-muqsit.427yosemite.com | @SamaTrpBot | 192.168.1.253 |
| Bisma | openclaw-bisma.427yosemite.com | @BismaTrpBot | (auto) |

- - -

## Deployment Playbook

### Prerequisites

Before starting, you need:
- A Telegram bot token (employee creates via @BotFather)
- The employee's Telegram user ID (they can get it from @userinfobot)
- SSH access to `spark` (k8s control plane) and `yosemite-m0` (nginx)
- Access to Cloudflare DNS for `427yosemite.com`

### Step 1: Create K8s Resources

All resources use the naming convention `openclaw-{name}`.

**Secret** (for API keys):
```bash
ssh muqsit@spark "kubectl create secret generic openclaw-{name}-secret \
  --from-literal=openrouter-api-key='sk-or-v1-...' \
  2>/dev/null"
```

**ConfigMap** (openclaw.json):
```bash
ssh muqsit@spark "kubectl create configmap openclaw-{name}-config \
  --from-literal=openclaw.json='{
  \"gateway\": {
    \"port\": 18789,
    \"bind\": \"lan\",
    \"auth\": { \"mode\": \"token\" },
    \"controlUi\": {
      \"allowedOrigins\": [\"https://openclaw-{name}.427yosemite.com\"]
    }
  },
  \"env\": {
    \"OPENROUTER_API_KEY\": \"sk-or-v1-...\"
  },
  \"auth\": {
    \"profiles\": {
      \"openai-codex:default\": {
        \"provider\": \"openai-codex\",
        \"mode\": \"oauth\"
      }
    }
  },
  \"channels\": {
    \"telegram\": {
      \"enabled\": true,
      \"botToken\": \"{BOT_TOKEN}\",
      \"dmPolicy\": \"pairing\",
      \"allowFrom\": [\"{TELEGRAM_USER_ID}\"]
    }
  },
  \"bindings\": [
    {
      \"agentId\": \"{name}\",
      \"match\": { \"channel\": \"telegram\", \"accountId\": \"default\" }
    }
  ],
  \"agents\": {
    \"list\": [
      {
        \"id\": \"{name}\",
        \"name\": \"{name}\",
        \"workspace\": \"/home/node/.openclaw/workspace\"
      }
    ],
    \"defaults\": {
      \"model\": \"openrouter/moonshotai/kimi-k2.6\"
    }
  },
  \"browser\": {
    \"enabled\": true,
    \"ssrfPolicy\": { \"dangerouslyAllowPrivateNetwork\": true },
    \"defaultProfile\": \"{name}\",
    \"remoteCdpTimeoutMs\": 2000,
    \"remoteCdpHandshakeTimeoutMs\": 4000,
    \"profiles\": {
      \"{name}\": {
        \"cdpUrl\": \"ws://localhost:3000?token=openclaw-browser\",
        \"color\": \"#00AA00\"
      }
    }
  }
}' 2>/dev/null"
```

**PVC** (10Gi persistent workspace):
```bash
ssh muqsit@spark "kubectl apply -f - <<'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: openclaw-{name}-data
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: longhorn
  resources:
    requests:
      storage: 10Gi
EOF"
```

**Deployment + Service** (OpenClaw + Chrome sidecar):
```bash
ssh muqsit@spark "kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: openclaw-{name}
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: openclaw-{name}
  template:
    metadata:
      labels:
        app: openclaw-{name}
    spec:
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
      imagePullSecrets:
        - name: registry-creds
      containers:
        - name: openclaw
          image: ghcr.io/openclaw/openclaw:latest
          imagePullPolicy: Always
          ports:
            - name: http
              containerPort: 18789
          env:
            - name: OPENCLAW_GATEWAY_TOKEN
              value: \"{GATEWAY_TOKEN}\"
            - name: OPENROUTER_API_KEY
              valueFrom:
                secretKeyRef:
                  name: openclaw-{name}-secret
                  key: openrouter-api-key
          volumeMounts:
            - name: openclaw-data
              mountPath: /home/node/.openclaw
            - name: openclaw-config
              mountPath: /home/node/.openclaw/openclaw.json
              subPath: openclaw.json
          resources:
            requests:
              cpu: 250m
              memory: 512Mi
            limits:
              cpu: \"1\"
              memory: 2Gi
          livenessProbe:
            httpGet:
              path: /healthz
              port: 18789
            initialDelaySeconds: 30
            periodSeconds: 30
          readinessProbe:
            httpGet:
              path: /readyz
              port: 18789
            initialDelaySeconds: 15
            periodSeconds: 10
        - name: browser
          image: ghcr.io/browserless/chromium:latest
          imagePullPolicy: Always
          ports:
            - name: cdp
              containerPort: 3000
          env:
            - name: TIMEOUT
              value: \"600000\"
            - name: CONCURRENT
              value: \"5\"
            - name: TOKEN
              value: \"openclaw-browser\"
          resources:
            requests:
              cpu: 250m
              memory: 512Mi
            limits:
              cpu: \"1\"
              memory: 2Gi
      volumes:
        - name: openclaw-data
          persistentVolumeClaim:
            claimName: openclaw-{name}-data
        - name: openclaw-config
          configMap:
            name: openclaw-{name}-config
--- # service
apiVersion: v1
kind: Service
metadata:
  name: openclaw-{name}
spec:
  type: LoadBalancer
  selector:
    app: openclaw-{name}
  ports:
    - name: http
      port: 80
      targetPort: 18789
YAML"
```

**Important notes:**
- Use `ghcr.io/openclaw/openclaw:latest` (upstream image). Custom images hit `ImagePullBackOff` on `spark-s1` due to registry auth issues.
- Strategy must be `Recreate` (not RollingUpdate) because the PVC is `ReadWriteOnce`.
- Generate a random `GATEWAY_TOKEN` (e.g., `openssl rand -hex 13`).
- `securityContext` with uid/gid 1000 matches the `node` user inside the OpenClaw container.

### Step 2: DNS (Cloudflare)

Add a CNAME record in the `427yosemite.com` zone:

| Type | Name | Target | Proxy |
|------|------|--------|-------|
| CNAME | `openclaw-{name}` | `openclaw.427yosemite.com` | Proxied (orange cloud) |

All OpenClaw subdomains CNAME to the original `openclaw.427yosemite.com` which has the A record pointing to the public IP. Cloudflare's Universal SSL covers `*.427yosemite.com`.

Can be done via Cloudflare dashboard or the `openclaw browser` on mac-mini.

### Step 3: Nginx + TLS (yosemite-m0)

Get the LoadBalancer IP assigned by MetalLB:
```bash
ssh muqsit@spark "kubectl get svc openclaw-{name} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
```

Create nginx config and get Let's Encrypt cert:
```bash
ssh muqsit@yosemite-m0 "sudo bash -c '
cat > /etc/nginx/sites-available/openclaw-{name}.427yosemite.com << \"NGINX\"
server {
    server_name openclaw-{name}.427yosemite.com;
    location / {
        proxy_pass http://{LB_IP}:80;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \"upgrade\";
        proxy_read_timeout 3600s;
    }
}
NGINX
ln -sf /etc/nginx/sites-available/openclaw-{name}.427yosemite.com /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
'"

# Get TLS cert
ssh muqsit@yosemite-m0 "sudo certbot --nginx -d openclaw-{name}.427yosemite.com \
  --non-interactive --agree-tos -m muqsit@getrush.ai"
```

**Critical:** The nginx config MUST include WebSocket upgrade headers (`Upgrade`, `Connection "upgrade"`) and a long `proxy_read_timeout` (3600s). Without these, Telegram polling and agent sessions break.

### Step 4: Wait for Pod + Copy Skills

The PVC mount overlays the image's baked-in `/home/node/.openclaw/skills/` directory. Skills must be copied to the PVC manually.

```bash
# Wait for pod
ssh muqsit@spark "kubectl rollout status deployment/openclaw-{name} --timeout=120s"

# Get pod name
POD=$(ssh muqsit@spark "kubectl get pods -l app=openclaw-{name} -o jsonpath='{.items[0].metadata.name}'")

# Copy skills tarball (pre-staged on spark from a previous deployment)
ssh muqsit@spark "kubectl cp /tmp/openclaw-skills.tar.gz default/$POD:/tmp/skills.tar.gz -c openclaw && \
  kubectl exec $POD -c openclaw -- sh -c 'cd /home/node/.openclaw && tar xzf /tmp/skills.tar.gz && rm /tmp/skills.tar.gz' && \
  kubectl exec $POD -c openclaw -- sh -c 'ls /home/node/.openclaw/skills/ | wc -l'"
```

If the skills tarball isn't on spark, create it from mac-mini first:
```bash
ssh muqsit@mac-mini "tar czf /tmp/openclaw-skills.tar.gz -C ~/.openclaw skills/"
scp muqsit@mac-mini:/tmp/openclaw-skills.tar.gz muqsit@spark:/tmp/
```

### Step 5: Create Workspace Files

Create the agent's identity. These files are injected into every session.

```bash
POD=$(ssh muqsit@spark "kubectl get pods -l app=openclaw-{name} -o jsonpath='{.items[0].metadata.name}'")

# Create memory directory
ssh muqsit@spark "kubectl exec $POD -c openclaw -- mkdir -p /home/node/.openclaw/workspace/memory"
```

Then copy workspace files to the pod. Each agent needs at minimum:

| File | Purpose | Required |
|------|---------|----------|
| IDENTITY.md | Name, role, personality summary | Yes |
| SOUL.md | Communication style, values, boundaries | Yes |
| AGENTS.md | Operating instructions, what the agent does | Yes |
| USER.md | Who the human is, their context | Yes |
| TOOLS.md | Environment notes (k8s, browser, model) | Yes |
| HEARTBEAT.md | Monitoring checklist (empty = skip) | Yes |
| MEMORY.md | Long-term memory index | Yes |
| BOOT.md | Startup checklist | Optional |

Write these locally, then `kubectl cp` them in:
```bash
kubectl cp /tmp/{name}-identity.md default/$POD:/home/node/.openclaw/workspace/IDENTITY.md -c openclaw
# ... repeat for each file
```

### Step 6: Fix Device Auth Scopes

After first boot, the gateway creates a device with `operator.read` scope only. Telegram needs `operator.approvals` to function. Without this fix, Telegram enters a "pairing required" loop.

```bash
ssh muqsit@spark "kubectl exec $POD -c openclaw -- python3 -c '
import json
# Fix paired.json
with open(\"/home/node/.openclaw/devices/paired.json\") as f:
    d = json.load(f)
for did, dev in d.items():
    dev[\"scopes\"] = [\"operator.read\", \"operator.approvals\", \"operator.write\"]
    dev[\"approvedScopes\"] = [\"operator.read\", \"operator.approvals\", \"operator.write\"]
    dev[\"tokens\"][\"operator\"][\"scopes\"] = [\"operator.read\", \"operator.approvals\", \"operator.write\"]
with open(\"/home/node/.openclaw/devices/paired.json\", \"w\") as f:
    json.dump(d, f, indent=2)
# Fix device-auth.json
with open(\"/home/node/.openclaw/identity/device-auth.json\") as f:
    d = json.load(f)
for role, tok in d[\"tokens\"].items():
    tok[\"scopes\"] = [\"operator.read\", \"operator.approvals\", \"operator.write\"]
with open(\"/home/node/.openclaw/identity/device-auth.json\", \"w\") as f:
    json.dump(d, f, indent=2)
print(\"Scopes fixed\")
'"
```

Then restart the deployment:
```bash
ssh muqsit@spark "kubectl rollout restart deployment/openclaw-{name}"
```

### Step 7: Set Telegram Bot Profile

Set the bot's name, description, and profile photo via the Bot API:

```bash
BOT_TOKEN="{bot_token}"

# Set description
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/setMyDescription" \
  -d "description=Personal AI agent for {Name}. Research, writing, browsing, analysis."

# Set short description
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/setMyShortDescription" \
  -d "short_description={Name}'s AI agent"

# Set profile photo (must be a local file)
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/setMyProfilePhoto" \
  -F 'photo={"type":"static","photo":"attach://file"}' \
  -F "file=@/tmp/avatar.jpg;type=image/jpeg"
```

### Step 8: Verify

```bash
# Health check
curl -s "https://openclaw-{name}.427yosemite.com/healthz"
# Expected: {"ok":true,"status":"live"}

# Pod status (should be 2/2 Running)
ssh muqsit@spark "kubectl get pods -l app=openclaw-{name}"

# Check logs for errors
ssh muqsit@spark "kubectl logs -l app=openclaw-{name} -c openclaw --tail=20"

# Verify Chrome sidecar
ssh muqsit@spark "kubectl logs -l app=openclaw-{name} -c browser --tail=5"

# Verify Telegram connected (look for "[telegram] [default] starting provider")
ssh muqsit@spark "kubectl logs -l app=openclaw-{name} -c openclaw --tail=20 | grep telegram"
```

Then message the bot on Telegram. It should respond.

### Step 9: Copy Model Auth (if using OpenAI Codex)

OpenAI Codex uses OAuth, not API keys. Copy the auth profile from mac-mini:

```bash
# Copy from mac-mini's main agent
ssh muqsit@mac-mini "cat ~/.openclaw/agents/main/agent/auth-profiles.json" | \
  ssh muqsit@spark "kubectl exec -i $POD -c openclaw -- sh -c 'mkdir -p /home/node/.openclaw/agents/{name}/agent && cat > /home/node/.openclaw/agents/{name}/agent/auth-profiles.json'"

ssh muqsit@mac-mini "cat ~/.openclaw/agents/main/agent/models.json" | \
  ssh muqsit@spark "kubectl exec -i $POD -c openclaw -- sh -c 'cat > /home/node/.openclaw/agents/{name}/agent/models.json'"
```

These files persist on the PVC across restarts.

- - -

## Troubleshooting

### "pairing required" loop in logs

Device scopes are too narrow. Run the Step 6 fix above.

### ImagePullBackOff on spark-s1

The private registry creds don't work on `spark-s1` for custom images. Use the upstream image `ghcr.io/openclaw/openclaw:latest` instead.

### Skills missing (count = 0)

The PVC mount at `/home/node/.openclaw/` overlays the image's baked-in skills. Re-copy skills to the PVC (Step 4).

### Telegram bot not responding

Check logs for:
- `[telegram] [default] starting provider (@BotName)` -- good, connected
- `pairing required` -- scope issue (Step 6)
- `ETIMEDOUT` -- DNS issue in the pod, usually resolves with IPv4 fallback
- `incomplete turn detected... payloads=0` -- model returning empty responses, switch model

### Browser not working

Verify the sidecar is running:
```bash
ssh muqsit@spark "kubectl exec $POD -c openclaw -- \
  curl -s -H 'Authorization: Bearer openclaw-browser' http://localhost:3000/json/version"
```

Should return Chrome version info. If "Bad or missing authentication", the TOKEN env var on the browser container doesn't match the `cdpUrl` token in the config.

### Model errors

Check what model is configured:
```bash
ssh muqsit@spark "kubectl logs -l app=openclaw-{name} -c openclaw --tail=20 | grep 'agent model'"
```

For OpenAI Codex: auth-profiles.json must exist at `/home/node/.openclaw/agents/{name}/agent/`. For OpenRouter: just needs the API key in env.

- - -

## Resource Costs

Each instance uses:
- **CPU:** 500m request, 2 cores limit (openclaw + browser)
- **Memory:** 1Gi request, 4Gi limit (openclaw + browser)
- **Storage:** 10Gi PVC (Longhorn replicated)
- **Network:** 1 MetalLB IP from home-pool

At ~10 instances, this is ~5 cores, 10Gi RAM, 100Gi storage. Well within cluster capacity.

- - -

## Naming Conventions

| Resource | Pattern | Example |
|----------|---------|---------|
| Domain | `openclaw-{name}.427yosemite.com` | `openclaw-bisma.427yosemite.com` |
| Deployment | `openclaw-{name}` | `openclaw-bisma` |
| Service | `openclaw-{name}` | `openclaw-bisma` |
| PVC | `openclaw-{name}-data` | `openclaw-bisma-data` |
| ConfigMap | `openclaw-{name}-config` | `openclaw-bisma-config` |
| Secret | `openclaw-{name}-secret` | `openclaw-bisma-secret` |
| Nginx config | `/etc/nginx/sites-available/openclaw-{name}.427yosemite.com` | |
| Telegram bot | `@{Name}TrpBot` | `@BismaTrpBot` |

`{name}` is always lowercase, no special characters. Matches the person's first name.

- - -

## Updating docs/TEAM_INFRA.md

After adding a new instance, update the table in `docs/TEAM_INFRA.md` under "OpenClaw (Per-Engineer)":

```markdown
| {Name} | openclaw-{name}.427yosemite.com |
```
