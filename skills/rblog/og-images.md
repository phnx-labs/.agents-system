# OG and Hero Images

Two images every post needs. They serve different purposes and have different constraints.

## Hero Image

The hero sits at the top of the post, full-width. It sets the mood for everything that follows. The reader sees it before they read a word.

**Think of it as the opening shot of a film.** It doesn't explain the plot. It establishes the emotional register -- are we in a thriller? A meditation? A polemic? The hero image answers that question visually.

### Craft

The hero should emerge from the post's core idea, not its topic. Read `/image-craft` (editorial-cinematic.md) for how to extract ideas from content and translate them into visual metaphors.

A hero image for a post about "the future of AI agents" should NOT be a robot or a neural network. Those are topics. The hero should capture what the post *feels* -- perhaps the vertigo of handing control to something you built but no longer fully understand.

### Technical

- Format: `.webp`
- Aspect: typically 16:9, but let the image's composition determine this
- Naming: `hero-{slug}.webp` in `rush/web/public/`
- Markdown: first line after frontmatter: `![Alt text](/hero-{slug}.webp)`
- Size: optimize for web -- under 500KB if possible

## OG Image

The OG image appears when the post is shared on Twitter, LinkedIn, Discord, Slack, iMessage. It is a thumbnail in a feed of thumbnails. It must work at 300px wide on a phone screen.

**This is not the hero image resized.** The OG image has a fundamentally different job: in a sea of social cards, it must stop the scroll and communicate what the post is about -- in under a second, at thumbnail size.

### What Makes an OG Image Work

1. **The title is on the image.** Social platforms often crop or truncate the text metadata. The image itself must carry the post title so the reader knows what they're clicking.

2. **Typography follows the brand.** The title text should use the same typographic sensibility as the blog -- weight, spacing, alignment. Not random Impact or Arial. The type IS the design.

3. **The background supports, never competes.** A subtle gradient, a desaturated version of the hero, or a solid color with texture. The title text must be the dominant visual element.

4. **Contrast at any size.** Light text on dark background or dark text on light background. No subtle color differences that disappear at thumbnail scale.

5. **Brand presence is subtle.** A small logo or wordmark in a corner. Not a giant badge competing with the title.

### Composition Approaches

**Type-dominant:** The post title IS the image. Large, well-set typography on a clean background. Works for provocative titles that are compelling enough on their own. Think Stratechery or Benedict Evans newsletter cards.

**Image + type overlay:** A desaturated or darkened version of the hero image with the title set on top. The image provides mood, the type provides information. The key: the image must be dark/muted enough that white or light text is legible.

**Split composition:** Left half is the title text, right half is a visual element. Clean divide. Works for technical posts where the visual element is a diagram or product screenshot.

**Abstract + type:** A geometric pattern, gradient, or abstract texture with the title. Feels modern, works at any scale, and avoids the "stock photo with text" look.

### Technical

- Format: `.webp` (with `.png` fallback for platforms that need it)
- Size: exactly 1200x630 pixels
- Naming: `og-{slug}.webp` in `rush/web/public/`
- Frontmatter: `image: "/og-{slug}.webp"`
- Text must be readable at 300px width (test by squinting)

### Typography Notes

Study the existing blog to match its typographic voice. The OG image text should feel like it belongs to the same family as the blog's headlines -- same personality, adapted for the image format.

Key decisions:
- **Weight:** Bold or heavy for titles. The feed is noisy; timid type gets lost.
- **Case:** Title case or sentence case -- match the blog's convention.
- **Line breaks:** Control where the title breaks. "The Missing Piece / of the Intelligence Revolution" reads differently than "The Missing Piece of / the Intelligence Revolution." The break should fall at a natural pause.
- **Hierarchy:** If the description appears below the title, it should be clearly subordinate -- smaller, lighter, maybe a different color.

### Generating OG Images

For type-dominant or abstract+type OG images, you may be able to generate these programmatically (Canvas API, SVG template) or via image generation with typography prompts. For image+type overlays, generate the background image via `/higgsfield`, then composite the text.

The key is that the typography must be clean and precise. If the image generator can't produce sharp, well-kerned text, use a compositing approach instead.
