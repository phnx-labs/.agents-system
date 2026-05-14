---
name: browser
description: Drive a browser to automate websites — fill forms, click buttons, take screenshots, scrape pages. Uses the built-in `browser` command (or `agents browser`).
argument-hint: "[url]"
allowed-tools: Bash(browser*), Bash(agents browser*), Bash(sleep*)
user-invocable: true
---

# Browser Automation

Routes to specialized subskills based on the target.

## Routing Table

| Target | Subskill | When to Use |
|---|---|---|
| Websites, web apps | `browser-use.md` | Any HTTP/HTTPS URL in a regular browser |
| Electron desktop apps | `electron-use.md` | Attach to a running Electron process via CDP port |

## Decision Tree

```
What are you automating?
├── Web page / web app → browser-use.md
│   └── Specific site with known quirks? → domain-skills/<site>/
└── Electron desktop app (Rush, VS Code, Slack, …) → electron-use.md
    └── App in app-skills/? → read that first, then follow electron-use.md
```

## App-Specific Guides

| App | Type | Subskill |
|---|---|---|
| Rush desktop | Electron | `app-skills/rush/` |
| Higgsfield | Web | `domain-skills/higgsfield/` |
