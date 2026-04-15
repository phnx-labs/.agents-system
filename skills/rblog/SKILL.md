---
name: rblog
description: "Write new blog posts or enrich existing ones. Covers the full lifecycle: writing, visuals, links, and design. Teaches agents to read a post like a designer -- understanding pacing, mood, and what the content is asking for. Triggers on 'blog post', 'enrich post', 'rblog', 'improve blog', or when an agent needs to create or enhance blog content."
argument-hint: "[path to post, or topic for new post]"
user-invocable: true
---

# R-Blog

Two modes: write a new post, or make an existing one better. Both require the same foundational skill -- reading content the way a designer reads space. Not for information, but for rhythm, weight, and what's missing.

Read the sub-files for specific guidance:

| File | What it teaches |
|------|----------------|
| `writing.md` | How to write -- voice, structure, openings, the mindset behind good posts |
| `enrichment.md` | How to see what a post needs -- the visual vocabulary and when to use each element |
| `og-images.md` | OG and hero image craft -- typography, composition, brand coherence |

## The Mindset

A blog post is not text with images bolted on. It is a reading experience -- a designed sequence of moments where text, image, silence, and rhythm work together.

The best online writing (Stripe Press, Verge longforms, Pudding.cool, Bartosz Ciechanowski's explorable explanations) treats every scroll-length as a design decision. Some scroll-lengths are dense with text because the argument demands focus. Some are a single image that lets the reader breathe. Some are a diagram that makes the abstract tangible. The writer chose each one.

Your job is to develop that same judgment. Not "add an image every 500 words" -- that produces wallpaper. Instead: read the post, feel its rhythm, and ask what each moment is asking for.

### Reading for Rhythm

Before touching a post -- new or existing -- read it the way a film editor watches footage. Not for content. For pacing.

Ask yourself:
- Where does the energy build? Where does it need to release?
- Where is the reader's attention most fragile? (long technical sections, abstract arguments, walls of text)
- Where is the reader's attention most captured? (stories, surprising data, vivid examples) -- these sections might need nothing at all.
- Where does the post shift tone? Transitions are where visuals land best -- they signal "something new is happening."
- Where would you, as a reader, feel your eyes glaze? That's where the post is failing you. Diagnose why before reaching for an image. Sometimes the fix is cutting text, not adding visuals.

### What the Content Is Asking For

Different content asks for different things. A contemplative essay about mortality does not want the same visual treatment as a competitive analysis of AI tools. Feel the difference:

| Post mood | What it might ask for |
|-----------|----------------------|
| Contemplative, philosophical | One perfect editorial image. Negative space. Pull quotes as visual breathers. Let the words do the work. |
| Technical, explanatory | Diagrams and architecture drawings. Screenshots. Step-by-step visuals. The reader needs to SEE the system. |
| Argumentative, persuasive | Data visualizations that prove the point. Before/after comparisons. Charts that make the case visually. |
| Profile, people-focused | Portraits. Real photos if available, editorial portraits if not. The reader wants to see who you're talking about. |
| Narrative, story-driven | Cinematic editorial images at act breaks. Photos of the places and things in the story. Visual world-building. |
| Short, punchy, provocative | Maybe no images at all. A single striking hero and pure text. Over-decorating a short piece dilutes it. |
| Data-heavy, research | Charts, tables, infographics. The visuals ARE the content, not decoration. |

This is not a lookup table. It's a starting point for your judgment. Most posts are a blend of moods, and the visual treatment should shift with the mood.

## The Visual Vocabulary

These are the elements you can work with. Read `enrichment.md` for deep guidance on each. Summary:

**Images that carry ideas:**
- Editorial/cinematic photography -- for abstract concepts, mood, emotional weight. Use `/image-craft` + `/higgsfield` to generate.
- Portraits of people -- real photos (web search) or editorial portraits (generated). For pieces that discuss specific individuals.
- Before/after pairs -- side-by-side images showing contrast. For comparison arguments.

**Images that explain:**
- Architecture diagrams -- system design, data flow, how things connect.
- Process diagrams -- step-by-step flows, decision trees.
- Data visualizations -- charts, graphs, timelines. For claims backed by numbers.
- Screenshots -- product UI, code output, real interfaces. For technical posts.

**Elements that pace:**
- Pull quotes -- key insights extracted and displayed with visual weight. They break up text and signal "this matters."
- Whitespace -- sometimes the best design decision is to leave a section alone. Silence between sections creates rhythm.
- Horizontal rules -- simple visual breaks that signal topic shifts.

**Dynamic media:**
- GIFs -- for product demos, subtle animations, step-by-step walkthroughs.
- Embedded video -- for complex demonstrations that static images can't capture.

**Links as enrichment:**
- Internal links -- connect to related posts on the site. Strengthens SEO, helps readers go deeper.
- External links -- cite sources, credit people, link to primary evidence. Builds credibility.

## Working with a Blog

### Understanding the Structure

Before making changes, understand the blog's architecture. Every blog has conventions:

- Where do posts live? (e.g. `content/blog/`, `posts/`, `src/pages/blog/`)
- Where do assets go? (e.g. `public/`, `static/`, `assets/images/`)
- What frontmatter fields are expected? (title, description, date, image, author)
- How are images referenced? (relative paths, absolute paths from public root)
- What's the deploy process? (build script, CI/CD, manual push)

Read the project's README, CLAUDE.md, or existing posts to learn these conventions. Match them exactly -- don't invent your own.

### Image Conventions

Common patterns across blogs:

```markdown
# Hero image (first line after frontmatter)
![Alt text](/hero-{slug}.webp)

# Inline section images
![Alt text](/blog/{descriptive-name}.webp)
```

Use `.webp` for photographs (smaller, modern). Use `.png` for diagrams and charts with sharp edges and text.

Name files descriptively: `intelligence-gap-pricing-collapse.webp` not `image-3.webp`.

### Alt Text

Every image needs alt text that describes what the reader would see. Not "image" or "diagram." Describe the content:
- Photo: "A frozen lake stretching to the horizon with a single wooden rowboat at center"
- Diagram: "System architecture showing the proxy server routing requests to three backend services"
- Chart: "Line chart showing API pricing decline from $60 to $0.22 per million tokens over 18 months"

Alt text serves accessibility, SEO, and the reader whose image didn't load.

## Image Generation

Use the `/image-craft` skill for crafting prompts and `/higgsfield` for generation via the OpenClaw browser. The prompt quality determines everything -- a lazy prompt produces a lazy image regardless of the model.

For editorial image prompts, read `image-craft/editorial-cinematic.md`. It teaches how to extract *ideas* (not topics) from content and translate them into visual metaphors.

### Aspect Ratios

Choose based on what the image IS, not a fixed rule:
- **Hero**: usually 16:9 (full-width banner) but a portrait-oriented hero can work for intimate pieces
- **OG**: 1200x630 (social cards demand this -- see `og-images.md`)
- **Section images**: 16:9 or 3:2 for landscapes, 1:1 or 3:4 for portraits
- **Diagrams**: whatever the content needs

## For Autonomous Sessions

When running via cron or autonomous session:

1. Choose a post that would benefit most from enrichment. Not randomly -- look at the ones with the most text and fewest visuals, or the ones most important for the site.
2. Read it fully. Feel its rhythm.
3. Make 2-4 high-impact additions per session. Don't try to finish an entire post in one run.
4. Track what you've done in your daily memory so you don't repeat work.
5. Deploy and verify the page renders correctly.

The post gets richer over multiple sessions. That's fine. Rushing to add 10 images in one session produces wallpaper.
