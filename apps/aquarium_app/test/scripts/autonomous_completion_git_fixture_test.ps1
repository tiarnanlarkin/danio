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

function Invoke-GitProbe {
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
  return [pscustomobject]@{
    exit_code = $exitCode
    output = ($output -join "`n").TrimEnd()
  }
}

function Test-GitRefExists {
  param(
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string]$RefName
  )

  $probe = Invoke-GitProbe `
    -RepositoryRoot $RepositoryRoot `
    -GitArguments @("show-ref", "--verify", "--quiet", $RefName)
  Assert-True `
    -Condition (@(0, 1) -contains $probe.exit_code) `
    -Message "Git ref probe failed ambiguously for '$RefName': $($probe.output)"
  return $probe.exit_code -eq 0
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

function Invoke-WriterClaim {
  param(
    [Parameter(Mandatory = $true)][string]$ScriptPath,
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)]$ClaimPlan,
    [Parameter(Mandatory = $true)][string]$TestTransportOutcome,
    [bool]$EnableTestMode = $true,
    [AllowNull()][string]$GitShimDirectory = $null,
    [hashtable]$ChildEnvironment = @{}
  )

  $planJson = $ClaimPlan | ConvertTo-Json -Depth 100 -Compress
  $planBase64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($planJson))
  $escapedScriptPath = $ScriptPath.Replace("'", "''")
  $escapedRepositoryRoot = $RepositoryRoot.Replace("'", "''")
  $escapedOutcome = $TestTransportOutcome.Replace("'", "''")
  $testModeCommand = if ($EnableTestMode) {
    "`$env:DANIO_AUTONOMY_TEST_MODE = '1'"
  } else {
    "[Environment]::SetEnvironmentVariable('DANIO_AUTONOMY_TEST_MODE', `$null, 'Process')"
  }
  $childCommand = @"
$testModeCommand
`$planJson = [Text.Encoding]::UTF8.GetString(
  [Convert]::FromBase64String('$planBase64')
)
& '$escapedScriptPath' ```
  -ClaimPlanJson `$planJson ```
  -RepositoryRoot '$escapedRepositoryRoot' ```
  -TestTransportOutcome '$escapedOutcome'
"@
  if (-not [string]::IsNullOrWhiteSpace($GitShimDirectory)) {
    $escapedGitShimDirectory = $GitShimDirectory.Replace("'", "''")
    $childCommand = "`$env:PATH = '$escapedGitShimDirectory;' + `$env:PATH`n$childCommand"
  }
  foreach ($key in @($ChildEnvironment.Keys | Sort-Object)) {
    if ([string]$key -cnotmatch '^[A-Z][A-Z0-9_]*$') {
      throw "Unsafe fixture environment key: $key"
    }
    $escapedValue = ([string]$ChildEnvironment[$key]).Replace("'", "''")
    $childCommand = "[Environment]::SetEnvironmentVariable('$key', '$escapedValue', 'Process')`n$childCommand"
  }
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
  Assert-True `
    -Condition (@(0, 1) -contains $exitCode) `
    -Message "Writer claim returned an unsupported exit code."
  Assert-Equal `
    -Actual $output.Count `
    -Expected 1 `
    -Message "Writer claim emitted more than one stdout object."
  $result = $output[0] | ConvertFrom-Json
  Assert-Equal `
    -Actual $result.accepted `
    -Expected ($exitCode -eq 0) `
    -Message "Writer claim JSON and exit code disagreed."
  return [pscustomobject]@{
    exit_code = $exitCode
    result = $result
  }
}

function New-ClaimTransactionFixture {
  param(
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)][string]$FixtureRoot,
    [Parameter(Mandatory = $true)][string]$SourceAppRoot,
    [Parameter(Mandatory = $true)][string]$ClaimPlannerScriptPath,
    [switch]$IncludeSecondClone
  )

  $root = Join-Path $FixtureRoot "ct-$Name"
  $remote = Join-Path $root "remote.git"
  $seed = Join-Path $root "seed"
  $cloneOne = Join-Path $root "clone-one"
  $cloneTwo = Join-Path $root "clone-two"
  $statePath = "apps/aquarium_app/docs/agent/autonomous_completion/phone_completion_run_state.json"
  $gatePath = "apps/aquarium_app/scripts/quality_gates/run_local_quality_gate.ps1"

  New-Item -ItemType Directory -Force -Path $root | Out-Null
  [void](Invoke-GitWithoutRepository -GitArguments @("init", "--bare", $remote))
  [void](Invoke-GitWithoutRepository -GitArguments @("init", $seed))
  [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("checkout", "-b", "main"))
  [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("config", "user.name", "Danio Claim Fixture"))
  [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("config", "user.email", "danio-claim-fixture@example.invalid"))

  $readyFixturePath = Join-Path $SourceAppRoot "test/scripts/fixtures/autonomous_completion/ready_run_state.json"
  $readyState = Get-Content -Raw -LiteralPath $readyFixturePath | ConvertFrom-Json
  $readyState.authorization.saved_project_root = $root.Replace("\", "/")
  $readyState.authorization.repository_root = $cloneOne.Replace("\", "/")
  Write-FixtureJson -Path (Join-Path $seed $statePath) -Value $readyState

  $gateScript = @'
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Profile,
  [switch]$RequireCleanWorktree
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
if ($Profile -cne "Docs") {
  throw "Disposable fixture accepts only the Docs profile."
}
Write-Output "Disposable Docs profile passed."
exit 0
'@
  $gateAbsolutePath = Join-Path $seed $gatePath
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $gateAbsolutePath) | Out-Null
  [IO.File]::WriteAllText(
    $gateAbsolutePath,
    $gateScript,
    (New-Object Text.UTF8Encoding($false))
  )

  [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("add", "apps/aquarium_app"))
  [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("commit", "-m", "fixture: seed claim transaction"))
  [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("remote", "add", "origin", $remote))
  [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("push", "-u", "origin", "main"))
  [void](Invoke-Git -RepositoryRoot $remote -GitArguments @("symbolic-ref", "HEAD", "refs/heads/main"))
  [void](Invoke-GitWithoutRepository -GitArguments @("clone", $remote, $cloneOne))
  [void](Invoke-Git -RepositoryRoot $cloneOne -GitArguments @("config", "user.name", "Danio Claim One"))
  [void](Invoke-Git -RepositoryRoot $cloneOne -GitArguments @("config", "user.email", "danio-claim-one@example.invalid"))
  if ($IncludeSecondClone) {
    [void](Invoke-GitWithoutRepository -GitArguments @("clone", $remote, $cloneTwo))
    [void](Invoke-Git -RepositoryRoot $cloneTwo -GitArguments @("config", "user.name", "Danio Claim Two"))
    [void](Invoke-Git -RepositoryRoot $cloneTwo -GitArguments @("config", "user.email", "danio-claim-two@example.invalid"))
  }

  $baseCommit = Invoke-Git -RepositoryRoot $cloneOne -GitArguments @("rev-parse", "origin/main")
  $readiness = [pscustomobject]@{
    document_type = "danio_readiness_report"
    schema_version = 1
    intent = "Claim"
    checked_at_utc = "2026-07-11T13:00:00.0000000Z"
    eligible = $true
    stop_reason_code = $null
    checks = @(
      [pscustomobject]@{
        code = "CLAIM_READY"
        status = "pass"
        detail = "Disposable claim transaction is ready."
      }
    )
  }
  $taskId = "task-$Name-one"
  $worktreeRoot = Join-Path $root ".codex-worktrees"
  $plan = Invoke-ClaimPlanner `
    -ScriptPath $ClaimPlannerScriptPath `
    -RepositoryRoot $cloneOne `
    -ReadinessReport $readiness `
    -TaskId $taskId `
    -ExpectedStateRevision ([int64]$readyState.state_revision) `
    -WorktreeRoot $worktreeRoot
  Assert-True `
    -Condition $plan.valid `
    -Message "Disposable writer claim plan was rejected: $($plan.details -join '; ')"

  return [pscustomobject]@{
    root = $root
    remote = $remote
    clone_one = $cloneOne
    clone_two = if ($IncludeSecondClone) { $cloneTwo } else { $null }
    state_path = $statePath
    ready_state = $readyState
    base_commit = $baseCommit
    plan = $plan
  }
}

