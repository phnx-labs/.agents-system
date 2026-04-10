# Creative Analysis Reference

Shared analysis framework across all creative media. Each medium has its own dimensions, but the diagnostic approach is the same: identify the gap between intention and execution, and be specific about where and why it exists.

## Analysis Modes by Input Type

| Input | Dimensions | Tools |
|-------|-----------|-------|
| **Written content** (blog, essay, copy, email) | Visual + Composition + Prose + Word Choice + Neural | Browser (visual), brain-scan (neural) |
| **Image** (photo, illustration, design, logo) | Composition + Color + Emotional Impact + Technical | Browser (viewing) |
| **Audio** (podcast, voiceover, music) | Pacing + Tonal Variation + Engagement Curve + Technical | brain-scan (neural) |
| **Video** (ad, content, presentation) | Visual + Audio + Pacing + Retention + Neural | brain-scan (neural) |

## Dimension: Neural Engagement (all media)

Uses Meta TRIBE v2 brain simulation model. Predicts fMRI activation across 20,484 cortical vertices per second. Applicable to text (converted to speech), audio, and video.

**When to use**: After the subjective analysis is complete. Neural data validates or challenges your reading. It does NOT replace editorial judgment -- it grounds it in predicted brain response.

**How to invoke**: Run `/brain-scan` with the content. The brain-scan skill handles text-to-speech conversion, model execution, and region mapping.

**Brain regions and what they mean for creative work**:

| Region | Creative Implication |
|--------|---------------------|
| **Language** (Broca/Wernicke) | Novel vs. predictable expression. High = the audience is actively processing your craft. Low = autopilot. |
| **Attention** (frontal/parietal) | Focus vs. drift. High = the audience is with you. Low = you're losing them. |
| **Emotion** (limbic) | Felt vs. abstract. High = the work lands emotionally. Low = intellectually interesting but cold. |
| **Memory** (temporal) | Sticky vs. forgettable. High = this will be remembered. Low = in one ear, out the other. |
| **Default Mode** (precuneus) | Mind-wandering. High = the audience is thinking about themselves, not your work. The anti-signal. |

**Editing rules from neural data**:
- Opening should be in the Top 3 by Overall score
- Any section in Bottom 3 with Attention < 0.08 needs rewriting or cutting
- Q1-to-Q4 engagement drop > 40% = the piece loses its audience
- Emotion < 0.06 = "dry" -- add human stakes, vivid imagery, conflict
- If Default Mode is the highest region for any section, that section causes mind-wandering

**What neural data does NOT tell you**:
- Whether the writing is good (it measures processing, not quality)
- Whether the argument is sound (a false claim can spike engagement)
- Whether the tone is appropriate (outrage spikes attention but may be wrong for the context)

## Dimension: Visual Presentation (written content, images, video)

### For Written Content

The page as artifact. Does the visual presentation invite reading or create friction?

- Above-the-fold impression -- what does the reader see before scrolling?
- Typography -- font, size hierarchy, line height, measure
- Whitespace -- breathing room vs. claustrophobic density
- Color and contrast -- sustained reading support or visual fatigue
- Layout -- does the structure guide the eye or scatter it?
- Mobile rendering -- degrades or adapts?

### For Images

- Composition -- rule of thirds, leading lines, visual weight distribution
- Color harmony -- complementary, analogous, monochromatic; intentional or accidental?
- Focal point -- where does the eye land first? Is it where the creator intended?
- Emotional tone -- what feeling does the image evoke before conscious analysis?
- Technical execution -- exposure, focus, noise, resolution

### For Video

- Opening frame -- does it earn the first 3 seconds?
- Visual rhythm -- cuts per minute, motion patterns, static vs. dynamic
- Color grading -- consistent mood or inconsistent palette?
- Text overlays -- readable, well-timed, or distracting?

## Dimension: Composition (written content)

Architecture, not sentences. The arrangement of parts.

- Section flow -- does the sequence create momentum? Could sections be rearranged without loss?
- Text-to-visual ratio -- walls of text vs. images, code blocks, callouts
- Paragraph length as rhythm -- uniform length is deadening
- Entry points -- headers, bold text, images for scanners
- Opening and closing -- energy at start, resonance at end
- Pacing -- intentional acceleration and deceleration

## Dimension: Prose Craft (written content)

Sentence-level execution. Sample 3-5 passages from different sections.

- Sentence rhythm -- variation in length, or metronomic uniformity?
- Fragment use -- emphasis (earned) or tic (formulaic)?
- Transitions -- logic and momentum, or mechanical connectives?
- Voice -- human personality or interchangeable?
- Techniques -- refer to `/writer` skill for prose patterns

## Dimension: Word Choice (written content)

Vocabulary texture.

- Register -- appropriate for audience and format?
- Concrete vs. abstract -- grounded in specifics or floating?
- Jargon density -- expected vs. decorative
- Cliche and dead metaphor
- Tone consistency -- shifts signal uncertain identity

## Dimension: Pacing (audio, video)

Temporal rhythm across the piece.

- Opening hook -- first 3-5 seconds
- Variation -- monotone delivery vs. dynamic shifts
- Dead zones -- sections where energy flatlines
- Climax placement -- where is the peak moment?
- Closing -- does it land or trail off?

## Diagnostic Output

The analysis is a cohesive reading, not a checklist. Name specific passages, quote specific sentences, point to specific visual or audio elements.

End with **The Diagnosis** -- 2-3 sentences that capture the core gap between intention and execution.

When neural data is available, include a **Neural Findings** section that maps brain region activations to the subjective observations. Agreement between subjective reading and neural data strengthens the diagnosis. Disagreement reveals blind spots -- the writer's intention may not match the audience's brain response.
