Requires -Version 5.1

<#
.SYNOPSIS
    Microsoft Teams management module via Microsoft Graph API.

.DESCRIPTION
    Provides functions to authenticate with Microsoft Graph API and manage
    Microsoft Teams resources including teams, channels, and members.
    Supports both app-only (client credentials) and interactive delegated
    authentication flows. Auto-installs the Microsoft.Graph.Teams module
    if not already present.

    Authentication secret is resolved in priority order:
        1. -ClientSecret parameter
        2. $env:TEAMS_CLIENT_SECRET environment variable
        3. Module-scoped default placeholder value

.EXAMPLE
    # Interactive login (browser-based delegated auth)
    Connect-Teams -Interactive

.EXAMPLE
    # App-only client credentials with explicit secret
    Connect-Teams -TenantId '00000000-0000-0000-0000-000000000000' `
                  -ClientId '00000000-0000-0000-0000-000000000000' `
                  -ClientSecret 'your-secret-here'

.EXAMPLE
    # List all teams in the tenant
    Get-TeamsAll -Verbose

.EXAMPLE
    # List channels for a specific team
    Get-TeamsChannel -TeamId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'

.EXAMPLE
    # Create a new standard channel
    New-TeamsChannel -TeamId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' `
                     -Name 'Project Alpha' `
                     -Description 'Channel for Project Alpha discussions' `
                     -MembershipType 'standard'

.NOTES
    Author  : admin
    Module  : Connect-Teams.psm1
    Requires: PowerShell 5.1+, Microsoft.Graph.Teams module
    License : Internal use
#>

# ==============================================================================
# Module-scoped default credentials — Override via parameters or $env variables
# ==============================================================================
# Example values (replace with your own)
$script:DefaultTenantId     = '00000000-0000-0000-0000-000000000000'   # Your tenant ID
$script:DefaultClientId     = '00000000-0000-0000-0000-000000000000'   # Your app ID
$script:DefaultClientSecret = 'REMOVED'   # Your secret (use $env:TEAMS_CLIENT_SECRET in production)

$script:GraphBaseUri = 'https://graph.microsoft.com/v1.0'

$script:TokenCache = $null

# ==============================================================================
# Module Initialization
# ==============================================================================

function Initialize-Module {
    <#
    .SYNOPSIS
        Ensures the Microsoft.Graph.Teams module is available and imported.
    #>
    [CmdletBinding()]
    param()

    $requiredModules = @(
        'Microsoft.Graph.Authentication',
        'Microsoft.Graph.Teams'
    )

    foreach ($moduleName in $requiredModules) {
        $existing = Get-Module -Name $moduleName -ListAvailable -ErrorAction SilentlyContinue
        if (-not $existing) {
            Write-Verbose "Module '$moduleName' not found. Attempting to install..."
            try {
                Install-Module -Name $moduleName -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
                Write-Verbose "Module '$moduleName' installed successfully."
            }
            catch {
                Write-Error "Failed to install module '$moduleName': $_"
                throw
            }
        }

        $loaded = Get-Module -Name $moduleName -ErrorAction SilentlyContinue
        if (-not $loaded) {
            Write-Verbose "Importing module '$moduleName'..."
            try {
                Import-Module -Name $moduleName -ErrorAction Stop
                Write-Verbose "Module '$moduleName' imported successfully."
            }
            catch {
                Write-Error "Failed to import module '$moduleName': $_"
                throw
            }
        }
    }
}

# ==============================================================================
# Helper Functions
# ==============================================================================

function Resolve-ClientSecret {
    <#
    .SYNOPSIS
        Resolves the client secret from parameter, environment, or default.
    .DESCRIPTION
        Priority order:
            1. Explicit -ClientSecret parameter value
            2. $env:TEAMS_CLIENT_SECRET environment variable
            3. Module-scoped $script:DefaultClientSecret placeholder
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [System.Security.SecureString]$ClientSecret
    )

    if ($ClientSecret) {
        Write-Verbose "Using client secret provided via parameter."
        return $ClientSecret
    }

    $envSecret = $env:TEAMS_CLIENT_SECRET
    if ($envSecret) {
        Write-Verbose "Using client secret from environment variable 'TEAMS_CLIENT_SECRET'."
        $secure = ConvertTo-SecureString -String $envSecret -AsPlainText -Force
        return $secure
    }

    Write-Verbose "Using module-scoped default client secret (placeholder)."
    $secure = ConvertTo-SecureString -String $script:DefaultClientSecret -AsPlainText -Force
    return $secure
}

