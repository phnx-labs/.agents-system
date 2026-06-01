---
name: composer
description: "Audio composition. Generates music beds, sound effects, and structured arcs via ElevenLabs. Masters with ffmpeg (fade-in/out, EBU R128 normalize). Crucially, produces a markers.json sidecar with named-section timestamps so a video composition can sync its hand-offs and reveals to musical boundaries. Append-only library — every generation lands in takes/ with a timestamp; explicit `composer pick` promotes a take to canonical/ and locks it read-only. Triggers on: compose music, music bed, score, sound effect, sfx, audio for video, release video score, build-up and drop, master audio, loudness normalize, ElevenLabs music."
argument-hint: "[task — e.g. 'score for the v1 launch', 'sound effect for a button-press transition', 'master and pick the take from 15:10']"
allowed-tools: Bash(*), Read(*), Write(*)
user-invocable: true
---

# composer

Sister to **`animator`**. Animator owns pixels (Remotion, ffmpeg-for-video). Composer owns time + harmony (ElevenLabs, audio post). For a release video, you'll use both: composer for the score, animator for the visual composition that syncs to it.

> **This skill is a tool, not a brand surface.** The example specs ship a neutral style. Override the brand voice per project — your launch video's score has nothing to do with mine. Canonical track names like `release-arc-v1` are your project's keepers; pick your own slugs and don't reuse a spec across unrelated videos.

## Decision: which command do I actually reach for?

Read this FIRST. The dominant failure mode is reaching for `composer score` when a canonical SFX or a quick `composer music` clip is the right tool. Score is for structured arcs; most short surfaces don't need one.

| Clip length | Visual character | Reach for | Why |
|---|---|---|---|
| **< 5s** | single hit (logo reveal, button-press, dispatch confirm) | `sfx/canonical/INDEX.md` lookup → if nothing fits, `composer sfx` | Sections don't make sense at this scale. The library already covers most short hits. |
| **5–15s** | atmosphere + one or two hits (short morph, OG card, social loop) | `composer music --duration <s>` for the bed + canonical SFX layered on hits | `composition_plan`'s 3000ms-per-section minimum makes 3-section arcs feel forced under 15s. |
| **15–60s** | named sections, build → drop → dwell, syncable beats | `composer score --spec <spec.yaml>` | Score's section markers let the video sync hand-offs to musical boundaries. |
| **> 60s** | long-form (demo, podcast intro, recap reel) | Score with multiple specs `composer chain`-ed, or a licensed library | One `composition_plan` caps around 40–60s. Beyond that, glue takes. |

**Check the canonical SFX library before generating anything new.** `sfx/canonical/INDEX.md` is the contract — ship-ready files with character descriptions and pairing notes. Most short hits are already there.

**The no-rookie-SFX rule:** no whooshes, no swishes, no glitch artifacts, no "ding!" chimes, no abrupt cartoony impacts, no EDM riser sweeps. Allowed: sustained warm tones, chord settlings, room tone, soft sub-bass pulses, analog textures. *Would Apple or A24 ship this?* If yes, keep going. If it sounds like a YouTube transition, kill it.

## The signature move

For any release/launch video, **start with the score**. The video should be timed to the music, not the other way around. The flow:

1. **Probe before composing** — if there's source audio (voiceover, screen capture, reference track), run `composer probe <audio>` first. Read the JSON. Decide whether the score should match the source's energy or contrast it.
2. **Write a fresh spec** — `specs/release-arc.yaml` is a *reference*, not a default. Each request gets its own spec, shaped from the source vibe + the intended emotional arc. Copy the reference, mutate freely, save as `specs/<your-slug>.yaml`. Don't reuse the same spec for unrelated videos.
3. `composer score <slug> --spec <spec.yaml>` — single ElevenLabs `composition_plan` generation. Emits the mp3 + a markers JSON with each section's `start_ms` / `end_ms`.
4. **Verify the arc was actually delivered** — `composer probe music/takes/<slug>--<ts>.mp3 --by-section`. The probe reports LUFS / dynamic range / silence ratio per section. If the "drop" section came out quieter than the "build", the generation didn't deliver — regenerate or tighten the spec's negative styles.
5. Iterate. Stochastic output — same spec yields different takes. Every call lands a new file in `music/takes/<slug>--<timestamp>.mp3`. Nothing is overwritten.
6. Listen, pick the keeper: `composer pick <take-slug>` promotes it to `music/canonical/<base>.mp3`, chmods it read-only, archives any prior canonical with a timestamp.
7. The video composition reads `music/canonical/<base>.markers.json` and times the hand-offs to those exact section boundaries.

