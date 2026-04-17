Share knowledge with the team by committing to the ai_info repository.

Instructions:
1. Ask the user what knowledge they want to share (or use context from the current conversation)
2. Determine the right location in ai_info:
   - Org-wide standards/rules → `../ai_info/org/`
   - Project-specific knowledge → `../ai_info/projects/<project>/`
   - Reusable skill/workflow → `../ai_info/skills/`
   - Company info → `../ai_info/companies/`
3. Read the ai_info directory to find existing files: `ls ../ai_info/`
4. Check if the knowledge already exists (search before writing)
5. Pull latest: `cd ../ai_info && git pull origin main`
6. Write or update the appropriate markdown file
7. Commit with a prefixed message:
   - `knowledge: <description>` for new facts
   - `skill: <description>` for new task instructions
   - `update: <description>` for edits to existing content
   - `fix: <description>` for corrections
8. Push: `git push origin main`
9. Report to user: "Updated ai_info: [what was changed]"

If git push fails due to conflicts:
1. `git pull --rebase origin main`
2. Resolve conflicts
3. `git push origin main`

Keep files concise (under 200 lines). Use markdown with headers and bullet points.
