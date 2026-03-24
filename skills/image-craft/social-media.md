# Social Media Graphics

Platform-specific graphics: post images, story templates, banners, cover images, thumbnails, ads.

---

## Understanding Phase

Before generating anything, extract these from the user's request:

- **Platform** — Instagram, Facebook, Twitter/X, LinkedIn, YouTube, Pinterest, TikTok. Each has its own visual culture and technical constraints.
- **Content type** — Post, story, banner, cover image, thumbnail, ad creative, carousel frame.
- **Brand voice** — Formal/corporate, casual/friendly, bold/edgy, minimal/elegant. Ask if unclear.
- **Audience** — Who is this for? B2B executives see different feeds than Gen Z consumers.
- **Message** — What is the single thing this image must communicate? One image, one message.
- **Call to action** — What should the viewer do? Follow, click, buy, sign up, share. This affects composition (where the CTA lives).
- **Brand assets** — Logos, hex colors, fonts, existing style guides. Consistency is non-negotiable.

Platform constraints override creative preferences. A beautiful image at the wrong aspect ratio is useless.

---

## Platform-Specific Dimensions and Constraints

| Platform | Format | Dimensions | Aspect Ratio | Notes |
|---|---|---|---|---|
| Instagram Post | Square | 1080×1080 | 1:1 | Also 4:5 (1080×1350) for maximum feed real estate |
| Instagram Story | Vertical | 1080×1920 | 9:16 | Keep key content in center 1080×1420; top 200px and bottom 300px are covered by UI |
| Instagram Carousel | Square/Portrait | 1080×1080 or 1080×1350 | 1:1 or 4:5 | Each frame must stand alone AND work in sequence |
| Facebook Post | Landscape | 1200×630 | ~1.91:1 | Landscape preferred; square also works but gets less space |
| Facebook Cover | Wide | 820×312 (desktop) / 640×360 (mobile) | Varies | Design for mobile crop — center the important content |
| Twitter/X Post | Landscape | 1600×900 | 16:9 | Preview crops to center; avoid text at extreme edges |
| Twitter/X Header | Wide | 1500×500 | 3:1 | Profile photo overlaps bottom-left on desktop |
| LinkedIn Post | Landscape | 1200×627 | 1.91:1 | Professional aesthetic required; clean, restrained |
| LinkedIn Banner | Wide | 1584×396 | 4:1 | Profile photo overlaps left side |
| YouTube Thumbnail | Landscape | 1280×720 | 16:9 | Must be readable at 120×68px. High contrast is mandatory |
| Pinterest Pin | Vertical | 1000×1500 | 2:3 | Vertical format dominates the feed. Scroll-stopping required |
| TikTok Cover | Vertical | 1080×1920 | 9:16 | Same safe zones as Instagram Stories |

When the user specifies a platform, use these dimensions to select the correct aspect ratio in the generation tool. Map to the closest supported ratio: `1:1`, `4:3`, `3:4`, `16:9`, `9:16`.

---

## Safe Zone Rules

Every platform overlays UI elements on the image. Respect these zones:

- **Instagram Stories/TikTok**: Top 200px (username, timestamp) and bottom 300px (swipe-up, message bar) are unsafe. Center all key content vertically.
- **YouTube Thumbnails**: Bottom-right corner shows video duration. Bottom-left may show "LIVE" or chapter markers. Keep critical elements in the upper two-thirds.
- **Facebook Cover**: Mobile crops differently than desktop. Keep critical content in a centered safe rectangle roughly 640×312.
- **Twitter/X Header**: Profile photo covers the bottom-left quadrant. Don't place text or key visuals there.
- **LinkedIn Banner**: Profile photo overlaps the left side. Weight your design toward center-right.

In your prompt, explicitly describe where visual weight and focal points should sit to avoid these zones.

---

## Social Media Design Principles

### 1. Scroll-Stopping Power
You have 0.5 seconds to earn attention. The image must arrest the thumb mid-scroll.
- Use high contrast between foreground and background.
- Create a single, unmistakable focal point.
- Bold color choices beat subtle ones in feeds.
- Unusual compositions or unexpected visuals outperform safe ones.
- Faces and eyes draw attention — use them when appropriate.

