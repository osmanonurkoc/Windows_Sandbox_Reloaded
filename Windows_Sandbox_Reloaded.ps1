<#
    .SYNOPSIS
    Windows Sandbox Reloaded Manager (v1.0 - Native Edition)
    A modern WPF GUI to manage Windows Sandbox features and context menu integration.

    .DESCRIPTION
    Key Features:
    - Feature Manager: Enable/Disable "Windows Sandbox" optional feature with one click.
    - Context Menu Integration: Adds "Open in Sandbox (Read-Only)" to the right-click menu.
    - Safe Execution: Mounts the target folder as Read-Only within the Sandbox for malware analysis.
    - Theme Engine: Auto-detects System Light/Dark mode.

    .AUTHOR
    @osmanonurkoc

    .LICENSE
    MIT License
#>

# ---------------------------------------------------------
# 1. LOAD ASSEMBLIES
# ---------------------------------------------------------
try {
    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName WindowsBase
} catch { exit }

# ---------------------------------------------------------
# 2. WIN32 API (SAFE LOADING)
# ---------------------------------------------------------
if (-not ("Win32Tools" -as [type])) {
    $Win32Code = @'
        using System;
        using System.Runtime.InteropServices;

        public class Win32Tools {
            [DllImport("dwmapi.dll", PreserveSig = true)]
            public static extern int DwmSetWindowAttribute(IntPtr hwnd, int attr, ref int attrValue, int attrSize);

            [DllImport("user32.dll")]
            public static extern int GetWindowLong(IntPtr hWnd, int nIndex);

            [DllImport("user32.dll")]
            public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);

            [DllImport("user32.dll", CharSet = CharSet.Auto)]
            public static extern IntPtr SendMessage(IntPtr hWnd, UInt32 Msg, IntPtr wParam, IntPtr lParam);
        }
'@
    Add-Type -TypeDefinition $Win32Code -Language CSharp
}

# ---------------------------------------------------------
# 3. ICON & ASSETS
# ---------------------------------------------------------
$SandboxIconBase64 = "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"

$IconBitmap = $null
if (![string]::IsNullOrEmpty($SandboxIconBase64)) {
    try {
        $Bytes = [Convert]::FromBase64String($SandboxIconBase64)
        $MemStream = New-Object System.IO.MemoryStream(,$Bytes)
        $IconBitmap = [System.Windows.Media.Imaging.BitmapFrame]::Create($MemStream)
    } catch {}
}

# ---------------------------------------------------------
# 4. THEME LOGIC
# ---------------------------------------------------------
function Get-SystemTheme {
    try {
        $regKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        $isLight = (Get-ItemProperty -Path $regKey -Name "AppsUseLightTheme" -ErrorAction SilentlyContinue).AppsUseLightTheme
        return if ($isLight -eq 1) { "Light" } else { "Dark" }
    } catch { return "Dark" }
}

$CurrentTheme = Get-SystemTheme
$Themes = @{
    "Dark" = @{
        "Bg" = "#202020"; "Surface" = "#2C2C2C"; "Text" = "#FFFFFF"; "SubText" = "#AAAAAA";
        "Border" = "#404040"; "Accent" = "#0078D4"; "ToggleOff" = "#333333"; "ToggleThumb" = "#FFFFFF"; "Red" = "#FF453A"; "Green" = "#32D74B"
    }
    "Light" = @{
        "Bg" = "#F3F3F3"; "Surface" = "#FFFFFF"; "Text" = "#000000"; "SubText" = "#666666";
        "Border" = "#E5E5E5"; "Accent" = "#0078D4"; "ToggleOff" = "#E0E0E0"; "ToggleThumb" = "#FFFFFF"; "Red" = "#E81123"; "Green" = "#107C10"
    }
}
$ThemeObj = $Themes[$CurrentTheme]

