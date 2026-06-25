"""Check a candidate draft against everything Emma has covered before.

This is Emma's dedup gate. Before drafting an angle, run it through here:
the index returns the most similar prior angles and a verdict so she never
re-polishes a take she already shipped (the "dead drafts" failure mode).

Usage:
  python check_coverage.py "your candidate post / angle text here"
  echo "candidate text" | python check_coverage.py
  python check_coverage.py --json "candidate text"

Verdict thresholds (cosine similarity to nearest prior angle):
  >= 0.95  TOO_SIMILAR  -> do not draft; it's a re-skin. (kill it)
  0.90-0.95 REVISE_ONLY -> only proceed if it genuinely advances the thread
  < 0.90   NEW          -> safe to draft
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import numpy as np
import pandas as pd

HERE = Path(__file__).resolve().parent
TOO_SIMILAR = 0.95
REVISE = 0.90
MODEL = "BAAI/bge-small-en-v1.5"


def load_index():
    emb = np.load(HERE / "embeddings.npy")
    meta = pd.read_parquet(HERE / "index_meta.parquet")
    return emb, meta


def verdict(score: float) -> str:
    if score >= TOO_SIMILAR:
        return "TOO_SIMILAR"
    if score >= REVISE:
        return "REVISE_ONLY"
    return "NEW"


def check(text: str, k: int = 5):
    from sentence_transformers import SentenceTransformer

    emb, meta = load_index()
    model = SentenceTransformer(MODEL)
    q = model.encode([text], normalize_embeddings=True).astype("float32")[0]
    sims = emb @ q  # cosine (both normalized)
    top = np.argsort(sims)[::-1][:k]
    neighbors = []
    for i in top:
        r = meta.iloc[int(i)]
        neighbors.append(
            {
                "similarity": round(float(sims[i]), 4),
                "date": r.get("date"),
                "account": r.get("account"),
                "pillar": r.get("pillar"),
                "subtopic": r.get("subtopic"),
                "text": (r.get("text") or "")[:200],
            }
        )
    return {"verdict": verdict(float(sims[top[0]])), "top_similarity": neighbors[0]["similarity"], "neighbors": neighbors}


def main() -> None:
    args = [a for a in sys.argv[1:] if a != "--json"]
    as_json = "--json" in sys.argv
    text = args[0] if args else sys.stdin.read()
    text = text.strip()
    if not text:
        print("usage: check_coverage.py \"candidate text\"", file=sys.stderr)
        sys.exit(2)
    res = check(text)
    if as_json:
        print(json.dumps(res, indent=2, default=str))
        return
    print(f"VERDICT: {res['verdict']}  (nearest = {res['top_similarity']})")
    print("Most similar prior angles:")
    for n in res["neighbors"]:
        print(f"  {n['similarity']:.3f}  [{n['date']} {n['account']} | {n['pillar']} > {n['subtopic']}]")
        print(f"         {n['text']}")


if __name__ == "__main__":
    main()
