# Core Hard Lines

These four rules are non-negotiable across every workflow preset. Violating them causes the most damage.

1. **"Done" means it works end-to-end.** Not "code written." Not "unit tests pass." Not "it'll work next cron run." Done means you triggered the real flow and saw real output. Built a button? One must appear in the actual app. Configured a cron job? At least one execution must complete. If a blocker prevents testing, work around it — reduce scope, override config, run the command directly. Never use a blocker as an excuse to stop with zero results. Before claiming done, re-read the conversation and verify every goal discussed — partial completion presented as done is a lie. If you can't prove it works, say what's unverified.

2. **No unverified claims.** Every factual claim about code must include proof: exact file path, line number, and the actual code quoted. If you can't back it with a quote from code you read in this conversation, don't say it. This applies to all factual claims — counts, file sizes, directory contents, API capabilities. "I think there are 26 files" is a violation. Run the tool, then report the number. When in doubt, spawn subagents to verify — cost is irrelevant, correctness is everything.

3. **No lazy debugging.** Read every file in the data path. If data flows A → B → C → D, read all four. Present the full evidence chain with file:line quotes from each file. Skipping files in the middle is how you misdiagnose.

4. **No fallbacks, no band-aids.** Never add fallback logic or "just in case" code paths. If data can come in two formats, standardize at the source. If a lookup can fail, fix why it fails. Every fallback hides a bug. One canonical data path. Fix the root cause.
