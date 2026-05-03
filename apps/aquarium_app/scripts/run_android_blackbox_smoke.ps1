param(
  [string]$DeviceId = "",
  [string]$AppId = "com.tiarnanlarkin.danio",
  [string]$AdbPath = "",
  [string]$ArtifactDir = "build\qa-artifacts\android-blackbox",
  [string]$InstallApkPath = "",
  [string[]]$ForceStopPackageIds = @(),
  [switch]$KeepState
)

$ErrorActionPreference = "Stop"

function Resolve-Adb {
  if ($AdbPath) {
    if (Test-Path $AdbPath) {
      return (Resolve-Path $AdbPath).Path
    }

    throw "adb not found at -AdbPath '$AdbPath'"
  }

  $command = Get-Command adb -ErrorAction SilentlyContinue
  if ($command) {
    return $command.Source
  }

  $sdkAdb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
  if (Test-Path $sdkAdb) {
    return $sdkAdb
  }

  throw "adb was not found. Add Android SDK platform-tools to PATH or pass -AdbPath."
}

$script:Adb = Resolve-Adb

function Invoke-Adb {
  param([Parameter(Mandatory = $true)][string[]]$AdbArgs)

  $base = @()
  if ($DeviceId) {
    $base += @("-s", $DeviceId)
  }

  $lastOutput = @()
  for ($attempt = 1; $attempt -le 4; $attempt++) {
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
      $lastOutput = & $script:Adb @base @AdbArgs 2>&1
      $exitCode = $LASTEXITCODE
    }
    finally {
      $ErrorActionPreference = $previousErrorActionPreference
    }

    if ($exitCode -eq 0) {
      return $lastOutput
    }

    if ($attempt -lt 4) {
      Start-Sleep -Milliseconds (500 * $attempt)
    }
  }

  $outputText = ($lastOutput | ForEach-Object { "$_" }) -join "`n"
  throw "adb failed: $($AdbArgs -join ' ')`n$outputText"
}

function Install-DebugApk {
  if (-not $InstallApkPath) {
    return
  }

  if (-not (Test-Path $InstallApkPath)) {
    throw "APK not found at -InstallApkPath '$InstallApkPath'"
  }

  $apk = (Resolve-Path $InstallApkPath).Path
  Write-Host "Installing debug APK $apk..."
  Invoke-Adb @("install", "-r", $apk) | Out-Host
}

function Stop-InterferingPackages {
  foreach ($packageId in $ForceStopPackageIds) {
    if (-not $packageId -or $packageId -eq $AppId) {
      continue
    }

    Write-Host "Force-stopping emulator package $packageId..."
    Invoke-Adb @("shell", "am", "force-stop", $packageId) | Out-Null
  }
}

function Get-ScreenSize {
  $raw = (Invoke-Adb @("shell", "wm", "size")) -join "`n"
  if ($raw -notmatch "(\d+)x(\d+)") {
    throw "Could not parse adb wm size output: $raw"
  }
  [pscustomobject]@{
    Width = [int]$Matches[1]
    Height = [int]$Matches[2]
  }
}

function Tap-Percent {
  param(
    [double]$X,
    [double]$Y
  )

  Ensure-AppForeground
  $px = [int][math]::Round($script:Screen.Width * $X / 100)
  $py = [int][math]::Round($script:Screen.Height * $Y / 100)
  Invoke-Adb @("shell", "input", "tap", "$px", "$py") | Out-Null
  Start-Sleep -Milliseconds 900
}

function Press-Back {
  Ensure-AppForeground
  Invoke-Adb @("shell", "input", "keyevent", "KEYCODE_BACK") | Out-Null
  Start-Sleep -Milliseconds 900
}

function Resolve-LaunchActivity {
  $resolved = Invoke-Adb @("shell", "cmd", "package", "resolve-activity", "--brief", $AppId)
  $activity = $resolved | Where-Object { $_ -match "/" } | Select-Object -Last 1
  if (-not $activity) {
    throw "Could not resolve launcher activity for $AppId. Output: $($resolved -join ' ')"
  }
  return $activity.Trim()
}

function Get-ForegroundPackage {
  $window = (Invoke-Adb @("shell", "dumpsys", "window")) -join "`n"
  if ($window -match "mCurrentFocus=Window\{[^ ]+ [^ ]+ ([^/ ]+)/") {
    return $Matches[1]
  }

  if ($window -match "mFocusedApp=ActivityRecord\{[^ ]+ [^ ]+ ([^/ ]+)/") {
    return $Matches[1]
  }

  return ""
}

