<#
.SYNOPSIS
    Connect-SharePoint - Connect to SharePoint Online via Microsoft Graph API.

.DESCRIPTION
    PowerShell module that authenticates to Microsoft Graph with SharePoint-specific
    permission scopes. Supports both app-only (client credentials) and delegated
    (interactive) authentication. Provides helper functions for common SharePoint
    operations such as site retrieval, list management, and file operations.

    Exported commands:
      Connect-SharePoint       - Authenticate to Microsoft Graph for SharePoint
      Disconnect-SharePoint    - Disconnect from Microsoft Graph
      Get-SharePointSite       - Get SharePoint site by URL or ID
      Get-SharePointList       - Get SharePoint list items
      Add-SharePointListItem   - Add item to a SharePoint list
      Get-SharePointFile       - Download a file from SharePoint
      Upload-SharePointFile    - Upload a file to SharePoint

.EXAMPLE
    Import-Module .\Connect-SharePoint.psm1
    Connect-SharePoint -SiteUrl "https://contoso.sharepoint.com/sites/IT"
    $items = Get-SharePointList -ListName "Hardware"
    Disconnect-SharePoint

.EXAMPLE
    $secret = ConvertTo-SecureString "your-client-secret" -AsPlainText -Force
    Connect-SharePoint -ClientId "your-app-id" -TenantId "your-tenant-id" -ClientSecret $secret

.NOTES
    Requirements:
      - Microsoft.Graph.Sites module (auto-installed if missing)
      - Microsoft.Graph.Files module (auto-installed if missing)
      - PowerShell 5.1+
      - Azure AD app with Sites.ReadWrite.All, Files.ReadWrite.All permissions

    Auth resolution priority (app-only):
      1. -ClientSecret parameter
      2. $env:SHAREPOINT_CLIENT_SECRET environment variable

    Note: TenantId, ClientId, and ClientSecret must be provided via parameters or environment variables.
#>

# ==============================================================================
# Module-scoped default credentials — Override via parameters or $env variables
# ==============================================================================
# Example values (replace with your own)
$script:DefaultTenantId     = '00000000-0000-0000-0000-000000000000'   # Your tenant ID
$script:DefaultClientId     = '00000000-0000-0000-0000-000000000000'   # Your app ID
$script:DefaultClientSecret = 'REMOVED'   # Your secret (use $env:SHAREPOINT_CLIENT_SECRET in production)

# Module state
$script:Connected = $false
$script:AuthMode = $null
$script:CurrentSiteId = $null
$script:CurrentSiteUrl = $null

# SharePoint-specific Graph scopes
$script:SharePointScopes = @(
    'Sites.ReadWrite.All',
    'Files.ReadWrite.All',
    'AllSites.FullControl'
)

