# RECIPES.md — composer

Working examples and gotchas. Read SKILL.md first for the overall architecture (takes → pick → canonical, score → markers → video sync).

The CLI wraps the canonical operations. Drop to raw curl / ffmpeg when you need a parameter the CLI doesn't expose (e.g. `seed`, `composition_plan` advanced fields, manual filter graphs).

---

## 1. Generate a structured arc (the canonical path)

```bash
composer score release-arc-v1 --spec specs/release-arc.yaml
```

What lands in `music/takes/`:

- `<slug>--<timestamp>.mp3` — composed track
- `<slug>--<timestamp>.markers.json` — `{total_ms, sections:[{name,start_ms,end_ms,duration_ms}]}`
- `<slug>--<timestamp>.plan.json` — exact body POSTed. Diff against future iterations to see what changed.

After listening, promote:

```bash
composer pick release-arc-v1--20260515-151013
# -> music/canonical/release-arc-v1.mp3 (chmod 444)
# -> music/canonical/release-arc-v1.markers.json
# -> music/canonical/release-arc-v1.plan.json
# Prior canonical (if any) moves to _archive/ with a 'prev-canonical-<ts>' suffix.
```

The composition reads from `music/canonical/<slug>.mp3` + `.markers.json`. Once canonical, the file is read-only — to ship a replacement, generate a new take and `composer pick` it. The old canonical isn't lost; it's in `_archive/`.

---

## 2. Unstructured music bed

For blog headers, social loops, or any video that doesn't need internal sync. One generation, no sections:

```bash
composer music gold-hour-piano \
  --mood "warm ambient piano, slow, no drums, gold-hour, contemplative" \
  --duration 25
```

**This is rarely what you want for a release video.** An unstructured 25s bed has no internal arc — no build, no drop. Use `composer score` with sections instead. The off-brand archive at `music/_archive/` is full of these — preserved as a negative reference.

---

## 3. Sound effects

```bash
composer sfx chime-success \
  --text "soft UI chime, two notes ascending, clean digital bell, no reverb tail" \
  --duration 2

# Seamless loop (room tone, ambient drone, mechanical hum)
composer sfx room-tone \
  --text "calm room tone, distant white noise, faint air, loopable" \
  --duration 5 --loop
```

