<#
.TITLE
    PSWrap Application Constants

.SYNOPSIS
    Global constants for paths, version, and application metadata.

.DESCRIPTION
    Initializes all global path constants, application metadata, and directory
    references used throughout PSWrap. This file must be dot-sourced before any
    other module. All paths are derived from $PSScriptRoot (the config directory)
    using relative resolution to the project root.

.TAGS
    Constants,Configuration,Paths,Version

.MINROLE
    Reader

.PERMISSIONS
    N/A — reads local filesystem for path resolution only

.AUTHOR
    admin

.VERSION
    1.0.0

.CHANGELOG
    1.1.0 - Auto-read metadata, full documentation, bug fixes
    1.0.0 - Initial release

.LASTUPDATE
    2026-06-17

.EXAMPLE
    . .\config\AppConstants.ps1
    Write-Host "App version: $script:AppVersion"

.NOTES
    - $script:RootDir is resolved from config directory (..\)
    - Log files use daily-rolling naming: PSWrap_yyyyMMdd.log
    - Settings are persisted to %APPDATA%\PSWrap\settings.json
#>

# ── Application Identity ──
$script:ToolName    = 'PSWrap'
$script:AppVersion  = '1.1.0'
$script:AppAuthor   = 'admin'
$script:AppRepo     = 'https://github.com/mabdulkadr/PSWrap'

# ── Directory Structure ──
$script:RootDir     = Resolve-Path (Join-Path $PSScriptRoot '..')
$script:LogDir      = Join-Path $script:RootDir 'logs'
$script:XamlDir     = Join-Path $script:RootDir 'xaml'
$script:SrcDir      = Join-Path $script:RootDir 'src'
$script:FeaturesDir = Join-Path $script:SrcDir 'Features'
$script:ConfigDir   = $PSScriptRoot

# ── Logging ──
$script:LogFilePath = Join-Path $script:LogDir "${script:ToolName}_$(Get-Date -Format 'yyyyMMdd').log"

# ── User Settings (per-user, stored in AppData) ──
$script:AppDataDir   = Join-Path $env:APPDATA $script:ToolName
$script:SettingsPath = Join-Path $script:AppDataDir 'settings.json'
