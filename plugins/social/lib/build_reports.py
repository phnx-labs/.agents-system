"""Assemble the markdown deliverables from the analysis artifacts.

Writes: report/analysis.md, report/taxonomy.md, report/content_backlog.md
"""

from __future__ import annotations

import json
import os
from pathlib import Path

ROOT = Path(os.environ.get("CA_DIR", Path.cwd()))
REPORT = ROOT / "report"
FIGREL = "figures"

stats = json.load(open(REPORT / "stats.json"))
tax = json.load(open(REPORT / "taxonomy_structure.json"))
nodes = {n["subtopic_id"]: n for n in json.load(open(REPORT / "nodes.json"))}
clusters = {c["cluster"]: c for c in json.load(open(REPORT / "clusters.json"))}
leaves = {}
for f in (REPORT / "leaves").glob("pillar_*.json"):
    d = json.load(open(f))
    for s in d["subtopics"]:
        leaves[s["subtopic_id"]] = s["angles"]

DATE = "2026-06-24"


def pill_count(p):
    return sum(nodes[s["id"]]["n_drafts"] for s in p["subtopics"])


def plat_split(p):
    x = lin = 0
    for s in p["subtopics"]:
        ps = nodes[s["id"]]["platform_split"]
        x += ps.get("X", 0)
        lin += ps.get("LinkedIn", 0)
    return x, lin


# ---------------- analysis.md ----------------
def build_analysis() -> str:
    t = stats["totals"]
    L = []
    L.append("# Emma Content Analysis\n")
    L.append(f"_Generated {DATE} — corpus snapshot of Emma's draft archive._\n")
    L.append("## 1. Corpus at a glance\n")
    L.append(f"- **{t['drafts']:,} drafts** authored across 3 accounts "
             f"({t['date_min']} → {t['date_max']})")
    L.append(f"- **{t['unique_texts']:,} unique** texts ({t['duplicates']:,} near-duplicate "
             "revision passes)")
    L.append(f"- **{t['sent']:,} sent** (rendered + pushed for review)")
    L.append(f"- **{t['links']:,} reference links** → {t['unique_urls']:,} unique URLs "
             f"across {t['unique_domains']:,} domains")
    L.append("")
    L.append("| Account | Drafts |\n|---|---:|")
    for a, n in stats["by_account"].items():
        L.append(f"| {a} | {n:,} |")
    L.append("")
    L.append("| Platform | Drafts |\n|---|---:|")
    for a, n in stats["by_platform"].items():
        L.append(f"| {a} | {n:,} |")
    L.append("")
    L.append(f"![Cadence]({FIGREL}/cadence_weekly.png)\n")
    L.append(f"![By month/platform]({FIGREL}/by_month_platform.png)\n")

    L.append("## 2. Emma's existing themes (her own 7-theme tagging)\n")
    L.append("Only ~57% of drafts carried a `theme` tag, and only across 7+2 coarse buckets — "
             "too blunt to drive a content calendar. That gap is exactly why we rebuilt the "
             "taxonomy bottom-up.\n")
    L.append("| Existing theme | Drafts |\n|---|---:|")
    for th, n in stats["existing_themes"].items():
        L.append(f"| {th} | {n:,} |")
    L.append(f"| _(untagged)_ | {stats['no_theme']:,} |")
    L.append("")
    L.append(f"![Themes over time]({FIGREL}/themes_over_time.png)\n")

    L.append("## 3. The rebuilt taxonomy — 12 pillars\n")
    L.append("We embedded every draft (bge-small) → UMAP → HDBSCAN, discovered **52 micro-topics**, "
             "then consolidated them with Emma's 21 narrative threads into **12 pillars × 3 subtopics "
             "× 9 angles**. Full tree in `taxonomy.md`.\n")
    L.append(f"![Cluster map]({FIGREL}/cluster_scatter.png)\n")
    L.append("| # | Pillar | Drafts | X | LinkedIn |\n|---:|---|---:|---:|---:|")
    for p in sorted(tax["pillars"], key=lambda p: -pill_count(p)):
        x, lin = plat_split(p)
        L.append(f"| {p['id']} | {p['name']} | {pill_count(p):,} | {x:,} | {lin:,} |")
    L.append("")

    L.append("## 4. What Emma cites — source intelligence\n")
    L.append(f"Source vs reference links: "
             f"{', '.join(f'{k}={v:,}' for k, v in stats['source_vs_reference'].items())}.\n")
    L.append(f"![Top domains]({FIGREL}/top_domains.png)\n")
    L.append("**Top 15 cited domains**\n")
    L.append("| Domain | Citations |\n|---|---:|")
    for dom, n in list(stats["top_domains"].items())[:15]:
        L.append(f"| {dom} | {n:,} |")
    L.append("")
    L.append("**Most-cited individual URLs** (recurring research worth a deeper content series)\n")
    L.append("| Citations | Source | URL |\n|---:|---|---|")
    for u in stats["top_urls"][:20]:
        lab = (u["label"] or "")[:60].replace("|", "/")
        L.append(f"| {u['n']} | {lab} | {u['url']} |")
    L.append("")

    L.append("## 5. Entities & vocabulary\n")
    L.append(f"![Entities]({FIGREL}/entity_mentions.png)\n")
    L.append("**Most-mentioned entities/topics** (drafts containing the term)\n")
    L.append("| Entity | Drafts |\n|---|---:|")
    for e, n in list(stats["entity_mentions"].items())[:18]:
        L.append(f"| {e} | {n:,} |")
    L.append("")
    L.append("**Top recurring bigrams**\n")
    bg = ", ".join(f"`{b['bigram']}` ({b['n']})" for b in stats["top_bigrams"][:30])
    L.append(bg + "\n")

    L.append("## 6. Whitespace & recommendations\n")
    ranked = sorted(tax["pillars"], key=lambda p: pill_count(p))
    light = ", ".join(f"**{p['name']}** ({pill_count(p):,})" for p in ranked[:3])
    heavy = ", ".join(f"**{p['name']}** ({pill_count(p):,})" for p in ranked[::-1][:3])
    L.append(f"- **Most-saturated** territories: {heavy}. These are well-mined — raise the bar "
             "for novelty before adding more.")
    L.append(f"- **Thinnest / highest-leverage whitespace**: {light}. Strong worldview fit but "
             "under-covered — prioritise these in the backlog.")
    L.append(f"- **{t['duplicates']:,} near-duplicate revision passes** ({t['duplicates']/t['drafts']:.0%} "
             "of volume) confirm Emma's own warning about 'thousands of dead drafts' from re-polishing. "
             "The backlog favors net-new angles over re-skins.")
    L.append("- LinkedIn is under-fed vs X on several pillars — see per-pillar split above.\n")
    return "\n".join(L)


