# Development Environment

## Required Software

| Tool | Version | Purpose |
|------|---------|---------|
| Git | Latest | Version control |
| Node.js | 22.x | emed_app runtime |
| Python | 3.11+ | emed_etl runtime |
| npm | Included with Node | Package management |
| pip | Included with Python | Package management |
| Claude Code | Latest | AI development assistant |
| Azure Data Studio or SSMS | Latest | Database management |

## Accounts Required

| Service | Access Needed | Who Grants |
|---------|--------------|------------|
| GitHub (Earth-Science-Tech org) | Write access to repos | Org admin |
| Azure Portal | Contributor on resource group | Azure admin |
| Azure SQL | emed_app and emed_etl user credentials | Team lead |
| WooCommerce API (Peaks) | Consumer key/secret | Team lead |
| Cloudways SSH | SSH credentials | Team lead |

## IDE Setup

### VS Code (recommended)
- Install Claude Code extension
- Install ESLint extension
- Install Prettier extension

### Editor Settings
Use `.editorconfig` (included in each project):
- 2 spaces for JS/TS
- 4 spaces for Python
- UTF-8, LF line endings

## Database Access

- **Server:** liberty-link.database.windows.net
- **Database:** liberty_link_stage
- **Auth:** SQL authentication (credentials in `.env`)
- **Admin access:** Only for schema changes (request from team lead)
