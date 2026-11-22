<#
.SYNOPSIS
    Connect-EXOSession - Connect to Exchange Online and Security & Compliance Center.

.DESCRIPTION
    PowerShell module that authenticates to Exchange Online (EXO) and the Security &
    Compliance Center (IPPS) using the ExchangeOnlineManagement module. Supports
    certificate-based app-only authentication (recommended for automation) and
    interactive user login.

    Exported commands:
      Connect-EXOSession     - Connect to EXO and IPPS
      Disconnect-EXOSession  - Disconnect from EXO and IPPS

.EXAMPLE
    Import-Module .\Connect-ExchangeOnline.psm1
    Connect-EXOSession
    Get-QuarantineMessage -PageSize 10
    Disconnect-EXOSession

.EXAMPLE
    Connect-EXOSession -CertificateThumbprint "your-cert-thumbprint" -Interactive

.NOTES
    Requirements:
      - ExchangeOnlineManagement module (auto-installed if missing)
      - PowerShell 5.1+
      - Azure AD app with Exchange application permissions

    Auth resolution priority (app-only):
      1. -CertificateThumbprint parameter
      2. $env:EXO_CERT_THUMBPRINT environment variable

    Note: TenantId, AppId, CertificateThumbprint, and Organization must be provided via parameters or environment variables.
#>

# ==============================================================================
# Module state
# ==============================================================================
$script:Connected = $false
$script:AuthMode = $null

# ==============================================================================
# Module-scoped defaults — Override via parameters or $env variables
# ==============================================================================
# Example values (replace with your own)
$script:DefaultTenantId             = '00000000-0000-0000-0000-000000000000'   # Your Azure AD tenant ID
$script:DefaultAppId                = '00000000-0000-0000-0000-000000000000'   # Your Azure AD application (client) ID
$script:DefaultCertificateThumbprint = 'F4E5D6C7-B8A9-0123-4567-89ABCDEF0123'  # Your certificate thumbprint (use $env:EXO_CERT_THUMBPRINT in production)
$script:DefaultOrganization         = 'your-domain.com'                       # Your organization domain

