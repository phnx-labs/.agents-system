#!/bin/bash
MSG="${1:-Agent needs attention. Check Telegram.}"
CFG="$HOME/.openclaw/skills/phone-call/config.json"
SID=$(python3 -c "import json; print(json.load(open('${CFG}'))['accountSid'])")
TOKEN=$(python3 -c "import json; print(json.load(open('${CFG}'))['authToken'])")
FROM=$(python3 -c "import json; print(json.load(open('${CFG}'))['fromNumber'])")
TO=$(python3 -c "import json; print(json.load(open('${CFG}'))['toNumber'])")
curl -s -X POST "https://api.twilio.com/2010-04-01/Accounts/${SID}/Calls.json" \
  --data-urlencode "To=${TO}" \
  --data-urlencode "From=${FROM}" \
  --data-urlencode "Twiml=<Response><Say voice=\"Polly.Joanna\">${MSG}</Say><Pause length=\"1\"/><Say voice=\"Polly.Joanna\">${MSG}</Say></Response>" \
  -u "${SID}:${TOKEN}" > /dev/null 2>&1
echo "Call placed."
