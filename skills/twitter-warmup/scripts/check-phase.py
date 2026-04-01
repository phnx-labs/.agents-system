#!/usr/bin/env python3
"""Compute current phase for Twitter warmup skill.

Reads ~/.twitter-warmup/state.yaml and outputs a structured phase briefing
consumed by both load-state.sh and gate.sh.

Usage:
    python3 check-phase.py              # Output phase briefing
    python3 check-phase.py --update     # Output + update state.yaml if phase changed
    python3 check-phase.py --json       # Output as JSON
"""

import sys
import os
from datetime import datetime, date
from pathlib import Path

STATE_FILE = Path.home() / ".twitter-warmup" / "state.yaml"

# Phase definitions: (min_days, min_followers)
PHASES = {
    1: {"min_days": 0, "min_followers": 0, "mode": "draft-only", "max_daily": 3, "links": False, "product_mentions": False},
    2: {"min_days": 14, "min_followers": 50, "mode": "direct", "max_daily": 5, "links": False, "product_mentions": "1-in-5"},
    3: {"min_days": 28, "min_followers": 200, "mode": "full", "max_daily": 7, "links": True, "product_mentions": True},
}


def parse_yaml_flat(path):
    """Minimal YAML parser for flat key-value state files."""
    data = {}
    current_section = None
    for line in path.read_text().splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if ":" in stripped:
            key, _, val = stripped.partition(":")
            val = val.strip().strip('"').strip("'")
            if val == "null" or val == "":
                val = None
            elif val == "true":
                val = True
            elif val == "false":
                val = False
            is_indented = line.startswith(" ") or line.startswith("\t")
            if not is_indented and val is None:
                # Section header (e.g., "account:" or "cooldown:")
                current_section = key.strip()
                data[current_section] = {}
            elif is_indented and current_section:
                # Indented key under a section
                data[current_section][key.strip()] = val
            else:
                # Top-level key with value (e.g., "phase: 1")
                current_section = None
                data[key.strip()] = val
    return data


def compute_phase(account_age_days, follower_count=0):
    """Determine phase based on age and followers. Both conditions must be met."""
    current = 1
    for phase_num in [3, 2]:
        reqs = PHASES[phase_num]
        if account_age_days >= reqs["min_days"] and follower_count >= reqs["min_followers"]:
            current = phase_num
            break
    return current


def update_state_file(state_path, new_phase):
    """Update phase in state.yaml."""
    lines = state_path.read_text().splitlines()
    updated = []
    for line in lines:
        if line.startswith("phase:"):
            updated.append(f"phase: {new_phase}")
        else:
            updated.append(line)
    state_path.write_text("\n".join(updated) + "\n")


def main():
    if not STATE_FILE.exists():
        print("ERROR: ~/.twitter-warmup/state.yaml not found. Run init.sh first.", file=sys.stderr)
        sys.exit(1)

    state = parse_yaml_flat(STATE_FILE)
    account = state.get("account", {})
    created_at_str = account.get("created_at")

    if not created_at_str:
        print("ERROR: account.created_at missing from state.yaml", file=sys.stderr)
        sys.exit(1)

    created_at = date.fromisoformat(created_at_str)
    today = date.today()
    account_age = (today - created_at).days

    # Follower count: try to fetch, default to 0
    follower_count = 0
    # TODO: optionally call `rush http GET /api/v1/twitter/users/@GetRushOS` for real count

    stored_phase = int(state.get("phase", 1))
    computed_phase = compute_phase(account_age, follower_count)
    phase_info = PHASES[computed_phase]

    should_update = "--update" in sys.argv
    as_json = "--json" in sys.argv

    if as_json:
        import json
        output = {
            "phase": computed_phase,
            "mode": phase_info["mode"],
            "max_daily": phase_info["max_daily"],
            "links_allowed": phase_info["links"],
            "product_mentions": phase_info["product_mentions"],
            "account_age_days": account_age,
            "follower_count": follower_count,
            "phase_changed": computed_phase != stored_phase,
        }
        print(json.dumps(output))
    else:
        print(f"PHASE: {computed_phase}")
        print(f"MODE: {phase_info['mode']}")
        print(f"MAX_DAILY: {phase_info['max_daily']}")
        print(f"LINKS_ALLOWED: {str(phase_info['links']).lower()}")
        print(f"PRODUCT_MENTIONS: {phase_info['product_mentions']}")
        print(f"ACCOUNT_AGE_DAYS: {account_age}")
        print(f"FOLLOWER_COUNT: {follower_count}")
        if computed_phase != stored_phase:
            print(f"PHASE_CHANGED: {stored_phase} -> {computed_phase}")

    if should_update and computed_phase != stored_phase:
        update_state_file(STATE_FILE, computed_phase)
        if not as_json:
            print(f"Updated state.yaml: phase {stored_phase} -> {computed_phase}")


if __name__ == "__main__":
    main()
