---
name: mq
description: "Structure-aware context query for large files — probe structure, then extract only the section you need, instead of reading whole files into context. Works on Markdown, HTML, PDF, JSON, YAML, CSV, XLSX, DOCX, PPTX AND source code (Go/Python/TS/Rust/...). Triggers on: reading any file 200+ lines, exploring a directory you haven't seen, extracting one section/function/endpoint from a large file, searching a topic across many files, 'use mq', or when reading a full file would waste context."
---

# mq Skill: Structure-Aware Context Query

`mq` doesn't compute answers — it externalizes a file's structure into your context so you extract only what you need instead of dumping the whole file. Probe, then extract.

```
File or dir → mq query → structure/section enters your context → you reason → answer
```

## It is NOT a docs-only tool

`mq --help` lists its formats: **Markdown, HTML, PDF, JSON, YAML, CSV, XLSX, DOCX, PPTX, and Code (Go / Python / TS / Rust / …)**. So `mq` maps the structure of a **source file** just as well as a markdown doc:

```bash
mq src/lib/router.ts .tree                       # every function/class + line ranges
mq src/lib/router.ts '.section("handleRequest") | .text'   # just that function
mq config.json .tree                             # JSON key structure
mq data.csv .tree                                # columns + row count
```

Reach for it on the `.ts`/`.py`/`.go` file you were about to `cat` — not only on `README.md`.

## The Pattern

```
1. Map      →  mq <dir>/ '.tree | depth(1)'      → what's here (files, sizes, sections)
2. Narrow   →  mq <file> .tree                     → sections/symbols + line ranges
3. Find     →  mq <path> '.search("term")'         → section-level matches across files
4. Extract  →  mq <file> '.section("Name") | .text'→ only the part you need
5. Reason   →  you compute the answer from what's now in context
```

Your context accumulates structure; you do the final reasoning. Don't re-query what you already see.

## Quick Reference

```bash
# Structure (your working index)
mq file.md .tree            mq page.html .tree        mq report.pdf .tree
mq router.ts .tree          mq config.yaml .tree      mq dir/ .tree

# Search
mq file.md   '.search("term")'      mq report.pdf '.search("term")'
mq src/      '.search("handler")'   mq log.jsonl  '.search("error")'

# Extract
mq file.md   '.section("Name") | .text'    mq api.ts '.section("createUser") | .text'
mq file.md   '.code("python")'             mq page.html .links
mq file.md   .metadata                     mq log.jsonl '.record(7)'
```

## Anti-Patterns

**Bad** — read the whole file when you need one part:
```bash
cat src/lib/router.ts        # dumps 800 lines into context for one function
```
**Good** — map then extract:
```bash
mq src/lib/router.ts .tree                        # see the structure
mq src/lib/router.ts '.section("handleRequest") | .text'   # get only that
```

**Bad** — re-`cat`/`grep` the same large file repeatedly to find different things. That's the single most common waste: the same file gets re-read many times in one session. Map it once with `.tree`; the structure stays in your context.

**Bad** — re-querying structure you already have (`mq dir/ .tree` twice). Use what's in context.

## When to just read

Files under ~100 lines: read them directly, `mq` is overkill. The win is on large files, directories you haven't mapped, and cross-file search.

## Scale

Warm cache (after first parse): a 30K-line markdown dir `.tree` in <1s; 123 PDFs / 365MB `.tree` in ~3s, `.search` in ~4s. Cold PDF parse is slow (minutes) but one-time — the cache persists across sessions, so every later query is sub-second.

## Examples by task

```bash
# Understand a source module          mq src/api.ts .tree ; mq src/api.ts '.section("POST /users") | .text'
# Find how auth works across a repo    mq src/ '.search("auth")' ; mq src/auth.ts '.section("Overview") | .text'
# Pull one section from a big doc      mq GUIDE.md .tree ; mq GUIDE.md '.section("Deploy") | .text'
# Query a PDF report                   mq report.pdf .tree ; mq report.pdf '.section("Results") | .text'
# Inspect a JSONL session              mq session.jsonl '.search("deploy")' ; mq session.jsonl '.record(8)'
```
