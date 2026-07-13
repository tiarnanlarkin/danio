[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-Equal {
  param(
    $Actual,
    $Expected,
    [Parameter(Mandatory = $true)][string]$Message
  )

  if ($Actual -ne $Expected) {
    throw "$Message Expected '$Expected', found '$Actual'."
  }
}

function Invoke-Git {
  param(
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string[]]$Arguments
  )

  $priorPreference = $ErrorActionPreference
  try {
    $ErrorActionPreference = "Continue"
    $output = @(& git -c core.longpaths=true -C $RepositoryRoot @Arguments 2>&1)
    $exitCode = $LASTEXITCODE
  } finally {
    $ErrorActionPreference = $priorPreference
  }
  if ($exitCode -ne 0) {
    throw "git $($Arguments -join ' ') failed ($exitCode): $($output -join "`n")"
  }
  return ($output -join "`n").TrimEnd()
}

function Get-RepositorySnapshot {
  param([Parameter(Mandatory = $true)][string]$RepositoryRoot)

  $indexPath = Invoke-Git `
    -RepositoryRoot $RepositoryRoot `
    -Arguments @("rev-parse", "--path-format=absolute", "--git-path", "index")
  $paths = @(
    Invoke-Git `
      -RepositoryRoot $RepositoryRoot `
      -Arguments @("ls-files", "--cached", "--others", "--exclude-standard") |
      ForEach-Object { $_ -split "`n" } |
      Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
  )
  [Array]::Sort($paths, [StringComparer]::Ordinal)
  $fileBytes = @(
    foreach ($path in $paths) {
      $candidate = [IO.Path]::GetFullPath((Join-Path $RepositoryRoot $path))
      $requiredPrefix = [IO.Path]::GetFullPath($RepositoryRoot).TrimEnd("\", "/") +
        [IO.Path]::DirectorySeparatorChar
      if (-not $candidate.StartsWith($requiredPrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Fixture path escaped repository root: $path"
      }
      if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
        "$path missing"
      } else {
        "$path $((Get-FileHash -Algorithm SHA256 -LiteralPath $candidate).Hash.ToLowerInvariant())"
      }
    }
  )
  return [pscustomobject]@{
    refs = Invoke-Git -RepositoryRoot $RepositoryRoot -Arguments @("show-ref")
    index_sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $indexPath).Hash
    worktrees = Invoke-Git -RepositoryRoot $RepositoryRoot -Arguments @("worktree", "list", "--porcelain")
    status = Invoke-Git -RepositoryRoot $RepositoryRoot -Arguments @("--no-optional-locks", "status", "--short", "-uall")
    files = $fileBytes -join "`n"
  }
}

function Assert-RepositorySnapshotEqual {
  param(
    [Parameter(Mandatory = $true)]$Before,
    [Parameter(Mandatory = $true)]$After,
    [Parameter(Mandatory = $true)][string]$Scenario
  )

  foreach ($field in @("refs", "index_sha256", "worktrees", "status", "files")) {
    Assert-Equal `
      -Actual $After.$field `
      -Expected $Before.$field `
      -Message "Validator mutated '$field' during $Scenario."
  }
}

function Write-Utf8Text {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$Content
  )

  $parent = Split-Path -Parent $Path
  if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
  }
  [IO.File]::WriteAllText($Path, $Content, (New-Object Text.UTF8Encoding($false)))
}

function Write-Json {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)]$Value
  )

  Write-Utf8Text -Path $Path -Content ($Value | ConvertTo-Json -Depth 100)
}

function Get-AuthoritySnapshot {
  param(
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string]$Commit
  )

  $paths = [ordered]@{
    phone_completion_program = "apps/aquarium_app/docs/agent/plans/2026-07-11-phone-complete-local-completion-program.md"
    closure_ledger = "apps/aquarium_app/docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md"
    finish_map = "apps/aquarium_app/docs/agent/FINISH_MAP.md"
    quality_ladder = "apps/aquarium_app/docs/agent/QUALITY_LADDER.md"
    verified_slice_execution_contract = "apps/aquarium_app/docs/agent/VERIFIED_SLICE_EXECUTION_CONTRACT.md"
    active_handoff = "apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md"
    device_ownership_policy = "apps/aquarium_app/docs/agent/DEVICE_OWNERSHIP.md"
  }
  $authority = [ordered]@{}
  foreach ($entry in $paths.GetEnumerator()) {
    $authority[$entry.Key] = [pscustomobject][ordered]@{
      path = [string]$entry.Value
      commit = $Commit
      blob_oid = Invoke-Git `
        -RepositoryRoot $RepositoryRoot `
        -Arguments @("rev-parse", "$Commit`:$($entry.Value)")
    }
  }
  return [pscustomobject]$authority
}

function Stage-ActivationCandidate {
  param(
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string]$ParentCommit,
    [Parameter(Mandatory = $true)]$CandidateState,
    [Parameter(Mandatory = $true)][string]$StatePath,
    [Parameter(Mandatory = $true)][string]$HandoffPath,
    [Parameter(Mandatory = $true)][string]$HandoffContent,
    [Parameter(Mandatory = $true)][string]$SliceLogPath,
    [Parameter(Mandatory = $true)][string]$SliceLogContent
  )

  $stagedCandidate = $CandidateState | ConvertTo-Json -Depth 100 | ConvertFrom-Json
  $stagedCandidate.authority = Get-AuthoritySnapshot `
    -RepositoryRoot $RepositoryRoot `
    -Commit $ParentCommit
  Write-Json -Path (Join-Path $RepositoryRoot $StatePath) -Value $stagedCandidate
  Write-Utf8Text -Path (Join-Path $RepositoryRoot $HandoffPath) -Content $HandoffContent
  Write-Utf8Text -Path (Join-Path $RepositoryRoot $SliceLogPath) -Content $SliceLogContent
  [void](Invoke-Git `
    -RepositoryRoot $RepositoryRoot `
    -Arguments @("add", $StatePath, $HandoffPath, $SliceLogPath))
  return [pscustomobject]@{
    state = $stagedCandidate
    tree_hash = Invoke-Git -RepositoryRoot $RepositoryRoot -Arguments @("write-tree")
  }
}

