---
name: accounts
description: "Set up Rush Cloud authentication and connected Claude/Codex account credentials. Covers `rush login`, `rush whoami`, `rush cloud accounts add/list/remove`, token storage, and how Factory receives credentials during cloud dispatch."
argument-hint: "[add|list|remove]"
allowed-tools: Bash(rush whoami*), Bash(rush login*), Bash(rush cloud accounts*), Bash(rush cloud run --help*), Bash(rush cloud agents*), Bash(rg*), Bash(sed*), Bash(nl*)
user-invocable: true
---

# cloud:accounts

Use this when the user needs to prepare Rush Cloud credentials before dispatch.

## Rush Login

Check current Rush auth:

```bash
rush whoami
```

If not logged in, use one of the supported login paths:

```bash
rush login
rush login --device
rush login --paste-code
```

The Rush CLI stores its session in `~/.rush/user.yaml`. Do not print the access token in chat or logs.

## Connected Harness Accounts

List connected cloud accounts:

```bash
rush cloud accounts list
```

Register a Claude Code OAuth token:

```bash
rush cloud accounts add
rush cloud accounts add --token <CLAUDE_CODE_OAUTH_TOKEN>
```

Register Codex auth:

```bash
rush cloud accounts add --provider codex --from-file ~/.codex/auth.json
```

Remove an account:

```bash
rush cloud accounts remove <id>
```

Never paste real tokens into chat. If a command prints a token, summarize auth state without repeating the token.

## What The Backend Does

The Rush-side account flow is source-verified:

- `rush cloud accounts add` posts `{ provider, token }` to `/api/v1/cloud-accounts`.
- prix-api accepts providers `claude` and `codex`.
- Claude tokens are validated against Anthropic's OAuth usage endpoint when possible; setup tokens that lack usage scope can still be accepted.
- Codex credentials are accepted as a JSON object from `~/.codex/auth.json`.
- Tokens are stored encrypted through Supabase Vault; the `cloud_user_accounts` table stores metadata and a vault secret id.
- During cloud dispatch, prix-api reads the caller's registered Claude tokens, weight-picks up to four by remaining capacity, and forwards them as `user_account_tokens`.
- Factory maps those tokens to `CLAUDE_CODE_OAUTH_TOKEN_0` through `CLAUDE_CODE_OAUTH_TOKEN_3` for the per-task process.
- For Codex, prix-api forwards the stored auth JSON and Factory materializes it as per-task Codex auth.

## Failure Modes

- `rush whoami` fails: the user is not logged in to Rush, or the session expired.
- `rush cloud accounts list` is empty: the cloud worker may not have Claude/Codex credentials for that harness.
- Claude token validation fails with 401: the token is invalid or revoked.
- Codex registration fails JSON validation: the file is not a top-level JSON object.
- Cloud dispatch fails with access or billing language: treat it as a Rush Cloud access/subscription issue, not a missing Claude/Codex token.
- Harness fails with auth or quota language inside logs: inspect the connected Claude/Codex account capacity.
