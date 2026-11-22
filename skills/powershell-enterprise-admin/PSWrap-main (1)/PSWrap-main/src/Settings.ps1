<#
.TITLE
    PSWrap User Settings Persistence

.SYNOPSIS
    JSON-based save/load for user preferences (theme, paths, config).

.DESCRIPTION
    Provides JSON-based serialization and deserialization of user preferences
    including theme choice, last-used file paths, and build configuration.

.TAGS
    Settings,Persistence,JSON,Configuration

.MINROLE
    Reader

.PERMISSIONS
    N/A — writes to %APPDATA% only

.AUTHOR
    admin

.VERSION
    1.0.0

.CHANGELOG
    1.0.0 - Initial release

.LASTUPDATE
    2026-06-17

.EXAMPLE
    Save-UserSettings -Settings @{ Theme = 'Dark' }
    $settings = Load-UserSettings

.NOTES
    Settings file location: %APPDATA%\PSWrap\settings.json
    Saved automatically on application close and loaded on startup.
#>

function Save-UserSettings {
    <#
    .SYNOPSIS
        Persists a hashtable of user settings to a compressed JSON file.

    .DESCRIPTION
        Serializes the provided settings hashtable as compressed JSON and writes
        it to %APPDATA%\PSWrap\settings.json. Creates the directory if it does
        not exist. Errors are logged but not thrown, allowing the application to
        continue even if settings cannot be saved.

    .PARAMETER Settings
        Hashtable containing the user settings to persist. Typical keys include
        Theme, LastProjectFolder, LastSourceScript, LastOutputPath, LastIconPath,
        BuildSettings, and ToastEnabled.

    .EXAMPLE
        Save-UserSettings -Settings @{ Theme = 'Dark'; BuildSettings = $script:dlgState }
        Saves the current theme and all build options to disk.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][hashtable]$Settings)
    try {
        $dir = Split-Path $script:SettingsPath -Parent
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        $Settings | ConvertTo-Json -Compress | Set-Content -LiteralPath $script:SettingsPath -Encoding UTF8 -Force
    } catch { Add-LogLine -Message "Failed to save settings: $($_.Exception.Message)" -Level 'WARNING' }
}

function Load-UserSettings {
    <#
    .SYNOPSIS
        Loads user settings from the persisted JSON file.

    .DESCRIPTION
        Reads and deserializes the settings file from %APPDATA%\PSWrap\settings.json.
        Returns a PSCustomObject on success, or $null if the file does not exist
        or cannot be parsed. Errors are logged but not thrown, allowing the
        application to start with default values.

    .OUTPUTS
        PSCustomObject. The deserialized settings object, or $null if no settings
        file exists or parsing fails.

    .EXAMPLE
        $settings = Load-UserSettings
        if ($settings) { $script:IsDarkMode = ($settings.Theme -eq 'Dark') }
        Loads settings and applies the saved theme preference.
    #>
    [CmdletBinding()]
    param()
    if (Test-Path $script:SettingsPath) {
        try {
            $content = Get-Content -LiteralPath $script:SettingsPath -Raw -Encoding UTF8
            if ($content) { return ($content | ConvertFrom-Json -ErrorAction Stop) }
        } catch { Add-LogLine -Message "Failed to load settings: $($_.Exception.Message)" -Level 'WARNING' }
    }
    return $null
}
