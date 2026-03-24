# Editorial / Cinematic Photography

Sub-skill for essay illustrations, article headers, mood imagery, conceptual photography, and fine art. Use this when the image must carry an *idea* — not just depict a subject.

---

## Understanding Phase

Your job is to read the source material and extract **ideas**, not topics.

### Topic vs. Idea Extraction

A topic is a category label. An idea is a tension, a feeling, a paradox — something that moves.

| Source Text | Topic (wrong) | Idea (right) |
|---|---|---|
| An essay about AI progress | "Artificial intelligence" | The feeling of watching something cross a threshold that does not uncross |
| A piece on remote work isolation | "Remote work" | The slow evaporation of the boundary between rest and labor |
| Code documentation for a compiler | "Compilers" | The violence of translation — meaning forced through a narrow passage and emerging changed |
| An obituary | "Death" | The unbearable specificity of what remains after someone leaves |
| A startup fundraising memo | "Entrepreneurship" | Convincing strangers to believe in a future that doesn't exist yet |
| An essay on climate change | "Environment" | The strange calm of knowing the math and doing nothing |

### How to Read for Ideas

1. **Read the full content.** Don't skim. The best ideas live in transitions, asides, and the spaces between arguments.
2. **Ask:** What is the author *feeling*? Not saying — feeling. What tension drives the piece?
3. **Ask:** What would be lost if this were reduced to a Wikipedia summary? That residue is the idea.
4. **Ask:** What is the unresolved thing? The best editorial images capture unresolved tensions, not conclusions.

### Output: Theme Extraction

Extract 4–8 themes from the source material. Each theme must be expressible as:
- A feeling ("the vertigo of irreversible choice")
- A tension ("intimacy vs. surveillance")
- A paradox ("the more connected, the more alone")

Do not extract topics like "technology" or "nature." If your theme could be a hashtag, go deeper.

---

## Visual Metaphor Phase

The core method: **translate abstract ideas into concrete physical situations.**

A visual metaphor works when it communicates the idea to someone who has never read the source material and never will. If you need a caption to explain it, the metaphor failed.

### Rules for Strong Metaphors

1. **Physical and tangible.** The scene must contain real objects in real space — materials you could touch, light that behaves like light, surfaces with texture and weight.
2. **Photographable.** Ask: could a photographer set this up in a studio or find it in the world? If not, simplify until they could.
3. **Grounded in the everyday.** A chair, a hallway, a glass of water, a field, a staircase — mundane objects carry more weight than spectacular ones because they anchor the viewer in the familiar before estranging them.
4. **Unexpected configuration.** The power comes from placing ordinary things in extraordinary relationships. A single chair facing a wall of empty chairs. A glass of water balanced on the edge of a table. A door opening into open sky.
5. **One idea per image.** Never try to encode multiple themes. Pick the strongest one.

### Metaphor Translation Table

| Abstract Idea | Feeling | Visual Metaphor |
|---|---|---|
| The irreversibility of technological progress | Vertigo at a threshold | A massive stone rolled to the edge of a cliff, perfectly balanced, with a vast landscape below. Morning light. The stone is ancient; the drop is permanent. |
| Loss of privacy in the digital age | Being watched from inside your own home | A house with walls made entirely of glass, sitting alone in an open field at dusk. Every lamp is on. A single figure sits inside reading. |
| The labor of maintaining a public self | Exhaustion behind performance | A theater dressing room after the show — costume draped over a chair, makeup smudged on a mirror, a single bare lightbulb still burning. No people. |
| Knowledge that doesn't lead to action | Paralysis despite clarity | A perfectly detailed map pinned to a wall in an empty room. The door is open. No one has left. Dust on the floor is undisturbed. |
| The fragility of complex systems | One thread holding everything | A massive suspension bridge photographed from below, every cable visible, with one cable frayed and glowing in late afternoon light. |
| Human-machine convergence | Two natures sharing one body | An old wooden loom with silk threads feeding into a modern circuit board, both objects resting on the same rough workbench. Overhead industrial light. |
| Collective denial | Looking away together | A row of park benches, all facing away from a rising column of smoke on the horizon. Late golden hour. The benches are occupied but we see only backs. |
| The weight of inherited systems | Building on top of what you can't see | A modern glass building photographed from a construction excavation that reveals ancient stone foundations beneath it. Mud, rebar, history. |

---

## Prompt Architecture

Every editorial/cinematic prompt follows this skeleton:

