# ai_info Setup Script
# Run this once after cloning ai_info to configure sibling projects.
# Usage: .\ai_info\scripts\setup.ps1

param(
    [switch]$Force  # Overwrite existing files
)

$ErrorActionPreference = "Stop"

# Determine paths
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$aiInfoDir = Split-Path -Parent $scriptDir
$parentDir = Split-Path -Parent $aiInfoDir

Write-Host "ai_info Setup Script" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host ""

# Verify ai_info location
Write-Host "ai_info directory: $aiInfoDir"
Write-Host "Parent directory:  $parentDir"
Write-Host ""

# Define sibling projects and their mappings
$projects = @(
    @{
        Name = "emed_app"
        Path = Join-Path $parentDir "emed_app"
        ProjectRules = "emed-app"
    },
    @{
        Name = "emed_etl"
        Path = Join-Path $parentDir "emed_etl"
        ProjectRules = "emed-etl"
    },
    @{
        Name = "emed_sql"
        Path = Join-Path $parentDir "emed_sql"
        ProjectRules = "emed-sql"
    }
)

# Check which projects exist
Write-Host "Checking sibling projects..." -ForegroundColor Yellow
foreach ($project in $projects) {
    if (Test-Path $project.Path) {
        Write-Host "  [OK] $($project.Name)" -ForegroundColor Green
    } else {
        Write-Host "  [--] $($project.Name) (not found, skipping)" -ForegroundColor DarkGray
    }
}
Write-Host ""

# Pull latest ai_info
Write-Host "Pulling latest ai_info..." -ForegroundColor Yellow
Push-Location $aiInfoDir
try {
    $pullResult = git pull origin main 2>&1
    Write-Host "  $pullResult" -ForegroundColor DarkGray
} catch {
    Write-Host "  Warning: Could not pull (may not have remote set up yet)" -ForegroundColor DarkYellow
}
Pop-Location
Write-Host ""

# Process each project
foreach ($project in $projects) {
    if (-not (Test-Path $project.Path)) { continue }

    Write-Host "Configuring $($project.Name)..." -ForegroundColor Yellow

    # Create .claude/rules/ directory
    $rulesDir = Join-Path $project.Path ".claude" "rules"
    if (-not (Test-Path $rulesDir)) {
        New-Item -ItemType Directory -Path $rulesDir -Force | Out-Null
        Write-Host "  Created .claude/rules/" -ForegroundColor Green
    }

    # Create .claude/commands/ directory
    $commandsDir = Join-Path $project.Path ".claude" "commands"
    if (-not (Test-Path $commandsDir)) {
        New-Item -ItemType Directory -Path $commandsDir -Force | Out-Null
        Write-Host "  Created .claude/commands/" -ForegroundColor Green
    }

    # Copy org rules
    $orgRulesDir = Join-Path $aiInfoDir "org" "rules"
    if (Test-Path $orgRulesDir) {
        $orgRules = Get-ChildItem -Path $orgRulesDir -Filter "*.md"
        foreach ($rule in $orgRules) {
            $dest = Join-Path $rulesDir $rule.Name
            if ($Force -or -not (Test-Path $dest)) {
                Copy-Item $rule.FullName $dest -Force
                Write-Host "  Copied rule: $($rule.Name)" -ForegroundColor DarkGreen
            }
        }
    }

    # Copy project-specific rules
    $projectRulesDir = Join-Path $aiInfoDir "projects" $project.ProjectRules "rules"
    if (Test-Path $projectRulesDir) {
        $projectRules = Get-ChildItem -Path $projectRulesDir -Filter "*.md"
        foreach ($rule in $projectRules) {
            $dest = Join-Path $rulesDir $rule.Name
            if ($Force -or -not (Test-Path $dest)) {
                Copy-Item $rule.FullName $dest -Force
                Write-Host "  Copied rule: $($rule.Name)" -ForegroundColor DarkGreen
            }
        }
    }

    # Copy shared commands
    $commandsSrcDir = Join-Path $aiInfoDir "commands"
    if (Test-Path $commandsSrcDir) {
        $commands = Get-ChildItem -Path $commandsSrcDir -Filter "*.md"
        foreach ($cmd in $commands) {
            $dest = Join-Path $commandsDir $cmd.Name
            if ($Force -or -not (Test-Path $dest)) {
                Copy-Item $cmd.FullName $dest -Force
                Write-Host "  Copied command: $($cmd.Name)" -ForegroundColor DarkGreen
            }
        }
    }

    # Check for @import directives in CLAUDE.md
    $claudeMd = Join-Path $project.Path "CLAUDE.md"
    if (Test-Path $claudeMd) {
        $content = Get-Content $claudeMd -Raw
        if ($content -notmatch "ai_info") {
            Write-Host "  [!] CLAUDE.md does not reference ai_info" -ForegroundColor DarkYellow
            Write-Host "      Add @import directives - see ai_info/team/claude-setup.md" -ForegroundColor DarkYellow
        } else {
            Write-Host "  [OK] CLAUDE.md has ai_info imports" -ForegroundColor Green
        }
    } else {
        Write-Host "  [!] No CLAUDE.md found" -ForegroundColor DarkYellow
    }

    Write-Host ""
}

Write-Host "Setup complete!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Ensure each project's CLAUDE.md has @import directives for ai_info"
Write-Host "  2. Start Claude Code in any project to verify shared knowledge loads"
Write-Host "  3. Ask Claude: 'What are the org-wide coding standards?' to test"
Write-Host ""
