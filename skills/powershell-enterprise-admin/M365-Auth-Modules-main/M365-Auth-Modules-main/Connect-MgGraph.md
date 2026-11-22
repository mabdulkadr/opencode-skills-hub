# 📦 Connect-MgGraph Module (Connect-MgGraph.psm1)

> Part of **[M365 Auth Modules](../README.md)** — centralized OAuth 2.0 + Certificate-based Microsoft 365 authentication.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)
![Graph](https://img.shields.io/badge/API-Microsoft%20Graph-0078D6.svg)
![Auth](https://img.shields.io/badge/Auth-OAuth%202.0%20%2B%20Interactive-2ea44f.svg)
![Version](https://img.shields.io/badge/version-1.1-green.svg)

---

## 📖 Overview

**Connect-MgGraph.psm1** is a general-purpose Microsoft Graph connection module for **Users**, **Groups**, **Devices**, and **organization-wide directory operations**. It supports both **app-only** (client credentials) and **delegated** (interactive) authentication and provides helper functions for the most common Microsoft Graph queries with automatic pagination.

- **Auth flow:** OAuth 2.0 client credentials (app-only) or interactive user login
- **API endpoint:** `https://graph.microsoft.com/v1.0/`
- **Best for:** User/Group/Device enumeration, OData-filtered queries, scheduled audit scripts

> 📖 For App Registration setup see [`SETUP.md`](SETUP.md) section **6️⃣ Connect-MgGraph App Registration**.

---

## ✨ Core Features

### 🔹 Connect-MgGraphModule / Disconnect-MgGraphModule
- OAuth 2.0 client credentials flow or interactive delegated auth
- Auto-installs `Microsoft.Graph.Authentication`, `Microsoft.Graph.Users`, `Microsoft.Graph.Groups`, `Microsoft.Graph.Identity.DirectoryManagement`
- Token caching with `finally`-block BSTR cleanup

### 🔹 Get-MgGraphUser
- Lists all users with property selection
- OData filter support (`-Filter "accountEnabled eq true"`)
- Auto-pagination via `-All` switch
- Default properties: Id, DisplayName, UserPrincipalName, Mail, Department, JobTitle, AccountEnabled, CreatedDateTime

### 🔹 Get-MgGraphGroup
- Lists all groups with property selection
- OData filter support
- `-WithMembers` switch enumerates members per group via `Get-MgGroupMember`
- Auto-pagination via `-All` switch

### 🔹 Get-MgGraphDevice
- Lists all Azure AD-registered devices
- OData filter support (e.g., `lastSignInDateTime le $cutoff`)
- Default properties include `LastSignInDateTime` for staleness checks
- Auto-pagination via `-All` switch

---

## ⚙️ Requirements

| Requirement | Minimum | Purpose |
|-------------|---------|---------|
| PowerShell | 5.1+ | Script execution |
| Azure AD App | App registration with Graph API permissions | Authentication |
| API Permissions | `User.Read.All`, `Group.Read.All`, `GroupMember.Read.All`, `Device.Read.All`, `Directory.Read.All`, `Organization.Read.All` (Application) | Graph queries |
| Network | Outbound HTTPS to `login.microsoftonline.com` and `graph.microsoft.com` | Token + Graph API calls |
| Auto-installed | Microsoft.Graph.Authentication + Users + Groups + DirectoryManagement | Cmdlet access |

---

## 🚀 How to Run

### Option 1 — App-Only (Recommended for Automation)

```powershell
$env:GRAPH_CLIENT_SECRET = "your-client-secret"

Import-Module .\Connect-MgGraph.psm1
Connect-MgGraphModule -TenantId "your-tenant-id" -ClientId "your-app-id"

$users  = Get-MgGraphUser -Filter "accountEnabled eq true" -All
$groups = Get-MgGraphGroup -WithMembers -Top 50

Disconnect-MgGraphModule
```

### Option 2 — Interactive (Delegated)

```powershell
Import-Module .\Connect-MgGraph.psm1
Connect-MgGraphModule -Interactive

Get-MgGraphUser -Top 10 | Select-Object DisplayName, UserPrincipalName

Disconnect-MgGraphModule
```

### Option 3 — From a Scheduled Task

```powershell
# In Task Scheduler → Action: powershell.exe -File "C:\Scripts\AuditUsers.ps1"
$env:GRAPH_CLIENT_SECRET = $env:GRAPH_CLIENT_SECRET  # Set as machine env var
Import-Module "C:\Modules\Connect-MgGraph.psm1"
Connect-MgGraphModule
$users = Get-MgGraphUser -All
$users | Export-Csv "C:\Reports\Users.csv" -NoTypeInformation
Disconnect-MgGraphModule
```

---

## ⚙️ Parameters

### Connect-MgGraphModule

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-TenantId` | string | `$script:DefaultTenantId` | Azure AD tenant ID |
| `-ClientId` | string | `$script:DefaultClientId` | Azure AD application (client) ID |
| `-ClientSecret` | SecureString | — | Client secret override |
| `-Interactive` | switch | `$false` | Use interactive delegated login (browser OAuth) |

### Secret Resolution Order (App-Only)

1. `-ClientSecret` parameter (SecureString)
2. `$env:GRAPH_CLIENT_SECRET` environment variable
3. `$script:DefaultClientSecret` module-scoped default

### Get-MgGraphUser

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Filter` | string | — | OData filter (e.g., `accountEnabled eq true`) |
| `-Property` | string[] | full set (see Overview) | Properties to retrieve |
| `-Top` | int | `100` | Maximum results per page |
| `-All` | switch | `$false` | Auto-paginate all results |

### Get-MgGraphGroup

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Filter` | string | — | OData filter |
| `-Property` | string[] | full set | Properties to retrieve |
| `-Top` | int | `100` | Maximum results per page |
| `-All` | switch | `$false` | Auto-paginate all results |
| `-WithMembers` | switch | `$false` | Include group members (slower; one call per group) |

### Get-MgGraphDevice

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Filter` | string | — | OData filter (e.g., `lastSignInDateTime le $cutoff`) |
| `-Property` | string[] | full set | Properties to retrieve |
| `-Top` | int | `100` | Maximum results per page |
| `-All` | switch | `$false` | Auto-paginate all results |

---

## 🔄 Typical Workflow

```
1. Connect-MgGraphModule        ──▶ Acquires token, sets $script:Connected = $true
2. Get-MgGraphUser -All         ──▶ Fetches page 1
    │                              handles @odata.nextLink automatically
    │                              until all pages consumed
3. Get-MgGraphGroup -WithMembers ──▶ Adds Members property to each group
4. Get-MgGraphDevice -Filter    ──▶ Server-side OData filter
5. Disconnect-MgGraphModule     ──▶ Clears token, sets $script:Connected = $false
```

---

## 📊 Operational Safeguards

- ✅ BSTR-safe SecureString handling — `ZeroFreeBSTR` in `finally` blocks
- 🔒 `script:Connected` state-checked before every Graph call
- 🛟 Auto-pagination via `@odata.nextLink` — never silently drops results
- 🔄 Token re-acquired on each fresh `Connect-MgGraphModule` call
- 📝 `-Verbose` flag on all functions for debug output
- 🆘 Module auto-installs missing `Microsoft.Graph.*` modules from PSGallery

---

## 🐛 Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| `Cannot find module 'Microsoft.Graph.Authentication'` | PSGallery blocked or offline | Run `Install-Module Microsoft.Graph.Authentication -Scope CurrentUser` |
| `AADSTS700016` | Wrong `ClientId` or app not in tenant | Verify Azure AD app registration values |
| `AADSTS7000215` | Invalid `ClientSecret` | Regenerate in Azure AD > Certificates & secrets |
| `403 Forbidden` | Permissions not granted | Click **Grant admin consent** in API permissions |
| `Not connected. Run Connect-MgGraphModule first.` | Function called before connect | Run `Connect-MgGraphModule` first |
| `429 Too Many Requests` | Graph API throttling | Reduce `-Top`, add `-Filter`, retry with backoff |
| `Get-MgGraphGroup -WithMembers` slow on large tenants | One API call per group | Use `-Top 50` without `-WithMembers` for batch view |

---

## 🛡 Design Principles

- **No secrets in code** — example placeholder values shown; use `$env:GRAPH_CLIENT_SECRET` in production
- **Pagination handled** — `@odata.nextLink` consumed automatically with `-All`
- **Auto-dependency** — required Graph modules installed on first import
- **State-checked** — `script:Connected` guard prevents calls before connection
- **BSTR-safe** — SecureString conversion uses `ZeroFreeBSTR` in `finally`
- **Filter-aware** — server-side OData reduces payload and rate-limit pressure
- **Property selector** — defaults include identity + workload fields; override with `-Property`

---

## 📜 License

This project is licensed under the [MIT License](../LICENSE) file.

---

## 👤 Author

**Mohammad Abdulkader Omar**  
Website: https://momar.tech  
LinkedIn: https://www.linkedin.com/in/mabdulkadr/  

---

## ⚠ Disclaimer

These scripts are provided as-is. Test them in a staging environment before applying them to production. The author is not responsible for any unintended outcomes resulting from their use.
