---
name: image-craft
description: "Generate high-quality images for any creative use case — editorial/cinematic photography, logos and brand marks, posters and print design, product photography, social media graphics, book covers, illustrations, and more. The agent reads the surrounding content, understands context and intent, researches the domain, selects the right visual approach, and generates images with expert-level prompt craft. Load this skill whenever image generation is involved."
allowed-tools: Bash(sleep*), Bash(ssh*), Bash(*/env.sh*)
user-invocable: true
---

# Image Craft

A universal system for generating the highest-quality AI images across any creative use case. This skill is an orchestrator — it reads the situation, selects the right visual approach, and applies domain-specific craft to produce images that meet professional standards.

## Core Philosophy

The quality gap between mediocre and exceptional AI images is never the model. It is always the thinking before the prompt.

Three principles apply to every use case:

1. **Understand before you generate.** Read the content, research the domain, grasp the intent. Never jump to prompts.
2. **Be specific about everything.** Vague prompts produce vague images. Every element — material, lighting, spatial relationship, color, typography, composition — must be deliberately chosen.
3. **Match the craft to the use case.** A logo prompt and a cinematic photograph prompt share almost no vocabulary. Each domain has its own visual language, principles, and failure modes.

## Workflow Overview

Every image generation task follows the same high-level flow, regardless of use case:

### Step 1: Understand the Context

Read whatever the user has provided or is working with:
- Articles, essays, documents (PDF, URL, text)
- Codebases, technical documentation
- Websites, products, brands
- Conversations, notes, briefs
- Reference images or mood boards
- A verbal description

**What you are extracting depends on the use case:**
- For editorial/cinematic: the ideas, tensions, feelings, and emotional cores
- For logos: the brand values, personality, industry, and differentiation
- For posters: the event/message, audience, hierarchy of information, mood
- For product shots: the product attributes, context of use, brand aesthetic
- For social media: the platform, audience, message, brand voice
- For book covers: the genre, tone, themes, target reader

### Step 2: Research the Domain

Before writing prompts, deepen your understanding:
- If reference images exist, study what makes them work (composition, palette, mood, technique)
- Research relevant visual references (designers, photographers, art movements, competing work)
- Understand the constraints of the medium (logo needs to work at 16px; poster needs to read at 20 feet; social graphic needs to stop a scroll)

### Step 3: Identify the Use Case and Load Sub-Skill

Based on context, select the appropriate sub-skill. Read the corresponding file for domain-specific guidance:

| Use Case | Sub-Skill File | When to Use |
|---|---|---|
| Editorial / Cinematic Photography | `editorial-cinematic.md` | Essay illustrations, article headers, mood imagery, conceptual photography, fine art |
| Logos & Brand Marks | `logos-brand.md` | Logos, icons, app icons, monograms, brand symbols, wordmarks |
| Posters & Print Design | `posters-print.md` | Event posters, movie posters, promotional flyers, print ads, album covers |
| Product Photography | `product-photography.md` | E-commerce product shots, lifestyle product images, packaging mockups |
| Social Media Graphics | `social-media.md` | Platform-specific graphics, story templates, post images, banners, thumbnails |
| Book Covers & Editorial Design | `book-covers.md` | Book covers, magazine covers, editorial spreads, publication design |
| Illustrations & Concept Art | `illustrations.md` | Character design, scene illustration, concept art, infographic illustrations, storyboards |

**If the use case doesn't fit neatly into one category**, combine guidance from multiple sub-skills. A "cinematic movie poster" draws from both `editorial-cinematic.md` and `posters-print.md`.

**If the user doesn't specify a use case**, infer it from context. An essay about philosophy needs editorial imagery. A startup brief needs a logo. A product page needs product photography. Ask only if genuinely ambiguous.

### Step 4: Write the Prompt

Every prompt, regardless of use case, follows this universal skeleton:

```
[MEDIUM / STYLE DECLARATION] — What this is and how it was made
[SUBJECT / SCENE] — The concrete visual content, described with extreme specificity
[INTENT / IDEA] — What this image communicates (stated plainly)
[TECHNIQUE / EXECUTION] — How it was created, rendered, or captured
[QUALITY ANCHORS] — References, mood, feel — what it should evoke
```

The specific vocabulary within each slot changes dramatically by use case. See sub-skill files for domain-specific prompt construction.

### Step 5: Generate

Load the `/browser-generate` skill for the full generation workflow. Use OpenClaw browser commands via SSH with `--browser-profile claude` to open higgsfield.ai, set aspect ratio, type prompt, and click Generate.

**Model selection:**
- `nano-banana-pro` (default) — high-quality, professional, client-facing work
- `nano-banana-2` — rapid iteration, exploration, budget/speed preference

**Aspect ratio:**
- `16:9` — Cinematic, editorial, website headers, YouTube thumbnails
- `4:3` — Documentary, traditional photography, some print layouts
- `1:1` — Logos, social media posts (Instagram), album art, icons
- `9:16` — Social media stories, vertical posters, mobile-first content
- `2:3`, `3:2`, `4:5`, `5:4` — also available for specific compositions

Always match the aspect ratio to the actual intended use. If unsure, ask. **Set aspect ratio BEFORE typing the prompt** — this is the most common mistake.

**Variations:**
- Generate 2-4 variations per concept using fundamentally different visual approaches
- Variations should explore different metaphors, styles, or compositions — not just minor tweaks
- Every image in a set must be visually distinct from every other
- Vary aspect ratios across a set when appropriate (not everything needs to be 16:9)

**Reference images:**
- If the user provides reference images, pass them via the `images` parameter
- Study references first: identify which qualities to preserve vs. what to change
- References anchor style, not content — use them for mood, palette, and technique

### Step 6: Review

Before sharing, every image must pass these universal checks:

1. **Intent check:** Does the image communicate what it needs to? (The idea, the brand, the message, the product)
2. **Craft check:** Does it look professionally made? (Not obviously AI-generated, no artifacts, no uncanny elements)
3. **Distinction check:** Is it visually different from every other image in the set?
4. **Use-case check:** Does it work for its intended medium? (Right aspect ratio, right level of detail, right mood)
5. **AI-artifact check:** No extra fingers, distorted faces, garbled text, impossible geometry, or plastic-looking surfaces

Domain-specific quality checks are in each sub-skill file.

## Shared Anti-Patterns (Apply to All Use Cases)

Read `anti-patterns.md` for the full catalog. Key universals:

1. **Never jump to prompts without understanding context.** The thinking before the prompt is always more important than the prompt itself.
2. **Never use generic AI vocabulary.** Avoid: "digital art," "concept art," "CGI render," "3D render," "futuristic," "glowing," "neon" (unless specifically appropriate).
3. **Never over-prompt.** One idea per image. One dominant visual element. Supporting details reinforce, not compete.
4. **Never generate without specifying the medium.** The first line of every prompt declares what this is — a photograph, a vector logo, a screen-printed poster, an oil painting. Without this, the model guesses.
5. **Never share without reviewing.** Every image gets checked before the user sees it.

## Adapting to Unknown Use Cases

If you encounter a creative use case not covered by the sub-skills (e.g., tattoo design, architectural visualization, fashion design, texture creation):

1. Research the domain's visual language, principles, and professional standards
2. Identify the closest sub-skill and adapt its prompt structure
3. Find domain-specific references (artists, photographers, designers) to use as quality anchors
4. Apply the universal skeleton with domain-appropriate vocabulary
5. Review against both universal checks and domain-specific standards

The system is designed to extend. The sub-skills are not an exhaustive list — they are templates for how to think about any visual domain.
