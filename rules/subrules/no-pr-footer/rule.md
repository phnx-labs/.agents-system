# No Claude-Code Footer

Never add the "Generated with Claude Code" promo line — or any `🤖 Generated with …`, `claude.com/claude-code`, or `claude.ai/code` variant — to PR bodies, GitHub issue bodies, or commit messages. Muqsit called it garbage. Applies to `gh pr create`/`edit`, `gh issue create`/`edit`, and `git commit`.

Enforced by the bundled `footer-guard.sh` (PreToolUse): a `gh`/`git commit` command whose inline body carries the footer is blocked. If you hit the block, delete the footer line and retry — don't work around the guard.
