# cloud plugin

Rush Cloud dispatch and account setup for coding agents.

This plugin documents the first-party `rush cloud` surface. Use it when a task should run away from the laptop on Rush Cloud infrastructure, against one or more GitHub repos, with a Claude Code or Codex harness inside the cloud worker.

## Commands

| Command | Use when |
| --- | --- |
| `cloud:run` | Dispatch a coding task to Rush Cloud, then inspect status, logs, transcript, PR output, or follow-up messages. |
| `cloud:accounts` | Set up Rush login and connect Claude/Codex account credentials that the cloud harness can use during dispatch. |

## Contract

- Rush Cloud is reached through the native `rush cloud` CLI, not by hand-curling API endpoints.
- Users need a Rush account and a valid `rush login` session for authenticated cloud operations.
- Repos must be connected through the Prix Cloud GitHub App so Rush Cloud can clone and push branches.
- Claude Code dispatches should use `rush cloud run --harness claude-code ...` or positional `claude`; Codex dispatches use `--harness codex` or positional `codex`.
- Cloud harness credentials are explicit user account credentials: `rush cloud accounts add` for Claude tokens, or `rush cloud accounts add --provider codex --from-file ~/.codex/auth.json` for Codex.
- Rush-side cloud subscription/access gates and vendor account capacity are separate concerns. Do not promise free or unlimited cloud usage, and do not imply connected Claude/Codex credentials replace any Rush Cloud subscription or access requirement.
