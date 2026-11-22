<#
.TITLE
    PSWrap Certificate Signing Module (CertSign)

.SYNOPSIS
    Generates self-signed Root CA + Code Signing certs and signs executables.

.DESCRIPTION
    Generates a self-signed Root CA + Code Signing certificate chain using
    pure .NET cryptography (no external dependencies), and signs PE executables
    with Authenticode signatures including optional RFC 3161 timestamping.

.TAGS
    Certificate,Signing,Authenticode,PKI,CA

.MINROLE
    Administrator

.PERMISSIONS
    - File system: write to PSWrap/cert/ directory
    - Admin: required for TrustRoot (install CA to Trusted Root)

.AUTHOR
    admin

.VERSION
    1.0.0

.CHANGELOG
    1.0.0 - Initial release

.LASTUPDATE
    2026-06-17

.EXAMPLE
    Invoke-CertSetup
    Generates Root CA and Code Signing certificate chain.

.EXAMPLE
    Invoke-SignFile -ExePath "C:\output.exe"
    Signs an existing executable with the generated certificate.

.NOTES
    - Certificates are stored in PSWrap/cert/ directory
    - PFX password is hardcoded as 'PsWrapCert'
    - CA is valid for 1000 days, signing cert for 398 days
    - Admin rights required for TrustRoot option
#>

$script:CertCaPath  = Join-Path $script:RootDir 'cert\PsWrapCert.ca.crt'
$script:CertPfxPath = Join-Path $script:RootDir 'cert\PsWrapCert.sign.pfx'
$script:CertPfxPass = 'PsWrapCert'

function New-CapiRsaKey {
    <#
    .SYNOPSIS
        Creates an ephemeral CAPI RSA key pair using Microsoft Enhanced RSA provider.
    .DESCRIPTION
        Generates a new RSA key pair through the legacy CAPI cryptographic service provider
        with ephemeral key creation flags. Used internally by Invoke-CertSetup to create
        CA and signing certificate keys.
    .PARAMETER KeySize
        RSA key size in bits. Default is 2048.
    .OUTPUTS
        System.Security.Cryptography.RSACryptoServiceProvider. An ephemeral RSA key pair.
    #>
    [CmdletBinding()]
    param([int]$KeySize = 2048)
    $csp = New-Object System.Security.Cryptography.CspParameters
    $csp.ProviderType = 24
    $csp.KeyNumber = [System.Security.Cryptography.KeyNumber]::Signature
    $csp.Flags = [System.Security.Cryptography.CspProviderFlags]::CreateEphemeralKey
    return New-Object System.Security.Cryptography.RSACryptoServiceProvider($KeySize, $csp)
}

