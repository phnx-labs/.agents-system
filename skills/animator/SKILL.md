---
name: animator
description: "Short branded animations and post-production video editing. Renders 4-10s Remotion compositions for blog/learn embeds, AND polishes existing screen-capture footage (trim, speed, silence-cut, music bed, intro/outro chrome). The CLI is intentionally minimal — for everything beyond rendering and frame inspection, read RECIPES.md and write the ffmpeg/curl yourself. Triggers on: animate, animation, video, motion graphic, screen recording edit, trim video, speed up video, music bed, intro outro."
argument-hint: "[task — e.g. 'agent-dispatch animation for /learn', 'trim this screen capture and add intro']"
allowed-tools: Bash(*), Read(*), Write(*)
user-invocable: true
---

# animator

Sister creative skill: **`composer`** (audio scoring + music beds).

## Modes

Two modes:

1. **Compose** — render a from-scratch 5–10s animation when there's no source footage (blog headers, /learn embeds, social loops).
2. **Edit** — polish an existing screen capture. **Write the ffmpeg yourself.** RECIPES.md has worked examples for every common edit; copy the relevant snippet and adapt it to your case.

## Philosophy

A canned `animator trim --start --end` command can't capture all the decisions a real edit needs: which beat to cut on, when to speed up, when to crossfade, when to flash, where the silence is *intentional*. Wrong abstractions are worse than no abstractions. So the CLI ships only two things:

- `animator compose <id>` — render a registered Remotion composition.
- `animator preview <video>` — extract keyframes so you can visually inspect a render. **You cannot watch MP4s directly. Always preview after rendering.**

For every other operation (trim, speed, silence-cut, music-overlay, chrome splicing, music generation, downscale, etc.), read **`RECIPES.md`** and adapt the ffmpeg/curl invocation. Don't blindly copy — *think* about what the specific clip needs.

## When to use this skill

- A blog post or `/learn` article needs a 5–10s embedded animation.
- A screen capture is rough — too long, too many silences, no brand frame around it.
- A social loop is needed (1:1 or 1.91:1 or 16:9).
- A launch announcement needs a title card.

## When NOT to use this skill

- Long-form videos (>60s). Use a real NLE (Final Cut / DaVinci).
- Voiceover, captions, transcription work.
- Live-action footage with people. The skill is graphics + UI capture only.
- Multi-track timeline editing with more than two beds.

## Setup (one-time)

```bash
animator install
```

Installs `bun install` deps and `brew install ffmpeg` if missing. The first `compose` call also downloads Chromium Headless Shell (~93MB) for Remotion — cached afterward.

## Registered compositions

| ID | Dim | Duration | Use |
| --- | --- | --- | --- |
| `AgentDispatch` | 3840×2160 | 8s | `/learn` embed about orchestration |

Add your own to `compositions/` and register in `src/Root.tsx` — see RECIPES.md §13.

```bash
# Render the agent-fan animation
animator compose AgentDispatch --out out/learn-hero.mp4
```

## Mandatory verification

Animations break in non-obvious ways (font missing → invisible text, gradient miscalculated → no sheen, off-screen positioning, etc.). After ANY render or edit:

```bash
animator preview out/your.mp4 --frames 5
```

Then `Read` each `out/preview/<name>/frame-*.jpg`. **Look at all 5 frames.** A render with 4 good frames and 1 broken frame is broken — fix it before shipping.

If a render looks wrong:

1. Frame 0 black or text invisible? Font likely didn't load — check `primitives/fonts.ts`.
2. Animation static across all frames? Component isn't reading `useCurrentFrame`.
3. Wrong colors? Brand tokens are in `primitives/colors.ts` — never inline hex.
4. Layout cropped? viewBox or `width`/`height` mismatch in composition vs Root.tsx.

## Edit workflow (think, don't follow a script)

A typical polish pass for a 1-minute screen capture:

1. **Probe** — `ffprobe ...` to know duration, fps, audio tracks. (RECIPES.md §1)
2. **Trim** — cut to the substantive ~30s. Pick the moment, not the second. (§1)
3. **Silence-cut** — remove pauses if the audio is keyboard-driven. (§3)
4. **Speed up** *only* the boring sections, not the whole thing. (§2)
5. **Music** — generate a bed (§5), overlay with sidechain duck under voiceover (§4).
6. **Chrome** — pre-render an intro card, concat. (§6)
7. **Downscale** — 4K master → 1920×1080 MP4 for upload. (§7)
8. **Preview** — extract frames, verify each one looks right.

Steps you skip vary by clip. A silent demo with no narration: skip step 3. A pure animation: skip 1–4.

## Brand discipline (replace with your own)

The bundled `primitives/colors.ts` and `primitives/fonts.ts` ship a neutral starter palette. Override them with your own tokens. Keep one accent, keep one easing.

Defaults:

| Token | Hex | Use |
| --- | --- | --- |
| ink | `#080C14` | Dark backgrounds |
| paper | `#E6EEF6` | Light backgrounds |
| gold | `#C9A962` | Emphasis — one accent per surface |
| silver | `#AFB0B5` | Data / secondary |

Easing: `cubic-bezier(0.45, 0, 0.55, 1)` — used everywhere for cohesion.

Fonts (loaded via `@remotion/google-fonts` in `primitives/fonts.ts`): EB Garamond (display), Cormorant Upright (wordmarks), JetBrains Mono (code/labels), Inter (UI).
