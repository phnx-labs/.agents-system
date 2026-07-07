---
name: plan-render
description: "Render an implementation plan as a self-contained, magazine-quality HTML doc — a fixed house structure (hero, chips, TOC, hand-authored inline-SVG diagrams, callouts, tagged tables, code) skinned in the target product's brand (dark + light editorial fallback with an in-page toggle), then opened in the user's default browser on the machine they sit at. The canonical LOOK for plan mode, /plan Step 9, and /swarm:plan. Triggers on: render a plan, present a plan, plan-as-HTML, open the plan in the browser, plan mode, show the plan visually."
allowed-tools: Bash(scp*), Bash(agents ssh*), Bash(open*), Bash(xdg-open*), Bash(find*), Write
user-invocable: true
---

# plan-render — plans as browser-ready HTML

A plan buried in terminal scrollback is hard to review. Render every implementation
plan as **one self-contained `.html`** (inline CSS, no CDN/framework — opens offline
by double-click) and open it in the user's default browser on the machine they sit at.
This is the single source of the plan LOOK; `/plan` Step 9 and `/swarm:plan` reference it.

Start from **`template.html`** (in this skill dir); **`example.html`** is the gold
reference (the remote-run bookkeeping plan). Write the filled copy to
`/tmp/plan-<slug>.html`.

## Structure — fixed house layout

Every plan has, in order:

- **Hero** — `.kicker` (mono, uppercased: `PRODUCT · plan mode · …`), an `<h1>` with one
  `.accent` phrase, a ~3-line `.sub` problem statement, `.chip` metadata (files touched,
  new helpers, `status: awaiting go`), and a `.toc` of numbered sections.
- **Numbered `<h2>` sections** (`<span class="n">01</span>…`) — context/problem first,
  then design, then a files table, then edge cases / verification.
- **≥1 hand-authored inline `<svg>` figure** in a `.fig` — a timeline, an architecture
  sketch, or a before/after `.grid2` comparison. **Never mermaid.** Diagrams are what make
  the plan land; a plan with zero figures is not done.
- **`.callout`** (and `.callout.warn`) for the load-bearing takeaway/caveat.
- **Tagged tables** — `.tag.a/.b/.c` pills (new / edit / keep) in the leftmost cell.
- **`<pre>`** code with `.c/.k/.s/.r` spans for the 1–2 key snippets.
- **`.foot`** — one mono line, ending `next: go / reshape`.

## Theme — match the product, don't impose one

Before rendering, **probe the target repo for its brand** and skin the plan in it by
editing only the two `:root` blocks (`--bg --panel --ink --dim --line --accent …`).
Fall through in order; first hit wins:

1. **Design tokens** — `design-system.css`, `theme.ts/css`, `tokens.json`, a `brand/` dir.
2. **Framework config** — `tailwind.config.*` theme colors, global CSS custom properties.
3. **Brand assets** — logo / favicon / `site.webmanifest` `theme_color`; sample the dominant hues.
4. **Live UI** — screenshots or a running app; eyedrop the palette.
5. **House fallback** — the dark + light editorial palette shipped in `template.html`,
   used **only** when the product declares no brand. Keep diagrams as dark blueprint cards.

Match the product's accent, surface, and ink; keep the house *structure* regardless.

## Light + dark, with a toggle

The house fallback ships **both** palettes and an in-page `◐` toggle (top-right) that
defaults to the OS `prefers-color-scheme` — so a user in bright light on a light-mode
machine gets the readable light theme automatically, and can flip either way. Keep the
toggle even when re-skinning to a brand that defines both light and dark tokens. The
light accent is darkened for AA contrast on a light surface (`--accent:#4d7c0f` in the
fallback); pick a similarly contrast-safe accent when theming.

## Open it on the machine the user sits at

Render, then open — **proactively, every time**, so an away user finds it waiting.

1. Identify the browser host from the **Host & Fleet** context injected at session start
   (`hooks/07-inject-device-topology.sh`): the **online macOS device** where the user sits.
   Resolve it dynamically — **never hardcode a host name**. If several Macs are online,
   prefer online+direct; ask once only if genuinely ambiguous.
2. Open it:
   - **On that host already** (`hostname` matches): `open /tmp/plan-<slug>.html` (macOS) /
     `xdg-open` (Linux). macOS `open` uses the user's **default browser**.
   - **Remote** (you're on a Linux node): copy over and open there —
     ```bash
     scp /tmp/plan-<slug>.html <browser-host>:/tmp/ \
       && agents ssh <browser-host> 'open /tmp/plan-<slug>.html'
     ```
3. Tell the user it opened in their browser, with a 2–3 line summary and the path.

Skip the open (not the render) only when there is **no reachable browser host**
(headless-only fleet) — say so, and still write the `.html`.

## Checklist before you present

- [ ] Self-contained HTML at `/tmp/plan-<slug>.html`, opens offline.
- [ ] Skinned in the product's brand, or the house fallback if none.
- [ ] ≥1 hand-authored inline-SVG figure; no mermaid, no CDN.
- [ ] Light/dark toggle present, defaults to `prefers-color-scheme`.
- [ ] Opened on the resolved online Mac's default browser (or headless noted).
