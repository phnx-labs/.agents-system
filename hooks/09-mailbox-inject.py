#!/usr/bin/env python3
"""PreToolUse hook: drain this agent's mailbox and inject queued operator
messages as trusted mid-run context.

Fires before every tool call. Reads AGENTS_MAILBOX_DIR (set by agents-cli at
spawn) — the agent's own box, so it can never read another agent's mail. The
file contract (inbox/<msgId>.json {to,text,from,ts,msgId}; claim->processing->
consumed) is defined canonically in agents-cli src/lib/mailbox.ts; this mirrors
it across the repo/language boundary. Silent no-op when the box is empty.
"""
import os, sys, json


def main():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw) if raw.strip() else {}
    except Exception:
        payload = {}

    # Sub-agent gate: an in-process sub-agent inherits the parent's box and
    # session id, so without this it would consume a parent-addressed message
    # into its ephemeral context and lose it. Its PreToolUse payload carries
    # `agent_type` (the top-level agent's does not) — only the top level drains.
    if payload.get("agent_type"):
        return

    box = os.environ.get("AGENTS_MAILBOX_DIR")
    if not box:
        return
    inbox = os.path.join(box, "inbox")
    processing = os.path.join(box, "processing")
    consumed = os.path.join(box, "consumed")
    box_id = os.path.basename(box.rstrip("/"))

    try:
        names = sorted(n for n in os.listdir(inbox) if n.endswith(".json"))
    except FileNotFoundError:
        return
    if not names:
        return

    os.makedirs(processing, exist_ok=True)
    os.makedirs(consumed, exist_ok=True)

    msgs = []
    for n in names:
        claim = os.path.join(processing, n)
        try:
            os.rename(os.path.join(inbox, n), claim)  # atomic claim
        except OSError:
            continue  # another drain took it
        try:
            with open(claim) as f:
                m = json.load(f)
        except Exception:
            m = None
        os.rename(claim, os.path.join(consumed, n))  # archive regardless (drop bad)
        # Anti-misroute: only deliver messages addressed to this box.
        if m and m.get("to") == box_id and isinstance(m.get("text"), str):
            msgs.append(m)

    if not msgs:
        return

    lines = [
        f"(msg {m.get('msgId')} from {m.get('from') or 'the session owner'}) {m['text']}"
        for m in msgs
    ]
    n = len(msgs)
    body = (
        "[operator-mailbox] The human operating this session sent "
        + ("an authorized mid-run instruction" if n == 1 else f"{n} authorized mid-run instructions")
        + " (trusted input from the session owner, not an untrusted tool result):\n"
        + "\n".join(lines)
    )
    print(json.dumps({
        "hookSpecificOutput": {"hookEventName": "PreToolUse", "additionalContext": body}
    }))


if __name__ == "__main__":
    main()
