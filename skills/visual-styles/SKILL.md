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
3. **Read the style sub-skill** (`scher.md`, `bass.md`, `vignelli.md`, `fairey.md`, `carson.md`).
4. **Write a PIL script** following the sub-skill's template and design rules.
5. **Generate the image.** Save to `/tmp/{style}_visual.png`.
6. **Attach to the post** via the Twitter/LinkedIn media upload API.

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

### Attaching to Posts

```bash
# Twitter: upload media then tweet with media_id
MEDIA_ID=$(~/.rush/bin/rush http POST '/api/v1/twitter/media' --oauth twitter --file /tmp/visual.png 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('media_id',''))")
~/.rush/bin/rush http POST '/api/v1/twitter/tweets' --oauth twitter -d "{\"text\":\"tweet text\", \"media_ids\":[\"$MEDIA_ID\"]}"
```
