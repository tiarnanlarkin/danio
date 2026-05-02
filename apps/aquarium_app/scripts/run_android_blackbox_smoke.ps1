param(
  [string]$DeviceId = "",
  [string]$AppId = "com.tiarnanlarkin.danio",
  [string]$AdbPath = "",
  [string]$ArtifactDir = "build\qa-artifacts\android-blackbox",
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

  & $script:Adb @base @AdbArgs
  if ($LASTEXITCODE -ne 0) {
    throw "adb failed: $($AdbArgs -join ' ')"
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

  $px = [int][math]::Round($script:Screen.Width * $X / 100)
  $py = [int][math]::Round($script:Screen.Height * $Y / 100)
  Invoke-Adb @("shell", "input", "tap", "$px", "$py") | Out-Null
  Start-Sleep -Milliseconds 900
}

function Press-Back {
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

function Start-App {
  $activity = Resolve-LaunchActivity
  Invoke-Adb @(
    "shell",
    "am",
    "start",
    "-W",
    "-n",
    $activity
  ) | Out-Null
}

function Get-Hierarchy {
  Invoke-Adb @("shell", "uiautomator", "dump", "/sdcard/danio-window.xml") | Out-Null
  (Invoke-Adb @("exec-out", "cat", "/sdcard/danio-window.xml")) -join "`n"
}

function Assert-Visible {
  param(
    [string]$Pattern,
    [int]$TimeoutSeconds = 6
  )

  $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
  do {
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
    $hierarchy = Get-Hierarchy

    try {
      [xml]$doc = $hierarchy
      $nodes = $doc.SelectNodes("//*[@clickable='true']")
      foreach ($node in $nodes) {
        $label = "$($node.GetAttribute("content-desc")) $($node.GetAttribute("text"))"
        if ($label -match $Pattern) {
          $center = Get-BoundsCenter $node.GetAttribute("bounds")
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

function Open-ToolAndReturn {
  param(
    [string]$TapPattern,
    [string]$ExpectedPattern
  )

  Tap-Visible $TapPattern
  Assert-Visible $ExpectedPattern
  Press-Back
  Assert-Visible "Tools &amp; calculators|Tools & calculators"
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
$script:Screen = Get-ScreenSize
Write-Host "Using screen size $($script:Screen.Width)x$($script:Screen.Height)"

if (-not $KeepState) {
  Write-Host "Clearing app state for fresh-install smoke..."
  Invoke-Adb @("shell", "pm", "clear", $AppId) | Out-Null
}

Invoke-Adb @("logcat", "-c") | Out-Null
Start-App
Start-Sleep -Seconds 4

if (-not $KeepState) {
  Assert-Visible "Your Privacy Matters"
  Tap-Percent 11 49
  Tap-Percent 11 59
  Tap-Percent 50 88
  Start-Sleep -Seconds 2
  Tap-Percent 50 91
  Start-Sleep -Seconds 2
}

Assert-Visible "Learning Paths"

Write-Host "Checking bottom tabs..."
Tap-Percent 30 92
Assert-Visible "Practice Modes"
Tap-Percent 50 92
Assert-Visible "Tank Toolbox"
Tap-Percent 70 92
Assert-Visible "Smart"
Tap-Percent 90 92
Assert-Visible "More"

Write-Host "Checking Workshop routes..."
Tap-Visible "Workshop"
Assert-Visible "Tools &amp; calculators|Tools & calculators"
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