# ---------------------------------------------------------
# 5. XAML UI DESIGN
# ---------------------------------------------------------
[xml]$Xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Windows Sandbox Reloaded Manager"
        Height="450" Width="380"
        WindowStartupLocation="CenterScreen"
        ResizeMode="NoResize"
        WindowStyle="SingleBorderWindow"
        Background="{DynamicResource BgBrush}">

    <Window.Resources>
        <Style x:Key="ToggleSwitch" TargetType="CheckBox">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="CheckBox">
                        <Grid Background="Transparent" Cursor="Hand">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <ContentPresenter Grid.Column="0" VerticalAlignment="Center" HorizontalAlignment="Left"/>
                            <Border Grid.Column="1" Name="Border" Width="44" Height="22" CornerRadius="11" Background="{DynamicResource ToggleOffBrush}" BorderThickness="1" BorderBrush="{DynamicResource BorderBrush}">
                                <Ellipse Name="Dot" Width="14" Height="14" HorizontalAlignment="Left" Margin="4,0,0,0" Fill="{DynamicResource ToggleThumbBrush}"/>
                            </Border>
                        </Grid>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsChecked" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="{DynamicResource AccentBrush}"/>
                                <Setter TargetName="Dot" Property="HorizontalAlignment" Value="Right"/>
                                <Setter TargetName="Dot" Property="Margin" Value="0,0,4,0"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="Border" Property="Opacity" Value="0.5"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid Margin="20">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="30"/>
        </Grid.RowDefinitions>

        <StackPanel Grid.Row="0" Margin="0,10,0,30" Cursor="Hand" Name="BannerLink">
            <Image Name="LogoImage" Width="64" Height="64" HorizontalAlignment="Center" Margin="0,0,0,15"/>
            <TextBlock Text="Windows Sandbox Reloaded" FontSize="20" FontWeight="SemiBold" Foreground="{DynamicResource TextBrush}" HorizontalAlignment="Center"/>
            <TextBlock Text="@osmanonurkoc" FontSize="14" Foreground="{DynamicResource SubTextBrush}" HorizontalAlignment="Center" Margin="0,5,0,0"/>
        </StackPanel>

        <StackPanel Grid.Row="1">
            <Border Background="{DynamicResource SurfaceBrush}" CornerRadius="8" Padding="15" Margin="0,0,0,15" BorderThickness="1" BorderBrush="{DynamicResource BorderBrush}">
                <StackPanel>
                    <Grid Margin="0,0,0,5">
                        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                        <TextBlock Text="Windows Sandbox Feature" FontWeight="Bold" Foreground="{DynamicResource TextBrush}" FontSize="14"/>
                        <CheckBox Name="ToggleFeature" Grid.Column="1" Style="{StaticResource ToggleSwitch}"/>
                    </Grid>
                    <TextBlock Name="StatusFeature" Text="Status: Checking..." FontSize="12" Foreground="{DynamicResource SubTextBrush}"/>
                </StackPanel>
            </Border>

            <Border Background="{DynamicResource SurfaceBrush}" CornerRadius="8" Padding="15" BorderThickness="1" BorderBrush="{DynamicResource BorderBrush}">
                <StackPanel>
                    <Grid Margin="0,0,0,5">
                        <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                        <TextBlock Text="Context Menu Integration" FontWeight="Bold" Foreground="{DynamicResource TextBrush}" FontSize="14"/>
                        <CheckBox Name="ToggleContext" Grid.Column="1" Style="{StaticResource ToggleSwitch}"/>
                    </Grid>
                    <TextBlock Name="StatusContext" Text="Status: Checking..." FontSize="12" Foreground="{DynamicResource SubTextBrush}"/>
                </StackPanel>
            </Border>
        </StackPanel>

        <TextBlock Text="v1.0 Native Final" Grid.Row="2" VerticalAlignment="Bottom" HorizontalAlignment="Center"
                   Foreground="{DynamicResource SubTextBrush}" FontSize="11" Opacity="0.6"/>
    </Grid>
</Window>
"@

# ---------------------------------------------------------
# 6. UI INITIALIZATION
# ---------------------------------------------------------
$Reader = (New-Object System.Xml.XmlNodeReader $Xaml)
$Window = [Windows.Markup.XamlReader]::Load($Reader)

if ($IconBitmap) { $Window.Icon = $IconBitmap }

