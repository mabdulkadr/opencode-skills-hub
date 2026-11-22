#Requires -Version 5.1
<#
.TITLE
    PSWrap UI Loader

.SYNOPSIS
    Decompresses embedded XAML and resolves all named WPF controls.

.DESCRIPTION
    Loads the application UI by decompressing the Base64-encoded, GZip-compressed
    XAML embedded in $script:EmbeddedXaml. Falls back to an external XAML file
    if the embedded data is unavailable. Uses XamlReader to parse the XAML into
    a WPF Window object, then resolves every named control via FindName() into
    $script:-scoped variables for use by other modules.

.TAGS
    UI,XAML,WPF,Loader,Embedded

.MINROLE
    Reader

.PERMISSIONS
    N/A - reads embedded data and local XAML file only

.AUTHOR
    admin

.VERSION
    1.0.0

.CHANGELOG
    1.0.0 - Initial release

.LASTUPDATE
    2026-06-17

.EXAMPLE
    . .\src\UiLoader.ps1
    # $script:Window now holds the parsed WPF Window
    # $script:btnCompile, $script:txtSrcScript, etc. are resolved

.NOTES
    - XamlReader::Parse is tried first; on failure, XmlReader with
      DtdProcessing::Ignore is used as a fallback for compatibility.
    - Embedded XAML is preferred over the external xaml/PSWrap.xaml file
      to ensure the application always has its complete control set.
    - Invisible/control characters (BOM, zero-width spaces, etc.) are
      stripped before parsing.
#>

$script:EmbeddedXaml = "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"

function Get-EmbeddedXaml {
    <#
    .SYNOPSIS
        Decompresses the embedded Base64/GZip XAML into a plain XML string.
    .DESCRIPTION
        Decodes the Base64-encoded string in $script:EmbeddedXaml, decompresses
        it with GZip, and returns the raw XAML markup. All streams are properly
        disposed via try/finally blocks.
    .OUTPUTS
        String. The decompressed XAML markup.
    #>
    $bytes = [System.Convert]::FromBase64String($script:EmbeddedXaml)
    $ms = New-Object System.IO.MemoryStream($bytes, 0, $bytes.Length)
    try {
        $gz = New-Object System.IO.Compression.GzipStream($ms, [System.IO.Compression.CompressionMode]::Decompress)
        try {
            $sr = New-Object System.IO.StreamReader($gz, [System.Text.Encoding]::UTF8)
            try { return $sr.ReadToEnd() } finally { $sr.Dispose() }
        } finally { $gz.Dispose() }
    } finally { $ms.Dispose() }
}

function Get-XamlWindow {
    <#
    .SYNOPSIS
        Parses XAML markup into a WPF Window object.
    .DESCRIPTION
        Loads XAML first from the embedded GZip blob, falling back to an external
        XAML file if the embedded data is unavailable. Strips invisible/control
        characters (BOM, zero-width spaces, Unicode bidi markers) before parsing.
        Uses a two-pass approach: XamlReader::Parse first, then XmlReader with
        DtdProcessing::Ignore as a compatibility fallback.
    .PARAMETER XamlPath
        Path to an external .xaml file, used as fallback if embedded XAML fails.
    .OUTPUTS
        System.Windows.Window. The parsed WPF Window instance.
    #>
    [CmdletBinding()]
    param([string]$XamlPath)
    $xaml = $null
    try { $xaml = Get-EmbeddedXaml } catch { }

    if (-not $xaml -and $XamlPath -and (Test-Path -LiteralPath $XamlPath -PathType Leaf)) {
        $xaml = Get-Content -LiteralPath $XamlPath -Raw -Encoding UTF8
    }
    if (-not $xaml) { throw "Failed to load XAML (no embedded nor file)." }
    $clean = $xaml -replace '[\uFEFF\u200B\u200C\u200D\u200E\u200F\u202A-\u202E]', ''
    $clean = $clean.TrimStart()
    if ($clean.Length -eq 0 -or $clean[0] -ne '<') { throw "XAML must start with '<'." }
    try { return [System.Windows.Markup.XamlReader]::Parse($clean) }
    catch {
        $settings = New-Object System.Xml.XmlReaderSettings
        $settings.DtdProcessing = [System.Xml.DtdProcessing]::Ignore
        $sr = New-Object System.IO.StringReader($clean)
        $xr = [System.Xml.XmlReader]::Create($sr, $settings)
        return [System.Windows.Markup.XamlReader]::Load($xr)
    }
}

$script:Window = Get-XamlWindow -XamlPath (Join-Path $script:XamlDir 'PSWrap.xaml')

# ── Navigation & Layout ──
$script:PageDashboard     = $script:Window.FindName('PageDashboard')
$script:PageCertSign      = $script:Window.FindName('PageCertSign')
$script:PageTitle         = $script:Window.FindName('PageTitle')
$script:PageSubtitle      = $script:Window.FindName('PageSubtitle')
$script:NavBtnDashboard   = $script:Window.FindName('NavBtnDashboard')
$script:NavBtnCertSign    = $script:Window.FindName('NavBtnCertSign')

# ── Input Fields ──
$script:txtProjectFolder  = $script:Window.FindName('txtProjectFolder')
$script:btnProjectFolder  = $script:Window.FindName('btnProjectFolder')
$script:txtSrcScript      = $script:Window.FindName('txtSrcScript')
$script:btnSrcScript      = $script:Window.FindName('btnSrcScript')
$script:txtOutPath        = $script:Window.FindName('txtOutPath')
$script:btnOutPath        = $script:Window.FindName('btnOutPath')
$script:txtIconPath       = $script:Window.FindName('txtIconPath')
$script:btnIconPath       = $script:Window.FindName('btnIconPath')
$script:lblBundleCount    = $script:Window.FindName('lblBundleCount')
$script:lblPkgName        = $script:Window.FindName('lblPkgName')
$script:lblSrcSize        = $script:Window.FindName('lblSrcSize')
$script:dgvBundleFiles    = $script:Window.FindName('dgvBundleFiles')
$script:chkSelectAll      = $script:Window.FindName('chkSelectAll')

