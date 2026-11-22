<#
.TITLE
    PSWrap WPF Helper Utilities

.SYNOPSIS
    Core GUI helpers: theme, toasts, dispatching, guarding, formatting.

.DESCRIPTION
    Provides core GUI helper functions including theme management (dark/light),
    toast notifications, safe UI dispatching, file size formatting, operation
    guarding, and icon path data for theme toggle buttons.

.TAGS
    WPF,UI,Theme,Helpers,Toast,Dispatcher

.MINROLE
    Reader

.PERMISSIONS
    N/A — UI helpers only, no external API calls

.AUTHOR
    admin

.VERSION
    1.0.0

.CHANGELOG
    1.0.0 - Initial release

.LASTUPDATE
    2026-06-17

.EXAMPLE
    Set-Theme -Window $Window -IsDark $true
    Show-ToastMessage -Message "Done!" -Type Success
    Guard-Operation "Compile"

.NOTES
    The theme system uses DynamicResource brushes for instant switching.
    The toast system uses fade-in/fade-out animations via DispatcherTimer.
#>

$SunIconData  = 'M12 7c-2.76 0-5 2.24-5 5s2.24 5 5 5 5-2.24 5-5-2.24-5-5-5zM2 13h2c.55 0 1-.45 1-1s-.45-1-1-1H2c-.55 0-1 .45-1 1s.45 1 1 1zm18 0h2c.55 0 1-.45 1-1s-.45-1-1-1h-2c-.55 0-1 .45-1 1s.45 1 1 1zM11 2v2c0 .55.45 1 1 1s1-.45 1-1V2c0-.55-.45-1-1-1s-1 .45-1 1zm0 18v2c0 .55.45 1 1 1s1-.45 1-1v-2c0-.55-.45-1-1-1s-1 .45-1 1zM5.99 4.58c-.39-.39-1.03-.39-1.41 0-.39.39-.39 1.03 0 1.41l1.06 1.06c.39.39 1.03.39 1.41 0s.39-1.03 0-1.41L5.99 4.58zm12.37 12.37c-.39-.39-1.03-.39-1.41 0-.39.39-.39 1.03 0 1.41l1.06 1.06c.39.39 1.03.39 1.41 0 .39-.39.39-1.03 0-1.41l-1.06-1.06zm1.06-10.96c.39-.39.39-1.03 0-1.41-.39-.39-1.03-.39-1.41 0l-1.06 1.06c-.39.39-.39 1.03 0 1.41s1.03.39 1.41 0l1.06-1.06zM7.05 18.36c.39-.39.39-1.03 0-1.41-.39-.39-1.03-.39-1.41 0l-1.06 1.06c-.39.39-.39 1.03 0 1.41s1.03.39 1.41 0l1.06-1.06z'
$MoonIconData = 'M9 2c-1.05 0-2.05.16-3 .46 4.06 1.27 7 5.06 7 9.54 0 4.48-2.94 8.27-7 9.54.95.3 1.95.46 3 .46 5.52 0 10-4.48 10-10S14.52 2 9 2z'

function New-Brush {
    <#
    .SYNOPSIS
        Creates a SolidColorBrush from a hex color string.
    .PARAMETER Hex
        Hex color string (e.g., '#3B82F6', '#FFFFFF'). Supports shorthand
        notation via BrushConverter.
    .OUTPUTS
        System.Windows.Media.SolidColorBrush.
    .EXAMPLE
        $blueBrush = New-Brush '#3B82F6'
    #>
    [CmdletBinding()]
    param([string]$Hex)
    (New-Object System.Windows.Media.BrushConverter).ConvertFromString($Hex)
}

