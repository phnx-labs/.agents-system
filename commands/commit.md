---
description: Stage all changes, commit with a conventional-commit message, and push in the background.
---

Commit and push. Arguments (optional): $ARGUMENTS

## Style

Conventional commits: `<type>: <description>`

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `build`, `release`, `chore`

Match the voice of these examples:

- feat: add user authentication with jwt tokens
- fix: resolve null pointer exception in payment handler
- docs: update api reference for v2 endpoints
- build: configure webpack for production optimization
- refactor: extract validation logic into separate module
- fix: correct timezone handling in date formatter
- feat: implement real-time notifications via websockets
- release: bump version to 1.2.0 for stable release
- refactor: simplify error handling in api client
- docs: add examples for configuration options

Rules:

- Under 72 characters. Lowercase. Imperative mood. Single line only — no bodies, ever.
- No emojis. No scope prefix like `feat(api):` — just `feat:`.
- **NEVER add `Co-Authored-By:` lines.** Not for Claude, Claude Code, Codex, GPT, Anthropic, any AI tool, or any bot. The commit is authored by the user — period.
- No "Generated with Claude Code" or similar trailers.

## Process

1. Run `git status` and `git diff` (staged + unstaged) in parallel.
2. If nothing to commit, say so and stop. Do not create an empty commit.
3. **Group the changes.** Scan the diff and cluster files that belong together into logical groups. Each group becomes one commit. A group is "one thing": a feature, a fix, a refactor scoped to one area, a docs pass. Unrelated changes (e.g. a hook tweak + a blog post + a bug fix) must NOT be lumped into a single commit.
4. **Safety check:** if a sensitive file is present (`.env`, `credentials.json`, `*.key`, `*.pem`, `id_rsa*`), warn the user and stop — don't commit it.
5. For each group:
    - `git add <files-in-group>` (explicit, not `-A`)
    - Pick one conventional-commit message for that group. Single line. No analysis paragraph.
    - `git commit -m "<message>"`
6. After all commits: single `git push` with `run_in_background: true`. Never block the conversation on the push. The user gets a notification when it finishes.

**Heuristics for grouping:**

- Same directory / same feature area → one group.
- Tests + the code they test → same group.
- A config change that enables a feature + the feature code → same group.
- Docs + the thing they document → same group IF tight coupling; separate if docs are standalone updates.
- Unrelated bug fixes in different areas → separate commits.
- Formatting/lint-only changes → separate `chore:` commit.

If the entire diff is genuinely one thing, one commit is fine. Don't fabricate groups.

## Ignore these paths when reasoning about the diff

`node_modules`, `dist`, `build`, `out`, `.git`, `*.lock`, `bun.lock`, `package-lock.json`, `*.vsix`

## Don'ts

- Don't lump unrelated changes into one commit. Group them.
- Don't fabricate groups when the diff is genuinely one thing — one commit is fine then.
- Don't ask "should I commit?" — the slash command IS the ask.
- Don't verify build/tests pre-commit — that's the user's job.
- Don't use `--no-verify` unless `$ARGUMENTS` contains `no-verify`.
- Don't run push in the foreground. It always goes in the background.