# Theme Binding
$Res = $Window.Resources
$Convert = { param($Hex) return (new-object System.Windows.Media.BrushConverter).ConvertFromString($Hex) }
$Res["BgBrush"]      = &$Convert $ThemeObj.Bg
$Res["SurfaceBrush"] = &$Convert $ThemeObj.Surface
$Res["TextBrush"]    = &$Convert $ThemeObj.Text
$Res["SubTextBrush"] = &$Convert $ThemeObj.SubText
$Res["BorderBrush"]  = &$Convert $ThemeObj.Border
$Res["AccentBrush"]  = &$Convert $ThemeObj.Accent
$Res["ToggleOffBrush"] = &$Convert $ThemeObj.ToggleOff
$Res["ToggleThumbBrush"] = &$Convert $ThemeObj.ToggleThumb
$Res["RedBrush"]     = &$Convert $ThemeObj.Red
$Res["GreenBrush"]   = &$Convert $ThemeObj.Green

# UI Controls
$BannerLink = $Window.FindName("BannerLink")
$LogoImage = $Window.FindName("LogoImage")
$ToggleFeature = $Window.FindName("ToggleFeature")
$ToggleContext = $Window.FindName("ToggleContext")
$StatusFeature = $Window.FindName("StatusFeature")
$StatusContext = $Window.FindName("StatusContext")

if ($IconBitmap) { $LogoImage.Source = $IconBitmap }

# ---------------------------------------------------------
# 7. LOGIC
# ---------------------------------------------------------
function Refresh-Status {
    $feat = Get-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM"
    $IsFeatureEnabled = ($feat.State -eq 'Enabled')

    if ($IsFeatureEnabled) {
        $ToggleFeature.IsChecked = $true
        $StatusFeature.Text = "Status: Active (Installed)"
        $StatusFeature.Foreground = $Res["GreenBrush"]
    } else {
        $ToggleFeature.IsChecked = $false
        $StatusFeature.Text = "Status: Inactive (Not Installed)"
        $StatusFeature.Foreground = $Res["SubTextBrush"]
    }

    $regPath = "Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\SandboxReadOnly"
    $IsContextInstalled = (Test-Path $regPath)

    if ($IsContextInstalled) {
        $ToggleContext.IsChecked = $true
        $StatusContext.Text = "Status: Integrated (Context Menu)"
        $StatusContext.Foreground = $Res["GreenBrush"]
    } else {
        $ToggleContext.IsChecked = $false
        $StatusContext.Text = "Status: Not Integrated"
        $StatusContext.Foreground = $Res["SubTextBrush"]
    }

    if (!$IsFeatureEnabled) {
        if ($IsContextInstalled) {
            $ToggleContext.IsEnabled = $true
            $StatusContext.Text = "Status: Installed (Warning: Sandbox is OFF)"
            $StatusContext.Foreground = $Res["RedBrush"]
        } else {
            $ToggleContext.IsEnabled = $false
            $StatusContext.Text = "Requirement: Enable Sandbox Feature first."
        }
    } else {
        $ToggleContext.IsEnabled = $true
    }
}

$ToggleFeature.Add_Click({
    $ToggleFeature.IsEnabled = $false
    $StatusFeature.Text = "Processing... Please wait."
    [System.Windows.Forms.Application]::DoEvents()
    if ($ToggleFeature.IsChecked) {
        Enable-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM" -All -NoRestart -ErrorAction SilentlyContinue
    } else {
        Disable-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM" -NoRestart -ErrorAction SilentlyContinue
    }
    Refresh-Status
    $ToggleFeature.IsEnabled = $true
})

