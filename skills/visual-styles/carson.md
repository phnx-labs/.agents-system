# David Carson Style

Deconstructed typographic data visualization inspired by David Carson's Ray Gun magazine work. Controlled chaos. Text as texture. Rules exist to be broken -- but broken with intent.

## Signature Elements

- **Multiple typefaces at war.** Conflicting sizes (8pt to 200pt), conflicting weights, conflicting angles. The tension IS the design.
- **Text rotation and overlap.** Words at 15, 45, 90 degree angles. Partially obscured. Layered on top of each other.
- **Muted palette with one vivid accent.** Desaturated background, then one color that screams.
- **Intentional "mistakes."** Text running off edges, letters cut off, overlapping elements. Looks accidental, is calculated.
- **Density gradient.** Heavy at center, thinning toward edges. Or heavy at one corner, pulling the eye.

## Color Palettes

### Palette A: "Ray Gun" (default)
```python
BG = (35, 32, 28)             # Warm dark gray
TEXT_PRIMARY = (220, 215, 205) # Off-white
TEXT_SECONDARY = (140, 135, 125) # Medium gray
ACCENT = (255, 45, 0)         # Vivid red-orange (the screamer)
MUTED = (90, 85, 75)          # Background text layer
```

### Palette B: "End of Print"
```python
BG = (245, 240, 230)          # Warm off-white
TEXT_PRIMARY = (20, 18, 15)    # Near-black
TEXT_SECONDARY = (160, 155, 145) # Gray
ACCENT = (0, 80, 180)         # Vivid blue
MUTED = (210, 205, 195)       # Light gray text layer
```

### Palette C: "Punk Zine"
```python
BG = (15, 12, 20)             # Near-black with purple tint
TEXT_PRIMARY = (255, 255, 255) # Pure white
TEXT_SECONDARY = (120, 110, 130) # Muted purple-gray
ACCENT = (255, 220, 0)        # Vivid yellow
MUTED = (45, 40, 55)          # Dark purple-gray
```

## Layout Patterns

### Pattern 1: Text Explosion
For surprising/counterintuitive findings. The key phrase explodes across the canvas.

```
+-----------------------------------------------+
|                    small context text           |
|        MASSIVE                                  |
|     ROTATED          the                        |
|        WORD     surprising    tiny detail       |
|                   FINDING                       |
|    background                                   |
|      text at         NUMBER                     |
|       angle      that changes                   |
|                  everything                     |
|  more background                                |
|    text filling         label                   |
+------------------------------------------------+
```

- Key phrase broken into individual words at different sizes and angles
- The "surprise" word or number is the largest element, in accent color
- Supporting text scattered at various angles and sizes
- Background text layer in muted color fills remaining space

### Pattern 2: Layer Stack
Data presented in overlapping layers, each slightly rotated.

```
+-----------------------------------------------+
|                                                |
|    +-[LAYER 3, rotated -3deg]----------+       |
|    |  CATEGORY C: 789                  |       |
|    +-----------------------------------+       |
|       +-[LAYER 2, rotated 2deg]--------+       |
|       |  CATEGORY B: 456              |        |
|       +--------------------------------+       |
|          +-[LAYER 1, rotated -1deg]----+       |
|          |  CATEGORY A: 123           |        |
|          +-----------------------------+       |
|                                                |
|    TITLE TEXT (large, bottom-left)              |
+------------------------------------------------+
```

- Each data category on its own "card" layer
- Layers slightly rotated and offset (like scattered papers)
- Cards overlap, creating depth
- Title placed wherever there's space (not necessarily top)

### Pattern 3: Margin Bleed
Text and numbers deliberately run off the canvas edges.

```
+-----------------------------------------------+
|HE KEY FINDING IS                               |
|                                                |
|               45,7                              |
|                   45                            |
|                                                |
|    the rest of the story continues here in     |
|    smaller text that wraps and fills and       |
|    creates a body of text that grounds the     |
|    chaotic number above                        |
|                                                |
|                           NOT WHAT YOU'D EXPE  |
+------------------------------------------------+
```

- Key text starts before the left edge (cut off on entry)
- Numbers split across two lines at unexpected positions
- Sentences run past the right edge (cut off on exit)
- Creates urgency: there's more than the frame can contain

## Controlled Chaos Algorithm

The chaos looks random but follows rules:

```python
import random, math

def chaos_placement(W, H, num_elements, seed=42):
    """Generate positions/rotations that look chaotic but are balanced."""
    random.seed(seed)
    placements = []

    # Divide canvas into zones to ensure distribution
    zones = [(0, 0, W//2, H//2), (W//2, 0, W, H//2),
             (0, H//2, W//2, H), (W//2, H//2, W, H)]

    for i in range(num_elements):
        zone = zones[i % len(zones)]
        x = random.randint(zone[0], zone[2])
        y = random.randint(zone[1], zone[3])
        rotation = random.uniform(-25, 25)  # degrees
        # Hero element gets less rotation
        if i == 0:
            rotation = random.uniform(-5, 5)
        placements.append((x, y, rotation))

    return placements

def chaos_font_size(importance, base=40):
    """Size by importance: 0=hero (huge), 1=secondary, 2+=small."""
    sizes = {0: base * 5, 1: base * 3, 2: base * 1.5}
    return int(sizes.get(importance, base))
```

## Text Rotation with PIL

PIL doesn't rotate text directly. Create a temporary image, rotate it, paste with transparency:

