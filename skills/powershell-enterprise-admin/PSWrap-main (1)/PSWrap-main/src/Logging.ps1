<#
.TITLE
    PSWrap Logging Module

.SYNOPSIS
    Structured logging with in-memory ring buffer and file output.

.DESCRIPTION
    Provides structured logging with in-memory ring buffer, file output,
    console output, and status bar integration. Supports INFO, SUCCESS,
    WARNING, ERROR, and DEBUG log levels with color-coded output.

.TAGS
    Logging,Diagnostics,Output,RingBuffer

.MINROLE
    Reader

.PERMISSIONS
    N/A — writes to local file system (%LOCALAPPDATA%)

.AUTHOR
    admin

.VERSION
    1.0.0

.CHANGELOG
    1.0.0 - Initial release

.LASTUPDATE
    2026-06-17

.EXAMPLE
    Add-LogLine -Message "Compilation started" -Level 'INFO'
    Add-LogLine -Message "Build successful" -Level 'SUCCESS'

.NOTES
    Log files are written to %LOCALAPPDATA%\PSWrap\Logs\PSWrap_YYYYMMDD.log.
    In-memory buffer is capped at 1000 entries (FIFO eviction).
#>

if (-not $script:LogEntries) {
    $script:LogCounter    = 0
    $script:MaxLogLines   = 1000
    $script:LogFileWriter = $null
    $script:LogEntries    = New-Object System.Collections.ArrayList
}

function Initialize-FileLog {
    <#
    .SYNOPSIS
        Initializes the file-based log writer.
    .DESCRIPTION
        Creates the logs directory if needed and opens a StreamWriter to the
        daily-rolling log file (PSWrap_yyyyMMdd.log) with AutoFlush enabled.
        If initialization fails, file logging is silently disabled and
        $script:LogFileWriter is set to $null.
    #>
    try {
        $logDir = $script:LogDir
        if (-not (Test-Path -LiteralPath $logDir -ErrorAction SilentlyContinue)) {
            $null = New-Item -ItemType Directory -Path $logDir -Force -ErrorAction SilentlyContinue
        }
        $script:LogFileWriter = New-Object System.IO.StreamWriter($script:LogFilePath, $true, [System.Text.Encoding]::UTF8)
        $script:LogFileWriter.AutoFlush = $true
    } catch { Write-Debug "Initialize-FileLog failed: $_"; $script:LogFileWriter = $null }
}

function Write-FileLog {
    <#
    .SYNOPSIS
        Writes a single formatted log entry to the file log.
    .PARAMETER Timestamp
        Formatted timestamp string (HH:mm:ss).
    .PARAMETER Level
        Log level label (INFO, SUCCESS, WARNING, ERROR, DEBUG).
    .PARAMETER Message
        The log message text.
    #>
    param([string]$Timestamp, [string]$Level, [string]$Message)
    try {
        if ($script:LogFileWriter) {
            $script:LogFileWriter.WriteLine(("{0} [{1}] {2}" -f $Timestamp, $Level.PadRight(7), $Message))
        }
    } catch { Write-Debug "Write-FileLog failed: $_" }
}

function Add-LogLine {
    <#
    .SYNOPSIS
        Adds a log entry to the in-memory ring buffer, file log, and status bar.
    .DESCRIPTION
        The primary logging entry point used throughout the application. Strips
        control characters from the message, assigns a color based on log level,
        appends to the ring buffer (FIFO, max 1000 entries), writes to the file
        log, and updates the status bar text via Dispatcher.
    .PARAMETER Message
        The log message text. Control characters are stripped automatically.
    .PARAMETER Level
        Log level. Valid values: INFO, SUCCESS, WARNING, ERROR, DEBUG.
        Default: INFO. Determines the display color:
          INFO    = Blue (#3B82F6)
          SUCCESS = Green (#10B981)
          WARNING = Amber (#F59E0B)
          ERROR   = Red (#EF4444)
          DEBUG   = Gray (#94A3B8)
    .EXAMPLE
        Add-LogLine -Message "Compilation started" -Level 'INFO'
        Add-LogLine -Message "Build successful!" -Level 'SUCCESS'
        Add-LogLine -Message "File not found: $path" -Level 'ERROR'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('INFO','SUCCESS','WARNING','ERROR','DEBUG')][string]$Level = 'INFO'
    )
    $clean = ($Message -replace '[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]', '' -replace '\s{2,}', ' ').Trim()
    if ([string]::IsNullOrWhiteSpace($clean)) { return }
    $ts = (Get-Date).ToString('HH:mm:ss')
    $color = switch ($Level) {
        'SUCCESS' { '#10B981' }
        'WARNING' { '#F59E0B' }
        'ERROR'   { '#EF4444' }
        'DEBUG'   { '#94A3B8' }
        default   { '#3B82F6' }
    }
    $script:LogCounter++
    $entry = [PSCustomObject]@{
        Counter   = $script:LogCounter
        Timestamp = $ts
        Level     = $Level
        Message   = $clean
        Color     = $color
    }
    [void]$script:LogEntries.Add($entry)
    while ($script:LogEntries.Count -gt $script:MaxLogLines) {
        [void]$script:LogEntries.RemoveAt(0)
    }
    Write-Debug "[$ts] [$($Level.PadRight(7))] $clean"
    Write-FileLog -Timestamp $ts -Level $Level -Message $clean
    if ($script:StatusBarText -and $script:Window -and $script:Window.IsLoaded) {
        $script:Window.Dispatcher.Invoke([Action]{ $script:StatusBarText.Text = $clean }, [System.Windows.Threading.DispatcherPriority]::Background)
    }
}

function Initialize-LogFile {
    <#
    .SYNOPSIS
        Initializes file logging and writes the session-start banner.
    #>
    Initialize-FileLog
    Add-LogLine -Message "=== $script:ToolName v$script:AppVersion Started ===" -Level 'INFO'
}

function Close-LogFile {
    <#
    .SYNOPSIS
        Writes the session-end banner and closes the file log writer.
    #>
    Add-LogLine -Message "=== $script:ToolName closing ===" -Level 'INFO'
    try {
        if ($script:LogFileWriter) { $script:LogFileWriter.Close(); $script:LogFileWriter.Dispose() }
    } catch { Write-Debug "Close-LogFile failed: $_" }
}
