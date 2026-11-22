<#
.TITLE
    PSWrap Event Handlers

.SYNOPSIS
    Wires all UI event handlers: button clicks, drag-drop, timers, window close.

.DESCRIPTION
    The central event-wiring module for the PSWrap GUI. Handles all user
    interactions including:
    - Theme toggle (dark/light mode)
    - Help popup display
    - Navigation between Script and CertSign pages
    - File/folder browsing dialogs
    - Drag-and-drop script loading
    - Compilation trigger with full option gathering
    - Async compilation polling and completion handling
    - Window close with settings persistence and resource cleanup
    - Help button wiring for advanced options
    - Bundle file DataGrid selection

.TAGS
    Events,UI,WPF,Click,Timers,Close

.MINROLE
    Reader

.PERMISSIONS
    N/A — UI event handlers only

.AUTHOR
    admin

.VERSION
    1.0.0

.CHANGELOG
    1.0.0 - Initial release

.LASTUPDATE
    2026-06-17

.EXAMPLE
    . .\src\EventHandlers.ps1
    # All UI controls are now wired with event handlers.

.NOTES
    - All event handlers are wrapped in control-existence guards (e.g., if ($script:btnCompile))
      because the controls may not exist if the XAML failed to load a specific version.
    - The async compilation polling timer runs at 350ms intervals during compilation.
    - Theme toggle uses $MoonIconData/$SunIconData SVG path data for the toggle icon.
#>

$script:IsDarkMode = $false

if ($script:ThemeToggleBtn) {
    $script:ThemeToggleBtn.Add_Click({
        Invoke-SafeUIAction -Action {
            $script:IsDarkMode = -not $script:IsDarkMode
            Set-Theme -Window $script:Window -IsDark $script:IsDarkMode
            if ($script:IsDarkMode) {
                $script:ThemeIcon.Data = [System.Windows.Media.Geometry]::Parse($MoonIconData)
                $script:ThemeIcon.Fill = (New-Object System.Windows.Media.BrushConverter).ConvertFromString('#CBD5E1')
                $script:ThemeToggleBtn.ToolTip = 'Switch to Light theme'
                Add-LogLine -Message "Dark theme activated" -Level 'INFO'
            } else {
                $script:ThemeIcon.Data = [System.Windows.Media.Geometry]::Parse($SunIconData)
                $script:ThemeIcon.Fill = (New-Object System.Windows.Media.BrushConverter).ConvertFromString('#EAB308')
                $script:ThemeToggleBtn.ToolTip = 'Switch to Dark theme'
                Add-LogLine -Message "Light theme activated" -Level 'INFO'
            }
        } -ActionName 'Theme Toggle'
    }) | Out-Null
}

function Show-HelpPopup {
    <#
    .SYNOPSIS
        Displays a modal help popup dialog with formatted help text.
    .DESCRIPTION
        Dynamically builds a XAML popup window from inline markup, using
        theme-appropriate colors. The help text is displayed in a scrollable
        TextBlock. The dialog is modal (ShowDialog) relative to the main window.
        Falls back to MessageBox on XAML parse failure.
    .PARAMETER HelpText
        The help content to display. Multi-line text is rendered with wrapping.
    .PARAMETER Title
        Optional dialog title. Displayed in the title bar and header.
    .EXAMPLE
        Show-HelpPopup -Title 'Version Info' -HelpText 'Enter the assembly version (e.g., 1.0.0.0).'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$HelpText,
        [string]$Title = 'Option Info'
    )
    if (-not $script:Window) { return }
    $isDark = $script:IsDarkMode
    $bgColor       = if ($isDark) { '#334155' } else { '#FFFFFF' }
    $borderColor   = if ($isDark) { '#475569' } else { '#E2E8F0' }
    $textPrimary   = if ($isDark) { '#FFFFFF' } else { '#0F172A' }
    $textBody      = if ($isDark) { '#E2E8F0' } else { '#334155' }
    $separatorColor = if ($isDark) { '#475569' } else { '#E2E8F0' }
    $closeBtnColor  = if ($isDark) { '#94A3B8' } else { '#94A3B8' }
    $closeBtnHover  = if ($isDark) { '#475569' } else { '#F1F5F9' }
    $titleEsc = $Title -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;'
    $textEsc  = $HelpText -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;'
    $xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="$titleEsc" Width="380" SizeToContent="Height"
    WindowStartupLocation="CenterOwner"
    WindowStyle="None" AllowsTransparency="True" Background="Transparent"
    ShowInTaskbar="False" ResizeMode="NoResize" Topmost="True">
    <Border CornerRadius="12" Background="$bgColor"
        BorderBrush="$borderColor" BorderThickness="1" Padding="24">
        <Border.Effect>
            <DropShadowEffect BlurRadius="32" ShadowDepth="12" Color="#0F172A" Opacity="0.18" Direction="270"/>
        </Border.Effect>
        <StackPanel>
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <TextBlock Grid.Column="0" Text="$titleEsc" FontSize="16" FontWeight="Bold"
                    Foreground="$textPrimary" VerticalAlignment="Center" TextWrapping="Wrap"/>
                <Button x:Name="btnClose" Grid.Column="1" Width="28" Height="28"
                    Cursor="Hand" Background="Transparent" BorderThickness="0"
                    HorizontalAlignment="Right" VerticalAlignment="Top" Margin="12,0,0,0">
                    <Button.Template>
                        <ControlTemplate TargetType="Button">
                            <Border x:Name="bd" Background="{TemplateBinding Background}"
                                CornerRadius="4" Width="28" Height="28">
                                <TextBlock Text="X" FontSize="13" FontWeight="Bold"
                                    Foreground="$closeBtnColor"
                                    HorizontalAlignment="Center" VerticalAlignment="Center"/>
                            </Border>
                            <ControlTemplate.Triggers>
                                <Trigger Property="IsMouseOver" Value="True">
                                    <Setter TargetName="bd" Property="Background" Value="$closeBtnHover"/>
                                </Trigger>
                            </ControlTemplate.Triggers>
                        </ControlTemplate>
                    </Button.Template>
                </Button>
            </Grid>
            <Border Height="1" Background="$separatorColor" Margin="0,12,0,16"/>
            <TextBlock Text="$textEsc" TextWrapping="Wrap" FontSize="13.5"
                Foreground="$textBody" LineHeight="22" LineStackingStrategy="BlockLineHeight"/>
        </StackPanel>
    </Border>
