#!/bin/bash
# Check job status and get image URLs
# Usage: status.sh <job_set_id>

JOB_SET_ID="$1"

if [ -z "$JOB_SET_ID" ]; then
  echo "Usage: status.sh <job_set_id>"
  exit 1
fi

# Token
if [ -z "$HIGGSFIELD_TOKEN" ]; then
  TOKEN=$(agent-browser eval 'window.Clerk?.session?.getToken()' 2>/dev/null | tr -d '"')
  if [ -z "$TOKEN" ] || [ "$TOKEN" = "undefined" ]; then
    echo "Error: No HIGGSFIELD_TOKEN set"
    exit 1
  fi
else
  TOKEN="$HIGGSFIELD_TOKEN"
fi

# Get job status
RESPONSE=$(curl -s "https://fnf.higgsfield.ai/job-sets/$JOB_SET_ID" \
  -H "authorization: Bearer $TOKEN" \
  -H 'accept: */*')

# Extract status and URLs
echo "$RESPONSE" | jq -r '.jobs[] | "\(.status) \(.results.raw.url // "pending")"'
