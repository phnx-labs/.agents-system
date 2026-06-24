# Changelog

## [0.1.24] - 2026-06-23

### Fixed
- **`hooks/03-linear-inject-tasks-context.sh`** — the SessionStart hook read Linear credentials with `security find-generic-password` (macOS Keychain), a binary that **does not exist on Linux**, so on Linux it printed `Linear credentials not found in Keychain` on every single session start. It now reads via `agents secrets get linear-api-key` / `linear-team-id`, which routes through the CLI's cross-platform keychain layer (macOS Keychain, Linux libsecret + encrypted-file fallback). macOS items stored by the previous `security -s linear-api-key` convention are read transparently (identical account+service lookup), so no migration is needed. The "not found" hint now points at `agents secrets set …`. Requires agents-cli with `secrets get/set` (phnx-labs/agents-cli#359).

## [0.1.23] - 2026-06-23

### Added
- **`commands/finish.md`** — the `/finish` command, ported from `.agents-extras` as a system default. An execution intervention (not a recap): recover the original contract from the conversation, convert each open item to a next action with evidence-backed verdicts, take the next action immediately, verify end-to-end on the real flow, ship, and keep going until the task is delivered or a hard external blocker is proven with three quoted attempts. Complements `/done` (which *checks* whether work is complete) by *driving* it to completion. Lightweight, no deps.

## [0.1.22] - 2026-06-23

### Added
- **`plugins/code`** — the `code` coding-workflow plugin now ships as a system default (graduated from `.agents-extras`). Bundles six skills (`dispatch`, `loop`, `review`, `verify`, `sprint`, `quality`) and their slash commands plus `/commit`: `/code:loop` drains a ticket/bug/TODO queue end-to-end (plan, code, test, review, rebase, fix CI, merge), `/code:dispatch` triages a single task and picks the delivery path, `/code:verify` runs the end-to-end gate from the project's canonical test per changed surface, `/code:review` reviews every PR opened in a session in parallel (with a security pass on risk-touching diffs) and merges per verdict, `/code:sprint` runs a time-boxed multi-track push via `agents teams`, `/code:quality` runs a read-only code-health diagnostic and opens an HTML report, and `/commit` splits the working tree into the maximum number of small logical commits. Registered in the new `.claude-plugin/marketplace.json` (marketplace `agents-system`); the system layer now tracks a `plugins/` directory.

## [0.1.21] - 2026-06-22

