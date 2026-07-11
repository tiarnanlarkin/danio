[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$ReadinessReportJson,
  [Parameter(Mandatory = $true)][string]$TaskId,
  [Parameter(Mandatory = $true)][int64]$ExpectedStateRevision,
  [string]$RepositoryRoot,
  [string]$WorktreeRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "DanioAutonomousCompletion.psm1"
Import-Module -Name $modulePath -Force
$statePath = "apps/aquarium_app/docs/agent/autonomous_completion/phone_completion_run_state.json"

function Format-StrictUtc {
  param([Parameter(Mandatory = $true)][DateTimeOffset]$Value)

  return $Value.ToUniversalTime().ToString(
    "yyyy-MM-dd'T'HH:mm:ss.fffffff'Z'",
    [Globalization.CultureInfo]::InvariantCulture
  )
}

function ConvertTo-ForwardSlashPath {
  param([Parameter(Mandatory = $true)][string]$Path)

  return $Path.Replace("\", "/").TrimEnd("/")
}

function New-RejectedClaimPlan {
  param(
    [Parameter(Mandatory = $true)][string]$PlannedAtUtc,
    [Parameter(Mandatory = $true)][string]$Code,
    [Parameter(Mandatory = $true)][string]$Detail
  )

  return [pscustomobject][ordered]@{
    document_type = "danio_writer_claim_plan"
    schema_version = 1
    planned_at_utc = $PlannedAtUtc
    valid = $false
    code = $Code
    details = @($Detail)
    mutations_performed = $false
    run_id = $null
    work_unit_id = $null
    task_id = $null
    expected_state_revision = $null
    owner_token_sha256 = $null
    branch_name = $null
    worktree_id = $null
    worktree_path = $null
    base_commit = $null
    state_path = $statePath
    next_run_state = $null
  }
}

function Invoke-DanioGitProbe {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string[]]$Arguments
  )

  $priorPreference = $ErrorActionPreference
  try {
    $ErrorActionPreference = "Continue"
    $output = @(& git -c core.longpaths=true -C $Root @Arguments 2>&1)
    $exitCode = $LASTEXITCODE
  } finally {
    $ErrorActionPreference = $priorPreference
  }
  return [pscustomobject]@{
    exit_code = $exitCode
    output = ($output -join "`n").TrimEnd()
  }
}

function Invoke-DanioReadOnlyGit {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string[]]$Arguments
  )

  $probe = Invoke-DanioGitProbe -Root $Root -Arguments $Arguments
  if ($probe.exit_code -ne 0) {
    throw "GIT_OBSERVATION_FAILED: git $($Arguments -join ' ') exited $($probe.exit_code): $($probe.output)"
  }
  return [string]$probe.output
}

function Get-ExpectedIdentity {
  param(
    [Parameter(Mandatory = $true)]$State,
    [Parameter(Mandatory = $true)][string]$Task,
    [Parameter(Mandatory = $true)][int64]$Revision
  )

  $runId = [string]$State.run_id
  $workUnitId = [string]$State.cursor.work_unit_id
  $tokenInput = @($runId, $workUnitId, $Task, [string]$Revision) -join "`n"
  $tokenBytes = [Text.Encoding]::UTF8.GetBytes($tokenInput)
  $sha256 = [Security.Cryptography.SHA256]::Create()
  try {
    $tokenHash = $sha256.ComputeHash($tokenBytes)
  } finally {
    $sha256.Dispose()
  }
  $token = ([BitConverter]::ToString($tokenHash)).Replace("-", "").ToLowerInvariant()
  $token12 = $token.Substring(0, 12)
  $worktreeId = "$runId-$workUnitId-$token12"
  $savedProjectRoot = ConvertTo-ForwardSlashPath -Path ([string]$State.authorization.saved_project_root)
  return [pscustomobject]@{
    token_sha256 = $token
    branch_name = "autonomy/$runId/$workUnitId/$token12"
    worktree_id = $worktreeId
    worktree_path = "$savedProjectRoot/.codex-worktrees/$worktreeId"
  }
}

