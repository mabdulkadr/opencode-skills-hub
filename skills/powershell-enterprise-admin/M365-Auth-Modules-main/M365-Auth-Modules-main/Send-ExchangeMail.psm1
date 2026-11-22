<#
.SYNOPSIS
    Send-ExchangeMail - Send email via Exchange Online using Microsoft Graph API (OAuth 2.0).

.DESCRIPTION
    PowerShell module that sends HTML email through Microsoft Graph API using Azure AD
    app-only authentication (client credentials flow). Designed for Azure AD
    app registration with Mail.Send permission. No SMTP, no basic auth, no legacy protocols.

    Exported command: Send-ExchangeMail

.EXAMPLE
    Import-Module .\Send-ExchangeMail.psm1
    Send-ExchangeMail -From "sender@your-domain.onmicrosoft.com" `
        -To "user@your-domain.com" `
        -Subject "Test" `
        -Body "<h1>Hello</h1>"

.EXAMPLE
    $pw = ConvertTo-SecureString "your-client-secret" -AsPlainText -Force
    Send-ExchangeMail -From "sender@your-domain.onmicrosoft.com" -To "user@your-domain.com" `
        -Subject "Report" -Body $html -ClientSecret $pw

.NOTES
    Author  : Mohammad Abdelkader
    Website : https://momar.tech
    Date    : 2025-06-01
    Version : 1.0

    Requirements:
      - Azure AD app with Mail.Send application permission
      - Admin consent granted for the app to send as the target mailbox
      - PowerShell 5.1+

    Secret resolution priority:
      1. -ClientSecret parameter
      2. $env:EXCHANGE_CLIENT_SECRET
      3. -ClientSecretDefault parameter

    Note: TenantId, ClientId, and ClientSecret must be provided via parameters or environment variables.

.CHANGELOG
    v1.0 (2025-06-01)
    - Initial release
    - OAuth 2.0 client credentials flow via Microsoft Graph
    - HTML body, CC/BCC, file attachments
    - Secret resolution: parameter > env var > embedded default
#>

# ==============================================================================
# Module-scoped default credentials — Override via parameters or $env variables
# ==============================================================================
# Example values (replace with your own)
$script:DefaultTenantId       = '00000000-0000-0000-0000-000000000000'   # Your Azure AD tenant ID
$script:DefaultClientId       = '00000000-0000-0000-0000-000000000000'   # Your Azure AD application (client) ID
$script:DefaultClientSecret   = 'REMOVED'   # Your secret (use $env:EXCHANGE_CLIENT_SECRET in production)

# ==============================================================================
# Acquire OAuth 2.0 access token via client credentials flow
# ==============================================================================
function Get-GraphAccessToken {
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
        Write-Error "Get-GraphAccessToken: $err"
        return $null
    }
}

# ==============================================================================
# Send email via Microsoft Graph /sendMail endpoint
# ==============================================================================
function Send-GraphMailMessage {
    param(
        [Parameter(Mandatory)] [string]$AccessToken,
        [Parameter(Mandatory)] [string]$From,
        [Parameter(Mandatory)] [string[]]$To,
        [Parameter(Mandatory)] [string]$Subject,
        [Parameter(Mandatory)] [string]$Body,
        [string[]]$Cc = @(),
        [string[]]$Bcc = @(),
        [string[]]$Attachments = @(),
        [switch]$SaveToSentItems
    )

    $recipients = @($To | ForEach-Object { @{ emailAddress = @{ address = $_ } } })
    $ccRecipients = @($Cc | ForEach-Object { @{ emailAddress = @{ address = $_ } } })
    $bccRecipients = @($Bcc | ForEach-Object { @{ emailAddress = @{ address = $_ } } })

    $message = @{
        subject      = $Subject
        body         = @{ contentType = 'HTML'; content = $Body }
        toRecipients = $recipients
        from         = @{ emailAddress = @{ address = $From } }
    }

    if ($ccRecipients.Count -gt 0) {
        $message.ccRecipients = $ccRecipients
    }

    if ($bccRecipients.Count -gt 0) {
        $message.bccRecipients = $bccRecipients
    }

    if ($Attachments.Count -gt 0) {
        $fileAttachments = @()
        foreach ($attPath in $Attachments) {
            if (Test-Path -LiteralPath $attPath) {
                $resolved = (Resolve-Path -LiteralPath $attPath).ProviderPath
                $bytes = [System.IO.File]::ReadAllBytes($resolved)
                $fileAttachments += @{
                    '@odata.type' = '#microsoft.graph.fileAttachment'
                    name          = [System.IO.Path]::GetFileName($resolved)
                    contentType   = 'application/octet-stream'
                    contentBytes  = [System.Convert]::ToBase64String($bytes)
                }
            } else {
                Write-Error "Send-GraphMailMessage: Attachment not found: $attPath"
            }
        }
        if ($fileAttachments.Count -gt 0) {
            $message.attachments = $fileAttachments
        }
    }

    $payload = @{
        message         = $message
        saveToSentItems = [bool]$SaveToSentItems
    } | ConvertTo-Json -Depth 5 -Compress

    $headers = @{
        Authorization  = "Bearer $AccessToken"
        'Content-Type' = 'application/json'
    }

    $sendUrl = "https://graph.microsoft.com/v1.0/users/$From/sendMail"
    try {
        Invoke-RestMethod -Method Post -Uri $sendUrl -Headers $headers `
            -Body ([System.Text.Encoding]::UTF8.GetBytes($payload)) `
            -ContentType 'application/json; charset=utf-8' -ErrorAction Stop
        return $true
    } catch {
        Write-Error "Send-GraphMailMessage: $($_.Exception.Message)"
        return $false
    }
}

