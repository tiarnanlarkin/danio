param(
    [switch]$ApplyToSession
)

$ErrorActionPreference = "Stop"

$sdk = $env:ANDROID_HOME
if ([string]::IsNullOrWhiteSpace($sdk)) {
    $sdk = $env:ANDROID_SDK_ROOT
}
if ([string]::IsNullOrWhiteSpace($sdk)) {
    $sdk = Join-Path $env:LOCALAPPDATA "Android\Sdk"
}

$platformTools = Join-Path $sdk "platform-tools"
$emulatorTools = Join-Path $sdk "emulator"
$cmdlineTools = Join-Path $sdk "cmdline-tools\latest\bin"
$isWindows = ($env:OS -eq "Windows_NT") -or ([System.IO.Path]::DirectorySeparatorChar -eq '\')
$apkAnalyzerName = if ($isWindows) { "apkanalyzer.bat" } else { "apkanalyzer" }
$apkAnalyzerPath = Join-Path $cmdlineTools $apkAnalyzerName

Write-Host "Danio Android tooling check"
Write-Host "SDK: $sdk"
Write-Host ""

if (!(Test-Path $sdk)) {
    Write-Host "Missing Android SDK directory: $sdk" -ForegroundColor Red
    exit 1
}

$missing = @()
if (!(Test-Path (Join-Path $platformTools "adb.exe"))) {
    $missing += "adb.exe"
}
if (!(Test-Path (Join-Path $emulatorTools "emulator.exe"))) {
    $missing += "emulator.exe"
}
if (!(Test-Path $apkAnalyzerPath)) {
    $missing += $apkAnalyzerName
}

if ($missing.Count -gt 0) {
    Write-Host "Missing Android tools: $($missing -join ', ')" -ForegroundColor Red
    if ($isWindows -and (Test-Path (Join-Path $cmdlineTools "apkanalyzer")) -and !(Test-Path $apkAnalyzerPath)) {
        Write-Host "Found extensionless apkanalyzer, but Flutter on Windows requires apkanalyzer.bat." -ForegroundColor Yellow
        Write-Host "Reinstall Android SDK Command-line Tools for Windows from Android Studio SDK Manager." -ForegroundColor Yellow
    }
    exit 1
}

if ($ApplyToSession) {
    $env:ANDROID_HOME = $sdk
    $env:ANDROID_SDK_ROOT = $sdk
    $pathEntries = $env:Path -split ';'
    foreach ($entry in @($platformTools, $emulatorTools, $cmdlineTools)) {
        if ($pathEntries -notcontains $entry) {
            $env:Path = "$entry;$env:Path"
        }
    }
    Write-Host "Applied ANDROID_HOME, ANDROID_SDK_ROOT, and PATH for this PowerShell session." -ForegroundColor Green
} else {
    Write-Host "Run with -ApplyToSession to update this PowerShell session PATH." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Tool versions:"

& (Join-Path $platformTools "adb.exe") version
Write-Host ""
& (Join-Path $emulatorTools "emulator.exe") -version
Write-Host ""
Write-Host "apkanalyzer: $apkAnalyzerPath"
Write-Host ""

Write-Host "Available Android virtual devices:"
& (Join-Path $emulatorTools "emulator.exe") -list-avds
Write-Host ""

Write-Host "Flutter devices:"
flutter devices
