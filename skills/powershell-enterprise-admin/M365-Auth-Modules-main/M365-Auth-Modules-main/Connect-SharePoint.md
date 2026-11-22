# 📦 Connect-SharePoint Module (Connect-SharePoint.psm1)

> Part of **[M365 Auth Modules](../README.md)** — centralized OAuth 2.0 + Certificate-based Microsoft 365 authentication.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)
![Graph](https://img.shields.io/badge/API-Microsoft%20Graph-0078D6.svg)
![SharePoint](https://img.shields.io/badge/SharePoint-Online-038387.svg)
![Auth](https://img.shields.io/badge/Auth-OAuth%202.0%20%2B%20Interactive-2ea44f.svg)
![Version](https://img.shields.io/badge/version-1.1-green.svg)

---

## 📖 Overview

**Connect-SharePoint.psm1** is a SharePoint Online management module via Microsoft Graph API. It authenticates with SharePoint-specific permission scopes and provides helpers for **site resolution**, **list CRUD operations**, and **file upload/download** through the Microsoft Graph SDK.

- **Auth flow:** OAuth 2.0 client credentials (app-only) or interactive user login
- **API endpoint:** `https://graph.microsoft.com/v1.0/`
- **Best for:** Site-scoped reporting, list automation, file transfer automation

> 📖 For App Registration setup see [`SETUP.md`](SETUP.md) section **5️⃣ Connect-SharePoint App Registration**.

---

## ✨ Core Features

### 🔹 Connect-SharePoint / Disconnect-SharePoint
- OAuth 2.0 client credentials flow or interactive delegated auth
- Auto-installs `Microsoft.Graph.Authentication`, `Microsoft.Graph.Sites`, `Microsoft.Graph.Files`
- Optional `-SiteUrl` pre-resolves the current site on connect
- Stores `$script:CurrentSiteId` + `$script:CurrentSiteUrl` for chained calls

### 🔹 Get-SharePointSite
- Resolves any SharePoint site by URL via `Get-MgSiteByHostName`
- Caches `site.Id` so subsequent `Get-SharePointList` calls don't repeat the resolve

### 🔹 Get-SharePointList / Add-SharePointListItem
- Read all items by list display name with OData `$filter` support
- Auto-pagination via `-All`
- `Add-SharePointListItem` uses `ShouldProcess` — supports `-WhatIf`
- OData filter injection prevented via `''` → `''''` escape on `displayName`

### 🔹 Get-SharePointFile / Upload-SharePointFile
- Binary file download via streaming `CopyTo`
- File upload with `conflictBehavior = rename`
- Upload uses `ShouldProcess` for safe `-WhatIf` testing

### 🔹 Authentication State
- `$script:Connected` guard on every operation
- Clear reset on `Disconnect-SharePoint`

---

## ⚙️ Requirements

| Requirement | Minimum | Purpose |
|-------------|---------|---------|
| PowerShell | 5.1+ | Script execution |
| Azure AD App | App registration with SharePoint permissions | Authentication |
| API Permissions | `Sites.ReadWrite.All`, `Files.ReadWrite.All`, `AllSites.FullControl` (Application) | Site, list, file access |
| Network | Outbound HTTPS to `login.microsoftonline.com` and `graph.microsoft.com` | Token + Graph API calls |
| Auto-installed | Microsoft.Graph.Authentication + Sites + Files | Cmdlet access |

---

## 🚀 How to Run

### Option 1 — App-Only with Pre-Resolved Site (Recommended)

```powershell
$env:SHAREPOINT_CLIENT_SECRET = "your-client-secret"

Import-Module .\Connect-SharePoint.psm1
Connect-SharePoint -TenantId "your-tenant-id" -ClientId "your-app-id" `
    -SiteUrl "https://contoso.sharepoint.com/sites/IT"

$items = Get-SharePointList -ListName "Hardware" -All
$items | Select-Object -ExpandProperty Fields | Format-Table

Disconnect-SharePoint
```

### Option 2 — Interactive (Delegated, Browser OAuth)

```powershell
Import-Module .\Connect-SharePoint.psm1
Connect-SharePoint -SiteUrl "https://contoso.sharepoint.com/sites/IT" -Interactive
Get-SharePointList -ListName "Hardware" -Top 10
Disconnect-SharePoint
```

### Option 3 — File Upload Automation (Scheduled Task)

```powershell
$env:SHAREPOINT_CLIENT_SECRET = $env:SHAREPOINT_CLIENT_SECRET  # Machine env var
Import-Module "C:\Modules\Connect-SharePoint.psm1"
Connect-SharePoint -SiteUrl "https://contoso.sharepoint.com/sites/Reports"
$site = Get-SharePointSite -SiteUrl "https://contoso.sharepoint.com/sites/Reports"
$drive = Get-MgSiteDrive -SiteId $site.Id | Where-Object Name -eq "Documents"
Upload-SharePointFile -SiteId $site.Id -DriveId $drive.Id `
    -FilePath "C:\Reports\Weekly.csv" -DrivePath "/Reports"
Disconnect-SharePoint
```

---

## ⚙️ Parameters

### Connect-SharePoint

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-TenantId` | string | `$script:DefaultTenantId` | Azure AD tenant ID |
| `-ClientId` | string | `$script:DefaultClientId` | Azure AD application (client) ID |
| `-ClientSecret` | SecureString | — | Client secret override |
| `-SiteUrl` | string | — | Pre-resolve SharePoint site URL on connect |
| `-Interactive` | switch | `$false` | Use interactive delegated login |

### Secret Resolution Order (App-Only)

1. `-ClientSecret` parameter (SecureString)
2. `$env:SHAREPOINT_CLIENT_SECRET` environment variable
3. `$script:DefaultClientSecret` module-scoped default

### Get-SharePointList

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-ListName` | string | — (required) | Display name of the SharePoint list |
| `-SiteId` | string | current site | Auto-resolved when connected with `-SiteUrl` |
| `-Filter` | string | — | OData `$filter` for list items |
| `-Top` | int | `100` | Page size |
| `-All` | switch | `$false` | Auto-paginate all items |

### Add-SharePointListItem

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-ListName` | string | — (required) | Display name of the list |
| `-Fields` | hashtable | — (required) | `@{ Title='Value'; Status='Active' }` |
| `-SiteId` | string | current site | Override the current site |

### Get-SharePointFile

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-SiteId` | string | — (required) | Site GUID |
| `-DriveId` | string | — (required) | Document library GUID |
| `-FilePath` | string | — (required) | Path inside the drive |
| `-OutputPath` | string | — (required) | Local destination path |

### Upload-SharePointFile

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-SiteId` | string | — (required) | Site GUID |
| `-DriveId` | string | — (required) | Document library GUID |
| `-FilePath` | string | — (required) | Local file to upload |
| `-DrivePath` | string | — (required) | Destination folder in the drive |

---

## 🔄 Typical Workflow

```
1. Connect-SharePoint -SiteUrl "..."
       └─ Acquires token, resolves site, sets $script:Connected = $true
2. Get-SharePointList -ListName "Hardware"
       └─ Server-side OData filter? Quick page fetch
3. Add-SharePointListItem -ListName "Hardware" -Fields @{...}
       └─ ShouldProcess prompt in interactive; -WhatIf supported
4. Upload-SharePointFile -FilePath "..." -DrivePath "/..."
       └─ ShouldProcess prompt; confirms upload
5. Disconnect-SharePoint
       └─ Revokes token, clears state
```

---

## 📊 Operational Safeguards

- ✅ OData injection prevented — `''` → `''''` escape on `displayName` filters
- 🔒 `script:Connected` state-checked before every Graph call
- 🛟 Auto-pagination via `@odata.nextLink` — never silently drops results
- 📝 `-Verbose` flag on all functions for debug output
- 🛟 `ShouldProcess` on add/upload — supports `-WhatIf` for safe testing
- 🆘 Module auto-installs missing `Microsoft.Graph.*` modules from PSGallery

---

## 🐛 Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| `Cannot find module 'Microsoft.Graph.Sites'` | PSGallery blocked | `Install-Module Microsoft.Graph.Sites -Scope CurrentUser` |
| `Site not found` / `404` | App lacks site access | Verify `Sites.ReadWrite.All` + admin consent |
| `List '<name>' not found` | Display name mismatch (case-sensitive) | Verify exact display name in SharePoint UI |
| `Insufficient privileges` / `403` | Permissions not granted | Click **Grant admin consent** |
| `SiteId is required` | Connected without `-SiteUrl` | Pass `-SiteId` or reconnect with `-SiteUrl` |
| `Not connected. Run Connect-SharePoint first.` | Function called before connect | Run `Connect-SharePoint` first |
| Upload `404` on `DriveItemId` | Wrong `DrivePath` format | Use absolute path with leading slash: `/Reports` |
| `Upload-SharePointFile` overwrites silently | Default conflict behavior is `rename` | Pass `conflictBehavior = 'replace'` if overwriting is desired |

---

## 🛡 Design Principles

- **No secrets in code** — example placeholder values shown; use `$env:SHAREPOINT_CLIENT_SECRET` in production
- **Pagination handled** — `@odata.nextLink` consumed automatically with `-All`
- **Auto-dependency** — required Graph modules installed on first import
- **State-checked** — `script:Connected` guard prevents calls before connection
- **BSTR-safe** — SecureString conversion uses `ZeroFreeBSTR` in `finally`
- **ShouldProcess-friendly** — all write operations support `-WhatIf`/`-Confirm`
- **OData-safe** — string interpolation escaped against filter injection
- **Site caching** — `-SiteUrl` on connect avoids repeated resolutions

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
