---
name: scripts
description: "Scripts directory contract — canonical build/test/install/release.sh patterns for deployable projects. Triggers on: scripts/, release.sh, build.sh, deploy, publish."
user-invocable: false
---

# Scripts Directory Contract

Every deployable project keeps a `scripts/` directory. Use them. Don't reinvent.

## Canonical scripts

- `scripts/build.sh` — compile/bundle and run the test suite. Green build means tests passed.
- `scripts/test.sh` — full test suite, runnable on its own.
- `scripts/install.sh` — install dependencies, set up local config.
- `scripts/release.sh` — ship the artifact (npm publish, docker push, deploy).

## release.sh contract

- **Dry-run by default.** Without `--confirm`, print what it would do and exit 0.
- **`--confirm` is the only way to actually release.**
- **`--skip-build` / `--skip-tests`** are escape hatches; default runs both.
- **Refuses on test failure** unless `--skip-tests` was passed. Never silence checks with `|| true`.
- **Cheap checks first.** Version-collision (`npm view <pkg> versions --json`) before `bun test`. Missing-secrets check before `git push`.
- **Source of truth is the target system, not git.** Registry for npm, deploy registry for services.
- **Idempotent.** Re-running after interruption converges — no double-bump, no double-tag.

## Done means published

A release isn't done until the version shows up on the registry (or the deploy URL serves the new build). Code merged is not released.

## Anti-patterns

- Publishing without running tests by default.
- Detecting "already published" by `git log` instead of the registry.
- Running expensive checks before cheap ones.
- A `deploy.sh` with no dry-run that hits production on every invocation.