function Wait-AppForeground {
  param([int]$TimeoutSeconds = 10)

  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  do {
    $package = Get-ForegroundPackage
    if ($package -eq $AppId) {
      return
    }

    Start-Sleep -Milliseconds 300
  } while ((Get-Date) -lt $deadline)

  throw "Expected $AppId to be foreground, but foreground package is '$(Get-ForegroundPackage)'."
}

function Bring-AppForeground {
  $activity = Resolve-LaunchActivity
  Invoke-Adb @(
    "shell",
    "am",
    "start",
    "-W",
    "-n",
    $activity
  ) | Out-Null
  Wait-AppForeground
}

function Start-App {
  Invoke-Adb @("shell", "am", "force-stop", $AppId) | Out-Null
  Start-Sleep -Milliseconds 300
  Bring-AppForeground
}

function Ensure-AppForeground {
  $package = Get-ForegroundPackage
  if ($package -eq $AppId) {
    return
  }

  Write-Host "Foreground package '$package' interrupted smoke; bringing $AppId back..."
  Bring-AppForeground
  Start-Sleep -Milliseconds 700
}

function Get-Hierarchy {
  $lastError = ""
  for ($attempt = 1; $attempt -le 6; $attempt++) {
    try {
      $dump = (Invoke-Adb @("exec-out", "uiautomator", "dump", "/dev/tty")) -join "`n"
      if ($dump -match "null root node") {
        throw "uiautomator dump returned null root node"
      }

      $start = $dump.IndexOf("<?xml")
      $end = $dump.LastIndexOf("</hierarchy>")
      if ($start -ge 0 -and $end -ge 0) {
        return $dump.Substring($start, $end + "</hierarchy>".Length - $start)
      }

      throw "uiautomator dump did not contain hierarchy XML"
    }
    catch {
      $lastError = "$_"
      Start-Sleep -Milliseconds 500
    }
  }

  throw "uiautomator dump failed after retries: $lastError"
}

function Assert-Visible {
  param(
    [string]$Pattern,
    [int]$TimeoutSeconds = 6
  )

  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  do {
    Ensure-AppForeground
    $xml = Get-Hierarchy
    if ($xml -match $Pattern) {
      return
    }

    Start-Sleep -Milliseconds 300
  } while ((Get-Date) -lt $deadline)

  if ($TimeoutSeconds -gt 0) {
    throw "Expected UI pattern not visible within $TimeoutSeconds seconds: $Pattern"
  }

  throw "Expected UI pattern not visible: $Pattern"
}

function Wait-FirstVisibleAppState {
  param([int]$TimeoutSeconds = 35)

  $patterns = @(
    "Your Privacy Matters",
    "Learning Paths",
    "Build your review deck|Start Review|Standard Review|All caught up",
    "Tank Toolbox",
    "Smart",
    "More",
    "Your fish deserve better|Let's get started|Skip setup",
    "Welcome|Name your tank|Tank type"
  )

  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  do {
    Ensure-AppForeground
    $xml = Get-Hierarchy
    foreach ($pattern in $patterns) {
      if ($xml -match $pattern) {
        return $pattern
      }
    }

    Start-Sleep -Milliseconds 300
  } while ((Get-Date) -lt $deadline)

  throw "No expected first app state visible within $TimeoutSeconds seconds."
}

function Try-WaitFirstVisibleAppState {
  param([int]$TimeoutSeconds = 2)

  try {
    return Wait-FirstVisibleAppState $TimeoutSeconds
  }
  catch {
    return ""
  }
}

function Get-BoundsCenter {
  param([Parameter(Mandatory = $true)][string]$Bounds)

  if ($Bounds -notmatch "\[(\d+),(\d+)\]\[(\d+),(\d+)\]") {
    throw "Could not parse UI bounds: $Bounds"
  }

  [pscustomobject]@{
    X = [int][math]::Round(([int]$Matches[1] + [int]$Matches[3]) / 2)
    Y = [int][math]::Round(([int]$Matches[2] + [int]$Matches[4]) / 2)
  }
}

