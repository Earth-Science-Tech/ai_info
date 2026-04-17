# New Engineer Onboarding

## Prerequisites

- Windows 11 with Git, Node.js 22+, Python 3.11+ installed
- GitHub account added to Earth-Science-Tech org
- Claude Code installed (CLI or VS Code extension)
- Access to Azure Portal (for database and app service)
- Azure Data Studio or SSMS (for direct database access)

## Step 1: Clone Repositories

All repos should be siblings in the same parent directory:

```powershell
cd "C:\Users\<username>\OneDrive - Earth Science Tech, Inc\Desktop\eMed"

git clone https://github.com/Earth-Science-Tech/eMed.git emed_app
git clone https://github.com/Earth-Science-Tech/emed_etl.git
git clone https://github.com/Earth-Science-Tech/emed_sql.git
git clone https://github.com/Earth-Science-Tech/ai_info.git
```

## Step 2: Run Setup Script

```powershell
.\ai_info\scripts\setup.ps1
```

This copies shared rules and commands to each project.

## Step 3: Get Environment Files

Request `.env` files from a team lead. Each project needs its own `.env`:
- `emed_app/.env` — Azure SQL, session secret, API keys
- `emed_etl/.env` — Azure SQL, WooCommerce API, SSH/SFTP credentials

See `.env.example` in each repo for required variables.

## Step 4: Start the Application

```powershell
cd emed_app
npm install
node app.js
```

Visit `http://localhost:3000` in your browser.

## Step 5: Verify Claude Code

Open Claude Code in any project directory. It should automatically load:
- The project's CLAUDE.md
- Shared knowledge from ai_info (via @import directives)
- Skills like "push prod" and "create table"

Test by asking: "What are the org-wide coding standards?"

## Key Things to Know

1. **Three repos, one database** — emed_app, emed_etl, and emed_sql all share Azure SQL
2. **Least-privilege users** — App uses `emed_app`, ETL uses `emed_etl` (never the admin account)
3. **New tables need GRANTs** — Always create permission migration scripts
4. **Tag-based deployment** — Push a numeric tag (e.g., `1.0.4`) to deploy emed_app
5. **AI knowledge is shared** — The ai_info repo is auto-read by all Claude instances
