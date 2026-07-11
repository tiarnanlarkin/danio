[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-True {
  param(
    [bool]$Condition,
    [string]$Message
  )

  if (-not $Condition) {
    throw $Message
  }
}

function Assert-Equal {
  param(
    $Actual,
    $Expected,
    [string]$Message
  )

  if ($Actual -ne $Expected) {
    throw "$Message Expected '$Expected', found '$Actual'."
  }
}

function Assert-ThrowsLike {
  param(
    [scriptblock]$Action,
    [string]$ExpectedPattern,
    [string]$Message
  )

  try {
    & $Action
  } catch {
    if ($_.Exception.Message -like "*$ExpectedPattern*") {
      return
    }
    throw "$Message Unexpected error: $($_.Exception.Message)"
  }

  throw "$Message Expected an error containing '$ExpectedPattern'."
}

function Copy-JsonValue {
  param([Parameter(Mandatory = $true)]$Value)

  $copy = $Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json
  if ($copy -is [System.Array]) {
    foreach ($item in $copy) {
      Write-Output $item
    }
    return
  }
  return $copy
}

function Get-ExpectedOwnerToken {
  param(
    [Parameter(Mandatory = $true)][string]$RunId,
    [Parameter(Mandatory = $true)][string]$WorkUnitId,
    [Parameter(Mandatory = $true)][string]$TaskId,
    [Parameter(Mandatory = $true)][int64]$ExpectedRevision
  )

  $tokenInput = @(
    $RunId,
    $WorkUnitId,
    $TaskId,
    [string]$ExpectedRevision
  ) -join "`n"
  $tokenBytes = [System.Text.Encoding]::UTF8.GetBytes($tokenInput)
  $tokenHash = [System.Security.Cryptography.SHA256]::Create().ComputeHash($tokenBytes)
  return ([System.BitConverter]::ToString($tokenHash)).Replace("-", "").ToLowerInvariant()
}

function New-TestOwner {
  param(
    [Parameter(Mandatory = $true)][string]$RunId,
    [Parameter(Mandatory = $true)][string]$WorkUnitId,
    [Parameter(Mandatory = $true)][int64]$ExpectedRevision
  )

  $taskId = "task-fixture-001"
  $token = Get-ExpectedOwnerToken `
    -RunId $RunId `
    -WorkUnitId $WorkUnitId `
    -TaskId $taskId `
    -ExpectedRevision $ExpectedRevision
  $token12 = $token.Substring(0, 12)
  $worktreeId = "$RunId-$WorkUnitId-$token12"

  return [pscustomobject]@{
    task_id = $taskId
    token_sha256 = $token
    claim_revision = $ExpectedRevision
    claim_parent_commit = "f10b6021e083ba745fc2abf254f7ca91093d703e"
    claim_staged_tree_hash = "9119ad828ff570ccd42df26553e8142569919fb8"
    branch_name = "autonomy/$RunId/$WorkUnitId/$token12"
    worktree_id = $worktreeId
    worktree_path = "C:/Users/larki/OneDrive/Documents/App Projects/Danio Aquarium App Project/.codex-worktrees/$worktreeId"
    claimed_at_utc = "2026-07-11T12:01:00.0000000Z"
    writer_lease_released = $false
    android_lease_released = $true
  }
}

function New-TestLeaseRelease {
  param([Parameter(Mandatory = $true)]$Owner)

  return [pscustomobject]@{
    owner_token = [string]$Owner.token_sha256
    writer_released = $true
    worktree_released = $true
    android_released = $true
    processes_released = $true
  }
}

function New-TestRecovery {
  param([Parameter(Mandatory = $true)]$Owner)

  return [pscustomobject]@{
    branch_name = [string]$Owner.branch_name
    worktree_path = [string]$Owner.worktree_path
    dirty_paths = @()
    relevant_processes = @()
    commands = @("Reconcile the exact stopped owner before resuming.")
    last_clean_commit = "f10b6021e083ba745fc2abf254f7ca91093d703e"
  }
}

function New-TransitionCandidate {
  param(
    [Parameter(Mandatory = $true)]$PreviousState,
    [Parameter(Mandatory = $true)][string]$ToMode,
    [Parameter(Mandatory = $true)][string]$Action,
    [string]$WorkUnitId,
    [switch]$Claim,
    [switch]$Consume,
    [switch]$RetainOwner,
    [switch]$Administrative,
    [string]$ReasonCode
  )

  $candidate = Copy-JsonValue -Value $PreviousState
  if ([string]::IsNullOrWhiteSpace($WorkUnitId)) {
    $WorkUnitId = [string]$PreviousState.cursor.work_unit_id
  }

  $candidate.state_revision = [int]$PreviousState.state_revision + 1
  $candidate.mode = $ToMode
  $candidate.transition = [pscustomobject]@{
    action = $Action
    from_mode = [string]$PreviousState.mode
    to_mode = $ToMode
    parent_state_revision = [int]$PreviousState.state_revision
    work_unit_id = $WorkUnitId
    reason_code = if ([string]::IsNullOrWhiteSpace($ReasonCode)) { $null } else { $ReasonCode }
    occurred_at_utc = "2026-07-11T12:10:00.0000000Z"
  }
  $candidate.stop_reason_code = if ([string]::IsNullOrWhiteSpace($ReasonCode)) { $null } else { $ReasonCode }

  if ($Claim) {
    $candidate.owner = New-TestOwner `
      -RunId ([string]$candidate.run_id) `
      -WorkUnitId $WorkUnitId `
      -ExpectedRevision ([int64]$PreviousState.state_revision)
    $candidate.budget.current_charge.work_unit_id = $WorkUnitId
    $candidate.budget.current_charge.status = "pending"
    $candidate.budget.current_charge.claimed_revision = [int]$PreviousState.state_revision
    $candidate.budget.current_charge.consumed_revision = $null
  } elseif ($Consume) {
    $candidate.budget.consumed_units = [int]$PreviousState.budget.consumed_units + 1
    $candidate.budget.remaining_units_including_current = [int]$PreviousState.budget.remaining_units_including_current - 1
    $candidate.budget.current_charge.work_unit_id = $WorkUnitId
    $candidate.budget.current_charge.status = "consumed"
    $candidate.budget.current_charge.consumed_revision = [int]$candidate.state_revision
    if (-not $RetainOwner) {
      $candidate.owner = $null
    }
  } elseif (-not $RetainOwner) {
    $candidate.owner = $null
  }

  if ($Action -eq "closeout") {
    $candidate.handoff_generation = [int]$PreviousState.handoff_generation + 1
  }

  if (@("closeout", "pause", "finalize", "complete") -contains $Action) {
    $candidate.last_verified_checkpoint = [pscustomobject]@{
      product_commit = "f10b6021e083ba745fc2abf254f7ca91093d703e"
      evidence_manifest_path = "apps/aquarium_app/docs/agent/autonomous_completion/evidence/f10b6021e083ba745fc2abf254f7ca91093d703e.json"
      verified_at_utc = "2026-07-11T12:09:00.0000000Z"
    }
  }
  if ($Action -eq "complete") {
    $candidate.last_verified_checkpoint.product_commit = ("2" * 40)
    $candidate.last_verified_checkpoint.evidence_manifest_path =
      "apps/aquarium_app/docs/agent/autonomous_completion/evidence/$("2" * 40).json"
    $candidate.last_verified_checkpoint.verified_at_utc = "2026-07-11T12:09:30.0000000Z"
  }

  if ($Administrative) {
    $candidate.control_surface_sync.status = "pending"
    $candidate.control_surface_sync.target_commit = "f10b6021e083ba745fc2abf254f7ca91093d703e"
  }

  return $candidate
}

function Read-Fixture {
  param(
    [Parameter(Mandatory = $true)][string]$FixtureRoot,
    [Parameter(Mandatory = $true)][string]$Name
  )

  $path = Join-Path $FixtureRoot $Name
  return Get-Content -Raw -LiteralPath $path | ConvertFrom-Json
}

$testRoot = (Resolve-Path -LiteralPath $PSScriptRoot).Path
$appRoot = (Resolve-Path -LiteralPath (Join-Path $testRoot "../..")).Path
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $appRoot "../..")).Path
$modulePath = Join-Path $appRoot "scripts/autonomous_completion/DanioAutonomousCompletion.psm1"
$fixtureRoot = Join-Path $testRoot "fixtures/autonomous_completion"
$ledgerPath = Join-Path $appRoot "docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md"
$ledgerHashBefore = (Get-FileHash -Algorithm SHA256 -LiteralPath $ledgerPath).Hash

if (-not (Test-Path -LiteralPath $modulePath -PathType Leaf)) {
  throw "Expected pure module is missing: $modulePath"
}

Import-Module -Name $modulePath -Force

$resolvedRoot = Resolve-DanioRepositoryRoot -RepositoryRoot $repoRoot
Assert-Equal -Actual $resolvedRoot -Expected $repoRoot -Message "Repository root resolution failed."

$activePhaseLedgerIds = @(
  "DCL-P1-001",
  "DCL-P1-002",
  "DCL-DR-001",
  "DCL-DR-002",
  "DCL-DR-003",
  "DCL-DR-004",
  "DCL-AI-001",
  "DCL-PREF-001",
  "DCL-P1-003",
  "DCL-P1-004",
  "DCL-P1-005",
  "DCL-P1-006",
  "DCL-CONTENT-001",
  "DCL-RULE-001",
  "DCL-A11Y-001",
  "DCL-VIS-001",
  "DCL-VIS-002",
  "DCL-MOTION-001",
  "DCL-PERF-001",
  "DCL-RC-001"
)

$ledgerRows = @(Read-DanioLedgerClosureRows -LedgerPath $ledgerPath)
Assert-True -Condition ($ledgerRows.Count -gt 0) -Message "Current ledger parsing returned no rows."

$bootstrapRows = @()
foreach ($index in 1..17) {
  $bootstrapRows += [pscustomobject]@{
    Id = ("DCL-BOOT-{0:D3}" -f $index)
    Disposition = "VERIFY_LOCALLY"
    ClosureState = "open"
  }
}
$bootstrapRows += [pscustomobject]@{
  Id = "DCL-RC-001"
  Disposition = "VERIFY_LOCALLY"
  ClosureState = "open"
}
foreach ($index in 1..5) {
  $bootstrapRows += [pscustomobject]@{
    Id = ("DCL-PARK-{0:D3}" -f $index)
    Disposition = "PHASE_PARKED"
    ClosureState = "parked"
  }
}
foreach ($index in 1..2) {
  $bootstrapRows += [pscustomobject]@{
    Id = ("DCL-ACCEPT-{0:D3}" -f $index)
    Disposition = "ACCEPTED_LOCAL_LIMITATION"
    ClosureState = "closed"
  }
  $bootstrapRows += [pscustomobject]@{
    Id = ("DCL-ARCH-{0:D3}" -f $index)
    Disposition = "NOT_CURRENT_ARCHIVED"
    ClosureState = "closed"
  }
}
$bootstrapValidation = Test-DanioLedgerClosureRows `
  -Rows $bootstrapRows `
  -ActivePhaseLedgerIds (@($bootstrapRows | Where-Object { $_.ClosureState -eq "open" } | ForEach-Object { $_.Id }))
Assert-True -Condition $bootstrapValidation.valid -Message "Immutable bootstrap ledger snapshot should validate."
Assert-Equal -Actual $bootstrapValidation.counts.open -Expected 18 -Message "Bootstrap open count mismatch."
Assert-Equal -Actual $bootstrapValidation.counts.parked -Expected 5 -Message "Bootstrap parked count mismatch."
Assert-Equal -Actual $bootstrapValidation.counts.closed -Expected 4 -Message "Bootstrap closed count mismatch."
Assert-Equal -Actual $bootstrapValidation.counts.decision_required -Expected 0 -Message "Bootstrap decision count mismatch."

$ledgerValidation = Test-DanioLedgerClosureRows `
  -Rows $ledgerRows `
  -ActivePhaseLedgerIds $activePhaseLedgerIds
Assert-True -Condition $ledgerValidation.valid -Message "Current ledger should validate: $($ledgerValidation.details -join '; ')"
Assert-Equal -Actual $ledgerValidation.code -Expected "LEDGER_VALID" -Message "Unexpected ledger validation code."

$extraRow = Copy-JsonValue -Value $ledgerRows[0]
$extraRow.Id = "DCL-NEW-001"
$extraRow.ClosureState = "open"
$extraRow.Disposition = "VERIFY_LOCALLY"
$expandedRows = @($ledgerRows) + @($extraRow)
$expandedValidation = Test-DanioLedgerClosureRows `
  -Rows $expandedRows `
  -ActivePhaseLedgerIds $activePhaseLedgerIds
Assert-True -Condition $expandedValidation.valid -Message "Runtime ledger validation must not freeze bootstrap counts."

$duplicateValidation = Test-DanioLedgerClosureRows `
  -Rows (@($ledgerRows) + @($ledgerRows[0])) `
  -ActivePhaseLedgerIds $activePhaseLedgerIds
Assert-True -Condition (-not $duplicateValidation.valid) -Message "Duplicate ledger IDs must fail."
Assert-Equal -Actual $duplicateValidation.code -Expected "LEDGER_DUPLICATE_ID" -Message "Duplicate ledger code mismatch."

$badDispositionRows = @(Copy-JsonValue -Value $ledgerRows)
$parkedIndex = 0
while ($badDispositionRows[$parkedIndex].ClosureState -ne "parked") {
  $parkedIndex += 1
}
$badDispositionRows[$parkedIndex].ClosureState = "open"
$badDispositionValidation = Test-DanioLedgerClosureRows `
  -Rows $badDispositionRows `
  -ActivePhaseLedgerIds $activePhaseLedgerIds
Assert-Equal -Actual $badDispositionValidation.code -Expected "LEDGER_DISPOSITION_STATE_MISMATCH" -Message "Parked disposition mismatch was not rejected."

$badOrderValidation = Test-DanioLedgerClosureRows `
  -Rows $ledgerRows `
  -ActivePhaseLedgerIds (@("DCL-RC-001") + $activePhaseLedgerIds[0..18])
Assert-Equal -Actual $badOrderValidation.code -Expected "RELEASE_CANDIDATE_ORDER" -Message "DCL-RC-001 must be the last active phase row."

$validLedgerSnippet = @'
## Active Findings

| ID | Finding | How Found | Evidence | Disposition | Closure State | Lane | User Input | Done Condition |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| DCL-TEST-001 | Escaped \| pipe | audit | proof | FIX_LOCALLY | open | Test | No | done |

## Closed, Accepted, Or Superseded Findings

| ID | Finding | Superseding Evidence | Disposition | Closure State | Rule |
| --- | --- | --- | --- | --- | --- |
| DCL-TEST-002 | Closed | proof | NOT_CURRENT_ARCHIVED | closed | retain |
'@
$snippetRows = @(Read-DanioLedgerClosureRows -Content $validLedgerSnippet)
Assert-Equal -Actual $snippetRows.Count -Expected 2 -Message "Formal ledger snippet did not parse."
Assert-True -Condition ($snippetRows[0].Finding -like "*|*") -Message "Escaped pipe was not preserved."

$literalPipeSnippet = $validLedgerSnippet.Replace("Escaped \| pipe", "Literal | pipe")
Assert-ThrowsLike `
  -Action { Read-DanioLedgerClosureRows -Content $literalPipeSnippet | Out-Null } `
  -ExpectedPattern "LEDGER_MALFORMED_ROW" `
  -Message "Literal unescaped pipe must fail."

$missingLeadingPipeSnippet = $validLedgerSnippet.Replace(
  "| DCL-TEST-001 | Escaped \| pipe",
  "DCL-TEST-001 | Escaped \| pipe"
)
Assert-ThrowsLike `
  -Action { Read-DanioLedgerClosureRows -Content $missingLeadingPipeSnippet | Out-Null } `
  -ExpectedPattern "LEDGER_MALFORMED_ROW" `
  -Message "A ledger data row missing its leading pipe must fail."

$inactive = Read-Fixture -FixtureRoot $fixtureRoot -Name "inactive_run_state.json"
$ready = Read-Fixture -FixtureRoot $fixtureRoot -Name "ready_run_state.json"
$active = Read-Fixture -FixtureRoot $fixtureRoot -Name "active_run_state.json"
$handoffReady = Read-Fixture -FixtureRoot $fixtureRoot -Name "handoff_ready_run_state.json"
$finalizing = Read-Fixture -FixtureRoot $fixtureRoot -Name "finalizing_run_state.json"
$complete = Read-Fixture -FixtureRoot $fixtureRoot -Name "complete_run_state.json"

foreach ($fixture in @($inactive, $ready, $active, $handoffReady, $finalizing, $complete)) {
  $stateValidation = Test-DanioRunState -State $fixture
  Assert-True -Condition $stateValidation.valid -Message "Fixture '$($fixture.mode)' should validate: $($stateValidation.details -join '; ')"
}

$nullStateValidation = Test-DanioRunState -State $null
Assert-True -Condition (-not $nullStateValidation.valid) -Message "Null run state did not return structured rejection."

$expectedActiveToken = "5566cc56fcd32df88a240501e09417589eab91939aa46f6bfde7a4a2b806ea89"
Assert-Equal -Actual $active.owner.token_sha256 -Expected $expectedActiveToken -Message "Active fixture owner token input drifted."

$badBudget = Copy-JsonValue -Value $ready
$badBudget.budget.remaining_units_including_current =
  [int]$ready.budget.remaining_units_including_current - 1
$badBudgetValidation = Test-DanioRunState -State $badBudget
Assert-Equal -Actual $badBudgetValidation.code -Expected "BUDGET_INVARIANT" -Message "Budget arithmetic mismatch was not rejected."

$missingOwner = Copy-JsonValue -Value $active
$missingOwner.owner = $null
$missingOwnerValidation = Test-DanioRunState -State $missingOwner
Assert-Equal -Actual $missingOwnerValidation.code -Expected "OWNER_REQUIRED" -Message "Active state without owner was not rejected."

$unexpectedOwner = Copy-JsonValue -Value $ready
$unexpectedOwner.owner = Copy-JsonValue -Value $active.owner
$unexpectedOwnerValidation = Test-DanioRunState -State $unexpectedOwner
Assert-Equal -Actual $unexpectedOwnerValidation.code -Expected "OWNER_NOT_ALLOWED" -Message "Ready state owner was not rejected."

$badToken = Copy-JsonValue -Value $active
$badToken.owner.token_sha256 = ("0" * 64)
$badTokenValidation = Test-DanioRunState -State $badToken
Assert-Equal -Actual $badTokenValidation.code -Expected "OWNER_TOKEN_INVALID" -Message "Invalid owner token was not rejected."

$largeRevisionOwner = Copy-JsonValue -Value $finalizing
$largeRevisionOwner.owner.claim_revision = [int64]2147483648
$largeRevisionOwner.budget.current_charge.claimed_revision = [int64]2147483648
$largeRevisionValidation = Test-DanioRunState -State $largeRevisionOwner
Assert-True -Condition (-not $largeRevisionValidation.valid) -Message "Out-of-history Int64 owner revision did not return structured rejection."

$unboundOwnerRevision = Copy-JsonValue -Value $active
$unboundOwnerRevision.owner.claim_revision = 999
$unboundOwnerRevision.owner.token_sha256 = Get-ExpectedOwnerToken `
  -RunId ([string]$unboundOwnerRevision.run_id) `
  -WorkUnitId ([string]$unboundOwnerRevision.cursor.work_unit_id) `
  -TaskId ([string]$unboundOwnerRevision.owner.task_id) `
  -ExpectedRevision 999
$unboundToken12 = $unboundOwnerRevision.owner.token_sha256.Substring(0, 12)
$unboundOwnerRevision.owner.branch_name = "autonomy/$($unboundOwnerRevision.run_id)/$($unboundOwnerRevision.cursor.work_unit_id)/$unboundToken12"
$unboundOwnerRevision.owner.worktree_id = "$($unboundOwnerRevision.run_id)-$($unboundOwnerRevision.cursor.work_unit_id)-$unboundToken12"
$unboundOwnerRevision.owner.worktree_path = "$($unboundOwnerRevision.authorization.saved_project_root)/.codex-worktrees/$($unboundOwnerRevision.owner.worktree_id)"
$unboundOwnerValidation = Test-DanioRunState -State $unboundOwnerRevision
Assert-Equal -Actual $unboundOwnerValidation.code -Expected "OWNER_REVISION_INVALID" -Message "Owner revision was not bound to the pending charge."

$unboundChargeRevision = Copy-JsonValue -Value $unboundOwnerRevision
$unboundChargeRevision.budget.current_charge.claimed_revision = 999
$unboundChargeValidation = Test-DanioRunState -State $unboundChargeRevision
Assert-Equal -Actual $unboundChargeValidation.code -Expected "OWNER_REVISION_INVALID" -Message "Active claim revision was not bound to its transition parent."

$escapedWorktree = Copy-JsonValue -Value $active
$escapedWorktree.owner.worktree_path = "D:/foreign/.codex-worktrees/$($escapedWorktree.owner.worktree_id)"
$escapedWorktreeValidation = Test-DanioRunState -State $escapedWorktree
Assert-Equal -Actual $escapedWorktreeValidation.code -Expected "OWNER_IDENTITY_INVALID" -Message "Owner worktree escaped the saved project root."

$badCheckpoint = Copy-JsonValue -Value $handoffReady
$badCheckpoint.last_verified_checkpoint | Add-Member -NotePropertyName "unknown" -NotePropertyValue $true
$badCheckpointValidation = Test-DanioRunState -State $badCheckpoint
Assert-Equal -Actual $badCheckpointValidation.code -Expected "VERIFIED_CHECKPOINT_INVALID" -Message "Unknown checkpoint field was not rejected."

$malformedTransition = Copy-JsonValue -Value $handoffReady
$malformedTransition.transition.PSObject.Properties.Remove("occurred_at_utc")
$malformedTransitionValidation = Test-DanioRunState -State $malformedTransition
Assert-Equal -Actual $malformedTransitionValidation.code -Expected "STATE_TRANSITION_INVALID" -Message "Malformed transition did not return structured rejection before checkpoint chronology validation."

$badRecovery = Copy-JsonValue -Value $ready
$badRecovery.recovery = New-TestRecovery -Owner $active.owner
$badRecovery.recovery | Add-Member -NotePropertyName "unknown" -NotePropertyValue $true
$badRecoveryValidation = Test-DanioRunState -State $badRecovery
Assert-Equal -Actual $badRecoveryValidation.code -Expected "RECOVERY_INVALID" -Message "Unknown recovery field was not rejected."

$badTimestamp = Copy-JsonValue -Value $ready
$badTimestamp.authorization.authorized_at_utc = "2026-99-11T12:00:00.0000000Z"
$badTimestampValidation = Test-DanioRunState -State $badTimestamp
Assert-Equal -Actual $badTimestampValidation.code -Expected "AUTHORIZATION_INVALID" -Message "Semantically invalid UTC timestamp was not rejected."

$unknownField = Copy-JsonValue -Value $ready
$unknownField | Add-Member -NotePropertyName "Product_Complete" -NotePropertyValue $false
$unknownFieldValidation = Test-DanioRunState -State $unknownField
Assert-Equal -Actual $unknownFieldValidation.code -Expected "STATE_UNKNOWN_FIELD" -Message "Unknown or case-drifted state field was not rejected."

$claimFromReady = New-TransitionCandidate -PreviousState $ready -ToMode "active" -Action "claim" -Claim
$claimFromHandoff = New-TransitionCandidate -PreviousState $handoffReady -ToMode "active" -Action "claim" -Claim
$preclaimStopFromReady = New-TransitionCandidate -PreviousState $ready -ToMode "stopped" -Action "preclaim_stop" -ReasonCode "AUTHORITY_CONFLICT"
$preclaimStopFromHandoff = New-TransitionCandidate -PreviousState $handoffReady -ToMode "stopped" -Action "preclaim_stop" -ReasonCode "AUTHORITY_CONFLICT"
$closeout = New-TransitionCandidate -PreviousState $active -ToMode "handoff_ready" -Action "closeout" -Consume
$paused = New-TransitionCandidate -PreviousState $active -ToMode "paused" -Action "pause" -Consume
$stopped = New-TransitionCandidate -PreviousState $active -ToMode "stopped" -Action "stop" -Consume -ReasonCode "BASELINE_FAILED"

$rcActive = Copy-JsonValue -Value $active
$rcActive.cursor.phase = "7-final-phone-candidate"
$rcActive.cursor.work_unit_id = "DCL-RC-001-final-candidate"
$rcActive.cursor.ledger_row_ids = @("DCL-RC-001")
$rcActive.owner = New-TestOwner `
  -RunId ([string]$rcActive.run_id) `
  -WorkUnitId ([string]$rcActive.cursor.work_unit_id) `
  -ExpectedRevision 1
$rcActive.budget.current_charge.work_unit_id = "DCL-RC-001-final-candidate"
$rcActive.budget.current_charge.status = "pending"
$rcActive.budget.current_charge.claimed_revision = 1
$rcActive.budget.current_charge.consumed_revision = $null

$finalize = New-TransitionCandidate `
  -PreviousState $rcActive `
  -ToMode "finalizing" `
  -Action "finalize" `
  -WorkUnitId "DCL-RC-001-final-candidate" `
  -Consume `
  -RetainOwner
$finalize.last_verified_checkpoint.product_commit = ("1" * 40)
$finalize.last_verified_checkpoint.evidence_manifest_path =
  "apps/aquarium_app/docs/agent/autonomous_completion/evidence/$("1" * 40).json"
$finalize.last_verified_checkpoint.verified_at_utc = "2026-07-11T12:08:30.0000000Z"
$terminalComplete = New-TransitionCandidate -PreviousState $finalize -ToMode "complete" -Action "complete"
$finalizationStop = New-TransitionCandidate -PreviousState $finalize -ToMode "stopped" -Action "finalization_stop" -ReasonCode "FINALIZATION_FAILED"
$finalizationStop.recovery = New-TestRecovery -Owner $finalize.owner
$resumePaused = New-TransitionCandidate -PreviousState $paused -ToMode "ready" -Action "resume"
$resumeStopped = New-TransitionCandidate -PreviousState $stopped -ToMode "ready" -Action "resume"
$handoffAdmin = New-TransitionCandidate -PreviousState $handoffReady -ToMode "handoff_ready" -Action "administrative_sync" -Administrative
$completeAdmin = New-TransitionCandidate -PreviousState $complete -ToMode "complete" -Action "administrative_sync" -Administrative
$launch = New-TransitionCandidate -PreviousState $inactive -ToMode "ready" -Action "launch"
$launch.budget.consumed_units = [int]$inactive.budget.consumed_units + 1
$launch.budget.remaining_units_including_current = [int]$inactive.budget.remaining_units_including_current - 1

$finalizationRows = @(Copy-JsonValue -Value $ledgerRows)
foreach ($row in $finalizationRows) {
  if ($activePhaseLedgerIds -contains $row.Id -and $row.Id -ne "DCL-RC-001") {
    $row.ClosureState = "closed"
  }
}
$stoppedRelease = New-TestLeaseRelease -Owner $active.owner
$closeoutRelease = New-TestLeaseRelease -Owner $active.owner
$pauseRelease = New-TestLeaseRelease -Owner $active.owner
$completeRelease = New-TestLeaseRelease -Owner $finalize.owner
$finalizationStopRelease = New-TestLeaseRelease -Owner $finalize.owner

$allowedTransitions = @(
  [pscustomobject]@{ Previous = $inactive; Candidate = $launch; LeaseRelease = $null; FinalizationScope = $false },
  [pscustomobject]@{ Previous = $ready; Candidate = $claimFromReady; LeaseRelease = $null; FinalizationScope = $false },
  [pscustomobject]@{ Previous = $handoffReady; Candidate = $claimFromHandoff; LeaseRelease = $null; FinalizationScope = $false },
  [pscustomobject]@{ Previous = $ready; Candidate = $preclaimStopFromReady; LeaseRelease = $null; FinalizationScope = $false },
  [pscustomobject]@{ Previous = $handoffReady; Candidate = $preclaimStopFromHandoff; LeaseRelease = $null; FinalizationScope = $false },
  [pscustomobject]@{ Previous = $active; Candidate = $closeout; LeaseRelease = $closeoutRelease; FinalizationScope = $false },
  [pscustomobject]@{ Previous = $active; Candidate = $paused; LeaseRelease = $pauseRelease; FinalizationScope = $false },
  [pscustomobject]@{ Previous = $active; Candidate = $stopped; LeaseRelease = $stoppedRelease; FinalizationScope = $false },
  [pscustomobject]@{ Previous = $rcActive; Candidate = $finalize; LeaseRelease = $null; FinalizationScope = $true },
  [pscustomobject]@{ Previous = $finalize; Candidate = $terminalComplete; LeaseRelease = $completeRelease; FinalizationScope = $false },
  [pscustomobject]@{ Previous = $finalize; Candidate = $finalizationStop; LeaseRelease = $finalizationStopRelease; FinalizationScope = $false },
  [pscustomobject]@{ Previous = $paused; Candidate = $resumePaused; LeaseRelease = $null; FinalizationScope = $false },
  [pscustomobject]@{ Previous = $stopped; Candidate = $resumeStopped; LeaseRelease = $null; FinalizationScope = $false },
  [pscustomobject]@{ Previous = $handoffReady; Candidate = $handoffAdmin; LeaseRelease = $null; FinalizationScope = $false },
  [pscustomobject]@{ Previous = $complete; Candidate = $completeAdmin; LeaseRelease = $null; FinalizationScope = $false }
)

foreach ($pair in $allowedTransitions) {
  $transitionParameters = @{
    PreviousState = $pair.Previous
    CandidateState = $pair.Candidate
  }
  if ($null -ne $pair.LeaseRelease) {
    $transitionParameters.LeaseRelease = $pair.LeaseRelease
  }
  if ($pair.FinalizationScope) {
    $transitionParameters.LedgerRows = $finalizationRows
    $transitionParameters.ActivePhaseLedgerIds = $activePhaseLedgerIds
  }
  $transitionResult = Test-DanioRunStateTransition @transitionParameters
  Assert-True `
    -Condition $transitionResult.valid `
    -Message "Allowed transition '$($pair.Previous.mode)>$($pair.Candidate.mode)' failed: $($transitionResult.code) $($transitionResult.details -join '; ')"
}

Assert-Equal -Actual $claimFromReady.budget.consumed_units -Expected $ready.budget.consumed_units -Message "Claim decremented consumed budget."
Assert-Equal -Actual $claimFromReady.budget.remaining_units_including_current -Expected $ready.budget.remaining_units_including_current -Message "Claim decremented remaining budget."
Assert-Equal -Actual $closeout.budget.consumed_units -Expected ([int]$active.budget.consumed_units + 1) -Message "Closeout did not consume exactly once."
Assert-Equal -Actual $finalize.budget.consumed_units -Expected ([int]$rcActive.budget.consumed_units + 1) -Message "Finalization did not consume exactly once."
Assert-Equal -Actual $terminalComplete.budget.consumed_units -Expected $finalize.budget.consumed_units -Message "Completion consumed a second unit."

$forbidden = New-TransitionCandidate -PreviousState $active -ToMode "ready" -Action "resume"
$forbiddenResult = Test-DanioRunStateTransition -PreviousState $active -CandidateState $forbidden
Assert-Equal -Actual $forbiddenResult.code -Expected "TRANSITION_NOT_ALLOWED" -Message "Forbidden transition was not rejected."

$revisionSkip = Copy-JsonValue -Value $closeout
$revisionSkip.state_revision = [int]$active.state_revision + 2
$revisionSkipResult = Test-DanioRunStateTransition -PreviousState $active -CandidateState $revisionSkip
Assert-Equal -Actual $revisionSkipResult.code -Expected "STATE_REVISION_INVALID" -Message "Revision skip was not rejected."

$claimLossCandidate = Copy-JsonValue -Value $ready
$claimLossCandidate.state_revision = [int]$ready.state_revision + 1
$claimLossCandidate.transition = [pscustomobject]@{
  action = "claim"
  from_mode = "ready"
  to_mode = "ready"
  parent_state_revision = [int]$ready.state_revision
  work_unit_id = [string]$ready.cursor.work_unit_id
  reason_code = "WRITER_CLAIM_LOST"
  occurred_at_utc = "2026-07-11T12:10:00.0000000Z"
}
$claimLossResult = Test-DanioRunStateTransition -PreviousState $ready -CandidateState $claimLossCandidate
Assert-True -Condition (-not $claimLossResult.valid) -Message "Writer claim loss must not become durable state."
Assert-Equal -Actual $claimLossCandidate.budget.remaining_units_including_current -Expected $ready.budget.remaining_units_including_current -Message "Writer claim loss decremented budget."

$stopPendingResult = Test-DanioRunStateTransition -PreviousState $active -CandidateState $stopped
Assert-Equal -Actual $stopPendingResult.code -Expected "STOP_PENDING" -Message "Unsafe release did not retain the active lease."
Assert-Equal -Actual $active.mode -Expected "active" -Message "Pure validation mutated the active state."
Assert-Equal -Actual $active.budget.current_charge.status -Expected "pending" -Message "STOP_PENDING mutated the pending charge."

foreach ($unprovenExit in @($closeout, $paused)) {
  $unprovenExitResult = Test-DanioRunStateTransition `
    -PreviousState $active `
    -CandidateState $unprovenExit
  Assert-Equal -Actual $unprovenExitResult.code -Expected "STOP_PENDING" -Message "Owner-releasing active exit lacked lease proof."
}

$unprovenCompleteResult = Test-DanioRunStateTransition `
  -PreviousState $finalize `
  -CandidateState $terminalComplete
Assert-Equal -Actual $unprovenCompleteResult.code -Expected "STOP_PENDING" -Message "Terminal completion lacked lease proof."

$staleTerminalComplete = Copy-JsonValue -Value $terminalComplete
$staleTerminalComplete.last_verified_checkpoint = Copy-JsonValue -Value $finalize.last_verified_checkpoint
$staleTerminalCompleteResult = Test-DanioRunStateTransition `
  -PreviousState $finalize `
  -CandidateState $staleTerminalComplete `
  -LeaseRelease $completeRelease
Assert-Equal -Actual $staleTerminalCompleteResult.code -Expected "VERIFIED_CHECKPOINT_INVALID" -Message "Terminal completion reused candidate-parent evidence."

$finalizationStopPending = Test-DanioRunStateTransition `
  -PreviousState $finalize `
  -CandidateState $finalizationStop
Assert-Equal -Actual $finalizationStopPending.code -Expected "STOP_PENDING" -Message "Unsafe finalization release did not retain its owner."

$zeroBudgetReady = Copy-JsonValue -Value $ready
$zeroBudgetReady.budget.consumed_units = [int]$zeroBudgetReady.budget.total_approved_units
$zeroBudgetReady.budget.remaining_units_including_current = 0
$zeroBudgetClaim = New-TransitionCandidate -PreviousState $zeroBudgetReady -ToMode "active" -Action "claim" -Claim
$zeroBudgetClaimResult = Test-DanioRunStateTransition -PreviousState $zeroBudgetReady -CandidateState $zeroBudgetClaim
Assert-Equal -Actual $zeroBudgetClaimResult.code -Expected "BUDGET_EXHAUSTED" -Message "Zero-budget claim was not rejected."

$lastUnitActive = Copy-JsonValue -Value $active
$lastUnitActive.budget.consumed_units = [int]$lastUnitActive.budget.total_approved_units - 1
$lastUnitActive.budget.remaining_units_including_current = 1
$exhaustedHandoff = New-TransitionCandidate -PreviousState $lastUnitActive -ToMode "handoff_ready" -Action "closeout" -Consume
$exhaustedHandoffResult = Test-DanioRunStateTransition `
  -PreviousState $lastUnitActive `
  -CandidateState $exhaustedHandoff `
  -LeaseRelease (New-TestLeaseRelease -Owner $lastUnitActive.owner)
Assert-Equal -Actual $exhaustedHandoffResult.code -Expected "BUDGET_EXHAUSTED" -Message "Zero post-closeout budget incorrectly allowed handoff."

$zeroBudgetStopped = Copy-JsonValue -Value $stopped
$zeroBudgetStopped.budget.consumed_units = [int]$zeroBudgetStopped.budget.total_approved_units
$zeroBudgetStopped.budget.remaining_units_including_current = 0
$zeroBudgetResume = New-TransitionCandidate -PreviousState $zeroBudgetStopped -ToMode "ready" -Action "resume"
$zeroBudgetResumeResult = Test-DanioRunStateTransition -PreviousState $zeroBudgetStopped -CandidateState $zeroBudgetResume
Assert-Equal -Actual $zeroBudgetResumeResult.code -Expected "BUDGET_EXHAUSTED" -Message "Zero-budget resume was not rejected."

$approvedBudgetResume = Copy-JsonValue -Value $zeroBudgetResume
$approvedBudgetResume.budget.total_approved_units = 22
$approvedBudgetResume.budget.remaining_units_including_current = 2
$approvedBudgetResume.authorization.authorization_id = "danio-phone-bootstrap-resume-001"
$approvedBudgetResume.authorization.authorized_at_utc = "2026-07-11T13:00:00.0000000Z"
$approvedBudgetResumeResult = Test-DanioRunStateTransition -PreviousState $zeroBudgetStopped -CandidateState $approvedBudgetResume
Assert-True -Condition $approvedBudgetResumeResult.valid -Message "Explicitly increased positive budget did not allow resume."

$resumeChargeSwap = Copy-JsonValue -Value $resumeStopped
$resumeChargeSwap.budget.current_charge.work_unit_id = $null
$resumeChargeSwap.budget.current_charge.status = "none"
$resumeChargeSwap.budget.current_charge.claimed_revision = $null
$resumeChargeSwap.budget.current_charge.consumed_revision = $null
$resumeChargeSwapResult = Test-DanioRunStateTransition -PreviousState $stopped -CandidateState $resumeChargeSwap
Assert-Equal -Actual $resumeChargeSwapResult.code -Expected "RESUME_BUDGET_INVALID" -Message "Resume replaced consumed charge attribution."

$wrongWorkUnitCloseout = Copy-JsonValue -Value $closeout
$wrongWorkUnitCloseout.transition.work_unit_id = "DCL-OTHER-001"
$wrongWorkUnitCloseout.budget.current_charge.work_unit_id = "DCL-OTHER-001"
$wrongWorkUnitResult = Test-DanioRunStateTransition `
  -PreviousState $active `
  -CandidateState $wrongWorkUnitCloseout `
  -LeaseRelease $closeoutRelease
Assert-Equal -Actual $wrongWorkUnitResult.code -Expected "WORK_UNIT_ATTRIBUTION_INVALID" -Message "Closeout charge escaped the owned work unit."

$wrongClaimRevision = Copy-JsonValue -Value $claimFromReady
$wrongClaimRevision.owner.claim_revision = 999
$wrongClaimRevision.budget.current_charge.claimed_revision = 999
$wrongClaimRevision.owner.token_sha256 = Get-ExpectedOwnerToken `
  -RunId ([string]$wrongClaimRevision.run_id) `
  -WorkUnitId ([string]$wrongClaimRevision.cursor.work_unit_id) `
  -TaskId ([string]$wrongClaimRevision.owner.task_id) `
  -ExpectedRevision 999
$wrongClaimToken12 = $wrongClaimRevision.owner.token_sha256.Substring(0, 12)
$wrongClaimRevision.owner.branch_name = "autonomy/$($wrongClaimRevision.run_id)/$($wrongClaimRevision.cursor.work_unit_id)/$wrongClaimToken12"
$wrongClaimRevision.owner.worktree_id = "$($wrongClaimRevision.run_id)-$($wrongClaimRevision.cursor.work_unit_id)-$wrongClaimToken12"
$wrongClaimRevision.owner.worktree_path = "$($wrongClaimRevision.authorization.saved_project_root)/.codex-worktrees/$($wrongClaimRevision.owner.worktree_id)"
$wrongClaimRevisionResult = Test-DanioRunStateTransition -PreviousState $ready -CandidateState $wrongClaimRevision
Assert-Equal -Actual $wrongClaimRevisionResult.code -Expected "OWNER_REVISION_INVALID" -Message "Claim owner was not bound to the parent revision."

$claimRunSwap = Copy-JsonValue -Value $claimFromReady
$claimRunSwap.run_id = "different-run"
$claimRunSwap.owner = New-TestOwner `
  -RunId ([string]$claimRunSwap.run_id) `
  -WorkUnitId ([string]$claimRunSwap.cursor.work_unit_id) `
  -ExpectedRevision ([int64]$ready.state_revision)
$claimRunSwapResult = Test-DanioRunStateTransition -PreviousState $ready -CandidateState $claimRunSwap
Assert-Equal -Actual $claimRunSwapResult.code -Expected "CLAIM_SCOPE_INVALID" -Message "Claim replaced run identity."

$claimRootSwap = Copy-JsonValue -Value $claimFromReady
$claimRootSwap.authorization.saved_project_root = "D:/Alternate Danio Project"
$claimRootSwap.authorization.repository_root = "D:/Alternate Danio Project/repo"
$claimRootSwap.owner.worktree_path = "$($claimRootSwap.authorization.saved_project_root)/.codex-worktrees/$($claimRootSwap.owner.worktree_id)"
$claimRootSwapResult = Test-DanioRunStateTransition -PreviousState $ready -CandidateState $claimRootSwap
Assert-Equal -Actual $claimRootSwapResult.code -Expected "CLAIM_SCOPE_INVALID" -Message "Claim replaced saved-project authorization."

$claimAuthoritySwap = Copy-JsonValue -Value $claimFromReady
$claimAuthoritySwap.authority.finish_map.commit = ("0" * 40)
$claimAuthoritySwapResult = Test-DanioRunStateTransition -PreviousState $ready -CandidateState $claimAuthoritySwap
Assert-Equal -Actual $claimAuthoritySwapResult.code -Expected "CLAIM_SCOPE_INVALID" -Message "Claim replaced authority references."

$claimGenerationSwap = Copy-JsonValue -Value $claimFromReady
$claimGenerationSwap.handoff_generation = [int]$claimGenerationSwap.handoff_generation + 1
$claimGenerationSwapResult = Test-DanioRunStateTransition -PreviousState $ready -CandidateState $claimGenerationSwap
Assert-Equal -Actual $claimGenerationSwapResult.code -Expected "CLAIM_SCOPE_INVALID" -Message "Claim replaced handoff generation."

$claimCursorSwap = Copy-JsonValue -Value $claimFromReady
$claimCursorSwap.cursor.phase = "different-phase"
$claimCursorSwap.cursor.ledger_row_ids = @("DCL-DR-002")
$claimCursorSwapResult = Test-DanioRunStateTransition -PreviousState $ready -CandidateState $claimCursorSwap
Assert-Equal -Actual $claimCursorSwapResult.code -Expected "CLAIM_SCOPE_INVALID" -Message "Claim replaced phase or ledger-row scope."

$nonRcFinalize = New-TransitionCandidate `
  -PreviousState $active `
  -ToMode "finalizing" `
  -Action "finalize" `
  -Consume `
  -RetainOwner
$nonRcFinalizeResult = Test-DanioRunStateTransition `
  -PreviousState $active `
  -CandidateState $nonRcFinalize `
  -LedgerRows $finalizationRows `
  -ActivePhaseLedgerIds $activePhaseLedgerIds
Assert-Equal -Actual $nonRcFinalizeResult.code -Expected "FINALIZATION_SCOPE_INVALID" -Message "Non-RC work unit entered finalization."

$openPrerequisiteFinalizeResult = Test-DanioRunStateTransition `
  -PreviousState $rcActive `
  -CandidateState $finalize `
  -LedgerRows $ledgerRows `
  -ActivePhaseLedgerIds $activePhaseLedgerIds
Assert-Equal -Actual $openPrerequisiteFinalizeResult.code -Expected "FINALIZATION_SCOPE_INVALID" -Message "Open non-RC prerequisites allowed finalization."

$malformedCandidate = Copy-JsonValue -Value $closeout
$malformedCandidate.PSObject.Properties.Remove("mode")
$malformedCandidateResult = Test-DanioRunStateTransition -PreviousState $active -CandidateState $malformedCandidate
Assert-True -Condition (-not $malformedCandidateResult.valid) -Message "Malformed transition candidate was not rejected structurally."

$nullCandidateResult = Test-DanioRunStateTransition -PreviousState $active -CandidateState $null
Assert-True -Condition (-not $nullCandidateResult.valid) -Message "Null transition candidate did not return structured rejection."

$badAdmin = Copy-JsonValue -Value $handoffAdmin
$badAdmin.cursor.work_unit_id = "DCL-DR-099-forbidden-change"
$badAdminResult = Test-DanioRunStateTransition -PreviousState $handoffReady -CandidateState $badAdmin
Assert-Equal -Actual $badAdminResult.code -Expected "ADMINISTRATIVE_CHANGE_FORBIDDEN" -Message "Administrative update changed product cursor."

$completionRows = @(Copy-JsonValue -Value $ledgerRows)
$finalProductCommit = ("2" * 40)
$evidenceLedgerParentCommit = ("3" * 40)
$finalManifestPath = "apps/aquarium_app/docs/agent/autonomous_completion/evidence/$finalProductCommit.json"
foreach ($row in $completionRows) {
  if ($activePhaseLedgerIds -contains $row.Id) {
    $row.ClosureState = "closed"
  }
}
$releaseCandidateRow = $completionRows | Where-Object { $_.Id -eq "DCL-RC-001" } | Select-Object -First 1
$releaseCandidateRow.Evidence = "Final evidence manifest $finalManifestPath for product $finalProductCommit"

$evidenceChecks = @(
  "FULL",
  "ANDROID_PREP",
  "CONTENT",
  "VISUAL",
  "PRODUCT_TRUTH",
  "PHONE_QA"
) | ForEach-Object {
  [pscustomobject]@{
    code = $_
    status = "pass"
    product_commit = $finalProductCommit
  }
}
$evidence = [pscustomobject]@{
  product_commit = $finalProductCommit
  manifest_path = $finalManifestPath
  checkpoint_commit = $evidenceLedgerParentCommit
  checks = @($evidenceChecks)
}
$cleanup = [pscustomobject]@{
  owner_token = [string]$finalize.owner.token_sha256
  branch_name = [string]$finalize.owner.branch_name
  worktree_id = [string]$finalize.owner.worktree_id
  worktree_path = [string]$finalize.owner.worktree_path
  branch_removed = $true
  worktree_removed = $true
  device_released = $true
}
$repositoryObservation = [pscustomobject]@{
  parent_commit = $evidenceLedgerParentCommit
  origin_main_commit = $evidenceLedgerParentCommit
  ahead = 0
  behind = 0
  clean = $true
}
Assert-True `
  -Condition (
    [string]$finalize.last_verified_checkpoint.product_commit -cne $finalProductCommit -and
    $finalProductCommit -cne $evidenceLedgerParentCommit -and
    [string]$finalize.last_verified_checkpoint.product_commit -cne $evidenceLedgerParentCommit
  ) `
  -Message "Terminal proof must keep prior state, final product, and evidence-parent commits distinct."

$completionReady = Test-DanioCompletionReadiness `
  -State $finalize `
  -LedgerRows $completionRows `
  -ActivePhaseLedgerIds $activePhaseLedgerIds `
  -Evidence $evidence `
  -Cleanup $cleanup `
  -RepositoryObservation $repositoryObservation
Assert-True -Condition $completionReady.ready -Message "Normalized completion inputs should be ready: $($completionReady.details -join '; ')"
Assert-Equal -Actual $completionReady.code -Expected "COMPLETION_READY" -Message "Completion readiness code mismatch."

$priorEqualsProductState = Copy-JsonValue -Value $finalize
$priorEqualsProductState.last_verified_checkpoint.product_commit = $finalProductCommit
$priorEqualsProductState.last_verified_checkpoint.evidence_manifest_path = $finalManifestPath
$priorEqualsProduct = Test-DanioCompletionReadiness `
  -State $priorEqualsProductState `
  -LedgerRows $completionRows `
  -ActivePhaseLedgerIds $activePhaseLedgerIds `
  -Evidence $evidence `
  -Cleanup $cleanup `
  -RepositoryObservation $repositoryObservation
Assert-Equal -Actual $priorEqualsProduct.code -Expected "COMPLETION_NOT_READY" -Message "Prior finalizing checkpoint and final product commit were not required to be distinct."

$productEqualsParentEvidence = Copy-JsonValue -Value $evidence
$productEqualsParentEvidence.checkpoint_commit = $finalProductCommit
$productEqualsParentRepository = Copy-JsonValue -Value $repositoryObservation
$productEqualsParentRepository.parent_commit = $finalProductCommit
$productEqualsParentRepository.origin_main_commit = $finalProductCommit
$productEqualsParent = Test-DanioCompletionReadiness `
  -State $finalize `
  -LedgerRows $completionRows `
  -ActivePhaseLedgerIds $activePhaseLedgerIds `
  -Evidence $productEqualsParentEvidence `
  -Cleanup $cleanup `
  -RepositoryObservation $productEqualsParentRepository
Assert-Equal -Actual $productEqualsParent.code -Expected "COMPLETION_NOT_READY" -Message "Final product and evidence-ledger parent commits were not required to be distinct."

$priorEqualsParentEvidence = Copy-JsonValue -Value $evidence
$priorEqualsParentEvidence.checkpoint_commit = [string]$finalize.last_verified_checkpoint.product_commit
$priorEqualsParentRepository = Copy-JsonValue -Value $repositoryObservation
$priorEqualsParentRepository.parent_commit = [string]$finalize.last_verified_checkpoint.product_commit
$priorEqualsParentRepository.origin_main_commit = [string]$finalize.last_verified_checkpoint.product_commit
$priorEqualsParent = Test-DanioCompletionReadiness `
  -State $finalize `
  -LedgerRows $completionRows `
  -ActivePhaseLedgerIds $activePhaseLedgerIds `
  -Evidence $priorEqualsParentEvidence `
  -Cleanup $cleanup `
  -RepositoryObservation $priorEqualsParentRepository
Assert-Equal -Actual $priorEqualsParent.code -Expected "COMPLETION_NOT_READY" -Message "Prior finalizing checkpoint and evidence-ledger parent commits were not required to be distinct."

$nullStateCompletion = Test-DanioCompletionReadiness `
  -State $null `
  -LedgerRows $completionRows `
  -ActivePhaseLedgerIds $activePhaseLedgerIds `
  -Evidence $evidence `
  -Cleanup $cleanup `
  -RepositoryObservation $repositoryObservation
Assert-Equal -Actual $nullStateCompletion.code -Expected "COMPLETION_NOT_READY" -Message "Null completion state did not return structured rejection."

$nullEvidenceCompletion = Test-DanioCompletionReadiness `
  -State $finalize `
  -LedgerRows $completionRows `
  -ActivePhaseLedgerIds $activePhaseLedgerIds `
  -Evidence $null `
  -Cleanup $cleanup `
  -RepositoryObservation $repositoryObservation
Assert-Equal -Actual $nullEvidenceCompletion.code -Expected "COMPLETION_NOT_READY" -Message "Null completion evidence did not return structured rejection."

$openCompletionRows = @(Copy-JsonValue -Value $completionRows)
($openCompletionRows | Where-Object { $_.Id -eq "DCL-DR-001" }).ClosureState = "open"
$openCompletion = Test-DanioCompletionReadiness `
  -State $finalize `
  -LedgerRows $openCompletionRows `
  -ActivePhaseLedgerIds $activePhaseLedgerIds `
  -Evidence $evidence `
  -Cleanup $cleanup `
  -RepositoryObservation $repositoryObservation
Assert-Equal -Actual $openCompletion.code -Expected "COMPLETION_NOT_READY" -Message "Open active row did not block completion."

$truncatedScopeCompletion = Test-DanioCompletionReadiness `
  -State $finalize `
  -LedgerRows $completionRows `
  -ActivePhaseLedgerIds @("DCL-RC-001") `
  -Evidence $evidence `
  -Cleanup $cleanup `
  -RepositoryObservation $repositoryObservation
Assert-Equal -Actual $truncatedScopeCompletion.code -Expected "COMPLETION_NOT_READY" -Message "Truncated active scope did not block completion."

$emptyScopeCompletion = Test-DanioCompletionReadiness `
  -State $finalize `
  -LedgerRows $completionRows `
  -ActivePhaseLedgerIds @() `
  -Evidence $evidence `
  -Cleanup $cleanup `
  -RepositoryObservation $repositoryObservation
Assert-Equal -Actual $emptyScopeCompletion.code -Expected "COMPLETION_NOT_READY" -Message "Empty active scope did not block completion."

$staleReleaseCandidateRows = @(Copy-JsonValue -Value $completionRows)
($staleReleaseCandidateRows | Where-Object { $_.Id -eq "DCL-RC-001" }).Evidence = "Final evidence checkpoint 0000000000000000000000000000000000000000"
$staleReleaseCandidateCompletion = Test-DanioCompletionReadiness `
  -State $finalize `
  -LedgerRows $staleReleaseCandidateRows `
  -ActivePhaseLedgerIds $activePhaseLedgerIds `
  -Evidence $evidence `
  -Cleanup $cleanup `
  -RepositoryObservation $repositoryObservation
Assert-Equal -Actual $staleReleaseCandidateCompletion.code -Expected "COMPLETION_NOT_READY" -Message "DCL-RC closure was not tied to the final evidence checkpoint."

$missingReleaseCandidateEvidenceRows = @(Copy-JsonValue -Value $completionRows)
$missingReleaseCandidateEvidence = $missingReleaseCandidateEvidenceRows |
  Where-Object { $_.Id -eq "DCL-RC-001" } |
  Select-Object -First 1
$missingReleaseCandidateEvidence.PSObject.Properties.Remove("Evidence")
$missingReleaseCandidateEvidenceCompletion = Test-DanioCompletionReadiness `
  -State $finalize `
  -LedgerRows $missingReleaseCandidateEvidenceRows `
  -ActivePhaseLedgerIds $activePhaseLedgerIds `
  -Evidence $evidence `
  -Cleanup $cleanup `
  -RepositoryObservation $repositoryObservation
Assert-Equal -Actual $missingReleaseCandidateEvidenceCompletion.code -Expected "COMPLETION_NOT_READY" -Message "Missing RC evidence did not return structured rejection."

$malformedEvidenceChecks = Copy-JsonValue -Value $evidence
$malformedEvidenceChecks.checks = @($malformedEvidenceChecks.checks) + @($null)
$malformedEvidenceCompletion = Test-DanioCompletionReadiness `
  -State $finalize `
  -LedgerRows $completionRows `
  -ActivePhaseLedgerIds $activePhaseLedgerIds `
  -Evidence $malformedEvidenceChecks `
  -Cleanup $cleanup `
  -RepositoryObservation $repositoryObservation
Assert-Equal -Actual $malformedEvidenceCompletion.code -Expected "COMPLETION_NOT_READY" -Message "Malformed evidence check did not return structured rejection."

$missingEvidence = Copy-JsonValue -Value $evidence
$missingEvidence.checks = @($missingEvidence.checks | Where-Object { $_.code -ne "PHONE_QA" })
$evidenceCompletion = Test-DanioCompletionReadiness `
  -State $finalize `
  -LedgerRows $completionRows `
  -ActivePhaseLedgerIds $activePhaseLedgerIds `
  -Evidence $missingEvidence `
  -Cleanup $cleanup `
  -RepositoryObservation $repositoryObservation
Assert-Equal -Actual $evidenceCompletion.code -Expected "COMPLETION_NOT_READY" -Message "Missing phone QA evidence did not block completion."

$foreignCleanup = Copy-JsonValue -Value $cleanup
$foreignCleanup.owner_token = ("0" * 64)
$cleanupCompletion = Test-DanioCompletionReadiness `
  -State $finalize `
  -LedgerRows $completionRows `
  -ActivePhaseLedgerIds $activePhaseLedgerIds `
  -Evidence $evidence `
  -Cleanup $foreignCleanup `
  -RepositoryObservation $repositoryObservation
Assert-Equal -Actual $cleanupCompletion.code -Expected "COMPLETION_NOT_READY" -Message "Foreign cleanup lease did not block completion."

$foreignPathCleanup = Copy-JsonValue -Value $cleanup
$foreignPathCleanup.worktree_path = "D:/foreign/.codex-worktrees/$($finalize.owner.worktree_id)"
$foreignPathCompletion = Test-DanioCompletionReadiness `
  -State $finalize `
  -LedgerRows $completionRows `
  -ActivePhaseLedgerIds $activePhaseLedgerIds `
  -Evidence $evidence `
  -Cleanup $foreignPathCleanup `
  -RepositoryObservation $repositoryObservation
Assert-Equal -Actual $foreignPathCompletion.code -Expected "COMPLETION_NOT_READY" -Message "Foreign worktree cleanup did not block completion."

$stringBooleanObservation = Copy-JsonValue -Value $repositoryObservation
$stringBooleanObservation.clean = "false"
$stringBooleanCompletion = Test-DanioCompletionReadiness `
  -State $finalize `
  -LedgerRows $completionRows `
  -ActivePhaseLedgerIds $activePhaseLedgerIds `
  -Evidence $evidence `
  -Cleanup $cleanup `
  -RepositoryObservation $stringBooleanObservation
Assert-Equal -Actual $stringBooleanCompletion.code -Expected "COMPLETION_NOT_READY" -Message "String repository boolean bypassed completion proof."

$stringCleanup = Copy-JsonValue -Value $cleanup
$stringCleanup.branch_removed = "false"
$stringCleanupCompletion = Test-DanioCompletionReadiness `
  -State $finalize `
  -LedgerRows $completionRows `
  -ActivePhaseLedgerIds $activePhaseLedgerIds `
  -Evidence $evidence `
  -Cleanup $stringCleanup `
  -RepositoryObservation $repositoryObservation
Assert-Equal -Actual $stringCleanupCompletion.code -Expected "COMPLETION_NOT_READY" -Message "String cleanup boolean bypassed completion proof."

$emptyCheckpointEvidence = Copy-JsonValue -Value $evidence
$emptyCheckpointEvidence.checkpoint_commit = ""
$emptyCheckpointRepository = Copy-JsonValue -Value $repositoryObservation
$emptyCheckpointRepository.parent_commit = ""
$emptyCheckpointRepository.origin_main_commit = ""
$emptyCheckpointCompletion = Test-DanioCompletionReadiness `
  -State $finalize `
  -LedgerRows $completionRows `
  -ActivePhaseLedgerIds $activePhaseLedgerIds `
  -Evidence $emptyCheckpointEvidence `
  -Cleanup $cleanup `
  -RepositoryObservation $emptyCheckpointRepository
Assert-Equal -Actual $emptyCheckpointCompletion.code -Expected "COMPLETION_NOT_READY" -Message "Empty checkpoint values bypassed completion proof."

$ledgerHashAfter = (Get-FileHash -Algorithm SHA256 -LiteralPath $ledgerPath).Hash
Assert-Equal -Actual $ledgerHashAfter -Expected $ledgerHashBefore -Message "Pure behavior tests changed the ledger."

[pscustomobject]@{
  document_type = "danio_autonomous_completion_behavior_test_result"
  schema_version = 1
  passed = $true
  allowed_transition_count = $allowedTransitions.Count
  ledger_row_count = $ledgerRows.Count
} | ConvertTo-Json -Compress
