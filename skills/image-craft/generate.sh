#!/bin/bash
# Higgsfield image generation with model/aspect/resolution control
# Usage: generate.sh "prompt" [--model nano-banana-pro|nano-banana-2] [--aspect 16:9|4:3|1:1|9:16] [--batch N] [--resolution 1k|2k]
# Defaults: model=nano-banana-pro, aspect=16:9, batch=4, resolution=1k
#
# Requires: agent-browser with a Higgsfield profile (logged into higgsfield.ai)
# The script opens the browser, grabs a fresh Clerk token, and makes the API call
# via the browser's fetch (bypasses Cloudflare bot protection on fnf.higgsfield.ai).

PROMPT=""
MODEL="nano-banana-pro"
ASPECT="16:9"
BATCH_SIZE=4
RESOLUTION="1k"

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --model) MODEL="$2"; shift 2 ;;
    --aspect) ASPECT="$2"; shift 2 ;;
    --batch) BATCH_SIZE="$2"; shift 2 ;;
    --resolution) RESOLUTION="$2"; shift 2 ;;
    *)
      if [ -z "$PROMPT" ]; then
        PROMPT="$1"
      fi
      shift ;;
  esac
done

if [ -z "$PROMPT" ]; then
  echo "Usage: generate.sh \"prompt\" [--model nano-banana-pro] [--aspect 16:9] [--batch 4] [--resolution 1k]"
  exit 1
fi

# Calculate dimensions from aspect ratio and resolution
if [ "$RESOLUTION" = "2k" ]; then
  BASE=2048
else
  BASE=1024
fi

case "$ASPECT" in
  "16:9") WIDTH=$BASE; HEIGHT=$(( BASE * 9 / 16 )) ;;
  "4:3")  WIDTH=$BASE; HEIGHT=$(( BASE * 3 / 4 )) ;;
  "9:16") WIDTH=$(( BASE * 9 / 16 )); HEIGHT=$BASE ;;
  "1:1")  WIDTH=$BASE; HEIGHT=$BASE ;;
  *)      WIDTH=$BASE; HEIGHT=$(( BASE * 9 / 16 )) ;;
esac

# Ensure browser is on higgsfield.ai (for Clerk session)
agent-browser --profile ~/.agent-browser/profiles/higgsfield open "https://higgsfield.ai" >/dev/null 2>&1

# Get fresh token and cookies from browser (need cookies to bypass Cloudflare)
TOKEN=$(agent-browser eval "window.Clerk.session.getToken()" 2>&1 | tr -d '"')
COOKIES=$(agent-browser eval "document.cookie" 2>&1 | tr -d '"')

if [ -z "$TOKEN" ] || [[ "$TOKEN" == *"Error"* ]] || [[ "$TOKEN" == *"error"* ]]; then
  echo "Error: Failed to get auth token. Make sure you're logged into higgsfield.ai"
  exit 1
fi

# Build JSON body with jq (handles all prompt escaping properly)
JSON_BODY=$(jq -n \
  --arg prompt "$PROMPT" \
  --argjson width "$WIDTH" \
  --argjson height "$HEIGHT" \
  --argjson batch "$BATCH_SIZE" \
  --arg aspect "$ASPECT" \
  --arg resolution "$RESOLUTION" \
  '{
    params: {
      prompt: $prompt,
      input_images: [],
      width: $width,
      height: $height,
      batch_size: $batch,
      aspect_ratio: $aspect,
      is_storyboard: false,
      is_zoom_control: false,
      use_unlim: false,
      resolution: $resolution
    },
    use_unlim: false
  }')

# Make API call with curl, passing browser cookies to bypass Cloudflare
RESULT=$(curl -s "https://fnf.higgsfield.ai/jobs/$MODEL" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Cookie: $COOKIES" \
  -H "Referer: https://higgsfield.ai/" \
  -H "Origin: https://higgsfield.ai" \
  --data-raw "$JSON_BODY")

# Extract job ID from response
JOB_ID=$(echo "$RESULT" | jq -r '.job_sets[0].id // empty')

if [ -z "$JOB_ID" ]; then
  echo "Error: $RESULT"
  exit 1
fi

echo "$JOB_ID"
