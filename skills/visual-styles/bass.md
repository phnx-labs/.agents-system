# Saul Bass Style

Minimalist geometric data visualization inspired by Saul Bass's title sequences and poster work. One iconic shape. One color accent. Maximum impact from maximum restraint.

## Signature Elements

- **One geometric shape dominates.** A circle, spiral, hand, silhouette, angular cutout. The shape IS the poster.
- **Vast solid-color fields.** 70%+ of the canvas is a single flat color. The shape punches through it.
- **Minimal text.** Title stack on one side, number in or near the shape. Nothing else.
- **Orange/black/white palette.** Occasionally red. Never more than 3 colors total.
- **Asymmetric composition.** Shape off-center creates tension. Text on the opposite side balances.

## When to Use

- Post has ONE dominant number or KPI
- Milestone announcement ("we hit X")
- Single surprising stat
- NOT for multi-stat comparisons (use Scher) or grid data (use Vignelli)

## Data Interface

```python
# === YOUR DATA (fill this in) ===
config = {
    "number": "45,745",                # The hero number (inside the shape)
    "label_stack": [                    # Text stack on the opposite side of the shape
        ("TIMES", "small"),            # (text, size): "small", "large", or "light"
        ("CLAUDE", "large"),
        ("SAID", "large"),
    ],
    "phrase": '"let me"',              # Key phrase (light/italic weight)
    "context": "IN 60,254 MESSAGES",   # Context line below rule
    "secondary_stat": "75.9%",         # Optional secondary stat
    "secondary_label": "OF ALL MESSAGES",  # Label for secondary stat
    "shape": "circle",                 # "circle", "ring", "triangle", "diagonal"
    "layout": "shape-left",            # "shape-left" or "shape-right" or "shape-center"
}
# === END DATA ===
```

## Color Palette

```python
# Primary palette
ORANGE = (232, 93, 38)
DARK_ORANGE = (190, 70, 25)    # Shadow/depth
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)

# Dark variant (swap bg and shape colors)
# BG = BLACK, SHAPE = ORANGE, TEXT = WHITE

# Minimal variant
# BG = (245, 240, 230), SHAPE = BLACK, ACCENT = ORANGE
```

## Layout Patterns

### Pattern 1: Shape Left + Text Right (default)
The shape pushes against the left side, text stacks on the right.

```
+-----------------------------------------------+
|                                                |
|                         SMALL LABEL            |
|     +--------+          LARGE TEXT             |
|    /          \         LARGE TEXT             |
|   |   NUMBER   |                               |
|   |            |        "phrase"               |
|    \          /         ________________       |
|     +--------+          context line           |
|                         stat  label            |
|                                                |
+------------------------------------------------+
```

### Pattern 2: Shape Right + Text Left
Mirror of Pattern 1.

### Pattern 3: Shape Center + Text Below
Shape centered, text underneath. For maximum shape dominance.

## Geometric Shape Library

```python
# Circle (with subtle drop shadow)
draw.ellipse([cx-r+8, cy-r+8, cx+r+8, cy+r+8], fill=DARK_ORANGE)  # shadow
draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=BLACK)                  # shape

# Ring (circle with hole)
draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=BLACK)
draw.ellipse([cx-r2, cy-r2, cx+r2, cy+r2], fill=ORANGE)

# Triangle
draw.polygon([(cx, cy-r), (cx-r, cy+r), (cx+r, cy+r)], fill=BLACK)

# Diagonal cut
draw.polygon([(0, H*0.6), (W, H*0.3), (W, H), (0, H)], fill=BLACK)
```

## Fonts

```python
from PIL import ImageFont

helvetica_bold = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=1)
helvetica = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=0)
helvetica_light = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=2)
```

Size map for label_stack:
- `"small"` = Helvetica Bold 28pt
- `"large"` = Helvetica Bold 72pt
- `"light"` = Helvetica Light 56pt

## Production Script Template

