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
    $output = @(& git -C $RepositoryRoot @GitArguments 2>&1)
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

if (-not (Test-Path -LiteralPath $syncScriptPath -PathType Leaf)) {
  throw "Expected synchronization wrapper is missing: $syncScriptPath"
}
if (-not (Test-Path -LiteralPath $readinessScriptPath -PathType Leaf)) {
  throw "Expected readiness wrapper is missing: $readinessScriptPath"
}

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

  $handoffPath = Join-Path $cloneTwoRoot "apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md"
  Add-Content -LiteralPath $handoffPath -Value "`nFixture remote advance."
  [void](Invoke-Git -RepositoryRoot $cloneTwoRoot -GitArguments @("add", "apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md"))
  [void](Invoke-Git -RepositoryRoot $cloneTwoRoot -GitArguments @("commit", "-m", "fixture: advance remote"))
  [void](Invoke-Git -RepositoryRoot $cloneTwoRoot -GitArguments @("push", "origin", "main"))
  Assert-ReadinessNoMutation `
    -SyncScriptPath $syncScriptPath `
    -ReadinessScriptPath $readinessScriptPath `
    -RepositoryRoot $cloneOneRoot `
    -InvocationNonce $invocationNonce `
    -ExpectedStopReason "REMOTE_DIVERGED" `
    -Scenario "remote divergence"

  [pscustomobject]@{
    document_type = "danio_autonomous_completion_git_fixture_test_result"
    schema_version = 1
    passed = $true
    scenarios = 5
    mutations_performed_by_readiness = $false
  } | ConvertTo-Json -Compress
} finally {
  $resolvedFixtureRoot = [System.IO.Path]::GetFullPath($tempRoot)
  if (-not $resolvedFixtureRoot.StartsWith($tempBase, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to remove fixture outside the system temp directory: $resolvedFixtureRoot"
  }
  if (Test-Path -LiteralPath $resolvedFixtureRoot) {
    Remove-Item -LiteralPath $resolvedFixtureRoot -Recurse -Force
  }
}
