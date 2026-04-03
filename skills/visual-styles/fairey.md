# Shepard Fairey Style

Propaganda-poster data visualization inspired by Shepard Fairey's OBEY and Hope campaigns. Bold claims demand attention. Limited palette, high contrast, radiating energy. The viewer doesn't glance -- they obey.

## Signature Elements

- **Propaganda framing.** Bold text bars across the top and bottom. The claim is a command, not a suggestion.
- **Limited palette.** 3-4 colors maximum: dark red, cream, navy, black. Never bright or playful.
- **Radiating patterns.** Sunburst lines emanating from center. Creates urgency.
- **Central icon area.** A number, symbol, or portrait occupies the center, framed by decorative borders.
- **ALL CAPS condensed type.** Compressed, heavy, authoritative. Every word hits like a fist.

## When to Use

- Bold announcement or milestone ("we hit X")
- Claims you want to shout ("X% of all Y")
- "Pay attention" posts, provocative findings
- NOT for nuanced data (use Vignelli) or multi-stat comparisons (use Scher)

## Data Interface

```python
# === YOUR DATA (fill this in) ===
config = {
    "top_bar": "THE MACHINES ARE ALREADY TALKING LIKE THIS",  # Top text bar (the claim)
    "hero_stat": "75.9%",                                      # Center number
    "hero_sublabel": "OF ALL MESSAGES",                        # Label inside circle under number
    "bottom_bar": "OBEY YOUR TRAINING DATA",                  # Bottom text bar (the command)
    "footer_left": "60,254 MESSAGES ANALYZED",                 # Small footer left
    "footer_right": "CLAUDE CONVERSATION DATA",                # Small footer right
}
# === END DATA ===
```

## Color Palette

```python
DARK_RED = (139, 0, 0)
CREAM = (245, 230, 200)
NAVY = (27, 43, 75)
BLACK = (10, 5, 0)
```

Rules:
- Background is CREAM
- Text bars are DARK_RED with CREAM text
- Sunburst lines are NAVY
- Center circle is DARK_RED with NAVY outline ring
- Never use bright colors. This palette is muted, authoritative, vintage.

## Layout Pattern

```
+--[DOUBLE BORDER]----------------------------------+
|  [======== DARK RED TOP TEXT BAR ========]         |
|  * * * * * * * * * * * * * * * * * * * *           |
|  ________________________________________________  |
|                                                    |
|              ////  SUNBURST  \\\\                  |
|            ////                \\\\                |
|          [[ NAVY RING ]]                           |
|          [[ [CREAM RING] ]]                        |
|          [[ [  DARK RED  ] ]]                      |
|          [[ [   NUMBER   ] ]]                      |
|          [[ [  SUBLABEL  ] ]]                      |
|          [[ [CREAM RING] ]]                        |
|          [[ NAVY RING ]]                           |
|            \\\\                ////                |
|              \\\\  SUNBURST  ////                  |
|  ________________________________________________  |
|  * * * * * * * * * * * * * * * * * * * *           |
|  [======== DARK RED BOTTOM TEXT BAR ========]      |
|  footer left                    footer right       |
+----------------------------------------------------+
```

## Fonts

```python
import os
from PIL import ImageFont

druk_xcond = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukXCond-Super-Trial.otf"), s)
druk_cond = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukCond-Super-Trial.otf"), s)
helvetica_bold = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=1)
helvetica = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=0)
```

Usage:
- Text bars: DrukXCond-Super at 58-66pt
- Hero number: DrukCond-Super at 160-200pt
- Sublabel: Helvetica Bold at 20-24pt
- Footer: Helvetica Regular at 14pt

## Drawing Utilities