### Changed
- **`commands/test.md`** — the parallel-team step was modeled on the old `/debug` verification panel ("validate"/"synthesize"), which is the wrong shape for testing. Reworked into **Parallel Test Authoring**: the team now exists to *cut wall-clock by writing tests concurrently*, not to review. The lead decomposes the surface into slices that map to **separate test files** (so no two agents edit the same file), hands each a `parallel-teams` boundary contract (**Owns** / **Must NOT touch** / **Shared fixtures**, one canonical fixture owner), and spawns them in **`--mode edit`** to author in parallel. Vendor variety is explicitly *not* the goal here — throughput is. The lead then owns a mandatory integration pass: read each slice, **run the full suite itself**, write the cross-slice end-to-end flows no single author owned, dedup overlapping coverage, and report real pass/fail counts ("written" is not "passing"). Output reorganized around slices + a quoted suite result.
- **`commands/plan.md`** — Step 7 "Early Design Review" was *Recommended* (so it got skipped), `claude`+`codex` only, blinded with one line, and reconciled with four soft bullets. Replaced with **Independent Design Panel -> Adjudicate**, which runs **automatically** for medium+/architectural/unfamiliar work. Instead of a team *critiquing the lead's plan* (which anchors reviewers on its framing and lets their mistakes feed straight in), a vendor-varied panel (`codex`/`gemini`/`cursor`/`claude`, `--mode plan`) each produces a **full independent plan**. The brief is an explicit **SHARE / WITHHOLD** contract: planners get the goal, constraints, files to read, and the *factual* primitives inventory — but never the lead's approach, artifacts, or file-by-file plan (each named so it can't slip in). The lead then **adjudicates one merged plan**, adopting an idea only after verifying it against the actual code (file:line) — so a reviewer's error loses that point rather than corrupting the plan — and treating its own plan as one candidate among N, not the privileged answer. Genuine trade-offs become `AskUserQuestion` design questions; the Output gains an **Independent Plans** (adopted / rejected-with-reason / design-question) section.

## [0.1.20] - 2026-06-22

### Changed
- **`commands/debug.md`** — the independent-verification step is no longer an optional afterthought the agent had to be *told* to run. Restructured into seven phases where Phase 5 ("Independent Blind Review") fires **automatically** for any non-trivial bug, so the lead never stops to ask "should I spin up a team?". The lead now must commit to a defensible root cause itself first (Phase 4 is a gate — read the existing logs yourself, name a file:line), *then* spawn a panel via `agents teams … --mode plan` (read-only) to pressure-test it. The blinding is now an explicit **SHARE / WITHHOLD** contract: reviewers get the symptom, verbatim error, repro command, and *where to look* — but never the lead's root cause, mapped data path, hypothesis, or proposed fix (each named so it can't slip into the brief). **Variety across vendor agents (`codex`/`gemini`/`cursor`/`claude`) is the hard requirement** — three copies of one agent share blind spots; reviewer count is left to the lead's judgment, scaled to the bug's breadth. New Phase 6 ("Reconcile & Strengthen") builds a convergence matrix: independent agreement → report with high confidence; divergence → re-read the disputed file:line (the lead's own theory isn't privileged); a reviewer's new finding → folded into the report. The Output gains **Confidence** and **Independent Review** sections. This codifies, as the default flow, what previously had to be requested by hand every time.

## [0.1.19] - 2026-06-18

### Changed
- **`hooks/git-guard.sh`** — *starting* a rebase is now allowed when it runs inside an isolated worktree (`<repo>/.agents/worktrees/<slug>`), detected via the worktree path in the command (`git -C <wt> rebase`, `cd <wt> && git rebase`) or the session cwd already being inside one. Rewriting history on a branch nothing else uses, off the user's main checkout, is the blessed worktree flow — and `git push --force-with-lease` was already permitted, so the rebase round-trip now works end to end. Starting a rebase anywhere else (notably the primary checkout) stays denied. This is the natural successor to 0.1.18, which had only un-blocked *finishing* an in-progress rebase.

## [0.1.18] - 2026-06-14

### Changed
- **`hooks/git-guard.sh`** — finishing an in-progress rebase is now allowed (`git rebase --continue` / `--skip` / `--abort` / `--quit` / `--edit-todo` / `--show-current-patch`); only *starting* a rebase stays denied, since that's what rewrites history. Hand-resolving conflicts and advancing the sequence is safe and was previously blocked outright.
- **`.gitignore`** — ignore the local-only `/tests/` directory.

## [0.1.17] - 2026-06-14

### Fixed
- **`README.md` resolution table omitted the extras layer.** The real precedence is `project > user > extras > system`, but both the layer table and the resolve line listed only three layers. Added the extras row and corrected the order.

### Added
- **`README.md` "Going further: extras bundles" section.** New users land on this README but had no pointer to the heavier opt-in workflows (parallel coding loops, branded media, git plumbing). Documents `agents repo add gh:phnx-labs/.agents-extras` and why those skills stay out of system (heavier deps + paid keys; the default install stays fast and OS-portable). This is the deliberate alternative to porting them in — an investigation found each extras plugin is blocked from a system port for a concrete reason: `git:cleanup` duplicates the existing `/prune` command; the `code` plugin collides with the built-in `/loop` and `/verify` skills and overlaps system `/review` `/commit` `/test`, and its `code:` namespace is load-bearing; `creative` carries brand references plus Remotion/ElevenLabs/paid-API dependencies and is documented as intentionally kept out.

## [0.1.16] - 2026-06-14

