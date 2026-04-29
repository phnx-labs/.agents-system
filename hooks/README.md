# Hooks

Scripts that customize how agents read prompts and handle parts of a session. If behavior feels different from plain Codex or Claude, it usually starts here.

The two most visible:

- `02-expand-prompt-user-shortcuts.sh` — expands `#shortcut` tokens via `promptcuts.yaml`.
- `02-expand-prompt-bang-commands.py` — runs inline `` `!cmd` `` and injects the result.

Other hooks are operational (session-start context, completion gates, etc.).

## Manifest schema (`../hooks.yaml`)

```yaml
my-hook:
  script: 02-my-hook.sh
  events: [UserPromptSubmit]
  timeout: 5
  matches:                 # optional pre-filters; AND together
    prompt_contains: "#"
  enabled: true            # default; set false to disable a system hook from user side
```

- `script` — path relative to this dir.
- `events` — lifecycle events to register on.
- `timeout` — seconds.
- `matches` — `prompt_contains`, `prompt_matches`, `tool_name`, `tool_args_match`, `cwd_includes`, `project_has`, `git_dirty`. All AND together. Empty/missing → always fires.
- `enabled` — set `false` in user `~/.agents/hooks.yaml` to disable a system-shipped hook.
- `agents` — **deprecated**. The capability table decides which agents register the hook; the field is parsed for back-compat but ignored.

## Layering

System (`~/.agents-system/hooks.yaml`) and user (`~/.agents/hooks.yaml`) merge with **user wins on key collision**. Same name in user repo overrides the system entry wholesale.

## Promptcuts

`promptcuts.yaml` is data for the expand-promptcuts hook. Layered the same way:

- `~/.agents-system/hooks/promptcuts.yaml` — system-shipped defaults (`#checkit`, `#rethink`, …)
- `~/.agents/hooks/promptcuts.yaml` — your shortcuts; user keys win

## Look here when

- a shortcut did not expand
- a bang command did not run
- a system-shipped hook fires that you want to disable (use `enabled: false` in user repo)
- agent behavior feels customized in a way that is not obvious

The scripts here are the implementations. `../hooks.yaml` shows which are wired into lifecycle events. The installed agent config (e.g. `~/.claude/settings.json`) shows what is currently active.
