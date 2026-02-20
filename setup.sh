#!/bin/bash
# Setup script for .agents repo
# Run once after cloning: ./setup.sh

set -e

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "Setting up .agents repo..."

# Configure git to use our hooks
git config core.hooksPath .githooks
echo "✓ Git hooks configured"

# Ensure hooks are executable
chmod +x "$REPO_ROOT/.githooks/"* 2>/dev/null || true
echo "✓ Hooks made executable"

echo ""
echo "Setup complete!"
