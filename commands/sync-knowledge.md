Sync the latest shared knowledge from the ai_info repository.

Instructions:
1. Pull the latest ai_info content:
   ```bash
   cd ../ai_info && git pull origin main
   ```

2. Report what changed:
   ```bash
   git log --oneline -10
   ```

3. If running from emed_app, emed_etl, or emed_sql, also copy rules and commands:

   For the current project, copy rule files:
   ```bash
   # Determine current project
   # Copy org rules
   cp ../ai_info/org/rules/*.md .claude/rules/ 2>/dev/null
   # Copy project-specific rules
   cp ../ai_info/projects/<current-project>/rules/*.md .claude/rules/ 2>/dev/null
   # Copy shared commands
   cp ../ai_info/commands/*.md .claude/commands/ 2>/dev/null
   ```

4. Report: "Synced ai_info. Latest changes: [summary of recent commits]"