This is why the score has named sections: the video knows what "drop" and "dwell" mean, and can lock its camera moves to them.

## Compose creatively, not from templates

**Every video deserves its own score, shaped by judgment, not stamped from a template.** Generating from a generic "warm contemplative" prompt that has nothing to do with the specific moment being captured is the failure mode. What the agent does instead, on each request:

1. **What is this video about?** A solo founder milestone deserves different music than a Series A announcement than a feature drop than a blog header. Stop, read the context.
2. **What's the source telling us?** If there's screen-capture audio or a voiceover, probe it. Quiet-and-sparse source → bed needs to be present without competing → tighter LRA, fewer silences. Loud-and-talky source → bed needs to duck → wider LRA, instrumental, more space.
3. **What's the emotional arc?** Anticipation → reveal → dwell is one shape. Confident-from-the-start → drop → outro is another. Quiet-throughout-with-a-single-hit is a third. The arc dictates section count, durations, and transition character.
4. **Write the spec.** Section names should mean something for *this* video. `chip-light-up` and `artifact-reveal` are better names than `build` and `drop` when the video has those exact moments.
5. **Generate, probe, iterate.** Compare the probe output to the spec's intent — did the drop actually get louder? Did the intro have the negative space you asked for?

The CLI is a tool. The spec is the score. The agent is the composer.

## Probing audio

`composer probe <audio>` runs ffmpeg's `ebur128` + `astats` + `silencedetect` and emits structured JSON:

```bash
composer probe music/canonical/release-arc-v1.mp3 --by-section
```

How to read it:

- **Integrated LUFS** — perceived loudness over time. -14 to -16 is typical for video beds. Lower is quieter.
- **LRA (loudness range)** — dynamic range. Low LRA (< 2 LU) = continuous, punchy, controlled. High LRA (> 6 LU) = expressive, breathing, wide dynamics.
- **True peak dBFS** — ceiling. Mastered tracks sit at -1 to -2. Higher (less negative) = louder masters.
- **silence_ratio_at_-40dB** — fraction of the section below -40 dB. High = sparse, ambient, lots of negative space. Low = continuous, dense.

Use the probe to **diagnose mismatches between spec intent and what the model delivered**:

| Symptom | Probe signal | What to fix in the spec |
| --- | --- | --- |
| Drop doesn't land | Drop LUFS ≤ Build LUFS | Add to drop's positive: "louder", "kick enters", "clean four-on-floor". Add to build's negative: "kick drum (not yet)". |
| Section feels empty | High `silence_ratio_at_-30dB` for that section | Add positive style for continuous element ("sustained pad", "constant pulse"). |
| Whole track too dynamic / loose | Overall LRA > 6 | Add global negative: "wide dynamic range", "extreme dynamics". Master more aggressively. |
| Track sounds same throughout | Per-section LUFS within 1 LU | Sections need bigger style contrasts in spec; intro/outro should differ more from drop. |

Probe is also the right tool for **matching a reference**. Probe the reference → derive target loudness, LRA, density → bake those into the spec's global + section styles → generate → re-probe to verify proximity to the reference.

## Commands

```bash
composer list
                            # Canonical (locked), takes (pending), SFX, specs.

composer music <slug> --mood "<prompt>" [--duration <sec>]
                            # Unstructured music bed via /v1/music.
                            # Writes music/takes/<slug>--<ts>.mp3.

composer sfx <slug> --text "<prompt>" [--duration <sec>] [--loop]
                            # Sound effect via /v1/sound-generation.
                            # --loop produces a seamlessly loopable clip.

composer score <slug> --spec <spec.yaml>
                            # Structured arc via composition_plan.
                            # Writes the mp3 + markers.json + plan.json.

composer chain <out.mp3> <in1.mp3> <in2.mp3> [...] [--crossfade <sec>]
                            # Glue 2+ clips with crossfade. Fallback for when
                            # one composition_plan can't reach the arc you want.

composer master <in.mp3> [<out.mp3>] [--fade-in <s>] [--fade-out <s>] [--lufs <db>]
                            # fade-in + fade-out + EBU R128 normalize.
                            # If <out.mp3> is omitted, derives a take filename
                            # so masters also never overwrite.

composer probe <audio> [--by-section]
                            # Analyze with ffmpeg ebur128 + astats +
                            # silencedetect. Emits JSON with loudness, levels,
                            # density. --by-section requires a sibling
                            # .markers.json. Use BEFORE generating to-match.

composer pick <take-slug>
                            # Promote a take to canonical:
                            #   music/takes/<take>.mp3 -> music/canonical/<base>.mp3
                            # <base> is everything before '--' in the take slug.
                            # Any prior canonical is moved to _archive/ with a
                            # 'prev-canonical-<ts>' suffix. New canonical is
                            # chmod 444 (read-only).
```

