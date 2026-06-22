param(
  [string]$AvdName = "danio_api36",
  [string]$AppId = "com.tiarnanlarkin.danio",
  [string]$DeviceId = "",
  [string]$OutputRoot = "docs\qa\screenshots\live-preview",
  [switch]$AllowNotForeground,
  [int]$LogcatLines = 400
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ScriptPath = $MyInvocation.MyCommand.Path
$ScriptsDir = Split-Path -Parent $ScriptPath
$AppRoot = Split-Path -Parent $ScriptsDir

function Resolve-Tool {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [string[]]$FallbackPaths = @()
  )

  $command = Get-Command $Name -ErrorAction SilentlyContinue
  if ($command) {
    return $command.Source
  }

  foreach ($path in $FallbackPaths) {
    if ($path -and (Test-Path -LiteralPath $path)) {
      return (Resolve-Path -LiteralPath $path).Path
    }
  }

  throw "$Name was not found on PATH or in the expected local SDK paths."
}

$script:Adb = Resolve-Tool -Name "adb" -FallbackPaths @(
  (Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe")
)

function Invoke-Adb {
  param(
    [string]$Serial = "",
    [Parameter(Mandatory = $true)]
    [string[]]$Arguments
  )

  $base = @()
  if ($Serial) {
    $base += @("-s", $Serial)
  }

  $output = & $script:Adb @base @Arguments 2>&1
  if ($LASTEXITCODE -ne 0) {
    throw "adb $($Arguments -join ' ') failed for '$Serial': $($output -join ' ')"
  }
  return $output
}

function Get-ReadyDevices {
  $output = Invoke-Adb -Arguments @("devices")
  return @(
    $output |
      Select-Object -Skip 1 |
      Where-Object { $_ -match "^\S+\s+device$" } |
      ForEach-Object { ($_ -split "\s+")[0] }
  )
}

function Get-DeviceAvdName {
  param([Parameter(Mandatory = $true)][string]$Serial)

  try {
    $output = Invoke-Adb -Serial $Serial -Arguments @("emu", "avd", "name")
    return (
      $output |
        Where-Object { $_ -and $_.Trim() -and $_.Trim() -ne "OK" } |
        Select-Object -First 1
    ).Trim()
  }
  catch {
    return ""
  }
}

function Get-ForegroundPackage {
  param([Parameter(Mandatory = $true)][string]$Serial)

  $window = (Invoke-Adb -Serial $Serial -Arguments @("shell", "dumpsys", "window")) -join "`n"
  if ($window -match "mCurrentFocus=Window\{[^ ]+ [^ ]+ ([^/ ]+)/") {
    return $Matches[1]
  }
  if ($window -match "mFocusedApp=ActivityRecord\{[^ ]+ [^ ]+ ([^/ ]+)/") {
    return $Matches[1]
  }
  return ""
}

function Resolve-DanioDevice {
  $devices = Get-ReadyDevices
  if ($DeviceId) {
    if ($devices -notcontains $DeviceId) {
      throw "Requested device '$DeviceId' is not listed as ready."
    }
    return $DeviceId
  }

  $matches = @()
  foreach ($serial in $devices) {
    if ((Get-DeviceAvdName -Serial $serial) -eq $AvdName) {
      $matches += $serial
    }
  }

  if ($matches.Count -eq 1) {
    return $matches[0]
  }
  if ($matches.Count -gt 1) {
    throw "Multiple ready devices match AVD '$AvdName': $($matches -join ', '). Pass -DeviceId."
  }
  throw "No owned Danio device found for AVD '$AvdName'."
}

function Resolve-OutputRoot {
  $allowedRoot = [System.IO.Path]::GetFullPath(
    (Join-Path $AppRoot "docs\qa\screenshots\live-preview")
  )

  if ([System.IO.Path]::IsPathRooted($OutputRoot)) {
    $requestedRoot = [System.IO.Path]::GetFullPath($OutputRoot)
  }
  else {
    $requestedRoot = [System.IO.Path]::GetFullPath(
      (Join-Path $AppRoot $OutputRoot)
    )
  }

  $allowedPrefix = $allowedRoot.TrimEnd(
    [System.IO.Path]::DirectorySeparatorChar,
    [System.IO.Path]::AltDirectorySeparatorChar
  ) + [System.IO.Path]::DirectorySeparatorChar

  if (
    $requestedRoot -ne $allowedRoot -and
    -not $requestedRoot.StartsWith($allowedPrefix, [System.StringComparison]::OrdinalIgnoreCase)
  ) {
    throw "Refusing to write outside $allowedRoot."
  }

  return $requestedRoot
}

$device = Resolve-DanioDevice
$foregroundPackage = Get-ForegroundPackage -Serial $device
if (-not $AllowNotForeground -and $foregroundPackage -ne $AppId) {
  throw "Expected Danio foreground package '$AppId', but foreground package is '$foregroundPackage'."
}

$root = Resolve-OutputRoot
$day = Get-Date -Format "yyyy-MM-dd"
$timestamp = Get-Date -Format "HHmmss"
$outputDir = Join-Path $root $day
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

$screenPath = Join-Path $outputDir "screen-$timestamp.png"
$focusPath = Join-Path $outputDir "focus-$timestamp.txt"
$logcatPath = Join-Path $outputDir "logcat-$timestamp.txt"
$deviceScreenPath = "/sdcard/danio-live-preview-$timestamp.png"

Invoke-Adb -Serial $device -Arguments @("shell", "screencap", "-p", $deviceScreenPath) | Out-Null
Invoke-Adb -Serial $device -Arguments @("pull", $deviceScreenPath, $screenPath) | Out-Null
Invoke-Adb -Serial $device -Arguments @("shell", "rm", $deviceScreenPath) | Out-Null

$focus = Invoke-Adb -Serial $device -Arguments @("shell", "dumpsys", "window")
Set-Content -Path $focusPath -Value ($focus -join "`n") -Encoding UTF8

if ($LogcatLines -gt 0) {
  $logcat = Invoke-Adb -Serial $device -Arguments @("logcat", "-d", "-t", "$LogcatLines")
  Set-Content -Path $logcatPath -Value ($logcat -join "`n") -Encoding UTF8
}

Write-Host "Saved Danio screenshot evidence to $outputDir"
Write-Host $screenPath
