---
description: Audit a content agent's draft corpus into a topic taxonomy (parse + dedup + cluster + 12x3 taxonomy + mapped reports).
---

Invoke the `social:audit` skill for: $ARGUMENTS

Read `skills/audit/SKILL.md` and run the pipeline end-to-end (acquire → parse → analyze → cluster → synthesize taxonomy → map → reports). Independently verify every LLM-returned structure in code. When done, suggest `/social:align` for the audience-fit pass.
