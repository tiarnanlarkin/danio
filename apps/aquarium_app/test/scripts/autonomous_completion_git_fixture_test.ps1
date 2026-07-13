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

  $indexPath = Invoke-Git `
    -RepositoryRoot $RepositoryRoot `
    -GitArguments @("rev-parse", "--path-format=absolute", "--git-path", "index")
  $paths = @(
    Invoke-Git `
      -RepositoryRoot $RepositoryRoot `
      -GitArguments @("ls-files", "--cached", "--others", "--exclude-standard") |
      ForEach-Object { $_ -split "`n" } |
      Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
  )
  [Array]::Sort($paths, [StringComparer]::Ordinal)
  $fileBytes = @(
    foreach ($path in $paths) {
      $candidate = [IO.Path]::GetFullPath((Join-Path $RepositoryRoot $path))
      $requiredPrefix = [IO.Path]::GetFullPath($RepositoryRoot).TrimEnd("\", "/") + [IO.Path]::DirectorySeparatorChar
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
    refs = Invoke-Git -RepositoryRoot $RepositoryRoot -GitArguments @("show-ref")
    index_sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $indexPath).Hash
    worktrees = Invoke-Git -RepositoryRoot $RepositoryRoot -GitArguments @("worktree", "list", "--porcelain")
    status = Invoke-Git -RepositoryRoot $RepositoryRoot -GitArguments @("--no-optional-locks", "status", "--short", "-uall")
    files = $fileBytes -join "`n"
  }
}

function Assert-SnapshotEqual {
  param(
    [Parameter(Mandatory = $true)]$Before,
    [Parameter(Mandatory = $true)]$After,
    [Parameter(Mandatory = $true)][string]$Scenario
  )

  foreach ($field in @("refs", "index_sha256", "worktrees", "status", "files")) {
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

function Invoke-Rehearsal {
  param(
    [Parameter(Mandatory = $true)][string]$ScriptPath,
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string]$InvocationNonce,
    [Parameter(Mandatory = $true)]$Receipt
  )

  $receiptJson = $Receipt | ConvertTo-Json -Depth 100 -Compress
  $receiptBase64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($receiptJson))
  $escapedScript = $ScriptPath.Replace("'", "''")
  $escapedRoot = $RepositoryRoot.Replace("'", "''")
  $childCommand = @"
`$receiptJson = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$receiptBase64'))
& '$escapedScript' ``
  -SynchronizationReceiptJson `$receiptJson ``
  -ExpectedInvocationNonce '$InvocationNonce' ``
  -RehearsalRunId 'fixture-rehearsal-001' ``
  -TaskId 'task-fixture-001' ``
  -ProposedAutonomousUnits 12 ``
  -ProposedWorkUnitId 'WF-2026-07-11-015' ``
  -ProposedLedgerRowIds @('DCL-DR-001') ``
  -RepositoryRoot '$escapedRoot'
"@
  $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($childCommand))
  $output = @(& powershell `
    -NoProfile `
    -NonInteractive `
    -ExecutionPolicy Bypass `
    -EncodedCommand $encodedCommand `
    2>$null)
  Assert-Equal `
    -Actual $LASTEXITCODE `
    -Expected 0 `
    -Message "Rehearsal rejected a valid zero-side-effect fixture: $($output -join '; ')"
  Assert-Equal -Actual $output.Count -Expected 1 -Message "Rehearsal emitted more than one stdout object."
  return $output[0] | ConvertFrom-Json
}

function Invoke-HandoffPromptGenerator {
  param(
    [Parameter(Mandatory = $true)][string]$ScriptPath,
    [Parameter(Mandatory = $true)][string]$PromptKind,
    [Parameter(Mandatory = $true)][string]$RunStateJson,
    [Parameter(Mandatory = $true)][string]$ReadinessReportJson,
    [Parameter(Mandatory = $true)][string]$TaskCapabilitiesJson,
    [Parameter(Mandatory = $true)][string]$SavedProjectJson,
    [Parameter(Mandatory = $true)][string]$RepositoryRoot
  )

  $encodedState = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($RunStateJson))
  $encodedReadiness = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($ReadinessReportJson))
  $encodedCapabilities = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($TaskCapabilitiesJson))
  $encodedProject = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($SavedProjectJson))
  $escapedScript = $ScriptPath.Replace("'", "''")
  $escapedRoot = $RepositoryRoot.Replace("'", "''")
  $childCommand = @"
