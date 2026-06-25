"""Build reviewable taxonomy diagrams: sunburst + treemap of pillars/subtopics.

Writes: report/figures/taxonomy_sunburst.png, taxonomy_treemap.png
"""

from __future__ import annotations

import json
import os
from pathlib import Path

import plotly.graph_objects as go

ROOT = Path(os.environ.get("CA_DIR", Path.cwd()))
REPORT = ROOT / "report"
FIG = REPORT / "figures"

tax = json.load(open(REPORT / "taxonomy_structure.json"))
nodes = {n["subtopic_id"]: n for n in json.load(open(REPORT / "nodes.json"))}

PALETTE = [
    "#2563eb", "#0891b2", "#7c3aed", "#db2777", "#ea580c", "#16a34a",
    "#ca8a04", "#dc2626", "#0d9488", "#4f46e5", "#9333ea", "#65a30d",
]

grand_total = sum(
    nodes[s["id"]]["n_drafts"] for p in tax["pillars"] for s in p["subtopics"]
)
labels, parents, values, colors, text = [], [], [], [], []
labels.append(f"All drafts ({grand_total})")
parents.append("")
values.append(grand_total)
colors.append("#0f172a")
text.append("")
ROOT_LABEL = f"All drafts ({grand_total})"

for i, p in enumerate(tax["pillars"]):
    pid = f"P{p['id']}"
    ptot = sum(nodes[s["id"]]["n_drafts"] for s in p["subtopics"])
    labels.append(f"{p['id']}. {p['name']}")
    parents.append(ROOT_LABEL)
    values.append(ptot)
    colors.append(PALETTE[i % len(PALETTE)])
    text.append(f"{ptot}")
    for s in p["subtopics"]:
        n = nodes[s["id"]]
        labels.append(f"{s['id']} {s['name']}")
        parents.append(f"{p['id']}. {p['name']}")
        values.append(n["n_drafts"])
        colors.append(PALETTE[i % len(PALETTE)])
        text.append(f"{n['n_drafts']}")

# Sunburst
sb = go.Figure(go.Sunburst(
    labels=labels, parents=parents, values=values,
    branchvalues="total", marker=dict(colors=colors),
    insidetextorientation="radial",
    hovertemplate="<b>%{label}</b><br>%{value} drafts<extra></extra>",
))
sb.update_layout(
    title="Emma Content Taxonomy — 12 pillars x 3 subtopics (sized by draft volume)",
    margin=dict(t=60, l=10, r=10, b=10), width=1100, height=1100,
    font=dict(size=13),
)
sb.write_image(str(FIG / "taxonomy_sunburst.png"), scale=2)

# Treemap
tm = go.Figure(go.Treemap(
    labels=labels, parents=parents, values=values,
    branchvalues="total", marker=dict(colors=colors),
    text=text, textinfo="label+value",
    hovertemplate="<b>%{label}</b><br>%{value} drafts<extra></extra>",
))
tm.update_layout(
    title="Emma Content Taxonomy — treemap (area = draft volume)",
    margin=dict(t=60, l=10, r=10, b=10), width=1400, height=900,
    font=dict(size=13),
)
tm.write_image(str(FIG / "taxonomy_treemap.png"), scale=2)

print("wrote taxonomy_sunburst.png, taxonomy_treemap.png")
