"""Build the audience-alignment figure + markdown report.

Reads  : report/audience_alignment.json, report/nodes.json
Writes : report/figures/audience_alignment.png, report/audience_alignment.md
"""

from __future__ import annotations

import json
import os
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

ROOT = Path(os.environ.get("CA_DIR", Path.cwd()))
REPORT = ROOT / "report"
FIG = REPORT / "figures"

a = json.load(open(REPORT / "audience_alignment.json"))
s = a["subtopic_scores"]

vol = np.array([x["drafts"] for x in s], float)
buyer = np.array([x["buyer"] for x in s], float)
amp = np.array([x["amplifier"] for x in s], float)
ids = [x["id"] for x in s]
names = [x["name"] for x in s]

# ---- figure: amplifier (x) vs buyer (y), bubble = draft volume ----
plt.figure(figsize=(12, 8))
jitter = (np.random.RandomState(1).rand(len(s)) - 0.5) * 0.12
jitter2 = (np.random.RandomState(2).rand(len(s)) - 0.5) * 0.12
plt.scatter(amp + jitter, buyer + jitter2, s=vol * 2.2, alpha=0.45,
            c="#dc2626", edgecolors="#7f1d1d", linewidths=0.5)
for i, x in enumerate(s):
    if vol[i] >= 140 or (buyer[i] >= 2):  # label big bubbles + the rare buyer wins
        plt.annotate(f"{ids[i]} {names[i][:22]}", (amp[i] + jitter[i], buyer[i] + jitter2[i]),
                     fontsize=7, alpha=0.85, ha="center")
plt.axhspan(-0.3, 1.0, color="#fee2e2", alpha=0.4, zorder=0)
plt.text(0.05, 0.05, "dead zone for buyers\n(40% of all drafts live here)", fontsize=9, color="#7f1d1d")
plt.xlabel("Amplifier resonance (AI-Twitter influencers)  →")
plt.ylabel("Buyer resonance (SMB ICP who pays $50/mo)  →")
plt.title("Content taxonomy vs audience — bubble size = drafts written\n"
          "Mass sits bottom-right: high amplifier, ~zero buyer", fontsize=12)
plt.xlim(-0.4, 3.4)
plt.ylim(-0.4, 3.4)
plt.grid(alpha=0.2)
plt.tight_layout()
plt.savefig(FIG / "audience_alignment.png", dpi=130)
plt.close()
print("wrote audience_alignment.png")

# ---- markdown report ----
vw_buyer = (vol * buyer).sum() / vol.sum()
vw_amp = (vol * amp).sum() / vol.sum()
L = []
L.append("# Second Pass — Audience Alignment\n")
L.append("_Does the 12x3x9 content taxonomy match the people Rush wants to reach?_\n")
L.append("Audience truth pulled from the growth side: **Marc's SMB prospect list** "
         "(626 rows — founders, fractional CTOs, AI consultants, content solopreneurs; "
         "the ones who pay $50/mo) and **Emma's X engagement targets** (roon, Will Manidis, "
         "Aakash Gupta, Alex Finn, NIK — the amplifiers whose followers = buyers).\n")
L.append("## Headline\n")
L.append(f"- **Volume-weighted buyer resonance: {vw_buyer:.2f}/3** vs **amplifier {vw_amp:.2f}/3**.")
L.append(f"- **{int(vol[buyer==0].sum()):,} drafts ({vol[buyer==0].sum()/vol.sum():.0%}) sit on subtopics no buyer cares about**; only "
         f"{int(vol[buyer>=2].sum()):,} ({vol[buyer>=2].sum()/vol.sum():.0%}) land on a buyer pain.")
L.append("- 11 of 12 pillars are **amplifier-skewed**. The content engine builds AI-Twitter "
         "credibility but barely speaks to the $50/mo SMB — consistent with the current **0% outreach reply rate**.")
L.append("- This is not 'bad content' — it's **content aimed at the wrong conversion target**. Great for "
         "the @themuqsit/builder credibility play; nearly silent on the buyer's day-to-day pain.\n")
L.append(f"![Alignment](figures/audience_alignment.png)\n")

L.append("## Pillar verdicts\n")
L.append("| Pillar | avg buyer | avg amp | verdict |\n|---|---:|---:|---|")
for p in a["pillar_summary"]:
    L.append(f"| {p['pillar']} | {p['avg_buyer']:.1f} | {p['avg_amplifier']:.1f} | {p['verdict']} |")
L.append("")

L.append("## Over-invested (high volume, low buyer value)\n")
L.append("| Subtopic | drafts | note |\n|---|---:|---|")
for o in a["over_invested"]:
    L.append(f"| {o['id']} | {o['drafts']} | {o['note']} |")
L.append("")

L.append("## The buyer gaps — content we *don't* make that the ICP actually wants\n")
for g in a["buyer_gaps"]:
    L.append(f"**{g['territory']}** — {g['why_buyers_care']}")
    for ang in g.get("example_angles", [])[:2]:
        L.append(f"  - {ang}")
    L.append("")

L.append("## Recommended re-weighting\n")
rw = a["reweighting"]
L.append(f"- **Keep (capped) for amplifier credibility:** {', '.join(rw['keep_for_amplifiers'])}")
L.append(f"- **Dial down:** {', '.join(rw['dial_down'])}")
L.append("- **Add net-new buyer-facing pillars:**")
for p in rw["add_buyer_pillars"]:
    subs = ", ".join(p["subtopics"])
    L.append(f"  - **{p['name']}** — {subs}")
L.append("")
L.append("## So what\n")
L.append("Keep ~1/3 of output on the sharp amplifier meta-takes (that's the credibility flywheel and "
         "it works — amplifier score 2.3/3). Re-point the other ~2/3 from abstract industry commentary "
         "toward **concrete, segment-specific, time-saved workflow content** the SMB buyer recognizes as "
         "their own problem. The coverage index + backlog already exist; this just changes which pillars "
         "the backlog should weight.\n")

(REPORT / "audience_alignment.md").write_text("\n".join(L))
print("wrote audience_alignment.md")
print(f"vw_buyer={vw_buyer:.2f} vw_amp={vw_amp:.2f}")