& '$escapedScript' ``
  -PromptKind '$PromptKind' ``
  -RunStateJson ([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$encodedState'))) ``
  -ReadinessReportJson ([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$encodedReadiness'))) ``
  -TaskCapabilitiesJson ([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$encodedCapabilities'))) ``
  -SavedProjectJson ([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$encodedProject'))) ``
  -RepositoryRoot '$escapedRoot'
"@
  $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($childCommand))
  $output = @(& powershell `
    -NoProfile `
    -NonInteractive `
    -ExecutionPolicy Bypass `
    -EncodedCommand $encodedCommand `
    2>$null)
  Assert-Equal -Actual $LASTEXITCODE -Expected 0 -Message "Handoff binding fixture generation failed."
  Assert-Equal -Actual $output.Count -Expected 1 -Message "Handoff binding fixture emitted multiple reports."
  return $output[0] | ConvertFrom-Json
}

function Invoke-FinalizationReadiness {
  param(
    [Parameter(Mandatory = $true)][string]$ScriptPath,
    [Parameter(Mandatory = $true)]$Fixture,
    [Parameter(Mandatory = $true)][string]$InvocationNonce,
    [Parameter(Mandatory = $true)]$Receipt,
    [AllowNull()]$LeaseRelease = $null
  )

  $receiptJson = $Receipt | ConvertTo-Json -Depth 100 -Compress
  $receiptBase64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($receiptJson))
  $leaseJson = if ($null -eq $LeaseRelease) {
    ""
  } else {
    $LeaseRelease | ConvertTo-Json -Depth 20 -Compress
  }
  $leaseBase64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($leaseJson))
  $escapedScriptPath = $ScriptPath.Replace("'", "''")
  $escapedRepositoryRoot = ([string]$Fixture.clone).Replace("'", "''")
  $escapedEvidencePath = ([string]$Fixture.manifest_path).Replace("'", "''")
  $escapedNonce = $InvocationNonce.Replace("'", "''")
  $childCommand = @"
`$receiptJson = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$receiptBase64'))
`$leaseJson = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$leaseBase64'))
`$parameters = @{
  Intent = 'Finalization'
  SynchronizationReceiptJson = `$receiptJson
  ExpectedInvocationNonce = '$escapedNonce'
  RepositoryRoot = '$escapedRepositoryRoot'
  EvidenceManifestPath = '$escapedEvidencePath'
}
if (-not [string]::IsNullOrWhiteSpace(`$leaseJson)) {
  `$parameters.LeaseReleaseJson = `$leaseJson
}
& '$escapedScriptPath' @parameters
"@
  $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($childCommand))
  $output = @(& powershell `
    -NoProfile `
    -NonInteractive `
    -ExecutionPolicy Bypass `
    -EncodedCommand $encoded `
    2>$null)
  $exitCode = $LASTEXITCODE
  Assert-True -Condition (@(0, 1) -contains $exitCode) -Message "Finalization readiness returned unsupported exit code."
  Assert-Equal -Actual $output.Count -Expected 1 -Message "Finalization readiness emitted more than one stdout object."
  $report = $output[0] | ConvertFrom-Json
  Assert-Equal -Actual $report.eligible -Expected ($exitCode -eq 0) -Message "Finalization readiness disagrees with exit code."
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
    [Parameter(Mandatory = $true)][string]$Scenario,
    [bool]$RequireCandidate = $true
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
  if ($RequireCandidate) {
    Assert-True `
      -Condition ([string]$Invocation.result.candidate_commit -cmatch '^[0-9a-f]{40}$') `
      -Message "Writer claim omitted its candidate commit during $Scenario."
  }
}

function Invoke-TransitionValidation {
  param(
    [Parameter(Mandatory = $true)][string]$ScriptPath,
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string]$Source,
    [AllowNull()][string]$ExpectedParentCommit = $null,
    [AllowNull()][string]$ExpectedStagedTreeHash = $null,
    [string]$Commit = "HEAD",
    [AllowNull()][string]$EvidenceManifestPath = $null,
    [AllowNull()][string]$LeaseReleaseJson = $null
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
  if (-not [string]::IsNullOrWhiteSpace($EvidenceManifestPath)) {
    $arguments += @("-EvidenceManifestPath", $EvidenceManifestPath)
  }
  if (-not [string]::IsNullOrWhiteSpace($LeaseReleaseJson)) {
    $arguments += @("-LeaseReleaseJson", $LeaseReleaseJson)
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

function Get-TransitionLedgerContent {
  param(
    [ValidateSet("ordinary", "rc_open", "rc_closed")]
    [string]$Mode,
    [AllowNull()][string]$EvidenceText = $null
  )

  $rows = switch ($Mode) {
    "ordinary" {
      @(
        "| DCL-DR-001 | Fixture closeout row | fixture | proof | IMPLEMENT | closed | data | none | verified |",
        "| DCL-DR-002 | Fixture next row | fixture | pending | IMPLEMENT | open | data | none | verified |"
      ) -join "`n"
    }
    "rc_open" {
      @(
        "| DCL-DR-001 | Prior verified row | fixture | proof | IMPLEMENT | closed | data | none | verified |",
        "| DCL-RC-001 | Final phone candidate | fixture | pending | IMPLEMENT | open | release | none | terminal proof |"
      ) -join "`n"
    }
    "rc_closed" {
      @(
        "| DCL-DR-001 | Prior verified row | fixture | proof | IMPLEMENT | closed | data | none | verified |",
        "| DCL-RC-001 | Final phone candidate | fixture | $EvidenceText | IMPLEMENT | closed | release | none | terminal proof |"
      ) -join "`n"
    }
  }
  return @"
# Fixture closure ledger

## Active Findings

| ID | Finding | How Found | Evidence | Disposition | Closure State | Lane | User Input | Done Condition |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
$rows

## Closed, Accepted, Or Superseded Findings

| ID | Finding | Superseding Evidence | Disposition | Closure State | Rule |
| --- | --- | --- | --- | --- | --- |
"@
}

function Set-TransitionFixtureLocation {
  param(
    [Parameter(Mandatory = $true)]$State,
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string]$SavedProjectRoot
  )

  $normalizedRepositoryRoot = $RepositoryRoot.Replace("\", "/").TrimEnd("/")
  $normalizedSavedProjectRoot = $SavedProjectRoot.Replace("\", "/").TrimEnd("/")
  $State.authorization.repository_root = $normalizedRepositoryRoot
  $State.authorization.saved_project_root = $normalizedSavedProjectRoot
  if ($null -ne $State.owner) {
    $State.owner.worktree_path = "$normalizedSavedProjectRoot/.codex-worktrees/$($State.owner.worktree_id)"
  }
  return $State
}

function Set-RcOwnerIdentity {
  param(
    [Parameter(Mandatory = $true)]$State,
    [Parameter(Mandatory = $true)][string]$SavedProjectRoot
  )

  $identity = Get-ExpectedWriterIdentity `
    -RunId ([string]$State.run_id) `
    -WorkUnitId ([string]$State.cursor.work_unit_id) `
    -TaskId ([string]$State.owner.task_id) `
    -ExpectedStateRevision ([int64]$State.owner.claim_revision) `
    -SavedProjectRoot $SavedProjectRoot
  $State.owner.token_sha256 = $identity.token_sha256
  $State.owner.branch_name = $identity.branch_name
  $State.owner.worktree_id = $identity.worktree_id
  $State.owner.worktree_path = $identity.worktree_path
  return $State
}

function Set-TransitionFixtureAuthority {
  param(
    [Parameter(Mandatory = $true)]$State,
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string]$Commit
  )

  foreach ($property in @($State.authority.PSObject.Properties)) {
    $property.Value.commit = $Commit
    $property.Value.blob_oid = Invoke-Git `
      -RepositoryRoot $RepositoryRoot `
      -GitArguments @("rev-parse", "$Commit`:$($property.Value.path)")
  }
  return $State
}

function Commit-TransitionFixtureState {
  param(
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string]$StatePath,
    [Parameter(Mandatory = $true)]$State,
    [Parameter(Mandatory = $true)][string]$Subject,
    [AllowNull()][string]$EvidenceManifestPath = $null
  )

  Write-FixtureJson -Path (Join-Path $RepositoryRoot $StatePath) -Value $State
  [void](Invoke-Git -RepositoryRoot $RepositoryRoot -GitArguments @("add", "--", $StatePath))
  $tree = Invoke-Git -RepositoryRoot $RepositoryRoot -GitArguments @("write-tree")
  $trailerLines = @(
    "Danio-State-Tree: $tree",
    "Danio-State-Validation: pass",
    "Danio-Docs-Profile: pass",
    "Danio-Verified-At: 2026-07-11T12:01:30.0000000Z"
  )
  if (-not [string]::IsNullOrWhiteSpace($EvidenceManifestPath)) {
    $trailerLines += "Danio-Evidence-Manifest: $EvidenceManifestPath"
  }
  [void](Invoke-Git `
    -RepositoryRoot $RepositoryRoot `
    -GitArguments @("commit", "-m", $Subject, "-m", ($trailerLines -join "`n")))
  return Invoke-Git -RepositoryRoot $RepositoryRoot -GitArguments @("rev-parse", "HEAD")
}

function New-TransitionEvidenceManifest {
  param(
    [Parameter(Mandatory = $true)][string]$ProductCommit,
    [Parameter(Mandatory = $true)][string]$WorkUnitId,
    [Parameter(Mandatory = $true)][string]$LedgerRowId,
    [string]$ArtifactPath,
    [string]$ArtifactSha256,
    [switch]$Terminal,
    [string]$StartedAtUtc = "2026-07-11T12:05:00.0000000Z",
    [string]$CompletedAtUtc = "2026-07-11T12:06:00.0000000Z"
  )

  $codes = if ($Terminal) {
    @("FULL", "ANDROID_PREP", "CONTENT", "VISUAL", "PRODUCT_TRUTH", "PHONE_QA")
  } else {
    @("FOCUSED")
  }
  $checks = @(
    $codes | ForEach-Object {
      $artifactIndexes = @()
      if (-not [string]::IsNullOrWhiteSpace($ArtifactPath)) {
        $artifactIndexes = @(0)
      }
      [pscustomobject]@{
        code = $_
        status = "pass"
        command_indexes = @(0)
        artifact_indexes = $artifactIndexes
      }
    }
  )
  $artifacts = @()
  if (-not [string]::IsNullOrWhiteSpace($ArtifactPath)) {
    $artifacts = @(
      [pscustomobject]@{
        kind = "fixture-proof"
        path = $ArtifactPath
        sha256 = $ArtifactSha256
      }
    )
  }
  return [pscustomobject]@{
    schema_version = 1
    product_commit = $ProductCommit
    work_unit_id = $WorkUnitId
    ledger_row_ids = @($LedgerRowId)
    commands = @(
      [pscustomobject]@{
        command = "fixture local gate"
        exit_code = 0
        started_at_utc = $StartedAtUtc
        completed_at_utc = $CompletedAtUtc
      }
    )
    environment = [pscustomobject]@{
      platform = "windows"
      device_id = $null
    }
    artifacts = $artifacts
    checks = $checks
    overall_status = "pass"
  }
}

function New-TransitionTransactionFixture {
  param(
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)][string]$FixtureRoot,
    [Parameter(Mandatory = $true)][string]$SourceAppRoot,
    [ValidateSet("closeout", "pause", "stop", "finalize", "complete", "finalization_stop")]
    [string]$Action,
    [switch]$LastBudgetUnit,
    [switch]$FailDocsProfile
  )

  $root = Join-Path $FixtureRoot "tt-$Name"
  $remote = Join-Path $root "remote.git"
  $seed = Join-Path $root "seed"
  $clone = Join-Path $root "clone"
  $stateRelativePath = "apps/aquarium_app/docs/agent/autonomous_completion/phone_completion_run_state.json"
  $ledgerRelativePath = "apps/aquarium_app/docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md"
  $handoffRelativePath = "apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md"
  $sliceLogRelativePath = "apps/aquarium_app/docs/agent/SLICE_LOG.md"
  $gateRelativePath = "apps/aquarium_app/scripts/quality_gates/run_local_quality_gate.ps1"
  $evidenceRoot = "apps/aquarium_app/docs/agent/autonomous_completion/evidence"
  $isRc = @("finalize", "complete", "finalization_stop") -ccontains $Action

  New-Item -ItemType Directory -Force -Path $root | Out-Null
  [void](Invoke-GitWithoutRepository -GitArguments @("init", "--bare", $remote))
  [void](Invoke-GitWithoutRepository -GitArguments @("init", $seed))
  [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("checkout", "-b", "main"))
  [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("config", "user.name", "Danio Transition Fixture"))
  [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("config", "user.email", "transition@example.invalid"))
  [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("config", "core.autocrlf", "false"))

  Write-FixtureScript -Path (Join-Path $seed $handoffRelativePath) -Content "fixture handoff`n"
  Write-FixtureScript -Path (Join-Path $seed $sliceLogRelativePath) -Content "fixture slice log`n"
  $gateExit = if ($FailDocsProfile) { 1 } else { 0 }
  Write-FixtureScript -Path (Join-Path $seed $gateRelativePath) -Content @"
[CmdletBinding()]
param([string]`$Profile)
if (`$Profile -cne "Docs") { exit 1 }
Write-Output "Disposable Docs profile executed."
exit $gateExit
"@
  foreach ($relativePath in @(
    "docs/agent/plans/2026-07-11-phone-complete-local-completion-program.md",
    "docs/agent/FINISH_MAP.md",
    "docs/agent/QUALITY_LADDER.md",
    "docs/agent/VERIFIED_SLICE_EXECUTION_CONTRACT.md",
    "docs/agent/DEVICE_OWNERSHIP.md",
    "docs/agent/autonomous_completion/runner_compatibility.json"
  )) {
    $sourcePath = Join-Path $SourceAppRoot $relativePath
    $destinationPath = Join-Path $seed "apps/aquarium_app/$relativePath"
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destinationPath) | Out-Null
    Copy-Item -LiteralPath $sourcePath -Destination $destinationPath
  }
  $transitionRunnerManifestPath = Join-Path `
    $seed `
    "apps/aquarium_app/docs/agent/autonomous_completion/runner_compatibility.json"
  $transitionRunnerManifest = Get-Content `
    -Raw `
    -LiteralPath $transitionRunnerManifestPath | ConvertFrom-Json
  $transitionRunnerManifest.manifest_revision = 2
  $transitionRunnerManifest.authorizes_launch = $false
  $transitionRunnerManifest.launch_proof = $null
  Write-FixtureJson `
    -Path $transitionRunnerManifestPath `
    -Value $transitionRunnerManifest

  $ledgerMode = if ($isRc) { "rc_open" } else { "ordinary" }
  Write-FixtureScript `
    -Path (Join-Path $seed $ledgerRelativePath) `
    -Content (Get-TransitionLedgerContent -Mode $ledgerMode)
  $historicalArtifactPath = "apps/aquarium_app/docs/agent/autonomous_completion/product-proof.txt"
  Write-FixtureScript -Path (Join-Path $seed $historicalArtifactPath) -Content "historical product proof`n"
  [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("add", "apps/aquarium_app"))
  [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("commit", "-m", "fixture: authority and product base"))
  $historicalProductCommit = Invoke-Git -RepositoryRoot $seed -GitArguments @("rev-parse", "HEAD")
  $historicalArtifactSha256 = (Get-FileHash `
    -Algorithm SHA256 `
    -LiteralPath (Join-Path $seed $historicalArtifactPath)).Hash.ToLowerInvariant()

  $historicalManifestPath = $null
  if ($isRc) {
    $historicalManifestPath = "$evidenceRoot/$historicalProductCommit.json"
    $historicalManifest = New-TransitionEvidenceManifest `
      -ProductCommit $historicalProductCommit `
      -WorkUnitId "DCL-DR-001-prior" `
      -LedgerRowId "DCL-DR-001" `
      -ArtifactPath $historicalArtifactPath `
      -ArtifactSha256 $historicalArtifactSha256 `
      -StartedAtUtc "2026-07-11T11:50:00.0000000Z" `
      -CompletedAtUtc "2026-07-11T11:51:00.0000000Z"
    Write-FixtureJson -Path (Join-Path $seed $historicalManifestPath) -Value $historicalManifest
    [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("add", "--", $historicalManifestPath))
    [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("commit", "-m", "fixture: historical evidence checkpoint"))
  }
  $authoritySnapshotCommit = Invoke-Git -RepositoryRoot $seed -GitArguments @("rev-parse", "HEAD")

  $readyState = Get-Content -Raw -LiteralPath (
    Join-Path $SourceAppRoot "test/scripts/fixtures/autonomous_completion/ready_run_state.json"
  ) | ConvertFrom-Json
  $readyState = Set-TransitionFixtureLocation `
    -State $readyState `
    -RepositoryRoot $clone `
    -SavedProjectRoot $root
  if ($isRc) {
    $readyState.cursor.phase = "7-final-phone-candidate"
    $readyState.cursor.work_unit_id = "DCL-RC-001-final-candidate"
    $readyState.cursor.ledger_row_ids = @("DCL-RC-001")
    $readyState.last_verified_checkpoint = [pscustomobject]@{
      product_commit = $historicalProductCommit
      evidence_manifest_path = $historicalManifestPath
      verified_at_utc = "2026-07-11T11:55:00.0000000Z"
    }
  } else {
    $readyState.cursor.phase = "1-data-resilience"
    $readyState.cursor.work_unit_id = "DCL-DR-001-fixture"
    $readyState.cursor.ledger_row_ids = @("DCL-DR-001")
    $readyState.last_verified_checkpoint = $null
  }
  $readyState.budget.current_charge.work_unit_id = $null
  $readyState.budget.current_charge.status = "none"
  $readyState.budget.current_charge.claimed_revision = $null
  $readyState.budget.current_charge.consumed_revision = $null
  if ($LastBudgetUnit) {
    $readyState.budget.consumed_units = 19
    $readyState.budget.remaining_units_including_current = 1
  }
  $readyState.transition.occurred_at_utc = "2026-07-11T11:59:00.0000000Z"
  $readyState = Set-TransitionFixtureAuthority `
    -State $readyState `
    -RepositoryRoot $seed `
    -Commit $authoritySnapshotCommit
  Write-FixtureJson -Path (Join-Path $seed $stateRelativePath) -Value $readyState
  [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("add", "--", $stateRelativePath))
  [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("commit", "-m", "fixture: ready state parent"))
  $readyCommit = Invoke-Git -RepositoryRoot $seed -GitArguments @("rev-parse", "HEAD")
  $readyTree = Invoke-Git -RepositoryRoot $seed -GitArguments @("rev-parse", "$readyCommit^{tree}")

  $activeState = $readyState | ConvertTo-Json -Depth 100 | ConvertFrom-Json
  $activeState.state_revision = [int64]$readyState.state_revision + 1
  $activeState.mode = "active"
  $activeState.transition = [pscustomobject]@{
    action = "claim"
    from_mode = "ready"
    to_mode = "active"
    parent_state_revision = [int64]$readyState.state_revision
    work_unit_id = [string]$readyState.cursor.work_unit_id
    reason_code = $null
    occurred_at_utc = "2026-07-11T12:01:00.0000000Z"
  }
  $ownerTaskId = "task-transition-fixture"
  $ownerIdentity = Get-ExpectedWriterIdentity `
    -RunId ([string]$activeState.run_id) `
    -WorkUnitId ([string]$activeState.cursor.work_unit_id) `
    -TaskId $ownerTaskId `
    -ExpectedStateRevision ([int64]$readyState.state_revision) `
    -SavedProjectRoot $root
  $activeState.owner = [pscustomobject][ordered]@{
    task_id = $ownerTaskId
    token_sha256 = $ownerIdentity.token_sha256
    claim_revision = [int64]$readyState.state_revision
    claim_parent_commit = $readyCommit
    claim_staged_tree_hash = $readyTree
    branch_name = $ownerIdentity.branch_name
    worktree_id = $ownerIdentity.worktree_id
    worktree_path = $ownerIdentity.worktree_path
    claimed_at_utc = "2026-07-11T12:01:00.0000000Z"
    writer_lease_released = $false
    android_lease_released = $false
  }
  $activeState.budget.current_charge.work_unit_id = [string]$activeState.cursor.work_unit_id
  $activeState.budget.current_charge.status = "pending"
  $activeState.budget.current_charge.claimed_revision = [int64]$readyState.state_revision
  $activeState.budget.current_charge.consumed_revision = $null
  $activeCommit = Commit-TransitionFixtureState `
    -RepositoryRoot $seed `
    -StatePath $stateRelativePath `
    -State $activeState `
    -Subject "fixture: typed writer claim"

  $previousState = $activeState
  $previousStateCommit = $activeCommit
  if (@("complete", "finalization_stop") -ccontains $Action) {
    $finalizingState = $activeState | ConvertTo-Json -Depth 100 | ConvertFrom-Json
    $finalizingState.state_revision = [int64]$activeState.state_revision + 1
    $finalizingState.mode = "finalizing"
    $finalizingState.transition = [pscustomobject]@{
      action = "finalize"
      from_mode = "active"
      to_mode = "finalizing"
      parent_state_revision = [int64]$activeState.state_revision
      work_unit_id = [string]$activeState.cursor.work_unit_id
      reason_code = $null
      occurred_at_utc = "2026-07-11T12:02:00.0000000Z"
    }
    $finalizingState.budget.consumed_units = [int64]$activeState.budget.consumed_units + 1
    $finalizingState.budget.remaining_units_including_current = [int64]$activeState.budget.remaining_units_including_current - 1
    $finalizingState.budget.current_charge.status = "consumed"
    $finalizingState.budget.current_charge.consumed_revision = [int64]$finalizingState.state_revision
    $finalizingState = Set-TransitionFixtureAuthority `
      -State $finalizingState `
      -RepositoryRoot $seed `
      -Commit $activeCommit
    $previousStateCommit = Commit-TransitionFixtureState `
      -RepositoryRoot $seed `
      -StatePath $stateRelativePath `
      -State $finalizingState `
      -Subject "fixture: typed finalization entry" `
      -EvidenceManifestPath $historicalManifestPath
    $previousState = $finalizingState
  }

  $productCommit = $historicalProductCommit
  $manifestPath = $historicalManifestPath
  if (
    @("closeout", "pause") -ccontains $Action -or
    ($Action -ceq "stop" -and $LastBudgetUnit)
  ) {
    $productArtifactPath = "apps/aquarium_app/docs/agent/autonomous_completion/current-proof.txt"
    Write-FixtureScript -Path (Join-Path $seed $productArtifactPath) -Content "current product proof`n"
    [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("add", "--", $productArtifactPath))
    [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("commit", "-m", "fixture: owned product checkpoint"))
    $productCommit = Invoke-Git -RepositoryRoot $seed -GitArguments @("rev-parse", "HEAD")
    $productArtifactSha256 = (Get-FileHash `
      -Algorithm SHA256 `
      -LiteralPath (Join-Path $seed $productArtifactPath)).Hash.ToLowerInvariant()
    $manifestPath = "$evidenceRoot/$productCommit.json"
    $manifest = New-TransitionEvidenceManifest `
      -ProductCommit $productCommit `
      -WorkUnitId ([string]$activeState.cursor.work_unit_id) `
      -LedgerRowId "DCL-DR-001" `
      -ArtifactPath $productArtifactPath `
      -ArtifactSha256 $productArtifactSha256
    Write-FixtureJson -Path (Join-Path $seed $manifestPath) -Value $manifest
    [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("add", "--", $manifestPath))
    [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("commit", "-m", "fixture: owned evidence manifest"))
  } elseif ($Action -ceq "complete") {
    $terminalArtifactPath = "apps/aquarium_app/docs/agent/autonomous_completion/final-proof.txt"
    Write-FixtureScript -Path (Join-Path $seed $terminalArtifactPath) -Content "terminal product proof`n"
    [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("add", "--", $terminalArtifactPath))
    [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("commit", "-m", "fixture: terminal product checkpoint"))
    $productCommit = Invoke-Git -RepositoryRoot $seed -GitArguments @("rev-parse", "HEAD")
    $terminalArtifactSha256 = (Get-FileHash `
      -Algorithm SHA256 `
      -LiteralPath (Join-Path $seed $terminalArtifactPath)).Hash.ToLowerInvariant()
    $manifestPath = "$evidenceRoot/$productCommit.json"
    $terminalManifest = New-TransitionEvidenceManifest `
      -ProductCommit $productCommit `
      -WorkUnitId ([string]$previousState.cursor.work_unit_id) `
      -LedgerRowId "DCL-RC-001" `
      -ArtifactPath $terminalArtifactPath `
      -ArtifactSha256 $terminalArtifactSha256 `
      -Terminal `
      -StartedAtUtc "2026-07-11T12:05:00.0000000Z" `
      -CompletedAtUtc "2026-07-11T12:06:00.0000000Z"
    Write-FixtureJson -Path (Join-Path $seed $manifestPath) -Value $terminalManifest
    $rcEvidence = "Final evidence manifest $manifestPath for product $productCommit"
    Write-FixtureScript `
      -Path (Join-Path $seed $ledgerRelativePath) `
      -Content (Get-TransitionLedgerContent -Mode "rc_closed" -EvidenceText $rcEvidence)
    [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("add", "apps/aquarium_app"))
    [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("commit", "-m", "fixture: terminal evidence and ledger checkpoint"))
  }
  $evidenceCommit = Invoke-Git -RepositoryRoot $seed -GitArguments @("rev-parse", "HEAD")

  [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("remote", "add", "origin", $remote))
  [void](Invoke-Git -RepositoryRoot $seed -GitArguments @("push", "-u", "origin", "main"))
  [void](Invoke-Git -RepositoryRoot $remote -GitArguments @("symbolic-ref", "HEAD", "refs/heads/main"))
  [void](Invoke-GitWithoutRepository -GitArguments @("-c", "core.autocrlf=false", "clone", $remote, $clone))
  [void](Invoke-Git -RepositoryRoot $clone -GitArguments @("config", "user.name", "Danio Transition Clone"))
  [void](Invoke-Git -RepositoryRoot $clone -GitArguments @("config", "user.email", "transition-clone@example.invalid"))
  [void](Invoke-Git -RepositoryRoot $clone -GitArguments @("config", "core.autocrlf", "false"))

  New-Item -ItemType Directory -Force -Path (Split-Path -Parent ([string]$previousState.owner.worktree_path)) | Out-Null
  [void](Invoke-Git -RepositoryRoot $clone -GitArguments @(
    "worktree", "add", "-b", [string]$previousState.owner.branch_name,
    [string]$previousState.owner.worktree_path, $previousStateCommit
  ))
  $ownerExistedBeforeCleanup = (
    (Test-Path -LiteralPath ([string]$previousState.owner.worktree_path) -PathType Container) -and
    (Test-GitRefExists -RepositoryRoot $clone -RefName "refs/heads/$($previousState.owner.branch_name)")
  )
  $ownerCheckpointAligned = (
    (Invoke-Git -RepositoryRoot $clone -GitArguments @("rev-parse", "HEAD")) -ceq $evidenceCommit -and
    (Invoke-Git -RepositoryRoot $clone -GitArguments @("rev-parse", "origin/main")) -ceq $evidenceCommit -and
    $ownerExistedBeforeCleanup
  )
  $ownerCleanupPerformed = $false
  if ($Action -cne "finalize") {
    [void](Invoke-Git -RepositoryRoot $clone -GitArguments @(
      "worktree", "remove", "--", [string]$previousState.owner.worktree_path
    ))
    [void](Invoke-Git -RepositoryRoot $clone -GitArguments @(
      "branch", "-d", "--", [string]$previousState.owner.branch_name
    ))
    $ownerCleanupPerformed = $true
  }
  [IO.File]::AppendAllText((Join-Path $clone $handoffRelativePath), "closeout update`n")
  [IO.File]::AppendAllText((Join-Path $clone $sliceLogRelativePath), "slice update`n")

  $candidateState = $previousState | ConvertTo-Json -Depth 100 | ConvertFrom-Json
  $candidateState.state_revision = [int64]$previousState.state_revision + 1
  $candidateState.transition = [pscustomobject]@{
    action = $Action
    from_mode = [string]$previousState.mode
    to_mode = switch ($Action) {
      "closeout" { "handoff_ready" }
      "pause" { "paused" }
      "stop" { "stopped" }
      "finalize" { "finalizing" }
      "complete" { "complete" }
      "finalization_stop" { "stopped" }
    }
    parent_state_revision = [int64]$previousState.state_revision
    work_unit_id = [string]$previousState.cursor.work_unit_id
    reason_code = if (@("stop", "finalization_stop") -ccontains $Action) {
      if ($Action -ceq "stop") {
        if ($LastBudgetUnit) { "BUDGET_EXHAUSTED" } else { "BASELINE_FAILED" }
      } else {
        "FINALIZATION_FAILED"
      }
    } else {
      $null
    }
    occurred_at_utc = "2026-07-11T12:10:00.0000000Z"
  }
  $candidateState.mode = [string]$candidateState.transition.to_mode
  $candidateState.stop_reason_code = $candidateState.transition.reason_code
  if (@("closeout", "pause", "stop", "finalize") -ccontains $Action) {
    $candidateState.budget.consumed_units = [int64]$previousState.budget.consumed_units + 1
    $candidateState.budget.remaining_units_including_current = [int64]$previousState.budget.remaining_units_including_current - 1
    $candidateState.budget.current_charge.status = "consumed"
    $candidateState.budget.current_charge.consumed_revision = [int64]$candidateState.state_revision
  }
  if ($Action -ceq "closeout") {
    $candidateState.handoff_generation = [int64]$previousState.handoff_generation + 1
    $candidateState.cursor.work_unit_id = "DCL-DR-002-next"
    $candidateState.cursor.ledger_row_ids = @("DCL-DR-002")
  }
  if (@("closeout", "pause", "stop", "complete", "finalization_stop") -ccontains $Action) {
    $candidateState.owner = $null
  }
  if (
    @("closeout", "pause") -ccontains $Action -or
    ($Action -ceq "stop" -and $LastBudgetUnit)
  ) {
    $candidateState.last_verified_checkpoint = [pscustomobject]@{
      product_commit = $productCommit
      evidence_manifest_path = $manifestPath
      verified_at_utc = "2026-07-11T12:09:00.0000000Z"
    }
  } elseif ($Action -ceq "complete") {
    $candidateState.last_verified_checkpoint = [pscustomobject]@{
      product_commit = $productCommit
      evidence_manifest_path = $manifestPath
      verified_at_utc = "2026-07-11T12:09:00.0000000Z"
    }
  } elseif ($Action -ceq "stop") {
    $candidateState.last_verified_checkpoint = $null
  } else {
    $candidateState.last_verified_checkpoint = $previousState.last_verified_checkpoint
  }
  if (@("stop", "finalization_stop") -ccontains $Action) {
    $candidateState.recovery = [pscustomobject]@{
      branch_name = [string]$previousState.owner.branch_name
      worktree_path = [string]$previousState.owner.worktree_path
      dirty_paths = @()
      relevant_processes = @()
      commands = @("Reconcile the exact stopped owner before resuming.")
      last_clean_commit = $historicalProductCommit
    }
  } else {
    $candidateState.recovery = $null
  }
  $candidateState = Set-TransitionFixtureAuthority `
    -State $candidateState `
    -RepositoryRoot $clone `
    -Commit $evidenceCommit

  $releaseActions = @("closeout", "pause", "stop", "complete", "finalization_stop")
  $leaseRelease = if ($releaseActions -ccontains $Action) {
    [pscustomobject]@{
      owner_token = [string]$previousState.owner.token_sha256
      android_released = $true
      processes_released = $true
    }
  } else {
    $null
  }
  return [pscustomobject]@{
    root = $root
    remote = $remote
    seed = $seed
    clone = $clone
    state_path = $stateRelativePath
    handoff_path = $handoffRelativePath
    slice_log_path = $sliceLogRelativePath
    previous_state = $previousState
    candidate_state = $candidateState
    product_commit = $productCommit
    historical_product_commit = $historicalProductCommit
    historical_artifact_path = $historicalArtifactPath
    historical_artifact_sha256 = $historicalArtifactSha256
    evidence_commit = $evidenceCommit
    manifest_path = if ($Action -ceq "stop" -and -not $LastBudgetUnit) { $null } else { $manifestPath }
    lease_release = $leaseRelease
    owner_state_commit = $previousStateCommit
    owner_existed_before_cleanup = $ownerExistedBeforeCleanup
    owner_checkpoint_aligned = $ownerCheckpointAligned
    owner_cleanup_performed = $ownerCleanupPerformed
  }
}

function Update-TransitionFixtureEvidenceParent {
  param([Parameter(Mandatory = $true)]$Fixture)

  $newParent = Invoke-Git -RepositoryRoot $Fixture.clone -GitArguments @("rev-parse", "HEAD")
  [void](Invoke-Git -RepositoryRoot $Fixture.clone -GitArguments @("push", "origin", "main"))
  $Fixture.evidence_commit = $newParent
  $Fixture.candidate_state = Set-TransitionFixtureAuthority `
    -State $Fixture.candidate_state `
    -RepositoryRoot $Fixture.clone `
    -Commit $newParent
  return $Fixture
}

function Invoke-CompletionTransition {
  param(
    [Parameter(Mandatory = $true)][string]$ScriptPath,
    [Parameter(Mandatory = $true)]$Fixture,
    [Parameter(Mandatory = $true)][string]$TestTransportOutcome,
    [AllowNull()][string]$GitShimDirectory = $null,
    [hashtable]$ChildEnvironment = @{}
  )

  $stateJson = $Fixture.candidate_state | ConvertTo-Json -Depth 100 -Compress
  $stateBase64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($stateJson))
  $leaseJson = if ($null -eq $Fixture.lease_release) {
    ""
  } else {
    $Fixture.lease_release | ConvertTo-Json -Depth 20 -Compress
  }
  $leaseBase64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($leaseJson))
  $escapedScriptPath = $ScriptPath.Replace("'", "''")
  $escapedRoot = ([string]$Fixture.clone).Replace("'", "''")
  $escapedEvidence = ([string]$Fixture.manifest_path).Replace("'", "''")
  $escapedOutcome = $TestTransportOutcome.Replace("'", "''")
  $childCommand = @"