</Window>
"@
    try {
        $xml = [xml]$xaml
        $reader = New-Object System.Xml.XmlNodeReader($xml)
        $popup = [System.Windows.Markup.XamlReader]::Load($reader)
        $reader.Close()
        $btnClose = $popup.FindName('btnClose')
        if ($btnClose) { $btnClose.Add_Click({ $popup.Close() }) | Out-Null }
        $popup.Owner = $script:Window
        [void]$popup.ShowDialog()
    } catch {
        Add-LogLine -Message "Failed to show help: $($_.Exception.Message)" -Level 'ERROR'
        [System.Windows.MessageBox]::Show($script:Window, $HelpText, $Title, 'OK', 'Information')
    }
}

if ($script:AboutBtn) {
    $script:AboutBtn.Add_Click({
        Invoke-SafeUIAction -Action { Show-AboutDialog } -ActionName 'About'
    }) | Out-Null
}

if ($script:LogsBtn) {
    $script:LogsBtn.Add_Click({
        Invoke-SafeUIAction -Action { Show-LogViewer } -ActionName 'View Logs'
    }) | Out-Null
}

if ($script:FooterLink) {
    $script:FooterLink.Add_RequestNavigate({
        param($s, $e)
        Start-Process $e.Uri.AbsoluteUri
        $e.Handled = $true
    }) | Out-Null
}

if ($script:btnSrcScript) {
    $script:btnSrcScript.Add_Click({
        if (-not (Guard-Operation 'Browse Source Script')) { return }
        $dlg = New-Object System.Windows.Forms.OpenFileDialog
        $dlg.Filter = 'PowerShell Scripts (*.ps1)|*.ps1|All Files (*.*)|*.*'
        $dlg.Title = 'Select PowerShell Source Script'
        if ($script:txtProjectFolder.Text -and (Test-Path $script:txtProjectFolder.Text)) {
            $dlg.InitialDirectory = $script:txtProjectFolder.Text
        }
        if ($dlg.ShowDialog() -eq 'OK') {
            $script:txtSrcScript.Text = $dlg.FileName
            Add-LogLine -Message "Source script: $($dlg.FileName)" -Level 'INFO'
            Apply-ScriptMetadata -FilePath $dlg.FileName
            Update-UIState
        }
        Release-Operation
    }) | Out-Null
}

if ($script:btnOutPath) {
    $script:btnOutPath.Add_Click({
        if (-not (Guard-Operation 'Browse Output Path')) { return }
        $dlg = New-Object System.Windows.Forms.SaveFileDialog
        $dlg.Filter = 'Executable Files (*.exe)|*.exe'
        $dlg.Title = 'Save Compiled Executable As'
        $dlg.DefaultExt = 'exe'
        if ($script:txtOutPath.Text) {
            $dlg.InitialDirectory = Split-Path $script:txtOutPath.Text -Parent
            $dlg.FileName = Split-Path $script:txtOutPath.Text -Leaf
        }
        if ($dlg.ShowDialog() -eq 'OK') {
            $script:txtOutPath.Text = $dlg.FileName
            Add-LogLine -Message "Output path: $($dlg.FileName)" -Level 'INFO'
        }
        Release-Operation
    }) | Out-Null
}

