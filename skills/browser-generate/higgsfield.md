# Higgsfield Backend

Platform-specific instructions for generating images and videos via Higgsfield AI (higgsfield.ai).

## Input

`$ARGUMENTS` = mode + prompt. First word is `image` or `video`, rest is the prompt. Default: `image`.

## URLs

| Mode | URL |
|------|-----|
| `image` | `https://higgsfield.ai/image/nano_banana_flash` |
| `video` | `https://www.higgsfield.ai/video` |

## Workflow

### Local Agents

```bash
# PROFILE must be your agent's browser profile name
OC="PATH=/opt/homebrew/bin:${HOME}/.agents-system/shims:$PATH openclaw browser --browser-profile PROFILE"
```

### Remote Agents

```bash
!`${CLAUDE_SKILL_DIR}/env.sh block`
# Set PROFILE to your browser profile name
# All commands: $SSH "$OC <command> --browser-profile $PROFILE"
```

### Steps

```bash
# 1. Open generation page in NEW TAB
$OC open 'https://higgsfield.ai/image/nano_banana_flash'
# Save the target ID from output

# 2. Focus your tab
$OC focus <targetId>

# 3. Snapshot to get element refs
$OC snapshot --labels

# 4. Dismiss any promo dialogs
$OC press Escape
$OC snapshot --labels

# 5. VERIFY MODEL
#    Check the model label at bottom-left of the composer.
#    If it doesn't say "Nano Banana 2", click the model label button,
#    snapshot to see the dropdown, then click "Nano Banana 2".

# 6. Set aspect ratio (MUST do before typing prompt)
$OC click <aspect-btn-ref>
$OC snapshot --labels
$OC click <option-ref>  # e.g. 16:9, 9:16, 1:1

# 7. Click textbox, select all, type prompt
$OC click <textbox-ref>
$OC press 'Meta+a'
$OC type <textbox-ref> 'prompt text here'

# 8. Re-snapshot and click Generate
$OC snapshot --labels
$OC click <generate-ref>

# 9. Poll for completion
$OC screenshot   # Check if still "Generating..." or images are ready
# Repeat until done (usually 30-60s for images, 60-180s for video)

# 10. Close tab when done
$OC close <targetId>
```

### Downloading Results

1. Click on a generated image in history to open the detail view
2. Snapshot to find the download button ref
3. Use `openclaw browser download <ref>` to save the image

Alternatively, extract image URLs from the DOM and download via curl.

## Quirks

- **Promo dialogs** -- Press Escape to dismiss, then re-snapshot.
- **Aspect ratio resets** -- Always verify current aspect before submitting.
- **Refs change after every action** -- Always re-snapshot before clicking.
- **Page navigation** -- Clicking some elements navigates away. If this happens, open a fresh tab.
- **Contenteditable input** -- The prompt textbox is contenteditable. `type` via OpenClaw works. If not, try `click` first to focus.

## Settings

- **Aspect ratio:** Portrait = 9:16, cinematic = 16:9, square = 1:1
- **Model:** Nano Banana 2 for rapid iteration, Nano Banana Pro for higher quality
- **Wait times:** Images 30-60s, video 60-180s
