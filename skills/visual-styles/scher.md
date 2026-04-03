# Paula Scher Style

Bold typographic data visualization inspired by Paula Scher's poster and identity work. Typography IS the design -- no charts, no icons, just massive numbers, dense text, and saturated color fields.

## Signature Elements

- **Type as image.** Numbers and words fill the frame. Text is not labeling a visual -- text IS the visual.
- **Dense composition.** Fill every pixel. Background text, overlapping phrases, color blocking. No breathing room.
- **High contrast color blocking.** Bright yellow against black. Red accents that punch through. Split fields of solid color.
- **Druk typeface family.** The signature face. Wide Heavy for hero numbers, Heavy for titles, Text for labels.

## When to Use

- Post contains multiple data points (3+ numbers)
- Contrast or comparison data (before/after, expected vs actual)
- Lists of items with counts
- NOT for single stats (use Bass) or grid dashboards (use Vignelli)

## Data Interface

The agent fills in this config block. The rendering code adapts to whatever data is provided.

```python
# === YOUR DATA (fill this in) ===
config = {
    "title": "DEAD ANTI-PATTERNS",           # Main title (black block, top-left)
    "subtitle": "WHAT CLAUDE SAYS INSTEAD OF THINKING",  # Optional subtitle below title
    "context_stat": "60,254",                 # Top-right stat
    "context_label": "MESSAGES ANALYZED",     # Label for context stat
    "data": [                                 # List of (label, value) tuples -- any length
        ("LET ME", "45,745"),
        ("I CANNOT", "8,234"),
        ("I APOLOGIZE", "3,891"),
        ("AS AN AI", "2,456"),
        ("CERTAINLY", "1,987"),
        ("HOWEVER", "1,654"),
    ],
    "hero_stat": "75.9%",                     # Big center stat (red block)
    "hero_label": "OF ALL MESSAGES CONTAIN DEAD PATTERNS",  # Label under hero
    "punchline": "THE MOST PREDICTABLE AI IN HISTORY",      # Bottom bar text
    "ghost_phrases": ["LET ME", "I CANNOT", "CERTAINLY", "HOWEVER"],  # Background texture
}
# === END DATA ===
```

## Color Palettes

### Palette A: "Public Theater" (contrast/comparison data)
```python
YELLOW = (255, 210, 0)
BLACK = (0, 0, 0)
RED = (220, 30, 30)
DARK_YELLOW = (235, 190, 0)    # Large ghost text
GHOST_YELLOW = (245, 200, 0)   # Small ghost text grid
WHITE = (255, 255, 255)
```

### Palette B: "Overwhelming" (dominance/scale data)
```python
BG = (15, 5, 0)               # Near-black
HERO = (255, 60, 20)           # Vivid orange-red
SECONDARY = (255, 210, 0)      # Yellow
SUPPORT = (255, 255, 255)      # White
GHOST = (55, 15, 5)            # Dark red (background phrases)
```

### Palette C: "Split" (vs/comparison)
Left half uses Palette A, right half uses Palette B, separated by a 4px black divider.

## Layout Patterns

### Pattern 1: Data List (Palette A)
For listing multiple data points in two columns.

```
+--[BLACK TITLE BLOCK]--------[CONTEXT STAT]--+
|  subtitle text               LABEL           |
|                                              |
|  ITEM 1 -------- COUNT    ITEM 5 --- COUNT  |
|  ITEM 2 -------- COUNT    ITEM 6 --- COUNT  |
|  ITEM 3 -------- COUNT    ITEM 7 --- COUNT  |
|                                              |
|         [===== RED HERO STAT BLOCK =====]    |
|         [===== hero label below        =====]|
|                                              |
|  [========= BLACK PUNCHLINE BAR =========]   |
+----------------------------------------------+
```

### Pattern 2: Hero Stat (Palette B)
For one dominant number on dark background.

### Pattern 3: Split Comparison (Palette C)
For side-by-side contrast. Each half self-contained.

## Fonts

```python
import os
from PIL import ImageFont

druk_heavy = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/Druk-Heavy-Trial.otf"), s)
druk_wide = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukWide-Heavy-Trial.otf"), s)
druk_text = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukText-Heavy-Trial.otf"), s)
druk_text_bold = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukText-Bold-Trial.otf"), s)
druk_super = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/Druk-Super-Trial.otf"), s)
```

