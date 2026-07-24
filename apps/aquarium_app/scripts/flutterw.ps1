param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$FlutterArgs = @()
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$AppRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
if ($flutterCommand) {
  $flutter = $flutterCommand.Source
}
else {
  $flutter = Join-Path $env:USERPROFILE 'development\flutter\bin\flutter.bat'
}
if (-not (Test-Path -LiteralPath $flutter -PathType Leaf)) {
  throw "Flutter was not found on PATH or at '$flutter'."
}

$androidDir = Join-Path $AppRoot 'android'
$gradle = Join-Path $androidDir 'gradlew.bat'

if (
  $FlutterArgs.Length -ge 2 -and
  $FlutterArgs[0] -eq 'build' -and
  $FlutterArgs[1] -eq 'appbundle'
) {
  Write-Host 'Using direct Gradle bundleRelease (known-good path for Danio on Windows)...'
  Push-Location -LiteralPath $androidDir
  try {
    & $gradle 'bundleRelease'
    $exitCode = $LASTEXITCODE
  }
  finally {
    Pop-Location
  }
  exit $exitCode
}

Push-Location -LiteralPath $AppRoot
try {
  & $flutter @FlutterArgs
  $exitCode = $LASTEXITCODE
}
finally {
  Pop-Location
}
exit $exitCode
