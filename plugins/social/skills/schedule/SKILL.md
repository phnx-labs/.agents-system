---
name: schedule
description: "Generate a deduped, on-rubric content backlog and schedule it to X/LinkedIn via the getlate pipeline. Builds a semantic coverage index so nothing re-skins a prior post, drafts platform-tailored posts in the channel's house voice (engagement-first, no pitch, comment-prompt, AI-tells scrubbed), and lays out a Tue/Wed/Thu morning schedule. Triggers on: schedule posts, content backlog, draft posts for X/LinkedIn, queue social posts, getlate, dedup posts."
argument-hint: "[path to a completed run ($CA_DIR), optional pillar focus]"
allowed-tools: Bash(*), Read(*), Write(*), Edit(*)
user-invocable: true
---

# social:schedule

Turns the taxonomy + alignment into scheduled posts. Runs after `social:audit` (and ideally `social:align`).

## Step 1 — Coverage index (dedup gate)  (`lib/coverage_index/`)
Seed from `drafts_mapped`, then `build_coverage_index.py` embeds every prior angle. `check_coverage.py "<candidate>"` → NEW / REVISE_ONLY / TOO_SIMILAR.
**Calibrate thresholds to the corpus** — dense single-topic corpora run hot (median nearest-neighbor ~0.91), so use ~0.90 / 0.95, not 0.80 / 0.88. Validate against a known near-dup before trusting it. `record_covered.py` appends shipped angles so the index stays current.

## Step 2 — Draft posts (subagents, per platform)
Keep the buyer-pillar TOPICS (from `social:align`) but write in the channel's house voice. For Rush, load the `rush:social` rubric and obey it verbatim:
- **Engagement-first** (reactions/comments/reshares, not literary cleverness). **End EVERY post with a comment prompt** — the #1 driver.
- **Product invisible / no pitch** — personal thought-leadership, no CTA, no product name.
- **Kill the AI-tells:** em-dashes (≈zero), the "X isn't A, it's B" inversion, the triadic "X. Then Y. Now Z." cadence, italics-for-emphasis.
- Format: X ≤ 280; LinkedIn 800-1300, short line-broken paragraphs; first person.

Run EVERY candidate through `check_coverage.py`; drop ≥ 0.90. For a batch (4+), run a 3-agent engagement panel (score reach only) and rank.

## Step 3 — Schedule via getlate
`build_schedule.py` lays out Tue/Wed/Thu mornings (16:00Z), alternating platforms, best-first, dodging existing scheduled dates (GET `/api/v1/social/scheduled`; strip `rush http`'s leading `200 OK` line before parsing). `schedule_posts.py` POSTs each via `rush http POST /api/v1/social/post` — one call per platform, body `{platform, text, scheduleDate}`; response gives `postId` (saved so any is one `DELETE /api/v1/social/post/<id>` away).

**Publishing to live accounts is gated** — confirm the final copy + date map with the user, then let THEM run `schedule_posts.py` (the sandbox blocks outward posts). Verify afterward with a `GET /scheduled` count.

## Connected platforms / quota
getlate (rebranded) wraps LinkedIn / X / Reddit / IG; **one POST per platform** (cross-post = N posts = N quota). Quota is account-wide/month — check remaining before a batch.