Sizing guide:
- Hero numbers: DrukWide-Heavy at 200-300pt
- Titles: Druk-Heavy at 72-90pt
- Data labels: DrukText-Heavy at 28-36pt
- Data values: DrukWide-Heavy at 32-40pt
- Ghost text (large scattered): Druk-Super at 140-200pt
- Ghost text (small grid): DrukText-Bold at 12-14pt

## Production Script Template

```python
from PIL import Image, ImageDraw, ImageFont
import os, random

# === YOUR DATA (fill this in) ===
config = {
    "title": "YOUR TITLE",
    "subtitle": "YOUR SUBTITLE",
    "context_stat": "10,000",
    "context_label": "THINGS COUNTED",
    "data": [
        ("ITEM A", "5,000"),
        ("ITEM B", "3,000"),
        ("ITEM C", "1,500"),
        ("ITEM D", "500"),
    ],
    "hero_stat": "85%",
    "hero_label": "OF ALL THINGS ARE ITEM A",
    "punchline": "YOUR BOLD TAKEAWAY HERE",
    "ghost_phrases": ["ITEM A", "ITEM B", "ITEM C"],
}
# === END DATA ===

W, H = 1800, 1012
random.seed(42)

druk_heavy = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/Druk-Heavy-Trial.otf"), s)
druk_wide = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukWide-Heavy-Trial.otf"), s)
druk_text = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukText-Heavy-Trial.otf"), s)
druk_text_bold = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/DrukText-Bold-Trial.otf"), s)
druk_super = lambda s: ImageFont.truetype(os.path.expanduser("~/Library/Fonts/Druk-Super-Trial.otf"), s)
helvetica_bold = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=1)

# Druk trial fonts are missing %, $, + glyphs -- fall back to Helvetica for those
BROKEN_IN_DRUK = set('%$+')
def draw_mixed_text(draw, pos, text, druk_font, helv_font, color):
    x, y = pos
    for c in text:
        f = helv_font if c in BROKEN_IN_DRUK else druk_font
        draw.text((x, y), c, fill=color, font=f)
        x += int(draw.textlength(c, font=f))
def mixed_text_width(draw, text, druk_font, helv_font):
    return sum(int(draw.textlength(c, font=(helv_font if c in BROKEN_IN_DRUK else druk_font))) for c in text)

YELLOW = (255, 210, 0)
BLACK = (0, 0, 0)
RED = (220, 30, 30)
DARK_YELLOW = (235, 190, 0)
WHITE = (255, 255, 255)

img = Image.new('RGB', (W, H), YELLOW)
draw = ImageDraw.Draw(img)

# --- 1. GHOST TEXT: two layers (large scattered + small grid) ---
# Large ghost words scattered diagonally -- fills canvas with texture
ghost_large = druk_super(160)
for i in range(12):
    x = random.randint(-200, W - 100)
    y = random.randint(-40, H - 100)
    draw.text((x, y), random.choice(config["ghost_phrases"]), fill=DARK_YELLOW, font=ghost_large)

# Small ghost text grid filling every remaining pixel
ghost_small = druk_text_bold(13)
y = 0
while y < H:
    x = 0
    while x < W:
        phrase = random.choice(config["ghost_phrases"])
        draw.text((x, y), phrase, fill=(245, 200, 0), font=ghost_small)
        bbox = ghost_small.getbbox(phrase)
        x += bbox[2] - bbox[0] + 12
    y += 16

# --- 2. TITLE BLOCK: black rectangle, flush top-left ---
title_font = druk_heavy(78)
title_bbox = title_font.getbbox(config["title"])
title_w = title_bbox[2] - title_bbox[0] + 50
title_h = title_bbox[3] - title_bbox[1] + 36
draw.rectangle([0, 0, title_w, title_h + 8], fill=BLACK)
draw.text((25, 6), config["title"], fill=YELLOW, font=title_font)

# Subtitle under title block
if config.get("subtitle"):
    sub_font = druk_text(22)
    draw.text((25, title_h + 18), config["subtitle"], fill=BLACK, font=sub_font)

# --- 3. CONTEXT STAT: top-right ---
stat_font = druk_wide(90)
stat_bbox = stat_font.getbbox(config["context_stat"])
stat_w = stat_bbox[2] - stat_bbox[0]
draw.text((W - stat_w - 60, 8), config["context_stat"], fill=BLACK, font=stat_font)
label_font = druk_text(26)
draw.text((W - stat_w - 60, 92), config["context_label"], fill=BLACK, font=label_font)

# --- 4. DATA COLUMNS: auto-layout into 2 columns ---
data = config["data"]
n = len(data)
cols = 2 if n > 4 else 1
rows_per_col = (n + cols - 1) // cols

label_font = druk_text(30)
value_font = druk_wide(34)
y_start = 160
# Adaptive row height: fit data between title and hero stat
data_zone_h = 380  # space available for data
row_h = min(62, data_zone_h // max(rows_per_col, 1))

for i, (label, value) in enumerate(data):
    col = i // rows_per_col
    row = i % rows_per_col
    x_base = 60 + col * 870
    y = y_start + row * row_h

    # Label
    draw.text((x_base, y), label, fill=BLACK, font=label_font)

    # Red strikethrough through label
    lbbox = label_font.getbbox(label)
    line_y = y + (lbbox[3] - lbbox[1]) // 2 + 2
    draw.line([(x_base - 4, line_y), (x_base + lbbox[2] - lbbox[0] + 4, line_y)], fill=RED, width=5)

    # Value -- offset right of label (mixed rendering for $, %, +)
    value_helv = helvetica_bold(34)
    vw = mixed_text_width(draw, value, value_font, value_helv)
    draw_mixed_text(draw, (x_base + 440 - vw, y - 2), value, value_font, value_helv, BLACK)

# --- 5. HERO STAT: big red block in center ---
if config.get("hero_stat"):
    big_druk = druk_wide(280)
    big_helv = helvetica_bold(240)
    pct_w = mixed_text_width(draw, config["hero_stat"], big_druk, big_helv)
    pct_h = big_druk.getbbox("0")[3] - big_druk.getbbox("0")[1]  # use digit for height ref
    pct_x = (W - pct_w) // 2
    pct_y = 560
    draw.rectangle([pct_x - 60, pct_y - 10, pct_x + pct_w + 60, pct_y + pct_h + 20], fill=RED)
    draw_mixed_text(draw, (pct_x, pct_y), config["hero_stat"], big_druk, big_helv, WHITE)

    # Label under hero
    if config.get("hero_label"):
        under_font = druk_text(36)
        under_bbox = under_font.getbbox(config["hero_label"])
        under_w = under_bbox[2] - under_bbox[0]
        draw.text(((W - under_w) // 2, pct_y + pct_h + 30), config["hero_label"], fill=BLACK, font=under_font)

# --- 6. PUNCHLINE BAR: full-width black bar at bottom ---
bar_y = H - 90
draw.rectangle([0, bar_y, W, H], fill=BLACK)
punch_font = druk_heavy(48)
punch_bbox = punch_font.getbbox(config["punchline"])
punch_w = punch_bbox[2] - punch_bbox[0]
draw.text(((W - punch_w) // 2, bar_y + 18), config["punchline"], fill=YELLOW, font=punch_font)

img.save('/tmp/scher_visual.png', quality=95)
print(f"Saved: /tmp/scher_visual.png ({W}x{H})")
```

## Key Rules

1. Numbers in DrukWide-Heavy at 80-300pt. They DOMINATE.
2. Labels in DrukText-Heavy at 24-36pt. Subordinate to numbers.
3. TWO layers of ghost text: large scattered (Druk-Super 140-200pt) AND small grid (DrukText-Bold 12-14pt). Both required.
4. Red strikethrough = 5px line through labels.
5. Title blocks: solid black rectangle, text in yellow.
6. Fill the canvas edge to edge. If there's empty space, add more ghost text.
7. Ghost phrases should be contextually relevant to the topic.
8. Punchline bar: full-width black, bold takeaway in yellow. This is the scroll-stopper.