function Invoke-GraphRequest {
    <#
    .SYNOPSIS
        Sends an authenticated request to Microsoft Graph API.
    .DESCRIPTION
        Uses the cached access token to call the Microsoft Graph REST API.
        Supports GET, POST, PATCH, DELETE, and PUT methods.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Uri,

        [Parameter(Mandatory = $false)]
        [ValidateSet('GET', 'POST', 'PATCH', 'DELETE', 'PUT')]
        [string]$Method = 'GET',

        [Parameter(Mandatory = $false)]
        [object]$Body,

        [Parameter(Mandatory = $false)]
        [string]$ContentType = 'application/json'
    )

    if (-not $script:TokenCache) {
        throw 'No active session. Please run Connect-Teams first.'
    }

    $headers = @{
        'Authorization' = "Bearer $($script:TokenCache)"
        'Content-Type'  = $ContentType
    }

    $requestParams = @{
        Uri     = $Uri
        Method  = $Method
        Headers = $headers
    }

    if ($Body) {
        if ($Body -is [string]) {
            $requestParams['Body'] = $Body
        }
        else {
            $requestParams['Body'] = ($Body | ConvertTo-Json -Depth 20 -Compress)
        }
    }

    Write-Verbose "Sending $Method request to $Uri"

    try {
        $response = Invoke-RestMethod @requestParams -ErrorAction Stop
        return $response
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $message    = $_.Exception.Message
        Write-Error "Graph API request failed [$statusCode]: $message"
        throw
    }
}

# ==============================================================================
# Exported Functions
# ==============================================================================

