<#
.SYNOPSIS
    Connect-Intune - Connect to Microsoft Intune via Microsoft Graph API.

.DESCRIPTION
    PowerShell module that authenticates to Microsoft Graph with Intune-specific
    permission scopes. Supports both app-only (client credentials) and interactive
    user authentication. Provides helper functions for common Intune operations
    such as device enumeration, sync commands, and policy retrieval.

    Exported commands:
      Connect-Intune          - Authenticate to Microsoft Graph for Intune
      Disconnect-Intune       - Disconnect from Microsoft Graph
      Get-IntuneDevices       - List all managed devices
      Send-IntuneDeviceSync   - Send sync command to a device
      Get-IntunePolicy        - Retrieve device configuration policies

.EXAMPLE
    Import-Module .Connect-Intune.psm1
    Connect-Intune
    $devices = Get-IntuneDevices
    Send-IntuneDeviceSync -DeviceId $devices[0].id

.EXAMPLE
    $secret = ConvertTo-SecureString "your-client-secret" -AsPlainText -Force
    Connect-Intune -ClientId "your-app-id" -TenantId "your-tenant-id" -ClientSecret $secret

.NOTES
    Requirements:
      - Microsoft.Graph.Authentication module (auto-installed if missing)
      - PowerShell 5.1+
      - Azure AD app registration with Intune permissions

    Auth resolution priority (app-only):
      1. -ClientSecret parameter
      2. $env:INTUNE_CLIENT_SECRET environment variable

    Note: TenantId, ClientId, and ClientSecret must be provided via parameters or environment variables.
#>

# ==============================================================================
# Module-scoped defaults — Override via parameters or $env:INTUNE_CLIENT_SECRET
# ==============================================================================
# Example values (replace with your own)
$script:DefaultTenantId     = '00000000-0000-0000-0000-000000000000'   # Your tenant ID
$script:DefaultClientId     = '00000000-0000-0000-0000-000000000000'   # Your app ID
$script:DefaultClientSecret = 'REMOVED'   # Your secret (use $env:INTUNE_CLIENT_SECRET in production)

# Module state
$script:Connected = $false
$script:AuthMode = $null

# Interactive auth scopes
$script:IntuneUserScopes = @(
    'DeviceManagementManagedDevices.ReadWrite.All',
    'DeviceManagementConfiguration.Read.All',
    'Directory.Read.All',
    'DeviceManagementApps.Read.All',
    'DeviceManagementManagedDevices.PrivilegedOperations.All'
)

# Token cache (avoids re-auth on repeated calls)
$script:CachedToken = $null
$script:TokenExpiresAt = [DateTime]::MinValue

# ==============================================================================
# Ensure Microsoft.Graph.Authentication is available
# ==============================================================================
function Install-GraphModule {
    if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Authentication)) {
        Write-Verbose "Installing Microsoft.Graph.Authentication module..."
        try {
            Install-Module -Name Microsoft.Graph.Authentication -Scope CurrentUser `
                -Repository PSGallery -Force -ErrorAction Stop
        } catch {
            Write-Error "Failed to install Microsoft.Graph.Authentication: $($_.Exception.Message)"
            return $false
        }
    }
    Import-Module Microsoft.Graph.Authentication -Force -ErrorAction Stop
    return $true
}

# ==============================================================================
# Acquire OAuth 2.0 token via client credentials (app-only)
# ==============================================================================
function Get-IntuneAccessToken {
    param(
        [Parameter(Mandatory)] [string]$TenantId,
        [Parameter(Mandatory)] [string]$ClientId,
        [Parameter(Mandatory)] [securestring]$ClientSecret
    )

    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ClientSecret)
    try {
        $plainSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr) -replace '\0', ''
    } finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }

    $body = @{
        grant_type    = 'client_credentials'
        client_id     = $ClientId
        client_secret = $plainSecret
        scope         = 'https://graph.microsoft.com/.default'
    }

    $tokenUrl = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
    try {
        $response = Invoke-RestMethod -Method Post -Uri $tokenUrl `
            -Body $body -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop
        return $response.access_token
    } catch {
        $err = $_.Exception.Message
        try { $err = ($_.ErrorDetails.Message | ConvertFrom-Json).error_description } catch {}
        Write-Error "Get-IntuneAccessToken: $err"
        return $null
    }
}

