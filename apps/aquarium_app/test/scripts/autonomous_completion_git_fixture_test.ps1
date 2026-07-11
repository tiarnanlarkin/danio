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

function Invoke-Git {
  param(
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string[]]$GitArguments
  )

  $priorErrorActionPreference = $ErrorActionPreference
  try {
    $ErrorActionPreference = "Continue"
    $output = @(& git -c core.longpaths=true -C $RepositoryRoot @GitArguments 2>&1)
    $exitCode = $LASTEXITCODE
  } finally {
    $ErrorActionPreference = $priorErrorActionPreference
  }
  if ($exitCode -ne 0) {
    throw "Git command failed ($exitCode): git -C '$RepositoryRoot' $($GitArguments -join ' ')`n$($output -join "`n")"
  }
  return ($output -join "`n").TrimEnd()
}

function Invoke-GitWithoutRepository {
  param([Parameter(Mandatory = $true)][string[]]$GitArguments)

  $priorErrorActionPreference = $ErrorActionPreference
  try {
    $ErrorActionPreference = "Continue"
    $output = @(& git @GitArguments 2>&1)
    $exitCode = $LASTEXITCODE
  } finally {
    $ErrorActionPreference = $priorErrorActionPreference
  }
  if ($exitCode -ne 0) {
    throw "Git command failed ($exitCode): git $($GitArguments -join ' ')`n$($output -join "`n")"
  }
  return ($output -join "`n").TrimEnd()
}

function Get-RepositorySnapshot {
  param([Parameter(Mandatory = $true)][string]$RepositoryRoot)

  $indexPath = Join-Path $RepositoryRoot ".git/index"
  return [pscustomobject]@{
    refs = Invoke-Git -RepositoryRoot $RepositoryRoot -GitArguments @("show-ref")
    index_sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $indexPath).Hash
    worktrees = Invoke-Git -RepositoryRoot $RepositoryRoot -GitArguments @("worktree", "list", "--porcelain")
    status = Invoke-Git -RepositoryRoot $RepositoryRoot -GitArguments @("--no-optional-locks", "status", "--short", "-uall")
  }
}

function Assert-SnapshotEqual {
  param(
    [Parameter(Mandatory = $true)]$Before,
    [Parameter(Mandatory = $true)]$After,
    [Parameter(Mandatory = $true)][string]$Scenario
  )

  foreach ($field in @("refs", "index_sha256", "worktrees", "status")) {
    Assert-Equal `
      -Actual $After.$field `
      -Expected $Before.$field `
      -Message "Readiness mutated '$field' during $Scenario."
  }
}

function Invoke-Synchronization {
  param(
    [Parameter(Mandatory = $true)][string]$ScriptPath,
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string]$InvocationNonce
  )

  $output = @(& powershell `
    -NoProfile `
    -ExecutionPolicy Bypass `
    -File $ScriptPath `
    -RepositoryRoot $RepositoryRoot `
    -InvocationNonce $InvocationNonce)
  $exitCode = $LASTEXITCODE
  Assert-Equal -Actual $exitCode -Expected 0 -Message "Synchronization wrapper rejected a valid fixture."
  Assert-Equal -Actual $output.Count -Expected 1 -Message "Synchronization wrapper emitted more than one stdout object."
  return $output[0] | ConvertFrom-Json
}

function Invoke-Readiness {
  param(
    [Parameter(Mandatory = $true)][string]$ScriptPath,
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string]$InvocationNonce,
    [Parameter(Mandatory = $true)]$Receipt
  )

  $receiptJson = $Receipt | ConvertTo-Json -Depth 100 -Compress
  $receiptBase64 = [Convert]::ToBase64String(
    [Text.Encoding]::UTF8.GetBytes($receiptJson)
  )
  $escapedScriptPath = $ScriptPath.Replace("'", "''")
  $escapedRepositoryRoot = $RepositoryRoot.Replace("'", "''")
  $escapedInvocationNonce = $InvocationNonce.Replace("'", "''")
  $childCommand = @"
`$receiptJson = [Text.Encoding]::UTF8.GetString(
  [Convert]::FromBase64String('$receiptBase64')
)
& '$escapedScriptPath' ``
  -Intent Launch ``
  -SynchronizationReceiptJson `$receiptJson ``
  -ExpectedInvocationNonce '$escapedInvocationNonce' ``
  -RepositoryRoot '$escapedRepositoryRoot'
"@
  $encodedCommand = [Convert]::ToBase64String(
    [Text.Encoding]::Unicode.GetBytes($childCommand)
  )
  $output = @(& powershell `
    -NoProfile `
    -NonInteractive `
    -ExecutionPolicy Bypass `
    -EncodedCommand $encodedCommand `
    2>$null)
  $exitCode = $LASTEXITCODE
  Assert-True -Condition (@(0, 1) -contains $exitCode) -Message "Readiness wrapper returned an unsupported exit code."
  Assert-Equal -Actual $output.Count -Expected 1 -Message "Readiness wrapper emitted more than one stdout object."
  $report = $output[0] | ConvertFrom-Json
  Assert-Equal -Actual $report.eligible -Expected ($exitCode -eq 0) -Message "Readiness JSON and exit code disagreed."
  return $report
}

function Get-ExpectedWriterIdentity {
  param(
    [Parameter(Mandatory = $true)][string]$RunId,
    [Parameter(Mandatory = $true)][string]$WorkUnitId,
    [Parameter(Mandatory = $true)][string]$TaskId,
    [Parameter(Mandatory = $true)][int64]$ExpectedStateRevision,
    [Parameter(Mandatory = $true)][string]$SavedProjectRoot
  )

  $tokenInput = @(
    $RunId,
    $WorkUnitId,
    $TaskId,
    [string]$ExpectedStateRevision
  ) -join "`n"
  $tokenBytes = [Text.Encoding]::UTF8.GetBytes($tokenInput)
  $tokenHash = [Security.Cryptography.SHA256]::Create().ComputeHash($tokenBytes)
  $token = ([BitConverter]::ToString($tokenHash)).Replace("-", "").ToLowerInvariant()
  $token12 = $token.Substring(0, 12)
  $worktreeId = "$RunId-$WorkUnitId-$token12"
  $normalizedSavedProjectRoot = $SavedProjectRoot.Replace("\", "/").TrimEnd("/")

  return [pscustomobject]@{
    token_sha256 = $token
    branch_name = "autonomy/$RunId/$WorkUnitId/$token12"
    worktree_id = $worktreeId
    worktree_path = "$normalizedSavedProjectRoot/.codex-worktrees/$worktreeId"
  }
}

function Invoke-ClaimPlanner {
  param(
    [Parameter(Mandatory = $true)][string]$ScriptPath,
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)]$ReadinessReport,
    [Parameter(Mandatory = $true)][string]$TaskId,
    [Parameter(Mandatory = $true)][int64]$ExpectedStateRevision,
    [AllowNull()][string]$WorktreeRoot = $null,
    [AllowNull()][string]$GitShimDirectory = $null
  )

  $readinessJson = $ReadinessReport | ConvertTo-Json -Depth 100 -Compress
  $readinessBase64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($readinessJson))
  $escapedScriptPath = $ScriptPath.Replace("'", "''")
  $escapedRepositoryRoot = $RepositoryRoot.Replace("'", "''")
  $escapedTaskId = $TaskId.Replace("'", "''")
  $childCommand = @"
