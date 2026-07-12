[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$ClaimPlanJson,
  [string]$RepositoryRoot,
  [string]$TestTransportOutcome
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "DanioAutonomousCompletion.psm1"
$module = Import-Module -Name $modulePath -Force -PassThru
$statePath = "apps/aquarium_app/docs/agent/autonomous_completion/phone_completion_run_state.json"
$transitionScriptPath = Join-Path $PSScriptRoot "validate_autonomous_completion_transition.ps1"
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

function ConvertTo-ForwardSlashPath {
  param([Parameter(Mandatory = $true)][string]$Path)

  return $Path.Replace("\", "/").TrimEnd("/")
}

function ConvertTo-ExtendedPath {
  param([Parameter(Mandatory = $true)][string]$Path)

  $fullPath = [IO.Path]::GetFullPath($Path)
  if ($fullPath.StartsWith("\\?\", [StringComparison]::Ordinal)) {
    return $fullPath
  }
  if ($fullPath.StartsWith("\\", [StringComparison]::Ordinal)) {
    return "\\?\UNC\$($fullPath.Substring(2))"
  }
  return "\\?\$fullPath"
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
    [string]$FailureCode = "CLAIM_TRANSACTION_INVALID"
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

  $rootBase64 = [Convert]::ToBase64String(
    [Text.Encoding]::UTF8.GetBytes($Root)
  )
  $argumentsJson = ConvertTo-Json -InputObject @($Arguments) -Compress
  $argumentsBase64 = [Convert]::ToBase64String(
    [Text.Encoding]::UTF8.GetBytes($argumentsJson)
  )
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
  $encoded = [Convert]::ToBase64String(
    [Text.Encoding]::Unicode.GetBytes($childCommand)
  )
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
      throw "PUSH_OUTCOME_UNKNOWN: push process did not start."
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
    $stdout = if ($stdoutCompleted) { $stdoutTask.Result } else { "" }
    $stderr = if ($stderrCompleted) { $stderrTask.Result } else { "Push process tree or redirected streams did not terminate cleanly." }
    return [pscustomobject]@{
      timed_out = -not $completed
      termination_confirmed = $terminationConfirmed
      exit_code = if ($completed) { $process.ExitCode } else { $null }
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
    [int]$TimeoutSeconds = 60
  )

  return Invoke-DanioBoundedTransportGit `
    -Root $Root `
    -Arguments @("push", "--", $TransportTarget, "HEAD:main") `
    -TimeoutSeconds $TimeoutSeconds
}

function Invoke-DanioBoundedFetch {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string[]]$Arguments,
    [int]$TimeoutSeconds = 60
  )

  return Invoke-DanioBoundedTransportGit `
    -Root $Root `
    -Arguments $Arguments `
    -TimeoutSeconds $TimeoutSeconds
}

function Restore-DanioRejectedIdentity {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$WorktreePath,
    [Parameter(Mandatory = $true)][string]$BranchRef,
    [Parameter(Mandatory = $true)][string]$ExpectedCommit
  )

  $branchName = $BranchRef.Substring("refs/heads/".Length)
  $branchProbe = Invoke-DanioGitProbe `
    -Root $Root `
    -Arguments @("show-ref", "--verify", "--quiet", $BranchRef)
  if ($branchProbe.exit_code -eq 1) {
    $zeroObject = "0" * $ExpectedCommit.Length
    $restoreRef = Invoke-DanioGitProbe `
      -Root $Root `
      -Arguments @("update-ref", $BranchRef, $ExpectedCommit, $zeroObject)
    if ($restoreRef.exit_code -ne 0) {
      throw "REJECTION_CLEANUP_PARTIAL: exact candidate ref restoration failed."
    }
  } elseif ($branchProbe.exit_code -ne 0) {
    throw "REJECTION_CLEANUP_PARTIAL: candidate ref restoration state is ambiguous."
  }

  $restoredRef = Invoke-DanioGit -Root $Root -Arguments @("rev-parse", $BranchRef)
  if ($restoredRef -cne $ExpectedCommit) {
    throw "REJECTION_CLEANUP_PARTIAL: candidate ref moved during restoration."
  }

  $extendedWorktreePath = ConvertTo-ExtendedPath -Path $WorktreePath
  if (-not (Test-Path -LiteralPath $extendedWorktreePath)) {
    $restoreWorktree = Invoke-DanioGitProbe `
      -Root $Root `
      -Arguments @("worktree", "add", $WorktreePath, $branchName)
    if ($restoreWorktree.exit_code -ne 0) {
      throw "REJECTION_CLEANUP_PARTIAL: exact candidate worktree restoration failed."
    }
  }

  $restoredHead = Invoke-DanioGit -Root $WorktreePath -Arguments @("rev-parse", "HEAD")
  $restoredBranch = Invoke-DanioGit -Root $WorktreePath -Arguments @("branch", "--show-current")
  $restoredStatus = Invoke-DanioGit `
    -Root $WorktreePath `
    -Arguments @("--no-optional-locks", "status", "--short", "-uall")
  $registry = Invoke-DanioGit -Root $Root -Arguments @("worktree", "list", "--porcelain")
  $normalizedPath = ConvertTo-ForwardSlashPath -Path $WorktreePath
  $registeredPathCount = @(
    $registry -split "`r?`n" |
      Where-Object {
        $_.StartsWith("worktree ", [StringComparison]::Ordinal) -and
        [string]::Equals(
          (ConvertTo-ForwardSlashPath -Path $_.Substring(9)),
          $normalizedPath,
          [StringComparison]::OrdinalIgnoreCase
        )
      }
  ).Count
  if (
    $restoredHead -cne $ExpectedCommit -or
    $restoredBranch -cne $branchName -or
    -not [string]::IsNullOrWhiteSpace($restoredStatus) -or
    $registeredPathCount -ne 1 -or
    -not (Test-OrdinaryDirectory -Path $WorktreePath)
  ) {
    throw "REJECTION_CLEANUP_PARTIAL: exact candidate identity restoration could not be proven."
  }
}

function Remove-DanioWorktreeWithPreparedRefDeletion {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$WorktreePath,
    [Parameter(Mandatory = $true)][string]$BranchRef,
    [Parameter(Mandatory = $true)][string]$ExpectedCommit,
    [bool]$InjectPostRemovalCommitFailure = $false
  )

  if (
    $Root.Contains('"') -or
    $BranchRef -notmatch '^refs/heads/[A-Za-z0-9._/-]+$' -or
    $ExpectedCommit -notmatch '^[0-9a-f]{40,64}$'
  ) {
    throw "REJECTION_CLEANUP_UNSAFE: ref transaction identity is malformed."
  }

  $startInfo = New-Object Diagnostics.ProcessStartInfo
  $startInfo.FileName = (Get-Command git.exe -ErrorAction Stop).Source
  $startInfo.Arguments = "-c core.longpaths=true -C `"$Root`" update-ref --stdin"
  $startInfo.UseShellExecute = $false
  $startInfo.CreateNoWindow = $true
  $startInfo.RedirectStandardInput = $true
  $startInfo.RedirectStandardOutput = $true
  $startInfo.RedirectStandardError = $true
  $process = New-Object Diagnostics.Process
  $process.StartInfo = $startInfo
  $processStarted = $false
  $prepared = $false
  $commitSent = $false
  $worktreeRemoved = $false
  $transactionFailure = $null
  try {
    if (-not $process.Start()) {
      throw "REJECTION_CLEANUP_UNSAFE: ref transaction did not start."
    }
    $processStarted = $true
    $process.StandardInput.NewLine = "`n"
    $process.StandardInput.WriteLine("start")
    $process.StandardInput.WriteLine("delete $BranchRef $ExpectedCommit")
    $process.StandardInput.WriteLine("prepare")
    $process.StandardInput.Flush()

    $startResponseTask = $process.StandardOutput.ReadLineAsync()
    if (-not $startResponseTask.Wait(5000)) {
      throw "REJECTION_CLEANUP_UNSAFE: exact ref deletion did not start."
    }
    $prepareResponseTask = $process.StandardOutput.ReadLineAsync()
    if (
      -not $prepareResponseTask.Wait(5000) -or
      [string]$startResponseTask.Result -cne "start: ok" -or
      [string]$prepareResponseTask.Result -cne "prepare: ok"
    ) {
      throw "REJECTION_CLEANUP_UNSAFE: exact ref deletion could not be prepared."
    }
    $prepared = $true

    $removeProbe = Invoke-DanioGitProbe `
      -Root $Root `
      -Arguments @("worktree", "remove", $WorktreePath)
    $worktreeRemoved = -not (
      Test-Path -LiteralPath (ConvertTo-ExtendedPath -Path $WorktreePath)
    )
    if ($removeProbe.exit_code -ne 0 -or -not $worktreeRemoved) {
      throw "REJECTION_CLEANUP_UNSAFE: rejected worktree removal failed while the ref deletion was prepared."
    }
    if ($InjectPostRemovalCommitFailure) {
      throw "REJECTION_CLEANUP_UNSAFE: injected post-removal ref transaction failure."
    }

    $process.StandardInput.WriteLine("commit")
    $process.StandardInput.Close()
    $commitSent = $true
    if (-not $process.WaitForExit(5000)) {
      throw "REJECTION_CLEANUP_UNSAFE: prepared ref deletion did not finish."
    }
    $remainingOutput = $process.StandardOutput.ReadToEnd().Trim()
    $errorOutput = $process.StandardError.ReadToEnd().Trim()
    if (
      $process.ExitCode -ne 0 -or
      $remainingOutput -cne "commit: ok" -or
      -not [string]::IsNullOrWhiteSpace($errorOutput)
    ) {
      throw "REJECTION_CLEANUP_UNSAFE: prepared ref deletion did not commit cleanly."
    }
  } catch {
    $transactionFailure = $_.Exception.Message
  } finally {
    if ($processStarted -and -not $process.HasExited) {
      if ($prepared -and -not $commitSent) {
        try {
          $process.StandardInput.WriteLine("abort")
          $process.StandardInput.Close()
        } catch {
        }
      } else {
        try { $process.StandardInput.Close() } catch { }
      }
      if (-not $process.WaitForExit(5000)) {
        try { $process.Kill() } catch { }
        [void]$process.WaitForExit(5000)
      }
    }
    $process.Dispose()
  }

  if ($null -ne $transactionFailure) {
    if ($worktreeRemoved) {
      try {
        Restore-DanioRejectedIdentity `
          -Root $Root `
          -WorktreePath $WorktreePath `
          -BranchRef $BranchRef `
          -ExpectedCommit $ExpectedCommit
      } catch {
        throw "REJECTION_CLEANUP_PARTIAL: $transactionFailure Recovery failed: $($_.Exception.Message)"
      }
      throw "REJECTION_CLEANUP_UNSAFE: $transactionFailure Exact branch and worktree artifacts were restored."
    }
    throw $transactionFailure
  }
}