function Connect-Teams {
    <#
    .SYNOPSIS
        Authenticates to Microsoft Graph API for Teams management.

    .DESCRIPTION
        Establishes an authenticated session with Microsoft Graph using either
        app-only client credentials (default) or interactive delegated auth.
        Initializes required modules if not present. Caches the access token
        for subsequent Graph API calls.

        Client secret resolution priority:
            1. -ClientSecret parameter
            2. $env:TEAMS_CLIENT_SECRET environment variable
            3. Module-scoped default placeholder

    .PARAMETER TenantId
        Azure AD tenant ID (GUID). Defaults to module-scoped placeholder.

    .PARAMETER ClientId
        Azure AD application (client) ID (GUID). Defaults to module-scoped placeholder.

    .PARAMETER ClientSecret
        SecureString representing the application client secret. If not provided,
        the module checks the TEAMS_CLIENT_SECRET environment variable and then
        falls back to the module-scoped default.

    .PARAMETER Interactive
        If specified, performs interactive browser-based delegated authentication
        instead of app-only client credentials.

    .EXAMPLE
        Connect-Teams -Interactive
        # Opens browser for interactive login with delegated permissions.

    .EXAMPLE
        Connect-Teams -TenantId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' `
                      -ClientId 'yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy' `
                      -ClientSecret (ConvertTo-SecureString 'secret' -AsPlainText -Force)
        # Authenticates using app-only client credentials.

    .EXAMPLE
        Connect-Teams
        # Uses all default values including placeholder secret.

    .NOTES
        Requires: Microsoft.Graph.Authentication module
        Author  : admin
    #>
    [CmdletBinding(DefaultParameterSetName = 'AppOnly')]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = 'AppOnly')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Interactive')]
        [string]$TenantId,

        [Parameter(Mandatory = $false, ParameterSetName = 'AppOnly')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Interactive')]
        [string]$ClientId,

        [Parameter(Mandatory = $false, ParameterSetName = 'AppOnly')]
        [System.Security.SecureString]$ClientSecret,

        [Parameter(Mandatory = $false, ParameterSetName = 'Interactive')]
        [switch]$Interactive
    )

    Write-Verbose "Initializing Microsoft Graph modules..."
    Initialize-Module

    $resolvedTenantId = if ($TenantId) { $TenantId } else { $script:DefaultTenantId }
    $resolvedClientId = if ($ClientId) { $ClientId } else { $script:DefaultClientId }

    Write-Verbose "Tenant ID : $resolvedTenantId"
    Write-Verbose "Client ID : $resolvedClientId"
    Write-Verbose "Auth Mode : $(if ($Interactive) { 'Interactive Delegated' } else { 'App-Only Client Credentials' })"

    try {
        if ($Interactive) {
            Write-Verbose "Starting interactive delegated authentication..."
            Connect-MgGraph -Scopes 'Team.ReadBasic.All', 'Channel.ReadBasic.All', 'TeamMember.Read.All', 'Channel.Create' -ErrorAction Stop
        }
        else {
            $resolvedSecret = Resolve-ClientSecret -ClientSecret $ClientSecret

            $body = @{
                grant_type    = 'client_credentials'
                client_id     = $resolvedClientId
                client_secret = [System.Net.NetworkCredential]::new('', $resolvedSecret).Password
                scope         = 'https://graph.microsoft.com/.default'
            }

            $tokenUri = "https://login.microsoftonline.com/$resolvedTenantId/oauth2/v2.0/token"
            Write-Verbose "Requesting access token from $tokenUri"

            $tokenResponse = Invoke-RestMethod -Uri $tokenUri -Method Post -Body $body -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop

            $script:TokenCache = $tokenResponse.access_token
            Write-Verbose "Access token acquired successfully (expires in $($tokenResponse.expires_in) seconds)."
        }

        Write-Verbose "Connection to Microsoft Graph established."
        Write-Verbose "Successfully connected to Microsoft Teams via Graph API."
    }
    catch {
        $script:TokenCache = $null
        Write-Error "Connection failed: $_"
        throw
    }
}

function Disconnect-Teams {
    <#
    .SYNOPSIS
        Disconnects from Microsoft Graph and clears the session.

    .DESCRIPTION
        Clears the cached access token, disconnects any active Microsoft Graph
        session, and removes module state. Safe to call multiple times.

    .EXAMPLE
        Disconnect-Teams

    .NOTES
        Author  : admin
    #>
    [CmdletBinding()]
    param()

    Write-Verbose "Clearing cached access token..."
    $script:TokenCache = $null

    Write-Verbose "Disconnecting Microsoft Graph session..."
    try {
        Disconnect-MgGraph -ErrorAction SilentlyContinue
    }
    catch {
        Write-Verbose "No active Microsoft Graph session to disconnect."
    }

    Write-Verbose "Disconnected from Microsoft Teams / Graph API."
}

function Get-TeamsAll {
    <#
    .SYNOPSIS
        Lists all Microsoft Teams in the tenant.

    .DESCRIPTION
        Retrieves all teams the authenticated application or user has access to
        via the Microsoft Graph /teams endpoint. Supports pagination with the
        -All switch or limiting results with -Top.

    .PARAMETER Top
        Maximum number of teams to return per page. Default is 100. Valid range 1-999.

    .PARAMETER All
        If specified, fetches all pages and returns the complete list of teams.

    .EXAMPLE
        Get-TeamsAll
        # Returns the first page of up to 100 teams.

    .EXAMPLE
        Get-TeamsAll -Top 500 -All -Verbose
        # Returns all teams, fetching up to 500 per page.

    .NOTES
        Required Graph Permissions: Team.ReadBasic.All (Application or Delegated)
        Author  : admin
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 999)]
        [int]$Top = 100,

        [Parameter(Mandatory = $false)]
        [switch]$All
    )

    $uri = "$script:GraphBaseUri/teams?`$top=$Top"
    $allTeams = [System.Collections.Generic.List[object]]::new()

    do {
        Write-Verbose "Fetching teams from: $uri"
        $response = Invoke-GraphRequest -Uri $uri -Method GET

        if ($response.value) {
            foreach ($team in $response.value) {
                $allTeams.Add($team)
            }
            Write-Verbose "Retrieved $($response.value.Count) team(s) (total so far: $($allTeams.Count))."
        }

        $uri = $response.'@odata.nextLink'
    } while ($All -and $uri)

    Write-Verbose "Total teams returned: $($allTeams.Count)."
    return $allTeams
}

function Get-TeamsChannel {
    <#
    .SYNOPSIS
        Lists channels for a specific Microsoft Team.

    .DESCRIPTION
        Retrieves all channels within a specified team using the Microsoft Graph
        /teams/{teamId}/channels endpoint. Supports pagination.

    .PARAMETER TeamId
        The GUID of the team to list channels for.

    .EXAMPLE
        Get-TeamsChannel -TeamId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
        # Returns all channels for the specified team.

    .EXAMPLE
        Get-TeamsChannel -TeamId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' -Verbose
        # Returns all channels with verbose output.

    .NOTES
        Required Graph Permissions: Channel.ReadBasic.All (Application or Delegated)
        Author  : admin
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TeamId
    )

    $uri = "$script:GraphBaseUri/teams/$TeamId/channels"
    $allChannels = [System.Collections.Generic.List[object]]::new()

    do {
        Write-Verbose "Fetching channels from: $uri"
        $response = Invoke-GraphRequest -Uri $uri -Method GET

        if ($response.value) {
            foreach ($channel in $response.value) {
                $allChannels.Add($channel)
            }
            Write-Verbose "Retrieved $($response.value.Count) channel(s) (total so far: $($allChannels.Count))."
        }

        $uri = $response.'@odata.nextLink'
    } while ($uri)

    Write-Verbose "Total channels returned: $($allChannels.Count)."
    return $allChannels
}

