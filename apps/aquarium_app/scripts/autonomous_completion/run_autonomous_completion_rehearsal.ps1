[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$SynchronizationReceiptJson,
  [Parameter(Mandatory = $true)][string]$ExpectedInvocationNonce,
  [Parameter(Mandatory = $true)][string]$RehearsalRunId,
  [Parameter(Mandatory = $true)][string]$TaskId,
  [Parameter(Mandatory = $true)][int64]$ProposedAutonomousUnits,
  [Parameter(Mandatory = $true)][string]$ProposedWorkUnitId,
  [Parameter(Mandatory = $true)][string[]]$ProposedLedgerRowIds,
  [string]$RepositoryRoot,
  [string]$WorktreeRoot,
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

function Get-TextSha256 {
  param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Value)

  $sha256 = [Security.Cryptography.SHA256]::Create()
  try {
    $bytes = [Text.Encoding]::UTF8.GetBytes($Value)
    $hash = $sha256.ComputeHash($bytes)
    return ([BitConverter]::ToString($hash)).Replace("-", "").ToLowerInvariant()
  } finally {
    $sha256.Dispose()
  }
}

function Get-FileContentSha256 {
  param([Parameter(Mandatory = $true)][string]$LiteralPath)

  $stream = [IO.File]::Open(
    $LiteralPath,
    [IO.FileMode]::Open,
    [IO.FileAccess]::Read,
    [IO.FileShare]::Read
  )
  $sha256 = [Security.Cryptography.SHA256]::Create()
  try {
    $hash = $sha256.ComputeHash($stream)
    return ([BitConverter]::ToString($hash)).Replace("-", "").ToLowerInvariant()
  } finally {
    $sha256.Dispose()
    $stream.Dispose()
  }
}

function Invoke-RehearsalGit {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string[]]$Arguments
  )

  $priorOptionalLocks = [Environment]::GetEnvironmentVariable(
    "GIT_OPTIONAL_LOCKS",
    [EnvironmentVariableTarget]::Process
  )
  $hadPriorOptionalLocks = $null -ne $priorOptionalLocks
  $priorPreference = $ErrorActionPreference
  try {
    [Environment]::SetEnvironmentVariable(
      "GIT_OPTIONAL_LOCKS",
      "0",
      [EnvironmentVariableTarget]::Process
    )
    $ErrorActionPreference = "Continue"
    $output = @(& git -c core.longpaths=true -C $Root @Arguments 2>&1)
    $exitCode = $LASTEXITCODE
  } finally {
    $ErrorActionPreference = $priorPreference
    if ($hadPriorOptionalLocks) {
      [Environment]::SetEnvironmentVariable(
        "GIT_OPTIONAL_LOCKS",
        $priorOptionalLocks,
        [EnvironmentVariableTarget]::Process
      )
    } else {
      [Environment]::SetEnvironmentVariable(
        "GIT_OPTIONAL_LOCKS",
        $null,
        [EnvironmentVariableTarget]::Process
      )
    }
  }
  if ($exitCode -ne 0) {
    throw "REHEARSAL_GIT_OBSERVATION_FAILED: git observation failed: $($output -join '; ')"
  }
  return ($output | ForEach-Object { [string]$_ }) -join "`n"
}

