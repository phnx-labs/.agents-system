# Agentic Git Workflow

## Session export on PRs

Every PR includes a session transcript as a SECRET GitHub Gist.

```bash
agents sessions --last 50 --markdown > /tmp/session-export.md
gh gist create /tmp/session-export.md --desc "Session transcript for PR"
```

Never `--public` by default — transcripts can leak repo internals, tool output, infra details. Only `--public` when the target repo is public AND the transcript is reviewed.

Attach the gist URL in the PR description:

```
## Session Context
[Session transcript](https://gist.github.com/...)
```

Secret gists are URL-only access — not indexed, not discoverable. Creates an audit trail linking code to reasoning.
