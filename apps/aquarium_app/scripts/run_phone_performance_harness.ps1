param(
  [Parameter(Mandatory = $true)]
  [string]$DeviceId,
  [string]$ProductCommit = "",
  [string]$AppId = "com.tiarnanlarkin.danio",
  [string]$OutputPath = "docs/qa/performance/2026-07-22/dcl-perf-001-phone-profile.json"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$AppRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$AdbExe = (Get-Command adb -CommandType Application -ErrorAction Stop).Source

function Invoke-Adb {
  param(
    [Parameter(Mandatory = $true)][string[]]$Arguments,
    [switch]$Global
  )

  $adbArguments = @($Arguments)
  if (-not $Global) {
    $adbArguments = @("-s", $DeviceId) + $adbArguments
  }
  $previousErrorActionPreference = $ErrorActionPreference
  $output = @()
  $adbExitCode = $null
  try {
    $ErrorActionPreference = "Continue"
    $global:LASTEXITCODE = $null
    $output = & $AdbExe @adbArguments 2>&1
    $adbExitCode = $global:LASTEXITCODE
  }
  finally {
    $ErrorActionPreference = $previousErrorActionPreference
  }
  if ($null -eq $adbExitCode -or $adbExitCode -ne 0) {
    throw "adb $($adbArguments -join ' ') failed: $($output -join ' ')"
  }
  return @($output)
}

function Get-Hierarchy {
  $lastError = ""
  for ($attempt = 1; $attempt -le 8; $attempt++) {
    try {
      $dump = (Invoke-Adb @("exec-out", "uiautomator", "dump", "/dev/tty")) -join "`n"
      $start = $dump.IndexOf("<?xml")
      $end = $dump.LastIndexOf("</hierarchy>")
      if ($start -ge 0 -and $end -ge 0) {
        return $dump.Substring($start, $end + "</hierarchy>".Length - $start)
      }
      throw "uiautomator output contained no hierarchy XML"
    }
    catch {
      $lastError = "$_"
      Start-Sleep -Milliseconds 250
    }
  }
  throw "uiautomator hierarchy failed: $lastError"
}

function Wait-TankInteractive {
  param([int]$TimeoutSeconds = 10)

  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  do {
    $xml = Get-Hierarchy
    $tankSelected =
      $xml -match 'content-desc="Tank Tab 3 of 5"[^>]*selected="true"' -or
      $xml -match 'selected="true"[^>]*content-desc="Tank Tab 3 of 5"'
    $toolboxVisible = $xml -match 'content-desc="Tank Toolbox"'
    if ($tankSelected -and $toolboxVisible) {
      return
    }
    Start-Sleep -Milliseconds 100
  } while ((Get-Date) -lt $deadline)

  throw "Timed out waiting for the selected Tank tab and Tank Toolbox."
}

function Resolve-LaunchActivity {
  $resolved = Invoke-Adb @("shell", "cmd", "package", "resolve-activity", "--brief", $AppId)
  $activity = $resolved | Where-Object { $_ -match "/" } | Select-Object -Last 1
  if (-not $activity) {
    throw "Could not resolve the launcher activity for $AppId."
  }
  return $activity.Trim()
}

function Clear-PerformanceLog {
  Invoke-Adb @("logcat", "-c") | Out-Null
}

function Get-PerformanceLog {
  return (Invoke-Adb @(
    "logcat", "-d", "-v", "brief",
    "DanioPerformance:I", "*:S"
  )) -join "`n"
}

function Invoke-PerformanceLaunch {
  param(
    [Parameter(Mandatory = $true)][string]$Activity,
    [Parameter(Mandatory = $true)]
    [ValidateSet("cold_start", "warm_resume")]
    [string]$Scenario
  )

  $launchCommand = `
    'log -p i -t DanioPerformance "DANIO_PERF_LAUNCH|{0}|$(cut -d " " -f1 /proc/uptime)"; am start -n {1}' `
      -f $Scenario, $Activity
  Invoke-Adb @("shell", $launchCommand) | Out-Null
}

function Wait-PerformanceSample {
  param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("cold_start", "warm_resume")]
    [string]$Scenario,
    [int]$TimeoutSeconds = 15
  )

  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  $launchSeconds = $null
  $readyMilliseconds = $null
  do {
    $log = Get-PerformanceLog
    if ($log -match "DANIO_PERF_LAUNCH\|$Scenario\|([0-9]+(?:\.[0-9]+)?)") {
      $launchSeconds = [double]::Parse(
        $Matches[1],
        [Globalization.CultureInfo]::InvariantCulture
      )
    }
    if ($log -match "DANIO_PERF_READY\|$Scenario\|([0-9]+(?:\.[0-9]+)?)") {
      $readyMilliseconds = [double]::Parse(
        $Matches[1],
        [Globalization.CultureInfo]::InvariantCulture
      )
    }
    if (
      $null -ne $launchSeconds -and
      $null -ne $readyMilliseconds
    ) {
      $elapsedMilliseconds = $readyMilliseconds - ($launchSeconds * 1000)
      if ($elapsedMilliseconds -le 0) {
        throw "Device readiness clock was not after its launch marker."
      }
      return $elapsedMilliseconds
    }
    Start-Sleep -Milliseconds 100
  } while ((Get-Date) -lt $deadline)

  throw "Timed out waiting for device launch and Tank-ready markers for $Scenario."
}

