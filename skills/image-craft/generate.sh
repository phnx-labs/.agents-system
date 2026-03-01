#!/bin/bash
# Higgsfield image generation with model/aspect/resolution control
# Usage: generate.sh "prompt" [--model nano-banana-pro|nano-banana-2] [--aspect 16:9|4:3|1:1|9:16] [--batch N] [--resolution 1k|2k]
# Defaults: model=nano-banana-pro, aspect=16:9, batch=4, resolution=1k

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

# Escape prompt for JSON
ESCAPED_PROMPT=$(echo "$PROMPT" | sed 's/\\/\\\\/g; s/"/\\"/g')

# Use browser fetch - gets token and makes request in one call
RESULT=$(agent-browser eval "
(async () => {
  const token = await window.Clerk.session.getToken();
  const response = await fetch('https://fnf.higgsfield.ai/jobs/$MODEL', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + token
    },
    body: JSON.stringify({
      params: {
        prompt: \"$ESCAPED_PROMPT\",
        input_images: [],
        width: $WIDTH,
        height: $HEIGHT,
        batch_size: $BATCH_SIZE,
        aspect_ratio: '$ASPECT',
        is_storyboard: false,
        is_zoom_control: false,
        use_unlim: false,
        resolution: '$RESOLUTION'
      },
      use_unlim: false
    })
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
