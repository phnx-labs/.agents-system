# social

Turn a content agent's pile of drafts/posts into a usable content strategy. Built from a real audit of ~4,600 social drafts; every phase maps to a step that produced a decision.

**Why it exists:** a content engine usually fails not on writing quality but on (1) repetition, (2) no map of what it covers, and (3) optimizing for the wrong audience. This plugin measures all three and produces the fix.

## Sub-skills

| Skill | Does | Phases |
|---|---|---|
| `social:audit` | Pull a corpus → tolerant parse + dedup → descriptive analysis → embedding clusters → LLM-synthesized topic taxonomy (12×3) → map every draft → reports | acquire, parse, analyze, cluster, taxonomy, map |
| `social:align` | Extract the real ICP/audience from the growth side, score every subtopic for buyer vs amplifier resonance, flag over-investment + gaps + a re-weighting | alignment |
| `social:schedule` | Generate angles/posts per pillar, gate them through a semantic coverage index (no re-skins), enforce the engagement rubric, schedule to X/LinkedIn via getlate | backlog, distribute |

Run them in order for a full audit, or any one standalone.

## Shared `lib/`
Python pipeline (run with `uv`, scripts read the working dir from `$CA_DIR`):
`parse.py`(+`parse_test.py`) · `analyze.py` · `perf_audit.py` · `cluster.py` · `map_taxonomy.py` · `alignment_report.py` · `build_reports.py` · `diagrams.py` · `coverage_index/{build,check,record}_*.py` · `build_schedule.py` · `schedule_posts.py`.

## Setup (once per run)
```bash
export CA_DIR=/path/to/work/social-audit-<agent>-<date>
mkdir -p "$CA_DIR"/{data/raw/drafts,data/raw/context,data/clean,report/figures} && cd "$CA_DIR"
uv init -q -p 3.12 . && uv add -q pandas pyarrow tldextract matplotlib \
  sentence-transformers scikit-learn hdbscan umap-learn plotly kaleido && uv add -q --dev pytest
LIB="$(dirname "$(dirname "$0")")/lib"   # plugin lib; or hardcode the plugin path
```
Then `CA_DIR=$CA_DIR uv run python $LIB/<script>.py`.

## Cross-cutting lessons (don't relearn)
- `rush http` prefixes output with a `200 OK` line — strip to the first `{` before JSON-parsing.
- bge-small on a single-topic corpus runs *hot* (median nearest-neighbor ~0.91) — calibrate dedup thresholds empirically (~0.90/0.95), never hardcode 0.80.
- Verify every LLM-returned structure in code (counts reconcile, 0 unassigned, no fabricated URLs). Trust nothing self-reported.
- The taxonomy serves the *amplifier* play by default; `social:align` is what catches that you're ignoring the buyer.
- Publishing to live accounts is gated — confirm with the user and let THEM run the scheduler.
