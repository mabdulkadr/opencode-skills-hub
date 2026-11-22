# OpenCode Skills Hub - Installer (Windows PowerShell)
# Usage: .\install.ps1 [-All] [-Skills] [-Agents] [-Commands] [-Rules]
param(
    [switch]$All,
    [switch]$Skills,
    [switch]$Agents,
    [switch]$Commands,
    [switch]$Rules
)

$cfg = "$env:USERPROFILE\.config\opencode"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

if ($All -or (-not ($Skills -or $Agents -or $Commands -or $Rules))) {
    $Skills = $true; $Agents = $true; $Commands = $true; $Rules = $true
}

function Merge-Copy {
    param([string]$Src, [string]$Dst)
    if (-not (Test-Path $Dst)) { New-Item -ItemType Directory -Force -Path $Dst | Out-Null }
    Get-ChildItem -Path $Src -Force | ForEach-Object {
        $target = Join-Path $Dst $_.Name
        if ($_.PSIsContainer) {
            Merge-Copy -Src $_.FullName -Dst $target
        } else {
            Copy-Item -Path $_.FullName -Destination $target -Force
        }
    }
}

New-Item -ItemType Directory -Force -Path "$cfg\skills","$cfg\agents","$cfg\commands","$cfg\rules" | Out-Null

try {
    if ($Skills)   { Merge-Copy "$root\skills"   "$cfg\skills";   Write-Host "Installed skills"   -ForegroundColor Green }
    if ($Agents)   { Merge-Copy "$root\agents"   "$cfg\agents";   Write-Host "Installed agents"   -ForegroundColor Green }
    if ($Commands) { Merge-Copy "$root\commands" "$cfg\commands"; Write-Host "Installed commands" -ForegroundColor Green }
    if ($Rules)    { Merge-Copy "$root\rules"    "$cfg\rules";    Write-Host "Installed rules"    -ForegroundColor Green }
    Write-Host "Done. Restart OpenCode to load." -ForegroundColor Cyan
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}
