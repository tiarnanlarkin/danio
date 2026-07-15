[CmdletBinding()]
param(
  [string]$RepositoryRoot = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptPath = $MyInvocation.MyCommand.Path
$qualityGateDirectory = Split-Path -Parent $scriptPath
$scriptsDirectory = Split-Path -Parent $qualityGateDirectory
$appRoot = Split-Path -Parent $scriptsDirectory

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
  $RepositoryRoot = Join-Path $appRoot "../.."
}

$resolvedRoot = (Resolve-Path -LiteralPath $RepositoryRoot).Path
$gitRoot = (& git -C $resolvedRoot rev-parse --show-toplevel 2>$null).Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($gitRoot)) {
  throw "RepositoryRoot is not inside a Git worktree."
}
$gitRoot = (Resolve-Path -LiteralPath $gitRoot).Path

$trackedPaths = @(& git -C $gitRoot ls-files)
if ($LASTEXITCODE -ne 0) {
  throw "git ls-files failed."
}

$findings = New-Object System.Collections.Generic.List[object]
$privateFilePattern = '(?i)(^|/)(key\.properties|[^/]+\.(jks|keystore|p12|pfx))$'
$signingFieldPattern = '(?i)(?:(?<assignmentField>store\s*password|storePassword|key\s*password|keyPassword|key\s*alias|keyAlias|keystore\s*alias|signing\s*alias|alias)\**\s*[:=]\s*|(?<cliField>-(storepass|keypass|alias))\s+)(?<value>.+?)\s*$'
$gitGrepPattern = '((store[[:space:]]*password|key[[:space:]]*password|key[[:space:]]*alias|keystore[[:space:]]*alias|signing[[:space:]]*alias|alias)[*[:space:]]*[:=]|-(storepass|keypass|alias)[[:space:]]+)'
$ciFixturePath = '.github/workflows/ci.yml'
$ciFixtureBegin = '# DANIO_CI_DISPOSABLE_SIGNING_FIXTURE_BEGIN'
$ciFixtureEnd = '# DANIO_CI_DISPOSABLE_SIGNING_FIXTURE_END'

function Get-NormalizedSigningValue {
  param([Parameter(Mandatory = $true)][string]$Value)

  $candidate = $Value.Trim()
  if ($candidate.EndsWith('\')) {
    $candidate = $candidate.Substring(0, $candidate.Length - 1).TrimEnd()
  }
  return $candidate.Trim('"').Trim("'").Trim()
}

function Test-SafeSigningExampleValue {
  param([Parameter(Mandatory = $true)][string]$Value)

  $candidate = Get-NormalizedSigningValue -Value $Value
  if ([string]::IsNullOrWhiteSpace($candidate)) {
    return $true
  }

  if ($candidate -cmatch '^<[A-Z][A-Z0-9_ -]*>$' -or
      $candidate -cmatch '^YOUR(?:_[A-Z0-9]+)+$') {
    return $true
  }

  if ($candidate -match '^(placeholder|example|redacted|not[-_ ]?set|local[-_ ]?only|change[-_ ]?me|replace[-_ ]?me)$') {
    return $true
  }

  if ($candidate -cmatch '^\$env:[A-Za-z_][A-Za-z0-9_]*$' -or
      $candidate -cmatch '^\$\{[A-Za-z_][A-Za-z0-9_]*\}$' -or
      $candidate -cmatch '^\$\{\{[^{}\r\n]+\}\}$' -or
      $candidate -cmatch '^%[A-Za-z_][A-Za-z0-9_]*%$') {
    return $true
  }

  if ($candidate -match '^(System\.getenv|findProperty|providers?\.environmentVariable)\([^\r\n]+\)(\s+as\s+String)?$' -or
      $candidate -match '^(keystoreProperties|signingProperties)(\[[^\]\r\n]+\]|\.[A-Za-z][A-Za-z0-9_]*\([^\r\n]+\))(\s+as\s+String)?$' -or
      $candidate -match '^(env|secrets)\.[A-Za-z_][A-Za-z0-9_.-]*$') {
    return $true
  }

  return $false
}

function Test-KnownCiFixtureValue {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][bool]$InsideMarkedFixture,
    [Parameter(Mandatory = $true)][string]$Field,
    [Parameter(Mandatory = $true)][string]$Value
  )

  if ($Path -cne $ciFixturePath -or -not $InsideMarkedFixture) {
    return $false
  }

  $candidate = Get-NormalizedSigningValue -Value $Value
  if ($Field -match '(password|pass)$') {
    return $candidate -ceq 'android'
  }
  if ($Field -match 'alias') {
    return $candidate -ceq 'ci'
  }
  return $false
}

function Add-SigningFindingFromLine {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Line,
    [Parameter(Mandatory = $true)][int]$LineNumber,
    [Parameter(Mandatory = $true)][ValidateSet('index', 'worktree')][string]$Source,
    [Parameter(Mandatory = $true)][bool]$InsideCiFixture
  )

  $match = [regex]::Match($Line, $signingFieldPattern)
  if (-not $match.Success) {
    return
  }

  $field = if ($match.Groups['assignmentField'].Success) {
    $match.Groups['assignmentField'].Value.ToLowerInvariant()
  } else {
    $match.Groups['cliField'].Value.ToLowerInvariant()
  }
  if ($field -eq 'alias' -and
      $Path -notmatch '(?i)(sign|keystore|release|build|play[_ -]?store|launch)') {
    return
  }

  $value = $match.Groups['value'].Value
  if (Test-SafeSigningExampleValue -Value $value) {
    return
  }
  if (Test-KnownCiFixtureValue -Path $Path -InsideMarkedFixture $InsideCiFixture -Field $field -Value $value) {
    return
  }

  $category = if ($field -match 'alias') { "tracked-signing-alias-$Source" } else { "tracked-signing-password-$Source" }
  $findings.Add([pscustomobject]@{
    path = $Path
    line = $LineNumber
    category = $category
  }) | Out-Null
}

