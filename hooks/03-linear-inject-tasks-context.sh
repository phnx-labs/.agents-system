#!/bin/bash
# SessionStart hook: inject a short Linear brief + the active-sprint task board.
#
# The brief (top of the injection) gives the agent the who/what it needs before
# picking up work:
#   - Humans     -- the real people on the team (who to defer to / ping).
#   - Agents     -- the agent members that can be assigned work (claude, codex, ...).
#   - Focus      -- if the cwd maps to a Linear project (e.g. this repo `agents-cli`
#                   -> the "Agents CLI" project), its progress, milestones, and top
#                   open issues, so the running agent starts on the project it's in.
# The active-sprint board (grouped by agent label) follows, unchanged.

# Read credentials through the CLI's cross-platform keychain layer (macOS
# Keychain via /usr/bin/security, Linux via secret-tool + encrypted-file
# fallback) instead of hardcoding the macOS-only `security` binary — which
# does not exist on Linux and made this hook print "not found" on every
# launch there. macOS items written by the previous `security -s linear-api-key`
# convention are read transparently (same account+service lookup).
LINEAR_API_KEY=$(agents secrets get linear-api-key 2>/dev/null)
TEAM_ID=$(agents secrets get linear-team-id 2>/dev/null)

# Identify which harness is running this hook so "Your Tasks" reflects the right
# agent bucket instead of always assuming Claude. Most reliable signal: this
# script's own resolved path. agents-cli installs one copy per agent under
# .../versions/<agent>/.../home/.<agent>/hooks/, and each harness invokes ITS
# copy — so the path names the agent on every launch path (interactive shim,
# headless runner, sandbox) with no dependency on harness-specific env vars.
# AGENT_SELF is an explicit override/escape hatch; claude is the last resort.
self_path=$(realpath "${BASH_SOURCE[0]}" 2>/dev/null || printf '%s' "${BASH_SOURCE[0]}")
AGENT_SELF="${AGENT_SELF:-$(printf '%s' "$self_path" | sed -n 's#.*/versions/\([^/]*\)/.*#\1#p')}"
export AGENT_SELF="${AGENT_SELF:-claude}"

# Candidate names to match the cwd against a Linear project. The git repo name is
# stable across subdirs, so try it first; fall back to the raw cwd basename. The
# Python side normalizes both ("agents-cli" and "Agents CLI" -> "agentscli").
git_root=$(git rev-parse --show-toplevel 2>/dev/null)
export CWD_PROJECT_HINTS="$(basename "$git_root" 2>/dev/null),$(basename "$PWD" 2>/dev/null)"

if [ -z "$LINEAR_API_KEY" ] || [ -z "$TEAM_ID" ]; then
  echo "Linear credentials not found. Add them with:"
  echo '  agents secrets set linear-api-key --value YOUR_KEY'
  echo '  agents secrets set linear-team-id --value YOUR_TEAM_ID'
  exit 0
fi

# One round trip: workspace users (humans + agent apps), every team project (name
# + progress + milestones + top open issues, for the cwd match), and the active
# sprint board. Build the JSON body in Python to sidestep GraphQL-in-bash quoting.
QUERY='{
  users(first: 250) { nodes { displayName name email active app guest } }
  team(id: "'"$TEAM_ID"'") {
    projects(first: 50) {
      nodes {
        name state progress
        projectMilestones(first: 20) { nodes { name targetDate progress } }
        issues(first: 6, filter: { state: { type: { nin: ["completed", "canceled"] } } }) {
          nodes { identifier title priority state { name type } assignee { displayName } }
        }
      }
    }
    activeCycle {
      name startsAt endsAt
      issues(filter: { state: { type: { nin: ["completed", "canceled"] } } }) {
        nodes { identifier title description state { name type } priority assignee { name } labels { nodes { name } } updatedAt }
      }
    }
  }
}'
BODY=$(python3 -c 'import json,sys; print(json.dumps({"query": sys.argv[1]}))' "$QUERY")

result=$(curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d "$BODY" 2>/dev/null)

echo "$result" | python3 -c "
import json, sys, os, re

SELF = os.environ.get('AGENT_SELF', 'claude')
HINTS = [h for h in os.environ.get('CWD_PROJECT_HINTS', '').split(',') if h.strip()]

def norm(s):
    return re.sub(r'[^a-z0-9]', '', (s or '').lower())

