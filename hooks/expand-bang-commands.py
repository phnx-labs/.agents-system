#!/usr/bin/env python3
"""
Expands `! command` patterns in prompts by executing them in the session cwd.

Examples:
  "List files in `! ls agents`"  -> "List files in `agent1.md agent2.md`"
  "Check `! pwd`"                -> "Check `/Users/muqsit/project`"
"""

import json
import os
import re
import subprocess
import sys


def expand_commands(prompt: str, cwd: str) -> str:
    """Find all `! command` patterns and replace with command output."""

    # Pattern: backtick, exclamation, space, command, backtick
    pattern = r'`! ([^`]+)`'

    def replace_match(match):
        command = match.group(1).strip()
        try:
            result = subprocess.run(
                f"cd {cwd} && {command}",
                shell=True,
                capture_output=True,
                text=True,
                timeout=5
            )
            output = result.stdout.strip()
            if result.returncode != 0 and not output:
                output = f"[error: {result.stderr.strip()}]"
            return f"`{output}`"
        except subprocess.TimeoutExpired:
            return "`[timeout]`"
        except Exception as e:
            return f"`[error: {e}]`"

    return re.sub(pattern, replace_match, prompt)


def main():
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    prompt = data.get("prompt", "")
    cwd = data.get("cwd", os.getcwd())

    # Check if any `! command` patterns exist
    if "`! " not in prompt:
        sys.exit(0)

    expanded = expand_commands(prompt, cwd)

    if expanded != prompt:
        print("<user-prompt-submit-hook>")
        print(expanded)
        print("</user-prompt-submit-hook>")

    sys.exit(0)


if __name__ == "__main__":
    main()
