#Requires -Version 5.1
<#
.SYNOPSIS
    PS2EXE compilation engine for PSWrap.

.DESCRIPTION
    Provides the core compilation functionality that converts PowerShell scripts
    into native Windows executables using the PS2EXE engine. Generates a full
    C# PSHost wrapper with:
    - Console and GUI (windowless) modes
    - Read-Host, Write-Host, ChoicePrompt, CredentialPrompt support
    - Icon embedding with automatic image-to-ICO conversion
    - Companion file bundling via embedded resources
    - Assembly metadata (version, description, product, copyright)
    - UAC manifest generation for admin rights
    - Platform target (AnyCPU/x86/x64) and threading (STA/MTA) options

.FUNCTIONS
    Cleanup-TempFiles      - Removes temporary icon files
    ConvertTo-Icon         - Converts images (PNG/JPG/BMP/GIF) to ICO format
    Invoke-CompileExePS2EXE - Main compilation function (PS2EXE engine)
#>

# ── Compiler State ────────────────────────────────────────────────────
$script:isBusy          = $false                    # Busy state flag
$script:activeRunspace  = $null                     # Background runspace reference
$script:asyncResult     = $null                     # Async compilation result
$script:asyncPowerShell = $null                     # PowerShell instance for async ops
$script:dlgState = @{ Ok = $false; Ver = '1.1.0.0'; Prod = ''; Desc = ''; Copy = ''; Comp = ''; Trade = ''; NoCon = $true; SOut = $true; SErr = $true; Adm = $false; Cfg = $false; STA = $true; Plat = 0; LCID = ''; Extra = ''; CopyIcon = $false; UsePS2EXE = $false; NoVisual = $false; ExitCancel = $false; DPI = $false; Debug = $false; SupportOS = $false; Virtual = $false; LongPaths = $false; ConHost = $false; UnicodeEnc = $false; CredGUI = $false }  # Build options state
$script:tempIconFiles = New-Object System.Collections.ArrayList  # Temporary icon files to clean up
$script:DefaultIconPath = Join-Path $script:RootDir 'images\app-icon.png'  # Default application icon
$script:CompilationCount = 0                        # Successful compilation counter
$script:bundleFiles = New-Object System.Collections.ArrayList  # Bundle file list for DataGrid

function Cleanup-TempFiles {
    <#
    .SYNOPSIS
        Removes temporary icon files created during compilation.
    .DESCRIPTION
        Iterates through the tempIconFiles collection, deletes each file,
        and clears the collection.
    #>
    if ($script:tempIconFiles) {
        foreach ($f in $script:tempIconFiles) {
            if ($f -and (Test-Path $f)) { Remove-Item $f -Force -ErrorAction SilentlyContinue }
        }
        $script:tempIconFiles.Clear()
    }
}

function ConvertTo-Icon {
    <#
    .SYNOPSIS
        Converts an image file to Windows ICO format.
    .DESCRIPTION
        Takes an image (PNG, JPG, BMP, GIF) and creates a multi-size ICO file
        with 16x16, 32x32, 48x48, and 256x256 pixel variants. Uses manual
        ICO binary format writing for compatibility.
    .PARAMETER ImagePath
        Path to the source image file.
    .PARAMETER OutputPath
        Path for the output ICO file. If not specified, uses the same name as
        the input file with .ico extension.
    .OUTPUTS
        Path to the created ICO file, or $null on failure.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ImagePath,
        [string]$OutputPath
    )
    if (-not (Test-Path $ImagePath)) { Add-LogLine -Message "Image not found: $ImagePath" -Level 'ERROR'; return $null }
    $images = @()
    try {
        $img = [System.Drawing.Image]::FromFile($ImagePath)
        if (-not $OutputPath) { $OutputPath = [System.IO.Path]::ChangeExtension($ImagePath, '.ico') }

        # Generate multiple sizes for the ICO file
        $sizes = @(16, 32, 48, 256)
        foreach ($size in $sizes) {
            $bmp = New-Object System.Drawing.Bitmap($size, $size)
            $g = [System.Drawing.Graphics]::FromImage($bmp)
            $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $g.DrawImage($img, 0, 0, $size, $size)
            $g.Dispose()
            $images += $bmp
        }

        # Write ICO binary format manually
        $fs = [System.IO.File]::OpenWrite($OutputPath)
        try {
            $writer = [System.IO.BinaryWriter]::new($fs)
            # ICO header: reserved (2 bytes) + type (2 bytes) + count (2 bytes)
            $writer.Write([int16]0)
            $writer.Write([int16]1)
            $writer.Write([int16]$images.Count)

            # Calculate data offset (header + directory entries)
            $dataOffset = 6 + (16 * $images.Count)
            $imageDataList = @()

            # Write directory entries for each image
            foreach ($bmp in $images) {
                $ms = New-Object System.IO.MemoryStream
                $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
                $pngData = $ms.ToArray()
                $ms.Dispose()
                $w = if ($bmp.Width -ge 256) { 0 } else { $bmp.Width }  # 0 means 256 in ICO format
                $h = if ($bmp.Height -ge 256) { 0 } else { $bmp.Height }
                $writer.Write([byte]$w); $writer.Write([byte]$h)
                $writer.Write([byte]0); $writer.Write([byte]0)          # Reserved, color count
                $writer.Write([int16]1); $writer.Write([int16]32)       # Planes, bits per pixel
                $writer.Write([int32]$pngData.Length)                     # Image data size
                $writer.Write([int32]$dataOffset)                        # Image data offset
                $imageDataList += @{ Offset = $dataOffset; Data = $pngData }
                $dataOffset += $pngData.Length
            }

            # Write image data for all sizes
            foreach ($entry in $imageDataList) { $writer.Write($entry.Data) }
            $writer.Flush()
        } finally {
            $fs.Close(); $fs.Dispose()
        }

        # Clean up resources
        $img.Dispose()
        foreach ($bmp in $images) { $bmp.Dispose() }
        Add-LogLine -Message "Image converted to ICO: $(Split-Path $ImagePath -Leaf) -> $(Split-Path $OutputPath -Leaf)" -Level 'SUCCESS'
        return $OutputPath
    } catch {
        Add-LogLine -Message "Icon conversion failed: $($_.Exception.Message)" -Level 'ERROR'
        if ($img) { $img.Dispose() }
        foreach ($bmp in $images) { if ($bmp) { $bmp.Dispose() } }
        return $null
    }
}

function Invoke-CompileExePS2EXE {
    <#
    .SYNOPSIS
        Compiles a PowerShell script into an executable using the PS2EXE engine.
    .DESCRIPTION
        Generates a C# wrapper with full PSHost implementation, bundles the
        source script as an embedded resource, and compiles everything into
        a native Windows executable using CodeDOM.

        The generated executable supports:
        - Console and GUI (windowless) modes
        - Read-Host, Write-Host, Write-Progress, ChoicePrompt, CredentialPrompt
        - Custom icon embedding
        - Companion file bundling via embedded resources
        - Assembly metadata and UAC manifest

    .PARAMETER SourcePath
        Path to the source .ps1 script to compile.
    .PARAMETER OutputPath
        Path for the output .exe file.
    .PARAMETER IconPath
        Optional path to a custom .ico file for the executable.
    .PARAMETER BundleFolder
        Optional folder path containing companion files to embed.
    .PARAMETER Version
        Assembly version string (default: '1.1.0.0').
    .PARAMETER FileDescription
        Assembly file description.
    .PARAMETER ProductName
        Assembly product name.
    .PARAMETER Copyright
        Assembly copyright text.
    .PARAMETER Company
        Assembly company name.
    .PARAMETER NoConsole
        If $true, creates a GUI (windowless) executable.
    .PARAMETER RequireAdmin
        If $true, embeds a UAC manifest requiring administrator rights.
    .PARAMETER ApartmentState
        Thread apartment state: 'STA' or 'MTA'.
    .PARAMETER Platform
        Target platform: 'anycpu', 'x86', or 'x64'.
    .PARAMETER SelectedFiles
        Array of file paths to bundle into the executable.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$SourcePath,
        [Parameter(Mandatory)][string]$OutputPath,
        [string]$IconPath,
        [string]$BundleFolder,
        [string]$Version = '1.1.0.0',
        [string]$FileDescription = '',
        [string]$ProductName = '',
        [string]$Copyright = '',
        [string]$Company = '',
        [string]$Trademark = '',
        [bool]$NoConsole = $true,
        [bool]$ConHost = $false,
        [bool]$UnicodeEncoding = $false,
        [bool]$CredentialGUI = $false,
        [bool]$SuppressOutput = $false,
        [bool]$SuppressError = $false,
        [bool]$RequireAdmin = $false,
        [bool]$GenerateConfig = $false,
        [bool]$NoVisualStyles = $false,
        [bool]$ExitOnCancel = $false,
        [bool]$DPIAware = $false,
        [bool]$PrepareDebug = $false,
        [bool]$SupportOS = $false,
        [bool]$Virtualize = $false,
        [bool]$LongPaths = $false,
        [bool]$SaveIcon = $false,
        [string]$ApartmentState = 'STA',
        [string]$Platform = 'anycpu',
        [string]$LCID = '',
        [string]$ExtraArgs = '',
        [string[]]$SelectedFiles = @()
    )

    Add-LogLine -Message 'Initializing PS2EXE engine - building C# host wrapper...' -Level 'INFO'

    # Build C# template outside script block to avoid parsing issues
    $scriptResourceName = [System.IO.Path]::GetFileName($SourcePath)
    $productName = if ($ProductName) { $ProductName } else { [System.IO.Path]::GetFileNameWithoutExtension($SourcePath) }
    $descText = if ($FileDescription) { $FileDescription } else { $productName }
    $companyName = if ($Company) { $Company } else { ' ' }
    $copyrText = if ($Copyright) { $Copyright } else { "Copyright \u00A9 $(Get-Date -Format yyyy)" }
    $trademarkText = if ($Trademark) { $Trademark } else { ' ' }
    $assemblyGuid = [Guid]::NewGuid().ToString('D').ToUpper()
    $rsAptState = if ($ApartmentState -eq 'MTA') { 'MTA' } else { 'STA' }

    $metaAttr = @"