function Guard-Operation {
    <#
    .SYNOPSIS
        Acquires the global busy lock to prevent concurrent operations.
    .DESCRIPTION
        Checks the global $script:isBusy flag. If the application is already
        processing an operation, logs a warning and returns $false. Otherwise,
        sets the flag and returns $true. Must be paired with Release-Operation.
    .PARAMETER ActionName
        Human-readable name of the operation being guarded (for log messages).
    .OUTPUTS
        Boolean. $true if the lock was acquired, $false if already busy.
    .EXAMPLE
        if (-not (Guard-Operation 'Compile')) { return }
        # ... do work ...
        Release-Operation
    #>
    [CmdletBinding()]
    param([string]$ActionName)
    if ($script:isBusy) {
        Add-LogLine -Message "Operation in progress - please wait: $ActionName" -Level 'WARNING'
        return $false
    }
    $script:isBusy = $true
    return $true
}

function Release-Operation {
    <#
    .SYNOPSIS
        Releases the global busy lock.
    .DESCRIPTION
        Clears the $script:isBusy flag, allowing new operations to start.
        Must be called after every successful Guard-Operation call.
    #>
    $script:isBusy = $false
}

function Set-Theme {
    <#
    .SYNOPSIS
        Applies the dark or light theme to a WPF Window.
    .DESCRIPTION
        Replaces all DynamicResource brushes in the Window's Resources dictionary
        with theme-specific color values. The dark theme uses Slate-based colors
        (#1E293B surface, #60A5FA accent). The light theme uses neutral whites
        and blues. All UI elements bound to DynamicResource update instantly.
    .PARAMETER Window
        The WPF Window to theme. Its Resources dictionary is modified in place.
    .PARAMETER IsDark
        If $true, applies the dark theme; otherwise the light theme.
    .EXAMPLE
        Set-Theme -Window $script:Window -IsDark $true
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Window,
        [bool]$IsDark = $false
    )
    try {
        $resources = $Window.Resources
        if ($IsDark) {
            $resources['BackgroundBrush']    = New-Brush '#1E293B'
            $resources['SurfaceBrush']       = New-Brush '#334155'
            $resources['SurfaceHoverBrush']  = New-Brush '#475569'
            $resources['SidebarBrush']       = New-Brush '#475569'
            $resources['BorderBrush']        = New-Brush '#475569'
            $resources['BorderHoverBrush']   = New-Brush '#60A5FA'
            $resources['TextPrimaryBrush']   = New-Brush '#FFFFFF'
            $resources['TextSecondaryBrush'] = New-Brush '#CBD5E1'
            $resources['TextMutedBrush']     = New-Brush '#94A3B8'
            $resources['TextBodyBrush']      = New-Brush '#E2E8F0'
            $resources['AccentBrush']        = New-Brush '#60A5FA'
            $resources['AccentHoverBrush']   = New-Brush '#93C5FD'
            $resources['AccentTintBrush']    = New-Brush '#1E3A5F'
            $resources['SuccessBrush']       = New-Brush '#10B981'
            $resources['DangerBrush']        = New-Brush '#EF4444'
            $resources['BtnPrimaryBg']       = New-Brush '#5B7CF5'
            $resources['BtnBlueBg']          = New-Brush '#4A78E8'
            $resources['BtnGreenBg']         = New-Brush '#2EA76E'
            $resources['BtnRedBg']           = New-Brush '#D9534F'
            $resources['BtnPurpleBg']        = New-Brush '#9560D8'
            $resources['BtnGhostFg']         = New-Brush '#A0A1A6'
            $resources['BtnGhostHoverBg']    = New-Brush '#232536'
            $resources['CodeBg']             = New-Brush '#1E3A5F'
            $resources['CodeFg']             = New-Brush '#93C5FD'
            $resources['TableBg']            = New-Brush '#334155'
            $resources['TableHeaderBg']      = New-Brush '#475569'
            $resources['TableAltBg']         = New-Brush '#3B4A5E'
            $resources['TableBorder']        = New-Brush '#475569'
            $resources['LinkFg']             = New-Brush '#60A5FA'
            $resources['BlockquoteBg']       = New-Brush '#1E3A5F'
            $resources['BlockquoteFg']       = New-Brush '#93C5FD'
            $resources['BulletFg']           = New-Brush '#60A5FA'
            $resources['IconBg']             = New-Brush '#1E3A5F'
            $resources['IconFg']             = New-Brush '#60A5FA'
            $resources['H4Fg']               = New-Brush '#93C5FD'
            $resources['HeadingFg']          = New-Brush '#F1F5F9'
            $resources['BodyFg']             = New-Brush '#E2E8F0'
            $resources['SeparatorBg']        = New-Brush '#475569'
            $resources['UnderlineFg']        = New-Brush '#60A5FA'
            $resources['TabAccentBg']        = New-Brush '#60A5FA'
            $resources['TabAccentText']      = New-Brush '#FFFFFF'
            $resources['TabInactiveBg']      = New-Brush '#1E293B'
            $resources['TabInactiveBorder']  = New-Brush '#475569'
            $resources['TabInactiveText']    = New-Brush '#94A3B8'
            $resources['TabHoverBg']         = New-Brush '#334155'
            $resources['CodeBlockBg']        = New-Brush '#0F172A'
            $resources['CodeBlockFg']        = New-Brush '#E2E8F0'
            $Window.Background = New-Brush '#1E293B'
        } else {
            $resources['BackgroundBrush']    = New-Brush '#F1F5F9'
            $resources['SurfaceBrush']       = New-Brush '#FFFFFF'
            $resources['SurfaceHoverBrush']  = New-Brush '#F1F5F9'
            $resources['SidebarBrush']       = New-Brush '#E8EDF4'
            $resources['BorderBrush']        = New-Brush '#E2E8F0'
            $resources['BorderHoverBrush']   = New-Brush '#93C5FD'
            $resources['TextPrimaryBrush']   = New-Brush '#0F172A'
            $resources['TextSecondaryBrush'] = New-Brush '#64748B'
            $resources['TextMutedBrush']     = New-Brush '#94A3B8'
            $resources['TextBodyBrush']      = New-Brush '#334155'
            $resources['AccentBrush']        = New-Brush '#3B82F6'
            $resources['AccentHoverBrush']   = New-Brush '#1D4ED8'
            $resources['AccentTintBrush']    = New-Brush '#EFF6FF'
            $resources['SuccessBrush']       = New-Brush '#10B981'
            $resources['DangerBrush']        = New-Brush '#EF4444'
            $resources['BtnPrimaryBg']       = New-Brush '#4F46E5'
            $resources['BtnBlueBg']          = New-Brush '#3B82F6'
            $resources['BtnGreenBg']         = New-Brush '#10B981'
            $resources['BtnRedBg']           = New-Brush '#EF4444'
            $resources['BtnPurpleBg']        = New-Brush '#A855F7'
            $resources['BtnGhostFg']         = New-Brush '#64748B'
            $resources['BtnGhostHoverBg']    = New-Brush '#F1F5F9'
            $resources['CodeBg']             = New-Brush '#EFF6FF'
            $resources['CodeFg']             = New-Brush '#1D4ED8'
            $resources['TableBg']            = New-Brush '#FFFFFF'
            $resources['TableHeaderBg']      = New-Brush '#F1F5F9'
            $resources['TableAltBg']         = New-Brush '#F8FAFC'
            $resources['TableBorder']        = New-Brush '#E2E8F0'
            $resources['LinkFg']             = New-Brush '#3B82F6'
            $resources['BlockquoteBg']       = New-Brush '#F0F9FF'
            $resources['BlockquoteFg']       = New-Brush '#1E40AF'
            $resources['BulletFg']           = New-Brush '#3B82F6'
            $resources['IconBg']             = New-Brush '#DBEAFE'
            $resources['IconFg']             = New-Brush '#1D4ED8'
            $resources['H4Fg']               = New-Brush '#1D4ED8'
            $resources['HeadingFg']          = New-Brush '#0F172A'
            $resources['BodyFg']             = New-Brush '#334155'
            $resources['SeparatorBg']        = New-Brush '#E2E8F0'
            $resources['UnderlineFg']        = New-Brush '#3B82F6'
            $resources['TabAccentBg']        = New-Brush '#3B82F6'
            $resources['TabAccentText']      = New-Brush '#FFFFFF'
            $resources['TabInactiveBg']      = New-Brush '#F8FAFC'
            $resources['TabInactiveBorder']  = New-Brush '#E2E8F0'
            $resources['TabInactiveText']    = New-Brush '#64748B'
            $resources['TabHoverBg']         = New-Brush '#F1F5F9'
            $resources['CodeBlockBg']        = New-Brush '#1E293B'
            $resources['CodeBlockFg']        = New-Brush '#E2E8F0'
            $Window.Background = New-Brush '#F4F7FB'
        }
    } catch {
        Add-LogLine -Message "Set-Theme failed: $($_.Exception.Message)" -Level 'ERROR'
    }
}