function Tap-Visible {
  param(
    [string]$Pattern,
    [int]$TimeoutSeconds = 6
  )

  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  do {
    Ensure-AppForeground
    $hierarchy = Get-Hierarchy

    try {
      [xml]$doc = $hierarchy
      $nodes = $doc.SelectNodes("//*[@clickable='true']")
      foreach ($node in $nodes) {
        if ($node.GetAttribute("enabled") -ne "true") {
          continue
        }

        $label = "$($node.GetAttribute("content-desc")) $($node.GetAttribute("text"))"
        if ($label -match $Pattern) {
          $tapNode = $node
          $checkboxChild = $node.SelectSingleNode(".//*[@class='android.widget.CheckBox' and @clickable='true' and @enabled='true']")
          if ($checkboxChild) {
            $tapNode = $checkboxChild
          }

          $center = Get-BoundsCenter $tapNode.GetAttribute("bounds")
          Invoke-Adb @("shell", "input", "tap", "$($center.X)", "$($center.Y)") | Out-Null
          Start-Sleep -Milliseconds 900
          return
        }
      }
    }
    catch {
      if ($hierarchy -match $Pattern) {
        throw "Visible UI pattern found but clickable bounds could not be parsed: $Pattern"
      }
    }

    Start-Sleep -Milliseconds 300
  } while ((Get-Date) -lt $deadline)

  throw "Clickable UI pattern not visible within $TimeoutSeconds seconds: $Pattern"
}

function Try-Tap-Visible {
  param(
    [string]$Pattern,
    [int]$TimeoutSeconds = 2
  )

  try {
    Tap-Visible $Pattern $TimeoutSeconds
    return $true
  }
  catch {
    return $false
  }
}

function Open-ToolAndReturn {
  param(
    [string]$TapPattern,
    [string]$ExpectedPattern
  )

  Assert-Visible "Workshop|Tools.*calculators" 10
  Tap-Visible $TapPattern 20
  Assert-Visible $ExpectedPattern 10
  Press-Back
  Assert-Visible "Workshop|Tools.*calculators" 10
  Start-Sleep -Milliseconds 1800
}

function Save-FailureArtifacts {
  param([string]$Reason)

  $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
  $dir = Join-Path $ArtifactDir $timestamp
  New-Item -ItemType Directory -Force -Path $dir | Out-Null

  Set-Content -Path (Join-Path $dir "failure.txt") -Value $Reason -Encoding UTF8

  try {
    $screenshotDevicePath = "/sdcard/danio-blackbox-failure.png"
    Invoke-Adb @("shell", "screencap", "-p", $screenshotDevicePath) | Out-Null
    Invoke-Adb @("pull", $screenshotDevicePath, (Join-Path $dir "screen.png")) | Out-Null
  }
  catch {
    Set-Content -Path (Join-Path $dir "screen-error.txt") -Value "$_" -Encoding UTF8
  }

  try {
    Set-Content -Path (Join-Path $dir "window.xml") -Value (Get-Hierarchy) -Encoding UTF8
  }
  catch {
    Set-Content -Path (Join-Path $dir "window-error.txt") -Value "$_" -Encoding UTF8
  }

  try {
    $logcat = (Invoke-Adb @("logcat", "-d", "-t", "5000")) -join "`n"
    Set-Content -Path (Join-Path $dir "logcat.txt") -Value $logcat -Encoding UTF8
  }
  catch {
    Set-Content -Path (Join-Path $dir "logcat-error.txt") -Value "$_" -Encoding UTF8
  }

  Write-Host "Saved failure artifacts to $dir"
}

