# Profiles

> Layered with `~/.agents/profiles/`. Same name in your user repo wins; everything else unions in.

A profile is a host CLI + endpoint + model + auth bundle. It lets you run an alternate model (Kimi, DeepSeek, Qwen, GLM, MiniMax) through an existing agent CLI by swapping the base URL, model name, and credential.

## File format

```yaml
name: <profile-name>
host:
  agent: claude | codex | gemini   # which CLI hosts this profile
env:
  ANTHROPIC_BASE_URL: ...
  ANTHROPIC_MODEL: provider/model-id
  ANTHROPIC_SMALL_FAST_MODEL: provider/model-id
auth:
  envVar: ANTHROPIC_AUTH_TOKEN     # env var the host CLI reads
  keychainItem: agents-cli.<provider>.token
description: short summary of cost, ctx window, quirks
preset: <preset-id>                # built-in preset this was derived from
provider: openrouter | ...
```

## Use

```bash
agents profiles add kimi                # apply preset; prompts for API key
agents profiles list
agents profiles login openrouter        # rotate stored key
agents run kimi "explain this diff"     # run as if it were a regular agent
```

The API key is stored in macOS keychain under the name in `auth.keychainItem` — never in this repo.

## Built-in presets

`agents profiles presets` lists all bundled presets. Currently: `kimi`, `kimi-chat`, `deepseek`, `qwen`, `glm`, `minimax` — all routed via OpenRouter.

## Adding a new profile

Either start from a preset (`agents profiles add <preset>`) and edit the resulting YAML, or write one by hand and drop it in this directory.
