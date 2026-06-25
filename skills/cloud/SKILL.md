---
name: cloud
description: "Dispatch and manage agent tasks in the cloud across providers — Rush Cloud (GitHub repo + branch, auto-opens a PR), Codex Cloud (pre-built env), and Factory pods (Droid + computer-use). Covers run, list, status, logs, message, cancel, providers. Triggers on: 'cloud run', 'dispatch to the cloud', 'rush cloud', 'codex cloud', 'run an agent in the cloud', 'cloud task', 'agents cloud'."
argument-hint: "<prompt> --provider rush|codex|factory [--repo owner/repo | --env <id>]"
allowed-tools: Bash(agents cloud*)
user-invocable: true
---

# Cloud Skill

Dispatch a task to a cloud agent instead of running it locally. Where `agents run` executes on this machine, `agents cloud run` hands the work to a remote backend that clones the repo, runs the agent, and (for Rush) opens a PR. Use it to fan out many tasks past local capacity, or to run work that needs a clean, pre-built environment.

## Providers

| Provider | What it is | Dispatch needs | PR? | Multi-repo |
|----------|-----------|----------------|-----|------------|
| `rush` (default) | Rush Cloud — clones a GitHub repo + branch, runs the agent, auto-commits and opens a PR | `--repo owner/repo` | yes | yes |
| `codex` | Codex Cloud — runs in a pre-built Codex environment (repos fixed at env-creation time) | `--env <id>` | per env | no |
| `factory` | Factory pods — Droid + computer-use targets | `--computer <name>` | n/a | no |

Check what's signed in before dispatching:

```bash
agents cloud providers              # human-readable
agents cloud providers --json       # {id, name, available, default}
```

`available: false` means that backend isn't signed in on this machine — pick another or authenticate first.

## Dispatch

```bash
agents cloud run "<prompt>" --provider <id> [options]
```

The prompt can be inline (positional), via `-p/--prompt`, or a path to a file whose contents become the prompt.

| Flag | Purpose |
|------|---------|
| `--provider <id>` | `rush`, `codex`, or `factory` (defaults to the configured default) |
| `--agent <name>` | Agent to run: `claude`, `codex`, `droid` |
| `--repo <owner/repo>` | GitHub repo. Repeatable for multi-repo (Rush only) |
| `--branch <name>` | Target git branch |
| `-p, --prompt <text>` | Inline prompt (alternative to the positional arg) |
| `--env <id>` | Codex Cloud environment ID (required for `--provider codex`) |
| `--computer <name>` | Factory/Droid computer target |
| `--model <model>` | Model override |
| `--mode <mode>` | Execution mode (`plan`, `edit`, `full`) |
| `--timeout <dur>` | Kill after a duration (`30m`, `2h`) |
| `-b, --balanced` | Route a factory run across all healthy accounts |
| `--strategy balanced` | Account selection strategy (factory) |
| `--upload-account-tokens` | Consent to upload Claude OAuth creds to Rush Cloud (first dispatch) |
| `--json` | Structured JSON output |
| `--no-follow` | Dispatch and exit without streaming (returns the task id) |

## Rush Cloud

Runs against a GitHub repo and opens a PR with the result.

```bash
# Dispatch and stream the output
agents cloud run "fix the flaky e2e in apps/web/tests/checkout.spec.ts" \
  --provider rush --repo acme/example --branch main

# Fire-and-forget — returns the task id, no streaming
agents cloud run "bump tailwind to v4 and fix the breaks" \
  --provider rush --repo acme/example --no-follow

# Multi-repo: cloned into /workspace/<owner>/<name>/ each
agents cloud run "rename POST /v1/charge -> /v2/charge across server + extension" \
  --provider rush --repo acme/example --repo acme/example-extension
```

**Token-upload consent.** On first dispatch (or after your Claude token rotates) Rush Cloud asks to sync your Claude OAuth credentials (accessToken + refreshToken) to its API so the pods can act as your Anthropic account:

```bash
agents cloud run "..." --provider rush --repo acme/example --upload-account-tokens
# or:  AGENTS_RUSH_UPLOAD_TOKENS=1 agents cloud run ...
```

Consent is recorded at `~/.agents/.cache/cloud/rush-consent.json` (delete it to revoke). This is a credential-upload decision — get explicit OK from the user before passing the flag.

## Codex Cloud

Runs in a pre-built environment. The provider wraps the real `codex` CLI (`codex cloud exec/status/list`).

```bash
agents cloud run "add pytest fixtures for the new billing module" \
  --provider codex --agent codex --env <env_id> --timeout 30m
```

- `--env <id>` is **required**. Set a default in `~/.agents/agents.yaml` under `cloud.providers.codex.env` to omit it.
- Environment IDs are **not listable from the CLI**. Find them in the Codex web settings — open `https://chatgpt.com/codex/cloud/settings/environments`, click an environment, and read the id from the URL (`.../environment/<id>`). The repos a Codex task can touch are fixed at env-creation time, so `--repo` multi-dispatch is rejected — use `--provider rush` for that.
- Codex Cloud has no live stream; `logs`/`status` poll until the task reaches a terminal state.
- `cancel` and `message` are **not supported** for Codex tasks via the CLI.

## Factory pods

Droid + computer-use targets.

```bash
agents cloud run "QA the new onboarding flow end-to-end" \
  --provider factory --computer linux-vm-1 --agent droid
```

## Manage tasks

```bash
agents cloud list                       # every task you've dispatched, most recent first
agents cloud list --json                # machine-readable
agents cloud status <id>                # task detail + latest status
agents cloud logs <id>                  # live-tail output (polls for codex)
agents cloud message <id> "<text>"      # follow-up while in needs-review (rush/factory)
agents cloud cancel <id>                # cancel a running task (not supported for codex)
```

## Set a default provider

Add to `~/.agents/agents.yaml`:

```yaml
cloud:
  defaultProvider: rush
  providers:
    codex:
      env: <env_id>          # so codex dispatch needs no --env
```

Then `agents cloud run "refactor auth module" --repo owner/repo` uses the default.

## When to use cloud vs run vs teams

- **`run`** — one agent, on this machine, now. Fast iteration, local files.
- **`cloud`** — offload to a remote backend; scale past local capacity; needs a repo (rush) or env (codex). Async by default with `--no-follow`.
- **`teams`** — multiple local agents collaborating on shared work with boundary contracts.

For local execution see the `run` skill; for parallel local work see `teams`.

For everything else, run `agents cloud --help` or `agents cloud run --help`.
