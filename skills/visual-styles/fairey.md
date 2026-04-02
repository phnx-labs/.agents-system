# Shepard Fairey Style

Propaganda-poster data visualization inspired by Shepard Fairey's OBEY and Hope campaigns. Bold claims demand attention. Limited palette, high contrast, radiating energy. The viewer doesn't glance -- they obey.

## Signature Elements

- **Propaganda framing.** Bold text bars across the top and bottom. The claim is a command, not a suggestion.
- **Limited palette.** 3-4 colors maximum: dark red, cream, navy, black. Never bright or playful.
- **Radiating patterns.** Sunburst lines or concentric circles emanating from center. Creates urgency.
- **Central icon area.** A portrait, symbol, or number occupies the center. Frame it with decorative borders.
- **ALL CAPS condensed type.** Compressed, heavy, authoritative. Every word hits like a fist.

## Color Palette

```python
# Fairey propaganda palette
DARK_RED = (139, 0, 0)        # Primary (blood red)
CREAM = (245, 230, 200)       # Background / text on dark
NAVY = (27, 43, 75)           # Secondary dark
BLACK = (0, 0, 0)             # Darkest elements
OFF_WHITE = (250, 245, 235)   # Lightest elements

# "Hope" variant
BLUE = (0, 51, 76)
RED = (190, 30, 45)
LIGHT_BLUE = (124, 175, 196)
BEIGE = (252, 227, 166)
```

## Layout Patterns

### Pattern 1: Proclamation
For bold announcements and milestone claims.

```
+-----------------------------------------------+
|  ███████████████████████████████████████████   |
|  ██         TOP TEXT BAR                  ██   |
|  ███████████████████████████████████████████   |
|                                                |
|          ╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱                |
|        ╱╱╱╱  [RADIATING     ╱╱╱╱              |
|       ╱╱╱╱╱   SUNBURST     ╱╱╱╱╱              |
|        ╱╱╱╱   BEHIND      ╱╱╱╱                |
|          ╱╱╱╱  NUMBER   ╱╱╱╱                   |
|            ╱╱╱╱╱╱╱╱╱╱╱╱╱                      |
|               75.9%                            |
|                                                |
|  ███████████████████████████████████████████   |
|  ██       BOTTOM TEXT BAR                ██   |
|  ███████████████████████████████████████████   |
+------------------------------------------------+
```

- Decorative border (double lines or stars) around entire canvas
- Dark red text bars top and bottom with cream text
- Radiating sunburst lines from center point
- Hero number/stat centered over sunburst
- Navy or black background behind sunburst

### Pattern 2: Portrait Frame
For when using Higgsfield-generated editorial imagery as center.

```
+--[BORDER]-------------------------------------+
|  ████████ CLAIM TEXT HERE ████████████████████ |
|                                                |
|  +--[INNER BORDER]-------------------------+  |
|  |                                          |  |
|  |          [HIGGSFIELD IMAGE              |  |
|  |           OR SOLID COLOR                |  |
|  |           WITH ICON]                    |  |
|  |                                          |  |
|  +------------------------------------------+  |
|                                                |
|  ████████ SUPPORTING STAT ███████████████████ |
|                                                |
|           SMALL DETAIL TEXT                    |
+------------------------------------------------+
```

- Outer decorative border (3-5px red on cream)
- Top bar: main claim in ALL CAPS condensed
- Center area: Higgsfield-generated editorial image or solid fill with large icon
- Bottom bar: supporting statistic
- Footer: small detail text

### Pattern 3: Star Banner
For celebratory/milestone announcements.

```
+-----------------------------------------------+
|  ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★  |
|                                                |
|         ████████████████████████               |
|         ██                    ██               |
|         ██    THE NUMBER      ██               |
|         ██                    ██               |
|         ████████████████████████               |
|                                                |
|           LABEL GOES HERE                      |
|                                                |
|  ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★  |
+------------------------------------------------+
```

## Drawing Utilities

### Sunburst Pattern
```python
import math

def draw_sunburst(draw, cx, cy, r_inner, r_outer, num_rays, color):
    """Draw radiating lines from center point."""
    for i in range(num_rays):
        angle = 2 * math.pi * i / num_rays
        x1 = cx + r_inner * math.cos(angle)
        y1 = cy + r_inner * math.sin(angle)
        x2 = cx + r_outer * math.cos(angle)
        y2 = cy + r_outer * math.sin(angle)
        draw.line([(x1, y1), (x2, y2)], fill=color, width=3)
```

### Decorative Border
```python
def draw_border(draw, W, H, color, thickness=4, inset=20):
    """Double-line decorative border."""
    # Outer
    draw.rectangle([inset, inset, W-inset, H-inset], outline=color, width=thickness)
    # Inner
    gap = thickness + 6
    draw.rectangle([inset+gap, inset+gap, W-inset-gap, H-inset-gap], outline=color, width=2)
```

### Star Row
```python
def draw_star_row(draw, y, W, color, star_size=12, spacing=40, margin=60):
    """Row of stars across the width."""
    x = margin
    while x < W - margin:
        # Simple 5-pointed star using polygon
        points = []
        for i in range(10):
            angle = math.pi / 2 + 2 * math.pi * i / 10
            r = star_size if i % 2 == 0 else star_size * 0.4
            points.append((x + r * math.cos(angle), y + r * math.sin(angle)))
        draw.polygon(points, fill=color)
        x += spacing
```

