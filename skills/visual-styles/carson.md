# David Carson Style

Deconstructed typographic data visualization inspired by David Carson's Ray Gun magazine work. Controlled chaos. Text as texture. Rules exist to be broken -- but broken with intent.

## Signature Elements

- **Multiple typefaces at war.** Conflicting sizes (8pt to 200pt), conflicting weights, conflicting angles. The tension IS the design.
- **Text rotation and overlap.** Words at various angles, partially obscured, layered on top of each other.
- **Muted palette with one vivid accent.** Desaturated background, then one color that screams.
- **Intentional "mistakes."** Text running off edges, overlapping elements. Looks accidental, is calculated.
- **Density gradient.** Heavy at center, thinning toward edges.

## When to Use

- Surprising or counterintuitive finding ("wait, what?")
- Data that doesn't make intuitive sense
- Disruption narratives, contrarian takes
- NOT for professional/authoritative tone (use Vignelli) or clean announcements (use Bass)

## Data Interface

```python
# === YOUR DATA (fill this in) ===
config = {
    "hero_phrase": "LET ME",              # The key finding (vivid accent color, largest)
    "hero_number": "45,745",              # The surprising number (off-white, second largest)
    "scatter_data": [                     # Secondary data scattered around the hero
        {"label": "HEDGING", "value": "45,745"},
        {"label": "APOLOGIZING", "value": "8,234"},
        {"label": "DISCLAIMING", "value": "3,891"},
        {"label": "FILLER", "value": "2,456"},
        {"label": "VERBOSE", "value": "1,987"},
    ],
    "accent_word": "TIMES",              # Small word near hero at conflicting angle
    "body_text": [                        # Grounding text (calm Helvetica at bottom)
        "75.9% of all Claude messages started with",
        "the same two words. The most predictable",
        "conversational AI in history.",
    ],
    "bg_phrases": ["LET ME", "CERTAINLY", "I APOLOGIZE", "AS AN AI", "HOWEVER", "DELVE"],
}
# === END DATA ===
```

## Color Palettes

### Palette A: "Ray Gun" (default -- dark background)
```python
BG = (35, 32, 28)
OFF_WHITE = (220, 215, 205)
GRAY = (140, 135, 125)
ACCENT = (255, 45, 0)          # The screamer -- vivid red-orange
MUTED = (65, 60, 52)           # Mid background text
DARK_MUTED = (50, 46, 40)      # Deep background text
```

### Palette B: "End of Print" (light background)
```python
BG = (245, 240, 230)
OFF_WHITE = (20, 18, 15)       # Near-black text
GRAY = (160, 155, 145)
ACCENT = (0, 80, 180)          # Vivid blue
MUTED = (210, 205, 195)
DARK_MUTED = (225, 220, 210)
```

### Palette C: "Punk Zine" (dark with yellow accent)
```python
BG = (15, 12, 20)
OFF_WHITE = (255, 255, 255)
GRAY = (120, 110, 130)
ACCENT = (255, 220, 0)         # Vivid yellow
MUTED = (45, 40, 55)
DARK_MUTED = (30, 26, 38)
```

## Controlled Chaos System

The chaos looks random but follows rules:

1. **Three depth layers**: deep background (barely visible) -> mid background (texture) -> foreground (readable)
2. **Scatter data into quadrants**: divide canvas into 4-6 zones, place one data point per zone
3. **Hero gets minimal rotation** (-3 to +3 degrees). Chaos surrounds it, not obscures it.
4. **Body text is the anchor**: one block of calm, readable Helvetica grounds the composition.

```python
# Scatter placement: one item per zone, with controlled randomness
zones = [
    (50, 80, 400, 250),       # top-left
    (1200, 100, 1550, 300),   # top-right
    (100, 650, 450, 800),     # bottom-left
    (1300, 620, 1600, 780),   # bottom-right
    (1350, 350, 1600, 500),   # mid-right
]
angles = [-14, 10, -20, 7, -5]  # pre-set angles per zone
```

