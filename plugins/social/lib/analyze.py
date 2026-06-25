"""Descriptive + link + entity + n-gram analysis over the clean corpus.

Reads  : data/clean/drafts.parquet, links.parquet
Writes : report/figures/*.png, report/stats.json (machine-readable rollup)
"""

from __future__ import annotations

import json
import re
from collections import Counter
import os
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd

ROOT = Path(os.environ.get("CA_DIR", Path.cwd()))
CLEAN = ROOT / "data" / "clean"
FIG = ROOT / "report" / "figures"
FIG.mkdir(parents=True, exist_ok=True)

# Entities worth tracking (models / labs / products / protocols) in this corpus.
ENTITIES = {
    "Anthropic": r"\banthropic\b",
    "Claude": r"\bclaude\b",
    "OpenAI": r"\bopenai\b",
    "GPT": r"\bgpt[- ]?\d|\bgpt\b",
    "Google/Gemini": r"\bgemini\b|\bdeepmind\b|\bgemma\b",
    "Alibaba/Qwen": r"\bqwen\b|\balibaba\b",
    "Meta/Llama": r"\bllama\b|\bmeta\b",
    "Mistral": r"\bmistral\b",
    "DeepSeek": r"\bdeepseek\b",
    "xAI/Grok": r"\bgrok\b|\bxai\b",
    "Microsoft/Copilot": r"\bcopilot\b|\bmicrosoft\b",
    "Cursor": r"\bcursor\b",
    "GitHub": r"\bgithub\b",
    "MCP": r"\bmcp\b|model context protocol",
    "Agents/agentic": r"\bagent(s|ic)?\b",
    "RAG": r"\brag\b|retrieval[- ]augmented",
    "Evals/benchmarks": r"\beval(s|uation)?\b|\bbenchmark",
    "Fine-tuning": r"fine[- ]?tun",
    "Open-source/weights": r"open[- ](source|model|weight)",
    "Rush": r"\brush\b|getrush",
}

STOP = set(
    """the a an and or but of to in for on with is are be as at by it this that
    you your we our they their he she his her not no do does did so if then than
    from into about over under more most less can will would could should may
    just like one two now new what who how why when where which while because its
    it's i'm don't isn't you're they're we're that's there here some any all into
    out up down off only also even more much many less few""".split()
)


def fig_save(name: str) -> None:
    plt.tight_layout()
    plt.savefig(FIG / name, dpi=120, bbox_inches="tight")
    plt.close()


def main() -> None:
    df = pd.read_parquet(CLEAN / "drafts.parquet")
    links = pd.read_parquet(CLEAN / "links.parquet")
    df["month"] = df["date"].str[:7]
    df["blob"] = (df["text"].fillna("") + " " + df["story"].fillna("")).str.lower()

    stats: dict = {}
    stats["totals"] = {
        "drafts": int(len(df)),
        "unique_texts": int(df["text_hash"].nunique()),
        "duplicates": int(df["is_dup"].sum()),
        "links": int(len(links)),
        "unique_urls": int(links["url"].nunique()),
        "unique_domains": int(links["domain"].nunique()),
        "date_min": df["date"].dropna().min(),
        "date_max": df["date"].dropna().max(),
        "sent": int(df["sent"].sum()),
    }
    stats["by_account"] = df["account"].value_counts().to_dict()
    stats["by_platform"] = df["platform"].value_counts().to_dict()
    stats["existing_themes"] = df[df["theme"] != ""]["theme"].value_counts().to_dict()
    stats["no_theme"] = int((df["theme"] == "").sum())

    # --- temporal cadence ---
    cad = df.dropna(subset=["date"]).groupby("date").size()
    cad.index = pd.to_datetime(cad.index)
    plt.figure(figsize=(12, 4))
    cad.resample("W").sum().plot(color="#2563eb")
    plt.title("Emma drafts per week")
    plt.ylabel("drafts")
    fig_save("cadence_weekly.png")

    # drafts per month per platform
    mp = df.dropna(subset=["month"]).groupby(["month", "platform"]).size().unstack(fill_value=0)
    mp.plot(kind="bar", figsize=(10, 4))
    plt.title("Drafts per month by platform")
    fig_save("by_month_platform.png")
    stats["by_month"] = df.dropna(subset=["month"]).groupby("month").size().to_dict()

    # --- existing themes over time ---
    tt = (
        df[df["theme"] != ""]
        .dropna(subset=["month"])
        .groupby(["month", "theme"])
        .size()
        .unstack(fill_value=0)
    )
    tt.plot(kind="area", figsize=(12, 5), alpha=0.8)
    plt.title("Existing themes over time (drafts)")
    plt.legend(fontsize=7, ncol=2)
    fig_save("themes_over_time.png")

    # --- domains ---
    topdom = links["domain"].value_counts().head(25)
    stats["top_domains"] = topdom.to_dict()
    topdom[::-1].plot(kind="barh", figsize=(9, 8), color="#0891b2")
    plt.title("Top 25 cited domains (sources + references)")
    fig_save("top_domains.png")

    # most-cited individual URLs
    top_urls = (
        links.groupby("url")
        .agg(n=("draft_id", "nunique"), label=("label", "first"), domain=("domain", "first"))
        .sort_values("n", ascending=False)
        .head(40)
        .reset_index()
    )
    stats["top_urls"] = top_urls.to_dict(orient="records")
    stats["source_vs_reference"] = links["kind"].value_counts().to_dict()

    # --- entity mentions ---
    ent_counts = {}
    for name, pat in ENTITIES.items():
        rx = re.compile(pat, re.I)
        ent_counts[name] = int(df["blob"].str.contains(rx).sum())
    ent_counts = dict(sorted(ent_counts.items(), key=lambda kv: -kv[1]))
    stats["entity_mentions"] = ent_counts
    pd.Series(ent_counts).head(20)[::-1].plot(kind="barh", figsize=(9, 7), color="#7c3aed")
    plt.title("Entity / topic mentions (drafts containing term)")
    fig_save("entity_mentions.png")

    # --- top bigrams (cheap salient-term scan) ---
    tokpat = re.compile(r"[a-z][a-z'\-]+")
    big = Counter()
    for blob in df["text"].fillna("").str.lower():
        toks = [t for t in tokpat.findall(blob) if t not in STOP and len(t) > 2]
        for i in range(len(toks) - 1):
            if toks[i] not in STOP and toks[i + 1] not in STOP:
                big[(toks[i], toks[i + 1])] += 1
    stats["top_bigrams"] = [
        {"bigram": f"{a} {b}", "n": n} for (a, b), n in big.most_common(60)
    ]

    (ROOT / "report" / "stats.json").write_text(json.dumps(stats, indent=2, default=str))
    print("WROTE report/stats.json and", len(list(FIG.glob("*.png"))), "figures")
    print("totals:", stats["totals"])
    print("top entities:", list(ent_counts.items())[:8])
    print("top domains:", list(stats["top_domains"].items())[:8])


if __name__ == "__main__":
    main()