if ($script:btnIconPath) {
    $script:btnIconPath.Add_Click({
        if (-not (Guard-Operation 'Browse Icon')) { return }
        $dlg = New-Object System.Windows.Forms.OpenFileDialog
        $dlg.Filter = 'Icon & Image Files (*.ico;*.png;*.jpg;*.bmp;*.gif)|*.ico;*.png;*.jpg;*.jpeg;*.bmp;*.gif|All Files (*.*)|*.*'
        $dlg.Title = 'Select Custom Icon or Image'
        if ($script:txtProjectFolder.Text -and (Test-Path $script:txtProjectFolder.Text)) {
            $dlg.InitialDirectory = $script:txtProjectFolder.Text
        }
        if ($dlg.ShowDialog() -eq 'OK') {
            $selectedFile = $dlg.FileName
            $ext = [System.IO.Path]::GetExtension($selectedFile).ToLower()
            if ($ext -eq '.ico') {
                $script:txtIconPath.Text = $selectedFile
                Add-LogLine -Message "Custom icon selected: $selectedFile" -Level 'INFO'
            } elseif ($ext -in '.png','.jpg','.jpeg','.bmp','.gif') {
                Add-LogLine -Message "Converting image to ICO format..." -Level 'INFO'
                $tmpIco = [System.IO.Path]::GetTempFileName()
                Remove-Item $tmpIco -Force -ErrorAction SilentlyContinue
                $tmpIco = [System.IO.Path]::ChangeExtension($tmpIco, '.ico')
                $result = ConvertTo-Icon -ImagePath $selectedFile -OutputPath $tmpIco
                if ($result) {
                    $script:txtIconPath.Text = $result
                    [void]$script:tempIconFiles.Add($result)
                    Add-LogLine -Message "Converted to .ico: $(Split-Path $result -Leaf)" -Level 'SUCCESS'
                }
            }
        }
        Release-Operation
    }) | Out-Null
}

if ($script:btnProjectFolder) {
    $script:btnProjectFolder.Add_Click({
        if (-not (Guard-Operation 'Browse Project Folder')) { return }
        $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
        $dlg.Description = 'Select project folder'
        $dlg.ShowNewFolderButton = $false
        if ($dlg.ShowDialog() -eq 'OK') {
            $script:txtProjectFolder.Text = $dlg.SelectedPath
            Add-LogLine -Message "Project folder: $($dlg.SelectedPath)" -Level 'INFO'
            $pdir = $dlg.SelectedPath
            $ps1f = Get-ChildItem -LiteralPath $pdir -Filter '*.ps1' -File -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($ps1f) {
                $script:txtSrcScript.Text = $ps1f.FullName
                $script:txtOutPath.Text = Join-Path $pdir ([System.IO.Path]::GetFileNameWithoutExtension($ps1f.Name) + '.exe')
                Add-LogLine -Message "Auto-detected script: $($ps1f.Name)" -Level 'INFO'
                Apply-ScriptMetadata -FilePath $ps1f.FullName
                Update-UIState
            }
            $icof = Get-ChildItem -LiteralPath $pdir -Filter '*.ico' -File -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($icof) {
                $script:txtIconPath.Text = $icof.FullName
                Add-LogLine -Message "Auto-detected icon: $($icof.Name)" -Level 'INFO'
            }
        }
        Release-Operation
    }) | Out-Null
}
function Set-ActiveNavTab {
    <#
    .SYNOPSIS
        Activates a navigation tab and updates visibility of page panels.
    .DESCRIPTION
        Highlights the selected navigation button with accent colors and shows
        the corresponding page. Handles both 'Script' (Dashboard) and 'CertSign'
        pages. Uses DynamicResource brushes for theme-aware styling.
    .PARAMETER TabName
        Tab identifier. 'Script' or 'CertSign' — toggles PageDashboard and
        PageCertSign visibility.
    .EXAMPLE
        Set-ActiveNavTab -TabName 'Script'
    #>
    [CmdletBinding()]
    param([string]$TabName)
    $activeBg = $script:Window.TryFindResource('AccentTintBrush')
    $activeFg = $script:Window.TryFindResource('AccentHoverBrush')
    $inactiveFg = $script:Window.TryFindResource('TextSecondaryBrush')
    $inactiveBg = [System.Windows.Media.Brushes]::Transparent

    if ($script:NavBtnDashboard) {
        if ($TabName -eq 'Script') {
            $script:NavBtnDashboard.Background = $activeBg
            $script:NavBtnDashboard.Foreground = $activeFg
            $script:NavBtnDashboard.FontWeight = [System.Windows.FontWeights]::Bold
        } else {
            $script:NavBtnDashboard.Background = $inactiveBg
            $script:NavBtnDashboard.Foreground = $inactiveFg
            $script:NavBtnDashboard.FontWeight = [System.Windows.FontWeights]::SemiBold
        }
    }
    if ($script:NavBtnCertSign) {
        if ($TabName -eq 'CertSign') {
            $script:NavBtnCertSign.Background = $activeBg
            $script:NavBtnCertSign.Foreground = $activeFg
            $script:NavBtnCertSign.FontWeight = [System.Windows.FontWeights]::Bold
        } else {
            $script:NavBtnCertSign.Background = $inactiveBg
            $script:NavBtnCertSign.Foreground = $inactiveFg
            $script:NavBtnCertSign.FontWeight = [System.Windows.FontWeights]::SemiBold
        }
    }
    if ($script:PageDashboard) { $script:PageDashboard.Visibility = if ($TabName -eq 'Script') { 'Visible' } else { 'Collapsed' } }
    if ($script:PageCertSign)  { $script:PageCertSign.Visibility  = if ($TabName -eq 'CertSign') { 'Visible' } else { 'Collapsed' } }
}

