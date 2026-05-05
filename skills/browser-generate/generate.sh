#!/bin/bash
# Higgsfield image generation via browser fetch (bypasses Cloudflare)
# Usage: generate.sh "prompt" [batch_size] [resolution]
# Example: generate.sh "3D macOS app icon..." 4 1k

PROMPT="$1"
BATCH_SIZE="${2:-4}"
RESOLUTION="${3:-1k}"

if [ -z "$PROMPT" ]; then
  echo "Usage: generate.sh \"prompt\" [batch_size] [resolution]"
  exit 1
fi

# Calculate dimensions
if [ "$RESOLUTION" = "2k" ]; then
  SIZE=2048
else
  SIZE=1024
fi

# Build JSON body with jq (handles all escaping properly)
JSON_BODY=$(jq -n \
  --arg prompt "$PROMPT" \
  --argjson size "$SIZE" \
  --argjson batch "$BATCH_SIZE" \
  --arg resolution "$RESOLUTION" \
  '{
    params: {
      prompt: $prompt,
      input_images: [],
      width: $size,
      height: $size,
      batch_size: $batch,
      aspect_ratio: "1:1",
      is_storyboard: false,
      is_zoom_control: false,
      use_unlim: false,
      resolution: $resolution
    },
    use_unlim: false
  }')

# Base64 encode to safely pass through bash -> JS boundary
B64_BODY=$(echo -n "$JSON_BODY" | base64)

# Use browser fetch - gets token and makes request in one call
RESULT=$(agent-browser eval "
(async () => {
  const token = await window.Clerk.session.getToken();
  const body = atob('$B64_BODY');
  const response = await fetch('https://fnf.higgsfield.ai/jobs/nano-banana-2', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + token
    },
    body: body
  });
  const data = await response.json();
  return data.job_sets[0].id;
})()
" 2>&1)

# Clean up output
JOB_ID=$(echo "$RESULT" | tr -d '"')

if [ -z "$JOB_ID" ] || [[ "$JOB_ID" == *"Error"* ]] || [[ "$JOB_ID" == *"error"* ]]; then
  echo "Error: $RESULT"
  exit 1
fi

echo "$JOB_ID"
