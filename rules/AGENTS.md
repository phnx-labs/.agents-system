# Core Hard Lines (Tier 1)

> Tier 1 of 3 — companion tiers: `code-quality` (Tier 2), `operational` (Tier 3).

Non-negotiable. Ordered by impact.

1. **"Done" means end-to-end.** Not "code written" or "unit tests pass." Trigger the real flow and see real output. If a blocker prevents testing, work around it — reduce scope, override config, run the command directly. Re-read the conversation and verify every goal before claiming done. If you can't prove it works, say what's unverified.

2. **No unverified claims.** Every factual claim — code, counts, sizes, API capabilities — needs proof: file path, line number, code quoted from this conversation. "I think there are 26 files" is a violation. Run the tool, then report. When in doubt, spawn subagents — cost is irrelevant, correctness is everything.

3. **No lazy debugging.** Read every file in the data path. If data flows A → B → C → D, read all four and present file:line quotes from each.

4. **No fallbacks, no band-aids.** Never add "just in case" code paths. Standardize at the source. Every fallback hides a bug.

5. **Current date anchoring.** Your weights are stale. The real date is in the system prompt under `currentDate`. Every web query about state-of-the-world (models, APIs, prices, libraries, releases) must include the current YEAR.

6. **Web-search first for time-sensitive claims.** WebSearch before answering, not "if the user asks." Load search tools eagerly at session start: `ToolSearch select:WebSearch,WebFetch`.

7. **Ban Haiku for subagents.** Always set `model` explicitly on Agent calls. Default `"sonnet"`, use `"opus"` for load-bearing work. Omission falls through to subagent frontmatter, which may pin haiku.

8. **Investigation briefs demand evidence.** Every Agent prompt for investigation/debugging/review must end with: `Return file:line quotes for every claim. Do NOT paraphrase. If you can't quote it, don't claim it.`

9. **Exhaust alternatives before declaring a blocker.** "I cannot do X. Period." is banned without three distinct attempts quoted. The fix is almost never "ask the user" — it's "try a different launch path."

10. **Never ask the user to verify env state you can check yourself.** You have the same shell, OS, and files. List, query, probe, dump.

11. **Parallelize from message one for multi-dimensional questions.** Multiple files, cross-platform, audit, ship-readiness, parity check, root-cause across a stack — spawn 3-7 Agent subagents in parallel in your first response. About to write a third sequential Bash investigation call? Stop and spawn agents instead.

# Proactive Workflow

**Pattern: ACT → VERIFY → SHOW → CONTINUE.**

- See a problem? Investigate, fix it. Don't ask permission for obvious fixes.
- Path clear? Take it. Don't narrate — do.
- Unsure which path? Decide, state reasoning in one line, continue. User will redirect.

**Never say:** "I noticed X — would you like me to investigate?" You should have already.

## Don't stop mid-task

After ACT → VERIFY → SHOW the next step is CONTINUE, not pause. Stopping is for:
- Hard blockers (quote the obstacle and three attempts to work around it)
- Genuine ambiguity in user intent (not "shall I proceed?")
- Task is actually delivered end-to-end (committed, pushed, PR open, real-flow verified)

If the user types "check", "continue", or "status?" — you missed this rule.

**`AskUserQuestion` is not an off-ramp.** Use it only for genuine intent ambiguity. Not for "should I do the obvious next step?"

## Waiting

- Short waits (<2 min): `sleep 45 && echo "checking..."`
- Long waits (2+ min): `run_in_background: true` with echo sleeve — `long-cmd && echo "DONE — next: <action>"`

## Design before code

Only for *new* design (UI flow, architecture, pipeline shape). Show mockup/diagram, then ship. For follow-ups and edits, skip the design step — go straight to code.

# Code Quality (Tier 2)

> Tier 2 of 3 — companion tiers: `core-hard-lines` (Tier 1), `operational` (Tier 3).

- **No duplicate code.** Search before writing. Use or extend what exists.
- **No scope creep.** Do exactly what was asked. No drive-by refactors, renames, or import reorganization.
- **Cross-cutting changes go to the source.** Edit the canonical location, never ad-hoc logic in consumers. If no central place exists, propose refactoring first.
- **User-facing text must be human.** "13 minutes" not "12m 49s", "30 seconds" not "30.0s". If a grandmother can't parse it, rewrite it.

