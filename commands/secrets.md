---
description: Manage secrets via macOS Keychain-backed bundles
---

You are managing secrets for: $ARGUMENTS

Load the `/secrets` skill and use `agents secrets` to handle credentials.

## Quick Commands

```bash
# List existing bundles
agents secrets list

# Create a new bundle
agents secrets create production

# Add a secret
agents secrets add production API_KEY

# View a bundle (masked by default)
agents secrets view production

# Export to .env file
agents secrets export production .env
```

## Security

- Secrets are stored in macOS Keychain (never touch disk in plaintext); macOS-only today
- Use `--reveal` sparingly and carefully
- Separate bundles per environment (dev, staging, production)

## Usage in Agent Runs

```bash
agents run --secrets production
# Injects all secrets from the production bundle
```

Load the skill for full documentation on secrets management.
