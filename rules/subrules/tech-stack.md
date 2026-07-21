# Tooling & Stack Conventions

## Right tool for the job

| Task | Tool |
| --- | --- |
| Read a large file (200+ lines) or map an unfamiliar dir | `mq` — probe structure (`.tree`), then extract only the section you need. Works on **code (ts/py/go/…), docs (md/html/pdf), data (json/yaml/csv), Office** — not just docs. See `context-query-mq`. |
| Issue tracker (Linear/GitHub/Jira) | `/tickets` command — auto-detects |
| Browser automation | `browser` skill (a.k.a. `agents browser`) |
| Interactive terminal (REPLs, TUIs) | `agents pty` — see `agents pty --help` |
| Parallel coding agents | `agents teams` — see `parallel-teams` |
| Credentials | `agents secrets` — OS keychain-backed |
| Release/publish | `release` skill |
| Charts and dataviz | `dither-kit` skill — default for chart-producing HTML, dashboards, reports, plans, and blog visuals |
| See what's already in flight (open PRs, live sessions) before taking work | auto-injected at session start (`inject-repo-inflight` hook); on demand: `gh pr list`, `agents sessions --active` |

## Charting Default

Use **dither-kit** by default for any output that renders charts or quantitative
data visualizations: HTML plans, QA/quality reports, dashboards, blog visuals,
status pages, and generated app UI. It gives agents one sanctioned charting look
instead of ad-hoc inline SVG or one-off canvas code.

Reach for plain inline SVG/ASCII only for non-chart diagrams: architecture maps,
flowcharts, state machines, timelines without a quantitative axis, or UI mockups.
When a figure encodes numeric values, trends, distributions, or proportions, load
the `dither-kit` skill and use it.