function Invoke-SafeUIAction {
    <#
    .SYNOPSIS
        Executes a script block on the WPF Dispatcher thread.
    .DESCRIPTION
        Checks if the current thread has access to the WPF Dispatcher. If so,
        executes directly. Otherwise, marshals the call to the UI thread via
        Dispatcher.Invoke. Errors are caught and logged.
    .PARAMETER Action
        Script block to execute on the UI thread.
    .PARAMETER ActionName
        Human-readable name for error logging. Default: 'Unknown'.
    .EXAMPLE
        Invoke-SafeUIAction -Action { $script:ProgressBar.IsIndeterminate = $true } -ActionName 'Start Progress'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][scriptblock]$Action,
        [string]$ActionName = 'Unknown'
    )
    try {
        if ($script:Window -and $script:Window.Dispatcher.CheckAccess()) { & $Action }
        else { $script:Window.Dispatcher.Invoke([Action]{ & $Action }) }
    } catch {
        Add-LogLine -Message "$ActionName failed: $($_.Exception.Message)" -Level 'ERROR'
    }
}

function Format-FileSize {
    <#
    .SYNOPSIS
        Converts a byte count to a human-readable file size string.
    .PARAMETER Bytes
        The number of bytes to format.
    .OUTPUTS
        String. Examples: '512 B', '15.43 KB', '2.10 MB'.
    .EXAMPLE
        Format-FileSize -Bytes 1048576  # returns '1.00 MB'
    #>
    [CmdletBinding()]
    param([long]$Bytes)
    if ($Bytes -lt 1KB) { return '{0} B' -f $Bytes }
    if ($Bytes -lt 1MB) { return '{0:N2} KB' -f ($Bytes / 1KB) }
    return '{0:N2} MB' -f ($Bytes / 1MB)
}

