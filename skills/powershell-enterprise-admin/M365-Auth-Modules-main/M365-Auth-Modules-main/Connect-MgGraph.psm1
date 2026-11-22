<#
.SYNOPSIS
    Connect-MgGraph - General Microsoft Graph connection module.

.DESCRIPTION
    PowerShell module that authenticates to Microsoft Graph API with broad permission
    scopes for Users, Groups, Devices, and Policies operations. Supports both app-only
    (client credentials) and delegated (interactive) authentication.

    Exported commands:
      Connect-MgGraphModule  - Authenticate to Microsoft Graph
      Disconnect-MgGraphModule - Disconnect from Microsoft Graph
      Get-MgGraphUser        - List users with filtering
      Get-MgGraphGroup       - List groups with members
      Get-MgGraphDevice      - List devices with filtering

.EXAMPLE
    Import-Module .\Connect-MgGraph.psm1
    Connect-MgGraphModule
    $users = Get-MgGraphUser -Top 10
    Disconnect-MgGraphModule

.EXAMPLE
    $secret = ConvertTo-SecureString "your-client-secret" -AsPlainText -Force
    Connect-MgGraphModule -ClientId "your-app-id" -TenantId "your-tenant-id" -ClientSecret $secret

.NOTES
    Requirements:
      - Microsoft.Graph.Authentication module (auto-installed if missing)
      - Microsoft.Graph.Users module (auto-installed if missing)
      - Microsoft.Graph.Groups module (auto-installed if missing)
      - Microsoft.Graph.Identity.DirectoryManagement module (auto-installed if missing)
      - PowerShell 5.1+
      - Azure AD app registration with appropriate permissions

    Auth resolution priority (app-only):
      1. -ClientSecret parameter
      2. $env:GRAPH_CLIENT_SECRET environment variable

    Note: TenantId, ClientId, and ClientSecret must be provided via parameters or environment variables.
#>

# ==============================================================================
# Module-scoped default credentials — Override via parameters or $env variables
# ==============================================================================
# Example values (replace with your own)
$script:DefaultTenantId       = '00000000-0000-0000-0000-000000000000'   # Your tenant ID
$script:DefaultClientId       = '00000000-0000-0000-0000-000000000000'   # Your app ID
$script:DefaultClientSecret   = 'REMOVED'   # Your secret (use $env:GRAPH_CLIENT_SECRET in production)

# Module state
$script:Connected = $false
$script:AuthMode = $null

# Graph scopes (application permissions)
$script:GraphScopes = @(
    'User.Read.All',
    'Group.Read.All',
    'GroupMember.Read.All',
    'Device.Read.All',
    'Directory.Read.All',
    'Organization.Read.All'
)

