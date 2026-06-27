---
name: run
description: "Dispatch and manage coding agents on Rush Cloud via `rush cloud run`. Covers Rush login, GitHub repo access, Claude Code/Codex harness selection, execution lifecycle commands, and evidence to collect before claiming a run worked."
argument-hint: "[prompt] --repo owner/repo [--harness claude-code|codex]"
allowed-tools: Bash(rush whoami*), Bash(rush login*), Bash(rush cloud*), Bash(git remote*), Bash(git rev-parse*), Bash(rg*), Bash(sed*), Bash(nl*)
user-invocable: true
---

# cloud:run

Use this when the user wants a coding agent to run on Rush Cloud instead of the local machine.

## Preconditions

Check these yourself before dispatching:

```bash
rush whoami
rush cloud accounts list
rush cloud run --help
```

Required:

- A Rush account with a valid CLI session. `rush login`, `rush login --device`, and `rush login --paste-code` are the supported login paths.
- A GitHub repo connected through the Prix Cloud GitHub App. `rush cloud run --help` says the run clones repos and pushes a branch plus PR per repo.
- A connected Claude or Codex account if the cloud harness needs that vendor identity. Use `cloud:accounts` for setup.
- Cloud access/subscription where the Rush backend requires it. The API owns this gate; do not bypass it with local flags or copied tokens.

## Dispatch

Prefer the native Rush CLI for Rush Cloud:

```bash
rush cloud run --harness claude-code --repo owner/repo --prompt "Fix the failing checkout test and open a PR."
rush cloud run claude owner/repo -p "Fix the failing checkout test and open a PR."
rush cloud run --harness codex --repo owner/repo -p "Add parser tests for the edge case."
```

For multi-repo work, repeat `--repo`:

```bash
rush cloud run --harness claude-code \
  --repo owner/service \
  --repo owner/sdk \
  -p "Rename the billing endpoint across service and SDK. Open PRs."
```

For an agents-cli workflow inside Rush Cloud:

```bash
rush cloud run --workflow autodev owner/repo -p "RUSH-123" --mode exec
```

Use `--agents-repo owner/.agents` when the cloud pod needs a specific user DotAgents repo overlaid into the sandbox.

## Manage Runs

```bash
rush cloud list
rush cloud status <execution-id>
rush cloud logs <execution-id>
rush cloud transcript <execution-id>
rush cloud message <execution-id> "Also update the generated client."
rush cloud cancel <execution-id>
rush cloud agents
rush cloud warmup owner/repo --agent claude
```

Do not claim the run worked until you have real output:

- Dispatch output should include `Dispatched <agent> to <owner/repo>` and an execution id.
- `rush cloud status <id>` should show the current state, agent, repo, and PR URL when one exists.
- `rush cloud logs <id>` or `rush cloud transcript <id>` should show what the remote agent actually did.
- If the work is code-changing, verify the PR or branch end-to-end before saying done.

## Implementation Notes

These are source-verified in the Rush repo:

- `rush cloud run` registers flags including `--repo`, `--harness`, `--model`, `--agents-repo`, `--workflow`, and `--computer`.
- `--harness claude-code` maps to agent `claude`; `--harness codex` maps to `codex`.
- The CLI builds a request body with `agent`, `prompt`, and `repos`, then posts to `api.BaseURL() + "/api/v1/cloud-runs"`.
- The production Rush CLI base URL is `https://api.prix.dev`.
- prix-api creates a cloud execution and dispatches to Factory Floor at `FACTORY_FLOOR_URL`, which defaults to `https://agents.427yosemite.com`.
- Factory's normal single-repo cloud mode is an `agent-host` pod with a per-task worktree.

## Pricing and Access

Keep these separate:

- Rush Cloud access/subscription: the Rush backend can gate cloud products. The codebase has cloud subscription/access concepts, including `users.cloud_access` for webhook dispatches and an `execution_kind = "cloud"` subscription bucket.
- Vendor account capacity: Claude Code and Codex harnesses need usable Claude/Codex credentials in the cloud worker. Connected credentials are managed with `rush cloud accounts`.

Do not tell users that adding a Claude/Codex token automatically grants Rush Cloud subscription access. Do not tell users that Rush Cloud subscription access automatically gives the cloud pod their Claude/Codex identity.
