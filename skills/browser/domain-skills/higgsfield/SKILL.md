# Higgsfield

Image and video generation via higgsfield.ai. See parent `/browser` skill for general automation workflow.

## URLs

| Mode | URL |
|------|-----|
| Image | `https://higgsfield.ai/image/nano_banana_2` |
| Video | `https://higgsfield.ai/video` |

## Default Settings

- **Model:** Nano Banana 2 (NOT flash)
- **Batch size:** 4
- **Resolution:** 2K minimum, 4K preferred
- **Aspect:** Set BEFORE typing prompt (16:9, 9:16, 1:1)

## Site-Specific Steps

1. Navigate to URL above
2. Dismiss promo dialogs (press Escape)
3. Verify model shows "Nano Banana 2" at bottom-left — click to change if wrong
4. Set batch size to 4
5. Set resolution to 2K or 4K
6. Set aspect ratio
7. Click textbox, select all (Meta+a), type prompt
8. Click Generate
9. Poll with screenshots every 15-30s until complete

## Quirks

- **Refs change after every action** — re-snapshot before clicking
- **Promo dialogs** — press Escape first
- **Aspect ratio resets** — verify before each generation
- **Contenteditable input** — click to focus, then type

## Downloading

Click generated image → snapshot → click download button, or extract image URL from DOM.
