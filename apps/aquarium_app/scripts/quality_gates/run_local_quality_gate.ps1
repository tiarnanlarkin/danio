[CmdletBinding()]
param(
  [ValidateSet("Focused", "Docs", "Full", "Visual", "AndroidPrep")]
  [string]$Profile = "Focused",

  [string[]]$FocusedTests = @(
    "test/copy/current_docs_local_truth_test.dart",
    "test/quality/content_validation_test.dart",
    "test/scripts/local_quality_gate_script_test.dart"
  ),

  [switch]$SkipApkBuild,
  [switch]$RunAndroidSmoke,
  [switch]$RunPatrolSmoke,
  [string]$PatrolDeviceId = "",
  [string]$PatrolTarget = "integration_test/smoke_test.dart",
  [string]$PatrolPackageName = "com.tiarnanlarkin.danio",
  [switch]$PatrolUninstall,
  [switch]$RunOptionalTools,
  [switch]$StrictOptionalTools,
  [switch]$RequireCleanWorktree
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$script:Failures = New-Object System.Collections.Generic.List[string]
$script:Warnings = New-Object System.Collections.Generic.List[string]

$ScriptPath = $MyInvocation.MyCommand.Path
$QualityGateDir = Split-Path -Parent $ScriptPath
$ScriptsDir = Split-Path -Parent $QualityGateDir
$AppRoot = Split-Path -Parent $ScriptsDir
$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $AppRoot "..\..")).Path

$GoldenTests = @(
  "test/golden_tests/mc_card_golden_test.dart",
  "test/golden_tests/empty_room_scene_golden_test.dart"
)

function Add-Failure {
  param([string]$Message)

  $script:Failures.Add($Message) | Out-Null
  Write-Host "FAIL: $Message" -ForegroundColor Red
}

function Add-WarningMessage {
  param([string]$Message)

  $script:Warnings.Add($Message) | Out-Null
  Write-Warning $Message
}

function Invoke-Step {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [scriptblock]$Command,

    [string]$WorkingDirectory = $AppRoot,

    [switch]$Optional
  )

  Write-Host ""
  Write-Host "==> $Name"
  Push-Location -LiteralPath $WorkingDirectory
  try {
    $global:LASTEXITCODE = 0
    & $Command

    if ($global:LASTEXITCODE -ne 0) {
      throw "exit code $global:LASTEXITCODE"
    }

    Write-Host "PASS: $Name" -ForegroundColor Green
  } catch {
    $message = "$Name - $($_.Exception.Message)"
    if ($Optional -and -not $StrictOptionalTools) {
      Add-WarningMessage $message
    } else {
      Add-Failure $message
    }
  } finally {
    Pop-Location
  }
}

function Invoke-Flutter {
  param([string[]]$Arguments)

  & flutter @Arguments
  if ($global:LASTEXITCODE -ne 0) {
    throw "flutter $($Arguments -join ' ') failed with exit code $global:LASTEXITCODE"
  }
}

function Resolve-AdbCommand {
  $command = Get-Command adb -ErrorAction SilentlyContinue
  if ($command) {
    return $command.Source
  }

  $sdkAdb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
  if (Test-Path -LiteralPath $sdkAdb) {
    return $sdkAdb
  }

  throw "adb is not available on PATH or at the default Android SDK location."
}

function Resolve-PatrolCommand {
  $command = Get-Command patrol -ErrorAction SilentlyContinue
  if ($command) {
    return $command.Source
  }

  $pubCachePatrol = Join-Path $env:LOCALAPPDATA "Pub\Cache\bin\patrol.bat"
  if (Test-Path -LiteralPath $pubCachePatrol) {
    return $pubCachePatrol
  }

  throw "patrol was not found. Install with: dart pub global activate patrol_cli"
}

