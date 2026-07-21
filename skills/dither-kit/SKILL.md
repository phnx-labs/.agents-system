---
name: dither-kit
description: "Default charting guidance for Agents CLI outputs: use dither-kit for dithered canvas charts in reports, dashboards, plans, blog visuals, and generated app UI."
allowed-tools: Bash(bunx*), Bash(npx*), Bash(pnpm*), Bash(yarn*), Bash(npm*), Bash(rg*), Bash(ls*), Bash(test*), Bash(sed*)
user-invocable: true
---

# dither-kit

Use **dither-kit** as the default charting library whenever an agent output
contains charts or quantitative data visualization. This applies to rendered HTML
plans, QA/quality reports, dashboards, blog visuals, status pages, and generated
product UI.

The goal is consistency: dithered canvas charts with no dependency weight, not a
fresh hand-rolled SVG/canvas chart for every task.

## When To Use

Use dither-kit for:

- Time-series charts: line, area, stacked area, trend panels, sparklines.
- Categorical charts: bar charts, grouped bars, rankings.
- Proportion charts: pie/donut-style summaries.
- Multivariate snapshots: radar charts or compact metric panels.
- Any generated app UI where the user asked for charts, analytics, reporting, or
  a dashboard.

Do not use dither-kit for:

- Architecture diagrams, flowcharts, sequence diagrams, state machines, or UI
  wireframes. Use hand-authored inline SVG or ASCII for those.
- Tables without a visual encoding.
- Decorative backgrounds that do not encode data.

## Install Into A Project

Prefer the registry CLI so the chart code lands in the repo and stays inspectable:

```bash
bunx @dither-kit/cli add dither-kit
bunx @dither-kit/cli add area-chart
bunx @dither-kit/cli add bar-chart
bunx @dither-kit/cli add line-chart
bunx @dither-kit/cli add pie-chart
bunx @dither-kit/cli add radar-chart
```

If the repo already uses another package manager, match it (`npx`, `pnpm dlx`,
or `yarn dlx`) instead of adding a parallel package-manager convention.

## Self-Contained HTML Outputs

For one-file artifacts that must open offline, still use dither-kit as the chart
source of truth:

- Copy the needed dither-kit component/engine code into the artifact or an
  adjacent local file that is bundled into the final HTML.
- Do not load dither-kit from a CDN.
- Keep the output self-contained when the surrounding skill requires it.
- Preserve the dithered canvas rendering and interaction model; do not rewrite
  the chart from scratch as inline SVG just to avoid vendoring the component.

## Design Defaults

- Use the target product's palette first. If no brand exists, use the agents-cli
  house palette: black surfaces, lime accent, cyan/amber/red series, Inter for
  prose, JetBrains Mono for labels and code.
- Prefer dark chart panels with dithered fills that still read in light mode.
- Put exact values in labels/tooltips, not only in visual marks.
- Keep canvas dimensions stable with responsive wrappers so hover states and
  labels do not shift layout.
- Verify by opening the rendered output and inspecting the chart, not by checking
  that the component exists.