# ── Action Buttons ──
$script:btnCompile        = $script:Window.FindName('btnCompile')
$script:btnSettings       = $script:Window.FindName('btnSettings')
$script:btnOpenOut        = $script:Window.FindName('btnOpenOut')
$script:btnClear          = $script:Window.FindName('btnClear')
$script:btnCopyConsole    = $script:Window.FindName('btnCopyConsole')
$script:btnClearConsole   = $script:Window.FindName('btnClearConsole')

# ── Console & Status Bar ──
$script:txtLog            = $script:Window.FindName('txtLog')
$script:ProgressBar       = $script:Window.FindName('ProgressBar')
$script:StatusLabel       = $script:Window.FindName('StatusLabel')
$script:StatusBarText     = $script:Window.FindName('StatusBarText')
$script:StatusTime        = $script:Window.FindName('StatusTime')
$script:StatusDot         = $script:Window.FindName('StatusDot')

# ── Header & Footer ──
$script:ThemeToggleBtn    = $script:Window.FindName('ThemeToggleBtn')
$script:ThemeIcon         = $script:Window.FindName('ThemeIcon')
$script:ConnectionDot     = $script:Window.FindName('ConnectionDot')
$script:ToastContainer    = $script:Window.FindName('ToastContainer')
$script:AboutBtn          = $script:Window.FindName('AboutBtn')
$script:LogsBtn           = $script:Window.FindName('LogsBtn')
$script:FooterVersion     = $script:Window.FindName('FooterVersion')
$script:FooterLink        = $script:Window.FindName('FooterLink')

# ── Advanced Options (Tab 2) Metadata ──
$script:txtOptVersion     = $script:Window.FindName('txtOptVersion')
$script:txtOptProduct     = $script:Window.FindName('txtOptProduct')
$script:txtOptDesc        = $script:Window.FindName('txtOptDesc')
$script:txtOptCopyright   = $script:Window.FindName('txtOptCopyright')
$script:txtOptCompany     = $script:Window.FindName('txtOptCompany')
$script:txtOptTrademark   = $script:Window.FindName('txtOptTrademark')

# ── Advanced Options: Compilation Behaviour ──
$script:chkOptGrid        = $script:Window.FindName('chkOptGrid')
$script:chkOptNoConsole   = $script:Window.FindName('chkOptNoConsole')
$script:chkOptConHost     = $script:Window.FindName('chkOptConHost')
$script:chkOptUnicodeEncoding = $script:Window.FindName('chkOptUnicodeEncoding')
$script:chkOptCredentialGUI = $script:Window.FindName('chkOptCredentialGUI')
$script:chkOptNoOutput    = $script:Window.FindName('chkOptNoOutput')
$script:chkOptNoError     = $script:Window.FindName('chkOptNoError')
$script:chkOptRequireAdmin = $script:Window.FindName('chkOptRequireAdmin')
$script:chkOptConfigFile  = $script:Window.FindName('chkOptConfigFile')
$script:chkOptNoVisualStyles = $script:Window.FindName('chkOptNoVisualStyles')
$script:chkOptExitOnCancel = $script:Window.FindName('chkOptExitOnCancel')
$script:chkOptDPIAware    = $script:Window.FindName('chkOptDPIAware')
$script:chkOptPrepareDebug = $script:Window.FindName('chkOptPrepareDebug')
$script:chkOptSupportOS   = $script:Window.FindName('chkOptSupportOS')
$script:chkOptVirtualize  = $script:Window.FindName('chkOptVirtualize')
$script:chkOptLongPaths   = $script:Window.FindName('chkOptLongPaths')
$script:chkOptSaveIcon    = $script:Window.FindName('chkOptSaveIcon')

# ── Advanced Options: Platform & Threading ──
$script:radOptSTA         = $script:Window.FindName('radOptSTA')
$script:radOptMTA         = $script:Window.FindName('radOptMTA')
$script:cboOptPlatform    = $script:Window.FindName('cboOptPlatform')
$script:txtOptLCID        = $script:Window.FindName('txtOptLCID')

# ── Help Buttons ──
$script:btnHelpMetadata   = $script:Window.FindName('btnHelpMetadata')
$script:btnHelpApt        = $script:Window.FindName('btnHelpApt')
$script:btnHelpPlatform   = $script:Window.FindName('btnHelpPlatform')
$script:btnHelpLCID       = $script:Window.FindName('btnHelpLCID')

# ── Toast Settings ──
$script:chkToastEnabled   = $script:Window.FindName('chkToastEnabled')
$script:btnTestToast      = $script:Window.FindName('btnTestToast')

# ── CertSign Page ──
$script:txtCertCaPath     = $script:Window.FindName('txtCertCaPath')
$script:txtCertPfxPath    = $script:Window.FindName('txtCertPfxPath')
$script:btnGenCerts       = $script:Window.FindName('btnGenCerts')
$script:txtSignTarget     = $script:Window.FindName('txtSignTarget')
$script:btnSignBrowse     = $script:Window.FindName('btnSignBrowse')
$script:chkSignTrust      = $script:Window.FindName('chkSignTrust')
$script:chkSignTimestamp  = $script:Window.FindName('chkSignTimestamp')
$script:txtSignTimestamp  = $script:Window.FindName('txtSignTimestamp')
$script:txtCertStatus     = $script:Window.FindName('txtCertStatus')
$script:btnSignNow        = $script:Window.FindName('btnSignNow')
