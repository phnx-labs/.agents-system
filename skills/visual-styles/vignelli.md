# Massimo Vignelli Style

Rigorous Swiss-grid data visualization inspired by Massimo Vignelli's systems design. Mathematical spacing, Helvetica only, red/black/white. Data in cells. Order from chaos.

## Signature Elements

- **The grid is sacred.** Every element snaps to a modular grid. No eyeballing. Math determines placement.
- **Helvetica only.** Multiple weights create hierarchy. No other typeface exists.
- **Red/black/white.** Strict 2-3 color maximum. Red is the accent, never the background.
- **Generous margins.** White space is a design element, not wasted space.
- **Rules and dividers.** Thin lines separate data cells. The structure is visible.

## Color Palette

```python
# Strict Vignelli palette
RED = (204, 0, 0)            # Accent, headers, emphasis
BLACK = (0, 0, 0)            # Primary text, rules
WHITE = (255, 255, 255)      # Background
LIGHT_GRAY = (240, 240, 240) # Alternating row fill (subtle)
DARK_GRAY = (60, 60, 60)     # Secondary text
```

Rules:
- Background is ALWAYS white
- Text is ALWAYS black or dark gray
- Red is used ONLY for: headers, key numbers, accent bars, or one highlighted cell
- Never use red as a background fill for large areas

## Grid System

```python
# Standard Vignelli grid for 1800x1012
MARGIN = 80                   # All four sides
COLS = 6                      # 6-column grid
GUTTER = 24                   # Between columns
COL_W = (1800 - 2 * MARGIN - (COLS - 1) * GUTTER) // COLS  # ~254px each

# Row heights
ROW_H = 60                    # Standard data row
HEADER_H = 80                 # Header row
SECTION_GAP = 40              # Between sections

# Grid math helper
def col_x(col, span=1):
    """X position for column start. span=2 means spanning 2 columns."""
    x = MARGIN + col * (COL_W + GUTTER)
    return x

def col_w(span):
    """Width spanning N columns (includes internal gutters)."""
    return span * COL_W + (span - 1) * GUTTER
```

## Layout Patterns

### Pattern 1: Data Table
Structured data in rows and columns with header.

```
+--[MARGIN]------------------------------------------[MARGIN]--+
|                                                               |
|  TITLE                                          SUBTITLE      |
|  ____________________________________________________________ |
|  COL 1        COL 2        COL 3        COL 4                |
|  ____________________________________________________________ |
|  Data         Data         Data         Data                  |
|  ____________________________________________________________ |
|  Data         Data         Data         Data (RED)            |
|  ____________________________________________________________ |
|  Data         Data         Data         Data                  |
|  ____________________________________________________________ |
|                                                               |
|  FOOTER NOTE                                    SOURCE        |
+---------------------------------------------------------------+
```

- Title top-left in Helvetica Bold, 48-64pt
- Thin black rules (1-2px) between rows
- Header row in Helvetica Bold, data in Regular
- One highlighted value in red
- Footer/source bottom-right in small text

### Pattern 2: Category Blocks
Data organized in grid modules, each a self-contained cell.

```
+---------------------------------------------------------------+
|                                                               |
|  TITLE                                                        |
|                                                               |
|  +----------+  +----------+  +----------+                    |
|  | CATEGORY |  | CATEGORY |  | CATEGORY |                    |
|  |          |  |          |  |          |                    |
|  |   123    |  |   456    |  |   789    |                    |
|  |  label   |  |  label   |  |  label   |                    |
|  +----------+  +----------+  +----------+                    |
|                                                               |
|  +----------+  +----------+  +----------+                    |
|  | CATEGORY |  | CATEGORY |  | CATEGORY |                    |
|  |          |  |          |  |          |                    |
|  |   012    |  |   345    |  |   678    |                    |
|  |  label   |  |  label   |  |  label   |                    |
|  +----------+  +----------+  +----------+                    |
|                                                               |
+---------------------------------------------------------------+
```

- 2x3 or 3x3 grid of category blocks
- Each block has: category name (red, small caps), number (black, large), label (gray, small)
- Blocks separated by gutters, aligned to grid
- Thin rule borders or subtle gray fill for blocks

### Pattern 3: Ranking/List
Vertical list with emphasis on order.

