# Visual Styles

Generate scroll-stopping data visualization images in iconic designer styles. Each style has a distinct visual language, palette, and layout system. Choose the right style for the content, then follow that style's sub-skill to generate the image.

## When to Use

- Post contains specific numbers, statistics, or data
- Post makes a comparison, reveals a surprising finding, or announces a milestone
- Content benefits from a visual that IS the data (not a generic stock photo)
- NOT for every post -- only when the visual will make someone stop scrolling

## Style Routing

| Content Type | Best Style | Why |
|---|---|---|
| Multi-stat comparison, contrast data | **Scher** | Dense typography handles many data points. Bold color blocking separates categories. |
| Single KPI, one big number, milestone | **Bass** | One geometric shape + one number = maximum impact. Clean, iconic. |
| Dashboard data, financial/grid data | **Vignelli** | Swiss grid was built for structured data. Professional, authoritative. |
| Bold announcements, "pay attention" claims | **Fairey** | Propaganda aesthetic commands attention. Use Higgsfield for editorial background. |
| Surprising/counterintuitive findings | **Carson** | Chaotic typography mirrors the "this doesn't make sense" feeling. |

## Workflow

1. **Analyze the post content.** Identify the data, the story, and the emotional register.
2. **Choose a style** from the routing table above.
3. **Look at references.** Check `references/` for real examples of the style. If you want more inspiration, use the browser skill to search for the designer's work (e.g. "Paula Scher poster design", "Saul Bass movie poster").
4. **Read the style sub-skill** (`scher.md`, `bass.md`, `vignelli.md`, `fairey.md`, `carson.md`).
5. **Copy and adapt the script template.** The templates are starting points, not rigid specs. Feel free to:
   - Remove or swap components (no circle? use a triangle. no sunburst? use a diagonal cut)
   - Change border styles, layout proportions, text placement
   - Combine elements from different patterns within the same style
   - Adjust font sizes and spacing to fit your specific data
6. **Generate the image.** Save to `/tmp/{style}_visual.png`.
7. **Verify at phone scale.** Open the image and check readability at 375px wide.
8. **Attach to the post** via the Twitter/LinkedIn media upload API.

## References

The `references/` directory contains real examples of each designer's work. Study these before generating -- they show the full range of each style, not just the one layout the template demonstrates.

If you want more inspiration beyond what's in `references/`, use the browser skill:
- Search for "[designer name] poster design" or "[designer name] best work"
- Study the density, color relationships, and typography choices
- Then adapt the script template to capture what you saw

Each designer has a wider range than one template can show. Bass did spirals AND silhouettes AND geometric cuts. Fairey did portraits AND typography-only AND mixed layouts. The template is one path through the style -- find others.

## Shared Constraints

### Canvas Sizes
- **Twitter:** 1800 x 1012 px (16:9)
- **LinkedIn:** 1200 x 627 px (1.91:1)

### Font Locations
```
~/Library/Fonts/Druk-Heavy-Trial.otf          # Bold titles
~/Library/Fonts/DrukWide-Heavy-Trial.otf       # Hero numbers (widest, most impact)
~/Library/Fonts/DrukText-Heavy-Trial.otf       # Supporting labels
~/Library/Fonts/DrukText-Bold-Trial.otf        # Background texture text, small labels
~/Library/Fonts/Druk-Bold-Trial.otf            # Medium emphasis titles
~/Library/Fonts/Druk-Super-Trial.otf           # Maximum weight (heavier than Heavy)
~/Library/Fonts/DrukCond-Super-Trial.otf       # Condensed for tight spaces
~/Library/Fonts/DrukXCond-Super-Trial.otf      # Extra condensed
~/Library/Fonts/DrukXXCond-Super-Trial.otf     # Ultra condensed (tallest, narrowest)
/System/Library/Fonts/Helvetica.ttc            # System Helvetica (all weights)
/System/Library/Fonts/HelveticaNeue.ttc        # Helvetica Neue (all weights)
```

### CRITICAL: Druk Trial Font Glyph Bug

