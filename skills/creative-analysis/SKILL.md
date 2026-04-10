---
name: creative-analysis
description: >-
  Analyze creative work across multiple dimensions. Supports text (blog posts, essays, copy),
  images, audio, and video. Combines subjective craft analysis with neural engagement data
  (via TRIBE v2 brain simulation). Triggers on: analyze writing, creative analysis, prose autopsy,
  writing critique, blog analysis, page review, review this post, content analysis, engagement analysis,
  what's wrong with this writing, why does this sound robotic.
allowed-tools: Bash(ssh*), Bash(openclaw*), Bash(*/env.sh*), Bash(sleep*), Bash(scp*), Bash(cat*)
user-invocable: true
---

# Creative Analysis

Diagnose creative work across all relevant dimensions for its medium. The output is a cohesive reading -- what works, what doesn't, and why -- not a scorecard.

Read `${CLAUDE_SKILL_DIR}/REFERENCE.md` for the full analysis framework covering all dimensions and media types.

## Input

`$ARGUMENTS` = a URL, a file path, or inline text. Determine the medium type:
- **Text/URL**: blog post, essay, copy, email -> prose analysis + optional neural
- **Image**: photo, illustration, design -> visual analysis
- **Audio**: podcast, voiceover, music -> pacing + neural
- **Video**: ad, content, presentation -> visual + audio + neural

## Workflow

### For Written Content (default)

1. **If URL provided:** Load `/browser`. Open the URL. Screenshot at desktop and mobile viewports. Study the visual dimension.
2. **Read the content.** If URL, fetch or read via snapshot. If file, read directly.
3. **Analyze all four prose dimensions** in order (Visual, Composition, Prose, Word Choice). Each informs the next.
4. **Neural analysis (recommended).** Run `/brain-scan` on the text to get per-paragraph brain engagement data. Map neural findings to your subjective observations.
5. **Synthesize a diagnosis.** One cohesive reading that identifies the central tension between intention and execution.

### For Images

1. View the image (browser or file read).
2. Analyze: Composition, Color, Emotional Impact, Technical execution.
3. Synthesize diagnosis.

### For Audio/Video

1. Run `/brain-scan --audio <file>` for neural engagement curve.
2. Analyze pacing, tonal variation, retention.
3. Synthesize diagnosis.

## Output

Write the analysis as a short essay, not a checklist. Use the dimensions as loose structure, but let the diagnosis flow naturally. Name specific passages, quote specific sentences, point to specific elements.

When neural data is available, include a **Neural Findings** section showing how brain activation maps to your subjective reading. Agreement strengthens the diagnosis. Disagreement reveals blind spots.

End with **The Diagnosis** -- 2-3 sentences that capture the core issue.

## Calibration

- **Do not score.** No numbers, no letter grades, no percentages. Scores create false precision.
- **Do not prescribe formulas.** Quote the passage that drones, don't say "use more variety."
- **Be specific.** Every observation must point to a specific passage, element, or pattern.
- **Be honest.** Good work deserves recognition. Bad work deserves clarity.
- **Connect the dimensions.** The best insights cross boundaries: "The typography is elegant but the prose doesn't match its ambition."
- **Use neural data to ground, not replace.** Brain activation validates your reading. It does not substitute for editorial judgment.
