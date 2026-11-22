<#
.TITLE
    PSWrap Log Viewer Module

.SYNOPSIS
    Sub-window for viewing, copying, and clearing in-memory log entries.

.DESCRIPTION
    Provides a sub-window for viewing, copying, and clearing in-memory log entries.
    Entries are color-coded by severity level and displayed in a RichTextBox
    with monospace font on a dark background.

.TAGS
    LogViewer,Diagnostics,UI,Debug

.MINROLE
    Reader

.PERMISSIONS
    N/A — reads in-memory log buffer only

.AUTHOR
    admin

.VERSION
    1.0.0

.CHANGELOG
    1.0.0 - Initial release

.LASTUPDATE
    2026-06-17

.EXAMPLE
    Show-LogViewer
    Opens the log viewer dialog window.

.NOTES
    The log viewer is a self-contained XAML window rendered via XamlReader.
    It reads from the $script:LogEntries collection maintained by Logging.ps1.
#>

$logViewerXaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Activity Log" Width="900" Height="600"
        MinWidth="600" MinHeight="400"
        WindowStartupLocation="CenterOwner" Background="{DynamicResource BackgroundBrush}"
        FontFamily="Segoe UI Variable Text, Segoe UI Variable Display, Segoe UI" FontSize="13"
        TextOptions.TextRenderingMode="ClearType"
        UseLayoutRounding="True" SnapsToDevicePixels="True">
    <Window.Resources>
        <Style x:Key="BtnBase" TargetType="{x:Type Button}">
            <Setter Property="BorderThickness" Value="0"/><Setter Property="Cursor" Value="Hand"/><Setter Property="FontWeight" Value="SemiBold"/><Setter Property="Padding" Value="16,0"/><Setter Property="Height" Value="38"/><Setter Property="MinWidth" Value="100"/>
            <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="{x:Type Button}"><Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="8" SnapsToDevicePixels="True"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" Margin="{TemplateBinding Padding}"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="border" Property="UIElement.Opacity" Value="0.85"/></Trigger><Trigger Property="IsPressed" Value="True"><Setter TargetName="border" Property="UIElement.Opacity" Value="0.7"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Setter.Value></Setter>
        </Style>
        <Style x:Key="BtnPrimary" TargetType="{x:Type Button}" BasedOn="{StaticResource BtnBase}"><Setter Property="Background" Value="{DynamicResource AccentBrush}"/><Setter Property="Foreground" Value="White"/><Setter Property="Padding" Value="16,0"/><Setter Property="BorderThickness" Value="0"/></Style>
        <Style x:Key="BtnOutline" TargetType="{x:Type Button}" BasedOn="{StaticResource BtnBase}"><Setter Property="Background" Value="Transparent"/><Setter Property="Foreground" Value="{DynamicResource TextBodyBrush}"/><Setter Property="BorderBrush" Value="{DynamicResource BorderBrush}"/><Setter Property="BorderThickness" Value="1"/><Setter Property="Template"><Setter.Value><ControlTemplate TargetType="{x:Type Button}"><Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="8"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="border" Property="Background" Value="{DynamicResource SurfaceHoverBrush}"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Setter.Value></Setter></Style>
    </Window.Resources>
    <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
        <Border Grid.Row="0" Background="{DynamicResource SurfaceBrush}" BorderBrush="{DynamicResource BorderBrush}" BorderThickness="0,0,0,1" Padding="16,12">
            <Grid><StackPanel><TextBlock x:Name="LogTitle" Text="Activity Log" FontSize="20" FontWeight="SemiBold" Foreground="{DynamicResource TextPrimaryBrush}" FontFamily="Segoe UI"/><TextBlock x:Name="LogCountText" Text="0 entries" FontSize="13" Foreground="{DynamicResource TextSecondaryBrush}" FontWeight="SemiBold" Margin="0,2,0,0"/></StackPanel>
                <WrapPanel HorizontalAlignment="Right" VerticalAlignment="Center">
                    <Button x:Name="CopyLogBtn" Style="{StaticResource BtnOutline}" Height="30" FontSize="13" Padding="10,0" Margin="0,0,6,4" ToolTip="Copy all log entries to clipboard"><StackPanel Orientation="Horizontal"><Path Stretch="Uniform" Width="12" Height="12" Fill="{Binding Foreground, RelativeSource={RelativeSource AncestorType=Button}}" Data="M16 1H4c-1.1 0-2 .9-2 2v14h2V3h12V1zm3 4H8c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h11c1.1 0 2-.9 2-2V7c0-1.1-.9-2-2-2zm0 16H8V7h11v14z" Margin="0,0,6,0" VerticalAlignment="Center"/><TextBlock Text="Copy" VerticalAlignment="Center"/></StackPanel></Button>
                    <Button x:Name="ClearLogBtn" Style="{StaticResource BtnOutline}" Height="30" FontSize="13" Padding="10,0" Margin="0,0,6,4" ToolTip="Clear all log entries"><StackPanel Orientation="Horizontal"><Path Stretch="Uniform" Width="12" Height="12" Fill="{Binding Foreground, RelativeSource={RelativeSource AncestorType=Button}}" Data="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z" Margin="0,0,6,0" VerticalAlignment="Center"/><TextBlock Text="Clear" VerticalAlignment="Center"/></StackPanel></Button>
                </WrapPanel>
            </Grid>
        </Border>
        <RichTextBox x:Name="LogContent" Grid.Row="1" Background="#1E293B" Foreground="#F8FAFC" BorderThickness="0" FontFamily="Cascadia Code, Consolas, Courier New" FontSize="12" IsReadOnly="True" VerticalScrollBarVisibility="Auto" Padding="16,12" Margin="0,0,0,0"/>
        <Border Grid.Row="2" Background="{DynamicResource SurfaceBrush}" BorderBrush="{DynamicResource BorderBrush}" BorderThickness="0,1,0,0" Padding="16,8"><TextBlock x:Name="FooterText" Text="Real-time log viewer" FontSize="12" Foreground="{DynamicResource TextSecondaryBrush}" FontWeight="SemiBold"/></Border>
    </Grid>
