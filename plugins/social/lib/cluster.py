"""Embed drafts locally, reduce, and cluster to discover latent micro-topics.

Reads  : data/clean/drafts.parquet
Writes : data/clean/drafts_clustered.parquet  (adds `cluster` to every draft)
         report/clusters.json                  (per-cluster keywords + samples)
         report/figures/cluster_scatter.png

Pipeline: bge-small embeddings -> UMAP(10d) -> HDBSCAN -> assign noise to
nearest centroid -> c-TF-IDF keywords + centroid-nearest representative posts.
"""

from __future__ import annotations

import json
import re
import os
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.feature_extraction.text import CountVectorizer

ROOT = Path(os.environ.get("CA_DIR", Path.cwd()))
CLEAN = ROOT / "data" / "clean"
REPORT = ROOT / "report"
MIN_CLUSTER_SIZE = 22  # tuned to land ~30-55 clusters
MODEL = "BAAI/bge-small-en-v1.5"


def embed(texts: list[str]) -> np.ndarray:
    from sentence_transformers import SentenceTransformer

    model = SentenceTransformer(MODEL)
    return model.encode(
        texts, batch_size=64, show_progress_bar=True, normalize_embeddings=True
    )


def ctfidf_keywords(docs_per_cluster: dict[int, str], top_n: int = 12) -> dict[int, list[str]]:
    ids = sorted(docs_per_cluster)
    corpus = [docs_per_cluster[c] for c in ids]
    vec = CountVectorizer(
        ngram_range=(1, 2),
        stop_words="english",
        min_df=2,
        token_pattern=r"(?u)\b[a-zA-Z][a-zA-Z\-]+\b",
    )
    X = vec.fit_transform(corpus).toarray().astype(float)
    terms = np.array(vec.get_feature_names_out())
    tf = X / X.sum(axis=1, keepdims=True).clip(min=1)
    n_per_term = (X > 0).sum(axis=0)
    idf = np.log(1 + len(ids) / n_per_term.clip(min=1))
    score = tf * idf
    out = {}
    for i, c in enumerate(ids):
        top = score[i].argsort()[::-1][:top_n]
        out[c] = [t for t in terms[top]]
    return out


def main() -> None:
    df = pd.read_parquet(CLEAN / "drafts.parquet")
    # Embed unique texts only, then propagate to duplicates by hash.
    uniq = df.drop_duplicates("text_hash")[["text_hash", "text"]].reset_index(drop=True)
    texts = (uniq["text"].fillna("")).tolist()
    print(f"embedding {len(texts)} unique texts with {MODEL} ...")
    emb = embed(texts)

    import umap
    import hdbscan

    print("UMAP -> 10d ...")
    reducer = umap.UMAP(
        n_neighbors=15, n_components=10, min_dist=0.0, metric="cosine", random_state=42
    )
    red = reducer.fit_transform(emb)

    print("HDBSCAN ...")
    clusterer = hdbscan.HDBSCAN(
        min_cluster_size=MIN_CLUSTER_SIZE, min_samples=5, metric="euclidean"
    )
    labels = clusterer.fit_predict(red)
    n_clusters = len(set(labels)) - (1 if -1 in labels else 0)
    noise = int((labels == -1).sum())
    print(f"clusters: {n_clusters} | noise: {noise}/{len(labels)}")

    # Assign noise points to nearest cluster centroid (everyone gets a cluster).
    centroids = {}
    for c in set(labels):
        if c == -1:
            continue
        centroids[c] = red[labels == c].mean(axis=0)
    cids = list(centroids)
    cmat = np.vstack([centroids[c] for c in cids])
    for idx in np.where(labels == -1)[0]:
        d = np.linalg.norm(cmat - red[idx], axis=1)
        labels[idx] = cids[int(d.argmin())]

    uniq["cluster"] = labels
    # 2D projection for the scatter plot.
    proj = umap.UMAP(
        n_neighbors=15, n_components=2, min_dist=0.1, metric="cosine", random_state=42
    ).fit_transform(emb)
    uniq["x"], uniq["y"] = proj[:, 0], proj[:, 1]

    # Propagate cluster to all drafts via text_hash.
    df = df.merge(uniq[["text_hash", "cluster"]], on="text_hash", how="left")
    df["cluster"] = df["cluster"].astype(int)
    df.to_parquet(CLEAN / "drafts_clustered.parquet", index=False)

    # c-TF-IDF keywords per cluster (over unique texts).
    docs = (
        uniq.groupby("cluster")["text"]
        .apply(lambda s: " ".join(s.fillna("")))
        .to_dict()
    )
    keywords = ctfidf_keywords(docs)

    # Representative posts: nearest to centroid in reduced space.
    uniq_red = pd.DataFrame(red)
    summaries = []
    for c in sorted(set(labels)):
        members = np.where(labels == c)[0]
        cen = red[members].mean(axis=0)
        dist = np.linalg.norm(red[members] - cen, axis=1)
        reps = members[dist.argsort()[:4]]
        rep_texts = [texts[i][:300] for i in reps]
        total = int((df["cluster"] == c).sum())  # all drafts incl dups
        plat = df[df["cluster"] == c]["platform"].value_counts().to_dict()
        themes = (
            df[(df["cluster"] == c) & (df["theme"] != "")]["theme"]
            .value_counts()
            .head(3)
            .to_dict()
        )
        summaries.append(
            {
                "cluster": int(c),
                "n_drafts": total,
                "n_unique": int(len(members)),
                "platforms": plat,
                "top_existing_themes": themes,
                "keywords": keywords.get(c, []),
                "representative_posts": rep_texts,
            }
        )
    summaries.sort(key=lambda s: -s["n_drafts"])
    (REPORT / "clusters.json").write_text(json.dumps(summaries, indent=2))

    # scatter
    plt.figure(figsize=(11, 9))
    plt.scatter(uniq["x"], uniq["y"], c=uniq["cluster"], cmap="tab20", s=5, alpha=0.6)
    plt.title(f"{n_clusters} discovered micro-topics (bge-small + UMAP + HDBSCAN)")
    plt.tight_layout()
    plt.savefig(REPORT / "figures" / "cluster_scatter.png", dpi=120)
    plt.close()

    print(f"WROTE clusters.json ({len(summaries)} clusters), drafts_clustered.parquet")
    for s in summaries[:8]:
        print(f"  c{s['cluster']:>3} n={s['n_drafts']:>4}  {', '.join(s['keywords'][:8])}")


if __name__ == "__main__":
    main()