```
[MEDIUM AND FORMAT]
Fine art / editorial / documentary photograph. Specify color or black-and-white.
Aspect ratio and orientation.

[SCENE DESCRIPTION]
Concrete, specific, physical. Name the materials. Describe the light source and direction.
Specify spatial relationships (foreground, midground, background).
Include textures, surfaces, weather if outdoor.
This is the longest section — 2-4 sentences minimum.

[THE IDEA]
Stated plainly with "The idea:" prefix.
One sentence. This anchors the model's interpretation.

[CAMERA AND TECHNIQUE]
Camera type (large format, medium format, 35mm).
Lens (wide angle, 50mm, telephoto, macro).
Film stock or sensor quality (Kodak Tri-X, Portra 400, Fuji Velvia, digital medium format).
Depth of field (shallow, deep, selective focus).
Any technique: long exposure, double exposure, tilt-shift.

[EMOTIONAL ANCHOR]
"In the style of [photographer/cinematographer]" or "Evoking [photographer]'s [specific body of work]."
This sets tonal direction — mood, grain, contrast, palette.
```

**Example — fully assembled:**

> Fine art black and white photograph, 16:9 horizontal format. A single wooden rowboat sits in the center of an enormous frozen lake. The ice extends to the horizon in every direction — cracked, textured, luminous grey. The boat is weathered, paint peeling, oars still resting in the locks as if someone just stepped out. Thin fog sits inches above the ice surface. The idea: the feeling of arriving somewhere you can no longer leave. Shot on large format 4x5 camera, 90mm lens, Ilford HP5 film, deep focus from foreground ice cracks to distant horizon. Evoking Hiroshi Sugimoto's Seascapes series — extreme stillness, infinite tonal range, the sublime made quietly terrifying.

---

## Prompt Patterns

### 1. The Juxtaposition

**When to use:** The idea involves tension, opposition, contradiction, or two forces meeting.

**Template:**
```
[Medium]. Two [objects/elements] in the same frame — [element A described] and [element B described].
They [spatial relationship: face each other / share a boundary / occupy the same surface].
[Lighting and environment that amplifies the tension].
The idea: [the tension stated plainly].
[Camera/technique]. [Emotional anchor].
```

**Example:**
> Editorial color photograph, 4:3 format. A pristine white grand piano sits in the middle of a dense forest clearing. Ferns grow through cracks in its open lid. Morning mist threads between the trees. Moss has begun to climb one leg. The idea: culture's losing negotiation with time. Shot on medium format Hasselblad, 80mm lens, Kodak Portra 400 film, shallow focus on the piano with the forest softening behind. Evoking the saturated natural stillness of Sally Mann's Southern landscapes.

### 2. The Vast Field

**When to use:** The idea involves scale, insignificance, the sublime, incomprehensible forces, or being dwarfed by something larger.

**Template:**
```
[Medium]. A [vast landscape/space] stretching [to horizon / endlessly / beyond the frame].
[One small element] sits [in the center / at the edge / barely visible].
[Environmental detail: weather, light, atmosphere].
The idea: [smallness or enormity stated plainly].
[Camera/technique — wide angle preferred]. [Emotional anchor].
```

**Example:**
> Fine art color photograph, 16:9 panoramic format. An endless salt flat under a cloudless sky, the horizon line perfectly bisecting the frame. A single red plastic chair sits dead center, casting a long shadow in the low afternoon sun. The ground is cracked into hexagonal tiles stretching in every direction. The idea: the absurdity of human scale against geological indifference. Shot on large format 4x5, 65mm wide angle lens, Fuji Velvia 50 for saturated color and extreme sharpness. Evoking Andreas Gursky's monumental landscapes — clinical precision, overwhelming pattern, the individual reduced to punctuation.

### 3. The Empty Container

**When to use:** The idea involves absence, hollowness, potential, or the gap between form and substance.

**Template:**
```
[Medium]. A [container/vessel/structure] that should hold [something] but is empty.
[Describe the container in specific material detail].
[Evidence of what was here — traces, marks, residue].
The idea: [the absence stated plainly].
[Camera/technique]. [Emotional anchor].
```

**Example:**
> Black and white documentary photograph, 3:4 vertical format. A cast-iron bathtub sits in an abandoned room, positioned beneath a hole in the ceiling open to the sky. Rain has pooled in the tub — a few inches of still water reflecting the clouds above. Peeling wallpaper, plaster debris on the floor, a single rusted faucet still attached. The idea: shelter that no longer shelters. Shot on 35mm Leica, 28mm wide angle, Kodak Tri-X pushed to 1600 for heavy grain and deep blacks. Evoking the quiet devastation of Robert Polidori's post-Katrina interiors.

### 4. The Procession

**When to use:** The idea involves collective movement, momentum, ritual, migration, or humanity moving toward something uncertain.

**Template:**
```
[Medium]. A [group/line/crowd] of [figures/objects] moving [direction].
[They are carrying / wearing / pulling / following] [specific detail].
[The destination is: visible but distant / obscured / absent].
The idea: [collective movement stated plainly].
[Camera/technique — often slightly elevated or from behind]. [Emotional anchor].
```

