---
name: phone-call
description: Call Muqsit when critically blocked. Last resort escalation.
user-invocable: true
---

# Phone Call Escalation

Call Muqsit's phone when you are critically blocked and cannot make progress.

## When to Use

- You have been blocked on the **same issue for 2+ consecutive cron runs**
- All retries and workarounds are exhausted
- The blocker requires human intervention (credentials, service restart, manual approval)
- It is within active hours (7 AM - midnight PT)

## When NOT to Use

- Minor issues that can wait for the next cron run
- Problems you can work around by switching to a different task
- Non-blocking observations or status updates (use Telegram instead)
- Outside active hours unless truly urgent

## How to Use

```bash
bash ~/.openclaw/skills/phone-call/call.sh "This is Paul. Blocked on Higgsfield browser timeouts for 3 hours. Browser relay times out before I can download generated images. Please check Telegram for details."
```

The message plays twice so Muqsit catches it. Keep messages under 30 seconds. State:
1. Who you are
2. What is blocked
3. How long
4. What you need

## Credentials

Stored in `~/.openclaw/skills/phone-call/config.json` (machine-local, not synced). The `call.sh` script reads them automatically.

```json
{
  "accountSid": "...",
  "authToken": "...",
  "fromNumber": "+1...",
  "toNumber": "+1..."
}
```

## Rate Limit

Do NOT call more than once per hour for the same issue. If no response after 60 minutes, try once more then stop.
