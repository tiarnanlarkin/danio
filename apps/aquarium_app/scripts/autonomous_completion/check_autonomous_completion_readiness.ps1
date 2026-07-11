[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Intent,
  [Parameter(Mandatory = $true)][string]$SynchronizationReceiptJson,
  [Parameter(Mandatory = $true)][string]$ExpectedInvocationNonce,
  [string]$RepositoryRoot,
  [int64]$MaxReceiptAgeSeconds = 120,
  [switch]$RuntimeRequired
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

function New-RejectedReadinessReport {
  param(
    [Parameter(Mandatory = $true)][string]$IntentValue,
    [Parameter(Mandatory = $true)][string]$CheckedAtUtc,
    [Parameter(Mandatory = $true)][string]$Code,
    [Parameter(Mandatory = $true)][string]$Detail
  )

  return [pscustomobject]@{
    document_type = "danio_readiness_report"
    schema_version = 1
    intent = $IntentValue
    checked_at_utc = $CheckedAtUtc
    eligible = $false
    stop_reason_code = $Code
    checks = @(
      [pscustomobject]@{
        code = $Code
        status = "fail"
        detail = $Detail
      }
    )
  }
}

$checkedAtUtc = Format-StrictUtc -Value ([DateTimeOffset]::UtcNow)
$report = $null

try {
  try {
    $receipt = $SynchronizationReceiptJson | ConvertFrom-Json
  } catch {
    throw "INVALID_SYNC_RECEIPT: synchronization receipt JSON is malformed."
  }

  $resolvedRoot = Resolve-DanioRepositoryRoot -RepositoryRoot $RepositoryRoot
  $stateRelativePath = "apps/aquarium_app/docs/agent/autonomous_completion/phone_completion_run_state.json"
  $statePath = Join-Path $resolvedRoot $stateRelativePath
  $state = $null
  if (Test-Path -LiteralPath $statePath -PathType Leaf) {
    try {
      $state = Get-Content -Raw -LiteralPath $statePath | ConvertFrom-Json
    } catch {
      $state = [pscustomobject]@{
        malformed_state = $true
      }
    }
  }

  $observation = Get-DanioRepositoryObservation `
    -RepositoryRoot $resolvedRoot `
    -State $state

  $runnerManifestPath = Join-Path $resolvedRoot "apps/aquarium_app/docs/agent/autonomous_completion/runner_compatibility.json"
  $runnerValidation = if (Test-Path -LiteralPath $runnerManifestPath -PathType Leaf) {
    try {
      $runnerManifest = Get-Content -Raw -LiteralPath $runnerManifestPath | ConvertFrom-Json
      Test-DanioRunnerCompatibility `
        -Manifest $runnerManifest `
        -RequireLaunchAuthorization:($Intent -ceq "Launch" -or $Intent -ceq "Claim")
    } catch {
      [pscustomobject]@{
        valid = $false
        code = "RUNNER_INCOMPATIBLE"
        details = @("Runner manifest is malformed.")
      }
    }
  } else {
    [pscustomobject]@{
      valid = $false
      code = "RUNNER_INCOMPATIBLE"
      details = @("Runner manifest is missing.")
    }
  }

  $remainingUnits = if ($null -ne $state -and $state.PSObject.Properties.Name -ccontains "budget") {
    [int64]$state.budget.remaining_units_including_current
  } elseif ($null -ne $observation.bootstrap_remaining_units) {
    [int64]$observation.bootstrap_remaining_units
  } else {
    0
  }

  $ledgerRows = @()
  $activePhaseLedgerIds = @()
  if ($Intent -ceq "Finalization") {
    $ledgerPath = Join-Path $resolvedRoot "apps/aquarium_app/docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md"
    $ledgerRows = @(Read-DanioLedgerClosureRows -LedgerPath $ledgerPath)
    $nonReleaseIds = @(
      $ledgerRows | Where-Object {
        (
          [string]$_.Table -ceq "Active Findings" -and
          [string]$_.ClosureState -cne "parked" -and
          [string]$_.Id -cne "DCL-RC-001"
        ) -or
        [string]$_.Disposition -ceq "ACCEPTED_LOCAL_LIMITATION"
      } | ForEach-Object { [string]$_.Id }
    )
    $activePhaseLedgerIds = @($nonReleaseIds) + @("DCL-RC-001")
  }

  $report = Test-DanioAutonomousReadiness `
    -Intent $Intent `
    -SynchronizationReceipt $receipt `
    -ExpectedInvocationNonce $ExpectedInvocationNonce `
    -ExpectedRepositoryRoot ([string]$observation.repository_root) `
    -RepositoryObservation $observation `
    -State $state `
    -AuthorityValidation $observation.authority_validation `
    -RunnerValidation $runnerValidation `
    -RemainingUnitsIncludingCurrent $remainingUnits `
    -CheckedAtUtc $checkedAtUtc `
    -MaxReceiptAgeSeconds $MaxReceiptAgeSeconds `
    -RuntimeRequired ([bool]$RuntimeRequired) `
    -RuntimeOwnershipClear (-not [bool]$RuntimeRequired) `
    -LedgerRows $ledgerRows `
    -ActivePhaseLedgerIds $activePhaseLedgerIds `
    -Evidence $null `
    -Cleanup $null
} catch {
  $message = $_.Exception.Message
  $code = if ($message -like "INVALID_SYNC_RECEIPT:*") {
    "INVALID_SYNC_RECEIPT"
  } elseif ($message -like "*REPO_ROOT_INVALID*") {
    "REPO_ROOT_INVALID"
  } else {
    "AUTHORITY_CONFLICT"
  }
  $safeIntent = if (@("Launch", "Claim", "Closeout", "Finalization", "AdministrativeSync") -ccontains $Intent) {
    $Intent
  } else {
    "Launch"
  }
  $report = New-RejectedReadinessReport `
    -IntentValue $safeIntent `
    -CheckedAtUtc $checkedAtUtc `
    -Code $code `
    -Detail $message
}

Write-Output ($report | ConvertTo-Json -Depth 100 -Compress)
if ($report.eligible) {
  exit 0
}
exit 1