# ==============================================================================
# Connect-Intune - Public: authenticate to Microsoft Graph for Intune
# ==============================================================================
function Connect-Intune {
    <#
    .SYNOPSIS
        Connect to Microsoft Graph with Intune permission scopes.

    .DESCRIPTION
        Authenticates to Microsoft Graph using either app-only (client credentials)
        or interactive user login. Automatically installs the Graph module if missing.

    .PARAMETER ClientId
        Azure AD application (client) ID. Uses embedded default if omitted.

    .PARAMETER TenantId
        Azure AD tenant ID. Uses embedded default if omitted.

    .PARAMETER ClientSecret
        Client secret as SecureString for app-only auth.

    .PARAMETER Interactive
        Switch to use interactive user login instead of app-only auth.

    .PARAMETER Scopes
        Custom Graph scopes for interactive auth (overrides defaults).

    .EXAMPLE
        Connect-Intune

    .EXAMPLE
        Connect-Intune -Interactive

    .EXAMPLE
        $secret = ConvertTo-SecureString "your-secret" -AsPlainText -Force
        Connect-Intune -ClientId "your-app-id" -TenantId "your-tenant-id" -ClientSecret $secret
    #>
    [CmdletBinding()]
    param(
        [string]$ClientId,
        [string]$TenantId,
        [securestring]$ClientSecret,
        [switch]$Interactive,
        [string[]]$Scopes
    )

    # Install Graph module if needed
    $moduleReady = Install-GraphModule
    if (-not $moduleReady) { return $false }

    $tenant = if ($TenantId) { $TenantId } else { $script:DefaultTenantId }
    $client = if ($ClientId) { $ClientId } else { $script:DefaultClientId }

    # Resolve client secret
    $secret = $ClientSecret
    if (-not $secret -and $env:INTUNE_CLIENT_SECRET) {
        $secret = ConvertTo-SecureString $env:INTUNE_CLIENT_SECRET -AsPlainText -Force
    }
    if (-not $secret -and -not $Interactive -and $script:DefaultClientSecret) {
        $secret = ConvertTo-SecureString $script:DefaultClientSecret -AsPlainText -Force
    }

    try {
        $version = (Get-Module -ListAvailable Microsoft.Graph.Authentication | Select-Object -ExpandProperty Version).Major

        if ($Interactive -or (-not $secret)) {
            # Interactive user authentication
            $authScopes = if ($Scopes) { $Scopes } else { $script:IntuneUserScopes }

            if ($version -eq 2) {
                Connect-MgGraph -Scopes $authScopes -ErrorAction Stop | Out-Null
            } else {
                Select-MgProfile -Name Beta
                Connect-MgGraph -Scopes $authScopes -ErrorAction Stop | Out-Null
            }

            $ctx = Get-MgContext
            Write-Verbose "Connected to tenant $($ctx.TenantId) as $($ctx.Account) (interactive)"
        } else {
            # App-only authentication
            $accessToken = Get-IntuneAccessToken -TenantId $tenant -ClientId $client -ClientSecret $secret
            if (-not $accessToken) {
                Write-Error "Connect-Intune: Failed to acquire access token."
                return $false
            }

            if ($version -eq 2) {
                $secureToken = ConvertTo-SecureString -String $accessToken -AsPlainText -Force
                Connect-MgGraph -AccessToken $secureToken -ErrorAction Stop | Out-Null
            } else {
                Select-MgProfile -Name Beta
                Connect-MgGraph -AccessToken $accessToken -ErrorAction Stop | Out-Null
            }

            Write-Verbose "Connected to Intune tenant $tenant (app-only)"
        }

        # Store connection state
        $script:Connected = $true
        $script:AuthMode = if ($Interactive) { 'Interactive' } else { 'AppOnly' }

        return $true
    } catch {
        $msg = $_.Exception.Message
        if ($msg -match 'AADSTS700016') {
            Write-Error "Connect-Intune: Wrong ClientId or app not found in tenant."
        } elseif ($msg -match 'AADSTS7000215') {
            Write-Error "Connect-Intune: Invalid client secret. Regenerate in Azure AD."
        } elseif ($msg -match 'Access is denied') {
            Write-Error "Connect-Intune: Access denied. Check app permissions and admin consent."
        } else {
            Write-Error "Connect-Intune: $msg"
        }
        return $false
    }
}

# ==============================================================================
# Disconnect-Intune - Public: disconnect from Microsoft Graph
# ==============================================================================
function Disconnect-Intune {
    <#
    .SYNOPSIS
        Disconnect from Microsoft Graph.

    .DESCRIPTION
        Ends the current Microsoft Graph session and clears connection state.

    .EXAMPLE
        Disconnect-Intune
    #>
    [CmdletBinding()]
    param()

    try {
        Disconnect-MgGraph -ErrorAction SilentlyContinue
    } catch {
        Write-Warning "Disconnect-Intune: $($_.Exception.Message)"
    }

    $script:Connected = $false
    $script:AuthMode = $null
    Write-Verbose "Disconnected from Microsoft Graph."
}

