#!/usr/bin/env python3
"""Sync operational state back into ~/.twitter-warmup/state.yaml.

Reads Emma's daily files (if accessible) and updates last_session.
Also runs check-phase to ensure phase is current.

Usage:
    python3 sync-state.py                    # Update last_session to today
    python3 sync-state.py --from-emma        # Read Emma's daily files via ssh (mac-mini)
"""

import sys
import subprocess
from datetime import date
from pathlib import Path

STATE_FILE = Path.home() / ".twitter-warmup" / "state.yaml"


def update_last_session(state_path, session_date):
    """Update last_session in state.yaml."""
    lines = state_path.read_text().splitlines()
    updated = []
    found = False
    for line in lines:
        if line.startswith("last_session:"):
            updated.append(f'last_session: "{session_date}"')
            found = True
        else:
            updated.append(line)
    if not found:
        updated.append(f'last_session: "{session_date}"')
    state_path.write_text("\n".join(updated) + "\n")


def main():
    if not STATE_FILE.exists():
        print("ERROR: ~/.twitter-warmup/state.yaml not found.", file=sys.stderr)
        sys.exit(1)

    today = date.today().isoformat()

    if "--from-emma" in sys.argv:
        # Try to read Emma's latest daily file via ssh
        try:
            result = subprocess.run(
                ["ssh", os.environ.get("BROWSER_SSH_USER", "muqsit") + "@" + os.environ.get("BROWSER_SSH_HOST", "mac-mini"),
                 f"ls ~/.openclaw/emma/state/daily/ 2>/dev/null | sort | tail -1"],
                capture_output=True, text=True, timeout=10
            )
            latest = result.stdout.strip()
            if latest:
                session_date = latest.replace(".yaml", "")
                print(f"Latest Emma session: {session_date}")
            else:
                session_date = today
                print(f"No Emma daily files found, using today: {today}")
        except (subprocess.TimeoutExpired, FileNotFoundError):
            session_date = today
            print(f"Could not reach mac-mini, using today: {today}")
    else:
        session_date = today

    update_last_session(STATE_FILE, session_date)
    print(f"Updated last_session to {session_date}")

    # Run check-phase to ensure phase is current
    check_phase = Path(__file__).parent / "check-phase.py"
    if check_phase.exists():
        subprocess.run([sys.executable, str(check_phase), "--update"])


if __name__ == "__main__":
    main()