function Resolve-OsvScannerCommand {
  $command = Get-Command osv-scanner -ErrorAction SilentlyContinue
  if ($command) {
    return $command.Source
  }

  $wingetPackagesRoot = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages"
  if (Test-Path -LiteralPath $wingetPackagesRoot) {
    $wingetMatches = @(
      Get-ChildItem -LiteralPath $wingetPackagesRoot -Directory -Filter "Google.OSVScanner_*" -ErrorAction SilentlyContinue |
        ForEach-Object { Join-Path $_.FullName "osv-scanner.exe" } |
        Where-Object { Test-Path -LiteralPath $_ } |
        Sort-Object
    )

    if ($wingetMatches.Count -gt 0) {
      return $wingetMatches[-1]
    }
  }

  throw "osv-scanner was not found. Install locally with: winget install --exact --id Google.OSVScanner"
}

function Get-AndroidDeviceIds {
  $adb = Resolve-AdbCommand
  $output = & $adb devices
  if ($global:LASTEXITCODE -ne 0) {
    throw "adb devices failed with exit code $global:LASTEXITCODE"
  }

  return @(
    $output |
      Select-Object -Skip 1 |
      Where-Object { $_ -match "^\S+\s+device$" } |
      ForEach-Object { ($_ -split "\s+")[0] }
  )
}

function Resolve-PatrolDeviceId {
  if ($PatrolDeviceId) {
    return $PatrolDeviceId
  }

  $devices = @(Get-AndroidDeviceIds)
  if ($devices.Count -eq 1) {
    return $devices[0]
  }

  if ($devices.Count -eq 0) {
    throw "No ready Android device found for Patrol. Start an emulator or pass -PatrolDeviceId."
  }

  throw "Multiple Android devices found for Patrol: $($devices -join ', '). Pass -PatrolDeviceId to avoid cross-session emulator conflicts."
}

function Remove-GeneratedDirectory {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [string]$AllowedRoot = $AppRoot
  )

  if (-not (Test-Path -LiteralPath $Path)) {
    return
  }

  $resolvedRoot = (Resolve-Path -LiteralPath $AllowedRoot).Path
  $resolvedPath = (Resolve-Path -LiteralPath $Path).Path
  $guard = $resolvedRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
  if (-not $resolvedPath.StartsWith($guard, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to remove generated path outside app root: $resolvedPath"
  }

  $links = @(Get-ChildItem -LiteralPath $resolvedPath -Force -Recurse -Attributes ReparsePoint -ErrorAction SilentlyContinue)
  foreach ($link in $links) {
    if (-not $link.FullName.StartsWith($guard, [System.StringComparison]::OrdinalIgnoreCase)) {
      throw "Refusing to remove generated link outside app root: $($link.FullName)"
    }
    [System.IO.Directory]::Delete($link.FullName, $false)
  }

  try {
    Remove-Item -LiteralPath $resolvedPath -Force -Recurse -ErrorAction Stop
  } catch {
    $emptyDir = Join-Path ([System.IO.Path]::GetTempPath()) "danio_empty_dir_for_cleanup"
    if (-not (Test-Path -LiteralPath $emptyDir)) {
      New-Item -ItemType Directory -Path $emptyDir | Out-Null
    }

    & robocopy $emptyDir $resolvedPath /MIR /R:0 /W:0 /NFL /NDL /NJH /NJS /NP
    if ($global:LASTEXITCODE -gt 7) {
      throw "robocopy cleanup failed for $resolvedPath with exit code $global:LASTEXITCODE"
    }

    Remove-Item -LiteralPath $resolvedPath -Force -ErrorAction Stop
  }
}

function Clear-CustomLintGeneratedOutputs {
  $paths = @(
    "build",
    "android\app\mnt",
    "linux\flutter\ephemeral",
    "macos\Flutter\ephemeral",
    "windows\flutter\ephemeral"
  )

  foreach ($relativePath in $paths) {
    Remove-GeneratedDirectory -Path (Join-Path $AppRoot $relativePath)
  }
}

