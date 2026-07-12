[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$NextRunStateJson,
  [Parameter(Mandatory = $true)][int64]$ExpectedStateRevision,
  [Parameter(Mandatory = $true)][string]$ExpectedOriginMainCommit,
  [string]$EvidenceManifestPath,
  [string]$LeaseReleaseJson,
  [string]$RepositoryRoot,
  [string]$TestTransportOutcome
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "DanioAutonomousCompletion.psm1"
Import-Module -Name $modulePath -Force
$transitionScriptPath = Join-Path $PSScriptRoot "validate_autonomous_completion_transition.ps1"
$statePath = "apps/aquarium_app/docs/agent/autonomous_completion/phone_completion_run_state.json"
$ledgerPath = "apps/aquarium_app/docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md"
$handoffPath = "apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md"
$sliceLogPath = "apps/aquarium_app/docs/agent/SLICE_LOG.md"
$allowedTestOutcomes = @(
  "accepted",
  "rejected",
  "unknown_accepted",
  "unknown_not_accepted",
  "unknown_unresolved"
)

function Format-StrictUtc {
  param([Parameter(Mandatory = $true)][DateTimeOffset]$Value)

  return $Value.ToUniversalTime().ToString(
    "yyyy-MM-dd'T'HH:mm:ss.fffffff'Z'",
    [Globalization.CultureInfo]::InvariantCulture
  )
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

function Invoke-DanioGit {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string[]]$Arguments,
    [string]$FailureCode = "TRANSITION_TRANSACTION_INVALID"
  )

  $probe = Invoke-DanioGitProbe -Root $Root -Arguments $Arguments
  if ($probe.exit_code -ne 0) {
    throw "$FailureCode`: git $($Arguments -join ' ') exited $($probe.exit_code): $($probe.output)"
  }
  return [string]$probe.output
}

function Invoke-DanioBoundedTransportGit {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string[]]$Arguments,
    [int]$TimeoutSeconds = 60
  )

  $rootBase64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Root))
  $argumentsJson = ConvertTo-Json -InputObject @($Arguments) -Compress
  $argumentsBase64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($argumentsJson))
  $childCommand = @"
`$root = [Text.Encoding]::UTF8.GetString(
  [Convert]::FromBase64String('$rootBase64')
)
`$argumentsJson = [Text.Encoding]::UTF8.GetString(
  [Convert]::FromBase64String('$argumentsBase64')
)
`$gitArguments = @(`$argumentsJson | ConvertFrom-Json)
`$ErrorActionPreference = 'Continue'
`$env:GIT_TERMINAL_PROMPT = '0'
`$env:GCM_INTERACTIVE = 'Never'
& git -c core.longpaths=true -C `$root @gitArguments
exit `$LASTEXITCODE
"@
  $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($childCommand))
  $startInfo = New-Object Diagnostics.ProcessStartInfo
  $startInfo.FileName = (Get-Command powershell.exe -ErrorAction Stop).Source
  $startInfo.Arguments = "-NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -EncodedCommand $encoded"
  $startInfo.UseShellExecute = $false
  $startInfo.CreateNoWindow = $true
  $startInfo.RedirectStandardOutput = $true
  $startInfo.RedirectStandardError = $true
  $process = New-Object Diagnostics.Process
  $process.StartInfo = $startInfo
  try {
    if (-not $process.Start()) {
      throw "PUSH_OUTCOME_UNKNOWN: transport process did not start."
    }
    $stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $stderrTask = $process.StandardError.ReadToEndAsync()
    $completed = $process.WaitForExit($TimeoutSeconds * 1000)
    $treeKillConfirmed = $completed
    if (-not $completed) {
      $taskkill = Join-Path $env:SystemRoot "System32\taskkill.exe"
      $priorPreference = $ErrorActionPreference
      try {
        $ErrorActionPreference = "Continue"
        [void]@(& $taskkill "/PID" ([string]$process.Id) "/T" "/F" 2>&1)
        $treeKillConfirmed = $LASTEXITCODE -eq 0
      } finally {
        $ErrorActionPreference = $priorPreference
      }
      [void]$process.WaitForExit(10000)
      if (-not $process.HasExited) {
        try {
          $process.Kill()
          [void]$process.WaitForExit(5000)
        } catch {
        }
      }
    } else {
      $process.WaitForExit()
    }
    $processExited = $process.HasExited
    $stdoutCompleted = $false
    $stderrCompleted = $false
    if ($processExited) {
      try { $stdoutCompleted = $stdoutTask.Wait(5000) } catch { }
      try { $stderrCompleted = $stderrTask.Wait(5000) } catch { }
    }
    $terminationConfirmed = `
      $treeKillConfirmed -and $processExited -and $stdoutCompleted -and $stderrCompleted
    $stdout = if ($stdoutCompleted) { [string]$stdoutTask.Result } else { "" }
    $stderr = if ($stderrCompleted) {
      [string]$stderrTask.Result
    } else {
      "Transport process tree or redirected streams did not terminate cleanly."
    }
    return [pscustomobject]@{
      timed_out = -not $completed
      termination_confirmed = $terminationConfirmed
      exit_code = if ($completed) { $process.ExitCode } else { $null }
      stdout = $stdout.Trim()
      stderr = $stderr.Trim()
      output = (@($stdout, $stderr) -join "`n").Trim()
    }
  } finally {
    $process.Dispose()
  }
}

function Invoke-DanioBoundedPush {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$TransportTarget,
    [Parameter(Mandatory = $true)][string]$CandidateCommit
  )

  return Invoke-DanioBoundedTransportGit `
    -Root $Root `
    -Arguments @("push", "--porcelain", "--", $TransportTarget, "$CandidateCommit`:refs/heads/main")
}

function Invoke-DanioBoundedFetch {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$TransportTarget
  )

  return Invoke-DanioBoundedTransportGit `
    -Root $Root `
    -Arguments @(
      "fetch",
      "--prune",
      "--",
      $TransportTarget,
      "refs/heads/main:refs/remotes/origin/main"
    )
}