function Get-TeamsMember {
    <#
    .SYNOPSIS
        Lists members of a specific Microsoft Team.

    .DESCRIPTION
        Retrieves all members (owners and members) within a specified team using
        the Microsoft Graph /teams/{teamId}/members endpoint. Supports pagination.

    .PARAMETER TeamId
        The GUID of the team to list members for.

    .EXAMPLE
        Get-TeamsMember -TeamId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
        # Returns all members for the specified team.

    .EXAMPLE
        Get-TeamsMember -TeamId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' -Verbose
        # Returns all members with verbose output.

    .NOTES
        Required Graph Permissions: TeamMember.Read.All (Application or Delegated)
        Author  : admin
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TeamId
    )

    $uri = "$script:GraphBaseUri/teams/$TeamId/members"
    $allMembers = [System.Collections.Generic.List[object]]::new()

    do {
        Write-Verbose "Fetching members from: $uri"
        $response = Invoke-GraphRequest -Uri $uri -Method GET

        if ($response.value) {
            foreach ($member in $response.value) {
                $allMembers.Add($member)
            }
            Write-Verbose "Retrieved $($response.value.Count) member(s) (total so far: $($allMembers.Count))."
        }

        $uri = $response.'@odata.nextLink'
    } while ($uri)

    Write-Verbose "Total members returned: $($allMembers.Count)."
    return $allMembers
}

function New-TeamsChannel {
    <#
    .SYNOPSIS
        Creates a new channel in a specified Microsoft Team.

    .DESCRIPTION
        Creates a new channel within a specified team using the Microsoft Graph
        /teams/{teamId}/channels endpoint. Supports standard, private, and
        shared membership types.

    .PARAMETER TeamId
        The GUID of the team where the channel will be created.

    .PARAMETER Name
        Display name for the new channel. Must not exceed 256 characters.

    .PARAMETER Description
        Optional description for the channel. Must not exceed 1024 characters.

    .PARAMETER MembershipType
        The membership type for the channel. Valid values: 'standard', 'private', 'shared'.
        Defaults to 'standard'.

    .EXAMPLE
        New-TeamsChannel -TeamId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' `
                         -Name 'Project Alpha'
        # Creates a standard channel named 'Project Alpha'.

    .EXAMPLE
        New-TeamsChannel -TeamId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' `
                         -Name 'Confidential' `
                         -Description 'Private channel for leadership' `
                         -MembershipType 'private'
        # Creates a private channel.

    .NOTES
        Required Graph Permissions: Channel.Create (Application or Delegated)
        Author  : admin
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TeamId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [string]$Description,

        [Parameter(Mandatory = $false)]
        [ValidateSet('standard', 'private', 'shared')]
        [string]$MembershipType = 'standard'
    )

    $channelBody = @{
        displayName    = $Name
        membershipType = $MembershipType
    }

    if ($Description) {
        $channelBody['description'] = $Description
    }

    $uri = "$script:GraphBaseUri/teams/$TeamId/channels"

    if ($PSCmdlet.ShouldProcess("Team '$TeamId'", "Create channel '$Name' (type: $MembershipType)")) {
        Write-Verbose "Creating channel '$Name' in team '$TeamId' (type: $MembershipType)..."
        $result = Invoke-GraphRequest -Uri $uri -Method POST -Body $channelBody
        Write-Verbose "Channel created successfully. Channel ID: $($result.id)"
        Write-Verbose "Channel '$Name' created successfully in team '$TeamId'."
        return $result
    }
}

# ==============================================================================
# Module Exports
# ==============================================================================

Export-ModuleMember -Function @(
    'Connect-Teams',
    'Disconnect-Teams',
    'Get-TeamsAll',
    'Get-TeamsChannel',
    'Get-TeamsMember',
    'New-TeamsChannel'
)
