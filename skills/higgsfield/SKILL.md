---
name: higgsfield
description: Generate images and videos via Higgsfield AI (higgsfield.ai) using OpenClaw browser with agent's own browser profile
argument-hint: "[image|video] prompt"
allowed-tools: Bash(sleep*), Bash(ssh*), Bash(*/env.sh*), Bash(openclaw*), Bash(agent-browser*)
user-invocable: true
---

# Higgsfield Generation

Read the `/browser` skill first for general browser automation guidelines.

## Input

`$ARGUMENTS` = mode + prompt. First word is `image` or `video`, rest is the prompt. Default: `image`.

## Modes

| Mode | URL |
|------|-----|
| `image` | `https://higgsfield.ai/image/nano_banana_flash` |
| `video` | `https://www.higgsfield.ai/video` |

## OpenClaw Browser Workflow

**CRITICAL: Always pass `--browser-profile <your-profile>` on every command.** Each agent has a dedicated browser profile (paul, emma, sergey, claude, etc.) with its own login sessions. Omitting the flag uses the default profile, which may not be logged into Higgsfield.

### Local Agents (OC agents on mac-mini)

```bash
# PROFILE must be your agent's browser profile name (paul, emma, sergey, etc.)
OC="PATH=/opt/homebrew/bin:${HOME}/.agents-system/shims:$PATH openclaw browser --browser-profile PROFILE"
```

### Remote Agents (Claude via SSH)

```bash
!`${CLAUDE_SKILL_DIR}/env.sh block`
# Set PROFILE to your browser profile name (e.g. claude)
# All commands: $SSH "$OC <command> --browser-profile $PROFILE"
```

### Submission Workflow

Steps below use `$OC` shorthand. Remote agents prefix with `$SSH "..."`.

```bash
# 1. Open generation page in NEW TAB (never navigate!)
$OC open 'https://higgsfield.ai/image/nano_banana_flash'
# Save the target ID from output, e.g. TARGET=3EB5FF70...

# 2. Focus your tab
$OC focus <targetId>

# 3. Snapshot to get element refs
$OC snapshot --labels

# 4. Dismiss any promo dialogs (press Escape if a dialog blocks the page)
$OC press Escape
$OC snapshot --labels

# 5. VERIFY MODEL (URL does NOT control the model — Higgsfield remembers the last-used model)
#    Check the model label at bottom-left of the composer.
#    If it doesn't say "Nano Banana 2", click the model label button,
#    snapshot to see the dropdown, then click "Nano Banana 2".

# 6. Set aspect ratio (MUST do before typing prompt)
#    Click the current aspect button -> snapshot -> click desired option
$OC click <aspect-btn-ref>
$OC snapshot --labels   # Find the option refs
$OC click <option-ref>  # e.g. 16:9, 9:16, 1:1

# 7. Click textbox, select all, type prompt
$OC click <textbox-ref>
$OC press 'Meta+a'
$OC type <textbox-ref> 'prompt text here'

# 8. Re-snapshot (refs change after typing) and click Generate
$OC snapshot --labels
$OC click <generate-ref>

# 9. Poll for completion (DO NOT use sleep — relay times out after 30s idle)
#    Take screenshots every 15s until images appear
$OC screenshot   # Check if still "Generating..." or images are ready
# Repeat until done (usually 30-60s for images, 60-180s for video)

# 10. Close tab when done downloading results
$OC close <targetId>
```

### Downloading Results

After generation completes, images appear in the History panel. To download:

1. Click on a generated image in history to open the detail view
2. Snapshot to find the download button ref
3. Use `openclaw browser download <ref>` to save the image

Alternatively, extract image URLs from the DOM and download via curl.

### Important Quirks

- **Promo dialogs** -- Higgsfield shows promotional popups on page load. Press Escape to dismiss, then re-snapshot.
- **Aspect ratio resets** -- Higgsfield may reset aspect ratio between generations. Always verify the current aspect before submitting.
- **Refs change after every action** -- always re-snapshot before clicking if you've typed or navigated.
- **Page navigation** -- clicking some elements navigates away from `/image/nano_banana_2`. If this happens, open a fresh tab.
- **Contenteditable input** -- the prompt textbox is contenteditable, not a standard input. `type` via OpenClaw relay works. If it doesn't, try `click` first to focus.

## Guidelines

- **Set aspect ratio FIRST** -- before typing the prompt. Most common mistake.
- **Verify model EVERY TIME** -- the URL does not control the model. Check the label at bottom-left.
- **Intelligently select settings** -- based on prompt, choose appropriate ratio. Portrait = 9:16, cinematic = 16:9, square = 1:1.
- **Batch workflow** -- when generating many images, write a helper script rather than running individual commands.
- **Wait times** -- image generation 30-60s, video 60-180s.
- **Model** -- Nano Banana 2 for rapid iteration, Nano Banana Pro for higher quality.
- **Always use `--browser-profile <your-profile>`** -- never omit it. Each agent has its own profile with separate Higgsfield login sessions.

## Fallback: agent-browser (Local)

If OpenClaw relay is unavailable, use agent-browser locally with the Higgsfield profile:

```bash
agent-browser \
  --executable-path "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --profile ~/.agent-browser/profiles/higgsfield \
  open "https://www.higgsfield.ai/image" --headed 2>&1
```

Note: may hit Cloudflare verification.

## Fallback: API via generate.sh

The `generate.sh` script calls the Higgsfield API directly by extracting a Clerk auth token from a logged-in browser session. Currently blocked by Cloudflare challenges, but useful as reference. See `generate.sh` in this skill directory.
