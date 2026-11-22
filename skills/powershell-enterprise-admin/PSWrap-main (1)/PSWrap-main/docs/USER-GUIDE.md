# PSWrap User Guide

> Complete end-user guide for compiling PowerShell scripts to Windows executables.

---

## Getting Started

### Prerequisites

- **Windows 7+** (Windows 10/11 recommended)
- **PowerShell 5.1** (Windows PowerShell — also supports PowerShell Core 7.x)
- **.NET Framework 4.7.2+** (included with Windows 10/11)

### Launch

```powershell
powershell.exe -STA -File "Start-PSWrap.ps1"
```

Or double-click `Start-PSWrap.ps1` in File Explorer.

> **Note:** STA (Single-Threaded Apartment) mode is required for WPF. The tool auto-restarts with `-STA` if launched without it.

---

## Main Window Layout

```
┌──────────────────────────────────────────────────────────────────────────┐
│ ┌─────────sidebar (220px)──────────┐ ┌──────header───────────────────┐ │
│ │ ⬡ PSWrap                         │ │  Script to EXE Compiler   ☀️ │ │
│ │   Script to EXE Compiler          │ │  Compile PowerShell...       │ │
│ │                                   │ └──────────────────────────────┘ │
│ │ ─── TOOLS ────────               │ ┌──────body (main content)─────┐ │
│ │ [■ PS1 to EXE]                   │ │ ┌─────────────────────────┐  │ │
│ │                                   │ │ │Last Compile│Src Size   │  │ │
│ │ ┌── Session ────┐                │ │ │   --       │  --       │  │ │
│ │ │ Machine: HOST │                │ │ │OS Target  │Output Type│  │ │
│ │ │ User:   USER  │                │ │ │  AnyCPU   │  GUI      │  │ │
│ │ │ Elevation: No │                │ │ │ PS Version │           │  │ │
│ │ └───────────────┘                │ │ │   5.1     │           │  │ │
│ │                                   │ │ └─────────────────────────┘  │ │
│ │ [📄 About]  [📋 Logs]            │ │ ┌── SOURCE FILES ──────────┐ │ │
│ │ Version 1.0.0                    │ │ │ Project Folder  [____] 🔍│ │ │
│ │ (c) 2026 Mohammad Omar           │ │ │ Source Script   [____] 🔍│ │ │
│ └───────────────────────────────────┘ │ │ Output Path     [____] 🔍│ │ │
│                                        │ │ Custom Icon     [____] 🔍│ │ │
│                                        │ └─────────────────────────┘ │ │
│                                        │ ┌─────────────────────────┐ │ │
│                                        │ │ [⚙Settings] [▶Compile] │ │ │
│                                        │ │ [📂Open] [🗑Clear]      │ │ │
│                                        │ └─────────────────────────┘ │ │
│                                        │ └──────────────────────────┘ │ │
│                                        │ ┌────status bar────────────┐ │ │
│                                        │ │ ● Ready │ Drag & drop...│ │ │
│                                        │ └──────────────────────────┘ │ │
└──────────────────────────────────────────────────────────────────────────┘
```

### Window Sections

| Section | Description |
|---|---|
| **Sidebar** (left) | App logo, navigation, session info, About/Logs buttons, version with copyright |
| **Header** (top) | Page title, subtitle, theme toggle |
| **Body** (center) | KPI stat cards, file selection form, action buttons |
| **Status Bar** (bottom) | Connection status, progress bar, live clock |

---

## Complete Workflow

### Step 1: Select Project Folder (Optional)

Click **Browse** (green folder button) next to "Project Folder" to select a folder containing your `.ps1` files.

**Auto-detection:** When you select a folder, PSWrap automatically:
- Finds the first `.ps1` file and fills the "Source Script" field
- Finds the first `.ico` file for the icon
- If no `.ico` found, looks for PNG/JPG/BMP/GIF and auto-converts to `.ico`
- Sets the output path to `<scriptname>.exe` in the same folder

### Step 2: Select Source Script

Click **Browse** (blue document button) next to "Source Script" to select your `.ps1` file.