## Library layout

```
skills/composer/
├── SKILL.md                  this file
├── RECIPES.md                ElevenLabs + ffmpeg patterns; iteration recipes
├── scripts/
│   └── composer              the CLI
├── specs/
│   └── release-arc.yaml      canonical 40s arc spec for release videos
├── music/
│   ├── canonical/            ship-ready, chmod 444. Read these in compositions.
│   ├── takes/                every generation lands here, never overwritten
│   └── _archive/             prior canonicals + off-brand legacy
└── sfx/
    ├── canonical/            ship-ready SFX (UI chimes, transitions, room tone)
    ├── takes/                generated SFX awaiting pick
    └── _archive/             retired SFX
```

The `canonical/` directory is the contract with downstream skills. The `animator` skill resolves audio paths under `composer/music/canonical/` and `composer/sfx/canonical/`.

## Score spec format

```yaml
slug: release-arc-v1
global:
  positive: [modern electronic film score, agentic forward motion, controlled tension]
  negative: [acoustic piano, ambient meditation, vocals, EDM cliche]
sections:
  - name: intro
    duration_ms: 6000      # 3000..120000ms per section (model limit)
    positive: [low sub-bass pulse, distant synth pad rising, anticipation]
    negative: [drums, melody]
  - name: build
    duration_ms: 8000
    positive: [layered synth, ticking hi-hat, rising tension]
    negative: [kick drum]
  - name: drop
    duration_ms: 14000
    positive: [clean four-on-the-floor kick, glitchy arpeggio, agentic energy]
    negative: [vocals, dubstep wobble]
  - name: dwell
    duration_ms: 8000
    positive: [kick recedes, pad sustains, atmospheric]
  - name: outro
    duration_ms: 4000
    positive: [filter sweep down, fade-friendly tail]
    negative: [sudden cut]
```

Section names become marker names. Use short, descriptive identifiers (intro, build, drop, dwell, outro, hook, payoff, etc.) — the video composition will switch on them.

## Sync the video to the score

Inside a Remotion composition:

```tsx
import markers from "../music/canonical/release-arc-v1.markers.json";

const sectionAtFrame = (frame: number, fps: number) => {
  const t = (frame / fps) * 1000;
  return markers.sections.find(s => t >= s.start_ms && t < s.end_ms);
};

// In your component:
const frame = useCurrentFrame();
const { fps } = useVideoConfig();
const section = sectionAtFrame(frame, fps);  // {name, start_ms, end_ms}
// Drive chip hand-offs, artifact-section reveals, etc. off section?.name
```

The hand-offs are no longer guessed timestamps — they're locked to musical boundaries.

## Prompt advice

Per ElevenLabs docs:

- Describe **instrumentation + tempo + mood + what NOT to include**.
- The model takes negatives seriously. "no drums", "no vocals", "no melody" are honored.
- Keep section durations honest — a 3s section produces a 3s section, not a hint.
- **Brand names trip moderation.** Naming "A24", "Apple", "Pixar", specific artists returns `bad_composition_plan` (400). The error body includes a `composition_plan_suggestion` with a sanitized rewrite — read it and apply the equivalent generic phrasing to your spec ("A24 trailer" → "indie film trailer with moody atmospheric textures").

## Setup

Requires an `elevenlabs` secret bundle with `ELEVENLABS_API_KEY` (Creator+ tier for Music API; SFX works on lower tiers but costs ~20 credits/sec). The CLI calls `agents secrets exec elevenlabs -- ...` automatically.

```bash
brew install ffmpeg                          # if missing
agents secrets list | grep elevenlabs        # confirm bundle exists
composer list
```

## When NOT to use composer

- Voiceover. ElevenLabs voice is a different endpoint, lives outside this skill.
- Generic background music for a long screen capture — use a licensed library (Pixabay Audio, Epidemic Sound, Artlist). Composer is for the moments that matter.
- Overlaying a bed onto an existing video — that's an animator operation (see `animator` RECIPES.md §4).
- Live recording, microphone capture, multi-track editing. Use a real DAW (Logic, Ableton).

## See also

- [`RECIPES.md`](RECIPES.md) — ElevenLabs request shapes, ffmpeg filter graphs, iteration loops, moderation rewrite handling.
- `animator` — Remotion compositions, video edit, ffmpeg-for-video. Imports composer's `canonical/` as a sibling skill.
