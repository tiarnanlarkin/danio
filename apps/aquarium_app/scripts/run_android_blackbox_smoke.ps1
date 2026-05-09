param(
  [string]$DeviceId = "",
  [string]$AppId = "com.tiarnanlarkin.danio",
  [string]$AdbPath = "",
  [string]$ArtifactDir = "build\qa-artifacts\android-blackbox",
  [string]$InstallApkPath = "",
  [string[]]$ForceStopPackageIds = @(),
  [switch]$KeepState,
  [switch]$IncludeQaDeepLinks,
  [switch]$ExercisePlatformHandoffs,
  [string]$QaLessonPathId = "nitrogen_cycle"
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
  try {
    Invoke-Adb @("shell", "am", "force-stop", $AppId) | Out-Null
    Invoke-Adb @("install", "-r", $apk) | Out-Host
  }
  catch {
    if ("$_" -notmatch "INSTALL_FAILED_UPDATE_INCOMPATIBLE") {
      throw
    }

    Write-Host "Existing package signature differs; uninstalling $AppId and retrying install..."
    Invoke-Adb @("uninstall", $AppId) | Out-Null
    Invoke-Adb @("install", $apk) | Out-Host
  }

  Invoke-Adb @("shell", "am", "force-stop", $AppId) | Out-Null
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

function Hide-SoftKeyboard {
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
  if ($ForceStopPackageIds -contains $package) {
    Invoke-Adb @("shell", "am", "force-stop", $package) | Out-Null
  }
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
      $nodes = $doc.SelectNodes("//*[@clickable='true' or @checkable='true' or @class='android.widget.Button']")
      foreach ($node in $nodes) {
        if ($node.GetAttribute("enabled") -ne "true") {
          continue
        }

        $label = "$($node.GetAttribute("content-desc")) $($node.GetAttribute("text")) $($node.GetAttribute("hint"))"
        if ($label -match $Pattern) {
          $tapNode = $node
          $checkboxChild = $node.SelectSingleNode(".//*[@class='android.widget.CheckBox' and @clickable='true' and @enabled='true']")
          if ($checkboxChild) {
            $tapNode = $checkboxChild
          }
          elseif ($node.GetAttribute("clickable") -ne "true") {
            $clickableChild = $node.SelectSingleNode(".//*[@clickable='true' and @enabled='true']")
            if ($clickableChild) {
              $tapNode = $clickableChild
            }
          }

          $center = Get-BoundsCenter $tapNode.GetAttribute("bounds")
          if ($tapNode.GetAttribute("class") -eq "android.widget.CheckBox") {
            $bounds = $tapNode.GetAttribute("bounds")
            if ($bounds -match "\[(\d+),(\d+)\]\[(\d+),(\d+)\]") {
              $left = [int]$Matches[1]
              $center.X = [int][math]::Min($center.X, $left + 96)
            }
          }
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

function Try-Assert-Visible {
  param(
    [string]$Pattern,
    [int]$TimeoutSeconds = 2
  )

  try {
    Assert-Visible $Pattern $TimeoutSeconds
    return $true
  }
  catch {
    return $false
  }
}

function Open-QaDeepLink {
  param([Parameter(Mandatory = $true)][string]$Uri)

  Write-Host "Opening QA deep link $Uri..."
  Invoke-Adb @(
    "shell",
    "am",
    "start",
    "-W",
    "-a",
    "android.intent.action.VIEW",
    "-d",
    $Uri,
    $AppId
  ) | Out-Host
  Wait-AppForeground
  Start-Sleep -Milliseconds 1200
}

function Check-QaDeepLinks {
  Write-Host "Checking debug QA deep links..."

  Open-QaDeepLink "danio://qa/settings"
  Assert-Visible "Preferences" 12
  Assert-Visible "Backup|Light/Dark Mode|Daily Goal" 12
  Press-Back
  Assert-Visible "More" 12

  Open-QaDeepLink "danio://qa/create-tank?name=Q"
  Assert-Visible "New Tank|Tank Name|Tank name" 12
  if (-not (Try-Assert-Visible "text=`"Q`"|49 characters remaining" 2)) {
    if (-not (Try-Tap-Visible "Tank Name|Tank name|Name" 2)) {
      Tap-Percent 50 28
    }
    Invoke-Adb @("shell", "input", "text", "Q") | Out-Null
    Start-Sleep -Milliseconds 700
  }
  Assert-Visible "text=`"Q`"|49 characters remaining" 6
  Hide-SoftKeyboard
  if (Try-Assert-Visible "Discard new tank\?" 1) {
    Tap-Visible "Cancel" 6
    Assert-Visible "New Tank|Tank Name|Tank name" 8
  }
  Tap-Visible "Close and discard new tank|Close" 8
  Assert-Visible "Discard new tank\?" 8
  Tap-Visible "Cancel" 6
  Assert-Visible "New Tank|Tank Name|Tank name" 8
  Tap-Visible "Close and discard new tank|Close" 8
  Assert-Visible "Discard new tank\?" 8
  Tap-Visible "Discard" 6
  Assert-Visible "More|Learning Paths|Tank Toolbox|Smart" 12

  Open-QaDeepLink "danio://qa/lesson/$QaLessonPathId"
  Assert-Visible "Question|Need a hint|Check Answer|Lesson|Nitrogen" 15

  if (Try-Tap-Visible "Need a hint|Show hint" 3) {
    Assert-Visible "Look for keywords|hint" 6
  }
  else {
    Write-Host "Lesson opened, but hint control was not visible in the current lesson state."
  }

  Press-Back

  Open-QaDeepLink "danio://qa/lesson-quiz?state=hint"
  Assert-Visible "QA Lesson Quiz" 12
  Assert-Visible "Need a hint\\?|Show hint" 12
  Tap-Visible "Need a hint\\?|Show hint" 8
  Assert-Visible "Look for keywords|Hint shown|correct answer often relates" 8
  Press-Back

  Open-QaDeepLink "danio://qa/lesson-quiz?state=selected-correct"
  Assert-Visible "QA Lesson Quiz" 12
  Assert-Visible "Selected answer [A-D], correct|Explanation:" 12
  Press-Back

  Open-QaDeepLink "danio://qa/practice-session?mode=due-mc"
  Assert-Visible "Practice Session" 20
  Assert-Visible "Card 1 of 1|Check Answer|Question" 12
  $practiceXml = Get-Hierarchy
  if (
    $practiceXml -match 'content-desc="Learn' -and
    $practiceXml -match 'content-desc="Tank' -and
    $practiceXml -match 'content-desc="Smart' -and
    $practiceXml -match 'content-desc="More'
  ) {
    throw "Bottom navigation is visible during seeded practice session."
  }
  Press-Back
  if (Try-Assert-Visible "Exit Session\\?" 3) {
    Tap-Visible "Exit" 6
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
  Invoke-Adb @("shell", "am", "force-stop", $AppId) | Out-Null
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
Assert-Visible "Practice Modes|Build your review deck|Start Review|Standard Review|All caught up" 12
if (Try-Tap-Visible "Standard Practice|Quick Review" 2) {
  Assert-Visible "Practice Session|Review this concept" 10
  if (Try-Tap-Visible "Exit Session" 2) {
    Tap-Visible "^Exit$" 5
  }
  else {
    Press-Back
    if (Try-Assert-Visible "Exit Session" 2) {
      Tap-Visible "^Exit$" 5
    }
  }
  Assert-Visible "Practice Modes|Build your review deck|Start Review|Standard Review|All caught up" 12
}
else {
  Write-Host "Practice session smoke skipped: no enabled review mode was visible."
}
Tap-Percent 50 92
Assert-Visible "Tank Toolbox" 12
Tap-Percent 70 92
Assert-Visible "Smart" 12
if (Try-Tap-Visible "Fish & Plant ID" 4) {
  Assert-Visible "Set up Smart Hub|Open Preferences" 8
  if (-not (Try-Tap-Visible "Not now" 2)) {
    Press-Back
  }
  Assert-Visible "Smart" 8
}
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
if (-not (Try-Assert-Visible "More" 2)) {
  Press-Back
}
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
Assert-Visible "Backup|Restore" 10
Assert-Visible "Export Data" 10
Assert-Visible "Import Data" 10
Assert-Visible "Export Backup.*ZIP|Go to Tank" 10
if ($ExercisePlatformHandoffs -and (Try-Tap-Visible "Export Backup.*ZIP" 2)) {
  Start-Sleep -Seconds 3
  $foregroundAfterExport = Get-ForegroundPackage
  Write-Host "Foreground package after export handoff: '$foregroundAfterExport'"
  if ($foregroundAfterExport -ne $AppId) {
    Bring-AppForeground
  }
  Assert-Visible "Backup|Restore|More" 12
}
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

if ($IncludeQaDeepLinks) {
  Check-QaDeepLinks
  Tap-Percent 90 92
  Assert-Visible "More" 12
}

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
