#!/usr/bin/env python3
"""Lightweight evaluation of Twitter warmup activity.

Reads log/*.yaml files and aggregates metrics. No API calls needed.

Usage:
    python3 evaluate.py              # Evaluate all available logs
    python3 evaluate.py --days 7     # Evaluate last 7 days only
"""

import sys
import re
from datetime import date, timedelta
from pathlib import Path

LOG_DIR = Path.home() / ".twitter-warmup" / "log"
EVAL_DIR = Path.home() / ".twitter-warmup" / "evaluation"


def parse_log(path):
    """Extract metrics from a daily log file."""
    text = path.read_text()
    metrics = {
        "date": path.stem,
        "replies": 0,
        "standalone": 0,
        "quote_tweets": 0,
        "likes_received": 0,
        "replies_received": 0,
        "profile_visits": 0,
        "new_followers": 0,
        "targets_engaged": [],
    }

    # Count replies (lines with "- to:")
    metrics["replies"] = len(re.findall(r"^\s*- to:", text, re.MULTILINE))

    # Count standalone (lines under standalone: section with "- tweet_url:")
    standalone_match = re.search(r"^standalone:\s*\n((?:\s+- .+\n)*)", text, re.MULTILINE)
    if standalone_match:
        metrics["standalone"] = standalone_match.group(1).count("- tweet_url:")

    # Metrics observed
    for key in ["likes_received", "replies_received", "profile_visits", "new_followers"]:
        match = re.search(rf"^\s*{key}:\s*(\d+)", text, re.MULTILINE)
        if match:
            metrics[key] = int(match.group(1))

    # Targets engaged
    targets_match = re.search(r"^targets_engaged:\s*\[([^\]]*)\]", text, re.MULTILINE)
    if targets_match:
        handles = [h.strip().strip('"').strip("'") for h in targets_match.group(1).split(",") if h.strip()]
        metrics["targets_engaged"] = handles

    return metrics


def main():
    if not LOG_DIR.exists():
        print("No log directory found at ~/.twitter-warmup/log/")
        sys.exit(1)

    days_limit = None
    if "--days" in sys.argv:
        idx = sys.argv.index("--days")
        if idx + 1 < len(sys.argv):
            days_limit = int(sys.argv[idx + 1])

    log_files = sorted(LOG_DIR.glob("*.yaml"))
    if not log_files:
        print("No log files found.")
        sys.exit(0)

    if days_limit:
        cutoff = (date.today() - timedelta(days=days_limit)).isoformat()
        log_files = [f for f in log_files if f.stem >= cutoff]

    # Aggregate
    totals = {
        "days_logged": 0,
        "total_replies": 0,
        "total_standalone": 0,
        "total_quote_tweets": 0,
        "total_likes": 0,
        "total_replies_received": 0,
        "total_profile_visits": 0,
        "total_new_followers": 0,
        "target_engagement_count": {},
    }

    daily = []
    for f in log_files:
        m = parse_log(f)
        daily.append(m)
        totals["days_logged"] += 1
        totals["total_replies"] += m["replies"]
        totals["total_standalone"] += m["standalone"]
        totals["total_quote_tweets"] += m["quote_tweets"]
        totals["total_likes"] += m["likes_received"]
        totals["total_replies_received"] += m["replies_received"]
        totals["total_profile_visits"] += m["profile_visits"]
        totals["total_new_followers"] += m["new_followers"]
        for t in m["targets_engaged"]:
            totals["target_engagement_count"][t] = totals["target_engagement_count"].get(t, 0) + 1

    # Output
    print(f"=== Evaluation ({totals['days_logged']} days logged) ===")
    print(f"Date range: {log_files[0].stem} to {log_files[-1].stem}")
    print()
    print(f"Total posts: {totals['total_replies'] + totals['total_standalone'] + totals['total_quote_tweets']}")
    print(f"  Replies: {totals['total_replies']}")
    print(f"  Standalone: {totals['total_standalone']}")
    print(f"  Quote tweets: {totals['total_quote_tweets']}")
    print()
    print(f"Engagement received:")
    print(f"  Likes: {totals['total_likes']}")
    print(f"  Replies: {totals['total_replies_received']}")
    print(f"  Profile visits: {totals['total_profile_visits']}")
    print(f"  New followers: {totals['total_new_followers']}")

    if totals["days_logged"] > 0:
        print()
        avg_likes = totals["total_likes"] / totals["days_logged"]
        avg_followers = totals["total_new_followers"] / totals["days_logged"]
        print(f"Averages per day:")
        print(f"  Likes: {avg_likes:.1f}")
        print(f"  New followers: {avg_followers:.1f}")

    if totals["target_engagement_count"]:
        print()
        print("Target engagement frequency:")
        for handle, count in sorted(totals["target_engagement_count"].items(), key=lambda x: -x[1]):
            print(f"  {handle}: {count} sessions")

    # Save evaluation
    EVAL_DIR.mkdir(parents=True, exist_ok=True)
    eval_file = EVAL_DIR / f"{date.today().isoformat()}.yaml"
    with open(eval_file, "w") as f:
        f.write(f"date: \"{date.today().isoformat()}\"\n")
        f.write(f"days_evaluated: {totals['days_logged']}\n")
        f.write(f"total_posts: {totals['total_replies'] + totals['total_standalone'] + totals['total_quote_tweets']}\n")
        f.write(f"total_likes: {totals['total_likes']}\n")
        f.write(f"total_new_followers: {totals['total_new_followers']}\n")
        f.write(f"avg_likes_per_day: {totals['total_likes'] / max(totals['days_logged'], 1):.1f}\n")
        f.write(f"avg_followers_per_day: {totals['total_new_followers'] / max(totals['days_logged'], 1):.1f}\n")
        f.write("target_frequency:\n")
        for handle, count in sorted(totals["target_engagement_count"].items(), key=lambda x: -x[1]):
            f.write(f"  \"{handle}\": {count}\n")
    print(f"\nSaved to {eval_file}")


if __name__ == "__main__":
    main()