function Test-DanioExplicitRemoteRejection {
  param(
    [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Stdout,
    [Parameter(Mandatory = $true)][string]$CandidateCommit
  )

  $records = @(
    $Stdout -split "`r?`n" | Where-Object { $_ -match '^[!+=*\-]\t' }
  )
  if ($records.Count -ne 1) {
    return $false
  }
  return [string]$records[0] -match `
    "^!\t$([regex]::Escape($CandidateCommit)):refs/heads/main\t\[rejected\] \((fetch first|non-fast-forward)\)$"
}

function Get-DanioParentAuthority {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$ParentCommit
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
  foreach ($entry in @($paths.GetEnumerator())) {
    $probe = Invoke-DanioGitProbe `
      -Root $Root `
      -Arguments @("rev-parse", "$ParentCommit`:$($entry.Value)")
    if ($probe.exit_code -ne 0 -or $probe.output -cnotmatch '^[0-9a-f]{40}$') {
      throw "AUTHORITY_CONFLICT: canonical parent authority '$($entry.Key)' is missing."
    }
    $authority[$entry.Key] = [pscustomobject][ordered]@{
      path = [string]$entry.Value
      commit = $ParentCommit
      blob_oid = [string]$probe.output
    }
  }
  return [pscustomobject]$authority
}

function Assert-DanioParentStateTransitionPreflight {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$ParentCommit,
    [Parameter(Mandatory = $true)]$ObservedState
  )

  $validatorLibrary = $null
  try {
    $validatorLibrary = New-Module `
      -Name "DanioTransitionParentProvenance" `
      -ArgumentList @($transitionScriptPath) `
      -ScriptBlock {
        param([Parameter(Mandatory = $true)][string]$ValidatorPath)

        $script:DanioTransitionLibraryOnly = $true
        . $ValidatorPath -Source "Committed"
      }
    $stateCommit = & $validatorLibrary {
      param($RepositoryRootValue, $ParentCommitValue, $ObservedStateValue)

      Assert-DanioParentStateProvenance `
        -Root $RepositoryRootValue `
        -ParentCommit $ParentCommitValue `
        -ObservedState $ObservedStateValue
    } $Root $ParentCommit $ObservedState
    if ($stateCommit -cnotmatch '^[0-9a-f]{40}$') {
      throw "exact parent helper did not return an owner transition commit."
    }
  } catch {
    throw "PARENT_STATE_PROVENANCE_INVALID: prior owner transition is invalid: $($_.Exception.Message)"
  } finally {
    if ($null -ne $validatorLibrary) {
      Remove-Module -ModuleInfo $validatorLibrary -Force
    }
  }
}