function New-CompetingClaimPlan {
  param(
    [Parameter(Mandatory = $true)]$FirstPlan,
    [Parameter(Mandatory = $true)]$ReadyState,
    [Parameter(Mandatory = $true)][string]$TaskId
  )

  $plan = $FirstPlan | ConvertTo-Json -Depth 100 | ConvertFrom-Json
  $identity = Get-ExpectedWriterIdentity `
    -RunId ([string]$ReadyState.run_id) `
    -WorkUnitId ([string]$ReadyState.cursor.work_unit_id) `
    -TaskId $TaskId `
    -ExpectedStateRevision ([int64]$ReadyState.state_revision) `
    -SavedProjectRoot ([string]$ReadyState.authorization.saved_project_root)
  $plan.task_id = $TaskId
  $plan.owner_token_sha256 = $identity.token_sha256
  $plan.branch_name = $identity.branch_name
  $plan.worktree_id = $identity.worktree_id
  $plan.worktree_path = $identity.worktree_path
  $plan.next_run_state.owner.task_id = $TaskId
  $plan.next_run_state.owner.token_sha256 = $identity.token_sha256
  $plan.next_run_state.owner.branch_name = $identity.branch_name
  $plan.next_run_state.owner.worktree_id = $identity.worktree_id
  $plan.next_run_state.owner.worktree_path = $identity.worktree_path
  return $plan
}

function Read-RemoteRunState {
  param(
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string]$StatePath
  )

  $json = Invoke-Git `
    -RepositoryRoot $RepositoryRoot `
    -GitArguments @("show", "origin/main`:$StatePath")
  return $json | ConvertFrom-Json
}