function New-CustomLintWorkingRoot {
  $lintRoot = Join-Path ([System.IO.Path]::GetTempPath()) "danio_aquarium_lint_root"
  if (Test-Path -LiteralPath $lintRoot) {
    $existing = Get-Item -LiteralPath $lintRoot -Force
    if (-not ($existing.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
      throw "Temporary lint path exists and is not a reparse point: $lintRoot"
    }
    [System.IO.Directory]::Delete($lintRoot, $false)
  }

  New-Item -ItemType Junction -Path $lintRoot -Target $AppRoot | Out-Null
  return $lintRoot
}

function Remove-CustomLintWorkingRoot {
  param([string]$LintRoot)

  if (-not (Test-Path -LiteralPath $LintRoot)) {
    return
  }

  $existing = Get-Item -LiteralPath $LintRoot -Force
  if ($existing.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
    [System.IO.Directory]::Delete($LintRoot, $false)
  }
}

function Invoke-FocusedTests {
  Invoke-Step -Name "Focused Flutter tests" -Command {
    Invoke-Flutter -Arguments (@("test") + $FocusedTests + @("--reporter", "compact"))
  }
}

function Invoke-FullTests {
  Invoke-Step -Name "Full Flutter test suite" -Command {
    Invoke-Flutter -Arguments @("test", "--reporter", "compact")
  }
}

function Invoke-Analyze {
  Invoke-Step -Name "Flutter analyze" -Command {
    Invoke-Flutter -Arguments @("analyze")
  }
}

function Invoke-CustomLint {
  Invoke-Step -Name "Danio custom lint" -Command {
    Clear-CustomLintGeneratedOutputs
    $lintRoot = New-CustomLintWorkingRoot
    try {
      Push-Location -LiteralPath $lintRoot
      & dart run custom_lint
      if ($global:LASTEXITCODE -ne 0) {
        throw "dart run custom_lint failed with exit code $global:LASTEXITCODE"
      }
    } finally {
      Pop-Location
      Remove-CustomLintWorkingRoot -LintRoot $lintRoot
    }
  }
}

function Invoke-DebugApkBuild {
  if ($SkipApkBuild) {
    Add-WarningMessage "Skipping debug APK build because -SkipApkBuild was supplied."
    return
  }

  Invoke-Step -Name "Debug APK build" -Command {
    Invoke-Flutter -Arguments @("build", "apk", "--debug", "--target", "lib/main.dart")
  }
}

function Invoke-GoldenTests {
  Invoke-Step -Name "Focused golden tests" -Command {
    Invoke-Flutter -Arguments (@("test") + $GoldenTests + @("--reporter", "compact"))
  }
}

function Invoke-OptionalTool {
  param(
    [Parameter(Mandatory = $true)]
    [string]$CommandName,

    [Parameter(Mandatory = $true)]
    [string[]]$Arguments,

    [string]$WorkingDirectory = $AppRoot
  )

  if (-not (Get-Command $CommandName -ErrorAction SilentlyContinue)) {
    $message = "Optional tool not installed: $CommandName"
    if ($StrictOptionalTools) {
      Add-Failure $message
    } else {
      Add-WarningMessage $message
    }
    return
  }

  Invoke-Step -Name "Optional $CommandName" -WorkingDirectory $WorkingDirectory -Optional -Command {
    & $CommandName @Arguments
    if ($global:LASTEXITCODE -ne 0) {
      throw "$CommandName $($Arguments -join ' ') failed with exit code $global:LASTEXITCODE"
    }
  }
}

function Invoke-OptionalTools {
  if (-not $RunOptionalTools) {
    return
  }

  Invoke-Step -Name "Optional osv-scanner" -Optional -Command {
    $osvScanner = Resolve-OsvScannerCommand
    $arguments = @("scan", "source", "--format=vertical", "--verbosity=error", "--recursive", ".")
    & $osvScanner @arguments
    if ($global:LASTEXITCODE -ne 0) {
      throw "osv-scanner $($arguments -join ' ') failed with exit code $global:LASTEXITCODE"
    }
  }
  # Optional DCM Pro path: dcm analyze lib
  Invoke-OptionalTool -CommandName "dcm" -Arguments @("analyze", "lib")
  Invoke-OptionalTool -CommandName "cspell" -Arguments @("--config", ".cspell.json", "--no-progress", "docs/agent", "docs/design")
  Invoke-OptionalTool -CommandName "vale" -Arguments @("docs")
}

function Invoke-AndroidDeviceVisibility {
  Invoke-Step -Name "Android device visibility" -Optional -Command {
    $adb = Resolve-AdbCommand
    & $adb devices
    if ($global:LASTEXITCODE -ne 0) {
      throw "adb devices failed with exit code $global:LASTEXITCODE"
    }
  }
}

function Invoke-AndroidSmoke {
  if (-not $RunAndroidSmoke) {
    return
  }

  Invoke-Step -Name "Android blackbox smoke" -Command {
    $smokeScript = Join-Path $AppRoot "scripts/run_android_blackbox_smoke.ps1"
    & powershell -NoProfile -ExecutionPolicy Bypass -File $smokeScript
    if ($global:LASTEXITCODE -ne 0) {
      throw "scripts/run_android_blackbox_smoke.ps1 failed with exit code $global:LASTEXITCODE"
    }
  }
}

function Invoke-PatrolSmoke {
  if (-not $RunPatrolSmoke) {
    return
  }

  Invoke-Step -Name "Patrol Android smoke" -Command {
    $patrol = Resolve-PatrolCommand
    $deviceId = Resolve-PatrolDeviceId
    $previousAnalytics = $env:PATROL_ANALYTICS_ENABLED
    $env:PATROL_ANALYTICS_ENABLED = "false"

    $arguments = @(
      "test",
      "-t",
      $PatrolTarget,
      "--device",
      $deviceId,
      "--package-name",
      $PatrolPackageName
    )

    if ($PatrolUninstall) {
      $arguments += "--uninstall"
    } else {
      $arguments += "--no-uninstall"
    }

    try {
      Write-Host "patrol test -t $PatrolTarget --device $deviceId --package-name $PatrolPackageName"
      & $patrol @arguments
      if ($global:LASTEXITCODE -ne 0) {
        throw "patrol test failed with exit code $global:LASTEXITCODE"
      }
    } finally {
      $env:PATROL_ANALYTICS_ENABLED = $previousAnalytics
    }
  }
}

Write-Host "Danio local quality gate"
Write-Host "Profile: $Profile"
Write-Host "Repo root: $RepoRoot"
Write-Host "App root: $AppRoot"

Invoke-Step -Name "Worktree visibility" -WorkingDirectory $RepoRoot -Command {
  $dirtyStatus = & git status --short -uall
  if ($global:LASTEXITCODE -ne 0) {
    throw "git status --short -uall failed with exit code $global:LASTEXITCODE"
  }

  if ($dirtyStatus) {
    Write-Host $dirtyStatus
    if ($RequireCleanWorktree) {
      throw "RequireCleanWorktree was supplied and the worktree is dirty."
    }
  } else {
    Write-Host "Worktree is clean."
  }
}

Invoke-Step -Name "Whitespace diff check" -WorkingDirectory $RepoRoot -Command {
  & git diff --check
  if ($global:LASTEXITCODE -ne 0) {
    throw "git diff --check failed with exit code $global:LASTEXITCODE"
  }
}

switch ($Profile) {
  "Focused" {
    Invoke-FocusedTests
  }
  "Docs" {
    Invoke-FocusedTests
    Invoke-CustomLint
    Invoke-Analyze
  }
  "Full" {
    Invoke-FocusedTests
    Invoke-CustomLint
    Invoke-FullTests
    Invoke-Analyze
    Invoke-DebugApkBuild
  }
  "Visual" {
    Invoke-FocusedTests
    Invoke-CustomLint
    Invoke-GoldenTests
    Invoke-Analyze
  }
  "AndroidPrep" {
    Invoke-FocusedTests
    Invoke-CustomLint
    Invoke-Analyze
    Invoke-DebugApkBuild
    Invoke-AndroidDeviceVisibility
  }
}

Invoke-AndroidSmoke
Invoke-PatrolSmoke
Invoke-OptionalTools

Write-Host ""
if ($script:Warnings.Count -gt 0) {
  Write-Host "Warnings:"
  foreach ($warning in $script:Warnings) {
    Write-Host "- $warning"
  }
}

if ($script:Failures.Count -gt 0) {
  Write-Host "Failures:"
  foreach ($failure in $script:Failures) {
    Write-Host "- $failure"
  }
  exit 1
}

Write-Host "Local quality gate passed." -ForegroundColor Green
exit 0
