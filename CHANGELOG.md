# Changelog

## [0.1.4] - 2026-05-14

### Changed
- **`browser` skill restructured into multi-level subskills** — `SKILL.md` is now a router only; implementation detail moved to dedicated files.

### Added
- **`skills/browser/browser-use.md`** — full web automation reference updated to the new API (`AGENTS_BROWSER_TASK` env var, `tab add/focus/close`, `done`/`status`, `-t <tabId>` flag).
- **`skills/browser/electron-use.md`** — Electron desktop app automation: `--browser custom --electron` attach pattern, common gotchas (stale preload, hidden windows, no new tabs, debug port not exposed), `app-skills/` routing.

## [0.1.3] - 2026-05-13

### Changed
- **Rules ruleset tightened** to reduce compiled `CLAUDE.md`/`AGENTS.md` size. Prose trimmed across all 11 remaining subrules with no rule numbers dropped.
- **`rules/subrules/scripts-discipline.md` moved to a skill** at `skills/scripts/SKILL.md`. Agent invokes it when touching `scripts/`, `release.sh`, `build.sh`, or deploy/publish flows instead of carrying the contract in every session.

### Removed
- **`rules/presets/`** (`cautious.md`, `minimal.md`, `proactive.md`) — `rules/rules.yaml`'s `default` preset is the only one in use.
- **`rules/subrules/linear-tickets.md`** — `hooks/03-linear-inject-tasks-context.sh` already injects ticket context at session start; the rule was duplicative.
- **`rules/subrules/scripts-discipline.md`** — see above (moved to skill).
- **`rules/subrules/workflow-cautious.md`** — not referenced by any active preset.
- **`rules/subrules/product-mindset.md`** — not referenced by any active preset.

### Note
Users with `~/.agents/rules/subrules/{linear-tickets,scripts-discipline,workflow-cautious,product-mindset}.md` overrides at the user layer still get those rules — only the system-shipped copies were removed.

## [0.1.2] - 2026-05-13

### Security
- **PR session gist export defaults to secret, not public** (`commands/done.md`, `rules/subrules/git-workflow.md`). Session transcripts can leak repo internals, infra details, tool output, and bundle names. The previous `--public` default published this material to github.com/<user> as anonymously-indexable content. New default omits `--public`, producing a secret (URL-only) gist. Use `--public` explicitly only when the target repo is public AND the transcript has been reviewed for sensitive content.

## [0.1.1] - 2026-05-10

Public release cleanup. Streamlined commands, improved workflows, better documentation.

### Added
- **`/done` command** — comprehensive completion checklist: verify code, test E2E, commit, create PR with session gist, release if applicable, handle remaining items via tickets.
- **`/teams` command** — inline workflow for spawning parallel agents (single agent via `agents run`, teams via `agents teams`).
- **`/plan` enhancements** — web search for current best practices, user flows for UI features, primitive reuse requirement, optional early design review with agent team.

### Changed
- **Commands consolidated** — removed redundant skill redirects (`/secrets`, `/sessions`, `/teams` stubs) in favor of invoking skills directly.
- **`/spawn` removed** — use `agents run <agent> "prompt" --mode edit` for single-agent dispatch.
- **`/design`, `/redesign` removed** — covered by the `design` skill with multiple modes.
- **`/product` moved to rules** — now `rules/subrules/product-mindset.md` (opt-in, not in default preset).
- **Teams skill updated** — documents `agents run` for single-agent work.
- **README rewritten** — accurate command/skill tables, cleaner structure.

### Fixed
- Hooks documentation clarified: system uses `hooks.yaml`, user hooks go in `agents.yaml` under `hooks:` section.

## [0.1.0] - 2026-04-01

First tagged release. Consolidates agent configuration, permissions, hooks, and skills.

### Added
- **Stop completion gate hook** (`hooks/stop-completion-gate.sh`) -- blocks agents from claiming "done" without end-to-end verification. Extracts original user request from transcript, forces goal-by-goal self-audit before allowing session to end.
- **Permission rules for `2>/dev/null` redirections** -- read-only commands (`ls`, `cat`, `head`, `tail`, `wc`, `file`, `stat`, `which`, `grep`, `rg`, `readlink`, `diff`, `command -v`, `type`) now have allow patterns covering stderr suppression to `/dev/null`.

### Changed
- **AGENTS.md restructured by priority** -- rules reordered into 3 tiers by impact. "Done means it works end-to-end" promoted to Hard Line #1. Core workflow changed from `ACT -> SHOW -> CONTINUE` to `ACT -> VERIFY -> SHOW -> CONTINUE`. 8 sections consolidated to 5, 204 lines reduced to 144.
- **Private skills moved out of version control** -- skills with proprietary content (image-craft, writer, browser, linear, etc.) gitignored and managed separately.

### Fixed
- Cross-cutting changes rule promoted from buried Design Principles section to Hard Line #8.
- Testing section now cross-references Hard Line #1 to prevent "unit tests pass = done" loophole.
