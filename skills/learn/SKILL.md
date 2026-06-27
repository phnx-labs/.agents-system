---
name: learn
description: "Post-session reflection that writes durable improvements forward. After a substantial session, recall what was actually used, distill only the lessons that generalize, and route each to its right home — a skill, a rule, a memory, or nothing. Built to NOT downgrade existing workflows and NOT overfit to one session. Triggers on: 'learn from this', 'reflect and improve', 'update your skills', 'what did we learn', 'capture the lesson', 'retro', 'post-mortem this session'."
argument-hint: "[empty = current session | session-id | topic to reflect across]"
allowed-tools: Bash(agents *), Bash(git *), Bash(rg *), Bash(fd *), Bash(ls *), Bash(cat *), Bash(jq *), Read(*), Write(*), Edit(*), Task(*)
user-invocable: true
---

# learn

You just finished real work. Some of it taught you something — a tool that behaved differently than you assumed, a step you had to rediscover, a correction the user made twice. This skill turns that into a durable improvement to your own skills, rules, or memory, so the next agent (or you, next week) starts ahead of where you started.

It is the opposite failure mode that makes this hard. The lazy output is to encode nothing. The eager output is to encode everything — to overfit a permanent rule to one session's fluke, or to rewrite a battle-tested skill around a single bad afternoon. Both degrade the system. Your job is the narrow middle: the few lessons that are real, general, and durable — and the discipline to ship them without breaking what already works.

**Not `reflect`.** `reflect` is mid-conversation: it recalls the user's feedback before your next attempt and writes nothing. `learn` is post-session: it writes durable lessons forward into the skill library. Different jobs — don't conflate them.

## Phase 1 — Recall, grounded

Reconstruct what actually happened, from evidence, not impression.

- **What did the session use?** The skills, commands, plugins, and tools you invoked. Name them.
- **Where was the friction?** Retries, dead-ends, manual workarounds, a five-call detour that should have been one, a thing you had to rediscover live, a correction the user gave you. Each friction point is a candidate lesson — cite the concrete moment (a quoted user line, a tool-call sequence, a file:line).
- **What's the improvable surface?** `agents inspect <user|system|project> --json` lists the skills/commands/rules/plugins you could touch. **Read** the specific skills the session leaned on before proposing any change — you cannot improve, or avoid downgrading, what you have not read.

If `$ARGUMENTS` names a session id or a topic, pull it with `agents sessions` and reflect across that instead of the current conversation.

## Phase 2 — Check the plugins for their own learning guidance

Before you decide how to encode anything, see whether the plugins this session used ship their own reflection guidance — a skill named `learn`, `develop`, `improve`, or similar inside the plugin. For each plugin you used:

```bash
fd -t f 'SKILL.md' ~/.agents/.system/plugins/<plugin>/skills ~/.agents/plugins/<plugin>/skills 2>/dev/null \
  | xargs grep -l -iE 'name: (learn|develop|improve|reflect)' 2>/dev/null
```

If a plugin has one (e.g. `code:learn`), **read it and follow its domain-specific routing** — it knows where lessons about *that* plugin's features belong, what its skills already cover, and what its conventions are. This is how `learn` stays smart about specialized surfaces without hard-coding every plugin's internals. If a plugin has none, the general method below still applies — you don't need permission to reflect on a plugin that hasn't documented how.

## Phase 3 — Distill, then filter hard

Write each candidate lesson as one line. Then put every candidate through four gates. A candidate must pass **all four** to earn a durable edit:

1. **Generalization.** Name 2-3 *different future* situations where this lesson would help. If the only situation you can name is the one that just happened, it's an incident, not a pattern.
2. **Recurrence.** Has this bitten before, or is it likely to bite again? A service that was down, a one-time flake, a typo — transient and environmental one-offs don't earn permanent edits.
3. **Root cause.** Is this the actual cause, or a surface symptom? Encode the cause.
4. **Durability.** Will it still be true in six months, or is it pinned to a version/repo state that will change? Volatile facts go to dated memory, not a skill.

**Show your rejects.** List the candidates you dropped and which gate they failed. A learn pass that encodes every candidate isn't thorough — it's overfitting. The rejects are proof the filter ran.

## Phase 4 — Route each survivor to its home

| The lesson is… | It goes to… |
|---|---|
| A principle that should constrain every session | a rule: `~/.agents/rules/subrules/<name>.md` (a new name unions into the `default` preset) |
| A reusable capability or procedure | a new skill, or a new **section** in the most relevant existing skill |
| A gotcha about one tool | that tool's skill |
| A user preference / recurring behavior | a named memory: `~/.claude/memory/<slug>.md` (+ an index line in `MEMORY.md`) |
| A one-off machine/context fix | dated memory: `~/.agents/memory/<YYYY-MM-DD>.md` |
| Real but not generalizable | **nothing** — drop it |

"Drop it" is a valid, common outcome. Most sessions yield zero to two durable lessons.

## Phase 5 — Edit without downgrading

- **Read the target fully first**, and understand why it's shaped the way it is. Guidance you don't understand, you can't safely change.
- **Prefer additive.** A new section or a new skill beats rewriting prose that already works. Battle-tested wording earned its shape.
- **If you change existing guidance, quote the old text** and state why the change doesn't break the cases it currently serves.
- **Minimal, scoped diff.** No drive-by refactors, renames, or reorganizations. Touch only what the lesson requires.

## Phase 6 — Verify, then ship

- **Verify.** If the lesson touched an executable artifact (a script, a command), run it end-to-end — that's how you catch the bug in your own fix. For prose edits, re-read them in context to be sure they don't contradict the guidance around them.
- **Ship, for repo-backed config.** Changes to `~/.agents` or `~/.agents/.system` are real releases: work in a worktree, bump the version + `CHANGELOG`, commit, push, open a PR, and tag on merge (`/git:tag-release` handles the tag). **Present the proposed lessons and diffs to the user before committing** — a human saying "that one's overfit" is the cheapest, best filter you have.

## Evidence

Every lesson you claim cites the moment that earned it — a quoted correction, a tool-call trace, a file:line. A lesson you can't ground is a hunch; drop it. When you hand any part of this to a sub-agent, end the brief with: `Return file:line quotes for every claim. Do NOT paraphrase. If you can't quote it, don't claim it.`