`$readinessJson = [Text.Encoding]::UTF8.GetString(
  [Convert]::FromBase64String('$readinessBase64')
)
`$parameters = @{
  ReadinessReportJson = `$readinessJson
  TaskId = '$escapedTaskId'
  ExpectedStateRevision = [int64]$ExpectedStateRevision
  RepositoryRoot = '$escapedRepositoryRoot'
}
"@
  if (-not [string]::IsNullOrWhiteSpace($WorktreeRoot)) {
    $escapedWorktreeRoot = $WorktreeRoot.Replace("'", "''")
    $childCommand += "`n`$parameters.WorktreeRoot = '$escapedWorktreeRoot'"
  }
  if (-not [string]::IsNullOrWhiteSpace($GitShimDirectory)) {
    $escapedGitShimDirectory = $GitShimDirectory.Replace("'", "''")
    $childCommand += "`n`$env:PATH = '$escapedGitShimDirectory;' + `$env:PATH"
  }
  $childCommand += "`n& '$escapedScriptPath' @parameters"
  $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($childCommand))
  $output = @(& powershell `
    -NoProfile `
    -NonInteractive `
    -ExecutionPolicy Bypass `
    -EncodedCommand $encodedCommand `
    2>$null)
  $exitCode = $LASTEXITCODE
  Assert-True -Condition (@(0, 1) -contains $exitCode) -Message "Claim planner returned an unsupported exit code."
  Assert-Equal -Actual $output.Count -Expected 1 -Message "Claim planner emitted more than one stdout object."
  $plan = $output[0] | ConvertFrom-Json
  Assert-Equal -Actual $plan.valid -Expected ($exitCode -eq 0) -Message "Claim planner JSON and exit code disagreed."
  Assert-Equal -Actual $plan.mutations_performed -Expected $false -Message "Claim planner reported mutation."
  return $plan
}

function Invoke-TransitionValidation {
  param(
    [Parameter(Mandatory = $true)][string]$ScriptPath,
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string]$Source,
    [AllowNull()][string]$ExpectedParentCommit = $null,
    [AllowNull()][string]$ExpectedStagedTreeHash = $null,
    [string]$Commit = "HEAD"
  )

  $arguments = @(
    "-NoProfile",
    "-NonInteractive",
    "-ExecutionPolicy",
    "Bypass",
    "-File",
    $ScriptPath,
    "-Source",
    $Source,
    "-RepositoryRoot",
    $RepositoryRoot,
    "-Commit",
    $Commit
  )
  if (-not [string]::IsNullOrWhiteSpace($ExpectedParentCommit)) {
    $arguments += @("-ExpectedParentCommit", $ExpectedParentCommit)
  }
  if (-not [string]::IsNullOrWhiteSpace($ExpectedStagedTreeHash)) {
    $arguments += @("-ExpectedStagedTreeHash", $ExpectedStagedTreeHash)
  }
  $output = @(& powershell @arguments 2>$null)
  $exitCode = $LASTEXITCODE
  Assert-True -Condition (@(0, 1) -contains $exitCode) -Message "Transition validator returned an unsupported exit code."
  Assert-Equal -Actual $output.Count -Expected 1 -Message "Transition validator emitted more than one stdout object."
  $report = $output[0] | ConvertFrom-Json
  Assert-Equal -Actual $report.valid -Expected ($exitCode -eq 0) -Message "Transition validator JSON and exit code disagreed."
  Assert-Equal -Actual $report.mutations_performed -Expected $false -Message "Transition validator reported mutation."
  return $report
}

function Write-FixtureJson {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)]$Value
  )

  $directory = Split-Path -Parent $Path
  if (-not (Test-Path -LiteralPath $directory -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
  }
  $json = $Value | ConvertTo-Json -Depth 100
  [IO.File]::WriteAllText($Path, $json, (New-Object Text.UTF8Encoding($false)))
}

function Assert-ReadinessNoMutation {
  param(
    [Parameter(Mandatory = $true)][string]$SyncScriptPath,
    [Parameter(Mandatory = $true)][string]$ReadinessScriptPath,
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string]$InvocationNonce,
    [Parameter(Mandatory = $true)][string]$ExpectedStopReason,
    [Parameter(Mandatory = $true)][string]$Scenario
  )

  $receipt = Invoke-Synchronization `
    -ScriptPath $SyncScriptPath `
    -RepositoryRoot $RepositoryRoot `
    -InvocationNonce $InvocationNonce
  $before = Get-RepositorySnapshot -RepositoryRoot $RepositoryRoot
  $report = Invoke-Readiness `
    -ScriptPath $ReadinessScriptPath `
    -RepositoryRoot $RepositoryRoot `
    -InvocationNonce $InvocationNonce `
    -Receipt $receipt
  $after = Get-RepositorySnapshot -RepositoryRoot $RepositoryRoot
  Assert-SnapshotEqual -Before $before -After $after -Scenario $Scenario
  Assert-Equal `
    -Actual $report.stop_reason_code `
    -Expected $ExpectedStopReason `
    -Message "Unexpected stop reason during $Scenario. Checks: $($report.checks | ConvertTo-Json -Depth 20 -Compress)"
}

$testRoot = (Resolve-Path -LiteralPath $PSScriptRoot).Path
$appRoot = (Resolve-Path -LiteralPath (Join-Path $testRoot "../..")).Path
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $appRoot "../..")).Path
$syncScriptPath = Join-Path $appRoot "scripts/autonomous_completion/sync_autonomous_completion.ps1"
$readinessScriptPath = Join-Path $appRoot "scripts/autonomous_completion/check_autonomous_completion_readiness.ps1"
$transitionScriptPath = Join-Path $appRoot "scripts/autonomous_completion/validate_autonomous_completion_transition.ps1"
$claimPlannerScriptPath = Join-Path $appRoot "scripts/autonomous_completion/plan_autonomous_writer_claim.ps1"

if (-not (Test-Path -LiteralPath $syncScriptPath -PathType Leaf)) {
  throw "Expected synchronization wrapper is missing: $syncScriptPath"
}
if (-not (Test-Path -LiteralPath $readinessScriptPath -PathType Leaf)) {
  throw "Expected readiness wrapper is missing: $readinessScriptPath"
}
if (-not (Test-Path -LiteralPath $transitionScriptPath -PathType Leaf)) {
  throw "Expected transition validation wrapper is missing: $transitionScriptPath"
}
if (-not (Test-Path -LiteralPath $claimPlannerScriptPath -PathType Leaf)) {
  throw "Expected claim planner wrapper is missing: $claimPlannerScriptPath"
}
Import-Module -Name (Join-Path $appRoot "scripts/autonomous_completion/DanioAutonomousCompletion.psm1") -Force

$tempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$tempRoot = Join-Path $tempBase "danio-autonomy-$([Guid]::NewGuid().ToString('N'))"
$remoteRoot = Join-Path $tempRoot "remote.git"
$seedRoot = Join-Path $tempRoot "seed"
$cloneOneRoot = Join-Path $tempRoot "clone-one"
$cloneTwoRoot = Join-Path $tempRoot "clone-two"
$foreignWorktreeRoot = Join-Path $tempRoot "foreign-worktree"
$invocationNonce = "0123456789abcdef0123456789abcdef"

try {
  New-Item -ItemType Directory -Path $tempRoot | Out-Null
  [void](Invoke-GitWithoutRepository -GitArguments @("init", "--bare", $remoteRoot))
  [void](Invoke-GitWithoutRepository -GitArguments @("init", $seedRoot))
  [void](Invoke-Git -RepositoryRoot $seedRoot -GitArguments @("checkout", "-b", "main"))
  [void](Invoke-Git -RepositoryRoot $seedRoot -GitArguments @("config", "user.name", "Danio Fixture"))
  [void](Invoke-Git -RepositoryRoot $seedRoot -GitArguments @("config", "user.email", "danio-fixture@example.invalid"))

  $fixtureRelativePaths = @(
    "apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md",
    "apps/aquarium_app/docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md",
    "apps/aquarium_app/docs/agent/FINISH_MAP.md",
    "apps/aquarium_app/docs/agent/QUALITY_LADDER.md",
    "apps/aquarium_app/docs/agent/VERIFIED_SLICE_EXECUTION_CONTRACT.md",
    "apps/aquarium_app/docs/agent/DEVICE_OWNERSHIP.md",
    "apps/aquarium_app/docs/agent/plans/2026-07-11-phone-complete-local-completion-program.md",
    "apps/aquarium_app/docs/agent/autonomous_completion/runner_compatibility.json"
  )
  foreach ($relativePath in $fixtureRelativePaths) {
    $sourcePath = Join-Path $repoRoot $relativePath
    $destinationPath = Join-Path $seedRoot $relativePath
    $destinationDirectory = Split-Path -Parent $destinationPath
    New-Item -ItemType Directory -Force -Path $destinationDirectory | Out-Null
    Copy-Item -LiteralPath $sourcePath -Destination $destinationPath
  }

  [void](Invoke-Git -RepositoryRoot $seedRoot -GitArguments @("add", "apps/aquarium_app"))
  [void](Invoke-Git -RepositoryRoot $seedRoot -GitArguments @("commit", "-m", "fixture: seed Danio authority"))
  [void](Invoke-Git -RepositoryRoot $seedRoot -GitArguments @("remote", "add", "origin", $remoteRoot))
  [void](Invoke-Git -RepositoryRoot $seedRoot -GitArguments @("push", "-u", "origin", "main"))
  [void](Invoke-Git -RepositoryRoot $remoteRoot -GitArguments @("symbolic-ref", "HEAD", "refs/heads/main"))
  [void](Invoke-GitWithoutRepository -GitArguments @("clone", $remoteRoot, $cloneOneRoot))
  [void](Invoke-GitWithoutRepository -GitArguments @("clone", $remoteRoot, $cloneTwoRoot))
  [void](Invoke-Git -RepositoryRoot $cloneTwoRoot -GitArguments @("config", "user.name", "Danio Fixture Two"))
  [void](Invoke-Git -RepositoryRoot $cloneTwoRoot -GitArguments @("config", "user.email", "danio-fixture-two@example.invalid"))

  Assert-ReadinessNoMutation `
    -SyncScriptPath $syncScriptPath `
    -ReadinessScriptPath $readinessScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -InvocationNonce $invocationNonce `
    -ExpectedStopReason "RUNNER_INCOMPATIBLE" `
    -Scenario "clean launch-blocked fixture"

  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("switch", "-c", "fixture-wrong-source"))
  Assert-ReadinessNoMutation `
    -SyncScriptPath $syncScriptPath `
    -ReadinessScriptPath $readinessScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -InvocationNonce $invocationNonce `
    -ExpectedStopReason "WRONG_SOURCE_BRANCH" `
    -Scenario "wrong source branch"
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("switch", "main"))
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("branch", "-D", "fixture-wrong-source"))

  $untrackedPath = Join-Path $cloneOneRoot "fixture-untracked.txt"
  Set-Content -LiteralPath $untrackedPath -Value "untracked fixture"
  Assert-ReadinessNoMutation `
    -SyncScriptPath $syncScriptPath `
    -ReadinessScriptPath $readinessScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -InvocationNonce $invocationNonce `
    -ExpectedStopReason "DIRTY_UNOWNED" `
    -Scenario "untracked fixture dirt"
  Remove-Item -LiteralPath $untrackedPath

  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @(
    "worktree",
    "add",
    "-b",
    "fixture-foreign-worktree",
    $foreignWorktreeRoot,
    "main"
  ))
  Assert-ReadinessNoMutation `
    -SyncScriptPath $syncScriptPath `
    -ReadinessScriptPath $readinessScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -InvocationNonce $invocationNonce `
    -ExpectedStopReason "DIRTY_UNOWNED" `
    -Scenario "foreign worktree ownership"
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("worktree", "remove", $foreignWorktreeRoot))
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("branch", "-D", "fixture-foreign-worktree"))

  $ownedWorktreeRoot = Join-Path $tempRoot "owned-worktree"
  $ownedBranch = "autonomy/fixture-run/fixture-unit/000000000000"
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @(
    "worktree",
    "add",
    "-b",
    $ownedBranch,
    $ownedWorktreeRoot,
    "main"
  ))
  $ownedState = [pscustomobject]@{
    mode = "active"
    owner = [pscustomobject]@{
      branch_name = $ownedBranch
      worktree_path = $ownedWorktreeRoot.Replace("\", "/")
    }
    authority = [pscustomobject]@{}
  }
  $ownedObservation = Get-DanioRepositoryObservation `
    -RepositoryRoot $cloneOneRoot `
    -State $ownedState
  Assert-True `
    -Condition $ownedObservation.ownership_clear `
    -Message "The exact recorded owner branch/worktree was classified as foreign."
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("worktree", "remove", $ownedWorktreeRoot))
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("branch", "-D", $ownedBranch))
  $missingActiveOwnerObservation = Get-DanioRepositoryObservation `
    -RepositoryRoot $cloneOneRoot `
    -State $ownedState
  Assert-True `
    -Condition (-not $missingActiveOwnerObservation.ownership_clear) `
    -Message "Active readiness accepted a missing recorded owner branch/worktree."
  $finalizingOwnedState = [pscustomobject]@{
    mode = "finalizing"
    owner = $ownedState.owner
    authority = [pscustomobject]@{}
  }
  $missingFinalizingOwnerObservation = Get-DanioRepositoryObservation `
    -RepositoryRoot $cloneOneRoot `
    -State $finalizingOwnedState
  Assert-True `
    -Condition $missingFinalizingOwnerObservation.ownership_clear `
    -Message "Finalizing cleanup absence was misclassified as foreign ownership."

  $authorityPaths = [ordered]@{
    phone_completion_program = "apps/aquarium_app/docs/agent/plans/2026-07-11-phone-complete-local-completion-program.md"
    closure_ledger = "apps/aquarium_app/docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md"
    finish_map = "apps/aquarium_app/docs/agent/FINISH_MAP.md"
    quality_ladder = "apps/aquarium_app/docs/agent/QUALITY_LADDER.md"
    verified_slice_execution_contract = "apps/aquarium_app/docs/agent/VERIFIED_SLICE_EXECUTION_CONTRACT.md"
    active_handoff = "apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md"
    device_ownership_policy = "apps/aquarium_app/docs/agent/DEVICE_OWNERSHIP.md"
  }
  $authorityCommit = Invoke-Git `
    -RepositoryRoot $cloneOneRoot `
    -GitArguments @("rev-parse", "origin/main")
  $authorityReferences = [ordered]@{}
  foreach ($authorityName in $authorityPaths.Keys) {
    $authorityPath = $authorityPaths[$authorityName]
    $authorityReferences[$authorityName] = [pscustomobject]@{
      path = $authorityPath
      commit = $authorityCommit
      blob_oid = Invoke-Git `
        -RepositoryRoot $cloneOneRoot `
        -GitArguments @("rev-parse", "${authorityCommit}:$authorityPath")
    }
  }
  $authorityState = [pscustomobject]@{
    authority = [pscustomobject]$authorityReferences
  }
  $authorityBeforeAdvance = Get-DanioRepositoryObservation `
    -RepositoryRoot $cloneOneRoot `
    -State $authorityState
  Assert-True `
    -Condition $authorityBeforeAdvance.authority_validation.valid `
    -Message "Canonical authority pins were invalid before origin/main moved."

  $programRelativePath = $authorityPaths.phone_completion_program
  $programPath = Join-Path $cloneTwoRoot $programRelativePath
  Add-Content -LiteralPath $programPath -Value "`nFixture remote authority advance."
  [void](Invoke-Git -RepositoryRoot $cloneTwoRoot -GitArguments @("add", $programRelativePath))
  [void](Invoke-Git -RepositoryRoot $cloneTwoRoot -GitArguments @("commit", "-m", "fixture: advance remote"))
  [void](Invoke-Git -RepositoryRoot $cloneTwoRoot -GitArguments @("push", "origin", "main"))
  Assert-ReadinessNoMutation `
    -SyncScriptPath $syncScriptPath `
    -ReadinessScriptPath $readinessScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -InvocationNonce $invocationNonce `
    -ExpectedStopReason "REMOTE_DIVERGED" `
    -Scenario "remote divergence"

  $beforeAuthorityObservation = Get-RepositorySnapshot -RepositoryRoot $cloneOneRoot
  $authorityAfterAdvance = Get-DanioRepositoryObservation `
    -RepositoryRoot $cloneOneRoot `
    -State $authorityState
  $afterAuthorityObservation = Get-RepositorySnapshot -RepositoryRoot $cloneOneRoot
  Assert-SnapshotEqual `
    -Before $beforeAuthorityObservation `
    -After $afterAuthorityObservation `
    -Scenario "authority movement observation"
  Assert-True `
    -Condition (-not $authorityAfterAdvance.authority_validation.valid) `
    -Message "Authority validation accepted a program blob that moved on origin/main."
  Assert-Equal `
    -Actual $authorityAfterAdvance.authority_validation.code `
    -Expected "AUTHORITY_CONFLICT" `
    -Message "Authority movement returned the wrong validation code."

  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("config", "user.name", "Danio Fixture One"))
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("config", "user.email", "danio-fixture-one@example.invalid"))
  $stateRelativePath = "apps/aquarium_app/docs/agent/autonomous_completion/phone_completion_run_state.json"
  $readyFixturePath = Join-Path $appRoot "test/scripts/fixtures/autonomous_completion/ready_run_state.json"
  $readyState = Get-Content -Raw -LiteralPath $readyFixturePath | ConvertFrom-Json
  $readyState.authorization.saved_project_root = $tempRoot.Replace("\", "/")
  $readyState.authorization.repository_root = $cloneOneRoot.Replace("\", "/")
  $cloneTwoStatePath = Join-Path $cloneTwoRoot $stateRelativePath
  Write-FixtureJson -Path $cloneTwoStatePath -Value $readyState
  [void](Invoke-Git -RepositoryRoot $cloneTwoRoot -GitArguments @("add", $stateRelativePath))
  [void](Invoke-Git -RepositoryRoot $cloneTwoRoot -GitArguments @("commit", "-m", "fixture: add ready run state"))
  [void](Invoke-Git -RepositoryRoot $cloneTwoRoot -GitArguments @("push", "origin", "main"))
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("fetch", "--prune"))
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("merge", "--ff-only", "origin/main"))

  $claimBaseCommit = Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("rev-parse", "HEAD")
  $claimBaseTree = Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("rev-parse", "$claimBaseCommit^{tree}")
  $claimTaskId = "task-fixture-001"
  $claimReadiness = [pscustomobject]@{
    document_type = "danio_readiness_report"
    schema_version = 1
    intent = "Claim"
    checked_at_utc = "2026-07-11T12:00:30.0000000Z"
    eligible = $true
    stop_reason_code = $null
    checks = @(
      [pscustomobject]@{
        code = "CLAIM_READY"
        status = "pass"
        detail = "Disposable claim prerequisites validate."
      }
    )
  }
  $claimIdentity = Get-ExpectedWriterIdentity `
    -RunId ([string]$readyState.run_id) `
    -WorkUnitId ([string]$readyState.cursor.work_unit_id) `
    -TaskId $claimTaskId `
    -ExpectedStateRevision ([int64]$readyState.state_revision) `
    -SavedProjectRoot ([string]$readyState.authorization.saved_project_root)
  $expectedWorktreeRoot = Join-Path $tempRoot ".codex-worktrees"
  $longestFixturePath = @(
    (
      Invoke-Git `
        -RepositoryRoot $cloneOneRoot `
        -GitArguments @("ls-tree", "-r", "--name-only", $claimBaseCommit)
    ) -split "`r?`n"
  ) | Sort-Object Length -Descending | Select-Object -First 1
  $projectedCheckoutLength = $claimIdentity.worktree_path.Length + 1 + $longestFixturePath.Length
  Assert-True `
    -Condition ($projectedCheckoutLength -gt 260) `
    -Message "Long-path reuse fixture no longer exceeds the legacy Windows path boundary."

  $beforeAbsentPlan = Get-RepositorySnapshot -RepositoryRoot $cloneOneRoot
  $expectedPathExistedBefore = Test-Path -LiteralPath $claimIdentity.worktree_path
  $absentPlan = Invoke-ClaimPlanner `
    -ScriptPath $claimPlannerScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -ReadinessReport $claimReadiness `
    -TaskId $claimTaskId `
    -ExpectedStateRevision ([int64]$readyState.state_revision) `
    -WorktreeRoot $expectedWorktreeRoot
  $afterAbsentPlan = Get-RepositorySnapshot -RepositoryRoot $cloneOneRoot
  Assert-SnapshotEqual -Before $beforeAbsentPlan -After $afterAbsentPlan -Scenario "absent writer claim planning"
  Assert-Equal `
    -Actual (Test-Path -LiteralPath $claimIdentity.worktree_path) `
    -Expected $expectedPathExistedBefore `
    -Message "Absent writer claim planning created its worktree path."
  Assert-True -Condition $absentPlan.valid -Message "Absent deterministic identity was rejected: $($absentPlan.details -join '; ')"
  Assert-Equal -Actual $absentPlan.code -Expected "CLAIM_PLAN_VALID" -Message "Absent identity plan code mismatch."
  Assert-Equal -Actual $absentPlan.base_commit -Expected $claimBaseCommit -Message "Claim plan base commit mismatch."
  Assert-Equal `
    -Actual $absentPlan.next_run_state.owner.claim_staged_tree_hash `
    -Expected $claimBaseTree `
    -Message "Claim plan did not record the clean parent tree."

  $outsideWorktreeRoot = Join-Path $tempRoot "outside-worktrees"
  $outsidePlan = Invoke-ClaimPlanner `
    -ScriptPath $claimPlannerScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -ReadinessReport $claimReadiness `
    -TaskId $claimTaskId `
    -ExpectedStateRevision ([int64]$readyState.state_revision) `
    -WorktreeRoot $outsideWorktreeRoot
  Assert-Equal -Actual $outsidePlan.code -Expected "OWNER_IDENTITY_INVALID" -Message "Outside worktree root was accepted."

  $reparseTarget = Join-Path $tempRoot "reparse-target"
  New-Item -ItemType Directory -Path $reparseTarget | Out-Null
  New-Item -ItemType Junction -Path $expectedWorktreeRoot -Target $reparseTarget | Out-Null
  $reparsePlan = Invoke-ClaimPlanner `
    -ScriptPath $claimPlannerScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -ReadinessReport $claimReadiness `
    -TaskId $claimTaskId `
    -ExpectedStateRevision ([int64]$readyState.state_revision) `
    -WorktreeRoot $expectedWorktreeRoot
  Assert-Equal -Actual $reparsePlan.code -Expected "OWNER_IDENTITY_INVALID" -Message "Reparse-point escape was accepted."
  Remove-Item -LiteralPath $expectedWorktreeRoot -Force
  Assert-True -Condition (Test-Path -LiteralPath $reparseTarget -PathType Container) -Message "Removing the fixture junction removed its target."

  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @(
    "worktree",
    "add",
    "-b",
    $claimIdentity.branch_name,
    $claimIdentity.worktree_path,
    $claimBaseCommit
  ))
  $beforeReusablePlan = Get-RepositorySnapshot -RepositoryRoot $cloneOneRoot
  $reusablePlan = Invoke-ClaimPlanner `
    -ScriptPath $claimPlannerScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -ReadinessReport $claimReadiness `
    -TaskId $claimTaskId `
    -ExpectedStateRevision ([int64]$readyState.state_revision) `
    -WorktreeRoot $expectedWorktreeRoot
  $afterReusablePlan = Get-RepositorySnapshot -RepositoryRoot $cloneOneRoot
  Assert-SnapshotEqual -Before $beforeReusablePlan -After $afterReusablePlan -Scenario "exact writer identity reuse"
  Assert-True -Condition $reusablePlan.valid -Message "Exact quiescent writer identity was rejected."
  Assert-Equal -Actual $reusablePlan.owner_token_sha256 -Expected $claimIdentity.token_sha256 -Message "Exact reuse changed owner identity."

  $processMarkerScriptPath = Join-Path $tempRoot "writer-process-marker.ps1"
  $processMarkerScript = @'
param([Parameter(Mandatory = $true)][string]$Marker)
Start-Sleep -Seconds 60
'@
  [IO.File]::WriteAllText(
    $processMarkerScriptPath,
    $processMarkerScript,
    (New-Object Text.UTF8Encoding($false))
  )
  $nativeWorktreeMarker = $claimIdentity.worktree_path.Replace("/", "\")
  $markerProcess = Start-Process `
    -FilePath "powershell.exe" `
    -ArgumentList @(
      "-NoProfile",
      "-NonInteractive",
      "-ExecutionPolicy",
      "Bypass",
      "-File",
      "`"$processMarkerScriptPath`"",
      "-Marker",
      "`"$nativeWorktreeMarker`""
    ) `
    -WindowStyle Hidden `
    -PassThru
  try {
    Start-Sleep -Milliseconds 500
    $activeProcessPlan = Invoke-ClaimPlanner `
      -ScriptPath $claimPlannerScriptPath `
      -RepositoryRoot $cloneOneRoot `
      -ReadinessReport $claimReadiness `
      -TaskId $claimTaskId `
      -ExpectedStateRevision ([int64]$readyState.state_revision) `
      -WorktreeRoot $expectedWorktreeRoot
    Assert-Equal `
      -Actual $activeProcessPlan.code `
      -Expected "WRITER_IDENTITY_CONFLICT" `
      -Message "Active process using a native Windows worktree path was accepted for exact reuse."
  } finally {
    if (-not $markerProcess.HasExited) {
      Stop-Process -Id $markerProcess.Id -Force
      $markerProcess.WaitForExit()
    }
  }

  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("worktree", "remove", $claimIdentity.worktree_path))
  $partialPlan = Invoke-ClaimPlanner `
    -ScriptPath $claimPlannerScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -ReadinessReport $claimReadiness `
    -TaskId $claimTaskId `
    -ExpectedStateRevision ([int64]$readyState.state_revision) `
    -WorktreeRoot $expectedWorktreeRoot
  Assert-Equal -Actual $partialPlan.code -Expected "WRITER_IDENTITY_CONFLICT" -Message "Branch-only partial identity was accepted."
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("branch", "-D", $claimIdentity.branch_name))

  $fatalProbeTaskId = "task-fixture-fatal-probe"
  $gitShimRoot = Join-Path $tempRoot "git-shim"
  New-Item -ItemType Directory -Path $gitShimRoot | Out-Null
  $gitShimPath = Join-Path $gitShimRoot "git.ps1"
  $realGitPath = (Get-Command git.exe -ErrorAction Stop).Source.Replace("'", "''")
  $gitShim = @"
