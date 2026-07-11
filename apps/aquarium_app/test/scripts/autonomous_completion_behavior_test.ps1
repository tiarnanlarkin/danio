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
    [Parameter(Mandatory = $true)][int]$ExpectedRevision
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
    [Parameter(Mandatory = $true)][int]$ExpectedRevision
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
      -ExpectedRevision ([int]$PreviousState.state_revision)
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
Assert-Equal -Actual $ledgerRows.Count -Expected 27 -Message "Bootstrap ledger row count changed unexpectedly."
Assert-Equal -Actual @($ledgerRows | Where-Object { $_.ClosureState -eq "open" }).Count -Expected 18 -Message "Bootstrap open count mismatch."
Assert-Equal -Actual @($ledgerRows | Where-Object { $_.ClosureState -eq "parked" }).Count -Expected 5 -Message "Bootstrap parked count mismatch."
Assert-Equal -Actual @($ledgerRows | Where-Object { $_.ClosureState -eq "closed" }).Count -Expected 4 -Message "Bootstrap closed count mismatch."
Assert-Equal -Actual @($ledgerRows | Where-Object { $_.ClosureState -eq "decision_required" }).Count -Expected 0 -Message "Bootstrap decision count mismatch."

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
$terminalComplete = New-TransitionCandidate -PreviousState $finalize -ToMode "complete" -Action "complete"
$finalizationStop = New-TransitionCandidate -PreviousState $finalize -ToMode "stopped" -Action "finalization_stop" -ReasonCode "FINALIZATION_FAILED"
$resumePaused = New-TransitionCandidate -PreviousState $paused -ToMode "ready" -Action "resume"
$resumeStopped = New-TransitionCandidate -PreviousState $stopped -ToMode "ready" -Action "resume"
$handoffAdmin = New-TransitionCandidate -PreviousState $handoffReady -ToMode "handoff_ready" -Action "administrative_sync" -Administrative
$completeAdmin = New-TransitionCandidate -PreviousState $complete -ToMode "complete" -Action "administrative_sync" -Administrative
$launch = New-TransitionCandidate -PreviousState $inactive -ToMode "ready" -Action "launch"
$launch.budget.consumed_units = [int]$inactive.budget.consumed_units + 1
$launch.budget.remaining_units_including_current = [int]$inactive.budget.remaining_units_including_current - 1

$allowedTransitions = @(
  [pscustomobject]@{ Previous = $inactive; Candidate = $launch },
  [pscustomobject]@{ Previous = $ready; Candidate = $claimFromReady },
  [pscustomobject]@{ Previous = $handoffReady; Candidate = $claimFromHandoff },
  [pscustomobject]@{ Previous = $ready; Candidate = $preclaimStopFromReady },
  [pscustomobject]@{ Previous = $handoffReady; Candidate = $preclaimStopFromHandoff },
  [pscustomobject]@{ Previous = $active; Candidate = $closeout },
  [pscustomobject]@{ Previous = $active; Candidate = $paused },
  [pscustomobject]@{ Previous = $active; Candidate = $stopped },
  [pscustomobject]@{ Previous = $rcActive; Candidate = $finalize },
  [pscustomobject]@{ Previous = $finalize; Candidate = $terminalComplete },
  [pscustomobject]@{ Previous = $finalize; Candidate = $finalizationStop },
  [pscustomobject]@{ Previous = $paused; Candidate = $resumePaused },
  [pscustomobject]@{ Previous = $stopped; Candidate = $resumeStopped },
  [pscustomobject]@{ Previous = $handoffReady; Candidate = $handoffAdmin },
  [pscustomobject]@{ Previous = $complete; Candidate = $completeAdmin }
)

foreach ($pair in $allowedTransitions) {
  $transitionResult = Test-DanioRunStateTransition `
    -PreviousState $pair.Previous `
    -CandidateState $pair.Candidate
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

$stopPending = Copy-JsonValue -Value $active
$stopPending.state_revision = [int]$active.state_revision + 1
$stopPending.mode = "stopped"
$stopPending.transition = [pscustomobject]@{
  action = "stop"
  from_mode = "active"
  to_mode = "stopped"
  parent_state_revision = [int]$active.state_revision
  work_unit_id = [string]$active.cursor.work_unit_id
  reason_code = "BASELINE_FAILED"
  occurred_at_utc = "2026-07-11T12:10:00.0000000Z"
}
$stopPendingResult = Test-DanioRunStateTransition -PreviousState $active -CandidateState $stopPending
Assert-Equal -Actual $stopPendingResult.code -Expected "STOP_PENDING" -Message "Unsafe release did not retain the active lease."
Assert-Equal -Actual $active.mode -Expected "active" -Message "Pure validation mutated the active state."
Assert-Equal -Actual $active.budget.current_charge.status -Expected "pending" -Message "STOP_PENDING mutated the pending charge."

$badAdmin = Copy-JsonValue -Value $handoffAdmin
$badAdmin.cursor.work_unit_id = "DCL-DR-099-forbidden-change"
$badAdminResult = Test-DanioRunStateTransition -PreviousState $handoffReady -CandidateState $badAdmin
Assert-Equal -Actual $badAdminResult.code -Expected "ADMINISTRATIVE_CHANGE_FORBIDDEN" -Message "Administrative update changed product cursor."

$completionRows = @(Copy-JsonValue -Value $ledgerRows)
foreach ($row in $completionRows) {
  if ($activePhaseLedgerIds -contains $row.Id) {
    $row.ClosureState = "closed"
  }
}

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
    checkpoint_commit = "f10b6021e083ba745fc2abf254f7ca91093d703e"
  }
}
$evidence = [pscustomobject]@{
  checkpoint_commit = "f10b6021e083ba745fc2abf254f7ca91093d703e"
  checks = @($evidenceChecks)
}
$cleanup = [pscustomobject]@{
  owner_token = [string]$finalize.owner.token_sha256
  branch_removed = $true
  worktree_removed = $true
  device_released = $true
}
$repositoryObservation = [pscustomobject]@{
  parent_commit = "f10b6021e083ba745fc2abf254f7ca91093d703e"
  origin_main_commit = "f10b6021e083ba745fc2abf254f7ca91093d703e"
  ahead = 0
  behind = 0
  clean = $true
}

$completionReady = Test-DanioCompletionReadiness `
  -State $finalize `
  -LedgerRows $completionRows `
  -ActivePhaseLedgerIds $activePhaseLedgerIds `
  -Evidence $evidence `
  -Cleanup $cleanup `
  -RepositoryObservation $repositoryObservation
Assert-True -Condition $completionReady.ready -Message "Normalized completion inputs should be ready: $($completionReady.details -join '; ')"
Assert-Equal -Actual $completionReady.code -Expected "COMPLETION_READY" -Message "Completion readiness code mismatch."

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

$ledgerHashAfter = (Get-FileHash -Algorithm SHA256 -LiteralPath $ledgerPath).Hash
Assert-Equal -Actual $ledgerHashAfter -Expected $ledgerHashBefore -Message "Pure behavior tests changed the ledger."

[pscustomobject]@{
  document_type = "danio_autonomous_completion_behavior_test_result"
  schema_version = 1
  passed = $true
  allowed_transition_count = $allowedTransitions.Count
  ledger_row_count = $ledgerRows.Count
} | ConvertTo-Json -Compress