```python
from PIL import Image, ImageDraw, ImageFont
import os, math

# === YOUR DATA (fill this in) ===
config = {
    "number": "45,745",
    "label_stack": [
        ("TIMES", "small"),
        ("CLAUDE", "large"),
        ("SAID", "large"),
    ],
    "phrase": '"let me"',
    "context": "IN 60,254 MESSAGES",
    "secondary_stat": "75.9%",
    "secondary_label": "OF ALL MESSAGES",
    "shape": "circle",
    "layout": "shape-left",
}
# === END DATA ===

W, H = 1800, 1012
ORANGE = (232, 93, 38)
DARK_ORANGE = (190, 70, 25)
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)

font_map = {
    "small": lambda: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 28, index=1),
    "large": lambda: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 72, index=1),
    "light": lambda: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 56, index=2),
}
helvetica_bold = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=1)
helvetica = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=0)
helvetica_light = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=2)

img = Image.new('RGB', (W, H), ORANGE)
draw = ImageDraw.Draw(img)

# --- Shape placement (off-center for tension) ---
if config["layout"] == "shape-left":
    cx, cy = int(W * 0.42), int(H * 0.52)
    text_x = int(W * 0.72)
elif config["layout"] == "shape-right":
    cx, cy = int(W * 0.58), int(H * 0.52)
    text_x = int(W * 0.08)
else:  # shape-center
    cx, cy = W // 2, int(H * 0.45)
    text_x = W // 2  # text below, centered

r = 340  # shape radius -- large, dominant

# --- Draw shape ---
if config["shape"] == "circle":
    draw.ellipse([cx-r+8, cy-r+8, cx+r+8, cy+r+8], fill=DARK_ORANGE)
    draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=BLACK)
elif config["shape"] == "ring":
    draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=BLACK)
    r2 = int(r * 0.6)
    draw.ellipse([cx-r2, cy-r2, cx+r2, cy+r2], fill=ORANGE)
elif config["shape"] == "triangle":
    draw.polygon([(cx, cy-r), (cx-r, cy+r), (cx+r, cy+r)], fill=BLACK)

# --- Number inside shape ---
num_font = helvetica_bold(200)
num_bbox = num_font.getbbox(config["number"])
nw = num_bbox[2] - num_bbox[0]
nh = num_bbox[3] - num_bbox[1]
draw.text((cx - nw // 2, cy - nh // 2 - 15), config["number"], fill=WHITE, font=num_font)

# --- Text stack (on opposite side) ---
if config["layout"] != "shape-center":
    y_cursor = int(H * 0.25)
    for text, size in config["label_stack"]:
        font = font_map[size]()
        draw.text((text_x, y_cursor), text, fill=WHITE, font=font)
        bbox = font.getbbox(text)
        y_cursor += bbox[3] - bbox[1] + 8

    # Phrase (light weight, slightly indented)
    if config.get("phrase"):
        y_cursor += 10
        draw.text((text_x, y_cursor), config["phrase"], fill=WHITE, font=helvetica_light(56))
        y_cursor += 70

    # Thin horizontal rule
    draw.line([(text_x, y_cursor), (W - 80, y_cursor)], fill=WHITE, width=2)
    y_cursor += 20

    # Context line
    if config.get("context"):
        draw.text((text_x, y_cursor), config["context"], fill=WHITE, font=helvetica(24))
        y_cursor += 40

    # Secondary stat
    if config.get("secondary_stat"):
        draw.text((text_x, y_cursor), config["secondary_stat"], fill=WHITE, font=helvetica_bold(40))
        if config.get("secondary_label"):
            # Place label next to stat
            stat_bbox = helvetica_bold(40).getbbox(config["secondary_stat"])
            stat_w = stat_bbox[2] - stat_bbox[0]
            draw.text((text_x + stat_w + 15, y_cursor + 12), config["secondary_label"], fill=WHITE, font=helvetica_light(20))

else:
    # Center layout: text below shape
    y_cursor = cy + r + 40
    for text, size in config["label_stack"]:
        font = font_map[size]()
        bbox = font.getbbox(text)
        tw = bbox[2] - bbox[0]
        draw.text(((W - tw) // 2, y_cursor), text, fill=WHITE, font=font)
        y_cursor += bbox[3] - bbox[1] + 8

img.save('/tmp/bass_visual.png', quality=95)
print(f"Saved: /tmp/bass_visual.png ({W}x{H})")
```

## Key Rules

1. **Maximum three colors.** Orange + black + white. If you need a fourth, you've over-designed.
2. **One shape.** Not two shapes. Not a shape with decorations. One bold geometric form.
3. **One number.** If you have multiple data points, use Scher or Vignelli instead.
4. **Asymmetry is power.** Shape off-center, text on the opposite side. Creates visual tension.
5. **No gradients.** Flat color only. Hard edges. Bass never blurred anything.
6. **Drop shadow on shape.** Subtle offset (+8px) in darker shade adds depth without breaking flatness.
7. **Text hierarchy via weight.** Small bold for labels, large bold for emphasis, light for phrases.
