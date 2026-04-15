# Enrichment -- Seeing What a Post Needs

This is not a checklist of visual types to apply. It is a guide to developing the judgment that tells you *this section needs a diagram* vs *this section needs to breathe* vs *this section needs a portrait of the person being discussed*.

## The Audit Mindset

Before adding anything, understand what the post already has and what it's missing. Not mechanically -- the way a chef tastes a dish and knows it needs acid, not sweetness.

Read the post twice:
1. **First read: as a reader.** Where did you get bored? Where were you confused? Where did your mind wander? Where did you want to see something? Those reactions are data.
2. **Second read: as a designer.** Map the density. Where is the text thick and unbroken? Where does the post change direction? Where are claims made that could be shown instead of told?

After both reads, you should have an instinct for what the post is asking for. Trust that instinct before applying any framework.

## Visual Types -- When Each Earns Its Place

### Editorial Photography

**What it does:** Carries an *idea*, not a subject. The best editorial images make the reader pause and feel something about the abstract concept being discussed -- before they even read the words around it.

**When it earns its place:**
- The post discusses something abstract (loss of privacy, the pace of change, the loneliness of building) and the reader needs a visual anchor
- A section shift happens and the new section has a fundamentally different mood
- The post is long and contemplative and needs breathing room between dense passages

**When it doesn't:**
- The post is already vivid with concrete examples. Adding an image is redundant.
- The section is short. An image before a 3-sentence paragraph makes the image feel orphaned.
- The concept is better served by a diagram or data.

**How:** Read `/image-craft` (editorial-cinematic.md). Extract the *idea* from the section. Translate it into a visual metaphor. Generate via `/higgsfield`.

### Portraits

**What it does:** Puts a face to a name. When a post discusses someone -- their work, their ideas, their impact -- a portrait makes that person real to the reader.

**When it earns its place:**
- A specific person is discussed at length (not just mentioned in passing)
- The post's argument rests on quoting or citing someone
- Multiple people are compared or contrasted
- The person is not famous enough that the reader would already picture them

**When it doesn't:**
- The person is mentioned in a list with 10 others. You don't need 10 portraits.
- The person is a household name (Elon Musk, Steve Jobs). The reader already has an image.
- The post is about ideas, not people. Forcing a portrait breaks the flow.

**How:** Search for a real photo first (LinkedIn, company website, press kit). Only generate an editorial portrait if no real photo is available and the person is central to the piece. Never generate a fake photorealistic portrait of a real person.

### Diagrams

**What it does:** Makes the invisible visible. Systems, processes, architectures, data flows, hierarchies -- anything with structure that the reader needs to *see* to understand.

**When it earns its place:**
- The post describes how something works (a system, a process, a workflow)
- The post compares multiple options and the reader needs to hold them in mind simultaneously
- The argument has a structure (if X then Y, A leads to B leads to C) that benefits from spatial layout
- The reader would otherwise need to re-read the paragraph 3 times to follow the relationships

**When it doesn't:**
- The concept is simple enough that the sentence explains it fully
- The diagram would just be a box with one label (that's not a diagram, it's a sign)
- The post is deliberately abstract and a concrete diagram would break the mood

**How:** Mermaid for simple flowcharts. `/image-craft` (illustrations) for styled diagrams. Hand-drawn style for informal posts, clean vector for technical ones.

### Data Visualizations

**What it does:** Turns numbers into meaning. A chart of API pricing collapse over 18 months says more than "prices dropped 280x."

**When it earns its place:**
- The post cites specific numbers or statistics
- The argument is "things are changing fast/slow/differently than you think"
- A trend, comparison, or distribution is the core evidence for a claim
- The reader would otherwise just skim past the numbers in the sentence

**When it doesn't:**
- The numbers are incidental, not central to the argument
- There's only one data point (you don't chart a single number)
- The data is speculative or made up ("imagine if...")

**How:** Generate chart images, or use inline SVG/HTML if the blog supports it.

### Pull Quotes

**What it does:** Elevates a key insight from the text and gives it visual weight. Like a billboard on the highway of the article -- it signals "this is worth remembering."

**When it earns its place:**
- A single sentence captures the post's thesis or most surprising insight
- The post is long and the reader needs anchor points to remember where they are
- A quoted person said something that deserves to be displayed, not buried

**When it doesn't:**
- Every section has one. Pull quotes lose power through repetition.
- The quote is unremarkable. Only pull what would make someone screenshot it.

### Before/After Comparisons

**What it does:** Makes contrast vivid. Side-by-side images that show the old way vs the new way, the problem vs the solution, the competitor vs you.

**When it earns its place:**
- The post's core argument is "X has changed" or "X is different from Y"
- The reader needs to SEE the difference, not just be told about it
- Product comparisons where the UI tells the story better than words

**When it doesn't:**
- The comparison is about abstract qualities (speed, intelligence) that don't have visual form
- Forcing a visual comparison when the textual comparison is already crystal clear

### GIFs and Video

**What it does:** Shows motion, process, interaction. Static images can't capture a product workflow, an animation, or a step-by-step demonstration.

**When it earns its place:**
- Demonstrating a product interaction (click this, see this happen)
- A process has sequential steps that benefit from animation
- The "wow factor" of the thing being discussed is in its motion, not its appearance

**When it doesn't:**
- A static screenshot captures the same information
- The post is contemplative and a moving element would break the mood
- The GIF would be longer than 5 seconds (that's a video, embed it properly)

### Links

**Internal links** connect the post to others on the same site. They strengthen SEO and guide readers deeper. But they must feel natural -- linked phrases should make sense in context, not feel shoehorned in for Google.

**External links** cite sources, credit people, and let curious readers go deeper. They build credibility. Link to primary sources (the actual paper, the actual tweet), not summaries of summaries.

**When links don't help:** Don't litter a post with links just for SEO. Five thoughtful links beat twenty mechanical ones.

### Nothing

Sometimes the most powerful design decision is restraint. A section that's working -- vivid writing, clear argument, strong voice -- doesn't need decoration. Adding an image to a section that's already carrying its weight is like putting a frame around a window. The view was the point.

## The Process

1. Read the post. Feel it.
2. Mark the moments that need something. Note WHAT they need and WHY -- not "add image here" but "this is where the reader's attention breaks because 600 words of abstraction need a concrete visual anchor."
3. Plan the additions. For each one, know what it is, why it belongs, and what tool creates it.
4. Generate. Use the right tool for each type.
5. Insert. Place it where it serves the reading experience, with descriptive alt text.
6. Read the post again with the additions. Does it flow better? Or did you interrupt something that was working? Remove anything that hurts the rhythm.
