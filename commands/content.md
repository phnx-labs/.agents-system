# Content Generator

Generate authentic content - social posts OR publication-quality blog articles.

## Input: $ARGUMENTS

Parse the input for:
- **Format:** "blog", "LinkedIn", "Reddit", "X" (Twitter), or "all"
- **Topic:** Required for blog posts, optional for social content
- **Tone:** If specified (e.g., "casual", "technical", "philosophical")

If no format specified, default to LinkedIn.

Examples:
- `/content blog "Why agents are replacing SaaS"` - Research-driven blog post
- `/content LinkedIn` - LinkedIn post from recent work
- `/content X agent infrastructure` - Tweet about agents
- `/content Reddit r/ClaudeAI learning with AI` - Reddit comment
- `/content the parallel execution thing` - Infer platform, focus on that topic

---

## IMPORTANT CONSTRAINTS

1. **Do NOT mention Rush, getrush.ai, or Phoenix Horizon publicly** - User works at TikTok and cannot publicly promote side projects. Keep content general/philosophical or framed as personal observations.

2. **Do NOT make claims without grounding** - Every insight should connect to something happening in the real world (news, launches, conversations, papers).

---

## Step 1: Load Context

Read these files to understand voice and current work:

1. `~/.reddit/profile.md` - Voice, perspective, writing style
2. `~/.reddit/projects.md` - Active projects and themes (for PRIVATE context only)

## Step 2: Research What's Happening in the Field

**This is critical.** Before generating content, search for recent context:

### Search queries to run (use WebSearch):
- "AI agents news [current month] [current year]"
- "AI agents startups launches"
- "AI agents [specific topic from user's hint]"
- "[topic] site:reddit.com" or "[topic] site:news.ycombinator.com"

### What to look for:
- Recent breakthroughs or announcements
- YC launches or startup news related to agents
- Reddit/HN discussions about agent limitations or possibilities
- Papers or research being discussed
- Viral moments or experiments (agents doing unexpected things)
- Real examples of agent limitations (can't pay, can't persist, etc.)

### Why this matters:
- Grounds the user's thinking in real events
- Makes content feel timely and connected
- Provides concrete examples instead of abstract claims
- Shows the user is plugged into what's happening, not just theorizing

## Step 3: Mine Recent Work (Private Context)

Check for authentic material from the user's projects:

```bash
# Recent commits across main projects (last 7 days)
cd /Users/muqsit/src/github.com/muqsitnawaz/agents && git log --since="7 days ago" --oneline | head -10
cd /Users/muqsit/src/github.com/muqsitnawaz/swarmify && git log --since="7 days ago" --oneline | head -10
```

**Use this to understand what the user is thinking about** - but don't reference these projects directly in public content.

## Step 4: Connect the Dots

The magic is in connecting:
- **User's private thinking** (from projects, VISION.md, etc.)
- **Public conversation** (from web search)
- **Concrete examples** (from news, experiments, launches)

The content should feel like: "Here's what's happening in the world, and here's how I'm thinking about it" - NOT "here's my theory in isolation."

## Step 5: Generate Content

### Platform Guidelines

**LinkedIn:**
- Length: 150-300 words ideal, can go longer for substantive posts
- Structure: Hook (often a recent event or observation) → Insight → Supporting evidence → Takeaway
- Tone: Professional but not corporate. Thoughtful. First-person.
- Line breaks between paragraphs
- Reference real events, launches, or conversations happening now
- No hashtags unless specifically requested

**X (Twitter):**
- Length: Under 280 chars for single tweet, or thread format
- Tone: Punchy, direct, slightly provocative
- Can quote-tweet or reference specific events/posts
- For threads: Number them (1/, 2/, etc.)

**Reddit:**
- Length: Varies by subreddit culture
- Tone: Helpful, genuine, not self-promotional
- Reference specific things happening in the community
- Include concrete examples from experience (but keep company stuff vague)Voice Checklist (from profile.md)

- Direct, casual, no fluff
- Uses concrete examples
- Comfortable admitting uncertainty
- Avoids ego flexing or name-dropping
- Pragmatic over theoretical
- No emojis unless explicitly requested
- **Grounded in what's actually happening**

### Content Patterns That Work

1. **The observation + context:** "[Recent event/news]. Here's what this means..."
2. **The connection:** "Everyone's talking about [X]. But nobody's asking [Y]."
3. **The grounded prediction:** "[Trend/event] suggests [implication]. Here's why..."
4. **The experience + lesson:** "Saw [thing happening in the field]. Reminds me of [insight]."
5. **The contrarian take:** "[Common take on recent news]. But actually [different angle]."

## Step 6: Output

Present the draft with:
1. **The content itself** (ready to copy-paste)
2. **Platform** it's for
3. **Grounding sources** - what news/events/conversations this connects to
4. **Private context** - what from your work inspired this (not included in post)
5. **Suggested variations** or edits

---

## Example Process

**User input:** `/content LinkedIn agent infrastructure`

**Step 2 (Research):** Search "AI agents infrastructure 2026", "AI agents payments", "AI agents limitations reddit"
→ Find: Article about agents attempting commerce but failing, YC launch of agent tooling company, Reddit thread about agent persistence

**Step 3 (Mine work):** Check recent commits, see VISION.md updates about agent wallets and identity

**Step 4 (Connect):** User's thinking about agent infrastructure aligns with real gap being discussed - agents can't actually transact or persist

**Step 5 (Generate):**
```
Saw an experiment last week where AI agents tried to run their own social network.

They could post. They could reply. They could coordinate.

But when they wanted to actually buy something? Dead end. No wallet. No identity. No way to transact.

Smart enough to want things. No infrastructure to get them.

This is the gap nobody's building for yet...
```

**Output includes: Link to the experiment, note that this connects to user's thinking about agent economics, variations for different angles.