# ==============================================================================
# Get-IntuneDevices - Public: list all managed devices
# ==============================================================================
function Get-IntuneDevices {
    <#
    .SYNOPSIS
        Retrieve all Intune-managed devices.

    .DESCRIPTION
        Queries Microsoft Graph Beta endpoint for all managed devices in the
        Intune tenant. Handles pagination automatically.

    .PARAMETER Filter
        OData filter string (e.g., "deviceName eq 'WORKSTATION01'").

    .PARAMETER Top
        Maximum number of devices to return (default: all).

    .EXAMPLE
        $devices = Get-IntuneDevices

    .EXAMPLE
        $devices = Get-IntuneDevices -Filter "deviceName eq 'PC-001'"
    #>
    [CmdletBinding()]
    param(
        [string]$Filter,
        [int]$Top = 0
    )

    if (-not $script:Connected) {
        Write-Error "Not connected. Run Connect-Intune first."
        return @()
    }

    $baseUri = 'https://graph.microsoft.com/Beta/deviceManagement/managedDevices'
    $uri = $baseUri

    $queryParams = @()
    if ($Filter) { $queryParams += "`$filter=$Filter" }
    if ($Top -gt 0) { $queryParams += "`$top=$Top" }
    if ($queryParams.Count -gt 0) { $uri += "?$($queryParams -join '&')" }

    try {
        $response = Invoke-MgGraphRequest -Uri $uri -Method Get -OutputType PSObject
        $allDevices = @($response.value)

        $nextLink = $response."@odata.nextLink"
        while ($nextLink) {
            $response = Invoke-MgGraphRequest -Uri $nextLink -Method Get -OutputType PSObject
            $allDevices += $response.value
            $nextLink = $response."@odata.nextLink"
        }

        Write-Verbose "Retrieved $($allDevices.Count) Intune device(s)."
        return $allDevices
    } catch {
        Write-Error "Get-IntuneDevices: $($_.Exception.Message)"
        return @()
    }
}

# ==============================================================================
# Send-IntuneDeviceSync - Public: send sync command to a device
# ==============================================================================
function Send-IntuneDeviceSync {
    <#
    .SYNOPSIS
        Send a sync command to an Intune-managed device.

    .DESCRIPTION
        Invokes the syncDevice action on the specified managed device via Graph API.

    .PARAMETER DeviceId
        The Intune device ID (GUID) to sync.

    .EXAMPLE
        Send-IntuneDeviceSync -DeviceId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

    .EXAMPLE
        $devices = Get-IntuneDevices
        $devices | ForEach-Object { Send-IntuneDeviceSync -DeviceId $_.id }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$DeviceId
    )

    if (-not $script:Connected) {
        Write-Error "Not connected. Run Connect-Intune first."
        return $false
    }

    $uri = "https://graph.microsoft.com/Beta/deviceManagement/managedDevices('$DeviceId')/syncDevice"
    try {
        Invoke-MgGraphRequest -Uri $uri -Method Post -Body $null -ErrorAction Stop
        Write-Verbose "Sync command sent to device $DeviceId."
        return $true
    } catch {
        Write-Error "Send-IntuneDeviceSync: $($_.Exception.Message)"
        return $false
    }
}

# ==============================================================================
# Get-IntunePolicy - Public: retrieve device configuration policies
# ==============================================================================
function Get-IntunePolicy {
    <#
    .SYNOPSIS
        Retrieve Intune device configuration policies.

    .DESCRIPTION
        Queries Graph API for device configuration policies in the Intune tenant.
        Supports filtering by name.

    .PARAMETER Name
        Filter policies by display name (contains match).

    .EXAMPLE
        $policies = Get-IntunePolicy

    .EXAMPLE
        $policies = Get-IntunePolicy -Name "Windows Update"
    #>
    [CmdletBinding()]
    param(
        [string]$Name
    )

    if (-not $script:Connected) {
        Write-Error "Not connected. Run Connect-Intune first."
        return @()
    }

    $uri = 'https://graph.microsoft.com/Beta/deviceManagement/deviceConfigurations'
    try {
        $response = Invoke-MgGraphRequest -Uri $uri -Method Get -OutputType PSObject
        $policies = @($response.value)

        $nextLink = $response."@odata.nextLink"
        while ($nextLink) {
            $response = Invoke-MgGraphRequest -Uri $nextLink -Method Get -OutputType PSObject
            $policies += $response.value
            $nextLink = $response."@odata.nextLink"
        }

        if ($Name) {
            $policies = $policies | Where-Object { $_.displayName -like "*$Name*" }
        }

        Write-Verbose "Retrieved $($policies.Count) policy/policies."
        return $policies
    } catch {
        Write-Error "Get-IntunePolicy: $($_.Exception.Message)"
        return @()
    }
}

# ==============================================================================
# Export public functions
# ==============================================================================
Export-ModuleMember -Function @(
    'Connect-Intune',
    'Disconnect-Intune',
    'Get-IntuneDevices',
    'Send-IntuneDeviceSync',
    'Get-IntunePolicy'
)