# ---------------- taxonomy.md ----------------
def build_taxonomy() -> str:
    L = []
    L.append("# Emma Content Taxonomy — 12 × 3 × 9\n")
    L.append(f"_Generated {DATE}. 12 pillars → 36 subtopics → 324 ready-to-write post angles, "
             "grounded in 4,617 analysed drafts._\n")
    L.append("## Map\n")
    for p in tax["pillars"]:
        subs = " · ".join(s["name"] for s in p["subtopics"])
        L.append(f"**{p['id']}. {p['name']}** ({pill_count(p):,}) — {subs}")
    L.append("")
    L.append("---\n")
    for p in tax["pillars"]:
        x, lin = plat_split(p)
        L.append(f"## {p['id']}. {p['name']}\n")
        L.append(f"_{p['description']}_\n")
        L.append(f"**{pill_count(p):,} drafts** · X {x:,} / LinkedIn {lin:,}\n")
        for s in p["subtopics"]:
            n = nodes[s["id"]]
            ps = n["platform_split"]
            L.append(f"### {s['id']} — {s['name']}\n")
            L.append(f"{s['description']}\n")
            L.append(f"`{n['n_drafts']} drafts` · X {ps.get('X',0)} / LinkedIn {ps.get('LinkedIn',0)} · "
                     f"keywords: {', '.join(n['keywords'][:10])}\n")
            if n["top_links"]:
                L.append("Key recurring sources:")
                for lk in n["top_links"][:5]:
                    lab = (lk["label"] or lk["domain"])[:70]
                    L.append(f"- [{lab}]({lk['url']}) ×{lk['n']}")
                L.append("")
            L.append("**9 post angles:**\n")
            for i, ang in enumerate(leaves.get(s["id"], []), 1):
                plat = ang.get("platform", "")
                L.append(f"{i}. **{ang['hook']}** _( {plat} )_  ")
                L.append(f"   ↳ {ang['insight']}")
                for lk in ang.get("links", []):
                    if lk.get("url"):
                        L.append(f"   ↳ [{(lk.get('label') or '')[:60]}]({lk['url']})")
            L.append("")
        L.append("---\n")
    return "\n".join(L)


# ---------------- content_backlog.md ----------------
def build_backlog() -> str:
    L = []
    L.append("# Emma Content Backlog — prioritised angles\n")
    L.append(f"_Generated {DATE}. 324 ready-to-write angles, ranked by whitespace leverage._\n")
    L.append("Priority = inverse coverage: pillars Emma has covered *least* (strong fit, low volume) "
             "rise to the top as the highest-leverage net-new content. Each angle carries its platform "
             "and supporting research links.\n")
    ranked = sorted(tax["pillars"], key=lambda p: pill_count(p))

    # Quick-wins: angles from the 3 lightest pillars that ship with >=1 link.
    L.append("## Top quick-wins (whitespace + sourced)\n")
    qcount = 0
    for p in ranked[:4]:
        for s in p["subtopics"]:
            for ang in leaves.get(s["id"], []):
                if ang.get("links") and any(l.get("url") for l in ang["links"]) and qcount < 30:
                    qcount += 1
                    lk = next(l for l in ang["links"] if l.get("url"))
                    L.append(f"{qcount}. **[{p['name']}]** {ang['hook']} "
                             f"_({ang.get('platform','')})_ — [{(lk.get('label') or 'src')[:45]}]({lk['url']})")
    L.append("")

    L.append("## Full backlog by priority\n")
    for rank, p in enumerate(ranked, 1):
        L.append(f"### P{rank}. {p['name']}  ({pill_count(p):,} existing drafts)\n")
        for s in p["subtopics"]:
            L.append(f"**{s['name']}**\n")
            for ang in leaves.get(s["id"], []):
                links = " ".join(
                    f"[link]({l['url']})" for l in ang.get("links", []) if l.get("url")
                )
                L.append(f"- {ang['hook']} _({ang.get('platform','')})_ {links}")
            L.append("")
    return "\n".join(L)


def main() -> None:
    (REPORT / "analysis.md").write_text(build_analysis())
    (REPORT / "taxonomy.md").write_text(build_taxonomy())
    (REPORT / "content_backlog.md").write_text(build_backlog())
    n_angles = sum(len(v) for v in leaves.values())
    print(f"wrote analysis.md, taxonomy.md, content_backlog.md")
    print(f"pillars={len(tax['pillars'])} subtopics={len(leaves)} angles={n_angles}")


if __name__ == "__main__":
    main()