# ==============================================================================
# Ensure Microsoft.Graph modules are available
# ==============================================================================
function Install-SPModule {
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
# Connect-SharePoint — Authenticate to Microsoft Graph for SharePoint
# ==============================================================================
function Connect-SharePoint {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$TenantId,

        [Parameter()]
        [string]$ClientId,

        [Parameter()]
        [securestring]$ClientSecret,

        [Parameter()]
        [string]$SiteUrl,

        [Parameter()]
        [switch]$Interactive
    )

    if ($script:Connected) {
        Write-Warning "Already connected to Microsoft Graph for SharePoint."
        return
    }

    # Ensure required modules
    @('Microsoft.Graph.Authentication', 'Microsoft.Graph.Sites', 'Microsoft.Graph.Files') | ForEach-Object {
        Install-SPModule -ModuleName $_
    }

    # --- Resolve parameters ---
    if (-not $TenantId) { $TenantId = $script:DefaultTenantId }
    if (-not $ClientId) { $ClientId = $script:DefaultClientId }

    # Resolve client secret
    $resolvedSecret = $null
    if ($ClientSecret) {
        $resolvedSecret = $ClientSecret
    } elseif ($env:SHAREPOINT_CLIENT_SECRET) {
        $resolvedSecret = ConvertTo-SecureString $env:SHAREPOINT_CLIENT_SECRET -AsPlainText -Force
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
            Write-Verbose "Connecting to Microsoft Graph (interactive, SharePoint scopes)..."
            Connect-MgGraph -Scopes $script:SharePointScopes -ErrorAction Stop
            $script:AuthMode = 'Delegated'
        } else {
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

        # Optionally resolve site
        if ($SiteUrl) {
            $site = Get-MgSiteByHostName -SiteHostname ($SiteUrl -replace 'https?://([^/]+).*', '$1') `
                -RelativePath ($SiteUrl -replace 'https?://[^/]+(.*)', '$1') -ErrorAction SilentlyContinue
            if ($site) {
                $script:CurrentSiteId = $site.Id
                $script:CurrentSiteUrl = $SiteUrl
                Write-Verbose "Site resolved: $($site.DisplayName) ($SiteUrl)"
            }
        }

    } catch {
        $script:Connected = $false
        throw "Failed to connect to Microsoft Graph: $($_.Exception.Message)"
    }
}

# ==============================================================================
# Disconnect-SharePoint — Disconnect from Microsoft Graph
# ==============================================================================
function Disconnect-SharePoint {
    [CmdletBinding()]
    param()

    if (-not $script:Connected) {
        Write-Warning "Not connected to Microsoft Graph for SharePoint."
        return
    }

    try {
        Disconnect-MgGraph -ErrorAction SilentlyContinue
        $script:Connected = $false
        $script:AuthMode = $null
        $script:CurrentSiteId = $null
        $script:CurrentSiteUrl = $null
        Write-Verbose "Disconnected from Microsoft Graph (SharePoint)."
    } catch {
        Write-Warning "Error disconnecting: $($_.Exception.Message)"
    }
}

# ==============================================================================
# Get-SharePointSite — Get SharePoint site by URL
# ==============================================================================
function Get-SharePointSite {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SiteUrl
    )

    if (-not $script:Connected) {
        throw "Not connected. Run Connect-SharePoint first."
    }

    try {
        $hostname = ($SiteUrl -replace 'https?://([^/]+).*', '$1')
        $relativePath = ($SiteUrl -replace 'https?://[^/]+(.*)', '$1')
        if (-not $relativePath) { $relativePath = '/' }

        $site = Get-MgSiteByHostName -SiteHostname $hostname `
            -RelativePath $relativePath -ErrorAction Stop

        $script:CurrentSiteId = $site.Id
        $script:CurrentSiteUrl = $SiteUrl

        return $site

    } catch {
        throw "Failed to get SharePoint site: $($_.Exception.Message)"
    }
}

# ==============================================================================
# Get-SharePointList — Get items from a SharePoint list
# ==============================================================================
function Get-SharePointList {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ListName,

        [Parameter()]
        [string]$SiteId,

        [Parameter()]
        [string]$Filter,

        [Parameter()]
        [int]$Top = 100,

        [Parameter()]
        [switch]$All
    )

    if (-not $script:Connected) {
        throw "Not connected. Run Connect-SharePoint first."
    }

    if (-not $SiteId) { $SiteId = $script:CurrentSiteId }
    if (-not $SiteId) {
        throw "SiteId is required. Provide via -SiteId or connect with -SiteUrl."
    }

    try {
        $escapedName = ($ListName -replace "'", "''")
        $list = Get-MgSiteList -SiteId $SiteId -Filter "displayName eq '$escapedName'" -ErrorAction Stop
        if (-not $list) {
            throw "List '$ListName' not found on site."
        }

        $params = @{}
        if ($Filter) { $params['Filter'] = $Filter }
        if ($Top) { $params['Top'] = $Top }

        $items = Get-MgSiteListItem -SiteId $SiteId -ListId $list.Id @params -ErrorAction Stop

        if ($All) {
            $allItems = @()
            $page = $items
            while ($page) {
                $allItems += $page
                if ($page.'@odata.nextLink') {
                    $page = Invoke-MgGraphRequest -Uri $page.'@odata.nextLink' -Method GET
                    $page = $page.value
                } else {
                    $page = $null
                }
            }
            return $allItems
        }

        return $items

    } catch {
        throw "Failed to get list items: $($_.Exception.Message)"
    }
}

