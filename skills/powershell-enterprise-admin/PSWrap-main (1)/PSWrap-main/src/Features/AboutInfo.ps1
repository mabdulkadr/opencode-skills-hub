<#
.TITLE
    PSWrap About / Documentation Dialog

.SYNOPSIS
    Markdown-to-WPF dialog displaying ABOUT.md and USER-GUIDE.md.

.DESCRIPTION
    Renders a markdown-to-WPF dialog window that displays documentation from
    ABOUT.md and USER-GUIDE.md with tab navigation, syntax-highlighted code
    blocks, tables, lists, blockquotes, and heading icons.

.TAGS
    About,Documentation,Help,Markdown,Renderer

.MINROLE
    Reader

.PERMISSIONS
    N/A — reads local markdown files only

.AUTHOR
    admin

.VERSION
    1.0.0

.CHANGELOG
    1.0.0 - Initial release

.LASTUPDATE
    2026-06-17

.EXAMPLE
    Show-AboutDialog
    Opens the About dialog with tabbed documentation.

.NOTES
    - Supports full markdown rendering including bold, inline code, links,
      tables, code blocks, blockquotes, headings, lists, and separators
    - Uses a file content cache ($script:aboutLineCache) for performance
    - DynamicResource brushes are inherited from the main window
#>

$script:aboutLineCache = @{}

