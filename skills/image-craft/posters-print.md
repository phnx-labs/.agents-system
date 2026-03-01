# Posters & Print Design

Sub-skill for event posters, movie posters, promotional flyers, print ads, album covers, and any design where image and text work together on a fixed surface.

---

## Understanding Phase

Before writing a single prompt, extract these from the user's context:

1. **The message.** What is this poster communicating? An event, a film, a product, an idea?
2. **The audience.** Who will see this? Age, taste, cultural context. A jazz festival poster and a tech conference poster share almost no visual language.
3. **Information hierarchy.** Rank every piece of text by importance. Typically: Title/Name > Date/Time > Venue/Location > Supporting details > Fine print. The hierarchy dictates the entire composition.
4. **Mood and tone.** Elegant? Aggressive? Playful? Somber? This determines palette, typography style, and imagery.
5. **Hard constraints.** Required text (dates, sponsors, logos), format/dimensions, color limitations (single-color print?), brand guidelines.
6. **Viewing context.** Will this be seen on a billboard at 60 mph, a flyer in someone's hand, or a 1080px Instagram post? Distance determines scale, detail, and complexity.

**The core challenge of poster design is the relationship between image and text.** They must coexist — neither overpowering the other unless that's the deliberate intention. A poster is information design. It must communicate quickly, from a distance, to a distracted viewer.

---

## Composition Principles

### 1. Visual Hierarchy
Size, weight, color, and position signal importance. The most important element is the largest, the boldest, the highest-contrast, or the most centrally placed — ideally several of these at once. Everything else is subordinate.

### 2. Focal Point
Every poster needs one dominant element the eye goes to first. If there are two equally competing focal points, the poster fails. Decide: is the focal point the image, the title, or a graphic element? Build everything else around it.

### 3. Balance
- **Symmetric:** Centered, formal, stable. Works for classical, institutional, or elegant subjects.
- **Asymmetric:** Off-center weight, dynamic tension. Works for energetic, modern, or provocative subjects.
- Asymmetric balance is harder but more interesting. The weight of a small, dark element can balance a large, light one.

### 4. Contrast
Contrast creates visual interest and hierarchy. Deploy it across multiple dimensions simultaneously:
- Big / small (scale contrast)
- Light / dark (tonal contrast)
- Thick / thin (weight contrast)
- Organic / geometric (form contrast)
- Dense / sparse (texture contrast)

Without contrast, a poster is flat and unreadable.

### 5. White Space / Negative Space
Emptiness is a design element, not wasted space. Generous white space signals sophistication, gives the eye a resting place, and makes the filled areas more impactful. Crowded posters read as cheap.

### 6. Grid and Alignment
Even the most expressive poster has an invisible grid underneath. Elements that share an alignment edge feel connected. Random placement feels amateur. Specify alignment in prompts: "text block aligned to the left third," "centered composition on a vertical axis."

### 7. Leading Lines
Direct the eye through the composition in a deliberate path. Diagonal lines, pointing shapes, gaze direction of a figure, converging perspective — all of these pull the viewer from the entry point (focal point) through the supporting information to the call-to-action or fine print.

---

## Typography in Posters

### Font Count
Maximum 2–3 typefaces. One display/headline font for impact. One body/detail font for readability. Optionally a third accent font for a specific element (date, tagline). More than three typefaces creates visual chaos.

### Font Pairing
Pair fonts that contrast in style but share an underlying feel. A geometric sans-serif headline with a humanist serif body. A bold slab-serif title with a light sans-serif subtitle. Avoid pairing two fonts that are similar but not identical — it reads as a mistake.

### Scale Hierarchy
The headline should be 3–5x larger than the body text. This ratio guarantees readability at a distance. If someone can't read the most important word from across a room, the poster has failed.

### Typography Styles by Genre
- **Sans-serif (Helvetica, Futura, Aktiv Grotesk):** Modern, tech, clean, institutional.
- **Serif (Garamond, Didot, Playfair Display):** Editorial, formal, literary, luxury.
- **Hand-drawn / Script:** Creative, organic, personal, artisanal.
- **Slab-serif (Rockwell, Clarendon):** Bold, industrial, confident, retro.
- **Blackletter / Display:** Dramatic, niche — metal, horror, gothic, heritage.
- **Monospace:** Technical, code-related, brutalist, experimental.

### CRITICAL: AI Text Limitations
AI image models cannot reliably render text. Letters will be malformed, misspelled, or nonsensical. **This is expected behavior, not a failure.**

When generating poster compositions:
- Treat text areas as placeholders for layout and positioning.
- Focus the prompt on getting the visual composition, color palette, imagery, and spatial layout right.
- Note to the user that text will need to be replaced or refined in a design tool (Figma, Photoshop, Canva, Illustrator).
- You can prompt for the general typographic treatment — "bold sans-serif headline in the upper third" — even if the rendered letters are imperfect.

