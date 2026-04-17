# ai_info Sync Script
# Pulls latest ai_info and re-copies rules/commands to sibling projects.
# Usage: .\ai_info\scripts\sync-rules.ps1

param(
    [switch]$NoPull  # Skip git pull
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$aiInfoDir = Split-Path -Parent $scriptDir
$parentDir = Split-Path -Parent $aiInfoDir

Write-Host "ai_info Sync" -ForegroundColor Cyan
Write-Host ""

# Pull latest
if (-not $NoPull) {
    Write-Host "Pulling latest ai_info..." -ForegroundColor Yellow
    Push-Location $aiInfoDir
    try {
        git pull origin main 2>&1 | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
    } catch {
        Write-Host "  Warning: Could not pull" -ForegroundColor DarkYellow
    }
    Pop-Location
    Write-Host ""
}

# Show recent changes
Write-Host "Recent ai_info changes:" -ForegroundColor Yellow
Push-Location $aiInfoDir
git log --oneline -5 2>&1 | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
Pop-Location
Write-Host ""

# Re-run setup with Force to overwrite
Write-Host "Syncing rules and commands..." -ForegroundColor Yellow
& (Join-Path $scriptDir "setup.ps1") -Force

Write-Host "Sync complete!" -ForegroundColor Cyan
