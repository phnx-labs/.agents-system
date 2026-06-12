---
name: computer
description: Drive native macOS apps — screenshot windows, click, type, drag, read text. Uses the built-in `agents computer` command (Accessibility + ScreenCaptureKit daemon). Triggers on automating desktop apps (Photoshop, Parallels VMs, Finder, any non-browser GUI), "computer use", clicking/typing in a Mac app, or capturing an app window.
argument-hint: "[bundle-id]"
allowed-tools: Bash(agents computer*), Bash(sleep*)
user-invocable: true
---

# Computer Use — macOS App Automation

Drives native macOS apps through the Computer Helper daemon (Accessibility + ScreenCaptureKit + HID-tap event synthesis). macOS only. For websites use the `browser` skill; for Electron apps prefer `browser`'s `electron-use.md` (CDP beats pixel automation when available).

When you need exact flags, run `agents computer <verb> --help`.

## Preflight

```bash
agents computer status     # installed? daemon running? trust granted? policy?
agents computer setup      # one-time install to /Applications (then: start)
agents computer start      # boot the daemon (writes policy + peers, launchctl)
```

The daemon only drives **allow-listed** apps. `permission_denied` or `bundle not in allow list` means the target is missing from policy:

```bash
# Add to a permissions group, then reload
echo '  - "Computer(com.example.app)"' >> ~/.agents/permissions/groups/02-computer-apps.yaml
agents computer reload
```

Find a bundle id: `osascript -e 'id of app "AppName"'`.

## The Core Loop

Every interaction follows **observe → act → verify**. Never chain actions blind.

```bash
agents computer apps                                   # 1. what's running (allow-listed)
agents computer raise --bundle <id> --title "<win>"    # 2. bring the target forward
agents computer screenshot --bundle <id> --list --json # 3. enumerate windows
agents computer screenshot --bundle <id> --window-id <n> --out /tmp/s.jpg
agents computer describe --bundle <id>                 # 4. AX tree (element ids @eN)
agents computer click --bundle <id> --id @e7           # 5. act
agents computer screenshot ... --out /tmp/s2.jpg       # 6. VERIFY — re-capture, compare
```

A **byte-identical screenshot after an action means the action did not land**. Treat `ok:true` as "the event was posted", not "the app reacted" — only a visible state change is proof.

## Two Targeting Modes

**AX mode** (preferred): `describe` dumps the accessibility tree; element ids (`@eN`) feed `click --id`, `type --id`, `focus --id`, `ax-action`. Works for native AppKit apps.

**Coordinate mode** (fallback): for AX-opaque surfaces — **VM guests (Parallels), Chromium/UXP/canvas editors, games** — `describe` shows nothing useful inside them. Work from screenshots:

```
global_x = origin_x + pixel_x / scale
global_y = origin_y + pixel_y / scale
```

`origin` and `scale` are in every screenshot result (`--json` or the `saved:` line). Re-capture **after every raise or window move** — a window on an inactive fullscreen Space reports shifted global coords, so coordinates from a stale capture land in the wrong place.

## Focus Discipline (read this before typing)

Mouse clicks are HID-tap synthesized and need the target **visible on the active Space**. Keyboard (`type-text`, `key`) is posted to the pid and is **silently dropped by key-window-gated apps** (Parallels VMs and similar) when the app isn't frontmost.

- `raise` first. `--title` matches a window substring; bare raise activates the app.
- Add `--require-frontmost` to `type-text`/`key` whenever the target gates on key-window (VMs, anything that previously ate your keystrokes) — turns silent drops into a hard `not_frontmost` error.
- Every `type-text`/`key` result includes `"frontmost"`. A stderr warning or `frontmost:false` means the keystrokes probably landed nowhere — raise and retry, do not continue the chain.
- One-shot form: `type-text --raise --require-frontmost --text "..."`.
- Focus can be stolen **between** CLI calls (Space switches, user activity). If a mid-sequence step fails with `not_frontmost`, raise again; don't assume the earlier raise still holds.

## Verb Reference

| Verb | What | Key flags |
|---|---|---|
| `apps` | List drivable apps | `--json` |
| `launch` | Start an app | `--bundle` / `--path` / `--name` |
| `raise` | Bring app/window frontmost (switches Spaces) | `--window-id`, `--title` |
| `screenshot` | Capture window/display, or `--list` windows | `--window-id`, `--display`, `--out`, `--json` |
| `describe` | AX tree with element ids | `--depth` |
| `get-text` | Extract text without OCR | `--id`, `--max-chars` |
| `click` / `right-click` | Element or coordinate | `--id` \| `--x --y`; `--count 2` = double; `--raise` |
| `type` | Set an AX field value | `--id`, `--text`, `--commit` |
| `type-text` | Stream unicode keystrokes to the focused field | `--text`, `--commit`, `--raise`, `--require-frontmost` |
| `key` | Key chord (`enter`, `esc`, `cmd+shift+s`) | `--keys`, `--require-frontmost` |
| `drag` | Coordinate drag | `--from "x,y" --to "x,y"` |
| `scroll` | Scroll at element/coordinate | `--dy`/`--dx`, `--id` \| `--x --y` |
| `ax-action` | Any advertised AX action | `--id`, `--action AXConfirm` |
| `focus` | AX keyboard focus to an element | `--id` |
| `wait` | Sleep or poll for an element | `--duration` \| `--id --until` \| `--role/--label` |

## Failure-Mode Playbook

| Error / symptom | Meaning | Fix |
|---|---|---|
| `not_frontmost` | Keystrokes would be dropped | `raise` (with `--title` for the right window), retry |
| `window_offscreen` | Window on an inactive fullscreen Space; SCK can't capture | `raise --window-id <n>`, then re-screenshot |
| `element_not_found` (raise) | No AX window matched | `screenshot --list`, use the exact title substring |
| `element_stale` / dead `@eN` | UI changed since `describe` | Re-run `describe`, use fresh ids |
| `bundle not in allow list` | Policy gate | Add `Computer(<id>)` to a permissions group, `reload` |
| `rpc_timeout` | Daemon hung or stopped | `agents computer status`; `stop` + `start` |
| `ok:true` but screenshot unchanged | Event posted, app ignored it | Wrong coords (re-derive from a fresh capture) or window not key — raise, re-capture, retry |
| Typed text partially landed (VM guests) | Mid-stream focus blip | `key esc` to clear, retype with `--require-frontmost` |

## Worked Example: Drive a Windows VM (fully AX-opaque)

```bash
agents computer raise --bundle com.parallels.desktop.console --title "Windows 11" --json
agents computer screenshot --bundle com.parallels.desktop.console --list --json   # find window_id
agents computer screenshot --bundle com.parallels.desktop.console --window-id <n> --out /tmp/vm.jpg
# read /tmp/vm.jpg, pick a pixel target, map: global = origin + pixel/scale
agents computer click --bundle com.parallels.desktop.console --x 507 --y 960
agents computer type-text --bundle com.parallels.desktop.console --raise --require-frontmost --text "powershell"
agents computer key --bundle com.parallels.desktop.console --keys enter --require-frontmost
agents computer screenshot --bundle com.parallels.desktop.console --window-id <n> --out /tmp/vm2.jpg  # verify
```

## Safety Rails

- Password/secure fields are refused unless `type --allow-secure-field` is passed explicitly. Don't pass it unless the user asked you to fill a credential.
- System surfaces (`tccd`, SecurityAgent, System Settings) are hard-denied by the daemon — don't try to automate permission prompts.
- Destructive in-app actions (delete, send, purchase) follow the same rule as everywhere: verify state via screenshot before and after, and confirm with the user when irreversible.
