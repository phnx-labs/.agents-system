---
name: audit
description: "Audit a content agent's full draft/post corpus: tolerant-parse + dedup the archive, run descriptive analysis (cadence, domains, entities, dup/padding/sourcing health), embed + cluster it into micro-topics, and synthesize a MECE topic taxonomy (12 pillars x 3 subtopics) with every draft mapped to it. Produces analysis.md, taxonomy.md, drafts_mapped.csv, and figures. Triggers on: content audit, analyze our posts/drafts, topic taxonomy, content taxonomy, what do we post about, content gap analysis."
argument-hint: "[agent name or corpus path] e.g. 'emma'"
allowed-tools: Bash(*), Read(*), Write(*), Edit(*)
user-invocable: true
---

# social:audit

Corpus → clean dataset → topic taxonomy. The analysis core. Set up `$CA_DIR` + deps per the plugin README, then `LIB=<plugin>/lib`.

## Phase 0 — Acquire
Pull the agent's drafts (JSON with a `drafts[]` array of `{text, theme?, sources[], references[]}`) into `$CA_DIR/data/raw/drafts/`. For an OpenClaw agent:
```bash
rsync -az --include='*.json' --exclude='*' muqsit@mac-mini:/Users/muqsit/.openclaw/<agent>/drafts/ "$CA_DIR/data/raw/drafts/"
rsync -az muqsit@mac-mini:/Users/muqsit/.openclaw/<agent>/COVERED.md "$CA_DIR/data/raw/context/" 2>/dev/null || true
ssh muqsit@mac-mini "cd .openclaw/<agent>/drafts && ls -1 *.pdf.sent 2>/dev/null" > "$CA_DIR/data/raw/sent_markers.txt" || true
```

## Phase 1 — Parse & clean  (`parse.py` + `parse_test.py`)
Tolerant loader repairs the 4 real malformations (raw control chars in strings, invalid `\'` escapes, unescaped interior quotes, truncated files via object-salvage). Emits `drafts.parquet/jsonl` + `links.parquet` + dedup flags.
```bash
CA_DIR=$CA_DIR uv run python $LIB/parse.py
cd $LIB && CA_DIR=$CA_DIR uv run pytest parse_test.py -q
```
Reconcile the printed totals (drafts, recovered, account/platform split, URLs) before continuing.

## Phase 2 — Descriptive analysis  (`analyze.py`, `perf_audit.py`)
`analyze.py` → `report/stats.json` + figures (cadence, themes-over-time, top domains, entities, bigrams). `perf_audit.py` → `report/perf_audit.json`: dup rate over time, volume↔dup correlation (padding signal), tag coverage, sourcing concentration. These quantify the "dead drafts" failure mode.

## Phase 3 — Discover topics  (`cluster.py`)
Local embeddings (bge-small) → UMAP(10d) → HDBSCAN → ~30-60 micro-clusters (noise reassigned to nearest centroid so every draft gets one). → `report/clusters.json` + `drafts_clustered.parquet`. Tune `MIN_CLUSTER_SIZE` to land 30-55 clusters.

## Phase 4 — Synthesize the taxonomy  (1 opus subagent)
Build a bundle (clusters + existing themes + COVERED.md headings + top entities/domains) and dispatch ONE opus `Agent`:
> Consolidate these N clusters + existing themes + narrative threads into a MECE taxonomy: 12 pillars × 3 subtopics. Assign EVERY cluster id to EXACTLY ONE subtopic (none missing, none duplicated). Name pillars in the brand voice. Write strict JSON to `report/taxonomy_structure.json` `{pillars:[{id,name,description,subtopics:[{id,name,description,cluster_ids:[]}]}]}`. Verify all cluster ids appear once; report per-pillar draft totals.

**Independently verify in code** (12×3, every cluster mapped once, totals reconcile) — never trust the agent's self-report.

## Phase 5 — Map drafts → taxonomy  (`map_taxonomy.py`)
Propagates cluster→pillar/subtopic to all drafts (`drafts_mapped.csv/jsonl/parquet`, assert 0 unassigned) and builds `report/nodes.json` (per-subtopic rollup: counts, platform split, keywords, reps, top links).

## (optional) Phase 6 — Angles  (parallel subagents, one per pillar)
Split `nodes.json` per pillar → `report/leaf_inputs/pillar_N.json`. Fan out one sonnet `Agent` per pillar: *"for each subtopic, 9 distinct ready-to-write angles grounded in the cluster reps/keywords, each with 1-3 URLs drawn ONLY from that subtopic's top_links (never invent), tagged platform → report/leaves/pillar_N.json."* Verify counts; drop any URL not in `links.jsonl`.

## Reports
`build_reports.py` → `analysis.md`, `taxonomy.md`, `content_backlog.md`. `diagrams.py` → `taxonomy_sunburst/treemap.png`. PDF via `pandoc <md> -f gfm --pdf-engine=typst`.

Hand off to **`social:align`** for the audience-fit second pass.
