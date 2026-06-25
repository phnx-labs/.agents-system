"""Build Emma's semantic coverage index.

Embeds every previously-covered angle (coverage_seed.jsonl) so Emma can check
a candidate draft against everything she has ever written via vector similarity
instead of eyeballing a 39KB COVERED.md text ledger.

Run once to bootstrap, then append new angles with `record_covered.py`.
Outputs (same dir): embeddings.npy (float32 [N,384]) + index_meta.parquet.

Usage: python build_coverage_index.py
"""

from __future__ import annotations

import json
from pathlib import Path

import numpy as np
import pandas as pd
from sentence_transformers import SentenceTransformer

HERE = Path(__file__).resolve().parent
SEED = HERE / "coverage_seed.jsonl"
MODEL = "BAAI/bge-small-en-v1.5"


def main() -> None:
    rows = [json.loads(l) for l in SEED.read_text().splitlines() if l.strip()]
    meta = pd.DataFrame(rows)
    texts = meta["text"].fillna("").tolist()
    print(f"embedding {len(texts)} covered angles with {MODEL} ...")
    model = SentenceTransformer(MODEL)
    emb = model.encode(
        texts, batch_size=64, show_progress_bar=True, normalize_embeddings=True
    ).astype("float32")
    np.save(HERE / "embeddings.npy", emb)
    meta.drop(columns=["text"]).assign(text=meta["text"].str.slice(0, 400)).to_parquet(
        HERE / "index_meta.parquet", index=False
    )
    print(f"wrote embeddings.npy {emb.shape} and index_meta.parquet ({len(meta)} rows)")


if __name__ == "__main__":
    main()
