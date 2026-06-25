"""Tests for the tolerant JSON repair logic in parse.py.

Each test exercises one real malformation found in Emma's corpus.
Run: uv run pytest src/parse_test.py -q
"""

import json

from parse import load_tolerant, _salvage_partial


def _write(tmp_path, name, content):
    p = tmp_path / name
    p.write_text(content, encoding="utf-8")
    return p


def test_clean_json(tmp_path):
    p = _write(tmp_path, "ok.json", '{"account":"@x","drafts":[{"text":"hi"}]}')
    data, rep = load_tolerant(p)
    assert rep is False
    assert data["drafts"][0]["text"] == "hi"


def test_raw_newline_in_string(tmp_path):
    # Literal newline inside a value (invalid JSON control char).
    p = _write(tmp_path, "nl.json", '{"account":"@x","drafts":[{"text":"a\nb"}]}')
    data, rep = load_tolerant(p)
    assert rep is True
    assert data["drafts"][0]["text"] == "a\nb"


def test_bad_backslash_escape(tmp_path):
    # JS-style \' is illegal in JSON.
    p = _write(tmp_path, "esc.json", '{"account":"@x","drafts":[{"text":"isn\\\'t"}]}')
    data, rep = load_tolerant(p)
    assert rep is True
    assert "isn" in data["drafts"][0]["text"]


def test_interior_unescaped_quote(tmp_path):
    # Pretty-printed line with an unescaped interior double-quote.
    content = (
        '{\n  "account": "@x",\n  "drafts": [\n'
        '    {\n      "text": "the pitch was "9,000 things" today"\n    }\n  ]\n}'
    )
    p = _write(tmp_path, "q.json", content)
    data, rep = load_tolerant(p)
    assert rep is True
    assert "9,000 things" in data["drafts"][0]["text"]


def test_salvage_truncated(tmp_path):
    # First draft complete, second draft truncated mid-write.
    content = (
        '{"account":"@x","drafts":[{"text":"first","theme":"t1"},'
        '{"text":"second incomplete'
    )
    p = _write(tmp_path, "trunc.json", content)
    data, rep = load_tolerant(p)
    assert rep is True
    assert len(data["drafts"]) == 1
    assert data["drafts"][0]["text"] == "first"


def test_unrecoverable_empty(tmp_path):
    p = _write(tmp_path, "empty.json", "")
    data, rep = load_tolerant(p)
    assert data is None


def test_salvage_no_complete_draft(tmp_path):
    # Truncated before the first draft object closes -> nothing to salvage.
    assert _salvage_partial('{"account":"@x","drafts":[{"text":"half') is None
