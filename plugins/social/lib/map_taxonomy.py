"""Map every draft to its pillar/subtopic and build per-node rollups.

Reads  : data/clean/drafts_clustered.parquet, links.parquet,
         report/taxonomy_structure.json, report/clusters.json
Writes : data/clean/drafts_mapped.parquet/.csv/.jsonl  (every draft + pillar/subtopic)
         report/nodes.json  (per-subtopic rollup for taxonomy doc + leaf agents)
"""

from __future__ import annotations

import json
import os
from pathlib import Path

import pandas as pd

ROOT = Path(os.environ.get("CA_DIR", Path.cwd()))
CLEAN = ROOT / "data" / "clean"
REPORT = ROOT / "report"


def main() -> None:
    df = pd.read_parquet(CLEAN / "drafts_clustered.parquet")
    links = pd.read_parquet(CLEAN / "links.parquet")
    tax = json.load(open(REPORT / "taxonomy_structure.json"))
    clusters = {c["cluster"]: c for c in json.load(open(REPORT / "clusters.json"))}

    # cluster -> (pillar_id, pillar_name, subtopic_id, subtopic_name)
    cmap = {}
    for p in tax["pillars"]:
        for s in p["subtopics"]:
            for cid in s["cluster_ids"]:
                cmap[cid] = (p["id"], p["name"], s["id"], s["name"])

    df["pillar_id"] = df["cluster"].map(lambda c: cmap[c][0])
    df["pillar"] = df["cluster"].map(lambda c: cmap[c][1])
    df["subtopic_id"] = df["cluster"].map(lambda c: cmap[c][2])
    df["subtopic"] = df["cluster"].map(lambda c: cmap[c][3])
    assert df["pillar_id"].notna().all(), "unassigned drafts exist!"

    cols = [
        "id", "account", "platform", "date", "sent", "type", "theme",
        "pillar_id", "pillar", "subtopic_id", "subtopic", "cluster",
        "is_dup", "word_count", "text",
    ]
    out = df[cols]
    out.to_parquet(CLEAN / "drafts_mapped.parquet", index=False)
    out.to_csv(CLEAN / "drafts_mapped.csv", index=False)
    out.to_json(CLEAN / "drafts_mapped.jsonl", orient="records", lines=True, force_ascii=False)

    # link lookup by draft id
    links_by_draft = links.groupby("draft_id")

    # Per-subtopic rollup
    nodes = []
    for p in tax["pillars"]:
        for s in p["subtopics"]:
            mask = df["subtopic_id"] == s["id"]
            sub = df[mask]
            ids = set(sub["id"])
            sublinks = links[links["draft_id"].isin(ids)]
            top_urls = (
                sublinks.groupby("url")
                .agg(n=("draft_id", "nunique"), label=("label", "first"),
                     domain=("domain", "first"))
                .sort_values("n", ascending=False)
                .head(12)
                .reset_index()
                .to_dict(orient="records")
            )
            # representative posts from the subtopic's clusters
            reps = []
            for cid in s["cluster_ids"]:
                reps.extend(clusters[cid].get("representative_posts", [])[:2])
            kws = []
            for cid in s["cluster_ids"]:
                kws.extend(clusters[cid].get("keywords", [])[:6])
            nodes.append({
                "pillar_id": p["id"],
                "pillar": p["name"],
                "pillar_desc": p["description"],
                "subtopic_id": s["id"],
                "subtopic": s["name"],
                "subtopic_desc": s["description"],
                "cluster_ids": s["cluster_ids"],
                "n_drafts": int(mask.sum()),
                "platform_split": sub["platform"].value_counts().to_dict(),
                "keywords": list(dict.fromkeys(kws))[:14],
                "representative_posts": reps[:6],
                "top_links": top_urls,
            })
    (REPORT / "nodes.json").write_text(json.dumps(nodes, indent=2))

    # Pillar rollup for quick reference
    pill = (
        out.groupby(["pillar_id", "pillar"])
        .agg(drafts=("id", "count"),
             x=("platform", lambda s: int((s == "X").sum())),
             linkedin=("platform", lambda s: int((s == "LinkedIn").sum())))
        .reset_index()
        .sort_values("pillar_id")
    )
    print("mapped drafts:", len(out), "| unassigned:", int(out["pillar_id"].isna().sum()))
    print("nodes:", len(nodes), "(expect 36)")
    print(pill.to_string(index=False))


if __name__ == "__main__":
    main()
