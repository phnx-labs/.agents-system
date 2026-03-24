#!/bin/bash
# Loads environment and prints the requested variable.
# Usage: env.sh <key> [default]
source ~/.agents/.environment 2>/dev/null
key="$1"
default="$2"
val="${!key:-$default}"
echo -n "$val"
