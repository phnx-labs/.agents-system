#!/bin/bash
# Loads environment and prints variables.
# Usage:
#   env.sh <key> [default]    — print single variable
#   env.sh block              — print full environment block for skill injection
source ~/.agents/.environment 2>/dev/null

if [ "$1" = "block" ]; then
  USER="${OPENCLAW_USER:-muqsit}"
  HOST="${OPENCLAW_HOST:-mac-mini}"
  PATHPFX="${OPENCLAW_PATH:-/opt/homebrew/bin}"
  cat <<EOF
- SSH target: ${USER}@${HOST}
- PATH prefix: ${PATHPFX}
- Command prefix: ssh ${USER}@${HOST} "PATH=${PATHPFX}:\$PATH openclaw browser"
EOF
else
  key="$1"
  default="$2"
  val="${!key:-$default}"
  echo -n "$val"
fi