**Alternative: Drag & Drop**
- Drag any `.ps1` file from File Explorer onto the PSWrap window
- The source script field auto-fills
- If output path is empty, it auto-sets to `<scriptname>.exe`

### Step 3: Set Output Path

Click **Browse** (blue download button) next to "Output Path" to choose where the compiled `.exe` will be saved. The path auto-defaults to `<scriptname>.exe` if not specified.

### Step 4: Choose Custom Icon (Optional)

Click **Browse** (outline image button) next to "Custom Icon" to select:
- `.ico` file — used directly
- PNG/JPG/BMP/GIF — auto-converted to `.ico` with 16, 32, 48, and 256px resolutions

If no icon is selected, the built-in default app icon is used.

### Step 5: Configure Settings (Optional)

Click the **Settings** button to open the Build Settings dialog:

#### Assembly Metadata Tab
| Field | Example | Description |
|---|---|---|
| Version | `1.0.0.0` | Assembly version (Major.Minor.Build.Revision) |
| Product | `MyTool` | Product name metadata |
| File Desc | `Network Diagnostic Tool` | File description shown in Properties |
| Copyright | `© 2026 My Company` | Copyright notice |
| Company | `My Company` | Company name |
| Trademark | `MyTool™` | Trademark info |

#### Compilation Options
| Option | Default | Description |
|---|---|---|
| GUI Application (no console) | ON | Creates a Windows GUI app (no console window) |
| Suppress output | OFF | Suppresses `Write-Host` / stdout output |
| Suppress errors | OFF | Suppresses error stream output |
| Require admin rights | OFF | Adds UAC manifest requesting administrator privileges |
| Generate config file | OFF | Creates `app.exe.config` alongside the executable |

#### Runtime Settings
| Setting | Options | Default | Description |
|---|---|---|---|
| Thread Apartment | STA / MTA | STA | Single-Threaded (STA) for UI apps, Multi-Threaded (MTA) for services |
| Target CPU | AnyCPU / x86 / x64 | AnyCPU | Platform target for the compiled executable |
| Extra Arguments | (free text) | — | Additional `csc.exe` compiler arguments (e.g. `/nowarn:1701`) |

### Step 6: Compile

Click **Compile to EXE** to start compilation.

**During compilation:**
- UI buttons are disabled
- Progress bar shows indeterminate animation
- Status bar shows progress messages

**After completion:**
- Success toast appears with green check
- Log entries show compilation details
- `KpiLastCompile` timestamp updates
- Click **Open Output** to open the output folder in Explorer

---

## UI Features

### Theme Toggle

Click the **sun/moon icon** in the top-right header to switch between Light and Dark themes. The setting persists across sessions.

| Mode | Icon | Color |
|---|---|---|
| Light | ☀️ Sun | Yellow (`#EAB308`) |
| Dark | 🌙 Moon | Gray (`#CBD5E1`) |

### KPI Stat Cards

The top of the body area shows five stat cards in a Grid layout:

| Card | Description |
|---|---|
| **Last Compile** | Timestamp of the last successful compilation this session |
| **Source Size** | Size of the selected source script |
| **OS Target** | Target CPU platform (AnyCPU, x86, x64) |
| **Output Type** | Output mode (GUI or Console) |
| **PS Version** | Detected PowerShell version |

### Toast Notifications

Non-blocking notifications slide in from the bottom-right corner:

| Type | Color | Icon | Example |
|---|---|---|---|
| Success | Green (#10B981) | ✓ | "Compilation completed successfully!" |
| Error | Red (#EF4444) | ✗ | "Source file not found" |
| Warning | Yellow (#F59E0B) | ⚠ | "Output folder does not exist yet" |
| Info | Blue (#3B82F6) | ℹ | "Compilation started..." |

Toasts auto-dismiss after 3 seconds (200ms fade-in, 3s display, 300ms fade-out).

### Log Viewer

Click **Logs** in the sidebar footer to open the Log Viewer sub-window.

**Features:**
- Color-coded entries by level (blue=INFO, green=SUCCESS, yellow=WARNING, red=ERROR)
- Copy all entries to clipboard
- Clear all entries
- Monospace font (Consolas) on dark background
- Auto-scroll to latest entry

### About Dialog

Click **About** in the sidebar footer to open the About dialog with documentation tabs. Each `.md` file in the `docs/` folder renders as a separate tab with formatted markdown.

### Session Info

The sidebar shows session information:

| Field | Description |
|---|---|
| **Machine** | Computer name (blue badge) |
| **User** | Current username (green badge) |
| **Elevation** | Admin status (yellow badge) |

---

## Keyboard Shortcuts

| Key | Action |
|---|---|
| **F5** | Refresh UI state and KPI cards |
| **Enter** (in Settings dialog) | Apply changes and close |

---

## Responsive Layout

PSWrap adapts to different window sizes:

| Window Width | Behavior |
|---|---|
| **≥1200px** (wide) | All 5 stat cards in one row, full-width inputs, buttons in one row |
| **900-1200px** (medium) | Stat cards remain in one row (Grid columns auto-scale), buttons in one row |
| **<900px** (narrow) | Inputs remain usable, action buttons wrap to multiple rows |
| **Minimum (900x600)** | All content accessible via vertical scroll |

**Key responsive behaviors:**
- KPI stat cards: Grid with 5 equal `*` columns, auto-scale with window width
- Action buttons: WrapPanel wraps to next line on narrow windows
- Input fields: Expand to fill available space up to `MaxWidth=600`
- Horizontal scrollbar: Disabled — content wraps or clips instead of overflowing

---

## Data Persistence

### Saved Settings

On close, PSWrap saves to `%APPDATA%\PSWrap\settings.json`:

```
{
  "Theme": "Light" | "Dark",
  "LastProjectFolder": "C:\\scripts",
  "LastSourceScript": "C:\\scripts\\myscript.ps1",
  "LastOutputPath": "C:\\scripts\\myscript.exe",
  "LastIconPath": "C:\\scripts\\icon.ico",
  "BuildSettings": { ... }
}
```

### Log Files

Session logs are written to `logs/PSWrap_YYYYMMDD.log` (one file per day) in the application directory.

---

## Troubleshooting

### "CodeDOM not available"

**.NET Framework 4.x SDK is missing.** PSWrap falls back to `csc.exe` automatically. If `csc.exe` is also missing:

- Install **.NET Framework 4.7.2+ Developer Pack** from Microsoft
- Or install **Visual Studio Build Tools** (includes `csc.exe`)

### "csc.exe not found"

The C# compiler is not installed. Solutions:
1. Install **.NET Framework 4.x Developer Pack**
2. Install **Visual Studio** (Community edition is free)
3. Install **Visual Studio Build Tools** (standalone compiler)

### Output file is locked

If compilation fails with an access error:
1. Close any process that has the `.exe` file open (e.g. running the compiled app)
2. Check if the file is open in another editor or process
3. Delete the existing `.exe` manually before retrying

### Application doesn't start

1. Ensure you're using **Windows PowerShell** (powershell.exe), not PowerShell 7 (pwsh.exe)
2. Launch with: `powershell.exe -STA -File "Start-PSWrap.ps1"`
3. Check execution policy: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

### Compilation succeeds but EXE doesn't run

1. Run the EXE from a command prompt to see error output
2. If using **GUI mode** (no console), temporarily switch to **Console mode** in Settings to see error messages
3. Ensure the PowerShell script has no syntax errors
4. Check that all referenced modules are available on the target machine
5. If your script uses `$PSScriptRoot` to locate files, the compiled EXE writes the script to `%TEMP%\<ExeName>\__main.ps1` and dot-sources it — `$PSScriptRoot` points to the temp extraction folder
6. If your script has companion files, ensure "Project Folder" is selected so they're bundled as embedded resources and extracted alongside `__main.ps1`

### Theme not applying

If dark/light theme doesn't work properly:
1. Delete `%APPDATA%\PSWrap\settings.json`
2. Restart the application
3. Toggle the theme again

### Settings not saving

1. Check write permissions to `%APPDATA%\PSWrap\`
2. Delete `settings.json` and restart
3. Check antivirus isn't blocking file writes