$ToggleContext.Add_Click({
    $ToggleContext.IsEnabled = $false
    if ($ToggleContext.IsChecked) {
        $feat = Get-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM"
        if ($feat.State -ne 'Enabled') {
            [System.Windows.MessageBox]::Show("You must enable Windows Sandbox Feature before installing the Context Menu tool.", "Dependency Error", "OK", "Error")
            $ToggleContext.IsChecked = $false
            Refresh-Status
            $ToggleContext.IsEnabled = $true
            return
        }
        $StatusContext.Text = "Installing Scripts..."
        [System.Windows.Forms.Application]::DoEvents()

        $InstallDir = "$env:ProgramData\CustomTools_Sandbox"
        if (!(Test-Path $InstallDir)) { New-Item -Path $InstallDir -ItemType Directory -Force | Out-Null }
        $RunnerScriptPath = "$InstallDir\SandboxRunner_Bg.ps1"
        $ScriptContent = @'
param([string]$TargetFolder)
if ([string]::IsNullOrWhiteSpace($TargetFolder)) { exit }
$TargetFolder = $TargetFolder -replace '"', ''
$WsbConfig = @"
<Configuration>
  <MappedFolders>
    <MappedFolder>
      <HostFolder>$TargetFolder</HostFolder>
      <SandboxFolder>C:\Users\WDAGUtilityAccount\Desktop\Mounted_ReadOnly</SandboxFolder>
      <ReadOnly>true</ReadOnly>
    </MappedFolder>
  </MappedFolders>
  <Networking>Default</Networking>
  <VideoInput>Enable</VideoInput>
  <ProtectedClient>Enable</ProtectedClient>
  <PrinterRedirection>Disable</PrinterRedirection>
  <ClipboardRedirection>Default</ClipboardRedirection>
</Configuration>
"@
$TempWsbFile = "$env:TEMP\Sandbox_$(Get-Random).wsb"
$WsbConfig | Out-File -FilePath $TempWsbFile -Encoding UTF8
Start-Process -FilePath $TempWsbFile
'@
        $ScriptContent | Out-File -FilePath $RunnerScriptPath -Encoding UTF8 -Force
        $RegPath = "Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\SandboxReadOnly"
        if (!(Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
        Set-ItemProperty -Path $RegPath -Name "(Default)" -Value "Open in Sandbox (Read-Only)"
        Set-ItemProperty -Path $RegPath -Name "Icon" -Value "WindowsSandbox.exe"
        New-Item -Path "$RegPath\command" -Force | Out-Null
        Set-ItemProperty -Path "$RegPath\command" -Name "(Default)" -Value "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$RunnerScriptPath`" `"%V`""
    } else {
        $StatusContext.Text = "Removing Integration..."
        [System.Windows.Forms.Application]::DoEvents()
        $RegPath = "Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\SandboxReadOnly"
        if (Test-Path $RegPath) { Remove-Item -Path $RegPath -Recurse -Force }
        $InstallDir = "$env:ProgramData\CustomTools_Sandbox"
        if (Test-Path $InstallDir) { Remove-Item -Path $InstallDir -Recurse -Force }
    }
    Refresh-Status
    $ToggleContext.IsEnabled = $true
})

$BannerLink.Add_MouseLeftButtonDown({ Start-Process "https://www.osmanonurkoc.com" })

# ---------------------------------------------------------
# 8. WINDOW MODIFICATIONS
# ---------------------------------------------------------
$Window.Add_SourceInitialized({
    try {
        $InteropHelper = New-Object System.Windows.Interop.WindowInteropHelper($Window)
        $Hwnd = $InteropHelper.Handle

        # Dark Mode Titlebar
        if ($CurrentTheme -eq "Dark") {
            $Val = 1
            [Win32Tools]::DwmSetWindowAttribute($Hwnd, 20, [ref]$Val, 4)
        }

        # Remove Min/Max Buttons
        $Style = [Win32Tools]::GetWindowLong($Hwnd, -16)
        $NewStyle = $Style -band -bnot 0x20000 -band -bnot 0x10000
        [Win32Tools]::SetWindowLong($Hwnd, -16, $NewStyle) | Out-Null
    } catch { }
})

$Window.Add_Loaded({
    Refresh-Status
    if (![string]::IsNullOrEmpty($SandboxIconBase64)) {
        try {
            $InteropHelper = New-Object System.Windows.Interop.WindowInteropHelper($Window)
            $Hwnd = $InteropHelper.Handle
            $IconBytes = [Convert]::FromBase64String($SandboxIconBase64)
            $script:IconMemStream = New-Object System.IO.MemoryStream(,$IconBytes)
            $Bitmap = [System.Drawing.Bitmap]::FromStream($script:IconMemStream)
            $Hicon = $Bitmap.GetHicon()
            [Win32Tools]::SendMessage($Hwnd, 0x0080, [IntPtr]0, $Hicon) # ICON_SMALL
            [Win32Tools]::SendMessage($Hwnd, 0x0080, [IntPtr]1, $Hicon) # ICON_BIG
        } catch { }
    }
})

$Window.ShowDialog() | Out-Null
[System.Environment]::Exit(0)