function Set-UIState {
    <#
    .SYNOPSIS
        Toggles the UI between processing and idle states.
    .DESCRIPTION
        Enables or disables the progress bar (indeterminate mode), status label,
        status dot color, and all action buttons based on the IsProcessing flag.
    .PARAMETER IsProcessing
        If $true, shows "Compiling..." status, orange dot, indeterminate
        progress bar, and disables buttons. If $false, resets to idle.
    .EXAMPLE
        Set-UIState -IsProcessing $true   # Start processing
        Set-UIState -IsProcessing $false  # End processing
    #>
    [CmdletBinding()]
    param([bool]$IsProcessing)
    $script:isBusy = $IsProcessing
    if ($script:ProgressBar) {
        $script:ProgressBar.IsIndeterminate = $IsProcessing
        if (-not $IsProcessing) { $script:ProgressBar.Value = 0 }
    }
    if ($script:StatusLabel) {
        $script:StatusLabel.Text = if ($IsProcessing) { 'Compiling...' } else { 'Ready' }
    }
    if ($script:StatusDot) {
        try { $script:StatusDot.Fill = if ($IsProcessing) { [System.Windows.Media.Brushes]::Orange } else { [System.Windows.Media.Brushes]::LimeGreen } } catch { }
    }
    @($script:btnCompile, $script:btnSettings, $script:btnProjectFolder,
      $script:btnSrcScript, $script:btnOutPath, $script:btnIconPath,
      $script:btnClear) | ForEach-Object { if ($_) { $_.IsEnabled = -not $IsProcessing } }
}