### Added
- **`skills/git-workflow/`** — new skill holding the full PR worktree lifecycle: create the branch under `<repo>/.agents/worktrees/<slug>/` from the real default branch, work and verify end-to-end inside it, open the PR, wait for review, clean up after merge — with the bash recipes. Auto-loads on PR/worktree triggers; also invocable as `/git-workflow`.

### Changed
- **`rules/subrules/git-workflow.md` slimmed 40 → 10 lines.** The procedural bash (worktree creation, push, PR, after-merge cleanup) moved into the new `git-workflow` skill. The always-on rule now keeps only the behavioral invariants plus the correctness-critical "resolve the default branch dynamically (`git symbolic-ref refs/remotes/origin/HEAD`), never hardcode `main`" guard and a pointer to the skill. `rules/AGENTS.md` dropped 195 → 165 lines (1856 → 1749 words): less procedural detail diluting the always-on hard lines, with the full recipe one auto-load away. Establishes the pattern — invariants stay always-on, procedures load on demand.

## [0.1.15] - 2026-06-14

### Fixed
- **Broken rule cross-references.** `rules/subrules/parallel-teams.md` pointed at a `swarm` slash command that doesn't exist → now `/teams`. `rules/subrules/git-workflow.md` pointed at a `git-session-export` skill that doesn't exist → now the real `sessions` skill. Regenerated `rules/AGENTS.md` (with its `CLAUDE.md`/`GEMINI.md` symlinks) from the subrules; it stays a byte-exact concatenation in preset order.
- **macOS-only assumptions in the always-on rules.** `operational.md` and `tech-stack.md` hardcoded `pbcopy`, "use `find` on macOS (use `fd`)", and "macOS Keychain" — which break the very first clipboard/secrets/file-find action for Linux and cloud agents. Clipboard hand-off now lists `pbcopy` (macOS) **and** `xclip`/`wl-copy` (Linux); credentials read "OS keychain-backed"; the finder note no longer assumes the OS.

### Changed
- **`commands/README.md` and top-level `README.md` reconciled with the filesystem.** Both advertised phantom commands with no file (`/audit`, `/design`, `/redesign`, `/product`, `/secrets`, `/sessions`, `/spawn`) and omitted real ones (`/done`, `/prune`, `/review`). Tables now list exactly the 12 shipped commands; a note clarifies `/secrets`, `/sessions`, `/audit`, `/design` are skills, not commands. Top-level skills table expanded from 4-of-13 to a representative set pointing at `skills/README.md` as the source of truth.
- **`skills/README.md`** — added the four undocumented skills (`routines`, `run`, `secrets`, `sessions`); table now covers all 12.
- **`commands/continue.md`** — dropped the "don't use the older `/sessions` skill" line that contradicted the skill still shipping; now just names the `agents sessions` CLI as the context-recovery tool. Normalized command-description em-dashes across `continue`, `plan`, `recap`, `test`.

### Removed
- **`skills/composer/`** — empty, untracked phantom directory (no `SKILL.md`). The real composer skill lives in the `creative` plugin, not system.

## [0.1.14] - 2026-06-12

### Added
- **`skills/docs/`** — ported the documentation skill: `SKILL.md` plus `write-changelog.md`, `write-onboarding.md`, `write-runbook.md`, `write-technical.md`, `write-user.md`. Methodology is "less is more — only document what code can't tell you." Scrubbed of brand-specific file-path examples (generic `src/agent/execution.go` instead of internal paths).
- **`skills/reflect/SKILL.md`** — ported the reflect skill: enumerate every piece of feedback (REJECTED / CORRECTED / CONFIRMED / CONSTRAINT) from the conversation, identify the connecting thread, state the revised approach, then execute with all constraints active simultaneously. Brand-specific example constraint genericized.
- **`skills/release/SKILL.md`** — ported the release skill: discover repo structure, scaffold build/release scripts if missing, run tests, update changelog, publish to npm/CDN, and tag. Supports monorepos and semver prereleases. Scrubbed of internal package names and author metadata (generic `@your-scope/your-package`, `packages/app` examples).

