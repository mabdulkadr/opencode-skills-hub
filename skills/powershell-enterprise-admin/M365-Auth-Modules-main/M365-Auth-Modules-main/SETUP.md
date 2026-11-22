# 🛠 M365 Auth Modules — Azure AD App Registration Guide

> Part of **[M365 Auth Modules](README.md)** — centralized OAuth 2.0 + Certificate-based Microsoft 365 authentication.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)
![Azure AD](https://img.shields.io/badge/Azure%20AD-App%20Registration-0078D6.svg)
![Auth](https://img.shields.io/badge/Auth-OAuth%202.0%20%2B%20Cert-2ea44f.svg)
![Version](https://img.shields.io/badge/version-1.1-green.svg)

---

## 📖 Overview

This guide walks you through creating **Azure AD App Registrations** for each module of **M365 Auth Modules**. Each module requires its own app registration (or a shared one with combined permissions) to authenticate via **OAuth 2.0** or **Certificate-based auth**.

> ⚠️ **Important:** Microsoft is deprecating SMTP AUTH Basic Authentication. OAuth 2.0 via Microsoft Graph is the **future-proof** authentication method. See the [Microsoft announcement](https://learn.microsoft.com/en-us/exchange/mail-flow-best-practices/remote-domain-articles-auth-and-undeliverable-email-organization-settings#smtp-auth) for details.

---

## 🧭 Table of Contents

- [📦 Module Overview](#-module-overview)
- [🔧 Common Setup Steps](#-common-setup-steps)
- [1️⃣ Connect-Intune App Registration](#1️⃣-connect-intune-app-registration)
- [2️⃣ Send-ExchangeMail App Registration](#2️⃣-send-exchangemail-app-registration)
- [3️⃣ Connect-ExchangeOnline App Registration](#3️⃣-connect-exchangeonline-app-registration)
- [4️⃣ Connect-Teams App Registration](#4️⃣-connect-teams-app-registration)
- [5️⃣ Connect-SharePoint App Registration](#5️⃣-connect-sharepoint-app-registration)
- [6️⃣ Connect-MgGraph App Registration](#6️⃣-connect-mggraph-app-registration)
- [🔐 Shared App (All Modules)](#-shared-app-all-modules)
- [📋 Admin Consent](#-admin-consent)
- [🔑 Creating Client Secrets](#-creating-client-secret)
- [📜 Creating Certificates](#-creating-certificates)
- [✅ Verification Steps](#-verification-steps)
- [🐛 Troubleshooting](#-troubleshooting)

---

## 📦 Module Overview

| Module | Auth Method | App Registration Needed | Key Permission |
|---|---|---|---|
| `Connect-Intune` | OAuth 2.0 (Client Credentials) | ✅ Yes | `DeviceManagementManagedDevices.ReadWrite.All` |
| `Send-ExchangeMail` | OAuth 2.0 (Client Credentials) | ✅ Yes | `Mail.Send` |
| `Connect-ExchangeOnline` | Certificate-based Auth | ✅ Yes | `Exchange.ManageAsApp` |
| `Connect-Teams` | OAuth 2.0 (Client Credentials) | ✅ Yes | `Team.ReadBasic.All` |
| `Connect-SharePoint` | OAuth 2.0 (Client Credentials) | ✅ Yes | `Sites.ReadWrite.All` |
| `Connect-MgGraph` | OAuth 2.0 (Client Credentials) | ✅ Yes | `User.Read.All` |

---

## 🔧 Common Setup Steps

These steps apply to **all** app registrations:

### Step 1: Open Azure Portal

1. Go to [https://portal.azure.com](https://portal.azure.com)
2. Sign in with your **Global Admin** or **Application Admin** account

### Step 2: Navigate to App Registrations

1. In the search bar, type **"App registrations"**
2. Click on **App registrations** under **Azure Active Directory**

### Step 3: Register a New Application

1. Click **+ New registration**
2. Enter a **Name** (e.g., `Intune-PowerShell-Module`)
3. Under **Supported account types**, select:
   - **Accounts in this organizational directory only** (Single tenant)
4. Click **Register**

### Step 4: Note Your Application IDs

After registration, copy and save these values:

| Value | Where to Find | Used By |
|---|---|---|
| **Application (client) ID** | Overview page → `Application (client) ID` | All modules |
| **Directory (tenant) ID** | Overview page → `Directory (tenant) ID` | All modules |
| **Object ID** | Overview page → `Object ID` | Reference only |

---

## 1️⃣ Connect-Intune App Registration

### App Name Suggestion
```
Intune-PowerShell-Module
```

### Required API Permissions

| Permission | Type | Purpose |
|---|---|---|
| `DeviceManagementManagedDevices.ReadWrite.All` | Application | Read/write managed devices |
| `DeviceManagementConfiguration.ReadWrite.All` | Application | Read/write device configurations |
| `DeviceManagementManagedDevices.PrivilegedOperations.All` | Application | Remote actions (sync, wipe, etc.) |
| `Directory.Read.All` | Application | Read directory data |
| `Domain.Read.All` | Application | Read domain information |
| `CloudPC.ReadWrite.All` | Application | Read/write Cloud PC (optional) |

### Step-by-Step: Adding Permissions

1. Go to your **App Registration** → **API permissions**
2. Click **+ Add a permission**
3. Select **Microsoft Graph**
4. Select **Application permissions** (NOT Delegated)
5. Search and add each permission:

```
✅ DeviceManagementManagedDevices.ReadWrite.All
✅ DeviceManagementConfiguration.ReadWrite.All
✅ DeviceManagementManagedDevices.PrivilegedOperations.All
✅ Directory.Read.All
✅ Domain.Read.All
```

6. Click **Add permissions**
7. Click **Grant admin consent for [Your Organization]**
8. Verify all permissions show ✅ green checkmarks

### Step-by-Step: Creating a Client Secret

1. Go to **App Registration** → **Certificates & secrets**
2. Click **+ New client secret**
3. Enter a description (e.g., `PowerShell Module Secret`)
4. Select expiration: **24 months** (recommended)
5. Click **Add**
6. **IMMEDIATELY** copy the **Value** (not the Secret ID)
7. Save it securely — **it won't be shown again**

> ⚠️ The secret value is only shown once. Copy it immediately.

### Setting the Environment Variable

```powershell
# Option 1: Current session only
$env:INTUNE_CLIENT_SECRET = "your-client-secret-value"

# Option 2: User-level persistent (survives restart)
[Environment]::SetEnvironmentVariable("INTUNE_CLIENT_SECRET", "your-client-secret-value", "User")

# Option 3: System-level (requires admin)
[Environment]::SetEnvironmentVariable("INTUNE_CLIENT_SECRET", "your-client-secret-value", "Machine")
```

### Using with the Module

```powershell
$env:INTUNE_CLIENT_SECRET = "your-secret"

Import-Module .\Connect-Intune.psm1
Connect-Intune -TenantId "your-tenant-id" -ClientId "your-app-id"
```

---

## 2️⃣ Send-ExchangeMail App Registration

### App Name Suggestion
```
ExchangeMail-Graph-PowerShell
```

### Required API Permissions

| Permission | Type | Purpose |
|---|---|---|
| `Mail.Send` | Application | Send email as any mailbox in the tenant |

### Step-by-Step: Adding Permissions

1. Go to your **App Registration** → **API permissions**
2. Click **+ Add a permission**
3. Select **Microsoft Graph**
4. Select **Application permissions**
5. Search and add:

```
✅ Mail.Send
```

6. Click **Add permissions**
7. Click **Grant admin consent for [Your Organization]**
8. Verify the permission shows ✅ green checkmark

### Step-by-Step: Creating a Client Secret

1. Go to **App Registration** → **Certificates & secrets**
2. Click **+ New client secret**
3. Enter a description (e.g., `Graph Email Secret`)
4. Select expiration: **24 months** (recommended)
5. Click **Add**
6. **IMMEDIATELY** copy the **Value**
7. Save it securely

### Additional: Grant "Send As" Permission

The app needs permission to send as the specific mailbox:

1. Go to **Exchange Admin Center** → [https://admin.exchange.microsoft.com](https://admin.exchange.microsoft.com)
2. Navigate to **Recipients** → **Mailboxes**
3. Select the mailbox you want to send as (e.g., `noreply@your-domain.com`)
4. Click **Delegation**
5. Under **Send as**, click **Edit**
6. Add your **App Registration** name
7. Click **Save**

### Setting the Environment Variable

```powershell
# Option 1: Current session only
$env:EXCHANGE_CLIENT_SECRET = "your-client-secret-value"

# Option 2: User-level persistent
[Environment]::SetEnvironmentVariable("EXCHANGE_CLIENT_SECRET", "your-client-secret-value", "User")
```

### Using with the Module

```powershell
$env:EXCHANGE_CLIENT_SECRET = "your-secret"

Import-Module .\Send-ExchangeMail.psm1
Send-ExchangeMail -From "noreply@your-domain.com" `
    -To "user@your-domain.com" `
    -Subject "Report" `
    -Body "<h1>Hello</h1>" `
    -TenantId "your-tenant-id" `
    -ClientId "your-app-id"
```

---

## 3️⃣ Connect-ExchangeOnline App Registration

### App Name Suggestion
```
ExchangeOnline-CertAuth-PowerShell
```

### Required API Permissions

| Permission | Type | Purpose |
|---|---|---|
| `Exchange.ManageAsApp` | Application | Manage Exchange Online as app |

### Step-by-Step: Adding Permissions

1. Go to your **App Registration** → **API permissions**
2. Click **+ Add a permission**
3. Select **APIs my organization uses**
4. Search for **"Exchange"**
5. Select **Office 365 Exchange Online**
6. Select **Application permissions**
7. Search and add:

```
✅ Exchange.ManageAsApp
```

8. Click **Add permissions**
9. Click **Grant admin consent for [Your Organization]**
10. Verify the permission shows ✅ green checkmark

### Step-by-Step: Creating a Certificate

Certificate-based auth is **required** for Connect-ExchangeOnline (not client secrets).

#### Option A: Self-Signed Certificate (Quick Testing)

```powershell
# Run as Administrator
$cert = New-SelfSignedCertificate `
    -Subject "CN=ExchangeOnline-PS-Module" `
    -CertStoreLocation "Cert:\LocalMachine\My" `
    -KeyExportPolicy Exportable `
    -KeySpec Signature `
    -KeyLength 2048 `
    -KeyAlgorithm RSA `
    -HashAlgorithm SHA256 `
    -NotAfter (Get-Date).AddMonths(24)

Write-Host "Certificate Thumbprint: $($cert.Thumbprint)"
```

#### Option B: Generate CSR for Enterprise CA

```powershell
# Create certificate request
$cert = New-SelfSignedCertificate `
    -Subject "CN=ExchangeOnline-PS-Module" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -KeyExportPolicy Exportable `
    -KeySpec Signature `
    -KeyLength 2048 `
    -KeyAlgorithm RSA `
    -HashAlgorithm SHA256

# Export CSR
$csr = $cert | Export-CertificateRequest -Path "C:\Certs\ExchangeOnline-CSR.csr"
Write-Host "CSR saved. Submit to your Enterprise CA."
```

### Step-by-Step: Upload Certificate to Azure AD

1. Go to your **App Registration** → **Certificates & secrets**
2. Click **Upload certificate**
3. Select your `.cer` file
4. Click **Add**
5. Copy the **Certificate Thumbprint**

### Setting the Environment Variable

```powershell
# Option 1: Current session only
$env:EXO_CERT_THUMBPRINT = "your-cert-thumbprint"

# Option 2: User-level persistent
[Environment]::SetEnvironmentVariable("EXO_CERT_THUMBPRINT", "your-cert-thumbprint", "User")
```

### Using with the Module

```powershell
$env:EXO_CERT_THUMBPRINT = "your-cert-thumbprint"

Import-Module .\Connect-ExchangeOnline.psm1
Connect-EXOSession -AppId "your-app-id" -TenantId "your-tenant-id" -Organization "your-domain.com"
```

---

## 4️⃣ Connect-Teams App Registration

### App Name Suggestion
```
Teams-PowerShell-Module
```

### Required API Permissions

| Permission | Type | Purpose |
|---|---|---|
| `Team.ReadBasic.All` | Application | Read basic team info |
| `Channel.ReadBasic.All` | Application | Read channel info |
| `Channel.Create` | Application | Create new channels |
| `TeamMember.Read.All` | Application | Read team members |

### Step-by-Step: Adding Permissions

1. Go to your **App Registration** → **API permissions**
2. Click **+ Add a permission**
3. Select **Microsoft Graph**
4. Select **Application permissions**
5. Search and add:

```
✅ Team.ReadBasic.All
✅ Channel.ReadBasic.All
✅ Channel.Create
✅ TeamMember.Read.All
```

6. Click **Add permissions**
7. Click **Grant admin consent for [Your Organization]**
8. Verify all permissions show ✅ green checkmarks

### Setting the Environment Variable

```powershell
# Option 1: Current session only
$env:TEAMS_CLIENT_SECRET = "your-client-secret-value"

# Option 2: User-level persistent
[Environment]::SetEnvironmentVariable("TEAMS_CLIENT_SECRET", "your-client-secret-value", "User")
```

### Using with the Module

```powershell
$env:TEAMS_CLIENT_SECRET = "your-secret"
Import-Module .\Connect-Teams.psm1
Connect-Teams -TenantId "your-tenant-id" -ClientId "your-app-id"
$teams = Get-TeamsAll
$teams | Select-Object displayName, id
Disconnect-Teams
```

---

## 5️⃣ Connect-SharePoint App Registration

### App Name Suggestion
```
SharePoint-PowerShell
```

### Required API Permissions

| Permission | Type | Purpose |
|---|---|---|
| `Sites.ReadWrite.All` | Application | Read/write SharePoint sites |
| `Files.ReadWrite.All` | Application | Read/write files in all site collections |
| `AllSites.FullControl` | Application | Full control on all sites |

### Step-by-Step: Adding Permissions

1. Go to your **App Registration** → **API permissions**
2. Click **+ Add a permission**
3. Select **Microsoft Graph**
4. Select **Application permissions**
5. Search and add:

```
✅ Sites.ReadWrite.All
✅ Files.ReadWrite.All
✅ AllSites.FullControl
```

6. Click **Add permissions**
7. Click **Grant admin consent for [Your Organization]**
8. Verify all permissions show ✅ green checkmarks

### Setting the Environment Variable

```powershell
# Option 1: Current session only
$env:SHAREPOINT_CLIENT_SECRET = "your-client-secret-value"

# Option 2: User-level persistent
[Environment]::SetEnvironmentVariable("SHAREPOINT_CLIENT_SECRET", "your-client-secret-value", "User")
```

### Using with the Module

```powershell
$env:SHAREPOINT_CLIENT_SECRET = "your-secret"
Import-Module .\Connect-SharePoint.psm1
Connect-SharePoint -TenantId "your-tenant-id" -ClientId "your-app-id" `
    -SiteUrl "https://contoso.sharepoint.com/sites/IT"
$site = Get-SharePointSite -SiteUrl "https://contoso.sharepoint.com/sites/IT"
$items = Get-SharePointList -ListName "Hardware" -All
Disconnect-SharePoint
```

---

## 6️⃣ Connect-MgGraph App Registration

### App Name Suggestion
```
MgGraph-General-PowerShell
```

### Required API Permissions

| Permission | Type | Purpose |
|---|---|---|
| `User.Read.All` | Application | Read all users |
| `Group.Read.All` | Application | Read all groups |
| `GroupMember.Read.All` | Application | Read group members |
| `Device.Read.All` | Application | Read all devices |
| `Directory.Read.All` | Application | Read directory data |
| `Organization.Read.All` | Application | Read organization info |

### Step-by-Step: Adding Permissions

1. Go to your **App Registration** → **API permissions**
2. Click **+ Add a permission**
3. Select **Microsoft Graph**
4. Select **Application permissions**
5. Search and add:

```
✅ User.Read.All
✅ Group.Read.All
✅ GroupMember.Read.All
✅ Device.Read.All
✅ Directory.Read.All
✅ Organization.Read.All
```

6. Click **Add permissions**
7. Click **Grant admin consent for [Your Organization]**
8. Verify all permissions show ✅ green checkmarks

### Setting the Environment Variable

```powershell
# Option 1: Current session only
$env:GRAPH_CLIENT_SECRET = "your-client-secret-value"

# Option 2: User-level persistent
[Environment]::SetEnvironmentVariable("GRAPH_CLIENT_SECRET", "your-client-secret-value", "User")
```

### Using with the Module

```powershell
$env:GRAPH_CLIENT_SECRET = "your-secret"
Import-Module .\Connect-MgGraph.psm1
Connect-MgGraphModule -TenantId "your-tenant-id" -ClientId "your-app-id"
$users = Get-MgGraphUser -Filter "accountEnabled eq true" -All
$groups = Get-MgGraphGroup -WithMembers -Top 10
$devices = Get-MgGraphDevice -All
Disconnect-MgGraphModule
```

---

## 🔐 Shared App (All Modules)

If you want **one app registration** for all modules, combine the permissions:

### Combined Permissions

| Permission | Type | Module |
|---|---|---|
| `DeviceManagementManagedDevices.ReadWrite.All` | Application | Connect-Intune |
| `DeviceManagementConfiguration.ReadWrite.All` | Application | Connect-Intune |
| `DeviceManagementManagedDevices.PrivilegedOperations.All` | Application | Connect-Intune |
| `Directory.Read.All` | Application | Connect-Intune, Connect-MgGraph |
| `Domain.Read.All` | Application | Connect-Intune |
| `Mail.Send` | Application | Send-ExchangeMail |
| `Exchange.ManageAsApp` | Application | Connect-ExchangeOnline |
| `Team.ReadBasic.All` | Application | Connect-Teams |
| `Channel.ReadBasic.All` | Application | Connect-Teams |
| `Channel.Create` | Application | Connect-Teams |
| `TeamMember.Read.All` | Application | Connect-Teams |
| `Sites.ReadWrite.All` | Application | Connect-SharePoint |
| `Files.ReadWrite.All` | Application | Connect-SharePoint |
| `AllSites.FullControl` | Application | Connect-SharePoint |
| `User.Read.All` | Application | Connect-MgGraph |
| `Group.Read.All` | Application | Connect-MgGraph |
| `GroupMember.Read.All` | Application | Connect-MgGraph |
| `Device.Read.All` | Application | Connect-MgGraph |
| `Organization.Read.All` | Application | Connect-MgGraph |

### Steps

1. Register **one** app (e.g., `M365-PowerShell-All`)
2. Add **all** permissions listed above
3. Create **one client secret** (for Intune + Email)
4. Upload **one certificate** (for EXO)
5. Grant admin consent for all permissions

### Environment Variables for Shared App

```powershell
# Set all environment variables
$env:INTUNE_CLIENT_SECRET = "your-client-secret"
$env:EXCHANGE_CLIENT_SECRET = "your-client-secret"      # Same secret
$env:EXO_CERT_THUMBPRINT = "your-cert-thumbprint"
$env:TEAMS_CLIENT_SECRET = "your-client-secret"          # Same secret
$env:SHAREPOINT_CLIENT_SECRET = "your-client-secret"     # Same secret
$env:GRAPH_CLIENT_SECRET = "your-client-secret"          # Same secret
```

---

## 📋 Admin Consent

After adding permissions, you **must** grant admin consent:

1. Go to **App Registration** → **API permissions**
2. Click **Grant admin consent for [Your Organization]**
3. Sign in with a **Global Admin** account
4. Click **Accept**
5. Verify all permissions show ✅ green checkmarks

> ⚠️ Without admin consent, the app will fail with `403 Forbidden` or `Access is denied`.

---

## 🔑 Creating Client Secrets

### Best Practices

| Practice | Recommendation |
|---|---|
| Expiration | **24 months** (longer = harder to rotate) |
| Description | Use meaningful names (e.g., `Intune-PS-Module-Secret`) |
| Storage | Use Azure Key Vault, environment variables, or secrets manager |
| Rotation | Rotate every **6 months** minimum |
| Backup | Store in a secure password manager |

### Rotation Schedule

```
Every 6 months:
├── Generate new secret in Azure AD
├── Update environment variable or secrets manager
├── Test all modules with new secret
└── Delete old secret
```

---

## 📜 Creating Certificates

### For Exchange Online (Certificate Auth)

| Requirement | Details |
|---|---|
| Key Type | RSA |
| Key Length | 2048 or 4096 bits |
| Hash Algorithm | SHA256 |
| Exportable | Yes (for upload to Azure AD) |
| Validity | 12-24 months recommended |

### Certificate Store Locations

| Store | Use Case |
|---|---|
| `Cert:\LocalMachine\My` | System-level (scheduled tasks) |
| `Cert:\CurrentUser\My` | User-level (interactive scripts) |

---

## ✅ Verification Steps

### Test Connect-Intune

```powershell
$env:INTUNE_CLIENT_SECRET = "your-secret"
Import-Module .\Connect-Intune.psm1
Connect-Intune -TenantId "your-tenant-id" -ClientId "your-app-id" -Verbose
$devices = Get-IntuneDevices
Write-Host "Devices found: $($devices.Count)"
Disconnect-Intune
```

**Expected output:**
```
Connected to Intune tenant xxxxxxxx (app-only)
Devices found: 150
Disconnected from Microsoft Graph.
```

### Test Send-ExchangeMail

```powershell
$env:EXCHANGE_CLIENT_SECRET = "your-secret"
Import-Module .\Send-ExchangeMail.psm1
$result = Send-ExchangeMail -From "sender@domain.com" -To "you@domain.com" `
    -Subject "Test Email" -Body "<h1>Hello from PowerShell!</h1>" `
    -TenantId "your-tenant-id" -ClientId "your-app-id" -Verbose
Write-Host "Email sent: $result"
```

**Expected output:**
```
Acquiring token: Tenant=xxx Client=xxx
Sending email From=sender@domain.com To=you@domain.com Subject='Test Email'
True
```

### Test Connect-ExchangeOnline

```powershell
$env:EXO_CERT_THUMBPRINT = "your-cert-thumbprint"
Import-Module .\Connect-ExchangeOnline.psm1
Connect-EXOSession -AppId "your-app-id" -TenantId "your-tenant-id" `
    -Organization "your-domain.com" -Verbose
Get-QuarantineMessage -PageSize 5
Disconnect-EXOSession
```

**Expected output:**
```
Connected to Exchange Online (app-only, cert=your-thumbprint).
Connected to Security & Compliance Center.
```

### Test Connect-Teams

```powershell
$env:TEAMS_CLIENT_SECRET = "your-secret"
Import-Module .\Connect-Teams.psm1
Connect-Teams -TenantId "your-tenant-id" -ClientId "your-app-id" -Verbose
$teams = Get-TeamsAll
Write-Host "Teams found: $($teams.Count)"
$channels = Get-TeamsChannel -TeamId $teams[0].id
Write-Host "Channels: $($channels.Count)"
Disconnect-Teams
```

### Test Connect-SharePoint

```powershell
$env:SHAREPOINT_CLIENT_SECRET = "your-secret"
Import-Module .\Connect-SharePoint.psm1
Connect-SharePoint -TenantId "your-tenant-id" -ClientId "your-app-id" `
    -SiteUrl "https://contoso.sharepoint.com/sites/IT" -Verbose
$site = Get-SharePointSite -SiteUrl "https://contoso.sharepoint.com/sites/IT"
Write-Host "Site: $($site.DisplayName)"
$items = Get-SharePointList -ListName "Hardware" -Top 5
Write-Host "Items: $($items.Count)"
Disconnect-SharePoint
```

### Test Connect-MgGraph

```powershell
$env:GRAPH_CLIENT_SECRET = "your-secret"
Import-Module .\Connect-MgGraph.psm1
Connect-MgGraphModule -TenantId "your-tenant-id" -ClientId "your-app-id" -Verbose
$users = Get-MgGraphUser -Top 5
Write-Host "Users: $($users.Count)"
$groups = Get-MgGraphGroup -Top 5
Write-Host "Groups: $($groups.Count)"
$devices = Get-MgGraphDevice -Top 5
Write-Host "Devices: $($devices.Count)"
Disconnect-MgGraphModule
```

---

## 🐛 Troubleshooting

| Error | Cause | Fix |
|---|---|---|
| `AADSTS700016` | Wrong ClientId or app not found | Verify Application (client) ID in Azure AD |
| `AADSTS7000215` | Invalid secret/certificate | Regenerate in Azure AD > Certificates & secrets |
| `Access is denied` / `403` | Admin consent not granted | Click "Grant admin consent" in API permissions |
| `Insufficient privileges` | Missing permissions | Add required permissions and re-consent |
| `SendAsDenied` | App not authorized for mailbox | Add "Send As" in Exchange Admin Center |
| `Certificate not found` | Certificate not in store | Install in Local Machine\Personal or CurrentUser\My |
| `Unable to connect` | Firewall blocks endpoints | Allow HTTPS to `login.microsoftonline.com:443` and `graph.microsoft.com:443` |
| `Exchange.ManageAsApp` error | Permission not added | Add from "APIs my organization uses" → Office 365 Exchange Online |
| Teams: `Channel.Create` error | Permission missing | Add `Channel.Create` permission in Azure AD |
| SharePoint: `Site not found` | App lacks site access | Grant `Sites.ReadWrite.All` and admin consent |
| MgGraph: `User.Read.All` error | Directory permission missing | Add `Directory.Read.All` alongside `User.Read.All` |

### Debug Commands

```powershell
# Check if module is loaded
Get-Command Connect-Intune

# Check environment variables
$env:INTUNE_CLIENT_SECRET
$env:EXCHANGE_CLIENT_SECRET
$env:EXO_CERT_THUMBPRINT

# Test Azure AD connectivity
Test-NetConnection login.microsoftonline.com -Port 443
Test-NetConnection graph.microsoft.com -Port 443
```


