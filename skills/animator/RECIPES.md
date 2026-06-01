# RECIPES.md

Worked examples for everything the `animator` CLI does NOT do. Adapt them to your specific case — these are starting points, not rigid commands.

The agent is expected to read this, understand the technique, and write its own ffmpeg/curl/SVG invocations. The CLI only ships two canonical operations: `compose` (render a registered Remotion composition) and `preview` (extract keyframes for visual inspection).

---

## Brand tokens (always available)

```
ink     #080C14   dark surfaces
paper   #E6EEF6   light surfaces
gold    #C9A962   emphasis (one accent per composition)
goldHi  #E8CE8C   highlight stop in gold gradients
goldLo  #A8884A   shadow stop in gold gradients
silver  #AFB0B5   data / secondary
```

Easing: `cubic-bezier(0.45, 0, 0.55, 1)` — the breath ease, used everywhere.

Default render: **3840×2160 @ 30fps**. Downscale to upload size at the end.

Fonts (loaded via @remotion/google-fonts):
- Serif display: EB Garamond
- Italic accent: Cormorant Garamond italic 300 (one italic word per surface, max)
- Mono/UI labels: JetBrains Mono
- Body UI: Inter

---

## 1. Trim a clip

Re-encode for frame accuracy (cuts on keyframes only if you use `-c copy`):

```bash
ffmpeg -y -ss 0:05 -to 0:42 -i input.mov \
  -c:v libx264 -preset medium -crf 18 -c:a aac \
  out/trimmed.mp4
```

Stream-copy (instant, but cuts on the previous I-frame — fine for quick rough cuts):

```bash
ffmpeg -y -ss 0:05 -to 0:42 -i input.mov -c copy out/trimmed-rough.mp4
```

**Pick the moment, not the second.** A trim that cuts mid-keystroke or mid-word feels sloppy. Probe first:

```bash
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 input.mov
```

---

## 2. Speed up / down

Preserve audio pitch by using `atempo` (clamp 0.5..2.0 per stage; chain for bigger jumps):

```bash
# 2× faster
ffmpeg -y -i input.mp4 \
  -filter_complex "[0:v]setpts=0.5*PTS[v];[0:a]atempo=2.0[a]" \
  -map "[v]" -map "[a]" -c:v libx264 -crf 18 -c:a aac out/2x.mp4

# 4× faster — chain atempo because >2.0 in one filter clamps to 2.0
ffmpeg -y -i input.mp4 \
  -filter_complex "[0:v]setpts=0.25*PTS[v];[0:a]atempo=2.0,atempo=2.0[a]" \
  -map "[v]" -map "[a]" -c:v libx264 -crf 18 -c:a aac out/4x.mp4

# Slow to 0.75×
ffmpeg -y -i input.mp4 \
  -filter_complex "[0:v]setpts=1.3333*PTS[v];[0:a]atempo=0.75[a]" \
  -map "[v]" -map "[a]" -c:v libx264 -crf 18 -c:a aac out/slow.mp4
```

For screen recordings where the dev is staring at the screen, speed only the *boring* sections via concat. Don't blanket-2× the whole thing — viewers feel anxious.

---

## 3. Silence-cut (auto-trim quiet gaps)

Tightens screen recordings by removing pauses. Tune `threshold` and `stop_duration` to the source — `-30dB` is fine for clean room audio; raise to `-25dB` if there's hiss.

```bash
ffmpeg -y -i input.mp4 \
  -af "silenceremove=start_periods=1:start_duration=0:start_threshold=-30dB:stop_periods=-1:stop_duration=0.6:stop_threshold=-30dB" \
  -c:v copy out/tight.mp4
```

Note: `-c:v copy` here is okay because silenceremove only touches audio. Video timestamps are recomputed.

---

## 4. Music bed under a video

Simple mix at low bed volume:

```bash
ffmpeg -y -i video.mp4 -i bed.mp3 \
  -filter_complex "[1:a]volume=0.2[bed];[0:a][bed]amix=inputs=2:duration=first:dropout_transition=0[a]" \
  -map 0:v -map "[a]" -c:v copy -c:a aac -shortest out/scored.mp4
```

Sidechain duck (bed drops when source audio speaks) — better for narrated tutorials:

