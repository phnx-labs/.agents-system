# Anti-Patterns

Universal failure modes in AI image generation. These apply across all use cases — editorial, logos, posters, product, social, book covers, illustrations. Each anti-pattern was discovered through real iteration: producing bad images and understanding why they failed.

## Anti-Pattern 1: Jumping to Prompts Without Understanding

**The failure:** Generating images immediately without reading the content, researching the domain, or understanding what the image needs to accomplish.

**Why it happens:** It feels efficient. It isn't. An image generated without understanding the context will be generic at best.

**The fix:** Every generation begins with reading and thinking. What is this content about? Who is the audience? What does this image need to communicate? What's the intended medium? Answer these before writing a single prompt.

---

## Anti-Pattern 2: Prompting Objects Instead of Ideas

**The failure:** Describing a thing ("a brain," "a rocket," "a handshake") instead of a situation, relationship, or concept.

**Applies especially to:** Editorial/cinematic, book covers, posters.

**How to detect:** If you can name the image in one or two nouns, it's an object. If you need a verb, relationship, or spatial description, it's an idea.

**The fix:** Add context, relationship, tension. Not "a broken hourglass" but "sand pouring through a crack in a dam wall into a river that's already flowing."

---

## Anti-Pattern 3: The Generic AI Look

**The failure:** Using vocabulary that triggers AI models' default aesthetic — smooth, over-lit, plasticky, digitally rendered. Words like "digital art," "concept art," "CGI," "3D render," "futuristic," "glowing," "neon."

**Applies to:** Everything. This is the single most common failure mode.

**How to detect:** The image looks like it was made by AI. It has a particular "smoothness" and lack of physical texture.

**The fix:** Specify the medium concretely. Not "digital art of a forest" but "Large format photograph of a forest, morning fog, Fuji Velvia film stock, Ansel Adams tonal range." For logos: "Clean vector logo" not "futuristic logo design." For illustration: "Pen and ink illustration" not "digital illustration." Ground every prompt in a real-world medium.

---

## Anti-Pattern 4: Sameness Across a Set

**The failure:** All images in a batch share the same visual vocabulary — palette, scale, composition, subject type. They feel like variations of one image.

**Applies to:** Any batch generation (editorial sets, social media packs, product variants).

**How to detect:** Lay all images side by side. If they blur together, they're too similar.

**The fix:** Deliberately vary across the set:
- **Scale:** Alternate macro, human-scale, and vast views
- **Subject type:** Mix natural, architectural, human, object, environmental
- **Composition:** Alternate symmetry, rule-of-thirds, close-up, wide establishing
- **Palette/tone:** Vary light/dark, warm/cool, saturated/muted
- **Medium:** If appropriate, mix photography, illustration, graphic design

---

## Anti-Pattern 5: Abstract Soup

**The failure:** Prompts too abstract — "flowing energy converging on a luminous point." Produces beautiful textures that communicate nothing.

**Applies especially to:** Editorial/cinematic, book covers.

**How to detect:** Would someone unfamiliar with the context feel something specific? Or just "it's pretty"?

**The fix:** Every image needs at least one recognizable physical element — a hand, a chair, a path, a book, a crowd. Abstract elements can be part of the composition, but they can't be the whole thing.

---

## Anti-Pattern 6: Over-Prompting

**The failure:** Cramming too many ideas, objects, and instructions into one prompt. The model tries to include everything and produces clutter.

**Applies to:** Everything, but especially posters and illustrations.

**How to detect:** The prompt describes more than one primary scene or more than 3-4 major elements.

**The fix:** One idea per image. One dominant element. Supporting details reinforce, not compete. If you have two ideas, make two images.

---

## Anti-Pattern 7: Ignoring the Medium Declaration

**The failure:** Not telling the model WHAT this is in the first line. Without this, the model defaults to its most common training data — usually generic digital art.

**Applies to:** Everything.

**The fix:** The first line of every prompt declares the medium:
- "Fine art black and white photograph"
- "Clean flat vector logo on white background"
- "Swiss International style event poster"
- "Professional product photograph, studio setting"
- "Bold graphic Instagram post"
- "Watercolor children's book illustration"