if ($script:NavBtnDashboard) {
    $script:NavBtnDashboard.Add_Click({
        $script:PageTitle.Text = 'Script to EXE Compiler'
        $script:PageSubtitle.Text = 'Compile PowerShell scripts into native Windows executables.'
        Set-ActiveNavTab -TabName 'Script'
    }) | Out-Null
}
if ($script:NavBtnCertSign) {
    $script:NavBtnCertSign.Add_Click({
        $script:PageTitle.Text = 'Certificate Signing'
        $script:PageSubtitle.Text = 'Generate certificates and sign executables with Authenticode.'
        Set-ActiveNavTab -TabName 'CertSign'
    }) | Out-Null
}

if ($script:btnCompile) {
    $script:btnCompile.Add_Click({
        if (-not (Guard-Operation 'Compile to EXE')) { return }
        $sourcePath = $script:txtSrcScript.Text.Trim()
        $outputPath = $script:txtOutPath.Text.Trim()
        $iconPath   = $script:txtIconPath.Text.Trim()
        $bundlePath = $script:txtProjectFolder.Text.Trim()

        if (-not $sourcePath) {
            Add-LogLine -Message 'Select a PowerShell script (.ps1) to compile' -Level 'ERROR'
            Show-ToastMessage -Message 'Select a source script to compile' -Type Error
            return
        }
        if (-not (Test-Path $sourcePath)) {
            Add-LogLine -Message "Source file not found: $sourcePath" -Level 'ERROR'
            Show-ToastMessage -Message 'Source file not found' -Type Error
            return
        }
        if (-not $outputPath) {
            Add-LogLine -Message 'Specify the output EXE file path' -Level 'ERROR'
            Show-ToastMessage -Message 'Specify the output EXE file path' -Type Error
            return
        }

        # Ensure output path has .exe extension (case-insensitive check)
        if ($outputPath -notlike '*.exe') { $outputPath += '.exe'; $script:txtOutPath.Text = $outputPath }

        # Create output directory if it doesn't exist
        $outputDir = Split-Path $outputPath -Parent
        if ($outputDir -and -not (Test-Path $outputDir)) {
            $null = New-Item -ItemType Directory -Path $outputDir -Force
        }

        # Check if existing output file is locked (in use by another process)
        if (Test-Path $outputPath) {
            try {
                $fs = [System.IO.File]::Open($outputPath, 'Open', 'Read', 'None')
                $fs.Close(); $fs.Dispose()
            } catch {
                Add-LogLine -Message 'Output file is locked' -Level 'ERROR'
                Show-ToastMessage -Message 'Output file is locked' -Type Error
                return
            }
        }
        if ($iconPath -and -not (Test-Path $iconPath)) {
            Add-LogLine -Message "Icon not found: $iconPath" -Level 'ERROR'
            Show-ToastMessage -Message 'Icon file not found' -Type Error
            return
        }
        if ($bundlePath -and -not (Test-Path $bundlePath)) {
            Add-LogLine -Message "Bundle folder not found: $bundlePath" -Level 'ERROR'
            Show-ToastMessage -Message 'Bundle folder not found' -Type Error
            return
        }

        Set-UIState -IsProcessing $true
        Add-LogLine -Message 'Compilation process initiated...' -Level 'INFO'
        Add-LogLine -Message "Source: $sourcePath" -Level 'INFO'
        Add-LogLine -Message "Output: $outputPath" -Level 'INFO'
        if ($iconPath) { Add-LogLine -Message "Icon: $iconPath" -Level 'INFO' }
        if ($bundlePath) { Add-LogLine -Message "Bundle: $bundlePath" -Level 'INFO' }

        $selectedFiles = @($script:bundleFiles | Where-Object { $_.IsSelected } | ForEach-Object { $_.FullPath })
        $optVersion = $script:dlgState.Ver
        $optProduct = $script:dlgState.Prod
        $optDesc = $script:dlgState.Desc
        $optCopyright = $script:dlgState.Copy
        $optCompany = $script:dlgState.Comp
        $optTrademark = $script:dlgState.Trade
        $optNoConsole = if ($script:chkOptNoConsole) { [bool]$script:chkOptNoConsole.IsChecked } else { $true }
        $optConHost = if ($script:chkOptConHost) { [bool]$script:chkOptConHost.IsChecked } else { $false }
        $optUnicodeEncoding = if ($script:chkOptUnicodeEncoding) { [bool]$script:chkOptUnicodeEncoding.IsChecked } else { $false }
        $optCredentialGUI = if ($script:chkOptCredentialGUI) { [bool]$script:chkOptCredentialGUI.IsChecked } else { $false }
        $optNoOutput = if ($script:chkOptNoOutput) { [bool]$script:chkOptNoOutput.IsChecked } else { $false }
        $optNoError = if ($script:chkOptNoError) { [bool]$script:chkOptNoError.IsChecked } else { $false }
        $optRequireAdmin = [bool]$script:dlgState.Adm
        $optConfigFile = if ($script:chkOptConfigFile) { [bool]$script:chkOptConfigFile.IsChecked } else { $false }
        $optNoVisualStyles = if ($script:chkOptNoVisualStyles) { [bool]$script:chkOptNoVisualStyles.IsChecked } else { $false }
        $optExitOnCancel = if ($script:chkOptExitOnCancel) { [bool]$script:chkOptExitOnCancel.IsChecked } else { $false }
        $optDPIAware = if ($script:chkOptDPIAware) { [bool]$script:chkOptDPIAware.IsChecked } else { $false }
        $optPrepareDebug = if ($script:chkOptPrepareDebug) { [bool]$script:chkOptPrepareDebug.IsChecked } else { $false }
        $optSupportOS = if ($script:chkOptSupportOS) { [bool]$script:chkOptSupportOS.IsChecked } else { $false }
        $optVirtualize = if ($script:chkOptVirtualize) { [bool]$script:chkOptVirtualize.IsChecked } else { $false }
        $optLongPaths = if ($script:chkOptLongPaths) { [bool]$script:chkOptLongPaths.IsChecked } else { $false }
        $optSaveIcon = if ($script:chkOptSaveIcon) { [bool]$script:chkOptSaveIcon.IsChecked } else { $false }
        $optSTA = if ($script:radOptSTA) { [bool]$script:radOptSTA.IsChecked } else { $true }
        $optPlatform = if ($script:cboOptPlatform) { @('anycpu', 'x86', 'x64')[$script:cboOptPlatform.SelectedIndex] } else { 'anycpu' }
        $optLCID = if ($script:txtOptLCID) { $script:txtOptLCID.Text.Trim() } else { '' }

        Add-LogLine -Message 'Using PS2EXE Advanced Engine (full PowerShell host)' -Level 'INFO'
        Invoke-CompileExePS2EXE -SourcePath $sourcePath -OutputPath $outputPath -IconPath $iconPath -BundleFolder $bundlePath `
            -Version $optVersion -ProductName $optProduct -FileDescription $optDesc -Copyright $optCopyright -Company $optCompany `
            -Trademark $optTrademark -NoConsole $optNoConsole -ConHost $optConHost `
            -UnicodeEncoding $optUnicodeEncoding -CredentialGUI $optCredentialGUI `
            -SuppressOutput $optNoOutput -SuppressError $optNoError -RequireAdmin $optRequireAdmin `
            -GenerateConfig $optConfigFile -NoVisualStyles $optNoVisualStyles -ExitOnCancel $optExitOnCancel `
            -DPIAware $optDPIAware -PrepareDebug $optPrepareDebug -SupportOS $optSupportOS `
            -Virtualize $optVirtualize -LongPaths $optLongPaths -SaveIcon $optSaveIcon `
            -ApartmentState $(if ($optSTA) { 'STA' } else { 'MTA' }) `
            -Platform $optPlatform -LCID $optLCID -SelectedFiles $selectedFiles
    }) | Out-Null
}
if ($script:btnOpenOut) {
    $script:btnOpenOut.Add_Click({
        $out = $script:txtOutPath.Text.Trim()
        if ($out) {
            $dir = Split-Path $out -Parent
            if ($dir -and (Test-Path $dir)) {
                Start-Process explorer.exe -ArgumentList "`"$dir`"" | Out-Null
                Add-LogLine -Message "Output folder opened in File Explorer" -Level 'INFO'
            } else { Add-LogLine -Message 'Output folder does not exist yet.' -Level 'WARNING' }
        } else { Add-LogLine -Message 'No output file path specified' -Level 'WARNING' }
    }) | Out-Null
}