**Example:**
> Editorial black and white photograph, 16:9 format. A long line of people in dark coats walking single-file along a narrow dirt path through a snow-covered field. They carry identical black umbrellas though no rain falls. The path leads toward a dense tree line shrouded in fog. No faces visible — only backs and shoulders. The idea: faith as forward motion without a visible destination. Shot on medium format, 150mm telephoto to compress the line, Ilford Delta 3200 for extreme grain and atmosphere. Evoking Sebastião Salgado's migrations — the monumental dignity of collective human movement.

### 5. The Intimate Trace

**When to use:** The idea involves mortality, memory, the personal, what individuals leave behind, or the evidence of a life.

**Template:**
```
[Medium]. A close-up or intimate view of [marks/traces/objects left behind].
[Specific material: handwriting, fingerprints, wear patterns, stains, impressions].
[No people present — only the evidence of their existence].
The idea: [what the trace communicates].
[Camera/technique — often macro or medium close-up]. [Emotional anchor].
```

**Example:**
> Fine art color photograph, 1:1 square format. A well-worn wooden kitchen table surface shot from directly above. Decades of knife marks, cup rings, pen impressions, a child's crayon scribble half-sanded away. The wood grain is warm amber. Late afternoon window light rakes across the surface at a low angle, catching every groove and scratch. The idea: a family autobiography written in accidental damage. Shot on medium format digital, 80mm macro lens, shallow depth of field. Evoking the tender material attention of Edward Weston's close-up studies — surfaces as portraits.

### 6. The Impossible Object

**When to use:** The idea involves paradox, logical impossibility, cognitive dissonance, or something that shouldn't exist.

**Template:**
```
[Medium]. A [object/scene] that contains a [physical impossibility or paradox].
[Describe it as if photographing something real — materials, light, texture all behave normally].
[The impossibility is quiet, not spectacular — it takes a moment to register].
The idea: [the paradox stated plainly].
[Camera/technique]. [Emotional anchor].
```

**Example:**
> Fine art color photograph, 4:3 format. A perfectly ordinary wooden staircase in a residential home, carpeted in beige, with a white-painted banister. The stairs descend from the second floor and — instead of reaching the ground floor — continue straight down into still, dark water that fills the entire first floor to waist height. The water is calm. Light from a window reflects off the surface. The idea: the moment a familiar system stops working the way it always has. Shot on large format 4x5, 75mm lens, Kodak Ektar 100 for fine grain and precise color. Evoking Gregory Crewdson's staged suburban uncanny — hyperreal domestic spaces harboring quiet impossibility.

### 7. The Threshold

**When to use:** The idea involves a point of no return, a transition, a boundary between states, a moment before or after change.

**Template:**
```
[Medium]. A [doorway/gate/edge/boundary] between [state A] and [state B].
[One side described in detail]. [The other side described in contrasting detail].
[A figure or object at the exact boundary, or the boundary itself as the subject].
The idea: [the irreversibility or transition stated plainly].
[Camera/technique]. [Emotional anchor].
```

**Example:**
> Editorial color photograph, 16:9 format. A heavy industrial fire door propped open with a brick, seen from inside a dark concrete corridor. Through the door: blinding white daylight, so overexposed that nothing beyond is visible — just pure white. The corridor behind is detailed — pipes on the ceiling, scuff marks on the floor, a fire extinguisher on the wall. The idea: the terror and magnetism of a future you can't preview. Shot on 35mm, 35mm wide angle lens, Kodak Portra 800 with the highlights deliberately blown. Evoking the liminal tension of Fan Ho's Hong Kong street photography — geometry, light, and the human caught between.

### 8. The Organic Machine

**When to use:** The idea involves human-technology integration, natural and artificial merging, systems that blur the line between grown and built.

**Template:**
```
[Medium]. A [natural/organic element] and a [mechanical/technological element] sharing [a body/structure/space] in a way that makes it unclear where one ends and the other begins.
[Describe specific materials: bark and copper, root and wire, skin and glass].
The idea: [the convergence stated plainly].
[Camera/technique]. [Emotional anchor].
```

**Example:**
> Fine art black and white photograph, 3:4 vertical format. A cross-section of an old tree trunk, freshly cut, displayed on a museum pedestal. The growth rings in the inner wood gradually transition into concentric circuits — copper traces, solder points, tiny resistors — growing denser toward the center, as if the tree's earliest years were electronic. The bark on the exterior is perfectly natural. The idea: the suspicion that something mechanical was always inside us. Shot on medium format, 120mm macro lens, Ilford FP4 for exquisite tonal detail. Evoking Hiroshi Sugimoto's conceptual precision — objects as philosophical propositions.

---

## Photographer / Cinematographer Reference Table