try {
Write-Host "Checking Android device..."
Invoke-Adb @("devices") | Out-Host
Install-DebugApk
Stop-InterferingPackages
$script:Screen = Get-ScreenSize
Write-Host "Using screen size $($script:Screen.Width)x$($script:Screen.Height)"

if (-not $KeepState) {
  Write-Host "Clearing app state for fresh-install smoke..."
  Invoke-Adb @("shell", "pm", "clear", $AppId) | Out-Null
}

Invoke-Adb @("logcat", "-c") | Out-Null
Start-App
$firstState = Wait-FirstVisibleAppState

if ((-not $KeepState) -and $firstState -match "Your Privacy Matters") {
  Tap-Visible "Age confirmation checkbox" 10
  Tap-Visible "Terms of Service and Privacy Policy acceptance checkbox" 10
  $deadline = (Get-Date).AddSeconds(8)
  do {
    $candidateState = Try-WaitFirstVisibleAppState 2
    if ($candidateState) {
      $firstState = $candidateState
      if ($firstState -notmatch "Your Privacy Matters") {
        break
      }
    }

    if (Try-Tap-Visible "No Thanks|Accept Analytics" 1) {
      Start-Sleep -Seconds 2
      $firstState = Wait-FirstVisibleAppState
      break
    }

    Start-Sleep -Milliseconds 300
  } while ((Get-Date) -lt $deadline)

  if ($firstState -match "Your Privacy Matters") {
    throw "Consent controls did not advance past the privacy screen."
  }
}

if ((-not $KeepState) -and $firstState -match "Your fish deserve better|Let's get started|Skip setup") {
  Tap-Visible "Skip setup, explore first|Skip setup, I'll explore first"
  Start-Sleep -Seconds 2
  $firstState = Wait-FirstVisibleAppState
}

Assert-Visible "Learning Paths|Tank Toolbox|Smart|More|Build your review deck|Start Review"

Write-Host "Checking bottom tabs..."
Tap-Percent 30 92
Assert-Visible "Build your review deck|Start Review|Standard Review|All caught up" 12
Tap-Percent 50 92
Assert-Visible "Tank Toolbox" 12
Tap-Percent 70 92
Assert-Visible "Smart" 12
Tap-Percent 90 92
Assert-Visible "More" 12

Write-Host "Checking Workshop routes..."
Tap-Visible "Workshop" 10
Assert-Visible "Workshop|Tools.*calculators" 12
Start-Sleep -Milliseconds 1800

Open-ToolAndReturn "Water Change" "Water Change Calculator"
Open-ToolAndReturn "Stocking" "Stocking"
Open-ToolAndReturn "CO. Calculator" "CO. Calculator|Calculator"
Open-ToolAndReturn "Dosing" "Dosing"
Open-ToolAndReturn "Unit Converter" "Unit Converter"
Open-ToolAndReturn "Tank Volume" "Tank Volume"
Open-ToolAndReturn "Lighting" "Lighting"
Open-ToolAndReturn "Compatibility" "Compatibility"

Write-Host "Checking More hub routes..."
Press-Back
Assert-Visible "More"
Start-Sleep -Milliseconds 1800

Tap-Visible "Trophy Case|Achievements"
Assert-Visible "Trophy Case|Achievements"
Press-Back
Assert-Visible "More"
Start-Sleep -Milliseconds 1800

Tap-Visible "Preferences|Settings"
Assert-Visible "Preferences|Settings"
Press-Back
Assert-Visible "More"
Start-Sleep -Milliseconds 1800

Invoke-Adb @("shell", "input", "swipe", "540", "1900", "540", "1100", "500") | Out-Null
Start-Sleep -Milliseconds 1200
Assert-Visible "Backup"
Tap-Visible "Backup"
Assert-Visible "Backup|Restore"
Press-Back
Assert-Visible "More"
Start-Sleep -Milliseconds 1800

Tap-Visible "About|Version"
Assert-Visible "About|Version"
Invoke-Adb @("shell", "input", "swipe", "540", "1900", "540", "700", "500") | Out-Null
Start-Sleep -Milliseconds 1200

Tap-Visible "Privacy"
Assert-Visible "Privacy Policy"
Press-Back
Assert-Visible "About|Version"
Start-Sleep -Milliseconds 1200

Tap-Visible "Terms"
Assert-Visible "Terms|Terms of Service"
Press-Back
Assert-Visible "About|Version"
Start-Sleep -Milliseconds 1200

Press-Back
Assert-Visible "More"

Write-Host "Checking logcat for crash signatures..."
$logcat = (Invoke-Adb @("logcat", "-d", "-t", "5000")) -join "`n"
$fatalPattern = "FATAL EXCEPTION|AndroidRuntime: FATAL|ANR in|Missing type parameter|MethodChannel#dexterous\.com/flutter/local_notifications"
if ($logcat -match $fatalPattern) {
  $matches = ($logcat -split "`n") | Select-String -Pattern $fatalPattern
  $matches | Select-Object -First 20 | ForEach-Object { Write-Host $_.Line }
  throw "Crash/error signature found in logcat."
}

Write-Host "Android black-box smoke passed."
}
catch {
  Save-FailureArtifacts "$_"
  throw
}