function Invoke-CertSetup {
    <#
    .SYNOPSIS
        Generates a self-signed Root CA and Code Signing certificate chain.
    .DESCRIPTION
        Creates a complete PKI certificate chain using pure .NET cryptography:
        a self-signed Root CA (1000 days) and a subordinate Code Signing certificate
        (398 days) signed by the CA. Both certificates are exported to the PSWrap/cert/
        directory as .crt and .pfx files respectively.
    .OUTPUTS
        System.Boolean. Returns $true on success.
    #>
    Add-LogLine -Message '=== Certificate Setup Started ===' -Level 'INFO'
    $certDir = Split-Path $script:CertCaPath -Parent
    if (-not (Test-Path $certDir)) { New-Item -ItemType Directory -Path $certDir -Force | Out-Null }

    $caKey = New-CapiRsaKey
    $caSubject = "CN=PsWrapCert CA, O=PsWrapCert, L=Austin, S=Texas, C=US"
    $caSubjectDN = New-Object System.Security.Cryptography.X509Certificates.X500DistinguishedName($caSubject)
    $caReq = [System.Security.Cryptography.X509Certificates.CertificateRequest]::new($caSubjectDN, $caKey, [System.Security.Cryptography.HashAlgorithmName]::SHA256, [System.Security.Cryptography.RSASignaturePadding]::Pkcs1)
    $caReq.CertificateExtensions.Add([System.Security.Cryptography.X509Certificates.X509BasicConstraintsExtension]::new($true, $false, 0, $true)) | Out-Null
    $caReq.CertificateExtensions.Add([System.Security.Cryptography.X509Certificates.X509KeyUsageExtension]::new([System.Security.Cryptography.X509Certificates.X509KeyUsageFlags]::KeyCertSign -bor [System.Security.Cryptography.X509Certificates.X509KeyUsageFlags]::CrlSign, $true)) | Out-Null
    $caReq.CertificateExtensions.Add([System.Security.Cryptography.X509Certificates.X509SubjectKeyIdentifierExtension]::new($caReq.PublicKey, $false)) | Out-Null
    $caCert = $caReq.CreateSelfSigned([System.DateTimeOffset]::Now, [System.DateTimeOffset]::Now.AddDays(1000))
    Add-LogLine -Message "  CA cert: $caSubject (1000 days)" -Level 'SUCCESS'

    $signKey = New-CapiRsaKey
    $signSubject = "CN=PsWrapCert Code Signing, O=PsWrapCert, L=Austin, S=Texas, C=US"
    $signSubjectDN = New-Object System.Security.Cryptography.X509Certificates.X500DistinguishedName($signSubject)
    $signReq = [System.Security.Cryptography.X509Certificates.CertificateRequest]::new($signSubjectDN, $signKey, [System.Security.Cryptography.HashAlgorithmName]::SHA256, [System.Security.Cryptography.RSASignaturePadding]::Pkcs1)
    # DigitalSignature and KeyEncipherment usage flags
    $signReq.CertificateExtensions.Add([System.Security.Cryptography.X509Certificates.X509KeyUsageExtension]::new([System.Security.Cryptography.X509Certificates.X509KeyUsageFlags]::DigitalSignature, $true)) | Out-Null
    $ekuOids = New-Object System.Security.Cryptography.OidCollection
    # 1.3.6.1.5.5.7.3.3 = Code Signing purpose
    $null = $ekuOids.Add([System.Security.Cryptography.Oid]::new('1.3.6.1.5.5.7.3.3', 'Code Signing'))
    $signReq.CertificateExtensions.Add([System.Security.Cryptography.X509Certificates.X509EnhancedKeyUsageExtension]::new($ekuOids, $true)) | Out-Null
    $signReq.CertificateExtensions.Add([System.Security.Cryptography.X509Certificates.X509SubjectKeyIdentifierExtension]::new($signReq.PublicKey, $false)) | Out-Null
    $serialBytes = New-Object byte[] 8; $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create(); $rng.GetBytes($serialBytes)
    $signCertPub = $signReq.Create($caCert.SubjectName, [System.Security.Cryptography.X509Certificates.X509SignatureGenerator]::CreateForRSA($caKey, [System.Security.Cryptography.RSASignaturePadding]::Pkcs1), [System.DateTimeOffset]::Now, [System.DateTimeOffset]::Now.AddDays(398), $serialBytes)
    $signCert = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::CopyWithPrivateKey($signCertPub, $signKey)
    Add-LogLine -Message "  Signing cert: $signSubject (398 days)" -Level 'SUCCESS'

    $caBytes = $caCert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
    [System.IO.File]::WriteAllBytes($script:CertCaPath, $caBytes)
    $pfxBytes = $signCert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12, $script:CertPfxPass)
    [System.IO.File]::WriteAllBytes($script:CertPfxPath, $pfxBytes)

    $caKey.Dispose(); $signKey.Dispose(); $caCert.Dispose(); $signCert.Dispose(); $signCertPub.Dispose()
    if ($rng) { $rng.Dispose() }
    Add-LogLine -Message "  Exported: PsWrapCert.ca.crt, PsWrapCert.sign.pfx" -Level 'SUCCESS'
    Add-LogLine -Message '=== Certificate Setup Complete ===' -Level 'SUCCESS'
    return $true
}