if (@(`$args) -contains "show-ref") {
  Write-Output "injected show-ref observation failure"
  exit 2
}
& '$realGitPath' @args
exit `$LASTEXITCODE
"@
  [IO.File]::WriteAllText(
    $gitShimPath,
    $gitShim,
    (New-Object Text.UTF8Encoding($false))
  )
  $fatalProbePlan = Invoke-ClaimPlanner `
    -ScriptPath $claimPlannerScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -ReadinessReport $claimReadiness `
    -TaskId $fatalProbeTaskId `
    -ExpectedStateRevision ([int64]$readyState.state_revision) `
    -WorktreeRoot $expectedWorktreeRoot `
    -GitShimDirectory $gitShimRoot
  Assert-Equal `
    -Actual $fatalProbePlan.code `
    -Expected "WRITER_IDENTITY_CONFLICT" `
    -Message "Fatal branch probe was misclassified as an absent identity."

  $plainTaskId = "task-fixture-plain"
  $plainIdentity = Get-ExpectedWriterIdentity `
    -RunId ([string]$readyState.run_id) `
    -WorkUnitId ([string]$readyState.cursor.work_unit_id) `
    -TaskId $plainTaskId `
    -ExpectedStateRevision ([int64]$readyState.state_revision) `
    -SavedProjectRoot ([string]$readyState.authorization.saved_project_root)
  New-Item -ItemType Directory -Force -Path $plainIdentity.worktree_path | Out-Null
  $plainDirectoryPlan = Invoke-ClaimPlanner `
    -ScriptPath $claimPlannerScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -ReadinessReport $claimReadiness `
    -TaskId $plainTaskId `
    -ExpectedStateRevision ([int64]$readyState.state_revision) `
    -WorktreeRoot $expectedWorktreeRoot
  Assert-Equal -Actual $plainDirectoryPlan.code -Expected "WRITER_IDENTITY_CONFLICT" -Message "Plain-directory identity was accepted."
  Remove-Item -LiteralPath $plainIdentity.worktree_path -Force

  $wrongPathTaskId = "task-fixture-wrong-path"
  $wrongPathIdentity = Get-ExpectedWriterIdentity `
    -RunId ([string]$readyState.run_id) `
    -WorkUnitId ([string]$readyState.cursor.work_unit_id) `
    -TaskId $wrongPathTaskId `
    -ExpectedStateRevision ([int64]$readyState.state_revision) `
    -SavedProjectRoot ([string]$readyState.authorization.saved_project_root)
  $wrongRegisteredPath = Join-Path $tempRoot "wrong-registered-worktree"
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @(
    "worktree",
    "add",
    "-b",
    $wrongPathIdentity.branch_name,
    $wrongRegisteredPath,
    $claimBaseCommit
  ))
  $wrongPathPlan = Invoke-ClaimPlanner `
    -ScriptPath $claimPlannerScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -ReadinessReport $claimReadiness `
    -TaskId $wrongPathTaskId `
    -ExpectedStateRevision ([int64]$readyState.state_revision) `
    -WorktreeRoot $expectedWorktreeRoot
  Assert-Equal -Actual $wrongPathPlan.code -Expected "WRITER_IDENTITY_CONFLICT" -Message "Wrong registered worktree path was accepted."
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("worktree", "remove", $wrongRegisteredPath))
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("branch", "-D", $wrongPathIdentity.branch_name))

  $wrongCommitTaskId = "task-fixture-wrong-commit"
  $wrongCommitIdentity = Get-ExpectedWriterIdentity `
    -RunId ([string]$readyState.run_id) `
    -WorkUnitId ([string]$readyState.cursor.work_unit_id) `
    -TaskId $wrongCommitTaskId `
    -ExpectedStateRevision ([int64]$readyState.state_revision) `
    -SavedProjectRoot ([string]$readyState.authorization.saved_project_root)
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @(
    "worktree",
    "add",
    "-b",
    $wrongCommitIdentity.branch_name,
    $wrongCommitIdentity.worktree_path,
    $claimBaseCommit
  ))
  [void](Invoke-Git -RepositoryRoot $wrongCommitIdentity.worktree_path -GitArguments @("config", "user.name", "Danio Wrong Commit"))
  [void](Invoke-Git -RepositoryRoot $wrongCommitIdentity.worktree_path -GitArguments @("config", "user.email", "wrong-commit@example.invalid"))
  $wrongCommitFile = Join-Path $wrongCommitIdentity.worktree_path "wrong-commit.txt"
  Set-Content -LiteralPath $wrongCommitFile -Value "wrong commit"
  [void](Invoke-Git -RepositoryRoot $wrongCommitIdentity.worktree_path -GitArguments @("add", "wrong-commit.txt"))
  [void](Invoke-Git -RepositoryRoot $wrongCommitIdentity.worktree_path -GitArguments @("commit", "-m", "fixture: wrong reusable commit"))
  $wrongCommitPlan = Invoke-ClaimPlanner `
    -ScriptPath $claimPlannerScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -ReadinessReport $claimReadiness `
    -TaskId $wrongCommitTaskId `
    -ExpectedStateRevision ([int64]$readyState.state_revision) `
    -WorktreeRoot $expectedWorktreeRoot
  Assert-Equal -Actual $wrongCommitPlan.code -Expected "WRITER_IDENTITY_CONFLICT" -Message "Wrong reusable commit was accepted."
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("worktree", "remove", $wrongCommitIdentity.worktree_path))
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("branch", "-D", $wrongCommitIdentity.branch_name))

  $cloneOneStatePath = Join-Path $cloneOneRoot $stateRelativePath
  Write-FixtureJson -Path $cloneOneStatePath -Value $absentPlan.next_run_state
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("add", $stateRelativePath))
  $claimStagedTree = Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("write-tree")
  $beforeStagedValidation = Get-RepositorySnapshot -RepositoryRoot $cloneOneRoot
  $validStaged = Invoke-TransitionValidation `
    -ScriptPath $transitionScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -Source "Staged" `
    -ExpectedParentCommit $claimBaseCommit `
    -ExpectedStagedTreeHash $claimStagedTree
  $afterStagedValidation = Get-RepositorySnapshot -RepositoryRoot $cloneOneRoot
  Assert-SnapshotEqual -Before $beforeStagedValidation -After $afterStagedValidation -Scenario "valid staged transition validation"
  Assert-True -Condition $validStaged.valid -Message "Valid staged claim transition was rejected: $($validStaged.details -join '; ')"

  $treeMismatch = Invoke-TransitionValidation `
    -ScriptPath $transitionScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -Source "Staged" `
    -ExpectedParentCommit $claimBaseCommit `
    -ExpectedStagedTreeHash ("0" * 40)
  Assert-Equal -Actual $treeMismatch.code -Expected "STAGED_TREE_MISMATCH" -Message "Staged tree mismatch was accepted."

  $postGateDirtPath = Join-Path $cloneOneRoot "post-gate-dirt.txt"
  Set-Content -LiteralPath $postGateDirtPath -Value "post gate dirt"
  $beforeDirtyValidation = Get-RepositorySnapshot -RepositoryRoot $cloneOneRoot
  $dirtyAfterGate = Invoke-TransitionValidation `
    -ScriptPath $transitionScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -Source "Staged" `
    -ExpectedParentCommit $claimBaseCommit `
    -ExpectedStagedTreeHash $claimStagedTree
  $afterDirtyValidation = Get-RepositorySnapshot -RepositoryRoot $cloneOneRoot
  Assert-SnapshotEqual -Before $beforeDirtyValidation -After $afterDirtyValidation -Scenario "dirty-after-gate validation"
  Assert-Equal -Actual $dirtyAfterGate.code -Expected "DIRTY_AFTER_GATE" -Message "Post-gate dirt was accepted."
  Remove-Item -LiteralPath $postGateDirtPath

  $revisionSkip = $absentPlan.next_run_state | ConvertTo-Json -Depth 100 | ConvertFrom-Json
  $revisionSkip.state_revision = [int64]$readyState.state_revision + 2
  Write-FixtureJson -Path $cloneOneStatePath -Value $revisionSkip
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("add", $stateRelativePath))
  $revisionSkipTree = Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("write-tree")
  $revisionSkipReport = Invoke-TransitionValidation `
    -ScriptPath $transitionScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -Source "Staged" `
    -ExpectedParentCommit $claimBaseCommit `
    -ExpectedStagedTreeHash $revisionSkipTree
  Assert-Equal -Actual $revisionSkipReport.code -Expected "STATE_REVISION_INVALID" -Message "Staged revision skip was accepted."

  $forbiddenTransition = $absentPlan.next_run_state | ConvertTo-Json -Depth 100 | ConvertFrom-Json
  $forbiddenTransition.mode = "complete"
  $forbiddenTransition.transition.action = "complete"
  $forbiddenTransition.transition.to_mode = "complete"
  Write-FixtureJson -Path $cloneOneStatePath -Value $forbiddenTransition
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("add", $stateRelativePath))
  $forbiddenTree = Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("write-tree")
  $forbiddenReport = Invoke-TransitionValidation `
    -ScriptPath $transitionScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -Source "Staged" `
    -ExpectedParentCommit $claimBaseCommit `
    -ExpectedStagedTreeHash $forbiddenTree
  Assert-Equal -Actual $forbiddenReport.code -Expected "TRANSITION_NOT_ALLOWED" -Message "Forbidden staged transition was accepted."

  Write-FixtureJson -Path $cloneOneStatePath -Value $absentPlan.next_run_state
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("add", $stateRelativePath))
  $claimStagedTree = Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("write-tree")
  $validTrailerBlock = @"
