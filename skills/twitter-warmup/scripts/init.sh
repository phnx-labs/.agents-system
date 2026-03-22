#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="$HOME/.twitter-warmup"

if [ -d "$STATE_DIR" ]; then
  echo "Already initialized: $STATE_DIR"
  echo "To reset, remove the directory: rm -rf $STATE_DIR"
  exit 0
fi

mkdir -p "$STATE_DIR/log"

cat > "$STATE_DIR/state.yaml" << 'YAML'
account:
  handle: ""
  created_at: ""
  premium: false
  profile_complete: false
  api_access: false
phase: 1
cooldown:
  active: false
  since: null
  reason: null
last_session: null
YAML

cat > "$STATE_DIR/targets.yaml" << 'YAML'
# Engagement targets — seed with 5+ accounts before starting
# Agent updates this file after each session
targets: []
# Format:
# - handle: "@example"
#   name: "Full Name"
#   tier: 1
#   topics: ["AI agents", "developer tools"]
#   why: "Key voice in AI agent space"
#   last_engaged: null
#   response_rate: null
#   discovered_via: "seed"
YAML

cat > "$STATE_DIR/topics.yaml" << 'YAML'
themes:
  monday:
    name: "Ecosystem observations"
    angle: "Market structure, who's building what"
  tuesday:
    name: "Your thesis"
    angle: "Why your approach/category matters"
  wednesday:
    name: "Builder perspective"
    angle: "What building in this space is actually like"
  thursday:
    name: "Hot takes on news"
    angle: "Contrarian angles on whatever dropped this week"
  friday:
    name: "Future implications"
    angle: "How your domain reshapes work/life"
  saturday:
    name: "Technical insight"
    angle: "Something specific and educational"
  sunday:
    name: "Philosophical"
    angle: "Bigger picture, historical parallels"
avoid: []
resonate: []
YAML

echo "Initialized: $STATE_DIR"
echo "Next steps:"
echo "  1. Fill in account details in $STATE_DIR/state.yaml"
echo "  2. Seed 5+ targets in $STATE_DIR/targets.yaml"
echo "  3. Set premium: true after subscribing to X Premium"
