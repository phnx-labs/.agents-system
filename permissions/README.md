# Permissions

Canonical YAML permission rules that `agents-cli` translates into each agent's native format (Claude `settings.json`, OpenCode `opencode.jsonc`, Codex `config.toml`).

See [`AGENTS.md`](./AGENTS.md) for the full rule syntax, the cross-agent translation table, and authoring guidance — that's the reference.

## Layout

```
permissions/
  AGENTS.md         # full reference (also synced into agent context)
  CLAUDE.md         # symlink -> AGENTS.md
  GEMINI.md         # symlink -> AGENTS.md
  groups/           # ordered YAML fragments (01-core.yaml, 09-git.yaml, ...)
  sets/             # named bundles that include a list of groups
  build.sh          # concatenates groups -> default.yaml
  default.yaml      # AUTO-GENERATED; do not edit by hand
```

## Workflow

1. Edit the relevant file in `groups/`.
2. Run `./build.sh` to regenerate `default.yaml`.
3. `agents permissions add` (or `agents pull`) installs it.

## Sets

`sets/<name>.yaml` defines a named permission bundle as a list of group includes. `default` is the laptop-strict bundle; `sandbox` is for sandboxed execution. Pick a set when registering: `agents permissions add --set sandbox`.

## Local-only rules

Machine-specific allows (paths, custom CLIs) live in `groups/00-local.yaml` — gitignored, never synced.