function Measure-ColdStart {
  param([Parameter(Mandatory = $true)][string]$Activity)

  Invoke-Adb @("shell", "am", "force-stop", $AppId) | Out-Null
  Start-Sleep -Milliseconds 250
  Clear-PerformanceLog
  Invoke-PerformanceLaunch -Activity $Activity -Scenario "cold_start"
  $elapsedMilliseconds = Wait-PerformanceSample -Scenario "cold_start"
  Wait-TankInteractive
  return $elapsedMilliseconds
}

function Measure-WarmResume {
  param([Parameter(Mandatory = $true)][string]$Activity)

  Invoke-Adb @("shell", "input", "keyevent", "KEYCODE_HOME") | Out-Null
  Start-Sleep -Milliseconds 300
  Clear-PerformanceLog
  Invoke-PerformanceLaunch -Activity $Activity -Scenario "warm_resume"
  $elapsedMilliseconds = Wait-PerformanceSample -Scenario "warm_resume"
  Wait-TankInteractive
  return $elapsedMilliseconds
}

function Write-HostLatencyRun {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][double[]]$ColdStartSamples,
    [Parameter(Mandatory = $true)][double[]]$WarmResumeSamples,
    [Parameter(Mandatory = $true)][string]$Commit,
    [Parameter(Mandatory = $true)][string]$Device
  )

  $run = [ordered]@{
    schema_version = 1
    product_commit = $Commit
    device = $Device
    records = @(
      [ordered]@{
        scenario = "cold_start"
        metric = "latency_ms"
        warm_up = $true
        samples_ms = @($ColdStartSamples[0])
      },
      [ordered]@{
        scenario = "cold_start"
        metric = "latency_ms"
        warm_up = $false
        samples_ms = @($ColdStartSamples[1..5])
      },
      [ordered]@{
        scenario = "warm_resume"
        metric = "latency_ms"
        warm_up = $true
        samples_ms = @($WarmResumeSamples[0])
      },
      [ordered]@{
        scenario = "warm_resume"
        metric = "latency_ms"
        warm_up = $false
        samples_ms = @($WarmResumeSamples[1..5])
      }
    )
  }
  [System.IO.File]::WriteAllText(
    $Path,
    ($run | ConvertTo-Json -Depth 8) + [Environment]::NewLine
  )
}

$restoreProductApk = ""
$restoreRequired = $false
$runError = $null
$restoreError = $null

