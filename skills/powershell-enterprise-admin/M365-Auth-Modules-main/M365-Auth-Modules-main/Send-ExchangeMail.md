# 📦 Send-ExchangeMail Module (Send-ExchangeMail.psm1)

> Part of **[M365 Auth Modules](../README.md)** — centralized OAuth 2.0 + Certificate-based Microsoft 365 authentication.

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)
![Graph](https://img.shields.io/badge/API-Microsoft%20Graph-0078D6.svg)
![Mail](https://img.shields.io/badge/Mail-OAuth%202.0-0078D4.svg)
![Auth](https://img.shields.io/badge/Auth-OAuth%202.0-2ea44f.svg)
![Version](https://img.shields.io/badge/version-1.1-green.svg)

---

## 📖 Overview

**Send-ExchangeMail.psm1** sends HTML email through Microsoft Graph API using **OAuth 2.0 client credentials** (app-only). It is designed for an Azure AD app registration with the `Mail.Send` application permission. **No SMTP**, **no Basic Auth**, **no legacy protocols**.

- **Auth flow:** OAuth 2.0 client credentials (app-only) only
- **API endpoint:** `https://graph.microsoft.com/v1.0/users/{from}/sendMail`
- **Best for:** Scheduled reports, alert emails, automated notifications from non-interactive scripts

> 📖 For App Registration setup see [`SETUP.md`](SETUP.md) section **2️⃣ Send-ExchangeMail App Registration**.

---

## ✨ Core Features

### 🔹 Send-ExchangeMail (Single Public Function)
- **HTML body** (`<h1>`, tables, formatting) via `contentType = HTML`
- **CC / BCC** recipient arrays
- **File attachments** as Graph `fileAttachment` with Base64-encoded `contentBytes`
- **Save to Sent Items** via `-SaveToSentItems` switch
- **Send As** mailbox — the app must be granted "Send As" in Exchange Admin Center

### 🔹 OAuth 2.0 Token Acquisition
- POST to `login.microsoftonline.com/{tenant}/oauth2/v2.0/token`
- BSTR-safe SecureString handling — `ZeroFreeBSTR` in `finally` block
- Surfaces AADSTS `error_description` from response body for troubleshooting

### 🔹 Multi-Source Secret Resolution
- Priority: `-ClientSecret` parameter → `$env:EXCHANGE_CLIENT_SECRET` → `$script:DefaultClientSecret`
- Plain-text fallback via `-ClientSecretDefault` parameter for legacy tooling

---

## ⚙️ Requirements

| Requirement | Minimum | Purpose |
|-------------|---------|---------|
| PowerShell | 5.1+ | Script execution |
| Azure AD App | App registration with Mail permission | Authentication |
| API Permissions | `Mail.Send` (Application) | Sending mail as any user |
| Exchange Admin | App granted **Send As** for the `-From` mailbox | Send on behalf of mailbox |
| Network | Outbound HTTPS to `login.microsoftonline.com` and `graph.microsoft.com` | Token + sendMail call |

---

## 🚀 How to Run

### Option 1 — From a Scheduled Task (Recommended)

```powershell
# Task Scheduler → Action: powershell.exe -File "C:\Scripts\SendReport.ps1"
$env:EXCHANGE_CLIENT_SECRET = $env:EXCHANGE_CLIENT_SECRET  # Machine env var
Import-Module "C:\Modules\Send-ExchangeMail.psm1"

Send-ExchangeMail `
    -From "noreply@contoso.com" `
    -To "ops-team@contoso.com" `
    -Subject "Weekly Compliance Report — $(Get-Date -Format 'yyyy-MM-dd')" `
    -Body "<h1>Weekly Report</h1><p>All systems green.</p>" `
    -Attachments "C:\Reports\Weekly.csv"
```

### Option 2 — Interactive (with explicit secret)

```powershell
$secret = ConvertTo-SecureString "your-secret" -AsPlainText -Force
Import-Module .\Send-ExchangeMail.psm1

Send-ExchangeMail `
    -From "noreply@contoso.com" `
    -To "user@contoso.com" `
    -Subject "Test" `
    -Body "<h1>Hello</h1>" `
    -TenantId "your-tenant-id" `
    -ClientId "your-app-id" `
    -ClientSecret $secret
```

### Option 3 — Variables Inline

```powershell
$env:EXCHANGE_CLIENT_SECRET = "your-client-secret"
$env:TENANT_ID = "your-tenant-id"
$env:CLIENT_ID = "your-app-id"

Import-Module .\Send-ExchangeMail.psm1
Send-ExchangeMail -From "noreply@contoso.com" -To "user@contoso.com" `
    -Subject "Test" -Body "<p>Hello</p>"
# Tenant/Client resolved from $script:Default* values
```

---

## ⚙️ Parameters

### Send-ExchangeMail

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-From` | string | — (required) | Sender mailbox the app has Send As on |
| `-To` | string[] | — (required) | Recipient email address(es) |
| `-Subject` | string | — (required) | Email subject line |
| `-Body` | string | — (required) | HTML body content |
| `-Cc` | string[] | empty | CC recipient(s) |
| `-Bcc` | string[] | empty | BCC recipient(s) |
| `-Attachments` | string[] | empty | Local file path(s) to attach as `fileAttachment` |
| `-SaveToSentItems` | switch | `$false` | Save copy in sender's Sent Items |
| `-TenantId` | string | `$script:DefaultTenantId` | Azure AD tenant ID |
| `-ClientId` | string | `$script:DefaultClientId` | Azure AD application (client) ID |
| `-ClientSecret` | SecureString | — | Client secret override |
| `-ClientSecretDefault` | string | — | Plaintext fallback secret |

### Secret Resolution Order (App-Only)

1. `-ClientSecret` parameter (SecureString)
2. `$env:EXCHANGE_CLIENT_SECRET` environment variable
3. `-ClientSecretDefault` parameter (plaintext)
4. `$script:DefaultClientSecret` module-scoped default

---

## 🔄 Typical Workflow

```
1. Send-ExchangeMail invoked
2. Resolve credentials  ──▶ param > env > ClientSecretDefault > module default
3. Acquire Graph token  ──▶ POST /oauth2/v2.0/token, BSTR-safe finally
4. Build message body   ──▶ HTML, toRecipients, ccRecipients, bccRecipients
5. Encode attachments   ──▶ fileAttachment with Base64 contentBytes
6. POST /users/{from}/sendMail ──▶ Returns $true/$false
```

---

## 📊 Operational Safeguards

- ✅ BSTR-safe SecureString handling — `ZeroFreeBSTR` in `finally` blocks
- 🔒 Plaintext secret `[System.Text.Encoding]::UTF8.GetBytes` only inside request scope
- 🛟 Returns `$true` on success, descriptive `Write-Error` on failure
- 🛡 `saveToSentItems` defaults to `$false` — explicit opt-in for compliance
- 📝 `-Verbose` on acquisition + dispatch messages
- 🆘 Surfaces AADSTS `error_description` from token API response

---

## 🐛 Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| `Send-ExchangeMail: No client secret provided` | All sources empty | Set env var or pass `-ClientSecret` |
| `Mail.Send ... 403` | App lacks `Mail.Send` | Add `Mail.Send` + **Grant admin consent** |
| `SendAsDenied` | App not authorized for `-From` mailbox | Add Send As in **Exchange Admin Center** → mailbox → delegation |
| `AADSTS700016` | Wrong `ClientId` | Verify app registration |
| `AADSTS7000215` | Invalid `ClientSecret` | Regenerate in Certificates & secrets |
| `AuthenticationRequired` (Graph) | App not granted mailbox.SendAs | Re-grant via Exchange Admin Center |
| Empty `To` accepted but nothing sent | Address filter rejects empty arrays | Always pass at least one recipient |
| Attachment > 25 MB | Graph sendMail size limit | Use OneDrive upload + sharing link |

---

## 🛡 Design Principles

- **No SMTP / No Basic Auth** — Graph API only; future-proof against SMTP AUTH deprecation
- **HTML-first** — `contentType = HTML` on all sends
- **BSTR-safe** — SecureString conversion uses `ZeroFreeBSTR` in `finally`
- **Multi-source secret** — parameter → env var → plaintext fallback → module default
- **Explicit Send-As** — uses `from` field to identify the sender mailbox
- **No persistence** — no token caching; token lives only during the function call
- **Attestation-friendly** — `saveToSentItems` toggles user-visible audit trail

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
