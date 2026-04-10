#!/bin/bash
source ~/.agents/.environment 2>/dev/null

if [ "$1" = "block" ]; then
  USER="${BRAIN_SCAN_SSH_USER:-user}"
  HOST="${BRAIN_SCAN_SSH_HOST:-gpu-server}"
  VENV="${BRAIN_SCAN_VENV:-~/tribev2-env}"
  CACHE="${BRAIN_SCAN_CACHE:-~/cache}"
  cat <<EOF
- SSH target: ${USER}@${HOST}
- Python venv: ${VENV}
- Cache dir: ${CACHE}
- Run prefix: ssh ${USER}@${HOST} "source ${VENV}/bin/activate &&"
- HF Token: Set HF_TOKEN in ~/.agents/.environment (required for first model download)
EOF
else
  key="$1"
  default="$2"
  val="${!key:-$default}"
  echo -n "$val"
fi