function Get-RehearsalObservation {
  param([Parameter(Mandatory = $true)][string]$Root)

  $worktreeText = Invoke-RehearsalGit `
    -Root $Root `
    -Arguments @("worktree", "list", "--porcelain")
  $worktreePaths = @(
    @($worktreeText -split "`n") |
      Where-Object { $_ -clike "worktree *" } |
      ForEach-Object { $_.Substring(9).Replace("\", "/").TrimEnd("/") }
  )
  [Array]::Sort($worktreePaths, [StringComparer]::OrdinalIgnoreCase)

  $statusAndIndex = New-Object System.Collections.Generic.List[string]
  foreach ($worktreePath in $worktreePaths) {
    $statusAndIndex.Add("worktree=$worktreePath")
    $statusAndIndex.Add((Invoke-RehearsalGit `
      -Root $worktreePath `
      -Arguments @("--no-optional-locks", "status", "--porcelain=v1", "-uall")))
    $statusAndIndex.Add((Invoke-RehearsalGit `
      -Root $worktreePath `
      -Arguments @("ls-files", "--stage")))
    $indexPath = (Invoke-RehearsalGit `
      -Root $worktreePath `
      -Arguments @("rev-parse", "--path-format=absolute", "--git-path", "index")).Trim()
    if (-not (Test-Path -LiteralPath $indexPath -PathType Leaf)) {
      throw "REHEARSAL_GIT_OBSERVATION_FAILED: worktree index is missing."
    }
    $index_sha256 = Get-FileContentSha256 -LiteralPath $indexPath
    $statusAndIndex.Add("index_sha256=$index_sha256")

    $filePaths = @(
      @((Invoke-RehearsalGit `
        -Root $worktreePath `
        -Arguments @("ls-files", "--cached", "--others", "--exclude-standard")) -split "`n") |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    )
    [Array]::Sort($filePaths, [StringComparer]::Ordinal)
    $rootPrefix = [IO.Path]::GetFullPath($worktreePath).TrimEnd("\", "/") +
      [IO.Path]::DirectorySeparatorChar
    foreach ($filePath in $filePaths) {
      $absolutePath = [IO.Path]::GetFullPath((Join-Path $worktreePath $filePath))
      if (-not $absolutePath.StartsWith($rootPrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "REHEARSAL_GIT_OBSERVATION_FAILED: repository path escaped its worktree."
      }
      if (-not (Test-Path -LiteralPath $absolutePath -PathType Leaf)) {
        $statusAndIndex.Add("file=$filePath missing")
        continue
      }
      $item = Get-Item -LiteralPath $absolutePath -Force
      $fileHash = Get-FileContentSha256 -LiteralPath $absolutePath
      $statusAndIndex.Add(
        "file=$filePath length=$($item.Length) attributes=$([int64]$item.Attributes) sha256=$fileHash"
      )
    }
    $statusAndIndex.Add((Invoke-RehearsalGit `
      -Root $worktreePath `
      -Arguments @("rev-parse", "HEAD")))
  }

  $indexTree = Invoke-RehearsalGit -Root $Root -Arguments @("rev-parse", "HEAD^{tree}")
  if ($indexTree -cnotmatch '^[0-9a-f]{40}$') {
    throw "REHEARSAL_GIT_OBSERVATION_FAILED: canonical index tree is malformed."
  }
  $allRefs = Invoke-RehearsalGit `
    -Root $Root `
    -Arguments @("for-each-ref", "--sort=refname", "--format=%(refname) %(objectname)", "refs")
  $refLines = @(
    @($allRefs -split "`n") |
      Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
  )
  $remoteRefs = @($refLines | Where-Object { $_ -clike "refs/remotes/*" }) -join "`n"
  $localRefs = @($refLines | Where-Object { $_ -cnotlike "refs/remotes/*" }) -join "`n"

  return [pscustomobject][ordered]@{
    status_sha256 = Get-TextSha256 -Value ($statusAndIndex.ToArray() -join "`n")
    index_tree = $indexTree
    local_refs_sha256 = Get-TextSha256 -Value $localRefs
    remote_refs_sha256 = Get-TextSha256 -Value $remoteRefs
    worktrees_sha256 = Get-TextSha256 -Value $worktreeText
  }
}

function Test-ExactStringSet {
  param(
    [Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$Actual,
    [Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$Expected
  )

  if ($Actual.Count -ne $Expected.Count) {
    return $false
  }
  foreach ($value in $Expected) {
    if ($Actual -cnotcontains $value) {
      return $false
    }
  }
  return $true
}

function New-Preview {
  param([Parameter(Mandatory = $true)][string]$Code)

  return [pscustomobject][ordered]@{
    eligible = $false
    code = $Code
    mutations_performed = $false
  }
}

$result = $null
$exitCode = 1
try {
  if ($ExpectedInvocationNonce -cnotmatch '^[0-9a-f]{32}$') {
    throw "REHEARSAL_INPUT_INVALID: invocation nonce is malformed."
  }
  if ($ProposedAutonomousUnits -lt 1) {
    throw "REHEARSAL_INPUT_INVALID: proposed autonomous units must be positive."
  }
  if ($ProposedLedgerRowIds.Count -lt 1) {
    throw "REHEARSAL_INPUT_INVALID: at least one proposed ledger row is required."
  }
  try {
    $receipt = $SynchronizationReceiptJson | ConvertFrom-Json -ErrorAction Stop
  } catch {
    throw "INVALID_SYNC_RECEIPT: synchronization receipt JSON is malformed."
  }

  $resolvedRoot = Resolve-DanioRepositoryRoot -RepositoryRoot $RepositoryRoot
  $normalizedRoot = $resolvedRoot.Replace("\", "/").TrimEnd("/")
  $statePath = Join-Path $resolvedRoot "apps/aquarium_app/docs/agent/autonomous_completion/phone_completion_run_state.json"
  if (Test-Path -LiteralPath $statePath -PathType Leaf) {
    throw "AUTHORITY_CONFLICT: live operational state already exists."
  }

  $repositoryObservation = Get-DanioRepositoryObservation -RepositoryRoot $resolvedRoot
  if (
    [string]$repositoryObservation.branch -cne "main" -or
    -not [bool]$repositoryObservation.clean -or
    [int64]$repositoryObservation.ahead -ne 0 -or
    [int64]$repositoryObservation.behind -ne 0
  ) {
    throw "REHEARSAL_REPOSITORY_NOT_READY: canonical main is not clean and aligned."
  }

  $expectedWorktrees = @($normalizedRoot)
  $expectedBranches = @()
  if (-not [string]::IsNullOrWhiteSpace($WorktreeRoot)) {
    $resolvedWorktree = (Resolve-Path -LiteralPath $WorktreeRoot -ErrorAction Stop).Path
    $normalizedWorktree = $resolvedWorktree.Replace("\", "/").TrimEnd("/")
    if ([string]::Equals($normalizedWorktree, $normalizedRoot, [StringComparison]::OrdinalIgnoreCase)) {
      throw "REHEARSAL_INPUT_INVALID: the explicit worktree must differ from canonical main."
    }
    $worktreeBranch = Invoke-RehearsalGit `
      -Root $resolvedWorktree `
      -Arguments @("branch", "--show-current")
    if ([string]::IsNullOrWhiteSpace($worktreeBranch) -or $worktreeBranch -ceq "main") {
      throw "REHEARSAL_INPUT_INVALID: the explicit worktree branch is invalid."
    }
    $expectedWorktrees += $normalizedWorktree
    $expectedBranches += $worktreeBranch
  }
  if (
    -not (Test-ExactStringSet `
      -Actual @($repositoryObservation.worktrees) `
      -Expected $expectedWorktrees) -or
    -not (Test-ExactStringSet `
      -Actual @($repositoryObservation.temporary_branches) `
      -Expected $expectedBranches)
  ) {
    throw "DIRTY_UNOWNED: unexpected branch or worktree identity is present."
  }
  $repositoryObservation.ownership_clear = $true

  $runnerManifestPath = Join-Path $resolvedRoot "apps/aquarium_app/docs/agent/autonomous_completion/runner_compatibility.json"
  $runnerManifest = Get-Content -Raw -LiteralPath $runnerManifestPath -ErrorAction Stop |
    ConvertFrom-Json -ErrorAction Stop
  if ($runnerManifest.authorizes_launch -isnot [bool] -or [bool]$runnerManifest.authorizes_launch) {
    throw "REHEARSAL_PREVIEW_INVALID: rehearsal requires the committed false launch bit."
  }
  $runnerValidation = Test-DanioRunnerCompatibility `
    -Manifest $runnerManifest `
    -RepositoryRoot $resolvedRoot
  if (-not $runnerValidation.valid) {
    throw "RUNNER_INCOMPATIBLE: $($runnerValidation.details -join '; ')"
  }

  $before = Get-RehearsalObservation -Root $resolvedRoot
  $baseCommit = [string]$repositoryObservation.head_commit
  $checkedAtUtc = Format-StrictUtc -Value ([DateTimeOffset]::UtcNow)
  $readinessParameters = @{
    SynchronizationReceipt = $receipt
    ExpectedInvocationNonce = $ExpectedInvocationNonce
    ExpectedRepositoryRoot = $normalizedRoot
    RepositoryObservation = $repositoryObservation
    State = $null
    AuthorityValidation = $repositoryObservation.authority_validation
    RunnerValidation = $runnerValidation
    RemainingUnitsIncludingCurrent = $ProposedAutonomousUnits
    CheckedAtUtc = $checkedAtUtc
    RuntimeRequired = [bool]$RuntimeRequired
    RuntimeOwnershipClear = (-not [bool]$RuntimeRequired)
  }

  $launchReadiness = Test-DanioAutonomousReadiness -Intent "Launch" @readinessParameters
  if (-not $launchReadiness.eligible) {
    throw "REHEARSAL_PREVIEW_INVALID: Launch prerequisites failed before authorization: $($launchReadiness.stop_reason_code)."
  }
  $claimReadiness = Test-DanioAutonomousReadiness -Intent "Claim" @readinessParameters
  $closeoutReadiness = Test-DanioAutonomousReadiness -Intent "Closeout" @readinessParameters
  if (
    $claimReadiness.eligible -or
    [string]$claimReadiness.stop_reason_code -cne "AUTHORITY_CONFLICT" -or
    $closeoutReadiness.eligible -or
    [string]$closeoutReadiness.stop_reason_code -cne "AUTHORITY_CONFLICT"
  ) {
    throw "REHEARSAL_PREVIEW_INVALID: Claim or Closeout did not fail on absent live state."
  }

  $after = Get-RehearsalObservation -Root $resolvedRoot
  $result = New-DanioRehearsalReport `
    -RehearsalRunId $RehearsalRunId `
    -TaskId $TaskId `
    -CreatedAtUtc $checkedAtUtc `
    -RepositoryRoot $normalizedRoot `
    -BaseCommit $baseCommit `
    -ProposedAutonomousUnits $ProposedAutonomousUnits `
    -ProposedWorkUnitId $ProposedWorkUnitId `
    -ProposedLedgerRowIds $ProposedLedgerRowIds `
    -Before $before `
    -After $after `
    -LaunchPreview (New-Preview -Code "LAUNCH_NOT_AUTHORIZED") `
    -ClaimPreview (New-Preview -Code "AUTHORITY_CONFLICT") `
    -CloseoutPreview (New-Preview -Code "AUTHORITY_CONFLICT")
  $exitCode = 0
} catch {
  $message = $_.Exception.Message
  $code = if ($message -cmatch '^([A-Z][A-Z0-9_]+):') {
    $Matches[1]
  } else {
    "REHEARSAL_REJECTED"
  }
  $result = [pscustomobject][ordered]@{
    document_type = "danio_autonomous_completion_rehearsal_rejection"
    schema_version = 1
    accepted = $false
    code = $code
    detail = $message
    mutations_performed = $false
  }
}

Write-Output ($result | ConvertTo-Json -Depth 100 -Compress)
exit $exitCode
