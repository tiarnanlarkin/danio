param(
  [string]$DeviceId = "",
  [string]$AvdName = "danio_api36",
  [string]$ArtifactDir = "build\qa-artifacts\android-user-journeys",
  [string]$InstallApkPath = "",
  [switch]$CleanInstall,
  [switch]$ListOnly
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$journeys = @(
  "JOURNEY|first-run-and-shell|consent, skip setup, and all five main tabs",
  "JOURNEY|practice-and-tank|practice entry, Tank toolbox, and tank routes",
  "JOURNEY|learn-smart-and-more|learning, Smart, Workshop, preferences, and backup"
)

$journeys | ForEach-Object { Write-Host $_ }
if ($ListOnly) {
  Write-Host "LIST_ONLY|PASS|no device command was run"
  exit 0
}

if (-not $DeviceId) {
  throw "DeviceId is required unless ListOnly is used."
}

$scriptsDir = $PSScriptRoot
$preflight = Join-Path $scriptsDir "run_danio_live_preview.ps1"
$blackbox = Join-Path $scriptsDir "run_android_blackbox_smoke.ps1"
$powerShell = (Get-Command powershell.exe -ErrorAction Stop).Source

Write-Host "Validating pinned Danio device ownership preflight..."
& $powerShell -NoProfile -ExecutionPolicy Bypass -File $preflight `
  -AvdName $AvdName `
  -DeviceId $DeviceId `
  -CheckOnly `
  -AdbCommandTimeoutSeconds 10 `
  -PreflightTimeoutSeconds 30
if ($LASTEXITCODE -ne 0) {
  throw "Danio device preflight failed with exit code $LASTEXITCODE."
}

$blackboxArgs = @(
  "-NoProfile",
  "-ExecutionPolicy", "Bypass",
  "-File", $blackbox,
  "-DeviceId", $DeviceId,
  "-ArtifactDir", $ArtifactDir,
  "-IncludeQaDeepLinks"
)
if ($InstallApkPath) {
  $blackboxArgs += @("-InstallApkPath", $InstallApkPath)
}
if ($CleanInstall) {
  $blackboxArgs += "-CleanInstall"
}

Write-Host "Running the compact local Android user-journey suite..."
& $powerShell @blackboxArgs
if ($LASTEXITCODE -ne 0) {
  throw "Android user-journey suite failed with exit code $LASTEXITCODE."
}

Write-Host "ANDROID_USER_JOURNEYS|PASS|device=$DeviceId|artifacts=$ArtifactDir"
