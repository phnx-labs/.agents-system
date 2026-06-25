"""Append newly-shipped angles to the coverage index so future runs dedup against them.

Run after a brief is sent. Reads any draft JSONs newer than the index and adds
their `text` (with pillar/subtopic if present) to embeddings.npy + index_meta.parquet.

Usage:
  python record_covered.py                      # scan drafts/ for new since last run
  python record_covered.py "<angle text>" ...   # add explicit angle(s)
"""

from __future__ import annotations

import json
import sys
import time
from pathlib import Path

import numpy as np
import pandas as pd

HERE = Path(__file__).resolve().parent
WS = HERE.parent
DRAFTS = WS / "drafts"
STAMP = HERE / ".last_indexed"
MODEL = "BAAI/bge-small-en-v1.5"


def new_texts_from_drafts() -> list[dict]:
    since = float(STAMP.read_text()) if STAMP.exists() else 0.0
    rows = []
    for j in DRAFTS.glob("*.json"):
        if j.stat().st_mtime <= since:
            continue
        try:
            d = json.loads(j.read_text())
        except Exception:
            continue
        for dr in d.get("drafts", []):
            t = (dr.get("text") or "").strip()
            if t:
                rows.append({"id": j.stem, "account": d.get("account", ""),
                             "date": time.strftime("%Y-%m-%d"),
                             "pillar": "", "subtopic": dr.get("theme", ""), "text": t})
    return rows


def main() -> None:
    explicit = [a for a in sys.argv[1:]]
    if explicit:
        rows = [{"id": "manual", "account": "", "date": time.strftime("%Y-%m-%d"),
                 "pillar": "", "subtopic": "", "text": t} for t in explicit]
    else:
        rows = new_texts_from_drafts()
    if not rows:
        print("nothing new to index")
        return
    from sentence_transformers import SentenceTransformer

    model = SentenceTransformer(MODEL)
    new_emb = model.encode([r["text"] for r in rows], normalize_embeddings=True).astype("float32")

    emb = np.load(HERE / "embeddings.npy")
    meta = pd.read_parquet(HERE / "index_meta.parquet")
    emb = np.vstack([emb, new_emb])
    add = pd.DataFrame(rows)
    add["text"] = add["text"].str.slice(0, 400)
    meta = pd.concat([meta, add[meta.columns.intersection(add.columns)]], ignore_index=True)

    np.save(HERE / "embeddings.npy", emb)
    meta.to_parquet(HERE / "index_meta.parquet", index=False)
    STAMP.write_text(str(time.time()))
    print(f"indexed {len(rows)} new angles -> {len(meta)} total")


if __name__ == "__main__":
    main()