function Show-ToastMessage {
    <#
    .SYNOPSIS
        Displays an animated toast notification in the bottom-right corner.
    .DESCRIPTION
        Creates a colored toast notification with an icon, fades it in over 200ms,
        displays it for 3 seconds, then fades it out over 300ms and removes it
        from the ToastContainer. Only works if $script:ToastContainer exists.
    .PARAMETER Message
        The notification text to display.
    .PARAMETER Type
        Toast type determining color and icon. Valid values:
          Success (green checkmark)
          Error   (red cross)
          Warning (amber triangle)
          Info    (blue circle-i, default)
    .EXAMPLE
        Show-ToastMessage -Message "Compilation complete!" -Type Success
        Show-ToastMessage -Message "File not found" -Type Error
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('Success','Error','Warning','Info')][string]$Type = 'Info'
    )
    if (-not $script:ToastContainer) { return }
    $bg = switch ($Type) {
        'Success' { '#10B981' }
        'Error'   { '#EF4444' }
        'Warning' { '#F59E0B' }
        default   { '#3B82F6' }
    }
    $icon = switch ($Type) {
        'Success' { 'M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41L9 16.17z' }
        'Error'   { 'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z' }
        'Warning' { 'M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z' }
        default   { 'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z' }
    }
    $script:Window.Dispatcher.Invoke([Action]{
        $border = New-Object System.Windows.Controls.Border
        $border.Background = New-Brush $bg
        $border.CornerRadius = [System.Windows.CornerRadius]::new(8)
        $border.Padding = [System.Windows.Thickness]::new(14, 10, 14, 10)
        $border.Margin = [System.Windows.Thickness]::new(0, 0, 0, 8)
        $border.Opacity = 0
        $border.HorizontalAlignment = 'Right'
        $stack = New-Object System.Windows.Controls.StackPanel
        $stack.Orientation = 'Horizontal'
        $path = New-Object System.Windows.Shapes.Path
        $path.Data = [System.Windows.Media.Geometry]::Parse($icon)
        $path.Fill = [System.Windows.Media.Brushes]::White
        $path.Width = 16; $path.Height = 16; $path.Stretch = 'Uniform'
        $path.Margin = [System.Windows.Thickness]::new(0, 0, 8, 0)
        $path.VerticalAlignment = 'Center'
        $text = New-Object System.Windows.Controls.TextBlock
        $text.Text = $Message; $text.Foreground = [System.Windows.Media.Brushes]::White
        $text.FontSize = 12; $text.FontWeight = [System.Windows.FontWeights]::SemiBold
        $text.VerticalAlignment = 'Center'
        $stack.Children.Add($path) | Out-Null
        $stack.Children.Add($text) | Out-Null
        $border.Child = $stack
        $script:ToastContainer.Children.Add($border) | Out-Null
        $anim = New-Object System.Windows.Media.Animation.DoubleAnimation
        $anim.From = 0; $anim.To = 1
        $anim.Duration = [System.Windows.Duration]::new([TimeSpan]::FromMilliseconds(200))
        $border.BeginAnimation([System.Windows.UIElement]::OpacityProperty, $anim)
        $timer = New-Object System.Windows.Threading.DispatcherTimer
        $timer.Interval = [TimeSpan]::FromSeconds(3)
        $timer.Tag = $border
        $timer.Add_Tick({
            $t = $this; $t.IsEnabled = $false; $b = $t.Tag
            if (-not $b) { return }
            $fo = New-Object System.Windows.Media.Animation.DoubleAnimation
            $fo.From = 1; $fo.To = 0
            $fo.Duration = [System.Windows.Duration]::new([TimeSpan]::FromMilliseconds(300))
            $fo.Add_Completed({ $script:ToastContainer.Children.Remove($b) })
            $b.BeginAnimation([System.Windows.UIElement]::OpacityProperty, $fo)
        })
        $timer.Start()
    }, [System.Windows.Threading.DispatcherPriority]::Normal)
}
