"""Parse Emma's draft JSON corpus into clean datasets.

Inputs : data/raw/drafts/*.json  (each file = {account, drafts:[{...}]})
         data/raw/sent_markers.txt (list of *.pdf.sent filenames)
Outputs: data/clean/drafts.parquet + drafts.jsonl  (one row per draft)
         data/clean/links.jsonl                     (one row per source/reference URL)

Tolerant of malformed files (unescaped control chars U+0000-U+001F).
"""

from __future__ import annotations

import hashlib
import json
import re
import os
from pathlib import Path

import pandas as pd
import tldextract

ROOT = Path(os.environ.get("CA_DIR", Path.cwd()))
RAW = ROOT / "data" / "raw" / "drafts"
CLEAN = ROOT / "data" / "clean"
SENT_MARKERS = ROOT / "data" / "raw" / "sent_markers.txt"

# Control chars that break json.load when unescaped inside strings.
_CTRL = re.compile(r"[\x00-\x08\x0b\x0c\x0e-\x1f]")
# Invalid JSON escapes Emma's generator sometimes emits (JS-style \' ).
# Valid JSON escapes after a backslash: " \ / b f n r t u. Anything else
# (notably \') is illegal -> drop the stray backslash.
_BAD_ESC = re.compile(r'\\([^"\\/bfnrtu])')
# A pretty-printed string-valued line: indent + "key": "value"  (opt trailing comma).
# Emma's drafts keep each field on its own physical line (newlines are literal \n),
# so unescaped interior quotes in the value can be re-escaped safely.
_STR_LINE = re.compile(r'^(\s*"[A-Za-z_]+":\s*")(.*)("[ \t]*,?[ \t]*)$')


def _escape_ctrl_in_strings(text: str) -> str:
    """Walk the JSON; escape raw control chars (newlines/tabs) that sit inside
    string literals, leaving structural whitespace between tokens untouched."""
    out = []
    in_str = False
    esc = False
    for ch in text:
        if esc:
            out.append(ch)
            esc = False
            continue
        if ch == "\\":
            out.append(ch)
            esc = True
            continue
        if ch == '"':
            in_str = not in_str
            out.append(ch)
            continue
        if in_str and ord(ch) < 0x20:
            out.append(f"\\u{ord(ch):04x}")
            continue
        out.append(ch)
    return "".join(out)


def _fix_interior_quotes(text: str) -> str:
    out = []
    for line in text.split("\n"):
        m = _STR_LINE.match(line)
        if m:
            prefix, value, suffix = m.group(1), m.group(2), m.group(3)
            # Escape any double-quote in the value that isn't already escaped.
            value = re.sub(r'(?<!\\)"', r'\\"', value)
            out.append(prefix + value + suffix)
        else:
            out.append(line)
    return "\n".join(out)
# A date embedded in the filename, e.g. themuqsit-2026-06-23-2330.json
_DATE = re.compile(r"(20\d{2})-(\d{2})-(\d{2})")
_EXTRACT = tldextract.TLDExtract(suffix_list_urls=())  # offline, no network


def load_tolerant(path: Path) -> tuple[dict | None, bool]:
    """Return (data, was_repaired). Escapes raw control chars and retries."""
    text = path.read_text(encoding="utf-8", errors="replace")
    try:
        return json.loads(text), False
    except json.JSONDecodeError:
        # 1) Escape raw control chars inside string literals (newlines/tabs),
        #    then strip invalid backslash escapes (\').
        repaired = _escape_ctrl_in_strings(text)
        repaired = _BAD_ESC.sub(r"\1", repaired)
        try:
            return json.loads(repaired), True
        except json.JSONDecodeError:
            pass
        # 2) Re-escape unescaped interior quotes line-by-line.
        repaired = _fix_interior_quotes(repaired)
        try:
            return json.loads(repaired), True
        except json.JSONDecodeError:
            pass
        # 3) File is truncated/corrupt: salvage complete draft objects.
        salv = _salvage_partial(repaired)
        if salv is not None:
            return salv, True
        return None, False


def _salvage_partial(text: str) -> dict | None:
    """Pull whatever complete draft objects exist before a truncation point."""
    am = re.search(r'"account"\s*:\s*"([^"]*)"', text)
    account = am.group(1) if am else ""
    start = text.find('"drafts"')
    if start == -1:
        return None
    lb = text.find("[", start)
    if lb == -1:
        return None
    dec = json.JSONDecoder()
    i = lb + 1
    drafts = []
    n = len(text)
    while i < n:
        while i < n and text[i] in " \t\r\n,":
            i += 1
        if i >= n or text[i] == "]":
            break
        try:
            obj, end = dec.raw_decode(text, i)
        except json.JSONDecodeError:
            break  # hit the truncated object
        if isinstance(obj, dict):
            drafts.append(obj)
        i = end
    return {"account": account, "drafts": drafts} if drafts else None


def platform_of(account: str, fname: str) -> str:
    a = (account or "").lower()
    f = fname.lower()
    if "linkedin" in a or f.startswith("linkedin"):
        return "LinkedIn"
    if "getrushos" in a or f.startswith("getrushos") or "getrush" in a:
        return "X"  # @GetRushOS is an X handle
    if "themuqsit" in a or f.startswith("themuqsit"):
        return "X"
    return "Other"


