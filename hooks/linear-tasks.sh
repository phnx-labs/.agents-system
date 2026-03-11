#!/bin/bash
# SessionStart hook: fetch Linear tasks labeled agent:claude from active sprint
# Output goes to Claude's context automatically

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
    \"query\": \"{ team(id: \\\"$TEAM_ID\\\") { activeCycle { name startsAt endsAt issues(filter: { labels: { name: { eq: \\\"agent:claude\\\" } }, state: { type: { nin: [\\\"completed\\\", \\\"canceled\\\"] } } }) { nodes { identifier title description state { name } priority labels { nodes { name } } } } } } }\"
  }" 2>/dev/null)

issues=$(echo "$result" | python3 -c "
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
        print(f'No agent:claude tasks in {cycle_name}.')
        sys.exit(0)

    priority_map = {0: 'None', 1: 'Urgent', 2: 'High', 3: 'Medium', 4: 'Low'}

    # Sort by priority (1=urgent first)
    nodes.sort(key=lambda n: n.get('priority', 4))

    print(f'## Linear Tasks (agent:claude) - {cycle_name} - {len(nodes)} open')
    print()
    for n in nodes:
        ident = n['identifier']
        title = n['title']
        state = n['state']['name']
        pri = priority_map.get(n.get('priority', 0), 'None')
        labels = ', '.join(l['name'] for l in n.get('labels', {}).get('nodes', []) if l['name'] != 'agent:claude')
        desc = n.get('description', '')

        label_str = f' [{labels}]' if labels else ''
        print(f'- **{ident}** ({pri}, {state}){label_str}: {title}')
        if desc:
            # First 200 chars of description
            short = desc[:200].replace(chr(10), ' ')
            if len(desc) > 200:
                short += '...'
            print(f'  > {short}')

    print()
    print('Pick the highest-priority task, mark it In Progress, work it, mark it Done.')
except Exception as e:
    print(f'Linear query failed: {e}')
" 2>&1)

echo "$issues"
