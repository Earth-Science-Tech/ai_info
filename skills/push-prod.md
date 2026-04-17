# Skill: Push Prod

## Trigger

When the user says **"push prod"** or similar.

## What to Do

### Standard: "push prod" (auto-increment)

1. Stage and commit any uncommitted changes with a descriptive commit message
2. Push to `master`
3. Look up the latest git tag: `git describe --tags --abbrev=0`
4. Increment the **patch version** (last number) by 1 (e.g., `1.0.3` → `1.0.4`)
5. Create an annotated tag with the new version
6. Push the tag to trigger the CI/CD pipeline

### Explicit version: "push prod x.x.x" (e.g., "push prod 2.0.0")

1. Stage and commit any uncommitted changes with a descriptive commit message
2. Push to `master`
3. Use the **explicitly specified version** as the tag
4. Create an annotated tag with that version
5. Push the tag to trigger the CI/CD pipeline

## Critical Rules

- **Tag format:** Always `x.x.x` — NO `v` prefix
  - `1.0.4` triggers the pipeline
  - `v1.0.4` does NOT trigger the pipeline (learned the hard way)
- **Annotated tags:** The tag message should briefly describe what's in the release
- **CI trigger:** The GitHub Actions workflow (`.github/workflows/deploy-azure.yml`) triggers on tags matching `[0-9]+.[0-9]+.[0-9]+`

## Example Commands

```bash
# Auto-increment patch
git add -A
git commit -m "feat(billing): add invoice PDF export"
git push origin master
git tag -a 1.0.4 -m "Add invoice PDF export"
git push origin 1.0.4

# Explicit version
git tag -a 2.0.0 -m "Major release: new billing system"
git push origin 2.0.0
```

## Applies To

- **emed_app** — primary project using this workflow
- Any future project with tag-based Azure deployment