```python
import math

def draw_star(draw, cx, cy, r, color):
    """5-pointed star."""
    points = []
    for i in range(10):
        angle = -math.pi/2 + 2 * math.pi * i / 10
        radius = r if i % 2 == 0 else r * 0.38
        points.append((cx + radius * math.cos(angle), cy + radius * math.sin(angle)))
    draw.polygon(points, fill=color)

def draw_star_row(draw, y, W, color, r=11, spacing=32, margin=60):
    """Row of stars across the width."""
    sx = margin
    while sx < W - margin:
        draw_star(draw, sx, y, r, color)
        sx += spacing

def draw_text_bar(draw, y, W, text, font, bar_color, text_color, height=80, margin=44):
    """Solid color bar with centered text."""
    draw.rectangle([margin, y, W - margin, y + height], fill=bar_color)
    bbox = font.getbbox(text)
    tw = bbox[2] - bbox[0]
    draw.text(((W - tw) // 2, y + 4), text, fill=text_color, font=font)
```

## Production Script Template

```python
from PIL import Image, ImageDraw, ImageFont
import os, math

# === YOUR DATA (fill this in) ===
config = {
    "top_bar": "THE MACHINES ARE ALREADY TALKING LIKE THIS",
    "hero_stat": "75.9%",
    "hero_sublabel": "OF ALL MESSAGES",
    "bottom_bar": "OBEY YOUR TRAINING DATA",
    "footer_left": "60,254 MESSAGES ANALYZED",
    "footer_right": "CLAUDE CONVERSATION DATA",
}
# === END DATA ===

W, H = 1800, 1012
DARK_RED = (139, 0, 0)
CREAM = (245, 230, 200)
NAVY = (27, 43, 75)

druk_xcond = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukXCond-Super-Trial.otf"), s)
druk_cond = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukCond-Super-Trial.otf"), s)
helvetica_bold = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=1)
helvetica = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=0)

def draw_star(draw, cx, cy, r, color):
    points = []
    for i in range(10):
        angle = -math.pi/2 + 2 * math.pi * i / 10
        radius = r if i % 2 == 0 else r * 0.38
        points.append((cx + radius * math.cos(angle), cy + radius * math.sin(angle)))
    draw.polygon(points, fill=color)

# Druk trial fonts are missing %, $, + glyphs -- fall back to Helvetica
BROKEN_IN_DRUK = set('%$+')
def draw_mixed_text(draw, pos, text, druk_font, helv_font, color):
    x, y = pos
    for c in text:
        f = helv_font if c in BROKEN_IN_DRUK else druk_font
        draw.text((x, y), c, fill=color, font=f)
        x += int(draw.textlength(c, font=f))
def mixed_text_width(draw, text, druk_font, helv_font):
    return sum(int(draw.textlength(c, font=(helv_font if c in BROKEN_IN_DRUK else druk_font))) for c in text)

img = Image.new('RGB', (W, H), CREAM)
draw = ImageDraw.Draw(img)

# --- 1. Decorative double border + corner ornaments ---
draw.rectangle([16, 16, W-16, H-16], outline=DARK_RED, width=5)
draw.rectangle([30, 30, W-30, H-30], outline=DARK_RED, width=2)
for cx, cy in [(16, 16), (W-16, 16), (16, H-16), (W-16, H-16)]:
    draw.rectangle([cx-10, cy-10, cx+10, cy+10], fill=DARK_RED)

# --- 2. Top text bar ---
bar_h = 80
bar_font = druk_xcond(62)
draw.rectangle([44, 48, W-44, 48 + bar_h], fill=DARK_RED)
bbox = bar_font.getbbox(config["top_bar"])
tw = bbox[2] - bbox[0]
draw.text(((W - tw) // 2, 52), config["top_bar"], fill=CREAM, font=bar_font)

# --- 3. Star row below top bar ---
star_y = 48 + bar_h + 22
sx = 60
while sx < W - 60:
    draw_star(draw, sx, star_y, 11, DARK_RED)
    sx += 32
draw.line([(44, star_y + 18), (W - 44, star_y + 18)], fill=DARK_RED, width=1)

# --- 4. Sunburst (120 rays, alternating thickness) ---
cx, cy = W // 2, H // 2 + 15
for i in range(120):
    angle = 2 * math.pi * i / 120
    x1 = cx + 40 * math.cos(angle)
    y1 = cy + 40 * math.sin(angle)
    x2 = cx + 420 * math.cos(angle)
    y2 = cy + 420 * math.sin(angle)
    draw.line([(x1, y1), (x2, y2)], fill=NAVY, width=(3 if i % 3 == 0 else 2))

# --- 5. Center circle: navy ring + dark red fill + cream inner ring ---
r = 210
draw.ellipse([cx-r-6, cy-r-6, cx+r+6, cy+r+6], fill=NAVY)
draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=DARK_RED)
draw.ellipse([cx-r+12, cy-r+12, cx+r-12, cy+r-12], outline=CREAM, width=2)

# --- 6. Hero number (centered in circle, mixed rendering for %, $, +) ---
for font_size in [180, 160, 140, 120]:
    num_font = druk_cond(font_size)
    helv_font = helvetica_bold(int(font_size * 0.85))
    nw = mixed_text_width(draw, config["hero_stat"], num_font, helv_font)
    if nw < r * 1.6:
        break
nh = num_font.getbbox("0")[3] - num_font.getbbox("0")[1]
draw_mixed_text(draw, ((W - nw) // 2, cy - nh // 2 - 18), config["hero_stat"], num_font, helv_font, CREAM)

# Sublabel inside circle
if config.get("hero_sublabel"):
    sub_font = helvetica_bold(22)
    sub_bbox = sub_font.getbbox(config["hero_sublabel"])
    sw = sub_bbox[2] - sub_bbox[0]
    draw.text(((W - sw) // 2, cy + nh // 2 + 10), config["hero_sublabel"], fill=CREAM, font=sub_font)

# --- 7. Star row above bottom bar ---
star_y2 = H - 48 - bar_h - 22
sx = 60
while sx < W - 60:
    draw_star(draw, sx, star_y2, 11, DARK_RED)
    sx += 32
draw.line([(44, star_y2 - 18), (W - 44, star_y2 - 18)], fill=DARK_RED, width=1)

# --- 8. Bottom text bar ---
draw.rectangle([44, H - 48 - bar_h, W - 44, H - 48], fill=DARK_RED)
bbox = bar_font.getbbox(config["bottom_bar"])
tw = bbox[2] - bbox[0]
draw.text(((W - tw) // 2, H - 48 - bar_h + 4), config["bottom_bar"], fill=CREAM, font=bar_font)

# --- 9. Footer ---
draw.text((52, H - 38), config.get("footer_left", ""), fill=DARK_RED, font=helvetica(14))
if config.get("footer_right"):
    fr_bbox = helvetica(14).getbbox(config["footer_right"])
    draw.text((W - 52 - (fr_bbox[2] - fr_bbox[0]), H - 38), config["footer_right"], fill=DARK_RED, font=helvetica(14))

img.save('/tmp/fairey_visual.png', quality=95)
print(f"Saved: /tmp/fairey_visual.png ({W}x{H})")
```

## Higgsfield Integration (Optional)

For portrait-style visuals, generate an editorial background with Higgsfield and composite into the center area instead of the sunburst/circle:

```
Prompt: "editorial portrait photograph, dramatic lighting, [subject],
muted red cream navy tones, high contrast, studio lighting, no text"
```

Then PIL-paste the Higgsfield output into the center frame.

## Key Rules

1. **ALL CAPS always.** Fairey never whispers. Every word is a command.
2. **3-4 colors maximum.** Dark red + cream + navy + black. No pastels. No brights.
3. **Text bars are mandatory.** Top and bottom. They ARE the claim.
4. **Symmetry is power.** Centered and balanced. The viewer faces it head-on.
5. **Decorative borders and star rows.** The poster is a contained artifact.
6. **Sunburst creates urgency.** Radiating lines from center. 120 rays, alternating thickness.
7. **Auto-size the number.** Try largest font first, reduce until it fits inside the circle.