# Strict Testing

- **Test file = source file, 1:1.** `read.go` → `read_test.go`, `parser.ts` → `parser.test.ts`.
- **Tests live in the codebase, not `/tmp`.** Fixtures in `testdata/` near source.
- **No mocking.** Real services only. Tests must exercise the actual critical path.
- **Only tests that catch real bugs:** merge logic, state corruption, algorithmic edges. Skip constants and trivial guards — if the test would pass with a broken implementation, it's ceremony.
- **Unit tests are necessary, not sufficient.** Verify end-to-end (core-hard-lines #1).

# Git: Read-only + Commit/Push Only

Allowed: `status`, `diff`, `log`, `show`, `remote`, `ls-files`, `cat-file`, `rev-parse`, `describe`, `shortlog`, `blame`, `tag`, `check-ignore`, `config --get`, `ls-tree`, `add`, `commit`, `push`, `clone`, `fetch`, `worktree list`, `worktree add`, `worktree remove`.

Off-limits without explicit user ask: `checkout`, `switch`, `branch`, `stash`, `reset`, `rebase`, `cherry-pick`, `revert`, `merge --abort`, `clean`, `reflog`, `filter-branch`, `gc`, `prune`, `fsck`, `config` (write), force push.

**Why:** autonomous agents have caused real data loss with `git reset --hard`, `git checkout -- .`, and force pushes. Fast, irreversible, hard to audit.

**On obstacles** (merge conflict, lock file, unexpected state): investigate and resolve at the source. Don't `git reset` or `git clean` as a shortcut — that's how in-progress work disappears.

**Never stash — commit instead.** Uncommitted working-tree changes get committed properly via the `/code:commit` skill (maximum small logical commits), never `git stash`. Stash hides work somewhere easy to lose or forget; a commit is durable, reviewable, and recoverable.

**Uncommitted changes on `main` → commit + WIP PR.** If the `main` branch or the main working tree has uncommitted changes, don't leave them dirty and don't commit straight to `main`: commit them (via `/code:commit` or the relevant skill) on a branch/worktree and open a **WIP pull request**. In-progress work belongs in a reviewable PR, never as a dirty working tree or a direct-to-`main` commit.

**Reconcile with rebase — `reset --hard` is never run.** To bring a behind/diverged local branch up to its upstream, use `git pull --rebase` / `git rebase origin/<branch>`: it replays local commits and drops only those already upstream (patch-id match), preserving any genuinely unique work. **Never run `git reset --hard`, period** — it discards commits unconditionally and irrecoverably. `rebase` still needs explicit user OK per the deny list above, and the `git-guard` hook blocks it on the agent's own shell — so hand a rebase to the user to run via the `!` session prefix (`!git -C <repo> rebase origin/<branch>`), which bypasses the agent hook.

# Agentic Git Workflow

PR-bound work runs in an isolated worktree, never in the user's checkout.

- **Use a worktree, not a branch in place.** PR work goes in `<repo>/.agents/worktrees/<slug>/`. Don't create a branch in place, don't switch the user's checkout, don't ask the user to run git. `checkout`/`switch`/`branch`/`reset` are on the `git-readonly` deny list; `git worktree add -b` is the allowed, isolated branch-creation path.
- **Base off the real default branch.** Don't `checkout main` or `git pull` first — `pull` mutates the checkout. `git fetch`, resolve the default branch dynamically (`git symbolic-ref refs/remotes/origin/HEAD`) — never hardcode `main` — and create the worktree from `origin/<default-branch>`.
- **End-to-end inside `$WT`.** Implement → test → verify the real flow (core-hard-lines #1) → commit → push → open PR, all in the worktree. The deny list still applies (`reset`/`rebase`/`stash` off-limits).
- **PR open is not "done" — but merging is autonomous on green.** A reviewer that is **not** the author reviews the diff and runs the real tests/CI. If the review is clean **and** tests pass, squash-merge and clean up the worktree without asking. Only fall back to `AskUserQuestion` (request changes / iterate) when the review finds problems, tests fail, or the merge conflicts. Post the merged URL when done. Don't remove the worktree or delete the branch until merge.

Full recipe — worktree creation, PR, after-merge cleanup: the `git-workflow` skill.

# Operational Guardrails (Tier 3)

> Tier 3 of 3 — companion tiers: `core-hard-lines` (Tier 1), `code-quality` (Tier 2).

- **Ask about scope; decide about implementation.** Unclear what the user wants (requirements, scope, priorities)? Ask — 30 seconds beats hours of wrong work. Unclear *how* to implement what they asked for? Decide, state reasoning briefly, keep going (see `workflow-proactive`).
- **No emojis** in code, comments, commits, or user-facing output — unless explicitly asked.
- **No credentials in env vars or config.** Use `agents secrets` (OS keychain-backed).
- **No locally built CLIs.** Install globally (`npm i -g`, `cargo install`); don't invoke `./bin/foo`.
- **No background shells left running.** Foreground or explicit `run_in_background` with a finish signal.
- **No toasts.** Silent success, inline errors.
- **No unsolicited .md files.** No README/docs/summary/notes unless asked.
- **Permissions:** Add permanent agent permissions to settings once; don't re-prompt across sessions.
- **Images:** Include the full file path so the user can click to preview.
- **Hand off commands the user must run — don't just print them.** Markdown code fences aren't executable. Prefer, in order: (1) pipe to the clipboard (`pbcopy` on macOS, `xclip -selection clipboard` / `wl-copy` on Linux) and tell the user "copied — paste it"; (2) write a one-shot script to a temp path (`mktemp` or `/tmp/<slug>.sh`), `chmod +x` it, and tell them to run that single path; (3) only as last resort, render the command in the message. Multi-line commands always go to a script. Quote what you copied so the user can verify before pasting.
- **Don't:** start/kill dev servers without asking; add backwards-compat shims you weren't asked for; reach for `find` when a faster finder like `fd` is available.

# Conventions

- **Memory file:** `AGENTS.md` is canonical. `CLAUDE.md` and `GEMINI.md` are symlinks (or synced copies).
- **Tickets:** Linear context is auto-injected at session start by the linear hook — read it before starting work. Use `/tickets` to take explicit action (query, update, close) on tickets across Linear/GitHub/Jira. Close only with proof.
- **Parallel work:** Multi-surface changes use `agents teams` — see `parallel-teams`.

# agents-cli

- **Agent home dirs are symlinks.** `~/.claude/`, `~/.codex/`, etc. point into `~/.agents/versions/{agent}/{version}/home/`. Source of truth for shared config (commands, skills, hooks, memory, MCP) is `~/.agents/` — go there to inspect or modify.
- **Recall prior work with `agents sessions`.** Search by topic/repo before starting. Use `--include`/`--exclude` to filter roles. `agents sessions --help` for full flags.
- **Check active agents before spawning new ones.** `agents sessions --active` lists everything running right now (terminals, teams, cloud, headless).

# Parallel Work via `agents teams`

Default to teams for changes touching 3+ independent surfaces. Single-threaded editing is the failure mode.

**Skip for:** exploration (use `Agent` subagents), single-surface bugs, plan-mode research.

## Boundary contracts are mandatory

Before spawning, present a distribution plan. Each teammate needs:

- **Owns** — explicit files.
- **Must NOT touch** — files owned by others.
- **Shared deps** — one canonical owner; everyone else imports.

If A waits on B's output to start, the split is wrong. Re-cut, or sequence with `--after`.

## Pattern

```bash
agents teams create my-feature
agents teams add my-feature claude "Owns: src/auth/*. Not: src/ui/*. ..." --name auth
agents teams add my-feature codex  "Owns: src/ui/*. Not: src/auth/*. ..." --name ui --after auth
agents teams start my-feature --watch
```

Every brief includes Mission, Full scope, Owns, Must NOT touch, concrete code pattern, success criteria, and ends with the line from core-hard-lines #8. The `/teams` command is the long-form playbook.

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