```
+---------------------------------------------------------------+
|                                                               |
|  TITLE                                                        |
|  ____________________________________________________________ |
|                                                               |
|  01   ITEM NAME                              1,234  ________ |
|  02   ITEM NAME                                987  ________ |
|  03   ITEM NAME                                654  ________ |
|  04   ITEM NAME                                321  ________ |
|  05   ITEM NAME                                 98  ________ |
|                                                               |
|                                              TOTAL: 3,294     |
+---------------------------------------------------------------+
```

- Rank numbers in red, left-aligned
- Item names in black Regular
- Values right-aligned with leader dots or thin rules
- Total at bottom, right-aligned, in Bold

## Fonts

```python
from PIL import ImageFont

# Helvetica only. Multiple weights for hierarchy.
helvetica_bold = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 64, index=1)
helvetica_regular = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 36, index=0)
helvetica_light = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 28, index=2)
```

Weight hierarchy:
- Title: Helvetica Bold, 48-72pt
- Numbers (hero): Helvetica Bold, 64-120pt
- Column headers: Helvetica Bold, 24-32pt
- Data values: Helvetica Regular, 28-40pt
- Labels/footnotes: Helvetica Light, 18-24pt

## Script Template

```python
from PIL import Image, ImageDraw, ImageFont
import os

# --- Config ---
W, H = 1800, 1012
MARGIN = 80
GUTTER = 24
COLS = 6
COL_W = (W - 2 * MARGIN - (COLS - 1) * GUTTER) // COLS

RED = (204, 0, 0)
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
GRAY = (120, 120, 120)
LIGHT_GRAY = (240, 240, 240)

helvetica_bold = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=1)
helvetica = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=0)
helvetica_light = lambda s: ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", s, index=2)

img = Image.new('RGB', (W, H), WHITE)
draw = ImageDraw.Draw(img)

# Grid helpers
def col_x(col):
    return MARGIN + col * (COL_W + GUTTER)

def col_w(span):
    return span * COL_W + (span - 1) * GUTTER

# 1. TITLE
title = "DATA TITLE"
title_font = helvetica_bold(56)
draw.text((MARGIN, MARGIN), title, fill=BLACK, font=title_font)

# 2. HORIZONTAL RULE below title
rule_y = MARGIN + 80
draw.line([(MARGIN, rule_y), (W - MARGIN, rule_y)], fill=BLACK, width=2)

# 3. COLUMN HEADERS
headers = ["COL A", "COL B", "COL C"]
header_font = helvetica_bold(28)
header_y = rule_y + 20
for i, h in enumerate(headers):
    draw.text((col_x(i * 2), header_y), h, fill=RED, font=header_font)

# 4. DATA ROWS
data_font = helvetica(32)
data = [
    ["Value 1A", "Value 1B", "Value 1C"],
    ["Value 2A", "Value 2B", "Value 2C"],
]
row_y = header_y + 60
for row_i, row in enumerate(data):
    # Alternating row background
    if row_i % 2 == 1:
        draw.rectangle(
            [MARGIN, row_y - 5, W - MARGIN, row_y + 45],
            fill=LIGHT_GRAY
        )
    for col_i, val in enumerate(row):
        draw.text((col_x(col_i * 2), row_y), val, fill=BLACK, font=data_font)
    # Row divider
    div_y = row_y + 50
    draw.line([(MARGIN, div_y), (W - MARGIN, div_y)], fill=(200, 200, 200), width=1)
    row_y = div_y + 10

# 5. FOOTER
footer_font = helvetica_light(20)
draw.text((MARGIN, H - MARGIN - 20), "Source: your data source", fill=GRAY, font=footer_font)

img.save('/tmp/vignelli_visual.png', quality=95)
print(f"Saved: /tmp/vignelli_visual.png ({W}x{H})")
```

## Key Rules

1. **Grid or nothing.** Every element must align to the column grid. No "close enough." Use the math.
2. **Helvetica only.** If you reach for another font, stop. Adjust weight or size instead.
3. **Maximum 3 colors.** White background + black text + red accent. That's the full palette.
4. **Rules are structural.** Horizontal lines separate content, not decorate. 1-2px, black or light gray.
5. **Margins are sacred.** 80px minimum on all sides. Content never touches the edge.
6. **Red is rare.** Use red for exactly ONE element type: headers, key numbers, or rank indicators. Not all three.
7. **Alignment creates hierarchy.** Left-align text, right-align numbers. Consistent within each column.
