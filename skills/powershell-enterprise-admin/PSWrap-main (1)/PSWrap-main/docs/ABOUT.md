# PSWrap

> **PowerShell Script to EXE Compiler** — Compile `.ps1` scripts into native Windows executables.

| Field | Value |
|---|---|
| **Version** | 1.1.0 |
| **Author** | admin |
| **Created** | 2026-06-17 |
| **Updated** | 2026-08-09 |
| **Framework** | PowerShell 5.1+ / WPF / .NET 4.x |
| **License** | All Rights Reserved |

---

## Overview

PSWrap compiles PowerShell scripts (`.ps1`) into native Windows executables (`.exe`) using in-process C# CodeDOM compilation on Windows PowerShell 5.1, with automatic fallback to `csc.exe` on PowerShell Core 7.x. The generated executable runs the script entirely in-memory without extracting temporary script files to disk, making it suitable for distributing PowerShell tools as standalone binaries.

The compiler supports companion file bundling, custom icons (with automatic image-to-icon conversion), a built-in default icon, assembly metadata, and various compilation options including GUI/console mode, UAC elevation, and platform targeting.

---

## Features

### Compilation Engine
- In-process C# CodeDOM compilation (falls back to `csc.exe` on PowerShell Core)
- PS Core fallback uses .NET Framework SMA from GAC to avoid System.Runtime version conflicts
- Script embedded as managed resource — no Base64 strings in generated code
- Companion file bundling — embed entire project folders as embedded resources
- Async compilation via background runspace — non-blocking UI with progress feedback

### Icon Support
- Custom `.ico` icon embedding
- Auto-convert PNG, JPG, BMP, GIF to `.ico` format (multi-resolution: 16, 32, 48, 256px)
- Built-in default app icon when no custom icon is specified

### Assembly Metadata
- Auto-read from script comment-based help (`.TITLE`, `.SYNOPSIS`, `.VERSION`, `.AUTHOR`, `.DESCRIPTION`)
- Supports `#requires -Version` for auto version detection
- Manual override via Settings dialog for current session
- Version (e.g. `1.1.0.0`)
- Product Name, File Description, Copyright, Company, Trademark

### Compilation Options
- **Output Type**: GUI application (no console) or Console application
- **Console Host**: Windows Console Host mode for console apps
- **Encoding**: Unicode output encoding support
- **Credential GUI**: Enable credential prompt GUI
- **Stream Control**: Suppress standard output, suppress error output
- **Security**: Require administrator privileges (UAC manifest)
- **Config**: Generate `.exe.config` file alongside executable
- **Visual Styles**: Disable Windows visual styles
- **DpiAware**: Enable DPI awareness
- **Debug**: Prepare for debugging support
- **Platform**: AnyCPU, x86, x64
- **Thread Apartment**: STA (Single-Threaded), MTA (Multi-Threaded)
- **OS Support**: Long path support, virtualization, OS compatibility flags
- **Save Icon**: Embed and save icon with executable
- **LCID**: Custom locale identifier

### User Interface
- Modern WPF interface with Tailwind Slate design system
- Dark/Light theme toggle with instant DynamicResource switching
- KPI stat cards: Last Compile, Source Size, OS Target, Output Type, PS Version
- Grid-based KPI layout with 5 equal columns
- WrapPanel action buttons (responsive reflow)
- Drag-and-drop `.ps1` file support
- Toast notifications (success, error, warning, info) with fade-in/out animation
- Persistent user settings (theme, last paths, build config)
- Log viewer sub-window with copy/clear
- About dialog with markdown-rendered documentation tabs
- Sidebar with navigation, session info, About/Logs buttons, version footer

---

## Requirements

| Dependency | Minimum |
|---|---|
| **Operating System** | Windows 7+ |
| **PowerShell** | 5.1 (legacy Windows PowerShell) or PowerShell Core 7.x |
| **.NET Framework** | 4.7.2+ (included with Windows 10/11) |
| **WPF Assemblies** | PresentationFramework, PresentationCore, WindowsBase |
| **Windows Forms** | System.Windows.Forms (for file dialogs) |
| **C# Compiler** | Built-in CodeDOM (WinPS 5.1) or `csc.exe` (.NET Framework SDK) |

---

## Version History

| Version | Date | Highlights |
|---|---|---|---|
| **1.1.0** | 2026-08-09 | Auto-read metadata from script (`.TITLE`, `.SYNOPSIS`, `.VERSION`, `.AUTHOR`, `.DESCRIPTION`, `#requires -Version`), expanded compilation options (ConHost, Unicode, CredentialGUI, NoVisualStyles, DPI, Debug, LongPaths), full code documentation, bug fixes (Run as Admin, ProgressBar hit-test, settings restore), Arabic UI |
| 1.2.0 | 2026-06-23 | Bundle extraction fix (stream-based line reading, remove double Base64), dot-source `__main.ps1` for correct `$PSScriptRoot`, About dialog perf (ReadAllLines + persistent cache), fix `-Include` bug in icon auto-detect, responsive input fields (remove MaxWidth) |
| 1.1.0 | 2026-06-22 | Default app icon, KPI redesign (Last Compile/Source Size/OS Target/Output Type), PS Core GAC SMA fallback, toast notification fix, footer update |
| 2.1.0 | 2026-06-21 | Fully responsive layout, settings dialog resize, font fixes |
| 2.0.0 | 2026-06-20 | Complete architectural redesign, modular architecture, DynamicResource theme system, borderless window |
| 1.0.0 | 2026-06-17 | Initial release with single-file WPF GUI, CodeDOM compilation, icon embedding |