---

## Anti-Pattern 8: Ignoring AI's Text Limitations

**The failure:** Expecting AI to render readable, well-formed text. It almost never does. Letters get garbled, extra characters appear, spacing breaks.

**Applies especially to:** Logos, posters, social media, book covers.

**The fix:** Design the visual composition. Treat text areas as spatial zones. Note in every prompt whether text is expected and plan to refine it externally. For logos: generate the symbol/icon, add text in a design tool. For posters: compose the layout, replace text post-generation.

---

## Anti-Pattern 9: The Uncanny Valley of People

**The failure:** Requesting detailed human faces or specific expressions. AI produces subtle distortions that destroy credibility.

**Applies especially to:** Editorial/cinematic, lifestyle product photography, book covers.

**How to detect:** The person has a slightly wrong face, an extra finger, or an expression that doesn't fit.

**The fix:**
- Use silhouettes, backs of heads, hands, figures at a distance
- Use blur, fog, or shadow to naturally obscure facial detail
- For crowds/groups: keep individuals at a distance
- If faces are essential, review carefully and be willing to regenerate

---

## Anti-Pattern 10: Wrong Aspect Ratio

**The failure:** Generating an image at the wrong dimensions for its intended use. A social story at 16:9. A product shot at 9:16. A logo at 16:9.

**Applies to:** Everything.

**The fix:** Determine the intended use FIRST, then set the aspect ratio:
- `1:1` — Logos, Instagram posts, album art, icons
- `16:9` — Cinematic, web headers, YouTube, Twitter
- `9:16` — Stories, vertical posters, TikTok, mobile
- `4:3` — Traditional photo, some print
- `3:4` — Pinterest, portrait, some book covers

---

## Anti-Pattern 11: Color Negligence

**The failure:** Not specifying a color palette, letting the model choose randomly. Results feel disjointed, off-brand, or clash with surrounding design.

**Applies especially to:** Logos, social media, posters, brand materials.

**The fix:** Always specify color direction:
- Exact hex codes if brand colors exist
- A mood-based palette ("warm earth tones," "cool desaturated blues," "monochrome with single red accent")
- A color count ("maximum 3 colors," "monochrome," "duotone black and gold")
- Genre-appropriate conventions (thrillers: dark, high contrast; romance: warm tones; tech: clean blues and whites)

---

## Anti-Pattern 12: Literal Illustration

**The failure:** Depicting the topic directly instead of finding a metaphor or creative approach. An article about data shows a screen with graphs. A brand about speed shows a cheetah.

**Applies especially to:** Editorial/cinematic, book covers, logos.

**How to detect:** "Is this what a stock photo search would return?" If yes, it's literal.

**The fix:** Go one level deeper. Don't illustrate the topic — illustrate the *feeling* the topic produces, or find a metaphor from an unexpected domain. The essay about data doesn't need a screen — it needs an image that captures the feeling of being overwhelmed by information, or the beauty of finding a pattern in noise.

---

## Recovery Checklist

When an image comes out wrong, diagnose which anti-pattern caused it:

| Symptom | Likely Anti-Pattern | Fix |
|---|---|---|
| Looks like stock art | #12 Literal illustration | Find a metaphor |
| Looks like AI-generated art | #3 Generic AI look | Specify real-world medium |
| Looks like a wallpaper with no meaning | #5 Abstract soup | Add recognizable element |
| Looks digitally rendered/plastic | #7 No medium declaration | Declare medium in first line |
| Looks too similar to other images in set | #4 Sameness | Change scale, subject, composition |
| Feels cluttered or confused | #6 Over-prompting | Simplify to one idea |
| Can be named in one noun | #2 Object, not idea | Add relationship/tension |
| Faces look wrong | #9 Uncanny valley | Use silhouettes/distance |
| Colors feel random or off-brand | #11 Color negligence | Specify palette |
| Text is garbled | #8 AI text limitations | Design composition, fix text externally |
| Doesn't fit the intended platform | #10 Wrong aspect ratio | Set correct dimensions |
| Feels generic, could be for anything | #1 No context understanding | Go back and read the content |