`$env:DANIO_AUTONOMY_TEST_MODE = '1'
`$stateJson = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$stateBase64'))
`$leaseJson = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$leaseBase64'))
`$parameters = @{
  NextRunStateJson = `$stateJson
  ExpectedStateRevision = [int64]$($Fixture.previous_state.state_revision)
  ExpectedOriginMainCommit = '$($Fixture.evidence_commit)'
  RepositoryRoot = '$escapedRoot'
  TestTransportOutcome = '$escapedOutcome'
}
if (-not [string]::IsNullOrWhiteSpace('$escapedEvidence')) {
  `$parameters.EvidenceManifestPath = '$escapedEvidence'
}
if (-not [string]::IsNullOrWhiteSpace(`$leaseJson)) {
  `$parameters.LeaseReleaseJson = `$leaseJson
}
& '$escapedScriptPath' @parameters
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
  $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($childCommand))
  $output = @(& powershell `
    -NoProfile `
    -NonInteractive `
    -ExecutionPolicy Bypass `
    -EncodedCommand $encoded `
    2>$null)
  $exitCode = $LASTEXITCODE
  Assert-True -Condition (@(0, 1) -contains $exitCode) -Message "Completion transition returned unsupported exit code."
  Assert-Equal -Actual $output.Count -Expected 1 -Message "Completion transition emitted more than one stdout object."
  $result = $output[0] | ConvertFrom-Json
  Assert-Equal -Actual $result.accepted -Expected ($exitCode -eq 0) -Message "Transition result disagrees with exit code."
  return [pscustomobject]@{
    exit_code = $exitCode
    result = $result
  }
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
$transitionCommitScriptPath = Join-Path $appRoot "scripts/autonomous_completion/commit_autonomous_completion_transition.ps1"
$handoffScriptPath = Join-Path $appRoot "scripts/autonomous_completion/new_autonomous_handoff_prompt.ps1"
$rehearsalScriptPath = Join-Path $appRoot "scripts/autonomous_completion/run_autonomous_completion_rehearsal.ps1"

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
if (-not (Test-Path -LiteralPath $transitionCommitScriptPath -PathType Leaf)) {
  throw "Expected transition mutation entry point is missing: $transitionCommitScriptPath"
}
if (-not (Test-Path -LiteralPath $handoffScriptPath -PathType Leaf)) {
  throw "Expected handoff prompt entry point is missing: $handoffScriptPath"
}
if (-not (Test-Path -LiteralPath $rehearsalScriptPath -PathType Leaf)) {
  throw "Expected rehearsal entry point is missing: $rehearsalScriptPath"
}
Import-Module -Name (Join-Path $appRoot "scripts/autonomous_completion/DanioAutonomousCompletion.psm1") -Force

$tempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$tempRoot = Join-Path $tempBase "danio-autonomy-$([Guid]::NewGuid().ToString('N'))"
$remoteRoot = Join-Path $tempRoot "remote.git"
$seedRoot = Join-Path $tempRoot "seed"
$cloneOneRoot = Join-Path $tempRoot "clone-one"
$cloneTwoRoot = Join-Path $tempRoot "clone-two"
$foreignWorktreeRoot = Join-Path $tempRoot "foreign-worktree"
$proofRoot = Join-Path $tempRoot "launch-proof"
$proofRemoteRoot = Join-Path $tempRoot "launch-proof-remote.git"
$invocationNonce = "0123456789abcdef0123456789abcdef"

try {
  New-Item -ItemType Directory -Path $tempRoot | Out-Null
  [void](Invoke-GitWithoutRepository -GitArguments @("init", $proofRoot))
  [void](Invoke-Git -RepositoryRoot $proofRoot -GitArguments @("checkout", "-b", "main"))
  [void](Invoke-Git -RepositoryRoot $proofRoot -GitArguments @("config", "user.name", "Danio Proof Fixture"))
  [void](Invoke-Git -RepositoryRoot $proofRoot -GitArguments @("config", "user.email", "danio-proof@example.invalid"))
  [void](Invoke-Git -RepositoryRoot $proofRoot -GitArguments @("config", "core.autocrlf", "false"))
  $proofAppRoot = Join-Path $proofRoot "apps/aquarium_app"
  New-Item -ItemType Directory -Force -Path $proofAppRoot | Out-Null
  [IO.File]::WriteAllText(
    (Join-Path $proofAppRoot "proof-base.txt"),
    "proof base",
    (New-Object Text.UTF8Encoding($false))
  )
  [void](Invoke-Git -RepositoryRoot $proofRoot -GitArguments @("add", "apps/aquarium_app/proof-base.txt"))
  [void](Invoke-Git -RepositoryRoot $proofRoot -GitArguments @("commit", "-m", "fixture: establish proof base"))
  $proofBaseCommit = Invoke-Git -RepositoryRoot $proofRoot -GitArguments @("rev-parse", "HEAD")
  $proofBaseTree = Invoke-Git -RepositoryRoot $proofRoot -GitArguments @("rev-parse", "HEAD^{tree}")
  $proofObservation = [pscustomobject][ordered]@{
    status_sha256 = ("1" * 64)
    index_tree = $proofBaseTree
    local_refs_sha256 = ("2" * 64)
    remote_refs_sha256 = ("3" * 64)
    worktrees_sha256 = ("4" * 64)
  }
  $proofLaunchPreview = [pscustomobject][ordered]@{
    eligible = $false
    code = "LAUNCH_NOT_AUTHORIZED"
    mutations_performed = $false
  }
  $proofAuthorityPreview = [pscustomobject][ordered]@{
    eligible = $false
    code = "AUTHORITY_CONFLICT"
    mutations_performed = $false
  }
  $proofReport = New-DanioRehearsalReport `
    -RehearsalRunId "fixture-committed-rehearsal" `
    -TaskId "fixture-task-001" `
    -CreatedAtUtc "2026-07-13T12:00:00.0000000Z" `
    -RepositoryRoot ($proofRoot.Replace("\", "/")) `
    -BaseCommit $proofBaseCommit `
    -ProposedAutonomousUnits 12 `
    -ProposedWorkUnitId "WF-2026-07-11-015" `
    -ProposedLedgerRowIds @("DCL-DR-001") `
    -Before $proofObservation `
    -After ($proofObservation | ConvertTo-Json -Depth 100 | ConvertFrom-Json) `
    -LaunchPreview $proofLaunchPreview `
    -ClaimPreview $proofAuthorityPreview `
    -CloseoutPreview ($proofAuthorityPreview | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
  $proofReportRelativePath = "apps/aquarium_app/docs/agent/autonomous_completion/rehearsal-proof.json"
  $proofReportPath = Join-Path $proofRoot $proofReportRelativePath
  Write-FixtureJson -Path $proofReportPath -Value $proofReport
  [void](Invoke-Git -RepositoryRoot $proofRoot -GitArguments @("add", $proofReportRelativePath))
  [void](Invoke-Git -RepositoryRoot $proofRoot -GitArguments @("commit", "-m", "fixture: commit valid rehearsal proof"))
  $proofCommit = Invoke-Git -RepositoryRoot $proofRoot -GitArguments @("rev-parse", "HEAD")
  $proofReportSha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $proofReportPath).Hash.ToLowerInvariant()
  $sourceRunnerManifest = Get-Content -Raw -LiteralPath (
    Join-Path $appRoot "docs/agent/autonomous_completion/runner_compatibility.json"
  ) | ConvertFrom-Json
  $authorizedProofManifest = $sourceRunnerManifest | ConvertTo-Json -Depth 100 | ConvertFrom-Json
  $authorizedProofManifest.manifest_revision = 3
  $authorizedProofManifest.authorizes_launch = $true
  $authorizedProofManifest.launch_proof = [pscustomobject]@{
    report_path = $proofReportRelativePath
    report_sha256 = $proofReportSha256
    report_commit = $proofCommit
  }
  $validProofValidation = Test-DanioRunnerCompatibility `
    -Manifest $authorizedProofManifest `
    -RequireLaunchAuthorization `
    -RepositoryRoot $proofRoot
  Assert-Equal -Actual $validProofValidation.code -Expected "RUNNER_COMPATIBLE" -Message "Valid committed rehearsal proof was rejected."

  [IO.File]::WriteAllText(
    $proofReportPath,
    "working tree tamper",
    (New-Object Text.UTF8Encoding($false))
  )
  $committedBlobValidation = Test-DanioRunnerCompatibility `
    -Manifest $authorizedProofManifest `
    -RequireLaunchAuthorization `
    -RepositoryRoot $proofRoot
  Assert-Equal -Actual $committedBlobValidation.code -Expected "RUNNER_COMPATIBLE" -Message "Working-tree tamper displaced committed rehearsal proof bytes."
  [void](Invoke-Git `
    -RepositoryRoot $proofRoot `
    -GitArguments @("restore", "--source", $proofCommit, "--", $proofReportRelativePath))

  [IO.File]::WriteAllText(
    (Join-Path $proofAppRoot "unrelated.txt"),
    "unrelated",
    (New-Object Text.UTF8Encoding($false))
  )
  [void](Invoke-Git -RepositoryRoot $proofRoot -GitArguments @("add", "apps/aquarium_app/unrelated.txt"))
  [void](Invoke-Git -RepositoryRoot $proofRoot -GitArguments @("commit", "-m", "fixture: unrelated commit"))
  $unrelatedCommit = Invoke-Git -RepositoryRoot $proofRoot -GitArguments @("rev-parse", "HEAD")
  $nonContainingManifest = $authorizedProofManifest | ConvertTo-Json -Depth 100 | ConvertFrom-Json
  $nonContainingManifest.launch_proof.report_commit = $unrelatedCommit
  $nonContainingValidation = Test-DanioRunnerCompatibility `
    -Manifest $nonContainingManifest `
    -RequireLaunchAuthorization `
    -RepositoryRoot $proofRoot
  Assert-Equal -Actual $nonContainingValidation.code -Expected "RUNNER_INCOMPATIBLE" -Message "An unrelated commit was accepted as the containing report commit."

  $workingOnlyRelativePath = "apps/aquarium_app/docs/agent/autonomous_completion/rehearsal-working-tree-only.json"
  $workingOnlyPath = Join-Path $proofRoot $workingOnlyRelativePath
  Write-FixtureJson -Path $workingOnlyPath -Value $proofReport
  $workingOnlyManifest = $authorizedProofManifest | ConvertTo-Json -Depth 100 | ConvertFrom-Json
  $workingOnlyManifest.launch_proof.report_path = $workingOnlyRelativePath
  $workingOnlyManifest.launch_proof.report_sha256 = (
    Get-FileHash -Algorithm SHA256 -LiteralPath $workingOnlyPath
  ).Hash.ToLowerInvariant()
  $workingOnlyManifest.launch_proof.report_commit = $unrelatedCommit
  $workingOnlyValidation = Test-DanioRunnerCompatibility `
    -Manifest $workingOnlyManifest `
    -RequireLaunchAuthorization `
    -RepositoryRoot $proofRoot
  Assert-Equal -Actual $workingOnlyValidation.code -Expected "RUNNER_INCOMPATIBLE" -Message "Working-tree-only rehearsal proof was accepted."
  Remove-Item -LiteralPath $workingOnlyPath -Force

  $tamperedReports = @(
    @{
      Name = "changed-observation"
      Mutate = {
        param($Report)
        $Report.after.local_refs_sha256 = ("5" * 64)
      }
    },
    @{
      Name = "wrong-launch-code"
      Mutate = {
        param($Report)
        $Report.previews.launch.code = "RUNNER_INCOMPATIBLE"
      }
    },
    @{
      Name = "wrong-claim-code"
      Mutate = {
        param($Report)
        $Report.previews.claim.code = "RUNNER_INCOMPATIBLE"
      }
    },
    @{
      Name = "wrong-closeout-code"
      Mutate = {
        param($Report)
        $Report.previews.closeout.code = "RUNNER_INCOMPATIBLE"
      }
    }
  )
  foreach ($tamperedCase in $tamperedReports) {
    $tamperedReport = $proofReport | ConvertTo-Json -Depth 100 | ConvertFrom-Json
    & $tamperedCase.Mutate $tamperedReport
    $tamperedRelativePath = "apps/aquarium_app/docs/agent/autonomous_completion/rehearsal-$($tamperedCase.Name).json"
    $tamperedPath = Join-Path $proofRoot $tamperedRelativePath
    Write-FixtureJson -Path $tamperedPath -Value $tamperedReport
    [void](Invoke-Git -RepositoryRoot $proofRoot -GitArguments @("add", $tamperedRelativePath))
    [void](Invoke-Git -RepositoryRoot $proofRoot -GitArguments @("commit", "-m", "fixture: $($tamperedCase.Name)"))
    $tamperedManifest = $authorizedProofManifest | ConvertTo-Json -Depth 100 | ConvertFrom-Json
    $tamperedManifest.launch_proof.report_path = $tamperedRelativePath
    $tamperedManifest.launch_proof.report_sha256 = (
      Get-FileHash -Algorithm SHA256 -LiteralPath $tamperedPath
    ).Hash.ToLowerInvariant()
    $tamperedManifest.launch_proof.report_commit = Invoke-Git `
      -RepositoryRoot $proofRoot `
      -GitArguments @("rev-parse", "HEAD")
    $tamperedValidation = Test-DanioRunnerCompatibility `
      -Manifest $tamperedManifest `
      -RequireLaunchAuthorization `
      -RepositoryRoot $proofRoot
    Assert-Equal `
      -Actual $tamperedValidation.code `
      -Expected "RUNNER_INCOMPATIBLE" `
      -Message "Tampered rehearsal proof '$($tamperedCase.Name)' was accepted."
  }

  foreach ($mutationName in @(
    "repository_files",
    "index",
    "local_refs",
    "remote_refs",
    "worktrees",
    "successor_tasks",
    "android_runtime",
    "figma",
    "external_services"
  )) {
    $tamperedReport = $proofReport | ConvertTo-Json -Depth 100 | ConvertFrom-Json
    $tamperedReport.mutations.$mutationName = $true
    $tamperedRelativePath = "apps/aquarium_app/docs/agent/autonomous_completion/rehearsal-true-$($mutationName.Replace('_', '-')).json"
    $tamperedPath = Join-Path $proofRoot $tamperedRelativePath
    Write-FixtureJson -Path $tamperedPath -Value $tamperedReport
    [void](Invoke-Git -RepositoryRoot $proofRoot -GitArguments @("add", $tamperedRelativePath))
    [void](Invoke-Git -RepositoryRoot $proofRoot -GitArguments @("commit", "-m", "fixture: true mutation $mutationName"))
    $tamperedManifest = $authorizedProofManifest | ConvertTo-Json -Depth 100 | ConvertFrom-Json
    $tamperedManifest.launch_proof.report_path = $tamperedRelativePath
    $tamperedManifest.launch_proof.report_sha256 = (
      Get-FileHash -Algorithm SHA256 -LiteralPath $tamperedPath
    ).Hash.ToLowerInvariant()
    $tamperedManifest.launch_proof.report_commit = Invoke-Git `
      -RepositoryRoot $proofRoot `
      -GitArguments @("rev-parse", "HEAD")
    $tamperedValidation = Test-DanioRunnerCompatibility `
      -Manifest $tamperedManifest `
      -RequireLaunchAuthorization `
      -RepositoryRoot $proofRoot
    Assert-Equal `
      -Actual $tamperedValidation.code `
      -Expected "RUNNER_INCOMPATIBLE" `
      -Message "True mutation flag '$mutationName' was accepted."
  }

  foreach ($relativePath in @(
    "apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md",
    "apps/aquarium_app/docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md",
    "apps/aquarium_app/docs/agent/FINISH_MAP.md",
    "apps/aquarium_app/docs/agent/QUALITY_LADDER.md",
    "apps/aquarium_app/docs/agent/VERIFIED_SLICE_EXECUTION_CONTRACT.md",
    "apps/aquarium_app/docs/agent/DEVICE_OWNERSHIP.md",
    "apps/aquarium_app/docs/agent/plans/2026-07-11-phone-complete-local-completion-program.md",
    "apps/aquarium_app/docs/agent/autonomous_completion/runner_compatibility.json"
  )) {
    $sourcePath = Join-Path $repoRoot $relativePath
    $destinationPath = Join-Path $proofRoot $relativePath
    $destinationDirectory = Split-Path -Parent $destinationPath
    New-Item -ItemType Directory -Force -Path $destinationDirectory | Out-Null
    Copy-Item -LiteralPath $sourcePath -Destination $destinationPath -Force
  }
  [void](Invoke-Git -RepositoryRoot $proofRoot -GitArguments @("add", "apps/aquarium_app"))
  [void](Invoke-Git -RepositoryRoot $proofRoot -GitArguments @("commit", "-m", "fixture: authorized manifest without proof object"))
  [void](Invoke-GitWithoutRepository -GitArguments @("init", "--bare", $proofRemoteRoot))
  [void](Invoke-Git -RepositoryRoot $proofRoot -GitArguments @("remote", "add", "origin", $proofRemoteRoot))
  [void](Invoke-Git -RepositoryRoot $proofRoot -GitArguments @("push", "-u", "origin", "main"))
  [void](Invoke-Git -RepositoryRoot $proofRemoteRoot -GitArguments @("symbolic-ref", "HEAD", "refs/heads/main"))
  $rootBindingReceipt = Invoke-Synchronization `
    -ScriptPath $syncScriptPath `
    -RepositoryRoot $proofRoot `
    -InvocationNonce $invocationNonce
  $rootBindingBefore = Get-RepositorySnapshot -RepositoryRoot $proofRoot
  $rootBindingReport = Invoke-Readiness `
    -ScriptPath $readinessScriptPath `
    -RepositoryRoot $proofRoot `
    -InvocationNonce $invocationNonce `
    -Receipt $rootBindingReceipt
  $rootBindingAfter = Get-RepositorySnapshot -RepositoryRoot $proofRoot
  Assert-SnapshotEqual `
    -Before $rootBindingBefore `
    -After $rootBindingAfter `
    -Scenario "target-repository launch proof binding"
  Assert-Equal `
    -Actual $rootBindingReport.stop_reason_code `
    -Expected "RUNNER_INCOMPATIBLE" `
    -Message "Readiness inherited authorization from the module checkout instead of the target repository."

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
  $seedRunnerManifestPath = Join-Path `
    $seedRoot `
    "apps/aquarium_app/docs/agent/autonomous_completion/runner_compatibility.json"
  $seedRunnerManifest = Get-Content -Raw -LiteralPath $seedRunnerManifestPath | ConvertFrom-Json
  $seedRunnerManifest.manifest_revision = 2
  $seedRunnerManifest.authorizes_launch = $false
  $seedRunnerManifest.launch_proof = $null
  Write-FixtureJson -Path $seedRunnerManifestPath -Value $seedRunnerManifest

  [void](Invoke-Git -RepositoryRoot $seedRoot -GitArguments @("add", "apps/aquarium_app"))
  [void](Invoke-Git -RepositoryRoot $seedRoot -GitArguments @("commit", "-m", "fixture: seed Danio authority"))
  [void](Invoke-Git -RepositoryRoot $seedRoot -GitArguments @("remote", "add", "origin", $remoteRoot))
  [void](Invoke-Git -RepositoryRoot $seedRoot -GitArguments @("push", "-u", "origin", "main"))
  [void](Invoke-Git -RepositoryRoot $remoteRoot -GitArguments @("symbolic-ref", "HEAD", "refs/heads/main"))
  [void](Invoke-GitWithoutRepository -GitArguments @("clone", "-c", "core.autocrlf=false", $remoteRoot, $cloneOneRoot))
  [void](Invoke-GitWithoutRepository -GitArguments @("clone", $remoteRoot, $cloneTwoRoot))
  [void](Invoke-Git -RepositoryRoot $cloneTwoRoot -GitArguments @("config", "user.name", "Danio Fixture Two"))
  [void](Invoke-Git -RepositoryRoot $cloneTwoRoot -GitArguments @("config", "user.email", "danio-fixture-two@example.invalid"))

  $linkedSnapshotRoot = Join-Path $tempRoot "linked-snapshot"
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @(
    "worktree",
    "add",
    "-b",
    "fixture-linked-snapshot",
    $linkedSnapshotRoot,
    "main"
  ))
  $linkedSnapshot = Get-RepositorySnapshot -RepositoryRoot $linkedSnapshotRoot
  Assert-Equal `
    -Actual $linkedSnapshot.status `
    -Expected "" `
    -Message "Linked-worktree snapshot should observe a clean checkout."
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("worktree", "remove", $linkedSnapshotRoot))
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("branch", "-D", "fixture-linked-snapshot"))

  $rehearsalReceipt = Invoke-Synchronization `
    -ScriptPath $syncScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -InvocationNonce $invocationNonce
  $rehearsalBefore = Get-RepositorySnapshot -RepositoryRoot $cloneOneRoot
  $rehearsalReport = Invoke-Rehearsal `
    -ScriptPath $rehearsalScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -InvocationNonce $invocationNonce `
    -Receipt $rehearsalReceipt
  $rehearsalAfter = Get-RepositorySnapshot -RepositoryRoot $cloneOneRoot
  Assert-SnapshotEqual -Before $rehearsalBefore -After $rehearsalAfter -Scenario "Task 12 rehearsal"
  Assert-Equal -Actual $rehearsalReport.overall_status -Expected "pass" -Message "Rehearsal report did not pass."
  Assert-Equal -Actual $rehearsalReport.previews.launch.code -Expected "LAUNCH_NOT_AUTHORIZED" -Message "Rehearsal launch code mismatch."
  Assert-Equal -Actual $rehearsalReport.previews.claim.code -Expected "AUTHORITY_CONFLICT" -Message "Rehearsal claim code mismatch."
  Assert-Equal -Actual $rehearsalReport.previews.closeout.code -Expected "AUTHORITY_CONFLICT" -Message "Rehearsal closeout code mismatch."
  foreach ($mutation in @(
    "repository_files",
    "index",
    "local_refs",
    "remote_refs",
    "worktrees",
    "successor_tasks",
    "android_runtime",
    "figma",
    "external_services"
  )) {
    Assert-Equal -Actual $rehearsalReport.mutations.$mutation -Expected $false -Message "Rehearsal mutation '$mutation' was not false."
  }

  Assert-ReadinessNoMutation `
    -SyncScriptPath $syncScriptPath `
    -ReadinessScriptPath $readinessScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -InvocationNonce $invocationNonce `
    -ExpectedStopReason "LAUNCH_NOT_AUTHORIZED" `
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
    -Condition $authorityAfterAdvance.authority_validation.valid `
    -Message "Immutable authority snapshot was invalidated by a later canonical output."
  $unreachableAuthorityState = $authorityState | ConvertTo-Json -Depth 100 | ConvertFrom-Json
  $unreachableAuthorityState.authority.phone_completion_program.commit = ("f" * 40)
  $unreachableAuthority = Get-DanioRepositoryObservation `
    -RepositoryRoot $cloneOneRoot `
    -State $unreachableAuthorityState
  Assert-Equal `
    -Actual $unreachableAuthority.authority_validation.code `
    -Expected "AUTHORITY_CONFLICT" `
    -Message "Unreachable authority snapshot returned the wrong validation code."

  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("config", "user.name", "Danio Fixture One"))
  [void](Invoke-Git -RepositoryRoot $cloneOneRoot -GitArguments @("config", "user.email", "danio-fixture-one@example.invalid"))
  $stateRelativePath = "apps/aquarium_app/docs/agent/autonomous_completion/phone_completion_run_state.json"
  $readyFixturePath = Join-Path $appRoot "test/scripts/fixtures/autonomous_completion/ready_run_state.json"
  $readyState = Get-Content -Raw -LiteralPath $readyFixturePath | ConvertFrom-Json
  $readyState.authorization.saved_project_root = $tempRoot.Replace("\", "/")
  $readyState.authorization.repository_root = $cloneOneRoot.Replace("\", "/")
  $cloneOneStatePath = Join-Path $cloneOneRoot $stateRelativePath
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
  $bindingReadiness = $claimReadiness | ConvertTo-Json -Depth 20 | ConvertFrom-Json
  $bindingReadiness.intent = "Launch"
  $bindingReadiness.checked_at_utc = [DateTimeOffset]::UtcNow.ToString(
    "yyyy-MM-dd'T'HH:mm:ss.fffffff'Z'",
    [Globalization.CultureInfo]::InvariantCulture
  )
  $bindingCapabilities = [pscustomobject][ordered]@{
    list_threads = $true
    read_thread = $true
    "create_thread.project_target" = $true
  }
  $bindingProject = [pscustomobject][ordered]@{
    project_id = "fixture-project"
    root = $tempRoot.Replace("\", "/")
  }
  $exactStateJson = Get-Content -Raw -LiteralPath $cloneOneStatePath
  $bindingBefore = Get-RepositorySnapshot -RepositoryRoot $cloneOneRoot
  $exactBindingReport = Invoke-HandoffPromptGenerator `
    -ScriptPath $handoffScriptPath `
    -PromptKind "Launch" `
    -RunStateJson $exactStateJson `
    -ReadinessReportJson ($bindingReadiness | ConvertTo-Json -Depth 20 -Compress) `
    -TaskCapabilitiesJson ($bindingCapabilities | ConvertTo-Json -Compress) `
    -SavedProjectJson ($bindingProject | ConvertTo-Json -Compress) `
    -RepositoryRoot $cloneOneRoot
  $exactBindingCheck = @($exactBindingReport.checks | Where-Object { $_.code -ceq "LIVE_STATE_BOUND" })
  Assert-Equal -Actual $exactBindingCheck.Count -Expected 1 -Message "Exact binding report lost its live-state check."
  Assert-Equal -Actual $exactBindingCheck[0].status -Expected "pass" -Message "Exact committed live-state bytes were not accepted."
  $whitespaceBindingReport = Invoke-HandoffPromptGenerator `
    -ScriptPath $handoffScriptPath `
    -PromptKind "Launch" `
    -RunStateJson (" " + $exactStateJson) `
    -ReadinessReportJson ($bindingReadiness | ConvertTo-Json -Depth 20 -Compress) `
    -TaskCapabilitiesJson ($bindingCapabilities | ConvertTo-Json -Compress) `
    -SavedProjectJson ($bindingProject | ConvertTo-Json -Compress) `
    -RepositoryRoot $cloneOneRoot
  $whitespaceBindingCheck = @($whitespaceBindingReport.checks | Where-Object { $_.code -ceq "LIVE_STATE_BOUND" })
  Assert-Equal -Actual $whitespaceBindingCheck.Count -Expected 1 -Message "Whitespace binding report lost its live-state check."
  Assert-Equal -Actual $whitespaceBindingCheck[0].status -Expected "fail" -Message "Whitespace-different supplied state passed exact live-state binding."
  $bindingAfter = Get-RepositorySnapshot -RepositoryRoot $cloneOneRoot
  Assert-SnapshotEqual -Before $bindingBefore -After $bindingAfter -Scenario "handoff exact-byte binding"
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

  $cwdReuseFixture = New-ClaimTransactionFixture `
    -Name "cw" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -ClaimPlannerScriptPath $claimPlannerScriptPath
  [void](Invoke-Git `
    -RepositoryRoot $cwdReuseFixture.clone_one `
    -GitArguments @(
      "worktree", "add", "-b",
      $cwdReuseFixture.plan.branch_name,
      $cwdReuseFixture.plan.worktree_path,
      $cwdReuseFixture.base_commit
    ))
  $cwdProcessStart = New-Object Diagnostics.ProcessStartInfo
  $cwdProcessStart.FileName = (Get-Command powershell.exe -ErrorAction Stop).Source
  $cwdProcessStart.Arguments = '-NoProfile -NonInteractive -Command "Start-Sleep -Seconds 90"'
  $cwdProcessStart.WorkingDirectory = $cwdReuseFixture.plan.worktree_path
  $cwdProcessStart.UseShellExecute = $false
  $cwdProcessStart.CreateNoWindow = $true
  $cwdProcess = New-Object Diagnostics.Process
  $cwdProcess.StartInfo = $cwdProcessStart
  $cwdProcessStarted = $false
  try {
    Assert-True -Condition $cwdProcess.Start() -Message "CWD-only fixture process did not start."
    $cwdProcessStarted = $true
    Start-Sleep -Milliseconds 500
    $cwdObservation = Get-CimInstance `
      -ClassName Win32_Process `
      -Filter "ProcessId = $($cwdProcess.Id)" `
      -ErrorAction Stop
    $cwdCommandLine = ([string]$cwdObservation.CommandLine).Replace("\", "/")
    Assert-True `
      -Condition (
        $cwdCommandLine.IndexOf(
          $cwdReuseFixture.plan.worktree_path.Replace("\", "/"),
          [StringComparison]::OrdinalIgnoreCase
        ) -lt 0 -and
        $cwdCommandLine.IndexOf(
          $cwdReuseFixture.plan.branch_name,
          [StringComparison]::OrdinalIgnoreCase
        ) -lt 0
      ) `
      -Message "CWD-only fixture command line unexpectedly exposed the writer identity."
    $cwdReuseInvocation = Invoke-WriterClaim `
      -ScriptPath $claimInvokerScriptPath `
      -RepositoryRoot $cwdReuseFixture.clone_one `
      -ClaimPlan $cwdReuseFixture.plan `
      -TestTransportOutcome "rejected"
    Assert-WriterClaimResult `
      -Invocation $cwdReuseInvocation `
      -Accepted $false `
      -Code "WRITER_IDENTITY_CONFLICT" `
      -Scenario "pre-existing writer identity with cwd-only process" `
      -RequireCandidate $false
    Assert-Equal `
      -Actual $cwdReuseInvocation.result.mutations_performed `
      -Expected $false `
      -Message "CWD-only pre-existing identity was mutated."
    Assert-Equal `
      -Actual $cwdReuseInvocation.result.push_attempt_count `
      -Expected 0 `
      -Message "CWD-only pre-existing identity attempted a push."
  } finally {
    if ($cwdProcessStarted -and -not $cwdProcess.HasExited) {
      $cwdProcess.Kill()
      $cwdProcess.WaitForExit()
    }
    $cwdProcess.Dispose()
  }

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
    -Actual $rejectedInvocation.result.push_rejection_proven `
    -Expected $true `
    -Message "Fixture-only definite rejection did not record its synthetic proof."
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
    -Code "PUSH_OUTCOME_UNKNOWN" `
    -Scenario "unknown not accepted transport"
  Assert-Equal `
    -Actual $unknownNotAcceptedInvocation.result.transport_result `
    -Expected "unknown_not_accepted" `
    -Message "Unknown not accepted transport classification mismatch."
  Assert-Equal `
    -Actual $unknownNotAcceptedInvocation.result.reconciliation_status `
    -Expected "unknown" `
    -Message "Unknown not accepted transport was over-classified."
  Assert-Equal `
    -Actual $unknownNotAcceptedInvocation.result.push_rejection_proven `
    -Expected $false `
    -Message "Unknown not accepted transport fabricated rejection proof."
  Assert-Equal `
    -Actual $unknownNotAcceptedInvocation.result.cleanup_performed `
    -Expected $false `
    -Message "Unknown not accepted claim performed cleanup without proof."
  Assert-Equal `
    -Actual $unknownNotAcceptedInvocation.result.artifacts_preserved `
    -Expected $true `
    -Message "Unknown not accepted claim did not preserve artifacts."
  Assert-Equal `
    -Actual (Test-Path -LiteralPath $unknownNotAcceptedFixture.plan.worktree_path -PathType Container) `
    -Expected $true `
    -Message "Unknown not accepted worktree was removed."
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

  $ambiguousPushFixture = New-ClaimTransactionFixture `
    -Name "af" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -ClaimPlannerScriptPath $claimPlannerScriptPath
  $ambiguousPushShimRoot = Join-Path $ambiguousPushFixture.root "git-shim"
  $ambiguousPushShim = @"
`$captured = @(`$args)
if (@(`$captured | Where-Object { `$_ -ceq 'push' }).Count -eq 1) {
  [Console]::Error.WriteLine('fatal: simulated connection reset after send')
  exit 1
}
& '$fixtureRealGit' @args
exit `$LASTEXITCODE
"@
  Write-FixtureScript `
    -Path (Join-Path $ambiguousPushShimRoot "git.ps1") `
    -Content $ambiguousPushShim
  $ambiguousPushInvocation = Invoke-WriterClaim `
    -ScriptPath $claimInvokerScriptPath `
    -RepositoryRoot $ambiguousPushFixture.clone_one `
    -ClaimPlan $ambiguousPushFixture.plan `
    -TestTransportOutcome "accepted" `
    -GitShimDirectory $ambiguousPushShimRoot
  Assert-WriterClaimResult `
    -Invocation $ambiguousPushInvocation `
    -Accepted $false `
    -Code "PUSH_OUTCOME_UNKNOWN" `
    -Scenario "ambiguous completed push failure"
  Assert-Equal `
    -Actual $ambiguousPushInvocation.result.cleanup_performed `
    -Expected $false `
    -Message "Ambiguous completed push failure performed cleanup."
  Assert-Equal `
    -Actual $ambiguousPushInvocation.result.artifacts_preserved `
    -Expected $true `
    -Message "Ambiguous completed push failure did not preserve artifacts."
  Assert-Equal `
    -Actual $ambiguousPushInvocation.result.push_attempt_count `
    -Expected 1 `
    -Message "Ambiguous completed push failure did not attempt exactly one push."
  Assert-True `
    -Condition (Test-Path -LiteralPath $ambiguousPushFixture.plan.worktree_path -PathType Container) `
    -Message "Ambiguous completed push failure removed the worktree."
  Assert-True `
    -Condition (Test-GitRefExists `
      -RepositoryRoot $ambiguousPushFixture.clone_one `
      -RefName "refs/heads/$($ambiguousPushFixture.plan.branch_name)") `
    -Message "Ambiguous completed push failure removed the branch."
  Assert-Equal `
    -Actual (Invoke-Git `
      -RepositoryRoot $ambiguousPushFixture.remote `
      -GitArguments @("rev-parse", "refs/heads/main")) `
    -Expected $ambiguousPushFixture.base_commit `
    -Message "Ambiguous completed push fixture unexpectedly moved the remote."
  $ambiguousPushState = Read-RemoteRunState `
    -RepositoryRoot $ambiguousPushFixture.clone_one `
    -StatePath $ambiguousPushFixture.state_path
  Assert-ClaimBudgetUnchanged `
    -BeforeState $ambiguousPushFixture.ready_state `
    -AfterState $ambiguousPushState `
    -Scenario "ambiguous completed push failure"

  $stderrRejectionFixture = New-ClaimTransactionFixture `
    -Name "sr" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -ClaimPlannerScriptPath $claimPlannerScriptPath
  $stderrRejectionShimRoot = Join-Path $stderrRejectionFixture.root "git-shim"
  $stderrRejectionShim = @"
`$captured = @(`$args)
if (@(`$captured | Where-Object { `$_ -ceq 'push' }).Count -eq 1) {
  [Console]::Error.WriteLine("!`tHEAD:refs/heads/main`t[rejected] (fetch first)")
  exit 1
}
& '$fixtureRealGit' @args
exit `$LASTEXITCODE
"@
  Write-FixtureScript `
    -Path (Join-Path $stderrRejectionShimRoot "git.ps1") `
    -Content $stderrRejectionShim
  $stderrRejectionInvocation = Invoke-WriterClaim `
    -ScriptPath $claimInvokerScriptPath `
    -RepositoryRoot $stderrRejectionFixture.clone_one `
    -ClaimPlan $stderrRejectionFixture.plan `
    -TestTransportOutcome "accepted" `
    -GitShimDirectory $stderrRejectionShimRoot
  Assert-WriterClaimResult `
    -Invocation $stderrRejectionInvocation `
    -Accepted $false `
    -Code "PUSH_OUTCOME_UNKNOWN" `
    -Scenario "rejection-looking stderr transport failure"
  Assert-Equal `
    -Actual $stderrRejectionInvocation.result.push_rejection_proven `
    -Expected $false `
    -Message "Rejection-looking stderr was treated as porcelain proof."
  Assert-Equal `
    -Actual $stderrRejectionInvocation.result.cleanup_performed `
    -Expected $false `
    -Message "Rejection-looking stderr transport failure performed cleanup."
  Assert-Equal `
    -Actual $stderrRejectionInvocation.result.artifacts_preserved `
    -Expected $true `
    -Message "Rejection-looking stderr transport failure did not preserve artifacts."
  Assert-True `
    -Condition (Test-Path -LiteralPath $stderrRejectionFixture.plan.worktree_path -PathType Container) `
    -Message "Rejection-looking stderr transport failure removed the worktree."
  Assert-True `
    -Condition (Test-GitRefExists `
      -RepositoryRoot $stderrRejectionFixture.clone_one `
      -RefName "refs/heads/$($stderrRejectionFixture.plan.branch_name)") `
    -Message "Rejection-looking stderr transport failure removed the branch."
  $stderrRejectionState = Read-RemoteRunState `
    -RepositoryRoot $stderrRejectionFixture.clone_one `
    -StatePath $stderrRejectionFixture.state_path
  Assert-ClaimBudgetUnchanged `
    -BeforeState $stderrRejectionFixture.ready_state `
    -AfterState $stderrRejectionState `
    -Scenario "rejection-looking stderr transport failure"

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
    -Message "Two-clone race loser did not clean up its exact identity: $($secondRaceInvocation.result.details -join '; ')"
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

  $closeoutFixture = New-TransitionTransactionFixture `
    -Name "closeout-accepted" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "closeout"
  $closeoutInvocation = Invoke-CompletionTransition `
    -ScriptPath $transitionCommitScriptPath `
    -Fixture $closeoutFixture `
    -TestTransportOutcome "accepted"
  Assert-True `
    -Condition $closeoutInvocation.result.accepted `
    -Message "Ordinary closeout was not accepted: $($closeoutInvocation.result | ConvertTo-Json -Depth 20 -Compress)"
  Assert-Equal -Actual $closeoutInvocation.result.code -Expected "TRANSITION_COMMITTED" -Message "Ordinary closeout result code mismatch."
  Assert-Equal -Actual $closeoutInvocation.result.push_attempt_count -Expected 1 -Message "Ordinary closeout did not attempt exactly one push."
  Assert-Equal -Actual $closeoutInvocation.result.retry_performed -Expected $false -Message "Ordinary closeout retried its push."
  Assert-Equal -Actual $closeoutInvocation.result.candidate_charge_consumed -Expected $true -Message "Ordinary closeout did not consume its candidate charge."
  Assert-Equal -Actual $closeoutInvocation.result.durable_charge_consumption_proven -Expected $true -Message "Ordinary closeout charge was not proven durable."
  Assert-Equal -Actual $closeoutInvocation.result.owner_released -Expected $true -Message "Ordinary closeout retained its owner."
  Assert-Equal -Actual $closeoutInvocation.result.owned_cleanup_proven -Expected $true -Message "Ordinary closeout cleanup was unproven."
  Assert-Equal -Actual $closeoutFixture.owner_existed_before_cleanup -Expected $true -Message "Ordinary closeout never held its exact physical owner."
  Assert-Equal -Actual $closeoutFixture.owner_checkpoint_aligned -Expected $true -Message "Evidence checkpoint was not aligned while the owner remained active."
  Assert-Equal -Actual $closeoutFixture.owner_cleanup_performed -Expected $true -Message "Ordinary closeout did not perform phase-two owner cleanup."
  $expectedTransitionFields = @(
    "document_type", "schema_version", "completed_at_utc", "accepted", "code", "details",
    "transition_action", "from_mode", "to_mode", "run_id", "work_unit_id",
    "expected_state_revision", "candidate_state_revision", "evidence_manifest_path",
    "owner_token_sha256", "mutations_performed", "push_attempted", "push_attempt_count",
    "push_timed_out", "push_termination_confirmed", "push_rejection_proven", "retry_performed",
    "reconciliation_status", "candidate_charge_consumed", "durable_charge_consumption_proven",
    "owner_retained", "owner_released", "owned_cleanup_proven", "artifacts_preserved",
    "candidate_commit", "staged_tree_hash", "origin_main_commit", "test_transport_outcome"
  )
  $observedTransitionFields = @($closeoutInvocation.result.PSObject.Properties | ForEach-Object { $_.Name })
  Assert-Equal -Actual $observedTransitionFields.Count -Expected $expectedTransitionFields.Count -Message "Transition result field count drifted."
  Assert-Equal `
    -Actual @($observedTransitionFields | Where-Object { $expectedTransitionFields -cnotcontains $_ }).Count `
    -Expected 0 `
    -Message "Transition result contains unknown fields."
  $closeoutParent = Invoke-Git -RepositoryRoot $closeoutFixture.clone -GitArguments @("rev-parse", "$($closeoutInvocation.result.candidate_commit)^")
  Assert-Equal -Actual $closeoutParent -Expected $closeoutFixture.evidence_commit -Message "State closeout did not follow the evidence checkpoint."
  $closeoutRemoteState = Read-RemoteRunState -RepositoryRoot $closeoutFixture.clone -StatePath $closeoutFixture.state_path
  Assert-Equal -Actual $closeoutRemoteState.mode -Expected "handoff_ready" -Message "Ordinary closeout did not reach handoff_ready."
  Assert-Equal -Actual $closeoutRemoteState.budget.consumed_units -Expected ([int64]$closeoutFixture.previous_state.budget.consumed_units + 1) -Message "Ordinary closeout did not consume exactly once."
  Assert-Equal -Actual $closeoutRemoteState.handoff_generation -Expected ([int64]$closeoutFixture.previous_state.handoff_generation + 1) -Message "Ordinary closeout did not advance generation once."
  $closeoutParentState = Invoke-Git -RepositoryRoot $closeoutFixture.clone -GitArguments @("show", "$($closeoutFixture.evidence_commit):$($closeoutFixture.state_path)") | ConvertFrom-Json
  Assert-Equal -Actual $closeoutParentState.mode -Expected "active" -Message "Evidence checkpoint released ownership too early."

  $pauseFixture = New-TransitionTransactionFixture `
    -Name "pause-accepted" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "pause"
  $pauseInvocation = Invoke-CompletionTransition `
    -ScriptPath $transitionCommitScriptPath `
    -Fixture $pauseFixture `
    -TestTransportOutcome "accepted"
  Assert-True -Condition $pauseInvocation.result.accepted -Message "Paused closeout was not accepted."
  $pauseState = Read-RemoteRunState -RepositoryRoot $pauseFixture.clone -StatePath $pauseFixture.state_path
  Assert-Equal -Actual $pauseState.mode -Expected "paused" -Message "Paused closeout mode mismatch."
  Assert-Equal -Actual $pauseState.budget.consumed_units -Expected ([int64]$pauseFixture.previous_state.budget.consumed_units + 1) -Message "Paused closeout did not consume once."
  Assert-Equal -Actual $pauseFixture.owner_existed_before_cleanup -Expected $true -Message "Paused closeout never held its exact physical owner."
  Assert-Equal -Actual $pauseFixture.owner_cleanup_performed -Expected $true -Message "Paused closeout did not clean its exact owner."

  $lastUnitFixture = New-TransitionTransactionFixture `
    -Name "last-budget-stop" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "stop" `
    -LastBudgetUnit
  $lastUnitInvocation = Invoke-CompletionTransition `
    -ScriptPath $transitionCommitScriptPath `
    -Fixture $lastUnitFixture `
    -TestTransportOutcome "accepted"
  Assert-True -Condition $lastUnitInvocation.result.accepted -Message "Budget-one normal closeout stop was not accepted."
  $lastUnitState = Read-RemoteRunState -RepositoryRoot $lastUnitFixture.clone -StatePath $lastUnitFixture.state_path
  Assert-Equal -Actual $lastUnitState.mode -Expected "stopped" -Message "Budget-one closeout did not stop."
  Assert-Equal -Actual $lastUnitState.budget.remaining_units_including_current -Expected 0 -Message "Budget-one stop did not reach zero."
  Assert-Equal -Actual $lastUnitState.budget.consumed_units -Expected 20 -Message "Budget-one stop did not consume exactly once."
  Assert-Equal -Actual $lastUnitState.handoff_generation -Expected $lastUnitFixture.previous_state.handoff_generation -Message "Budget-one stop exposed a successor generation."
  Assert-Equal -Actual $lastUnitState.transition.reason_code -Expected "BUDGET_EXHAUSTED" -Message "Budget-one normal closeout used the wrong stop reason."
  Assert-Equal -Actual $lastUnitState.last_verified_checkpoint.evidence_manifest_path -Expected $lastUnitFixture.manifest_path -Message "Budget-one normal closeout did not advance evidence."
  $lastUnitMessage = Invoke-Git -RepositoryRoot $lastUnitFixture.clone -GitArguments @("log", "-1", "--format=%B", $lastUnitInvocation.result.candidate_commit)
  Assert-True -Condition ($lastUnitMessage -match "(?m)^Danio-Evidence-Manifest: $([regex]::Escape($lastUnitFixture.manifest_path))$") -Message "Budget-one evidence trailer is not path-exact."

  $emergencyFixture = New-TransitionTransactionFixture `
    -Name "emergency-stop-accepted" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "stop"
  $emergencyInvocation = Invoke-CompletionTransition `
    -ScriptPath $transitionCommitScriptPath `
    -Fixture $emergencyFixture `
    -TestTransportOutcome "accepted"
  Assert-True -Condition $emergencyInvocation.result.accepted -Message "Emergency stopped closeout was not accepted."
  $emergencyState = Read-RemoteRunState -RepositoryRoot $emergencyFixture.clone -StatePath $emergencyFixture.state_path
  Assert-Equal -Actual $emergencyState.mode -Expected "stopped" -Message "Emergency closeout did not stop."
  Assert-Equal -Actual $emergencyState.last_verified_checkpoint -Expected $null -Message "Emergency closeout invented a checkpoint."
  $emergencyMessage = Invoke-Git -RepositoryRoot $emergencyFixture.clone -GitArguments @("log", "-1", "--format=%B", $emergencyInvocation.result.candidate_commit)
  Assert-True -Condition ($emergencyMessage -match '(?m)^Danio-Evidence-Manifest: none$') -Message "Emergency null-manifest trailer is missing."

  $unsafeFixture = New-TransitionTransactionFixture `
    -Name "unsafe-release" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "stop"
  $unsafeOwnerRoot = Split-Path -Parent ([string]$unsafeFixture.previous_state.owner.worktree_path)
  New-Item -ItemType Directory -Force -Path $unsafeOwnerRoot | Out-Null
  [void](Invoke-Git -RepositoryRoot $unsafeFixture.clone -GitArguments @(
    "worktree", "add", "-b", [string]$unsafeFixture.previous_state.owner.branch_name,
    [string]$unsafeFixture.previous_state.owner.worktree_path, [string]$unsafeFixture.evidence_commit
  ))
  $unsafeBefore = Get-RepositorySnapshot -RepositoryRoot $unsafeFixture.clone
  $unsafeInvocation = Invoke-CompletionTransition `
    -ScriptPath $transitionCommitScriptPath `
    -Fixture $unsafeFixture `
    -TestTransportOutcome "accepted"
  $unsafeAfter = Get-RepositorySnapshot -RepositoryRoot $unsafeFixture.clone
  Assert-SnapshotEqual -Before $unsafeBefore -After $unsafeAfter -Scenario "unsafe lease release"
  Assert-Equal -Actual $unsafeInvocation.result.code -Expected "STOP_PENDING" -Message "Unsafe release did not return STOP_PENDING."
  Assert-Equal -Actual $unsafeInvocation.result.mutations_performed -Expected $false -Message "STOP_PENDING mutated candidate state."
  Assert-Equal -Actual $unsafeInvocation.result.candidate_commit -Expected $null -Message "STOP_PENDING created a candidate commit."
  Assert-Equal -Actual $unsafeInvocation.result.owner_retained -Expected $true -Message "STOP_PENDING lost durable owner retention."
  Assert-Equal -Actual $unsafeInvocation.result.owner_released -Expected $false -Message "STOP_PENDING claimed durable owner release."
  [void](Invoke-Git -RepositoryRoot $unsafeFixture.clone -GitArguments @("worktree", "remove", [string]$unsafeFixture.previous_state.owner.worktree_path))
  [void](Invoke-Git -RepositoryRoot $unsafeFixture.clone -GitArguments @("branch", "-D", [string]$unsafeFixture.previous_state.owner.branch_name))

  $finalizeFixture = New-TransitionTransactionFixture `
    -Name "finalize-accepted" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "finalize"
  $finalizeInvocation = Invoke-CompletionTransition `
    -ScriptPath $transitionCommitScriptPath `
    -Fixture $finalizeFixture `
    -TestTransportOutcome "accepted"
  Assert-True -Condition $finalizeInvocation.result.accepted -Message "active to finalizing was not accepted."
  Assert-Equal -Actual $finalizeInvocation.result.candidate_charge_consumed -Expected $true -Message "Finalization entry did not consume once."
  Assert-Equal -Actual $finalizeInvocation.result.owner_retained -Expected $true -Message "Finalization entry released its owner."
  Assert-Equal -Actual $finalizeInvocation.result.owned_cleanup_proven -Expected $false -Message "Finalization entry claimed cleanup."
  Assert-Equal -Actual $finalizeFixture.owner_existed_before_cleanup -Expected $true -Message "Finalization entry lacked its exact physical owner."
  Assert-Equal -Actual $finalizeFixture.owner_checkpoint_aligned -Expected $true -Message "Finalization evidence parent was not aligned with the retained owner."
  Assert-Equal -Actual $finalizeFixture.owner_cleanup_performed -Expected $false -Message "Finalization entry cleaned its retained owner."
  $finalizingState = Read-RemoteRunState -RepositoryRoot $finalizeFixture.clone -StatePath $finalizeFixture.state_path
  Assert-Equal -Actual $finalizingState.mode -Expected "finalizing" -Message "Finalization entry mode mismatch."
  Assert-Equal -Actual (Invoke-Git -RepositoryRoot $finalizeFixture.previous_state.owner.worktree_path -GitArguments @("rev-parse", "HEAD")) -Expected $finalizeInvocation.result.candidate_commit -Message "Retained owner did not fast-forward to finalizing state."
  $revalidatedFinalize = Invoke-TransitionValidation `
    -ScriptPath $transitionScriptPath `
    -RepositoryRoot $finalizeFixture.clone `
    -Source "Committed" `
    -ExpectedParentCommit $finalizeFixture.evidence_commit `
    -ExpectedStagedTreeHash $finalizeInvocation.result.staged_tree_hash `
    -Commit $finalizeInvocation.result.candidate_commit `
    -EvidenceManifestPath $finalizeFixture.manifest_path
  Assert-True -Condition $revalidatedFinalize.valid -Message "Committed finalize did not revalidate after retained-owner alignment."

  $completeFixture = New-TransitionTransactionFixture `
    -Name "complete-accepted" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "complete"
  [void](Invoke-Git -RepositoryRoot $completeFixture.clone -GitArguments @(
    "restore", "--", $completeFixture.handoff_path, $completeFixture.slice_log_path
  ))
  $finalizationNonce = "abcdef0123456789abcdef0123456789"
  $finalizationReceipt = Invoke-Synchronization `
    -ScriptPath $syncScriptPath `
    -RepositoryRoot $completeFixture.clone `
    -InvocationNonce $finalizationNonce
  $finalizationReadiness = Invoke-FinalizationReadiness `
    -ScriptPath $readinessScriptPath `
    -Fixture $completeFixture `
    -InvocationNonce $finalizationNonce `
    -Receipt $finalizationReceipt `
    -LeaseRelease $completeFixture.lease_release
  Assert-True `
    -Condition $finalizationReadiness.eligible `
    -Message "Committed final evidence and exact release proof were not Finalization-ready: $($finalizationReadiness | ConvertTo-Json -Depth 20 -Compress)"
  $wrongFinalizationRelease = $completeFixture.lease_release | ConvertTo-Json -Depth 20 | ConvertFrom-Json
  $wrongFinalizationRelease.owner_token = ("0" * 64)
  $wrongOwnerReadiness = Invoke-FinalizationReadiness `
    -ScriptPath $readinessScriptPath `
    -Fixture $completeFixture `
    -InvocationNonce $finalizationNonce `
    -Receipt $finalizationReceipt `
    -LeaseRelease $wrongFinalizationRelease
  Assert-Equal -Actual $wrongOwnerReadiness.stop_reason_code -Expected "COMPLETION_NOT_READY" -Message "Wrong-owner Finalization proof did not fail closed."
  $missingReleaseReadiness = Invoke-FinalizationReadiness `
    -ScriptPath $readinessScriptPath `
    -Fixture $completeFixture `
    -InvocationNonce $finalizationNonce `
    -Receipt $finalizationReceipt `
    -LeaseRelease $null
  Assert-Equal -Actual $missingReleaseReadiness.stop_reason_code -Expected "COMPLETION_NOT_READY" -Message "Missing Finalization release proof did not fail closed."
  [IO.File]::AppendAllText((Join-Path $completeFixture.clone $completeFixture.handoff_path), "closeout update`n")
  [IO.File]::AppendAllText((Join-Path $completeFixture.clone $completeFixture.slice_log_path), "slice update`n")
  $completeInvocation = Invoke-CompletionTransition `
    -ScriptPath $transitionCommitScriptPath `
    -Fixture $completeFixture `
    -TestTransportOutcome "accepted"
  Assert-True -Condition $completeInvocation.result.accepted -Message "finalizing to complete was not accepted."
  Assert-Equal -Actual $completeInvocation.result.candidate_charge_consumed -Expected $false -Message "Terminal completion charged twice."
  Assert-Equal -Actual $completeInvocation.result.durable_charge_consumption_proven -Expected $true -Message "Previously consumed finalization charge was not proven."
  Assert-Equal -Actual $completeInvocation.result.owner_released -Expected $true -Message "Terminal completion retained its owner."
  Assert-Equal -Actual $completeFixture.owner_existed_before_cleanup -Expected $true -Message "Terminal completion never held its exact owner before cleanup."
  Assert-Equal -Actual $completeFixture.owner_cleanup_performed -Expected $true -Message "Terminal completion did not clean its exact owner."
  $completeState = Read-RemoteRunState -RepositoryRoot $completeFixture.clone -StatePath $completeFixture.state_path
  Assert-Equal -Actual $completeState.mode -Expected "complete" -Message "Terminal completion mode mismatch."
  Assert-Equal -Actual $completeState.budget.consumed_units -Expected $completeFixture.previous_state.budget.consumed_units -Message "Terminal completion consumed a second unit."

  $rejectedCompleteFixture = New-TransitionTransactionFixture `
    -Name "complete-rejected" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "complete"
  $rejectedCompleteInvocation = Invoke-CompletionTransition `
    -ScriptPath $transitionCommitScriptPath `
    -Fixture $rejectedCompleteFixture `
    -TestTransportOutcome "rejected"
  Assert-Equal -Actual $rejectedCompleteInvocation.result.code -Expected "REMOTE_MOVED" -Message "Rejected terminal transition classification mismatch."
  Assert-Equal -Actual $rejectedCompleteInvocation.result.candidate_charge_consumed -Expected $false -Message "Rejected terminal transition charged twice."
  Assert-Equal -Actual $rejectedCompleteInvocation.result.durable_charge_consumption_proven -Expected $true -Message "Rejected terminal transition lost prior charge proof."
  Assert-Equal -Actual $rejectedCompleteInvocation.result.push_attempt_count -Expected 0 -Message "Injected rejection attempted a push."
  Assert-Equal -Actual $rejectedCompleteInvocation.result.retry_performed -Expected $false -Message "Rejected terminal transition retried."
  Assert-Equal -Actual $rejectedCompleteInvocation.result.owner_retained -Expected $true -Message "Rejected terminal transition did not preserve durable owner truth."
  Assert-Equal -Actual $rejectedCompleteInvocation.result.owner_released -Expected $false -Message "Rejected terminal transition claimed durable owner release."
  Assert-True -Condition (-not [string]::IsNullOrWhiteSpace([string]$rejectedCompleteInvocation.result.candidate_commit)) -Message "Rejected terminal candidate was not preserved."
  $rejectedRemoteState = Read-RemoteRunState -RepositoryRoot $rejectedCompleteFixture.clone -StatePath $rejectedCompleteFixture.state_path
  Assert-Equal -Actual $rejectedRemoteState.mode -Expected "finalizing" -Message "Rejected terminal candidate reached origin/main."
  $rejectedLocalState = Invoke-Git -RepositoryRoot $rejectedCompleteFixture.clone -GitArguments @("show", "$($rejectedCompleteInvocation.result.candidate_commit):$($rejectedCompleteFixture.state_path)") | ConvertFrom-Json
  Assert-Equal -Actual $rejectedLocalState.mode -Expected "complete" -Message "Rejected terminal candidate artifact is missing."

  $finalizationStopFixture = New-TransitionTransactionFixture `
    -Name "finalization-stop-accepted" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "finalization_stop"
  $finalizationStopInvocation = Invoke-CompletionTransition `
    -ScriptPath $transitionCommitScriptPath `
    -Fixture $finalizationStopFixture `
    -TestTransportOutcome "accepted"
  Assert-True -Condition $finalizationStopInvocation.result.accepted -Message "Finalization failure stop was not accepted."
  Assert-Equal -Actual $finalizationStopInvocation.result.candidate_charge_consumed -Expected $false -Message "Finalization failure consumed a second unit."
  Assert-Equal -Actual $finalizationStopInvocation.result.durable_charge_consumption_proven -Expected $true -Message "Finalization failure lost the prior consumed charge."
  Assert-Equal -Actual $finalizationStopInvocation.result.owner_released -Expected $true -Message "Finalization failure retained durable ownership."
  $finalizationStoppedState = Read-RemoteRunState -RepositoryRoot $finalizationStopFixture.clone -StatePath $finalizationStopFixture.state_path
  Assert-Equal -Actual $finalizationStoppedState.mode -Expected "stopped" -Message "Finalization failure did not stop."
  Assert-Equal -Actual $finalizationStoppedState.last_verified_checkpoint.evidence_manifest_path -Expected $finalizationStopFixture.manifest_path -Message "Finalization failure did not preserve historical evidence."
  $finalizationStopMessage = Invoke-Git -RepositoryRoot $finalizationStopFixture.clone -GitArguments @("log", "-1", "--format=%B", $finalizationStopInvocation.result.candidate_commit)
  Assert-True -Condition ($finalizationStopMessage -match "(?m)^Danio-Evidence-Manifest: $([regex]::Escape($finalizationStopFixture.manifest_path))$") -Message "Finalization failure trailer did not preserve exact historical evidence."

  $docsFailureFixture = New-TransitionTransactionFixture `
    -Name "docs-profile-failure" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "closeout" `
    -FailDocsProfile
  $docsFailureInvocation = Invoke-CompletionTransition `
    -ScriptPath $transitionCommitScriptPath `
    -Fixture $docsFailureFixture `
    -TestTransportOutcome "accepted"
  Assert-Equal -Actual $docsFailureInvocation.result.code -Expected "DOCS_PROFILE_FAILED" -Message "Failing Docs profile returned the wrong stable code."
  Assert-Equal -Actual $docsFailureInvocation.result.push_attempted -Expected $false -Message "Failing Docs profile attempted a push."
  Assert-Equal -Actual $docsFailureInvocation.result.candidate_commit -Expected $null -Message "Failing Docs profile created a commit."
  Assert-Equal -Actual $docsFailureInvocation.result.artifacts_preserved -Expected $true -Message "Failing Docs profile discarded staged recovery artifacts."
  Assert-Equal -Actual (Invoke-Git -RepositoryRoot $docsFailureFixture.clone -GitArguments @("rev-parse", "HEAD")) -Expected $docsFailureFixture.evidence_commit -Message "Failing Docs profile moved local HEAD."
  Assert-Equal -Actual (Invoke-Git -RepositoryRoot $docsFailureFixture.clone -GitArguments @("rev-parse", "origin/main")) -Expected $docsFailureFixture.evidence_commit -Message "Failing Docs profile moved origin/main."
  $docsFailureStagedPaths = @((Invoke-Git -RepositoryRoot $docsFailureFixture.clone -GitArguments @("diff", "--cached", "--name-only", "--")) -split "`r?`n")
  Assert-Equal -Actual $docsFailureStagedPaths.Count -Expected 3 -Message "Failing Docs profile did not preserve the exact staged recovery scope."
  foreach ($expectedStagedPath in @($docsFailureFixture.state_path, $docsFailureFixture.handoff_path, $docsFailureFixture.slice_log_path)) {
    Assert-True -Condition ($docsFailureStagedPaths -ccontains $expectedStagedPath) -Message "Failing Docs profile lost staged path '$expectedStagedPath'."
  }
  $docsFailureIndexedState = Invoke-Git -RepositoryRoot $docsFailureFixture.clone -GitArguments @("show", ":$($docsFailureFixture.state_path)") | ConvertFrom-Json
  Assert-Equal -Actual $docsFailureIndexedState.transition.action -Expected "closeout" -Message "Failing Docs profile did not preserve candidate state in the index."

  $missingManifestFixture = New-TransitionTransactionFixture `
    -Name "missing-manifest" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "closeout"
  [void](Invoke-Git -RepositoryRoot $missingManifestFixture.clone -GitArguments @("rm", "--", $missingManifestFixture.manifest_path))
  [void](Invoke-Git -RepositoryRoot $missingManifestFixture.clone -GitArguments @("commit", "-m", "fixture: remove transition manifest"))
  [void](Update-TransitionFixtureEvidenceParent -Fixture $missingManifestFixture)
  $missingManifestInvocation = Invoke-CompletionTransition `
    -ScriptPath $transitionCommitScriptPath `
    -Fixture $missingManifestFixture `
    -TestTransportOutcome "accepted"
  Assert-Equal -Actual $missingManifestInvocation.result.code -Expected "EVIDENCE_MANIFEST_INVALID" -Message "Missing committed manifest escaped its stable evidence code."

  $malformedManifestFixture = New-TransitionTransactionFixture `
    -Name "malformed-manifest" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "closeout"
  Write-FixtureScript -Path (Join-Path $malformedManifestFixture.clone $malformedManifestFixture.manifest_path) -Content "{"
  [void](Invoke-Git -RepositoryRoot $malformedManifestFixture.clone -GitArguments @("add", "--", $malformedManifestFixture.manifest_path))
  [void](Invoke-Git -RepositoryRoot $malformedManifestFixture.clone -GitArguments @("commit", "-m", "fixture: corrupt transition manifest"))
  [void](Update-TransitionFixtureEvidenceParent -Fixture $malformedManifestFixture)
  $malformedManifestInvocation = Invoke-CompletionTransition `
    -ScriptPath $transitionCommitScriptPath `
    -Fixture $malformedManifestFixture `
    -TestTransportOutcome "accepted"
  Assert-Equal -Actual $malformedManifestInvocation.result.code -Expected "EVIDENCE_MANIFEST_INVALID" -Message "Malformed committed manifest escaped its stable evidence code."

  $unsafeArtifactFixture = New-TransitionTransactionFixture `
    -Name "unsafe-artifact-path" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "closeout"
  $unsafeArtifactManifest = Invoke-Git `
    -RepositoryRoot $unsafeArtifactFixture.clone `
    -GitArguments @("show", "HEAD:$($unsafeArtifactFixture.manifest_path)") | ConvertFrom-Json
  $unsafeArtifactManifest.artifacts[0].path = "apps/aquarium_app/docs/agent/autonomous_completion/proof;unsafe.txt"
  Write-FixtureJson `
    -Path (Join-Path $unsafeArtifactFixture.clone $unsafeArtifactFixture.manifest_path) `
    -Value $unsafeArtifactManifest
  [void](Invoke-Git -RepositoryRoot $unsafeArtifactFixture.clone -GitArguments @("add", "--", $unsafeArtifactFixture.manifest_path))
  [void](Invoke-Git -RepositoryRoot $unsafeArtifactFixture.clone -GitArguments @("commit", "-m", "fixture: inject unsafe artifact path"))
  [void](Update-TransitionFixtureEvidenceParent -Fixture $unsafeArtifactFixture)
  $unsafeArtifactInvocation = Invoke-CompletionTransition `
    -ScriptPath $transitionCommitScriptPath `
    -Fixture $unsafeArtifactFixture `
    -TestTransportOutcome "accepted"
  Assert-Equal -Actual $unsafeArtifactInvocation.result.code -Expected "EVIDENCE_MANIFEST_INVALID" -Message "Unsafe artifact path reached transition probing."

  $preOwnerProductFixture = New-TransitionTransactionFixture `
    -Name "pre-owner-product" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "closeout"
  $preOwnerManifest = Invoke-Git -RepositoryRoot $preOwnerProductFixture.clone -GitArguments @("show", "HEAD:$($preOwnerProductFixture.manifest_path)") | ConvertFrom-Json
  $oldPreOwnerManifestPath = [string]$preOwnerProductFixture.manifest_path
  $preOwnerManifest.product_commit = [string]$preOwnerProductFixture.historical_product_commit
  $preOwnerManifest.artifacts[0].path = [string]$preOwnerProductFixture.historical_artifact_path
  $preOwnerManifest.artifacts[0].sha256 = [string]$preOwnerProductFixture.historical_artifact_sha256
  $preOwnerManifestPath = "apps/aquarium_app/docs/agent/autonomous_completion/evidence/$($preOwnerProductFixture.historical_product_commit).json"
  Remove-Item -LiteralPath (Join-Path $preOwnerProductFixture.clone $oldPreOwnerManifestPath)
  Write-FixtureJson -Path (Join-Path $preOwnerProductFixture.clone $preOwnerManifestPath) -Value $preOwnerManifest
  [void](Invoke-Git -RepositoryRoot $preOwnerProductFixture.clone -GitArguments @("add", "-A", "apps/aquarium_app/docs/agent/autonomous_completion/evidence"))
  [void](Invoke-Git -RepositoryRoot $preOwnerProductFixture.clone -GitArguments @("commit", "-m", "fixture: reuse pre-owner product proof"))
  $preOwnerProductFixture.product_commit = [string]$preOwnerProductFixture.historical_product_commit
  $preOwnerProductFixture.manifest_path = $preOwnerManifestPath
  $preOwnerProductFixture.candidate_state.last_verified_checkpoint.product_commit = [string]$preOwnerProductFixture.historical_product_commit
  $preOwnerProductFixture.candidate_state.last_verified_checkpoint.evidence_manifest_path = $preOwnerManifestPath
  [void](Update-TransitionFixtureEvidenceParent -Fixture $preOwnerProductFixture)
  $preOwnerProductInvocation = Invoke-CompletionTransition `
    -ScriptPath $transitionCommitScriptPath `
    -Fixture $preOwnerProductFixture `
    -TestTransportOutcome "accepted"
  Assert-Equal -Actual $preOwnerProductInvocation.result.code -Expected "EVIDENCE_MANIFEST_INVALID" -Message "Pre-owner product evidence was accepted as a new owned checkpoint."

  $unreachableProductFixture = New-TransitionTransactionFixture `
    -Name "unreachable-product" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "closeout"
  $sideWorktree = Join-Path $unreachableProductFixture.root "invalid-side-worktree"
  [void](Invoke-Git -RepositoryRoot $unreachableProductFixture.clone -GitArguments @("worktree", "add", "-b", "invalid-side-proof", $sideWorktree, $unreachableProductFixture.product_commit))
  [void](Invoke-Git -RepositoryRoot $sideWorktree -GitArguments @("commit", "--allow-empty", "-m", "fixture: unreachable product proof"))
  $sideProductCommit = Invoke-Git -RepositoryRoot $sideWorktree -GitArguments @("rev-parse", "HEAD")
  [void](Invoke-Git -RepositoryRoot $unreachableProductFixture.clone -GitArguments @("worktree", "remove", "--", $sideWorktree))
  [void](Invoke-Git -RepositoryRoot $unreachableProductFixture.clone -GitArguments @("branch", "-D", "invalid-side-proof"))
  $unreachableManifest = Invoke-Git -RepositoryRoot $unreachableProductFixture.clone -GitArguments @("show", "HEAD:$($unreachableProductFixture.manifest_path)") | ConvertFrom-Json
  $oldUnreachableManifestPath = [string]$unreachableProductFixture.manifest_path
  $unreachableManifest.product_commit = $sideProductCommit
  $unreachableManifestPath = "apps/aquarium_app/docs/agent/autonomous_completion/evidence/$sideProductCommit.json"
  Remove-Item -LiteralPath (Join-Path $unreachableProductFixture.clone $oldUnreachableManifestPath)
  Write-FixtureJson -Path (Join-Path $unreachableProductFixture.clone $unreachableManifestPath) -Value $unreachableManifest
  [void](Invoke-Git -RepositoryRoot $unreachableProductFixture.clone -GitArguments @("add", "-A", "apps/aquarium_app/docs/agent/autonomous_completion/evidence"))
  [void](Invoke-Git -RepositoryRoot $unreachableProductFixture.clone -GitArguments @("commit", "-m", "fixture: reference unreachable product proof"))
  $unreachableProductFixture.product_commit = $sideProductCommit
  $unreachableProductFixture.manifest_path = $unreachableManifestPath
  $unreachableProductFixture.candidate_state.last_verified_checkpoint.product_commit = $sideProductCommit
  $unreachableProductFixture.candidate_state.last_verified_checkpoint.evidence_manifest_path = $unreachableManifestPath
  [void](Update-TransitionFixtureEvidenceParent -Fixture $unreachableProductFixture)
  $unreachableProductInvocation = Invoke-CompletionTransition `
    -ScriptPath $transitionCommitScriptPath `
    -Fixture $unreachableProductFixture `
    -TestTransportOutcome "accepted"
  Assert-Equal -Actual $unreachableProductInvocation.result.code -Expected "EVIDENCE_MANIFEST_INVALID" -Message "Locally present unreachable product commit was accepted."

  $tamperedParentFixture = New-TransitionTransactionFixture `
    -Name "tampered-parent-state" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "closeout"
  [void](Invoke-Git -RepositoryRoot $tamperedParentFixture.clone -GitArguments @("restore", "--", $tamperedParentFixture.handoff_path, $tamperedParentFixture.slice_log_path))
  $tamperedParentState = $tamperedParentFixture.previous_state | ConvertTo-Json -Depth 100 | ConvertFrom-Json
  $tamperedParentState.repeated_failure = [pscustomobject]@{
    signature = ("a" * 64)
    attempt_count = 1
    last_failed_at_utc = "2026-07-11T12:05:00.0000000Z"
  }
  Write-FixtureJson -Path (Join-Path $tamperedParentFixture.clone $tamperedParentFixture.state_path) -Value $tamperedParentState
  [void](Invoke-Git -RepositoryRoot $tamperedParentFixture.clone -GitArguments @("add", "--", $tamperedParentFixture.state_path))
  [void](Invoke-Git -RepositoryRoot $tamperedParentFixture.clone -GitArguments @("commit", "-m", "fixture: tamper state without revision"))
  [void](Update-TransitionFixtureEvidenceParent -Fixture $tamperedParentFixture)
  [IO.File]::AppendAllText((Join-Path $tamperedParentFixture.clone $tamperedParentFixture.handoff_path), "closeout update`n")
  [IO.File]::AppendAllText((Join-Path $tamperedParentFixture.clone $tamperedParentFixture.slice_log_path), "slice update`n")
  $tamperedParentInvocation = Invoke-CompletionTransition `
    -ScriptPath $transitionCommitScriptPath `
    -Fixture $tamperedParentFixture `
    -TestTransportOutcome "accepted"
  Assert-Equal -Actual $tamperedParentInvocation.result.code -Expected "PARENT_STATE_PROVENANCE_INVALID" -Message "Same-revision parent-state tamper bypassed provenance."

  $wrongClaimBindingFixture = New-TransitionTransactionFixture `
    -Name "wrong-claim-binding" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "closeout"
  $originalActiveCommit = [string]$wrongClaimBindingFixture.owner_state_commit
  $originalEvidenceCommit = [string]$wrongClaimBindingFixture.evidence_commit
  $readyParentCommit = Invoke-Git `
    -RepositoryRoot $wrongClaimBindingFixture.clone `
    -GitArguments @("rev-parse", "$originalActiveCommit^")
  $laterFixtureCommits = @(
    (Invoke-Git `
      -RepositoryRoot $wrongClaimBindingFixture.clone `
      -GitArguments @("rev-list", "--reverse", "$originalActiveCommit..$originalEvidenceCommit")) -split "`r?`n" |
      Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
  )
  $wrongClaimState = Invoke-Git `
    -RepositoryRoot $wrongClaimBindingFixture.clone `
    -GitArguments @("show", "$originalActiveCommit`:$($wrongClaimBindingFixture.state_path)") | ConvertFrom-Json
  $wrongClaimState.owner.claim_parent_commit = ("f" * 40)
  [void](Invoke-Git -RepositoryRoot $wrongClaimBindingFixture.clone -GitArguments @("reset", "--hard", $readyParentCommit))
  $wrongClaimCommit = Commit-TransitionFixtureState `
    -RepositoryRoot $wrongClaimBindingFixture.clone `
    -StatePath $wrongClaimBindingFixture.state_path `
    -State $wrongClaimState `
    -Subject "fixture: typed claim with wrong parent binding"
  foreach ($laterFixtureCommit in $laterFixtureCommits) {
    [void](Invoke-Git -RepositoryRoot $wrongClaimBindingFixture.clone -GitArguments @("cherry-pick", $laterFixtureCommit))
  }
  [void](Invoke-Git -RepositoryRoot $wrongClaimBindingFixture.clone -GitArguments @("push", "--force", "origin", "main"))
  $wrongClaimBindingFixture.owner_state_commit = $wrongClaimCommit
  $wrongClaimBindingFixture.evidence_commit = Invoke-Git `
    -RepositoryRoot $wrongClaimBindingFixture.clone `
    -GitArguments @("rev-parse", "HEAD")
  $wrongClaimBindingFixture.candidate_state = Set-TransitionFixtureAuthority `
    -State $wrongClaimBindingFixture.candidate_state `
    -RepositoryRoot $wrongClaimBindingFixture.clone `
    -Commit $wrongClaimBindingFixture.evidence_commit
  [IO.File]::AppendAllText((Join-Path $wrongClaimBindingFixture.clone $wrongClaimBindingFixture.handoff_path), "closeout update`n")
  [IO.File]::AppendAllText((Join-Path $wrongClaimBindingFixture.clone $wrongClaimBindingFixture.slice_log_path), "slice update`n")
  $wrongClaimBindingInvocation = Invoke-CompletionTransition `
    -ScriptPath $transitionCommitScriptPath `
    -Fixture $wrongClaimBindingFixture `
    -TestTransportOutcome "accepted"
  Assert-Equal -Actual $wrongClaimBindingInvocation.result.code -Expected "PARENT_STATE_PROVENANCE_INVALID" -Message "Wrong claim parent binding bypassed provenance."
  Assert-Equal -Actual $wrongClaimBindingInvocation.result.mutations_performed -Expected $false -Message "Wrong claim parent binding mutated transition state."

  $pathScopeFixture = New-TransitionTransactionFixture `
    -Name "transition-path-scope" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "closeout"
  Write-FixtureJson -Path (Join-Path $pathScopeFixture.clone $pathScopeFixture.state_path) -Value $pathScopeFixture.candidate_state
  $foreignTransitionPath = "apps/aquarium_app/docs/agent/autonomous_completion/forbidden-product.txt"
  Write-FixtureScript -Path (Join-Path $pathScopeFixture.clone $foreignTransitionPath) -Content "forbidden transition payload`n"
  [void](Invoke-Git -RepositoryRoot $pathScopeFixture.clone -GitArguments @("add", "--", $pathScopeFixture.state_path, $pathScopeFixture.handoff_path, $pathScopeFixture.slice_log_path, $foreignTransitionPath))
  $pathScopeTree = Invoke-Git -RepositoryRoot $pathScopeFixture.clone -GitArguments @("write-tree")
  $pathScopeLeaseJson = $pathScopeFixture.lease_release | ConvertTo-Json -Compress
  $pathScopeReport = Invoke-TransitionValidation `
    -ScriptPath $transitionScriptPath `
    -RepositoryRoot $pathScopeFixture.clone `
    -Source "Staged" `
    -ExpectedParentCommit $pathScopeFixture.evidence_commit `
    -ExpectedStagedTreeHash $pathScopeTree `
    -EvidenceManifestPath $pathScopeFixture.manifest_path `
    -LeaseReleaseJson $pathScopeLeaseJson
  Assert-Equal -Actual $pathScopeReport.code -Expected "TRANSITION_SCOPE_INVALID" -Message "Transition validator accepted a co-committed product path."

  $dirtyFinalizeFixture = New-TransitionTransactionFixture `
    -Name "dirty-retained-owner" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "finalize"
  Write-FixtureScript -Path (Join-Path $dirtyFinalizeFixture.previous_state.owner.worktree_path "dirty-owner.txt") -Content "dirty owner`n"
  $dirtyFinalizeInvocation = Invoke-CompletionTransition `
    -ScriptPath $transitionCommitScriptPath `
    -Fixture $dirtyFinalizeFixture `
    -TestTransportOutcome "accepted"
  Assert-Equal -Actual $dirtyFinalizeInvocation.result.code -Expected "STOP_PENDING" -Message "Dirty retained finalization owner did not fail closed."
  Assert-Equal -Actual $dirtyFinalizeInvocation.result.mutations_performed -Expected $false -Message "Dirty retained owner mutated finalization state."

  $wrongReleaseFixture = New-TransitionTransactionFixture `
    -Name "wrong-release-owner" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "closeout"
  $wrongReleaseFixture.lease_release.owner_token = ("0" * 64)
  $wrongReleaseInvocation = Invoke-CompletionTransition `
    -ScriptPath $transitionCommitScriptPath `
    -Fixture $wrongReleaseFixture `
    -TestTransportOutcome "accepted"
  Assert-Equal -Actual $wrongReleaseInvocation.result.code -Expected "LEASE_RELEASE_INVALID" -Message "Wrong-owner release proof escaped its stable code."
  Assert-Equal -Actual $wrongReleaseInvocation.result.mutations_performed -Expected $false -Message "Wrong-owner release proof mutated state."

  $badRecoveryFixture = New-TransitionTransactionFixture `
    -Name "missing-recovery-commit" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "stop"
  $badRecoveryFixture.candidate_state.recovery.last_clean_commit = ("f" * 40)
  $badRecoveryInvocation = Invoke-CompletionTransition `
    -ScriptPath $transitionCommitScriptPath `
    -Fixture $badRecoveryFixture `
    -TestTransportOutcome "accepted"
  Assert-Equal -Actual $badRecoveryInvocation.result.code -Expected "EVIDENCE_MANIFEST_INVALID" -Message "Nonexistent recovery commit escaped evidence validation."

  $remoteAdvancedFixture = New-TransitionTransactionFixture `
    -Name "remote-advanced-state" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "closeout"
  $remoteAdvancedShimRoot = Join-Path $remoteAdvancedFixture.root "git-shim"
  $remoteAdvancedShim = @"
