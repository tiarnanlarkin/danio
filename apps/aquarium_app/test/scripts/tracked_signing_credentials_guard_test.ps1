[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-True {
  param(
    [Parameter(Mandatory = $true)][bool]$Condition,
    [Parameter(Mandatory = $true)][string]$Message
  )

  if (-not $Condition) {
    throw $Message
  }
}

function Invoke-Git {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string[]]$Arguments
  )

  $output = @(& git -C $Root @Arguments 2>&1)
  if ($LASTEXITCODE -ne 0) {
    throw "Fixture git command failed: git $($Arguments -join ' ')"
  }
  return @($output)
}

function New-FixtureRepository {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$Name
  )

  $path = Join-Path $Root $Name
  New-Item -ItemType Directory -Path $path | Out-Null
  Invoke-Git -Root $path -Arguments @("init", "--quiet") | Out-Null
  Invoke-Git -Root $path -Arguments @("config", "user.email", "fixture@example.invalid") | Out-Null
  Invoke-Git -Root $path -Arguments @("config", "user.name", "Danio Fixture") | Out-Null
  return $path
}

function Invoke-Guard {
  param(
    [Parameter(Mandatory = $true)][string]$GuardPath,
    [Parameter(Mandatory = $true)][string]$RepositoryRoot
  )

  $startInfo = New-Object Diagnostics.ProcessStartInfo
  $startInfo.FileName = "powershell.exe"
  $startInfo.Arguments = @(
    "-NoProfile",
    "-NonInteractive",
    "-ExecutionPolicy", "Bypass",
    "-File", ('"' + $GuardPath + '"'),
    "-RepositoryRoot", ('"' + $RepositoryRoot + '"')
  ) -join " "
  $startInfo.UseShellExecute = $false
  $startInfo.CreateNoWindow = $true
  $startInfo.RedirectStandardOutput = $true
  $startInfo.RedirectStandardError = $true
  $process = New-Object Diagnostics.Process
  $process.StartInfo = $startInfo
  try {
    Assert-True -Condition $process.Start() -Message "Credential guard did not start."
    $stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $stderrTask = $process.StandardError.ReadToEndAsync()
    $process.WaitForExit()
    return [pscustomobject]@{
      exit_code = $process.ExitCode
      output = ($stdoutTask.Result + $stderrTask.Result)
    }
  } finally {
    $process.Dispose()
  }
}

$testRoot = (Resolve-Path -LiteralPath $PSScriptRoot).Path
$appRoot = (Resolve-Path -LiteralPath (Join-Path $testRoot "../..")).Path
$guardPath = Join-Path $appRoot "scripts/quality_gates/check_tracked_signing_credentials.ps1"

if (-not (Test-Path -LiteralPath $guardPath -PathType Leaf)) {
  throw "Tracked signing credential guard is missing: $guardPath"
}