---

## Poster Style Categories

### 1. Swiss / International Style
Grid-based layout. Sans-serif typography (Helvetica, Akzidenz-Grotesk). Clean geometric shapes. Limited color palette (often 2–3 colors). Rational, objective, information-first. Think Josef Müller-Brockmann, Armin Hofmann.
- **Best for:** Tech events, institutional posters, museum exhibitions, academic conferences.
- **Prompt cues:** "Swiss International style," "grid-based layout," "Helvetica typography," "geometric abstraction," "asymmetric grid composition."

### 2. Psychedelic / Maximalist
Saturated, clashing colors. Organic flowing letterforms. Dense layering of pattern and image. Warped, melting shapes. Visual overload is the point. Think Wes Wilson, Victor Moscoso, 1960s Fillmore posters.
- **Best for:** Music festivals, concerts, counterculture events, immersive experiences.
- **Prompt cues:** "Psychedelic concert poster," "hand-drawn flowing lettering," "saturated neon palette," "art nouveau influence," "dense organic patterns."

### 3. Minimalist
One powerful image, shape, or typographic element. Vast white (or single-color) space. Restrained palette — often monochrome or two-color. Impact through reduction. Think Noma Bar, the iconic Saul Bass film posters.
- **Best for:** Film festivals, gallery exhibitions, luxury brands, conceptual messaging.
- **Prompt cues:** "Minimalist poster," "single focal element," "generous negative space," "limited palette," "reductive composition."

### 4. Typographic
Text IS the visual. The letterforms themselves create the image through scale, color, arrangement, distortion, or repetition. No separate illustration needed — the words do the visual work. Think David Carson, Paula Scher, Emigre.
- **Best for:** Literary events, design conferences, word-driven campaigns, spoken word.
- **Prompt cues:** "Typographic poster," "text as image," "experimental letterforms," "layered type," "scale contrast in typography."

### 5. Photographic
A dominant photograph — often cinematic, dramatically lit — with text overlaid. The photo does the emotional heavy-lifting. Text is integrated through careful placement, transparency, or contrast. Think movie posters, fashion campaigns.
- **Best for:** Film, theater, music (artist portraits), fashion, food events.
- **Prompt cues:** "Photographic poster," "cinematic photograph," "text overlay," "dramatic lighting," "film grain."

### 6. Illustrated
A hand-drawn or digitally illustrated hero image occupies most of the poster. Ranges from detailed realistic illustration to loose, gestural, or abstract. Think Olly Moss, Tyler Stout, Mondo posters.
- **Best for:** Indie films, children's events, cultural festivals, book fairs, fantasy/sci-fi.
- **Prompt cues:** "Illustrated poster," "hand-drawn illustration," "screen-print aesthetic," "limited color palette illustration," "flat color illustration."

### 7. Constructivist / Bauhaus
Bold geometric shapes. Red-black-white palette (or similar high-contrast limited palette). Diagonal composition that implies movement and urgency. Political energy even for non-political subjects. Think El Lissitzky, Alexander Rodchenko, Herbert Bayer.
- **Best for:** Political events, activism, experimental theater, design retrospectives, punk/alternative.
- **Prompt cues:** "Constructivist poster," "Bauhaus design," "red and black palette," "diagonal composition," "geometric typography," "propaganda aesthetic."

### 8. Collage / Mixed Media
Layered textures, cut-out photographic elements, torn paper edges, analog artifacts (halftone dots, print registration marks, tape). Feels handmade even when digital. Think Jamie Reid (Sex Pistols), contemporary zine culture.
- **Best for:** Alternative music, zines, grassroots events, art exhibitions, experimental work.
- **Prompt cues:** "Collage poster," "mixed media," "torn paper textures," "halftone printing," "layered cut-out photographs," "analog artifacts."

---

## Prompt Architecture for Posters

Every poster prompt should address these elements in order:

```
[STYLE DECLARATION] — The design tradition or movement. e.g., "Swiss International style event poster"
[COMPOSITION] — Layout structure, focal point, where major elements sit. e.g., "asymmetric grid, title in upper-left third, central geometric shape"
[IMAGERY] — The visual content: photograph, illustration, abstract shape, texture. Be specific.
[COLOR PALETTE] — Specific colors or direction. e.g., "deep navy, burnt orange, and cream" or "monochrome with a single red accent"
[TYPOGRAPHY TREATMENT] — Font style, scale, placement. Even as placeholders. e.g., "bold sans-serif headline spanning the top quarter"
[MOOD / ATMOSPHERE] — The emotional register. e.g., "urgent and electric" or "calm and contemplative"
[REFERENCE DIRECTION] — Designer, era, or movement anchor. e.g., "in the style of Saul Bass" or "1970s screen-print aesthetic"
```

---

## Prompt Examples

