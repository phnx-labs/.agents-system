#!/bin/bash
# SessionStart hook: fetch ALL Linear tasks from active sprint
# Groups by agent label, shows Claude's tasks first, then full team status

LINEAR_API_KEY=$(security find-generic-password -s "linear-api-key" -w 2>/dev/null)
TEAM_ID=$(security find-generic-password -s "linear-team-id" -w 2>/dev/null)

if [ -z "$LINEAR_API_KEY" ] || [ -z "$TEAM_ID" ]; then
  echo "Linear credentials not found in Keychain. Add them with:"
  echo '  security add-generic-password -a "$USER" -s "linear-api-key" -w "YOUR_KEY"'
  echo '  security add-generic-password -a "$USER" -s "linear-team-id" -w "YOUR_TEAM_ID"'
  exit 0
fi

result=$(curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d "{
    \"query\": \"{ team(id: \\\"$TEAM_ID\\\") { activeCycle { name startsAt endsAt issues(filter: { state: { type: { nin: [\\\"completed\\\", \\\"canceled\\\"] } } }) { nodes { identifier title description state { name type } priority assignee { name } labels { nodes { name } } updatedAt } } } } }\"
  }" 2>/dev/null)

echo "$result" | python3 -c "
import json, sys

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

    # Claude's tasks first
    claude_tasks = groups.pop('agent:claude', [])
    if claude_tasks:
        print(f'### Your Tasks (agent:claude) -- {len(claude_tasks)}')
        for n in claude_tasks:
            print(fmt_issue(n))
        print()
    else:
        print('### Your Tasks (agent:claude) -- none assigned')
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
    if claude_tasks:
        print('Pick your highest-priority task. For team tasks, check agent status if anything looks stale.')
    else:
        print('No tasks for you. Review team status -- check on stale or blocked work.')

except Exception as e:
    print(f'Linear query failed: {e}')
" 2>&1
