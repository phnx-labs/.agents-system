#!/bin/bash
# Phone call with cloned voice (ElevenLabs TTS + Twilio)
# Tries: Muqsit voice -> premade fallback -> Amazon Polly
# Usage: bash call.sh "Message to speak" [phone_number]

MSG="${1:-Agent needs attention. Check Telegram.}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CFG="${SCRIPT_DIR}/config.json"

# Read config
TW_SID=$(python3 -c "import json; print(json.load(open('${CFG}'))[twilio][accountSid])")
TW_TOKEN=$(python3 -c "import json; print(json.load(open('${CFG}'))[twilio][authToken])")
TW_FROM=$(python3 -c "import json; print(json.load(open('${CFG}'))[twilio][fromNumber])")
TW_TO="${2:-$(python3 -c "import json; print(json.load(open('${CFG}'))[twilio][toNumber])")}"
EL_KEY=$(python3 -c "import json; print(json.load(open('${CFG}'))[elevenlabs][apiKey])")
EL_VOICE=$(python3 -c "import json; print(json.load(open('${CFG}'))[elevenlabs][voiceId])")
EL_FALLBACK=$(python3 -c "import json; print(json.load(open('${CFG}'))[elevenlabs].get(fallbackVoiceId,onwK4e9ZLuTAKqWW03F9))")

# Try ElevenLabs TTS (primary voice, then fallback)
AUDIO_FILE="/tmp/muqsit-call-$(date +%s).mp3"
VOICE_USED=""

for VOICE in "$EL_VOICE" "$EL_FALLBACK"; do
  HTTP_CODE=$(curl -s -w "%{http_code}" -o "${AUDIO_FILE}" \
    "https://api.elevenlabs.io/v1/text-to-speech/${VOICE}" \
    -H "xi-api-key: ${EL_KEY}" \
    -H "Content-Type: application/json" \
    -d "{
      \"text\": \"${MSG}\",
      \"model_id\": \"eleven_multilingual_v2\",
      \"voice_settings\": {
        \"similarity_boost\": 1.0,
        \"stability\": 0.3,
        \"style\": 0.7
      }
    }")
  if [ "$HTTP_CODE" = "200" ] && [ -s "${AUDIO_FILE}" ]; then
    VOICE_USED="$VOICE"
    break
  fi
done

if [ -z "$VOICE_USED" ]; then
  echo "ElevenLabs failed. Falling back to Polly."
  rm -f "${AUDIO_FILE}"
  curl -s -X POST "https://api.twilio.com/2010-04-01/Accounts/${TW_SID}/Calls.json" \
    --data-urlencode "To=${TW_TO}" \
    --data-urlencode "From=${TW_FROM}" \
    --data-urlencode "Twiml=<Response><Say voice=\"Polly.Joanna\">${MSG}</Say><Pause length=\"1\"/><Say voice=\"Polly.Joanna\">${MSG}</Say></Response>" \
    -u "${TW_SID}:${TW_TOKEN}" > /dev/null 2>&1
  echo "Call placed (Polly)."
  exit 0
fi

# Upload audio to temp host for Twilio to fetch
AUDIO_URL=$(curl -s -F "file=@${AUDIO_FILE}" https://0x0.st 2>/dev/null)

if [ -z "${AUDIO_URL}" ] || echo "${AUDIO_URL}" | grep -qi "error"; then
  # Fallback upload: file.io
  AUDIO_URL=$(curl -s -F "file=@${AUDIO_FILE}" https://file.io 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get(link,))" 2>/dev/null)
fi

if [ -z "${AUDIO_URL}" ]; then
  echo "Upload failed. Falling back to Polly."
  rm -f "${AUDIO_FILE}"
  curl -s -X POST "https://api.twilio.com/2010-04-01/Accounts/${TW_SID}/Calls.json" \
    --data-urlencode "To=${TW_TO}" \
    --data-urlencode "From=${TW_FROM}" \
    --data-urlencode "Twiml=<Response><Say voice=\"Polly.Joanna\">${MSG}</Say><Pause length=\"1\"/><Say voice=\"Polly.Joanna\">${MSG}</Say></Response>" \
    -u "${TW_SID}:${TW_TOKEN}" > /dev/null 2>&1
  echo "Call placed (Polly)."
  exit 0
fi

# Place call via Twilio with ElevenLabs audio
curl -s -X POST "https://api.twilio.com/2010-04-01/Accounts/${TW_SID}/Calls.json" \
  --data-urlencode "To=${TW_TO}" \
  --data-urlencode "From=${TW_FROM}" \
  --data-urlencode "Twiml=<Response><Play>${AUDIO_URL}</Play><Pause length=\"1\"/><Play>${AUDIO_URL}</Play></Response>" \
  -u "${TW_SID}:${TW_TOKEN}" > /dev/null 2>&1

rm -f "${AUDIO_FILE}"
echo "Call placed (ElevenLabs voice: ${VOICE_USED})."