Danio-State-Tree: $claimStagedTree
Danio-State-Validation: pass
Danio-Docs-Profile: pass
Danio-Verified-At: 2026-07-11T12:20:00.0000000Z
"@
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @(
    "commit",
    "-m",
    "fixture: valid committed claim",
    "-m",
    $validTrailerBlock
  ))
  $validClaimCommit = Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("rev-parse", "HEAD")
  $beforeCommittedValidation = Get-RepositorySnapshot -RepositoryRoot $cloneOneRoot
  $validCommitted = Invoke-TransitionValidation `
    -ScriptPath $transitionScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -Source "Committed" `
    -ExpectedParentCommit $claimBaseCommit `
    -ExpectedStagedTreeHash $claimStagedTree `
    -Commit $validClaimCommit
  $afterCommittedValidation = Get-RepositorySnapshot -RepositoryRoot $cloneOneRoot
  Assert-SnapshotEqual -Before $beforeCommittedValidation -After $afterCommittedValidation -Scenario "valid committed transition validation"
  Assert-True -Condition $validCommitted.valid -Message "Valid committed claim transition was rejected: $($validCommitted.details -join '; ')"

  $committedDirtPath = Join-Path $cloneOneRoot "committed-post-gate-dirt.txt"
  Set-Content -LiteralPath $committedDirtPath -Value "committed post gate dirt"
  $dirtyCommitted = Invoke-TransitionValidation `
    -ScriptPath $transitionScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -Source "Committed" `
    -ExpectedParentCommit $claimBaseCommit `
    -ExpectedStagedTreeHash $claimStagedTree `
    -Commit $validClaimCommit
  Assert-Equal -Actual $dirtyCommitted.code -Expected "DIRTY_AFTER_GATE" -Message "Dirty committed HEAD validation was accepted."
  Remove-Item -LiteralPath $committedDirtPath

  $stagedDirtRelativePath = "apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md"
  $stagedDirtPath = Join-Path $cloneOneRoot $stagedDirtRelativePath
  $stagedDirtOriginalBytes = [IO.File]::ReadAllBytes($stagedDirtPath)
  Add-Content -LiteralPath $stagedDirtPath -Value "`nStaged post-gate fixture dirt."
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("add", $stagedDirtRelativePath))
  try {
    $stagedDirtyCommitted = Invoke-TransitionValidation `
      -ScriptPath $transitionScriptPath `
      -RepositoryRoot $cloneOneRoot `
      -Source "Committed" `
      -ExpectedParentCommit $claimBaseCommit `
      -ExpectedStagedTreeHash $claimStagedTree `
      -Commit $validClaimCommit
    Assert-Equal `
      -Actual $stagedDirtyCommitted.code `
      -Expected "DIRTY_AFTER_GATE" `
      -Message "Staged-only committed HEAD dirt was accepted."
  } finally {
    [IO.File]::WriteAllBytes($stagedDirtPath, $stagedDirtOriginalBytes)
    [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("add", $stagedDirtRelativePath))
  }

  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("switch", "-c", "fixture-missing-trailer", $claimBaseCommit))
  Write-FixtureJson -Path $cloneOneStatePath -Value $absentPlan.next_run_state
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("add", $stateRelativePath))
  $missingTrailerBlock = @"
Danio-State-Tree: $claimStagedTree
Danio-State-Validation: pass
Danio-Verified-At: 2026-07-11T12:21:00.0000000Z
"@
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @(
    "commit", "-m", "fixture: missing trailer",
    "-m", $missingTrailerBlock
  ))
  $missingTrailerReport = Invoke-TransitionValidation -ScriptPath $transitionScriptPath -RepositoryRoot $cloneOneRoot -Source "Committed"
  Assert-Equal -Actual $missingTrailerReport.code -Expected "COMMIT_TRAILER_INVALID" -Message "Missing committed trailer was accepted."

  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("switch", "main"))
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("switch", "-c", "fixture-duplicate-trailer", $claimBaseCommit))
  Write-FixtureJson -Path $cloneOneStatePath -Value $absentPlan.next_run_state
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("add", $stateRelativePath))
  $duplicateTrailerBlock = @"
Danio-State-Tree: $claimStagedTree
Danio-State-Tree: $claimStagedTree
Danio-State-Validation: pass
Danio-Docs-Profile: pass
Danio-Verified-At: 2026-07-11T12:22:00.0000000Z
"@
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @(
    "commit", "-m", "fixture: duplicate trailer",
    "-m", $duplicateTrailerBlock
  ))
  $duplicateTrailerReport = Invoke-TransitionValidation -ScriptPath $transitionScriptPath -RepositoryRoot $cloneOneRoot -Source "Committed"
  Assert-Equal -Actual $duplicateTrailerReport.code -Expected "COMMIT_TRAILER_INVALID" -Message "Duplicate committed trailer was accepted."

  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("switch", "main"))
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("switch", "-c", "fixture-wrong-trailer", $claimBaseCommit))
  Write-FixtureJson -Path $cloneOneStatePath -Value $absentPlan.next_run_state
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("add", $stateRelativePath))
  $wrongTrailerBlock = @"
Danio-State-Tree: $("0" * 40)
Danio-State-Validation: pass
Danio-Docs-Profile: pass
Danio-Verified-At: 2026-07-11T12:23:00.0000000Z
"@
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @(
    "commit", "-m", "fixture: wrong trailer",
    "-m", $wrongTrailerBlock
  ))
  $wrongTrailerReport = Invoke-TransitionValidation -ScriptPath $transitionScriptPath -RepositoryRoot $cloneOneRoot -Source "Committed"
  Assert-Equal -Actual $wrongTrailerReport.code -Expected "COMMIT_TRAILER_INVALID" -Message "Wrong committed tree trailer was accepted."

  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("switch", "main"))
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("switch", "-c", "fixture-body-spoof", $claimBaseCommit))
  Write-FixtureJson -Path $cloneOneStatePath -Value $absentPlan.next_run_state
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("add", $stateRelativePath))
  $spoofedTrailerBody = @"
Danio-State-Tree: $claimStagedTree
Danio-State-Validation: pass
Danio-Docs-Profile: pass
Danio-Verified-At: 2026-07-11T12:24:00.0000000Z

These lines are ordinary body text, not a terminal trailer block.
"@
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @(
    "commit",
    "-m",
    "fixture: body spoof",
    "-m",
    $spoofedTrailerBody
  ))
  $bodySpoofReport = Invoke-TransitionValidation -ScriptPath $transitionScriptPath -RepositoryRoot $cloneOneRoot -Source "Committed"
  Assert-Equal -Actual $bodySpoofReport.code -Expected "COMMIT_TRAILER_INVALID" -Message "Commit body lines spoofed the required terminal trailer block."

  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("switch", "main"))
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("switch", "-c", "fixture-admin-base", $claimBaseCommit))
  $handoffFixturePath = Join-Path $appRoot "test/scripts/fixtures/autonomous_completion/handoff_ready_run_state.json"
  $handoffState = Get-Content -Raw -LiteralPath $handoffFixturePath | ConvertFrom-Json
  $handoffState.authorization.saved_project_root = $tempRoot.Replace("\", "/")
  $handoffState.authorization.repository_root = $cloneOneRoot.Replace("\", "/")
  Write-FixtureJson -Path $cloneOneStatePath -Value $handoffState
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("add", $stateRelativePath))
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("commit", "-m", "fixture: administrative parent"))
  $adminParentCommit = Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("rev-parse", "HEAD")
  $adminCandidate = $handoffState | ConvertTo-Json -Depth 100 | ConvertFrom-Json
  $adminCandidate.state_revision = [int64]$handoffState.state_revision + 1
  $adminCandidate.transition = [pscustomobject]@{
    action = "administrative_sync"
    from_mode = "handoff_ready"
    to_mode = "handoff_ready"
    parent_state_revision = [int64]$handoffState.state_revision
    work_unit_id = [string]$handoffState.cursor.work_unit_id
    reason_code = $null
    occurred_at_utc = "2026-07-11T12:30:00.0000000Z"
  }
  $adminCandidate.cursor.phase = "$($handoffState.cursor.phase)-forbidden"
  Write-FixtureJson -Path $cloneOneStatePath -Value $adminCandidate
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("add", $stateRelativePath))
  $adminTree = Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("write-tree")
  $adminReport = Invoke-TransitionValidation `
    -ScriptPath $transitionScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -Source "Staged" `
    -ExpectedParentCommit $adminParentCommit `
    -ExpectedStagedTreeHash $adminTree
  Assert-Equal -Actual $adminReport.code -Expected "ADMINISTRATIVE_CHANGE_FORBIDDEN" -Message "Administrative deep comparison accepted a cursor change."

  [pscustomobject]@{
    document_type = "danio_autonomous_completion_git_fixture_test_result"
    schema_version = 1
    passed = $true
    scenarios = 30
    mutations_performed_by_readiness = $false
  } | ConvertTo-Json -Compress
} finally {
  $resolvedFixtureRoot = [System.IO.Path]::GetFullPath($tempRoot)
  if (-not $resolvedFixtureRoot.StartsWith($tempBase, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to remove fixture outside the system temp directory: $resolvedFixtureRoot"
  }
  if (Test-Path -LiteralPath $resolvedFixtureRoot) {
    $extendedFixtureRoot = "\\?\$resolvedFixtureRoot"
    Remove-Item -LiteralPath $extendedFixtureRoot -Recurse -Force
  }
}
