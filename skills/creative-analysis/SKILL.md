---
name: creative-analysis
description: >-
  Analyze creative writing across four dimensions: visual presentation, composition,
  prose craft, and word choice. Takes a URL or text. Produces a cohesive diagnosis,
  not a checklist. Triggers on: analyze writing, creative analysis, prose autopsy,
  writing critique, why does this sound robotic, blog analysis, page review,
  review this post, what's wrong with this writing.
allowed-tools: Bash(ssh*), Bash(openclaw*), Bash(*/env.sh*), Bash(sleep*)
user-invocable: true
---

# Creative Analysis

Diagnose creative writing across four dimensions. The output is a cohesive reading -- what works, what doesn't, and why -- not a scorecard.

Read the `/writer` skill for prose craft principles. Load the `/browser` skill for visual analysis commands.

## Input

`$ARGUMENTS` = a URL, a file path, or inline text. If a URL, open it in the browser for visual analysis. If text or file, skip the visual dimension unless the user provides a screenshot.

## The Four Dimensions

Analyze in this order. Each dimension informs the next.

### 1. Visual (the page as artifact)

Open the URL in a browser. Screenshot at desktop (1440px) and mobile (375px). Study what you see.

**What to notice:**
- Above-the-fold impression -- what does the reader see before scrolling? Does it earn the scroll?
- Typography -- font choice, size hierarchy, line height, measure (line length). Does the type invite reading or repel it?
- Whitespace -- breathing room between elements, or claustrophobic density?
- Color and contrast -- does the palette support sustained reading or fight it?
- Layout -- does the structure guide the eye or scatter it?
- Mobile rendering -- does the experience degrade or adapt?

This is not a design audit. You are asking: does the visual presentation make someone want to read, or does it create friction before the first word is processed?

### 2. Composition (the arrangement)

Read the page structure, not the sentences. Look at the architecture.

**What to notice:**
- Section flow -- does the sequence create momentum? Could you rearrange sections without loss? (If yes, the structure is weak.)
- Text-to-visual ratio -- walls of text vs. images, code blocks, callouts. Is there visual relief?
- Paragraph length as rhythm -- a page of uniform 4-line paragraphs is as deadening as uniform 15-word sentences. Look for variation.
- Entry points -- can a scanner find their way in? Headers, bold text, images create entry points. Their absence means only linear readers survive.
- Opening and closing -- does the piece open with energy and close with resonance?
- Pacing -- where does the piece accelerate and where does it slow down? Is the pacing intentional or accidental?

### 3. Prose (sentence-level craft)

Read several representative passages closely. Sample 3-5 passages from different sections (opening, middle, close).

**What to notice:**
- Sentence rhythm -- variation in length, or metronomic uniformity? Read a passage aloud mentally. Does it have music or does it drone?
- Techniques present or absent -- refer to the `/writer` skill's essay and product copy techniques. Which ones appear? Which absences hurt the piece?
- Fragment patterns -- are fragments used for emphasis (earned) or as a tic (formulaic)?
- Transitions -- do paragraphs connect through logic and momentum, or through mechanical phrases ("However," "Furthermore," "In addition")?
- Voice -- does a human personality come through, or could this have been written by anyone?

### 4. Word Choice (the texture)

Examine the vocabulary layer.

**What to notice:**
- Register -- is the language appropriate for the audience and format?
- Concrete vs. abstract -- does the writing ground claims in specifics (names, numbers, examples) or float in abstraction?
- Jargon density -- technical terms are fine when expected. Jargon as decoration signals insecurity, not expertise.
- Cliche and dead metaphor -- words so overused they've lost all meaning.
- Tone consistency -- does the register shift unexpectedly? Inconsistency signals uncertain identity.

## Workflow

1. **If URL provided:** Load `/browser`. Open the URL. Screenshot at desktop and mobile viewports. Snapshot for structural analysis. Study the visual dimension.
2. **Read the content.** If URL, fetch or read via snapshot. If file, read directly.
3. **Analyze all four dimensions** in order. Each informs the next -- visual rhythm connects to compositional rhythm connects to sentence rhythm connects to word texture.
4. **Synthesize a diagnosis.** Not four separate reports. One cohesive reading that identifies the central tension. What is the piece trying to be, and where does the gap between intention and execution live?

## Output

Write the analysis as a short essay, not a checklist. Use the four dimensions as loose structure, but let the diagnosis flow naturally. Name specific passages, quote specific sentences, point to specific visual elements.

End with **The Diagnosis** -- 2-3 sentences that capture the core issue. The kind of insight that makes the writer say "yes, that's exactly what's wrong."

## Calibration

- **Do not score.** No numbers, no letter grades, no percentages. Scores create false precision.
- **Do not prescribe formulas.** "The uniform sentence length creates a droning quality -- here's where variation would land" beats "use more sentence length variation."
- **Be specific.** Every observation must point to a specific passage, element, or pattern. "The prose lacks rhythm" is useless. Quote the passage that drones.
- **Be honest.** If the writing is good, say so and say why. If it's bad, say so and say why.
- **Connect the dimensions.** The best insights come from cross-dimensional observations: "The typography is elegant but the prose doesn't match its ambition" or "the composition creates visual variety that the uniform sentence structure undermines."
