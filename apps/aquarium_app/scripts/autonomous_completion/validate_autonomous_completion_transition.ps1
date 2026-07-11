[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Source,
  [string]$RepositoryRoot,
  [string]$ExpectedParentCommit,
  [string]$ExpectedStagedTreeHash,
  [string]$Commit = "HEAD"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "DanioAutonomousCompletion.psm1"
Import-Module -Name $modulePath -Force
$statePath = "apps/aquarium_app/docs/agent/autonomous_completion/phone_completion_run_state.json"
$inactiveFixturePath = "apps/aquarium_app/test/scripts/fixtures/autonomous_completion/inactive_run_state.json"

function Format-StrictUtc {
  param([Parameter(Mandatory = $true)][DateTimeOffset]$Value)

  return $Value.ToUniversalTime().ToString(
    "yyyy-MM-dd'T'HH:mm:ss.fffffff'Z'",
    [Globalization.CultureInfo]::InvariantCulture
  )
}

function Test-StrictUtc {
  param($Value)

  if (
    $Value -isnot [string] -or
    $Value.Length -ne 28 -or
    $Value -notmatch '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{7}Z$'
  ) {
    return $false
  }
  $parsed = [DateTimeOffset]::MinValue
  return [DateTimeOffset]::TryParseExact(
    $Value,
    "yyyy-MM-dd'T'HH:mm:ss.fffffff'Z'",
    [Globalization.CultureInfo]::InvariantCulture,
    [Globalization.DateTimeStyles]::AssumeUniversal -bor [Globalization.DateTimeStyles]::AdjustToUniversal,
    [ref]$parsed
  )
}

function Test-GitOid {
  param($Value)

  return $Value -is [string] -and $Value -cmatch '^[0-9a-f]{40}$'
}

function New-TransitionCheck {
  param(
    [Parameter(Mandatory = $true)][string]$Code,
    [Parameter(Mandatory = $true)][bool]$Passed,
    [Parameter(Mandatory = $true)][string]$Detail
  )

  return [pscustomobject][ordered]@{
    code = $Code
    status = if ($Passed) { "pass" } else { "fail" }
    detail = $Detail
  }
}

function New-TransitionReport {
  param(
    [Parameter(Mandatory = $true)][string]$ReportSource,
    [Parameter(Mandatory = $true)][string]$ValidatedAtUtc,
    [Parameter(Mandatory = $true)][bool]$Valid,
    [Parameter(Mandatory = $true)][string]$Code,
    [object[]]$Details = @(),
    [AllowNull()][string]$ExpectedParent = $null,
    [AllowNull()][string]$ObservedParent = $null,
    [AllowNull()][string]$TreeHash = $null,
    [Parameter(Mandatory = $true)][object[]]$Checks
  )

  return [pscustomobject][ordered]@{
    document_type = "danio_transition_validation_report"
    schema_version = 1
    source = $ReportSource
    validated_at_utc = $ValidatedAtUtc
    valid = $Valid
    code = $Code
    details = @($Details)
    expected_parent_commit = $ExpectedParent
    observed_parent_commit = $ObservedParent
    staged_tree_hash = $TreeHash
    mutations_performed = $false
    checks = @($Checks)
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

function Invoke-DanioGit {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string[]]$Arguments
  )

  $probe = Invoke-DanioGitProbe -Root $Root -Arguments $Arguments
  if ($probe.exit_code -ne 0) {
    throw "TRANSITION_INPUT_INVALID: git $($Arguments -join ' ') exited $($probe.exit_code): $($probe.output)"
  }
  return [string]$probe.output
}

function Read-DanioGitJsonBlob {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [AllowEmptyString()][string]$Revision = "",
    [Parameter(Mandatory = $true)][string]$Path,
    [switch]$Index,
    [switch]$AllowMissing
  )

  if (-not $Index -and [string]::IsNullOrWhiteSpace($Revision)) {
    throw "STATE_BLOB_INVALID: a committed revision is required."
  }
  $objectSpec = if ($Index) { ":$Path" } else { "$Revision`:$Path" }
  $probe = Invoke-DanioGitProbe -Root $Root -Arguments @("show", $objectSpec)
  if ($probe.exit_code -ne 0) {
    if ($AllowMissing) {
      return $null
    }
    throw "STATE_BLOB_INVALID: state blob '$objectSpec' is missing."
  }
  try {
    return $probe.output | ConvertFrom-Json
  } catch {
    throw "STATE_BLOB_INVALID: state blob '$objectSpec' is malformed."
  }
}