### 2. Brand Consistency
Every post is a brick in the brand's visual identity. Maintain:
- Recurring color palette (specify hex codes in prompts when available).
- Consistent typography style (even if AI can't render text perfectly, the visual weight and placement should match).
- Visual motifs — a brand's signature shapes, textures, or illustration style.
- Consistent use of photography style (bright and airy vs. moody and dark).

### 3. Text Overlay Strategy
- Keep text minimal. Especially on Instagram, let the image speak.
- Facebook and paid ads: the old 20% text rule is relaxed but still affects reach. Less text = better distribution.
- Design clear negative space or solid-color zones where text can be composited in post-processing.
- In prompts, describe "an area of solid [color] occupying the [position] third of the image for text overlay" rather than asking the AI to render text.

### 4. Platform-Native Feel
Each platform has a visual culture. Match it:
- **LinkedIn**: Clean, professional, structured. Think presentation slides, not magazine ads.
- **Instagram**: Aesthetic, curated, aspirational. Visual quality is paramount.
- **TikTok**: Raw, authentic, energetic. Overly polished looks out of place.
- **Pinterest**: Inspirational, instructional, beautiful. Vertical compositions with clear subject matter.
- **Twitter/X**: Bold, punchy, meme-aware. Thumbnails and preview images must hook instantly.
- **Facebook**: Accessible, community-oriented, informational. Works for a broader age range.

### 5. Mobile-First Design
Everything is viewed on a phone screen (6 inches diagonal, typically).
- Small details disappear. Simplify.
- Thin lines and small text become invisible. Use bold weights.
- Test mentally: would this work at 400px wide on a phone? If not, simplify.
- High-frequency detail (complex patterns, thin stripes) can cause moiré on screens.

---

## Style Categories

### 1. Clean/Corporate
Solid backgrounds, geometric shapes, professional typography treatment. Grid-based layouts.
**Use for**: B2B, SaaS, finance, consulting, healthcare.
**Prompt cues**: "clean corporate design, solid color background, geometric accent shapes, professional layout, organized grid, business aesthetic"

### 2. Lifestyle/Aspirational
Beautiful photography, soft tones, natural lighting, minimal text overlay. Emphasis on mood.
**Use for**: Fashion, travel, wellness, food, real estate.
**Prompt cues**: "lifestyle photography, natural lighting, soft warm tones, aspirational mood, editorial quality, shallow depth of field"

### 3. Bold/Graphic
Saturated colors, large type, graphic elements, high energy. Maximum visual impact.
**Use for**: Entertainment, food brands, sports, music, events.
**Prompt cues**: "bold graphic design, saturated colors, high contrast, energetic composition, dynamic angles, strong visual impact"

### 4. Minimal/Editorial
Generous white space, restrained palette, elegant typography, intentional emptiness.
**Use for**: Design, architecture, luxury brands, premium products.
**Prompt cues**: "minimalist design, ample white space, restrained color palette, elegant composition, editorial aesthetic, refined simplicity"

### 5. Playful/Illustrated
Hand-drawn elements, bright colors, casual feel, approachable personality.
**Use for**: Education, children's brands, creative services, indie products.
**Prompt cues**: "playful illustrated style, hand-drawn elements, bright cheerful colors, casual friendly aesthetic, whimsical details"

---

## Prompt Architecture

Structure every social media prompt with these components in order:

```
[STYLE AND PLATFORM] — Declare the style category and platform format upfront.
  e.g. "Bold graphic Instagram post, square 1:1 format"

[VISUAL CONTENT] — Describe what the image shows. Be specific about subjects, objects, scenes.
  e.g. "A pair of wireless earbuds floating against an electric blue gradient background"

[COLOR PALETTE] — Specify brand colors (hex codes if available) or palette direction.
  e.g. "Electric blue (#0066FF) and white with black accents"

[TEXT ZONES] — Describe where text will be composited later. Don't ask AI to render text.
  e.g. "Large clear area in the upper third with solid color for headline overlay"

[COMPOSITION] — Layout, focal point, visual hierarchy, negative space.
  e.g. "Product centered in lower two-thirds, negative space above for text, subtle geometric shapes framing the product"

[MOOD/ENERGY] — Emotional register and energy level.
  e.g. "High energy, modern, premium tech feel"
```

---

## Prompt Examples

### Clean LinkedIn Announcement
```
Clean corporate LinkedIn post, landscape 16:9 format. A modern office workspace scene with a laptop displaying a dashboard with glowing data visualizations, shot from a slight overhead angle. Color palette: deep navy (#1B2A4A), white, and a single accent of teal (#00B4D8). Large area of solid navy in the left third of the image for text overlay. Composition weighted to the right, with the workspace occupying 60% of the frame and clean negative space on the left. Professional, authoritative, and forward-looking mood. Soft directional lighting, shallow depth of field blurring the background.
```

### Bold Instagram Product Launch
```
Bold graphic Instagram post, square 1:1 format. A matte black smart speaker on a reflective surface, surrounded by radiating concentric sound wave rings rendered as glowing neon lines. Color palette: jet black background, neon coral (#FF6B6B) for the sound waves, white highlights on the product. Clear rectangular zone in the top quarter for headline text. Product centered, sound waves expanding outward to all edges, creating a dynamic radial composition. High energy, futuristic, premium consumer tech mood. Dramatic lighting from below casting upward shadows.
```

### YouTube Thumbnail (Click-Worthy)
```
High-contrast YouTube thumbnail, landscape 16:9 format. A close-up of a person's face showing an expression of genuine surprise and excitement, with eyes wide and mouth slightly open, positioned in the right two-thirds of the frame. The left third has a bold solid yellow (#FFD700) color block for title text overlay. A subtle bokeh background of a kitchen scene. Bright, punchy, warm color palette — the face is well-lit with soft golden light. Composition follows the rule of thirds with the face offset right. Energetic, inviting, curiosity-provoking mood. The image must remain legible and impactful when scaled down to 120×68 pixels — bold shapes, high contrast, no fine details.
```

### Minimalist Instagram Story
```
Minimalist editorial Instagram story, vertical 9:16 format. A single stem of dried pampas grass casting a soft shadow on a warm off-white (#F5F0EB) textured plaster wall. Muted palette: warm beige, cream, soft terracotta (#C4856A) accent. The pampas grass occupies the lower 40% of the frame, with expansive negative space in the upper 60% for text overlay — keep this zone completely clean. Centered composition, vertical orientation of the stem. Calm, refined, understated luxury mood. Soft diffused natural light from the left side, gentle shadows.
```

---

## Critical Constraints

### AI Text Rendering
AI-generated text in images is unreliable — expect misspellings, garbled characters, and inconsistent letterforms. **Never rely on the AI to render readable text.** Instead:
- Design compositions with clear, solid-colored zones where text can be added in post-processing.
- Describe these zones in the prompt as "area for text overlay" with specific position and color.
- If the user needs text in the final image, inform them that text should be composited afterward using a design tool.

### Thumbnail Legibility
For YouTube thumbnails, Pinterest pins, and any content that appears as a small preview:
- Mentally test at 100px wide. If you can't distinguish the subject, simplify.
- Use bold shapes, not fine details.
- High contrast between subject and background is mandatory.
- Faces should occupy at least 30% of the frame if included.
- Limit to 2-3 visual elements maximum.

### Paid Ad Compliance
- Facebook/Instagram ads perform better with less than 20% text coverage. Design accordingly.
- Avoid misleading imagery that could violate ad platform policies.
- Include clear space for "Sponsored" labels and CTA buttons that platforms overlay.

### Brand Color Fidelity
- When the user provides hex codes, include them in the prompt explicitly.
- AI models interpret color descriptions loosely — "brand blue" is ambiguous, "#0066FF electric blue" is specific.
- If generating a series of posts, repeat the exact same color specifications in every prompt.

### Multi-Post Consistency
For carousel posts or series:
- Establish the visual system in the first prompt (background color, element placement, style).
- Repeat these specifications verbatim in subsequent prompts.
- Use reference images from earlier generations to maintain consistency.

---

## Quality Checks

Run these checks mentally before finalizing any social media image prompt:

1. **Platform test** — Does the prompt specify the correct aspect ratio and respect safe zones for the target platform?
2. **Scroll-stop test** — Is there a bold focal point, high contrast, and immediate visual impact? Would this stop a thumb mid-scroll?
3. **Brand test** — Are brand colors, style, and visual tone consistent with the user's existing identity?
4. **Text zone test** — Is there a well-defined area for text overlay that doesn't compete with the visual content?
5. **Mobile test** — Will this image hold up on a 6-inch screen? Are there any small details that will disappear?
6. **Simplicity test** — Is there one clear message? If you can't describe the image's point in one sentence, simplify it.
7. **Native test** — Does this look like it belongs on the target platform, or does it look like it was designed for somewhere else?