function Get-NormalizedLocalRemotePath {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$RemoteUrl
  )

  if (
    [string]::IsNullOrWhiteSpace($RemoteUrl) -or
    $RemoteUrl -match '^[A-Za-z][A-Za-z0-9+.-]*://' -or
    $RemoteUrl -match '^[^/\\]+@[^:]+:'
  ) {
    return $null
  }
  if ([IO.Path]::IsPathRooted($RemoteUrl)) {
    return [IO.Path]::GetFullPath($RemoteUrl).TrimEnd("\", "/")
  }
  return [IO.Path]::GetFullPath((Join-Path $Root $RemoteUrl)).TrimEnd("\", "/")
}

function Get-DanioImmutableProductionTransportTarget {
  param([Parameter(Mandatory = $true)][string]$Root)

  $urlText = Invoke-DanioGit `
    -Root $Root `
    -Arguments @("remote", "get-url", "--push", "--all", "origin") `
    -FailureCode "PUSH_OUTCOME_UNKNOWN"
  $urls = @($urlText -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
  if (
    $urls.Count -ne 1 -or
    [string]$urls[0] -match '^[\-]' -or
    [string]$urls[0] -match '[\x00-\x1F\x7F]'
  ) {
    throw "PUSH_OUTCOME_UNKNOWN: immutable origin push endpoint is not singular and safe."
  }
  $captured = [string]$urls[0]
  if (
    $captured -match '^[A-Za-z][A-Za-z0-9+.-]*://' -or
    $captured -match '^[^/\\]+@[^:]+'
  ) {
    return $captured
  }
  $local = Get-NormalizedLocalRemotePath -Root $Root -RemoteUrl $captured
  if ([string]::IsNullOrWhiteSpace($local)) {
    throw "PUSH_OUTCOME_UNKNOWN: local origin push endpoint cannot be canonicalized."
  }
  return $local
}

function Test-OrdinaryDirectory {
  param([Parameter(Mandatory = $true)][string]$Path)

  if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
    return $false
  }
  $item = Get-Item -LiteralPath $Path -Force
  return ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0
}

function Assert-DanioExactOwnershipSet {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string[]]$AllowedBranches,
    [Parameter(Mandatory = $true)][string[]]$AllowedWorktrees
  )

  $branchText = Invoke-DanioGit `
    -Root $Root `
    -Arguments @("for-each-ref", "--format=%(refname:short)", "refs/heads") `
    -FailureCode "STOP_PENDING"
  $observedBranches = @(
    $branchText -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
  )
  $registryText = Invoke-DanioGit `
    -Root $Root `
    -Arguments @("worktree", "list", "--porcelain") `
    -FailureCode "STOP_PENDING"
  $observedWorktrees = @(
    @($registryText -split "`r?`n") |
      Where-Object { $_ -clike "worktree *" } |
      ForEach-Object { $_.Substring("worktree ".Length).Replace("\", "/").TrimEnd("/") }
  )
  $normalizedAllowedWorktrees = @(
    $AllowedWorktrees | ForEach-Object { $_.Replace("\", "/").TrimEnd("/") }
  )
  if (
    $observedBranches.Count -ne $AllowedBranches.Count -or
    @($observedBranches | Where-Object { $AllowedBranches -cnotcontains $_ }).Count -ne 0 -or
    $observedWorktrees.Count -ne $normalizedAllowedWorktrees.Count
  ) {
    throw "STOP_PENDING: foreign local branch or worktree ownership exists."
  }
  foreach ($observedWorktree in $observedWorktrees) {
    $matches = @(
      $normalizedAllowedWorktrees | Where-Object {
        [string]::Equals($_, $observedWorktree, [StringComparison]::OrdinalIgnoreCase)
      }
    )
    if ($matches.Count -ne 1) {
      throw "STOP_PENDING: foreign local branch or worktree ownership exists."
    }
  }
}

function Assert-DisposableTestTransport {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$BaseCommit
  )

  if ($env:DANIO_AUTONOMY_TEST_MODE -cne "1") {
    throw "TEST_TRANSPORT_FORBIDDEN: test transport requires DANIO_AUTONOMY_TEST_MODE=1."
  }
  $tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd("\", "/")
  $rootFull = [IO.Path]::GetFullPath($Root).TrimEnd("\", "/")
  if (
    -not $rootFull.StartsWith("$tempBase\", [StringComparison]::OrdinalIgnoreCase) -or
    -not (Test-OrdinaryDirectory -Path $rootFull)
  ) {
    throw "TEST_TRANSPORT_FORBIDDEN: fixture repository must be an ordinary directory below the system temp root."
  }
  $fetchText = Invoke-DanioGit -Root $rootFull -Arguments @("remote", "get-url", "--all", "origin")
  $pushText = Invoke-DanioGit -Root $rootFull -Arguments @("remote", "get-url", "--push", "--all", "origin")
  $fetchUrls = @($fetchText -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
  $pushUrls = @($pushText -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
  if ($fetchUrls.Count -ne 1 -or $pushUrls.Count -ne 1) {
    throw "TEST_TRANSPORT_FORBIDDEN: fixture origin must have one fetch and push endpoint."
  }
  $remotePath = Get-NormalizedLocalRemotePath -Root $rootFull -RemoteUrl $fetchUrls[0]
  $pushPath = Get-NormalizedLocalRemotePath -Root $rootFull -RemoteUrl $pushUrls[0]
  if (
    $null -eq $remotePath -or
    $null -eq $pushPath -or
    -not [string]::Equals($remotePath, $pushPath, [StringComparison]::OrdinalIgnoreCase) -or
    -not $remotePath.StartsWith("$tempBase\", [StringComparison]::OrdinalIgnoreCase) -or
    -not (Test-OrdinaryDirectory -Path $remotePath)
  ) {
    throw "TEST_TRANSPORT_FORBIDDEN: fixture transport must be one local ordinary bare repository."
  }
  $isBare = Invoke-DanioGit -Root $remotePath -Arguments @("rev-parse", "--is-bare-repository")
  $remoteTip = Invoke-DanioGit -Root $rootFull -Arguments @("rev-parse", "origin/main")
  if ($isBare -cne "true" -or $remoteTip -cne $BaseCommit) {
    throw "TEST_TRANSPORT_FORBIDDEN: fixture remote is not aligned and bare."
  }
  return $remotePath
}

function Get-DanioReleaseProofBeforeMutation {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)]$PreviousState,
    [Parameter(Mandatory = $true)][string]$Action
  )

  $releaseActions = @("closeout", "pause", "stop", "complete", "finalization_stop")
  if ($releaseActions -cnotcontains $Action) {
    if (-not [string]::IsNullOrWhiteSpace($LeaseReleaseJson)) {
      throw "LEASE_RELEASE_INVALID: release JSON is forbidden for '$Action'."
    }
    return $false
  }
  if ([string]::IsNullOrWhiteSpace($LeaseReleaseJson)) {
    throw "STOP_PENDING: exact lease release proof is required before mutation."
  }
  try {
    $release = $LeaseReleaseJson | ConvertFrom-Json
  } catch {
    throw "LEASE_RELEASE_INVALID: lease release JSON is malformed."
  }
  if ($null -eq $release) {
    throw "LEASE_RELEASE_INVALID: lease release JSON cannot be null."
  }
  $names = @($release.PSObject.Properties | ForEach-Object { $_.Name })
  $requiredNames = @("owner_token", "android_released", "processes_released")
  if (
    $names.Count -ne $requiredNames.Count -or
    @($requiredNames | Where-Object { $names -cnotcontains $_ }).Count -ne 0 -or
    $null -eq $PreviousState.owner -or
    [string]$release.owner_token -cne [string]$PreviousState.owner.token_sha256 -or
    $release.android_released -isnot [bool] -or
    $release.processes_released -isnot [bool]
  ) {
    throw "LEASE_RELEASE_INVALID: lease release fields or owner token are invalid."
  }
  $worktreeText = Invoke-DanioGit `
    -Root $Root `
    -Arguments @("worktree", "list", "--porcelain") `
    -FailureCode "STOP_PENDING"
  $ownedPath = ([string]$PreviousState.owner.worktree_path).Replace("\", "/").TrimEnd("/")
  $registered = @(
    @($worktreeText -split "`r?`n") |
      Where-Object { $_ -clike "worktree *" } |
      ForEach-Object { $_.Substring("worktree ".Length).Replace("\", "/").TrimEnd("/") } |
      Where-Object { [string]::Equals($_, $ownedPath, [StringComparison]::OrdinalIgnoreCase) }
  ).Count -gt 0
  $branchProbe = Invoke-DanioGitProbe `
    -Root $Root `
    -Arguments @("show-ref", "--verify", "--quiet", "refs/heads/$($PreviousState.owner.branch_name)")
  if (@(0, 1) -cnotcontains $branchProbe.exit_code) {
    throw "STOP_PENDING: owned branch release is ambiguous."
  }
  try {
    $ownedWorktreeExists = Test-Path -LiteralPath ([string]$PreviousState.owner.worktree_path)
  } catch {
    throw "STOP_PENDING: owned worktree release cannot be observed safely: $($_.Exception.Message)"
  }
  $released = (
    $branchProbe.exit_code -eq 1 -and
    -not $registered -and
    -not $ownedWorktreeExists -and
    [bool]$release.android_released -and
    [bool]$release.processes_released
  )
  if (-not $released) {
    throw "STOP_PENDING: exact owner branch, worktree, Android, and process release is unproven."
  }
  Assert-DanioExactOwnershipSet `
    -Root $Root `
    -AllowedBranches @("main") `
    -AllowedWorktrees @($Root)
  return $true
}

function Get-DanioRetainedOwnerBeforeMutation {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)]$PreviousState,
    [Parameter(Mandatory = $true)][string]$ParentCommit
  )

  if ($null -eq $PreviousState.owner) {
    throw "STOP_PENDING: finalization owner is missing."
  }
  $ownerPath = [string]$PreviousState.owner.worktree_path
  try {
    $ordinaryOwnerPath = Test-OrdinaryDirectory -Path $ownerPath
  } catch {
    throw "STOP_PENDING: retained owner filesystem observation failed: $($_.Exception.Message)"
  }
  if (-not $ordinaryOwnerPath) {
    throw "STOP_PENDING: retained owner worktree is missing or reparsed."
  }
  $registryText = Invoke-DanioGit `
    -Root $Root `
    -Arguments @("worktree", "list", "--porcelain") `
    -FailureCode "STOP_PENDING"
  $normalizedOwnerPath = $ownerPath.Replace("\", "/").TrimEnd("/")
  $registeredCount = @(
    @($registryText -split "`r?`n") |
      Where-Object { $_ -clike "worktree *" } |
      ForEach-Object { $_.Substring("worktree ".Length).Replace("\", "/").TrimEnd("/") } |
      Where-Object {
        [string]::Equals($_, $normalizedOwnerPath, [StringComparison]::OrdinalIgnoreCase)
      }
  ).Count
  $ownerHead = Invoke-DanioGit -Root $ownerPath -Arguments @("rev-parse", "HEAD") -FailureCode "STOP_PENDING"
  $ownerBranch = Invoke-DanioGit -Root $ownerPath -Arguments @("branch", "--show-current") -FailureCode "STOP_PENDING"
  $ownerStatus = Invoke-DanioGit `
    -Root $ownerPath `
    -Arguments @("--no-optional-locks", "status", "--short", "-uall") `
    -FailureCode "STOP_PENDING"
  $branchCommit = Invoke-DanioGit `
    -Root $Root `
    -Arguments @("rev-parse", "refs/heads/$($PreviousState.owner.branch_name)") `
    -FailureCode "STOP_PENDING"
  $ownerAncestor = Invoke-DanioGitProbe `
    -Root $Root `
    -Arguments @("merge-base", "--is-ancestor", $ownerHead, $ParentCommit)
  if (
    $registeredCount -ne 1 -or
    $ownerHead -cne $branchCommit -or
    $ownerBranch -cne [string]$PreviousState.owner.branch_name -or
    -not [string]::IsNullOrWhiteSpace($ownerStatus) -or
    $ownerAncestor.exit_code -ne 0
  ) {
    throw "STOP_PENDING: retained owner branch/worktree is not exact, clean, and ancestral to the evidence parent."
  }
  Assert-DanioExactOwnershipSet `
    -Root $Root `
    -AllowedBranches @("main", [string]$PreviousState.owner.branch_name) `
    -AllowedWorktrees @($Root, $ownerPath)
  return [pscustomobject]@{
    branch_name = [string]$PreviousState.owner.branch_name
    worktree_path = $ownerPath
    parent_head = $ownerHead
  }
}

function Align-DanioRetainedOwner {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)]$RetainedOwner,
    [Parameter(Mandatory = $true)][string]$CandidateCommit
  )

  [void](Invoke-DanioGit `
    -Root ([string]$RetainedOwner.worktree_path) `
    -Arguments @("merge", "--ff-only", $CandidateCommit))
  $ownerHead = Invoke-DanioGit `
    -Root ([string]$RetainedOwner.worktree_path) `
    -Arguments @("rev-parse", "HEAD")
  $ownerBranch = Invoke-DanioGit `
    -Root ([string]$RetainedOwner.worktree_path) `
    -Arguments @("branch", "--show-current")
  $ownerStatus = Invoke-DanioGit `
    -Root ([string]$RetainedOwner.worktree_path) `
    -Arguments @("--no-optional-locks", "status", "--short", "-uall")
  $branchCommit = Invoke-DanioGit `
    -Root $Root `
    -Arguments @("rev-parse", "refs/heads/$($RetainedOwner.branch_name)")
  if (
    $ownerHead -cne $CandidateCommit -or
    $branchCommit -cne $CandidateCommit -or
    $ownerBranch -cne [string]$RetainedOwner.branch_name -or
    -not [string]::IsNullOrWhiteSpace($ownerStatus)
  ) {
    throw "TRANSITION_TRANSACTION_INVALID: retained owner did not fast-forward cleanly to the finalizing candidate."
  }
  Assert-DanioExactOwnershipSet `
    -Root $Root `
    -AllowedBranches @("main", [string]$RetainedOwner.branch_name) `
    -AllowedWorktrees @($Root, [string]$RetainedOwner.worktree_path)
}

function Invoke-TransitionValidation {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$Source,
    [Parameter(Mandatory = $true)][string]$BaseCommit,
    [Parameter(Mandatory = $true)][string]$TreeHash,
    [string]$Commit = "HEAD"
  )

  $leaseBase64 = [Convert]::ToBase64String(
    [Text.Encoding]::UTF8.GetBytes([string]$LeaseReleaseJson)
  )
  $escapedScript = $transitionScriptPath.Replace("'", "''")
  $escapedRoot = $Root.Replace("'", "''")
  $escapedSource = $Source.Replace("'", "''")
  $escapedCommit = $Commit.Replace("'", "''")
  $escapedEvidence = ([string]$EvidenceManifestPath).Replace("'", "''")
  $childCommand = @"
`$parameters = @{
  Source = '$escapedSource'
  RepositoryRoot = '$escapedRoot'
  ExpectedParentCommit = '$BaseCommit'
  ExpectedStagedTreeHash = '$TreeHash'
  Commit = '$escapedCommit'
}
if (-not [string]::IsNullOrWhiteSpace('$escapedEvidence')) {
  `$parameters.EvidenceManifestPath = '$escapedEvidence'
}
`$leaseJson = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('$leaseBase64'))
if (-not [string]::IsNullOrWhiteSpace(`$leaseJson)) {
  `$parameters.LeaseReleaseJson = `$leaseJson
}
& '$escapedScript' @parameters
"@
  $encodedCommand = [Convert]::ToBase64String(
    [Text.Encoding]::Unicode.GetBytes($childCommand)
  )
  $priorPreference = $ErrorActionPreference
  try {
    $ErrorActionPreference = "Continue"
    $output = @(& powershell.exe `
      -NoProfile `
      -NonInteractive `
      -ExecutionPolicy Bypass `
      -EncodedCommand $encodedCommand `
      2>$null)
    $exitCode = $LASTEXITCODE
  } finally {
    $ErrorActionPreference = $priorPreference
  }
  if ($output.Count -ne 1) {
    throw "TRANSITION_VALIDATION_FAILED: $Source validator did not emit one report."
  }
  try {
    $report = $output[0] | ConvertFrom-Json
  } catch {
    throw "TRANSITION_VALIDATION_FAILED: $Source validator output is malformed."
  }
  if ($exitCode -ne 0 -or -not $report.valid) {
    throw "$($report.code): $($report.details -join '; ')"
  }
}

function Invoke-DocsProfile {
  param([Parameter(Mandatory = $true)][string]$Root)

  $appRoot = Join-Path $Root "apps/aquarium_app"
  $gate = Join-Path $appRoot "scripts/quality_gates/run_local_quality_gate.ps1"
  if (-not (Test-Path -LiteralPath $gate -PathType Leaf)) {
    throw "DOCS_PROFILE_FAILED: Docs gate is missing."
  }
  Push-Location -LiteralPath $appRoot
  $priorPreference = $ErrorActionPreference
  try {
    $ErrorActionPreference = "Continue"
    $output = @(& powershell.exe `
      -NoProfile `
      -NonInteractive `
      -ExecutionPolicy Bypass `
      -File $gate `
      -Profile Docs `
      2>&1)
    $exitCode = $LASTEXITCODE
  } finally {
    $ErrorActionPreference = $priorPreference
    Pop-Location
  }
  if ($exitCode -ne 0) {
    throw "DOCS_PROFILE_FAILED: Docs profile exited $exitCode`: $($output -join ' ')"
  }
}

$result = [ordered]@{
  document_type = "danio_transition_commit_result"
  schema_version = 1
  completed_at_utc = $null
  accepted = $false
  code = "TRANSITION_TRANSACTION_INVALID"
  details = @()
  transition_action = $null
  from_mode = $null
  to_mode = $null
  run_id = $null
  work_unit_id = $null
  expected_state_revision = $ExpectedStateRevision
  candidate_state_revision = $null
  evidence_manifest_path = if ([string]::IsNullOrWhiteSpace($EvidenceManifestPath)) { $null } else { $EvidenceManifestPath }
  owner_token_sha256 = $null
  mutations_performed = $false
  push_attempted = $false
  push_attempt_count = 0
  push_timed_out = $false
  push_termination_confirmed = $null
  push_rejection_proven = $false
  retry_performed = $false
  reconciliation_status = "not_attempted"
  candidate_charge_consumed = $false
  durable_charge_consumption_proven = $false
  owner_retained = $null
  owner_released = $null
  owned_cleanup_proven = $false
  artifacts_preserved = $false
  candidate_commit = $null
  staged_tree_hash = $null
  origin_main_commit = $null
  test_transport_outcome = if ([string]::IsNullOrWhiteSpace($TestTransportOutcome)) { $null } else { $TestTransportOutcome }
}

try {
  if (
    -not [string]::IsNullOrWhiteSpace($TestTransportOutcome) -and
    $allowedTestOutcomes -cnotcontains $TestTransportOutcome
  ) {
    throw "TEST_TRANSPORT_FORBIDDEN: unsupported test transport outcome."
  }
  if ($ExpectedStateRevision -le 0 -or $ExpectedOriginMainCommit -cnotmatch '^[0-9a-f]{40}$') {
    throw "TRANSITION_TRANSACTION_INVALID: expected revision or origin commit is malformed."
  }
  try {
    $candidateState = $NextRunStateJson | ConvertFrom-Json
  } catch {
    throw "TRANSITION_TRANSACTION_INVALID: next run state JSON is malformed."
  }

  $resolvedRoot = Resolve-DanioRepositoryRoot -RepositoryRoot $RepositoryRoot
  $branch = Invoke-DanioGit -Root $resolvedRoot -Arguments @("branch", "--show-current")
  $head = Invoke-DanioGit -Root $resolvedRoot -Arguments @("rev-parse", "HEAD")
  $main = Invoke-DanioGit -Root $resolvedRoot -Arguments @("rev-parse", "main")
  $originMain = Invoke-DanioGit -Root $resolvedRoot -Arguments @("rev-parse", "origin/main")
  $result.origin_main_commit = $originMain
  if (
    $branch -cne "main" -or
    $head -cne $main -or
    $head -cne $ExpectedOriginMainCommit -or
    $originMain -cne $ExpectedOriginMainCommit
  ) {
    throw "REMOTE_MOVED: local main is not at the expected evidence checkpoint."
  }
  $stagedBefore = Invoke-DanioGit -Root $resolvedRoot -Arguments @("diff", "--cached", "--name-only", "--")
  $dirtyBefore = @(
    (Invoke-DanioGit -Root $resolvedRoot -Arguments @("diff", "--name-only", "--")) -split "`r?`n" |
      Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
  )
  $untrackedBefore = Invoke-DanioGit `
    -Root $resolvedRoot `
    -Arguments @("ls-files", "--others", "--exclude-standard")
  $allowedPreexistingPaths = @($handoffPath, $sliceLogPath)
  if (
    -not [string]::IsNullOrWhiteSpace($stagedBefore) -or
    -not [string]::IsNullOrWhiteSpace($untrackedBefore) -or
    @($dirtyBefore | Where-Object { $allowedPreexistingPaths -cnotcontains $_ }).Count -ne 0
  ) {
    throw "TRANSITION_TRANSACTION_INVALID: pre-existing dirt is not limited to closeout documents (staged='$stagedBefore'; dirty='$($dirtyBefore -join ',')'; untracked='$untrackedBefore')."
  }

  $previousStateJson = Invoke-DanioGit `
    -Root $resolvedRoot `
    -Arguments @("show", "$head`:$statePath")
  try {
    $previousState = $previousStateJson | ConvertFrom-Json
  } catch {
    throw "TRANSITION_TRANSACTION_INVALID: parent run state is malformed."
  }
  $result.durable_charge_consumption_proven = $false
  $action = [string]$candidateState.transition.action
  $task9Actions = @("closeout", "pause", "stop", "finalize", "complete", "finalization_stop")
  if ($task9Actions -cnotcontains $action) {
    throw "TRANSITION_TRANSACTION_INVALID: transition action '$action' is outside the Task 9 commit boundary."
  }
  $result.transition_action = $action
  $result.from_mode = [string]$previousState.mode
  $result.to_mode = [string]$candidateState.mode
  $result.run_id = [string]$candidateState.run_id
  $result.work_unit_id = [string]$previousState.cursor.work_unit_id
  $result.candidate_state_revision = [int64]$candidateState.state_revision
  if ($null -ne $previousState.owner) {
    $result.owner_token_sha256 = [string]$previousState.owner.token_sha256
    $result.owner_retained = $true
    $result.owner_released = $false
  }
  if (
    [int64]$previousState.state_revision -ne $ExpectedStateRevision -or
    [int64]$candidateState.state_revision -ne ($ExpectedStateRevision + 1) -or
    [int64]$candidateState.transition.parent_state_revision -ne $ExpectedStateRevision
  ) {
    throw "TRANSITION_TRANSACTION_INVALID: state revision compare-and-swap failed."
  }
  if (
    [string]$previousState.authorization.repository_root -cne
      $resolvedRoot.Replace("\", "/").TrimEnd("/")
  ) {
    throw "REPO_ROOT_INVALID: execution root differs from durable authorization."
  }

  $expectedCandidateAuthority = Get-DanioParentAuthority `
    -Root $resolvedRoot `
    -ParentCommit $head
  Assert-DanioParentStateTransitionPreflight `
    -Root $resolvedRoot `
    -ParentCommit $head `
    -ObservedState $previousState
  $preflightParameters = @{
    PreviousState = $previousState
    CandidateState = $candidateState
    ExpectedCandidateAuthority = $expectedCandidateAuthority
  }
  if ($null -ne $previousState.owner) {
    $preflightParameters.LeaseRelease = [pscustomobject]@{
      owner_token = [string]$previousState.owner.token_sha256
      writer_released = $true
      worktree_released = $true
      android_released = $true
      processes_released = $true
    }
  }
  $preflight = Test-DanioRunStateTransition @preflightParameters
  if (
    -not $preflight.valid -and
    @("STOP_PENDING", "FINALIZATION_SCOPE_INVALID") -cnotcontains [string]$preflight.code
  ) {
    throw "$($preflight.code): $($preflight.details -join '; ')"
  }
  $retainedOwner = $null
  if ($action -ceq "finalize") {
    $retainedOwner = Get-DanioRetainedOwnerBeforeMutation `
      -Root $resolvedRoot `
      -PreviousState $previousState `
      -ParentCommit $head
  }
  $result.owned_cleanup_proven = Get-DanioReleaseProofBeforeMutation `
    -Root $resolvedRoot `
    -PreviousState $previousState `
    -Action $action

  $transportTarget = if ([string]::IsNullOrWhiteSpace($TestTransportOutcome)) {
    Get-DanioImmutableProductionTransportTarget -Root $resolvedRoot
  } else {
    Assert-DisposableTestTransport -Root $resolvedRoot -BaseCommit $originMain
  }
  $result.mutations_performed = $true
  $preflightFetch = Invoke-DanioBoundedFetch `
    -Root $resolvedRoot `
    -TransportTarget $transportTarget
  if (
    -not [bool]$preflightFetch.termination_confirmed -or
    [bool]$preflightFetch.timed_out -or
    $preflightFetch.exit_code -ne 0
  ) {
    $result.owner_retained = $null
    $result.owner_released = $null
    throw "PUSH_OUTCOME_UNKNOWN: fresh evidence-checkpoint alignment is unprovable before mutation."
  }
  $originMain = Invoke-DanioGit -Root $resolvedRoot -Arguments @("rev-parse", "origin/main")
  $result.origin_main_commit = $originMain
  if ($head -cne $originMain -or $originMain -cne $ExpectedOriginMainCommit) {
    $result.owner_retained = $null
    $result.owner_released = $null
    $result.durable_charge_consumption_proven = $false
    throw "REMOTE_MOVED: evidence checkpoint is not the fresh origin/main tip."
  }
  $result.durable_charge_consumption_proven = (
    [string]$previousState.budget.current_charge.status -ceq "consumed"
  )

  $stateAbsolutePath = Join-Path $resolvedRoot $statePath
  $stateDirectory = Split-Path -Parent $stateAbsolutePath
  [IO.Directory]::CreateDirectory($stateDirectory) | Out-Null
  [IO.File]::WriteAllText(
    $stateAbsolutePath,
    ($candidateState | ConvertTo-Json -Depth 100),
    (New-Object Text.UTF8Encoding($false))
  )
  $result.mutations_performed = $true
  $pathsToStage = @($statePath) + @($dirtyBefore)
  [void](Invoke-DanioGit -Root $resolvedRoot -Arguments (@("add", "--") + $pathsToStage))
  $stagedPaths = @(
    (Invoke-DanioGit -Root $resolvedRoot -Arguments @("diff", "--cached", "--name-only", "--")) -split "`r?`n" |
      Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
  )
  if (
    $stagedPaths.Count -ne $pathsToStage.Count -or
    @($stagedPaths | Where-Object { $pathsToStage -cnotcontains $_ }).Count -ne 0 -or
    $stagedPaths -cnotcontains $statePath
  ) {
    throw "TRANSITION_TRANSACTION_INVALID: staged paths differ from exact closeout scope."
  }
  $unstagedAfterWrite = Invoke-DanioGit -Root $resolvedRoot -Arguments @("diff", "--name-only", "--")
  $untrackedAfterWrite = Invoke-DanioGit `
    -Root $resolvedRoot `
    -Arguments @("ls-files", "--others", "--exclude-standard")
  if (
    -not [string]::IsNullOrWhiteSpace($unstagedAfterWrite) -or
    -not [string]::IsNullOrWhiteSpace($untrackedAfterWrite)
  ) {
    throw "TRANSITION_TRANSACTION_INVALID: unstaged or untracked output remains after staging."
  }
  $stagedTree = Invoke-DanioGit -Root $resolvedRoot -Arguments @("write-tree")
  $result.staged_tree_hash = $stagedTree
  Invoke-TransitionValidation `
    -Root $resolvedRoot `
    -Source "Staged" `
    -BaseCommit $originMain `
    -TreeHash $stagedTree

  Invoke-DocsProfile -Root $resolvedRoot
  $postGateTree = Invoke-DanioGit -Root $resolvedRoot -Arguments @("write-tree")
  $postGateUnstaged = Invoke-DanioGit -Root $resolvedRoot -Arguments @("diff", "--name-only", "--")
  $postGateUntracked = Invoke-DanioGit `
    -Root $resolvedRoot `
    -Arguments @("ls-files", "--others", "--exclude-standard")
  if (
    $postGateTree -cne $stagedTree -or
    -not [string]::IsNullOrWhiteSpace($postGateUnstaged) -or
    -not [string]::IsNullOrWhiteSpace($postGateUntracked)
  ) {
    throw "DOCS_PROFILE_FAILED: Docs gate moved the staged tree or left output."
  }
  Invoke-TransitionValidation `
    -Root $resolvedRoot `
    -Source "Staged" `
    -BaseCommit $originMain `
    -TreeHash $stagedTree

  $verifiedAt = Format-StrictUtc -Value ([DateTimeOffset]::UtcNow)
  $evidenceTrailer = if ([string]::IsNullOrWhiteSpace($EvidenceManifestPath)) {
    "none"
  } else {
    $EvidenceManifestPath
  }
  $trailerBlock = @"
Danio-State-Tree: $stagedTree
Danio-State-Validation: pass
Danio-Docs-Profile: pass
Danio-Verified-At: $verifiedAt
Danio-Evidence-Manifest: $evidenceTrailer
"@
  [void](Invoke-DanioGit `
    -Root $resolvedRoot `
    -Arguments @("commit", "-m", "chore: commit autonomous $action transition", "-m", $trailerBlock))
  $candidateCommit = Invoke-DanioGit -Root $resolvedRoot -Arguments @("rev-parse", "HEAD")
  $result.candidate_commit = $candidateCommit
  $result.artifacts_preserved = $true
  $result.candidate_charge_consumed = (
    [int64]$candidateState.budget.consumed_units -eq
      ([int64]$previousState.budget.consumed_units + 1)
  )
  Invoke-TransitionValidation `
    -Root $resolvedRoot `
    -Source "Committed" `
    -BaseCommit $originMain `
    -TreeHash $stagedTree `
    -Commit $candidateCommit

  $skipPush = @("rejected", "unknown_not_accepted") -ccontains $TestTransportOutcome
  $definiteRejection = $TestTransportOutcome -ceq "rejected"
  if ($definiteRejection) {
    $result.push_rejection_proven = $true
  }
  $skipReconciliation = $false
  if (-not $skipPush) {
    $result.push_attempted = $true
    $result.push_attempt_count = 1
    $pushProbe = Invoke-DanioBoundedPush `
      -Root $resolvedRoot `
      -TransportTarget $transportTarget `
      -CandidateCommit $candidateCommit
    if ($TestTransportOutcome -ceq "unknown_unresolved") {
      $pushProbe = [pscustomobject]@{
        timed_out = $true
        termination_confirmed = $false
        exit_code = $null
        stdout = ""
        stderr = "Injected unresolved process-tree termination evidence."
        output = "Injected unresolved process-tree termination evidence."
      }
    }
    $result.push_timed_out = [bool]$pushProbe.timed_out
    $result.push_termination_confirmed = [bool]$pushProbe.termination_confirmed
    $explicitRejection = (
      [bool]$pushProbe.termination_confirmed -and
      -not [bool]$pushProbe.timed_out -and
      $pushProbe.exit_code -ne 0 -and
      (Test-DanioExplicitRemoteRejection `
        -Stdout ([string]$pushProbe.stdout) `
        -CandidateCommit $candidateCommit)
    )
    $result.push_rejection_proven = $explicitRejection
    if (-not [bool]$pushProbe.termination_confirmed) {
      if ($action -cne "finalize") {
        $result.owner_retained = $null
        $result.owner_released = $null
      }
      $result.code = "PUSH_OUTCOME_UNKNOWN"
      $result.reconciliation_status = "unknown"
      $result.details = @("Push termination is unproven; candidate and evidence artifacts were preserved.")
      $skipReconciliation = $true
    } elseif ($pushProbe.timed_out) {
      if ($action -cne "finalize") {
        $result.owner_retained = $null
        $result.owner_released = $null
      }
      $result.code = "PUSH_OUTCOME_UNKNOWN"
    } elseif ($pushProbe.exit_code -ne 0 -and $explicitRejection) {
      $definiteRejection = $true
    }
  }

  if (-not $skipReconciliation) {
    $fetchProbe = Invoke-DanioBoundedFetch `
      -Root $resolvedRoot `
      -TransportTarget $transportTarget
    if (
      -not [bool]$fetchProbe.termination_confirmed -or
      [bool]$fetchProbe.timed_out -or
      $fetchProbe.exit_code -ne 0
    ) {
      if ($action -cne "finalize") {
        $result.owner_retained = $null
        $result.owner_released = $null
      }
      $result.code = "PUSH_OUTCOME_UNKNOWN"
      $result.reconciliation_status = "unknown"
      $result.details = @("Fresh origin/main history is unprovable; candidate artifacts were preserved.")
    } else {
      $remoteTip = Invoke-DanioGit -Root $resolvedRoot -Arguments @("rev-parse", "origin/main")
      $result.origin_main_commit = $remoteTip
      if ($remoteTip -ceq $candidateCommit) {
        $result.reconciliation_status = "accepted"
        $result.owner_retained = $null -ne $candidateState.owner
        $result.owner_released = $null -eq $candidateState.owner
        $result.durable_charge_consumption_proven = (
          [bool]$result.durable_charge_consumption_proven -or
          [bool]$result.candidate_charge_consumed
        )
        $alignedHead = Invoke-DanioGit -Root $resolvedRoot -Arguments @("rev-parse", "HEAD")
        $alignedMain = Invoke-DanioGit -Root $resolvedRoot -Arguments @("rev-parse", "main")
        $alignedBranch = Invoke-DanioGit -Root $resolvedRoot -Arguments @("branch", "--show-current")
        $alignedStatus = Invoke-DanioGit `
          -Root $resolvedRoot `
          -Arguments @("--no-optional-locks", "status", "--short", "-uall")
        if (
          $alignedHead -cne $candidateCommit -or
          $alignedMain -cne $candidateCommit -or
          $alignedBranch -cne "main" -or
          -not [string]::IsNullOrWhiteSpace($alignedStatus)
        ) {
          $result.code = "REMOTE_MOVED"
          $result.reconciliation_status = "local_alignment_failed"
          $result.details = @("Remote accepted the transition, but local main is not safely aligned.")
        } else {
          $ownerAlignmentProven = $true
          if ($action -ceq "finalize") {
            try {
              Align-DanioRetainedOwner `
                -Root $resolvedRoot `
                -RetainedOwner $retainedOwner `
                -CandidateCommit $candidateCommit
            } catch {
              $ownerAlignmentProven = $false
              $result.code = "REMOTE_MOVED"
              $result.reconciliation_status = "local_alignment_failed"
              $result.details = @("Remote accepted the transition, but retained-owner alignment failed: $($_.Exception.Message)")
            }
          } else {
            try {
              Assert-DanioExactOwnershipSet `
                -Root $resolvedRoot `
                -AllowedBranches @("main") `
                -AllowedWorktrees @($resolvedRoot)
            } catch {
              $ownerAlignmentProven = $false
              $result.code = "REMOTE_MOVED"
              $result.reconciliation_status = "local_alignment_failed"
              $result.details = @("Remote accepted the transition, but post-push ownership is ambiguous: $($_.Exception.Message)")
            }
          }
          if ($ownerAlignmentProven) {
            $result.accepted = $true
            $result.code = "TRANSITION_COMMITTED"
            $result.reconciliation_status = "accepted"
            $result.details = @("The exact transition candidate is clean and aligned on local and remote main.")
            $result.durable_charge_consumption_proven = (
              [bool]$result.durable_charge_consumption_proven -or
              [bool]$result.candidate_charge_consumed
            )
          }
        }
      } else {
        $reachability = Invoke-DanioGitProbe `
          -Root $resolvedRoot `
          -Arguments @("merge-base", "--is-ancestor", $candidateCommit, $remoteTip)
        if ($reachability.exit_code -eq 0) {
          $result.owner_retained = $null -ne $candidateState.owner
          $result.owner_released = $null -eq $candidateState.owner
          $result.durable_charge_consumption_proven = (
            [bool]$result.durable_charge_consumption_proven -or
            [bool]$result.candidate_charge_consumed
          )
          $result.code = "REMOTE_MOVED"
          $result.reconciliation_status = "remote_moved"
          $result.details = @("Origin/main contains and advanced beyond the preserved transition candidate.")
        } elseif ($reachability.exit_code -eq 1 -and $definiteRejection) {
          $remoteStateProbe = Invoke-DanioGitProbe `
            -Root $resolvedRoot `
            -Arguments @("show", "$remoteTip`:$statePath")
          if ($remoteStateProbe.exit_code -eq 0) {
            try {
              $remoteState = $remoteStateProbe.output | ConvertFrom-Json
              $remoteStateValidation = Test-DanioRunState -State $remoteState
              if (
                $remoteStateValidation.valid -and
                $null -ne $remoteState.owner -and
                [string]$remoteState.owner.token_sha256 -ceq [string]$previousState.owner.token_sha256
              ) {
                $result.owner_retained = $true
                $result.owner_released = $false
              } else {
                $result.owner_retained = $null
                $result.owner_released = $null
              }
            } catch {
              $result.owner_retained = $null
              $result.owner_released = $null
            }
          } else {
            $result.owner_retained = $null
            $result.owner_released = $null
          }
          $result.code = "REMOTE_MOVED"
          $result.reconciliation_status = "remote_moved"
          $result.details = @("Origin/main does not equal the preserved transition candidate.")
        } else {
          if ($action -cne "finalize") {
            $result.owner_retained = $null
            $result.owner_released = $null
          }
          $result.code = "PUSH_OUTCOME_UNKNOWN"
          $result.reconciliation_status = "unknown"
          $result.details = @("Candidate acceptance or absence is not proven; artifacts were preserved.")
        }
      }
    }
  }
} catch {
  $message = $_.Exception.Message
  $codeMatch = [regex]::Match($message, '^(?<code>[A-Z][A-Z0-9_]*):')
  $result.code = if ($codeMatch.Success) {
    $codeMatch.Groups["code"].Value
  } else {
    "TRANSITION_TRANSACTION_INVALID"
  }
  $result.details = @($message)
  if ($null -ne $result.candidate_commit -or [bool]$result.mutations_performed) {
    $result.artifacts_preserved = $true
  }
} finally {
  $result.completed_at_utc = Format-StrictUtc -Value ([DateTimeOffset]::UtcNow)
}

Write-Output ([pscustomobject]$result | ConvertTo-Json -Depth 100 -Compress)
if ([bool]$result.accepted) {
  exit 0
}
exit 1