if ($script:btnClear) {
    $script:btnClear.Add_Click({
        if (-not (Guard-Operation 'Clear')) { return }
        $script:txtProjectFolder.Text = ''
        $script:txtSrcScript.Text = ''
        $script:txtOutPath.Text = ''
        $script:txtIconPath.Text = ''
        $script:lblBundleCount.Text = '(select project folder)'
        $script:lblPkgName.Text = ''
        $script:lblSrcSize.Text = '--'
        Add-LogLine -Message 'All input fields have been reset' -Level 'INFO'
        Update-UIState
        Release-Operation
    }) | Out-Null
}

if ($script:btnCopyConsole) {
    $script:btnCopyConsole.Add_Click({
        $range = New-Object System.Windows.Documents.TextRange(
            $script:txtLog.Document.ContentStart,
            $script:txtLog.Document.ContentEnd
        )
        if (-not [string]::IsNullOrWhiteSpace($range.Text)) {
            [System.Windows.Clipboard]::SetText($range.Text)
            Show-ToastMessage -Message 'Console content copied to clipboard' -Type Success
            Add-LogLine -Message "Console content copied to clipboard" -Level 'SUCCESS'
        } else {
            Show-ToastMessage -Message 'Console is empty' -Type Warning
            Add-LogLine -Message "Console is empty, nothing to copy" -Level 'WARNING'
        }
    }) | Out-Null
}

