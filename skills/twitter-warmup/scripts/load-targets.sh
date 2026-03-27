#!/bin/bash
# Load and display targets from ~/.twitter-warmup/targets.yaml

TARGETS_FILE="$HOME/.twitter-warmup/targets.yaml"

if [ ! -f "$TARGETS_FILE" ]; then
  echo "TARGETS: No targets file. Run init.sh first."
  exit 0
fi

python3 - "$TARGETS_FILE" << 'PYEOF'
import sys
from datetime import date
from pathlib import Path

text = Path(sys.argv[1]).read_text()
now = date.today()

blocks = text.split("- handle:")[1:]
tier_due = {1: [], 2: [], 3: []}

for block in blocks:
    lines = block.strip().splitlines()
    handle = lines[0].strip().strip('"').strip("'")
    fields = {}
    for line in lines[1:]:
        if ":" in line:
            key, _, val = line.strip().partition(":")
            fields[key.strip()] = val.strip().strip('"').strip("'")

    name = fields.get("name", "")
    tier = int(fields.get("tier", "3"))
    topics = fields.get("topics", "").strip("[]")
    last = fields.get("last_engaged", "null")

    days_since = "never"
    is_due = True

    if last and last != "null":
        try:
            days = (now - date.fromisoformat(last)).days
            days_since = f"{days}d ago"
            if tier == 1 and days <= 2: is_due = False
            elif tier == 2 and days <= 4: is_due = False
        except ValueError:
            pass

    entry = f"  {handle} | {name} | topics: {topics} | last: {days_since}"
    if is_due or tier == 3:
        tier_due[tier].append(entry)

total = sum(len(v) for v in tier_due.values())
print(f"DUE FOR ENGAGEMENT ({total} targets):")
print()

for t, label in [(1, "TIER 1 — engage this session"), (2, "TIER 2 — engage if time"), (3, "TIER 3 — monitor, engage if natural")]:
    if tier_due[t]:
        print(f"{label} ({len(tier_due[t])}):")
        for e in tier_due[t]: print(e)
        print()

if total == 0:
    print("(all targets recently engaged — discover new ones this session)")
PYEOF