### Changed
- **`commands/issues.md` → `commands/tickets.md`** — renamed the tracker command from `/issues` to `/tickets`. Auto-detect behavior across Linear/GitHub/Jira is unchanged. Updated every reference in `rules/AGENTS.md`, `rules/subrules/conventions.md`, `rules/subrules/tech-stack.md`, `README.md`, `commands/done.md`, `commands/recap.md`, `commands/continue.md`, and `commands/README.md`.
- **`skills/browser/SKILL.md`** — merged the generic "Adding a new domain-skill" workflow from the user copy (check `browser-use/awesome-prompts` upstream first, scaffold `domain-skills/<site>/`, match by directory name or explicit `domains:` array, auto-discovery via `agents browser start --url`). Scrubbed brand-specific app entries from the routing table; did not bring over the personal `app-skills/` or `domain-skills/` directories.

### Removed
- **`skills/scripts/`** — dropped the scripts skill. It encoded a convention (canonical `build.sh`/`test.sh`/`release.sh` layout), not an invocable capability, so it moves to the user's personal rules. Repointed the `tech-stack` tools table (and `rules/AGENTS.md`, `rules/rules.yaml`) from the `scripts` skill to the new `release` skill.

## [0.1.13] - 2026-06-11

### Added
- **`skills/computer/SKILL.md`** — new skill teaching agents the `agents computer` macOS automation surface: observe → act → verify loop, AX mode vs coordinate mode (origin/scale pixel mapping for AX-opaque surfaces like Parallels VMs and canvas editors), focus discipline (`raise` first, `--require-frontmost` on keyboard verbs, `frontmost:false` means dropped keystrokes), failure-mode playbook (`not_frontmost`, `window_offscreen`, `element_stale`, `rpc_timeout`), worked Windows-VM example, and safety rails (secure-field guard, hard-denied system surfaces). Mirrors agents-cli PR #258.

## [0.1.12] - 2026-06-11

### Added
- **`skills/secrets/SKILL.md`** — new section "Multiple Accounts on One Website": one domain-named bundle per site (`x.com`), keys grouped by account handle (`THEMUQSIT_USERNAME` / `THEMUQSIT_PASSWORD`, plus `_EMAIL` / `_TOTP_SECRET`), per-key `--note` recording when an agent should use each account. `view` prints notes in the clear with values masked, so agents pick the right account before revealing anything; reveal one pair via `export --plaintext | grep '^HANDLE_'` or bind the bundle to a browser profile (`agents browser profiles create -s <bundle>`). Mirrors agents-cli PR #255.

## [0.1.11] - 2026-06-08

### Added
- **`rules/subrules/operational.md`** — new rule: "Hand off commands the user must run — don't just print them." Markdown code fences aren't executable. Preferred order is pipe to `pbcopy` and tell the user it's copied; write a one-shot script to `/tmp/<slug>.sh` for anything multi-line; render the command inline only as last resort. Always quote what was copied so the user can verify before pasting.

### Changed
- **`rules/subrules/git-workflow.md`** — worktree recipe now fetches the actual default branch (`remote set-head origin --auto` + `symbolic-ref refs/remotes/origin/HEAD`) instead of hardcoding `origin/main`. The hardcode broke worktrees in repos whose default branch is `master`, `trunk`, etc.
- **`rules/AGENTS.md`** (and `CLAUDE.md`, `GEMINI.md` symlinks) — regenerated from subrules in preset order to pick up the new hand-off-commands rule and the worktree recipe update.

## [0.1.8] - 2026-06-07

### Added
- **`cli/linear-cli.yaml`** — first system-level CLI manifest. Declares `phnx-labs/linear-cli` as installable via `agents cli install linear-cli` (curl-bash one-liner from the upstream `install.sh`). Touch ID / Keychain integration is the CLI's own concern; the manifest just gets the binary onto PATH.

