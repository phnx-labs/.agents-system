# X/Twitter Policy Context — March 2026

## Premium Requirement (Critical)

X Premium is mandatory for any account growth strategy. Without it:
- Replies are hidden behind "Show more" in threads
- Zero placement in For You algorithmic feed
- Users can filter to "Verified replies only" — your replies become invisible
- Search ranking is deprioritized
- API rate limits are more restrictive

**Action:** Subscribe to X Premium BEFORE any engagement activity. Do not waste sessions posting to an account nobody can see.

## Anti-Reply-Bot Policy (Feb 23, 2026)

X updated automation rules: **automated programs using the API may only reply when the original poster mentions or quotes them.** Unsolicited automated replies to strangers violate this policy.

**Implications:**
- The agent cannot blindly reply to any tweet via API
- Replies must be carefully positioned as human-directed, not bulk automated
- Keep reply volume low (2-3 per session, not 10+)
- Vary timing, length, and tone between replies
- The human operator should review replies before posting in early phases

Source: X Developer Agreement update, Feb 2026.

## Reply Impressions (Jan 19, 2026)

Reply impressions **no longer count** toward creator payouts or the algorithmic boost that came with the X Ads Revenue Sharing program. Only home timeline impressions count.

**What this changes:**
- The pure reply-guy strategy has less algorithmic upside than it did in 2024
- Standalone tweets and quote-retweets matter more for reach
- Replies still matter for relationship building (getting noticed), but don't expect algorithmic amplification from reply activity alone
- Balance shifts toward: 40% replies, 30% standalone, 30% QRTs

## Self-Reply Link Penalty

X's algorithm penalizes the parent tweet when the author immediately replies to it with a link. This was a popular growth hack ("tweet insight, reply to self with link") that X has specifically targeted.

**New link strategy:**
- Links go in the **bio** (always) and **pinned tweet** (primary CTA)
- In Phase 3, links can appear in main tweets sparingly (max 1/day)
- Never self-reply with a link
- Say "link in bio" or "see pinned" when relevant
- Screenshots and native media don't trigger link penalties

## Grok Semantic Analysis

X uses Grok to analyze content patterns and detect AI-generated "slop." Known detection signals:

- Repetitive sentence structure across multiple posts
- "Newsletter voice" (perfectly structured paragraphs with topic sentences)
- Em-dash overuse (LLMs produce 3-5x more em-dashes than human writers)
- Predictable opinion structure: "X is interesting because Y. But the real insight is Z."
- Uniform reply length and tone
- Sycophantic engagement patterns ("Great insight!", "This is so true!")

**Mitigation:** See references/anti-patterns.md for full voice calibration guide.

## API Economics

| Tier | Cost | Read Limit | Write Limit |
|------|------|-----------|-------------|
| Free | $0 | 100 reads/mo | 0 writes |
| Basic | $100/mo | 50k reads/mo | ~10k writes/mo |
| Pro | $5,000/mo | 1M reads/mo | 300k writes/mo |

For a warmup cadence of 3-5 posts/day: Basic tier is sufficient.

**Budget awareness:**
- Each API call costs credits regardless of whether the tweet gets engagement
- Failed/rejected tweets still consume write credits
- Monitor usage via X Developer Portal dashboard
- Set alerts at 80% of monthly allocation

## EU AI Act Article 50

Enforcement begins **August 2, 2026**. Requirements:
- AI-generated content must be clearly labeled when it could be mistaken for human-created
- Applies to content visible to EU users (which includes most public X accounts)
- Non-compliance penalties can be significant

**Recommended approach:**
- Add a note in the account bio indicating AI-assisted content (e.g., "Some posts crafted with AI assistance")
- This is both legally prudent and builds trust
- Most X users don't read bios, so the impact on engagement is minimal
- Better to add it now than retroactively after enforcement begins

## Community Notes Risk

Community Notes can be attached to any tweet by approved contributors. Risks:
- Factually inaccurate claims get noted quickly
- Product claims without evidence attract notes
- Notes reduce a tweet's distribution and the poster's trust score
- Repeated notes can affect account-level visibility

**Mitigation:**
- Never make unsourced claims about market size, user counts, or performance
- Don't exaggerate product capabilities
- When citing data, be specific about sources
- Avoid clickbait-style statements that invite fact-checking
- If a note is attached, don't argue — let it stand or delete the tweet

## Video/Visual Content Bias

X's algorithm in 2026 strongly favors visual and video content:
- Native video gets 5-10x the reach of text-only posts
- Images get 2-3x the reach of text-only
- External video links (YouTube) get penalized vs native upload
- Carousel images (multiple photos) perform well

**Practical guidance:**
- From Phase 2 onward, include images or screenshots in 30-40% of standalone tweets
- Product demos as short native videos perform exceptionally
- Screenshots of interesting data, code, or UI are low-effort high-reward
- Memes related to your domain work well for AI/tech audiences

## InfoFi Precedent (Jan 15, 2026)

X revoked API access for "InfoFi" (post-to-earn) applications that incentivized mass posting of AI-generated content. This signals:
- X is actively identifying and cutting off automated content farms
- High-volume AI posting patterns are a known enforcement target
- API access revocation is permanent, not temporary
- Even legitimate apps were caught in the sweep

**What this means for warmup:**
- Keep volume modest (3-5 posts/day, not 20+)
- Quality over quantity is not just strategy, it's survival
- Mix of reply types, standalone, and engagement shows authentic behavior
- Avoid patterns that look like bulk automation (same time, same length, same format)
