---
description: Alias for /code:commit — split changes into the maximum number of small logical commits (one concept per commit) and push in the background.
---

**`/commit` is an alias of `/code:commit`.** There is one commit command, defined once in the `code` plugin; this is the convenience short name so you don't have to type the namespace.

Apply the full `/code:commit` procedure to `$ARGUMENTS`. In brief:

- Default: **maximum micro-commits** — one concept per commit, split as aggressively as the diff allows; any group larger than ~2 files must justify staying together. Pass `squash` or `chunky` in `$ARGUMENTS` for coarser groups.
- Conventional-commit messages, single line, imperative, under 72 chars. **Never** add `Co-Authored-By:` or any AI-attribution / "Generated with" trailer — the commit is authored by the user.
- Explicit `git add <files>` per group (not `-A`); stop and warn if a secret file (`.env`, `*.key`, `*.pem`, `id_rsa*`) is staged.
- After all commits, a single `git push` with `run_in_background: true` — never block on the push.

The canonical, authoritative definition lives at `plugins/code/commands/commit.md`. Make behavior changes **there**, not here — this file only forwards to it.