`$captured = @(`$args)
& '$fixtureRealGit' @args
`$code = `$LASTEXITCODE
if (
  `$code -eq 0 -and
  @(`$captured | Where-Object { `$_ -ceq 'push' }).Count -eq 1 -and
  @(`$captured | Where-Object { `$_ -cmatch '^[0-9a-f]{40}:refs/heads/main$' }).Count -eq 1
) {
  & '$fixtureRealGit' -c core.longpaths=true -C `$env:DANIO_ADVANCE_ROOT fetch --prune origin main
  if (`$LASTEXITCODE -ne 0) { exit `$LASTEXITCODE }
  & '$fixtureRealGit' -c core.longpaths=true -C `$env:DANIO_ADVANCE_ROOT merge --ff-only origin/main
  if (`$LASTEXITCODE -ne 0) { exit `$LASTEXITCODE }
  & '$fixtureRealGit' -c core.longpaths=true -C `$env:DANIO_ADVANCE_ROOT commit --allow-empty -m 'fixture: advance accepted transition'
  if (`$LASTEXITCODE -ne 0) { exit `$LASTEXITCODE }
  & '$fixtureRealGit' -c core.longpaths=true -C `$env:DANIO_ADVANCE_ROOT push origin HEAD:main
  if (`$LASTEXITCODE -ne 0) { exit `$LASTEXITCODE }
}
exit `$code
"@
  Write-FixtureScript -Path (Join-Path $remoteAdvancedShimRoot "git.ps1") -Content $remoteAdvancedShim
  $remoteAdvancedInvocation = Invoke-CompletionTransition `
    -ScriptPath $transitionCommitScriptPath `
    -Fixture $remoteAdvancedFixture `
    -TestTransportOutcome "unknown_accepted" `
    -GitShimDirectory $remoteAdvancedShimRoot `
    -ChildEnvironment @{ DANIO_ADVANCE_ROOT = $remoteAdvancedFixture.seed }
  Assert-Equal -Actual $remoteAdvancedInvocation.result.code -Expected "REMOTE_MOVED" -Message "Remote-advanced transition classification mismatch."
  Assert-Equal -Actual $remoteAdvancedInvocation.result.reconciliation_status -Expected "remote_moved" -Message "Remote-advanced transition reconciliation mismatch."
  Assert-Equal -Actual $remoteAdvancedInvocation.result.durable_charge_consumption_proven -Expected $true -Message "Remote-advanced transition lost durable charge proof."
  Assert-Equal -Actual $remoteAdvancedInvocation.result.owner_retained -Expected $false -Message "Remote-advanced closeout overclaimed owner retention."
  Assert-Equal -Actual $remoteAdvancedInvocation.result.owner_released -Expected $true -Message "Remote-advanced closeout lost proven owner release."

  $localAlignmentFixture = New-TransitionTransactionFixture `
    -Name "local-alignment-state" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "closeout"
  $localAlignmentShimRoot = Join-Path $localAlignmentFixture.root "git-shim"
  $localAlignmentShim = @"
`$captured = @(`$args)
& '$fixtureRealGit' @args
`$code = `$LASTEXITCODE
if (
  `$code -eq 0 -and
  @(`$captured | Where-Object { `$_ -ceq 'push' }).Count -eq 1 -and
  @(`$captured | Where-Object { `$_ -cmatch '^[0-9a-f]{40}:refs/heads/main$' }).Count -eq 1
) {
  [IO.File]::WriteAllText(
    (Join-Path `$env:DANIO_DIRTY_ROOT 'alignment-race.txt'),
    'preserve local alignment dirt',
    (New-Object Text.UTF8Encoding(`$false))
  )
}
exit `$code
"@
  Write-FixtureScript -Path (Join-Path $localAlignmentShimRoot "git.ps1") -Content $localAlignmentShim
  $localAlignmentInvocation = Invoke-CompletionTransition `
    -ScriptPath $transitionCommitScriptPath `
    -Fixture $localAlignmentFixture `
    -TestTransportOutcome "unknown_accepted" `
    -GitShimDirectory $localAlignmentShimRoot `
    -ChildEnvironment @{ DANIO_DIRTY_ROOT = $localAlignmentFixture.clone }
  Assert-Equal -Actual $localAlignmentInvocation.result.code -Expected "REMOTE_MOVED" -Message "Local-alignment transition classification mismatch."
  Assert-Equal -Actual $localAlignmentInvocation.result.reconciliation_status -Expected "local_alignment_failed" -Message "Local-alignment transition reconciliation mismatch."
  Assert-Equal -Actual $localAlignmentInvocation.result.durable_charge_consumption_proven -Expected $true -Message "Local-alignment failure lost durable charge proof."
  Assert-Equal -Actual $localAlignmentInvocation.result.owner_retained -Expected $false -Message "Local-alignment closeout overclaimed owner retention."
  Assert-Equal -Actual $localAlignmentInvocation.result.owner_released -Expected $true -Message "Local-alignment closeout lost proven owner release."
  Assert-True -Condition (Test-Path -LiteralPath (Join-Path $localAlignmentFixture.clone "alignment-race.txt") -PathType Leaf) -Message "Local-alignment failure removed unrelated dirt."

  $unknownFixture = New-TransitionTransactionFixture `
    -Name "unknown-state-push" `
    -FixtureRoot $tempRoot `
    -SourceAppRoot $appRoot `
    -Action "closeout"
  $unknownInvocation = Invoke-CompletionTransition `
    -ScriptPath $transitionCommitScriptPath `
    -Fixture $unknownFixture `
    -TestTransportOutcome "unknown_unresolved"
  Assert-Equal -Actual $unknownInvocation.result.code -Expected "PUSH_OUTCOME_UNKNOWN" -Message "Unknown state push did not fail closed."
  Assert-Equal -Actual $unknownInvocation.result.push_attempt_count -Expected 1 -Message "Unknown state push count mismatch."
  Assert-Equal -Actual $unknownInvocation.result.retry_performed -Expected $false -Message "Unknown state push retried."
  Assert-Equal -Actual $unknownInvocation.result.artifacts_preserved -Expected $true -Message "Unknown state push discarded artifacts."
  Assert-Equal -Actual $unknownInvocation.result.owner_retained -Expected $null -Message "Unknown release push overclaimed durable owner retention."
  Assert-Equal -Actual $unknownInvocation.result.owner_released -Expected $null -Message "Unknown release push overclaimed durable owner release."
  Assert-True -Condition (-not [string]::IsNullOrWhiteSpace([string]$unknownInvocation.result.candidate_commit)) -Message "Unknown state candidate was not preserved."

  [pscustomobject]@{
    document_type = "danio_autonomous_completion_git_fixture_test_result"
    schema_version = 1
    passed = $true
    scenarios = 91
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
