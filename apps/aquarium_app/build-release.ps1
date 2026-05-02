# Build Release AAB for Danio
# Run from Windows PowerShell in apps/aquarium_app.

$ErrorActionPreference = "Stop"

Write-Host "Building Danio release AAB..." -ForegroundColor Cyan
Write-Host ""

$expectedPath = "C:\Users\larki\Documents\Danio Aquarium App Project\repo\apps\aquarium_app"

if (!(Test-Path "pubspec.yaml")) {
    Write-Host "Error: must run from app root directory." -ForegroundColor Red
    Write-Host "Expected: $expectedPath" -ForegroundColor Yellow
    exit 1
}

$pubspec = Get-Content -Raw "pubspec.yaml"
if ($pubspec -notmatch "name:\s+danio") {
    Write-Host "Error: this does not look like the Danio Flutter app root." -ForegroundColor Red
    exit 1
}

try {
    flutter --version | Out-Null
} catch {
    Write-Host "Error: Flutter not found in PATH." -ForegroundColor Red
    Write-Host "Add Flutter to PATH or run through the configured Flutter shell." -ForegroundColor Yellow
    exit 1
}

$sdk = $env:ANDROID_HOME
if ([string]::IsNullOrWhiteSpace($sdk)) {
    $sdk = $env:ANDROID_SDK_ROOT
}
if ([string]::IsNullOrWhiteSpace($sdk)) {
    $sdk = Join-Path $env:LOCALAPPDATA "Android\Sdk"
}

foreach ($entry in @(
    (Join-Path $sdk "platform-tools"),
    (Join-Path $sdk "emulator"),
    (Join-Path $sdk "cmdline-tools\latest\bin")
)) {
    if ((Test-Path $entry) -and (($env:Path -split ';') -notcontains $entry)) {
        $env:Path = "$entry;$env:Path"
    }
}

$cmdlineTools = Join-Path $sdk "cmdline-tools\latest\bin"
$apkAnalyzerPath = Join-Path $cmdlineTools "apkanalyzer.bat"
if (!(Test-Path $apkAnalyzerPath)) {
    Write-Host "Error: apkanalyzer.bat not found at $apkAnalyzerPath." -ForegroundColor Red
    if (Test-Path (Join-Path $cmdlineTools "apkanalyzer")) {
        Write-Host "Found extensionless apkanalyzer, but Flutter on Windows requires apkanalyzer.bat." -ForegroundColor Yellow
    }
    Write-Host "Install Android SDK Command-line Tools for Windows from Android Studio SDK Manager." -ForegroundColor Yellow
    exit 1
}

Write-Host "Cleaning previous build..." -ForegroundColor Yellow
flutter clean

Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host "Running analyzer..." -ForegroundColor Yellow
flutter analyze --no-pub

Write-Host "Running tests..." -ForegroundColor Yellow
flutter test

Write-Host "Building release AAB..." -ForegroundColor Yellow
$startTime = Get-Date
flutter build appbundle --release

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Build failed. Check errors above." -ForegroundColor Red
    exit $LASTEXITCODE
}

$duration = (Get-Date) - $startTime
$minutes = [math]::Floor($duration.TotalMinutes)
$seconds = $duration.Seconds
$aabPath = "build\app\outputs\bundle\release\app-release.aab"

Write-Host ""
Write-Host "Build successful. ($minutes min $seconds sec)" -ForegroundColor Green
Write-Host ""
Write-Host "AAB location:" -ForegroundColor Cyan
Write-Host "  $aabPath" -ForegroundColor White

if (Test-Path $aabPath) {
    $sizeMB = [math]::Round((Get-Item $aabPath).Length / 1MB, 2)
    Write-Host "File size: $sizeMB MB" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Next release checks:" -ForegroundColor Yellow
Write-Host "  1. Run Android device smoke tests."
Write-Host "  2. Verify legal URLs and Play Console metadata."
Write-Host "  3. Upload the AAB only after CI/release gates are green."
