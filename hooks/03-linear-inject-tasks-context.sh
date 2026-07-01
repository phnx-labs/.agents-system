#!/bin/bash
# SessionStart hook: fetch ALL Linear tasks from active sprint
# Groups by agent label, shows the RUNNING agent's tasks first, then team status

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

if [ -z "$LINEAR_API_KEY" ] || [ -z "$TEAM_ID" ]; then
  echo "Linear credentials not found. Add them with:"
  echo '  agents secrets set linear-api-key --value YOUR_KEY'
  echo '  agents secrets set linear-team-id --value YOUR_TEAM_ID'
  exit 0
fi

result=$(curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d "{
    \"query\": \"{ team(id: \\\"$TEAM_ID\\\") { activeCycle { name startsAt endsAt issues(filter: { state: { type: { nin: [\\\"completed\\\", \\\"canceled\\\"] } } }) { nodes { identifier title description state { name type } priority assignee { name } labels { nodes { name } } updatedAt } } } } }\"
  }" 2>/dev/null)

echo "$result" | python3 -c "
import json, sys, os

SELF = os.environ.get('AGENT_SELF', 'claude')

try:
    data = json.load(sys.stdin)
    cycle = data.get('data', {}).get('team', {}).get('activeCycle')
    if not cycle:
        print('No active sprint in Linear.')
        sys.exit(0)

    nodes = cycle.get('issues', {}).get('nodes', [])
    cycle_name = cycle.get('name', 'Current Sprint')

    if not nodes:
        print(f'No open tasks in {cycle_name}.')
        sys.exit(0)

    priority_map = {0: 'None', 1: 'Urgent', 2: 'High', 3: 'Medium', 4: 'Low'}

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
