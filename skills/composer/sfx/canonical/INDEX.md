# Canonical SFX library

Ship-ready SFX. Each file is chmod 444 — read these from video compositions, never overwrite.

## How to use this

Before reaching for `composer sfx` to generate something new, scan this table. Most short hits a product video needs are already here. The composer SKILL.md decision matrix points you here first.

Import in a Remotion composition:

```tsx
import paperRustle from "../../composer/sfx/canonical/paper-rustle-2s.mp3";
<Audio src={paperRustle} volume={0.6} />
```

Or in ffmpeg:

```bash
ffmpeg -i video.mp4 -i <repo>/skills/composer/sfx/canonical/paper-rustle-2s.mp3 -filter_complex "..." out.mp4
```

## The library

| File | Duration | LUFS | Peak | Character | Use when | Brand fit |
|---|---|---|---|---|---|---|
| `boot-hum-3s.mp3` | 3.0s | −12.7 | −1.1 | Sustained low electronic hum, continuous, no transient. Wakeful machine-on tone. | Behind a system-coming-online beat, dispatch confirmation, sustained underbed. | **Keeper** |
| `room-tone-5s.mp3` | 5.0s | −43.6 | −27.3 | True ambient room tone — air, distant HVAC, no content. The silence-that-isn't-silence. | Layer at −20 dB under any sustained scene to keep it from feeling dead. Critical for editorial register. | **Keeper** |
| `paper-rustle-2s.mp3` | 2.0s | −41.4 | −18.4 | Sparse paper texture, analog, dry, no reverb. Pages turning slowly. | Paper-register videos, parchment / editorial scenes. | **Keeper** |
| `typing-soft-2s.mp3` | 2.0s | −27.5 | −3.4 | Soft mechanical keyboard, no clicks-as-cliché. Restrained, real. | Behind any "writing happens" beat — drafting, code shipping, demo voice-over. | **Keeper** |
| `chime-success-2s.mp3` | 2.0s | −36.5 | −18.7 | Sparse, quiet bell-like tone, 74% silence — not a "ding!" Closer to a single note settling. | Soft success confirmation, end-of-task moment. Verify character before shipping — name is generic, sound is restrained. | **Probably keeper** — listen to confirm it's not a tinkly "ding". |
| `hover-tick-1s.mp3` | 1.0s | −28.9 | −9.4 | Short tactile tick, sparse. UI feedback texture. | Hover state, micro-interaction. Use ONE per scene, not as a percussion. Watch for cuteness drift. | **Conditional** — fine if it reads as tactile click; flag if it reads as toy/UI-cute. |
| `shutter-click-1s.mp3` | 1.0s | −14.1 | **+0.4** | Camera-shutter mechanical click. **Peak clips at +0.4 dBFS — needs re-mastering before ship.** | Capture/snapshot moments. Avoid if a softer tactile beat works. | **Broken master** — re-render via `composer master --lufs -16` before use. |
| `pop-burst-1s.mp3` | 1.0s | −17.8 | −1.5 | Short, hot, percussive pop. | **Likely off-brand.** Cartoony register. | **OFF-BRAND** by the no-rookie-SFX rule. Kept for legacy projects only. |
| `slam-impact-1s.mp3` | 1.0s | −21.7 | −0.4 | Hard percussive impact, abrupt transient, no decay tail. | "Title card lands" moments. | **OFF-BRAND** — abrupt impacts collide with editorial register. Use a sustained warm chord landing instead. |
| `whoosh-transition-1s.mp3` | 1.0s | **−9.2** | **+1.2** | Air-movement transition swell — the classic YouTube/tutorial swoosh. **Peak clips at +1.2 dBFS.** | Transitions. | **OFF-BRAND** — explicitly banned per the no-rookie-swooshes rule. Also broken master. Deprecate. |

## The rule

Per the no-rookie-SFX rule:

| Allowed family | Banned family |
|---|---|
| Sustained warm brass tones | Whoosh / swoosh / swish transitions |
| Single chord settlings | Glitch, stutter, granular abrupt cuts |
| Room tone, air, breath | Hard cartoony impacts (slam, pop, burst) |
| Soft sub-bass pulses | "Ding!" chimes |
| Analog textures (paper, ink, fabric) | Beep-boop UI, blips, "pew pew" |
| Held drones with slow filter | EDM riser sweeps |

When in doubt: **would Apple or A24 ship this?** If yes, keep. If it sounds like a YouTube transition, deprecate.
