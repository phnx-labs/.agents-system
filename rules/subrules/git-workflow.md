# Agentic Git Workflow

Rules for agent-driven git operations that go beyond basic read-only + commit/push.

## Session Export on PRs

Every PR must include a session transcript as a GitHub Gist — no exceptions.

### Workflow

1. **Export session** — Run `agents sessions --last 50 --markdown` to capture the conversation
2. **Create a SECRET gist** — Use `gh gist create` *without* `--public`. Session transcripts can leak repo internals, tool output, and infra details; never publish them by default. Use `--public` only when the target repo is itself public AND you've reviewed the transcript for sensitive content.
   ```bash
   agents sessions --last 50 --markdown > /tmp/session-export.md
   gh gist create /tmp/session-export.md --desc "Session transcript for PR"
   ```
3. **Attach to PR** — Add the gist URL to the PR description. Secret gists are URL-only access — anyone with the link can view, but the gist is not indexed or discoverable.

### PR Description Format

```
## Session Context
[Session transcript](https://gist.github.com/...)
```

This creates an audit trail linking code changes to the reasoning that produced them.