# ==============================================================================
# Add-SharePointListItem — Add item to a SharePoint list
# ==============================================================================
function Add-SharePointListItem {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$ListName,

        [Parameter(Mandatory)]
        [hashtable]$Fields,

        [Parameter()]
        [string]$SiteId
    )

    if (-not $script:Connected) {
        throw "Not connected. Run Connect-SharePoint first."
    }

    if (-not $SiteId) { $SiteId = $script:CurrentSiteId }
    if (-not $SiteId) {
        throw "SiteId is required. Provide via -SiteId or connect with -SiteUrl."
    }

    try {
        $escapedName = ($ListName -replace "'", "''")
        $list = Get-MgSiteList -SiteId $SiteId -Filter "displayName eq '$escapedName'" -ErrorAction Stop
        if (-not $list) {
            throw "List '$ListName' not found on site."
        }

        if ($PSCmdlet.ShouldProcess($ListName, "Add list item")) {
            $body = @{ fields = $Fields }
            $item = New-MgSiteListItem -SiteId $SiteId -ListId $list.Id -BodyParameter $body -ErrorAction Stop
            Write-Verbose "Item added to '$ListName': $($item.Id)"
            return $item
        }

    } catch {
        throw "Failed to add list item: $($_.Exception.Message)"
    }
}

# ==============================================================================
# Get-SharePointFile — Download a file from SharePoint
# ==============================================================================
function Get-SharePointFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SiteId,

        [Parameter(Mandatory)]
        [string]$DriveId,

        [Parameter(Mandatory)]
        [string]$FilePath,

        [Parameter(Mandatory)]
        [string]$OutputPath
    )

    if (-not $script:Connected) {
        throw "Not connected. Run Connect-SharePoint first."
    }

    try {
        # Get file content
        $fileStream = Get-MgSiteDriveItemContent -SiteId $SiteId -DriveId $DriveId `
            -DriveItemId $FilePath -ErrorAction Stop

        # Save to local path
        $outputDir = Split-Path $OutputPath -Parent
        if (-not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
        }

        $fileStream.CopyTo([System.IO.File]::Create($OutputPath))
        $fileStream.Close()

        Write-Verbose "File downloaded to: $OutputPath"

    } catch {
        throw "Failed to download file: $($_.Exception.Message)"
    }
}

# ==============================================================================
# Upload-SharePointFile — Upload a file to SharePoint
# ==============================================================================
function Upload-SharePointFile {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$SiteId,

        [Parameter(Mandatory)]
        [string]$DriveId,

        [Parameter(Mandatory)]
        [string]$FilePath,

        [Parameter(Mandatory)]
        [string]$DrivePath
    )

    if (-not $script:Connected) {
        throw "Not connected. Run Connect-SharePoint first."
    }

    if (-not (Test-Path $FilePath)) {
        throw "File not found: $FilePath"
    }

    try {
        if ($PSCmdlet.ShouldProcess($FilePath, "Upload to $DrivePath")) {
            $fileContent = [System.IO.File]::ReadAllBytes($FilePath)
            $fileName = Split-Path $FilePath -Leaf

            $item = New-MgSiteDriveItemContent -SiteId $SiteId -DriveId $DriveId `
                -DriveItemId $DrivePath -BodyParameter @{
                    "@microsoft.graph.conflictBehavior" = "rename"
                    name = $fileName
                    file = @{}
                    contentStream = @{
                        type = "binary"
                        content = $fileContent
                    }
                } -ErrorAction Stop

            Write-Verbose "File uploaded: $($item.Name) -> $DrivePath"
            return $item
        }

    } catch {
        throw "Failed to upload file: $($_.Exception.Message)"
    }
}

# ==============================================================================
# Export module members
# ==============================================================================
Export-ModuleMember -Function @(
    'Connect-SharePoint',
    'Disconnect-SharePoint',
    'Get-SharePointSite',
    'Get-SharePointList',
    'Add-SharePointListItem',
    'Get-SharePointFile',
    'Upload-SharePointFile'
)