function Get-CiFixtureMarkerLines {
  param(
    [Parameter(Mandatory = $true)][AllowEmptyCollection()][AllowEmptyString()][string[]]$Lines
  )

  $beginLine = 0
  $endLine = 0
  for ($index = 0; $index -lt $Lines.Count; $index++) {
    $trimmedLine = $Lines[$index].Trim()
    if ($trimmedLine -ceq $ciFixtureBegin) {
      $beginLine = $index + 1
    } elseif ($trimmedLine -ceq $ciFixtureEnd) {
      $endLine = $index + 1
    }
  }
  return [pscustomobject]@{ begin = $beginLine; end = $endLine }
}

function Add-SigningFindingsFromGrepMatches {
  param(
    [Parameter(Mandatory = $true)][AllowEmptyCollection()][AllowEmptyString()][string[]]$Matches,
    [Parameter(Mandatory = $true)][ValidateSet('index', 'worktree')][string]$Source,
    [Parameter(Mandatory = $true)][int]$CiBeginLine,
    [Parameter(Mandatory = $true)][int]$CiEndLine
  )

  foreach ($grepMatch in $Matches) {
    $parsed = [regex]::Match($grepMatch, '^(?<path>.*?):(?<line>[0-9]+):(?<text>.*)$')
    if (-not $parsed.Success) {
      throw "Unable to parse tracked $Source scan output."
    }
    $path = $parsed.Groups['path'].Value.Replace('\', '/')
    $lineNumber = [int]$parsed.Groups['line'].Value
    $insideCiFixture = (
      $path -ceq $ciFixturePath -and
      $CiBeginLine -gt 0 -and
      $CiEndLine -gt $CiBeginLine -and
      $lineNumber -gt $CiBeginLine -and
      $lineNumber -lt $CiEndLine
    )
    Add-SigningFindingFromLine `
      -Path $path `
      -Line $parsed.Groups['text'].Value `
      -LineNumber $lineNumber `
      -Source $Source `
      -InsideCiFixture $insideCiFixture
  }
}

foreach ($relativePath in $trackedPaths) {
  $normalizedPath = $relativePath.Replace('\', '/')
  if ($normalizedPath -match $privateFilePattern) {
    $findings.Add([pscustomobject]@{
      path = $normalizedPath
      line = 0
      category = "tracked-private-signing-file"
    }) | Out-Null
  }
}

$ciIndexMarkers = [pscustomobject]@{ begin = 0; end = 0 }
$ciWorktreeMarkers = [pscustomobject]@{ begin = 0; end = 0 }
if ($trackedPaths -ccontains $ciFixturePath) {
  $ciIndexLines = @(& git -C $gitRoot show (':' + $ciFixturePath) 2>$null)
  if ($LASTEXITCODE -ne 0) {
    throw "Unable to inspect the CI fixture index blob."
  }
  $ciIndexMarkers = Get-CiFixtureMarkerLines -Lines $ciIndexLines

  $ciWorktreePath = Join-Path $gitRoot ($ciFixturePath -replace '/', [IO.Path]::DirectorySeparatorChar)
  if (Test-Path -LiteralPath $ciWorktreePath -PathType Leaf) {
    $ciWorktreeMarkers = Get-CiFixtureMarkerLines -Lines @([IO.File]::ReadAllLines($ciWorktreePath))
  }
}

$indexMatches = @(& git -C $gitRoot grep --cached -n -I -i -E $gitGrepPattern 2>$null)
$gitGrepExitCode = $LASTEXITCODE
if ($gitGrepExitCode -notin @(0, 1)) {
  throw "Unable to scan tracked index text."
}
Add-SigningFindingsFromGrepMatches `
  -Matches $indexMatches `
  -Source 'index' `
  -CiBeginLine $ciIndexMarkers.begin `
  -CiEndLine $ciIndexMarkers.end

$worktreeMatches = @(& git -C $gitRoot grep -n -I -i -E $gitGrepPattern 2>$null)
$gitGrepExitCode = $LASTEXITCODE
if ($gitGrepExitCode -notin @(0, 1)) {
  throw "Unable to scan tracked working-tree text."
}
Add-SigningFindingsFromGrepMatches `
  -Matches $worktreeMatches `
  -Source 'worktree' `
  -CiBeginLine $ciWorktreeMarkers.begin `
  -CiEndLine $ciWorktreeMarkers.end

if ($findings.Count -gt 0) {
  [Console]::Error.WriteLine("Tracked Android signing information was found. Values are intentionally redacted.")
  foreach ($finding in $findings) {
    $location = if ($finding.line -gt 0) { "$($finding.path):$($finding.line)" } else { $finding.path }
    [Console]::Error.WriteLine("$location [$($finding.category)]")
  }
  exit 1
}

[pscustomobject][ordered]@{
  document_type = "danio_tracked_signing_credentials_guard_result"
  schema_version = 1
  passed = $true
  tracked_paths_checked = $trackedPaths.Count
  sources_checked = @('index', 'worktree')
  findings = 0
  values_redacted = $true
} | ConvertTo-Json -Compress