function Read-DanioPreviousState {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$ParentRevision
  )

  $previousState = Read-DanioGitJsonBlob `
    -Root $Root `
    -Revision $ParentRevision `
    -Path $statePath `
    -AllowMissing
  if ($null -ne $previousState) {
    return $previousState
  }
  return Read-DanioGitJsonBlob `
    -Root $Root `
    -Revision $ParentRevision `
    -Path $inactiveFixturePath
}

$validatedAtUtc = Format-StrictUtc -Value ([DateTimeOffset]::UtcNow)
$reportSource = if (@("Staged", "Committed") -ccontains $Source) { $Source } else { "Staged" }
$checks = New-Object System.Collections.Generic.List[object]
$observedParent = $null
$treeHash = $null
$report = $null
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
  if (@("Staged", "Committed") -cnotcontains $Source) {
    throw "TRANSITION_INPUT_INVALID: Source must be Staged or Committed."
  }
  if (
    -not [string]::IsNullOrWhiteSpace($ExpectedParentCommit) -and
    -not (Test-GitOid -Value $ExpectedParentCommit)
  ) {
    throw "TRANSITION_INPUT_INVALID: expected parent commit is malformed."
  }
  if (
    -not [string]::IsNullOrWhiteSpace($ExpectedStagedTreeHash) -and
    -not (Test-GitOid -Value $ExpectedStagedTreeHash)
  ) {
    throw "TRANSITION_INPUT_INVALID: expected staged tree is malformed."
  }

  $resolvedRoot = Resolve-DanioRepositoryRoot -RepositoryRoot $RepositoryRoot
  if ($Source -ceq "Staged") {
    $observedParent = Invoke-DanioGit -Root $resolvedRoot -Arguments @("rev-parse", "HEAD")
    if (
      -not [string]::IsNullOrWhiteSpace($ExpectedParentCommit) -and
      $observedParent -cne $ExpectedParentCommit
    ) {
      throw "PARENT_COMMIT_MISMATCH: staged parent does not match the expected commit."
    }
    $checks.Add((New-TransitionCheck `
      -Code "PARENT_COMMIT" `
      -Passed $true `
      -Detail "Staged parent commit matches."))

    $candidateState = Read-DanioGitJsonBlob `
      -Root $resolvedRoot `
      -Path $statePath `
      -Index
    $previousState = Read-DanioPreviousState `
      -Root $resolvedRoot `
      -ParentRevision $observedParent
    $checks.Add((New-TransitionCheck `
      -Code "STATE_BLOB" `
      -Passed $true `
      -Detail "Parent and indexed candidate state blobs parse."))

    $treeHash = Invoke-DanioGit -Root $resolvedRoot -Arguments @("write-tree")
    $transitionValidation = Test-DanioRunStateTransition `
      -PreviousState $previousState `
      -CandidateState $candidateState
    if (-not $transitionValidation.valid) {
      throw "$($transitionValidation.code): $($transitionValidation.details -join '; ')"
    }
    $checks.Add((New-TransitionCheck `
      -Code "STATE_TRANSITION" `
      -Passed $true `
      -Detail "Indexed state transition validates."))

    if (
      -not [string]::IsNullOrWhiteSpace($ExpectedStagedTreeHash) -and
      $treeHash -cne $ExpectedStagedTreeHash
    ) {
      throw "STAGED_TREE_MISMATCH: index tree changed after the expected gate."
    }
    $checks.Add((New-TransitionCheck `
      -Code "STAGED_TREE" `
      -Passed $true `
      -Detail "Indexed tree matches the expected tree."))

    $unstagedPaths = Invoke-DanioGit `
      -Root $resolvedRoot `
      -Arguments @("diff", "--name-only", "--")
    $untrackedPaths = Invoke-DanioGit `
      -Root $resolvedRoot `
      -Arguments @("ls-files", "--others", "--exclude-standard")
    if (
      -not [string]::IsNullOrWhiteSpace($unstagedPaths) -or
      -not [string]::IsNullOrWhiteSpace($untrackedPaths)
    ) {
      throw "DIRTY_AFTER_GATE: unstaged or untracked output appeared after the gate."
    }
    $checks.Add((New-TransitionCheck `
      -Code "POST_GATE_CLEAN" `
      -Passed $true `
      -Detail "No unstaged or untracked post-gate output exists."))
  } else {
    $commitOid = Invoke-DanioGit -Root $resolvedRoot -Arguments @("rev-parse", "$Commit^{commit}")
    $parentsText = Invoke-DanioGit -Root $resolvedRoot -Arguments @("rev-list", "--parents", "-n", "1", $commitOid)
    $parentParts = @($parentsText -split '\s+' | Where-Object { $_ -ne "" })
    if ($parentParts.Count -ne 2) {
      throw "TRANSITION_INPUT_INVALID: committed validation requires exactly one parent."
    }
    $observedParent = [string]$parentParts[1]
    if (
      -not [string]::IsNullOrWhiteSpace($ExpectedParentCommit) -and
      $observedParent -cne $ExpectedParentCommit
    ) {
      throw "PARENT_COMMIT_MISMATCH: committed parent does not match the expected commit."
    }
    $checks.Add((New-TransitionCheck `
      -Code "PARENT_COMMIT" `
      -Passed $true `
      -Detail "Committed parent commit matches."))

    $treeHash = Invoke-DanioGit -Root $resolvedRoot -Arguments @("rev-parse", "$commitOid^{tree}")
    $candidateState = Read-DanioGitJsonBlob `
      -Root $resolvedRoot `
      -Revision $commitOid `
      -Path $statePath
    $previousState = Read-DanioPreviousState `
      -Root $resolvedRoot `
      -ParentRevision $observedParent
    $checks.Add((New-TransitionCheck `
      -Code "STATE_BLOB" `
      -Passed $true `
      -Detail "Parent and committed candidate state blobs parse."))

    $transitionValidation = Test-DanioRunStateTransition `
      -PreviousState $previousState `
      -CandidateState $candidateState
    if (-not $transitionValidation.valid) {
      throw "$($transitionValidation.code): $($transitionValidation.details -join '; ')"
    }
    $checks.Add((New-TransitionCheck `
      -Code "STATE_TRANSITION" `
      -Passed $true `
      -Detail "Committed state transition validates."))

    if (
      -not [string]::IsNullOrWhiteSpace($ExpectedStagedTreeHash) -and
      $treeHash -cne $ExpectedStagedTreeHash
    ) {
      throw "STAGED_TREE_MISMATCH: committed tree does not match the expected staged tree."
    }
    $checks.Add((New-TransitionCheck `
      -Code "STAGED_TREE" `
      -Passed $true `
      -Detail "Committed tree matches the expected staged tree."))

    $message = Invoke-DanioGit -Root $resolvedRoot -Arguments @("log", "-1", "--format=%B", $commitOid)
    $trailerNames = @(
      "Danio-State-Tree",
      "Danio-State-Validation",
      "Danio-Docs-Profile",
      "Danio-Verified-At"
    )
    $messageLines = @($message -split "`r?`n")
    $lineIndex = $messageLines.Count - 1
    while ($lineIndex -ge 0 -and [string]::IsNullOrWhiteSpace($messageLines[$lineIndex])) {
      $lineIndex -= 1
    }
    $terminalTrailerLines = New-Object System.Collections.Generic.List[string]
    while (
      $lineIndex -ge 0 -and
      $messageLines[$lineIndex] -cmatch '^[A-Za-z0-9-]+:\s*[^\r\n]+$'
    ) {
      $terminalTrailerLines.Insert(0, [string]$messageLines[$lineIndex])
      $lineIndex -= 1
    }
    if ($terminalTrailerLines.Count -eq 0) {
      throw "COMMIT_TRAILER_INVALID: commit has no terminal trailer block."
    }
    $trailers = @{}
    foreach ($trailerName in $trailerNames) {
      $matchingLines = @(
        $terminalTrailerLines | Where-Object {
          $_ -cmatch "^$([regex]::Escape($trailerName)):\s*[^\r\n]+$"
        }
      )
      if ($matchingLines.Count -ne 1) {
        throw "COMMIT_TRAILER_INVALID: '$trailerName' must appear exactly once."
      }
      $trailers[$trailerName] = $matchingLines[0].Substring(
        $matchingLines[0].IndexOf(":") + 1
      ).Trim()
    }
    if (
      [string]$trailers["Danio-State-Tree"] -cne $treeHash -or
      [string]$trailers["Danio-State-Validation"] -cne "pass" -or
      [string]$trailers["Danio-Docs-Profile"] -cne "pass" -or
      -not (Test-StrictUtc -Value $trailers["Danio-Verified-At"])
    ) {
      throw "COMMIT_TRAILER_INVALID: committed transition trailers do not match their proof."
    }
    $checks.Add((New-TransitionCheck `
      -Code "COMMIT_TRAILERS" `
      -Passed $true `
      -Detail "Committed transition trailers validate."))

    $currentHead = Invoke-DanioGit -Root $resolvedRoot -Arguments @("rev-parse", "HEAD")
    if ($commitOid -ceq $currentHead) {
      $statusPaths = Invoke-DanioGit `
        -Root $resolvedRoot `
        -Arguments @("--no-optional-locks", "status", "--short", "-uall")
      if (-not [string]::IsNullOrWhiteSpace($statusPaths)) {
        throw "DIRTY_AFTER_GATE: committed HEAD has staged, unstaged, or untracked output."
      }
      $checks.Add((New-TransitionCheck `
        -Code "POST_GATE_CLEAN" `
        -Passed $true `
        -Detail "Committed HEAD has no staged, unstaged, or untracked post-gate output."))
    }
  }

  $report = New-TransitionReport `
    -ReportSource $reportSource `
    -ValidatedAtUtc $validatedAtUtc `
    -Valid $true `
    -Code "TRANSITION_VALID" `
    -ExpectedParent $(if ([string]::IsNullOrWhiteSpace($ExpectedParentCommit)) { $null } else { $ExpectedParentCommit }) `
    -ObservedParent $observedParent `
    -TreeHash $treeHash `
    -Checks @($checks.ToArray())
} catch {
  $message = $_.Exception.Message
  $codeMatch = [regex]::Match($message, '^(?<code>[A-Z][A-Z0-9_]*):')
  $code = if ($codeMatch.Success) {
    $codeMatch.Groups["code"].Value
  } else {
    "TRANSITION_INPUT_INVALID"
  }
  $checks.Add((New-TransitionCheck -Code $code -Passed $false -Detail $message))
  $report = New-TransitionReport `
    -ReportSource $reportSource `
    -ValidatedAtUtc $validatedAtUtc `
    -Valid $false `
    -Code $code `
    -Details @($message) `
    -ExpectedParent $(if (Test-GitOid -Value $ExpectedParentCommit) { $ExpectedParentCommit } else { $null }) `
    -ObservedParent $observedParent `
    -TreeHash $treeHash `
    -Checks @($checks.ToArray())
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

Write-Output ($report | ConvertTo-Json -Depth 100 -Compress)
if ($report.valid) {
  exit 0
}
exit 1