```python
from PIL import Image, ImageDraw, ImageFont

def draw_rotated_text(canvas, position, text, font, color, angle):
    """Draw text at an angle on the canvas."""
    # Create text image with transparency
    bbox = font.getbbox(text)
    tw = bbox[2] - bbox[0] + 20
    th = bbox[3] - bbox[1] + 20
    txt_img = Image.new('RGBA', (tw, th), (0, 0, 0, 0))
    txt_draw = ImageDraw.Draw(txt_img)
    txt_draw.text((10, 10), text, fill=color + (255,), font=font)

    # Rotate
    rotated = txt_img.rotate(angle, expand=True, resample=Image.BICUBIC)

    # Paste onto canvas (need RGBA canvas or use mask)
    x, y = position
    canvas.paste(rotated, (x, y), rotated)
```

## Fonts

```python
import os
from PIL import ImageFont

# Multiple typefaces -- the conflict is intentional
druk_heavy = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/Druk-Heavy-Trial.otf"), s)
druk_wide = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukWide-Heavy-Trial.otf"), s)
druk_super = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/Druk-Super-Trial.otf"), s)
druk_text_medium = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukText-Medium-Trial.otf"), s)
helvetica = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=0)
helvetica_light = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=2)
```

Font conflict rules:
- Hero element: Druk-Super or DrukWide-Heavy (200-300pt)
- Secondary elements: Druk-Heavy at conflicting sizes (40-120pt)
- Body text: Helvetica Regular (20-32pt) -- the calm amid chaos
- Whisper text: Helvetica Light or DrukText-Medium (10-16pt)
- Never use the same font at the same size twice on the same canvas

## Script Template

```python
from PIL import Image, ImageDraw, ImageFont
import os, random, math

# --- Config ---
W, H = 1800, 1012

BG = (35, 32, 28)
OFF_WHITE = (220, 215, 205)
GRAY = (140, 135, 125)
ACCENT = (255, 45, 0)
MUTED = (90, 85, 75)

druk_heavy = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/Druk-Heavy-Trial.otf"), s)
druk_wide = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukWide-Heavy-Trial.otf"), s)
druk_super = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/Druk-Super-Trial.otf"), s)
helvetica = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=0)

def draw_rotated_text(canvas, position, text, font, color, angle):
    bbox = font.getbbox(text)
    tw = bbox[2] - bbox[0] + 20
    th = bbox[3] - bbox[1] + 20
    txt_img = Image.new('RGBA', (tw, th), (0, 0, 0, 0))
    txt_draw = ImageDraw.Draw(txt_img)
    txt_draw.text((10, 10), text, fill=color + (255,), font=font)
    rotated = txt_img.rotate(angle, expand=True, resample=Image.BICUBIC)
    canvas.paste(rotated, position, rotated)

# Use RGBA for rotation compositing
img = Image.new('RGBA', (W, H), BG + (255,))
draw = ImageDraw.Draw(img)

random.seed(42)

# 1. MUTED BACKGROUND TEXT LAYER
bg_phrases = ["BACKGROUND PHRASE", "ANOTHER ONE", "FILL TEXT"]
bg_font = helvetica(16)
for _ in range(80):
    x = random.randint(-50, W)
    y = random.randint(-20, H)
    angle = random.uniform(-30, 30)
    draw_rotated_text(img, (x, y), random.choice(bg_phrases), bg_font, MUTED, angle)
    draw = ImageDraw.Draw(img)  # Refresh after paste

# 2. SECONDARY ELEMENTS (scattered data points)
secondary_data = [("LABEL A", "123"), ("LABEL B", "456"), ("LABEL C", "789")]
positions = [(200, 150, -8), (1100, 250, 12), (400, 600, -15), (1200, 550, 5)]
for i, (label, value) in enumerate(secondary_data):
    if i >= len(positions):
        break
    x, y, angle = positions[i]
    # Label in small gray
    draw_rotated_text(img, (x, y), label, druk_heavy(28), GRAY, angle)
    draw = ImageDraw.Draw(img)
    # Value in larger off-white
    draw_rotated_text(img, (x + 20, y + 40), value, druk_heavy(72), OFF_WHITE, angle + random.uniform(-5, 5))
    draw = ImageDraw.Draw(img)

# 3. HERO ELEMENT (the surprise, in accent color)
hero_text = "THE KEY FINDING"
hero_font = druk_super(180)
# Slightly off-center, minimal rotation
draw_rotated_text(img, (W // 2 - 400, H // 2 - 120), hero_text, hero_font, ACCENT, random.uniform(-3, 3))
draw = ImageDraw.Draw(img)

# 4. HERO NUMBER
num_text = "45,745"
num_font = druk_wide(220)
draw_rotated_text(img, (W // 2 - 350, H // 2 + 60), num_text, num_font, OFF_WHITE, random.uniform(-2, 2))
draw = ImageDraw.Draw(img)

# 5. GROUNDING TEXT (body copy, calm contrast to chaos)
body = "The context that makes this finding matter."
body_font = helvetica(24)
draw.text((100, H - 120), body, fill=GRAY + (255,), font=body_font)

# Convert to RGB for saving
img_rgb = img.convert('RGB')
img_rgb.save('/tmp/carson_visual.png', quality=95)
print(f"Saved: /tmp/carson_visual.png ({W}x{H})")
```

## Key Rules

1. **Conflict is the point.** If everything looks harmonious, you're doing it wrong. Mix typefaces, sizes, angles.
2. **One accent color screams.** Everything else is muted. The accent is the finding. The rest is texture.
3. **Rotation range: -25 to +25 degrees.** Beyond that looks like a bug, not a choice.
4. **Size range: 10pt to 300pt on one canvas.** The contrast between whisper and shout creates drama.
5. **Hero gets minimal rotation.** The surprise finding should be readable. Chaos surrounds it, not obscures it.
6. **Body text is the anchor.** One block of calm, readable Helvetica grounds the composition. Without it, chaos becomes noise.
7. **Use for counterintuitive data only.** If the finding is straightforward, use Vignelli or Bass. Carson is for "wait, what?" moments.