function Read-DanioGitJsonBlob {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$Revision,
    [Parameter(Mandatory = $true)][string]$Path
  )

  $json = Invoke-DanioGit `
    -Root $Root `
    -Arguments @("show", "$Revision`:$Path")
  try {
    return $json | ConvertFrom-Json
  } catch {
    throw "STATE_BLOB_INVALID: '$Revision`:$Path' is not valid JSON."
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
  try {
    if ([IO.Path]::IsPathRooted($RemoteUrl)) {
      return [IO.Path]::GetFullPath($RemoteUrl).TrimEnd("\", "/")
    }
    return [IO.Path]::GetFullPath((Join-Path $Root $RemoteUrl)).TrimEnd("\", "/")
  } catch {
    return $null
  }
}

function Get-DanioImmutableProductionTransportTarget {
  param([Parameter(Mandatory = $true)][string]$Root)

  try {
    $pushUrlText = Invoke-DanioGit `
      -Root $Root `
      -Arguments @("remote", "get-url", "--push", "--all", "origin")
    $pushUrls = @(
      $pushUrlText -split "`r?`n" |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    )
    if (
      $pushUrls.Count -ne 1 -or
      [string]$pushUrls[0] -match '^[\-]' -or
      [string]$pushUrls[0] -match '[\x00-\x1F\x7F]'
    ) {
      throw "expanded origin push endpoint is not singular and safe"
    }
    $capturedUrl = [string]$pushUrls[0]
    $remoteLike = (
      $capturedUrl -match '^[A-Za-z][A-Za-z0-9+.-]*://' -or
      $capturedUrl -match '^[^/\\]+@[^:]+:'
    )
    if ($remoteLike) {
      return $capturedUrl
    }
    $localPath = Get-NormalizedLocalRemotePath `
      -Root $Root `
      -RemoteUrl $capturedUrl
    if ([string]::IsNullOrWhiteSpace($localPath)) {
      throw "local origin push endpoint could not be canonicalized"
    }
    return $localPath
  } catch {
    throw "PUSH_OUTCOME_UNKNOWN: the immutable production push endpoint could not be captured."
  }
}

function Test-OrdinaryDirectory {
  param([Parameter(Mandatory = $true)][string]$Path)

  if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
    return $false
  }
  $item = Get-Item -LiteralPath $Path -Force
  return ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0
}

function Test-ReparseFreePathBelow {
  param(
    [Parameter(Mandatory = $true)][string]$BasePath,
    [Parameter(Mandatory = $true)][string]$CandidatePath
  )

  $baseFull = [IO.Path]::GetFullPath($BasePath).TrimEnd("\", "/")
  $candidateFull = [IO.Path]::GetFullPath($CandidatePath).TrimEnd("\", "/")
  if (-not $candidateFull.StartsWith("$baseFull\", [StringComparison]::OrdinalIgnoreCase)) {
    return $false
  }
  if (-not (Test-OrdinaryDirectory -Path $baseFull)) {
    return $false
  }
  $relative = $candidateFull.Substring($baseFull.Length + 1)
  $current = $baseFull
  foreach ($segment in @($relative -split '[\\/]+')) {
    if ([string]::IsNullOrWhiteSpace($segment)) {
      return $false
    }
    $current = Join-Path $current $segment
    if (-not (Test-OrdinaryDirectory -Path $current)) {
      return $false
    }
  }
  return $true
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
    throw "TEST_TRANSPORT_FORBIDDEN: test transport requires an ordinary repository below the system temp root."
  }

  $fetchUrlText = Invoke-DanioGit `
    -Root $rootFull `
    -Arguments @("remote", "get-url", "--all", "origin")
  $pushUrlText = Invoke-DanioGit `
    -Root $rootFull `
    -Arguments @("remote", "get-url", "--push", "--all", "origin")
  $fetchUrls = @($fetchUrlText -split "`r?`n" | Where-Object {
    -not [string]::IsNullOrWhiteSpace($_)
  })
  $pushUrls = @($pushUrlText -split "`r?`n" | Where-Object {
    -not [string]::IsNullOrWhiteSpace($_)
  })
  if ($fetchUrls.Count -ne 1 -or $pushUrls.Count -ne 1) {
    throw "TEST_TRANSPORT_FORBIDDEN: fixture origin must have exactly one fetch URL and one push URL."
  }
  $remotePath = Get-NormalizedLocalRemotePath -Root $rootFull -RemoteUrl $fetchUrls[0]
  $pushPath = Get-NormalizedLocalRemotePath -Root $rootFull -RemoteUrl $pushUrls[0]
  $fixtureRoot = Split-Path -Parent $rootFull
  if (
    $null -eq $remotePath -or
    $null -eq $pushPath -or
    -not [string]::Equals($remotePath, $pushPath, [StringComparison]::OrdinalIgnoreCase) -or
    -not $remotePath.StartsWith("$fixtureRoot\", [StringComparison]::OrdinalIgnoreCase) -or
    -not (Test-ReparseFreePathBelow -BasePath $tempBase -CandidatePath $rootFull) -or
    -not (Test-ReparseFreePathBelow -BasePath $tempBase -CandidatePath $remotePath)
  ) {
    throw "TEST_TRANSPORT_FORBIDDEN: test transport requires one reparse-free local bare fetch/push remote inside the fixture root."
  }
  $isBare = Invoke-DanioGit -Root $remotePath -Arguments @("rev-parse", "--is-bare-repository")
  if ($isBare -cne "true") {
    throw "TEST_TRANSPORT_FORBIDDEN: disposable test remote is not bare."
  }
  $observedBase = Invoke-DanioGit -Root $rootFull -Arguments @("rev-parse", "origin/main")
  if ($observedBase -cne $BaseCommit) {
    throw "TEST_TRANSPORT_FORBIDDEN: disposable clone is not aligned at the claim base."
  }
  return [pscustomobject]@{
    temp_base = $tempBase
    fixture_root = $fixtureRoot
    remote_path = $remotePath
  }
}

function Test-DisposableEquivalentRoot {
  param(
    [Parameter(Mandatory = $true)][string]$ExecutionRoot,
    [Parameter(Mandatory = $true)][string]$AuthorizedRoot,
    [Parameter(Mandatory = $true)][string]$BaseCommit,
    [Parameter(Mandatory = $true)][string]$BaseTreeHash,
    [Parameter(Mandatory = $true)][string]$StateBlob,
    [Parameter(Mandatory = $true)]$TestGuard
  )

  $executionFull = [IO.Path]::GetFullPath($ExecutionRoot).TrimEnd("\", "/")
  $authorizedFull = [IO.Path]::GetFullPath($AuthorizedRoot).TrimEnd("\", "/")
  if ([string]::Equals($executionFull, $authorizedFull, [StringComparison]::OrdinalIgnoreCase)) {
    return $false
  }
  if (
    -not (Test-ReparseFreePathBelow `
      -BasePath ([string]$TestGuard.temp_base) `
      -CandidatePath $authorizedFull) -or
    -not [string]::Equals(
      (Split-Path -Parent $executionFull),
      (Split-Path -Parent $authorizedFull),
      [StringComparison]::OrdinalIgnoreCase
    ) -or
    -not [string]::Equals(
      (Split-Path -Parent $executionFull),
      [string]$TestGuard.fixture_root,
      [StringComparison]::OrdinalIgnoreCase
    )
  ) {
    throw "REPO_ROOT_INVALID: fixture clone root equivalence is not proven."
  }

  $authorizedUrl = Invoke-DanioGit -Root $authorizedFull -Arguments @("remote", "get-url", "origin")
  $authorizedRemote = Get-NormalizedLocalRemotePath -Root $authorizedFull -RemoteUrl $authorizedUrl
  if (-not [string]::Equals(
    $authorizedRemote,
    [string]$TestGuard.remote_path,
    [StringComparison]::OrdinalIgnoreCase
  )) {
    throw "REPO_ROOT_INVALID: fixture clones do not share one local bare remote."
  }
  $authorizedTree = Invoke-DanioGit -Root $authorizedFull -Arguments @("rev-parse", "$BaseCommit^{tree}")
  $authorizedState = Invoke-DanioGit -Root $authorizedFull -Arguments @("show", "$BaseCommit`:$statePath")
  if (
    $authorizedTree -cne $BaseTreeHash -or
    $authorizedState -cne $StateBlob
  ) {
    throw "REPO_ROOT_INVALID: fixture clone base, tree, or state evidence differs."
  }
  return $true
}

function Assert-WriterWorktreeContainment {
  param(
    [Parameter(Mandatory = $true)][string]$SavedProjectRoot,
    [Parameter(Mandatory = $true)][string]$WorktreePath
  )

  $savedFull = [IO.Path]::GetFullPath($SavedProjectRoot).TrimEnd("\", "/")
  $expectedRoot = [IO.Path]::GetFullPath(
    (Join-Path $savedFull ".codex-worktrees")
  ).TrimEnd("\", "/")
  $worktreeFull = [IO.Path]::GetFullPath($WorktreePath).TrimEnd("\", "/")
  if (
    -not $worktreeFull.StartsWith("$expectedRoot\", [StringComparison]::OrdinalIgnoreCase) -or
    [IO.Path]::GetPathRoot($worktreeFull) -cne [IO.Path]::GetPathRoot($expectedRoot)
  ) {
    throw "OWNER_IDENTITY_INVALID: writer worktree escapes the saved-project root."
  }
  foreach ($candidate in @($savedFull, $expectedRoot, $worktreeFull)) {
    if (Test-Path -LiteralPath $candidate) {
      $item = Get-Item -LiteralPath $candidate -Force
      if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "OWNER_IDENTITY_INVALID: writer worktree containment traverses a reparse point."
      }
    }
  }
  return $expectedRoot
}

function Get-WriterIdentityObservation {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$BranchName,
    [Parameter(Mandatory = $true)][string]$WorktreePath,
    [Parameter(Mandatory = $true)][string]$BaseCommit
  )

  $branchRef = "refs/heads/$BranchName"
  $branchProbe = Invoke-DanioGitProbe `
    -Root $Root `
    -Arguments @("show-ref", "--verify", "--hash", $branchRef)
  $branchAbsent = $branchProbe.exit_code -eq 128 -and
    $branchProbe.output -ceq "fatal: '$branchRef' - not a valid ref"
  if ($branchProbe.exit_code -ne 0 -and -not $branchAbsent) {
    return [pscustomobject]@{ status = "ambiguous"; detail = "Writer branch evidence is ambiguous." }
  }
  $branchExists = $branchProbe.exit_code -eq 0
  $pathExists = Test-Path -LiteralPath $WorktreePath
  $worktreeText = Invoke-DanioGit -Root $Root -Arguments @("worktree", "list", "--porcelain")
  $normalizedPath = ConvertTo-ForwardSlashPath -Path $WorktreePath
  $entries = New-Object System.Collections.Generic.List[object]
  $entry = $null
  foreach ($line in @($worktreeText -split "`r?`n")) {
    if ($line.StartsWith("worktree ", [StringComparison]::Ordinal)) {
      if ($null -ne $entry) { $entries.Add([pscustomobject]$entry) }
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
  if ($null -ne $entry) { $entries.Add([pscustomobject]$entry) }
  $matches = @($entries | Where-Object {
    [string]::Equals([string]$_.path, $normalizedPath, [StringComparison]::OrdinalIgnoreCase)
  })

  if (-not $branchExists -and -not $pathExists -and $matches.Count -eq 0) {
    return [pscustomobject]@{ status = "absent"; detail = "Writer identity is absent." }
  }
  if (
    -not $branchExists -or
    -not $pathExists -or
    $matches.Count -ne 1 -or
    [string]$branchProbe.output -cne $BaseCommit -or
    [string]$matches[0].head -cne $BaseCommit -or
    [string]$matches[0].branch -cne $BranchName -or
    -not (Test-OrdinaryDirectory -Path $WorktreePath)
  ) {
    return [pscustomobject]@{ status = "conflict"; detail = "Writer identity is not exact and reusable." }
  }
  $status = Invoke-DanioGit `
    -Root $WorktreePath `
    -Arguments @("--no-optional-locks", "status", "--short", "-uall")
  if (-not [string]::IsNullOrWhiteSpace($status)) {
    return [pscustomobject]@{ status = "conflict"; detail = "Reusable writer worktree is dirty." }
  }
  try {
    $processes = @(Get-CimInstance -ClassName Win32_Process -ErrorAction Stop | Where-Object {
      $commandLine = ([string]$_.CommandLine).Replace("\", "/")
      -not [string]::IsNullOrWhiteSpace($commandLine) -and
      (
        $commandLine.IndexOf($normalizedPath, [StringComparison]::OrdinalIgnoreCase) -ge 0 -or
        $commandLine.IndexOf($BranchName, [StringComparison]::OrdinalIgnoreCase) -ge 0
      )
    })
  } catch {
    return [pscustomobject]@{ status = "ambiguous"; detail = "Writer process evidence is ambiguous." }
  }
  if ($processes.Count -gt 0) {
    return [pscustomobject]@{ status = "ambiguous"; detail = "A process references the writer identity." }
  }
  return [pscustomobject]@{ status = "exact_reusable"; detail = "Writer identity is exact and quiescent." }
}

function Invoke-TransitionValidation {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$Source,
    [Parameter(Mandatory = $true)][string]$BaseCommit,
    [Parameter(Mandatory = $true)][string]$TreeHash,
    [string]$Commit = "HEAD"
  )

  $output = @(& powershell.exe `
    -NoProfile `
    -NonInteractive `
    -ExecutionPolicy Bypass `
    -File $transitionScriptPath `
    -Source $Source `
    -RepositoryRoot $Root `
    -ExpectedParentCommit $BaseCommit `
    -ExpectedStagedTreeHash $TreeHash `
    -Commit $Commit `
    2>$null)
  $exitCode = $LASTEXITCODE
  if ($exitCode -ne 0 -or $output.Count -ne 1) {
    throw "CLAIM_VALIDATION_FAILED: $Source transition validation failed."
  }
  $report = $output[0] | ConvertFrom-Json
  if (-not [bool]$report.valid) {
    throw "CLAIM_VALIDATION_FAILED: $Source transition validation returned '$($report.code)'."
  }
}

function Invoke-FreshClaimReadiness {
  param([Parameter(Mandatory = $true)][string]$Root)

  $syncScript = Join-Path $PSScriptRoot "sync_autonomous_completion.ps1"
  $readinessScript = Join-Path $PSScriptRoot "check_autonomous_completion_readiness.ps1"
  $nonce = [Guid]::NewGuid().ToString("N")
  $syncOutput = @(& powershell.exe `
    -NoProfile `
    -NonInteractive `
    -ExecutionPolicy Bypass `
    -File $syncScript `
    -RepositoryRoot $Root `
    -InvocationNonce $nonce `
    2>$null)
  if ($LASTEXITCODE -ne 0 -or $syncOutput.Count -ne 1) {
    throw "CLAIM_READINESS_INVALID: fresh synchronization failed."
  }
  $receiptJson = [string]$syncOutput[0]
  $readinessOutput = @(& powershell.exe `
    -NoProfile `
    -NonInteractive `
    -ExecutionPolicy Bypass `
    -File $readinessScript `
    -Intent "Claim" `
    -SynchronizationReceiptJson $receiptJson `
    -ExpectedInvocationNonce $nonce `
    -RepositoryRoot $Root `
    2>$null)
  if ($LASTEXITCODE -ne 0 -or $readinessOutput.Count -ne 1) {
    throw "CLAIM_READINESS_INVALID: fresh Claim readiness failed."
  }
  try {
    $readiness = $readinessOutput[0] | ConvertFrom-Json
  } catch {
    throw "CLAIM_READINESS_INVALID: fresh Claim readiness output is malformed."
  }
  if (
    [string]$readiness.document_type -cne "danio_readiness_report" -or
    [string]$readiness.intent -cne "Claim" -or
    -not [bool]$readiness.eligible -or
    $null -ne $readiness.stop_reason_code
  ) {
    throw "CLAIM_READINESS_INVALID: fresh Claim readiness is not eligible."
  }
}

function Get-FreeSubstDrive {
  foreach ($letter in @("R", "S", "T", "U", "V", "W", "X", "Y")) {
    if (-not (Test-Path -LiteralPath "$letter`:\")) {
      return "$letter`:"
    }
  }
  throw "DOCS_PROFILE_FAILED: no ephemeral drive letter is available."
}

function Invoke-DocsProfile {
  param(
    [Parameter(Mandatory = $true)][string]$WorktreeRoot,
    [Parameter(Mandatory = $true)][string]$OwnerToken
  )

  $drive = Get-FreeSubstDrive
  $subst = Join-Path $env:SystemRoot "System32\subst.exe"
  $sourceAppRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../.."))
  $actualDart = (Get-Command dart -ErrorAction Stop).Source
  $gateTemp = Join-Path ([IO.Path]::GetTempPath()) "danio-claim-gate-$($OwnerToken.Substring(0, 12))"
  $gateTempCreated = $false
  $driveMapped = $false
  $cleanupFailure = $null
  try {
    if (Test-Path -LiteralPath $gateTemp) {
      throw "DOCS_PROFILE_FAILED: isolated Docs temp root already exists."
    }
    New-Item -ItemType Directory -Path $gateTemp | Out-Null
    $gateTempCreated = $true
    & $subst $drive $WorktreeRoot
    if ($LASTEXITCODE -ne 0) {
      throw "DOCS_PROFILE_FAILED: ephemeral worktree mapping failed."
    }
    $driveMapped = $true

    $aliasAppRoot = "$drive\apps\aquarium_app"
    $gateScript = "$aliasAppRoot\scripts\quality_gates\run_local_quality_gate.ps1"
    $inner = @"
`$ErrorActionPreference = 'Stop'
`$env:GIT_CONFIG_COUNT = '1'
`$env:GIT_CONFIG_KEY_0 = 'core.longpaths'
`$env:GIT_CONFIG_VALUE_0 = 'true'
`$env:TEMP = '$($gateTemp.Replace("'", "''"))'
`$env:TMP = '$($gateTemp.Replace("'", "''"))'
`$global:ActualDart = '$($actualDart.Replace("'", "''"))'
`$global:ShortAppRoot = '$($sourceAppRoot.Replace("'", "''"))'
`$global:TargetAppRoot = '$($aliasAppRoot.Replace("'", "''"))'
function global:dart {
  [CmdletBinding()]
  param([Parameter(ValueFromRemainingArguments = `$true)][object[]]`$ArgumentList)
  if (`$ArgumentList.Count -ge 2 -and [string]`$ArgumentList[0] -eq 'run' -and [string]`$ArgumentList[1] -eq 'dependency_validator') {
    Push-Location -LiteralPath `$global:ShortAppRoot
    try {
      & `$global:ActualDart run dependency_validator --directory `$global:TargetAppRoot
      `$code = `$LASTEXITCODE
    } finally {
      Pop-Location
    }
  } else {
    & `$global:ActualDart @ArgumentList
    `$code = `$LASTEXITCODE
  }
  `$global:LASTEXITCODE = `$code
}
Set-Location -LiteralPath '$($aliasAppRoot.Replace("'", "''"))'
& '$($gateScript.Replace("'", "''"))' -Profile Docs
exit `$LASTEXITCODE
"@
    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($inner))
    $output = @(& powershell.exe `
      -NoLogo `
      -NoProfile `
      -NonInteractive `
      -EncodedCommand $encoded `
      2>&1)
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
      throw "DOCS_PROFILE_FAILED: Docs profile exited $exitCode`: $($output -join ' ')"
    }
  } finally {
    if ($driveMapped) {
      & $subst $drive "/D"
      if ($LASTEXITCODE -ne 0) {
        $cleanupFailure = "ephemeral worktree mapping cleanup failed"
      }
    }
    if ($gateTempCreated) {
      $gateTempFull = [IO.Path]::GetFullPath($gateTemp)
      $tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
      if (-not $gateTempFull.StartsWith($tempBase, [StringComparison]::OrdinalIgnoreCase)) {
        $cleanupFailure = "refusing temp cleanup outside the system temp root"
      } elseif (Test-Path -LiteralPath $gateTempFull) {
        try {
          Remove-Item -LiteralPath (ConvertTo-ExtendedPath -Path $gateTempFull) -Recurse -Force
        } catch {
          $cleanupFailure = "isolated Docs temp cleanup failed: $($_.Exception.Message)"
        }
      }
    }
    if ($null -ne $cleanupFailure) {
      throw "DOCS_PROFILE_FAILED: $cleanupFailure."
    }
  }
}

function Remove-ExactRejectedIdentity {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)]$Plan,
    [Parameter(Mandatory = $true)][string]$CandidateCommit,
    [Parameter(Mandatory = $true)][string]$TransportTarget,
    [bool]$InjectPostRemovalCommitFailure = $false
  )

  $candidateParent = Invoke-DanioGit -Root $Root -Arguments @("rev-parse", "$CandidateCommit^")
  $branchRef = "refs/heads/$($Plan.branch_name)"
  $branchCommit = Invoke-DanioGit -Root $Root -Arguments @("rev-parse", $branchRef)
  $candidateState = Read-DanioGitJsonBlob -Root $Root -Revision $CandidateCommit -Path $statePath
  if (
    $candidateParent -cne [string]$Plan.base_commit -or
    $branchCommit -cne $CandidateCommit -or
    [string]$candidateState.owner.token_sha256 -cne [string]$Plan.owner_token_sha256 -or
    [int64]$candidateState.owner.claim_revision -ne [int64]$Plan.expected_state_revision
  ) {
    throw "REJECTION_CLEANUP_UNSAFE: candidate identity does not match the rejected plan."
  }

  if (-not (Test-OrdinaryDirectory -Path $Plan.worktree_path)) {
    throw "REJECTION_CLEANUP_UNSAFE: rejected worktree path is missing or reparsed."
  }
  $worktreeText = Invoke-DanioGit -Root $Root -Arguments @("worktree", "list", "--porcelain")
  $normalizedExpectedPath = ConvertTo-ForwardSlashPath -Path ([string]$Plan.worktree_path)
  $entries = New-Object System.Collections.Generic.List[object]
  $entry = $null
  foreach ($line in @($worktreeText -split "`r?`n")) {
    if ($line.StartsWith("worktree ", [StringComparison]::Ordinal)) {
      if ($null -ne $entry) { $entries.Add([pscustomobject]$entry) }
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
  if ($null -ne $entry) { $entries.Add([pscustomobject]$entry) }
  $matches = @($entries | Where-Object {
    [string]::Equals(
      [string]$_.path,
      $normalizedExpectedPath,
      [StringComparison]::OrdinalIgnoreCase
    )
  })
  if (
    $matches.Count -ne 1 -or
    [string]$matches[0].head -cne $CandidateCommit -or
    [string]$matches[0].branch -cne [string]$Plan.branch_name
  ) {
    throw "REJECTION_CLEANUP_UNSAFE: worktree registry identity is not exact."
  }

  $fetchArguments = @(
    "fetch", "--prune", "--", $TransportTarget,
    "refs/heads/main:refs/remotes/origin/main"
  )
  $freshFetch = Invoke-DanioBoundedFetch -Root $Root -Arguments $fetchArguments
  if (
    -not [bool]$freshFetch.termination_confirmed -or
    [bool]$freshFetch.timed_out -or
    $freshFetch.exit_code -ne 0
  ) {
    throw "REJECTION_CLEANUP_UNSAFE: final remote rejection proof could not be refreshed."
  }
  $freshRemoteTip = Invoke-DanioGit -Root $Root -Arguments @("rev-parse", "origin/main")
  $freshReachability = Invoke-DanioGitProbe `
    -Root $Root `
    -Arguments @("merge-base", "--is-ancestor", $CandidateCommit, $freshRemoteTip)
  if ($freshReachability.exit_code -ne 1) {
    throw "REJECTION_CLEANUP_UNSAFE: final remote history does not prove candidate absence."
  }

  $freshWorktreeText = Invoke-DanioGit -Root $Root -Arguments @("worktree", "list", "--porcelain")
  if ($freshWorktreeText -cne $worktreeText) {
    throw "REJECTION_CLEANUP_UNSAFE: worktree registry changed during final rejection proof."
  }

  $branchCommit = Invoke-DanioGit -Root $Root -Arguments @("rev-parse", $branchRef)
  $worktreeHead = Invoke-DanioGit -Root $Plan.worktree_path -Arguments @("rev-parse", "HEAD")
  $worktreeBranch = Invoke-DanioGit -Root $Plan.worktree_path -Arguments @("branch", "--show-current")
  $worktreeStatus = Invoke-DanioGit `
    -Root $Plan.worktree_path `
    -Arguments @("--no-optional-locks", "status", "--short", "-uall")
  if (
    $branchCommit -cne $CandidateCommit -or
    $worktreeHead -cne $CandidateCommit -or
    $worktreeBranch -cne [string]$Plan.branch_name -or
    -not [string]::IsNullOrWhiteSpace($worktreeStatus) -or
    -not (Test-OrdinaryDirectory -Path $Plan.worktree_path)
  ) {
    throw "REJECTION_CLEANUP_UNSAFE: rejected identity changed before deletion."
  }
  Remove-DanioWorktreeWithPreparedRefDeletion `
    -Root $Root `
    -WorktreePath $Plan.worktree_path `
    -BranchRef $branchRef `
    -ExpectedCommit $CandidateCommit `
    -InjectPostRemovalCommitFailure $InjectPostRemovalCommitFailure
  $branchProbe = Invoke-DanioGitProbe -Root $Root -Arguments @("show-ref", "--verify", "--quiet", $branchRef)
  if ($branchProbe.exit_code -ne 1 -or (Test-Path -LiteralPath $Plan.worktree_path)) {
    throw "REJECTION_CLEANUP_UNSAFE: rejected identity cleanup could not be proven."
  }
}

$result = [ordered]@{
  document_type = "danio_writer_claim_result"
  schema_version = 1
  completed_at_utc = $null
  accepted = $false
  code = "CLAIM_TRANSACTION_INVALID"
  details = @()
  transport_result = if ([string]::IsNullOrWhiteSpace($TestTransportOutcome)) { "actual" } else { $TestTransportOutcome }
  test_transport_outcome = if ([string]::IsNullOrWhiteSpace($TestTransportOutcome)) { $null } else { $TestTransportOutcome }
  reconciliation_status = "not_attempted"
  mutations_performed = $false
  push_attempted = $false
  push_attempt_count = 0
  push_timed_out = $false
  push_termination_confirmed = $null
  retry_performed = $false
  budget_consumed = $false
  cleanup_performed = $false
  cleanup_partial = $false
  recovery_required = $false
  artifacts_preserved = $false
  fixture_root_equivalence_used = $false
  fresh_readiness_revalidated = $false
  run_id = $null
  work_unit_id = $null
  task_id = $null
  expected_state_revision = $null
  owner_token_sha256 = $null
  branch_name = $null
  worktree_id = $null
  worktree_path = $null
  base_commit = $null
  candidate_commit = $null
  staged_tree_hash = $null
  origin_main_commit = $null
}

try {
  if (
    -not [string]::IsNullOrWhiteSpace($TestTransportOutcome) -and
    $allowedTestOutcomes -cnotcontains $TestTransportOutcome
  ) {
    throw "TEST_TRANSPORT_FORBIDDEN: unsupported test transport outcome."
  }
  try {
    $plan = $ClaimPlanJson | ConvertFrom-Json
  } catch {
    throw "CLAIM_PLAN_INVALID: writer claim plan JSON is malformed."
  }

  foreach ($field in @(
    "run_id", "work_unit_id", "task_id", "expected_state_revision",
    "owner_token_sha256", "branch_name", "worktree_id", "worktree_path", "base_commit"
  )) {
    $result[$field] = $plan.$field
  }

  $resolvedRoot = Resolve-DanioRepositoryRoot -RepositoryRoot $RepositoryRoot
  if ([string]::IsNullOrWhiteSpace($TestTransportOutcome)) {
    Invoke-FreshClaimReadiness -Root $resolvedRoot
    $result.fresh_readiness_revalidated = $true
  }
  $branch = Invoke-DanioGit -Root $resolvedRoot -Arguments @("branch", "--show-current")
  $head = Invoke-DanioGit -Root $resolvedRoot -Arguments @("rev-parse", "HEAD")
  $main = Invoke-DanioGit -Root $resolvedRoot -Arguments @("rev-parse", "main")
  $originMain = Invoke-DanioGit -Root $resolvedRoot -Arguments @("rev-parse", "origin/main")
  $status = Invoke-DanioGit `
    -Root $resolvedRoot `
    -Arguments @("--no-optional-locks", "status", "--short", "-uall")
  if (
    $branch -cne "main" -or
    $head -cne $main -or
    $head -cne $originMain -or
    $originMain -cne [string]$plan.base_commit -or
    -not [string]::IsNullOrWhiteSpace($status)
  ) {
    throw "CLAIM_BASE_MOVED: source main is not clean and aligned at the planned base."
  }
  $baseTree = Invoke-DanioGit -Root $resolvedRoot -Arguments @("rev-parse", "$originMain^{tree}")
  $stateJson = Invoke-DanioGit -Root $resolvedRoot -Arguments @("show", "$originMain`:$statePath")
  try {
    $currentState = $stateJson | ConvertFrom-Json
  } catch {
    throw "STATE_BLOB_INVALID: committed run state is malformed."
  }

  $testGuard = $null
  if (-not [string]::IsNullOrWhiteSpace($TestTransportOutcome)) {
    $testGuard = Assert-DisposableTestTransport -Root $resolvedRoot -BaseCommit $originMain
  }
  $directFixtureTransport = $null -ne $testGuard
  $injectPostRemovalCommitFailure = $false
  $injectedFailureValue = [Environment]::GetEnvironmentVariable(
    "DANIO_TEST_FAIL_REF_COMMIT_AFTER_REMOVAL",
    "Process"
  )
  if (-not [string]::IsNullOrWhiteSpace($injectedFailureValue)) {
    if (-not $directFixtureTransport -or $injectedFailureValue -cne "1") {
      throw "TEST_TRANSPORT_FORBIDDEN: post-removal failure injection requires a disposable guarded fixture."
    }
    $injectPostRemovalCommitFailure = $true
  }
  $useProductionEndpointCapture = $false
  $productionCaptureValue = [Environment]::GetEnvironmentVariable(
    "DANIO_TEST_USE_PRODUCTION_ENDPOINT_CAPTURE",
    "Process"
  )
  if (-not [string]::IsNullOrWhiteSpace($productionCaptureValue)) {
    if (-not $directFixtureTransport -or $productionCaptureValue -cne "1") {
      throw "TEST_TRANSPORT_FORBIDDEN: production endpoint capture injection requires a disposable guarded fixture."
    }
    $useProductionEndpointCapture = $true
  }
  $transportTarget = if ($directFixtureTransport -and -not $useProductionEndpointCapture) {
    [string]$testGuard.remote_path
  } else {
    Get-DanioImmutableProductionTransportTarget -Root $resolvedRoot
  }
  $authorizedRoot = [string]$currentState.authorization.repository_root
  $fixtureEquivalent = $false
  if (-not [string]::Equals(
    (ConvertTo-ForwardSlashPath -Path $resolvedRoot),
    (ConvertTo-ForwardSlashPath -Path $authorizedRoot),
    [StringComparison]::OrdinalIgnoreCase
  )) {
    if ($null -eq $testGuard) {
      throw "REPO_ROOT_INVALID: execution root differs from durable authorization."
    }
    $fixtureEquivalent = Test-DisposableEquivalentRoot `
      -ExecutionRoot $resolvedRoot `
      -AuthorizedRoot $authorizedRoot `
      -BaseCommit $originMain `
      -BaseTreeHash $baseTree `
      -StateBlob $stateJson `
      -TestGuard $testGuard
  }
  $result.fixture_root_equivalence_used = $fixtureEquivalent

  $planValidation = & $module {
    param(
      $PlanValue,
      $CurrentStateValue,
      $RootValue,
      $BaseCommitValue,
      $BaseTreeValue,
      [bool]$AllowOverride
    )
    Test-DanioWriterClaimPlan `
      -Plan $PlanValue `
      -CurrentState $CurrentStateValue `
      -RepositoryRoot $RootValue `
      -ExpectedBaseCommit $BaseCommitValue `
      -ExpectedBaseTreeHash $BaseTreeValue `
      -AllowDisposableRepositoryRootOverride:$AllowOverride
  } $plan $currentState $resolvedRoot $originMain $baseTree $fixtureEquivalent
  if (-not $planValidation.valid) {
    throw "$($planValidation.code): $($planValidation.details -join '; ')"
  }

  $worktreeRoot = Assert-WriterWorktreeContainment `
    -SavedProjectRoot ([string]$currentState.authorization.saved_project_root) `
    -WorktreePath ([string]$plan.worktree_path)
  $identity = Get-WriterIdentityObservation `
    -Root $resolvedRoot `
    -BranchName ([string]$plan.branch_name) `
    -WorktreePath ([string]$plan.worktree_path) `
    -BaseCommit $originMain
  if (@("absent", "exact_reusable") -cnotcontains [string]$identity.status) {
    throw "WRITER_IDENTITY_CONFLICT: $($identity.detail)"
  }
  if ([string]$identity.status -ceq "absent") {
    $result.mutations_performed = $true
    if (-not (Test-Path -LiteralPath $worktreeRoot -PathType Container)) {
      New-Item -ItemType Directory -Path $worktreeRoot | Out-Null
    }
    if (-not (Test-OrdinaryDirectory -Path $worktreeRoot)) {
      throw "OWNER_IDENTITY_INVALID: writer worktree root is not an ordinary directory."
    }
    [void](Invoke-DanioGit `
      -Root $resolvedRoot `
      -Arguments @(
        "worktree", "add", "-b", [string]$plan.branch_name,
        [string]$plan.worktree_path, $originMain
      ))
  }

  $result.mutations_performed = $true
  $stateAbsolutePath = Join-Path ([string]$plan.worktree_path) $statePath
  $stateDirectory = Split-Path -Parent $stateAbsolutePath
  [IO.Directory]::CreateDirectory((ConvertTo-ExtendedPath -Path $stateDirectory)) | Out-Null
  $nextStateJson = $plan.next_run_state | ConvertTo-Json -Depth 100
  [IO.File]::WriteAllText(
    (ConvertTo-ExtendedPath -Path $stateAbsolutePath),
    $nextStateJson,
    (New-Object Text.UTF8Encoding($false))
  )
  [void](Invoke-DanioGit -Root $plan.worktree_path -Arguments @("add", "--", $statePath))
  $stagedPaths = @(
    (Invoke-DanioGit `
      -Root $plan.worktree_path `
      -Arguments @("diff", "--cached", "--name-only", "--")) -split "`r?`n" |
      Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
  )
  if ($stagedPaths.Count -ne 1 -or [string]$stagedPaths[0] -cne $statePath) {
    throw "CLAIM_STAGE_INVALID: writer claim staged paths other than run state."
  }
  $stagedTree = Invoke-DanioGit -Root $plan.worktree_path -Arguments @("write-tree")
  $result.staged_tree_hash = $stagedTree
  Invoke-TransitionValidation `
    -Root $plan.worktree_path `
    -Source "Staged" `
    -BaseCommit $originMain `
    -TreeHash $stagedTree

  Invoke-DocsProfile `
    -WorktreeRoot ([string]$plan.worktree_path) `
    -OwnerToken ([string]$plan.owner_token_sha256)
  Invoke-TransitionValidation `
    -Root $plan.worktree_path `
    -Source "Staged" `
    -BaseCommit $originMain `
    -TreeHash $stagedTree
  $postGatePaths = @(
    (Invoke-DanioGit `
      -Root $plan.worktree_path `
      -Arguments @("diff", "--cached", "--name-only", "--")) -split "`r?`n" |
      Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
  )
  if ($postGatePaths.Count -ne 1 -or [string]$postGatePaths[0] -cne $statePath) {
    throw "DIRTY_AFTER_GATE: Docs profile changed the staged path set."
  }

  $verifiedAt = Format-StrictUtc -Value ([DateTimeOffset]::UtcNow)
  $trailerBlock = @"
Danio-State-Tree: $stagedTree
Danio-State-Validation: pass
Danio-Docs-Profile: pass
Danio-Verified-At: $verifiedAt
"@
  [void](Invoke-DanioGit `
    -Root $plan.worktree_path `
    -Arguments @("commit", "-m", "chore: claim autonomous writer", "-m", $trailerBlock))
  $candidateCommit = Invoke-DanioGit -Root $plan.worktree_path -Arguments @("rev-parse", "HEAD")
  $result.candidate_commit = $candidateCommit
  Invoke-TransitionValidation `
    -Root $plan.worktree_path `
    -Source "Committed" `
    -BaseCommit $originMain `
    -TreeHash $stagedTree `
    -Commit $candidateCommit

  $skipPush = @("rejected", "unknown_not_accepted") -ccontains $TestTransportOutcome
  $skipReconciliation = $false
  if (-not $skipPush) {
    $result.push_attempted = $true
    $result.push_attempt_count = 1
    $pushProbe = Invoke-DanioBoundedPush `
      -Root $plan.worktree_path `
      -TransportTarget $transportTarget
    if ($TestTransportOutcome -ceq "unknown_unresolved") {
      $pushProbe = [pscustomobject]@{
        timed_out = $true
        termination_confirmed = $false
        exit_code = $null
        output = "Injected unresolved process-tree termination evidence."
      }
    }
    $result.push_timed_out = [bool]$pushProbe.timed_out
    $result.push_termination_confirmed = [bool]$pushProbe.termination_confirmed
    if (-not [bool]$pushProbe.termination_confirmed) {
      if ([string]::IsNullOrWhiteSpace($TestTransportOutcome)) {
        $result.transport_result = "unknown"
      }
      $result.code = "PUSH_OUTCOME_UNKNOWN"
      $result.reconciliation_status = "unknown"
      $result.details = @(
        "Push process-tree termination could not be proven; artifacts were preserved without reconciliation or cleanup."
      )
      $result.artifacts_preserved = $true
      $skipReconciliation = $true
    } elseif ($pushProbe.timed_out) {
      if ([string]::IsNullOrWhiteSpace($TestTransportOutcome)) {
        $result.transport_result = "unknown"
      }
    } elseif ($pushProbe.exit_code -ne 0 -and $TestTransportOutcome -ceq "accepted") {
      $result.transport_result = "rejected"
    }
  }

  if (-not $skipReconciliation) {
    $fetchArguments = @(
      "fetch", "--prune", "--", $transportTarget,
      "refs/heads/main:refs/remotes/origin/main"
    )
    $fetchProbe = Invoke-DanioBoundedFetch -Root $resolvedRoot -Arguments $fetchArguments
    if (
      -not [bool]$fetchProbe.termination_confirmed -or
      [bool]$fetchProbe.timed_out -or
      $fetchProbe.exit_code -ne 0
    ) {
      $result.code = "PUSH_OUTCOME_UNKNOWN"
      $result.reconciliation_status = "unknown"
      $result.details = @("Fresh remote history could not be observed; claim artifacts were preserved.")
      $result.artifacts_preserved = $true
    } else {
    $remoteTip = Invoke-DanioGit -Root $resolvedRoot -Arguments @("rev-parse", "origin/main")
    $result.origin_main_commit = $remoteTip
    if ($remoteTip -ceq $candidateCommit) {
      $sourceStatus = Invoke-DanioGit `
        -Root $resolvedRoot `
        -Arguments @("--no-optional-locks", "status", "--short", "-uall")
      $sourceHead = Invoke-DanioGit -Root $resolvedRoot -Arguments @("rev-parse", "HEAD")
      $sourceMain = Invoke-DanioGit -Root $resolvedRoot -Arguments @("rev-parse", "main")
      $sourceBranch = Invoke-DanioGit -Root $resolvedRoot -Arguments @("branch", "--show-current")
      if (
        $sourceBranch -cne "main" -or
        $sourceHead -cne $originMain -or
        $sourceMain -cne $originMain -or
        -not [string]::IsNullOrWhiteSpace($sourceStatus)
      ) {
        $result.code = "REMOTE_MOVED"
        $result.reconciliation_status = "remote_moved"
        $result.details = @("Remote accepted the claim, but local main could not be safely aligned.")
        $result.artifacts_preserved = $true
      } else {
        $mergeProbe = Invoke-DanioGitProbe `
          -Root $resolvedRoot `
          -Arguments @("merge", "--ff-only", "origin/main")
        if ($mergeProbe.exit_code -ne 0) {
          $result.code = "REMOTE_MOVED"
          $result.reconciliation_status = "remote_moved"
          $result.details = @("Remote accepted the claim, but local main fast-forward failed; artifacts were preserved.")
          $result.artifacts_preserved = $true
        } else {
          $alignedHead = Invoke-DanioGit -Root $resolvedRoot -Arguments @("rev-parse", "HEAD")
          $alignedMain = Invoke-DanioGit -Root $resolvedRoot -Arguments @("rev-parse", "main")
          $alignedRemote = Invoke-DanioGit -Root $resolvedRoot -Arguments @("rev-parse", "origin/main")
          $alignedStatus = Invoke-DanioGit `
            -Root $resolvedRoot `
            -Arguments @("--no-optional-locks", "status", "--short", "-uall")
          if (
            $alignedHead -cne $candidateCommit -or
            $alignedMain -cne $candidateCommit -or
            $alignedRemote -cne $candidateCommit -or
            -not [string]::IsNullOrWhiteSpace($alignedStatus)
          ) {
            throw "REMOTE_MOVED: accepted claim did not leave local main aligned."
          }
          $result.accepted = $true
          $result.code = "WRITER_CLAIM_ACCEPTED"
          $result.reconciliation_status = "accepted"
          $result.details = @("The exact candidate reached origin/main and local main is aligned.")
          $result.artifacts_preserved = $true
        }
      }
    } else {
      $reachability = Invoke-DanioGitProbe `
        -Root $resolvedRoot `
        -Arguments @("merge-base", "--is-ancestor", $candidateCommit, $remoteTip)
      if ($reachability.exit_code -eq 0) {
        $result.code = "REMOTE_MOVED"
        $result.reconciliation_status = "remote_moved"
        $result.details = @("The candidate is reachable, but origin/main advanced beyond it.")
        $result.artifacts_preserved = $true
      } elseif ($reachability.exit_code -eq 1) {
        $result.code = "WRITER_CLAIM_LOST"
        $result.reconciliation_status = "rejected"
        $result.details = @("Fresh origin/main history proves the candidate was not accepted.")
        try {
          Remove-ExactRejectedIdentity `
            -Root $resolvedRoot `
            -Plan $plan `
            -CandidateCommit $candidateCommit `
            -TransportTarget $transportTarget `
            -InjectPostRemovalCommitFailure $injectPostRemovalCommitFailure
          $result.cleanup_performed = $true
          $result.artifacts_preserved = $false
        } catch {
          $cleanupFailure = $_.Exception.Message
          $result.details += $cleanupFailure
          if ($cleanupFailure.StartsWith(
            "REJECTION_CLEANUP_PARTIAL:",
            [StringComparison]::Ordinal
          )) {
            $result.code = "REJECTION_CLEANUP_PARTIAL"
            $result.cleanup_partial = $true
            $result.recovery_required = $true
            $result.artifacts_preserved = $false
          } else {
            $result.artifacts_preserved = $true
          }
        }
      } else {
        $result.code = "PUSH_OUTCOME_UNKNOWN"
        $result.reconciliation_status = "unknown"
        $result.details = @("Candidate reachability could not be proven; every artifact was preserved.")
        $result.artifacts_preserved = $true
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
    "CLAIM_TRANSACTION_INVALID"
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
