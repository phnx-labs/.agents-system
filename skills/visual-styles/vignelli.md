# Massimo Vignelli Style

Rigorous Swiss-grid data visualization inspired by Massimo Vignelli's systems design. Mathematical spacing, Helvetica only, red/black/white. Data in cells. Order from chaos.

## Signature Elements

- **The grid is sacred.** Every element snaps to a modular grid. No eyeballing. Math determines placement.
- **Helvetica only.** Multiple weights create hierarchy. No other typeface exists.
- **Red/black/white.** Strict 2-3 color maximum. Red is the accent, never the background.
- **Generous margins.** White space is a design element, not wasted space.
- **Rules and dividers.** Thin lines separate data cells. The structure is visible.

## When to Use

- Post has categorized data (3-9 categories with counts)
- Financial or performance data
- Dashboards, rankings, structured comparisons
- Professional/authoritative tone needed
- NOT for single stats (use Bass) or chaotic/surprising data (use Carson)

## Data Interface

```python
# === YOUR DATA (fill this in) ===
config = {
    "title_line1": "ANTI-PATTERN",             # First line of title (black)
    "title_line2": "CATEGORIES",               # Second line of title (red) -- optional
    "context_label": "60,254 MESSAGES ANALYZED",  # Top-right context
    "context_stat": "63,547",                  # Top-right stat number
    "context_stat_label": "TOTAL VIOLATIONS",  # Label under context stat
    "categories": [                            # List of category dicts -- any length 1-12
        {"name": "HEDGING", "count": "45,745", "examples": "let me, I think, perhaps, maybe"},
        {"name": "APOLOGIZING", "count": "8,234", "examples": "I apologize, sorry, forgive me"},
        {"name": "DISCLAIMING", "count": "3,891", "examples": "as an AI, I cannot, unable to"},
        {"name": "FILLER", "count": "2,456", "examples": "certainly, indeed, furthermore"},
        {"name": "VERBOSE", "count": "1,987", "examples": "it is worth noting, in order to"},
        {"name": "CORPORATE", "count": "1,234", "examples": "leverage, utilize, facilitate"},
    ],
    "total": 63547,                            # Total for computing percentages (int)
    "source": "Source: Claude conversation analysis, 60,254 messages",  # Footer left
    "takeaway": "75.9% OF MESSAGES CONTAIN VIOLATIONS",  # Footer right (red)
}
# === END DATA ===
```

## Color Palette

```python
RED = (204, 0, 0)
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
GRAY = (130, 130, 130)
LIGHT_GRAY = (246, 246, 246)     # Block backgrounds
RULE_GRAY = (220, 220, 220)     # Internal rules
```

Rules:
- Background is ALWAYS white
- Text is ALWAYS black or gray
- Red is used ONLY for: category names, context stat, takeaway, and title accent line
- Never use red as a background fill

## Layout Patterns

### Pattern 1: Category Blocks (default)
Auto-arranges categories into rows of 3 (or 2 for fewer items).

```
+--[TITLE]-----------------------------[CONTEXT]--+
|  TITLE LINE 1                    context label   |
|  TITLE LINE 2 (red)             STAT NUMBER      |
|  ____________________________________________    |
|                                                  |
|  +----------+  +----------+  +----------+        |
|  |01 NAME %||  |02 NAME %||  |03 NAME %||        |
|  |  COUNT   |  |  COUNT   |  |  COUNT   |        |
|  |  ______  |  |  ______  |  |  ______  |        |
|  |  examples|  |  examples|  |  examples|        |
|  +----------+  +----------+  +----------+        |
|                                                  |
|  source text              TAKEAWAY (red)         |
+--------------------------------------------------+
```

### Pattern 2: Ranking List
For ordered data. Vertical list with rank numbers.

### Pattern 3: Data Table
For structured rows and columns with header.

## Fonts

```python
from PIL import ImageFont

helvetica_bold = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=1)
helvetica = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=0)
helvetica_light = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=2)
```

Weight hierarchy:
- Title: Helvetica Bold, 56-72pt
- Numbers (hero): Helvetica Bold, 80-100pt
- Category names: Helvetica Bold, 20-24pt
- Percentages: Helvetica Bold, 16-18pt
- Examples/footnotes: Helvetica Light, 16-20pt

## Production Script Template

