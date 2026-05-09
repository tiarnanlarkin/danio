param(
  [string]$DeviceId = "emulator-5554",
  [string]$AppId = "com.tiarnanlarkin.danio",
  [string]$AdbPath = "",
  [string]$MaestroPath = "",
  [string[]]$Flows = @(
    ".maestro\onboarding.yaml",
    ".maestro\tab-navigation.yaml",
    ".maestro\learning-lesson.yaml",
    ".maestro\settings.yaml",
    ".maestro\calculators.yaml",
    ".maestro\achievements.yaml",
    ".maestro\tank-creation.yaml",
    ".maestro\tank-management.yaml",
    ".maestro\edge-cases.yaml"
  ),
  [switch]$KeepState,
  [switch]$ContinueOnFailure
)

$ErrorActionPreference = "Stop"
$env:MAESTRO_CLI_NO_ANALYTICS = "true"
$env:MAESTRO_CLI_ANALYSIS_NOTIFICATION_DISABLED = "true"

function Resolve-CommandPath {
  param(
    [string]$ExplicitPath,
    [string]$CommandName,
    [string]$FallbackPath = ""
  )

  if ($ExplicitPath) {
    if (Test-Path $ExplicitPath) {
      return (Resolve-Path $ExplicitPath).Path
    }

    throw "$CommandName not found at '$ExplicitPath'"
  }

  $command = Get-Command $CommandName -ErrorAction SilentlyContinue
  if ($command) {
    return $command.Source
  }

  if ($FallbackPath -and (Test-Path $FallbackPath)) {
    return $FallbackPath
  }

  throw "$CommandName was not found. Add it to PATH or pass the explicit path."
}

$adb = Resolve-CommandPath `
  -ExplicitPath $AdbPath `
  -CommandName "adb" `
  -FallbackPath (Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe")

$maestro = Resolve-CommandPath -ExplicitPath $MaestroPath -CommandName "maestro"

function Invoke-Adb {
  param([Parameter(Mandatory = $true)][string[]]$AdbArgs)

  $base = @()
  if ($DeviceId) {
    $base += @("-s", $DeviceId)
  }

  & $adb @base @AdbArgs
  if ($LASTEXITCODE -ne 0) {
    throw "adb failed: $($AdbArgs -join ' ')"
  }
}

Write-Host "Checking Android device..."
Invoke-Adb @("get-state") | Out-Host

$results = @()

foreach ($flow in $Flows) {
  if (-not (Test-Path $flow)) {
    throw "Maestro flow not found: $flow"
  }

  if (-not $KeepState) {
    Write-Host "Clearing $AppId before $flow..."
    Invoke-Adb @("shell", "pm", "clear", $AppId) | Out-Null
  }

  $maestroArgs = @("test")
  if ($DeviceId) {
    $maestroArgs += @("--device", $DeviceId)
  }
  $maestroArgs += $flow

  Write-Host "Running $flow..."
  & $maestro @maestroArgs
  $exitCode = $LASTEXITCODE

  if ($exitCode -eq 0) {
    $results += "PASS $flow"
    continue
  }

  $results += "FAIL $flow ($exitCode)"
  if (-not $ContinueOnFailure) {
    $results | ForEach-Object { Write-Host $_ }
    exit $exitCode
  }
}

Write-Host ""
Write-Host "Maestro smoke results:"
$results | ForEach-Object { Write-Host $_ }

if ($results | Where-Object { $_ -like "FAIL *" }) {
  exit 1
}

exit 0
