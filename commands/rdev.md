---
description: Dispatch engineering task to a coding agent (Claude/Codex) on mac-mini
---

$ARGUMENTS

Load the `dev` skill for pipeline details (auth, label IDs, SSH commands, monitoring).

You have a pipeline that dispatches engineering tasks to coding agents (Claude, Codex) running on mac-mini. The user might give you anything: a vague idea, a keyword, a request to find work, or a specific RUSH-NNN issue number. Figure out what they want and make it happen.

**Linear API key**: available as `$LINEAR_API_KEY` in env. Use GraphQL at `https://api.linear.app/graphql`. Team ID: `0a82ae7e-b144-4e4f-a333-bcbaf9a2ccc2`.

**To dispatch**: add an `agent:*` label to a Linear issue. The webhook fires automatically. See the `dev` skill for label IDs and monitoring commands.

**Before dispatching**: make sure the issue description is agent-ready -- specific file paths, clear scope, out-of-scope section. If it's vague, rewrite it. Agents with good context succeed; agents without context fail.