### Text Bar
```python
def draw_text_bar(draw, y, W, text, font, bar_color, text_color, height=70, margin=40):
    """Solid color bar with centered text."""
    draw.rectangle([margin, y, W - margin, y + height], fill=bar_color)
    bbox = font.getbbox(text)
    tw = bbox[2] - bbox[0]
    tx = (W - tw) // 2
    draw.text((tx, y + (height - (bbox[3] - bbox[1])) // 2), text, fill=text_color, font=font)
```

## Fonts

```python
from PIL import ImageFont
import os

# Druk Condensed for maximum Fairey energy (ALL CAPS, tight)
druk_cond = ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukCond-Super-Trial.otf"), 72)
druk_xcond = ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukXCond-Super-Trial.otf"), 80)
druk_xxcond = ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukXXCond-Super-Trial.otf"), 96)

# Helvetica Bold for supporting text
helvetica_bold = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 36, index=1)
```

Weight usage:
- Text bars (main claim): DrukXCond-Super or DrukXXCond-Super at 60-96pt
- Hero number: DrukCond-Super at 120-200pt
- Supporting labels: Helvetica Bold at 28-40pt
- Detail text: Helvetica Regular at 20-28pt

## Higgsfield Integration

For Pattern 2 (Portrait Frame), generate an editorial background image using Higgsfield:

```
Prompt pattern: "editorial portrait photograph, dramatic lighting, [subject description],
muted color palette in red cream and navy tones, high contrast, studio lighting,
no text, no watermark"
```

Then composite the Higgsfield output into the center frame using PIL:
```python
from PIL import Image

# Load and resize Higgsfield output to fit center area
bg_img = Image.open("/tmp/higgsfield_output.png")
center_w, center_h = 800, 500  # adjust to frame
bg_img = bg_img.resize((center_w, center_h), Image.LANCZOS)

# Paste into main canvas
cx = (W - center_w) // 2
cy = (H - center_h) // 2
img.paste(bg_img, (cx, cy))
```

If no Higgsfield image is needed, fill the center area with a solid navy or dark red field and place the number/icon there.

## Script Template

```python
from PIL import Image, ImageDraw, ImageFont
import os, math

# --- Config ---
W, H = 1800, 1012

DARK_RED = (139, 0, 0)
CREAM = (245, 230, 200)
NAVY = (27, 43, 75)
BLACK = (0, 0, 0)

druk_cond = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukCond-Super-Trial.otf"), s)
druk_xcond = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukXCond-Super-Trial.otf"), s)
helvetica_bold = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=1)

img = Image.new('RGB', (W, H), CREAM)
draw = ImageDraw.Draw(img)

# 1. DECORATIVE BORDER
draw.rectangle([20, 20, W-20, H-20], outline=DARK_RED, width=4)
draw.rectangle([30, 30, W-30, H-30], outline=DARK_RED, width=2)

# 2. TOP TEXT BAR
bar_font = druk_xcond(64)
bar_text = "YOUR BOLD CLAIM HERE"
draw.rectangle([40, 50, W-40, 130], fill=DARK_RED)
bbox = bar_font.getbbox(bar_text)
tw = bbox[2] - bbox[0]
draw.text(((W - tw) // 2, 55), bar_text, fill=CREAM, font=bar_font)

# 3. SUNBURST (centered)
cx, cy = W // 2, H // 2
for i in range(72):
    angle = 2 * math.pi * i / 72
    x1 = cx + 60 * math.cos(angle)
    y1 = cy + 60 * math.sin(angle)
    x2 = cx + 400 * math.cos(angle)
    y2 = cy + 400 * math.sin(angle)
    draw.line([(x1, y1), (x2, y2)], fill=NAVY, width=2)

# 4. CENTER CIRCLE with number
r = 180
draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=DARK_RED)
num_font = druk_cond(140)
number = "75.9%"
num_bbox = num_font.getbbox(number)
nw = num_bbox[2] - num_bbox[0]
nh = num_bbox[3] - num_bbox[1]
draw.text(((W - nw) // 2, cy - nh // 2 - 10), number, fill=CREAM, font=num_font)

# 5. BOTTOM TEXT BAR
bottom_text = "OF ALL MESSAGES"
draw.rectangle([40, H - 130, W - 40, H - 50], fill=DARK_RED)
bbox = bar_font.getbbox(bottom_text)
tw = bbox[2] - bbox[0]
draw.text(((W - tw) // 2, H - 125), bottom_text, fill=CREAM, font=bar_font)

img.save('/tmp/fairey_visual.png', quality=95)
print(f"Saved: /tmp/fairey_visual.png ({W}x{H})")
```

## Key Rules

1. **ALL CAPS always.** Fairey never whispers. Every word is a command.
2. **3-4 colors maximum.** Dark red + cream + navy + black. No pastels. No brights.
3. **Text bars are mandatory.** Top and bottom bars frame the composition. They are the claim.
4. **Symmetry is power.** Unlike Bass (asymmetric), Fairey is centered and balanced. The viewer faces it head-on.
5. **Decorative borders.** Double-line borders or star rows at edges. The poster is a contained artifact.
6. **Sunburst or radiating lines.** Creates movement and urgency radiating from the center.
7. **No subtlety.** This style is for claims you want to shout. If the content is nuanced, use Vignelli.