try:
    data = json.load(sys.stdin)
    team = data.get('data', {}).get('team') or {}

    # -- Brief: humans + agent members ------------------------------------
    users = (data.get('data', {}).get('users') or {}).get('nodes', [])
    humans, agents = [], []
    for u in users:
        if not u.get('active', True):
            continue
        email = u.get('email') or ''
        name = u.get('displayName') or u.get('name') or 'unknown'
        if u.get('app'):
            # Skip Linear's own built-in integration user; keep assignable agents.
            if email.endswith('@linear.linear.app') or name == 'linear':
                continue
            agents.append(name)
        elif not u.get('guest'):
            humans.append((name, email))

    # This is a *brief*, not a directory dump -- a big workspace must not blow up
    # the injection. Fetch up to the API max (first: 250) so counts are accurate,
    # then cap what we render and summarize the rest as '+N more'.
    def capped(rendered, cap):
        if len(rendered) <= cap:
            return ', '.join(rendered)
        return ', '.join(rendered[:cap]) + f', +{len(rendered) - cap} more'

    if humans or agents:
        print('## Team & Agents')
        if humans:
            rows = [f'{n} ({e})' if e else n for n, e in sorted(humans, key=lambda x: x[0].lower())]
            print(f'**Humans ({len(humans)}):** {capped(rows, 15)}')
        if agents:
            names = sorted(set(agents), key=str.lower)
            print(f'**Agent members ({len(names)}, assignable):** {capped(names, 20)}')
        print()

    # -- Brief: cwd -> project focus --------------------------------------
    priority_map = {0: 'None', 1: 'Urgent', 2: 'High', 3: 'Medium', 4: 'Low'}
    projects = (team.get('projects') or {}).get('nodes', [])
    hint_norms = [norm(h) for h in HINTS if norm(h)]

    matched = None
    # Exact normalized match wins; else a containment match (>=4 chars, avoids
    # matching a 2-letter cwd against every project).
    for p in projects:
        if norm(p.get('name')) in hint_norms:
            matched = p
            break
    if not matched:
        for p in projects:
            pn = norm(p.get('name'))
            for hn in hint_norms:
                if len(hn) >= 4 and (hn in pn or pn in hn):
                    matched = p
                    break
            if matched:
                break

    if matched:
        prog = matched.get('progress')
        pct = f' -- {round(prog * 100)}% complete' if isinstance(prog, (int, float)) else ''
        print(f'### Focus: {matched[\"name\"]} (matched cwd){pct}')
        ms = (matched.get('projectMilestones') or {}).get('nodes', [])
        if ms:
            parts = []
            for m in ms:
                mp = m.get('progress')
                mpct = f' {round(mp * 100)}%' if isinstance(mp, (int, float)) else ''
                td = f' by {m[\"targetDate\"]}' if m.get('targetDate') else ''
                parts.append(f'{m[\"name\"]}{td}{mpct}')
            print(f'**Milestones:** {\"; \".join(parts)}')
        issues = (matched.get('issues') or {}).get('nodes', [])
        if issues:
            issues.sort(key=lambda n: n.get('priority', 4) or 4)
            print('**Top open issues:**')
            for n in issues:
                pri = priority_map.get(n.get('priority', 0), 'None')
                st = (n.get('state') or {}).get('name', '')
                a = (n.get('assignee') or {}).get('displayName')
                who = f' @{a}' if a else ''
                print(f'- **{n[\"identifier\"]}** ({pri}, {st}){who}: {n[\"title\"]}')
        print()
    elif projects:
        names = ', '.join(p['name'] for p in projects)
        print(f'_No cwd->project match (team projects: {names})._')
        print()

    # -- Active-sprint board ----------------------------------------------
    cycle = team.get('activeCycle')
    if not cycle:
        print('No active sprint in Linear.')
        sys.exit(0)

    nodes = cycle.get('issues', {}).get('nodes', [])
    cycle_name = cycle.get('name', 'Current Sprint')

    if not nodes:
        print(f'No open tasks in {cycle_name}.')
        sys.exit(0)

    # Group by agent label
    groups = {}
    unassigned = []
    for n in nodes:
        labels = [l['name'] for l in n.get('labels', {}).get('nodes', [])]
        agent_labels = [l for l in labels if l.startswith('agent:')]
        other_labels = [l for l in labels if not l.startswith('agent:')]
        n['_other_labels'] = other_labels

        if agent_labels:
            for al in agent_labels:
                groups.setdefault(al, []).append(n)
        else:
            unassigned.append(n)

    # Sort each group by priority
    for g in groups.values():
        g.sort(key=lambda n: n.get('priority', 4))
    unassigned.sort(key=lambda n: n.get('priority', 4))

    total = len(nodes)
    print(f'## {cycle_name} -- {total} open tasks')
    print()

    def fmt_issue(n):
        ident = n['identifier']
        title = n['title']
        state = n['state']['name']
        pri = priority_map.get(n.get('priority', 0), 'None')
        labels = ', '.join(n['_other_labels']) if n.get('_other_labels') else ''
        assignee = n.get('assignee', {})
        assignee_name = assignee.get('name', '') if assignee else ''
        desc = n.get('description', '')

        parts = [f'**{ident}**']
        parts.append(f'({pri}, {state})')
        if labels:
            parts.append(f'[{labels}]')
        if assignee_name:
            parts.append(f'@{assignee_name}')
        parts.append(f': {title}')

        line = '- ' + ' '.join(parts)
        if desc:
            short = desc[:200].replace(chr(10), ' ')
            if len(desc) > 200:
                short += '...'
            line += f'\n  > {short}'
        return line

    # The running agent's own tasks first (bucket chosen by the harness)
    mine = groups.pop(f'agent:{SELF}', [])
    if mine:
        print(f'### Your Tasks (agent:{SELF}) -- {len(mine)}')
        for n in mine:
            print(fmt_issue(n))
        print()
    else:
        print(f'### Your Tasks (agent:{SELF}) -- none assigned')
        print()

    # Other agents
    if groups:
        print('### Team Tasks')
        for label in sorted(groups.keys()):
            agent_name = label.replace('agent:', '')
            issues = groups[label]
            in_progress = sum(1 for n in issues if n['state'].get('type') == 'started')
            print(f'**{agent_name}** -- {len(issues)} tasks ({in_progress} in progress)')
            for n in issues:
                print(fmt_issue(n))
            print()

    # Unassigned
    if unassigned:
        print(f'### Unassigned -- {len(unassigned)}')
        for n in unassigned:
            print(fmt_issue(n))
        print()

    print('---')
    if mine:
        print('Pick your highest-priority task. For team tasks, check agent status if anything looks stale.')
    else:
        print('No tasks for you. Review team status -- check on stale or blocked work.')

except Exception as e:
    print(f'Linear query failed: {e}')
" 2>&1
