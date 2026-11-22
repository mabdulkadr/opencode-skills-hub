# 📦 Connect-ExchangeOnline Module (Connect-ExchangeOnline.psm1)

> Part of **[M365 Auth Modules](../README.md)** — centralized OAuth 2.0 + Certificate-based Microsoft 365 authentication.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)
![EXO](https://img.shields.io/badge/Exchange-Online-0078D4.svg)
![Auth](https://img.shields.io/badge/Auth-Certificate%20%2B%20Interactive-2ea44f.svg)
![Version](https://img.shields.io/badge/version-1.1-green.svg)

---

## 📖 Overview

**Connect-ExchangeOnline.psm1** connects to **Exchange Online (EXO)** and the **Security & Compliance Center (IPPS)** using the `ExchangeOnlineManagement` module. **Certificate-based app-only authentication** is recommended for automation; interactive user login is provided for development/testing.

- **Auth flow:** X.509 Certificate (app-only) or interactive user login
- **API endpoint:** `outlook.office365.com` (EXO), `ps.compliance.protection.outlook.com` (IPPS)
- **Best for:** Quarantine management, message trace, retention policies, scheduled compliance tasks

> 📖 For App Registration setup see [`SETUP.md`](SETUP.md) section **3️⃣ Connect-ExchangeOnline App Registration**.

---

## ✨ Core Features

### 🔹 Connect-EXOSession
- **Certificate-based app-only** via `ExchangeOnlineManagement\Connect-ExchangeOnline -CertificateThumbprint`
- **Interactive user** login via `ExchangeOnlineManagement\Connect-ExchangeOnline` (no params)
- Connects to **EXO + IPPS** by default; `-SkipIPPS` to skip IPPS
- TLS 1.2 forced on every connect
- Banner suppressed by default; `-ShowBanner` reveals it
- Maps `AADSTS700016` / `AADSTS7000215` / `Access is denied` / certificate errors to friendly messages

### 🔹 Disconnect-EXOSession
- Disconnects from both EXO and IPPS in one call
- `-SkipIPPS` to disconnect from EXO only
- `-Confirm:$false` so it can run unattended in Task Scheduler

### 🔹 Cert-Thumbprint Resolution
1. `-CertificateThumbprint` parameter
2. `$env:EXO_CERT_THUMBPRINT` environment variable
3. `$script:DefaultCertificateThumbprint` module-scoped default

---

## ⚙️ Requirements

| Requirement | Minimum | Purpose |
|-------------|---------|---------|
| PowerShell | 5.1+ | Script execution |
| Module | `ExchangeOnlineManagement` (auto-installed if missing) | EXO cmdlets |
| Azure AD App | App registration with Exchange permissions | Authentication |
| API Permissions | `Exchange.ManageAsApp` (Application) | EXO management as app |
| Certificate | X.509 cert uploaded to app registration (public key) | App-only auth |
| Local Machine Cert | Cert installed in `Cert:\LocalMachine\My\` with private key | Sign-in for app-only |
| Network | Outbound HTTPS to `outlook.office365.com` and `ps.compliance.protection.outlook.com` | EXO + IPPS |

---

## 🚀 How to Run

### Option 1 — Certificate Auth (Recommended for Automation)

```powershell
$env:EXO_CERT_THUMBPRINT = "your-cert-thumbprint"

Import-Module .\Connect-ExchangeOnline.psm1
Connect-EXOSession -TenantId "your-tenant-id" -AppId "your-app-id" `
    -Organization "your-domain.com"

Get-QuarantineMessage -PageSize 10
Disconnect-EXOSession
```

### Option 2 — Interactive (Delegated, Development)

```powershell
Import-Module .\Connect-ExchangeOnline.psm1
Connect-EXOSession -Interactive

# Login via browser popup
Get-QuarantineMessage -PageSize 5
Disconnect-EXOSession
```

### Option 3 — Skip Compliance Center

```powershell
Connect-EXOSession -CertificateThumbprint "your-thumbprint" `
    -AppId "your-app-id" -Organization "your-domain.com" -SkipIPPS

Get-Recipient -ResultSize 100
Disconnect-EXOSession
```

### Option 4 — Scheduled Task (SYSTEM Context)

```powershell
# Run as SYSTEM so cert in LocalMachine\My store is accessible
$env:EXO_CERT_THUMBPRINT = "your-thumbprint"
Import-Module "C:\Modules\Connect-ExchangeOnline.psm1"
Connect-EXOSession -AppId $env:EXO_APP_ID -Organization "contoso.com"

$result = Get-QuarantineMessage -PageSize 100 | Where-Object { $_.Released -eq $false }
$result | Export-Csv "C:\Reports\Quarantine.csv" -NoTypeInformation

Disconnect-EXOSession
```

---

## ⚙️ Parameters

### Connect-EXOSession

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-AppId` | string | `$script:DefaultAppId` | Azure AD application (client) ID |
| `-TenantId` | string | `$script:DefaultTenantId` | Azure AD tenant ID |
| `-CertificateThumbprint` | string | env/default | Certificate thumbprint for app-only auth |
| `-Organization` | string | `$script:DefaultOrganization` | Organization domain (e.g., `contoso.com`) |
| `-Interactive` | switch | `$false` | Use interactive user login (browser) |
| `-SkipIPPS` | switch | `$false` | Skip Security & Compliance Center |
| `-ShowBanner` | switch | `$false` | Show EXO module banner |

### Secret / Certificate Resolution Order (App-Only)

1. `-CertificateThumbprint` parameter
2. `$env:EXO_CERT_THUMBPRINT` environment variable
3. `$script:DefaultCertificateThumbprint` module-scoped default

### Disconnect-EXOSession

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-SkipIPPS` | switch | `$false` | Skip disconnecting from IPPS |

---

## 🔄 Typical Workflow

```
1. Connect-EXOSession                  ──▶ Auto-installs module, enforces TLS 1.2
       └─ App-only cert OR interactive   ──▶ Maps AADSTS codes to friendly errors
2. EXO cmdlets                         ──▶ Get-QuarantineMessage, Get-Recipient, etc.
       └─ IPPS cmdlets (security/compliance) — unless -SkipIPPS
3. Disconnect-EXOSession               ──▶ Confirms clean shutdown of both sessions
```

---

## 📊 Operational Safeguards

- ✅ TLS 1.2 forced via `[Net.ServicePointManager]::SecurityProtocol`
- 🔒 Cert auth never sends secrets over the wire — only RSA-signed JWTs
- 🛟 AADSTS error code mapping — `AADSTS700016` / `7000215` / `certificate not found` → readable errors
- 🔄 `-Confirm:$false` on disconnect — safe in unattended scripts
- 🛡 `ShowBanner` defaults to `$false` — quieter scheduled-task runs
- 🆘 Module auto-installs `ExchangeOnlineManagement` from PSGallery

---

## 🐛 Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| `AADSTS700016` | Wrong `AppId` or app not in tenant | Verify Azure AD app registration |
| `AADSTS7000215` | Invalid certificate | Re-upload cert to Azure AD > Certificates & secrets |
| `Access is denied` / `Forbidden` | Missing `Exchange.ManageAsApp` | Add from **APIs my org uses** → Office 365 Exchange Online |
| `Certificate not found` | Cert not in `Cert:\LocalMachine\My\` | `Import-PfxCertificate` or install from local store |
| `Connect-IPPSSession` connection error | IPPS endpoint blocked | Allow outbound 443 to `ps.compliance.protection.outlook.com` |
| `Connect-EXOSession` succeeds; IPPS fails | IPPS handshake issue | Use `-SkipIPPS` or update `ExchangeOnlineManagement` to v3+ |
| Quarantine cmdlets missing | Older module version | `Update-Module ExchangeOnlineManagement -Force` |
| `Connect-EXOSession` hangs | No internet or firewall block | Test outbound 443 to `outlook.office365.com` |

---

## 🛡 Design Principles

- **Certificate auth preferred** — no client secrets to leak; ideal for scheduled tasks
- **TLS 1.2 enforced** — always, even on older runtimes
- **Friendly AADSTS mapping** — AAD error codes translated to plain English
- **IPPS-by-default** — most compliance scripts need both; `-SkipIPPS` to opt out
- **No silent failures** — `$true` / `$false` return; `Write-Error` on every failure path
- **Auto-dependency** — `ExchangeOnlineManagement` installed on first connect
- **Banner-quiet** — banner suppressed by default to keep Task Scheduler logs clean

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
