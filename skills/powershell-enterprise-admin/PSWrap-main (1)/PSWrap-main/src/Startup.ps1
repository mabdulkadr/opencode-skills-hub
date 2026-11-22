<#
.TITLE
    PSWrap Application Startup Logic

.SYNOPSIS
    STA check, settings restore, log init, theme apply, window launch.

.DESCRIPTION
    Handles STA apartment state enforcement, user settings restoration,
    log file initialization, theme application, window icon loading,
    keyboard shortcut registration, and window display.

.TAGS
    Startup,STA,Initialization,Window,Launch

.MINROLE
    Reader

.PERMISSIONS
    N/A — local process management only

.AUTHOR
    admin

.VERSION
    1.0.0

.CHANGELOG
    1.0.0 - Initial release

.LASTUPDATE
    2026-06-17

.EXAMPLE
    . .\src\Startup.ps1
    Initializes and launches the PSWrap GUI window.

.NOTES
    Runs after all modules are loaded and UI elements are resolved.
    F5 key refreshes UI state. Window is shown as a modal dialog.
#>

# WPF requires STA (Single-Threaded Apartment) mode. PowerShell 7+ (pwsh.exe)
# does not support STA. If running with MTA, attempt auto-restart with -STA flag.
# For pwsh.exe, warn and continue (Startup.ps1 will handle gracefully).
if ([System.Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
    $processName = [System.IO.Path]::GetFileName((Get-Process -Id $pid).MainModule.FileName)
    if ($processName -ieq 'pwsh.exe') {
        Write-Warning 'PSWrap requires Windows PowerShell 5.1 with STA support. Run with powershell.exe -STA.'
    } else {
        Write-Warning 'This application requires STA apartment state. Restarting...'
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = (Get-Process -Id $pid).MainModule.FileName
        $psi.Arguments = "-STA -File `"$PSCommandPath`""
        $psi.UseShellExecute = $true
        try { $proc = [System.Diagnostics.Process]::Start($psi); if ($proc -and -not $proc.HasExited) { exit } }
        catch { Write-Warning "Auto-restart failed: $($_.Exception.Message). Continuing in current process." }
    }
}

# ── Restore saved user preferences from %APPDATA%\PSWrap\settings.json ──
# Theme, last-used file paths, build settings, and toast preference are restored.
# The BuildSettings block uses a dynamic loop over dlgState.Keys so new keys
# added in future versions are automatically supported.
try {
    $script:AppSettings = @{ ToastEnabled = $true }
    $settings = Load-UserSettings
    if ($settings) {
        $script:AppSettings = $settings
        if ($settings.Theme) { $script:IsDarkMode = ($settings.Theme -eq 'Dark') }
        if ($null -ne $settings.ToastEnabled) {
            if ($script:chkToastEnabled) { $script:chkToastEnabled.IsChecked = $settings.ToastEnabled }
        }
        if ($settings.BuildSettings) {
            foreach ($key in @($script:dlgState.Keys)) {
                if ($key -in 'Ver','Prod','Desc','Copy','Comp','Trade') { continue }
                $val = $settings.BuildSettings.$key
                if ($null -ne $val) { $script:dlgState.$key = $val }
            }
            $s = $script:dlgState
            if ($script:chkOptNoConsole) { $script:chkOptNoConsole.IsChecked = $s.NoCon }
            if ($script:chkOptNoOutput) { $script:chkOptNoOutput.IsChecked = $s.SOut }
            if ($script:chkOptNoError) { $script:chkOptNoError.IsChecked = $s.SErr }
            if ($script:chkOptRequireAdmin) { $script:chkOptRequireAdmin.IsChecked = $s.Adm }
            if ($script:chkOptConfigFile) { $script:chkOptConfigFile.IsChecked = $s.Cfg }
            if ($script:chkOptSaveIcon) { $script:chkOptSaveIcon.IsChecked = $s.CopyIcon }
            if ($script:radOptSTA) { $script:radOptSTA.IsChecked = $s.STA; $script:radOptMTA.IsChecked = -not $s.STA }
            if ($script:cboOptPlatform) { $script:cboOptPlatform.SelectedIndex = $s.Plat }
        }
    }
} catch { Write-Warning "Settings restore failed: $_" }

Initialize-LogFile
if ($script:FooterVersion) { $script:FooterVersion.Text = "Version $script:AppVersion" }

# ── Window.Loaded: Theme application, icon initialization, state refresh ──
# Runs once when the WPF Window is fully rendered.
$script:Window.Add_Loaded({
    Set-Theme -Window $script:Window -IsDark $script:IsDarkMode

    # Style CertSign nav button in inactive state (transparent background)
    if ($script:NavBtnCertSign) {
        $script:NavBtnCertSign.Background = [System.Windows.Media.Brushes]::Transparent
        $script:NavBtnCertSign.Foreground = $script:Window.TryFindResource('TextSecondaryBrush')
        $script:NavBtnCertSign.FontWeight = [System.Windows.FontWeights]::SemiBold
    }

    # Set the correct theme toggle icon (moon for dark, sun for light)
    if ($script:IsDarkMode) {
        $script:ThemeIcon.Data = [System.Windows.Media.Geometry]::Parse($MoonIconData)
        $script:ThemeIcon.Fill = New-Brush '#CBD5E1'
        $script:ThemeToggleBtn.ToolTip = 'Switch to Light theme'
    }

    # Load application icon from images/app-icon.png; convert to WPF BitmapSource
    $iconFile = Join-Path $script:RootDir 'images\app-icon.png'
    if (Test-Path $iconFile) {
        try {
            $img = [System.Drawing.Image]::FromFile($iconFile)
            $hIcon = $img.GetHicon()
            $iconSrc = [System.Windows.Interop.Imaging]::CreateBitmapSourceFromHIcon($hIcon, [System.Windows.Int32Rect]::Empty, [System.Windows.Media.Imaging.BitmapSizeOptions]::FromEmptyOptions())
            $script:Window.Icon = $iconSrc; $img.Dispose()
        } catch { Add-LogLine "Could not load application icon from file: $_" 'WARNING' }
    }

    # Initial UI state refresh: populate bundle list, file sizes, etc.
    Update-UIState

    # ProgressBar is a visual-only indicator; disable hit testing so it
    # doesn't intercept mouse clicks on nearby buttons (e.g. btnSettings).
    if ($script:ProgressBar) { $script:ProgressBar.IsHitTestVisible = $false }
}) | Out-Null

# F5 hotkey: manually refresh UI state (bundle list, file sizes, path indicators)
$script:Window.Add_KeyDown({
    if ($_.Key -eq 'F5') { $_.Handled = $true; Update-UIState; Add-LogLine -Message 'Interface refreshed via F5' -Level 'INFO' }
}) | Out-Null

# Show the main window as a modal dialog (blocks until window closes)
$null = $script:Window.ShowDialog()
