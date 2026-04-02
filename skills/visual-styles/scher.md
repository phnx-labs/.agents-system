# Paula Scher Style

Bold typographic data visualization inspired by Paula Scher's poster and identity work. Typography IS the design -- no charts, no icons, just massive numbers, dense text, and saturated color fields.

## Signature Elements

- **Type as image.** Numbers and words fill the frame. Text is not labeling a visual -- text IS the visual.
- **Dense composition.** Fill every pixel. Background text, overlapping phrases, color blocking. No breathing room.
- **High contrast color blocking.** Bright yellow against black. Red accents that punch through. Split fields of solid color.
- **Druk typeface family.** The signature face. Wide Heavy for hero numbers, Heavy for titles, Text for labels.

## Color Palettes

### Palette A: "Public Theater" (contrast/comparison data)
```python
BG = (255, 210, 0)          # Bright yellow
TEXT_PRIMARY = (0, 0, 0)     # Black
ACCENT = (220, 30, 30)       # Red (strikethroughs, callouts)
GHOST = (240, 195, 0)        # Darker yellow (background text)
TITLE_BG = (0, 0, 0)         # Black rectangle
TITLE_TEXT = (255, 210, 0)   # Yellow on black
```

### Palette B: "Overwhelming" (dominance/scale data)
```python
BG = (15, 5, 0)             # Near-black
HERO = (255, 60, 20)         # Vivid orange-red
SECONDARY = (255, 210, 0)    # Yellow
SUPPORT = (255, 255, 255)    # White
GHOST = (55, 15, 5)          # Dark red (background phrases)
```

### Palette C: "Split" (vs/comparison)
Left half uses Palette A, right half uses Palette B, separated by a 4px black divider.

## Layout Patterns

### Pattern 1: Data List (Palette A)
For listing multiple data points in two columns.

```
+--[BLACK TITLE BLOCK]--------[CONTEXT STAT]--+
|  "DEAD ANTI-PATTERNS"       60,254 MESSAGES  |
|                                               |
|  ITEM 1 -------- COUNT    ITEM 5 ---- COUNT  |
|  ITEM 2 -------- COUNT    ITEM 6 ---- COUNT  |
|  ITEM 3 -------- COUNT    ITEM 7 ---- COUNT  |
|  ITEM 4 -------- COUNT    ITEM 8 ---- COUNT  |
|                                               |
|  (ghost phrases fill all remaining space)     |
|                                               |
|        [RED BLOCK: PUNCHLINE TEXT]            |
+-----------------------------------------------+
```

- Black title block flush to top-left corner
- Context stat (total count) in Druk Wide Heavy, top-right
- Data in two columns, red strikethrough lines through "dead" items
- Ghost phrases (the actual dead words) filling background in slightly darker yellow
- Bottom punchline in red color block

### Pattern 2: Hero Stat (Palette B)
For one dominant number that tells the whole story.

```
+-----------------------------------------------+
|  (phrase repeated in tight grid, dark red)     |
|  "let me" "let me" "let me" "let me" "let me" |
|  "let me" "let me" "let me" "let me" "let me" |
|                                                |
|           45,745                               |
|        TIMES CLAUDE SAID                       |
|           "LET ME"                             |
|                                                |
|         75.9% OF ALL MESSAGES                  |
|  "let me" "let me" "let me" "let me" "let me" |
+------------------------------------------------+
```

- Background: relevant phrase repeated in tight grid (dark red on near-black)
- Massive hero number centered in Druk Wide Heavy, vivid orange-red, 200-300pt
- Context label in white, 40-60pt
- Secondary stat in yellow
- Supporting data in small text at bottom

### Pattern 3: Split Comparison (Palette C)
For side-by-side contrast.

```
+------------------------||------------------------+
| YELLOW BG              || DARK BG                 |
|                        ||                         |
| LEFT DATASET           || RIGHT DATASET           |
| numbers + labels       || numbers + labels        |
|                        ||                         |
| (ghost text fills)     || (ghost text fills)       |
+------------------------||------------------------+
```

Each half is self-contained with its own title, data, and background texture.

## Fonts

```python
import os
from PIL import ImageFont

DRUK_HEAVY = ImageFont.truetype(os.path.expanduser("~/Library/Fonts/Druk-Heavy-Trial.otf"), 120)
DRUK_WIDE_HEAVY = ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukWide-Heavy-Trial.otf"), 200)
DRUK_TEXT_HEAVY = ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukText-Heavy-Trial.otf"), 32)
DRUK_TEXT_BOLD = ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukText-Bold-Trial.otf"), 14)
```