function Show-AboutDialog {
<#
.SYNOPSIS
    Opens the About / Documentation dialog with tabbed markdown content.

.DESCRIPTION
    Renders a XAML dialog window that loads ABOUT.md and USER-GUIDE.md from the
    docs directory and converts markdown to styled WPF controls with syntax-
    highlighted code blocks, tables, blockquotes, lists, headings with icons,
    and inline formatting.

.NOTES
    Markdown rendering is performed by the ConvertFrom-MarkdownToUI function via
    a state-machine parser. File contents are cached in $script:aboutLineCache to
    avoid repeated disk reads on tab switches. DynamicResource brushes and styles
    from the main window are inherited by the About dialog for theme consistency.
#>
    try {
        $docsDir = Join-Path $script:RootDir 'docs'
        $tabs = @(
            @{ Name = 'About';      File = 'ABOUT.md';      Icon = 'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z' }
            @{ Name = 'User Guide'; File = 'USER-GUIDE.md'; Icon = 'M8 5v14l11-7z' }
        )
        $xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="About PSWrap" Width="780" Height="680"
        MinWidth="640" MinHeight="520"
        WindowStartupLocation="CenterOwner"
        Background="{DynamicResource BackgroundBrush}"
        FontFamily="Segoe UI Variable Text, Segoe UI Variable Display, Segoe UI" FontSize="13"
        TextOptions.TextRenderingMode="ClearType"
        UseLayoutRounding="True" SnapsToDevicePixels="True">
    <Window.Resources>
        <Style x:Key="BtnBase" TargetType="{x:Type Button}">
            <Setter Property="BorderThickness" Value="0"/><Setter Property="Cursor" Value="Hand"/><Setter Property="FontWeight" Value="SemiBold"/><Setter Property="Height" Value="36"/><Setter Property="MinWidth" Value="90"/>
            <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="{x:Type Button}"><Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="8"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" Margin="{TemplateBinding Padding}"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="border" Property="UIElement.Opacity" Value="0.85"/></Trigger><Trigger Property="IsPressed" Value="True"><Setter TargetName="border" Property="UIElement.Opacity" Value="0.7"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Setter.Value></Setter>
        </Style>
        <Style x:Key="BtnPrimary" TargetType="{x:Type Button}" BasedOn="{StaticResource BtnBase}"><Setter Property="Background" Value="{DynamicResource AccentBrush}"/><Setter Property="Foreground" Value="White"/><Setter Property="Padding" Value="24,0"/></Style>
        <Style x:Key="TabBtn" TargetType="{x:Type Button}">
            <Setter Property="Height" Value="34"/><Setter Property="Cursor" Value="Hand"/><Setter Property="FontSize" Value="13"/><Setter Property="FontWeight" Value="SemiBold"/><Setter Property="Padding" Value="14,0"/><Setter Property="Margin" Value="0,8,6,8"/>
            <Setter Property="Background" Value="{DynamicResource SurfaceHoverBrush}"/><Setter Property="Foreground" Value="{DynamicResource TextSecondaryBrush}"/><Setter Property="BorderBrush" Value="{DynamicResource BorderBrush}"/><Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="{x:Type Button}"><Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="8"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" Margin="{TemplateBinding Padding}"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="border" Property="Background" Value="{DynamicResource SurfaceHoverBrush}"/></Trigger><Trigger Property="IsPressed" Value="True"><Setter TargetName="border" Property="Opacity" Value="0.8"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Setter.Value></Setter>
        </Style>
    </Window.Resources>
    <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
        <Border Grid.Row="0" Background="{DynamicResource SurfaceBrush}" BorderBrush="{DynamicResource BorderBrush}" BorderThickness="0,0,0,1" Padding="28,16">
            <Grid><StackPanel Orientation="Horizontal">
                <Border Width="48" Height="48" CornerRadius="14"><Border.Background><LinearGradientBrush StartPoint="0,0" EndPoint="1,1"><GradientStop Color="#3B82F6" Offset="0"/><GradientStop Color="#8B5CF6" Offset="0.6"/><GradientStop Color="#EC4899" Offset="1"/></LinearGradientBrush></Border.Background>
                <Border.Effect><DropShadowEffect BlurRadius="14" ShadowDepth="3" Color="#3B82F6" Opacity="0.3" Direction="270"/></Border.Effect>
                <Path Stretch="Uniform" Width="24" Height="24" Fill="White" HorizontalAlignment="Center" VerticalAlignment="Center" Data="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 9h-2V7h-2v5H6v2h2v5h2v-5h2v-2zm4 4h-2v-5h2v5zm0-7h-2V7h2v2z"/></Border>
                <StackPanel Margin="16,0,0,0" VerticalAlignment="Center"><TextBlock x:Name="AboutTitle" Text="PSWrap" FontSize="24" FontWeight="SemiBold" Foreground="{DynamicResource TextPrimaryBrush}" FontFamily="Segoe UI"/><TextBlock x:Name="AboutSubtitle" Text="v2.0.0  &#8226;  Documentation &amp; Reference" FontSize="12" Foreground="{DynamicResource TextSecondaryBrush}" FontWeight="SemiBold" Margin="0,8,0,0"/></StackPanel>
            </StackPanel></Grid>
        </Border>
        <ScrollViewer Grid.Row="1" x:Name="TabScrollViewer" VerticalScrollBarVisibility="Disabled" HorizontalScrollBarVisibility="Auto" Background="{DynamicResource SurfaceBrush}" Padding="24,0,24,0" BorderBrush="{DynamicResource BorderBrush}" BorderThickness="0,0,0,1">
            <StackPanel x:Name="TabBar" Orientation="Horizontal" Margin="0,0,0,0"/>
        </ScrollViewer>
        <ScrollViewer Grid.Row="2" x:Name="ContentScrollViewer" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled" Padding="28,16,28,12" Background="{DynamicResource BackgroundBrush}">
            <StackPanel x:Name="ContentPanel"/>
        </ScrollViewer>
        <Border Grid.Row="3" Background="{DynamicResource SurfaceBrush}" BorderBrush="{DynamicResource BorderBrush}" BorderThickness="0,1,0,0" Padding="16,10">
            <Button x:Name="CloseAboutBtn" Style="{StaticResource BtnPrimary}" HorizontalAlignment="Right" ToolTip="Close about dialog"><StackPanel Orientation="Horizontal"><Path Stretch="Uniform" Width="14" Height="14" Fill="White" Data="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z" Margin="0,0,6,0" VerticalAlignment="Center"/><TextBlock Text="Close" VerticalAlignment="Center"/></StackPanel></Button>
        </Border>
    </Grid>
</Window>
'@
        $clean = $xaml -replace '[\uFEFF\u200B\u200C\u200D\u200E\u200F\u202A-\u202E]', ''
        $reader = [System.Xml.XmlNodeReader]::new(([xml]$clean))
        $aboutWindow = [System.Windows.Markup.XamlReader]::Load($reader); $reader.Close()
        $tabBar = $aboutWindow.FindName('TabBar'); $contentPanel = $aboutWindow.FindName('ContentPanel')
        $contentScroll = $aboutWindow.FindName('ContentScrollViewer'); $closeBtn = $aboutWindow.FindName('CloseAboutBtn')
        $aboutSubtitle = $aboutWindow.FindName('AboutSubtitle')
        if ($aboutSubtitle) { $aboutSubtitle.Text = "v$script:AppVersion  &#8226;  Documentation & Reference" }
        $aboutWindow.Owner = $script:Window
        $script:Window.Resources.Keys | ForEach-Object { $aboutWindow.Resources[$_] = $script:Window.Resources[$_] }
        $brushConv = New-Object System.Windows.Media.BrushConverter; $thick = [System.Windows.Thickness]; $res = $aboutWindow.Resources
        $script:activeTabBtn = $null

        function ConvertFrom-MarkdownToUI {
            param([string[]]$Lines, [System.Windows.Controls.StackPanel]$TargetPanel)
            # State-machine markdown parser supporting headings, code blocks, tables, blockquotes, and inline formatting
            $inCodeBlock = $false; $codeContent = ''; $inTable = $false; $tableRows = @(); $inBlockquote = $false; $blockquoteContent = @()
            # Map heading text to SVG Material Design icons using regex matching
            $headingIcons = @{
                'overview'='M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5'; 'feature|capabilit'='M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z'
                'architectur|structure'='M9.4 16.6L4.8 12l4.6-4.6L8 6l-6 6 6 6 1.4-1.4zm5.2 0l4.6-4.6-4.6-4.6L16 6l6 6-6 6-1.4-1.4z'; 'function|api|reference'='M14.6 16.6l4.6-4.6-4.6-4.6L16 6l6 6-6 6-1.4-1.4zM9.4 7.4L4.8 12l4.6 4.6L8 18l-6-6 6-6 1.4 1.4zm3.3-3.3l2 12-2.7.6-2-12 2.7-.6z'
                'color|palette|design'='M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 17.93c-3.95-.49-7-3.85-7-7.93 0-.62.08-1.21.21-1.79L9 15v1c0 1.1.9 2 2 2v1.93zm6.9-2.54c-.26-.81-1-1.39-1.9-1.39h-1v-3c0-.55-.45-1-1-1H8v-2h2c.55 0 1-.45 1-1V7h2c1.1 0 2-.9 2-2v-.41c2.93 1.19 5 4.06 5 7.41 0 2.08-.8 3.97-2.1 5.39z'
                'usage|how to|guide|quick start'='M8 5v14l11-7z'; 'data|flow'='M21 2H3c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h7v2H8v2h8v-2h-2v-2h7c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm0 14H3V4h18v12z'
                'compile|build|exe'='M8 5v14l11-7z'; 'theme|dark|light'='M20.21 15.32A8.956 8.956 0 0112 21c-4.97 0-9-4.03-9-9 0-4.97 4.03-9 9-9 1.21 0 2.36.24 3.42.67-2.23 1.72-3.67 4.38-3.67 7.42 0 3.04 1.44 5.7 3.67 7.42a8.956 8.956 0 01-1.21.81z'
                'author|about'='M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z'
            }
            function Get-ItemIcon { param([string]$Heading) $lower=$Heading.ToLower().Trim(); foreach($key in $headingIcons.Keys){$p=$key -split '\|'; foreach($x in $p){if($lower -match $x){return $headingIcons[$key]}}}; return 'M12 6v3l4-4-4-4v3c-4.42 0-8 3.58-8 8 0 1.57.46 3.03 1.24 4.26L6.7 14.8c-.45-.83-.7-1.79-.7-2.8 0-3.31 2.69-6 6-6zm6.76 1.74L17.3 9.2c.44.84.7 1.79.7 2.8 0 3.31-2.69 6-6 6v-3l-4 4 4 4v-3c4.42 0 8-3.58 8-8 0-1.57-.46-3.03-1.24-4.26z' }
            function Add-InlineTextBlock { param([string]$Text, [System.Windows.Controls.StackPanel]$Panel)
                $tb=New-Object System.Windows.Controls.TextBlock; $tb.TextWrapping='Wrap'; $tb.Foreground=$res['BodyFg']; $tb.FontSize=13.5; $tb.LineHeight=24; $tb.LineStackingStrategy='BlockLineHeight'; $tb.Margin=New-Object $thick(0,0,0,6)
                $parts=$Text -split '(\*\*.+?\*\*|`[^`]+`|!?\[[^\]]*\]\([^)]*\))'
                foreach($p in $parts){if($p -match '^\*\*(.+)\*\*$'){$b=New-Object System.Windows.Documents.Bold;$r=New-Object System.Windows.Documents.Run($matches[1]);[void]$b.Inlines.Add($r);[void]$tb.Inlines.Add($b)} elseif($p -match '^`(.+)`$'){$r=New-Object System.Windows.Documents.Run($matches[1]);$r.FontFamily=New-Object System.Windows.Media.FontFamily('Consolas');$r.FontSize=12;$r.Background=$res['CodeBg'];$r.Foreground=$res['CodeFg'];[void]$tb.Inlines.Add($r)} elseif($p -match '^\[([^\]]*)\]\(([^)]*)\)$'){$r=New-Object System.Windows.Documents.Run($matches[1]);$r.Foreground=$res['LinkFg'];$r.TextDecorations='Underline';[void]$tb.Inlines.Add($r)} elseif($p -match '^!\[([^\]]*)\]\([^)]*\)$'){if($matches[1]){$r=New-Object System.Windows.Documents.Run(("[{0}]"-f$matches[1]));$r.Foreground=$res['TextMutedBrush'];$r.FontStyle='Italic';[void]$tb.Inlines.Add($r)}} else{[void]$tb.Inlines.Add((New-Object System.Windows.Documents.Run($p)))}}
                [void]$Panel.Children.Add($tb)
            }
            foreach ($line in $Lines) {
                if ($line -match '^```') { $inCodeBlock = -not $inCodeBlock
                    if (-not $inCodeBlock) {
                        $outer=New-Object System.Windows.Controls.Border; $outer.Background=$res['CodeBlockBg']; $outer.CornerRadius=New-Object System.Windows.CornerRadius(10); $outer.Padding=New-Object $thick(16,12,16,12); $outer.Margin=New-Object $thick(0,0,0,12)
                        $is=New-Object System.Windows.Controls.StackPanel; $dr=New-Object System.Windows.Controls.StackPanel; $dr.Orientation='Horizontal'; $dr.Margin=New-Object $thick(4,2,0,8)
                        foreach($c in '#EF4444','#F59E0B','#10B981'){$d=New-Object System.Windows.Controls.Border;$d.Width=8;$d.Height=8;$d.CornerRadius=New-Object System.Windows.CornerRadius(4);$d.Background=$brushConv.ConvertFromString($c);$d.Margin=New-Object $thick(0,0,6,0);[void]$dr.Children.Add($d)}
                        [void]$is.Children.Add($dr); $sc=New-Object System.Windows.Controls.ScrollViewer; $sc.HorizontalScrollBarVisibility='Auto'; $sc.VerticalScrollBarVisibility='Disabled'; $sc.MaxHeight=220
                        $tb=New-Object System.Windows.Controls.TextBlock; $tb.Text=$codeContent.TrimEnd(); $tb.FontFamily=New-Object System.Windows.Media.FontFamily('Consolas, Courier New'); $tb.FontSize=12; $tb.Foreground=$res['CodeBlockFg']; $tb.TextWrapping='NoWrap'
                        $sc.Content=$tb; [void]$is.Children.Add($sc); $outer.Child=$is; [void]$TargetPanel.Children.Add($outer); $codeContent=''
                    } continue
                }
                if ($inCodeBlock) { $codeContent += $line + "`n"; continue }
                if ($line -match '^\|.*\|$' -and $line -notmatch '^\|[-: ]+\|') {
                    if (-not $inTable) { $inTable=$true; $tableRows=@() }
                    $p=$line -split '\|' | ForEach-Object {$_.Trim()}; if($p.Count -ge 2 -and $p[0]-eq''-and$p[-1]-eq''){$p=$p[1..($p.Count-2)]}; $tableRows+= ,$p; continue
                }
                if ($line -match '^\|[-: ]+\|') { continue }
                if ($inTable -and -not ($line -match '^\|.*\|$')) {
                    # Build WPF Grid with alternating row colors, header styling, and row selection
                    if ($tableRows.Count -gt 0) {
                        $cc=($tableRows|%{$_.Count}|Measure-Object -Maximum).Maximum
                        $ob=New-Object System.Windows.Controls.Border; $ob.BorderBrush=$res['TableBorder']; $ob.BorderThickness=New-Object $thick(1,1,1,1); $ob.CornerRadius=New-Object System.Windows.CornerRadius(8); $ob.Margin=New-Object $thick(0,0,0,14); $ob.Background=$res['TableBg']
                        $g=New-Object System.Windows.Controls.Grid; for($i=0;$i-lt$cc;$i++){$c=New-Object System.Windows.Controls.ColumnDefinition;$c.Width=New-Object System.Windows.GridLength(1,'Star');[void]$g.ColumnDefinitions.Add($c)}
                        $ri=0; $alt=$res['TableAltBg']; $wh=$res['TableBg']; $hb=$res['TableHeaderBg']; $bc=$res['TableBorder']; $ac=$res['AccentBrush']; $at=$res['AccentTintBrush']; $ls=$null; $bl=$null; $br=$null; $hv=New-Object System.Windows.Media.SolidColorBrush(([System.Windows.Media.Color]::FromArgb(35,255,255,255)))
                        foreach($row in $tableRows){$ih=($ri -eq 0); $rd=New-Object System.Windows.Controls.RowDefinition;$rd.Height=New-Object System.Windows.GridLength(1,'Auto');[void]$g.RowDefinitions.Add($rd)
                            for($i=0;$i-lt$cc;$i++){$ct=if($i-lt$row.Count){$row[$i]}else{''}; $cell=New-Object System.Windows.Controls.TextBlock; $cell.FontSize=if($ih){12.5}else{12}; $cell.FontWeight=if($ih){'SemiBold'}else{'Normal'}; $cell.Foreground=if($ih){$res['HeadingFg']}else{$res['BodyFg']}; $cell.Padding=New-Object $thick(10,7,10,7); $cell.TextWrapping='Wrap'; $cell.VerticalAlignment='Center'
                                $parts=$ct -split '(\*\*.+?\*\*|`[^`]+`)'; foreach($p in $parts){if($p-match'^\*\*(.+)\*\*$'){$b=New-Object System.Windows.Documents.Bold;$r=New-Object System.Windows.Documents.Run($matches[1]);[void]$b.Inlines.Add($r);[void]$cell.Inlines.Add($b)}elseif($p-match'^`(.+)`$'){$r=New-Object System.Windows.Documents.Run($matches[1]);$r.FontFamily=New-Object System.Windows.Media.FontFamily('Consolas');$r.FontSize=12;$r.Background=$res['CodeBg'];$r.Foreground=$res['CodeFg'];[void]$cell.Inlines.Add($r)}else{[void]$cell.Inlines.Add((New-Object System.Windows.Documents.Run($p)))}}
                                $cb=New-Object System.Windows.Controls.Border; $cb.Child=$cell; $cb.BorderBrush=$bc; $cb.BorderThickness=New-Object $thick(0,0,1,1); $cb.Cursor='Hand'
                                if($ih){$cb.Background=$hb}elseif($ri%2-eq0){$cb.Background=$alt}else{$cb.Background=$wh}
                                $cb.Tag=$cb.Background
                                if($ri-eq0-and$i-eq0){$cb.CornerRadius=New-Object System.Windows.CornerRadius(7,0,0,0)}elseif($ri-eq0-and$i-eq$cc-1){$cb.CornerRadius=New-Object System.Windows.CornerRadius(0,7,0,0)}elseif($ri-eq$tableRows.Count-1-and$i-eq0){$bl=$cb}elseif($ri-eq$tableRows.Count-1-and$i-eq$cc-1){$br=$cb}
                                $cb.Add_MouseEnter({if($ls-ne$this){$this.Background=$hv}}); $cb.Add_MouseLeave({if($ls-ne$this){$this.Background=$this.Tag}}); $cb.Add_MouseLeftButtonDown({if($ls-and$ls-ne$this){$ls.Background=$ls.Tag;$ls.BorderBrush=$bc}; if($ls-eq$this){$this.Background=$this.Tag;$this.BorderBrush=$bc;$ls=$null}else{$this.Background=$at;$this.BorderBrush=$ac;$ls=$this}})
                                [System.Windows.Controls.Grid]::SetColumn($cb,$i); [System.Windows.Controls.Grid]::SetRow($cb,$ri); [void]$g.Children.Add($cb)
                            } $ri++
                        } if($bl){$bl.CornerRadius=New-Object System.Windows.CornerRadius(0,0,0,7)}; if($br){$br.CornerRadius=New-Object System.Windows.CornerRadius(0,0,7,0)}; $ob.Child=$g; [void]$TargetPanel.Children.Add($ob); $tableRows=@(); $inTable=$false
                    } $inTable=$false
                }
                if ($line -match '^---+\s*$'){$s=New-Object System.Windows.Controls.Border;$s.Height=1;$s.Background=$res['SeparatorBg'];$s.Margin=New-Object $thick(0,12,0,16);[void]$TargetPanel.Children.Add($s); continue}
                if ($line -match '^#### (.+)'){$h4=$matches[1]-replace '`([^`]+)`','$1';$w=New-Object System.Windows.Controls.WrapPanel;$w.Margin=New-Object $thick(0,10,0,2);$tb=New-Object System.Windows.Controls.TextBlock;$tb.Text=$h4;$tb.FontSize=13.5;$tb.FontWeight='SemiBold';$tb.Foreground=$res['H4Fg'];$tb.VerticalAlignment='Center';[void]$w.Children.Add($tb);[void]$TargetPanel.Children.Add($w); continue}
                if ($line -match '^### (.+)'){$h3=$matches[1]-replace '`([^`]+)`','$1';$w=New-Object System.Windows.Controls.WrapPanel;$w.Margin=New-Object $thick(0,12,0,4);$ib=New-Object System.Windows.Controls.Border;$ib.Width=22;$ib.Height=22;$ib.Background=$res['CodeBg'];$ib.CornerRadius=New-Object System.Windows.CornerRadius(5);$ib.Margin=New-Object $thick(0,0,8,0);$ip=New-Object System.Windows.Shapes.Path;$ip.Stretch='Uniform';$ip.Width=12;$ip.Height=12;$ip.Fill=$res['IconFg'];$ip.Data=[System.Windows.Media.Geometry]::Parse((Get-ItemIcon -Heading $h3));$ip.HorizontalAlignment='Center';$ip.VerticalAlignment='Center';$ib.Child=$ip;$tb=New-Object System.Windows.Controls.TextBlock;$tb.Text=$h3;$tb.FontSize=14.5;$tb.FontWeight='SemiBold';$tb.Foreground=$res['HeadingFg'];$tb.VerticalAlignment='Center';[void]$w.Children.Add($ib);[void]$w.Children.Add($tb);[void]$TargetPanel.Children.Add($w); continue}
                if ($line -match '^## (.+)'){$h2=$matches[1]-replace '`([^`]+)`','$1';$o=New-Object System.Windows.Controls.StackPanel;$o.Margin=New-Object $thick(0,16,0,0);$w=New-Object System.Windows.Controls.WrapPanel;$w.Margin=New-Object $thick(0,0,0,6);$ib=New-Object System.Windows.Controls.Border;$ib.Width=26;$ib.Height=26;$ib.Background=$res['IconBg'];$ib.CornerRadius=New-Object System.Windows.CornerRadius(7);$ib.Margin=New-Object $thick(0,0,10,0);$ip=New-Object System.Windows.Shapes.Path;$ip.Stretch='Uniform';$ip.Width=14;$ip.Height=14;$ip.Fill=$res['IconFg'];$ip.Data=[System.Windows.Media.Geometry]::Parse((Get-ItemIcon -Heading $h2));$ip.HorizontalAlignment='Center';$ip.VerticalAlignment='Center';$ib.Child=$ip;$tb=New-Object System.Windows.Controls.TextBlock;$tb.Text=$h2;$tb.FontSize=17;$tb.FontWeight='SemiBold';$tb.Foreground=$res['HeadingFg'];$tb.FontFamily=New-Object System.Windows.Media.FontFamily('Segoe UI');$tb.VerticalAlignment='Center';[void]$w.Children.Add($ib);[void]$w.Children.Add($tb);[void]$o.Children.Add($w);$ul=New-Object System.Windows.Shapes.Rectangle;$ul.Height=4;$ul.Width=44;$ul.Fill=$res['UnderlineFg'];$ul.Margin=New-Object $thick(2,0,0,4);$ul.HorizontalAlignment='Left';[void]$o.Children.Add($ul);[void]$TargetPanel.Children.Add($o); continue}
                if ($line -match '^# (.+)'){$h1=$matches[1]-replace '`([^`]+)`','$1';$w=New-Object System.Windows.Controls.WrapPanel;$w.Margin=New-Object $thick(0,8,0,6);$tb=New-Object System.Windows.Controls.TextBlock;$tb.Text=$h1;$tb.FontSize=22;$tb.FontWeight='SemiBold';$tb.Foreground=$res['HeadingFg'];$tb.FontFamily=New-Object System.Windows.Media.FontFamily('Segoe UI');$tb.VerticalAlignment='Center';[void]$w.Children.Add($tb);[void]$TargetPanel.Children.Add($w); continue}
                if ($line -match '^> (.+)'){$qt=$matches[1];$bq=New-Object System.Windows.Controls.Border;$bq.Background=$res['BlockquoteBg'];$bq.BorderBrush=$res['LinkFg'];$bq.BorderThickness=New-Object $thick(4,0,0,0);$bq.CornerRadius=New-Object System.Windows.CornerRadius(4);$bq.Padding=New-Object $thick(16,10,16,10);$bq.Margin=New-Object $thick(0,0,0,8);$it=New-Object System.Windows.Controls.TextBlock;$it.TextWrapping='Wrap';$it.Foreground=$res['BlockquoteFg'];$it.FontSize=13;$it.FontStyle='Italic';$it.LineHeight=22;$it.LineStackingStrategy='BlockLineHeight'
                    $parts=$qt -split '(\*\*.+?\*\*|`[^`]+`)'; foreach($p in $parts){if($p-match'^\*\*(.+)\*\*$'){$b=New-Object System.Windows.Documents.Bold;$r=New-Object System.Windows.Documents.Run($matches[1]);$r.Foreground=$res['BlockquoteFg'];[void]$b.Inlines.Add($r);[void]$it.Inlines.Add($b)}elseif($p-match'^`(.+)`$'){$r=New-Object System.Windows.Documents.Run($matches[1]);$r.FontFamily=New-Object System.Windows.Media.FontFamily('Consolas');$r.FontSize=12;$r.Background=$res['CodeBg'];$r.Foreground=$res['CodeFg'];[void]$it.Inlines.Add($r)}else{$r=New-Object System.Windows.Documents.Run($p);$r.Foreground=$res['BlockquoteFg'];[void]$it.Inlines.Add($r)}}
                    $bq.Child=$it; [void]$TargetPanel.Children.Add($bq); continue
                }
                if ([string]::IsNullOrWhiteSpace($line)){$sp=New-Object System.Windows.Controls.Border;$sp.Height=6;[void]$TargetPanel.Children.Add($sp); continue}
                if ($line -match '^(\s*)([-*+]) (.+)'){$ind=$matches[1].Length;$it=$matches[3];$w=New-Object System.Windows.Controls.WrapPanel;$w.Margin=New-Object $thick((4+$ind*12),2,0,2);$d=New-Object System.Windows.Controls.Border;$d.Width=6;$d.Height=6;$d.CornerRadius=New-Object System.Windows.CornerRadius(3);$d.Background=$res['BulletFg'];$d.Margin=New-Object $thick(0,8,10,0);$d.VerticalAlignment='Top';$tb=New-Object System.Windows.Controls.TextBlock;$tb.TextWrapping='Wrap';$tb.Foreground=$res['BodyFg'];$tb.FontSize=13.5;$tb.LineHeight=22;$tb.LineStackingStrategy='BlockLineHeight';$tb.VerticalAlignment='Center'
                    $parts=$it -split '(\*\*.+?\*\*|`[^`]+`|!?\[[^\]]*\]\([^)]*\))'; foreach($p in $parts){if($p-match'^\*\*(.+)\*\*$'){$b=New-Object System.Windows.Documents.Bold;$r=New-Object System.Windows.Documents.Run($matches[1]);[void]$b.Inlines.Add($r);[void]$tb.Inlines.Add($b)}elseif($p-match'^`(.+)`$'){$r=New-Object System.Windows.Documents.Run($matches[1]);$r.FontFamily=New-Object System.Windows.Media.FontFamily('Consolas');$r.FontSize=12;$r.Background=$res['CodeBg'];$r.Foreground=$res['CodeFg'];[void]$tb.Inlines.Add($r)}elseif($p-match'^\[([^\]]*)\]\([^)]*\)$'){$r=New-Object System.Windows.Documents.Run($matches[1]);$r.Foreground=$res['LinkFg'];[void]$tb.Inlines.Add($r)}elseif($p-match'^!\[([^\]]*)\]\([^)]*\)$'){if($matches[1]){$r=New-Object System.Windows.Documents.Run(("[{0}]"-f$matches[1]));$r.Foreground=$res['TextMutedBrush'];$r.FontStyle='Italic';[void]$tb.Inlines.Add($r)}}else{[void]$tb.Inlines.Add((New-Object System.Windows.Documents.Run($p)))}}
                    [void]$w.Children.Add($d);[void]$w.Children.Add($tb);[void]$TargetPanel.Children.Add($w); continue
                }
                if ($line -match '^(\s*)(\d+)\.\s+(.+)'){$ind=$matches[1].Length;$num=$matches[2];$it=$matches[3];$w=New-Object System.Windows.Controls.WrapPanel;$w.Margin=New-Object $thick((4+$ind*12),2,0,2);$nb=New-Object System.Windows.Controls.TextBlock;$nb.Text="$num.";$nb.FontSize=12;$nb.FontWeight='SemiBold';$nb.Foreground=$res['BulletFg'];$nb.Margin=New-Object $thick(0,3,10,0);$nb.VerticalAlignment='Top';$tb=New-Object System.Windows.Controls.TextBlock;$tb.TextWrapping='Wrap';$tb.Foreground=$res['BodyFg'];$tb.FontSize=13.5;$tb.LineHeight=22;$tb.LineStackingStrategy='BlockLineHeight';$tb.VerticalAlignment='Center'
                    $parts=$it -split '(\*\*.+?\*\*|`[^`]+`|!?\[[^\]]*\]\([^)]*\))'; foreach($p in $parts){if($p-match'^\*\*(.+)\*\*$'){$b=New-Object System.Windows.Documents.Bold;$r=New-Object System.Windows.Documents.Run($matches[1]);[void]$b.Inlines.Add($r);[void]$tb.Inlines.Add($b)}elseif($p-match'^`(.+)`$'){$r=New-Object System.Windows.Documents.Run($matches[1]);$r.FontFamily=New-Object System.Windows.Media.FontFamily('Consolas');$r.FontSize=12;$r.Background=$res['CodeBg'];$r.Foreground=$res['CodeFg'];[void]$tb.Inlines.Add($r)}elseif($p-match'^\[([^\]]*)\]\([^)]*\)$'){$r=New-Object System.Windows.Documents.Run($matches[1]);$r.Foreground=$res['LinkFg'];[void]$tb.Inlines.Add($r)}elseif($p-match'^!\[([^\]]*)\]\([^)]*\)$'){if($matches[1]){$r=New-Object System.Windows.Documents.Run(("[{0}]"-f$matches[1]));$r.Foreground=$res['TextMutedBrush'];$r.FontStyle='Italic';[void]$tb.Inlines.Add($r)}}else{[void]$tb.Inlines.Add((New-Object System.Windows.Documents.Run($p)))}}
                    [void]$w.Children.Add($nb);[void]$w.Children.Add($tb);[void]$TargetPanel.Children.Add($w); continue
                }
                Add-InlineTextBlock -Text $line -Panel $TargetPanel
            }
        }
        $tabAccent=$res['TabAccentBg']; $tabAccentText=$res['TabAccentText']; $tabInactiveBg=$res['TabInactiveBg']; $tabInactiveBorder=$res['TabInactiveBorder']; $tabInactiveText=$res['TabInactiveText']; $tabHoverBg=$res['TabHoverBg']
        function Set-TabActive{param($btn) if($script:activeTabBtn){$script:activeTabBtn.Background=$tabInactiveBg;$script:activeTabBtn.Foreground=$tabInactiveText;$script:activeTabBtn.BorderBrush=$tabInactiveBorder;($script:activeTabBtn.Content.Children[0]).Fill=$tabInactiveText} $script:activeTabBtn=$btn; $btn.Background=$tabAccent; $btn.Foreground=$tabAccentText; $btn.BorderBrush=$tabAccent; ($btn.Content.Children[0]).Fill=$tabAccentText}
        function Get-CachedLines{param([string]$FilePath) if(-not $script:aboutLineCache.ContainsKey($FilePath)){if(-not(Test-Path -LiteralPath $FilePath)){return $null}; $script:aboutLineCache[$FilePath]=[System.IO.File]::ReadAllLines($FilePath,[System.Text.Encoding]::UTF8)}; return $script:aboutLineCache[$FilePath]}
        function Load-TabContent{param([string]$FilePath) $lines=Get-CachedLines -FilePath $FilePath; if($null-eq$lines){$tb=New-Object System.Windows.Controls.TextBlock;$tb.Text="File not found: $FilePath";$tb.Foreground=$res['DangerBrush'];$tb.Margin=New-Object $thick(0,20,0,0);[void]$contentPanel.Children.Add($tb);return}; ConvertFrom-MarkdownToUI -Lines $lines -TargetPanel $contentPanel}
        $lastGroup=$null; $firstTabBtn=$null
        foreach ($tab in $tabs) {
            if ($tab.Group -and $tab.Group -ne $lastGroup) {
                if ($lastGroup){$s=New-Object System.Windows.Controls.Border;$s.Width=1;$s.Height=22;$s.Background=$res['TableBorder'];$s.Margin=New-Object $thick(4,8,4,8);$s.VerticalAlignment='Center';[void]$tabBar.Children.Add($s)}
                $g=New-Object System.Windows.Controls.TextBlock;$g.Text=$tab.Group.ToUpper();$g.FontSize=10;$g.FontWeight='SemiBold';$g.Foreground=$res['TextMutedBrush'];$g.Margin=New-Object $thick(6,0,4,0);$g.VerticalAlignment='Center';[void]$tabBar.Children.Add($g); $lastGroup=$tab.Group
            }
            $btn=New-Object System.Windows.Controls.Button; $btn.Style=$aboutWindow.FindResource('TabBtn'); $btn.Background=$tabInactiveBg; $btn.Foreground=$tabInactiveText; $btn.BorderBrush=$tabInactiveBorder; $btn.ToolTip="View $($tab.Name) documentation"
            $bp=New-Object System.Windows.Controls.StackPanel; $bp.Orientation='Horizontal'; $ip=New-Object System.Windows.Shapes.Path; $ip.Stretch='Uniform'; $ip.Width=14; $ip.Height=14; $ip.Fill=$tabInactiveText; $ip.Data=[System.Windows.Media.Geometry]::Parse($tab.Icon); $ip.Margin=New-Object $thick(0,0,6,0); $ip.VerticalAlignment='Center'
            $l=New-Object System.Windows.Controls.TextBlock; $l.Text=$tab.Name; $l.VerticalAlignment='Center'; [void]$bp.Children.Add($ip); [void]$bp.Children.Add($l); $btn.Content=$bp
            $fp=Join-Path $docsDir $tab.File; $btn.Tag=$fp
            $btn.Add_Click({$contentPanel.Children.Clear();$contentScroll.ScrollToTop();Set-TabActive -btn $this;Load-TabContent -FilePath $this.Tag})|Out-Null
            $btn.Add_MouseEnter({if($this -ne $script:activeTabBtn){$this.Background=$tabHoverBg}})|Out-Null
            $btn.Add_MouseLeave({if($this -ne $script:activeTabBtn){$this.Background=$tabInactiveBg}})|Out-Null
            [void]$tabBar.Children.Add($btn); if(-not $firstTabBtn){$firstTabBtn=$btn}
        }
        if ($firstTabBtn){Set-TabActive -btn $firstTabBtn; Load-TabContent -FilePath (Join-Path $docsDir $tabs[0].File)}
        $closeBtn.Add_Click({$aboutWindow.Close()})|Out-Null; [void]$aboutWindow.ShowDialog()
    } catch { Add-LogLine -Message ("Failed to open About dialog: {0}" -f $_.Exception.Message) -Level 'ERROR' }
}
