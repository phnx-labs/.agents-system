# Hooks

This folder contains the behavior scripts that customize how your agents read prompts and handle parts of a session. If prompting feels different from plain Codex or Claude,\
the reason often starts here.

The two hooks most people notice are:

- `02-expand-prompt-user-shortcuts.sh` expands shortcut tokens into fuller instructions or context.
- `02-expand-prompt-bang-commands.py` executes backticked bang commands like `!pwd` and injects the result into the prompt flow.

Some other hooks in this folder are more operational. They still affect agent behavior, but they are less visible in normal day-to-day prompting.

Look here when:

- a shortcut did not expand
- a bang command did not run
- extra context appeared in a prompt
- agent behavior feels customized in a way that is not obvious

For debugging, the scripts in this folder are the implementations. `../hooks.yaml` shows which ones are wired into agent lifecycle events, and the installed agent config shows\
what is active right now.