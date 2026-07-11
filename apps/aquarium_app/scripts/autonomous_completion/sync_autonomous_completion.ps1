[CmdletBinding()]
param(
  [string]$RepositoryRoot,
  [Parameter(Mandatory = $true)][string]$InvocationNonce
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "DanioAutonomousCompletion.psm1"
Import-Module -Name $modulePath -Force

function Format-StrictUtc {
  param([Parameter(Mandatory = $true)][DateTimeOffset]$Value)

  return $Value.ToUniversalTime().ToString(
    "yyyy-MM-dd'T'HH:mm:ss.fffffff'Z'",
    [Globalization.CultureInfo]::InvariantCulture
  )
}

function Invoke-GitCaptured {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string[]]$Arguments
  )

  $priorErrorActionPreference = $ErrorActionPreference
  try {
    $ErrorActionPreference = "Continue"
    $output = @(& git -C $Root @Arguments 2>&1)
    $exitCode = $LASTEXITCODE
  } finally {
    $ErrorActionPreference = $priorErrorActionPreference
  }
  return [pscustomobject]@{
    exit_code = $exitCode
    output = @($output | ForEach-Object { [string]$_ })
  }
}

$resolvedRoot = $null
$normalizedRoot = if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
  "C:/invalid/repository"
} else {
  $RepositoryRoot.Replace("\", "/").TrimEnd("/")
}
$safeNonce = if ($InvocationNonce -cmatch '^[0-9a-f]{32}$') {
  $InvocationNonce
} else {
  "00000000000000000000000000000000"
}
$fetchExitCode = 1
$originMainCommit = $null
$ahead = $null
$behind = $null
$diagnostic = $null

try {
  if ($safeNonce -cne $InvocationNonce) {
    throw "InvocationNonce must be exactly 32 lowercase hexadecimal characters."
  }

  $resolvedRoot = Resolve-DanioRepositoryRoot -RepositoryRoot $RepositoryRoot
  $normalizedRoot = $resolvedRoot.Replace("\", "/").TrimEnd("/")
  $fetchResult = Invoke-GitCaptured -Root $resolvedRoot -Arguments @("fetch", "--prune")
  $fetchExitCode = [int]$fetchResult.exit_code
  if ($fetchExitCode -ne 0) {
    $diagnostic = $fetchResult.output -join "; "
  } else {
    $originResult = Invoke-GitCaptured -Root $resolvedRoot -Arguments @("rev-parse", "origin/main")
    if ($originResult.exit_code -ne 0) {
      throw "Unable to resolve origin/main: $($originResult.output -join '; ')"
    }
    $originMainCommit = ($originResult.output -join "").Trim()

    $countResult = Invoke-GitCaptured `
      -Root $resolvedRoot `
      -Arguments @("rev-list", "--left-right", "--count", "main...origin/main")
    if ($countResult.exit_code -ne 0) {
      throw "Unable to compare main and origin/main: $($countResult.output -join '; ')"
    }
    $countParts = @(($countResult.output -join " ") -split '\s+' | Where-Object { $_ -ne "" })
    if ($countParts.Count -ne 2) {
      throw "Ahead/behind output was malformed."
    }
    $ahead = [int64]$countParts[0]
    $behind = [int64]$countParts[1]
  }
} catch {
  $fetchExitCode = 1
  $originMainCommit = $null
  $ahead = $null
  $behind = $null
  $diagnostic = $_.Exception.Message
}

$completedAtUtc = Format-StrictUtc -Value ([DateTimeOffset]::UtcNow)
$receipt = New-DanioSynchronizationReceipt `
  -InvocationNonce $safeNonce `
  -RepositoryRoot $normalizedRoot `
  -ExitCode $fetchExitCode `
  -CompletedAtUtc $completedAtUtc `
  -OriginMainCommit $originMainCommit `
  -Ahead $ahead `
  -Behind $behind

if ($fetchExitCode -ne 0 -and -not [string]::IsNullOrWhiteSpace($diagnostic)) {
  [Console]::Error.WriteLine($diagnostic)
}

Write-Output ($receipt | ConvertTo-Json -Depth 100 -Compress)
if ($fetchExitCode -eq 0) {
  exit 0
}
exit 1