$fixtureRoot = Join-Path ([IO.Path]::GetTempPath()) ("danio-signing-guard-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $fixtureRoot | Out-Null
try {
  $sensitiveValue = "fixture-sensitive-value-8472"
  $trackedValueRepo = New-FixtureRepository -Root $fixtureRoot -Name "tracked-value"
  New-Item -ItemType Directory -Path (Join-Path $trackedValueRepo "docs") | Out-Null
  @(
    ("store" + "Password=" + $sensitiveValue),
    ("key" + "Password=" + $sensitiveValue),
    ("key" + "Alias" + "=" + $sensitiveValue),
    ("Alias" + "=" + $sensitiveValue)
  ) | Set-Content -LiteralPath (Join-Path $trackedValueRepo "docs/signing.txt") -Encoding UTF8
  Invoke-Git -Root $trackedValueRepo -Arguments @("add", "docs/signing.txt") | Out-Null
  $trackedValueResult = Invoke-Guard -GuardPath $guardPath -RepositoryRoot $trackedValueRepo
  Assert-True -Condition ($trackedValueResult.exit_code -ne 0) -Message "Tracked signing values were accepted."
  Assert-True -Condition ($trackedValueResult.output -notlike "*$sensitiveValue*") -Message "Guard output exposed the tracked signing value."
  Assert-True -Condition ($trackedValueResult.output -like "*docs/signing.txt*") -Message "Guard output did not identify the tracked path."

  $placeholderRepo = New-FixtureRepository -Root $fixtureRoot -Name "placeholders"
  @(
    ("store" + "Password" + "=" + "<YOUR_STORE_PASSWORD>"),
    ("key" + "Password" + "=" + "<YOUR_KEY_PASSWORD>"),
    ("key" + "Alias" + "=" + "<YOUR_KEY_ALIAS>")
  ) | Set-Content -LiteralPath (Join-Path $placeholderRepo "signing-example.properties") -Encoding UTF8
  Invoke-Git -Root $placeholderRepo -Arguments @("add", "signing-example.properties") | Out-Null
  $placeholderResult = Invoke-Guard -GuardPath $guardPath -RepositoryRoot $placeholderRepo
  Assert-True -Condition ($placeholderResult.exit_code -eq 0) -Message "Safe signing placeholders were rejected."

  $ignoredRepo = New-FixtureRepository -Root $fixtureRoot -Name "ignored-local"
  @("key.properties", "*.jks") | Set-Content -LiteralPath (Join-Path $ignoredRepo ".gitignore") -Encoding UTF8
  ("store" + "Password" + "=" + "local-only") | Set-Content -LiteralPath (Join-Path $ignoredRepo "key.properties") -Encoding UTF8
  [IO.File]::WriteAllBytes((Join-Path $ignoredRepo "local-release.jks"), [byte[]](1, 2, 3))
  Invoke-Git -Root $ignoredRepo -Arguments @("add", ".gitignore") | Out-Null
  $ignoredResult = Invoke-Guard -GuardPath $guardPath -RepositoryRoot $ignoredRepo
  Assert-True -Condition ($ignoredResult.exit_code -eq 0) -Message "Ignored local signing files were treated as tracked exposure."

  $privateFileRepo = New-FixtureRepository -Root $fixtureRoot -Name "tracked-private-file"
  [IO.File]::WriteAllBytes((Join-Path $privateFileRepo "release-key.jks"), [byte[]](4, 5, 6))
  Invoke-Git -Root $privateFileRepo -Arguments @("add", "release-key.jks") | Out-Null
  $privateFileResult = Invoke-Guard -GuardPath $guardPath -RepositoryRoot $privateFileRepo
  Assert-True -Condition ($privateFileResult.exit_code -ne 0) -Message "Tracked private signing file was accepted."
  Assert-True -Condition ($privateFileResult.output -like "*release-key.jks*") -Message "Guard output did not identify the tracked private file."

  $indexBypassRepo = New-FixtureRepository -Root $fixtureRoot -Name "staged-index-bypass"
  $indexBypassPath = Join-Path $indexBypassRepo "signing.properties"
  (("store" + "Password=") + $sensitiveValue) | Set-Content -LiteralPath $indexBypassPath -Encoding UTF8
  Invoke-Git -Root $indexBypassRepo -Arguments @("add", "signing.properties") | Out-Null
  ("store" + "Password" + "=" + "<YOUR_STORE_PASSWORD>") | Set-Content -LiteralPath $indexBypassPath -Encoding UTF8
  $indexBypassResult = Invoke-Guard -GuardPath $guardPath -RepositoryRoot $indexBypassRepo
  Assert-True -Condition ($indexBypassResult.exit_code -ne 0) -Message "A staged signing value hidden by a safe working-tree version was accepted."
  Assert-True -Condition ($indexBypassResult.output -notlike "*$sensitiveValue*") -Message "Index guard output exposed the staged signing value."

  $ciFixtureRepo = New-FixtureRepository -Root $fixtureRoot -Name "known-ci-fixture"
  New-Item -ItemType Directory -Path (Join-Path $ciFixtureRepo ".github/workflows") | Out-Null
  @(
    "# DANIO_CI_DISPOSABLE_SIGNING_FIXTURE_BEGIN",
    (("store" + "Password=") + "android"),
    (("key" + "Password=") + "android"),
    (("key" + "Alias" + "=") + "ci"),
    ("-store" + "pass android"),
    ("-key" + "pass android"),
    ("-ali" + "as ci"),
    "# DANIO_CI_DISPOSABLE_SIGNING_FIXTURE_END"
  ) | Set-Content -LiteralPath (Join-Path $ciFixtureRepo ".github/workflows/ci.yml") -Encoding UTF8
  Invoke-Git -Root $ciFixtureRepo -Arguments @("add", ".github/workflows/ci.yml") | Out-Null
  $ciFixtureResult = Invoke-Guard -GuardPath $guardPath -RepositoryRoot $ciFixtureRepo
  Assert-True -Condition ($ciFixtureResult.exit_code -eq 0) -Message "The exact marked disposable CI signing fixture was rejected."

  $ciMismatchRepo = New-FixtureRepository -Root $fixtureRoot -Name "mismatched-ci-fixture"
  New-Item -ItemType Directory -Path (Join-Path $ciMismatchRepo ".github/workflows") | Out-Null
  @(
    "# DANIO_CI_DISPOSABLE_SIGNING_FIXTURE_BEGIN",
    (("store" + "Password=") + $sensitiveValue),
    "# DANIO_CI_DISPOSABLE_SIGNING_FIXTURE_END"
  ) | Set-Content -LiteralPath (Join-Path $ciMismatchRepo ".github/workflows/ci.yml") -Encoding UTF8
  Invoke-Git -Root $ciMismatchRepo -Arguments @("add", ".github/workflows/ci.yml") | Out-Null
  $ciMismatchResult = Invoke-Guard -GuardPath $guardPath -RepositoryRoot $ciMismatchRepo
  Assert-True -Condition ($ciMismatchResult.exit_code -ne 0) -Message "A non-fixture signing value in the CI path was accepted."
  Assert-True -Condition ($ciMismatchResult.output -notlike "*$sensitiveValue*") -Message "CI guard output exposed the signing value."

  $ciCliMismatchRepo = New-FixtureRepository -Root $fixtureRoot -Name "mismatched-ci-cli-fixture"
  New-Item -ItemType Directory -Path (Join-Path $ciCliMismatchRepo ".github/workflows") | Out-Null
  @(
    "# DANIO_CI_DISPOSABLE_SIGNING_FIXTURE_BEGIN",
    (("-store" + "pass ") + $sensitiveValue),
    "# DANIO_CI_DISPOSABLE_SIGNING_FIXTURE_END"
  ) | Set-Content -LiteralPath (Join-Path $ciCliMismatchRepo ".github/workflows/ci.yml") -Encoding UTF8
  Invoke-Git -Root $ciCliMismatchRepo -Arguments @("add", ".github/workflows/ci.yml") | Out-Null
  $ciCliMismatchResult = Invoke-Guard -GuardPath $guardPath -RepositoryRoot $ciCliMismatchRepo
  Assert-True -Condition ($ciCliMismatchResult.exit_code -ne 0) -Message "A non-fixture keytool signing value in the CI path was accepted."
  Assert-True -Condition ($ciCliMismatchResult.output -notlike "*$sensitiveValue*") -Message "CLI guard output exposed the signing value."

  $nearMissRepo = New-FixtureRepository -Root $fixtureRoot -Name "placeholder-near-misses"
  @(
    (("store" + "Password=") + '$actual-secret'),
    (("key" + "Password=") + "my-placeholder-secret")
  ) | Set-Content -LiteralPath (Join-Path $nearMissRepo "signing.ini") -Encoding UTF8
  Invoke-Git -Root $nearMissRepo -Arguments @("add", "signing.ini") | Out-Null
  $nearMissResult = Invoke-Guard -GuardPath $guardPath -RepositoryRoot $nearMissRepo
  Assert-True -Condition ($nearMissResult.exit_code -ne 0) -Message "Loose placeholder/reference near misses were accepted."

  $formatRepo = New-FixtureRepository -Root $fixtureRoot -Name "additional-text-formats"
  foreach ($extension in @("env", "html", "toml")) {
    (("store" + "Password=") + $sensitiveValue) | Set-Content -LiteralPath (Join-Path $formatRepo "signing.$extension") -Encoding UTF8
  }
  Invoke-Git -Root $formatRepo -Arguments @("add", ".") | Out-Null
  $formatResult = Invoke-Guard -GuardPath $guardPath -RepositoryRoot $formatRepo
  Assert-True -Condition ($formatResult.exit_code -ne 0) -Message "A tracked signing value in an additional text format was accepted."
  Assert-True -Condition ($formatResult.output -notlike "*$sensitiveValue*") -Message "Additional-format guard output exposed the signing value."

  [pscustomobject][ordered]@{
    document_type = "danio_tracked_signing_credentials_guard_test_result"
    schema_version = 1
    passed = $true
    scenarios = 10
    secret_output_redacted = $true
  } | ConvertTo-Json -Compress
} finally {
  if (Test-Path -LiteralPath $fixtureRoot) {
    Remove-Item -LiteralPath $fixtureRoot -Recurse -Force
  }
}