function Invoke-CertSign {
    <#
    .SYNOPSIS
        Signs a PE executable with an Authenticode signature using the generated certificate.
    .DESCRIPTION
        Loads the code signing certificate from the PSWrap/cert/ directory, validates
        the target file as a valid PE executable (MZ header), handles file locking with
        automatic retry, and applies an Authenticode signature. Optionally timestamps the
        signature and trusts the Root CA for validation.
    .PARAMETER TargetExe
        Path to the PE executable (.exe, .dll) to sign with Authenticode.
    .PARAMETER TrustRoot
        If specified, imports the Root CA into the Local Machine Trusted Root store
        (requires Administrator privileges).
    .PARAMETER TimestampServer
        RFC 3161 timestamp server URL for countersigning. When specified, the signature
        remains valid after the code signing certificate expires.
    .OUTPUTS
        System.Boolean. Returns $true on success, $false on failure.
    #>
    param([string]$TargetExe, [switch]$TrustRoot, [string]$TimestampServer)
    if (-not (Test-Path $script:CertPfxPath) -or -not (Test-Path $script:CertCaPath)) { Add-LogLine -Message '  Certificate files not found. Run Setup first.' -Level 'ERROR'; return $false }
    # Validate PE executable format (MZ magic number)
    try { $peBytes = [System.IO.File]::ReadAllBytes($TargetExe); if ($peBytes.Length -lt 64 -or [System.Text.Encoding]::ASCII.GetString($peBytes, 0, 2) -ne 'MZ') { Add-LogLine -Message "  Not a valid PE executable (missing MZ header)" -Level 'ERROR'; return $false } }
    catch { Add-LogLine -Message "  Cannot read file: $_" -Level 'ERROR'; return $false }
    Add-LogLine -Message '  Loading certificate...' -Level 'INFO'
    # PersistKeySet + MachineKeySet + Exportable for signing access
    $keyFlags = [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet -bor [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::MachineKeySet -bor [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable
    $signCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($script:CertPfxPath, $script:CertPfxPass, $keyFlags)
    Add-LogLine -Message "  Signer: $($signCert.Subject)" -Level 'INFO'
    Add-LogLine -Message '  Importing CA to Intermediate store...' -Level 'INFO'
    # Import CA to user intermediate CA store for chain validation
    try { Import-Certificate -FilePath $script:CertCaPath -CertStoreLocation Cert:\CurrentUser\CA\ -ErrorAction Stop | Out-Null } catch { Add-LogLine -Message "  CA already in store or import failed: $_" -Level 'WARNING' }
    Add-LogLine -Message '  Waiting for file to be available...' -Level 'INFO'
    $fileReady = $false
    # Retry up to 30 times if file is locked (1s intervals)
    for ($attempt = 1; $attempt -le 30; $attempt++) {
        try {
            $fs = [System.IO.File]::Open($TargetExe, 'Open', 'ReadWrite', 'None')
            $fs.Close(); $fs.Dispose()
            $fileReady = $true
            break
        } catch {
            if ($attempt -lt 30) {
                Add-LogLine -Message "  File locked (attempt $attempt/30), retrying in 1s..." -Level 'WARNING'
                Start-Sleep -Seconds 1
            }
        }
    }
    if (-not $fileReady) {
        Add-LogLine -Message '  File remains locked after 30 attempts. Proceeding anyway...' -Level 'WARNING'
    }
    Add-LogLine -Message '  Signing...' -Level 'INFO'
    $sigParams = @{ Certificate=$signCert; FilePath=$TargetExe; IncludeChain='All'; Force=$true }
    if ($TimestampServer) { $sigParams.TimestampServer = $TimestampServer }
    try { Set-AuthenticodeSignature @sigParams -ErrorAction Stop; Add-LogLine -Message '  Signing completed.' -Level 'SUCCESS' }
    catch { Add-LogLine -Message "  Signing failed: $_" -Level 'ERROR'; return $false }
    $sigResult = Get-AuthenticodeSignature -FilePath $TargetExe
    Add-LogLine -Message "  Signature status: $($sigResult.Status)" -Level 'INFO'
    if ($TrustRoot) {
        try { Import-Certificate -FilePath $script:CertCaPath -CertStoreLocation Cert:\LocalMachine\Root\ -ErrorAction Stop | Out-Null; Add-LogLine -Message '  CA trusted.' -Level 'SUCCESS' } catch { Add-LogLine -Message "  Could not trust CA (run as admin): $_" -Level 'WARNING' }
        $sigResult = Get-AuthenticodeSignature -FilePath $TargetExe; Add-LogLine -Message "  Signature status after trust: $($sigResult.Status)" -Level 'INFO'
    }
    return $true
}