```bash
ffmpeg -y -i video.mp4 -i bed.mp3 \
  -filter_complex "[1:a]volume=0.25[bed];[0:a][bed]sidechaincompress=threshold=0.05:ratio=8:attack=20:release=400[ducked];[0:a][ducked]amix=inputs=2:duration=first[a]" \
  -map 0:v -map "[a]" -c:v copy -c:a aac -shortest out/scored.mp4
```

Fade the bed in/out:

```bash
ffmpeg -y -i video.mp4 -i bed.mp3 \
  -filter_complex "[1:a]volume=0.2,afade=t=in:st=0:d=1.5,afade=t=out:st=58:d=2[bed];[0:a][bed]amix=inputs=2:duration=first[a]" \
  -map 0:v -map "[a]" -c:v copy -c:a aac -shortest out/scored.mp4
```

Replace original audio entirely (e.g. when the source has typing noise you don't want):

```bash
ffmpeg -y -i video.mp4 -i bed.mp3 \
  -map 0:v -map 1:a -c:v copy -c:a aac -shortest out/with-bed.mp4
```

---

## 5. Generate music via ElevenLabs

Invoke under the secret bundle so the key injects automatically:

```bash
agents secrets exec elevenlabs -- bash -c '
  curl -fsSL -X POST "https://api.elevenlabs.io/v1/music" \
    -H "xi-api-key: $ELEVENLABS_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"prompt\": \"ambient piano, slow, no drums, contemplative, gold-hour\", \"music_length_ms\": 20000}" \
    --output ~/.agents/skills/animator/music/calm.mp3
'
```

Prompt advice (per ElevenLabs docs): describe instrumentation + mood + tempo + what NOT to include (no drums, no vocals). Keep clips short (≤30s) and loop with `-stream_loop -1` in ffmpeg.

Loop a short bed to fill a longer video:

```bash
ffmpeg -y -stream_loop -1 -i bed-20s.mp3 -i video-60s.mp4 \
  -filter_complex "[0:a]volume=0.2[bed];[1:a][bed]amix=inputs=2:duration=first[a]" \
  -map 1:v -map "[a]" -c:v copy -c:a aac -shortest out/scored.mp4
```

---

## 6. Splice intro / outro frames (chrome)

Pre-render the chrome via `animator compose GoldSheen --out chrome/intro.mp4 --props '{"text":"Daily Zen","subtitle":"launching"}'`, then concat. Frame rate, resolution, and pixel format must match.

```bash
# Concat list file
cat > /tmp/concat.txt <<EOF
file '/abs/path/intro.mp4'
file '/abs/path/source.mp4'
file '/abs/path/outro.mp4'
EOF

ffmpeg -y -f concat -safe 0 -i /tmp/concat.txt \
  -c:v libx264 -preset medium -crf 18 -c:a aac out/final.mp4
```

If the source is a different framerate/resolution than the chrome, normalize first:

```bash
ffmpeg -y -i source.mov -vf "scale=3840:2160:flags=lanczos,fps=30" \
  -c:v libx264 -crf 18 -c:a aac source-normalized.mp4
```

---

## 7. Downscale a 4K master for upload

Use lanczos for sharp downscales (default `bilinear` looks soft):

```bash
# 1080p web upload (no audio for silent compositions)
ffmpeg -y -i master.mp4 -vf "scale=1920:-2:flags=lanczos" \
  -c:v libx264 -preset slow -crf 20 -movflags +faststart -an out/upload-1080p.mp4

# 720p smaller embed
ffmpeg -y -i master.mp4 -vf "scale=1280:-2:flags=lanczos" \
  -c:v libx264 -preset slow -crf 22 -movflags +faststart out/upload-720p.mp4
```

`-movflags +faststart` puts the metadata at the start of the file so it streams immediately on the web.

---

## 8. Convert MP4 to WebM (smaller blog embed)

```bash
ffmpeg -y -i master.mp4 -c:v libvpx-vp9 -b:v 0 -crf 32 -c:a libopus out/embed.webm
```

WebM is 30–50% smaller for the same perceived quality, but takes longer to encode.

---

## 9. Crossfade two clips

```bash
ffmpeg -y -i clipA.mp4 -i clipB.mp4 \
  -filter_complex "[0:v][1:v]xfade=transition=fade:duration=0.8:offset=4.2[v];[0:a][1:a]acrossfade=d=0.8[a]" \
  -map "[v]" -map "[a]" -c:v libx264 -crf 18 -c:a aac out/cross.mp4
```

`offset` = where the crossfade starts in clipA's timeline. Set it to `(clipA duration) - (xfade duration)`.

---

## 10. Add a flash / cue / sting on a beat

Drop a 4-frame white flash at a specific timestamp (e.g. when a `git push` succeeds):

```bash
ffmpeg -y -i source.mp4 \
  -vf "drawbox=enable='between(t,12.3,12.43)':color=#E6EEF6@1:t=fill" \
  -c:v libx264 -crf 18 -c:a copy out/flash.mp4
```

Better: pre-render a `<Composition id="Flash">` in Remotion with proper easing and composite it.

---

## 11. Loop a video forever (silent ambient header)

In HTML:

```html
<video autoplay muted loop playsinline preload="auto">
  <source src="/hero.mp4" type="video/mp4" />
  <source src="/hero.webm" type="video/webm" />
</video>
```

For looping a Remotion composition that's already a loop (designed with matching start/end frames), no editing needed — render once and embed.

---

## 12. Verify a render

After ANY render or edit, run:

```bash
animator preview out/final.mp4 --frames 7
```

Then Read the JPGs in `out/preview/final/`. **You cannot watch MP4s directly.** If you trust the render without inspecting frames, you'll ship broken animations (font missing, gradient miscalculated, off-screen text, etc.).

---

## 13. Adding a new Remotion composition

When you need a from-scratch animation that isn't covered by the bundled compositions:

1. Create `compositions/MyComp.tsx` — React component returning `<AbsoluteFill>` with brand colors/fonts from `primitives/`.
2. Register in `src/Root.tsx`:
   ```tsx
   <Composition
     id="MyComp"
     component={MyComp}
     durationInFrames={30 * 6}    // 6s @ 30fps
     fps={30}
     width={3840}
     height={2160}
   />
   ```
3. Render: `animator compose MyComp --out out/my.mp4`.

Key Remotion patterns (looping animation driven by `useCurrentFrame`):

```tsx
const frame = useCurrentFrame();
const { fps, durationInFrames } = useVideoConfig();

const ease = Easing.bezier(0.45, 0, 0.55, 1);
const cycleFrames = 8 * fps;
const t = (frame % cycleFrames) / cycleFrames;
const phase = Math.sin(t * Math.PI);
const eased = ease(phase);
const value = interpolate(eased, [0, 1], [start, end]);
```

For spring physics (agent dispatch, drop-in cards):

```tsx
const progress = spring({
  frame: frame - startFrame,
  fps,
  config: { damping: 14, mass: 0.6, stiffness: 80 },
});
```

For SVG text with a moving gradient (avoid CSS `background-clip: text` — unreliable in headless Chromium):

```tsx
<svg width={w} height={h} viewBox={`0 0 ${w} ${h}`}>
  <defs>
    <linearGradient id="g" gradientUnits="userSpaceOnUse" x1={leftPx} y1={0} x2={rightPx} y2={0}>
      <stop offset="0%" stopColor={COLORS.paper} />
      <stop offset="50%" stopColor={COLORS.goldHi} />
      <stop offset="100%" stopColor={COLORS.paper} />
    </linearGradient>
  </defs>
  <text x="50%" y="50%" dominantBaseline="middle" textAnchor="middle" fill="url(#g)" fontFamily={FONTS.serif} fontSize={size}>
    Title
  </text>
</svg>
```

Fonts must be loaded with `delayRender` / `continueRender` (see `primitives/fonts.ts`) or text falls back to system fonts mid-render.

---

## Gotchas

- **`background-clip: text` is unreliable in Remotion's headless Chromium.** Use SVG `<text fill="url(#gradient)">` instead. Lost ~30 min to this.
- **Fonts must be awaited before rendering.** `primitives/fonts.ts` uses `delayRender` + `waitUntilDone()` — if you add a new font, add it there.
- **4K renders are large** (~250KB–2MB for 4–8s). Keep masters at 4K, downscale just before upload.
- **ffmpeg `-c copy` is fast but cuts only on keyframes.** Re-encode (`-c:v libx264 -crf 18`) when frame accuracy matters.
- **Music bed clipping**: use `duration=first` in `amix` and `-shortest` so the bed doesn't keep playing after the video ends.
- **Remotion concurrency**: defaults to `null` (= all cores). Fine for 4K renders. If your machine thermals are a concern, set `Config.setConcurrency(4)`.
- **Don't ship 0:42 to a user; ship "0:42 of 1:30 elapsed"** or similar — humans want context. Same rule as elsewhere: "13 minutes" not "12m 49s".
