---
description: Spawn single subagent to implement a task with full context
---

Spawn subagent for: $ARGUMENTS

## Process

1. **Gather context BEFORE spawning:**
   - Read relevant files
   - Trace code paths involved
   - Identify patterns to follow
   - Note constraints from project CLAUDE.md

2. **Select agent type:**

   | Agent | Best For |
   |-------|----------|
   | codex | Self-contained features, straightforward implementations, fast/cheap |
   | cursor | Bug fixes, debugging, tracing through codebases |
   | gemini | Complex multi-system features, architectural changes |
   | claude | Maximum capability, research, exploration |

3. **Write detailed prompt including:**
   - **Background**: What and why (business context)
   - **File paths**: Specific paths WITH line numbers (e.g., `src/auth/login.ts:45-85`)
   - **Patterns**: Paste code examples inline, don't just reference them
   - **Success criteria**: What "done" looks like
   - **Constraints**: From project docs, style guides, etc.

4. **Spawn the agent:**
   - For a single task: use `agents run` or the agent's native CLI
   - For parallel work: use `agents teams create`, `agents teams add`, `agents teams start`
   
   Example with teams:
   ```bash
   agents teams create <task-name>
   agents teams add <task-name> <agent-type> "detailed prompt..." --name <role> --mode edit
   agents teams start <task-name>
   ```

5. **Monitor and report** results when complete

## Guidelines

- ALWAYS gather context first - agents with context succeed, agents without fail
- Paste code patterns inline rather than saying "follow the pattern in X"
- Be specific about file paths and line numbers
- Include any project-specific rules (no mocking, style preferences, etc.)
- For implementation tasks, use mode: "edit". For research, use mode: "plan"
