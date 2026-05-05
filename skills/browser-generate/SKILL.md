---
name: browser-generate
description: "Generate images, videos, or other content via browser-based platforms that do not expose an API. Uses OpenClaw browser automation to drive platforms like Higgsfield, Panic, Runway, and others. Load this skill when the user wants to generate content on a platform without a direct API."
argument-hint: "[platform] [mode] prompt"
allowed-tools: Bash(sleep*), Bash(ssh*), Bash(*/env.sh*), Bash(openclaw*), Bash(agent-browser*)
user-invocable: true
---

# Browser-Based Generation

Generate content via browser-based platforms that do not expose a public API. This skill uses browser automation (OpenClaw) to drive the platform's web UI.

## Supported Platforms

| Platform | Content Type | Backend File |
|----------|-------------|--------------|
| Higgsfield | Images, Videos | `higgsfield.md` |
| Panic | Images | `panic.md` |
| Other | Varies | Add a new backend file |

## How to Use

1. Identify the platform from the user's request
2. Load the corresponding backend file for platform-specific instructions
3. Follow the browser automation workflow
4. Download or extract the generated content

## General Workflow

All platforms follow this pattern:

1. **Open** the generation page in a new tab
2. **Focus** the tab
3. **Snapshot** to see structure and get refs
4. **Configure** settings (aspect ratio, model, etc.)
5. **Type** the prompt
6. **Generate** and poll for completion
7. **Download** results
8. **Close** the tab

## Browser Setup

Read the `/browser` skill first for general browser automation guidelines.

**CRITICAL: Always pass `--browser-profile <your-profile>` on every command.** Each agent has a dedicated browser profile with its own login sessions.

```bash
# Check if OpenClaw is available
which openclaw

# Basic pattern
openclaw browser open <url> --browser-profile <your-profile>
openclaw browser snapshot --labels
openclaw browser click <ref>
openclaw browser type <ref> 'prompt'
openclaw browser screenshot
openclaw browser close <targetId>
```

## Adding a New Platform

To add support for a new platform:

1. Create a new `<platform>.md` file in this skill directory
2. Document the platform's URL, workflow, selectors, and quirks
3. Update the Supported Platforms table above
4. Follow the existing backend files as templates

## Guidelines

- **Set configuration FIRST** -- aspect ratio, model, etc. before typing the prompt
- **Verify settings EVERY TIME** -- platforms often remember last-used settings
- **Re-snapshot after every action** -- refs change after typing, clicking, etc.
- **Use `--browser-profile`** -- never omit it
- **Poll with screenshots** -- don't sleep; take screenshots every 15s to check progress
