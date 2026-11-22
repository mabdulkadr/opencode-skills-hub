<#
.TITLE
    PSWrap Settings Dialog

.SYNOPSIS
    Advanced build settings dialog for PSWrap compilation options.

.DESCRIPTION
    Modal dialog that allows users to configure advanced build settings including
    assembly metadata, compilation behavior, threading model, and platform target.
    Settings are persisted across sessions via the dlgState dictionary and saved
    to the user settings JSON file on application close.

.TAGS
    Settings,Dialog,Build,Configuration,WPF

.MINROLE
    Reader

.PERMISSIONS
    N/A — UI only, modifies in-memory state

.AUTHOR
    admin

.VERSION
    1.0.0

.CHANGELOG
    1.0.0 - Initial release

.LASTUPDATE
    2026-07-21

.EXAMPLE
    Show-SettingsDialog
    Opens the advanced build settings dialog.

.NOTES
    - All controls bind to $script:dlgState for persistence
    - Theme-aware using DynamicResource brushes from the main window
    - Changes are only committed on OK; Cancel discards all edits
#>

function Get-ScriptMetadata {
<#
.SYNOPSIS
    Extracts script metadata from a PowerShell file's comment-based help block.

.DESCRIPTION
    Parses a PowerShell script for .TITLE, .VERSION, .DESCRIPTION, and .AUTHOR
    keywords within the file's comment-based help. Falls back to .SYNOPSIS for
    title, #requires -Version for version, and the filename stem if no title
    is found.

.PARAMETER FilePath
    Path to the PowerShell script file to scan for metadata.

.OUTPUTS
    Hashtable. Returns a hashtable with keys Title, Version, Description, and
    Author containing the extracted metadata strings.
#>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$FilePath)
    $result = @{ Title = ''; Version = ''; Description = ''; Author = '' }
    try {
        if (-not (Test-Path -LiteralPath $FilePath -PathType Leaf)) { return $result }
        $content = Get-Content -LiteralPath $FilePath -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
        if (-not $content) { return $result }

        # Title: .TITLE -> .SYNOPSIS -> filename (supports same-line and next-line)
        if ($content -match '(?im)^\s*\.TITLE\s*\r?\n?\s*(.+?)\s*$') {
            $result.Title = $matches[1].Trim()
        }
        elseif ($content -match '(?im)^\s*\.SYNOPSIS\s*\r?\n?\s*(.+?)\s*$') {
            $result.Title = $matches[1].Trim()
        }
        if (-not $result.Title) {
            $result.Title = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
        }

        # Version: .VERSION or #requires -Version (supports same-line and next-line)
        if ($content -match '(?im)^\s*\.VERSION\s*\r?\n?\s*([\d.]+)') {
            $result.Version = $matches[1].Trim()
        }
        if (-not $result.Version -and $content -match '(?im)#requires\s+-Version\s+([\d.]+)') {
            $result.Version = $matches[1].Trim()
        }

        # Description: .DESCRIPTION (multiline, up to next .keyword or end of help block)
        if ($content -match '(?is)\.DESCRIPTION\s*\r?\n\s*(.+?)(?:\r?\n\s*\.\w+|\r?\n\s*#+>|$)') {
            $desc = $matches[1].Trim() -replace '\r?\n\s+', ' '
            if ($desc.Length -gt 200) { $desc = $desc.Substring(0, 200) }
            $result.Description = $desc
        }

        # Author: .AUTHOR (supports same-line and next-line)
        if ($content -match '(?im)^\s*\.AUTHOR\s*\r?\n?\s*(.+?)\s*$') {
            $result.Author = $matches[1].Trim()
        }
    } catch { }
    return $result
}

function Apply-ScriptMetadata {
<#
.SYNOPSIS
    Merges extracted script metadata into the global dialog state.

.DESCRIPTION
    Calls Get-ScriptMetadata on the given file and populates $script:dlgState
    with the extracted title, description, version, and company values.

.PARAMETER FilePath
    Path to the PowerShell script file whose metadata will be extracted and
    applied to the dialog state.

.NOTES
    Performs a non-destructive merge into $script:dlgState — existing dlgState
    values are only overwritten if they are empty or at their default values
     (e.g. Ver defaults to '1.1.0.0'). This preserves user-defined values while
    filling in gaps from script metadata.
#>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$FilePath)
    $meta = Get-ScriptMetadata -FilePath $FilePath
    if ($meta.Title) {
        $script:dlgState.Prod = $meta.Title
        $script:dlgState.Desc = $meta.Description
    }
    if ($meta.Version) {
        $script:dlgState.Ver = $meta.Version
    }
    if ($meta.Author) {
        $script:dlgState.Comp = $meta.Author
    }
}