### Example 1: Minimalist Film Festival Poster
```
Minimalist film festival poster. Centered composition with a single bold graphic element — a film reel abstracted into a spiral that also suggests an eye. Vast white background with the graphic in solid black, positioned slightly above center. A thin red horizontal line below the graphic serves as a divider. Bold condensed sans-serif title text placeholder in the lower third, small and understated. Palette: black, white, single red accent. Evokes the precision and restraint of Saul Bass's title sequences. Clean, intellectual, cinematic. Printed matte finish feel.
```

### Example 2: Psychedelic Concert Poster
```
Psychedelic rock concert poster in the 1960s San Francisco tradition. Dense, organic composition filling the entire frame — no empty space. A central figure of a musician dissolving into swirling patterns of paisley, spirals, and botanical forms. Colors: electric magenta, acid green, deep violet, golden yellow — clashing and vibrating. Hand-drawn flowing letterforms integrated into the imagery, practically illegible but visually spectacular, filling the upper third. Background of concentric radiating waves. The entire composition has a slight halftone print texture. Inspired by Wes Wilson and Victor Moscoso's Fillmore posters. Intense, hypnotic, overwhelming in the best way.
```

### Example 3: Swiss-Style Tech Conference Poster
```
Swiss International style conference poster. Strict grid-based layout divided into a 4-column asymmetric grid. Upper-left block contains a bold Helvetica-style title placeholder in black. Lower-right area holds a geometric data visualization — clean circles and lines suggesting a network graph — in electric blue against white. Large block of structured body text placeholder in a narrow column on the left third, small and dense. Palette: white background, black typography, single accent of saturated blue. Mathematical precision, generous margins, no decoration. In the tradition of Josef Müller-Brockmann. Rational, confident, modern. Feels like a printed broadsheet.
```

### Example 4: Photographic Movie Poster
```
Cinematic photographic movie poster. A solitary figure standing in a vast desert landscape at golden hour, seen from behind, slightly off-center to the right. The figure casts a long shadow toward the viewer. The sky dominates the upper two-thirds — gradient from deep amber at the horizon to dark teal overhead. Dramatic, natural lighting with lens flare brushing the left edge. Title text placeholder area at the very top in thin, wide-spaced serif letterforms, and a tagline placeholder at the bottom. The photograph is the entire poster — no borders, no graphic elements. Color grading: warm shadows, desaturated midtones, lifted blacks. Feels like a Roger Deakins frame. Quiet, epic, contemplative. Shot on large-format film with visible grain.
```

---

## Critical Constraints

1. **AI text is unreliable.** State this to the user every time. The generated poster gives the visual composition, layout, palette, and mood. Text must be finalized in a design tool. This is not a limitation — it's the standard professional workflow.

2. **Viewing context determines detail level.** A billboard needs massive scale, zero fine detail, and brute-force contrast. A handheld flyer can have texture, nuance, and small type. A social media graphic needs impact at thumbnail size. Specify this in the prompt.

3. **Color count matters for print.** If the poster will be screen-printed, specify the number of ink colors (typically 2–4). This fundamentally changes the design. A full-color digital poster and a two-color screen print are different design problems.

4. **Aspect ratio must match format.** A3/A2 is roughly 3:4. US letter is close to 4:5. Social media story is 9:16. Concert poster (11×17) is roughly 2:3. Get this right — cropping a finished poster destroys the composition.

5. **Density is intentional.** Some styles (psychedelic, collage) demand density. Others (minimalist, Swiss) demand space. Neither is better. Match the density to the style and the audience.

6. **Avoid the AI-art look.** Steer clear of: "digital art," "4K render," "unreal engine," "glowing neon lines," "epic cinematic." These produce the generic AI aesthetic that reads as cheap. Ground prompts in real print design traditions instead.

---

## Quality Checks

After generation, evaluate every poster against these criteria:

1. **Readability test.** Squint at the image or view it at 25% size. Is the hierarchy still clear? Can you identify the focal point, the title zone, and the secondary information? If not, the composition is too muddy.

2. **Focal point test.** Where does your eye land first? Is that the most important element? If your eye goes to a decorative detail instead of the title or hero image, the hierarchy has failed.

3. **Balance test.** Does the composition feel stable (if intended) or intentionally dynamic (if intended)? An unintentionally lopsided poster reads as amateur.

4. **Text zone test.** Even though AI text is imperfect, are the text areas well-placed? Is there enough contrast between text zones and background for legibility? Is there room for real text to be inserted cleanly?

5. **Mood test.** Show the poster with no context. Does it evoke the right feeling? A jazz festival poster should feel different from a metal concert poster, even before you read a single word.

6. **Print-readiness test.** Does the image feel like it could exist as a physical print? Or does it have the telltale digital glow of AI-generated imagery? Ground the output in real material qualities — paper texture, ink behavior, print imperfections.