```python
from PIL import Image, ImageDraw, ImageFont
import os

# === YOUR DATA (fill this in) ===
config = {
    "title_line1": "ANTI-PATTERN",
    "title_line2": "CATEGORIES",
    "context_label": "60,254 MESSAGES ANALYZED",
    "context_stat": "63,547",
    "context_stat_label": "TOTAL VIOLATIONS",
    "categories": [
        {"name": "HEDGING", "count": "45,745", "examples": "let me, I think, perhaps, maybe"},
        {"name": "APOLOGIZING", "count": "8,234", "examples": "I apologize, sorry, forgive me"},
        {"name": "DISCLAIMING", "count": "3,891", "examples": "as an AI, I cannot, unable to"},
        {"name": "FILLER", "count": "2,456", "examples": "certainly, indeed, furthermore"},
        {"name": "VERBOSE", "count": "1,987", "examples": "it is worth noting, in order to"},
        {"name": "CORPORATE", "count": "1,234", "examples": "leverage, utilize, facilitate"},
    ],
    "total": 63547,
    "source": "Source: Claude conversation analysis, 60,254 messages",
    "takeaway": "75.9% OF MESSAGES CONTAIN VIOLATIONS",
}
# === END DATA ===

W, H = 1800, 1012
MARGIN = 80

RED = (204, 0, 0)
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
GRAY = (130, 130, 130)
LIGHT_GRAY = (246, 246, 246)
RULE_GRAY = (220, 220, 220)

helvetica_bold = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=1)
helvetica = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=0)
helvetica_light = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=2)

img = Image.new('RGB', (W, H), WHITE)
draw = ImageDraw.Draw(img)

# --- Title ---
draw.text((MARGIN, MARGIN - 10), config["title_line1"], fill=BLACK, font=helvetica_bold(64))
if config.get("title_line2"):
    draw.text((MARGIN, MARGIN + 60), config["title_line2"], fill=RED, font=helvetica_bold(64))

# Rule below title
rule_y = MARGIN + 140
draw.line([(MARGIN, rule_y), (W - MARGIN, rule_y)], fill=BLACK, width=2)

# --- Context stat (top-right) ---
ctx_font = helvetica_light(20)
draw.text((W - MARGIN - 300, MARGIN), config["context_label"], fill=GRAY, font=ctx_font)
draw.text((W - MARGIN - 300, MARGIN + 30), config["context_stat"], fill=RED, font=helvetica_bold(48))
draw.text((W - MARGIN - 300, MARGIN + 82), config["context_stat_label"], fill=GRAY, font=ctx_font)

# --- Category blocks: auto-grid ---
cats = config["categories"]
n = len(cats)
cols = 3 if n >= 3 else max(n, 1)
rows = (n + cols - 1) // cols

gap_x, gap_y = 30, 30
block_w = (W - 2 * MARGIN - (cols - 1) * gap_x) // cols

# Adaptive block height: fill available space
start_y = rule_y + 35
footer_y = H - 70
available_h = footer_y - start_y - 20
block_h = min(290, (available_h - (rows - 1) * gap_y) // rows)

for i, cat in enumerate(cats):
    col = i % cols
    row = i // cols
    bx = MARGIN + col * (block_w + gap_x)
    by = start_y + row * (block_h + gap_y)

    # Block background + left accent bar
    draw.rectangle([bx, by, bx + block_w, by + block_h], fill=LIGHT_GRAY)
    draw.rectangle([bx, by, bx + 4, by + block_h], fill=RED)

    # Rank number
    draw.text((bx + 20, by + 18), f"{i+1:02d}", fill=GRAY, font=helvetica_bold(16))

    # Category name in red
    draw.text((bx + 50, by + 16), cat["name"], fill=RED, font=helvetica_bold(22))

    # Percentage (top-right of block)
    count_int = int(cat["count"].replace(",", ""))
    pct = round(count_int / config["total"] * 100, 1)
    pct_text = f"{pct}%"
    pct_bbox = helvetica_bold(18).getbbox(pct_text)
    draw.text((bx + block_w - (pct_bbox[2] - pct_bbox[0]) - 20, by + 18), pct_text, fill=GRAY, font=helvetica_bold(18))

    # Count -- big number (scale font to fit block width)
    count_size = 96 if len(cat["count"]) <= 6 else 72
    draw.text((bx + 20, by + 55), cat["count"], fill=BLACK, font=helvetica_bold(count_size))

    # Rule above examples
    rule_y_inner = by + block_h - 80
    draw.line([(bx + 20, rule_y_inner), (bx + block_w - 20, rule_y_inner)], fill=RULE_GRAY, width=1)

    # Examples
    if cat.get("examples"):
        draw.text((bx + 20, rule_y_inner + 15), cat["examples"], fill=GRAY, font=helvetica_light(18))

# --- Footer ---
draw.line([(MARGIN, H - 60), (W - MARGIN, H - 60)], fill=BLACK, width=1)
draw.text((MARGIN, H - 48), config["source"], fill=GRAY, font=helvetica_light(16))

# Takeaway (right-aligned, red)
takeaway_bbox = helvetica_bold(16).getbbox(config["takeaway"])
tw = takeaway_bbox[2] - takeaway_bbox[0]
draw.text((W - MARGIN - tw, H - 48), config["takeaway"], fill=RED, font=helvetica_bold(16))

img.save('/tmp/vignelli_visual.png', quality=95)
print(f"Saved: /tmp/vignelli_visual.png ({W}x{H})")
```

## Key Rules

1. **Grid or nothing.** Every element aligns to columns. No eyeballing. Use math.
2. **Helvetica only.** If you reach for another font, stop. Adjust weight or size instead.
3. **Maximum 3 colors.** White background + black text + red accent.
4. **Red accent bars.** 4px left border on each block. Red for category names and key stats.
5. **Margins are sacred.** 80px minimum on all sides. Content never touches the edge.
6. **Adaptive grid.** 3 columns for 3+ items, 2 for 2, 1 for 1. Block height scales to fill space.
7. **Percentages in every block.** Auto-computed from count/total. Shows proportion at a glance.
8. **Footer anchors the bottom.** Source left, takeaway right in red. Thin rule above.