function Show-SettingsDialog {
<#
.SYNOPSIS
    Opens the Advanced Build Settings dialog window.

.DESCRIPTION
    Renders a modal, theme-aware WPF dialog for configuring assembly metadata,
    compilation behavior, threading model, and platform target. Changes are
    committed to $script:dlgState on Save and persisted to JSON on app close.

.NOTES
    The XAML layout is constructed as a string with interpolated theme color
    variables derived from the current dark/light mode ($script:IsDarkMode).
    Color values are resolved inline via PowerShell string expansion before
    the XAML is parsed with XmlNodeReader and loaded through XamlReader.
    Controls bind directly to $script:dlgState for live reflection of saved
    preferences.
#>
    try {
        $isDark = $script:IsDarkMode
        $bgColor       = if ($isDark) { '#1E293B' } else { '#F4F7FB' }
        $surfaceColor  = if ($isDark) { '#334155' } else { '#FFFFFF' }
        $borderColor   = if ($isDark) { '#475569' } else { '#E2E8F0' }
        $textPrimary   = if ($isDark) { '#FFFFFF' } else { '#0F172A' }
        $textSecondary = if ($isDark) { '#CBD5E1' } else { '#64748B' }
        $textBody      = if ($isDark) { '#E2E8F0' } else { '#334155' }
        $textMuted     = if ($isDark) { '#94A3B8' } else { '#94A3B8' }
        $accentColor   = if ($isDark) { '#60A5FA' } else { '#3B82F6' }
        $accentTint    = if ($isDark) { '#1E3A5F' } else { '#EFF6FF' }
        $hoverColor    = if ($isDark) { '#475569' } else { '#F1F5F9' }
        $inputBg       = if ($isDark) { '#1E293B' } else { '#FFFFFF' }
        $closeBtnColor = '#94A3B8'
        $closeBtnHover = if ($isDark) { '#475569' } else { '#F1F5F9' }
        $separatorColor = $borderColor
        $codeBg        = if ($isDark) { '#0F172A' } else { '#EFF6FF' }
        $codeFg        = if ($isDark) { '#93C5FD' } else { '#1D4ED8' }
        $s = $script:dlgState

        $xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Advanced Build Settings" Width="640" Height="620"
    MinWidth="540" MinHeight="520"
    WindowStartupLocation="CenterOwner"
    WindowStyle="None" AllowsTransparency="True" Background="Transparent"
    ShowInTaskbar="False" ResizeMode="CanResizeWithGrip" Topmost="True">
    <Border CornerRadius="12" Background="$bgColor"
        BorderBrush="$borderColor" BorderThickness="1" Margin="8">
        <Border.Effect>
            <DropShadowEffect BlurRadius="32" ShadowDepth="12" Color="#0F172A" Opacity="0.18" Direction="270"/>
        </Border.Effect>
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <!-- Header -->
            <Border Grid.Row="0" Background="$surfaceColor" BorderBrush="$borderColor"
                BorderThickness="0,0,0,1" Padding="20,14" CornerRadius="12,12,0,0">
                <Grid>
                    <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                        <Border Width="32" Height="32" CornerRadius="8" Background="$accentTint" Margin="0,0,10,0">
                            <Path Stretch="Uniform" Width="16" Height="16" Fill="$accentColor"
                                Data="M19.14 12.94c.04-.3.06-.61.06-.94 0-.32-.02-.64-.07-.94l2.03-1.58a.49.49 0 00.12-.61l-1.92-3.32a.488.488 0 00-.59-.22l-2.39.96c-.5-.38-1.03-.7-1.62-.94L14.4 2.81a.484.484 0 00-.41-.3h-3.84c-.17 0-.33.09-.41.28l-.36 2.54c-.59.24-1.13.57-1.62.94l-2.39-.96c-.22-.08-.47 0-.59.22L2.74 8.87c-.12.21-.08.47.12.61l2.03 1.58c-.04.3-.07.62-.07.94s.02.64.07.94l-2.03 1.58a.49.49 0 00-.12.61l1.92 3.32c.12.22.37.29.59.22l2.39-.96c.5.38 1.03.7 1.62.94l.36 2.54c.08.19.24.3.41.3h3.84c.17 0 .33-.09.41-.28l.36-2.54c.59-.24 1.13-.56 1.62-.94l2.39.96c.22.08.47 0 .59-.22l1.92-3.32c.12-.22.07-.47-.12-.61l-2.01-1.58zM12 15.6c-1.98 0-3.6-1.62-3.6-3.6s1.62-3.6 3.6-3.6 3.6 1.62 3.6 3.6-1.62 3.6-3.6 3.6z"
                                HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <TextBlock Text="Advanced Build Settings" FontSize="16" FontWeight="Bold"
                            Foreground="$textPrimary" VerticalAlignment="Center"/>
                    </StackPanel>
                    <Button x:Name="btnCloseSettings" Width="28" Height="28"
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
            </Border>

            <!-- Content -->
            <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled"
                Padding="20,16,20,8">
                <StackPanel>

                    <!-- ASSEMBLY METADATA -->
                    <TextBlock Text="ASSEMBLY METADATA" FontSize="11" FontWeight="Bold"
                        Foreground="$textMuted" Margin="0,0,0,8"/>
                    <Border Background="$surfaceColor" BorderBrush="$borderColor" BorderThickness="1"
                        CornerRadius="8" Padding="14" Margin="0,0,0,14">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="100"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="6"/>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="6"/>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="6"/>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="6"/>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="6"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>

                            <TextBlock Grid.Row="0" Text="Version" FontSize="12" FontWeight="SemiBold"
                                Foreground="$textSecondary" VerticalAlignment="Center"/>
                            <TextBox x:Name="txtDlgVer" Grid.Row="0" Grid.Column="1"
                                Background="$inputBg" Foreground="$textPrimary" BorderBrush="$borderColor"
                                BorderThickness="1" Height="30" Padding="8,0" FontSize="12"
                                VerticalContentAlignment="Center" Text="$($s.Ver)"/>

                            <TextBlock Grid.Row="2" Text="Product" FontSize="12" FontWeight="SemiBold"
                                Foreground="$textSecondary" VerticalAlignment="Center"/>
                            <TextBox x:Name="txtDlgProd" Grid.Row="2" Grid.Column="1"
                                Background="$inputBg" Foreground="$textPrimary" BorderBrush="$borderColor"
                                BorderThickness="1" Height="30" Padding="8,0" FontSize="12"
                                VerticalContentAlignment="Center" Text="$($s.Prod)"/>

                            <TextBlock Grid.Row="4" Text="Description" FontSize="12" FontWeight="SemiBold"
                                Foreground="$textSecondary" VerticalAlignment="Center"/>
                            <TextBox x:Name="txtDlgDesc" Grid.Row="4" Grid.Column="1"
                                Background="$inputBg" Foreground="$textPrimary" BorderBrush="$borderColor"
                                BorderThickness="1" Height="30" Padding="8,0" FontSize="12"
                                VerticalContentAlignment="Center" Text="$($s.Desc)"/>

                            <TextBlock Grid.Row="6" Text="Copyright" FontSize="12" FontWeight="SemiBold"
                                Foreground="$textSecondary" VerticalAlignment="Center"/>
                            <TextBox x:Name="txtDlgCopy" Grid.Row="6" Grid.Column="1"
                                Background="$inputBg" Foreground="$textPrimary" BorderBrush="$borderColor"
                                BorderThickness="1" Height="30" Padding="8,0" FontSize="12"
                                VerticalContentAlignment="Center" Text="$($s.Copy)"/>

                            <TextBlock Grid.Row="8" Text="Company" FontSize="12" FontWeight="SemiBold"
                                Foreground="$textSecondary" VerticalAlignment="Center"/>
                            <TextBox x:Name="txtDlgComp" Grid.Row="8" Grid.Column="1"
                                Background="$inputBg" Foreground="$textPrimary" BorderBrush="$borderColor"
                                BorderThickness="1" Height="30" Padding="8,0" FontSize="12"
                                VerticalContentAlignment="Center" Text="$($s.Comp)"/>

                            <TextBlock Grid.Row="10" Text="Trademark" FontSize="12" FontWeight="SemiBold"
                                Foreground="$textSecondary" VerticalAlignment="Center"/>
                            <TextBox x:Name="txtDlgTrade" Grid.Row="10" Grid.Column="1"
                                Background="$inputBg" Foreground="$textPrimary" BorderBrush="$borderColor"
                                BorderThickness="1" Height="30" Padding="8,0" FontSize="12"
                                VerticalContentAlignment="Center" Text="$($s.Trade)"/>
                        </Grid>
                    </Border>

                    <!-- COMPILATION BEHAVIOR -->
                    <TextBlock Text="COMPILATION BEHAVIOR" FontSize="11" FontWeight="Bold"
                        Foreground="$textMuted" Margin="0,0,0,8"/>
                    <Border Background="$surfaceColor" BorderBrush="$borderColor" BorderThickness="1"
                        CornerRadius="8" Padding="14" Margin="0,0,0,14">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>
                            <StackPanel Grid.Column="0">
                                <CheckBox x:Name="chkDlgNoCon" IsChecked="$($s.NoCon)" Margin="0,0,0,8"
                                    FontSize="12" Foreground="$textBody" Content="No Console (GUI mode)"/>
                                <CheckBox x:Name="chkDlgSOut" IsChecked="$($s.SOut)" Margin="0,0,0,8"
                                    FontSize="12" Foreground="$textBody" Content="Suppress Output"/>
                                <CheckBox x:Name="chkDlgSErr" IsChecked="$($s.SErr)" Margin="0,0,0,8"
                                    FontSize="12" Foreground="$textBody" Content="Suppress Error"/>
                                <CheckBox x:Name="chkDlgAdm" IsChecked="$($s.Adm)" Margin="0,0,0,8"
                                    FontSize="12" Foreground="$textBody" Content="Require Admin"/>
                                <CheckBox x:Name="chkDlgCfg" IsChecked="$($s.Cfg)" Margin="0,0,0,8"
                                    FontSize="12" Foreground="$textBody" Content="Generate Config File"/>
                                <CheckBox x:Name="chkDlgCopyIcon" IsChecked="$($s.CopyIcon)" Margin="0,0,0,8"
                                    FontSize="12" Foreground="$textBody" Content="Save Icon"/>
                            </StackPanel>
                            <StackPanel Grid.Column="1">
                                <CheckBox x:Name="chkDlgNoVisual" IsChecked="$($s.NoVisual)" Margin="0,0,0,8"
                                    FontSize="12" Foreground="$textBody" Content="No Visual Styles"/>
                                <CheckBox x:Name="chkDlgExitCancel" IsChecked="$($s.ExitCancel)" Margin="0,0,0,8"
                                    FontSize="12" Foreground="$textBody" Content="Exit On Cancel"/>
                                <CheckBox x:Name="chkDlgDPI" IsChecked="$($s.DPI)" Margin="0,0,0,8"
                                    FontSize="12" Foreground="$textBody" Content="DPI Aware"/>
                                <CheckBox x:Name="chkDlgDebug" IsChecked="$($s.Debug)" Margin="0,0,0,8"
                                    FontSize="12" Foreground="$textBody" Content="Prepare Debug"/>
                                <CheckBox x:Name="chkDlgSupportOS" IsChecked="$($s.SupportOS)" Margin="0,0,0,8"
                                    FontSize="12" Foreground="$textBody" Content="Support OS"/>
                                <CheckBox x:Name="chkDlgVirtual" IsChecked="$($s.Virtual)" Margin="0,0,0,8"
                                    FontSize="12" Foreground="$textBody" Content="Virtualize"/>
                                <CheckBox x:Name="chkDlgLongPaths" IsChecked="$($s.LongPaths)" Margin="0,0,0,8"
                                    FontSize="12" Foreground="$textBody" Content="Long Paths"/>
                            </StackPanel>
                        </Grid>
                    </Border>

                    <!-- THREADING & PLATFORM -->
                    <TextBlock Text="THREADING &amp; PLATFORM" FontSize="11" FontWeight="Bold"
                        Foreground="$textMuted" Margin="0,0,0,8"/>
                    <Border Background="$surfaceColor" BorderBrush="$borderColor" BorderThickness="1"
                        CornerRadius="8" Padding="14" Margin="0,0,0,14">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="Auto" MinWidth="100"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="10"/>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="10"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>

                            <TextBlock Grid.Row="0" Text="Apartment:" FontSize="12" FontWeight="SemiBold"
                                Foreground="$textSecondary" VerticalAlignment="Center" Margin="0,0,10,0"/>
                            <StackPanel Grid.Row="0" Grid.Column="1" Orientation="Horizontal">
                                <RadioButton x:Name="radDlgSTA" Content="STA" IsChecked="$($s.STA)"
                                    FontSize="12" Foreground="$textBody" Margin="0,0,16,0"
                                    VerticalAlignment="Center"/>
                                <RadioButton x:Name="radDlgMTA" Content="MTA" IsChecked="$(-not $s.STA)"
                                    FontSize="12" Foreground="$textBody"
                                    VerticalAlignment="Center"/>
                            </StackPanel>

                            <TextBlock Grid.Row="2" Text="Platform:" FontSize="12" FontWeight="SemiBold"
                                Foreground="$textSecondary" VerticalAlignment="Center" Margin="0,0,10,0"/>
                            <ComboBox x:Name="cboDlgPlatform" Grid.Row="2" Grid.Column="1"
                                Background="$inputBg" Foreground="$textPrimary" BorderBrush="$borderColor"
                                BorderThickness="1" Height="30" Padding="8,0" FontSize="12"
                                SelectedIndex="$($s.Plat)">
                                <ComboBoxItem Content="Any CPU"/>
                                <ComboBoxItem Content="x86"/>
                                <ComboBoxItem Content="x64"/>
                            </ComboBox>

                            <TextBlock Grid.Row="4" Text="LCID:" FontSize="12" FontWeight="SemiBold"
                                Foreground="$textSecondary" VerticalAlignment="Center" Margin="0,0,10,0"/>
                            <TextBox x:Name="txtDlgLCID" Grid.Row="4" Grid.Column="1"
                                Background="$inputBg" Foreground="$textPrimary" BorderBrush="$borderColor"
                                BorderThickness="1" Height="30" Padding="8,0" FontSize="12"
                                VerticalContentAlignment="Center" Text="$($s.LCID)" Width="120"
                                HorizontalAlignment="Left"/>
                        </Grid>
                    </Border>

                    <!-- NOTIFICATIONS -->
                    <TextBlock Text="NOTIFICATIONS" FontSize="11" FontWeight="Bold"
                        Foreground="$textMuted" Margin="0,0,0,8"/>
                    <Border Background="$surfaceColor" BorderBrush="$borderColor" BorderThickness="1"
                        CornerRadius="8" Padding="14" Margin="0,0,0,4">
                        <StackPanel Orientation="Horizontal">
                            <CheckBox x:Name="chkDlgToast" IsChecked="$($script:AppSettings.ToastEnabled)"
                                FontSize="12" Foreground="$textBody"
                                Content="Enable toast notifications" VerticalAlignment="Center"/>
                        </StackPanel>
                    </Border>

                </StackPanel>
            </ScrollViewer>

            <!-- Footer -->
            <Border Grid.Row="2" Background="$surfaceColor" BorderBrush="$borderColor"
                BorderThickness="0,1,0,0" Padding="16,12" CornerRadius="0,0,12,12">
                <Grid>
                    <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                        <Button x:Name="btnSettingsCancel" Width="90" Height="34" Cursor="Hand"
                            FontSize="12" FontWeight="SemiBold" Margin="0,0,8,0">
                            <Button.Template>
                                <ControlTemplate TargetType="Button">
                                    <Border x:Name="bd" Background="$surfaceColor" BorderBrush="$borderColor"
                                        BorderThickness="1" CornerRadius="8">
                                        <TextBlock Text="Cancel" HorizontalAlignment="Center" VerticalAlignment="Center"
                                            Foreground="$textBody" FontSize="12" FontWeight="SemiBold"/>
                                    </Border>
                                    <ControlTemplate.Triggers>
                                        <Trigger Property="IsMouseOver" Value="True">
                                            <Setter TargetName="bd" Property="Background" Value="$hoverColor"/>
                                        </Trigger>
                                    </ControlTemplate.Triggers>
                                </ControlTemplate>
                            </Button.Template>
                        </Button>
                        <Button x:Name="btnSettingsApply" Width="90" Height="34" Cursor="Hand"
                            FontSize="12" FontWeight="SemiBold">
                            <Button.Template>
                                <ControlTemplate TargetType="Button">
                                    <Border x:Name="bd" Background="$accentColor" BorderThickness="0" CornerRadius="8">
                                        <TextBlock Text="Save" HorizontalAlignment="Center" VerticalAlignment="Center"
                                            Foreground="White" FontSize="12" FontWeight="SemiBold"/>
                                    </Border>
                                    <ControlTemplate.Triggers>
                                        <Trigger Property="IsMouseOver" Value="True">
                                            <Setter TargetName="bd" Property="UIElement.Opacity" Value="0.85"/>
                                        </Trigger>
                                        <Trigger Property="IsPressed" Value="True">
                                            <Setter TargetName="bd" Property="UIElement.Opacity" Value="0.7"/>
                                        </Trigger>
                                    </ControlTemplate.Triggers>
                                </ControlTemplate>
                            </Button.Template>
                        </Button>
                    </StackPanel>
                </Grid>
            </Border>
        </Grid>
    </Border>
</Window>
"@

        $clean = $xaml -replace '[\uFEFF\u200B\u200C\u200D\u200E\u200F\u202A-\u202E]', ''
        $xml = [xml]$clean
        $reader = New-Object System.Xml.XmlNodeReader($xml)
        $dlg = [System.Windows.Markup.XamlReader]::Load($reader)
        $reader.Close()

        $btnClose     = $dlg.FindName('btnCloseSettings')
        $btnCancel    = $dlg.FindName('btnSettingsCancel')
        $btnApply     = $dlg.FindName('btnSettingsApply')

        $closeAction = { $dlg.Close() }
        if ($btnClose)  { $btnClose.Add_Click($closeAction)  | Out-Null }
        if ($btnCancel) { $btnCancel.Add_Click($closeAction) | Out-Null }

        if ($btnApply) {
            $btnApply.Add_Click({
                $script:dlgState.Ver       = $dlg.FindName('txtDlgVer').Text.Trim()
                $script:dlgState.Prod      = $dlg.FindName('txtDlgProd').Text.Trim()
                $script:dlgState.Desc      = $dlg.FindName('txtDlgDesc').Text.Trim()
                $script:dlgState.Copy      = $dlg.FindName('txtDlgCopy').Text.Trim()
                $script:dlgState.Comp      = $dlg.FindName('txtDlgComp').Text.Trim()
                $script:dlgState.Trade     = $dlg.FindName('txtDlgTrade').Text.Trim()
                $script:dlgState.NoCon     = [bool]$dlg.FindName('chkDlgNoCon').IsChecked
                $script:dlgState.SOut      = [bool]$dlg.FindName('chkDlgSOut').IsChecked
                $script:dlgState.SErr      = [bool]$dlg.FindName('chkDlgSErr').IsChecked
                $script:dlgState.Adm       = [bool]$dlg.FindName('chkDlgAdm').IsChecked
                $script:dlgState.Cfg       = [bool]$dlg.FindName('chkDlgCfg').IsChecked
                $script:dlgState.CopyIcon  = [bool]$dlg.FindName('chkDlgCopyIcon').IsChecked
                $script:dlgState.NoVisual  = [bool]$dlg.FindName('chkDlgNoVisual').IsChecked
                $script:dlgState.ExitCancel = [bool]$dlg.FindName('chkDlgExitCancel').IsChecked
                $script:dlgState.DPI       = [bool]$dlg.FindName('chkDlgDPI').IsChecked
                $script:dlgState.Debug     = [bool]$dlg.FindName('chkDlgDebug').IsChecked
                $script:dlgState.SupportOS = [bool]$dlg.FindName('chkDlgSupportOS').IsChecked
                $script:dlgState.Virtual   = [bool]$dlg.FindName('chkDlgVirtual').IsChecked
                $script:dlgState.LongPaths = [bool]$dlg.FindName('chkDlgLongPaths').IsChecked
                $script:dlgState.STA       = [bool]$dlg.FindName('radDlgSTA').IsChecked
                $script:dlgState.Plat      = $dlg.FindName('cboDlgPlatform').SelectedIndex
                $script:dlgState.LCID      = $dlg.FindName('txtDlgLCID').Text.Trim()
                $script:dlgState.UsePS2EXE = $true
                if ($script:chkToastEnabled) {
                    $script:AppSettings.ToastEnabled = [bool]$dlg.FindName('chkDlgToast').IsChecked
                }
                Add-LogLine -Message 'Build settings updated' -Level 'INFO'
                $dlg.Close()
            }) | Out-Null
        }

        $dlg.Owner = $script:Window
        [void]$dlg.ShowDialog()
    } catch {
        Add-LogLine -Message "Failed to open Settings dialog: $($_.Exception.Message)" -Level 'ERROR'
    }
}
