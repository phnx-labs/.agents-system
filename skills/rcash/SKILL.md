---
name: rcash
description: Rush growth optimization — audit surfaces, propose changes, implement A/B tests, analyze funnel metrics via Insights API. Rush's version of Anthropic's CASH. Use before any conversion optimization or growth work.
argument-hint: "[audit | propose <surface> | analyze | baseline]"
user-invocable: true
---

# RCASH

Optimize conversion across Rush's web surfaces. This skill covers the full loop: audit what's tracked, propose changes, implement variants via PostHog feature flags, and analyze results using the Insights API.

**Related skills (don't duplicate):**
- `rush-analytics` — raw PostHog/Grafana queries. Use that for ad-hoc data pulls.
- `proof-loop` — binary funnel check (Y/N per stage). Use that for daily health checks.
- This skill is the strategy + optimization layer on top of both.

## Surfaces

All surfaces use PostHog project key `phc_6w3mQVSaK0YV8pBpw6j9tQMVeyCfekRs67RmTahNUeK` and send to `https://us.i.posthog.com`.

### getrush.ai (main product site — served by halo/proxy)

| Page | Route | File | What converts |
|------|-------|------|---------------|
| Landing | `/` | `halo/proxy/src/routes/landing-html.ts` | Visitor -> agent page or download |
| Agent listings | `/agents` | `halo/proxy/src/routes/agents-html.ts` | Browse -> agent detail |
| Agent detail | `/agent/{slug}` | `halo/proxy/src/routes/agent-html.ts` | Learn -> download Rush |
| Share pages | `/share/{id}` | `halo/proxy/src/routes/share-html.ts` | View artifact -> sign up |

### Agent websites (standalone domains — Next.js on CF Pages)

| Agent | Domain | Layout file |
|-------|--------|-------------|
| Rabbit Hole | gorabbithole.ai | `agents/rabbit-hole/website/src/app/layout.tsx` |
| Inbox Ninja | inboxninja.ai | `agents/inbox-ninja/website/app/layout.tsx` |
| Content Writer | antislop.io | `agents/content-writer/website/app/layout.tsx` |
| Daily Zen | ultravibe.ai | `agents/daily-zen/website/app/layout.tsx` |
| Image Studio | auramaxxing.ai | `agents/image-studio/website/src/app/layout.tsx` |
| UX Tester | websonic.ai | `agents/ux-tester/website/app/layout.tsx` |

### Rush desktop app

| Surface | File | What's tracked |
|---------|------|----------------|
| App analytics | `rush/app/src/lib/analytics.ts` | Agent executions, installs, sessions |

## The Funnel

```
visited (PostHog pageviews on getrush.ai)
  -> downloaded (agent_installed or app_downloaded events)
    -> firstRun (first session in range)
      -> gotValue (produced files or shared artifact)
        -> cameBack (sessions on 2+ distinct days)
          -> paid (active Stripe subscription)
```

Every proposed change should target moving one stage of this funnel.

## Insights API

The unified metrics endpoint. Returns the full funnel + activation + revenue + engagement + health in one call.

```bash
# 7-day window (default)
rush http GET '/api/v1/insights?range=7d'

# Other ranges: 1d, 30d
rush http GET '/api/v1/insights?range=30d'
```

**Response shape:**
```json
{
  "meta": { "range": "7d", "generatedAt": "...", "cacheTtlSeconds": 60 },
  "funnel": {
    "visited": 0,
    "downloaded": 0,
    "firstRun": 0,
    "gotValue": 0,
    "cameBack": 0,
    "paid": 0
  },
  "activation": {
    "rate": 0,
    "medianTimeToActivateHours": 0,
    "activatedUsers": 0,
    "totalNewUsers": 0,
    "byAgent": [{ "slug": "...", "title": "...", "activatedUsers": 0, "rate": 0 }]
  },
  "revenue": { "mrr": 0, "payingUsers": 0, "arpu": 0 },
  "engagement": {
    "dau": 0, "wau": 0,
    "sessionsPerUser": { "p50": 0, "p90": 0 },
    "topAgents": [{ "slug": "...", "sessions": 0 }],
    "retention": { "priorPeriodUsers": 0, "retained": 0, "rate": 0 }
  },
  "health": { "successRate": 0, "medianSessionDurationMs": 0, "llmCostPerSession": 0 },
  "users": [{ "userId": "...", "totalSessions": 0, "agentsUsed": [], "hasShared": false, "isPaying": false }]
}
```

`users` array only returned when < 100 users (current state). Use it to see individual user journeys.

## PostHog Traffic Data

For web-specific metrics (pageviews, referrers, top pages), use the PostHog endpoints:

```bash
# All sites overview
rush http GET '/api/v1/posthog/sites?days=7'

# Single site with daily breakdown + top pages + referrers
rush http GET '/api/v1/posthog/sites/gorabbithole.ai?days=7'

# Custom events (button clicks, CTA interactions)
rush http GET '/api/v1/posthog/events?days=7&site=getrush.ai'
```

## Active Experiments

### hero-subheadline (landing page)
- **Flag:** `hero-subheadline` in PostHog
- **File:** `halo/proxy/src/routes/landing-html.ts` lines 1388-1401
- **Target element:** `.subheadline`
- **Variants:**
  - `control`: "Not an app. Not a chatbot. Not an agent. The layer between you and everything else."
  - `frontier-founders`: "Research reports. Social content. Email drafts. Finished work on your desktop -- not another chat window."
  - `chat-is-dead`: "You don't need another chatbot. You need agents that deliver finished work you can actually use."
  - `stop-chatting`: "Stop typing prompts. Open Rush and get a finished research report, a week of content, or an empty inbox."

## How to Implement a New Variant Test

### For halo/proxy pages (getrush.ai/*)

These pages are server-rendered HTML strings in TypeScript. To add a test:

1. **Create the PostHog feature flag** in the PostHog dashboard (https://us.posthog.com) or via API
2. **Add variant logic** in the page's HTML template (same pattern as hero-subheadline):

```javascript
// In the <script> block after posthog.init
var variants = {
  'control': 'Original text here',
  'variant-a': 'New text to test',
  'variant-b': 'Another variant'
};
posthog.onFeatureFlags(function() {
  var variant = posthog.getFeatureFlag('your-flag-name');
  if (variant && variants[variant]) {
    var el = document.querySelector('.your-target-selector');
    if (el) el.textContent = variants[variant];
  }
});
```

3. **Deploy**: `./halo/proxy/scripts/deploy.sh`
4. **Verify**: Visit the page, check PostHog for flag evaluations

### For agent websites (Next.js)

These use React. Feature flags require the PostHog React SDK or client-side check:

```tsx
// In a client component
'use client';
import posthog from 'posthog-js';

// Check flag after init
const variant = posthog.getFeatureFlag('flag-name');
```

Or use `posthog.onFeatureFlags()` in a useEffect.

### Creating PostHog feature flags via API

```bash
POSTHOG_KEY=$(ssh muqsit@mark "grep POSTHOG_PERSONAL /home/muqsit/src/github.com/muqsitnawaz/agents/halo/proxy/.env.prod" 2>/dev/null | cut -d= -f2)

curl -s 'https://us.posthog.com/api/projects/201531/feature_flags/' \
  -H "Authorization: Bearer $POSTHOG_KEY" \
  -H 'Content-Type: application/json' \
  -d '{
    "key": "your-flag-name",
    "name": "Description of what you are testing",
    "filters": {
      "groups": [{"properties": [], "rollout_percentage": 100}],
      "multivariate": {
        "variants": [
          {"key": "control", "rollout_percentage": 50},
          {"key": "variant-a", "rollout_percentage": 50}
        ]
      }
    },
    "active": true
  }'
```

## Workflow

### 1. Audit (`/growth audit`)
- Pull Insights API for current funnel numbers
- Pull PostHog site data for traffic across all surfaces
- Identify: which surfaces have traffic but no experiments? Where is the funnel leaking?
- Report the single biggest opportunity

### 2. Propose (`/growth propose <surface>`)
- Read the current page source (from the file table above)
- Identify testable elements: headlines, subheadlines, CTAs, social proof, layout
- Propose 2-3 concrete variants with rationale
- Specify which funnel stage the test targets

### 3. Implement (`/growth implement`)
- Create PostHog feature flag (via API or dashboard instructions)
- Add variant code to the page file
- Deploy the change
- Verify the flag is evaluating

### 4. Analyze (`/growth analyze`)
- Pull Insights API: compare funnel metrics between periods
- Pull PostHog: check flag evaluation counts per variant
- Report: which variant is winning, confidence level, recommendation
- Note: Need sufficient traffic for statistical significance (typically 100+ visitors per variant)

## Principles

1. **One test per surface at a time.** Multiple overlapping tests make results unreadable.
2. **Test the biggest leak first.** If 1000 people visit but 10 download, fix visited->downloaded before optimizing later stages.
3. **Copy changes before layout changes.** Copy is cheaper to test and often higher impact.
4. **Every variant must stay on-brand.** Load `/rush-product-knowledge` and `/rush-taste` before proposing copy. No hype, no dark patterns.
5. **Measure for at least 7 days** before calling a winner (weekly traffic patterns matter).
6. **Document results.** Update the "Active Experiments" section in this skill when tests conclude.

## Bot Filtering

When interpreting traffic numbers, filter out known datacenter locations:
- Boardman, Oregon (AWS us-west-2)
- Falkenstein, Germany (Hetzner / mark server)
- Ashburn, Virginia (AWS us-east-1)
- Council Bluffs, Iowa (Google datacenter)

See `rush-analytics` skill for HogQL query patterns that exclude these.