Use these as emotional anchors. The reference sets tonal direction — the model interprets mood, grain, contrast, palette, and compositional style.

| Name | Known For | Use As Anchor When |
|---|---|---|
| **Sebastião Salgado** | Epic black-and-white, human labor, migration, dignity in suffering, monumental scale | The image needs grandeur, moral weight, or collective humanity |
| **Hiroshi Sugimoto** | Minimalism, long exposure, seascapes, theaters, time collapsed into single frames | The image needs extreme stillness, conceptual precision, or philosophical quiet |
| **Andreas Gursky** | Large-scale, clinical landscapes, overwhelming pattern, industrial sublime, digital-era scale | The image needs vastness, systematic pattern, or the individual dwarfed by structure |
| **Sally Mann** | Southern landscapes, family intimacy, decay, collodion process, haunted beauty | The image needs organic decay, familial weight, or beauty entwined with loss |
| **Ansel Adams** | Monumental Western landscapes, extreme tonal range, the zone system, pristine wilderness | The image needs landscape grandeur, technical perfection, or cathedral-like natural scale |
| **Edward Weston** | Close-up studies of form — peppers, shells, nudes, dunes — surfaces as abstract sculpture | The image needs intimate attention to surface, material texture, or form as meaning |
| **Gregory Crewdson** | Staged suburban tableaux, cinematic lighting, uncanny domestic scenes, American unease | The image needs hyperreal staging, quiet dread, or the familiar made strange |
| **Fan Ho** | Hong Kong street photography, geometry of light and shadow, human figures as compositional elements | The image needs dramatic geometry, high contrast light play, or urban loneliness |
| **Robert Frank** | Raw, grainy, spontaneous, The Americans — the unvarnished emotional truth of a culture | The image needs raw authenticity, imperfection as honesty, or cultural critique |
| **Dorothea Lange** | Documentary dignity, the Depression, faces that carry history, empathy without sentimentality | The image needs documentary weight, human resilience, or social conscience |
| **Terrence Malick** (cinematography) | Magic hour, natural light, waving grass, spiritual longing, the numinous in the ordinary | The image needs golden-hour transcendence, natural world as spiritual space |
| **Roger Deakins** (cinematography) | Precise composition, naturalistic lighting, architectural framing, visual storytelling | The image needs controlled cinematic light, architectural composition, or narrative clarity |
| **Emmanuel Lubezki** (cinematography) | Long takes, natural and available light, immersive movement, existential atmosphere | The image needs immersive atmosphere, available light realism, or existential weight |
| **Vivian Maier** | Street photography, urban observation, self-portraits in reflections, unposed humanity | The image needs candid urban observation, accidental poetry, or unguarded moments |

---

## Quality Checks for Editorial / Cinematic

Before finalizing any prompt, pass it through these tests:

1. **Idea test:** Remove the "The idea:" line. Can you still intuit the idea from the scene alone? If not, the metaphor is too abstract — make it more concrete.
2. **Realism test:** Could a skilled photographer actually capture this (or something very close to it) with real equipment in a real location? If not, simplify. Surrealism is fine, but it must be *physically constructed* surrealism — like a set piece — not digital fantasy.
3. **Distinction test:** If generating multiple images for the same piece, are they genuinely different compositions, different metaphors, different moods? Varying the lighting on the same scene does not count.
4. **DALL-E test:** Read the prompt imagining you are the model. Is every physical element unambiguous? Could the model misinterpret any spatial relationship? Rewrite anything fuzzy.
5. **Object-vs-idea test:** Is the prompt describing a thing, or communicating a feeling? If you removed the emotional anchor and the idea line, would the scene still feel intentional — or would it just be a picture of some objects? The scene composition itself must carry meaning.

---

## Constraints

- **Never describe AI-generated aesthetics.** No "digital art," "CGI render," "hyperrealistic 3D," or "AI-generated." Describe the image as if it were made by a human with physical tools.
- **Never use sci-fi vocabulary unless the content is about sci-fi.** No "holographic," "cyberpunk," "futuristic," "neon-lit" for an essay about education reform.
- **Avoid generic AI subjects.** No floating brains, glowing orbs, abstract neural networks, robots with human faces, or hands reaching toward light. These are visual clichés that communicate nothing.
- **Prefer natural materials.** Wood, stone, water, cloth, iron, glass, paper, soil. These carry more visual and emotional weight than plastic, chrome, or synthetic surfaces.
- **Every image must be visually distinct.** Within a set generated for the same content, no two images should share the same dominant composition, color palette, or central object.
- **Never over-specify people's demographics** unless the content requires it. A figure silhouetted in a doorway is more universal than a detailed portrait.
- **Let the negative space work.** The best editorial photographs are at least 40% empty — sky, water, fog, shadow, blank wall. Emptiness is not wasted space; it is where the idea breathes.
