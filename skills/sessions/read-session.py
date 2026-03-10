#!/usr/bin/env python3
"""Read a Claude/Codex session JSONL and output a clean conversation transcript.

Usage:
    read-session.py <session.jsonl> [--full] [--tools]

Options:
    --full      Show full tool inputs/outputs (default: summary only)
    --tools     Show tool calls as one-liners (default: hide completely)

Without flags, shows only user messages and assistant text — the conversation.
"""

import json
import sys
import os
from datetime import datetime, timezone


def format_ts(ts_str):
    """Format ISO timestamp to short date-time."""
    try:
        dt = datetime.fromisoformat(ts_str.replace("Z", "+00:00"))
        return dt.strftime("%b %d %H:%M")
    except (ValueError, AttributeError):
        return ""


def truncate(s, n=200):
    """Truncate string to n chars with ellipsis."""
    if len(s) <= n:
        return s
    return s[:n] + "..."


def summarize_tool_use(block):
    """One-line summary of a tool_use block."""
    name = block.get("name", "?")
    inp = block.get("input", {})

    if name in ("Read", "Write", "Edit"):
        path = inp.get("file_path", "")
        # Shorten home dir
        path = path.replace(os.path.expanduser("~"), "~")
        return f"{name} {path}"
    elif name == "Glob":
        return f"Glob {inp.get('pattern', '')}"
    elif name == "Grep":
        return f"Grep {inp.get('pattern', '')} {inp.get('path', '')}"
    elif name == "Bash":
        cmd = inp.get("command", "")
        cmd = cmd.replace("\n", " ").strip()
        return f"Bash: {truncate(cmd, 120)}"
    elif name == "Task":
        desc = inp.get("description", inp.get("prompt", ""))
        return f"Task: {truncate(desc, 100)}"
    elif name in ("TaskCreate", "TaskUpdate", "TaskList"):
        subj = inp.get("subject", inp.get("taskId", ""))
        return f"{name}: {truncate(str(subj), 80)}"
    elif name in ("WebSearch", "WebFetch"):
        q = inp.get("query", inp.get("url", ""))
        return f"{name}: {truncate(q, 100)}"
    else:
        # Generic: show first meaningful field
        for key in ("file_path", "pattern", "command", "prompt", "query", "url", "content"):
            if key in inp:
                return f"{name}: {truncate(str(inp[key]), 100)}"
        return name


def summarize_tool_result(block, full=False):
    """One-line summary of a tool_result block."""
    content = block.get("content", "")
    if isinstance(content, list):
        texts = []
        for item in content:
            if isinstance(item, dict) and "text" in item:
                texts.append(item["text"])
        content = "\n".join(texts)

    if not content or not isinstance(content, str):
        return "(empty)"

    if full:
        return content

    lines = content.strip().split("\n")
    if len(lines) <= 3:
        return content.strip()
    return f"({len(lines)} lines, {len(content)} chars)"


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    path = sys.argv[1]
    show_full = "--full" in sys.argv
    show_tools = "--tools" in sys.argv or show_full

    if not os.path.exists(path):
        print(f"File not found: {path}")
        sys.exit(1)

    with open(path) as f:
        lines = f.readlines()

    # Extract session info from first line
    first = json.loads(lines[0])
    session_id = first.get("sessionId", "?")
    slug = first.get("slug", "")
    version = first.get("version", "")
    project = first.get("cwd", "")
    ts = format_ts(first.get("timestamp", ""))

    print(f"Session: {session_id}")
    if slug:
        print(f"Slug: {slug}")
    if version:
        print(f"Version: {version}")
    if project:
        print(f"Project: {project}")
    if ts:
        print(f"Started: {ts}")
    print(f"Messages: {len(lines)}")
    print("=" * 60)
    print()

    for line in lines:
        try:
            d = json.loads(line.strip())
        except json.JSONDecodeError:
            continue

        msg = d.get("message", {})
        role = msg.get("role", "")
        content = msg.get("content", "")
        ts = format_ts(d.get("timestamp", ""))

        if not isinstance(content, list):
            continue

        for block in content:
            if not isinstance(block, dict):
                continue

            btype = block.get("type", "")

            if btype == "text" and role == "user":
                text = block.get("text", "").strip()
                if text and text != "[Request interrupted by user]" and text != "[Request interrupted by user for tool use]":
                    print(f"USER [{ts}]:")
                    print(text)
                    print()
                elif text.startswith("[Request interrupted"):
                    print(f"USER [{ts}]: {text}")
                    print()

            elif btype == "text" and role == "assistant":
                text = block.get("text", "").strip()
                if text:
                    print(f"ASSISTANT [{ts}]:")
                    print(text)
                    print()

            elif btype == "tool_use" and show_tools:
                summary = summarize_tool_use(block)
                if show_full:
                    inp = json.dumps(block.get("input", {}), indent=2)
                    print(f"  TOOL [{ts}]: {summary}")
                    print(f"  INPUT: {inp}")
                    print()
                else:
                    print(f"  > {summary}")

            elif btype == "tool_result" and show_full:
                summary = summarize_tool_result(block, full=True)
                print(f"  RESULT: {truncate(summary, 500)}")
                print()


if __name__ == "__main__":
    main()
