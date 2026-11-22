#Requires -Version 5.1
<#
.TITLE
    PSWrap — PowerShell Script to EXE Compiler (GUI)

.SYNOPSIS
    Compiles PowerShell scripts (.ps1) into native Windows executables (.exe).

.DESCRIPTION
    A modern WPF-based GUI tool that compiles PowerShell scripts (.ps1) into
    native Windows executables (.exe) using in-process C# CodeDOM compilation
    with automatic csc.exe fallback on PowerShell Core 7.x.
    Features include dark/light theme, certificate signing, log viewer,
    companion file bundling, custom icon embedding, and async compilation.

.TAGS
    Compiler,PowerShell,GUI,WPF,EXE,CodeDOM

.MINROLE
    Contributor

.PERMISSIONS
    - File system: read .ps1 files, write .exe output
    - Admin: required for TrustRoot certificate option

.AUTHOR
    admin

.VERSION
    1.1.0

.CHANGELOG
    1.1.0 - Auto-read metadata from script, full documentation, bug fixes
    1.0.0 - Initial release

.LASTUPDATE
    2026-06-17

.EXAMPLE
    powershell.exe -STA -File "PSWrap.ps1"
    Launches PSWrap with full GUI and compiler functionality.

.NOTES
    Launch   : powershell.exe -STA -File "PSWrap.ps1"
    Requires : Windows PowerShell 5.1+, .NET Framework 4.7.2+, WPF
    Repo     : https://github.com/mabdulkadr/PSWrap
    Disclaimer: This script is provided AS IS without warranty of any kind. Use it at your own risk.
#>

$ErrorActionPreference = 'Continue'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$configDir  = Join-Path $scriptRoot 'config'
$srcDir     = Join-Path $scriptRoot 'src'
$script:EntryDir = $scriptRoot

# Hide the PowerShell console window via P/Invoke. The application is a WPF GUI
# tool; the console is unnecessary and would flash briefly on launch.
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
if ($consolePtr -ne [IntPtr]::Zero) {
    [Console.Window]::ShowWindow($consolePtr, 0) | Out-Null
}

# ── Dot-source all modules in dependency order ──
# Config must load first (defines paths used by all other modules).
# UI modules must load before EventHandlers (which wires control events).
# Startup.ps1 is the last to execute; it restores settings and shows the window.
. (Join-Path $configDir 'AppConstants.ps1')
. (Join-Path $srcDir    'Environment.ps1')
. (Join-Path $srcDir    'Logging.ps1')
. (Join-Path $srcDir    'WpfHelpers.ps1')
. (Join-Path $srcDir    'Settings.ps1')
. (Join-Path $srcDir    'UiLoader.ps1')
. (Join-Path $script:FeaturesDir 'Compiler.ps1')
. (Join-Path $script:FeaturesDir 'CertSign.ps1')
. (Join-Path $script:FeaturesDir 'LogViewer.ps1')
. (Join-Path $script:FeaturesDir 'AboutInfo.ps1')
. (Join-Path $script:FeaturesDir 'SettingsDialog.ps1')
. (Join-Path $srcDir 'EventHandlers.ps1')
. (Join-Path $srcDir 'Startup.ps1')
