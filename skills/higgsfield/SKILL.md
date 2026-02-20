---
name: higgsfield
description: Generate images and videos via Higgsfield AI (higgsfield.ai) using agent-browser
argument-hint: "[image|video] [prompt]"
allowed-tools: Bash(agent-browser*), Bash(sleep*)
user-invocable: true
---

# Higgsfield Generation

Read the `/browser` skill first for general browser automation guidelines.

## Input

`$ARGUMENTS` = mode + prompt. First word is `image` or `video`, rest is the prompt. Default: `image`.

## Modes

| Mode | URL |
|------|-----|
| `image` | `https://www.higgsfield.ai/image` |
| `video` | `https://www.higgsfield.ai/video` |

## Guidelines

- **Intelligently select settings** — based on the user's prompt, choose appropriate quality, aspect ratio, and other generation options. For example, a portrait prompt should use portrait aspect ratio, a cinematic prompt should use widescreen.
- **Wait times** — image generation is typically 30-60s, video generation can take 60-180s. Use `sleep + screenshot` to monitor.
- **Download results** — after generation completes, screenshot the output and look for download options.