## Text Rotation Helper

```python
from PIL import Image, ImageDraw, ImageFont

def draw_rotated_text(canvas, position, text, font, color, angle):
    """Draw text at an angle. Creates temp RGBA image, rotates, composites."""
    bbox = font.getbbox(text)
    tw = bbox[2] - bbox[0] + 40
    th = bbox[3] - bbox[1] + 40
    txt_img = Image.new('RGBA', (tw, th), (0, 0, 0, 0))
    txt_draw = ImageDraw.Draw(txt_img)
    txt_draw.text((20, 20), text, fill=color + (255,), font=font)
    rotated = txt_img.rotate(angle, expand=True, resample=Image.BICUBIC)
    canvas.paste(rotated, position, rotated)
```

## Fonts

```python
import os
from PIL import ImageFont

# Multiple typefaces -- the conflict is intentional
druk_heavy = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/Druk-Heavy-Trial.otf"), s)
druk_wide = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukWide-Heavy-Trial.otf"), s)
druk_super = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/Druk-Super-Trial.otf"), s)
druk_text_med = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukText-Medium-Trial.otf"), s)
helvetica = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=0)
helvetica_light = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=2)
```

Font conflict rules:
- Hero phrase: Druk-Super 140-180pt (ACCENT color)
- Hero number: DrukWide-Heavy 200-240pt (OFF_WHITE)
- Accent word: Druk-Heavy 36-44pt (ACCENT, at 10-20 degree angle)
- Scatter labels: DrukText-Medium 24-36pt (GRAY)
- Scatter values: Druk-Heavy 40-56pt (OFF_WHITE)
- Body text: Helvetica Light 22-26pt (GRAY) -- the calm anchor
- Background (deep): Druk-Heavy 180-220pt (DARK_MUTED)
- Background (mid): Helvetica 11-17pt (MUTED)

## Production Script Template

