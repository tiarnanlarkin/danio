[CmdletBinding()]
param(
  [ValidateSet("Summary", "Firebase", "BrowserStack", "Percy", "All")]
  [string]$Target = "Summary",

  [switch]$RequireReady,
  [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptPath = $MyInvocation.MyCommand.Path
$QualityGateDir = Split-Path -Parent $ScriptPath
$ScriptsDir = Split-Path -Parent $QualityGateDir
$AppRoot = Split-Path -Parent $ScriptsDir
$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $AppRoot "..\..")).Path

$script:Checks = New-Object System.Collections.Generic.List[object]

function Test-CommandAvailable {
  param([Parameter(Mandatory = $true)][string]$Name)
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Test-EnvPresent {
  param([Parameter(Mandatory = $true)][string]$Name)
  $value = [System.Environment]::GetEnvironmentVariable($Name)
  return -not [string]::IsNullOrWhiteSpace($value)
}

function Test-RelativePath {
  param([Parameter(Mandatory = $true)][string]$RelativePath)
  return Test-Path -LiteralPath (Join-Path $AppRoot $RelativePath)
}

function Add-Check {
  param(
    [Parameter(Mandatory = $true)][string]$Area,
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)][bool]$Ready,
    [Parameter(Mandatory = $true)][string]$Detail,
    [bool]$Required = $true
  )

  $script:Checks.Add([pscustomobject]@{
    Area = $Area
    Name = $Name
    Ready = $Ready
    Required = $Required
    Detail = $Detail
  }) | Out-Null
}

function Include-Target {
  param([Parameter(Mandatory = $true)][string]$Name)
  return $Target -eq "All" -or $Target -eq "Summary" -or $Target -eq $Name
}

function Add-LocalArtifactChecks {
  param([Parameter(Mandatory = $true)][string]$Area)

  Add-Check `
    -Area $Area `
    -Name "Debug APK artifact" `
    -Ready (Test-RelativePath "build\app\outputs\flutter-apk\app-debug.apk") `
    -Detail "Expected after AndroidPrep: build/app/outputs/flutter-apk/app-debug.apk"
}

if (Include-Target "Firebase") {
  Add-Check `
    -Area "Firebase" `
    -Name "Android Firebase config" `
    -Ready (Test-RelativePath "android\app\google-services.json") `
    -Detail "Required for Crashlytics/Test Lab app identity."

  Add-Check `
    -Area "Firebase" `
    -Name "gcloud CLI" `
    -Ready (Test-CommandAvailable "gcloud") `
    -Detail "Required only for scripted Firebase Test Lab runs; console uploads remain manual."

  Add-LocalArtifactChecks -Area "Firebase"
}

if (Include-Target "BrowserStack") {
  Add-Check `
    -Area "BrowserStack" `
    -Name "BROWSERSTACK_USERNAME" `
    -Ready (Test-EnvPresent "BROWSERSTACK_USERNAME") `
    -Detail "Set as a local/session environment variable; never commit it."

  Add-Check `
    -Area "BrowserStack" `
    -Name "BROWSERSTACK_ACCESS_KEY" `
    -Ready (Test-EnvPresent "BROWSERSTACK_ACCESS_KEY") `
    -Detail "Set as a local/session environment variable; never commit it."

  Add-Check `
    -Area "BrowserStack" `
    -Name "curl.exe" `
    -Ready (Test-CommandAvailable "curl.exe") `
    -Detail "Used by BrowserStack REST examples; PowerShell Invoke-RestMethod is also acceptable."

  Add-LocalArtifactChecks -Area "BrowserStack"

  Add-Check `
    -Area "BrowserStack" `
    -Name "Android test-suite APK artifact" `
    -Ready (Test-RelativePath "build\app\outputs\apk\androidTest\debug\app-debug-androidTest.apk") `
    -Detail "Required by BrowserStack Flutter integration-test uploads."

  Add-Check `
    -Area "BrowserStack" `
    -Name "Android instrumentation test shell" `
    -Ready (Test-RelativePath "android\app\src\androidTest\java\com\tiarnanlarkin\danio\MainActivityTest.java") `
    -Detail "Existing repo instrumentation entry point; verify runner compatibility before cloud execution."
}

if (Include-Target "Percy") {
  Add-Check `
    -Area "Percy" `
    -Name "PERCY_TOKEN" `
    -Ready (Test-EnvPresent "PERCY_TOKEN") `
    -Detail "Set as a local/session environment variable; never commit it."

  Add-Check `
    -Area "Percy" `
    -Name "Visual baseline manifest" `
    -Ready (Test-RelativePath "docs\design\BASELINES.md") `
    -Detail "Local visual baselines must be stable before App Percy runs."

  Add-Check `
    -Area "Percy" `
    -Name "Visual baseline contract test" `
    -Ready (Test-RelativePath "test\quality\visual_baseline_manifest_test.dart") `
    -Detail "Run through the Focused or Visual local gate before external visual review."
}

if ($Json) {
  $script:Checks | ConvertTo-Json -Depth 4
} else {
  Write-Host "Danio external quality readiness"
  Write-Host "Target: $Target"
  Write-Host "Repo root: $RepoRoot"
  Write-Host "App root: $AppRoot"
  Write-Host ""
  $script:Checks |
    Sort-Object Area, Name |
    Format-Table Area, Name, Ready, Required, Detail -AutoSize
}

$missingRequired = @($script:Checks | Where-Object { $_.Required -and -not $_.Ready })
if ($RequireReady -and $missingRequired.Count -gt 0) {
  Write-Host ""
  Write-Host "Missing required external readiness checks:" -ForegroundColor Red
  foreach ($check in $missingRequired) {
    Write-Host "- $($check.Area): $($check.Name) - $($check.Detail)"
  }
  exit 1
}

exit 0
