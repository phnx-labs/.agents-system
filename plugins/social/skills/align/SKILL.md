---
name: align
description: "Second-pass audit: score how well a content taxonomy aligns with the audience you actually want to reach. Extracts the real ICP (buyer segments + pains) from the growth/scouting/outreach agents and the named amplifier accounts the social agent engages, scores every subtopic for buyer vs amplifier resonance, and surfaces over-investment, gaps, and a re-weighting. Triggers on: audience alignment, ICP fit, are we reaching the right people, content vs buyer, who is this content for, alignment scorecard."
argument-hint: "[path to a completed social:audit run ($CA_DIR)]"
allowed-tools: Bash(*), Read(*), Write(*), Edit(*)
user-invocable: true
---

# social:align

Runs after `social:audit`. Answers: *does what we post match who we want to reach?* Needs `report/taxonomy_structure.json` + `report/nodes.json` from the audit.

## Phase 1 — Extract the real audience (two sources, parallel subagents)
A content taxonomy is built for *reach*; this step finds whether it serves *conversion*. Pull the audience from the growth side:
- **Buyers (the ICP that pays):** from the scouting/outreach agents — prospect lists (CSVs), ICP definitions, outreach hooks. Extract 3-5 named segments, each with role, company type, top 3 pains, where reached. (For Rush: `sergey` (Scout) + `marc` (Closer) workspaces — `prospects_*.csv`, `AGENTS.md`/`SOUL.md`, outreach memory.)
- **Amplifiers (reach multipliers):** the named accounts the social agent engages (e.g. `emma/TARGETS.md` tiered targets) — who they are, what they reward.

End each extraction brief with: *"Return file:line quotes for every claim. Do NOT paraphrase. If you can't quote it, don't claim it."*

## Phase 2 — Score alignment  (1 opus subagent)
Pass the taxonomy spine (12×3 with draft volumes) + both audience profiles. Dispatch ONE opus `Agent`:
> Score EACH subtopic for resonance with BUYERS (0-3) and AMPLIFIERS (0-3), one-line justification each. Then: pillar-level averages + verdict (amplifier-skewed / balanced / buyer-relevant); OVER-INVESTED subtopics (high draft volume, low buyer resonance); buyer GAPS (pains with no/weak coverage + example angles); a re-weighting (keep-for-amplifiers / dial-down / add-buyer-pillars). Strict JSON → `report/audience_alignment.json`. Spread scores; don't cluster at 2.

## Phase 3 — Report  (`alignment_report.py`)
Builds `report/audience_alignment.md` + the bubble figure (amplifier x buyer, size = draft volume). **The punchline metrics to compute and lead with:**
- volume-weighted buyer score vs amplifier score,
- % of drafts on buyer=0 subtopics,
- corr(volume, buyer).

If the engine is amplifier-skewed (the common result), the deliverable is the re-weighting: keep ~⅓ for amplifier credibility, add buyer-facing pillars for the other ⅔. Feed those buyer pillars into **`social:schedule`**.