function Test-DanioResolvedWorktreeContainment {
  param(
    [Parameter(Mandatory = $true)][string]$SavedProjectRoot,
    [Parameter(Mandatory = $true)][string]$RequestedWorktreeRoot,
    [Parameter(Mandatory = $true)][string]$ExpectedWorktreePath
  )

  try {
    $savedFull = [IO.Path]::GetFullPath($SavedProjectRoot).TrimEnd("\", "/")
    $requestedFull = [IO.Path]::GetFullPath($RequestedWorktreeRoot).TrimEnd("\", "/")
    $expectedRootFull = [IO.Path]::GetFullPath(
      (Join-Path $savedFull ".codex-worktrees")
    ).TrimEnd("\", "/")
    $expectedPathFull = [IO.Path]::GetFullPath($ExpectedWorktreePath).TrimEnd("\", "/")
  } catch {
    return [pscustomobject]@{
      valid = $false
      detail = "Worktree containment paths cannot be resolved."
    }
  }

  if (
    -not [string]::Equals(
      [IO.Path]::GetPathRoot($savedFull),
      [IO.Path]::GetPathRoot($requestedFull),
      [StringComparison]::OrdinalIgnoreCase
    ) -or
    -not [string]::Equals(
      $requestedFull,
      $expectedRootFull,
      [StringComparison]::OrdinalIgnoreCase
    ) -or
    -not $expectedPathFull.StartsWith("$expectedRootFull\", [StringComparison]::OrdinalIgnoreCase)
  ) {
    return [pscustomobject]@{
      valid = $false
      detail = "Worktree root or derived path escapes the saved-project containment root."
    }
  }

  foreach ($candidate in @($expectedRootFull, $expectedPathFull)) {
    if (Test-Path -LiteralPath $candidate) {
      $item = Get-Item -LiteralPath $candidate -Force
      if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
        return [pscustomobject]@{
          valid = $false
          detail = "Worktree containment traverses a reparse point."
        }
      }
    }
  }
  return [pscustomobject]@{
    valid = $true
    detail = "Worktree path is contained below the saved-project root."
  }
}

function Get-DanioWriterIdentityObservation {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$ExpectedBranchName,
    [Parameter(Mandatory = $true)][string]$ExpectedWorktreePath,
    [Parameter(Mandatory = $true)][string]$ExpectedBaseCommit
  )

  $normalizedExpectedPath = ConvertTo-ForwardSlashPath -Path $ExpectedWorktreePath
  $expectedBranchRef = "refs/heads/$ExpectedBranchName"
  $branchProbe = Invoke-DanioGitProbe `
    -Root $Root `
    -Arguments @("show-ref", "--verify", "--hash", $expectedBranchRef)
  $ordinaryAbsence = (
    $branchProbe.exit_code -eq 128 -and
    [string]$branchProbe.output -ceq "fatal: '$expectedBranchRef' - not a valid ref"
  )
  if ($branchProbe.exit_code -ne 0 -and -not $ordinaryAbsence) {
    return [pscustomobject]@{
      status = "ambiguous"
      details = @("Existing writer branch evidence could not be observed safely.")
    }
  }
  $branchExists = $branchProbe.exit_code -eq 0
  $branchCommit = if ($branchExists) { [string]$branchProbe.output } else { $null }
  $pathExists = Test-Path -LiteralPath $ExpectedWorktreePath
  try {
    $worktreeText = Invoke-DanioReadOnlyGit -Root $Root -Arguments @("worktree", "list", "--porcelain")
  } catch {
    return [pscustomobject]@{
      status = "ambiguous"
      details = @("Existing writer worktree evidence could not be observed safely.")
    }
  }
  $entries = New-Object System.Collections.Generic.List[object]
  $entry = $null
  foreach ($line in @($worktreeText -split "`r?`n")) {
    if ($line.StartsWith("worktree ", [StringComparison]::Ordinal)) {
      if ($null -ne $entry) {
        $entries.Add([pscustomobject]$entry)
      }
      $entry = [ordered]@{
        path = ConvertTo-ForwardSlashPath -Path $line.Substring(9)
        head = $null
        branch = $null
      }
    } elseif ($null -ne $entry -and $line.StartsWith("HEAD ", [StringComparison]::Ordinal)) {
      $entry.head = $line.Substring(5)
    } elseif ($null -ne $entry -and $line.StartsWith("branch refs/heads/", [StringComparison]::Ordinal)) {
      $entry.branch = $line.Substring(18)
    }
  }
  if ($null -ne $entry) {
    $entries.Add([pscustomobject]$entry)
  }

  $pathEntries = @(
    $entries | Where-Object {
      [string]::Equals(
        [string]$_.path,
        $normalizedExpectedPath,
        [StringComparison]::OrdinalIgnoreCase
      )
    }
  )
  $branchEntries = @($entries | Where-Object { [string]$_.branch -ceq $ExpectedBranchName })
  if (-not $branchExists -and -not $pathExists -and $pathEntries.Count -eq 0 -and $branchEntries.Count -eq 0) {
    return [pscustomobject]@{
      status = "absent"
      details = @()
    }
  }

  if (
    -not $branchExists -or
    -not $pathExists -or
    $pathEntries.Count -ne 1 -or
    $branchEntries.Count -ne 1 -or
    [string]$pathEntries[0].branch -cne $ExpectedBranchName -or
    [string]$pathEntries[0].head -cne $ExpectedBaseCommit -or
    [string]$branchCommit -cne $ExpectedBaseCommit
  ) {
    return [pscustomobject]@{
      status = "conflict"
      details = @("Existing branch, worktree, path, or base commit is not an exact reusable identity.")
    }
  }

  $expectedItem = Get-Item -LiteralPath $ExpectedWorktreePath -Force
  if (($expectedItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
    return [pscustomobject]@{
      status = "conflict"
      details = @("Existing worktree path is a reparse point.")
    }
  }
  $worktreeHead = Invoke-DanioReadOnlyGit -Root $ExpectedWorktreePath -Arguments @("rev-parse", "HEAD")
  $worktreeStatus = Invoke-DanioReadOnlyGit `
    -Root $ExpectedWorktreePath `
    -Arguments @("--no-optional-locks", "status", "--short", "-uall")
  if ($worktreeHead -cne $ExpectedBaseCommit -or -not [string]::IsNullOrWhiteSpace($worktreeStatus)) {
    return [pscustomobject]@{
      status = "conflict"
      details = @("Existing worktree commit or dirt does not match the reusable identity.")
    }
  }

  try {
    $relevantProcesses = @(
      Get-CimInstance -ClassName Win32_Process -ErrorAction Stop |
        Where-Object {
          $commandLine = [string]$_.CommandLine
          if ([string]::IsNullOrWhiteSpace($commandLine)) {
            return $false
          }
          $normalizedCommandLine = $commandLine.Replace("\", "/")
          return (
            $normalizedCommandLine.IndexOf(
              $normalizedExpectedPath,
              [StringComparison]::OrdinalIgnoreCase
            ) -ge 0 -or
            $normalizedCommandLine.IndexOf(
              $ExpectedBranchName,
              [StringComparison]::OrdinalIgnoreCase
            ) -ge 0
          )
        }
    )
  } catch {
    return [pscustomobject]@{
      status = "ambiguous"
      details = @("Existing writer process evidence could not be enumerated.")
    }
  }
  if ($relevantProcesses.Count -gt 0) {
    return [pscustomobject]@{
      status = "ambiguous"
      details = @("A process still references the deterministic writer identity.")
    }
  }

  return [pscustomobject]@{
    status = "exact_reusable"
    details = @("Exact quiescent branch and worktree match the committed base.")
  }
}

$plannedAtUtc = Format-StrictUtc -Value ([DateTimeOffset]::UtcNow)
$plan = $null
$priorOptionalLocks = [Environment]::GetEnvironmentVariable(
  "GIT_OPTIONAL_LOCKS",
  [EnvironmentVariableTarget]::Process
)
$hadPriorOptionalLocks = $null -ne $priorOptionalLocks
[Environment]::SetEnvironmentVariable(
  "GIT_OPTIONAL_LOCKS",
  "0",
  [EnvironmentVariableTarget]::Process
)

try {
  try {
    $readinessReport = $ReadinessReportJson | ConvertFrom-Json
  } catch {
    throw "INVALID_READINESS_REPORT: readiness JSON is malformed."
  }

  $resolvedRoot = Resolve-DanioRepositoryRoot -RepositoryRoot $RepositoryRoot
  $baseCommit = Invoke-DanioReadOnlyGit -Root $resolvedRoot -Arguments @("rev-parse", "origin/main")
  $baseTreeHash = Invoke-DanioReadOnlyGit -Root $resolvedRoot -Arguments @("rev-parse", "$baseCommit^{tree}")
  $stateJson = Invoke-DanioReadOnlyGit -Root $resolvedRoot -Arguments @("show", "$baseCommit`:$statePath")
  try {
    $currentState = $stateJson | ConvertFrom-Json
  } catch {
    throw "STATE_BLOB_INVALID: committed run state is malformed."
  }

  $identity = Get-ExpectedIdentity `
    -State $currentState `
    -Task $TaskId `
    -Revision $ExpectedStateRevision
  $effectiveWorktreeRoot = if ([string]::IsNullOrWhiteSpace($WorktreeRoot)) {
    Join-Path ([string]$currentState.authorization.saved_project_root) ".codex-worktrees"
  } else {
    $WorktreeRoot
  }
  $containment = Test-DanioResolvedWorktreeContainment `
    -SavedProjectRoot ([string]$currentState.authorization.saved_project_root) `
    -RequestedWorktreeRoot $effectiveWorktreeRoot `
    -ExpectedWorktreePath ([string]$identity.worktree_path)
  if (-not $containment.valid) {
    $plan = New-RejectedClaimPlan `
      -PlannedAtUtc $plannedAtUtc `
      -Code "OWNER_IDENTITY_INVALID" `
      -Detail ([string]$containment.detail)
  } else {
    $identityObservation = Get-DanioWriterIdentityObservation `
      -Root $resolvedRoot `
      -ExpectedBranchName ([string]$identity.branch_name) `
      -ExpectedWorktreePath ([string]$identity.worktree_path) `
      -ExpectedBaseCommit $baseCommit
    $plan = New-DanioWriterClaimPlan `
      -ReadinessReport $readinessReport `
      -CurrentState $currentState `
      -TaskId $TaskId `
      -ExpectedStateRevision $ExpectedStateRevision `
      -RepositoryRoot $resolvedRoot `
      -WorktreeRoot $effectiveWorktreeRoot `
      -BaseCommit $baseCommit `
      -BaseTreeHash $baseTreeHash `
      -PlannedAtUtc $plannedAtUtc `
      -ExistingIdentityObservation $identityObservation
    if (
      $plan.valid -and
      (
        [string]$plan.owner_token_sha256 -cne [string]$identity.token_sha256 -or
        [string]$plan.branch_name -cne [string]$identity.branch_name -or
        [string]$plan.worktree_id -cne [string]$identity.worktree_id -or
        [string]$plan.worktree_path -cne [string]$identity.worktree_path
      )
    ) {
      $plan = New-RejectedClaimPlan `
        -PlannedAtUtc $plannedAtUtc `
        -Code "OWNER_IDENTITY_INVALID" `
        -Detail "Wrapper and pure planner identity derivation disagree."
    }
  }
} catch {
  $message = $_.Exception.Message
  $code = if ($message -like "INVALID_READINESS_REPORT:*") {
    "INVALID_READINESS_REPORT"
  } else {
    "OWNER_IDENTITY_INVALID"
  }
  $plan = New-RejectedClaimPlan `
    -PlannedAtUtc $plannedAtUtc `
    -Code $code `
    -Detail $message
} finally {
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

Write-Output ($plan | ConvertTo-Json -Depth 100 -Compress)
if ($plan.valid) {
  exit 0
}
exit 1
