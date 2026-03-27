---
name: mq
description: "Query markdown, HTML, and PDF files with mq CLI. Triggers on: exploring doc structure, extracting sections from large .md/.html/.pdf files, 'use mq', or when reading full documents wastes tokens."
---

# mq Skill: Efficient Document Querying

`mq` doesn't compute answers - it externalizes document structure into your context so you can reason to answers yourself. Works with Markdown, HTML, and PDF - same queries on all formats.

```
Documents (.md, .html, .pdf) → mq query → Structure enters your context → You reason → Results
```

## The Pattern

```
1. See structure    →  mq <path> .tree            → Map enters your context
2. Find relevant    →  mq <path> ".search('x')"   → Locations enter your context
3. Extract content  →  mq <path> ".section('Y') | .text"  → Content enters your context
                       mq <path> ".record(N)"     → (JSONL: full record at line N)
4. Reason           →  You compute the answer from what's now in your context
```

Your context accumulates structure. You do the final reasoning.

## Quick Reference

```bash
# Structure (your working index) - works on .md, .html, .pdf, .jsonl
mq file.md .tree                    # Document structure
mq page.html .tree                  # HTML heading/section structure
mq report.pdf .tree                 # PDF chapter/page structure
mq dir/ .tree                       # Directory overview (all supported formats, with sections + previews)

# Search
mq file.md ".search('term')"        # Find sections containing term
mq page.html ".search('term')"      # Search HTML sections
mq report.pdf ".search('term')"     # Search PDF sections
mq dir/ ".search('term')"           # Search across all files
mq log.jsonl ".search('error')"     # JSONL: line-level search with record context

# Extract
mq file.md ".section('Name') | .text"   # Get section content
mq page.html ".section('Nav') | .text"  # Get HTML section content
mq report.pdf ".section('Ch 1') | .text" # Get PDF section content
mq file.md ".code('python')"            # Get code blocks by language
mq page.html ".code('js')"              # Get code from HTML <pre><code>
mq file.md .links                       # Get all links
mq file.md .metadata                    # Get YAML frontmatter
mq log.jsonl '.record(7)'               # JSONL: pretty-print record at line 7
```

## Efficient Workflow

### Starting: Get the Map

```bash
# For a single file
mq README.md .tree

# For a directory (start here for multi-file exploration)
mq docs/ .tree
```

Output shows you the territory:
```
docs/ (7 files, 42 sections)
├── API.md (234 lines, 12 sections)
│   ├── # API Reference
│   │        "Complete reference for all REST endpoints..."
│   ├── ## Authentication
│   │        "All requests require Bearer token..."
```

Now you know: API.md has auth info, 234 lines, section called "Authentication".

### Finding: Narrow Down

If you need something specific but don't know where:

```bash
mq docs/ ".search('OAuth')"
```

Output points you to exact locations:
```
Found 3 matches for "OAuth":

docs/auth.md:
  ## Authentication (lines 34-89)
     "...OAuth 2.0 authentication flow..."
  ## OAuth Flow (lines 45-67)
```

Now you know: auth.md, section "OAuth Flow", lines 45-67.

### Extracting: Get Only What You Need

Don't read the whole file. Extract the section:

```bash
mq docs/auth.md ".section('OAuth Flow') | .text"
```

This returns just that section's content.

## Anti-Patterns

**Bad**: Reading entire files
```bash
cat docs/auth.md  # Wastes tokens on irrelevant content
```

**Good**: Query then extract
```bash
mq docs/auth.md .tree                           # See structure
mq docs/auth.md ".section('OAuth Flow') | .text"  # Get only what's needed
```

**Bad**: Re-querying structure you already have
```bash
mq docs/ .tree    # First time - good
mq docs/ .tree    # Again - wasteful, you already have this in context
```

**Good**: Use what's in your context
```bash
mq docs/ .tree    # Once - now you know the structure
# Use the structure you learned to make targeted queries
mq docs/auth.md ".section('OAuth') | .text"
```

## Context as Working Memory

Every mq output enters your context. Your context becomes a working index that grows as you explore:

```
Query 1: mq docs/ .tree
→ You now see: file list, line counts, section counts
→ You can reason: "auth.md looks relevant to my question"

Query 2: mq docs/auth.md .tree
→ You now see: auth.md's full section hierarchy
→ You can reason: "OAuth Flow section has what I need"

Query 3: mq docs/auth.md ".section('OAuth Flow') | .text"
→ You now have: the actual content
→ You can reason: compute the final answer
```

mq externalizes structure. You do the thinking. Don't re-query what you already see.

## Examples by Task

### "Find something in a JSONL session file"
```bash
mq session.jsonl ".search('deploy')"  # Line-level matches with record type
# → [line 5] user/user
#     content: Can you deploy the new version?
#     ts: 2026-02-01T20:25:29Z
# → [line 8] assistant/tool_use: Bash
#     ts: 2026-02-01T20:25:34Z

mq session.jsonl '.record(8)'         # Full pretty-printed JSON of that record
```

### "Find how authentication works"
```bash
mq docs/ ".search('auth')"           # Find relevant files/sections
mq docs/auth.md ".section('Overview') | .text"  # Read the overview
```

### "Get all Python examples"
```bash
mq docs/ .tree                       # Find files with examples
mq docs/examples.md ".code('python')"  # Extract all Python code
```

### "Understand the API structure"
```bash
mq docs/api.md .tree                 # See all endpoints/sections
mq docs/api.md ".section('Endpoints') | .tree"  # Drill into endpoints
mq docs/api.md ".section('POST /users') | .text"  # Get specific endpoint
```

### "Find configuration options"
```bash
mq . ".search('config')"             # Search entire project
mq config.md ".section('Options') | .text"  # Extract options
```

### "Extract content from an HTML page"
```bash
mq page.html .tree                           # See heading structure
mq page.html ".section('Features') | .text"  # Get specific section
mq page.html .links                          # Get all links
```

### "Query a PDF report"
```bash
mq report.pdf .tree                          # See chapter/section structure
mq report.pdf ".search('conclusion')"        # Find relevant sections
mq report.pdf ".section('Results') | .text"  # Extract section content
```
