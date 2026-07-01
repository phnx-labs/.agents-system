#!/bin/bash
# SessionStart hook: inject host + fleet topology into the model context.
#
# Every agent should know where it is running and what other machines it can
# reach, so it can dispatch work to a peer (`agents ssh <name>`) or surface an
# artifact on the machine the user actually sits at. The device list comes from
# `agents devices` (tailscale-backed, populated by the autosync). This hook is
# always-on and NOT gated on any keyword — it is pure context.
#
# Emitting to stdout is the injection mechanism: SessionStart stdout is folded
# into the model context on Claude/Codex (same convention the linear hook uses).
# Stay silent when there is nothing useful to say (no registry / no tailscale)
# so we never inject a bare, noisy block.

# Short hostname (first DNS label) + OS family of THIS machine.
SELF_HOST=$(hostname 2>/dev/null | cut -d. -f1)
case "$(uname -s 2>/dev/null)" in
  Darwin) SELF_OS=macos ;;
  Linux)  SELF_OS=linux ;;
  *)      SELF_OS=$(uname -s 2>/dev/null | tr '[:upper:]' '[:lower:]') ;;
esac

DEVICES_JSON=$(agents devices list --json 2>/dev/null)

SELF_HOST="$SELF_HOST" SELF_OS="$SELF_OS" python3 -c '
import json, os, sys

self_host = os.environ.get("SELF_HOST", "").strip()
self_os = os.environ.get("SELF_OS", "").strip()

raw = sys.stdin.read().strip()
devices = []
if raw:
    try:
        parsed = json.loads(raw)
        if isinstance(parsed, list):
            devices = parsed
    except Exception:
        devices = []

# Header line always establishes "where am I".
where = f"**{self_host}**" if self_host else "an unregistered host"
lines = []
lines.append("## Host & Fleet")
lines.append("")
lines.append(f"You are running on {where}" + (f" ({self_os})" if self_os else "") + ".")

if devices:
    lines.append("")
    lines.append("Machines you can reach (from `agents devices`):")
    lines.append("")
    for d in sorted(devices, key=lambda x: x.get("name", "")):
        name = d.get("name", "?")
        plat = d.get("platform", "unknown")
        ts = d.get("tailscale") or {}
        if name == self_host:
            reach = "this machine"
        elif ts.get("online"):
            reach = "online" + ("" if ts.get("direct") else " (relayed)")
        else:
            reach = "offline"
        lines.append(f"- {name} — {plat} — {reach}")
    lines.append("")
    lines.append(
        "Reach a peer with `agents ssh <name> [cmd]`. To show the user something "
        "visual (an HTML plan, a screenshot), open it on the online macOS device "
        "(where they sit) — SSH the file over and open it there if you are remote."
    )

print("\n".join(lines))
' <<< "$DEVICES_JSON"

exit 0
