param(
  [string]$DeviceId = "emulator-5554",
  [string]$FlutterCommand = "flutter",
  [string]$Driver = "test_driver\integration_test.dart",
  [string]$Target = "integration_test\smoke_test_v2.dart",
  [switch]$SkipDebugApkRebuild
)

$ErrorActionPreference = "Continue"

$arguments = @(
  "drive",
  "-d",
  $DeviceId,
  "--driver=$Driver",
  "--target=$Target"
)

Write-Host "Running integration smoke:"
Write-Host "$FlutterCommand drive -d $DeviceId --driver=$Driver --target=$Target"

& $FlutterCommand @arguments
$driveExitCode = $LASTEXITCODE

if ($driveExitCode -eq 0 -and -not $SkipDebugApkRebuild) {
  Write-Host "Rebuilding standard debug APK after flutter drive so downstream APK-based smoke tests install the app, not the integration-test harness."
  $rebuildArguments = @("build", "apk", "--debug")
  & $FlutterCommand @rebuildArguments
  $buildExitCode = $LASTEXITCODE
  if ($buildExitCode -ne 0) {
    exit $buildExitCode
  }
}

exit $driveExitCode
