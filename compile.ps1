# --- PS2EXE Module Check ---
$modName = "PS2EXE"
if (!(Get-Module -ListAvailable $modName)) {
    Write-Host "Module $modName not found, installing..." -ForegroundColor Yellow
    Install-Module -Name $modName -Scope CurrentUser -Force
}
Import-Module $modName

# --- Compilation Settings ---
$Params = @{
    InputFile    = ".\Windows_Sandbox_Reloaded.ps1"
    OutputFile   = ".\Windows_Sandbox_Reloaded.exe"
    IconFile     = ".\icon.ico"
    Title        = "Read-Only Windows Sandbox Integration"
    Description  = "File Explorer Integration to Windows Sandbox"
    Company      = "Osman Onur Koc"
    Product      = "Windows Sandbox Reloaded"
    Copyright    = "www.osmanonurkoc.com"
    Version      = "1.0.0.0"
    NoConsole    = $true
    STA          = $true  # Critical for WPF
    requireAdmin = $true  # <--- FIXED: The correct parameter name is 'requireAdmin'
}

# --- Icon Check ---
# Note: PS2EXE requires .ico format. Ensure you converted your PNG to ICO.
if (!(Test-Path $Params.IconFile)) {
    Write-Warning "WARNING: icon.ico not found. Using default icon."
    $Params.Remove('IconFile')
}

# --- Start Compilation ---
Write-Host "Starting compilation process..." -ForegroundColor Cyan
try {
    # Invoke-PS2EXE uses the splatted params
    Invoke-PS2EXE @Params
    Write-Host "`nSUCCESS: Windows_Sandbox_Reloaded.exe created successfully!" -ForegroundColor Green
}
catch {
    Write-Error "Error occurred during compilation: $_"
}

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
