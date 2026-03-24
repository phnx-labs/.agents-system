---
name: higgsfield
description: Generate images and videos via Higgsfield AI (higgsfield.ai) using OpenClaw browser or agent-browser
argument-hint: "[image|video] prompt"
allowed-tools: Bash(agent-browser*), Bash(sleep*), Bash(ssh*), Bash(openclaw*)
user-invocable: true
---

# Higgsfield Generation

Read the `/browser` skill first for general browser automation guidelines.

## Input

`$ARGUMENTS` = mode + prompt. First word is `image` or `video`, rest is the prompt. Default: `image`.

## Modes

| Mode | URL |
|------|-----|
| `image` | `https://www.higgsfield.ai/image/nano_banana_2` |
| `video` | `https://www.higgsfield.ai/video` |

## Preferred Method: OpenClaw Browser

### Submission Workflow

```bash
SSH="ssh !`${CLAUDE_SKILL_DIR}/env.sh OPENCLAW_USER muqsit`@!`${CLAUDE_SKILL_DIR}/env.sh OPENCLAW_HOST mac-mini`"
OC="PATH=!`${CLAUDE_SKILL_DIR}/env.sh OPENCLAW_PATH /opt/homebrew/bin`:\$PATH openclaw browser"

# 1. Open generation page in NEW TAB (never navigate!)
$SSH "$OC open 'https://www.higgsfield.ai/image/nano_banana_2'"
# Save the target ID from output, e.g. TARGET=3EB5FF70...

# 2. Focus your tab
$SSH "$OC focus <targetId>"

# 3. Snapshot to get element refs
$SSH "$OC snapshot --labels"

# 4. Set aspect ratio (MUST do before typing prompt)
#    Click the current aspect button -> snapshot -> click desired option
$SSH "$OC click <aspect-btn-ref>"
$SSH "$OC snapshot --labels"   # Find the option refs
$SSH "$OC click <option-ref>"  # e.g. 16:9, 9:16, 1:1

# 5. Click textbox, select all, type prompt
$SSH "$OC click <textbox-ref>"
$SSH "$OC press 'Meta+a'"
$SSH "$OC type <textbox-ref> 'prompt text here'"

# 6. Re-snapshot (refs change after typing) and click Generate
$SSH "$OC snapshot --labels"
$SSH "$OC click <generate-ref>"

# 7. Close tab when done downloading results
$SSH "$OC close <targetId>"
```

### Helper Script Pattern

For batch submissions, write a helper script to `/tmp/hf-submit.sh` on the remote host that:
1. Takes prompt as argument
2. Opens a new tab (saves target ID)
3. Focuses tab, snapshots to find textbox + generate refs
4. Clicks textbox, selects all, types prompt
5. Re-snapshots to get fresh generate ref
6. Clicks generate
7. Closes tab when generation completes

### Important Quirks

- **Aspect ratio resets** — Higgsfield may reset aspect ratio between generations. Always verify the current aspect before submitting.
- **Refs change after every action** — always re-snapshot before clicking if you've typed or navigated.
- **Page navigation** — clicking some elements navigates away from `/image/nano_banana_2`. If this happens, open a fresh tab.
- **Contenteditable input** — the prompt textbox is contenteditable, not a standard input. `type` via OpenClaw relay works. If it doesn't, try `click` first to focus.

## Guidelines

- **Set aspect ratio FIRST** — before typing the prompt. Most common mistake.
- **Intelligently select settings** — based on prompt, choose appropriate ratio. Portrait = 9:16, cinematic = 16:9, square = 1:1.
- **Batch workflow** — when generating many images, write a helper script rather than running individual commands.
- **Wait times** — image generation 30-60s, video 60-180s.
- **Model** — Nano Banana 2 for rapid iteration, Nano Banana Pro for higher quality.

## Fallback: agent-browser (Local)

If remote host is unavailable, use agent-browser locally with the Higgsfield profile:

```bash
agent-browser \
  --executable-path "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --profile ~/.agent-browser/profiles/higgsfield \
  open "https://www.higgsfield.ai/image" --headed 2>&1
```

Note: may hit Cloudflare verification. The generate.sh script in image-craft uses agent-browser to grab Clerk tokens for direct API calls — an alternative when the UI approach fails.

## Fallback: API via generate.sh

The `image-craft` skill has `generate.sh` which calls the Higgsfield API directly by extracting a Clerk auth token from a logged-in browser session. This bypasses the UI entirely but requires agent-browser to be running locally with a logged-in Higgsfield session.