function Assert-ClaimBudgetUnchanged {
  param(
    [Parameter(Mandatory = $true)]$BeforeState,
    [Parameter(Mandatory = $true)]$AfterState,
    [Parameter(Mandatory = $true)][string]$Scenario
  )

  foreach ($field in @("total_approved_units", "consumed_units", "remaining_units_including_current")) {
    Assert-Equal `
      -Actual $AfterState.budget.$field `
      -Expected $BeforeState.budget.$field `
      -Message "Writer claim changed budget field '$field' during $Scenario."
  }
}

function Assert-WriterClaimResult {
  param(
    [Parameter(Mandatory = $true)]$Invocation,
    [Parameter(Mandatory = $true)][bool]$Accepted,
    [Parameter(Mandatory = $true)][string]$Code,
    [Parameter(Mandatory = $true)][string]$Scenario
  )

  Assert-Equal `
    -Actual $Invocation.exit_code `
    -Expected $(if ($Accepted) { 0 } else { 1 }) `
    -Message "Writer claim exit code mismatch during $Scenario. Result: $($Invocation.result | ConvertTo-Json -Depth 20 -Compress)"
  Assert-Equal `
    -Actual $Invocation.result.document_type `
    -Expected "danio_writer_claim_result" `
    -Message "Writer claim document type mismatch during $Scenario."
  Assert-Equal `
    -Actual $Invocation.result.schema_version `
    -Expected 1 `
    -Message "Writer claim schema version mismatch during $Scenario."
  Assert-Equal `
    -Actual $Invocation.result.accepted `
    -Expected $Accepted `
    -Message "Writer claim acceptance mismatch during $Scenario."
  Assert-Equal `
    -Actual $Invocation.result.code `
    -Expected $Code `
    -Message "Writer claim code mismatch during $Scenario."
  Assert-Equal `
    -Actual $Invocation.result.budget_consumed `
    -Expected $false `
    -Message "Writer claim reported budget consumption during $Scenario."
  Assert-True `
    -Condition ([int]$Invocation.result.push_attempt_count -ge 0 -and [int]$Invocation.result.push_attempt_count -le 1) `
    -Message "Writer claim attempted more than one push during $Scenario."
  Assert-Equal `
    -Actual $Invocation.result.retry_performed `
    -Expected $false `
    -Message "Writer claim reported a retry during $Scenario."
  Assert-True `
    -Condition ([string]$Invocation.result.candidate_commit -cmatch '^[0-9a-f]{40}$') `
    -Message "Writer claim omitted its candidate commit during $Scenario."
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

function Write-FixtureScript {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$Content
  )

  $directory = Split-Path -Parent $Path
  if (-not (Test-Path -LiteralPath $directory -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
  }
  [IO.File]::WriteAllText(
    $Path,
    $Content,
    (New-Object Text.UTF8Encoding($false))
  )
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
$claimInvokerScriptPath = Join-Path $appRoot "scripts/autonomous_completion/invoke_autonomous_writer_claim.ps1"

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
if (-not (Test-Path -LiteralPath $claimInvokerScriptPath -PathType Leaf)) {
  throw "Expected writer claim mutation entry point is missing: $claimInvokerScriptPath"
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

  $missingTestModeFixture = New-ClaimTransactionFixture `
    -Name "gm" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -ClaimPlannerScriptPath $claimPlannerScriptPath
  $missingTestModeInvocation = Invoke-WriterClaim `
    -ScriptPath $claimInvokerScriptPath `
    -RepositoryRoot $missingTestModeFixture.clone_one `
    -ClaimPlan $missingTestModeFixture.plan `
    -TestTransportOutcome "rejected" `
    -EnableTestMode $false
  Assert-Equal `
    -Actual $missingTestModeInvocation.exit_code `
    -Expected 1 `
    -Message "Fixture transport without test mode did not fail."
  Assert-Equal `
    -Actual $missingTestModeInvocation.result.code `
    -Expected "TEST_TRANSPORT_FORBIDDEN" `
    -Message "Fixture transport without test mode returned the wrong code."
  Assert-Equal `
    -Actual $missingTestModeInvocation.result.mutations_performed `
    -Expected $false `
    -Message "Missing test-mode guard mutated the fixture."
  Assert-Equal `
    -Actual (Test-Path -LiteralPath $missingTestModeFixture.plan.worktree_path) `
    -Expected $false `
    -Message "Missing test-mode guard created a writer worktree."

  $hostilePushFixture = New-ClaimTransactionFixture `
    -Name "gp" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -ClaimPlannerScriptPath $claimPlannerScriptPath
  $hostilePushRemote = Join-Path $tempRoot "hostile-push.git"
  [void](Invoke-GitWithoutRepository -GitArguments @("clone", "--bare", $hostilePushFixture.remote, $hostilePushRemote))
  [void](Invoke-Git `
    -RepositoryRoot $hostilePushFixture.clone_one `
    -GitArguments @("remote", "set-url", "--push", "origin", $hostilePushRemote))
  $hostilePushInvocation = Invoke-WriterClaim `
    -ScriptPath $claimInvokerScriptPath `
    -RepositoryRoot $hostilePushFixture.clone_one `
    -ClaimPlan $hostilePushFixture.plan `
    -TestTransportOutcome "accepted"
  Assert-Equal `
    -Actual $hostilePushInvocation.exit_code `
    -Expected 1 `
    -Message "Hostile fixture push URL did not fail."
  Assert-Equal `
    -Actual $hostilePushInvocation.result.code `
    -Expected "TEST_TRANSPORT_FORBIDDEN" `
    -Message "Hostile fixture push URL returned the wrong code."
  Assert-Equal `
    -Actual $hostilePushInvocation.result.mutations_performed `
    -Expected $false `
    -Message "Hostile fixture push URL mutated the claim checkout."
  foreach ($remote in @($hostilePushFixture.remote, $hostilePushRemote)) {
    Assert-Equal `
      -Actual (Invoke-Git -RepositoryRoot $remote -GitArguments @("rev-parse", "refs/heads/main")) `
      -Expected $hostilePushFixture.base_commit `
      -Message "Hostile push URL guard allowed a remote mutation."
  }

  $acceptedFixture = New-ClaimTransactionFixture `
    -Name "a" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -ClaimPlannerScriptPath $claimPlannerScriptPath
  $acceptedInvocation = Invoke-WriterClaim `
    -ScriptPath $claimInvokerScriptPath `
    -RepositoryRoot $acceptedFixture.clone_one `
    -ClaimPlan $acceptedFixture.plan `
    -TestTransportOutcome "accepted"
  Assert-WriterClaimResult `
    -Invocation $acceptedInvocation `
    -Accepted $true `
    -Code "WRITER_CLAIM_ACCEPTED" `
    -Scenario "accepted transport"
  Assert-Equal `
    -Actual $acceptedInvocation.result.transport_result `
    -Expected "accepted" `
    -Message "Accepted transport classification mismatch."
  Assert-Equal `
    -Actual $acceptedInvocation.result.cleanup_performed `
    -Expected $false `
    -Message "Accepted writer claim was cleaned up."
  Assert-Equal `
    -Actual $acceptedInvocation.result.artifacts_preserved `
    -Expected $true `
    -Message "Accepted writer artifacts were not preserved."
  Assert-Equal `
    -Actual (Invoke-Git -RepositoryRoot $acceptedFixture.clone_one -GitArguments @("rev-parse", "HEAD")) `
    -Expected $acceptedInvocation.result.candidate_commit `
    -Message "Accepted writer claim did not fast-forward local main."
  Assert-Equal `
    -Actual (Invoke-Git -RepositoryRoot $acceptedFixture.clone_one -GitArguments @("rev-parse", "main")) `
    -Expected $acceptedInvocation.result.candidate_commit `
    -Message "Accepted writer claim left the main ref behind."
  Assert-Equal `
    -Actual (Invoke-Git -RepositoryRoot $acceptedFixture.clone_one -GitArguments @("rev-parse", "origin/main")) `
    -Expected $acceptedInvocation.result.candidate_commit `
    -Message "Accepted writer claim did not reach origin/main."
  Assert-True `
    -Condition (Test-Path -LiteralPath $acceptedFixture.plan.worktree_path -PathType Container) `
    -Message "Accepted writer worktree was removed."
  $acceptedState = Read-RemoteRunState `
    -RepositoryRoot $acceptedFixture.clone_one `
    -StatePath $acceptedFixture.state_path
  Assert-ClaimBudgetUnchanged `
    -BeforeState $acceptedFixture.ready_state `
    -AfterState $acceptedState `
    -Scenario "accepted transport"
  Assert-Equal `
    -Actual $acceptedState.budget.current_charge.status `
    -Expected "pending" `
    -Message "Accepted writer claim did not leave the unit charge pending."

  $relativeEndpointFixture = New-ClaimTransactionFixture `
    -Name "ap" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -ClaimPlannerScriptPath $claimPlannerScriptPath
  [void](Invoke-Git `
    -RepositoryRoot $relativeEndpointFixture.clone_one `
    -GitArguments @("config", "remote.origin.url", "../remote.git"))
  [void](Invoke-Git `
    -RepositoryRoot $relativeEndpointFixture.clone_one `
    -GitArguments @("config", "remote.origin.pushurl", "../remote.git"))
  $relativeEndpointInvocation = Invoke-WriterClaim `
    -ScriptPath $claimInvokerScriptPath `
    -RepositoryRoot $relativeEndpointFixture.clone_one `
    -ClaimPlan $relativeEndpointFixture.plan `
    -TestTransportOutcome "accepted" `
    -ChildEnvironment @{
      DANIO_TEST_USE_PRODUCTION_ENDPOINT_CAPTURE = "1"
    }
  Assert-WriterClaimResult `
    -Invocation $relativeEndpointInvocation `
    -Accepted $true `
    -Code "WRITER_CLAIM_ACCEPTED" `
    -Scenario "relative production endpoint capture"
  Assert-Equal `
    -Actual (Invoke-Git `
      -RepositoryRoot $relativeEndpointFixture.remote `
      -GitArguments @("rev-parse", "refs/heads/main")) `
    -Expected $relativeEndpointInvocation.result.candidate_commit `
    -Message "Canonical relative endpoint did not receive the candidate."
  Assert-Equal `
    -Actual (Invoke-Git `
      -RepositoryRoot $relativeEndpointFixture.clone_one `
      -GitArguments @("rev-parse", "main")) `
    -Expected $relativeEndpointInvocation.result.candidate_commit `
    -Message "Canonical relative endpoint did not reconcile local main."
  $relativeEndpointState = Read-RemoteRunState `
    -RepositoryRoot $relativeEndpointFixture.clone_one `
    -StatePath $relativeEndpointFixture.state_path
  Assert-ClaimBudgetUnchanged `
    -BeforeState $relativeEndpointFixture.ready_state `
    -AfterState $relativeEndpointState `
    -Scenario "relative production endpoint capture"

  $rejectedFixture = New-ClaimTransactionFixture `
    -Name "r" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -ClaimPlannerScriptPath $claimPlannerScriptPath
  $rejectedInvocation = Invoke-WriterClaim `
    -ScriptPath $claimInvokerScriptPath `
    -RepositoryRoot $rejectedFixture.clone_one `
    -ClaimPlan $rejectedFixture.plan `
    -TestTransportOutcome "rejected"
  Assert-WriterClaimResult `
    -Invocation $rejectedInvocation `
    -Accepted $false `
    -Code "WRITER_CLAIM_LOST" `
    -Scenario "rejected transport"
  Assert-Equal `
    -Actual $rejectedInvocation.result.transport_result `
    -Expected "rejected" `
    -Message "Rejected transport classification mismatch."
  Assert-Equal `
    -Actual $rejectedInvocation.result.cleanup_performed `
    -Expected $true `
    -Message "Definite rejection did not clean up the exact writer identity."
  Assert-Equal `
    -Actual $rejectedInvocation.result.artifacts_preserved `
    -Expected $false `
    -Message "Definite rejection incorrectly reported preserved artifacts."
  Assert-Equal `
    -Actual (Test-Path -LiteralPath $rejectedFixture.plan.worktree_path) `
    -Expected $false `
    -Message "Rejected writer worktree remains."
  Assert-Equal `
    -Actual (Test-GitRefExists -RepositoryRoot $rejectedFixture.clone_one -RefName "refs/heads/$($rejectedFixture.plan.branch_name)") `
    -Expected $false `
    -Message "Rejected writer branch remains."
  Assert-Equal `
    -Actual (Invoke-Git -RepositoryRoot $rejectedFixture.clone_one -GitArguments @("rev-parse", "origin/main")) `
    -Expected $rejectedFixture.base_commit `
    -Message "Rejected transport changed origin/main."
  $rejectedState = Read-RemoteRunState `
    -RepositoryRoot $rejectedFixture.clone_one `
    -StatePath $rejectedFixture.state_path
  Assert-ClaimBudgetUnchanged `
    -BeforeState $rejectedFixture.ready_state `
    -AfterState $rejectedState `
    -Scenario "rejected transport"

  $unknownAcceptedFixture = New-ClaimTransactionFixture `
    -Name "ua" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -ClaimPlannerScriptPath $claimPlannerScriptPath
  $unknownAcceptedInvocation = Invoke-WriterClaim `
    -ScriptPath $claimInvokerScriptPath `
    -RepositoryRoot $unknownAcceptedFixture.clone_one `
    -ClaimPlan $unknownAcceptedFixture.plan `
    -TestTransportOutcome "unknown_accepted"
  Assert-WriterClaimResult `
    -Invocation $unknownAcceptedInvocation `
    -Accepted $true `
    -Code "WRITER_CLAIM_ACCEPTED" `
    -Scenario "unknown accepted transport"
  Assert-Equal `
    -Actual $unknownAcceptedInvocation.result.transport_result `
    -Expected "unknown_accepted" `
    -Message "Unknown accepted transport was not reconciled."
  Assert-Equal `
    -Actual $unknownAcceptedInvocation.result.reconciliation_status `
    -Expected "accepted" `
    -Message "Unknown accepted reconciliation status mismatch."
  Assert-Equal `
    -Actual (Invoke-Git -RepositoryRoot $unknownAcceptedFixture.clone_one -GitArguments @("rev-parse", "HEAD")) `
    -Expected $unknownAcceptedInvocation.result.candidate_commit `
    -Message "Unknown accepted writer claim did not align local main."
  $unknownAcceptedState = Read-RemoteRunState `
    -RepositoryRoot $unknownAcceptedFixture.clone_one `
    -StatePath $unknownAcceptedFixture.state_path
  Assert-ClaimBudgetUnchanged `
    -BeforeState $unknownAcceptedFixture.ready_state `
    -AfterState $unknownAcceptedState `
    -Scenario "unknown accepted transport"

  $unknownNotAcceptedFixture = New-ClaimTransactionFixture `
    -Name "un" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -ClaimPlannerScriptPath $claimPlannerScriptPath
  $unknownNotAcceptedInvocation = Invoke-WriterClaim `
    -ScriptPath $claimInvokerScriptPath `
    -RepositoryRoot $unknownNotAcceptedFixture.clone_one `
    -ClaimPlan $unknownNotAcceptedFixture.plan `
    -TestTransportOutcome "unknown_not_accepted"
  Assert-WriterClaimResult `
    -Invocation $unknownNotAcceptedInvocation `
    -Accepted $false `
    -Code "WRITER_CLAIM_LOST" `
    -Scenario "unknown not accepted transport"
  Assert-Equal `
    -Actual $unknownNotAcceptedInvocation.result.transport_result `
    -Expected "unknown_not_accepted" `
    -Message "Unknown not accepted transport classification mismatch."
  Assert-Equal `
    -Actual $unknownNotAcceptedInvocation.result.reconciliation_status `
    -Expected "rejected" `
    -Message "Unknown not accepted transport did not reconcile to rejection."
  Assert-Equal `
    -Actual $unknownNotAcceptedInvocation.result.cleanup_performed `
    -Expected $true `
    -Message "Unknown not accepted claim did not clean up after proof."
  Assert-Equal `
    -Actual (Test-Path -LiteralPath $unknownNotAcceptedFixture.plan.worktree_path) `
    -Expected $false `
    -Message "Unknown not accepted worktree remains."
  $unknownNotAcceptedState = Read-RemoteRunState `
    -RepositoryRoot $unknownNotAcceptedFixture.clone_one `
    -StatePath $unknownNotAcceptedFixture.state_path
  Assert-ClaimBudgetUnchanged `
    -BeforeState $unknownNotAcceptedFixture.ready_state `
    -AfterState $unknownNotAcceptedState `
    -Scenario "unknown not accepted transport"

  $unknownUnresolvedFixture = New-ClaimTransactionFixture `
    -Name "uu" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -ClaimPlannerScriptPath $claimPlannerScriptPath
  $unknownUnresolvedInvocation = Invoke-WriterClaim `
    -ScriptPath $claimInvokerScriptPath `
    -RepositoryRoot $unknownUnresolvedFixture.clone_one `
    -ClaimPlan $unknownUnresolvedFixture.plan `
    -TestTransportOutcome "unknown_unresolved"
  Assert-WriterClaimResult `
    -Invocation $unknownUnresolvedInvocation `
    -Accepted $false `
    -Code "PUSH_OUTCOME_UNKNOWN" `
    -Scenario "unknown unresolved transport"
  Assert-Equal `
    -Actual $unknownUnresolvedInvocation.result.transport_result `
    -Expected "unknown_unresolved" `
    -Message "Unknown unresolved transport classification mismatch."
  Assert-Equal `
    -Actual $unknownUnresolvedInvocation.result.reconciliation_status `
    -Expected "unknown" `
    -Message "Unknown unresolved transport was over-classified."
  Assert-Equal `
    -Actual $unknownUnresolvedInvocation.result.cleanup_performed `
    -Expected $false `
    -Message "Unknown unresolved transport performed cleanup."
  Assert-Equal `
    -Actual $unknownUnresolvedInvocation.result.artifacts_preserved `
    -Expected $true `
    -Message "Unknown unresolved transport did not preserve artifacts."
  Assert-Equal `
    -Actual $unknownUnresolvedInvocation.result.push_attempt_count `
    -Expected 1 `
    -Message "Unknown unresolved transport did not exercise one real push attempt."
  Assert-Equal `
    -Actual $unknownUnresolvedInvocation.result.push_timed_out `
    -Expected $true `
    -Message "Unknown unresolved transport did not exercise the timeout path."
  Assert-Equal `
    -Actual $unknownUnresolvedInvocation.result.push_termination_confirmed `
    -Expected $false `
    -Message "Unknown unresolved transport did not preserve on unconfirmed termination."
  Assert-True `
    -Condition (Test-Path -LiteralPath $unknownUnresolvedFixture.plan.worktree_path -PathType Container) `
    -Message "Unknown unresolved worktree was removed."
  Assert-True `
    -Condition (Test-GitRefExists -RepositoryRoot $unknownUnresolvedFixture.clone_one -RefName "refs/heads/$($unknownUnresolvedFixture.plan.branch_name)") `
    -Message "Unknown unresolved branch was removed."
  Assert-Equal `
    -Actual (Invoke-Git -RepositoryRoot $unknownUnresolvedFixture.clone_one -GitArguments @("rev-parse", "origin/main")) `
    -Expected $unknownUnresolvedFixture.base_commit `
    -Message "Unknown unresolved transport unexpectedly refreshed local origin/main."
  Assert-Equal `
    -Actual (Invoke-Git -RepositoryRoot $unknownUnresolvedFixture.remote -GitArguments @("rev-parse", "refs/heads/main")) `
    -Expected $unknownUnresolvedInvocation.result.candidate_commit `
    -Message "Unknown unresolved transport did not model an accepted-but-unobservable push."
  $unknownUnresolvedStateJson = Invoke-Git `
    -RepositoryRoot $unknownUnresolvedFixture.remote `
    -GitArguments @("show", "refs/heads/main`:$($unknownUnresolvedFixture.state_path)")
  $unknownUnresolvedState = $unknownUnresolvedStateJson | ConvertFrom-Json
  Assert-ClaimBudgetUnchanged `
    -BeforeState $unknownUnresolvedFixture.ready_state `
    -AfterState $unknownUnresolvedState `
    -Scenario "unknown unresolved transport"

  $fixtureRealGit = (Get-Command git.exe -ErrorAction Stop).Source.Replace("'", "''")

  $remoteMovedFixture = New-ClaimTransactionFixture `
    -Name "rm" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -ClaimPlannerScriptPath $claimPlannerScriptPath `
    -IncludeSecondClone
  $remoteMovedShimRoot = Join-Path $remoteMovedFixture.root "git-shim"
  $remoteMovedShim = @"
`$captured = @(`$args)
& '$fixtureRealGit' @args
`$code = `$LASTEXITCODE
if (`$code -eq 0 -and @(`$captured | Where-Object { `$_ -ceq 'push' }).Count -eq 1 -and @(`$captured | Where-Object { `$_ -ceq 'HEAD:main' }).Count -eq 1) {
  & '$fixtureRealGit' -c core.longpaths=true -C `$env:DANIO_ADVANCE_CLONE fetch --prune origin main
  if (`$LASTEXITCODE -ne 0) { exit `$LASTEXITCODE }
  & '$fixtureRealGit' -c core.longpaths=true -C `$env:DANIO_ADVANCE_CLONE merge --ff-only origin/main
  if (`$LASTEXITCODE -ne 0) { exit `$LASTEXITCODE }
  & '$fixtureRealGit' -c core.longpaths=true -C `$env:DANIO_ADVANCE_CLONE commit --allow-empty -m 'fixture: advance accepted claim'
  if (`$LASTEXITCODE -ne 0) { exit `$LASTEXITCODE }
  & '$fixtureRealGit' -c core.longpaths=true -C `$env:DANIO_ADVANCE_CLONE push origin HEAD:main
  if (`$LASTEXITCODE -ne 0) { exit `$LASTEXITCODE }
}
exit `$code
"@
  Write-FixtureScript `
    -Path (Join-Path $remoteMovedShimRoot "git.ps1") `
    -Content $remoteMovedShim
  $remoteMovedInvocation = Invoke-WriterClaim `
    -ScriptPath $claimInvokerScriptPath `
    -RepositoryRoot $remoteMovedFixture.clone_one `
    -ClaimPlan $remoteMovedFixture.plan `
    -TestTransportOutcome "unknown_accepted" `
    -GitShimDirectory $remoteMovedShimRoot `
    -ChildEnvironment @{
      DANIO_ADVANCE_CLONE = $remoteMovedFixture.clone_two
    }
  Assert-WriterClaimResult `
    -Invocation $remoteMovedInvocation `
    -Accepted $false `
    -Code "REMOTE_MOVED" `
    -Scenario "remote advanced after accepted claim"
  Assert-Equal `
    -Actual $remoteMovedInvocation.result.cleanup_performed `
    -Expected $false `
    -Message "Remote-moved claim performed cleanup."
  Assert-Equal `
    -Actual $remoteMovedInvocation.result.artifacts_preserved `
    -Expected $true `
    -Message "Remote-moved claim did not preserve artifacts."
  $remoteMovedTip = Invoke-Git `
    -RepositoryRoot $remoteMovedFixture.remote `
    -GitArguments @("rev-parse", "refs/heads/main")
  $remoteMovedReachability = Invoke-GitProbe `
    -RepositoryRoot $remoteMovedFixture.clone_one `
    -GitArguments @(
      "merge-base", "--is-ancestor",
      $remoteMovedInvocation.result.candidate_commit,
      $remoteMovedTip
    )
  Assert-Equal `
    -Actual $remoteMovedReachability.exit_code `
    -Expected 0 `
    -Message "REMOTE_MOVED did not prove candidate reachability."
  Assert-True `
    -Condition (Test-Path -LiteralPath $remoteMovedFixture.plan.worktree_path -PathType Container) `
    -Message "REMOTE_MOVED removed the writer worktree."
  Assert-Equal `
    -Actual (Invoke-Git -RepositoryRoot $remoteMovedFixture.clone_one -GitArguments @("rev-parse", "main")) `
    -Expected $remoteMovedFixture.base_commit `
    -Message "REMOTE_MOVED advanced local main."
  $remoteMovedStateJson = Invoke-Git `
    -RepositoryRoot $remoteMovedFixture.remote `
    -GitArguments @("show", "refs/heads/main`:$($remoteMovedFixture.state_path)")
  Assert-ClaimBudgetUnchanged `
    -BeforeState $remoteMovedFixture.ready_state `
    -AfterState ($remoteMovedStateJson | ConvertFrom-Json) `
    -Scenario "remote advanced after accepted claim"

  $alignmentFixture = New-ClaimTransactionFixture `
    -Name "al" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -ClaimPlannerScriptPath $claimPlannerScriptPath
  $alignmentShimRoot = Join-Path $alignmentFixture.root "git-shim"
  $alignmentShim = @"
`$captured = @(`$args)
& '$fixtureRealGit' @args
`$code = `$LASTEXITCODE
if (`$code -eq 0 -and @(`$captured | Where-Object { `$_ -ceq 'push' }).Count -eq 1 -and @(`$captured | Where-Object { `$_ -ceq 'HEAD:main' }).Count -eq 1) {
  [IO.File]::WriteAllText(
    (Join-Path `$env:DANIO_DIRTY_ROOT 'alignment-race.txt'),
    'preserve local alignment dirt',
    (New-Object Text.UTF8Encoding(`$false))
  )
}
exit `$code
"@
  Write-FixtureScript `
    -Path (Join-Path $alignmentShimRoot "git.ps1") `
    -Content $alignmentShim
  $alignmentInvocation = Invoke-WriterClaim `
    -ScriptPath $claimInvokerScriptPath `
    -RepositoryRoot $alignmentFixture.clone_one `
    -ClaimPlan $alignmentFixture.plan `
    -TestTransportOutcome "unknown_accepted" `
    -GitShimDirectory $alignmentShimRoot `
    -ChildEnvironment @{
      DANIO_DIRTY_ROOT = $alignmentFixture.clone_one
    }
  Assert-WriterClaimResult `
    -Invocation $alignmentInvocation `
    -Accepted $false `
    -Code "REMOTE_MOVED" `
    -Scenario "unsafe local main alignment"
  Assert-Equal `
    -Actual $alignmentInvocation.result.cleanup_performed `
    -Expected $false `
    -Message "Unsafe local alignment performed cleanup."
  Assert-Equal `
    -Actual $alignmentInvocation.result.artifacts_preserved `
    -Expected $true `
    -Message "Unsafe local alignment did not preserve artifacts."
  $alignmentDirtPath = Join-Path $alignmentFixture.clone_one "alignment-race.txt"
  Assert-True `
    -Condition (Test-Path -LiteralPath $alignmentDirtPath -PathType Leaf) `
    -Message "Unsafe local alignment removed unrelated dirt."
  Assert-Equal `
    -Actual (Get-Content -Raw -LiteralPath $alignmentDirtPath) `
    -Expected "preserve local alignment dirt" `
    -Message "Unsafe local alignment changed unrelated dirt."
  Assert-Equal `
    -Actual (Invoke-Git -RepositoryRoot $alignmentFixture.clone_one -GitArguments @("rev-parse", "main")) `
    -Expected $alignmentFixture.base_commit `
    -Message "Unsafe local alignment advanced main."

  $cleanupMismatchFixture = New-ClaimTransactionFixture `
    -Name "cm" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -ClaimPlannerScriptPath $claimPlannerScriptPath
  $cleanupShimRoot = Join-Path $cleanupMismatchFixture.root "git-shim"
  $cleanupCounterPath = Join-Path $cleanupMismatchFixture.root "fetch-count.txt"
  $cleanupDirtPath = Join-Path $cleanupMismatchFixture.plan.worktree_path "cleanup-race.txt"
  $cleanupShim = @"
`$captured = @(`$args)
& '$fixtureRealGit' @args
`$code = `$LASTEXITCODE
if (`$code -eq 0 -and @(`$captured | Where-Object { `$_ -ceq 'fetch' }).Count -eq 1) {
  `$count = if (Test-Path -LiteralPath `$env:DANIO_FETCH_COUNTER) {
    [int](Get-Content -Raw -LiteralPath `$env:DANIO_FETCH_COUNTER)
  } else {
    0
  }
  `$count += 1
  [IO.File]::WriteAllText(`$env:DANIO_FETCH_COUNTER, [string]`$count)
  if (`$count -eq 2) {
    [IO.File]::WriteAllText(
      (Join-Path `$env:DANIO_CLEANUP_WORKTREE 'cleanup-race.txt'),
      'preserve cleanup mismatch',
      (New-Object Text.UTF8Encoding(`$false))
    )
  }
}
exit `$code
"@
  Write-FixtureScript `
    -Path (Join-Path $cleanupShimRoot "git.ps1") `
    -Content $cleanupShim
  $cleanupMismatchInvocation = Invoke-WriterClaim `
    -ScriptPath $claimInvokerScriptPath `
    -RepositoryRoot $cleanupMismatchFixture.clone_one `
    -ClaimPlan $cleanupMismatchFixture.plan `
    -TestTransportOutcome "rejected" `
    -GitShimDirectory $cleanupShimRoot `
    -ChildEnvironment @{
      DANIO_FETCH_COUNTER = $cleanupCounterPath
      DANIO_CLEANUP_WORKTREE = $cleanupMismatchFixture.plan.worktree_path
    }
  Assert-WriterClaimResult `
    -Invocation $cleanupMismatchInvocation `
    -Accepted $false `
    -Code "WRITER_CLAIM_LOST" `
    -Scenario "cleanup identity mismatch"
  Assert-Equal `
    -Actual $cleanupMismatchInvocation.result.cleanup_performed `
    -Expected $false `
    -Message "Cleanup identity mismatch deleted artifacts."
  Assert-Equal `
    -Actual $cleanupMismatchInvocation.result.artifacts_preserved `
    -Expected $true `
    -Message "Cleanup identity mismatch did not preserve artifacts."
  Assert-True `
    -Condition (@($cleanupMismatchInvocation.result.details | Where-Object { [string]$_ -match 'REJECTION_CLEANUP_UNSAFE' }).Count -gt 0) `
    -Message "Cleanup identity mismatch did not report fail-closed cleanup."
  Assert-True `
    -Condition (Test-Path -LiteralPath $cleanupDirtPath -PathType Leaf) `
    -Message "Cleanup identity mismatch did not preserve worktree bytes."
  Assert-Equal `
    -Actual (Get-Content -Raw -LiteralPath $cleanupDirtPath) `
    -Expected "preserve cleanup mismatch" `
    -Message "Cleanup identity mismatch changed preserved bytes."
  Assert-True `
    -Condition (Test-GitRefExists `
      -RepositoryRoot $cleanupMismatchFixture.clone_one `
      -RefName "refs/heads/$($cleanupMismatchFixture.plan.branch_name)") `
    -Message "Cleanup identity mismatch deleted the branch."

  $postRemovalFailureFixture = New-ClaimTransactionFixture `
    -Name "pr" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -ClaimPlannerScriptPath $claimPlannerScriptPath
  $postRemovalFailureInvocation = Invoke-WriterClaim `
    -ScriptPath $claimInvokerScriptPath `
    -RepositoryRoot $postRemovalFailureFixture.clone_one `
    -ClaimPlan $postRemovalFailureFixture.plan `
    -TestTransportOutcome "rejected" `
    -ChildEnvironment @{
      DANIO_TEST_FAIL_REF_COMMIT_AFTER_REMOVAL = "1"
    }
  Assert-WriterClaimResult `
    -Invocation $postRemovalFailureInvocation `
    -Accepted $false `
    -Code "WRITER_CLAIM_LOST" `
    -Scenario "post-removal ref transaction failure"
  Assert-Equal `
    -Actual $postRemovalFailureInvocation.result.cleanup_performed `
    -Expected $false `
    -Message "Post-removal transaction failure reported completed cleanup."
  Assert-Equal `
    -Actual $postRemovalFailureInvocation.result.artifacts_preserved `
    -Expected $true `
    -Message "Post-removal transaction failure did not restore artifacts."
  Assert-True `
    -Condition (@($postRemovalFailureInvocation.result.details | Where-Object {
      [string]$_ -match 'Exact branch and worktree artifacts were restored'
    }).Count -gt 0) `
    -Message "Post-removal transaction failure did not report exact restoration."
  Assert-True `
    -Condition (Test-Path -LiteralPath $postRemovalFailureFixture.plan.worktree_path -PathType Container) `
    -Message "Post-removal transaction failure did not restore the worktree."
  Assert-True `
    -Condition (Test-GitRefExists `
      -RepositoryRoot $postRemovalFailureFixture.clone_one `
      -RefName "refs/heads/$($postRemovalFailureFixture.plan.branch_name)") `
    -Message "Post-removal transaction failure did not restore the branch."
  Assert-Equal `
    -Actual (Invoke-Git `
      -RepositoryRoot $postRemovalFailureFixture.plan.worktree_path `
      -GitArguments @("rev-parse", "HEAD")) `
    -Expected $postRemovalFailureInvocation.result.candidate_commit `
    -Message "Restored worktree did not retain the exact candidate."
  Assert-Equal `
    -Actual (Invoke-Git `
      -RepositoryRoot $postRemovalFailureFixture.plan.worktree_path `
      -GitArguments @("--no-optional-locks", "status", "--short", "-uall")) `
    -Expected "" `
    -Message "Restored worktree is not clean."
  $postRemovalFailureState = Read-RemoteRunState `
    -RepositoryRoot $postRemovalFailureFixture.clone_one `
    -StatePath $postRemovalFailureFixture.state_path
  Assert-ClaimBudgetUnchanged `
    -BeforeState $postRemovalFailureFixture.ready_state `
    -AfterState $postRemovalFailureState `
    -Scenario "post-removal ref transaction failure"

  $raceFixture = New-ClaimTransactionFixture `
    -Name "x" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -ClaimPlannerScriptPath $claimPlannerScriptPath `
    -IncludeSecondClone
  $secondRacePlan = New-CompetingClaimPlan `
    -FirstPlan $raceFixture.plan `
    -ReadyState $raceFixture.ready_state `
    -TaskId "task-race-two"
  $firstRaceInvocation = Invoke-WriterClaim `
    -ScriptPath $claimInvokerScriptPath `
    -RepositoryRoot $raceFixture.clone_one `
    -ClaimPlan $raceFixture.plan `
    -TestTransportOutcome "accepted"
  $secondRaceInvocation = Invoke-WriterClaim `
    -ScriptPath $claimInvokerScriptPath `
    -RepositoryRoot $raceFixture.clone_two `
    -ClaimPlan $secondRacePlan `
    -TestTransportOutcome "accepted"
  $acceptedRaceResults = @(
    @($firstRaceInvocation.result, $secondRaceInvocation.result) |
      Where-Object { [bool]$_.accepted }
  )
  Assert-Equal `
    -Actual $acceptedRaceResults.Count `
    -Expected 1 `
    -Message "Exactly one disposable two-clone writer claim did not win."
  Assert-WriterClaimResult `
    -Invocation $firstRaceInvocation `
    -Accepted $true `
    -Code "WRITER_CLAIM_ACCEPTED" `
    -Scenario "two-clone race winner"
  Assert-WriterClaimResult `
    -Invocation $secondRaceInvocation `
    -Accepted $false `
    -Code "WRITER_CLAIM_LOST" `
    -Scenario "two-clone race loser"
  Assert-Equal `
    -Actual $secondRaceInvocation.result.cleanup_performed `
    -Expected $true `
    -Message "Two-clone race loser did not clean up its exact identity."
  Assert-Equal `
    -Actual (Test-Path -LiteralPath $secondRacePlan.worktree_path) `
    -Expected $false `
    -Message "Two-clone race loser worktree remains."
  Assert-Equal `
    -Actual (Test-GitRefExists -RepositoryRoot $raceFixture.clone_two -RefName "refs/heads/$($secondRacePlan.branch_name)") `
    -Expected $false `
    -Message "Two-clone race loser branch remains."
  Assert-Equal `
    -Actual (Invoke-Git -RepositoryRoot $raceFixture.clone_one -GitArguments @("rev-parse", "origin/main")) `
    -Expected $firstRaceInvocation.result.candidate_commit `
    -Message "Two-clone race remote tip is not the winning candidate."
  Assert-Equal `
    -Actual (Invoke-Git -RepositoryRoot $raceFixture.clone_one -GitArguments @("rev-parse", "$($firstRaceInvocation.result.candidate_commit)^")) `
    -Expected $raceFixture.base_commit `
    -Message "Two-clone race winner did not use the shared base revision."
  Assert-Equal `
    -Actual (Invoke-Git -RepositoryRoot $raceFixture.clone_two -GitArguments @("rev-parse", "$($secondRaceInvocation.result.candidate_commit)^")) `
    -Expected $raceFixture.base_commit `
    -Message "Two-clone race loser did not use the shared base revision."
  $loserReachability = Invoke-GitProbe `
    -RepositoryRoot $raceFixture.clone_two `
    -GitArguments @(
      "merge-base",
      "--is-ancestor",
      $secondRaceInvocation.result.candidate_commit,
      "origin/main"
    )
  Assert-Equal `
    -Actual $loserReachability.exit_code `
    -Expected 1 `
    -Message "Two-clone loser candidate unexpectedly reached origin/main."
  $raceState = Read-RemoteRunState `
    -RepositoryRoot $raceFixture.clone_one `
    -StatePath $raceFixture.state_path
  Assert-ClaimBudgetUnchanged `
    -BeforeState $raceFixture.ready_state `
    -AfterState $raceState `
    -Scenario "two-clone writer race"

  [pscustomobject]@{
    document_type = "danio_autonomous_completion_git_fixture_test_result"
    schema_version = 1
    passed = $true
    scenarios = 43
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
