<div align="center">

# 🚀 M365 Auth Modules

**Modern, reusable authentication modules for Microsoft 365**

Centralized OAuth 2.0 and certificate-based auth for Intune, Exchange Online, Teams, SharePoint, and Microsoft Graph — no credentials embedded in scripts, ever.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![PowerShell](https://img.shields.io/badge/powershell-5.1%2B-blue.svg)
![Platform](https://img.shields.io/badge/Windows-10%2F11-blue.svg)
![Graph](https://img.shields.io/badge/API-Microsoft%20Graph-0078D6.svg)
![EXO](https://img.shields.io/badge/Exchange-Online-0078D4.svg)
![Intune](https://img.shields.io/badge/Intune-Microsoft%20Graph-0078D6.svg)
![Teams](https://img.shields.io/badge/Teams-Microsoft%20Graph-6264A7.svg)
![SharePoint](https://img.shields.io/badge/SharePoint-Microsoft%20Graph-038387.svg)
![Version](https://img.shields.io/badge/version-1.1-green.svg)

[Overview](#-overview) • [Modules](#-core-features) • [Usage](#-usage) • [Permissions](#-permissions) • [Troubleshooting](#-troubleshooting)

</div>

---

# 📖 Overview

**M365 Auth Modules** is a collection of six self-contained PowerShell modules for **Microsoft 365 authentication and Azure AD automation**. Each module wraps one service with a clean `Connect-*` / `Disconnect-*` lifecycle — so your scripts never embed credentials or auth logic again.

> 🔐 **Modern auth only.** Every module uses OAuth 2.0 or certificate-based authentication — no Basic Auth, no SMTP, no legacy protocols. Microsoft is deprecating SMTP AUTH Basic Authentication (disabled by default Dec 2026, final removal H2 2027); this project is future-proof from day one.

| Method | Modules | Protocol |
|--------|---------|----------|
| **OAuth 2.0 Client Credentials** | Connect-Intune, Send-ExchangeMail, Connect-Teams, Connect-SharePoint, Connect-MgGraph | Microsoft Graph API via `login.microsoftonline.com` |
| **Certificate-based Auth** | Connect-ExchangeOnline | `ExchangeOnlineManagement` module with X.509 certificate |
| **Interactive Delegated** | All modules (optional) | Browser-based OAuth consent flow |

```text
                 M365 Auth Modules
                        │
     ┌──────────┬───────┼───────┬──────────┐
     ▼          ▼       ▼       ▼          ▼
┌─────────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌──────────┐
│ INTUNE  │ │ EXO │ │TEAMS│ │ SPO │ │   GRAPH  │
│ Devices │ │Cert │ │Chan │ │List │ │ Users    │
│ Sync    │ │Auth │ │nels │ │Items│ │ Groups   │
│ Policy  │ │IPPS │ │Memb │ │Files│ │ Devices  │
└─────────┘ └─────┘ └─────┘ └─────┘ └──────────┘
```

Each module is self-contained: code, documentation, and examples live together in a single `.ps1` + `.md` pair. No cross-folder dependencies.

---

# 📂 Project Structure

```text
M365-Auth-Modules/
│
├── README.md                       # This file
├── SETUP.md                        # Azure AD App Registration guide (per module)
├── CHANGELOG.md                    # Version history
├── LICENSE                         # MIT
│
├── Connect-Intune.psm1 / .md       # Intune/Graph connection + device operations
├── Send-ExchangeMail.psm1 / .md    # HTML email via Microsoft Graph (no SMTP)
├── Connect-ExchangeOnline.psm1 / .md  # EXO + Security & Compliance (IPPS)
├── Connect-Teams.psm1 / .md        # Teams, channels, members
├── Connect-SharePoint.psm1 / .md   # Sites, lists, files
└── Connect-MgGraph.psm1 / .md      # Users, groups, devices
```

---

# ✨ Core Features

### 🔹 Connect-Intune (`Connect-Intune.psm1`)

Authenticate to Microsoft Graph with Intune-specific permission scopes — app-only or interactive.

* `Connect-Intune` / `Disconnect-Intune` — OAuth 2.0 client credentials or interactive delegated login; auto-installs `Microsoft.Graph.Authentication`; friendly AADSTS error mapping (`700016` / `7000215` in plain English)
* `Get-IntuneDevices` — managed devices with auto-pagination via `@odata.nextLink` and server-side OData `-Filter`
* `Send-IntuneDeviceSync` — sends the `syncDevice` command to a device by GUID
* `Get-IntunePolicy` — filters device configuration policies by name substring

> 📖 Docs: [`Connect-Intune.md`](Connect-Intune.md) · ⚙ Setup: [`SETUP.md` §1](SETUP.md#1️⃣-connect-intune-app-registration)

### 🔹 Send-ExchangeMail (`Send-ExchangeMail.psm1`)

Send HTML email through Microsoft Graph — **no SMTP, no Basic Auth**.

* HTML body, CC/BCC arrays, file attachments as `fileAttachment`
* BSTR-safe SecureString handling — `ZeroFreeBSTR` in `finally`
* Multi-source secret resolution: `-ClientSecret` → `$env:EXCHANGE_CLIENT_SECRET` → module default
* `-SaveToSentItems` switch for audit-trail compliance

> 📖 Docs: [`Send-ExchangeMail.md`](Send-ExchangeMail.md) · ⚙ Setup: [`SETUP.md` §2](SETUP.md#2️⃣-send-exchangemail-app-registration)

### 🔹 Connect-ExchangeOnline (`Connect-ExchangeOnline.psm1`)

Connect to **Exchange Online** and the **Security & Compliance Center (IPPS)** with certificate-based app-only auth.

* Certificate auth via `Connect-ExchangeOnline -CertificateThumbprint`, or interactive browser login
* TLS 1.2 forced on every connection
* IPPS connected by default; `-SkipIPPS` to opt out
* Friendly mapping of `AADSTS700016` / `7000215` / certificate-not-found errors

> 📖 Docs: [`Connect-ExchangeOnline.md`](Connect-ExchangeOnline.md) · ⚙ Setup: [`SETUP.md` §3](SETUP.md#3️⃣-connect-exchangeonline-app-registration)

### 🔹 Connect-Teams (`Connect-Teams.psm1`)

Manage **Microsoft Teams** via Microsoft Graph.

* `Connect-Teams` / `Disconnect-Teams` — client credentials or interactive auth; auto-installs `Microsoft.Graph.Teams`; token caching with `finally`-block leak protection
* `Get-TeamsAll` / `Get-TeamsChannel` / `Get-TeamsMember` — auto-pagination with `-All`, members with role info
* `New-TeamsChannel` — standard / private / shared channels, with `ShouldProcess` (`-WhatIf`) support

> 📖 Docs: [`Connect-Teams.md`](Connect-Teams.md) · ⚙ Setup: [`SETUP.md` §4](SETUP.md#4️⃣-connect-teams-app-registration)

### 🔹 Connect-SharePoint (`Connect-SharePoint.psm1`)

Manage **SharePoint Online** — sites, lists, and files at scale.

* Auto-installs `Microsoft.Graph.Sites` + `Microsoft.Graph.Files`; optional `-SiteUrl` pre-resolves the site on connect
* `Get-SharePointSite` / `Get-SharePointList` / `Add-SharePointListItem` — OData `$filter`, `-All` pagination, `ShouldProcess` on writes, OData-injection prevention
* `Get-SharePointFile` / `Upload-SharePointFile` — streaming download; upload with `conflictBehavior = rename` (configurable)

> 📖 Docs: [`Connect-SharePoint.md`](Connect-SharePoint.md) · ⚙ Setup: [`SETUP.md` §5](SETUP.md#5️⃣-connect-sharepoint-app-registration)

### 🔹 Connect-MgGraph (`Connect-MgGraph.psm1`)

General-purpose **Microsoft Graph** connection for directory-wide operations.

* Auto-installs `Microsoft.Graph.Authentication`, `Users`, `Groups`, `Identity.DirectoryManagement`
* `Get-MgGraphUser` / `Get-MgGraphGroup` / `Get-MgGraphDevice` — OData `-Filter` for server-side queries, `-All` pagination, `-WithMembers` for per-group member enumeration, customizable `-Property` arrays
* BSTR-safe SecureString handling throughout

> 📖 Docs: [`Connect-MgGraph.md`](Connect-MgGraph.md) · ⚙ Setup: [`SETUP.md` §6](SETUP.md#6️⃣-connect-mggraph-app-registration)

---

# ⚙️ Requirements

| Requirement | Minimum | Notes |
|-------------|---------|-------|
| PowerShell | 5.1+ | Built into Windows 10/11; tested on 7+ too |
| .NET Framework | 4.6.2+ | Required by Microsoft.Graph.Authentication |
| Microsoft.Graph.Authentication | Auto-installed | Used by Connect-Intune |
| ExchangeOnlineManagement | Auto-installed | Used by Connect-ExchangeOnline |
| Azure AD App Registration | — | With appropriate permissions (see [Permissions](#-permissions)) |
| Internet Access | — | Outbound HTTPS to Graph, EXO, and login endpoints |

> 📖 **First time setup?** See the [App Registration Guide](SETUP.md) for step-by-step instructions.

---

# 🚀 Usage

### Connect to Intune (App-Only)

```powershell
$env:INTUNE_CLIENT_SECRET = "your-client-secret"

Import-Module .\Connect-Intune.psm1
Connect-Intune -TenantId "your-tenant-id" -ClientId "your-app-id"
$devices = Get-IntuneDevices
Send-IntuneDeviceSync -DeviceId $devices[0].id
Disconnect-Intune
```

### Connect to Intune (Interactive)

```powershell
Import-Module .\Connect-Intune.psm1
Connect-Intune -Interactive
$devices = Get-IntuneDevices
Disconnect-Intune
```

### Send Email via Graph

```powershell
$env:EXCHANGE_CLIENT_SECRET = "your-client-secret"

Import-Module .\Send-ExchangeMail.psm1
Send-ExchangeMail -From "sender@your-domain.onmicrosoft.com" `
    -To "user@your-domain.com" `
    -Subject "Report" `
    -Body "<h1>Hello</h1>" `
    -TenantId "your-tenant-id" `
    -ClientId "your-app-id"
```

### Connect to Exchange Online (Certificate Auth)

```powershell
$env:EXO_CERT_THUMBPRINT = "your-cert-thumbprint"

Import-Module .\Connect-ExchangeOnline.psm1
Connect-EXOSession -TenantId "your-tenant-id" -AppId "your-app-id" -Organization "your-domain.com"
Get-QuarantineMessage -PageSize 10
Disconnect-EXOSession
```

### Connect to Microsoft Teams

```powershell
$env:TEAMS_CLIENT_SECRET = "your-client-secret"

Import-Module .\Connect-Teams.psm1
Connect-Teams -TenantId "your-tenant-id" -ClientId "your-app-id"
$teams = Get-TeamsAll -Top 10
New-TeamsChannel -TeamId $teams[0].id -Name "Reports" -MembershipType standard
Disconnect-Teams
```

### Connect to SharePoint Online

```powershell
$env:SHAREPOINT_CLIENT_SECRET = "your-client-secret"

Import-Module .\Connect-SharePoint.psm1
Connect-SharePoint -TenantId "your-tenant-id" -ClientId "your-app-id" `
    -SiteUrl "https://your-domain.sharepoint.com/sites/IT"
$items = Get-SharePointList -ListName "Hardware" -All
$items | Select-Object -First 5
Disconnect-SharePoint
```

### General Microsoft Graph (Users, Groups, Devices)

```powershell
$env:GRAPH_CLIENT_SECRET = "your-client-secret"

Import-Module .\Connect-MgGraph.psm1
Connect-MgGraphModule -TenantId "your-tenant-id" -ClientId "your-app-id"
$users  = Get-MgGraphUser -Filter "accountEnabled eq true" -All
$groups = Get-MgGraphGroup -WithMembers -Top 50
Disconnect-MgGraphModule
```

### Using in Scripts (Recommended Pattern)

Place the modules folder two levels above your script:

```text
ProjectRoot/
  Modules/
    Connect-Intune.psm1
    Send-ExchangeMail.psm1
    Connect-ExchangeOnline.psm1
  Scripts/
    MyScript/
      MyScript.ps1
```

Inside `MyScript.ps1`:

```powershell
$modulePath = Join-Path $PSScriptRoot '..\..\Modules'
Import-Module (Join-Path $modulePath 'Connect-Intune.psm1') -Force
Import-Module (Join-Path $modulePath 'Send-ExchangeMail.psm1') -Force

Connect-Intune

# ... your logic ...

Send-ExchangeMail -From "noreply@your-domain.com" -To "admin@your-domain.com" `
    -Subject "Report" -Body "<p>Done</p>"

Disconnect-Intune
```

---

# 🔐 Environment Variables

| Variable | Module | Purpose |
|---|---|---|
| `$env:INTUNE_CLIENT_SECRET` | Connect-Intune | Client secret for app-only auth |
| `$env:EXCHANGE_CLIENT_SECRET` | Send-ExchangeMail | Client secret for app-only auth |
| `$env:EXO_CERT_THUMBPRINT` | Connect-ExchangeOnline | Certificate thumbprint for app-only auth |
| `$env:TEAMS_CLIENT_SECRET` | Connect-Teams | Client secret for app-only auth |
| `$env:SHAREPOINT_CLIENT_SECRET` | Connect-SharePoint | Client secret for app-only auth |
| `$env:GRAPH_CLIENT_SECRET` | Connect-MgGraph | Client secret for app-only auth |

---

# 🔑 Permissions

### Connect-Intune

| Permission | Type | Purpose |
|------------|------|---------|
| `DeviceManagementManagedDevices.ReadWrite.All` | Application | Read/write managed devices |
| `DeviceManagementConfiguration.ReadWrite.All` | Application | Read/write device configurations |
| `DeviceManagementManagedDevices.PrivilegedOperations.All` | Application | Remote actions (sync, wipe, etc.) |
| `Directory.Read.All` | Application | Read directory data |

### Send-ExchangeMail

| Permission | Type | Purpose |
|------------|------|---------|
| `Mail.Send` | Application | Send email as any mailbox |

### Connect-ExchangeOnline

| Permission | Type | Purpose |
|------------|------|---------|
| `Exchange.ManageAsApp` | Application | Manage Exchange as app |

### Connect-Teams

| Permission | Type | Purpose |
|------------|------|---------|
| `Team.ReadBasic.All` | Application | Read basic team info |
| `Channel.ReadBasic.All` | Application | Read channel info |
| `Channel.Create` | Application | Create channels |
| `TeamMember.Read.All` | Application | Read team members |

### Connect-SharePoint

| Permission | Type | Purpose |
|------------|------|---------|
| `Sites.ReadWrite.All` | Application | Read/write SharePoint sites |
| `Files.ReadWrite.All` | Application | Read/write files in all site collections |
| `AllSites.FullControl` | Application | Full control on all sites |

### Connect-MgGraph

| Permission | Type | Purpose |
|------------|------|---------|
| `User.Read.All` | Application | Read all users |
| `Group.Read.All` | Application | Read all groups |
| `GroupMember.Read.All` | Application | Read group members |
| `Device.Read.All` | Application | Read all devices |
| `Directory.Read.All` | Application | Read directory data |
| `Organization.Read.All` | Application | Read organization info |

---

# 🔄 Authentication Flow

```text
┌───────────────────────────────────────────────────────────┐
│                    AUTH FLOW                              │
│                                                           │
│  Script calls Connect-Intune                              │
│       ├── App-Only (Client Credentials)                   │
│       │   ├── Resolve secret: param > env > default       │
│       │   ├── POST login.microsoftonline.com/.../token    │
│       │   ├── Receive access_token                        │
│       │   └── Connect-MgGraph -AccessToken $token         │
│       └── Interactive (User Login)                        │
│           ├── Connect-MgGraph -Scopes @(...)              │
│           └── Browser-based OAuth consent                 │
│                                                           │
│  Script calls Send-ExchangeMail                           │
│       ├── Resolve secret: param > env > default           │
│       ├── POST login.microsoftonline.com/.../token        │
│       ├── Receive access_token                            │
│       └── POST graph.microsoft.com/v1.0/.../sendMail      │
│                                                           │
│  Script calls Connect-EXOSession                          │
│       ├── Certificate Auth                                │
│       │   └── ExchangeOnlineManagement\Connect-Exchange   │
│       │       -AppId $app -CertThumbprint $cert           │
│       └── Interactive                                     │
│           └── ExchangeOnlineManagement\Connect-Exchange   │
└───────────────────────────────────────────────────────────┘
```

---

# 🔍 Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| `AADSTS700016` | Wrong ClientId or app not found | Verify app registration in Azure AD |
| `AADSTS7000215` | Invalid client secret/certificate | Regenerate in Azure AD > Certificates & secrets |
| `Access is denied` / `403` | App lacks required permissions | Grant and admin-consent permissions |
| `Failed to install module` | No internet or PSGallery blocked | Install module manually |
| `Unable to connect to remote server` | Firewall/proxy blocks endpoints | Allow HTTPS to Graph/EXO endpoints |
| `SendAsDenied` | App not authorized for `-From` mailbox | Add Send As permission in Exchange Admin |
| `Certificate not found` | Certificate not installed locally | Install in Local Machine\Personal store |
| `Get-IntuneDevices` returns empty | Not connected | Run `Connect-Intune` first |
| `Invoke-MgGraphRequest` not found | Graph module not installed | `Connect-Intune` auto-installs it |

---

# 🛡 Operational Notes

* **No secrets in code** — placeholders only in examples; use `$env:XXX_CLIENT_SECRET` or a secrets manager in production
* **Least privilege** — each module requests only the scopes it actually calls
* **Token lifecycle** — tokens re-acquired on every connection; SecureStrings zeroed via `ZeroFreeBSTR` in `finally` blocks
* **Auto-dependency** — missing PSGallery modules install automatically on first connect
* **Pagination handled** — every `Get-*` function follows `@odata.nextLink` automatically
* **TLS enforced** — TLS 1.2 forced for all Exchange Online connections
* **Safe writes** — `ShouldProcess` on all create/update functions (`-WhatIf` supported); OData injection prevented
* **Descriptive errors** — AADSTS codes mapped to plain English
* **Modular by design** — one service per module; centralize auth, reuse everywhere
* **Future-proof** — OAuth 2.0 + certificates only; ready for the SMTP Basic Auth retirement

---

## 📝 Changelog

| Version | Date | Changes |
|---------|------|---------|
| v1.1 | 2025-06-15 | Added: Connect-Teams, Connect-SharePoint, Connect-MgGraph |
| v1.0 | 2025-06-01 | Initial release: Connect-Intune, Send-ExchangeMail, Connect-ExchangeOnline |

Full history: [CHANGELOG.md](CHANGELOG.md)

---

## 👤 Author

**Mohammad Abdulkader Omar**  
GitHub: [@mabdulkadr](https://github.com/mabdulkadr)  
Website: [momar.tech](https://momar.tech)  

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).

---

## ⚠ Disclaimer

This skill and every script it generates are provided as-is with no warranty
of any kind. Test generated tools in a staging environment before deploying to
production. The authors assume no liability for any damage or data loss
resulting from their use.

---

<div align="center">

⭐ **If this project saves you time, star the repo — it helps others find it.**

[Report an Issue](../../issues) · [momar.tech](https://momar.tech)

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/mabdulkadrx)

Built with [**PowerShell Enterprise Admin**](https://github.com/mabdulkadr/powershell-enterprise-admin-skill)

</div>