if ($script:btnClearConsole) {
    $script:btnClearConsole.Add_Click({
        $script:txtLog.Document.Blocks.Clear()
        Add-LogLine -Message 'Console cleared.' -Level 'INFO'
    }) | Out-Null
}

if ($script:btnSettings) {
    $script:btnSettings.Add_Click({
        Invoke-SafeUIAction -Action { Show-SettingsDialog } -ActionName 'Settings'
    }) | Out-Null
}

if ($script:btnGenCerts) {
    $script:btnGenCerts.Add_Click({
        if (-not (Guard-Operation 'Generate Certs')) { return }
        $script:btnGenCerts.IsEnabled = $false
        $script:txtCertStatus.Text = 'Generating certificates...'
        Add-LogLine -Message '=== CertSign: Generating Certificates ===' -Level 'INFO'
        try {
            Invoke-CertSetup
            $script:txtCertStatus.Text = 'Certificates generated successfully'
            Show-ToastMessage -Message 'Certificates generated successfully!' -Type Success
        } catch {
            Add-LogLine -Message "Certificate generation failed: $_" -Level 'ERROR'
            Show-ToastMessage -Message 'Certificate generation failed' -Type Error
            $script:txtCertStatus.Text = 'Failed - see logs'
        }
        $script:btnGenCerts.IsEnabled = $true
        Release-Operation
    }) | Out-Null
}

if ($script:btnSignBrowse) {
    $script:btnSignBrowse.Add_Click({
        if (-not (Guard-Operation 'Browse Target')) { return }
        $dlg = New-Object System.Windows.Forms.OpenFileDialog
        $dlg.Filter = 'Executable Files (*.exe)|*.exe|All Files (*.*)|*.*'
        $dlg.Title = 'Select executable to sign'
        if ($dlg.ShowDialog() -eq 'OK') {
            $script:txtSignTarget.Text = $dlg.FileName
            Add-LogLine -Message "Sign target: $($dlg.FileName)" -Level 'INFO'
        }
        Release-Operation
    }) | Out-Null
}
if ($script:chkSignTimestamp) {
    $script:chkSignTimestamp.Add_Checked({ $script:txtSignTimestamp.IsEnabled = $true }) | Out-Null
    $script:chkSignTimestamp.Add_Unchecked({ $script:txtSignTimestamp.IsEnabled = $false }) | Out-Null
}