# ==============================================================================
# Ensure Microsoft.Graph modules are available
# ==============================================================================
function Install-GraphModule {
    param([string]$ModuleName)

    if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
        Write-Verbose "Installing $ModuleName module..."
        try {
            Install-Module -Name $ModuleName -Scope CurrentUser `
                -Repository PSGallery -Force -ErrorAction Stop
        } catch {
            Write-Warning "Failed to install ${ModuleName}: $($_.Exception.Message)"
            throw
        }
    }
}

# ==============================================================================
# Connect-MgGraphModule — Authenticate to Microsoft Graph
# ==============================================================================
function Connect-MgGraphModule {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$TenantId,

        [Parameter()]
        [string]$ClientId,

        [Parameter()]
        [securestring]$ClientSecret,

        [Parameter()]
        [switch]$Interactive
    )

    if ($script:Connected) {
        Write-Warning "Already connected to Microsoft Graph."
        return
    }

    # Ensure required modules
    @('Microsoft.Graph.Authentication', 'Microsoft.Graph.Users',
      'Microsoft.Graph.Groups', 'Microsoft.Graph.Identity.DirectoryManagement') | ForEach-Object {
        Install-GraphModule -ModuleName $_
    }

    # --- Resolve parameters ---
    if (-not $TenantId) { $TenantId = $script:DefaultTenantId }
    if (-not $ClientId) { $ClientId = $script:DefaultClientId }

    # Resolve client secret
    $resolvedSecret = $null
    if ($ClientSecret) {
        $resolvedSecret = $ClientSecret
    } elseif ($env:GRAPH_CLIENT_SECRET) {
        $resolvedSecret = ConvertTo-SecureString $env:GRAPH_CLIENT_SECRET -AsPlainText -Force
    } elseif ($script:DefaultClientSecret) {
        $resolvedSecret = ConvertTo-SecureString $script:DefaultClientSecret -AsPlainText -Force
    }

    # Validate required values
    if (-not $TenantId -or -not $ClientId) {
        throw "TenantId and ClientId are required. Provide via parameters or set DefaultTenantId/DefaultClientId."
    }

    try {
        Import-Module Microsoft.Graph.Authentication -ErrorAction Stop

        if ($Interactive -or -not $resolvedSecret) {
            # Interactive delegated login
            Write-Verbose "Connecting to Microsoft Graph (interactive)..."
            Connect-MgGraph -Scopes $script:GraphScopes -ErrorAction Stop
            $script:AuthMode = 'Delegated'
        } else {
            # App-only client credentials
            Write-Verbose "Connecting to Microsoft Graph (app-only, TenantId=$TenantId, ClientId=$ClientId)..."
            $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($resolvedSecret)
            try {
                $plaintextSecret = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
            } finally {
                [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
            }
            $body = @{
                grant_type    = 'client_credentials'
                client_id     = $ClientId
                client_secret = $plaintextSecret
                scope         = 'https://graph.microsoft.com/.default'
            }

            $tokenResp = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
                -Method POST -Body $body -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop

            $secureToken = ConvertTo-SecureString $tokenResp.access_token -AsPlainText -Force
            Connect-MgGraph -AccessToken $secureToken -ErrorAction Stop
            $script:AuthMode = 'AppOnly'
        }

        $script:Connected = $true
        Write-Verbose "Connected to Microsoft Graph (mode=$($script:AuthMode))."

    } catch {
        $script:Connected = $false
        throw "Failed to connect to Microsoft Graph: $($_.Exception.Message)"
    }
}

# ==============================================================================
# Disconnect-MgGraphModule — Disconnect from Microsoft Graph
# ==============================================================================
function Disconnect-MgGraphModule {
    [CmdletBinding()]
    param()

    if (-not $script:Connected) {
        Write-Warning "Not connected to Microsoft Graph."
        return
    }

    try {
        Disconnect-MgGraph -ErrorAction SilentlyContinue
        $script:Connected = $false
        $script:AuthMode = $null
        Write-Verbose "Disconnected from Microsoft Graph."
    } catch {
        Write-Warning "Error disconnecting: $($_.Exception.Message)"
    }
}

# ==============================================================================
# Get-MgGraphUser — List users with filtering
# ==============================================================================
function Get-MgGraphUser {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Filter,

        [Parameter()]
        [string[]]$Property = @('Id', 'DisplayName', 'UserPrincipalName', 'Mail',
                                 'Department', 'JobTitle', 'AccountEnabled', 'CreatedDateTime'),

        [Parameter()]
        [int]$Top = 100,

        [Parameter()]
        [switch]$All
    )

    if (-not $script:Connected) {
        throw "Not connected. Run Connect-MgGraphModule first."
    }

    try {
        $params = @{
            Property = $Property
        }

        if ($Filter) { $params['Filter'] = $Filter }
        if (-not $All) { $params['Top'] = $Top }

        $users = Get-MgUser @params -ErrorAction Stop

        if ($All) {
            $allUsers = @()
            $page = $users
            while ($page) {
                $allUsers += $page
                if ($page.'@odata.nextLink') {
                    $page = Invoke-MgGraphRequest -Uri $page.'@odata.nextLink' -Method GET
                    $page = $page.value
                } else {
                    $page = $null
                }
            }
            return $allUsers
        }

        return $users

    } catch {
        throw "Failed to get users: $($_.Exception.Message)"
    }
}

# ==============================================================================
# Get-MgGraphGroup — List groups with members
# ==============================================================================
function Get-MgGraphGroup {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Filter,

        [Parameter()]
        [string[]]$Property = @('Id', 'DisplayName', 'Description', 'Mail',
                                 'GroupTypes', 'CreatedDateTime'),

        [Parameter()]
        [int]$Top = 100,

        [Parameter()]
        [switch]$All,

        [Parameter()]
        [switch]$WithMembers
    )

    if (-not $script:Connected) {
        throw "Not connected. Run Connect-MgGraphModule first."
    }

    try {
        $params = @{
            Property = $Property
        }

        if ($Filter) { $params['Filter'] = $Filter }
        if (-not $All) { $params['Top'] = $Top }

        $groups = Get-MgGroup @params -ErrorAction Stop

        if ($WithMembers) {
            foreach ($group in $groups) {
                $members = Get-MgGroupMember -GroupId $group.Id -ErrorAction SilentlyContinue
                $group | Add-Member -NotePropertyName 'Members' -NotePropertyValue $members -Force
            }
        }

        return $groups

    } catch {
        throw "Failed to get groups: $($_.Exception.Message)"
    }
}

# ==============================================================================
# Get-MgGraphDevice — List devices with filtering
# ==============================================================================
function Get-MgGraphDevice {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Filter,

        [Parameter()]
        [string[]]$Property = @('Id', 'DisplayName', 'OperatingSystem', 'OperatingSystemVersion',
                                 'TrustType', 'AccountEnabled', 'CreatedDateTime',
                                 'LastSignInDateTime'),

        [Parameter()]
        [int]$Top = 100,

        [Parameter()]
        [switch]$All
    )

    if (-not $script:Connected) {
        throw "Not connected. Run Connect-MgGraphModule first."
    }

    try {
        $params = @{
            Property = $Property
        }

        if ($Filter) { $params['Filter'] = $Filter }
        if (-not $All) { $params['Top'] = $Top }

        $devices = Get-MgDevice @params -ErrorAction Stop

        if ($All) {
            $allDevices = @()
            $page = $devices
            while ($page) {
                $allDevices += $page
                if ($page.'@odata.nextLink') {
                    $page = Invoke-MgGraphRequest -Uri $page.'@odata.nextLink' -Method GET
                    $page = $page.value
                } else {
                    $page = $null
                }
            }
            return $allDevices
        }

        return $devices

    } catch {
        throw "Failed to get devices: $($_.Exception.Message)"
    }
}

# ==============================================================================
# Export module members
# ==============================================================================
Export-ModuleMember -Function @(
    'Connect-MgGraphModule',
    'Disconnect-MgGraphModule',
    'Get-MgGraphUser',
    'Get-MgGraphGroup',
    'Get-MgGraphDevice'
)
