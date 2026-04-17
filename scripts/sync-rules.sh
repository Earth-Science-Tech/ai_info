#!/bin/bash
# ai_info Sync Script (Unix)
# Pulls latest ai_info and re-copies rules/commands to sibling projects.
# Usage: ./ai_info/scripts/sync-rules.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AI_INFO_DIR="$(dirname "$SCRIPT_DIR")"

echo "ai_info Sync"
echo ""

# Pull latest
echo "Pulling latest ai_info..."
cd "$AI_INFO_DIR"
git pull origin main 2>&1 || echo "  Warning: Could not pull"
echo ""

# Show recent changes
echo "Recent changes:"
git log --oneline -5
echo ""

# Re-run setup
echo "Syncing rules and commands..."
bash "$SCRIPT_DIR/setup.sh"