Adjust sizes per element:
- Hero numbers: DrukWide-Heavy at 150-300pt
- Titles/section heads: Druk-Heavy at 80-140pt
- Data labels: DrukText-Heavy at 24-40pt
- Background texture: DrukText-Bold at 10-16pt or Druk-Heavy at 80-200pt for ghost text

## Script Template

```python
from PIL import Image, ImageDraw, ImageFont
import os, random

# --- Config ---
W, H = 1800, 1012

# Fonts (adjust sizes per your data)
druk_heavy = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/Druk-Heavy-Trial.otf"), s)
druk_wide = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukWide-Heavy-Trial.otf"), s)
druk_text = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukText-Heavy-Trial.otf"), s)
druk_text_bold = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukText-Bold-Trial.otf"), s)

img = Image.new('RGB', (W, H), (255, 210, 0))
draw = ImageDraw.Draw(img)

# 1. BACKGROUND TEXTURE LAYER
# Fill canvas with ghost phrases in slightly darker yellow
ghost_font = druk_text_bold(14)
ghost_phrases = ["PHRASE 1", "PHRASE 2", "PHRASE 3"]  # Fill with relevant dead text
y = 0
while y < H:
    x = 0
    while x < W:
        phrase = random.choice(ghost_phrases)
        draw.text((x, y), phrase, fill=(240, 195, 0), font=ghost_font)
        bbox = ghost_font.getbbox(phrase)
        x += bbox[2] - bbox[0] + 20
    y += 18

# 2. TITLE BLOCK
# Black rectangle with yellow text, flush top-left
title_text = "YOUR TITLE HERE"
title_font = druk_heavy(72)
title_bbox = title_font.getbbox(title_text)
title_w = title_bbox[2] - title_bbox[0] + 60
title_h = title_bbox[3] - title_bbox[1] + 40
draw.rectangle([0, 0, title_w, title_h], fill=(0, 0, 0))
draw.text((30, 15), title_text, fill=(255, 210, 0), font=title_font)

# 3. CONTEXT STAT (top-right)
stat_text = "60,254"
stat_font = druk_wide(80)
stat_bbox = stat_font.getbbox(stat_text)
stat_x = W - (stat_bbox[2] - stat_bbox[0]) - 40
draw.text((stat_x, 20), stat_text, fill=(0, 0, 0), font=stat_font)

# 4. DATA COLUMNS
# Left column: items 1-N/2, Right column: items N/2+1-N
data = [("ITEM", "COUNT"), ...]  # Your data here
col_font = druk_text(28)
y_start = title_h + 60
for i, (label, value) in enumerate(data):
    col = 0 if i < len(data) // 2 else 1
    row = i if col == 0 else i - len(data) // 2
    x = 80 + col * (W // 2)
    y = y_start + row * 50
    text = f"{label}  {value}"
    draw.text((x, y), text, fill=(0, 0, 0), font=col_font)
    # Red strikethrough
    text_bbox = col_font.getbbox(label)
    line_y = y + (text_bbox[3] - text_bbox[1]) // 2
    draw.line([(x, line_y), (x + text_bbox[2] - text_bbox[0], line_y)], fill=(220, 30, 30), width=4)

# 5. PUNCHLINE (bottom center, red block)
punch_text = "PUNCHLINE TEXT"
punch_font = druk_heavy(56)
punch_bbox = punch_font.getbbox(punch_text)
punch_w = punch_bbox[2] - punch_bbox[0] + 80
punch_h = punch_bbox[3] - punch_bbox[1] + 40
punch_x = (W - punch_w) // 2
punch_y = H - punch_h - 40
draw.rectangle([punch_x, punch_y, punch_x + punch_w, punch_y + punch_h], fill=(220, 30, 30))
draw.text((punch_x + 40, punch_y + 15), punch_text, fill=(255, 255, 255), font=punch_font)

img.save('/tmp/scher_visual.png', quality=95)
print(f"Saved: /tmp/scher_visual.png ({W}x{H})")
```

## Key Rules

1. Numbers in DrukWide-Heavy at 80-300pt. They DOMINATE.
2. Labels in DrukText-Heavy at 24-32pt. Subordinate to numbers.
3. Background text: DrukText-Bold at 10-15pt in tight grid, or Druk-Heavy at 100-200pt scattered as ghost text.
4. Red strikethrough = 4-5px line through "dead" data.
5. Title blocks: solid black rectangle, text in yellow or white.
6. Fill the canvas edge to edge. If there's empty space, add more background text.
7. Ghost text should be contextually relevant (the actual dead phrases, repeated stats, etc.).
