#!/bin/bash
# Download images from a job set
# Usage: download.sh <job_set_id> <output_prefix>
# Example: download.sh abc123 /tmp/skills-crystal

JOB_SET_ID="$1"
OUTPUT_PREFIX="$2"

if [ -z "$JOB_SET_ID" ] || [ -z "$OUTPUT_PREFIX" ]; then
  echo "Usage: download.sh <job_set_id> <output_prefix>"
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

# Download each image
URLS=$(echo "$RESPONSE" | jq -r '.jobs[].results.raw.url // empty')
COUNT=1

for URL in $URLS; do
  OUTPUT_FILE="${OUTPUT_PREFIX}-${COUNT}.jpeg"
  echo "Downloading $OUTPUT_FILE..."
  curl -s -o "$OUTPUT_FILE" "$URL"
  COUNT=$((COUNT + 1))
done

echo "Downloaded $((COUNT - 1)) images to ${OUTPUT_PREFIX}-*.jpeg"