# ==============================================================================
# Public function: resolve secret, get token, send email
# ==============================================================================
function Send-ExchangeMail {
    <#
    .SYNOPSIS
        Send an HTML email via Exchange Online using Azure AD app-only OAuth.

    .DESCRIPTION
        Resolves the client secret (parameter > env var > default), acquires an
        OAuth 2.0 access token from Azure AD, and sends the email via Microsoft Graph.

    .PARAMETER From
        Sender email address. Must be a mailbox the app has permission to send as.

    .PARAMETER To
        Recipient email address(es).

    .PARAMETER Subject
        Email subject line.

    .PARAMETER Body
        HTML email body content.

    .PARAMETER Cc
        CC recipient email address(es).

    .PARAMETER Bcc
        BCC recipient email address(es).

    .PARAMETER Attachments
        Path(s) to local file(s) to attach to the email (sent as fileAttachment via Graph).

    .PARAMETER TenantId
        Azure AD tenant ID. Uses embedded default if omitted.

    .PARAMETER ClientId
        Azure AD application (client) ID. Uses embedded default if omitted.

    .PARAMETER ClientSecret
        Client secret as SecureString. Falls back to env var or embedded default.

    .PARAMETER ClientSecretDefault
        Plaintext fallback client secret when param and env var are both empty.

    .PARAMETER SaveToSentItems
        Save the sent email to the sender's Sent Items folder.

    .EXAMPLE
        Send-ExchangeMail -From "sender@your-domain.onmicrosoft.com" `
            -To "user@your-domain.com" `
            -Subject "OSD Report" -Body $htmlBody

    .EXAMPLE
        Send-ExchangeMail -From "noreply@your-domain.com" -To "it@your-domain.com" `
            -Subject "Daily Report" -Body $report `
            -TenantId "xxx" -ClientId "yyy" -ClientSecret $sec
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$From,
        [Parameter(Mandatory)] [string[]]$To,
        [Parameter(Mandatory)] [string]$Subject,
        [Parameter(Mandatory)] [string]$Body,
        [string[]]$Cc = @(),
        [string[]]$Bcc = @(),
        [string[]]$Attachments = @(),
        [switch]$SaveToSentItems,

        [string]$TenantId,
        [string]$ClientId,
        [securestring]$ClientSecret,
        [string]$ClientSecretDefault
    )

    $tenant = if ($TenantId) { $TenantId } else { $script:DefaultTenantId }
    $client = if ($ClientId) { $ClientId } else { $script:DefaultClientId }

    $secret = $ClientSecret
    if (-not $secret -and $env:EXCHANGE_CLIENT_SECRET) {
        $secret = ConvertTo-SecureString $env:EXCHANGE_CLIENT_SECRET -AsPlainText -Force
    }
    if (-not $secret) {
        $plainDefault = if ($ClientSecretDefault) { $ClientSecretDefault } else { $script:DefaultClientSecret }
        if ($plainDefault) {
            $secret = ConvertTo-SecureString $plainDefault -AsPlainText -Force
        }
    }
    if (-not $secret) {
        Write-Error "Send-ExchangeMail: No client secret provided. Use -ClientSecret, `$env:EXCHANGE_CLIENT_SECRET, or -ClientSecretDefault."
        return $false
    }

    Write-Verbose "Acquiring token: Tenant=$tenant Client=$client"
    $token = Get-GraphAccessToken -TenantId $tenant -ClientId $client -ClientSecret $secret
    if (-not $token) {
        Write-Error "Send-ExchangeMail: Failed to acquire Graph access token."
        return $false
    }

    Write-Verbose "Sending email From=$From To=$($To -join ',') Subject='$Subject'"
    $params = @{
        AccessToken     = $token
        From            = $From
        To              = $To
        Subject         = $Subject
        Body            = $Body
        Cc              = $Cc
        Bcc             = $Bcc
        Attachments     = $Attachments
        SaveToSentItems = $SaveToSentItems
    }
    return Send-GraphMailMessage @params
}

# ==============================================================================
# Export only the public function
# ==============================================================================
Export-ModuleMember -Function 'Send-ExchangeMail'