The Druk trial fonts are **missing glyphs for `%`, `$`, and `+`**. These characters render as invisible. When your data contains these characters, use the `draw_mixed_text` helper below which falls back to Helvetica for broken glyphs.

```python
BROKEN_IN_DRUK = set('%$+')

def draw_mixed_text(draw, pos, text, druk_font, helvetica_font, color):
    """Render text char-by-char, using Helvetica for glyphs missing in Druk trial."""
    x, y = pos
    for char in text:
        font = helvetica_font if char in BROKEN_IN_DRUK else druk_font
        draw.text((x, y), char, fill=color, font=font)
        x += int(draw.textlength(char, font=font))

def mixed_text_width(draw, text, druk_font, helvetica_font):
    """Measure total width of mixed-font text."""
    return sum(int(draw.textlength(c, font=(helvetica_font if c in BROKEN_IN_DRUK else druk_font))) for c in text)

def draw_rotated_mixed(canvas, position, text, druk_font, helvetica_font, color, angle):
    """Rotated text with Druk/Helvetica glyph fallback."""
    dummy_draw = ImageDraw.Draw(Image.new('RGBA', (1, 1)))
    total_w = mixed_text_width(dummy_draw, text, druk_font, helvetica_font)
    h_ref = druk_font.getbbox("A")
    pad = 80
    th = h_ref[3] - h_ref[1] + pad * 2
    tw = total_w + pad * 2
    txt_img = Image.new('RGBA', (tw, th), (0, 0, 0, 0))
    txt_draw = ImageDraw.Draw(txt_img)
    x = pad
    for c in text:
        f = helvetica_font if c in BROKEN_IN_DRUK else druk_font
        txt_draw.text((x, pad), c, fill=color + (255,), font=f)
        x += int(txt_draw.textlength(c, font=f))
    rotated = txt_img.rotate(angle, expand=True, resample=Image.BICUBIC)
    canvas.paste(rotated, position, rotated)
```

**When to use which:**
- `draw_mixed_text` -- flat (non-rotated) text with `%`, `$`, or `+`
- `draw_rotated_mixed` -- rotated text with `%`, `$`, or `+` (Carson style)
- Regular `draw.text` -- text without special characters (most labels, titles)

### PIL Font Loading
```python
from PIL import ImageFont

# Druk fonts (specify size at load time)
druk_heavy = ImageFont.truetype(os.path.expanduser("~/Library/Fonts/Druk-Heavy-Trial.otf"), 120)

# Helvetica from system .ttc (specify font index for weight)
helvetica_regular = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 48, index=0)
helvetica_bold = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 48, index=1)
helvetica_light = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 48, index=2)

# Helvetica Neue
helvetica_neue = ImageFont.truetype("/System/Library/Fonts/HelveticaNeue.ttc", 48, index=0)
helvetica_neue_bold = ImageFont.truetype("/System/Library/Fonts/HelveticaNeue.ttc", 48, index=3)
```

### Universal Rules

1. **No matplotlib.** No seaborn. No plotly. Pure PIL/Pillow only. We are making posters, not charts.
2. **Fill the canvas.** Dead space is a design failure. Every pixel should have intention.
3. **Numbers dominate.** The data IS the design. Numbers should be the biggest elements.
4. **Limit text.** Strip everything to its essential message. If it can be said in fewer words, use fewer words.
5. **Test at phone scale.** If the key message isn't readable at 375px wide, the font is too small.
6. **Scripts are starting points.** Copy the template, then modify freely. Remove components, swap layouts, adjust proportions. The design principles matter more than the exact code.

### Attaching to Posts

```bash
# Twitter: upload media then tweet with media_id
MEDIA_ID=$(~/.rush/bin/rush http POST '/api/v1/twitter/media' --oauth twitter --file /tmp/visual.png 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('media_id',''))")
~/.rush/bin/rush http POST '/api/v1/twitter/tweets' --oauth twitter -d "{\"text\":\"tweet text\", \"media_ids\":[\"$MEDIA_ID\"]}"
```
