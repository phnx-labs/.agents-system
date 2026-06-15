# Tooling & Stack Conventions

## Right tool for the job

| Task | Tool |
| --- | --- |
| Query large docs (.md, .html, .pdf) | `mq` — for files 100+ lines, probe then extract |
| Issue tracker (Linear/GitHub/Jira) | `/tickets` command — auto-detects |
| Browser automation | `browser` skill (a.k.a. `agents browser`) |
| Interactive terminal (REPLs, TUIs) | `agents pty` — see `agents pty --help` |
| Parallel coding agents | `agents teams` — see `parallel-teams` |
| Credentials | `agents secrets` — OS keychain-backed |
| Release/publish | `release` skill |