# ==============================================================================
# Ensure ExchangeOnlineManagement is available
# ==============================================================================
function Install-EXOModule {
    if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
        Write-Verbose "Installing ExchangeOnlineManagement module..."
        try {
            Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser `
                -Repository PSGallery -Force -ErrorAction Stop
        } catch {
            Write-Error "Failed to install ExchangeOnlineManagement: $($_.Exception.Message)"
            return $false
        }
    }
    Import-Module ExchangeOnlineManagement -Force -ErrorAction Stop
    return $true
}

# ==============================================================================
# Connect-EXOSession - Public: connect to EXO and IPPS
# ==============================================================================
function Connect-EXOSession {
    <#
    .SYNOPSIS
        Connect to Exchange Online and Security & Compliance Center.

    .DESCRIPTION
        Authenticates to Exchange Online (EXO) and the Security & Compliance Center
        (IPPS) using certificate-based app-only auth or interactive login. Automatically
        installs the ExchangeOnlineManagement module if missing.

    .PARAMETER AppId
        Azure AD application (client) ID. Uses embedded default if omitted.

    .PARAMETER TenantId
        Azure AD tenant ID. Uses embedded default if omitted.

    .PARAMETER CertificateThumbprint
        Certificate thumbprint for app-only auth. Falls back to env var or embedded default.

    .PARAMETER Organization
        Organization domain (e.g., your-domain.com). Uses embedded default if omitted.

    .PARAMETER Interactive
        Switch to use interactive user login instead of certificate auth.

    .PARAMETER SkipIPPS
        Skip connecting to the Security & Compliance Center (IPPS).

    .PARAMETER ShowBanner
        Show the ExchangeOnlineManagement banner (default: hidden).

    .EXAMPLE
        Connect-EXOSession

    .EXAMPLE
        Connect-EXOSession -Interactive

    .EXAMPLE
        Connect-EXOSession -CertificateThumbprint "your-cert-thumbprint" -Organization "your-domain.com"
    #>
    [CmdletBinding()]
    param(
        [string]$AppId,
        [string]$TenantId,
        [string]$CertificateThumbprint,
        [string]$Organization,
        [switch]$Interactive,
        [switch]$SkipIPPS,
        [switch]$ShowBanner
    )

    # Install EXO module if needed
    $moduleReady = Install-EXOModule
    if (-not $moduleReady) { return $false }

    $appIdVal    = if ($AppId) { $AppId } else { $script:DefaultAppId }
    $tenantVal   = if ($TenantId) { $TenantId } else { $script:DefaultTenantId }
    $orgVal      = if ($Organization) { $Organization } else { $script:DefaultOrganization }
    $thumbVal    = $CertificateThumbprint

    # Resolve certificate thumbprint
    if (-not $thumbVal -and $env:EXO_CERT_THUMBPRINT) {
        $thumbVal = $env:EXO_CERT_THUMBPRINT
    }
    if (-not $thumbVal -and -not $Interactive) {
        $thumbVal = $script:DefaultCertificateThumbprint
    }

    # Ensure TLS 1.2
    try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

    $bannerOpt = if ($ShowBanner) { $true } else { $false }

    try {
        if ($Interactive) {
            # Interactive user login
            Write-Verbose "Connecting to Exchange Online (interactive)..."
            ExchangeOnlineManagement\Connect-ExchangeOnline -ShowBanner:$bannerOpt -ErrorAction Stop
            Write-Verbose "Connected to Exchange Online (interactive)."
        } else {
            # Certificate-based app-only auth
            Write-Verbose "Connecting to Exchange Online (app-only, cert=$thumbVal)..."
            ExchangeOnlineManagement\Connect-ExchangeOnline `
                -AppId $appIdVal `
                -CertificateThumbprint $thumbVal `
                -Organization $orgVal `
                -ShowBanner:$bannerOpt `
                -ErrorAction Stop
            Write-Verbose "Connected to Exchange Online (app-only, org=$orgVal)."
        }

        # Connect to Security & Compliance Center (IPPS)
        if (-not $SkipIPPS) {
            if ($Interactive) {
                Write-Verbose "Connecting to Security & Compliance Center (interactive)..."
                Connect-IPPSSession -ShowBanner:$bannerOpt -ErrorAction Stop
            } else {
                Write-Verbose "Connecting to Security & Compliance Center (app-only)..."
                Connect-IPPSSession `
                    -AppId $appIdVal `
                    -CertificateThumbprint $thumbVal `
                    -Organization $orgVal `
                    -ShowBanner:$bannerOpt `
                    -ErrorAction Stop
            }
            Write-Verbose "Connected to Security & Compliance Center."
        }

        # Store connection state
        $script:Connected = $true
        $script:AuthMode = if ($Interactive) { 'Interactive' } else { 'AppOnly' }

        return $true
    } catch {
        $msg = $_.Exception.Message
        if ($msg -match 'AADSTS700016') {
            Write-Error "Connect-EXOSession: Wrong AppId or app not found in tenant."
        } elseif ($msg -match 'AADSTS7000215') {
            Write-Error "Connect-EXOSession: Invalid client secret/certificate. Check Azure AD app."
        } elseif ($msg -match 'Access is denied|Forbidden') {
            Write-Error "Connect-EXOSession: Access denied. Check app permissions and admin consent."
        } elseif ($msg -match 'certificate') {
            Write-Error "Connect-EXOSession: Certificate not found or invalid. Verify thumbprint."
        } else {
            Write-Error "Connect-EXOSession: $msg"
        }
        return $false
    }
}

# ==============================================================================
# Disconnect-EXOSession - Public: disconnect from EXO and IPPS
# ==============================================================================
function Disconnect-EXOSession {
    <#
    .SYNOPSIS
        Disconnect from Exchange Online and Security & Compliance Center.

    .DESCRIPTION
        Ends all Exchange Online and IPPS sessions and clears connection state.

    .PARAMETER SkipIPPS
        Skip disconnecting from the Security & Compliance Center.

    .EXAMPLE
        Disconnect-EXOSession
    #>
    [CmdletBinding()]
    param(
        [switch]$SkipIPPS
    )

    try {
        ExchangeOnlineManagement\Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
        Write-Verbose "Disconnected from Exchange Online."
    } catch {
        Write-Warning "Disconnect-EXOSession (EXO): $($_.Exception.Message)"
    }

    if (-not $SkipIPPS) {
        try {
            Disconnect-IPPSSession -Confirm:$false -ErrorAction SilentlyContinue
            Write-Verbose "Disconnected from Security & Compliance Center."
        } catch {
            Write-Warning "Disconnect-EXOSession (IPPS): $($_.Exception.Message)"
        }
    }

    $script:Connected = $false
    $script:AuthMode = $null
}

# ==============================================================================
# Export public functions
# ==============================================================================
Export-ModuleMember -Function @(
    'Connect-EXOSession',
    'Disconnect-EXOSession'
)
