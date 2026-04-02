# Saul Bass Style

Minimalist geometric data visualization inspired by Saul Bass's title sequences and poster work. One iconic shape. One color accent. Maximum impact from maximum restraint.

## Signature Elements

- **One geometric shape dominates.** A circle, spiral, hand, silhouette, angular cutout. The shape IS the poster.
- **Vast solid-color fields.** 70%+ of the canvas is a single flat color. The shape punches through it.
- **Minimal text.** Title at top or bottom. One number. Maybe a subtitle. Nothing else.
- **Orange/black/white palette.** Occasionally red. Never more than 3 colors total.
- **Asymmetric composition.** The shape is often off-center, creating tension.

## Color Palette

```python
# Primary palette
BG = (232, 93, 38)           # Signature Bass orange
SHAPE = (0, 0, 0)            # Black (the geometric shape)
TEXT = (255, 255, 255)        # White text on orange
ALT_TEXT = (0, 0, 0)         # Black text on white areas

# Dark variant
BG_DARK = (0, 0, 0)          # Black background
SHAPE_DARK = (232, 93, 38)   # Orange shape on black
TEXT_DARK = (255, 255, 255)   # White text

# Minimal variant
BG_MINIMAL = (245, 240, 230) # Off-white/cream
SHAPE_MINIMAL = (0, 0, 0)    # Black shape
ACCENT = (232, 93, 38)       # Orange accent (number only)
```

## Layout Patterns

### Pattern 1: Central Shape + Number
For single KPI or milestone announcements.

```
+-----------------------------------------------+
|                                                |
|              YOUR TITLE HERE                   |
|                                                |
|                                                |
|                  [LARGE                         |
|                 GEOMETRIC                       |
|                  SHAPE]                         |
|                                                |
|                 45,745                          |
|              subtitle text                     |
|                                                |
+------------------------------------------------+
```

- Solid orange background
- Title in Helvetica Bold, white, centered near top
- Large geometric shape (black) centered, taking 40-50% of canvas height
- Number below shape in Helvetica Bold, large
- Optional subtitle in lighter weight

### Pattern 2: Shape AS Number
The geometric shape contains or frames the number.

```
+-----------------------------------------------+
|                                                |
|          +-------------------+                 |
|         /                     \                |
|        |       75.9%           |               |
|        |                       |               |
|         \                     /                |
|          +-------------------+                 |
|                                                |
|          OF ALL MESSAGES                       |
+------------------------------------------------+
```

- Number sits inside the shape (circle, rectangle, angular form)
- Shape acts as a frame/container
- Text label below or beside

### Pattern 3: Silhouette/Cutout
The data creates a recognizable silhouette.

```
+-----------------------------------------------+
|  ████                                          |
|  ██████                                        |
|  ████████      TITLE                           |
|  ██████████                                    |
|  ████████████                                  |
|  ██████████████                                |
|  ████████████████   NUMBER                     |
|  ██████████████████                            |
+------------------------------------------------+
```

- A jagged or stepped shape formed by data bars
- But rendered as a solid silhouette, not as a chart
- Title and number positioned in the negative space

## Geometric Shape Library

Use these PIL drawing primitives:

```python
# Circle
draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=SHAPE)

# Ring (circle with hole)
draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=SHAPE)
draw.ellipse([cx-r2, cy-r2, cx+r2, cy+r2], fill=BG)  # punch out center

# Triangle
draw.polygon([(cx, cy-r), (cx-r, cy+r), (cx+r, cy+r)], fill=SHAPE)

# Spiral (approximate with arcs)
import math
points = []
for angle in range(0, 720, 5):
    rad = math.radians(angle)
    radius = 50 + angle * 0.3
    x = cx + radius * math.cos(rad)
    y = cy + radius * math.sin(rad)
    points.append((x, y))
draw.line(points, fill=SHAPE, width=8)

# Angular hand/arm (Bass signature)
draw.polygon([
    (cx-20, cy+200), (cx-60, cy), (cx-30, cy-150),
    (cx+30, cy-150), (cx+60, cy), (cx+20, cy+200)
], fill=SHAPE)

# Diagonal cut (divides canvas)
draw.polygon([(0, H*0.6), (W, H*0.3), (W, H), (0, H)], fill=SHAPE)
```

## Fonts

```python
from PIL import ImageFont

# Helvetica Bold for titles and numbers
helvetica_bold = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 120, index=1)

# Helvetica Regular for subtitles
helvetica = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 48, index=0)

# Helvetica Light for small text
helvetica_light = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 32, index=2)
```

Sizes:
- Hero number: 140-240pt Helvetica Bold
- Title: 48-72pt Helvetica Bold
- Subtitle: 28-40pt Helvetica Regular or Light

## Script Template

```python
from PIL import Image, ImageDraw, ImageFont
import os, math

# --- Config ---
W, H = 1800, 1012

helvetica_bold = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=1)
helvetica = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=0)

# Colors
ORANGE = (232, 93, 38)
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)

img = Image.new('RGB', (W, H), ORANGE)
draw = ImageDraw.Draw(img)

# 1. TITLE (top, centered)
title = "YOUR TITLE"
title_font = helvetica_bold(56)
title_bbox = title_font.getbbox(title)
title_w = title_bbox[2] - title_bbox[0]
draw.text(((W - title_w) // 2, 60), title, fill=WHITE, font=title_font)

# 2. GEOMETRIC SHAPE (centered, dominant)
cx, cy = W // 2, H // 2 - 20
r = 220  # radius

# Circle example
draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=BLACK)

# 3. NUMBER (inside or below shape)
number = "45,745"
num_font = helvetica_bold(160)
num_bbox = num_font.getbbox(number)
num_w = num_bbox[2] - num_bbox[0]
num_h = num_bbox[3] - num_bbox[1]
# Inside circle (white on black)
draw.text(((W - num_w) // 2, cy - num_h // 2), number, fill=WHITE, font=num_font)

# 4. SUBTITLE (below shape)
subtitle = "TIMES MEASURED"
sub_font = helvetica(36)
sub_bbox = sub_font.getbbox(subtitle)
sub_w = sub_bbox[2] - sub_bbox[0]
draw.text(((W - sub_w) // 2, cy + r + 40), subtitle, fill=WHITE, font=sub_font)

img.save('/tmp/bass_visual.png', quality=95)
print(f"Saved: /tmp/bass_visual.png ({W}x{H})")
```

## Key Rules

1. **Maximum three colors.** Orange + black + white. That's it. If you need a fourth, you've over-designed.
2. **One shape.** Not two shapes. Not a shape with decorations. One bold geometric form.
3. **One number.** This style is for single stats. If you have multiple data points, use Scher or Vignelli.
4. **70% negative space.** The power comes from what you DON'T fill. Let the shape breathe.
5. **No gradients.** Flat color only. Hard edges. Bass never blurred anything.
6. **Asymmetry is strength.** Slightly off-center placement creates visual tension. Don't center everything.