[assembly: AssemblyTitle("$productName")]
[assembly: AssemblyDescription("$descText")]
[assembly: AssemblyConfiguration("")]
[assembly: AssemblyCompany("$companyName")]
[assembly: AssemblyProduct("$productName")]
[assembly: AssemblyCopyright("$copyrText")]
[assembly: AssemblyTrademark("$trademarkText")]
[assembly: AssemblyCulture("")]
[assembly: AssemblyVersion("$Version")]
[assembly: AssemblyFileVersion("$Version")]
[assembly: ComVisible(false)]
[assembly: Guid("$assemblyGuid")]
"@

    # Build bundle file and extraction C# code
    $bundleResourcePath = $null
    $bundleResourceName = $null
    $embedSection = ""
    if ($SelectedFiles -and $SelectedFiles.Count -gt 0) {
        Add-LogLine "[~] PS2EXE bundling $($SelectedFiles.Count) file(s)..." -Level 'INFO'
        $bundleLines = [System.Collections.Generic.List[string]]::new()
        $totalSize = 0L
        $bundleDir = (Split-Path $SourcePath -Parent)
        foreach ($fPath in $SelectedFiles) {
            if (-not (Test-Path $fPath)) { continue }
            $rel = $fPath.Substring($bundleDir.TrimEnd('\').Length).TrimStart('\','/')
            $b = [System.IO.File]::ReadAllBytes($fPath)
            $totalSize += $b.Length
            $bundleLines.Add(($rel.Replace('\','/') + '|' + [Convert]::ToBase64String($b)))
        }
        if ($bundleLines.Count -gt 0) {
            $bundleBytes = [System.Text.Encoding]::UTF8.GetBytes(($bundleLines -join "`n"))
            $bundleResourcePath = [System.IO.Path]::GetTempFileName()
            Remove-Item $bundleResourcePath -Force -ErrorAction SilentlyContinue
            $bundleResourcePath = [System.IO.Path]::ChangeExtension($bundleResourcePath, '.bundle')
            [System.IO.File]::WriteAllBytes($bundleResourcePath, $bundleBytes)
            $bundleResourceName = [System.IO.Path]::GetFileName($bundleResourcePath)
            Add-LogLine "[+] Bundle created: $($bundleLines.Count) file(s), total $totalSize bytes" -Level 'INFO'
        }
    }
    if ($bundleResourceName) {
        $embedSection = "using (var bundleStream = executingAssembly.GetManifestResourceStream(`"$bundleResourceName`"))`r`nusing (var reader = new System.IO.StreamReader(bundleStream, System.Text.Encoding.UTF8))`r`n{`r`nstring line;`r`nwhile ((line = reader.ReadLine()) != null)`r`n{if (string.IsNullOrEmpty(line)) continue;`r`nint sep = line.IndexOf('|');`r`nif (sep <= 0) continue;`r`nstring rel = line.Substring(0, sep);`r`nstring b64 = line.Substring(sep + 1);`r`nstring outPath = System.IO.Path.Combine(scriptDir, rel.Replace('/', System.IO.Path.DirectorySeparatorChar));`r`nSystem.IO.Directory.CreateDirectory(System.IO.Path.GetDirectoryName(outPath));`r`nSystem.IO.File.WriteAllBytes(outPath, System.Convert.FromBase64String(b64));`r`n}`r`n}`r`nSystem.Environment.CurrentDirectory = scriptDir;`r`n"
    }

    # Determine if GUI mode
    $guiMode = if ($NoConsole) { 'winexe' } else { 'exe' }

    # Determine thread attribute
    $threadAttr = if ($ApartmentState -eq 'MTA') { '[MTAThread]' } else { '[STAThread]' }

    Add-LogLine -Message 'Generating PS2EXE C# wrapper with full PSHost...' -Level 'INFO'

    $csharpCode = [System.Text.StringBuilder]::new()
    $null = $csharpCode.AppendLine('using System;')
    $null = $csharpCode.AppendLine('using System.Collections.Generic;')
    $null = $csharpCode.AppendLine('using System.Text;')
    $null = $csharpCode.AppendLine('using System.Management.Automation;')
    $null = $csharpCode.AppendLine('using System.Management.Automation.Runspaces;')
    $null = $csharpCode.AppendLine('using System.Globalization;')
    $null = $csharpCode.AppendLine('using System.Management.Automation.Host;')
    $null = $csharpCode.AppendLine('using System.Security;')
    $null = $csharpCode.AppendLine('using System.Reflection;')
    $null = $csharpCode.AppendLine('using System.Runtime.InteropServices;')
    if ($NoConsole) {
        $null = $csharpCode.AppendLine('using System.Windows.Forms;')
        $null = $csharpCode.AppendLine('using System.Drawing;')
    }
    $null = $csharpCode.AppendLine()
    $null = $csharpCode.AppendLine($metaAttr)
    $null = $csharpCode.AppendLine('namespace PS2EXE')
    $null = $csharpCode.AppendLine('{')

    # Credential_Form class for GUI mode
    if ($NoConsole) {
        $null = $csharpCode.AppendLine(@'
    internal class Credential_Form
    {
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        private struct CREDUI_INFO { public int cbSize; public IntPtr hwndParent; public string pszMessageText; public string pszCaptionText; public IntPtr hbmBanner; }
        [Flags] enum CREDUI_FLAGS { INCORRECT_PASSWORD = 0x1, DO_NOT_PERSIST = 0x2, REQUEST_ADMINISTRATOR = 0x4, EXCLUDE_CERTIFICATES = 0x8, REQUIRE_CERTIFICATE = 0x10, SHOW_SAVE_CHECK_BOX = 0x40, ALWAYS_SHOW_UI = 0x80, REQUIRE_SMARTCARD = 0x100, PASSWORD_ONLY_OK = 0x200, VALIDATE_USERNAME = 0x400, COMPLETE_USERNAME = 0x800, PERSIST = 0x1000, SERVER_CREDENTIAL = 0x4000, EXPECT_CONFIRMATION = 0x20000, GENERIC_CREDENTIALS = 0x40000, USERNAME_TARGET_CREDENTIALS = 0x80000, KEEP_USERNAME = 0x100000, }
        public enum CredUI_ReturnCodes { NO_ERROR = 0, ERROR_CANCELLED = 1223, ERROR_NO_SUCH_LOGON_SESSION = 1312, ERROR_NOT_FOUND = 1168, ERROR_INVALID_ACCOUNT_NAME = 1315, ERROR_INSUFFICIENT_BUFFER = 122, ERROR_INVALID_PARAMETER = 87, ERROR_INVALID_FLAGS = 1004, }
        [DllImport("credui", CharSet = CharSet.Unicode)]
        private static extern CredUI_ReturnCodes CredUIPromptForCredentials(ref CREDUI_INFO credinfo, string targetName, IntPtr reserved1, int iError, StringBuilder userName, int maxUserName, StringBuilder password, int maxPassword, [MarshalAs(UnmanagedType.Bool)] ref bool pfSave, CREDUI_FLAGS flags);
        public class User_Pwd { public string User = string.Empty; public string Password = string.Empty; public string Domain = string.Empty; }
        internal static User_Pwd PromptForPassword(string caption, string message, string target, string user, PSCredentialTypes credTypes, PSCredentialUIOptions options)
        {
            StringBuilder userPassword = new StringBuilder("", 128), userID = new StringBuilder(user, 128);
            CREDUI_INFO credUI = new CREDUI_INFO();
            if (!string.IsNullOrEmpty(message)) credUI.pszMessageText = message;
            if (!string.IsNullOrEmpty(caption)) credUI.pszCaptionText = caption;
            credUI.cbSize = Marshal.SizeOf(credUI);
            bool save = false;
            CREDUI_FLAGS flags = CREDUI_FLAGS.DO_NOT_PERSIST;
            if ((credTypes & PSCredentialTypes.Generic) == PSCredentialTypes.Generic)
            { flags |= CREDUI_FLAGS.GENERIC_CREDENTIALS;
                if ((options & PSCredentialUIOptions.AlwaysPrompt) == PSCredentialUIOptions.AlwaysPrompt) flags |= CREDUI_FLAGS.ALWAYS_SHOW_UI; }
            CredUI_ReturnCodes returnCode = CredUIPromptForCredentials(ref credUI, target, IntPtr.Zero, 0, userID, 128, userPassword, 128, ref save, flags);
            if (returnCode == CredUI_ReturnCodes.NO_ERROR) { return new User_Pwd() { User = userID.ToString(), Password = userPassword.ToString(), Domain = "" }; }
            return null;
        }
    }
'@)
    }

    # PS2RawUI class
    $null = $csharpCode.AppendLine('    internal class PS2RawUI : PSHostRawUserInterface')
    $null = $csharpCode.AppendLine('    {')
    if ($NoConsole) {
        $null = $csharpCode.AppendLine(@'
        private ConsoleColor GUIBackgroundColor = ConsoleColor.White;
        private ConsoleColor GUIForegroundColor = ConsoleColor.Black;
        private string GUITitle = Assembly.GetExecutingAssembly().GetCustomAttribute<AssemblyTitleAttribute>().Title;
        public override ConsoleColor BackgroundColor { get { return GUIBackgroundColor; } set { GUIBackgroundColor = value; } }
        public override System.Management.Automation.Host.Size BufferSize { get { return new System.Management.Automation.Host.Size(120, 50); } set { } }
        public override Coordinates CursorPosition { get { return new Coordinates(0, 0); } set { } }
        public override int CursorSize { get { return 25; } set { } }
        private Form Invisible_Form = null;
        public override void FlushInputBuffer() { if (Invisible_Form != null) { Invisible_Form.Close(); Invisible_Form = null; } else { Invisible_Form = new Form() { Opacity = 0, ShowInTaskbar = false, Visible = true }; } }
        public override ConsoleColor ForegroundColor { get { return GUIForegroundColor; } set { GUIForegroundColor = value; } }
        public override bool KeyAvailable { get { return true; } }
        public override System.Management.Automation.Host.Size MaxPhysicalWindowSize { get { return new System.Management.Automation.Host.Size(240, 84); } }
        public override System.Management.Automation.Host.Size MaxWindowSize { get { return new System.Management.Automation.Host.Size(120, 84); } }
        public override Coordinates WindowPosition { get { return new Coordinates(0, 0); } set { } }
        public override System.Management.Automation.Host.Size WindowSize { get { return new System.Management.Automation.Host.Size(120, 50); } set { } }
        public override string WindowTitle { get { return GUITitle; } set { GUITitle = value; } }
'@)
    } else {
        $null = $csharpCode.AppendLine(@'
        const int STD_OUTPUT_HANDLE = -11;
        [StructLayout(LayoutKind.Explicit)] public struct CHAR_INFO { [FieldOffset(0)] internal char UnicodeChar; [FieldOffset(0)] internal char AsciiChar; [FieldOffset(2)] internal UInt16 Attributes; }
        [StructLayout(LayoutKind.Sequential)] public struct COORD { public short X; public short Y; }
        [StructLayout(LayoutKind.Sequential)] public struct SMALL_RECT { public short Left; public short Top; public short Right; public short Bottom; }
        [DllImport("kernel32.dll", EntryPoint = "ReadConsoleOutputW", CharSet = CharSet.Unicode, SetLastError = true)]
        internal static extern bool ReadConsoleOutput(IntPtr hConsoleOutput, [MarshalAs(UnmanagedType.LPArray), Out] CHAR_INFO[,] lpBuffer, COORD dwBufferSize, COORD dwBufferCoord, ref SMALL_RECT lpReadRegion);
        [DllImport("kernel32.dll", EntryPoint = "WriteConsoleOutputW", CharSet = CharSet.Unicode, SetLastError = true)]
        internal static extern bool WriteConsoleOutput(IntPtr hConsoleOutput, [MarshalAs(UnmanagedType.LPArray), In] CHAR_INFO[,] lpBuffer, COORD dwBufferSize, COORD dwBufferCoord, ref SMALL_RECT lpWriteRegion);
        [DllImport("kernel32.dll", SetLastError = true)]
        internal static extern IntPtr GetStdHandle(int nStdHandle);
        public override ConsoleColor BackgroundColor { get { return Console.BackgroundColor; } set { Console.BackgroundColor = value; } }
        public override System.Management.Automation.Host.Size BufferSize { get { return Console.IsOutputRedirected ? new System.Management.Automation.Host.Size(120, 50) : new System.Management.Automation.Host.Size(Console.BufferWidth, Console.BufferHeight); } set { } }
        public override Coordinates CursorPosition { get { return new Coordinates(Console.CursorLeft, Console.CursorTop); } set { Console.CursorTop = value.Y; Console.CursorLeft = value.X; } }
        public override int CursorSize { get { return Console.CursorSize; } set { Console.CursorSize = value; } }
        public override void FlushInputBuffer() { if (!Console.IsInputRedirected) { while (Console.KeyAvailable) Console.ReadKey(true); } }
        public override ConsoleColor ForegroundColor { get { return Console.ForegroundColor; } set { Console.ForegroundColor = value; } }
        public override bool KeyAvailable { get { return Console.KeyAvailable; } }
        public override System.Management.Automation.Host.Size MaxPhysicalWindowSize { get { return new System.Management.Automation.Host.Size(Console.LargestWindowWidth, Console.LargestWindowHeight); } }
        public override System.Management.Automation.Host.Size MaxWindowSize { get { return new System.Management.Automation.Host.Size(Console.BufferWidth, Console.BufferHeight); } }
        public override Coordinates WindowPosition { get { return new Coordinates(Console.WindowLeft, Console.WindowTop); } set { Console.WindowLeft = value.X; Console.WindowTop = value.Y; } }
        public override System.Management.Automation.Host.Size WindowSize { get { return new System.Management.Automation.Host.Size(Console.WindowWidth, Console.WindowHeight); } set { } }
        public override string WindowTitle { get { return Console.Title; } set { Console.Title = value; } }
'@)
    }

    # GetBufferContents override
    if ($NoConsole) {
        $null = $csharpCode.AppendLine(@'
        public override BufferCell[,] GetBufferContents(System.Management.Automation.Host.Rectangle rectangle)
        {
            BufferCell[,] ScreenBuffer = new BufferCell[rectangle.Bottom - rectangle.Top + 1, rectangle.Right - rectangle.Left + 1];
            for (int y = 0; y <= rectangle.Bottom - rectangle.Top; y++)
                for (int x = 0; x <= rectangle.Right - rectangle.Left; x++)
                    ScreenBuffer[y, x] = new BufferCell(' ', GUIForegroundColor, GUIBackgroundColor, BufferCellType.Complete);
            return ScreenBuffer;
        }
'@)
    } else {
        $null = $csharpCode.AppendLine(@'
        public override BufferCell[,] GetBufferContents(System.Management.Automation.Host.Rectangle rectangle)
        {
            IntPtr hStdOut = GetStdHandle(STD_OUTPUT_HANDLE);
            CHAR_INFO[,] buffer = new CHAR_INFO[rectangle.Bottom - rectangle.Top + 1, rectangle.Right - rectangle.Left + 1];
            COORD buffer_size = new COORD() { X = (short)(rectangle.Right - rectangle.Left + 1), Y = (short)(rectangle.Bottom - rectangle.Top + 1) };
            COORD buffer_index = new COORD() { X = 0, Y = 0 };
            SMALL_RECT screen_rect = new SMALL_RECT() { Left = (short)rectangle.Left, Top = (short)rectangle.Top, Right = (short)rectangle.Right, Bottom = (short)rectangle.Bottom };
            ReadConsoleOutput(hStdOut, buffer, buffer_size, buffer_index, ref screen_rect);
            BufferCell[,] ScreenBuffer = new BufferCell[rectangle.Bottom - rectangle.Top + 1, rectangle.Right - rectangle.Left + 1];
            for (int y = 0; y <= rectangle.Bottom - rectangle.Top; y++)
                for (int x = 0; x <= rectangle.Right - rectangle.Left; x++)
                    ScreenBuffer[y, x] = new BufferCell(buffer[y, x].AsciiChar, (ConsoleColor)(buffer[y, x].Attributes & 0xF), (ConsoleColor)((buffer[y, x].Attributes & 0xF0) / 0x10), BufferCellType.Complete);
            return ScreenBuffer;
        }
'@)
    }

    # ReadKey override
    if ($NoConsole) {
        $null = $csharpCode.AppendLine(@'
        public override KeyInfo ReadKey(ReadKeyOptions options) { return new KeyInfo(0, '\0', 0, false); }
'@)
    } else {
        $null = $csharpCode.AppendLine(@'
        public override KeyInfo ReadKey(ReadKeyOptions options)
        {
            ConsoleKeyInfo cki = Console.ReadKey((options & ReadKeyOptions.NoEcho) != 0);
            ControlKeyStates cks = 0;
            if ((cki.Modifiers & ConsoleModifiers.Alt) != 0) cks |= ControlKeyStates.LeftAltPressed | ControlKeyStates.RightAltPressed;
            if ((cki.Modifiers & ConsoleModifiers.Control) != 0) cks |= ControlKeyStates.LeftCtrlPressed | ControlKeyStates.RightCtrlPressed;
            if ((cki.Modifiers & ConsoleModifiers.Shift) != 0) cks |= ControlKeyStates.ShiftPressed;
            if (Console.CapsLock) cks |= ControlKeyStates.CapsLockOn;
            if (Console.NumberLock) cks |= ControlKeyStates.NumLockOn;
            return new KeyInfo((int)cki.Key, cki.KeyChar, cks, (options & ReadKeyOptions.IncludeKeyDown) != 0);
        }
'@)
    }

    $null = $csharpCode.AppendLine(@'
        public override void ScrollBufferContents(System.Management.Automation.Host.Rectangle source, Coordinates destination, System.Management.Automation.Host.Rectangle clip, BufferCell fill) { }
        public override void SetBufferContents(System.Management.Automation.Host.Rectangle rectangle, BufferCell fill) { }
        public override void SetBufferContents(Coordinates origin, BufferCell[,] contents) { }
    }
'@)

    # Input_Box and Choice_Box for GUI mode
    if ($NoConsole) {
        $null = $csharpCode.AppendLine(@'
    public class Input_Box
    {
        [DllImport("user32.dll", CharSet = CharSet.Unicode, CallingConvention = CallingConvention.Cdecl)]
        private static extern IntPtr MB_GetString(uint strId);
        public static DialogResult Show(string strTitle, string strPrompt, ref string strVal, bool blSecure)
        {
            Form form = new Form(); form.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F); form.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            Label label = new Label(); TextBox textBox = new TextBox(); Button buttonOk = new Button(); Button buttonCancel = new Button();
            if (string.IsNullOrEmpty(strPrompt)) label.Text = blSecure ? "Secure input:   " : "Input:          "; else label.Text = strPrompt;
            label.Location = new Point(9, 19); label.MaximumSize = new System.Drawing.Size(System.Windows.Forms.Screen.FromControl(form).Bounds.Width * 5 / 8 - 18, 0); label.AutoSize = true;
            form.Controls.Add(label);
            if (blSecure) textBox.UseSystemPasswordChar = true; textBox.Text = strVal; textBox.SetBounds(12, label.Bottom, label.Right - 12, 20);
            buttonOk.Text = "OK"; buttonOk.DialogResult = DialogResult.OK; buttonCancel.Text = "Cancel"; buttonCancel.DialogResult = DialogResult.Cancel;
            buttonOk.SetBounds(Math.Max(12, label.Right - 158), label.Bottom + 36, 75, 23); buttonCancel.SetBounds(Math.Max(93, label.Right - 77), label.Bottom + 36, 75, 23);
            form.Text = strTitle; form.ClientSize = new System.Drawing.Size(Math.Max(178, label.Right + 10), label.Bottom + 71);
            form.Controls.AddRange(new Control[] { textBox, buttonOk, buttonCancel }); form.FormBorderStyle = FormBorderStyle.FixedDialog;
            form.StartPosition = FormStartPosition.CenterScreen; form.MinimizeBox = false; form.MaximizeBox = false; form.AcceptButton = buttonOk; form.CancelButton = buttonCancel;
            DialogResult dialogResult = form.ShowDialog(); strVal = textBox.Text; return dialogResult;
        }
        public static DialogResult Show(string strTitle, string strPrompt, ref string strVal) { return Show(strTitle, strPrompt, ref strVal, false); }
    }

    public class Choice_Box
    {
        public static int Show(System.Collections.ObjectModel.Collection<ChoiceDescription> arrChoice, int intDefault, string strTitle, string strPrompt)
        {
            if (arrChoice == null || arrChoice.Count < 1) return -1;
            Form form = new Form(); form.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F); form.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            RadioButton[] aradioButton = new RadioButton[arrChoice.Count]; ToolTip toolTip = new ToolTip(); Button buttonOk = new Button();
            int iPosY = 19, iMaxX = 0;
            if (!string.IsNullOrEmpty(strPrompt)) { Label label = new Label() { Text = strPrompt, Location = new Point(9, 19), MaximumSize = new System.Drawing.Size(System.Windows.Forms.Screen.FromControl(form).Bounds.Width * 5 / 8 - 18, 0), AutoSize = true }; form.Controls.Add(label); iPosY = label.Bottom; iMaxX = label.Right; }
            int Counter = 0;
            foreach (ChoiceDescription sAuswahl in arrChoice) { aradioButton[Counter] = new RadioButton() { Text = sAuswahl.Label, Checked = (Counter == intDefault), Location = new Point(9, iPosY), AutoSize = true }; form.Controls.Add(aradioButton[Counter]); iPosY = aradioButton[Counter].Bottom; if (aradioButton[Counter].Right > iMaxX) { iMaxX = aradioButton[Counter].Right; } if (!string.IsNullOrEmpty(sAuswahl.HelpMessage)) toolTip.SetToolTip(aradioButton[Counter], sAuswahl.HelpMessage); Counter++; }
            toolTip.ShowAlways = true; buttonOk.Text = "OK"; buttonOk.DialogResult = DialogResult.OK; buttonOk.SetBounds(Math.Max(12, iMaxX - 77), iPosY + 36, 75, 23);
            form.Text = string.IsNullOrEmpty(strTitle) ? System.AppDomain.CurrentDomain.FriendlyName : strTitle; form.ClientSize = new System.Drawing.Size(Math.Max(178, iMaxX + 10), iPosY + 71); form.Controls.Add(buttonOk);
            form.FormBorderStyle = FormBorderStyle.FixedDialog; form.StartPosition = FormStartPosition.CenterScreen; form.MinimizeBox = false; form.MaximizeBox = false; form.AcceptButton = buttonOk;
            if (form.ShowDialog() == DialogResult.OK) { for (Counter = 0; Counter < arrChoice.Count; Counter++) if (aradioButton[Counter].Checked) return Counter; } return -1;
        }
    }
'@)
    }

    # PS2UI class
    $null = $csharpCode.AppendLine(@'
    internal class PS2UI : PSHostUserInterface
    {
        private PS2RawUI rawUI = null;
        public ConsoleColor ErrorForegroundColor = ConsoleColor.Red;
        public ConsoleColor ErrorBackgroundColor = ConsoleColor.Black;
        public ConsoleColor WarningForegroundColor = ConsoleColor.Yellow;
        public ConsoleColor WarningBackgroundColor = ConsoleColor.Black;
        public ConsoleColor DebugForegroundColor = ConsoleColor.Yellow;
        public ConsoleColor DebugBackgroundColor = ConsoleColor.Black;
        public ConsoleColor VerboseForegroundColor = ConsoleColor.Yellow;
        public ConsoleColor VerboseBackgroundColor = ConsoleColor.Black;
        public PS2UI() : base() { rawUI = new PS2RawUI();
'@)
    if (!$NoConsole) {
        $null = $csharpCode.AppendLine('rawUI.ForegroundColor = Console.ForegroundColor; rawUI.BackgroundColor = Console.BackgroundColor;')
    }
    $null = $csharpCode.AppendLine('}')
    $null = $csharpCode.AppendLine('public override PSHostRawUserInterface RawUI { get { return rawUI; } }')

    if ($NoConsole) {
        $null = $csharpCode.AppendLine('private string ib_message;')
    }

    $null = $csharpCode.Append('public override string ReadLine()')
    if ($NoConsole) {
        $null = $csharpCode.AppendLine(' { string sWert = ""; if (Input_Box.Show(rawUI.WindowTitle, ib_message, ref sWert) == DialogResult.OK) return sWert; return ""; }')
    } else {
        $null = $csharpCode.AppendLine(' { return Console.ReadLine(); }')
    }

    $null = $csharpCode.AppendLine(@'
        public override System.Security.SecureString ReadLineAsSecureString()
        {
            System.Security.SecureString secstr = new System.Security.SecureString();
'@)
    if ($NoConsole) {
        $null = $csharpCode.AppendLine('string sWert = ""; if (Input_Box.Show(rawUI.WindowTitle, ib_message, ref sWert, true) == DialogResult.OK) foreach (char ch in sWert) secstr.AppendChar(ch);')
    } else {
        $null = $csharpCode.AppendLine('while (true) { ConsoleKeyInfo i = Console.ReadKey(true); if (i.Key == ConsoleKey.Enter) { Console.WriteLine(); break; } else if (i.Key == ConsoleKey.Backspace) { if (secstr.Length > 0) { secstr.RemoveAt(secstr.Length - 1); Console.Write("\b \b"); } } else if (i.KeyChar != ((char)0)) { secstr.AppendChar(i.KeyChar); Console.Write("*"); } }')
    }
    $null = $csharpCode.AppendLine('return secstr; }')

    # Write methods
    $null = $csharpCode.Append('public override void Write(ConsoleColor fgc, ConsoleColor bgc, string value) {')
    if ($NoConsole) {
        $null = $csharpCode.AppendLine(' }')
    } else {
        $null = $csharpCode.AppendLine('ConsoleColor f = Console.ForegroundColor, b = Console.BackgroundColor; Console.ForegroundColor = fgc; Console.BackgroundColor = bgc; Console.Write(value); Console.ForegroundColor = f; Console.BackgroundColor = b; }')
    }

    $null = $csharpCode.Append('public override void Write(string value) {')
    if ($NoConsole) {
        $null = $csharpCode.AppendLine(' }')
    } else {
        $null = $csharpCode.AppendLine('Console.Write(value); }')
    }

    $null = $csharpCode.Append('public override void WriteDebugLine(string m) {')
    if ($NoConsole) { $null = $csharpCode.AppendLine('MessageBox.Show(m, rawUI.WindowTitle); }') } else { $null = $csharpCode.AppendLine('Console.WriteLine("DEBUG: " + m); }') }

    $null = $csharpCode.Append('public override void WriteErrorLine(string v) {')
    if ($NoConsole) { $null = $csharpCode.AppendLine('MessageBox.Show(v, rawUI.WindowTitle, MessageBoxButtons.OK, MessageBoxIcon.Error); }') } else { $null = $csharpCode.AppendLine('Console.Error.WriteLine("ERROR: " + v); }') }

    $null = $csharpCode.Append('public override void WriteLine() {')
    if (!$NoConsole) { $null = $csharpCode.AppendLine('Console.WriteLine(); }') } else { $null = $csharpCode.AppendLine(' }') }

    $null = $csharpCode.Append('public override void WriteLine(ConsoleColor fgc, ConsoleColor bgc, string v) {')
    if ($NoConsole) {
        $null = $csharpCode.AppendLine(' }')
    } else {
        $null = $csharpCode.AppendLine('ConsoleColor f = Console.ForegroundColor, b = Console.BackgroundColor; Console.ForegroundColor = fgc; Console.BackgroundColor = bgc; Console.WriteLine(v); Console.ForegroundColor = f; Console.BackgroundColor = b; }')
    }

    $null = $csharpCode.Append('public override void WriteLine(string v) {')
    if ($NoConsole) {
        $null = $csharpCode.AppendLine(' }')
    } else {
        $null = $csharpCode.AppendLine('Console.WriteLine(v); }')
    }

    $null = $csharpCode.Append('public override void WriteVerboseLine(string m) {')
    if ($NoConsole) { $null = $csharpCode.AppendLine(' }') } else { $null = $csharpCode.AppendLine('Console.WriteLine("VERBOSE: " + m); }') }

    $null = $csharpCode.Append('public override void WriteWarningLine(string m) {')
    if ($NoConsole) { $null = $csharpCode.AppendLine('MessageBox.Show(m, rawUI.WindowTitle, MessageBoxButtons.OK, MessageBoxIcon.Warning); }') } else { $null = $csharpCode.AppendLine('Console.WriteLine("WARNING: " + m); }') }

    $null = $csharpCode.AppendLine('public override void WriteProgress(long sourceId, ProgressRecord record) { }')

    # Prompt method
    $null = $csharpCode.AppendLine(@'
        public override Dictionary<string, PSObject> Prompt(string caption, string message, System.Collections.ObjectModel.Collection<FieldDescription> descriptions)
        {
            Dictionary<string, PSObject> ret = new Dictionary<string, PSObject>();
            foreach (FieldDescription cd in descriptions)
            {
                Type t = string.IsNullOrEmpty(cd.ParameterAssemblyFullName) ? typeof(string) : Type.GetType(cd.ParameterAssemblyFullName);
                if (t.IsArray)
                {
                    Type elementType = t.GetElementType();
                    Type genericListType = Type.GetType("System.Collections.Generic.List" + ((char)0x60).ToString() + "1");
                    genericListType = genericListType.MakeGenericType(new Type[] { elementType });
                    object resultList = genericListType.GetConstructor(BindingFlags.CreateInstance | BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null).Invoke(null);
                    int index = 0; string data = "";
                    do { if (!string.IsNullOrEmpty(cd.Name)) { string ps = string.Format("{0}[{1}]: ", cd.Name, index);
'@)
    if ($NoConsole) { $null = $csharpCode.Append(' ib_message = ps;') } else { $null = $csharpCode.Append(' Write(ps);') }
    $null = $csharpCode.AppendLine(' } data = ReadLine(); if (string.IsNullOrEmpty(data)) break; genericListType.InvokeMember("Add", BindingFlags.InvokeMethod | BindingFlags.Public | BindingFlags.Instance, null, resultList, new object[] { System.Convert.ChangeType(data, elementType) }); index++; } while (true);')
    $null = $csharpCode.AppendLine('ret.Add(cd.Name, new PSObject((Array)genericListType.InvokeMember("ToArray", BindingFlags.InvokeMethod | BindingFlags.Public | BindingFlags.Instance, null, resultList, null))); }')
    $null = $csharpCode.AppendLine('else { object o = null; string l = null;')
    $null = $csharpCode.Append('if (t == typeof(System.Security.SecureString)) {')
    if ($NoConsole) { $null = $csharpCode.Append(' if (!string.IsNullOrEmpty(cd.Name)) ib_message = string.Format("{0}: ", cd.Name);') } else { $null = $csharpCode.Append(' if (!string.IsNullOrEmpty(cd.Name)) Write(string.Format("{0}: ", cd.Name));') }
    $null = $csharpCode.AppendLine('o = ReadLineAsSecureString(); }')
    $null = $csharpCode.AppendLine('else if (t == typeof(System.Management.Automation.PSCredential)) { o = PromptForCredential("", "", "", ""); }')
    $null = $csharpCode.Append('else {')
    if ($NoConsole) {
        $null = $csharpCode.Append(' if (!string.IsNullOrEmpty(cd.Name)) ib_message = string.Format("{0}: ", cd.Name); if (!string.IsNullOrEmpty(cd.HelpMessage)) ib_message += "\n(Type !? for help.)";')
    } else {
        $null = $csharpCode.Append(' if (!string.IsNullOrEmpty(cd.Name)) Write(cd.Name); if (!string.IsNullOrEmpty(cd.HelpMessage)) Write(" (Type !? for help.)"); if ((!string.IsNullOrEmpty(cd.Name)) || (!string.IsNullOrEmpty(cd.HelpMessage))) Write(": ");')
    }
    $null = $csharpCode.AppendLine('do { l = ReadLine(); if (l == "!?") { if (!string.IsNullOrEmpty(cd.HelpMessage)) WriteLine(cd.HelpMessage); } else { if (string.IsNullOrEmpty(l)) o = cd.DefaultValue; if (o == null) { try { o = System.Convert.ChangeType(l, t); } catch { Write("Wrong format\\n"); l = "!?"; } } } } while (l == "!?"); }')
    $null = $csharpCode.AppendLine('ret.Add(cd.Name, new PSObject(o)); } }')
    if ($NoConsole) { $null = $csharpCode.AppendLine('ib_message = "";') }
    $null = $csharpCode.AppendLine('return ret; }')

    # PromptForChoice
    $null = $csharpCode.Append('public override int PromptForChoice(string caption, string message, System.Collections.ObjectModel.Collection<ChoiceDescription> choices, int defaultChoice) {')
    if ($NoConsole) {
        $null = $csharpCode.AppendLine('int i = Choice_Box.Show(choices, defaultChoice, caption, message); return (i == -1) ? defaultChoice : i; }')
    } else {
        $null = $csharpCode.AppendLine('if (!string.IsNullOrEmpty(caption)) WriteLine(caption); WriteLine(message); do { int idx = 0; SortedList<string, int> res = new SortedList<string, int>(); string defkey = ""; foreach (ChoiceDescription cd in choices) { string lkey = cd.Label.Substring(0, 1), ltext = cd.Label; int pos = cd.Label.IndexOf("&"); if (pos > -1) { lkey = cd.Label.Substring(pos + 1, 1).ToUpper(); ltext = (pos > 0) ? cd.Label.Substring(0, pos) + cd.Label.Substring(pos + 1) : cd.Label.Substring(1); } res.Add(lkey.ToLower(), idx); if (idx > 0) Write("  "); if (idx == defaultChoice) { Write(VerboseForegroundColor, rawUI.BackgroundColor, string.Format("[{0}] {1}", lkey, ltext)); defkey = lkey; } else { Write(rawUI.ForegroundColor, rawUI.BackgroundColor, string.Format("[{0}] {1}", lkey, ltext)); } idx++; } Write(rawUI.ForegroundColor, rawUI.BackgroundColor, string.Format("  [?] Help (default is \"{0}\"): ", defkey)); string inpkey = ""; try { inpkey = Console.ReadLine().ToLower(); if (res.ContainsKey(inpkey)) return res[inpkey]; if (string.IsNullOrEmpty(inpkey)) return defaultChoice; } catch { } if (inpkey == "?") { foreach (ChoiceDescription cd in choices) { string lk = cd.Label.Substring(0, 1); int p = cd.Label.IndexOf("&"); if (p > -1) lk = cd.Label.Substring(p + 1, 1).ToUpper(); WriteLine(string.Format("{0} - {1}", lk, cd.HelpMessage ?? "")); } } } while (true); }')
    }

    # PromptForCredential
    $null = $csharpCode.Append('public override PSCredential PromptForCredential(string caption, string message, string userName, string targetName, PSCredentialTypes allowedCredentialTypes, PSCredentialUIOptions options) {')
    if ($NoConsole) {
        $null = $csharpCode.AppendLine('var cred = Credential_Form.PromptForPassword(caption, message, targetName, userName, allowedCredentialTypes, options); if (cred != null) { var x = new SecureString(); foreach (char c in cred.Password.ToCharArray()) x.AppendChar(c); return new PSCredential(cred.User, x); } return null; }')
    } else {
        $null = $csharpCode.AppendLine('if (!string.IsNullOrEmpty(caption)) WriteLine(caption); WriteLine(message); string un; if (string.IsNullOrEmpty(userName) || ((options & PSCredentialUIOptions.ReadOnlyUserName) == 0)) { Write("User: "); un = ReadLine(); } else { Write("User: "); if (!string.IsNullOrEmpty(targetName)) Write(targetName + "\\"); WriteLine(userName); un = userName; } Write("Pass: "); SecureString pwd = ReadLineAsSecureString(); if (string.IsNullOrEmpty(un)) un = "<NOUSER>"; if (!string.IsNullOrEmpty(targetName) && un.IndexOf("\\") < 0) un = targetName + "\\" + un; return new PSCredential(un, pwd); }')
    }

    $null = $csharpCode.AppendLine('public override PSCredential PromptForCredential(string caption, string message, string userName, string targetName) { return PromptForCredential(caption, message, userName, targetName, PSCredentialTypes.Default, PSCredentialUIOptions.Default); }')
    $null = $csharpCode.AppendLine('}')

    # PS2Host class
    $null = $csharpCode.AppendLine(@'
    internal class PS2Host : PSHost
    {
        private PS2UI ui = null;
        private Guid myId = Guid.NewGuid();
        public PS2Host(PS2UI ui) { this.ui = ui; }
        public override CultureInfo CurrentCulture { get { return System.Threading.Thread.CurrentThread.CurrentCulture; } }
        public override CultureInfo CurrentUICulture { get { return System.Threading.Thread.CurrentThread.CurrentUICulture; } }
        public override Guid InstanceId { get { return this.myId; } }
        public override string Name { get { return "PS2EXE-PSHost"; } }
        public override PSHostUserInterface UI { get { return ui; } }
        public override Version Version { get { return new Version(2, 0, 0, 0); } }
        public override void EnterNestedPrompt() { }
        public override void ExitNestedPrompt() { }
        public override void NotifyBeginApplication() { }
        public override void NotifyEndApplication() { }
        public override void SetShouldExit(int exitCode) { }
    }
'@)

    # Main Program class
    $null = $csharpCode.AppendLine('    static class Program')
    $null = $csharpCode.AppendLine('    {')
    $null = $csharpCode.AppendLine("        $threadAttr")
    $null = $csharpCode.AppendLine(@'
        static void Main(string[] args)
        {
            int exitCode = 0;
            try {
                Assembly executingAssembly = Assembly.GetExecutingAssembly();
                string scriptDir = System.IO.Path.Combine(System.IO.Path.GetTempPath(), System.IO.Path.GetFileNameWithoutExtension(System.AppDomain.CurrentDomain.FriendlyName));
                System.IO.Directory.CreateDirectory(scriptDir);
                try { System.Reflection.Assembly.Load("PresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"); } catch {}
                try { System.Reflection.Assembly.Load("PresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"); } catch {}
                try { System.Reflection.Assembly.Load("WindowsBase, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"); } catch {}
'@)
    $null = $csharpCode.AppendLine($embedSection)
    $null = $csharpCode.AppendLine(@"
                using (System.IO.Stream scriptstream = executingAssembly.GetManifestResourceStream("$scriptResourceName"))
                using (System.IO.StreamReader scriptreader = new System.IO.StreamReader(scriptstream, System.Text.Encoding.UTF8))
                {
                    string script = scriptreader.ReadToEnd();
                    PS2UI ui = new PS2UI();
                    PS2Host host = new PS2Host(ui);
                    using (Runspace myRunSpace = RunspaceFactory.CreateRunspace(host))
                    {
                        myRunSpace.ApartmentState = System.Threading.ApartmentState.$rsAptState;
                        myRunSpace.Open();
                        try { System.Environment.CurrentDirectory = scriptDir; } catch { }
                        string baseDir = System.AppDomain.CurrentDomain.BaseDirectory.TrimEnd('\\');
                        myRunSpace.SessionStateProxy.SetVariable("ScriptRoot", baseDir);
                        string scriptFile = System.IO.Path.Combine(scriptDir, "__main__.ps1");
                        System.IO.File.WriteAllText(scriptFile, script, System.Text.Encoding.UTF8);
                        using (PowerShell posh = PowerShell.Create())
                        {
"@)
    if (!$NoConsole) {
        $null = $csharpCode.AppendLine('Console.CancelKeyPress += new ConsoleCancelEventHandler(delegate(object s, ConsoleCancelEventArgs e) { try { posh.BeginStop(null, null); e.Cancel = true; } catch { } });')
    }
    $null = $csharpCode.AppendLine(@'
                            posh.Runspace = myRunSpace;
                            posh.Streams.Error.DataAdded += new EventHandler<DataAddedEventArgs>(delegate(object sender, DataAddedEventArgs e)
                            { ui.WriteErrorLine(((PSDataCollection<ErrorRecord>)sender)[e.Index].Exception.Message); });
                            PSDataCollection<PSObject> colOutput = new PSDataCollection<PSObject>();
                            colOutput.DataAdded += new EventHandler<DataAddedEventArgs>(delegate(object sender, DataAddedEventArgs e)
                            { ui.WriteLine(((PSDataCollection<PSObject>)sender)[e.Index].ToString()); });
                            // Lift the execution policy for THIS PROCESS ONLY so the extracted __main__.ps1
                            // can run on machines where the policy defaults to Restricted (clean Windows installs).
                            // Process scope expires when the EXE exits - nothing is persisted or changed system-wide.
                            // A dedicated PowerShell instance keeps any policy noise out of the user-facing streams.
                            string effPolicy = "";
                            try
                            {
                                using (PowerShell prep = PowerShell.Create())
                                {
                                    prep.Runspace = myRunSpace;
                                    prep.AddScript("Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force -ErrorAction SilentlyContinue");
                                    prep.Invoke();
                                    prep.Commands.Clear();
                                    prep.AddScript("[string](Get-ExecutionPolicy)");
                                    foreach (PSObject po in prep.Invoke()) { if (po != null && po.BaseObject != null) effPolicy += po.BaseObject.ToString(); }
                                }
                            }
                            catch { }
                            // If a Group Policy still locks the policy (Restricted/AllSigned), fall back to
                            // executing the script text directly from memory, which is exempt from file policy checks.
                            bool fileAllowed = effPolicy.Equals("Bypass", StringComparison.OrdinalIgnoreCase)
                                || effPolicy.Equals("Unrestricted", StringComparison.OrdinalIgnoreCase)
                                || effPolicy.Equals("RemoteSigned", StringComparison.OrdinalIgnoreCase);
                            if (fileAllowed) { posh.AddCommand(scriptFile); } else { posh.AddScript(script); }
                            var asyncResult = posh.BeginInvoke<string, PSObject>(null, colOutput);
                            asyncResult.AsyncWaitHandle.WaitOne();
                            posh.Stop();
                            if (posh.InvocationStateInfo.State == PSInvocationState.Failed)
                                ui.WriteErrorLine(posh.InvocationStateInfo.Reason.Message);
                        }
                        myRunSpace.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                exitCode = 1;
'@)
    if ($NoConsole) {
        $null = $csharpCode.AppendLine('MessageBox.Show("Error: " + ex.Message, System.AppDomain.CurrentDomain.FriendlyName, MessageBoxButtons.OK, MessageBoxIcon.Error);')
    } else {
        $null = $csharpCode.AppendLine('Console.Write("Error: "); Console.WriteLine(ex.Message);')
    }
    $null = $csharpCode.AppendLine('Environment.Exit(exitCode); } } } }')

    $programFrame = $csharpCode.ToString()
    Add-LogLine -Message "[+] PS2EXE C# wrapper generated ($($programFrame.Length) chars)" -Level 'INFO'

    # Script block for async compilation
    $sb = {
        param($src, $out, $ico, $bundle,
              $ver, $desc, $prod, $copyr,
              $noConsole, $conHost, $unicodeEnc, $credGUI,
              $suppressOut, $suppressErr, $reqAdmin, $genConfig,
              $noVisualStyles, $exitOnCancel, $dpiAware, $prepareDebug,
              $supportOS, $virtualize, $longPaths,
              $aptState, $platform, $lcid, $extraArgs, $company, $trademark, $selectedFiles,
              $defaultIcon, $copyIcon, $csharpTemplate,
              $embedSections, $scriptResName, $bundleResPath, $bundleResName)
        $result = [ordered]@{
            Success = $false; ExitCode = -1
            Messages = [System.Collections.Generic.List[string]]::new()
            Output = ''
            CopiedIcon = ''
        }
        function LogMsg($msg) { $result.Messages.Add($msg) }
        function Format-FileSize { param([long]$Bytes)
            if ($Bytes -lt 1KB) { return '{0} B' -f $Bytes }
            if ($Bytes -lt 1MB) { return '{0:N2} KB' -f ($Bytes / 1KB) }
            return '{0:N2} MB' -f ($Bytes / 1MB)
        }

        LogMsg '============================================'
        LogMsg '  PSWrap v1.1.0 - PS2EXE Engine (Full PSHost)'
        LogMsg '============================================'
        LogMsg '[~] Reading source script...'
        $scriptContent = Get-Content -Path $src -Raw
        $scriptBytes = [System.Text.Encoding]::UTF8.GetBytes($scriptContent)
        LogMsg "[+] Source: $([System.IO.Path]::GetFileName($src)) ($($scriptBytes.Length) bytes)"

        $targetType = if ($noConsole) { 'winexe' } else { 'exe' }

        LogMsg '[~] Using PS2EXE C# wrapper with full PSHost...'

        $referenceAssemblies = [System.Collections.ArrayList]::new()
        $null = $referenceAssemblies.Add('System.dll')
        $null = $referenceAssemblies.Add('System.Core.dll')
        $smaAsm = [System.AppDomain]::CurrentDomain.GetAssemblies() |
            Where-Object { $_.ManifestModule.Name -ieq 'System.Management.Automation.dll' } | Select-Object -First 1
        if ($smaAsm) { $null = $referenceAssemblies.Add($smaAsm.Location) }

        # Resolve System.Windows.Forms by AssemblyName (strong name); fallback to scanning loaded assemblies
        try {
            $n = New-Object System.Reflection.AssemblyName('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
            [System.AppDomain]::CurrentDomain.Load($n) | Out-Null
        } catch {}
        $wfAsm = [System.AppDomain]::CurrentDomain.GetAssemblies() |
            Where-Object { $_.ManifestModule.Name -ieq 'System.Windows.Forms.dll' } | Select-Object -First 1
        if ($wfAsm) { $null = $referenceAssemblies.Add($wfAsm.Location) }

        # System.Drawing needed for icon handling in compiled EXE
        if ($noConsole) {
            try {
                $n = New-Object System.Reflection.AssemblyName('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
                [System.AppDomain]::CurrentDomain.Load($n) | Out-Null
            } catch {}
            $drawAsm = [System.AppDomain]::CurrentDomain.GetAssemblies() |
                Where-Object { $_.ManifestModule.Name -ieq 'System.Drawing.dll' } | Select-Object -First 1
            if ($drawAsm) { $null = $referenceAssemblies.Add($drawAsm.Location) }
        }
        LogMsg "[~] Resolved $($referenceAssemblies.Count) reference assemblies"

        $cp = New-Object System.CodeDom.Compiler.CompilerParameters($referenceAssemblies.ToArray(), $out, $false)
        $cp.GenerateExecutable = $true
        $cp.GenerateInMemory = $false
        $cp.TreatWarningsAsErrors = $false
        $cp.WarningLevel = 4
        $cp.IncludeDebugInformation = $false

        $plat = switch ($platform) {
            'x86' { 'x86' }
            'x64' { 'x64' }
            default { 'anycpu' }
        }

        $iconOption = ''
        $iconSrc = if ($ico -and (Test-Path $ico)) { $ico } else { $defaultIcon }
        if ($iconSrc -and (Test-Path $iconSrc)) {
            $outDir = Split-Path $out -Parent
            if ($copyIcon -and $outDir -and (Test-Path $outDir) -and ($iconSrc -ne (Join-Path $outDir ([System.IO.Path]::GetFileName($iconSrc))))) {
                Copy-Item -LiteralPath $iconSrc -Destination (Join-Path $outDir ([System.IO.Path]::GetFileName($iconSrc))) -Force -ErrorAction SilentlyContinue
                LogMsg "[~] Copied icon to output: $outDir"
            }
            $iconOption = "`"/win32icon:$iconSrc`""
            LogMsg "[~] Embedding icon: $iconSrc"
        }

        $manifestOption = ''
        $manifestPath = ''
        # Generate UAC manifest XML with requireAdministrator if admin mode was requested
        if ($reqAdmin) {
            $manifestPath = $out + '.win32manifest'
            $manifestXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
  <trustInfo xmlns="urn:schemas-microsoft-com:asm.v3">
    <security>
      <requestedPrivileges>
        <requestedExecutionLevel level="requireAdministrator" uiAccess="false"/>
      </requestedPrivileges>
    </security>
  </trustInfo>
</assembly>
"@
            [System.IO.File]::WriteAllText($manifestPath, $manifestXml, [System.Text.Encoding]::UTF8)
            $manifestOption = "`"/win32manifest:$manifestPath`""
            LogMsg '[~] Embedding admin rights manifest'
        }

        $extraOption = if ($extraArgs) { $extraArgs } else { '' }
        $cp.CompilerOptions = "/platform:$plat /target:$targetType /optimize+ $iconOption $manifestOption $extraOption".Trim() -replace '\s+', ' '
        LogMsg "  CompilerOptions: $($cp.CompilerOptions)"

        $null = $cp.EmbeddedResources.Add($src)
        # Embed each bundled file as a managed resource for runtime extraction
        if ($bundleResPath -and (Test-Path $bundleResPath)) {
            $null = $cp.EmbeddedResources.Add($bundleResPath)
            LogMsg "[~] Embedded bundle: $bundleResName ($([System.IO.File]::ReadAllBytes($bundleResPath).Length) bytes)"
        }

        $codeDOMsuccess = $false
        try {
            LogMsg '[~] Compiling PS2EXE engine via C# CodeDOM...'
            $cop = New-Object Microsoft.CSharp.CSharpCodeProvider
            $compilerResults = $cop.CompileAssemblyFromSource($cp, $csharpTemplate)
            if ($compilerResults.Errors.Count -gt 0) {
                $hasErr = $false
                foreach ($err in $compilerResults.Errors) {
                    if ($err.IsWarning) { LogMsg "  [W] $($err)" }
                    else { $hasErr = $true; LogMsg "  [X] $($err)" }
                }
                if ($hasErr) { $result.ExitCode = 1; LogMsg '[X] PS2EXE compilation failed' }
                else { $codeDOMsuccess = $true }
            } else { $codeDOMsuccess = $true }

            if ($codeDOMsuccess) {
                $result.Success = $true; $result.Output = $out
                LogMsg '*** COMPILATION SUCCESSFUL (PS2EXE Engine) ***'
                $fi = Get-Item $out -ErrorAction SilentlyContinue
                if ($fi) { LogMsg "  Output: $out"; LogMsg "  Size: $(Format-FileSize -Bytes $fi.Length)" }
            }
        } catch {
            LogMsg '[i] CodeDOM not available, falling back to csc.exe...'
        }

        if (-not $codeDOMsuccess) {
            # Find csc.exe: check .NET Framework paths, then Roslyn NuGet fallback
            try {
                $cscExe = $null
                $baseDir = "$env:windir\Microsoft.NET"
                $candidates = @("$baseDir\Framework64\v4.0.30319\csc.exe", "$baseDir\Framework\v4.0.30319\csc.exe")
                foreach ($p in $candidates) {
                    if (Test-Path $p) { $cscExe = (Get-Item $p).FullName; break }
                }
                if (-not $cscExe) { LogMsg '[X] csc.exe not found.'; $result.ExitCode = 1 }
                else {
                    LogMsg "[~] Compiling PS2EXE engine with csc.exe: $cscExe"
                    $csTemp = [System.IO.Path]::GetTempFileName()
                    Remove-Item $csTemp -Force -ErrorAction SilentlyContinue
                    $csTemp = [System.IO.Path]::ChangeExtension($csTemp, '.cs')
                    [System.IO.File]::WriteAllText($csTemp, $csharpTemplate, [System.Text.Encoding]::UTF8)

                    $refs = '/r:System.dll /r:System.Core.dll /r:System.Windows.Forms.dll'
                    $smaPath = Get-ChildItem -Path "$env:windir\Microsoft.NET\assembly\GAC_MSIL\System.Management.Automation" -Filter 'System.Management.Automation.dll' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
                    if ($smaPath) { $refs += " /r:`"$($smaPath.FullName)`"" }
                    else {
                        $smaAsm = [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.ManifestModule.Name -ieq 'System.Management.Automation.dll' } | Select-Object -First 1
                        if ($smaAsm) { $refs += " /r:`"$($smaAsm.Location)`" /r:System.Runtime.dll" }
                    }
                    if ($noConsole) { $refs += ' /r:System.Drawing.dll' }

                    $resOpt = " /resource:`"$src`",`"$scriptResName`""
                    if ($bundleResPath -and (Test-Path $bundleResPath)) {
                        $resOpt += " /resource:`"$bundleResPath`",`"$bundleResName`""
                    }

                    $cscOpts = "/platform:$plat /target:$targetType /optimize+ $iconOption $manifestOption $extraOption".Trim() -replace '\s+', ' '
                    $cmdLine = "`"$cscExe`" /nologo $cscOpts $refs /out:`"$out`" `"$csTemp`" $resOpt"
                    LogMsg "  $cmdLine"

                    $cscOutput = cmd /c $cmdLine 2>&1
                    $result.ExitCode = $LASTEXITCODE
                    if ($cscOutput) { foreach ($l in $cscOutput) { if ($l) { LogMsg "  $l" } } }

                    Remove-Item $csTemp -Force -ErrorAction SilentlyContinue

                    if ($LASTEXITCODE -eq 0) {
                        $result.Success = $true; $result.Output = $out
                        LogMsg '*** COMPILATION SUCCESSFUL (PS2EXE Engine via csc.exe) ***'
                        $fi = Get-Item $out -ErrorAction SilentlyContinue
                        if ($fi) { LogMsg "  Output: $out"; LogMsg "  Size: $(Format-FileSize -Bytes $fi.Length)" }
                    } else { LogMsg "[X] PS2EXE compilation failed (exit code: $LASTEXITCODE)" }
                }
            } catch { $result.ExitCode = -1; LogMsg "[X] csc.exe fallback exception: $_" }
        }

        if ($genConfig -and $result.Success) {
            try {
                $configPath = $out + '.config'
                $configXml = @'
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <startup>
    <supportedRuntime version="v4.0" sku=".NETFramework,Version=v4.0"/>
  </startup>
</configuration>
'@
                [System.IO.File]::WriteAllText($configPath, $configXml, [System.Text.Encoding]::UTF8)
                LogMsg "[+] Config file generated: $configPath"
            } catch { LogMsg "[X] Failed to generate config file: $_" }
        }

        if ($manifestPath -and (Test-Path $manifestPath)) { Remove-Item $manifestPath -Force -ErrorAction SilentlyContinue }
        if ($bundleResPath -and (Test-Path $bundleResPath)) { Remove-Item $bundleResPath -Force -ErrorAction SilentlyContinue }

        [pscustomobject]$result
    }

    # Prepare icon files
    $actualDefaultIcon = $script:DefaultIconPath
    if ($actualDefaultIcon -and (Test-Path $actualDefaultIcon) -and ([System.IO.Path]::GetExtension($actualDefaultIcon) -ne '.ico')) {
        $convertedIco = [System.IO.Path]::GetTempFileName()
        Remove-Item $convertedIco -Force -ErrorAction SilentlyContinue
        $convertedIco = [System.IO.Path]::ChangeExtension($convertedIco, '.ico')
        $result = ConvertTo-Icon -ImagePath $actualDefaultIcon -OutputPath $convertedIco
        if ($result) { $actualDefaultIcon = $result; [void]$script:tempIconFiles.Add($result) }
    }
    $actualIconPath = $IconPath
    if ($actualIconPath -and (Test-Path $actualIconPath) -and ([System.IO.Path]::GetExtension($actualIconPath) -ne '.ico')) {
        $convertedIco = [System.IO.Path]::GetTempFileName()
        Remove-Item $convertedIco -Force -ErrorAction SilentlyContinue
        $convertedIco = [System.IO.Path]::ChangeExtension($convertedIco, '.ico')
        $result = ConvertTo-Icon -ImagePath $actualIconPath -OutputPath $convertedIco
        if ($result) { $actualIconPath = $result; [void]$script:tempIconFiles.Add($result) }
    }

    $rs = [runspacefactory]::CreateRunspace()
    $rs.ApartmentState = 'STA'; $rs.ThreadOptions = 'ReuseThread'
    $rs.Open()

    $ps = [powershell]::Create()
    $ps.Runspace = $rs
    $null = $ps.AddScript($sb)
    $params = @($SourcePath, $OutputPath, $actualIconPath, $BundleFolder,
                $Version, $FileDescription, $ProductName, $Copyright,
                $NoConsole, $ConHost, $UnicodeEncoding, $CredentialGUI,
                $SuppressOutput, $SuppressError, $RequireAdmin, $GenerateConfig,
                $NoVisualStyles, $ExitOnCancel, $DPIAware, $PrepareDebug,
                $SupportOS, $Virtualize, $LongPaths,
                $ApartmentState, $Platform, $LCID, $ExtraArgs, $Company, $Trademark, $SelectedFiles,
                $actualDefaultIcon, $SaveIcon, $programFrame, $embedSection, $scriptResourceName,
                $bundleResourcePath, $bundleResourceName)
    $params | ForEach-Object { $null = $ps.AddArgument($_) }

    $handle = $ps.BeginInvoke()
    $script:activeRunspace = $rs
    $script:asyncPowerShell = $ps
    $script:asyncResult = $handle
}

<#
.SYNOPSIS
Stops and disposes the background PowerShell runspace and async operation.
.DESCRIPTION
Cancels the in-progress async PowerShell instance via Stop(), then disposes both the
PowerShell object and its backing Runspace. Clears all script-scoped async state variables.
#>
function Stop-AsyncOperation {
    try {
        if ($script:asyncPowerShell -and $script:asyncResult -and -not $script:asyncResult.IsCompleted) {
            try { $script:asyncPowerShell.Stop() } catch { }
        }
    } catch { }
    try { if ($script:asyncPowerShell) { $script:asyncPowerShell.Dispose() } } catch { }
    try { if ($script:activeRunspace) { $script:activeRunspace.Close(); $script:activeRunspace.Dispose() } } catch { }
    $script:asyncPowerShell = $null; $script:asyncResult = $null; $script:activeRunspace = $null
}

<#
.SYNOPSIS
Scans the project folder for companion files and builds the bundle files list.
.DESCRIPTION
Recursively enumerates all files in the project folder (excluding the source script itself),
populates the bundleFiles collection with metadata including relative path and size, and
updates the DataGrid bound to the bundle files list.
#>
function Update-BundleFilesList {
    $src = $script:txtSrcScript.Text.Trim()
    $pdir = $script:txtProjectFolder.Text.Trim()
    $script:bundleFiles.Clear()
    if ($pdir -and (Test-Path $pdir)) {
        $files = Get-ChildItem -LiteralPath $pdir -File -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -ine $src -and $_.Name -ine [System.IO.Path]::GetFileName($src) }
        $totalSize = 0L
        foreach ($f in $files) {
            $rel = $f.FullName.Substring($pdir.TrimEnd('\').Length).TrimStart('\','/')
            [void]$script:bundleFiles.Add([PSCustomObject]@{
                IsSelected   = $true
                Name         = $f.Name
                Size         = Format-FileSize -Bytes $f.Length
                SizeBytes    = $f.Length
                RelativePath = $rel
                FullPath     = $f.FullName
            })
            $totalSize += $f.Length
        }
        if ($script:dgvBundleFiles) {
            $script:dgvBundleFiles.ItemsSource = $null
            $script:dgvBundleFiles.ItemsSource = $script:bundleFiles
        }
        $script:lblBundleCount.Text = if ($files.Count -gt 0) { "{0} file(s), {1}" -f $files.Count, (Format-FileSize $totalSize) } else { 'No companion files' }
    } else {
        $script:bundleFiles.Clear()
        if ($script:dgvBundleFiles) { $script:dgvBundleFiles.ItemsSource = $null }
        $script:lblBundleCount.Text = '(select project folder)'
    }
}

<#
.SYNOPSIS
Refreshes the bundle count, package name, and source size labels from UI fields.
.DESCRIPTION
Reads the current source script and project folder paths from the UI, updates the
bundle files list if a project folder is set, and refreshes the package name and
source file size labels on the main form.
#>
function Update-UIState {
    $src = $script:txtSrcScript.Text.Trim()
    $pdir = $script:txtProjectFolder.Text.Trim()
    if ($pdir -and (Test-Path $pdir)) {
        Update-BundleFilesList
        if ($script:chkSelectAll) { $script:chkSelectAll.IsChecked = $true }
    } else {
        $script:bundleFiles.Clear()
        if ($script:dgvBundleFiles) { $script:dgvBundleFiles.ItemsSource = $null }
        $script:lblBundleCount.Text = '(select project folder)'
    }
    if ($src -and (Test-Path $src)) {
        $script:lblPkgName.Text = [System.IO.Path]::GetFileName($src)
        try {
            $fi = Get-Item -LiteralPath $src -ErrorAction SilentlyContinue
            if ($fi) { $script:lblSrcSize.Text = Format-FileSize -Bytes $fi.Length }
        } catch { $script:lblSrcSize.Text = '--' }
    } else {
        $script:lblPkgName.Text = ''
        $script:lblSrcSize.Text = '--'
    }
}

