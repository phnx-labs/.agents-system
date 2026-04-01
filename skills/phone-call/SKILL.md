---
name: phone-call
description: Call Muqsit when critically blocked. Last resort escalation.
allowed-tools: Bash(bash ~/.openclaw/skills/phone-call/call.sh*)
user-invocable: true
---

# Phone Call Escalation

Call Muqsit's phone when you are critically blocked and need human help.

## When to Call

- You need something only Muqsit can provide (credentials, service restart, manual approval, a decision)
- All workarounds and alternative tasks are exhausted
- The blocker is preventing meaningful progress

Calling disturbs Muqsit directly. Exhaust every alternative first. But when you genuinely need help, call without hesitation.

## How to Escalate

**Step 1: Print a Telegram briefing.** Before calling, print a clear message. This appears in Telegram and is what Muqsit reads when he unlocks his phone after the call.

Format:
```
BLOCKED: [one-line summary]

What: [what you were trying to do]
Error: [the specific error or blocker]
Tried: [what you already attempted]
Need: [exactly what you need from Muqsit]
Link: [relevant URL, file path, or log location]
```

**Step 2: Call.**
```bash
bash ~/.openclaw/skills/phone-call/call.sh "This is [Name]. [one sentence: what is blocked]. Check Telegram for details."
```

The call message plays twice. Keep it under 15 seconds. All detail goes in the Telegram briefing -- the call just gets Muqsit's attention.

## After Calling

Move on to other work immediately. Do not retry the blocked action.