def norm_account(account: str, fname: str) -> str:
    """Collapse the messy account labels to canonical handles."""
    a = (account or "").strip()
    al = a.lower()
    f = fname.lower()
    if "linkedin" in al or f.startswith("linkedin") or "muqsit nawaz" in al:
        return "LinkedIn"
    if "getrush" in al or f.startswith("getrushos"):
        return "@GetRushOS"
    if "themuqsit" in al or f.startswith("themuqsit"):
        return "@themuqsit"
    return a or "unknown"


def date_from_name(fname: str) -> str | None:
    m = _DATE.search(fname)
    return f"{m.group(1)}-{m.group(2)}-{m.group(3)}" if m else None


def domain_of(url: str) -> str:
    try:
        ext = _EXTRACT(url)
        if ext.domain and ext.suffix:
            return f"{ext.domain}.{ext.suffix}".lower()
        return (ext.domain or "").lower()
    except Exception:
        return ""


def norm_text(text: str) -> str:
    return re.sub(r"\s+", " ", (text or "").strip().lower())


def main() -> None:
    sent_set = set()
    if SENT_MARKERS.exists():
        for line in SENT_MARKERS.read_text().splitlines():
            line = line.strip()
            if line.endswith(".pdf.sent"):
                sent_set.add(line[: -len(".pdf.sent")])  # base name w/o ext

    files = sorted(RAW.glob("*.json"))
    rows: list[dict] = []
    link_rows: list[dict] = []
    repaired = 0
    failed: list[str] = []

    for path in files:
        data, was_rep = load_tolerant(path)
        if data is None:
            failed.append(path.name)
            continue
        repaired += int(was_rep)
        stem = path.stem  # filename w/o .json
        account_raw = data.get("account", "")
        account = norm_account(account_raw, path.name)
        platform = platform_of(account_raw, path.name)
        date = date_from_name(path.name)
        sent = stem in sent_set
        drafts = data.get("drafts", [])
        if not isinstance(drafts, list):
            drafts = []
        for i, dr in enumerate(drafts):
            if not isinstance(dr, dict):
                continue
            text = dr.get("text", "") or ""
            did = f"{stem}#{i}"
            sources = dr.get("sources") or []
            references = dr.get("references") or []
            rows.append(
                {
                    "id": did,
                    "file": path.name,
                    "draft_idx": i,
                    "account": account,
                    "account_raw": account_raw,
                    "platform": platform,
                    "date": date,
                    "sent": sent,
                    "type": dr.get("type", ""),
                    "theme": dr.get("theme", ""),
                    "text": text,
                    "context": dr.get("context", "") or "",
                    "story": dr.get("story", "") or "",
                    "image": dr.get("image", "") or "",
                    "n_sources": len(sources) if isinstance(sources, list) else 0,
                    "n_references": len(references)
                    if isinstance(references, list)
                    else 0,
                    "text_hash": hashlib.md5(norm_text(text).encode()).hexdigest(),
                    "word_count": len(text.split()),
                }
            )
            for kind, lst in (("source", sources), ("reference", references)):
                if not isinstance(lst, list):
                    continue
                for item in lst:
                    if not isinstance(item, dict):
                        continue
                    url = (item.get("url") or "").strip()
                    if not url:
                        continue
                    link_rows.append(
                        {
                            "draft_id": did,
                            "account": account,
                            "platform": platform,
                            "date": date,
                            "kind": kind,
                            "label": item.get("label", "") or "",
                            "url": url,
                            "domain": domain_of(url),
                        }
                    )

    df = pd.DataFrame(rows)
    # Duplicate grouping: identical normalized text -> same dup_group.
    df["dup_group"] = df.groupby("text_hash").ngroup()
    df["is_dup"] = df.duplicated("text_hash", keep="first")

    links = pd.DataFrame(link_rows)

    CLEAN.mkdir(parents=True, exist_ok=True)
    df.to_parquet(CLEAN / "drafts.parquet", index=False)
    df.to_json(CLEAN / "drafts.jsonl", orient="records", lines=True, force_ascii=False)
    links.to_json(
        CLEAN / "links.jsonl", orient="records", lines=True, force_ascii=False
    )
    links.to_parquet(CLEAN / "links.parquet", index=False)

    # ---- verification report ----
    print(f"json files parsed : {len(files) - len(failed)} / {len(files)}")
    print(f"repaired (ctrl)   : {repaired}")
    print(f"unrecoverable     : {len(failed)} {failed[:5]}")
    print(f"total drafts      : {len(df)}")
    print(f"unique texts      : {df['text_hash'].nunique()}  (dups: {df['is_dup'].sum()})")
    print(f"total link rows   : {len(links)}")
    print("account split     :")
    print(df["account"].value_counts().to_string())
    print("platform split    :")
    print(df["platform"].value_counts().to_string())
    print(f"sent drafts       : {df['sent'].sum()}")
    print(f"with theme        : {(df['theme'].astype(bool) & (df['theme'] != '')).sum()}")
    print(f"date range        : {df['date'].dropna().min()} -> {df['date'].dropna().max()}")


if __name__ == "__main__":
    main()
