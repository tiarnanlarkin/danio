[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Intent,
  [Parameter(Mandatory = $true)][string]$SynchronizationReceiptJson,
  [Parameter(Mandatory = $true)][string]$ExpectedInvocationNonce,
  [string]$RepositoryRoot,
  [int64]$MaxReceiptAgeSeconds = 120,
  [switch]$RuntimeRequired,
  [string]$EvidenceManifestPath,
  [string]$LeaseReleaseJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "DanioAutonomousCompletion.psm1"
$module = Import-Module -Name $modulePath -Force -PassThru

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

function Invoke-DanioReadinessGitProbe {
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

function Get-DanioReadinessArtifactObservation {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$Revision,
    [Parameter(Mandatory = $true)][string]$Path
  )

  if (
    [string]::IsNullOrWhiteSpace($Path) -or
    $Path -cnotmatch '^[A-Za-z0-9._/-]+$' -or
    $Path -match '(^|/)\.\.($|/)' -or
    [IO.Path]::IsPathRooted($Path)
  ) {
    throw "Artifact path cannot be probed safely."
  }

  $objectProbe = Invoke-DanioReadinessGitProbe `
    -Root $Root `
    -Arguments @("rev-parse", "$Revision`:$Path")
  if ($objectProbe.exit_code -ne 0 -or $objectProbe.output -cnotmatch '^[0-9a-f]{40}$') {
    return [pscustomobject]@{
      path = $Path
      exists_at_product_commit = $false
      sha256 = ("0" * 64)
    }
  }

  $startInfo = New-Object System.Diagnostics.ProcessStartInfo
  $startInfo.FileName = "git"
  $startInfo.WorkingDirectory = $Root
  $escapedRoot = $Root.Replace('"', '\"')
  $escapedObject = "$Revision`:$Path".Replace('"', '\"')
  $startInfo.Arguments = "-c core.longpaths=true -C `"$escapedRoot`" cat-file blob `"$escapedObject`""
  $startInfo.UseShellExecute = $false
  $startInfo.CreateNoWindow = $true
  $startInfo.RedirectStandardOutput = $true
  $startInfo.RedirectStandardError = $true
  $process = New-Object System.Diagnostics.Process
  $process.StartInfo = $startInfo
  $memory = New-Object IO.MemoryStream
  try {
    if (-not $process.Start()) {
      throw "Artifact process did not start."
    }
    $errorTask = $process.StandardError.ReadToEndAsync()
    $process.StandardOutput.BaseStream.CopyTo($memory)
    $process.WaitForExit()
    if ($process.ExitCode -ne 0) {
      throw "Artifact blob cannot be read: $($errorTask.Result)"
    }
    $sha256 = [Security.Cryptography.SHA256]::Create()
    try {
      $memory.Position = 0
      $hash = $sha256.ComputeHash($memory)
    } finally {
      $sha256.Dispose()
    }
    return [pscustomobject]@{
      path = $Path
      exists_at_product_commit = $true
      sha256 = ([BitConverter]::ToString($hash)).Replace("-", "").ToLowerInvariant()
    }
  } finally {
    $memory.Dispose()
    $process.Dispose()
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

  $stateValidation = if ($null -eq $state) {
    $null
  } else {
    Test-DanioRunState -State $state
  }
  $safeObservationState = if ($null -ne $stateValidation -and $stateValidation.valid) {
    $state
  } else {
    $null
  }
  $stateEligibleForFinalization = (
    $null -ne $stateValidation -and
    $stateValidation.valid -and
    [string]$state.mode -ceq "finalizing"
  )

  $observation = Get-DanioRepositoryObservation `
    -RepositoryRoot $resolvedRoot `
    -State $safeObservationState

  $runnerManifestPath = Join-Path $resolvedRoot "apps/aquarium_app/docs/agent/autonomous_completion/runner_compatibility.json"
  $runnerValidation = if (Test-Path -LiteralPath $runnerManifestPath -PathType Leaf) {
    try {
      $runnerManifest = Get-Content -Raw -LiteralPath $runnerManifestPath | ConvertFrom-Json
      Test-DanioRunnerCompatibility `
        -Manifest $runnerManifest `
        -RequireLaunchAuthorization:($Intent -ceq "Launch" -or $Intent -ceq "Claim") `
        -RepositoryRoot $resolvedRoot
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
  $evidence = $null
  $cleanup = $null
  if ($Intent -ceq "Finalization" -and $stateEligibleForFinalization) {
    try {
      $headCommitProbe = Invoke-DanioReadinessGitProbe `
        -Root $resolvedRoot `
        -Arguments @("rev-parse", "HEAD")
      if ($headCommitProbe.exit_code -ne 0 -or $headCommitProbe.output -cnotmatch '^[0-9a-f]{40}$') {
        throw "Aligned HEAD cannot be resolved."
      }
      $headCommit = [string]$headCommitProbe.output
      $ledgerRelativePath = "apps/aquarium_app/docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md"
      $ledgerProbe = Invoke-DanioReadinessGitProbe `
        -Root $resolvedRoot `
        -Arguments @("show", "$headCommit`:$ledgerRelativePath")
      if ($ledgerProbe.exit_code -ne 0) {
        throw "Parent ledger is missing."
      }
      $ledgerRows = @(Read-DanioLedgerClosureRows -Content ([string]$ledgerProbe.output))
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

      if ([string]::IsNullOrWhiteSpace($EvidenceManifestPath)) {
        throw "Finalization evidence path is missing."
      }
      $manifestProbe = Invoke-DanioReadinessGitProbe `
        -Root $resolvedRoot `
        -Arguments @("show", "$headCommit`:$EvidenceManifestPath")
      if ($manifestProbe.exit_code -ne 0) {
        throw "Finalization evidence manifest is missing from HEAD."
      }
      $manifest = [string]$manifestProbe.output | ConvertFrom-Json
      $productCommitProbe = Invoke-DanioReadinessGitProbe `
        -Root $resolvedRoot `
        -Arguments @("rev-parse", "$($manifest.product_commit)^{commit}")
      if (
        $productCommitProbe.exit_code -ne 0 -or
        [string]$productCommitProbe.output -cne [string]$manifest.product_commit
      ) {
        throw "Finalization product commit does not resolve exactly."
      }
      $productAncestorProbe = Invoke-DanioReadinessGitProbe `
        -Root $resolvedRoot `
        -Arguments @("merge-base", "--is-ancestor", [string]$manifest.product_commit, $headCommit)
      if ($productAncestorProbe.exit_code -ne 0) {
        throw "Finalization product commit is not in the aligned evidence history."
      }
      $artifactObservations = @()
      foreach ($artifact in @($manifest.artifacts)) {
        $artifactObservations += Get-DanioReadinessArtifactObservation `
          -Root $resolvedRoot `
          -Revision ([string]$manifest.product_commit) `
          -Path ([string]$artifact.path)
      }
      $latestCommandCompletion = @(
        $manifest.commands | ForEach-Object { [string]$_.completed_at_utc } | Sort-Object
      ) | Select-Object -Last 1
      if ([string]::IsNullOrWhiteSpace([string]$latestCommandCompletion)) {
        throw "Finalization evidence has no command completion."
      }
      $candidateState = $state | ConvertTo-Json -Depth 100 | ConvertFrom-Json
      $candidateState.state_revision = [int64]$state.state_revision + 1
      $candidateState.mode = "complete"
      $candidateState.transition = [pscustomobject]@{
        action = "complete"
        from_mode = "finalizing"
        to_mode = "complete"
        parent_state_revision = [int64]$state.state_revision
        work_unit_id = [string]$state.cursor.work_unit_id
        reason_code = $null
        occurred_at_utc = $checkedAtUtc
      }
      $candidateState.owner = $null
      $candidateState.last_verified_checkpoint = [pscustomobject]@{
        product_commit = [string]$manifest.product_commit
        evidence_manifest_path = $EvidenceManifestPath
        verified_at_utc = $checkedAtUtc
      }
      $evidenceValidation = & $module {
        param(
          $ManifestValue,
          $ManifestPathValue,
          $PreviousStateValue,
          $CandidateStateValue,
          $ParentCommitValue,
          $ArtifactObservationValues
        )
        Test-DanioEvidenceManifest `
          -Manifest $ManifestValue `
          -ManifestPath $ManifestPathValue `
          -PreviousState $PreviousStateValue `
          -CandidateState $CandidateStateValue `
          -ParentCommit $ParentCommitValue `
          -ArtifactObservations @($ArtifactObservationValues)
      } $manifest $EvidenceManifestPath $state $candidateState $headCommit $artifactObservations
      if ($evidenceValidation.valid) {
        $evidence = $evidenceValidation.evidence
      }

      if ([string]::IsNullOrWhiteSpace($LeaseReleaseJson)) {
        throw "Finalization lease release proof is missing."
      }
      $suppliedRelease = $LeaseReleaseJson | ConvertFrom-Json
      $releaseNames = @($suppliedRelease.PSObject.Properties | ForEach-Object { $_.Name })
      $requiredReleaseNames = @("owner_token", "android_released", "processes_released")
      if (
        $releaseNames.Count -ne $requiredReleaseNames.Count -or
        @($requiredReleaseNames | Where-Object { $releaseNames -cnotcontains $_ }).Count -ne 0 -or
        $null -eq $state.owner -or
        [string]$suppliedRelease.owner_token -cne [string]$state.owner.token_sha256 -or
        $suppliedRelease.android_released -isnot [bool] -or
        $suppliedRelease.processes_released -isnot [bool] -or
        -not $suppliedRelease.android_released -or
        -not $suppliedRelease.processes_released
      ) {
        throw "Finalization lease release proof is invalid."
      }
      $worktreeProbe = Invoke-DanioReadinessGitProbe `
        -Root $resolvedRoot `
        -Arguments @("worktree", "list", "--porcelain")
      $branchProbe = Invoke-DanioReadinessGitProbe `
        -Root $resolvedRoot `
        -Arguments @("show-ref", "--verify", "--quiet", "refs/heads/$($state.owner.branch_name)")
      if ($worktreeProbe.exit_code -ne 0 -or @(0, 1) -cnotcontains $branchProbe.exit_code) {
        throw "Finalization cleanup observation failed."
      }
      $ownedPath = ([string]$state.owner.worktree_path).Replace("\", "/").TrimEnd("/")
      $registeredPaths = @(
        @($worktreeProbe.output -split "`r?`n") |
          Where-Object { $_ -clike "worktree *" } |
          ForEach-Object { $_.Substring("worktree ".Length).Replace("\", "/").TrimEnd("/") }
      )
      $worktreeRegistered = @(
        $registeredPaths | Where-Object {
          [string]::Equals($_, $ownedPath, [StringComparison]::OrdinalIgnoreCase)
        }
      ).Count -gt 0
      $branchRemoved = $branchProbe.exit_code -eq 1
      $worktreeRemoved = -not $worktreeRegistered -and -not (Test-Path -LiteralPath ([string]$state.owner.worktree_path))
      if ($branchRemoved -and $worktreeRemoved) {
        $cleanup = [pscustomobject]@{
          owner_token = [string]$suppliedRelease.owner_token
          branch_name = [string]$state.owner.branch_name
          worktree_id = [string]$state.owner.worktree_id
          worktree_path = [string]$state.owner.worktree_path
          branch_removed = $true
          worktree_removed = $true
          device_released = $true
        }
      }
    } catch {
      $evidence = $null
      $cleanup = $null
    }
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
    -Evidence $evidence `
    -Cleanup $cleanup
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