if ($script:btnSignNow) {
    $script:btnSignNow.Add_Click({
        if (-not (Guard-Operation 'Sign Executable')) { return }
        $target = $script:txtSignTarget.Text.Trim()
        if (-not $target) {
            Add-LogLine 'Select an executable to sign first.' -Level 'ERROR'
            Show-ToastMessage -Message 'Select an executable to sign' -Type Error
            Release-Operation; return
        }
        if (-not (Test-Path $target)) {
            Add-LogLine "File not found: $target" -Level 'ERROR'
            Show-ToastMessage -Message 'File not found' -Type Error
            Release-Operation; return
        }
        if (-not (Test-Path $script:CertPfxPath) -or -not (Test-Path $script:CertCaPath)) {
            $result = [System.Windows.MessageBox]::Show("Certificate chain not found. Generate certificates first?", 'PSWrap - CertSign', 'YesNo', 'Question')
            if ($result -eq 'Yes') {
                Add-LogLine '=== Generating certificates before signing ===' -Level 'INFO'
                try { Invoke-CertSetup } catch {
                    Add-LogLine "Setup failed: $_" -Level 'ERROR'
                    Show-ToastMessage -Message 'Certificate setup failed' -Type Error
                    Release-Operation; return
                }
                if (-not (Test-Path $script:CertPfxPath)) {
                    Add-LogLine 'Certificate generation did not produce PFX.' -Level 'ERROR'
                    Show-ToastMessage -Message 'Certificate generation did not produce PFX' -Type Error
                    Release-Operation; return
                }
            } else { Release-Operation; return }
        }
        $script:btnSignNow.IsEnabled = $false
        $script:txtCertStatus.Text = 'Signing...'
        Add-LogLine "=== Signing: $target ===" -Level 'INFO'
        $ts = if ($script:chkSignTimestamp.IsChecked -and $script:txtSignTimestamp.Text.Trim()) { $script:txtSignTimestamp.Text.Trim() } else { '' }
        $ok = Invoke-CertSign -TargetExe $target -TrustRoot:($script:chkSignTrust.IsChecked) -TimestampServer $ts
        if ($ok) {
            $script:txtCertStatus.Text = 'Signed successfully'
            Add-LogLine '=== Signing Complete ===' -Level 'SUCCESS'
            Show-ToastMessage -Message 'Signing completed successfully!' -Type Success
        } else {
            $script:txtCertStatus.Text = 'Signing failed - see logs'
            Show-ToastMessage -Message 'Signing failed' -Type Error
        }
        $script:btnSignNow.IsEnabled = $true
        Release-Operation
    }) | Out-Null
}
if ($script:txtProjectFolder) {
    $script:txtProjectFolder.Add_TextChanged({ Update-UIState })
}

if ($script:chkSelectAll) {
    $script:chkSelectAll.Add_Checked({
        foreach ($item in $script:bundleFiles) { $item.IsSelected = $true }
        if ($script:dgvBundleFiles) { $script:dgvBundleFiles.Items.Refresh() }
    }) | Out-Null
    $script:chkSelectAll.Add_Unchecked({
        foreach ($item in $script:bundleFiles) { $item.IsSelected = $false }
        if ($script:dgvBundleFiles) { $script:dgvBundleFiles.Items.Refresh() }
    }) | Out-Null
}

$script:Window.Add_DragOver({
    if ($_.Data.GetDataPresent([System.Windows.DataFormats]::FileDrop)) {
        $_.Effects = [System.Windows.DragDropEffects]::Copy
    } else { $_.Effects = [System.Windows.DragDropEffects]::None }
    $_.Handled = $true
}) | Out-Null

$script:Window.Add_Drop({
    if ($_.Data.GetDataPresent([System.Windows.DataFormats]::FileDrop)) {
        $files = $_.Data.GetData([System.Windows.DataFormats]::FileDrop)
        $ps1 = $files | Where-Object { $_ -like '*.ps1' } | Select-Object -First 1
        if ($ps1) {
            $script:txtSrcScript.Text = $ps1
            if (-not $script:txtOutPath.Text) {
                $script:txtOutPath.Text = [System.IO.Path]::ChangeExtension($ps1, '.exe')
            }
            Apply-ScriptMetadata -FilePath $ps1
            Add-LogLine -Message "File dropped: $ps1" -Level 'INFO'
            Update-UIState
        }
    }
}) | Out-Null

$script:clockTimer = New-Object System.Windows.Threading.DispatcherTimer
$script:clockTimer.Interval = [TimeSpan]::FromSeconds(1)
$script:clockTimer.Add_Tick({ $script:StatusTime.Text = (Get-Date).ToString('HH:mm:ss') }) | Out-Null
$script:clockTimer.Start()

