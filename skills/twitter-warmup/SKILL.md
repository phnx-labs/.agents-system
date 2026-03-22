---
name: twitter-warmup
description: "Warm up a new Twitter/X account from zero to credible. Stateful — tracks phase, targets, and activity across sessions. Triggers on: 'twitter warmup', 'warm up twitter', 'X account warmup', 'tweet strategy', 'twitter engagement', or warmup session work."
user-invocable: true
argument-hint: "[session | init | status | targets]"
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/*)
---

# Twitter Account Warmup

Stateful skill for warming up a new X account. Tracks phase, targets, and daily activity across sessions.

## Current State
!`${CLAUDE_SKILL_DIR}/scripts/load-state.sh`

## Pre-Flight Checklist

**All must pass before ANY engagement session.** If any fail, guide the user through fixing them first.

1. **X Premium active** — without it, replies are hidden and reach is zero. Non-negotiable.
2. **Profile complete** — real photo or brand mark, custom banner, specific bio with product link, location set
3. **Pinned tweet** — primary conversion mechanism. Must exist before Phase 2.
4. **API write access** — Basic tier minimum ($100/mo). Confirm budget.
5. **Targets seeded** — at least 5 accounts in `~/.twitter-warmup/targets.yaml`
6. **State initialized** — `~/.twitter-warmup/` exists. If not: `${CLAUDE_SKILL_DIR}/scripts/init.sh`

Once all prereqs pass, update `state.yaml` to reflect (premium: true, profile_complete: true, api_access: true).

## Session Workflow

Every session follows this sequence:

1. **Check state** (auto-injected above). If prereqs incomplete, stop and fix.
2. **Load targets**: `${CLAUDE_SKILL_DIR}/scripts/load-targets.sh`
3. **Load recent activity**: `${CLAUDE_SKILL_DIR}/scripts/load-recent-activity.sh 7`
4. **Research** — web search for target accounts' recent activity and trending conversations
5. **Engage** — execute phase-appropriate actions (see phases below)
6. **Log** — write today's activity to `~/.twitter-warmup/log/YYYY-MM-DD.yaml`
7. **Update targets** — add new discoveries, update last_engaged dates in targets.yaml
8. **Update state** — set last_session, check if phase transition is warranted

## Phase 1: Observer & Reply-Guy (Days 0-14)

**Goal:** Build engagement history. Get noticed through valuable replies.

**Per session:**
- Pick 3-5 accounts from targets to research (rotate across sessions)
- Post 2-3 replies that add genuine value
- Post 1 standalone tweet inspired by what you observed

**Rules:**
- ZERO links, product mentions, or self-promotion
- Replies must add value: insight, contrarian take, data point, specific experience
- Standalone tweets = observations from someone deep in the space
- Vary posting times — never same cadence
- Replies > standalone (a reply on a 50k-follower thread beats any standalone)

**Reply quality bar:**
- GOOD: Adds a specific insight, reframes the point, shares a data point, asks a sharp question, or offers a contrarian angle backed by reasoning
- BAD: "Great point!" (empty, bot signal)
- BAD: "We're building exactly this!" (self-promotional)
- BAD: Generic agreement with nothing added

**Standalone quality bar:**
- GOOD: "everyone's racing to build the best AI agent. almost nobody is asking where all these agents live after you build them"
- BAD: "Excited to share our new product!" (nobody cares from a new account)

**Transition to Phase 2:** Account age >= 14 days AND has received engagement on replies. Update `phase: 2` in state.yaml.

## Phase 2: Voice & Identity (Days 14-28)

**Changes from Phase 1:**
- Use "we" occasionally (1 in 5 tweets)
- Name the product naturally ("building an agent OS taught us...")
- Still NO links — bio and pinned tweet have the links
- Continue reply activity (40%+ of output)
- Start quote-tweeting with added commentary
- Include images/screenshots in 30% of standalone tweets

**Natural mention examples:**
- "building an agent OS taught us one thing: the model doesn't matter as much as the interface"
- NOT: "At Rush, we believe..." (corporate)

**Transition to Phase 3:** Account age >= 28 days AND has established quality followers. Update `phase: 3` in state.yaml.

## Phase 3: Earned Promotion (Days 28+)

**Changes from Phase 2:**
- Links allowed in main tweets (NOT self-replies), max 1/day
- Product screenshots, demos, user stories are fair game
- 70% value-first content, 30% product-related
- Native video/media for demos (huge reach boost)
- Continue community engagement (don't go broadcast-only)

**Link strategy (updated for 2026):**
- Links in main tweets sparingly — never self-reply with a link (X penalizes this now)
- Use "link in bio" or "see pinned" as alternatives
- Screenshots and native media don't trigger link penalties
- External video links (YouTube) penalized vs native upload

## Critical Policy Rules (March 2026)

Non-negotiable. Violating these risks shadowban or API revocation.

1. **Premium required** — unverified accounts are invisible in replies and For You feed
2. **No bulk automated replies** — Feb 2026 policy: API programs may only reply when mentioned/quoted. Keep volume low (2-3/session), vary everything
3. **Reply impressions don't boost** — standalone tweets and QRTs matter more for algorithmic reach
4. **No self-reply links** — X penalizes parent tweets when author self-replies with links
5. **Grok detects AI slop** — avoid LLM cadence tells (see Anti-AI Voice below)
6. **Low volume only** — 3-5 posts/day max. X revoked API for bulk posting apps (Jan 2026 InfoFi ban)
7. **Community Notes risk** — never make unsourced claims about market size, users, or performance

Full policy details with evidence: [references/policy-2026.md](references/policy-2026.md)

## Anti-AI Voice Rules

The agent MUST avoid these LLM cadence tells:

1. **No sycophantic openers** — never "Great point!", "Absolutely!", "This is so true!"
2. **No em-dash overuse** — LLMs produce 3-5x more than humans
3. **No perfect structure** — replies should NOT read like mini-essays
4. **No uniform length** — vary between 5-word takes and 200-char observations
5. **No hedging** — "arguably", "it could be said" = AI tell. Be direct.
6. **No colon openers** — "Insight: ..." or "Key takeaway: ..." = LLM signature

**Voice calibration:**
- Use fragments. Not everything needs a verb.
- Occasional lowercase, missing periods
- Strong opinions without hedging
- Reference specific experiences ("spent 3 hours debugging X and realized...")
- Disagree sometimes — sycophantic accounts get flagged
- Vary tone across: sharp, curious, builder, funny, frustrated

Full catalog: [references/anti-patterns.md](references/anti-patterns.md)

## Profile Setup

### Bio Format
Write as a person, not a product page:
- What you're building (1 line)
- Your perspective/angle (1 line)
- Link to product

Example: "building the OS for AI agents. the interface matters more than the model. getrush.ai"
NOT: "Rush - The AI Agent Operating System | Try it free today!"

### Pinned Tweet
The #1 conversion mechanism:
- Demonstrate the product (screenshot, demo, or clear description)
- Genuine insight, not an ad
- Include link or CTA naturally
- Update as product evolves

### Before First Tweet
- Follow 20-50 accounts in your space (targets + peers + news)
- Set location
- Complete all profile fields

## Seeding Targets

The user MUST provide initial seed accounts. The agent cannot bootstrap domain knowledge from scratch. Ask for:

1. **10-15 accounts they respect** — real people, not brands
2. **Why each matters** — "go-to voice for X", "200k followers, posts daily about Y"
3. **2-3 competitors** — engage differently (learn from, don't reply-guy)
4. **Topics that resonate** and topics to AVOID

### Target Format (targets.yaml)
```yaml
targets:
  - handle: "@example"
    name: "Full Name"
    tier: 1
    topics: ["AI agents", "developer tools"]
    why: "Key voice in AI agent space"
    last_engaged: null
    response_rate: null
    discovered_via: "seed"
```

### Growing Organically
After the initial seed, expand by:
- Checking who seed accounts engage with (RT, QRT, reply to)
- Noting quality replies on seed accounts' threads
- Searching for conversations and finding new voices
- Adding discoveries to targets.yaml with `discovered_via: "@source_handle"`

## Content Mix

### Daily Themes (defaults, override for breaking news)

| Day | Theme | Angle |
|-----|-------|-------|
| Mon | Ecosystem observations | Market structure, who's building what |
| Tue | Your thesis | Why your approach matters |
| Wed | Builder perspective | What building in this space is actually like |
| Thu | Hot takes on news | Contrarian angles on whatever dropped |
| Fri | Future implications | How this domain reshapes work/life |
| Sat | Technical insight | Something specific and educational |
| Sun | Philosophical | Bigger picture, historical parallels |

### Media Mix (Phase 2+)
- 30-40% of standalone tweets should include images, screenshots, or video
- Native video gets 5-10x reach vs text-only
- Product screenshots are low-effort high-reward

### Activity Distribution
- Phase 1: 70% replies, 30% standalone
- Phase 2: 40% replies, 30% standalone, 30% QRTs
- Phase 3: 30% replies, 30% standalone, 20% QRTs, 20% product

### Voice: Curator-Narrator (All Phases)

Never tweet an abstract thesis. Be a **curator-narrator**: find interesting real things and tell them with specific names, numbers, and details.

**What works:**
- "An $800M company exists because evals were so broken the founder built the same tool twice — at his startup, then at Figma." (specific company, specific origin)
- "Boris Cherny's team at Anthropic kills 80% of what they prototype. ~30 versions of the condensed file view." (specific person, specific numbers)
- "I spent 2 hours with Naman Pandey breaking down how he set up OpenClaw as a PM." (specific person, specific time, specific workflow)

**What fails:**
- "The winning layer is orchestration" (abstract thesis, zero names)
- "Most AI products are still just one more tab" (generic, sounds like marketing)
- "The bottleneck is shifting to orchestration" (declares a position nobody asked for)

**The principle:** You don't need original evidence. Find real moves by real people — even small ones — and tell those stories well. The insight should emerge from the evidence, not be stated as a declaration.

See the writer skill's "Curator-Narrator Pattern" section for detailed archetypes and more examples.

## Research Methods

**Use these in priority order:**

1. **Twitter Search API** — real tweets from last 7 days with metrics. `rush http GET /api/v1/twitter/search` if available.
2. **Web search** — good for broader context, stale for X specifically. `site:x.com "AI agents" [topic]`
3. **Twitter User Lookup API** — for specific user profiles and recent tweets

**NEVER:** direct web_fetch on x.com/twitter.com (IP bans), scraping, or crawling.

## Logging & State Updates

### Daily Log Format (`~/.twitter-warmup/log/YYYY-MM-DD.yaml`)
```yaml
date: "2026-03-21"
phase: 2
replies:
  - to: "@handle"
    tweet_url: "https://x.com/..."
    topic: "AI agents"
standalone:
  - tweet_url: "https://x.com/..."
    topic: "builder perspective"
quote_tweets: []
metrics_observed:
  likes_received: 0
  replies_received: 0
  profile_visits: 0
  new_followers: 0
targets_engaged: ["@handle1", "@handle2"]
new_discoveries:
  - handle: "@newperson"
    found_via: "@handle1"
    notes: "sharp takes on agent UX"
cooldown_signals: false
notes: ""
```

### After Each Session
- Update `last_engaged` dates in targets.yaml for engaged targets
- Add new discoveries to targets.yaml
- Set `last_session` in state.yaml
- Check phase transition criteria

## Cooldown Protocol

If replies are hidden, impressions drop to zero, or follower growth stops:

1. Stop all activity immediately
2. Set `cooldown.active: true` in state.yaml with date and reason
3. Wait 48 hours (zero activity — no likes, no retweets, nothing)
4. Resume at 50% rate
5. If cooldown triggers again within 7 days, wait 7 full days

Full detection signals: [references/anti-patterns.md](references/anti-patterns.md)

## Metrics by Phase

**Phase 1:** Replies posted (target: 2-3/session), reply likes (1-2 is good), profile visits
**Phase 2:** Follower growth rate, engagement rate on standalone, quality of followers
**Phase 3:** Link clicks, conversion to product, referral traffic

## Anti-Patterns

1. Blasting links from day 1 — shadowban guaranteed
2. "Great point!" replies — bot signal, adds nothing
3. Rigid posting schedule — same cadence = automated
4. Same format every tweet — vary length, style, tone
5. Ignoring conversations — reply to people who reply to you
6. Only talking about product — 70%+ must be industry insight
7. Hashtags — nobody serious uses them on X
8. Threads from a new account — nobody reads them
9. Corporate voice — "We're thrilled to announce" = instant unfollow
10. Guessing who matters — use seed list from user, don't invent targets
11. Engaging competitors same as allies — monitor, don't reply-guy them
12. Self-reply link pattern — penalized since 2025

## Initialization

If `~/.twitter-warmup/` doesn't exist:
```bash
${CLAUDE_SKILL_DIR}/scripts/init.sh
```
Then fill in `~/.twitter-warmup/state.yaml` with account details and seed `~/.twitter-warmup/targets.yaml` with 5+ accounts.