### Changed
- **`commands/issues.md`** — added a Step 2 "Installed CLI" check (`linear`, `gh`, `jira`, `glab` on PATH) ahead of the repo-signal probe, and pointed Linear detection at `agents cli install linear-cli` when the binary is missing. New anti-pattern: don't silent-install tracker CLIs — always confirm, since wrong-tracker false positives are real.

## [0.1.7] - 2026-06-03

### Changed
- **`rules/subrules/git-workflow.md`** — adopted earlier (commit 6a0a92a): worktrees now standardized at `<repo>/.agents/worktrees/<slug>/` with a full PR-open-but-don't-clean-up-until-merge lifecycle. This release trims the recipe (86 → 70 lines) and replaces the `[[git-readonly]]` wiki-link with a bare reference for cross-ref consistency.
- **`rules/subrules/operational.md`** — clarified the ask-vs-decide boundary. New rule: ask about scope (requirements, priorities), decide about implementation. Resolves apparent conflict with `workflow-proactive`'s "decide, state reasoning, keep going."
- **`rules/subrules/conventions.md`** — clarified ticket boundary: linear hook auto-injects context at session start; `/issues` is the explicit-action surface across Linear/GitHub/Jira. Dropped duplicate `scripts` skill mention (kept in `tech-stack` tools table).
- **`rules/subrules/workflow-proactive.md`** — gained the "Design before code" section, moved from `testing-strict.md` where it didn't belong topically.
- **`rules/subrules/testing-strict.md`** — slimmed: "Design before code" relocated (above).
- **`rules/subrules/parallel-teams.md`** — slimmed: the "After" bullet list collapsed into one line; the long-form playbook already lives in the `swarm` command.
- **`rules/subrules/tech-stack.md`** — slimmed: dropped the off-theme "LLM tool design" section (meta-guidance about building tools, not using them).
- **`rules/subrules/core-hard-lines.md`, `code-quality.md`, `operational.md`** — added one-line "Tier N of 3 — companion tiers" breadcrumb at the top of each tiered file so the tier structure is navigable.
- **`rules/AGENTS.md`** (and `CLAUDE.md`, `GEMINI.md` symlinks) — regenerated from subrules in preset order. The hand-maintained fallback was stale since 0.1.3 (May 13) and still referenced retired skills (`image-craft`, `linear`), the 24-rule scheme, and a `agents pty` recipe that's no longer in any subrule. Now matches the composed output.

## [0.1.6] - 2026-05-18

### Removed
- **`hooks/tests/`** — pytest suite for `02-expand-prompt-skill-refs.py`. The dir broke `agents add claude@2.1.143` sandbox image materialization: agents-cli walks `hooks/` with `fs.copyFile()` (file-only) and tripped EISDIR on the `tests/` subdir. Dev artifacts shouldn't live inside the runtime hooks tree. If we want a regression suite again, host it at repo-root `tests/` (outside the hooks walk) and rewrite the `Path(__file__).parent.parent` reference accordingly.

## [0.1.5] - 2026-05-17

### Added
- **`hooks/02-expand-prompt-skill-refs.py`** — UserPromptSubmit hook that expands `$skill-name` tokens in prompts into skill path + description. Searches `{cwd}/.agents/skills/` → `~/.agents/skills/` → `~/.agents-system/skills/` (first match wins). Per-agent protocol matches `02-expand-prompt-bang-commands.py` (Claude `<user-prompt-submit-hook>` replacement, codex/gemini JSON `additionalContext`).
- **`hooks/tests/test_expand_prompt_skill_refs.py`** — pytest suite for the skill-refs hook.
- **`agents.yaml`** — system-layer config: `run.claude.strategy: balanced`.

### Changed
- **`hooks/02-expand-prompt-skill-refs.py`** prunes `node_modules`, `.git`, `__pycache__`, `.venv`, `venv`, `dist`, `build`, `.cache`, `.tox`, `.mypy_cache` during `os.walk` to avoid descending into massive trees during fuzzy skill lookup.

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