Tier note: `loop:true` is only valid on `eleven_text_to_sound_v2` (the CLI's default). Lower tiers can call SFX but each second costs ~20 credits — a 30s clip burns 600. Plan generation counts.

---

## 4. Chain — for when one composition_plan can't reach the arc

`composer score` is the default. `composer chain` is the escape hatch — used when (a) you need >2min cumulative which exceeds composition_plan limits, (b) one section needs a radically different production aesthetic, or (c) you want to swap a section without regenerating everything else.

```bash
composer chain music/takes/my-mix-out.mp3 \
  music/canonical/release-arc-v1.mp3 \
  music/takes/release-arc-v1-outro--<ts>.mp3 \
  --crossfade 1.5
```

Total duration = sum(inputs) − (N−1) × crossfade. Crossfades use `acrossfade=d=<dur>:c1=tri:c2=tri`.

Raw ffmpeg equivalent (chained pairwise):

```bash
ffmpeg -y -i a.mp3 -i b.mp3 -i c.mp3 \
  -filter_complex "[0:a][1:a]acrossfade=d=1.5:c1=tri:c2=tri[a01];[a01][2:a]acrossfade=d=1.5:c1=tri:c2=tri[aout]" \
  -map "[aout]" -c:a libmp3lame -b:a 192k out/mix.mp3
```

---

## 5. Master — fade-in, fade-out, LUFS

```bash
composer master music/takes/release-arc-v1--<ts>.mp3 \
  --fade-in 1.0 --fade-out 3.0 --lufs -16
# Auto-derives an output path: music/takes/release-arc-v1-mastered--<new-ts>.mp3
```

LUFS targets:

| Use | LUFS | Why |
| --- | --- | --- |
| Release video bed (no VO) | -16 | Default. Sits under typography reveals. |
| Tutorial/VO under bed | -23 | Headroom for ducking under a -16 LUFS voice track. |
| Hero blog header (silent visuals) | -14 | Loud enough on laptop speakers when user unmutes. |

Raw ffmpeg (single-pass loudnorm; for broadcast use two-pass):

```bash
ffmpeg -y -i in.mp3 \
  -af "afade=t=in:st=0:d=1.0,afade=t=out:st=36.97:d=3.0,loudnorm=I=-16:TP=-1.5:LRA=11" \
  -c:a libmp3lame -b:a 192k out.mp3
```

`st=` on fade-out is `(duration − fade_out_seconds)`. The CLI computes this for you.

---

## 6. Iterate a spec

Stochastic generation — same spec yields different output. Iteration loop:

```bash
composer score release-arc-v1 --spec specs/release-arc.yaml   # take A
composer score release-arc-v1 --spec specs/release-arc.yaml   # take B
composer score release-arc-v1 --spec specs/release-arc.yaml   # take C
composer list                                                  # see all three
# Pick the best
composer master music/takes/release-arc-v1--<ts-of-best>.mp3
composer pick release-arc-v1-mastered--<ts-from-master-output>
```

If you need a reproducible take, add `"seed": <int>` to the body. Not exposed by the CLI — drop to raw curl:

```bash
agents secrets exec elevenlabs -- bash -c '
  PLAN=$(cat music/takes/release-arc-v1--<ts>.plan.json | python3 -c "import json,sys; d=json.load(sys.stdin); d[\"seed\"]=42; print(json.dumps(d))")
  curl -fsSL -X POST "https://api.elevenlabs.io/v1/music?output_format=mp3_44100_128" \
    -H "xi-api-key: $ELEVENLABS_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$PLAN" \
    --output music/takes/release-arc-v1-seed42--<ts>.mp3
'
```

---

## 7. Tune the spec — read the moderation suggestion

When ElevenLabs rejects a prompt with `bad_composition_plan` (400), the error body includes a `composition_plan_suggestion` with sanitized rewrites:

```json
{
  "detail": {
    "code": "bad_request",
    "status": "bad_composition_plan",
    "data": {
      "composition_plan_suggestion": {
        "positive_global_styles": [
          "cinematic, indie film trailer aesthetic with moody and atmospheric textures",
          // ...
        ],
        "sections": [/* full rewrite */]
      }
    }
  }
}
```

The score CLI writes the error body to `music/takes/<slug>--<ts>.err.json`. Read it, apply the suggested phrasings back into your spec, regenerate. Known triggers:

- Brand names: "A24" → "indie film trailer with moody atmospheric textures"
- Company names: "Apple keynote" → "dynamic tech product launch momentum with driving rhythm and uplifting synths"
- Artist names: "Trent Reznor" → describe the technique ("controlled-tension electronic, restrained percussion")

Update the spec, not just one call. The spec is the source of truth.

---

## 8. The libmp3lame quirk

ffmpeg 8.1.1 + libmp3lame prints these on close even when the output is valid:

- `Conversion failed!`
- `[libmp3lame @ ...] 3 frames left in the queue on closing`
- `[libmp3lame @ ...] inadequate AVFrame plane padding`
- `Error submitting audio frame to the encoder`
- `Error encoding a frame: Invalid argument`
- `Task finished with error code: -22`

ffmpeg exits non-zero anyway. The CLI suppresses these specific lines and verifies the output by re-probing with ffprobe. If you write raw ffmpeg yourself, **don't trust the exit code alone** — check the duration:

```bash
dur=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 out.mp3)
```

If `$dur` is a number close to your expected duration, the file is fine.

---

## 9. Take naming convention

```
<slug>--<YYYYMMDD-HHMMSS>.mp3                  # generated take
<slug>--<YYYYMMDD-HHMMSS>.markers.json         # sidecar (score only)
<slug>--<YYYYMMDD-HHMMSS>.plan.json            # sidecar (score only)
<slug>-mastered--<YYYYMMDD-HHMMSS>.mp3         # output of `composer master`
<slug>.mp3                                      # canonical (after `composer pick`)
<slug>.markers.json                             # canonical sidecar
<slug>--prev-canonical-<YYYYMMDD-HHMMSS>.mp3   # archived prior canonical
```

`composer pick` derives the canonical name by splitting the take slug on `--` and taking the first part. So `release-arc-v1--20260515-145600` and `release-arc-v1-mastered--20260515-151013` both promote to canonical `release-arc-v1.mp3`.

---

## 10. Wiring into a Remotion composition

```tsx
// skills/animator/compositions/Release.tsx
import { useCurrentFrame, useVideoConfig, AbsoluteFill, Audio, staticFile } from "remotion";
import markers from "../../../composer/music/canonical/release-arc-v1.markers.json";

const sectionAtFrame = (frame: number, fps: number) => {
  const t = (frame / fps) * 1000;
  return markers.sections.find((s) => t >= s.start_ms && t < s.end_ms);
};

export const Release: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const section = sectionAtFrame(frame, fps);

  return (
    <AbsoluteFill style={{ background: "#080C14" }}>
      <Audio src={staticFile("release-arc-v1.mp3")} />
      {/* Drive component state off section?.name */}
      {section?.name === "intro" && <Roster />}
      {section?.name === "build" && <RosterLive activeIndex={0} />}
      {section?.name === "drop" && <ArtifactReveal />}
      {section?.name === "dwell" && <ArtifactDwell />}
      {section?.name === "outro" && <CloseFrame />}
    </AbsoluteFill>
  );
};
```

The audio mp3 is referenced via `staticFile()` — Remotion's `public/` dir is the only path it knows. Symlink the canonical track:

```bash
ln -sf <repo>/skills/composer/music/canonical/release-arc-v1.mp3 \
       <repo>/skills/animator/public/release-arc-v1.mp3
```

The composition imports `markers.json` directly via the file path (TS resolves it at build time, no `staticFile` needed for JSON).

The `durationInFrames` of the composition must match the score: `40s × 30fps = 1200 frames`. The score IS the spec — the video conforms to it.