function New-ClaimCandidate {
  param(
    [Parameter(Mandatory = $true)]$ReadyState,
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string]$ParentCommit,
    [Parameter(Mandatory = $true)][string]$SavedProjectRoot
  )

  $candidate = $ReadyState | ConvertTo-Json -Depth 100 | ConvertFrom-Json
  $candidate.state_revision = 2
  $candidate.mode = "active"
  $candidate.transition = [pscustomobject][ordered]@{
    action = "claim"
    from_mode = "ready"
    to_mode = "active"
    parent_state_revision = 1
    work_unit_id = [string]$candidate.cursor.work_unit_id
    reason_code = $null
    occurred_at_utc = "2026-07-13T12:01:00.0000000Z"
  }
  $taskId = "task-activation-fixture-claim"
  $token = & $danioModule {
    param($RunId, $WorkUnitId, $TaskId)
    Get-DanioOwnerToken `
      -RunId $RunId `
      -WorkUnitId $WorkUnitId `
      -TaskId $TaskId `
      -ExpectedRevision 1
  } ([string]$candidate.run_id) ([string]$candidate.cursor.work_unit_id) $taskId
  $token12 = $token.Substring(0, 12)
  $worktreeId = "$($candidate.run_id)-$($candidate.cursor.work_unit_id)-$token12"
  $candidate.owner = [pscustomobject][ordered]@{
    task_id = $taskId
    token_sha256 = $token
    claim_revision = 1
    claim_parent_commit = $ParentCommit
    claim_staged_tree_hash = Invoke-Git `
      -RepositoryRoot $RepositoryRoot `
      -Arguments @("rev-parse", "$ParentCommit^{tree}")
    branch_name = "autonomy/$($candidate.run_id)/$($candidate.cursor.work_unit_id)/$token12"
    worktree_id = $worktreeId
    worktree_path = "$SavedProjectRoot/.codex-worktrees/$worktreeId"
    claimed_at_utc = "2026-07-13T12:01:00.0000000Z"
    writer_lease_released = $false
    android_lease_released = $true
  }
  $candidate.budget.current_charge.work_unit_id = [string]$candidate.cursor.work_unit_id
  $candidate.budget.current_charge.status = "pending"
  $candidate.budget.current_charge.claimed_revision = 1
  $candidate.budget.current_charge.consumed_revision = $null
  return $candidate
}

function Stage-StateCandidate {
  param(
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string]$StatePath,
    [Parameter(Mandatory = $true)]$CandidateState
  )

  Write-Json -Path (Join-Path $RepositoryRoot $StatePath) -Value $CandidateState
  [void](Invoke-Git -RepositoryRoot $RepositoryRoot -Arguments @("add", $StatePath))
  return Invoke-Git -RepositoryRoot $RepositoryRoot -Arguments @("write-tree")
}

function Invoke-TransitionValidation {
  param(
    [Parameter(Mandatory = $true)][string]$ScriptPath,
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string]$ParentCommit,
    [Parameter(Mandatory = $true)][string]$TreeHash,
    [ValidateSet("Staged", "Committed")][string]$Source = "Staged",
    [string]$Commit = "HEAD"
  )

  $output = @(& powershell `
    -NoProfile `
    -NonInteractive `
    -ExecutionPolicy Bypass `
    -File $ScriptPath `
    -Source $Source `
    -RepositoryRoot $RepositoryRoot `
    -ExpectedParentCommit $ParentCommit `
    -ExpectedStagedTreeHash $TreeHash `
    -Commit $Commit `
    2>$null)
  $exitCode = $LASTEXITCODE
  Assert-Equal `
    -Actual (@(0, 1) -contains $exitCode) `
    -Expected $true `
    -Message "Validator returned an unsupported exit code."
  Assert-Equal `
    -Actual $output.Count `
    -Expected 1 `
    -Message "Validator emitted more than one stdout object."
  $report = $output[0] | ConvertFrom-Json
  Assert-Equal `
    -Actual $report.valid `
    -Expected ($exitCode -eq 0) `
    -Message "Validator JSON and exit code disagree."
  Assert-Equal `
    -Actual $report.mutations_performed `
    -Expected $false `
    -Message "Validator reported a mutation."
  return $report
}

$appRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../.."))
$danioModule = Import-Module `
  -Name (Join-Path $appRoot "scripts/autonomous_completion/DanioAutonomousCompletion.psm1") `
  -Force `
  -PassThru
$validatorPath = Join-Path `
  $appRoot `
  "scripts/autonomous_completion/validate_autonomous_completion_transition.ps1"
$inactiveFixturePath = Join-Path `
  $appRoot `
  "test/scripts/fixtures/autonomous_completion/inactive_run_state.json"
$readyFixturePath = Join-Path `
  $appRoot `
  "test/scripts/fixtures/autonomous_completion/ready_run_state.json"
$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$tempRoot = Join-Path $tempBase "danio-activation-$([guid]::NewGuid().ToString('N'))"
$localAppDataBase = [IO.Path]::GetFullPath([Environment]::GetFolderPath('LocalApplicationData'))
$outsideFixtureName = "danio-activation-outside-$([guid]::NewGuid().ToString('N'))"
$outsideRepositoryRoot = Join-Path $localAppDataBase $outsideFixtureName
$repositoryRoot = Join-Path $tempRoot "repo"
$statePath = "apps/aquarium_app/docs/agent/autonomous_completion/phone_completion_run_state.json"
$handoffPath = "apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md"
$sliceLogPath = "apps/aquarium_app/docs/agent/SLICE_LOG.md"

try {
  New-Item -ItemType Directory -Force -Path $repositoryRoot | Out-Null
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("init"))
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("checkout", "-b", "main"))
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("config", "user.name", "Danio Activation Fixture"))
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("config", "user.email", "activation@example.invalid"))
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("config", "core.autocrlf", "false"))

  $authorityPaths = @(
    "apps/aquarium_app/docs/agent/plans/2026-07-11-phone-complete-local-completion-program.md",
    "apps/aquarium_app/docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md",
    "apps/aquarium_app/docs/agent/FINISH_MAP.md",
    "apps/aquarium_app/docs/agent/QUALITY_LADDER.md",
    "apps/aquarium_app/docs/agent/VERIFIED_SLICE_EXECUTION_CONTRACT.md",
    "apps/aquarium_app/docs/agent/DEVICE_OWNERSHIP.md"
  )
  foreach ($path in $authorityPaths) {
    Write-Utf8Text `
      -Path (Join-Path $repositoryRoot $path) `
      -Content "fixture authority: $path`n"
  }

  $inactiveDestination = Join-Path `
    $repositoryRoot `
    "apps/aquarium_app/test/scripts/fixtures/autonomous_completion/inactive_run_state.json"
  $inactiveState = Get-Content -Raw -LiteralPath $inactiveFixturePath | ConvertFrom-Json
  $normalizedRepositoryRoot = [IO.Path]::GetFullPath($repositoryRoot).Replace("\", "/").TrimEnd("/")
  $normalizedSavedProjectRoot = [IO.Path]::GetFullPath($tempRoot).Replace("\", "/").TrimEnd("/")
  $inactiveState.authorization.repository_root = $normalizedRepositoryRoot
  $inactiveState.authorization.saved_project_root = $normalizedSavedProjectRoot
  Write-Json -Path $inactiveDestination -Value $inactiveState

  $bootstrapBefore = [pscustomobject][ordered]@{
    document_type = "danio_autonomy_bootstrap_budget"
    schema_version = 1
    authorization_id = "danio-phone-complete-local-2026-07-11"
    total_approved_units = 20
    consumed_units = 9
    remaining_units_including_current = 11
    last_closed_unit_id = "WF-2026-07-11-015"
    operational_state_path = $null
  }
  $fence = '```'
  $bootstrapBeforeJson = $bootstrapBefore | ConvertTo-Json -Depth 20
  $handoffBefore = @(
    "# Fixture handoff",
    "",
    "Status: Task 12 is complete and Task 13 is pending.",
    "Last updated: before activation.",
    "",
    "## Branch",
    "",
    "- Fixture branch state before activation.",
    "",
    "## Completed Product Slice",
    "",
    "This historical product checkpoint must be preserved byte for byte.",
    "",
    "## Autonomous Workflow Setup Unit 8",
    "",
    "This historical setup checkpoint must also be preserved.",
    "",
    "## Autonomous Chain Authorization",
    "",
    "This block is the bootstrap budget record until Task 13 activation.",
    "",
    "${fence}json",
    $bootstrapBeforeJson,
    $fence,
    "",
    "## Verification Evidence",
    "",
    "Task 12 fixture evidence must remain unchanged.",
    "",
    "## Blockers",
    "",
    "- Task 13 activation is still pending.",
    "",
    "## Next Action",
    "",
    "Activate Task 13 only after Launch readiness passes.",
    ""
  ) -join "`n"
  Write-Utf8Text -Path (Join-Path $repositoryRoot $handoffPath) -Content $handoffBefore

  $sliceRows = foreach ($unit in 7..15) {
    "| WF-2026-07-11-{0:d3} | 2026-07-11 | fixture | files | checks | closed | commit | next |" -f $unit
  }
  $sliceLogBefore = @"
# Fixture slice log

| Slice ID | Date | Goal | Files | Checks / evidence | Result | Commit | Follow-ups |
| --- | --- | --- | --- | --- | --- | --- | --- |
$($sliceRows -join "`n")
"@
  Write-Utf8Text -Path (Join-Path $repositoryRoot $sliceLogPath) -Content $sliceLogBefore

  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("add", "apps/aquarium_app"))
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("commit", "-m", "fixture: bootstrap parent"))
  $parentCommit = Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("rev-parse", "HEAD")

  $candidate = Get-Content -Raw -LiteralPath $readyFixturePath | ConvertFrom-Json
  $candidate.authorization.repository_root = $normalizedRepositoryRoot
  $candidate.authorization.saved_project_root = $normalizedSavedProjectRoot
  $candidate.budget.consumed_units = 10
  $candidate.budget.remaining_units_including_current = 10
  $candidate.transition.occurred_at_utc = "2026-07-13T12:00:00.0000000Z"

  $bootstrapAfter = $bootstrapBefore | ConvertTo-Json -Depth 20 | ConvertFrom-Json
  $bootstrapAfter.consumed_units = 10
  $bootstrapAfter.remaining_units_including_current = 10
  $bootstrapAfter.last_closed_unit_id = "WF-2026-07-11-016"
  $bootstrapAfter.operational_state_path = $statePath
  $bootstrapAfterJson = $bootstrapAfter | ConvertTo-Json -Depth 20
  $handoffAfter = @(
    "# Fixture handoff",
    "",
    "Status: Task 13 activation is complete; committed live run state is ready for the explicit launch handoff.",
    "Last updated: 2026-07-13 in this activation commit; live Git and committed run state remain the final authority.",
    "",
    "## Branch",
    "",
    '- Source-of-truth branch: `main`.',
    '- This handoff becomes authoritative only with its containing activation commit on clean, pushed, aligned `main`.',
    "- Only the canonical repository worktree may remain registered at durable closeout.",
    "",
    "## Completed Product Slice",
    "",
    "This historical product checkpoint must be preserved byte for byte.",
    "",
    "## Autonomous Workflow Setup Unit 8",
    "",
    "This historical setup checkpoint must also be preserved.",
    "",
    "## Autonomous Chain Authorization",
    "",
    "This historical bootstrap record is superseded by live run state as the sole accounting authority.",
    "",
    "${fence}json",
    $bootstrapAfterJson,
    $fence,
    "",
    "## Verification Evidence",
    "",
    "Task 12 fixture evidence must remain unchanged.",
    "",
    "## Blockers",
    "",
    "- No activation blocker is recorded in this candidate.",
    "- Product work remains forbidden in the Task 13 setup task.",
    "",
    "## Next Action",
    "",
    'After the activation commit is on clean, pushed, aligned `main`, use the duplicate-safe launch marker to create or reuse exactly one saved-project local first product task.',
    'The new task must synchronize, pass Claim readiness, and win `ready -> active` before auditing `DCL-DR-001`. Do not start product work in this setup task.',
    ""
  ) -join "`n"
  $activationSliceRow = "| WF-2026-07-11-016 | 2026-07-13 | Activate autonomous phone completion | live state, handoff, slice log | staged validator, Docs, clean alignment | ready | this activation commit | Create or reuse the explicit launch task; no product work here |"
  $sliceLogAfter = "$($sliceLogBefore.TrimEnd())`n$activationSliceRow`n"
  $stagedActivation = Stage-ActivationCandidate `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $parentCommit `
    -CandidateState $candidate `
    -StatePath $statePath `
    -HandoffPath $handoffPath `
    -HandoffContent $handoffAfter `
    -SliceLogPath $sliceLogPath `
    -SliceLogContent $sliceLogAfter
  $treeHash = [string]$stagedActivation.tree_hash
  $beforeSnapshot = Get-RepositorySnapshot -RepositoryRoot $repositoryRoot
  $report = Invoke-TransitionValidation `
    -ScriptPath $validatorPath `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $parentCommit `
    -TreeHash $treeHash
  $afterSnapshot = Get-RepositorySnapshot -RepositoryRoot $repositoryRoot

  Assert-RepositorySnapshotEqual `
    -Before $beforeSnapshot `
    -After $afterSnapshot `
    -Scenario "valid staged absent-state activation"
  Assert-Equal `
    -Actual $report.valid `
    -Expected $true `
    -Message "Valid absent-state activation was rejected: $($report.code): $($report.details -join '; ')."
  Assert-Equal -Actual $report.code -Expected "TRANSITION_VALID" -Message "Valid activation returned the wrong code."

  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("reset", "--hard", $parentCommit))
  $wrongTotalBootstrap = $bootstrapBefore | ConvertTo-Json -Depth 20 | ConvertFrom-Json
  $wrongTotalBootstrap.total_approved_units = 200
  $wrongTotalBootstrap.remaining_units_including_current = 191
  $wrongTotalHandoff = $handoffBefore.Replace(
    $bootstrapBeforeJson,
    ($wrongTotalBootstrap | ConvertTo-Json -Depth 20)
  )
  Write-Utf8Text -Path (Join-Path $repositoryRoot $handoffPath) -Content $wrongTotalHandoff
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("add", $handoffPath))
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("commit", "-m", "fixture: wrong approved total"))
  $wrongTotalParent = Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("rev-parse", "HEAD")
  $wrongTotalCandidate = $candidate | ConvertTo-Json -Depth 100 | ConvertFrom-Json
  $wrongTotalCandidate.budget.total_approved_units = 200
  $wrongTotalCandidate.budget.consumed_units = 10
  $wrongTotalCandidate.budget.remaining_units_including_current = 190
  $wrongTotalBootstrapAfter = $bootstrapAfter | ConvertTo-Json -Depth 20 | ConvertFrom-Json
  $wrongTotalBootstrapAfter.total_approved_units = 200
  $wrongTotalBootstrapAfter.remaining_units_including_current = 190
  $wrongTotalHandoffAfter = $wrongTotalHandoff.Replace(
    "This block is the bootstrap budget record until Task 13 activation.",
    "This historical bootstrap record is superseded by live run state as the sole accounting authority."
  ).Replace(
    ($wrongTotalBootstrap | ConvertTo-Json -Depth 20),
    ($wrongTotalBootstrapAfter | ConvertTo-Json -Depth 20)
  )
  $wrongTotalStage = Stage-ActivationCandidate `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $wrongTotalParent `
    -CandidateState $wrongTotalCandidate `
    -StatePath $statePath `
    -HandoffPath $handoffPath `
    -HandoffContent $wrongTotalHandoffAfter `
    -SliceLogPath $sliceLogPath `
    -SliceLogContent $sliceLogAfter
  $wrongTotalReport = Invoke-TransitionValidation `
    -ScriptPath $validatorPath `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $wrongTotalParent `
    -TreeHash ([string]$wrongTotalStage.tree_hash)
  Assert-Equal `
    -Actual $wrongTotalReport.code `
    -Expected "BOOTSTRAP_BUDGET_INVALID" `
    -Message "A bootstrap total outside the approved authorization was accepted."

  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("reset", "--hard", $parentCommit))
  $wrongRootInactive = $inactiveState | ConvertTo-Json -Depth 100 | ConvertFrom-Json
  $wrongRootInactive.authorization.repository_root = "C:/unauthorized/repo"
  $wrongRootInactive.authorization.saved_project_root = "C:/unauthorized"
  Write-Json -Path $inactiveDestination -Value $wrongRootInactive
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("add", $inactiveDestination))
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("commit", "-m", "fixture: wrong authorization roots"))
  $wrongRootParent = Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("rev-parse", "HEAD")
  $wrongRootCandidate = $candidate | ConvertTo-Json -Depth 100 | ConvertFrom-Json
  $wrongRootCandidate.authorization.repository_root = "C:/unauthorized/repo"
  $wrongRootCandidate.authorization.saved_project_root = "C:/unauthorized"
  $wrongRootStage = Stage-ActivationCandidate `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $wrongRootParent `
    -CandidateState $wrongRootCandidate `
    -StatePath $statePath `
    -HandoffPath $handoffPath `
    -HandoffContent $handoffAfter `
    -SliceLogPath $sliceLogPath `
    -SliceLogContent $sliceLogAfter
  $wrongRootReport = Invoke-TransitionValidation `
    -ScriptPath $validatorPath `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $wrongRootParent `
    -TreeHash ([string]$wrongRootStage.tree_hash)
  Assert-Equal `
    -Actual $wrongRootReport.code `
    -Expected "BOOTSTRAP_AUTHORIZATION_INVALID" `
    -Message "Authorization roots not bound to the selected repository were accepted."

  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("reset", "--hard", $parentCommit))
  $consumedLineMatch = [regex]::Match(
    $bootstrapBeforeJson,
    '(?m)^\s*"consumed_units"\s*:\s*9,\s*$'
  )
  Assert-Equal `
    -Actual $consumedLineMatch.Success `
    -Expected $true `
    -Message "Fixture bootstrap consumed line was not found."
  $duplicateConsumedLine = $consumedLineMatch.Value.Replace("9,", "999,")
  $duplicateKeyJson = $bootstrapBeforeJson.Replace(
    $consumedLineMatch.Value,
    "$duplicateConsumedLine`n$($consumedLineMatch.Value)"
  )
  $duplicateKeyHandoff = $handoffBefore.Replace($bootstrapBeforeJson, $duplicateKeyJson)
  Write-Utf8Text -Path (Join-Path $repositoryRoot $handoffPath) -Content $duplicateKeyHandoff
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("add", $handoffPath))
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("commit", "-m", "fixture: duplicate bootstrap key"))
  $duplicateKeyParent = Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("rev-parse", "HEAD")
  $duplicateKeyStage = Stage-ActivationCandidate `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $duplicateKeyParent `
    -CandidateState $candidate `
    -StatePath $statePath `
    -HandoffPath $handoffPath `
    -HandoffContent $handoffAfter `
    -SliceLogPath $sliceLogPath `
    -SliceLogContent $sliceLogAfter
  $duplicateKeyReport = Invoke-TransitionValidation `
    -ScriptPath $validatorPath `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $duplicateKeyParent `
    -TreeHash ([string]$duplicateKeyStage.tree_hash)
  Assert-Equal `
    -Actual $duplicateKeyReport.code `
    -Expected "BOOTSTRAP_BUDGET_INVALID" `
    -Message "A duplicate bootstrap JSON property was accepted."

  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("reset", "--hard", $parentCommit))
  $compactBootstrapJson = $bootstrapBefore | ConvertTo-Json -Depth 20 -Compress
  $compactDuplicateJson = $compactBootstrapJson.Replace(
    '"consumed_units":9,',
    '"consumed_units":999,"consumed_units":9,'
  )
  $compactDuplicateHandoff = $handoffBefore.Replace(
    $bootstrapBeforeJson,
    $compactDuplicateJson
  )
  Write-Utf8Text `
    -Path (Join-Path $repositoryRoot $handoffPath) `
    -Content $compactDuplicateHandoff
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("add", $handoffPath))
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("commit", "-m", "fixture: compact duplicate bootstrap key"))
  $compactDuplicateParent = Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("rev-parse", "HEAD")
  $compactDuplicateStage = Stage-ActivationCandidate `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $compactDuplicateParent `
    -CandidateState $candidate `
    -StatePath $statePath `
    -HandoffPath $handoffPath `
    -HandoffContent $handoffAfter `
    -SliceLogPath $sliceLogPath `
    -SliceLogContent $sliceLogAfter
  $compactDuplicateReport = Invoke-TransitionValidation `
    -ScriptPath $validatorPath `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $compactDuplicateParent `
    -TreeHash ([string]$compactDuplicateStage.tree_hash)
  Assert-Equal `
    -Actual $compactDuplicateReport.code `
    -Expected "BOOTSTRAP_BUDGET_INVALID" `
    -Message "A compact duplicate bootstrap JSON property was accepted."

  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("reset", "--hard", $parentCommit))
  $malformedMarkedFence = @(
    "${fence}json",
    '{ "document_type": "danio_autonomy_bootstrap_budget", broken }',
    $fence
  ) -join "`n"
  $ambiguousHandoff = "$handoffBefore`n$malformedMarkedFence`n"
  Write-Utf8Text -Path (Join-Path $repositoryRoot $handoffPath) -Content $ambiguousHandoff
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("add", $handoffPath))
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("commit", "-m", "fixture: malformed marked bootstrap fence"))
  $ambiguousParent = Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("rev-parse", "HEAD")
  $ambiguousStage = Stage-ActivationCandidate `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $ambiguousParent `
    -CandidateState $candidate `
    -StatePath $statePath `
    -HandoffPath $handoffPath `
    -HandoffContent $handoffAfter `
    -SliceLogPath $sliceLogPath `
    -SliceLogContent $sliceLogAfter
  $ambiguousReport = Invoke-TransitionValidation `
    -ScriptPath $validatorPath `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $ambiguousParent `
    -TreeHash ([string]$ambiguousStage.tree_hash)
  Assert-Equal `
    -Actual $ambiguousReport.code `
    -Expected "BOOTSTRAP_BUDGET_INVALID" `
    -Message "A second malformed marked bootstrap fence was ignored."

  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("reset", "--hard", $parentCommit))
  $wrongAuthorizationBootstrap = $bootstrapBefore | ConvertTo-Json -Depth 20 | ConvertFrom-Json
  $wrongAuthorizationBootstrap.authorization_id = "wrong-bootstrap-authorization"
  $wrongAuthorizationHandoff = @(
    "# Fixture handoff",
    "",
    "## Autonomous Chain Authorization",
    "",
    "This block is the bootstrap budget record until Task 13 activation.",
    "",
    "${fence}json",
    ($wrongAuthorizationBootstrap | ConvertTo-Json -Depth 20),
    $fence,
    ""
  ) -join "`n"
  Write-Utf8Text `
    -Path (Join-Path $repositoryRoot $handoffPath) `
    -Content $wrongAuthorizationHandoff
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("add", $handoffPath))
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("commit", "-m", "fixture: wrong bootstrap authorization"))
  $wrongAuthorizationParent = Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("rev-parse", "HEAD")
  $wrongAuthorizationStage = Stage-ActivationCandidate `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $wrongAuthorizationParent `
    -CandidateState $candidate `
    -StatePath $statePath `
    -HandoffPath $handoffPath `
    -HandoffContent $handoffAfter `
    -SliceLogPath $sliceLogPath `
    -SliceLogContent $sliceLogAfter
  $wrongAuthorizationReport = Invoke-TransitionValidation `
    -ScriptPath $validatorPath `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $wrongAuthorizationParent `
    -TreeHash ([string]$wrongAuthorizationStage.tree_hash)
  Assert-Equal `
    -Actual $wrongAuthorizationReport.code `
    -Expected "BOOTSTRAP_BUDGET_INVALID" `
    -Message "Bootstrap authorization mismatch was accepted."

  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("reset", "--hard", $parentCommit))
  $duplicateParentLog = "$sliceLogBefore`n| WF-2026-07-11-016 | 2026-07-13 | duplicate | files | checks | duplicate | commit | none |`n"
  Write-Utf8Text `
    -Path (Join-Path $repositoryRoot $sliceLogPath) `
    -Content $duplicateParentLog
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("add", $sliceLogPath))
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("commit", "-m", "fixture: pre-record Task 13 unit"))
  $duplicateParent = Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("rev-parse", "HEAD")
  $duplicateStage = Stage-ActivationCandidate `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $duplicateParent `
    -CandidateState $candidate `
    -StatePath $statePath `
    -HandoffPath $handoffPath `
    -HandoffContent $handoffAfter `
    -SliceLogPath $sliceLogPath `
    -SliceLogContent $sliceLogAfter
  $duplicateReport = Invoke-TransitionValidation `
    -ScriptPath $validatorPath `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $duplicateParent `
    -TreeHash ([string]$duplicateStage.tree_hash)
  Assert-Equal `
    -Actual $duplicateReport.code `
    -Expected "BOOTSTRAP_UNIT_ALREADY_RECORDED" `
    -Message "Pre-recorded Task 13 unit was accepted."

  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("reset", "--hard", $parentCommit))
  Write-Json -Path (Join-Path $repositoryRoot $statePath) -Value $inactiveState
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("add", $statePath))
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("commit", "-m", "fixture: pre-existing live state path"))
  $existingStateParent = Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("rev-parse", "HEAD")
  $existingStateStage = Stage-ActivationCandidate `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $existingStateParent `
    -CandidateState $candidate `
    -StatePath $statePath `
    -HandoffPath $handoffPath `
    -HandoffContent $handoffAfter `
    -SliceLogPath $sliceLogPath `
    -SliceLogContent $sliceLogAfter
  $existingStateReport = Invoke-TransitionValidation `
    -ScriptPath $validatorPath `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $existingStateParent `
    -TreeHash ([string]$existingStateStage.tree_hash)
  Assert-Equal `
    -Actual $existingStateReport.code `
    -Expected "LIVE_STATE_ALREADY_EXISTS" `
    -Message "Pre-existing live state path was accepted for launch."

  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("reset", "--hard", $parentCommit))
  $dirtyLaunchCandidate = $candidate | ConvertTo-Json -Depth 100 | ConvertFrom-Json
  $dirtyLaunchCandidate.repeated_failure = [pscustomobject][ordered]@{
    signature = "0" * 64
    attempt_count = 1
    last_failed_at_utc = "2026-07-13T11:59:00.0000000Z"
  }
  $dirtyLaunchStage = Stage-ActivationCandidate `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $parentCommit `
    -CandidateState $dirtyLaunchCandidate `
    -StatePath $statePath `
    -HandoffPath $handoffPath `
    -HandoffContent $handoffAfter `
    -SliceLogPath $sliceLogPath `
    -SliceLogContent $sliceLogAfter
  $dirtyLaunchReport = Invoke-TransitionValidation `
    -ScriptPath $validatorPath `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $parentCommit `
    -TreeHash ([string]$dirtyLaunchStage.tree_hash)
  Assert-Equal `
    -Actual $dirtyLaunchReport.code `
    -Expected "BOOTSTRAP_HANDOFF_INVALID" `
    -Message "Launch metadata not present in the inactive conceptual parent was accepted."

  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("reset", "--hard", $parentCommit))
  $duplicateStateStage = Stage-ActivationCandidate `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $parentCommit `
    -CandidateState $candidate `
    -StatePath $statePath `
    -HandoffPath $handoffPath `
    -HandoffContent $handoffAfter `
    -SliceLogPath $sliceLogPath `
    -SliceLogContent $sliceLogAfter
  $compactStateJson = $duplicateStateStage.state | ConvertTo-Json -Depth 100 -Compress
  $duplicateStateJson = $compactStateJson.Replace(
    '"consumed_units":10,',
    '"consumed_units":999,"consumed_units":10,'
  )
  Write-Utf8Text `
    -Path (Join-Path $repositoryRoot $statePath) `
    -Content $duplicateStateJson
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("add", $statePath))
  $duplicateStateTree = Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("write-tree")
  $duplicateStateReport = Invoke-TransitionValidation `
    -ScriptPath $validatorPath `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $parentCommit `
    -TreeHash $duplicateStateTree
  Assert-Equal `
    -Actual $duplicateStateReport.code `
    -Expected "STATE_BLOB_INVALID" `
    -Message "A compact duplicate nested run-state property was accepted."

  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("reset", "--hard", $parentCommit))
  $destructiveHandoff = @(
    "# Fixture handoff",
    "",
    "This historical bootstrap record is superseded by live run state as the sole accounting authority.",
    "",
    "${fence}json",
    $bootstrapAfterJson,
    $fence,
    ""
  ) -join "`n"
  $destructiveStage = Stage-ActivationCandidate `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $parentCommit `
    -CandidateState $candidate `
    -StatePath $statePath `
    -HandoffPath $handoffPath `
    -HandoffContent $destructiveHandoff `
    -SliceLogPath $sliceLogPath `
    -SliceLogContent $sliceLogAfter
  $destructiveReport = Invoke-TransitionValidation `
    -ScriptPath $validatorPath `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $parentCommit `
    -TreeHash ([string]$destructiveStage.tree_hash)
  Assert-Equal `
    -Actual $destructiveReport.code `
    -Expected "BOOTSTRAP_HANDOFF_INVALID" `
    -Message "Wholesale replacement of the active handoff was accepted."

  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("reset", "--hard", $parentCommit))
  $tamperedImmutableHandoff = $handoffAfter.Replace(
    "Task 12 fixture evidence must remain unchanged.",
    "Task 12 fixture evidence was rewritten during activation."
  )
  $tamperedImmutableStage = Stage-ActivationCandidate `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $parentCommit `
    -CandidateState $candidate `
    -StatePath $statePath `
    -HandoffPath $handoffPath `
    -HandoffContent $tamperedImmutableHandoff `
    -SliceLogPath $sliceLogPath `
    -SliceLogContent $sliceLogAfter
  $tamperedImmutableReport = Invoke-TransitionValidation `
    -ScriptPath $validatorPath `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $parentCommit `
    -TreeHash ([string]$tamperedImmutableStage.tree_hash)
  Assert-Equal `
    -Actual $tamperedImmutableReport.code `
    -Expected "BOOTSTRAP_HANDOFF_INVALID" `
    -Message "Activation rewrote an immutable handoff section."

  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("reset", "--hard", $parentCommit))
  $malformedActivationRow = "| WF-2026-07-11-016 | wrong | arbitrary | payload | was | accepted | here | incorrectly |"
  $malformedSliceLog = "$($sliceLogBefore.TrimEnd())`n$malformedActivationRow`n"
  $malformedRowStage = Stage-ActivationCandidate `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $parentCommit `
    -CandidateState $candidate `
    -StatePath $statePath `
    -HandoffPath $handoffPath `
    -HandoffContent $handoffAfter `
    -SliceLogPath $sliceLogPath `
    -SliceLogContent $malformedSliceLog
  $malformedRowReport = Invoke-TransitionValidation `
    -ScriptPath $validatorPath `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $parentCommit `
    -TreeHash ([string]$malformedRowStage.tree_hash)
  Assert-Equal `
    -Actual $malformedRowReport.code `
    -Expected "BOOTSTRAP_SLICE_LOG_INVALID" `
    -Message "A malformed Task 13 closeout row was accepted."

  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("reset", "--hard", $parentCommit))
  $duplicateCandidateLog = "$($sliceLogAfter.TrimEnd())`nDuplicate marker WF-2026-07-11-016 must be rejected.`n"
  $duplicateLogStage = Stage-ActivationCandidate `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $parentCommit `
    -CandidateState $candidate `
    -StatePath $statePath `
    -HandoffPath $handoffPath `
    -HandoffContent $handoffAfter `
    -SliceLogPath $sliceLogPath `
    -SliceLogContent $duplicateCandidateLog
  $duplicateLogReport = Invoke-TransitionValidation `
    -ScriptPath $validatorPath `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $parentCommit `
    -TreeHash ([string]$duplicateLogStage.tree_hash)
  Assert-Equal `
    -Actual $duplicateLogReport.code `
    -Expected "BOOTSTRAP_SLICE_LOG_INVALID" `
    -Message "A duplicate Task 13 marker outside the new slice row was accepted."

  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("reset", "--hard", $parentCommit))
  $forgedActivationStage = Stage-ActivationCandidate `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $parentCommit `
    -CandidateState $candidate `
    -StatePath $statePath `
    -HandoffPath $handoffPath `
    -HandoffContent $handoffAfter `
    -SliceLogPath $sliceLogPath `
    -SliceLogContent $sliceLogAfter
  [void](Invoke-Git `
    -RepositoryRoot $repositoryRoot `
    -Arguments @("commit", "-m", "fixture: forge unverified ready state"))
  $forgedActivationCommit = Invoke-Git `
    -RepositoryRoot $repositoryRoot `
    -Arguments @("rev-parse", "HEAD")
  $forgedClaim = New-ClaimCandidate `
    -ReadyState $forgedActivationStage.state `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $forgedActivationCommit `
    -SavedProjectRoot $normalizedSavedProjectRoot
  $forgedClaimTree = Stage-StateCandidate `
    -RepositoryRoot $repositoryRoot `
    -StatePath $statePath `
    -CandidateState $forgedClaim
  $forgedClaimReport = Invoke-TransitionValidation `
    -ScriptPath $validatorPath `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $forgedActivationCommit `
    -TreeHash $forgedClaimTree
  Assert-Equal `
    -Actual $forgedClaimReport.code `
    -Expected "BOOTSTRAP_ACTIVATION_PROOF_INVALID" `
    -Message "An unverified state-add commit was accepted as Task 13 activation authority."

  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("reset", "--hard", $parentCommit))
  $committedStage = Stage-ActivationCandidate `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $parentCommit `
    -CandidateState $candidate `
    -StatePath $statePath `
    -HandoffPath $handoffPath `
    -HandoffContent $handoffAfter `
    -SliceLogPath $sliceLogPath `
    -SliceLogContent $sliceLogAfter
  $committedTree = [string]$committedStage.tree_hash
  $trailerBlock = @(
    "Danio-State-Tree: $committedTree",
    "Danio-State-Validation: pass",
    "Danio-Docs-Profile: pass",
    "Danio-Verified-At: 2026-07-13T12:05:00.0000000Z"
  ) -join "`n"
  [void](Invoke-Git `
    -RepositoryRoot $repositoryRoot `
    -Arguments @(
      "commit",
      "-m",
      "chore: activate with the wrong subject",
      "-m",
      $trailerBlock
    ))
  $wrongSubjectCommit = Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("rev-parse", "HEAD")
  $wrongSubjectReport = Invoke-TransitionValidation `
    -ScriptPath $validatorPath `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $parentCommit `
    -TreeHash $committedTree `
    -Source Committed `
    -Commit $wrongSubjectCommit
  Assert-Equal `
    -Actual $wrongSubjectReport.code `
    -Expected "COMMIT_SUBJECT_INVALID" `
    -Message "A committed launch with the wrong subject was accepted."

  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("reset", "--hard", $parentCommit))
  $committedStage = Stage-ActivationCandidate `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $parentCommit `
    -CandidateState $candidate `
    -StatePath $statePath `
    -HandoffPath $handoffPath `
    -HandoffContent $handoffAfter `
    -SliceLogPath $sliceLogPath `
    -SliceLogContent $sliceLogAfter
  $committedTree = [string]$committedStage.tree_hash
  $trailerBlock = @(
    "Danio-State-Tree: $committedTree",
    "Danio-State-Validation: pass",
    "Danio-Docs-Profile: pass",
    "Danio-Verified-At: 2026-07-13T12:05:00.0000000Z"
  ) -join "`n"
  [void](Invoke-Git `
    -RepositoryRoot $repositoryRoot `
    -Arguments @(
      "commit",
      "-m",
      "chore: activate autonomous phone completion",
      "-m",
      $trailerBlock
    ))
  $activationCommit = Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("rev-parse", "HEAD")
  $committedReport = Invoke-TransitionValidation `
    -ScriptPath $validatorPath `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $parentCommit `
    -TreeHash $committedTree `
    -Source Committed `
    -Commit $activationCommit
  Assert-Equal -Actual $committedReport.valid -Expected $true -Message "Committed activation was rejected."
  Assert-Equal -Actual $committedReport.code -Expected "TRANSITION_VALID" -Message "Committed activation returned the wrong code."

  $copiedRepositoryRoot = Join-Path $tempRoot "copied-repo"
  [void](Invoke-Git `
    -RepositoryRoot $tempRoot `
    -Arguments @("clone", $repositoryRoot, $copiedRepositoryRoot))
  [void](Invoke-Git `
    -RepositoryRoot $copiedRepositoryRoot `
    -Arguments @("config", "user.name", "Danio Copied History Fixture"))
  [void](Invoke-Git `
    -RepositoryRoot $copiedRepositoryRoot `
    -Arguments @("config", "user.email", "copied-history@example.invalid"))
  $copiedClaim = New-ClaimCandidate `
    -ReadyState $committedStage.state `
    -RepositoryRoot $copiedRepositoryRoot `
    -ParentCommit $activationCommit `
    -SavedProjectRoot $normalizedSavedProjectRoot
  $copiedClaimTree = Stage-StateCandidate `
    -RepositoryRoot $copiedRepositoryRoot `
    -StatePath $statePath `
    -CandidateState $copiedClaim
  $copiedBefore = Get-RepositorySnapshot -RepositoryRoot $copiedRepositoryRoot
  $priorTestMode = $env:DANIO_AUTONOMY_TEST_MODE
  try {
    Remove-Item Env:DANIO_AUTONOMY_TEST_MODE -ErrorAction SilentlyContinue
    $copiedClaimReport = Invoke-TransitionValidation `
      -ScriptPath $validatorPath `
      -RepositoryRoot $copiedRepositoryRoot `
      -ParentCommit $activationCommit `
      -TreeHash $copiedClaimTree
  } finally {
    if ($null -eq $priorTestMode) {
      Remove-Item Env:DANIO_AUTONOMY_TEST_MODE -ErrorAction SilentlyContinue
    } else {
      $env:DANIO_AUTONOMY_TEST_MODE = $priorTestMode
    }
  }
  $copiedAfter = Get-RepositorySnapshot -RepositoryRoot $copiedRepositoryRoot
  Assert-RepositorySnapshotEqual `
    -Before $copiedBefore `
    -After $copiedAfter `
    -Scenario "copied history selected-root rejection"
  Assert-Equal `
    -Actual $copiedClaimReport.code `
    -Expected "BOOTSTRAP_ACTIVATION_PROOF_INVALID" `
    -Message "Copied activation history was accepted against the wrong selected repository root."

  $linkedRemoteRoot = Join-Path $tempRoot "linked-remote.git"
  $linkedWorktreeRoot = Join-Path $tempRoot "linked-worktree"
  [void](Invoke-Git `
    -RepositoryRoot $tempRoot `
    -Arguments @("init", "--bare", $linkedRemoteRoot))
  [void](Invoke-Git `
    -RepositoryRoot $tempRoot `
    -Arguments @("clone", $repositoryRoot, $outsideRepositoryRoot))
  [void](Invoke-Git `
    -RepositoryRoot $outsideRepositoryRoot `
    -Arguments @("remote", "set-url", "origin", $linkedRemoteRoot))
  [void](Invoke-Git `
    -RepositoryRoot $outsideRepositoryRoot `
    -Arguments @("push", "-u", "origin", "main"))
  [void](Invoke-Git `
    -RepositoryRoot $linkedRemoteRoot `
    -Arguments @("symbolic-ref", "HEAD", "refs/heads/main"))
  $standaloneCloneRoot = Join-Path $tempRoot "standalone-clone"
  [void](Invoke-Git `
    -RepositoryRoot $tempRoot `
    -Arguments @("clone", $linkedRemoteRoot, $standaloneCloneRoot))
  $standaloneClaim = New-ClaimCandidate `
    -ReadyState $committedStage.state `
    -RepositoryRoot $standaloneCloneRoot `
    -ParentCommit $activationCommit `
    -SavedProjectRoot $normalizedSavedProjectRoot
  $standaloneClaimTree = Stage-StateCandidate `
    -RepositoryRoot $standaloneCloneRoot `
    -StatePath $statePath `
    -CandidateState $standaloneClaim
  $standaloneBefore = Get-RepositorySnapshot -RepositoryRoot $standaloneCloneRoot
  $priorStandaloneTestMode = $env:DANIO_AUTONOMY_TEST_MODE
  try {
    $env:DANIO_AUTONOMY_TEST_MODE = "1"
    $standaloneClaimReport = Invoke-TransitionValidation `
      -ScriptPath $validatorPath `
      -RepositoryRoot $standaloneCloneRoot `
      -ParentCommit $activationCommit `
      -TreeHash $standaloneClaimTree
  } finally {
    if ($null -eq $priorStandaloneTestMode) {
      Remove-Item Env:DANIO_AUTONOMY_TEST_MODE -ErrorAction SilentlyContinue
    } else {
      $env:DANIO_AUTONOMY_TEST_MODE = $priorStandaloneTestMode
    }
  }
  $standaloneAfter = Get-RepositorySnapshot -RepositoryRoot $standaloneCloneRoot
  Assert-RepositorySnapshotEqual `
    -Before $standaloneBefore `
    -After $standaloneAfter `
    -Scenario "standalone disposable authorization override"
  Assert-Equal `
    -Actual $standaloneClaimReport.code `
    -Expected "TRANSITION_VALID" `
    -Message "A contained standalone disposable clone did not qualify for the test-only authorization override: $($standaloneClaimReport.details -join '; ')"
  $insideLinkedWorktreeRoot = Join-Path $tempRoot "inside-linked-worktree"
  [void](Invoke-Git `
    -RepositoryRoot $standaloneCloneRoot `
    -Arguments @("worktree", "add", "--detach", $insideLinkedWorktreeRoot, $activationCommit))
  $insideLinkedClaim = New-ClaimCandidate `
    -ReadyState $committedStage.state `
    -RepositoryRoot $insideLinkedWorktreeRoot `
    -ParentCommit $activationCommit `
    -SavedProjectRoot $normalizedSavedProjectRoot
  $insideLinkedClaimTree = Stage-StateCandidate `
    -RepositoryRoot $insideLinkedWorktreeRoot `
    -StatePath $statePath `
    -CandidateState $insideLinkedClaim
  $insideLinkedBefore = Get-RepositorySnapshot -RepositoryRoot $insideLinkedWorktreeRoot
  $priorInsideLinkedTestMode = $env:DANIO_AUTONOMY_TEST_MODE
  try {
    $env:DANIO_AUTONOMY_TEST_MODE = "1"
    $insideLinkedClaimReport = Invoke-TransitionValidation `
      -ScriptPath $validatorPath `
      -RepositoryRoot $insideLinkedWorktreeRoot `
      -ParentCommit $activationCommit `
      -TreeHash $insideLinkedClaimTree
  } finally {
    if ($null -eq $priorInsideLinkedTestMode) {
      Remove-Item Env:DANIO_AUTONOMY_TEST_MODE -ErrorAction SilentlyContinue
    } else {
      $env:DANIO_AUTONOMY_TEST_MODE = $priorInsideLinkedTestMode
    }
  }
  $insideLinkedAfter = Get-RepositorySnapshot -RepositoryRoot $insideLinkedWorktreeRoot
  Assert-RepositorySnapshotEqual `
    -Before $insideLinkedBefore `
    -After $insideLinkedAfter `
    -Scenario "inside-common-directory linked worktree override"
  Assert-Equal `
    -Actual $insideLinkedClaimReport.code `
    -Expected "TRANSITION_VALID" `
    -Message "A temp writer worktree backed by a contained standalone repository did not qualify for the test-only override: $($insideLinkedClaimReport.details -join '; ')"
  [void](Invoke-Git `
    -RepositoryRoot $standaloneCloneRoot `
    -Arguments @("worktree", "remove", "--force", $insideLinkedWorktreeRoot))
  [void](Invoke-Git `
    -RepositoryRoot $outsideRepositoryRoot `
    -Arguments @("worktree", "add", "--detach", $linkedWorktreeRoot, $activationCommit))
  $linkedClaim = New-ClaimCandidate `
    -ReadyState $committedStage.state `
    -RepositoryRoot $linkedWorktreeRoot `
    -ParentCommit $activationCommit `
    -SavedProjectRoot $normalizedSavedProjectRoot
  $linkedClaimTree = Stage-StateCandidate `
    -RepositoryRoot $linkedWorktreeRoot `
    -StatePath $statePath `
    -CandidateState $linkedClaim
  $linkedBefore = Get-RepositorySnapshot -RepositoryRoot $linkedWorktreeRoot
  $priorLinkedTestMode = $env:DANIO_AUTONOMY_TEST_MODE
  try {
    $env:DANIO_AUTONOMY_TEST_MODE = "1"
    $linkedClaimReport = Invoke-TransitionValidation `
      -ScriptPath $validatorPath `
      -RepositoryRoot $linkedWorktreeRoot `
      -ParentCommit $activationCommit `
      -TreeHash $linkedClaimTree
  } finally {
    if ($null -eq $priorLinkedTestMode) {
      Remove-Item Env:DANIO_AUTONOMY_TEST_MODE -ErrorAction SilentlyContinue
    } else {
      $env:DANIO_AUTONOMY_TEST_MODE = $priorLinkedTestMode
    }
  }
  $linkedAfter = Get-RepositorySnapshot -RepositoryRoot $linkedWorktreeRoot
  Assert-RepositorySnapshotEqual `
    -Before $linkedBefore `
    -After $linkedAfter `
    -Scenario "linked worktree common-directory rejection"
  Assert-Equal `
    -Actual $linkedClaimReport.code `
    -Expected "BOOTSTRAP_ACTIVATION_PROOF_INVALID" `
    -Message "A temp linked worktree bypassed selected common-directory root binding."
  [void](Invoke-Git `
    -RepositoryRoot $outsideRepositoryRoot `
    -Arguments @("worktree", "remove", "--force", $linkedWorktreeRoot))

  $reformattedHistoricalHandoff = $handoffAfter.Replace(
    $bootstrapAfterJson,
    ($bootstrapAfter | ConvertTo-Json -Depth 20 -Compress)
  )
  Write-Utf8Text `
    -Path (Join-Path $repositoryRoot $handoffPath) `
    -Content $reformattedHistoricalHandoff
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("add", $handoffPath))
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("commit", "-m", "fixture: reformat historical activation accounting"))
  $reformattedHistoricalParent = Invoke-Git `
    -RepositoryRoot $repositoryRoot `
    -Arguments @("rev-parse", "HEAD")
  $reformattedClaim = New-ClaimCandidate `
    -ReadyState $committedStage.state `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $reformattedHistoricalParent `
    -SavedProjectRoot $normalizedSavedProjectRoot
  $reformattedClaimTree = Stage-StateCandidate `
    -RepositoryRoot $repositoryRoot `
    -StatePath $statePath `
    -CandidateState $reformattedClaim
  $reformattedClaimReport = Invoke-TransitionValidation `
    -ScriptPath $validatorPath `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $reformattedHistoricalParent `
    -TreeHash $reformattedClaimTree
  Assert-Equal `
    -Actual $reformattedClaimReport.code `
    -Expected "BOOTSTRAP_HANDOFF_INVALID" `
    -Message "A formatting-only rewrite of immutable activation accounting was accepted."

  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("reset", "--hard", $activationCommit))
  $tamperedHistoricalBootstrap = $bootstrapAfter | ConvertTo-Json -Depth 20 | ConvertFrom-Json
  $tamperedHistoricalBootstrap.consumed_units = 11
  $tamperedHistoricalBootstrap.remaining_units_including_current = 9
  $tamperedHistoricalHandoff = $handoffAfter.Replace(
    $bootstrapAfterJson,
    ($tamperedHistoricalBootstrap | ConvertTo-Json -Depth 20)
  )
  Write-Utf8Text `
    -Path (Join-Path $repositoryRoot $handoffPath) `
    -Content $tamperedHistoricalHandoff
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("add", $handoffPath))
  [void](Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("commit", "-m", "fixture: tamper historical activation accounting"))
  $tamperedHistoricalParent = Invoke-Git -RepositoryRoot $repositoryRoot -Arguments @("rev-parse", "HEAD")
  $postTamperCandidate = $candidate | ConvertTo-Json -Depth 100 | ConvertFrom-Json
  $postTamperCandidate.state_revision = 2
  $postTamperCandidate.mode = "active"
  $postTamperCandidate.transition.action = "claim"
  $postTamperCandidate.transition.from_mode = "ready"
  $postTamperCandidate.transition.to_mode = "active"
  $postTamperCandidate.transition.parent_state_revision = 1
  $postTamperStage = Stage-ActivationCandidate `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $tamperedHistoricalParent `
    -CandidateState $postTamperCandidate `
    -StatePath $statePath `
    -HandoffPath $handoffPath `
    -HandoffContent $tamperedHistoricalHandoff `
    -SliceLogPath $sliceLogPath `
    -SliceLogContent $sliceLogAfter
  $postTamperReport = Invoke-TransitionValidation `
    -ScriptPath $validatorPath `
    -RepositoryRoot $repositoryRoot `
    -ParentCommit $tamperedHistoricalParent `
    -TreeHash ([string]$postTamperStage.tree_hash)
  Assert-Equal `
    -Actual $postTamperReport.code `
    -Expected "BOOTSTRAP_HANDOFF_INVALID" `
    -Message "Historical activation accounting was re-anchored to an intervening tamper."

  [pscustomobject][ordered]@{
    document_type = "danio_autonomous_completion_activation_fixture_test_result"
    schema_version = 1
    passed = $true
    scenarios = 24
    mutations_performed = $false
  } | ConvertTo-Json -Compress
} finally {
  $resolvedTempRoot = [IO.Path]::GetFullPath($tempRoot)
  if (-not $resolvedTempRoot.StartsWith($tempBase, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to remove fixture outside the system temp directory: $resolvedTempRoot"
  }
  if (Test-Path -LiteralPath $resolvedTempRoot) {
    Remove-Item -LiteralPath "\\?\$resolvedTempRoot" -Recurse -Force
  }
  $resolvedOutsideRoot = [IO.Path]::GetFullPath($outsideRepositoryRoot)
  $outsidePrefix = $localAppDataBase.TrimEnd("\", "/") + [IO.Path]::DirectorySeparatorChar
  if (
    -not $resolvedOutsideRoot.StartsWith($outsidePrefix, [StringComparison]::OrdinalIgnoreCase) -or
    [IO.Path]::GetFileName($resolvedOutsideRoot) -cne $outsideFixtureName
  ) {
    throw "Refusing to remove outside fixture with failed containment: $resolvedOutsideRoot"
  }
  if (Test-Path -LiteralPath $resolvedOutsideRoot) {
    Remove-Item -LiteralPath "\\?\$resolvedOutsideRoot" -Recurse -Force
  }
}