</Window>
'@

function Show-LogViewer {
<#
.SYNOPSIS
    Opens the Activity Log viewer sub-window.

.DESCRIPTION
    Renders a XAML sub-window containing a RichTextBox that displays in-memory log
    entries color-coded by severity level. Includes Copy and Clear buttons for
    clipboard export and log buffer reset.

.NOTES
    Resource dictionaries from the main window are cloned into the Log Viewer
    window to inherit theme-aware brushes (DynamicResource resolution). Log entries
    are rendered into the RichTextBox content model using FlowDocument Paragraphs
    and Run elements. Clipboard export uses [System.Windows.Clipboard]::SetText
    with a PowerShell Set-Clipboard fallback.
#>
    try {
        $clean = $logViewerXaml -replace '[\uFEFF\u200B\u200C\u200D\u200E\u200F\u202A-\u202E]', ''
        $reader = [System.Xml.XmlNodeReader]::new(([xml]$clean))
        $logWindow = [System.Windows.Markup.XamlReader]::Load($reader); $reader.Close()
        $logContent = $logWindow.FindName('LogContent'); $logCountText = $logWindow.FindName('LogCountText')
        $copyLogBtn = $logWindow.FindName('CopyLogBtn'); $clearLogBtn = $logWindow.FindName('ClearLogBtn')
        $logWindow.Owner = $script:Window
        $script:Window.Resources.Keys | ForEach-Object { $logWindow.Resources[$_] = $script:Window.Resources[$_] }
        $brushConv = New-Object System.Windows.Media.BrushConverter
        function Update-LogContent {
            try {
                $logContent.Document.Blocks.Clear()
                foreach ($entry in $script:LogEntries) {
                    $para = New-Object System.Windows.Documents.Paragraph; $para.Margin = New-Object System.Windows.Thickness(0,0,0,4)
                    $run1 = New-Object System.Windows.Documents.Run("[{0}] [{1}] " -f $entry.Timestamp, $entry.Level)
                    $run1.Foreground = $brushConv.ConvertFromString($entry.Color); $run1.FontWeight = 'SemiBold'
                    $run2 = New-Object System.Windows.Documents.Run($entry.Message); $run2.Foreground = $brushConv.ConvertFromString('#F8FAFC')
                    [void]$para.Inlines.Add($run1); [void]$para.Inlines.Add($run2); [void]$logContent.Document.Blocks.Add($para)
                }
                $logContent.ScrollToEnd(); $logCountText.Text = "{0} entries" -f $script:LogEntries.Count
            } catch { $logCountText.Text = "Error loading entries" }
        }
        Update-LogContent
        $copyLogBtn.Add_Click({
            try {
                $sb = New-Object System.Text.StringBuilder
                foreach ($entry in $script:LogEntries) { $sb.Append('[').Append($entry.Counter).Append('] [').Append($entry.Timestamp).Append('] [').Append($entry.Level).Append('] ').AppendLine($entry.Message) | Out-Null }
                $text = $sb.ToString()
                try { [System.Windows.Clipboard]::SetText($text) } catch { try { $text | Set-Clipboard } catch { } }
                Add-LogLine -Message "Log entries copied to clipboard." -Level 'INFO'
            } catch { Add-LogLine -Message "Failed to copy to clipboard: $($_.Exception.Message)" -Level 'ERROR'; [System.Windows.MessageBox]::Show("Could not copy log entries to clipboard.`n`n$($_.Exception.ToString())", "Copy Failed", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning) | Out-Null }
        }) | Out-Null
        $clearLogBtn.Add_Click({ $script:LogEntries.Clear(); $logContent.Document.Blocks.Clear(); $logCountText.Text = "0 entries"; Add-LogLine -Message "Activity log cleared." -Level 'INFO' }) | Out-Null
        $logWindow.Add_Closing({ try { $logWindow.Owner = $null } catch { } }) | Out-Null
        [void]$logWindow.ShowDialog()
    } catch { Add-LogLine -Message ("Failed to open Log Viewer: {0}" -f $_.Exception.Message) -Level 'ERROR' }
}
