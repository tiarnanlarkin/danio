param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$FlutterArgs
)

$ErrorActionPreference = 'Stop'
$repo = 'C:\Users\larki\Documents\Danio Aquarium App Project\repo\apps\aquarium_app'
$flutter = 'C:\Users\larki\flutter\bin\flutter.bat'
$androidDir = Join-Path $repo 'android'
$gradle = Join-Path $androidDir 'gradlew.bat'

if (
  $FlutterArgs.Length -ge 2 -and
  $FlutterArgs[0] -eq 'build' -and
  $FlutterArgs[1] -eq 'appbundle'
) {
  Write-Host 'Using direct Gradle bundleRelease (known-good path for Danio on Windows)...'
  Set-Location $androidDir
  & $gradle 'bundleRelease'
  exit $LASTEXITCODE
}

Set-Location $repo
& $flutter @FlutterArgs
exit $LASTEXITCODE
