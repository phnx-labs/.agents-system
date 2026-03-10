# Linear — Task Management for Getrush

Access and manage the Getrush sprint board. Use this skill to find your tasks, update status, and stay in sync with the team.

## Key Facts

- **Team:** Getrush (`0a82ae7e-b144-4e4f-a333-bcbaf9a2ccc2`)
- **API key:** stored in `~/.zshrc` on mac-mini as `$LINEAR_API_KEY`, and in `~/.claude/settings.json` MCP config locally
- **API endpoint:** `https://api.linear.app/graphql`
- **App URL:** `https://linear.app/getrush`

## Sprint Structure

3 weekly sprints (Mon–Fri). Weekends = review/close loops only.

| Sprint | Dates | Focus |
|--------|-------|-------|
| Sprint 1 — GTC Prep | Mar 10–14 | Launch blockers, critical bugs, Tier 1 directories |
| Sprint 2 — GTC Launch | Mar 16–21 | New agents, GTC wave, Tier 2-3 distribution |
| Sprint 3 — Final Push | Mar 23–28 | Close gaps, hit 125 paying users |

**Revenue target:** $5,000 MRR by March 31 = ~125 paying users at $40 ARPU blended ($29 Basic / $79 Plus for Rabbit Hole). Need ~9 new paying users per weekday.

## Labels

| Label | Meaning |
|-------|---------|
| `engineering` | Code, infra, bugs, agent builds |
| `growth` | Distribution, outreach, content, directories |
| `today` | Must ship today |
| `this-week` | Sprint commitment |
| `agent:claude` | Claude works this |
| `agent:codex` | Codex works this |
| `agent:sergey` | Sergey (Scout) works this |
| `agent:paul` | Paul (Writer) works this |
| `agent:emma` | Emma (Voice) works this |
| `agent:marc` | Marc (Closer) works this |
| `users:1/5/10/50+` | Estimated paying users this unlocks (Growth issues) |

## How to Query Your Tasks (GraphQL)

### Get this sprint's issues

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "{ team(id: \"0a82ae7e-b144-4e4f-a333-bcbaf9a2ccc2\") { activeCycle { issues { nodes { identifier title state { name } labels { nodes { name } } priority } } } } }"
  }' | python3 -m json.tool
```

### Get issues assigned to you (by agent label)

Replace `YOUR_LABEL` with e.g. `agent:codex`, `agent:sergey`, etc.

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "{ issues(filter: { team: { id: { eq: \"0a82ae7e-b144-4e4f-a333-bcbaf9a2ccc2\" } }, labels: { name: { eq: \"YOUR_LABEL\" } }, state: { type: { neq: \"completed\" } } }) { nodes { identifier title state { name } labels { nodes { name } } } } }"
  }' | python3 -m json.tool
```

### Get today's issues

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "{ issues(filter: { team: { id: { eq: \"0a82ae7e-b144-4e4f-a333-bcbaf9a2ccc2\" } }, labels: { name: { eq: \"today\" } }, state: { type: { neq: \"completed\" } } }) { nodes { identifier title description state { name } labels { nodes { name } } } } }"
  }' | python3 -m json.tool
```

### Mark an issue In Progress

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "mutation { issueUpdate(id: \"ISSUE_ID\", input: { stateId: \"034a35aa-8f8e-455a-94da-0eeb4b09dee5\" }) { success } }"
  }'
```

### Mark an issue Done

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "mutation { issueUpdate(id: \"ISSUE_ID\", input: { stateId: \"6e73a9ed-9a0e-4d98-b66b-449298dc66f3\" }) { success } }"
  }'
```

## State IDs (reference)

| State | ID |
|-------|----|
| Backlog | `d7b21969-8ce6-4fc3-a616-6d1ff0823e0c` |
| Todo | `133aac2b-50e4-42a5-9d6e-c72e6f9c3540` |
| In Progress | `034a35aa-8f8e-455a-94da-0eeb4b09dee5` |
| Done | `6e73a9ed-9a0e-4d98-b66b-449298dc66f3` |

## If You Have Linear MCP (Claude/Codex)

Use the MCP tools directly instead of curl — they're faster and typed:
- `linear_get_issues` — list issues with filters
- `linear_update_issue` — update state, labels
- `linear_create_issue` — create new issues

## What to Do at Session Start

1. Query the active cycle for your agent label
2. Pick the highest-priority incomplete issue
3. Mark it In Progress
4. Work it
5. Mark it Done
6. Repeat

If no issues are labeled for you, query the active cycle for unlabeled `engineering` or `growth` issues and pick the highest-priority one.

## Revenue Pace Check

At session start, also hit the dashboard to know today's number:

```bash
rush http GET "/api/v1/dashboard?range=1" 2>/dev/null | python3 -c "
import json, sys
from datetime import date

d = json.load(sys.stdin)
mrr = d['growth']['revenue']['mrr']
subs = d['growth']['revenue']['activeSubscriptions']
today = date.today()
mar31 = date(2026, 3, 31)
days_left = (mar31 - today).days
weekdays_left = sum(1 for i in range(days_left) if (today.toordinal() + i) % 7 not in (6, 0))
target_users = 125
needed = max(0, target_users - subs)
pace = round(needed / weekdays_left, 1) if weekdays_left > 0 else needed
print(f'MRR: \${mrr} | Paying users: {subs}/125 | Days left: {days_left} | Need {pace} new paying users/weekday')
"
```
