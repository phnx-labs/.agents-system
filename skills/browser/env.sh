#!/bin/bash
# Loads environment and prints variables.
# Usage:
#   env.sh <key> [default]    — print single variable
#   env.sh block              — print full environment block for skill injection
source ~/.agents/.environment 2>/dev/null

if [ "$1" = "block" ]; then
  USER="${BROWSER_SSH_USER:-muqsit}"
  HOST="${BROWSER_SSH_HOST:-mac-mini}"
  PATHPFX="${BROWSER_SSH_PATH:-/opt/homebrew/bin}"
  BROWSER_CMD="${BROWSER_CMD:-openclaw browser}"
  cat <<EOF
- SSH target: ${USER}@${HOST}
- PATH prefix: ${PATHPFX}
- Browser command: ${BROWSER_CMD}
- Command prefix: ssh ${USER}@${HOST} "PATH=${PATHPFX}:\$PATH ${BROWSER_CMD}"
EOF
else
  key="$1"
  default="$2"
  val="${!key:-$default}"
  echo -n "$val"
fi