```python
from PIL import Image, ImageDraw, ImageFont
import os, random, math

# === YOUR DATA (fill this in) ===
config = {
    "hero_phrase": "LET ME",
    "hero_number": "45,745",
    "scatter_data": [
        {"label": "HEDGING", "value": "45,745"},
        {"label": "APOLOGIZING", "value": "8,234"},
        {"label": "DISCLAIMING", "value": "3,891"},
        {"label": "FILLER", "value": "2,456"},
        {"label": "VERBOSE", "value": "1,987"},
    ],
    "accent_word": "TIMES",
    "body_text": [
        "75.9% of all Claude messages started with",
        "the same two words. The most predictable",
        "conversational AI in history.",
    ],
    "bg_phrases": ["LET ME", "CERTAINLY", "I APOLOGIZE", "AS AN AI", "HOWEVER", "DELVE"],
}
# === END DATA ===

W, H = 1800, 1012
random.seed(77)

BG = (35, 32, 28)
OFF_WHITE = (220, 215, 205)
GRAY = (140, 135, 125)
ACCENT = (255, 45, 0)
MUTED = (65, 60, 52)
DARK_MUTED = (50, 46, 40)

druk_heavy = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/Druk-Heavy-Trial.otf"), s)
druk_wide = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukWide-Heavy-Trial.otf"), s)
druk_super = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/Druk-Super-Trial.otf"), s)
druk_text_med = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukText-Medium-Trial.otf"), s)
helvetica = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=0)
helvetica_light = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=2)

def draw_rotated_text(canvas, position, text, font, color, angle):
    bbox = font.getbbox(text)
    tw = bbox[2] - bbox[0] + 40
    th = bbox[3] - bbox[1] + 40
    txt_img = Image.new('RGBA', (tw, th), (0, 0, 0, 0))
    txt_draw = ImageDraw.Draw(txt_img)
    txt_draw.text((20, 20), text, fill=color + (255,), font=font)
    rotated = txt_img.rotate(angle, expand=True, resample=Image.BICUBIC)
    canvas.paste(rotated, position, rotated)

img = Image.new('RGBA', (W, H), BG + (255,))
draw = ImageDraw.Draw(img)

# --- Layer 1: DEEP BACKGROUND (barely visible large words) ---
for phrase in config["bg_phrases"][:3]:
    x = random.randint(-100, W - 200)
    y = random.randint(-50, H - 100)
    draw_rotated_text(img, (x, y), phrase, druk_heavy(200), DARK_MUTED, random.uniform(-20, 20))
    draw = ImageDraw.Draw(img)

# --- Layer 2: MID BACKGROUND (scattered small phrases as texture) ---
for _ in range(120):
    x = random.randint(-80, W)
    y = random.randint(-30, H)
    size = random.choice([11, 13, 15, 17])
    draw_rotated_text(img, (x, y), random.choice(config["bg_phrases"]), helvetica(size), MUTED, random.uniform(-40, 40))
    draw = ImageDraw.Draw(img)

# --- Layer 3: SCATTER DATA (one per zone, readable) ---
zones = [
    (50, 90), (1250, 120), (120, 700), (1350, 680), (1400, 380),
]
angles = [-14, 10, -20, 7, -5]

for i, item in enumerate(config["scatter_data"]):
    if i >= len(zones):
        break
    x, y = zones[i]
    angle = angles[i]
    # Scale font size by importance (first items larger)
    label_size = max(24, 36 - i * 2)
    value_size = max(38, 52 - i * 2)

    draw_rotated_text(img, (x, y), item["label"], druk_text_med(label_size), GRAY, angle)
    draw = ImageDraw.Draw(img)
    draw_rotated_text(img, (x + 15, y + label_size + 8), item["value"], druk_heavy(value_size), OFF_WHITE, angle + random.uniform(-4, 4))
    draw = ImageDraw.Draw(img)

# --- Layer 4: HERO PHRASE (accent color, minimal rotation) ---
draw_rotated_text(img, (320, 240), config["hero_phrase"], druk_super(170), ACCENT, random.uniform(-3, 3))
draw = ImageDraw.Draw(img)

# --- Layer 5: HERO NUMBER (largest element, near-center) ---
draw_rotated_text(img, (280, 420), config["hero_number"], druk_wide(230), OFF_WHITE, random.uniform(-2, 2))
draw = ImageDraw.Draw(img)

# --- Layer 6: ACCENT WORD (conflicting angle near hero) ---
if config.get("accent_word"):
    draw_rotated_text(img, (820, 360), config["accent_word"], druk_heavy(40), ACCENT, 15)
    draw = ImageDraw.Draw(img)

# --- Layer 7: GROUNDING BODY TEXT (calm Helvetica, bottom-left) ---
draw = ImageDraw.Draw(img)
draw.line([(60, H - 130), (700, H - 130)], fill=MUTED + (255,), width=1)
body_font = helvetica_light(24)
for j, line in enumerate(config["body_text"]):
    draw.text((60, H - 110 + j * 30), line, fill=GRAY + (255,), font=body_font)

# --- Save ---
img.convert('RGB').save('/tmp/carson_visual.png', quality=95)
print(f"Saved: /tmp/carson_visual.png ({W}x{H})")
```

## Key Rules

1. **Conflict is the point.** Mix typefaces, sizes, angles. If it looks harmonious, you're doing it wrong.
2. **One accent color screams.** Everything else is muted. The accent IS the finding.
3. **Rotation range: -25 to +25 degrees.** Beyond that looks like a bug, not a choice.
4. **Hero gets minimal rotation (-3 to +3).** Readable. Chaos surrounds it, not obscures it.
5. **Three background layers.** Deep (barely visible, 180pt+), mid (texture, 11-17pt), foreground (readable).
6. **Body text is the anchor.** One block of calm Helvetica Light at the bottom grounds everything.
7. **Use for "wait, what?" moments only.** If the finding is straightforward, use Vignelli or Bass.
