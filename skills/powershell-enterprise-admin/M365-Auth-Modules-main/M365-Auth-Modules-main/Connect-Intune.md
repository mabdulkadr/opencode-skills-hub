# 📦 Connect-Intune Module (Connect-Intune.psm1)

> Part of **[M365 Auth Modules](../README.md)** — centralized OAuth 2.0 + Certificate-based Microsoft 365 authentication.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)
![Graph](https://img.shields.io/badge/API-Microsoft%20Graph-0078D6.svg)
![Auth](https://img.shields.io/badge/Auth-OAuth%202.0%20%2B%20Cert-2ea44f.svg)
![Version](https://img.shields.io/badge/version-1.1-green.svg)

---

## 📖 Overview

**Connect-Intune.psm1** connects to **Microsoft Intune** via Microsoft Graph API with Intune-specific permission scopes. Supports both **app-only** (client credentials) and **delegated** (browser OAuth) authentication. Provides helpers for **device enumeration**, **sync commands**, and **policy retrieval**.

- **Auth flow:** OAuth 2.0 client credentials (app-only) or interactive user login
- **API endpoint:** `https://graph.microsoft.com/Beta/`
- **Best for:** Intune device audits, sync automation, policy reports

> 📖 For App Registration setup see [`SETUP.md`](SETUP.md) section **1️⃣ Connect-Intune App Registration**.

---

## ✨ Core Features

### 🔹 Connect-Intune / Disconnect-Intune
- OAuth 2.0 client credentials flow (app-only) or interactive delegated
- Auto-installs `Microsoft.Graph.Authentication`
- Auto-detects Graph SDK v2 vs v1; switches profile to Beta for v1
- Maps `AADSTS700016` / `AADSTS7000215` / `Access is denied` to friendly errors

### 🔹 Get-IntuneDevices
- Lists all managed devices via `/Beta/deviceManagement/managedDevices`
- Auto-pagination via `@odata.nextLink`
- Optional `-Filter` (e.g., `deviceName eq 'PC-001'`)
- Optional `-Top` to cap result size

### 🔹 Send-IntuneDeviceSync
- POSTs `syncDevice` action to a specific device by ID
- Returns `$true` on success, descriptive error on failure

### 🔹 Get-IntunePolicy
- Lists all device configuration policies
- Optional `-Name` substring filter applied client-side
- Auto-paginated across all policy pages

---

## ⚙️ Requirements

| Requirement | Minimum | Purpose |
|-------------|---------|---------|
| PowerShell | 5.1+ | Script execution |
| Module | `Microsoft.Graph.Authentication` (auto-installed if missing) | Graph SDK |
| Azure AD App | App registration with Intune permissions | Authentication |
| API Permissions | `DeviceManagementManagedDevices.ReadWrite.All`, `DeviceManagementConfiguration.ReadWrite.All`, `DeviceManagementManagedDevices.PrivilegedOperations.All`, `Directory.Read.All` (Application) | Intune data + remote actions |
| Network | Outbound HTTPS to `login.microsoftonline.com` and `graph.microsoft.com` | Token + Graph calls |

---

## 🚀 How to Run

### Option 1 — App-Only (Recommended for Automation)

```powershell
$env:INTUNE_CLIENT_SECRET = "your-client-secret"

Import-Module .\Connect-Intune.psm1
Connect-Intune -TenantId "your-tenant-id" -ClientId "your-app-id"

$devices = Get-IntuneDevices
$devices | Where-Object { $_.osVersion -lt "10.0.22631" } |
    Select-Object deviceName, osVersion, lastSyncDateTime

Disconnect-Intune
```

### Option 2 — Interactive (Delegated)

```powershell
Import-Module .\Connect-Intune.psm1
Connect-Intune -Interactive

Get-IntunePolicy -Name "Windows Update" | Format-Table displayName, lastModifiedDateTime
Disconnect-Intune
```

### Option 3 — Trigger Device Sync (Scheduled)

```powershell
$env:INTUNE_CLIENT_SECRET = $env:INTUNE_CLIENT_SECRET
Import-Module "C:\Modules\Connect-Intune.psm1"
Connect-Intune

$devices = Get-IntuneDevices -Filter "lastSyncDateTime le 2025-01-01T00:00:00Z"
foreach ($d in $devices) {
    Send-IntuneDeviceSync -DeviceId $d.id
    Write-Host "Synced: $($d.deviceName)"
}

Disconnect-Intune
```

---

## ⚙️ Parameters

### Connect-Intune

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-ClientId` | string | `$script:DefaultClientId` | Azure AD application (client) ID |
| `-TenantId` | string | `$script:DefaultTenantId` | Azure AD tenant ID |
| `-ClientSecret` | SecureString | — | Client secret override |
| `-Interactive` | switch | `$false` | Use interactive user login |
| `-Scopes` | string[] | module defaults | Custom Graph scopes for interactive auth |

### Secret Resolution Order (App-Only)

1. `-ClientSecret` parameter (SecureString)
2. `$env:INTUNE_CLIENT_SECRET` environment variable
3. `$script:DefaultClientSecret` module-scoped default

### Get-IntuneDevices

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Filter` | string | — | OData filter (e.g., `deviceName eq 'PC-001'`) |
| `-Top` | int | `0` (all) | Max devices per page; `0` = all |

### Send-IntuneDeviceSync

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-DeviceId` | string | — (required) | Intune device GUID |

### Get-IntunePolicy

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Name` | string | — | Substring filter on `displayName` |

---

## 🔄 Typical Workflow

```
1. Connect-Intune                     ──▶ Token acquired; profile set to Beta
2. Get-IntuneDevices                  ──▶ Page through @odata.nextLink
3. Filter / report on devices         ──▶ e.g., lastSyncDateTime, osVersion
4. Send-IntuneDeviceSync -DeviceId $d ──▶ Force a sync on stale devices
5. Get-IntunePolicy -Name "..."       ──▶ Filter policies client-side
6. Disconnect-Intune                  ──▶ Terminate Graph session
```

---

## 📊 Operational Safeguards

- ✅ BSTR-safe SecureString handling — `ZeroFreeBSTR` in `finally` blocks
- 🔒 `script:Connected` state-checked before every Graph call
- 🛟 Auto-pagination via `@odata.nextLink` — never silently drops results
- 🔄 Token re-acquired on each `Connect-Intune` call (no stale tokens)
- 📝 `-Verbose` flag on all functions for debug output
- 🆘 Module auto-installs `Microsoft.Graph.Authentication` from PSGallery
- 🛡 Friendly AADSTS mapping — `AADSTS700016` / `7000215` / `Access denied` translated

---

## 🐛 Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| `AADSTS700016` | Wrong `ClientId` or app not in tenant | Verify app registration values |
| `AADSTS7000215` | Invalid `ClientSecret` | Regenerate in Certificates & secrets |
| `403 Forbidden` | Permissions missing | Add Intune permissions + **Grant admin consent** |
| `Not connected. Run Connect-Intune first.` | Function called before connect | Run `Connect-Intune` first |
| `Failed to install Microsoft.Graph.Authentication` | PSGallery blocked | `Install-Module Microsoft.Graph.Authentication -Scope CurrentUser` |
| `Beta endpoint not found` | Using older Graph SDK | `Update-Module Microsoft.Graph.* -Force` |
| `Get-IntuneDevices` returns empty | Wrong endpoint filter or no devices | Verify with `Get-MgDeviceManagementManagedDevice` directly |
| `Send-IntuneDeviceSync` 404 | Device not managed by this tenant | Verify device ID against `Get-IntuneDevices` |
| `Get-MgContext` empty | Disconnected state | Re-run `Connect-Intune` |

---

## 🛡 Design Principles

- **No secrets in code** — example placeholder values shown; use `$env:INTUNE_CLIENT_SECRET` in production
- **Pagination handled** — `@odata.nextLink` consumed automatically
- **Auto-dependency** — required Graph modules installed on first import
- **State-checked** — `script:Connected` guard prevents calls before connection
- **BSTR-safe** — SecureString conversion uses `ZeroFreeBSTR` in `finally`
- **Friendly errors** — AADSTS codes translated to plain English
- **Beta endpoint** — uses `/Beta/deviceManagement/managedDevices` for richer data
- **Profile-aware** — auto-detects v2 vs v1 SDK and selects correct profile

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
