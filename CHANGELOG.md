# Changelog

## [0.1.37] - 2026-07-01

### Fixed
- **`merge-guard.sh` no longer false-blocks commands that merely *mention* an admin-bypass merge in body/message text.** The guard did a naive substring match over the entire command string, so a `gh pr create` / `git commit` whose `--body` or `-m` text documented the guard (as this repo's own rules do) was blocked as if it were a bypass merge — it fired on a `gh pr create` during PR #40. Deciding shell dataflow with a regex is a losing game, so the guard is now **block-by-default**: it blanks only regions it can PROVE are inert, then matches; anything else stays visible and blocks (via `perl`, with a safe raw-match fallback if `perl` is absent). Provably-inert = (a) a documentation-flag value (`--body`/`-b`/`--title`/`-t`/`-m`/`--message`/…) that is a plain quoted string with no command substitution, and (b) a heredoc body whose sink is `cat`/`gh`/`git` at top level and that is not routed onward into execution (no pipe/`;`/`&`/backtick/redirect after the tag, no process substitution or interpreter around the sink). So real bypasses are always caught, including the review evasions: `-m "$(gh pr merge --admin)"`, `sh -c '...'`, `cat <<EOF | sh`, `cat <<EOF >x.sh`, `tee ... <<EOF; sh ...`, `sh <(cat <<EOF)`, `eval $(cat <<EOF)`, `. /dev/stdin <<EOF`, and `source`/`command sh`/`env bash` heredocs. It also normalizes quote/backslash obfuscation of `--admin` (`--ad""min`, `--ad\min`, `--ad'min'`) and joins backslash-newline line continuations so `cat <<EOF \`⏎`| sh` is seen as piped. Over-blocks exotic constructs (safe direction).
  - **Scope, stated honestly in the script header:** this is a best-effort speed-bump against a cooperative agent's careless admin-bypass merge, **not** an adversarial boundary — a shell string can't be fully analysed with text rules, so variable indirection (`X=--admin; gh pr merge $X`) or splitting the literal word `merge` can still evade it. The real enforcement is **server-side GitHub branch protection with required reviews** (note: `main` on this repo is currently unprotected).
  - Added `rules/subrules/gh-merge-guard/merge-guard_test.sh` — 34 cases over the real script and real stdin JSON: genuine bypass merges block (plain, chained, `sh -c` both quote styles, command-subst in `-m`, backtick; heredocs piped/redirected/process-substituted/line-continued into an interpreter; and `--admin` obfuscated via quotes/backslashes); legit merges and unrelated commands pass; and body / commit-message / `cat`-heredoc / `gh --body-file` documentation text mentioning the tokens passes.

## [0.1.36] - 2026-07-01

### Changed
- **`gh-merge-guard` rule (`rules/subrules/gh-merge-guard/rule.md`) aligned with auto-merge-on-green.** The rule contradicted `git-workflow` and `workflow-proactive`: those say "merge autonomously on green review + CI," while `gh-merge-guard` said "never merge a PR the user didn't explicitly ask you to merge … opening a PR is the end of the task — then ask," and "an earlier 'open a PR' does not authorize a merge." Agents reading the composed ruleset behaved inconsistently at the merge step. Resolved in favor of **auto-merge on green**: authorization to do the work carries through to a squash-merge once a non-author review **and** CI are green; `AskUserQuestion` only on red (review finds problems, tests fail, or conflict). The real safety rails are unchanged — never `gh pr merge --admin`, never self-approve your own PR, never transfer credentials.

## [0.1.35] - 2026-06-30

### Removed
- **`reflect` skill (`skills/reflect/`) — folded into `learn` + inlined where it was actually used.** `reflect` and `learn` were two reflection commands with colliding triggers (`reflect` on the bare word "reflect"; `learn` on "reflect and improve"). The scope axis people reach for — *this session vs many* — is already `learn`'s argument (`/learn` = current session, `/learn <id|topic>` = across sessions), so a second command wasn't earning its place; its only distinct job was the no-write, mid-draft feedback recall, which is baseline behavior, not a capability.
  - Its one real consumer, the `#rethink` promptcut (`hooks/promptcuts.yaml`), no longer loads the skill — its "recall every constraint, correction, and piece of feedback" step is now inlined (with the cumulative-feedback note reflect carried), so the rethink gate is unchanged in behavior.
  - Dropped the `reflect` rows from `README.md` and `skills/README.md`, and the now-dangling "Distinct from `reflect`" clause in the `learn` inventory line. `learn` is now the single reflection skill.

## [0.1.34] - 2026-06-30

### Added
- **`/learn <target>` — target-audit mode on the `learn` skill (`skills/learn/`).** `/learn` gains a second mode alongside post-session reflection: pass the name of a skill, plugin, command, or workflow you use (`/learn rush:design`, `/learn code:loop`) and it audits *that one thing* across every past session that used it, then proposes fixes for where it keeps going wrong.
  - **`audit/find-sessions.sh`** enumerates the sessions that actually used the target and classifies each use as a real invocation (`Skill`/tool `tool_use`, or a `<command-name>`) vs. an incidental prose mention — so a passing reference to the word never outranks a real run. `--structured-only` keeps only real invocations (named targets); omit it to grep conversation text for a loose workflow phrase. `--all` widens past the current project; results stream newest-first with the JSONL line numbers of the moments to quote.
  - **`audit/report.ts`** renders the findings to a self-contained HTML triage report (same visual language as `/code:quality`): each problem framed **expectation → what happened → why**, anchored to the session that surfaced it (id + topic + line) with the real user/error quote so the user recalls the moment instantly, recurrence count across sessions, a **recency-weighted "maybe fixed"** flag for problems only seen in old sessions, and a proposed fix + target. The user ticks the fixes they approve and **Copy approved fixes → /learn apply**.
  - Approved fixes flow back through the existing engine — four gates, route-to-home, edit-without-downgrading, verify + ship via worktree + PR. The audit changes *what* gets fixed (problems mined from real sessions, not the current conversation); it does not relax *how*.
  - Frontmatter updated: target-audit triggers + argument hint, and `bun`/`open`/`mkdir`/`chmod` added to `allowed-tools` for the report pipeline. Refreshed the `skills/README.md` inventory row.

## [0.1.33] - 2026-06-29

### Changed
- **`/done` repurposed to recap + self-exit; the ship gate moved into `/finish`.** `/done` and `/finish` had overlapping "complete the work" jobs. Now they own opposite ends of the lifecycle:
  - **`/done` (`commands/done.md`)** no longer runs a checklist — it builds a `/recap`-style handoff summary, emits it as the assistant message, then **cleanly self-exits the session** by sending `SIGTERM` to the harness (the Bash tool shell's `$PPID`). This is the agent-side equivalent of the user typing `/exit`; there is no `/exit` tool exposed, so signalling the parent is the only self-exit path. A guard refuses to fire if the parent looks like infrastructure (bare shell, tmux, sshd, init/systemd) rather than an agent harness. Agent-agnostic — works under claude/codex/gemini/etc.
  - **`/finish` (`commands/finish.md`)** absorbed `/done`'s ship-gate steps: Step 5 now covers docs (AGENTS.md/README/CHANGELOG/help-text), commit + PR with a secret session-transcript gist, an optional package release (build → test → confirm → verify-in-registry), and follow-up ticket creation for proven-remaining work. It remains the anti-stopping driver on top of that. This **relocates the "Update Docs" step added to `/done` in 0.1.30** into `/finish`, since `/done` no longer ship-gates.
  - Rewrote the `/done` ↔ `/finish` cross-reference at the top of both files and updated `commands/README.md`. Removed the stale user-repo override that shadowed the system `/done`.

## [0.1.32] - 2026-06-27

### Added
- **`plugins/cloud/`** - new Rush Cloud dispatch plugin. Ships `/cloud:run` for the native `rush cloud run` path (Claude Code/Codex harness selection, repo dispatch, status/logs/transcript/message/cancel lifecycle, and proof required before claiming a run worked) plus `/cloud:accounts` for Rush login and connected Claude/Codex account setup (`rush cloud accounts add/list/remove`). Documents the verified Rush path: production `rush` CLI -> `api.prix.dev` `/api/v1/cloud-runs` -> Factory Floor / Yosemite agent-host pods, with Claude tokens or Codex auth forwarded per task. Calls out the important distinction between Rush Cloud subscription/access gates and vendor account capacity, so users do not confuse adding Claude/Codex credentials with granting Rush Cloud access.

## [0.1.31] - 2026-06-27

### Added
- **`skills/learn/` (`/learn`)** — a top-level reflection engine that converts a finished session into durable improvements without downgrading existing workflows or overfitting to one session. Recalls what was used → checks the used plugins for their own learn/develop skills and follows their domain routing → distills candidates through four gates (generalization, recurrence, root cause, durability) and shows its rejects → routes survivors to a skill / rule / memory / nothing → edits additively → verifies → ships via worktree+PR with human sign-off. Distinct from `reflect` (intra-session feedback recall, writes nothing).
- **`plugins/code/skills/learn/` + `commands/learn.md` (`/code:learn`)** — the code-plugin-specific layer on the `learn` engine: a routing map from a lesson to the right `code:*` skill, when a missing loop *verb* justifies a new skill, and a contract-safety rule for editing the composing `code:*` skills.
- **`plugins/code/skills/ship/` + `commands/ship.md` (`/code:ship`)** — the post-merge gate for distributables (VS Code extensions, npm/cargo CLIs, web apps): publish, confirm live on the public channel's API, activate where it runs, verify the real surface. Wired into `code:loop` ("merged is the middle, not the end" for distributables; added to its composed-tools list). Code plugin bumped 0.6.1 → 0.7.0.

### Changed
- **`skills/computer/SKILL.md`** — added an "Electron Editors (VS Code / VSCodium / Cursor)" section: AX `get-text`/`describe` work when Screen Recording is denied; reload a window to activate a freshly-installed extension; `type-text` not `type` into the palette; webview React buttons ignore AXPress and coordinate clicks; `@eN` ids are per-`describe`; verify activation from `exthost.log`.

### Docs
- Refreshed the skill/plugin inventories to match the current surface: `README.md` (skills highlights + `code` plugin command list), `skills/README.md` (new `learn` row), and `plugins/code/README.md` (added the missing `code:loop`/`code:review` rows alongside `code:ship`/`code:learn`, and a ship step in the manager loop).

## [0.1.30] - 2026-06-25

### Changed
- **`commands/finish.md`** — folded the sharp anti-stall enforcement from a personal-repo `/next` command into `/finish` (rather than ship a second near-duplicate "stop stopping" command). Expanded the "Forbidden endings" list with the trailing-question stalls `/next` named ("Want me to continue?", "Should I do X next?", "Stopping here — let me know if you want more", and any steering-wheel-handback question), and added a new **"Required instead"** block: every turn ends with an action — `"Next: [doing X]"` with the tool call in the *same turn*, never a question — with `AskUserQuestion` reserved for genuine forks (forward-moving options only, never a "stop" option). `/finish` is now the single canonical anti-stall driver that ships to users; no separate `/next` is added (it would duplicate `/finish`).

## [0.1.29] - 2026-06-25

### Added
- **`commands/done.md`** — added a **"Update Docs"** step (new Step 4; Commit/PR → Release → Task Management → Handle Remaining → Recap renumber to 5–9). Graduated from a richer personal-repo `/done` so it ships to all users via the system layer: walk every changed file and update the docs that move with the code (`AGENTS.md`/`README`/`docs/`/`CHANGELOG`/help text/in-code descriptions), with an explicit "what does NOT need docs" list and anti-patterns (don't spawn new `.md` files, don't duplicate, don't write tutorials in the map file). The closing recap (Step 9) now expects a justification when the docs step is skipped. References use the system `/tickets` command (not the personal `/issues`).
## [0.1.28] - 2026-06-25

### Changed
- **De-dup of the command sprawl** in the completion/ship cluster (audit-driven). No behavior is lost; duplicates collapse to a single source of truth.
  - **`commands/commit.md` is now a thin alias of `/code:commit`.** The two had drifted — root `/commit` was the older "stage all + conventional message" version (67 lines), while `plugins/code/commands/commit.md` is the canonical superset (max micro-commit splitting + secrets/binary gate, 92 lines). `/commit` keeps its ergonomic name but now forwards to the one canonical definition; behavior changes go in the `code` plugin only.
  - **`commands/review.md` is now a thin alias of `/code:review`.** Same story — root `/review` (295 lines) duplicated the canonical `plugins/code/commands/review.md` (305 lines, adds anti-overengineering guardrails + a security pass on risk-touching diffs). `/review` keeps its name and forwards.
  - **`/done` and `/finish` now cross-reference and own one job each.** Added a "which one" pointer to the top of both: `/done` = closing checklist + ship gate (verify → commit → PR → optional release → close tickets, then ask what's next); `/finish` = anti-stopping driver (refuses to stop at a recap/blocker/partial handoff; no release step). Both point at `/code:loop` for draining a queue to merged.
  - **`code:loop` now documents its single-item "land one branch" mode** (`plugins/code/skills/loop/SKILL.md`), so there is no need for a separate `/land` or `/merge` command — landing one branch is `/code:loop` with a queue of one. Records the decision not to add `/code:land`.
  - Updated `README.md` and `commands/README.md` to label `/commit` and `/review` as aliases.

## [0.1.27] - 2026-06-25

### Changed
- **`plugins/git`** (plugin `0.1.0` → `0.2.0`) — built out the `git` plugin as the canonical home for pure git plumbing.
  - **Renamed `/git:cleanup` → `/git:prune`** so the plugin command matches the always-on top-level `/prune` (they remain twins that coexist, same as root `/commit` vs `code:commit`). Command logic and data-loss guards are unchanged — only the name moved (`commands/cleanup.md` → `commands/prune.md`).
  - **Added `/git:tag-release`** (`commands/tag-release.md`) — creates an annotated git tag for a release and pushes it to `origin`. Resolves the version from `$ARGUMENTS`, else the newest `CHANGELOG.md` heading, else `package.json`, else a confirmed bump of the last tag. Pure git plumbing: only `git tag -a` and `git push <tag>` — never force, never `--tags`, never deletes or re-points an existing tag (stops if the tag already exists). Delegates full package publishing (npm/CDN + changelog + build) to the `release` skill; this is the git-tag slice only.
  - Updated `plugin.json`, the plugin README, and the `marketplace.json` entry to describe both commands.
- Intentionally left out of the plugin: `/commit` (charter keeps it in `code`), the `git-workflow` skill (referenced by the always-on rules, so it stays an always-available system skill, not opt-in), and `/rebase-clean` (the `git-guard` hook denies `rebase` outside worktrees and interactive rebase is unsupported in-harness).

## [0.1.26] - 2026-06-24

### Added
- **`plugins/git`** — the `git` plugin now ships as a system default (migrated from `.agents-extras`). Pure git plumbing that isn't tied to code logic. Ships one command today, `/git:cleanup`: deletes merged branches and worktrees locally and on `origin` behind hard data-loss guards — it skips any worktree with uncommitted changes, a non-empty stash, unmerged commits, a lock, or a detached HEAD, and uses `git rev-list --count origin/$MAIN..HEAD == 0` as the load-bearing "nothing to lose" check (strictly stricter than `git branch --merged`, so squash-merged branches are treated as unsafe). Never uses `--force` on branch deletes or worktree removes; always shows the plan and asks before acting. Registered in `.claude-plugin/marketplace.json`. This is the future home for other git-only workflows (`/tag-release`, `/rebase-clean`); the code-aware loop (`/commit`, `/code:review`, `/code:sprint`) stays in the `code` plugin. The standalone top-level `/prune` command remains as the always-on default — same coexistence the repo already keeps between root `/commit` and `code:commit`.

## [0.1.25] - 2026-06-24

### Fixed
- **`plugins/code/skills/sprint/SKILL.md`** — the "Sibling references" section pointed at a `/swarm` command that does not exist; corrected to `/teams`, the actual parallel-teams command.
- **`plugins/code/.claude-plugin/plugin.json`** — removed an invalid `skills` field that is not part of the plugin manifest schema.

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