$script:pollTimer = New-Object System.Windows.Threading.DispatcherTimer
$script:pollTimer.Interval = [TimeSpan]::FromMilliseconds(350)
$script:pollTimer.Add_Tick({
    if ($script:isBusy -and $script:asyncResult -and -not $script:asyncResult.IsCompleted) { return }
    if ($script:isBusy -and $script:asyncResult -and $script:asyncResult.IsCompleted) {
        try {
            $res = $script:asyncPowerShell.EndInvoke($script:asyncResult)
            if ($res -is [System.Collections.IList]) { $res = if ($res.Count -gt 0) { $res[0] } else { $null } }
            if ($res) {
                if ($res.Messages) {
                    foreach ($msg in $res.Messages) {
                        if ([string]::IsNullOrWhiteSpace($msg)) { continue }
                        $lvl = 'INFO'
                        if ($msg -match '\*\*\* COMPILATION SUCCESSFUL') { $lvl = 'SUCCESS' }
                        elseif ($msg -match '\[X\]|failed|ERROR') { $lvl = 'ERROR' }
                        Add-LogLine -Message $msg -Level $lvl
                    }
                }
                if ($res.CopiedIcon -and (Test-Path $res.CopiedIcon)) {
                    Remove-Item -LiteralPath $res.CopiedIcon -Force -ErrorAction SilentlyContinue
                }
                if ($res.Success) {
                    Show-ToastMessage -Message 'Compilation completed successfully!' -Type Success
                    Add-LogLine -Message "Executable: $($res.Output)" -Level 'SUCCESS'
                } else {
                    Add-LogLine -Message "Compilation failed (ExitCode=$($res.ExitCode))." -Level 'ERROR'
                    Show-ToastMessage -Message 'Compilation failed' -Type Error
                }
            }
        } catch {
            Add-LogLine -Message "Compilation result error: $($_.Exception.Message)" -Level 'ERROR'
        } finally {
            Stop-AsyncOperation
            Set-UIState -IsProcessing $false
            Update-UIState
        }
    }
}) | Out-Null
$script:pollTimer.Start()
$script:Window.Add_Closing({
    try { $script:clockTimer.Stop() } catch { }
    try { $script:pollTimer.Stop() } catch { }
    Invoke-SafeUIAction -Action {
        Add-LogLine -Message "Application closing. Releasing resources..." -Level 'INFO'
        try {
            if ($script:chkOptNoConsole) { $script:dlgState.NoCon = [bool]$script:chkOptNoConsole.IsChecked }
            if ($script:chkOptNoOutput) { $script:dlgState.SOut = [bool]$script:chkOptNoOutput.IsChecked }
            if ($script:chkOptNoError) { $script:dlgState.SErr = [bool]$script:chkOptNoError.IsChecked }
            if ($script:chkOptRequireAdmin) { $script:dlgState.Adm = [bool]$script:chkOptRequireAdmin.IsChecked }
            if ($script:chkOptConfigFile) { $script:dlgState.Cfg = [bool]$script:chkOptConfigFile.IsChecked }
            if ($script:chkOptSaveIcon) { $script:dlgState.CopyIcon = [bool]$script:chkOptSaveIcon.IsChecked }
            if ($script:radOptSTA) { $script:dlgState.STA = [bool]$script:radOptSTA.IsChecked }
            if ($script:cboOptPlatform) { $script:dlgState.Plat = $script:cboOptPlatform.SelectedIndex }
            $script:dlgState.UsePS2EXE = $true
            $buildSettings = @{}
            $metaKeys = @('Ver', 'Prod', 'Desc', 'Copy', 'Comp', 'Trade')
            foreach ($key in $script:dlgState.Keys) {
                if ($key -notin $metaKeys) { $buildSettings.$key = $script:dlgState.$key }
            }
            $save = @{
                Theme = if ($script:IsDarkMode) { 'Dark' } else { 'Light' }
                BuildSettings = $buildSettings
                ToastEnabled = if ($script:AppSettings -and $null -ne $script:AppSettings.ToastEnabled) { $script:AppSettings.ToastEnabled } else { $true }
            }
            Save-UserSettings -Settings $save
        } catch { Add-LogLine -Message "Failed to save settings on exit: $_" -Level 'WARNING' }
        try {
            Stop-AsyncOperation
            Cleanup-TempFiles
            Close-LogFile
        } catch { Add-LogLine -Message "Cleanup error on exit: $_" -Level 'WARNING' }
    } -ActionName 'Window Closing'
}) | Out-Null

if ($script:chkOptGrid) {
    foreach ($child in $script:chkOptGrid.Children) {
        if ($child -is [System.Windows.Controls.CheckBox]) {
            $content = $child.Content
            if ($content -is [System.Windows.Controls.StackPanel]) {
                foreach ($el in $content.Children) {
                    if ($el -is [System.Windows.Controls.Button] -and $el.Tag) {
                        $helpTag = $el.Tag
                        $el.Add_Click({
                            $tag = $this.Tag
                            if ($tag -match '^(.+?)\|(.+)') {
                                Show-HelpPopup -Title $matches[1] -HelpText $matches[2]
                            } else {
                                Show-HelpPopup -HelpText $tag
                            }
                        }) | Out-Null
                        break
                    }
                }
            }
        }
    }
}

if ($script:btnHelpMetadata) {
    $script:btnHelpMetadata.Add_Click({ Show-HelpPopup -Title 'Assembly Metadata' -HelpText $this.Tag }) | Out-Null
}
if ($script:btnHelpApt) {
    $script:btnHelpApt.Add_Click({ Show-HelpPopup -Title 'Thread Apartment' -HelpText $this.Tag }) | Out-Null
}
if ($script:btnHelpPlatform) {
    $script:btnHelpPlatform.Add_Click({ Show-HelpPopup -Title 'Platform Target' -HelpText $this.Tag }) | Out-Null
}
if ($script:btnHelpLCID) {
    $script:btnHelpLCID.Add_Click({ Show-HelpPopup -Title 'Locale ID (LCID)' -HelpText $this.Tag }) | Out-Null
}

Write-Debug "EventHandlers.ps1 loaded successfully."
