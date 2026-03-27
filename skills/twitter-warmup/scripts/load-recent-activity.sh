#!/bin/bash
# Load recent activity from ~/.twitter-warmup/log/

DAYS=${1:-7}
LOG_DIR="$HOME/.twitter-warmup/log"

if [ ! -d "$LOG_DIR" ]; then
  echo "No activity logs found."
  exit 0
fi

python3 - "$LOG_DIR" "$DAYS" << 'PYEOF'
import sys, re
from datetime import date, timedelta
from pathlib import Path

log_dir = Path(sys.argv[1])
days = int(sys.argv[2])
cutoff = date.today() - timedelta(days=days)

files = sorted(log_dir.glob("*.yaml"))
files = [f for f in files if f.stem >= cutoff.isoformat()]

if not files:
    print(f"ACTIVITY (last {days} days): no logs found")
    sys.exit(0)

print(f"ACTIVITY (last {days} days):")
print()

totals = dict(replies=0, standalone=0, qrts=0, likes=0, followers=0, days=0)

for f in files:
    text = f.read_text()
    replies = len(re.findall(r"^\s*- to:", text, re.MULTILINE))

    standalone_match = re.search(r"^standalone:\s*\n((?:\s+- .+\n)*)", text, re.MULTILINE)
    standalone = standalone_match.group(1).count("- tweet_url:") if standalone_match else 0

    qrt_match = re.search(r"^quote_tweets:\s*\n((?:\s+- .+\n)*)", text, re.MULTILINE)
    qrts = qrt_match.group(1).count("- ") if qrt_match else 0

    likes = 0
    m = re.search(r"likes_received:\s*(\d+)", text)
    if m: likes = int(m.group(1))

    followers = 0
    m = re.search(r"new_followers:\s*(\d+)", text)
    if m: followers = int(m.group(1))

    engaged = ""
    m = re.search(r"targets_engaged:\s*\[([^\]]*)\]", text)
    if m: engaged = m.group(1).replace('"', '').replace("'", "").strip()

    print(f"  {f.stem}: {replies} replies, {standalone} standalone, {qrts} QRTs | likes: {likes} | new followers: {followers}")
    if engaged:
        print(f"    engaged: {engaged}")

    totals["replies"] += replies
    totals["standalone"] += standalone
    totals["qrts"] += qrts
    totals["likes"] += likes
    totals["followers"] += followers
    totals["days"] += 1

print()
print(f"TOTALS ({totals['days']} active days): {totals['replies']} replies, {totals['standalone']} standalone, {totals['qrts']} QRTs")
print(f"ENGAGEMENT: {totals['likes']} likes received, {totals['followers']} new followers")
PYEOF
