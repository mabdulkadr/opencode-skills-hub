# 📦 Connect-Teams Module (Connect-Teams.psm1)

> Part of **[M365 Auth Modules](../README.md)** — centralized OAuth 2.0 + Certificate-based Microsoft 365 authentication.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)
![Graph](https://img.shields.io/badge/API-Microsoft%20Graph-0078D6.svg)
![Teams](https://img.shields.io/badge/Teams-Microsoft%20Graph-6264A7.svg)
![Auth](https://img.shields.io/badge/Auth-OAuth%202.0%20%2B%20Interactive-2ea44f.svg)
![Version](https://img.shields.io/badge/version-1.1-green.svg)

---

## 📖 Overview

**Connect-Teams.psm1** is a Microsoft Teams management module via Microsoft Graph API. It authenticates with Teams-specific permission scopes and provides helpers for **listing teams**, **channels**, **members**, and **creating new channels** (standard, private, shared).

- **Auth flow:** OAuth 2.0 client credentials (app-only) or delegated (browser OAuth)
- **API endpoint:** `https://graph.microsoft.com/v1.0/`
- **Best for:** Teams inventory, channel provisioning, member reporting

> 📖 For App Registration setup see [`SETUP.md`](SETUP.md) section **4️⃣ Connect-Teams App Registration**.

---

## ✨ Core Features

### 🔹 Connect-Teams / Disconnect-Teams
- OAuth 2.0 client credentials flow (app-only) or interactive delegated
- Auto-installs `Microsoft.Graph.Authentication` + `Microsoft.Graph.Teams`
- Token caching with `finally`-block leak protection
- `Disconnect-Teams` clears cache + terminates Graph session safely

### 🔹 Get-TeamsAll
- Lists all teams visible to the authenticated identity
- Auto-pagination via `-All` switch (handles `@odata.nextLink`)
- `-Top` bound `1..999` for per-page control

### 🔹 Get-TeamsChannel / Get-TeamsMember
- Lists all channels of a given team
- Lists all members (owners + members) of a given team
- Both auto-paginate until exhausted

### 🔹 New-TeamsChannel
- Creates a channel with name + optional description
- `-MembershipType` accepts `standard`, `private`, `shared` (default `standard`)
- `ShouldProcess` enabled — supports `-WhatIf` for safe dry-runs

### 🔹 Generic Graph Request Helper
- Internal `Invoke-GraphRequest` issues GET/POST/PATCH/DELETE/PUT
- Auto-`Content-Type` JSON unless overridden
- Surfaces HTTP status code in error output

---

## ⚙️ Requirements

| Requirement | Minimum | Purpose |
|-------------|---------|---------|
| PowerShell | 5.1+ | Script execution |
| Azure AD App | App registration with Teams permissions | Authentication |
| API Permissions | `Team.ReadBasic.All`, `Channel.ReadBasic.All`, `TeamMember.Read.All`, `Channel.Create` (Application) | Teams data access + creation |
| Network | Outbound HTTPS to `login.microsoftonline.com` and `graph.microsoft.com` | Token + Graph API calls |
| Auto-installed | Microsoft.Graph.Authentication + Microsoft.Graph.Teams | Cmdlet access |

---

## 🚀 How to Run

### Option 1 — App-Only (Recommended for Automation)

```powershell
$env:TEAMS_CLIENT_SECRET = "your-client-secret"

Import-Module .\Connect-Teams.psm1
Connect-Teams -TenantId "your-tenant-id" -ClientId "your-app-id"

$teams = Get-TeamsAll -All
$teams | Select-Object DisplayName, Id

$channels = Get-TeamsChannel -TeamId $teams[0].Id
$channels | Select-Object DisplayName, MembershipType

New-TeamsChannel -TeamId $teams[0].Id -Name "Weekly Reports" -MembershipType standard

Disconnect-Teams
```

### Option 2 — Interactive (Browser OAuth Delegated)

```powershell
Import-Module .\Connect-Teams.psm1
Connect-Teams -TenantId "your-tenant-id" -ClientId "your-app-id" -Interactive

$teams = Get-TeamsAll -Top 50
$teams | Format-Table DisplayName, Id

Disconnect-Teams
```

### Option 3 — Scheduled Channel Provisioning

```powershell
$env:TEAMS_CLIENT_SECRET = $env:TEAMS_CLIENT_SECRET  # Machine env var
Import-Module "C:\Modules\Connect-Teams.psm1"
Connect-Teams -TenantId $env:TEAMS_TENANT_ID -ClientId $env:TEAMS_CLIENT_ID

$teamId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
New-TeamsChannel -TeamId $teamId -Name "Project Alpha" -MembershipType standard -WhatIf

Disconnect-Teams
```

---

## ⚙️ Parameters

### Connect-Teams

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-TenantId` | string | `$script:DefaultTenantId` | Azure AD tenant ID |
| `-ClientId` | string | `$script:DefaultClientId` | Azure AD application (client) ID |
| `-ClientSecret` | SecureString | — | Client secret override |
| `-Interactive` | switch | `$false` | Use interactive delegated login |

### Secret Resolution Order (App-Only)

1. `-ClientSecret` parameter (SecureString)
2. `$env:TEAMS_CLIENT_SECRET` environment variable
3. `$script:DefaultClientSecret` module-scoped default

### Get-TeamsAll

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Top` | int | `100` | Max teams per page (1..999) |
| `-All` | switch | `$false` | Auto-paginate all teams |

### Get-TeamsChannel

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-TeamId` | string | — (required) | Team GUID |

### Get-TeamsMember

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-TeamId` | string | — (required) | Team GUID |

### New-TeamsChannel

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-TeamId` | string | — (required) | Target team GUID |
| `-Name` | string | — (required) | Channel display name (max 256 chars) |
| `-Description` | string | empty | Channel description (max 1024 chars) |
| `-MembershipType` | string | `standard` | `standard` / `private` / `shared` |

---

## 🔄 Typical Workflow

```
1. Connect-Teams                     ──▶ Token cached; TLS 1.2 enforced
2. Get-TeamsAll -All                 ──▶ Page through @odata.nextLink
3. For each team: Get-TeamsChannel   ──▶ Iterate channels per team
4. For each team: Get-TeamsMember    ──▶ Enumerate member objects
5. New-TeamsChannel -TeamId $id      ──▶ ShouldProcess confirm (-WhatIf supported)
6. Disconnect-Teams                  ──▶ Clear token cache, terminate session
```

---

## 📊 Operational Safeguards

- ✅ BSTR-safe SecureString handling — `ZeroFreeBSTR` in `finally` blocks
- 🔒 `script:TokenCache` cleared on disconnect — no residue in memory
- 🛟 Auto-pagination via `@odata.nextLink` for all list operations
- 🛡 `ShouldProcess` on `New-TeamsChannel` — supports `-WhatIf` for safe testing
- 📝 `-Verbose` flag on all functions for debug output
- 🆘 Module auto-installs missing `Microsoft.Graph.*` modules from PSGallery

---

## 🐛 Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| `No active session. Please run Connect-Teams first.` | Function called before connect | Run `Connect-Teams` first |
| `AADSTS700016` | Wrong `ClientId` or app not in tenant | Verify Azure AD app registration |
| `AADSTS7000215` | Invalid `ClientSecret` | Regenerate in Certificates & secrets |
| `403 Forbidden` on `New-TeamsChannel` | App lacks `Channel.Create` | Add permission and re-consent |
| `403` on `Get-TeamsAll` returns empty | No admin consent | Click **Grant admin consent** |
| `Microsoft.Graph.Teams` not found | PSGallery blocked | `Install-Module Microsoft.Graph.Teams -Scope CurrentUser` |
| New private channel needs extra perms | Private channels need additional Graph perms | See Microsoft Graph private channel permissions |
| `Interactive` login fails | No redirect URI configured for device-code flow | Default uses device code; no URI needed |

---

## 🛡 Design Principles

- **No secrets in code** — example placeholder values shown; use `$env:TEAMS_CLIENT_SECRET` in production
- **Pagination handled** — `@odata.nextLink` consumed automatically with `-All`
- **Auto-dependency** — required Graph modules installed on first import
- **State-checked** — `script:TokenCache` cleared on disconnect
- **BSTR-safe** — SecureString conversion uses proper cleanup
- **ShouldProcess-friendly** — `New-TeamsChannel` supports `-WhatIf`/`-Confirm`
- **Membership-typed** — explicit `[ValidateSet]` on `MembershipType` prevents bad values
- **Generic helper** — internal `Invoke-GraphRequest` covers GET/POST/PATCH/DELETE/PUT for ad-hoc needs

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
