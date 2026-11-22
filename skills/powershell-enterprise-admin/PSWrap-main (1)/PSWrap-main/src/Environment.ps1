<#
.TITLE
    PSWrap Environment Setup

.SYNOPSIS
    Loads required .NET assemblies and verifies STA/WPF compatibility.

.DESCRIPTION
    Loads required .NET assemblies (WPF, Windows Forms, Drawing) for the GUI
    and checks the PowerShell version for STA compatibility.

.TAGS
    Environment,WPF,Assembly,Prerequisites,STA

.MINROLE
    Reader

.PERMISSIONS
    N/A — reads system information only

.AUTHOR
    admin

.VERSION
    1.0.0

.CHANGELOG
    1.0.0 - Initial release

.LASTUPDATE
    2026-06-17

.EXAMPLE
    . .\src\Environment.ps1
    Verifies WPF prerequisites and loads required assemblies.

.NOTES
    PowerShell 7+ does not support STA mode, which is required for WPF.
    The tool auto-restarts with powershell.exe -STA when needed.
#>

# Load WPF core assemblies required for the GUI infrastructure.
# PresentationFramework provides the WPF windowing/controls framework.
# PresentationCore provides low-level WPF primitives (media, animation).
# WindowsBase provides WPF base types (dependency objects, dispatcher).
try {
    Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase -ErrorAction Stop | Out-Null
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop | Out-Null
    Add-Type -AssemblyName System.Drawing -ErrorAction Stop | Out-Null
    $null = [System.Windows.Threading.Dispatcher]::CurrentDispatcher
} catch {
    Write-Error "Failed to load required WPF assemblies: $($_.Exception.Message)"
    exit 1
}

# WPF requires Single-Threaded Apartment (STA) mode. PowerShell 7+ does not
# support STA; this check warns the user but does not exit because Startup.ps1
# handles automatic restart with powershell.exe -STA when needed.
try {
    if ($PSVersionTable -and $PSVersionTable.PSVersion) {
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            Write-Warning "PowerShell 7+ does not support STA. Detected: $($PSVersionTable.PSVersion)"
        }
    }
} catch { Write-Warning "Could not check PowerShell version: $_" }
