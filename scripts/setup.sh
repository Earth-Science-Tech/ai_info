#!/bin/bash
# ai_info Setup Script (Unix)
# Run this once after cloning ai_info to configure sibling projects.
# Usage: ./ai_info/scripts/setup.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AI_INFO_DIR="$(dirname "$SCRIPT_DIR")"
PARENT_DIR="$(dirname "$AI_INFO_DIR")"

echo "ai_info Setup Script"
echo "==================="
echo ""
echo "ai_info directory: $AI_INFO_DIR"
echo "Parent directory:  $PARENT_DIR"
echo ""

# Pull latest
echo "Pulling latest ai_info..."
cd "$AI_INFO_DIR"
git pull origin main 2>&1 || echo "  Warning: Could not pull"
echo ""

# Process each project
for PROJECT_NAME in emed_app emed_etl emed_sql; do
    PROJECT_PATH="$PARENT_DIR/$PROJECT_NAME"

    if [ ! -d "$PROJECT_PATH" ]; then
        echo "  [--] $PROJECT_NAME (not found, skipping)"
        continue
    fi

    echo "Configuring $PROJECT_NAME..."

    # Map project name to ai_info project dir
    case $PROJECT_NAME in
        emed_app) PROJECT_RULES="emed-app" ;;
        emed_etl) PROJECT_RULES="emed-etl" ;;
        emed_sql) PROJECT_RULES="emed-sql" ;;
    esac

    # Create directories
    mkdir -p "$PROJECT_PATH/.claude/rules"
    mkdir -p "$PROJECT_PATH/.claude/commands"

    # Copy org rules
    if [ -d "$AI_INFO_DIR/org/rules" ]; then
        cp "$AI_INFO_DIR/org/rules/"*.md "$PROJECT_PATH/.claude/rules/" 2>/dev/null && \
            echo "  Copied org rules" || true
    fi

    # Copy project-specific rules
    if [ -d "$AI_INFO_DIR/projects/$PROJECT_RULES/rules" ]; then
        cp "$AI_INFO_DIR/projects/$PROJECT_RULES/rules/"*.md "$PROJECT_PATH/.claude/rules/" 2>/dev/null && \
            echo "  Copied project rules" || true
    fi

    # Copy shared commands
    if [ -d "$AI_INFO_DIR/commands" ]; then
        cp "$AI_INFO_DIR/commands/"*.md "$PROJECT_PATH/.claude/commands/" 2>/dev/null && \
            echo "  Copied commands" || true
    fi

    # Check CLAUDE.md for imports
    if [ -f "$PROJECT_PATH/CLAUDE.md" ]; then
        if grep -q "ai_info" "$PROJECT_PATH/CLAUDE.md"; then
            echo "  [OK] CLAUDE.md has ai_info imports"
        else
            echo "  [!] CLAUDE.md does not reference ai_info"
        fi
    fi

    echo ""
done

echo "Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Ensure each project's CLAUDE.md has @import directives for ai_info"
echo "  2. Start Claude Code in any project to verify shared knowledge loads"
echo ""