Push-Location -LiteralPath $AppRoot
try {
  $headCommit = (& git rev-parse HEAD).Trim()
  if ($LASTEXITCODE -ne 0) {
    throw "Could not resolve the product commit."
  }
  if (-not $ProductCommit) {
    $ProductCommit = $headCommit
  }
  elseif ($ProductCommit -ne $headCommit) {
    throw "ProductCommit $ProductCommit does not match checked-out HEAD $headCommit."
  }
  if ($ProductCommit -notmatch '^[0-9a-f]{40}$') {
    throw "ProductCommit must be a full 40-character lowercase Git commit."
  }
  $gitStatus = @(& git status --short -uall)
  if ($LASTEXITCODE -ne 0) {
    throw "Git status failed while checking the product commit."
  }
  if ($gitStatus.Count -gt 0) {
    throw "The profile harness requires a clean product commit."
  }

  $readyDevices = (Invoke-Adb -Arguments @("devices") -Global) -join "`n"
  if ($readyDevices -notmatch "(?m)^$([regex]::Escape($DeviceId))\s+device$") {
    throw "Requested device $DeviceId is not the single ready target."
  }
  $avdName = (Invoke-Adb @("emu", "avd", "name") | Where-Object {
    $_ -and $_.Trim() -ne "OK"
  } | Select-Object -First 1).Trim()
  if ($avdName -ne "danio_api36") {
    throw "Requested device $DeviceId is AVD '$avdName', not danio_api36."
  }

  $deviceIdentity = "danio_api36 ($DeviceId)"
  $shortCommit = $ProductCommit.Substring(0, 12)
  $rawRoot = Join-Path $AppRoot "build\phone_performance\$shortCommit"
  if (Test-Path -LiteralPath $rawRoot) {
    throw "Generated run directory already exists: $rawRoot"
  }
  New-Item -ItemType Directory -Path $rawRoot | Out-Null
  if (Test-Path -LiteralPath $OutputPath) {
    throw "Refusing to overwrite existing report: $OutputPath"
  }

  Write-Host "flutter build apk --profile"
  & flutter build apk --profile --target lib/main.dart
  if ($LASTEXITCODE -ne 0) {
    throw "Profile APK build failed with exit code $LASTEXITCODE."
  }
  $profileApk = Join-Path $AppRoot "build\app\outputs\flutter-apk\app-profile.apk"
  if (-not (Test-Path -LiteralPath $profileApk -PathType Leaf)) {
    throw "Profile APK was not produced at $profileApk."
  }
  $restoreProductApk = Join-Path $rawRoot "product-profile.apk"
  Copy-Item -LiteralPath $profileApk -Destination $restoreProductApk

  Write-Host "flutter build apk --profile (local readiness marker)"
  & flutter build apk --profile --target lib/main.dart `
    --dart-define=DANIO_PROFILE_PERFORMANCE=true
  if ($LASTEXITCODE -ne 0) {
    throw "Instrumented profile APK build failed with exit code $LASTEXITCODE."
  }

  Write-Host "adb install -r $profileApk"
  Invoke-Adb @("install", "-r", $profileApk) | Out-Null
  $restoreRequired = $true
  $activity = Resolve-LaunchActivity

  $coldStartSamples = @()
  foreach ($iterationIndex in 0..5) {
    $coldStartSamples += Measure-ColdStart -Activity $activity
  }

  $warmResumeSamples = @()
  foreach ($iterationIndex in 0..5) {
    $warmResumeSamples += Measure-WarmResume -Activity $activity
  }

  $hostPath = Join-Path $rawRoot "host-latency.json"
  Write-HostLatencyRun `
    -Path $hostPath `
    -ColdStartSamples $coldStartSamples `
    -WarmResumeSamples $warmResumeSamples `
    -Commit $ProductCommit `
    -Device $deviceIdentity

  $responsePath = Join-Path $AppRoot "build\integration_response_data.json"
  if (Test-Path -LiteralPath $responsePath) {
    throw "Refusing to overwrite stale build\integration_response_data.json."
  }

  function Invoke-PerformanceRun {
    param(
      [Parameter(Mandatory = $true)][string]$PhaseDefine,
      [Parameter(Mandatory = $true)][string]$Destination,
      [string]$IterationDefine = ""
    )

    $flutterArguments = @(
      "drive",
      "--driver=test_driver/integration_test.dart",
      "--target=integration_test/phone_performance_test.dart",
      "--profile",
      "--no-dds",
      "--keep-app-running",
      "-d", $DeviceId,
      "--dart-define=DANIO_PRODUCT_COMMIT=$ProductCommit",
      "--dart-define=DANIO_PERF_DEVICE=$deviceIdentity",
      $PhaseDefine
    )
    if ($IterationDefine) {
      $flutterArguments += $IterationDefine
    }

    & flutter @flutterArguments
    if ($LASTEXITCODE -ne 0) {
      throw "Profile integration run failed with exit code $LASTEXITCODE."
    }
    if (-not (Test-Path -LiteralPath $responsePath -PathType Leaf)) {
      throw "Profile run produced no build\integration_response_data.json."
    }
    Move-Item -LiteralPath $responsePath -Destination $Destination
  }

  $rawFiles = @($hostPath)
  foreach ($imageIteration in 0..5) {
    $destination = Join-Path $rawRoot "image-$imageIteration.json"
    Invoke-PerformanceRun `
      -PhaseDefine "--dart-define=DANIO_PERF_PHASE=image" `
      -IterationDefine "--dart-define=DANIO_PERF_ITERATION=$imageIteration" `
      -Destination $destination
    $rawFiles += $destination
  }

  $interactionsPath = Join-Path $rawRoot "interactions.json"
  Invoke-PerformanceRun `
    -PhaseDefine "--dart-define=DANIO_PERF_PHASE=interactions" `
    -Destination $interactionsPath
  $rawFiles += $interactionsPath

  & dart run tool/summarize_phone_performance.dart `
    --output $OutputPath `
    @rawFiles
  $summaryExit = $LASTEXITCODE

  if ($summaryExit -ne 0) {
    throw "Phone performance budgets failed with exit code $summaryExit. Report: $OutputPath"
  }
}
catch {
  $runError = $_
}
finally {
  if ($restoreRequired -and $restoreProductApk) {
    try {
      Write-Host "Restoring product profile APK"
      Invoke-Adb @("install", "-r", $restoreProductApk) | Out-Null
    }
    catch {
      $restoreError = $_
    }
  }
  Pop-Location
}

if ($runError) {
  if ($restoreError) {
    Write-Warning "Product APK restoration also failed: $restoreError"
  }
  throw $runError
}
if ($restoreError) {
  throw "Product APK restoration failed: $restoreError"
}
