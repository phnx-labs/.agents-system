---
description: Pull every registered DotAgent repo to latest across the whole fleet, refresh agents, and report drift — without ever clobbering local work.
---

Sync the fleet. Optional arguments: $ARGUMENTS (a device name or repo alias to scope to; default = all online devices, all registered repos).

## Goal

Bring **every registered DotAgent repo** — `system`, `user`, and any team/extra a
device registered (`agents repos add`) — up to `origin` latest on **every online
device**, then refresh the installed agents. End state: no device is behind on any
repo, and a matrix shows exactly what synced, what's blocked by local edits, and
what's unreachable.

This is a curated recipe on top of `agents devices run` / `agents repo` — its value
is the fast-forward workaround, the per-platform handling, the throttle retry, and
the honest report. **Do not reinvent the fan-out engine.**

## HARD LINE — NEVER CLOBBER LOCAL WORK

`user` and team repos are **user-authored** — people edit hooks, workflows, routines,
and config in them, and every machine carries *different* local drift (verified: a
real `user` repo can have a dozen uncommitted changes). So:

- **`git merge --ff-only` and nothing else.** It fast-forwards when safe and *aborts
  cleanly* when local changes would be overwritten. That abort is a feature — report
  it, never defeat it.
- **NEVER** `git reset --hard`, `git checkout -- .`, `git clean`, `git stash`, `git
  pull` (which can merge-commit), or any `--force`. Not to "make sync work." Ever.
- A repo that can't fast-forward because of local edits is a **`blocked (local
  changes)`** cell in the report, not a thing to force. The cost of skipping is zero;
  the cost of clobbering is irreversible.
- Do **not** auto-commit or push a device's local edits to propagate them. That's a
  separate, explicit opt-in (`fleet:sync --push`, not in scope here).

## Process

### 1. Orient (on the machine you're running from)

- `agents repos list` — the registered repos + their local git state.
- `agents devices list` — the fleet; note which are **online** and their platform
  (linux/macos/windows). Skip offline devices (report them as `unreachable`).
- If `$ARGUMENTS` names a device or repo alias, scope to it.

### 2. Sync each online device

Run the per-device block below **in parallel** across devices (they're independent).
For each device, discover *that device's* repos with `agents repos list` (repo sets
can differ per machine — a repo missing on a device is `not registered`, a job for
`fleet:onboard`, not sync).

**On the device that is macOS/Linux** — run over `agents ssh <dev>` with a **login
shell** (`bash -lc "…"`) so agents-cli is on PATH:

```bash
# For each registered repo path R on the device (system=~/.agents/.system,
# user=~/.agents, extra=~/.agents-<alias>):
DEF=$(git -C "$R" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##')
git -C "$R" fetch origin --quiet            # retry ONCE on transient GitHub SSH throttle (see below)
BEFORE=$(git -C "$R" rev-parse --short HEAD)
git -C "$R" merge --ff-only "origin/$DEF"   # non-destructive; may abort on local drift
AFTER=$(git -C "$R" rev-parse --short HEAD)
# classify: synced (BEFORE!=AFTER) | up-to-date (already current) |
#           blocked (merge printed "Not possible to fast-forward" / "local changes")
```
Then **once per device, after all its repos**: `agents repo refresh` (materializes
the pulled skills/commands/plugins into the installed agent homes).

**On a Windows device** — PowerShell over `agents ssh <dev>`, and mind the quoting
that bites (learned the hard way): use `Set-Location` then **plain `git`** (not
`git -C`), and **no nested double-quotes** inside `powershell -Command "…"`:

```powershell
Set-Location $env:USERPROFILE\.agents\.system; git fetch origin; git merge --ff-only origin/main
```
(repeat per repo path; then `agents repo refresh`).

### 3. Gotchas — bake these in, don't rediscover them

- **`agents repo pull <alias>` does NOT fast-forward** (known bug). That's why this
  command uses `git merge --ff-only origin/<default>` directly. (Upstream fix belongs
  in agents-cli; until then, this is the workaround.)
- **Transient GitHub SSH throttle:** a `fetch` can fail with
  `kex_exchange_identification: read: Software caused connection abort`. It's not a
  real outage — TCP:22 and auth are fine. **Retry the fetch once** before marking the
  repo/device failed.
- **Non-interactive PATH:** a bare `agents ssh <dev> 'agents …'` may not find
  agents-cli. Use `bash -lc "…"` (posix) so the login PATH is loaded.

### 4. Report — a repo × device matrix

```
FLEET SYNC — <N> devices · <M> repos

device          system      user        <extra>
zion            ✓ synced    ⏸ blocked   —
yosemite-s0     ✓ up-to-date ✓ synced   ✓ synced
yosemite-m3     ✓ synced    ⏸ blocked   · not registered
win-mini        ✓ synced    ✓ up-to-date —
mac-mini        ⚠ unreachable
```
Legend: `✓ synced` (fast-forwarded) · `✓ up-to-date` · `⏸ blocked (local changes)` ·
`· not registered` · `⚠ unreachable`. For every `⏸ blocked` cell, list the device,
repo, and the first line of `git status --porcelain` so the user can resolve it. End
with a one-line summary: how many device×repo pairs advanced, how many are blocked on
local drift, how many devices were unreachable.

## Safety rules (non-negotiable)

- `git merge --ff-only` only. Never `reset --hard`, `checkout -- .`, `clean`, `stash`,
  `pull`, or any `--force` — not even to make a stubborn repo sync.
- Never auto-commit or push a device's local changes in `sync` (that's `--push`, out
  of scope).
- A repo that won't fast-forward is **reported, not forced**.
- Refresh agents **after** the repos pull, once per device.
- Offline/unreachable device → report it, never block the rest of the fleet.
- A repo not registered on a device is a `fleet:onboard` job — note it, don't clone it
  here.
