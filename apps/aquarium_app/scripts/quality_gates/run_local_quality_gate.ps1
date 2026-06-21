[CmdletBinding()]
param(
  [ValidateSet("Focused", "Docs", "Full", "Visual", "AndroidPrep")]
  [string]$Profile = "Focused",

  [string[]]$FocusedTests = @(
    "test/copy/current_docs_local_truth_test.dart",
    "test/scripts/local_quality_gate_script_test.dart"
  ),

  [switch]$SkipApkBuild,
  [switch]$RunAndroidSmoke,
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

  Invoke-OptionalTool -CommandName "osv-scanner" -Arguments @("--offline", "--recursive", ".")
  Invoke-OptionalTool -CommandName "dcm" -Arguments @("analyze", ".")
  Invoke-OptionalTool -CommandName "cspell" -Arguments @(".")
  Invoke-OptionalTool -CommandName "vale" -Arguments @("docs")
}

function Invoke-AndroidDeviceVisibility {
  Invoke-Step -Name "Android device visibility" -Optional -Command {
    if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
      throw "adb is not available on PATH"
    }

    & adb devices
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
    Invoke-Analyze
  }
  "Full" {
    Invoke-FocusedTests
    Invoke-FullTests
    Invoke-Analyze
    Invoke-DebugApkBuild
  }
  "Visual" {
    Invoke-FocusedTests
    Invoke-GoldenTests
    Invoke-Analyze
  }
  "AndroidPrep" {
    Invoke-FocusedTests
    Invoke-Analyze
    Invoke-DebugApkBuild
    Invoke-AndroidDeviceVisibility
  }
}

Invoke-AndroidSmoke
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
