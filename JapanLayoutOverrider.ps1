# --- Auto-Elevate ---
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process -FilePath "powershell" -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# --- Load SHLoadIndirectString only once ---
if (-not ("NativeMethods" -as [type])) {
    Add-Type @"
using System;
using System.Text;
using System.Runtime.InteropServices;

public static class NativeMethods {
    [DllImport("shlwapi.dll", CharSet = CharSet.Unicode)]
    public static extern int SHLoadIndirectString(
        string pszSource,
        StringBuilder pszOutBuf,
        int cchOutBuf,
        IntPtr ppvReserved
    );
}
"@
}

function Resolve-ResourceString {
    param([string]$resource)

    if (-not $resource.StartsWith("@")) {
        return $resource
    }

    $buffer = New-Object System.Text.StringBuilder 1024
    $result = [NativeMethods]::SHLoadIndirectString($resource, $buffer, $buffer.Capacity, [IntPtr]::Zero)

    if ($result -eq 0) {
        return $buffer.ToString()
    }
    return $resource
}

# --- Read installed keyboard layouts (Preload + Substitutes) ---
$preloadPath = "HKCU:\Keyboard Layout\Preload"
$subsPath    = "HKCU:\Keyboard Layout\Substitutes"

$installed = @()

if (Test-Path $preloadPath) {
    $installed += (Get-Item $preloadPath).Property | ForEach-Object {
        (Get-ItemProperty $preloadPath).$_
    }
}

if (Test-Path $subsPath) {
    foreach ($code in $installed) {
        $subValue = (Get-ItemProperty $subsPath -ErrorAction SilentlyContinue).$code
        if ($subValue) {
            $installed = $installed -replace $code, $subValue
        }
    }
}

$installed = $installed | Sort-Object -Unique

# --- Read Keyboard Layout info ---
$basePath = "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layouts"
$layouts = Get-ChildItem $basePath

$layoutInfo = foreach ($layout in $layouts) {
    $props = Get-ItemProperty $layout.PSPath

    [PSCustomObject]@{
        Code = $layout.PSChildName
        Name = Resolve-ResourceString $props."Layout Display Name"
        File = $props."Layout File"
    }
}

# --- Filter only installed ---
$filtered = foreach ($code in $installed) {
    $layoutInfo | Where-Object { $_.Code -eq $code }
}

# --- Numbered list ---
Write-Host "=== Installed Keyboard Layouts ==="
$index = 1
$filtered | ForEach-Object {
    Write-Host "[$index] ($($_.Code))   $($_.File)   $($_.Name)"
    $index++
}

$choice = Read-Host "Select a number (e.g. 1)"

if ($choice -notmatch '^\d+$' -or $choice -lt 1 -or $choice -gt $filtered.Count) {
    Write-Host "Invalid selection. Exiting."
    exit
}

$selectedLayout = $filtered[$choice - 1]

Write-Host ""
Write-Host "Japanese Layout File updated to:"
$selectedLayout | Format-List

# --- Replace DLL ---
$japaneseDllPath = "$basePath\00000411"
Set-ItemProperty -Path $japaneseDllPath -Name "Layout File" -Value $selectedLayout.File

# --- Remove LayerDriver JPN ---
$driverPath = "HKLM:\SYSTEM\CurrentControlSet\Services\i8042prt\Parameters"
$driverValue = "LayerDriver JPN"

if (Get-ItemProperty -Path $driverPath -Name $driverValue -ErrorAction SilentlyContinue) {
    Remove-ItemProperty -Path $driverPath -Name $driverValue
    Write-Host "LayerDriver JPN removed."
}

Write-Host "Restart your PC for the settings to take effect."
