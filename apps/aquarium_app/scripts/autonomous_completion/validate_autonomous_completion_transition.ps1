[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Source,
  [string]$RepositoryRoot,
  [string]$ExpectedParentCommit,
  [string]$ExpectedStagedTreeHash,
  [string]$Commit = "HEAD",
  [string]$EvidenceManifestPath,
  [string]$LeaseReleaseJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "DanioAutonomousCompletion.psm1"
$module = Import-Module -Name $modulePath -Force -PassThru
$statePath = "apps/aquarium_app/docs/agent/autonomous_completion/phone_completion_run_state.json"
$inactiveFixturePath = "apps/aquarium_app/test/scripts/fixtures/autonomous_completion/inactive_run_state.json"
$ledgerPath = "apps/aquarium_app/docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md"
$activeHandoffPath = "apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md"
$sliceLogPath = "apps/aquarium_app/docs/agent/SLICE_LOG.md"
$historicalBootstrapSentence = "This historical bootstrap record is superseded by live run state as the sole accounting authority."
$activationStatusLine = "Status: Task 13 activation is complete; committed live run state is ready for the explicit launch handoff."
$activationUpdatedLine = "Last updated: 2026-07-13 in this activation commit; live Git and committed run state remain the final authority."
$activationBranchBody = @(
  '- Source-of-truth branch: `main`.',
  '- This handoff becomes authoritative only with its containing activation commit on clean, pushed, aligned `main`.',
  '- Only the canonical repository worktree may remain registered at durable closeout.'
) -join "`n"
$activationBlockersBody = @(
  "- No activation blocker is recorded in this candidate.",
  "- Product work remains forbidden in the Task 13 setup task."
) -join "`n"
$activationNextActionBody = @(
  'After the activation commit is on clean, pushed, aligned `main`, use the duplicate-safe launch marker to create or reuse exactly one saved-project local first product task.',
  'The new task must synchronize, pass Claim readiness, and win `ready -> active` before auditing `DCL-DR-001`. Do not start product work in this setup task.'
) -join "`n"

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

function Invoke-DanioOwnershipGit {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string[]]$Arguments
  )

  try {
    return Invoke-DanioGit -Root $Root -Arguments $Arguments
  } catch {
    throw "STOP_PENDING: ownership observation failed: $($_.Exception.Message)"
  }
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
  return & $module {
    param($RawJson, $FailureCode)
    ConvertFrom-DanioStrictJson -Json $RawJson -FailureCode $FailureCode
  } ([string]$probe.output) "STATE_BLOB_INVALID"
}

function Read-DanioEvidenceJsonBlob {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$Revision,
    [Parameter(Mandatory = $true)][string]$Path
  )

  $probe = Invoke-DanioGitProbe -Root $Root -Arguments @("show", "$Revision`:$Path")
  if ($probe.exit_code -ne 0) {
    throw "EVIDENCE_MANIFEST_INVALID: evidence manifest '$Revision`:$Path' is missing."
  }
  try {
    return $probe.output | ConvertFrom-Json
  } catch {
    throw "EVIDENCE_MANIFEST_INVALID: evidence manifest '$Revision`:$Path' is malformed."
  }
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
    $blobProbe = Invoke-DanioGitProbe `
      -Root $Root `
      -Arguments @("rev-parse", "$ParentCommit`:$($entry.Value)")
    if ($blobProbe.exit_code -ne 0 -or -not (Test-GitOid -Value $blobProbe.output)) {
      throw "AUTHORITY_CONFLICT: canonical parent authority '$($entry.Key)' is missing."
    }
    $authority[$entry.Key] = [pscustomobject][ordered]@{
      path = [string]$entry.Value
      commit = $ParentCommit
      blob_oid = [string]$blobProbe.output
    }
  }
  return [pscustomobject]$authority
}

function Assert-DanioTransitionPathScope {
  param(
    [Parameter(Mandatory = $true)][string[]]$ChangedPaths,
    [Parameter(Mandatory = $true)][string]$Action,
    [string]$FailureCode = "TRANSITION_SCOPE_INVALID"
  )

  $allowed = @($statePath)
  if (@("launch", "closeout", "pause", "stop", "finalize", "complete", "finalization_stop") -ccontains $Action) {
    $allowed += @(
      "apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md",
      "apps/aquarium_app/docs/agent/SLICE_LOG.md"
    )
  }
  $normalized = @($ChangedPaths | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
  if (
    $normalized -cnotcontains $statePath -or
    @($normalized | Where-Object { $allowed -cnotcontains $_ }).Count -ne 0
  ) {
    throw "$FailureCode`: transition changed paths outside its exact state/handoff scope."
  }
}

function Assert-DanioClaimParentBinding {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$ParentCommit,
    [Parameter(Mandatory = $true)]$CandidateState
  )

  if ([string]$CandidateState.transition.action -cne "claim") {
    return
  }
  $parentTree = Invoke-DanioGit `
    -Root $Root `
    -Arguments @("rev-parse", "$ParentCommit^{tree}")
  if (
    $null -eq $CandidateState.owner -or
    [string]$CandidateState.owner.claim_parent_commit -cne $ParentCommit -or
    [string]$CandidateState.owner.claim_staged_tree_hash -cne $parentTree
  ) {
    throw "OWNER_REVISION_INVALID: claim owner is not bound to the exact parent commit and tree."
  }
}

function Test-DanioStrictInteger {
  param($Value)

  if ($null -eq $Value) {
    return $false
  }
  return @(
    [byte],
    [sbyte],
    [int16],
    [uint16],
    [int32],
    [uint32],
    [int64],
    [uint64]
  ) -contains $Value.GetType()
}

function Get-DanioBootstrapBudgetFence {
  param(
    [Parameter(Mandatory = $true)][string]$Content,
    [string]$FailureCode = "BOOTSTRAP_BUDGET_INVALID"
  )

  $markerPattern = '"document_type"\s*:\s*"danio_autonomy_bootstrap_budget"'
  $markerMatches = [regex]::Matches($Content, $markerPattern)
  $fenceMatches = [regex]::Matches(
    $Content,
    '(?ms)```json[^\r\n]*\r?\n(?<json>.*?)\r?\n```[ \t]*'
  )
  $markedFences = @(
    $fenceMatches | Where-Object {
      $_.Groups["json"].Value -cmatch $markerPattern
    }
  )
  if ($markerMatches.Count -ne 1 -or $markedFences.Count -ne 1) {
    throw "$FailureCode`: exactly one unambiguous bootstrap budget fence is required."
  }

  $rawJson = [string]$markedFences[0].Groups["json"].Value
  $value = & $module {
    param($RawJson, $Code)
    ConvertFrom-DanioStrictJson -Json $RawJson -FailureCode $Code
  } $rawJson $FailureCode
  if (
    $null -eq $value -or
    [string]$value.document_type -cne "danio_autonomy_bootstrap_budget"
  ) {
    throw "$FailureCode`: bootstrap budget marker and parsed document disagree."
  }
  return [pscustomobject]@{
    value = $value
    full_text = [string]$markedFences[0].Value
    index = [int]$markedFences[0].Index
    length = [int]$markedFences[0].Length
  }
}

function Read-DanioBootstrapBudgetBlock {
  param(
    [Parameter(Mandatory = $true)][string]$Content,
    [switch]$RequireAbsentOperationalState,
    [AllowNull()][string]$ExpectedOperationalStatePath = $null,
    [string]$FailureCode = "BOOTSTRAP_BUDGET_INVALID"
  )

  $block = (Get-DanioBootstrapBudgetFence `
    -Content $Content `
    -FailureCode $FailureCode).value
  $requiredFields = @(
    "document_type",
    "schema_version",
    "authorization_id",
    "total_approved_units",
    "consumed_units",
    "remaining_units_including_current",
    "last_closed_unit_id",
    "operational_state_path"
  )
  $observedFields = @($block.PSObject.Properties | ForEach-Object { $_.Name })
  if (
    $observedFields.Count -ne $requiredFields.Count -or
    @($requiredFields | Where-Object { $observedFields -cnotcontains $_ }).Count -ne 0 -or
    [string]$block.document_type -cne "danio_autonomy_bootstrap_budget" -or
    -not (Test-DanioStrictInteger -Value $block.schema_version) -or
    [int64]$block.schema_version -ne 1 -or
    $block.authorization_id -isnot [string] -or
    [string]::IsNullOrWhiteSpace([string]$block.authorization_id) -or
    -not (Test-DanioStrictInteger -Value $block.total_approved_units) -or
    -not (Test-DanioStrictInteger -Value $block.consumed_units) -or
    -not (Test-DanioStrictInteger -Value $block.remaining_units_including_current) -or
    [int64]$block.total_approved_units -le 0 -or
    [int64]$block.consumed_units -le 0 -or
    [int64]$block.remaining_units_including_current -lt 0 -or
    [int64]$block.consumed_units + [int64]$block.remaining_units_including_current -ne
      [int64]$block.total_approved_units -or
    $block.last_closed_unit_id -isnot [string] -or
    [string]$block.last_closed_unit_id -cnotmatch '^WF-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}$'
  ) {
    throw "$FailureCode`: bootstrap budget fields or arithmetic are invalid."
  }
  if ($RequireAbsentOperationalState) {
    if (
      [int64]$block.remaining_units_including_current -le 0 -or
      $null -ne $block.operational_state_path
    ) {
      throw "$FailureCode`: pre-activation budget must be positive and operational state path must be null."
    }
  } elseif (
    $block.operational_state_path -isnot [string] -or
    [string]$block.operational_state_path -cne $ExpectedOperationalStatePath
  ) {
    throw "$FailureCode`: historical operational state path is invalid."
  }
  return $block
}

function Get-DanioNormalizedBootstrapFenceText {
  param(
    [Parameter(Mandatory = $true)][string]$Content,
    [string]$FailureCode = "BOOTSTRAP_HANDOFF_INVALID"
  )

  $fence = Get-DanioBootstrapBudgetFence `
    -Content $Content `
    -FailureCode $FailureCode
  return $fence.full_text.Replace("`r`n", "`n").Replace("`r", "`n").TrimEnd()
}

function Test-DanioBootstrapBudgetValuesEqual {
  param(
    [AllowNull()]$Left,
    [AllowNull()]$Right
  )

  if ($null -eq $Left -or $null -eq $Right) {
    return $false
  }
  return (
    [string]$Left.document_type -ceq [string]$Right.document_type -and
    [int64]$Left.schema_version -eq [int64]$Right.schema_version -and
    [string]$Left.authorization_id -ceq [string]$Right.authorization_id -and
    [int64]$Left.total_approved_units -eq [int64]$Right.total_approved_units -and
    [int64]$Left.consumed_units -eq [int64]$Right.consumed_units -and
    [int64]$Left.remaining_units_including_current -eq
      [int64]$Right.remaining_units_including_current -and
    [string]$Left.last_closed_unit_id -ceq [string]$Right.last_closed_unit_id -and
    [string]$Left.operational_state_path -ceq [string]$Right.operational_state_path
  )
}

function Get-DanioSliceUnitCount {
  param(
    [Parameter(Mandatory = $true)][string]$Content,
    [Parameter(Mandatory = $true)][string]$WorkUnitId
  )

  return [regex]::Matches(
    $Content,
    "(?m)^\|\s*$([regex]::Escape($WorkUnitId))\s*\|"
  ).Count
}

function Get-DanioNextBootstrapUnitId {
  param([Parameter(Mandatory = $true)][string]$LastClosedUnitId)

  $match = [regex]::Match(
    $LastClosedUnitId,
    '^WF-(?<date>[0-9]{4}-[0-9]{2}-[0-9]{2})-(?<sequence>[0-9]{3})$'
  )
  if (-not $match.Success) {
    throw "BOOTSTRAP_BUDGET_INVALID: last closed unit ID is malformed."
  }
  $nextSequence = [int]$match.Groups["sequence"].Value + 1
  if ($nextSequence -gt 999) {
    throw "BOOTSTRAP_BUDGET_INVALID: bootstrap unit sequence is exhausted."
  }
  return "WF-$($match.Groups['date'].Value)-$($nextSequence.ToString('000'))"
}

function ConvertTo-DanioNormalizedWindowsPath {
  param([Parameter(Mandatory = $true)][string]$Path)

  return [IO.Path]::GetFullPath($Path).Replace("\", "/").TrimEnd("/")
}

function Get-DanioSelectedRepositoryIdentity {
  param([Parameter(Mandatory = $true)][string]$Root)

  $commonDirectory = Invoke-DanioGit `
    -Root $Root `
    -Arguments @("rev-parse", "--path-format=absolute", "--git-common-dir")
  $normalizedCommonDirectory = ConvertTo-DanioNormalizedWindowsPath -Path $commonDirectory
  if ([IO.Path]::GetFileName($normalizedCommonDirectory) -cne ".git") {
    throw "BOOTSTRAP_AUTHORIZATION_INVALID: selected repository has no canonical non-bare common directory."
  }
  $repositoryRoot = ConvertTo-DanioNormalizedWindowsPath `
    -Path (Split-Path -Parent $normalizedCommonDirectory)
  $savedProjectRoot = ConvertTo-DanioNormalizedWindowsPath `
    -Path (Split-Path -Parent $repositoryRoot)
  return [pscustomobject]@{
    repository_root = $repositoryRoot
    saved_project_root = $savedProjectRoot
  }
}

function Test-DanioOrdinaryDirectoryChain {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$Boundary
  )

  try {
    $resolvedPath = [IO.Path]::GetFullPath($Path).TrimEnd("\", "/")
    $resolvedBoundary = [IO.Path]::GetFullPath($Boundary).TrimEnd("\", "/")
    $requiredPrefix = "$resolvedBoundary$([IO.Path]::DirectorySeparatorChar)"
    if (-not $resolvedPath.StartsWith($requiredPrefix, [StringComparison]::OrdinalIgnoreCase)) {
      return $false
    }
    $current = Get-Item -LiteralPath $resolvedPath -Force
    while ($null -ne $current) {
      if (
        -not $current.Exists -or
        ($current.Attributes -band [IO.FileAttributes]::Directory) -eq 0 -or
        ($current.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0
      ) {
        return $false
      }
      $currentPath = [IO.Path]::GetFullPath($current.FullName).TrimEnd("\", "/")
      if ([string]::Equals($currentPath, $resolvedBoundary, [StringComparison]::OrdinalIgnoreCase)) {
        return $true
      }
      $current = $current.Parent
    }
    return $false
  } catch {
    return $false
  }
}

function Test-DanioDisposableFixtureAuthorizationOverride {
  param([Parameter(Mandatory = $true)][string]$Root)

  if ($env:DANIO_AUTONOMY_TEST_MODE -cne "1") {
    return $false
  }
  try {
    $tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd("\", "/")
    $selectedRoot = [IO.Path]::GetFullPath($Root).TrimEnd("\", "/")
    $requiredPrefix = "$tempRoot$([IO.Path]::DirectorySeparatorChar)"
    if (
      -not $selectedRoot.StartsWith($requiredPrefix, [StringComparison]::OrdinalIgnoreCase) -or
      -not (Test-DanioOrdinaryDirectoryChain -Path $selectedRoot -Boundary $tempRoot)
    ) {
      return $false
    }
    $selectedIdentity = Get-DanioSelectedRepositoryIdentity -Root $selectedRoot
    $canonicalRepositoryRoot = [IO.Path]::GetFullPath(
      [string]$selectedIdentity.repository_root
    ).TrimEnd("\", "/")
    $commonDirectory = [IO.Path]::GetFullPath(
      (Invoke-DanioGit `
        -Root $selectedRoot `
        -Arguments @("rev-parse", "--path-format=absolute", "--git-common-dir"))
    ).TrimEnd("\", "/")
    $expectedCommonDirectory = [IO.Path]::GetFullPath(
      (Join-Path $canonicalRepositoryRoot ".git")
    ).TrimEnd("\", "/")
    if (
      -not (Test-DanioOrdinaryDirectoryChain `
        -Path $canonicalRepositoryRoot `
        -Boundary $tempRoot) -or
      -not (Test-DanioOrdinaryDirectoryChain `
        -Path $commonDirectory `
        -Boundary $tempRoot) -or
      -not [string]::Equals(
        $commonDirectory,
        $expectedCommonDirectory,
        [StringComparison]::OrdinalIgnoreCase
      )
    ) {
      return $false
    }

    $fetchUrls = @(
      (Invoke-DanioGit -Root $selectedRoot -Arguments @("remote", "get-url", "--all", "origin")) `
        -split "`r?`n" |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    )
    $pushUrls = @(
      (Invoke-DanioGit -Root $selectedRoot -Arguments @("remote", "get-url", "--push", "--all", "origin")) `
        -split "`r?`n" |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    )
    if ($fetchUrls.Count -ne 1 -or $pushUrls.Count -ne 1) {
      return $false
    }
    foreach ($url in @([string]$fetchUrls[0], [string]$pushUrls[0])) {
      if ($url -match '^[A-Za-z][A-Za-z0-9+.-]*://' -or $url -match '^[^/\\]+@[^:]+:') {
        return $false
      }
    }
    $fetchRoot = [IO.Path]::GetFullPath($(if ([IO.Path]::IsPathRooted([string]$fetchUrls[0])) {
      [string]$fetchUrls[0]
    } else {
      Join-Path $selectedRoot ([string]$fetchUrls[0])
    })).TrimEnd("\", "/")
    $pushRoot = [IO.Path]::GetFullPath($(if ([IO.Path]::IsPathRooted([string]$pushUrls[0])) {
      [string]$pushUrls[0]
    } else {
      Join-Path $selectedRoot ([string]$pushUrls[0])
    })).TrimEnd("\", "/")
    if (
      -not [string]::Equals($fetchRoot, $pushRoot, [StringComparison]::OrdinalIgnoreCase) -or
      -not $fetchRoot.StartsWith($requiredPrefix, [StringComparison]::OrdinalIgnoreCase) -or
      -not (Test-DanioOrdinaryDirectoryChain -Path $fetchRoot -Boundary $tempRoot)
    ) {
      return $false
    }
    if (
      (Invoke-DanioGit -Root $fetchRoot -Arguments @("rev-parse", "--is-bare-repository")) -cne "true"
    ) {
      return $false
    }
    return $true
  } catch {
    return $false
  }
}

function Get-DanioMarkdownHeadings {
  param([Parameter(Mandatory = $true)][string]$Content)

  return @(
    [regex]::Matches($Content, '(?m)^#{1,6}\s+[^\r\n]+$') |
      ForEach-Object { [string]$_.Value }
  )
}

function Get-DanioMarkdownLevelTwoDocument {
  param(
    [Parameter(Mandatory = $true)][string]$Content,
    [string]$FailureCode = "BOOTSTRAP_HANDOFF_INVALID"
  )

  $normalized = $Content.Replace("`r`n", "`n").Replace("`r", "`n").TrimEnd()
  $matches = [regex]::Matches($normalized, '(?m)^## [^\n]+$')
  if ($matches.Count -eq 0) {
    throw "$FailureCode`: the handoff has no level-two sections."
  }
  $preamble = $normalized.Substring(0, $matches[0].Index).TrimEnd()
  $sections = @(
    for ($index = 0; $index -lt $matches.Count; $index += 1) {
      $bodyStart = $matches[$index].Index + $matches[$index].Length
      $bodyEnd = if ($index + 1 -lt $matches.Count) {
        $matches[$index + 1].Index
      } else {
        $normalized.Length
      }
      $body = $normalized.Substring($bodyStart, $bodyEnd - $bodyStart)
      [pscustomobject]@{
        heading = [string]$matches[$index].Value
        body = $body.Trim([char[]]@("`n"))
      }
    }
  )
  return [pscustomobject]@{
    preamble = $preamble
    sections = $sections
  }
}

function Assert-DanioExactBootstrapHandoffTransformation {
  param(
    [Parameter(Mandatory = $true)][string]$ParentContent,
    [Parameter(Mandatory = $true)][string]$CandidateContent
  )

  $parentDocument = Get-DanioMarkdownLevelTwoDocument -Content $ParentContent
  $candidateDocument = Get-DanioMarkdownLevelTwoDocument -Content $CandidateContent
  $parentHeadings = @($parentDocument.sections | ForEach-Object { [string]$_.heading })
  $candidateHeadings = @($candidateDocument.sections | ForEach-Object { [string]$_.heading })
  if (-not (Test-DanioOrdinalStringArrayEqual -Left $parentHeadings -Right $candidateHeadings)) {
    throw "BOOTSTRAP_HANDOFF_INVALID: activation must preserve every level-two heading in order."
  }

  $parentPreambleLines = @($parentDocument.preamble -split "`n")
  if (
    $parentPreambleLines.Count -lt 1 -or
    [string]$parentPreambleLines[0] -cnotmatch '^# [^#].+$'
  ) {
    throw "BOOTSTRAP_HANDOFF_INVALID: parent handoff title is invalid."
  }
  $expectedPreamble = @(
    [string]$parentPreambleLines[0],
    "",
    $activationStatusLine,
    $activationUpdatedLine
  ) -join "`n"
  if ([string]$candidateDocument.preamble -cne $expectedPreamble) {
    throw "BOOTSTRAP_HANDOFF_INVALID: activation handoff preamble is not the exact Task 13 form."
  }

  $candidateFence = Get-DanioBootstrapBudgetFence `
    -Content $CandidateContent `
    -FailureCode "BOOTSTRAP_HANDOFF_INVALID"
  $expectedAuthorizationBody = @(
    $historicalBootstrapSentence,
    "",
    $candidateFence.full_text.Replace("`r`n", "`n").Replace("`r", "`n").TrimEnd()
  ) -join "`n"
  for ($index = 0; $index -lt $parentDocument.sections.Count; $index += 1) {
    $heading = [string]$parentDocument.sections[$index].heading
    $expectedBody = switch -CaseSensitive ($heading) {
      "## Branch" { $activationBranchBody; break }
      "## Autonomous Chain Authorization" { $expectedAuthorizationBody; break }
      "## Blockers" { $activationBlockersBody; break }
      "## Next Action" { $activationNextActionBody; break }
      default { [string]$parentDocument.sections[$index].body; break }
    }
    if ([string]$candidateDocument.sections[$index].body -cne $expectedBody) {
      throw "BOOTSTRAP_HANDOFF_INVALID: section '$heading' is not the exact allowed Task 13 transformation."
    }
  }
}

function Test-DanioOrdinalStringArrayEqual {
  param(
    [Parameter(Mandatory = $true)][string[]]$Left,
    [Parameter(Mandatory = $true)][string[]]$Right
  )

  if ($Left.Count -ne $Right.Count) {
    return $false
  }
  for ($index = 0; $index -lt $Left.Count; $index += 1) {
    if ([string]$Left[$index] -cne [string]$Right[$index]) {
      return $false
    }
  }
  return $true
}

function Assert-DanioBootstrapSliceHistory {
  param(
    [Parameter(Mandatory = $true)][string]$SliceLogContent,
    [Parameter(Mandatory = $true)]$Bootstrap
  )

  $match = [regex]::Match(
    [string]$Bootstrap.last_closed_unit_id,
    '^WF-(?<date>[0-9]{4}-[0-9]{2}-[0-9]{2})-(?<sequence>[0-9]{3})$'
  )
  if (-not $match.Success) {
    throw "BOOTSTRAP_BUDGET_INVALID: last closed unit ID is malformed."
  }
  $lastSequence = [int]$match.Groups["sequence"].Value
  $firstSequence = $lastSequence - [int64]$Bootstrap.consumed_units + 1
  if ($firstSequence -lt 0) {
    throw "BOOTSTRAP_BUDGET_INVALID: consumed units exceed the recorded workflow sequence."
  }
  foreach ($sequence in $firstSequence..$lastSequence) {
    $workUnitId = "WF-$($match.Groups['date'].Value)-$($sequence.ToString('000'))"
    if (
      (Get-DanioSliceUnitCount `
        -Content $SliceLogContent `
        -WorkUnitId $workUnitId) -ne 1
    ) {
      throw "BOOTSTRAP_BUDGET_INVALID: consumed bootstrap unit '$workUnitId' is not recorded exactly once."
    }
  }
}

function Assert-DanioActivationCreationCommitProof {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$CreationCommit
  )

  try {
    $parentLine = Invoke-DanioGit `
      -Root $Root `
      -Arguments @("rev-list", "--parents", "-n", "1", $CreationCommit)
    $parentParts = @(
      $parentLine -split '\s+' |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    )
    if ($parentParts.Count -ne 2 -or [string]$parentParts[0] -cne $CreationCommit) {
      throw "state creation commit must have one exact parent."
    }
    $activationParent = [string]$parentParts[1]
    $activationTree = Invoke-DanioGit `
      -Root $Root `
      -Arguments @("rev-parse", "$CreationCommit^{tree}")
    $candidateState = Read-DanioGitJsonBlob `
      -Root $Root `
      -Revision $CreationCommit `
      -Path $statePath
    $candidateValidation = Test-DanioRunState -State $candidateState
    if (-not $candidateValidation.valid) {
      throw "activation state is invalid: $($candidateValidation.code)."
    }
    $changedPaths = Invoke-DanioGit `
      -Root $Root `
      -Arguments @(
        "diff-tree",
        "--no-commit-id",
        "--name-only",
        "-r",
        $CreationCommit
      )
    Assert-DanioTransitionPathScope `
      -ChangedPaths @($changedPaths -split "`r?`n") `
      -Action ([string]$candidateState.transition.action)

    $previousContextParameters = @{
      Root = $Root
      ParentRevision = $activationParent
    }
    if (Test-DanioDisposableFixtureAuthorizationOverride -Root $Root) {
      $previousContextParameters.ExpectedAuthorization = $candidateState.authorization
    }
    $previousContext = Resolve-DanioPreviousStateContext @previousContextParameters
    if ([string]$previousContext.origin -cne "bootstrap_absent") {
      throw "state creation parent is not the absent bootstrap authority."
    }
    Assert-DanioBootstrapActivationOutputs `
      -Root $Root `
      -Context $previousContext `
      -CandidateState $candidateState `
      -CandidateRevision $CreationCommit
    Assert-DanioClaimParentBinding `
      -Root $Root `
      -ParentCommit $activationParent `
      -CandidateState $candidateState
    Assert-DanioTransitionPreflight `
      -PreviousState $previousContext.state `
      -CandidateState $candidateState `
      -ExpectedCandidateAuthority $previousContext.parent_authority
    $transitionProof = Get-DanioTransitionProof `
      -Root $Root `
      -ParentCommit $activationParent `
      -PreviousState $previousContext.state `
      -CandidateState $candidateState `
      -CandidateCommit $CreationCommit
    $transitionValidation = Test-DanioRunStateTransition `
      -PreviousState $previousContext.state `
      -CandidateState $candidateState `
      -LedgerRows @($transitionProof.ledger_rows) `
      -ActivePhaseLedgerIds @($transitionProof.active_phase_ledger_ids) `
      -ExpectedCandidateAuthority $previousContext.parent_authority
    if (-not $transitionValidation.valid) {
      throw "activation transition is invalid: $($transitionValidation.code)."
    }
    Assert-DanioTerminalCompletionReady `
      -Root $Root `
      -ParentCommit $activationParent `
      -PreviousState $previousContext.state `
      -CandidateState $candidateState `
      -Proof $transitionProof

    $subject = Invoke-DanioGit `
      -Root $Root `
      -Arguments @("log", "-1", "--format=%s", $CreationCommit)
    if ($subject -cne "chore: activate autonomous phone completion") {
      throw "activation commit subject is not exact."
    }
    $message = Invoke-DanioGit `
      -Root $Root `
      -Arguments @("log", "-1", "--format=%B", $CreationCommit)
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
    $trailers = @{}
    foreach ($trailerName in @(
      "Danio-State-Tree",
      "Danio-State-Validation",
      "Danio-Docs-Profile",
      "Danio-Verified-At"
    )) {
      $matchingLines = @(
        $terminalTrailerLines | Where-Object {
          $_ -cmatch "^$([regex]::Escape($trailerName)):\s*[^\r\n]+$"
        }
      )
      if ($matchingLines.Count -ne 1) {
        throw "activation trailer '$trailerName' is not unique."
      }
      $trailers[$trailerName] = $matchingLines[0].Substring(
        $matchingLines[0].IndexOf(":") + 1
      ).Trim()
    }
    if (
      @($terminalTrailerLines | Where-Object {
        $_ -cmatch '^Danio-Evidence-Manifest:\s*[^\r\n]+$'
      }).Count -ne 0 -or
      [string]$trailers["Danio-State-Tree"] -cne $activationTree -or
      [string]$trailers["Danio-State-Validation"] -cne "pass" -or
      [string]$trailers["Danio-Docs-Profile"] -cne "pass" -or
      -not (Test-StrictUtc -Value $trailers["Danio-Verified-At"])
    ) {
      throw "activation commit trailers do not match the exact tree proof."
    }
  } catch {
    if ($_.Exception.Message -like "BOOTSTRAP_ACTIVATION_PROOF_INVALID:*") {
      throw
    }
    throw "BOOTSTRAP_ACTIVATION_PROOF_INVALID: $($_.Exception.Message)"
  }
}

function Resolve-DanioPreviousStateContext {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$ParentRevision,
    [AllowNull()]$ExpectedAuthorization = $null
  )

  $stateEntry = Invoke-DanioGit `
    -Root $Root `
    -Arguments @("ls-tree", "-r", "--name-only", $ParentRevision, "--", $statePath)
  if (-not [string]::IsNullOrWhiteSpace($stateEntry)) {
    if ([string]$stateEntry -cne $statePath) {
      throw "STATE_BLOB_INVALID: parent state lookup returned an unexpected path."
    }
    $handoffContent = Read-DanioGitTextBlob `
      -Root $Root `
      -Revision $ParentRevision `
      -Path $activeHandoffPath
    try {
      $currentHistoricalBootstrap = Read-DanioBootstrapBudgetBlock `
        -Content $handoffContent `
        -ExpectedOperationalStatePath $statePath `
        -FailureCode "BOOTSTRAP_HANDOFF_INVALID"
      $currentHistoricalFenceText = Get-DanioNormalizedBootstrapFenceText `
        -Content $handoffContent `
        -FailureCode "BOOTSTRAP_HANDOFF_INVALID"
      $stateCreationText = Invoke-DanioGit `
        -Root $Root `
        -Arguments @("log", "--format=%H", "--diff-filter=A", $ParentRevision, "--", $statePath)
      $stateCreationCommits = @(
        $stateCreationText -split "`r?`n" |
          Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
      )
      if ($stateCreationCommits.Count -ne 1) {
        throw "BOOTSTRAP_HANDOFF_INVALID: live state does not have one unique creation commit."
      }
      Assert-DanioActivationCreationCommitProof `
        -Root $Root `
        -CreationCommit ([string]$stateCreationCommits[0])
      $activationHandoffContent = Read-DanioGitTextBlob `
        -Root $Root `
        -Revision ([string]$stateCreationCommits[0]) `
        -Path $activeHandoffPath
      $anchoredHistoricalBootstrap = Read-DanioBootstrapBudgetBlock `
        -Content $activationHandoffContent `
        -ExpectedOperationalStatePath $statePath `
        -FailureCode "BOOTSTRAP_HANDOFF_INVALID"
      $anchoredHistoricalFenceText = Get-DanioNormalizedBootstrapFenceText `
        -Content $activationHandoffContent `
        -FailureCode "BOOTSTRAP_HANDOFF_INVALID"
      $anchoredUnitId = [string]$anchoredHistoricalBootstrap.last_closed_unit_id
      if (
        -not (Test-DanioBootstrapBudgetValuesEqual `
          -Left $currentHistoricalBootstrap `
          -Right $anchoredHistoricalBootstrap) -or
        $currentHistoricalFenceText -cne $anchoredHistoricalFenceText -or
        [regex]::Matches(
          $activationHandoffContent,
          [regex]::Escape($historicalBootstrapSentence)
        ).Count -ne 1 -or
        [regex]::Matches(
          $handoffContent,
          [regex]::Escape($historicalBootstrapSentence)
        ).Count -ne 1 -or
        [regex]::Matches(
          $activationHandoffContent,
          [regex]::Escape($anchoredUnitId)
        ).Count -ne 1 -or
        [regex]::Matches(
          $handoffContent,
          [regex]::Escape($anchoredUnitId)
        ).Count -ne 1
      ) {
        throw "BOOTSTRAP_HANDOFF_INVALID: historical activation accounting differs from its creation commit."
      }
      $historicalBootstrap = $anchoredHistoricalBootstrap
      $historicalFenceText = $anchoredHistoricalFenceText
    } catch {
      if ($_.Exception.Message -like "BOOTSTRAP_ACTIVATION_PROOF_INVALID:*") {
        throw
      }
      $historicalBootstrap = $null
      $historicalFenceText = $null
    }
    return [pscustomobject]@{
      state = Read-DanioGitJsonBlob `
        -Root $Root `
        -Revision $ParentRevision `
        -Path $statePath
      origin = "live"
      bootstrap_budget = $historicalBootstrap
      bootstrap_fence_text = $historicalFenceText
      activation_closeout_unit_id = $null
      parent_authority = $null
      parent_slice_log_content = $null
      parent_handoff_content = $handoffContent
    }
  }

  $inactiveState = Read-DanioGitJsonBlob `
    -Root $Root `
    -Revision $ParentRevision `
    -Path $inactiveFixturePath
  $handoffContent = Read-DanioGitTextBlob `
    -Root $Root `
    -Revision $ParentRevision `
    -Path $activeHandoffPath
  $bootstrap = Read-DanioBootstrapBudgetBlock `
    -Content $handoffContent `
    -RequireAbsentOperationalState
  if (
    [string]$bootstrap.authorization_id -cne [string]$inactiveState.authorization.authorization_id -or
    [string]$bootstrap.authorization_id -cne [string]$inactiveState.run_id -or
    [int64]$bootstrap.total_approved_units -ne [int64]$inactiveState.budget.total_approved_units
  ) {
    throw "BOOTSTRAP_BUDGET_INVALID: bootstrap authorization or total does not match the approved run."
  }
  if (
    $null -ne $ExpectedAuthorization -and
    -not (Test-DanioDisposableFixtureAuthorizationOverride -Root $Root)
  ) {
    throw "BOOTSTRAP_AUTHORIZATION_INVALID: fixture authorization override is forbidden for the selected repository."
  }
  $selectedIdentity = if ($null -eq $ExpectedAuthorization) {
    Get-DanioSelectedRepositoryIdentity -Root $Root
  } else {
    [pscustomobject]@{
      repository_root = [string]$ExpectedAuthorization.repository_root
      saved_project_root = [string]$ExpectedAuthorization.saved_project_root
    }
  }
  if (
    -not [string]::Equals(
      [string]$inactiveState.authorization.repository_root,
      [string]$selectedIdentity.repository_root,
      [StringComparison]::OrdinalIgnoreCase
    ) -or
    -not [string]::Equals(
      [string]$inactiveState.authorization.saved_project_root,
      [string]$selectedIdentity.saved_project_root,
      [StringComparison]::OrdinalIgnoreCase
    )
  ) {
    throw "BOOTSTRAP_AUTHORIZATION_INVALID: approved authorization roots '$($inactiveState.authorization.repository_root)' and '$($inactiveState.authorization.saved_project_root)' do not match selected roots '$($selectedIdentity.repository_root)' and '$($selectedIdentity.saved_project_root)'."
  }

  $sliceLogContent = Read-DanioGitTextBlob `
    -Root $Root `
    -Revision $ParentRevision `
    -Path $sliceLogPath
  Assert-DanioBootstrapSliceHistory `
    -SliceLogContent $sliceLogContent `
    -Bootstrap $bootstrap
  $activationCloseoutUnitId = Get-DanioNextBootstrapUnitId `
    -LastClosedUnitId ([string]$bootstrap.last_closed_unit_id)
  if (
    (Get-DanioSliceUnitCount `
      -Content $sliceLogContent `
      -WorkUnitId $activationCloseoutUnitId) -ne 0
  ) {
    throw "BOOTSTRAP_UNIT_ALREADY_RECORDED: Task 13 closeout unit already exists in the parent log."
  }

  $syntheticState = $inactiveState | ConvertTo-Json -Depth 100 | ConvertFrom-Json
  $syntheticState.authority = Get-DanioParentAuthority `
    -Root $Root `
    -ParentCommit $ParentRevision
  $syntheticState.budget.total_approved_units = [int64]$bootstrap.total_approved_units
  $syntheticState.budget.consumed_units = [int64]$bootstrap.consumed_units
  $syntheticState.budget.remaining_units_including_current = [int64]$bootstrap.remaining_units_including_current
  $syntheticState.budget.current_charge.work_unit_id = $null
  $syntheticState.budget.current_charge.status = "none"
  $syntheticState.budget.current_charge.claimed_revision = $null
  $syntheticState.budget.current_charge.consumed_revision = $null

  return [pscustomobject]@{
    state = $syntheticState
    origin = "bootstrap_absent"
    bootstrap_budget = $bootstrap
    bootstrap_fence_text = $null
    activation_closeout_unit_id = $activationCloseoutUnitId
    parent_authority = $syntheticState.authority
    parent_slice_log_content = $sliceLogContent
    parent_handoff_content = $handoffContent
  }
}

function Read-DanioPreviousState {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$ParentRevision
  )

  return (Resolve-DanioPreviousStateContext `
    -Root $Root `
    -ParentRevision $ParentRevision).state
}

function Read-DanioCandidateTextBlob {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$Path,
    [switch]$Index,
    [AllowNull()][string]$Revision = $null
  )

  $objectSpec = if ($Index) { ":$Path" } else { "$Revision`:$Path" }
  $probe = Invoke-DanioGitProbe -Root $Root -Arguments @("show", $objectSpec)
  if ($probe.exit_code -ne 0) {
    throw "BOOTSTRAP_HANDOFF_INVALID: candidate blob '$objectSpec' is missing."
  }
  return [string]$probe.output
}

function Assert-DanioBootstrapActivationOutputs {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)]$Context,
    [Parameter(Mandatory = $true)]$CandidateState,
    [switch]$Index,
    [AllowNull()][string]$CandidateRevision = $null
  )

  if (
    [string]$Context.origin -ceq "live" -and
    [string]$CandidateState.transition.action -ceq "launch"
  ) {
    throw "LIVE_STATE_ALREADY_EXISTS: Task 13 launch requires an absent parent state path."
  }
  if ([string]$Context.origin -ceq "live") {
    if ($null -eq $Context.bootstrap_budget) {
      throw "BOOTSTRAP_HANDOFF_INVALID: a live parent is missing immutable historical activation accounting."
    }
    $candidateHandoffContent = Read-DanioCandidateTextBlob `
      -Root $Root `
      -Path $activeHandoffPath `
      -Index:$Index `
      -Revision $CandidateRevision
    $candidateHistoricalBootstrap = Read-DanioBootstrapBudgetBlock `
      -Content $candidateHandoffContent `
      -ExpectedOperationalStatePath $statePath `
      -FailureCode "BOOTSTRAP_HANDOFF_INVALID"
    $candidateHistoricalFenceText = Get-DanioNormalizedBootstrapFenceText `
      -Content $candidateHandoffContent `
      -FailureCode "BOOTSTRAP_HANDOFF_INVALID"
    $parentHistoricalBootstrap = $Context.bootstrap_budget
    $historicalUnitId = [string]$parentHistoricalBootstrap.last_closed_unit_id
    if (
      $candidateHistoricalFenceText -cne [string]$Context.bootstrap_fence_text -or
      [string]$candidateHistoricalBootstrap.authorization_id -cne
        [string]$parentHistoricalBootstrap.authorization_id -or
      [int64]$candidateHistoricalBootstrap.total_approved_units -ne
        [int64]$parentHistoricalBootstrap.total_approved_units -or
      [int64]$candidateHistoricalBootstrap.consumed_units -ne
        [int64]$parentHistoricalBootstrap.consumed_units -or
      [int64]$candidateHistoricalBootstrap.remaining_units_including_current -ne
        [int64]$parentHistoricalBootstrap.remaining_units_including_current -or
      [string]$candidateHistoricalBootstrap.last_closed_unit_id -cne $historicalUnitId -or
      [regex]::Matches(
        $candidateHandoffContent,
        [regex]::Escape($historicalUnitId)
      ).Count -ne 1 -or
      [regex]::Matches(
        $candidateHandoffContent,
        [regex]::Escape($historicalBootstrapSentence)
      ).Count -ne 1
    ) {
      throw "BOOTSTRAP_HANDOFF_INVALID: the historical activation accounting changed after launch."
    }
    return
  }
  if ([string]$Context.origin -cne "bootstrap_absent") {
    return
  }
  if ([string]$CandidateState.transition.action -cne "launch") {
    throw "LIVE_STATE_MISSING: an absent parent state permits only Task 13 launch."
  }

  $expectedCursor = [pscustomobject][ordered]@{
    phase = "1-data-resilience"
    work_unit_id = "DCL-DR-001-restore-matrix-audit"
    ledger_row_ids = @("DCL-DR-001")
  }
  $cursorMatches = & $module {
    param($Observed, $Expected)
    (ConvertTo-DanioCanonicalJson -Value $Observed) -ceq
      (ConvertTo-DanioCanonicalJson -Value $Expected)
  } $CandidateState.cursor $expectedCursor
  $expectedControlSurfaceSync = [pscustomobject][ordered]@{
    status = "not_required"
    target_commit = $null
    figma_file_id = $null
    figma_node_ids = @()
    attempted_at_utc = $null
    evidence_sha256 = $null
    failure_code = $null
  }
  $controlSurfaceMatches = & $module {
    param($Observed, $Expected)
    (ConvertTo-DanioCanonicalJson -Value $Observed) -ceq
      (ConvertTo-DanioCanonicalJson -Value $Expected)
  } $CandidateState.control_surface_sync $expectedControlSurfaceSync
  if (
    -not $cursorMatches -or
    -not $controlSurfaceMatches -or
    $null -ne $CandidateState.owner -or
    [int64]$CandidateState.handoff_generation -ne 0 -or
    $null -ne $CandidateState.transition.reason_code -or
    [string]$CandidateState.budget.current_charge.status -cne "none" -or
    $null -ne $CandidateState.budget.current_charge.work_unit_id -or
    $null -ne $CandidateState.budget.current_charge.claimed_revision -or
    $null -ne $CandidateState.budget.current_charge.consumed_revision -or
    $null -ne $CandidateState.last_verified_checkpoint -or
    $null -ne $CandidateState.repeated_failure -or
    $null -ne $CandidateState.stop_reason_code -or
    $null -ne $CandidateState.recovery
  ) {
    throw "BOOTSTRAP_HANDOFF_INVALID: initial ready state does not match the exact inactive-to-ready bootstrap defaults."
  }

  $handoffContent = Read-DanioCandidateTextBlob `
    -Root $Root `
    -Path $activeHandoffPath `
    -Index:$Index `
    -Revision $CandidateRevision
  $candidateBootstrap = Read-DanioBootstrapBudgetBlock `
    -Content $handoffContent `
    -ExpectedOperationalStatePath $statePath `
    -FailureCode "BOOTSTRAP_HANDOFF_INVALID"
  $parentBootstrap = $Context.bootstrap_budget
  $activationUnitId = [string]$Context.activation_closeout_unit_id
  Assert-DanioExactBootstrapHandoffTransformation `
    -ParentContent ([string]$Context.parent_handoff_content) `
    -CandidateContent $handoffContent
  if (
    [string]$candidateBootstrap.authorization_id -cne [string]$parentBootstrap.authorization_id -or
    [int64]$candidateBootstrap.total_approved_units -ne [int64]$CandidateState.budget.total_approved_units -or
    [int64]$candidateBootstrap.consumed_units -ne [int64]$CandidateState.budget.consumed_units -or
    [int64]$candidateBootstrap.remaining_units_including_current -ne
      [int64]$CandidateState.budget.remaining_units_including_current -or
    [string]$candidateBootstrap.last_closed_unit_id -cne
      $activationUnitId -or
    [regex]::Matches($handoffContent, [regex]::Escape($activationUnitId)).Count -ne 1 -or
    [regex]::Matches(
      $handoffContent,
      [regex]::Escape($historicalBootstrapSentence)
    ).Count -ne 1
  ) {
    throw "BOOTSTRAP_HANDOFF_INVALID: historical handoff accounting or preserved history does not match the activated run state."
  }

  $sliceLogContent = Read-DanioCandidateTextBlob `
    -Root $Root `
    -Path $sliceLogPath `
    -Index:$Index `
    -Revision $CandidateRevision
  $parentSliceLog = ([string]$Context.parent_slice_log_content).Replace("`r`n", "`n").TrimEnd()
  $candidateSliceLog = $sliceLogContent.Replace("`r`n", "`n").TrimEnd()
  $expectedSlicePrefix = "$parentSliceLog`n"
  $expectedActivationSliceRow = "| $activationUnitId | 2026-07-13 | Activate autonomous phone completion | live state, handoff, slice log | staged validator, Docs, clean alignment | ready | this activation commit | Create or reuse the explicit launch task; no product work here |"
  $sliceSuffixLines = @()
  if ($candidateSliceLog.StartsWith($expectedSlicePrefix, [StringComparison]::Ordinal)) {
    $sliceSuffixLines = @(
      $candidateSliceLog.Substring($expectedSlicePrefix.Length) -split "`n" |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    )
  }
  if (
    $sliceSuffixLines.Count -ne 1 -or
    [string]$sliceSuffixLines[0] -cne $expectedActivationSliceRow -or
    [regex]::Matches($candidateSliceLog, [regex]::Escape($activationUnitId)).Count -ne 1
  ) {
    throw "BOOTSTRAP_SLICE_LOG_INVALID: the exact Task 13 closeout row must appear once as the only candidate suffix."
  }
}

function Read-DanioGitTextBlob {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$Revision,
    [Parameter(Mandatory = $true)][string]$Path
  )

  $probe = Invoke-DanioGitProbe -Root $Root -Arguments @("show", "$Revision`:$Path")
  if ($probe.exit_code -ne 0) {
    throw "EVIDENCE_MANIFEST_INVALID: committed blob '$Revision`:$Path' is missing."
  }
  return [string]$probe.output
}

function Assert-DanioEvidenceProbeShape {
  param([Parameter(Mandatory = $true)][AllowNull()]$Manifest)

  $required = @(
    "schema_version",
    "product_commit",
    "work_unit_id",
    "ledger_row_ids",
    "commands",
    "environment",
    "artifacts",
    "checks",
    "overall_status"
  )
  if ($null -eq $Manifest) {
    throw "EVIDENCE_MANIFEST_INVALID: evidence manifest cannot be null."
  }
  $names = @($Manifest.PSObject.Properties | ForEach-Object { $_.Name })
  if (
    $names.Count -ne $required.Count -or
    @($required | Where-Object { $names -cnotcontains $_ }).Count -ne 0 -or
    -not (Test-GitOid -Value $Manifest.product_commit) -or
    $Manifest.artifacts -isnot [System.Array]
  ) {
    throw "EVIDENCE_MANIFEST_INVALID: evidence manifest cannot be probed safely."
  }
  foreach ($artifact in @($Manifest.artifacts)) {
    if ($null -eq $artifact) {
      throw "EVIDENCE_MANIFEST_INVALID: evidence artifact cannot be null."
    }
    $artifactNames = @($artifact.PSObject.Properties | ForEach-Object { $_.Name })
    if (
      $artifactNames.Count -ne 3 -or
      @(@("kind", "path", "sha256") | Where-Object { $artifactNames -cnotcontains $_ }).Count -ne 0 -or
      $artifact.path -isnot [string] -or
      [string]::IsNullOrWhiteSpace([string]$artifact.path) -or
      [string]$artifact.path -cnotmatch '^[A-Za-z0-9._/-]+$' -or
      [string]$artifact.path -match '(^|/|\\)\.\.($|/|\\)' -or
      [IO.Path]::IsPathRooted([string]$artifact.path)
    ) {
      throw "EVIDENCE_MANIFEST_INVALID: evidence artifact cannot be probed safely."
    }
  }
}

function Get-DanioGitBlobSha256 {
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
    throw "EVIDENCE_MANIFEST_INVALID: artifact path cannot be probed safely."
  }

  $objectProbe = Invoke-DanioGitProbe -Root $Root -Arguments @("rev-parse", "$Revision`:$Path")
  if ($objectProbe.exit_code -ne 0 -or -not (Test-GitOid -Value $objectProbe.output)) {
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
      throw "EVIDENCE_MANIFEST_INVALID: artifact blob process did not start."
    }
    $errorTask = $process.StandardError.ReadToEndAsync()
    $process.StandardOutput.BaseStream.CopyTo($memory)
    $process.WaitForExit()
    $errorText = $errorTask.Result
    if ($process.ExitCode -ne 0) {
      throw "EVIDENCE_MANIFEST_INVALID: artifact blob cannot be read: $errorText"
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

function Get-DanioActivePhaseLedgerIds {
  param([Parameter(Mandatory = $true)][object[]]$Rows)

  $nonReleaseIds = @(
    $Rows | Where-Object {
      (
        [string]$_.Table -ceq "Active Findings" -and
        [string]$_.ClosureState -cne "parked" -and
        [string]$_.Id -cne "DCL-RC-001"
      ) -or
      [string]$_.Disposition -ceq "ACCEPTED_LOCAL_LIMITATION"
    } | ForEach-Object { [string]$_.Id }
  )
  return @($nonReleaseIds) + @("DCL-RC-001")
}

function Assert-DanioParentStateProvenance {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$ParentCommit,
    [Parameter(Mandatory = $true)]$ObservedState
  )

  $stateCommit = Invoke-DanioGit `
    -Root $Root `
    -Arguments @("log", "-1", "--format=%H", $ParentCommit, "--", $statePath)
  if (-not (Test-GitOid -Value $stateCommit)) {
    throw "PARENT_STATE_PROVENANCE_INVALID: no committed run-state transition exists."
  }
  $stateCommitBlob = Invoke-DanioGit `
    -Root $Root `
    -Arguments @("rev-parse", "$stateCommit`:$statePath")
  $parentStateBlob = Invoke-DanioGit `
    -Root $Root `
    -Arguments @("rev-parse", "$ParentCommit`:$statePath")
  if ($stateCommitBlob -cne $parentStateBlob) {
    throw "PARENT_STATE_PROVENANCE_INVALID: evidence history changed the run state outside a typed transition."
  }
  $stateAtTransition = Read-DanioGitJsonBlob `
    -Root $Root `
    -Revision $stateCommit `
    -Path $statePath
  $stateIdentityMatches = & $module {
    param($Left, $Right)
    (ConvertTo-DanioCanonicalJson -Value $Left) -ceq
      (ConvertTo-DanioCanonicalJson -Value $Right)
  } $stateAtTransition $ObservedState
  if (-not $stateIdentityMatches) {
    throw "PARENT_STATE_PROVENANCE_INVALID: parent state bytes do not match the last typed transition."
  }

  $parentsText = Invoke-DanioGit `
    -Root $Root `
    -Arguments @("rev-list", "--parents", "-n", "1", $stateCommit)
  $parentParts = @($parentsText -split '\s+' | Where-Object { $_ -ne "" })
  if ($parentParts.Count -ne 2) {
    throw "PARENT_STATE_PROVENANCE_INVALID: state transition must have exactly one parent."
  }
  $stateParent = [string]$parentParts[1]
  $previousBeforeTransition = Read-DanioPreviousState `
    -Root $Root `
    -ParentRevision $stateParent
  $action = [string]$stateAtTransition.transition.action
  if (@("claim", "finalize") -cnotcontains $action) {
    throw "PARENT_STATE_PROVENANCE_INVALID: active/finalizing parent does not originate from claim/finalize."
  }
  $stateTransitionPathsText = Invoke-DanioGit `
    -Root $Root `
    -Arguments @("diff-tree", "--no-commit-id", "--name-only", "-r", $stateCommit)
  Assert-DanioTransitionPathScope `
    -ChangedPaths @($stateTransitionPathsText -split "`r?`n") `
    -Action $action `
    -FailureCode "PARENT_STATE_PROVENANCE_INVALID"

  $transitionParameters = @{
    PreviousState = $previousBeforeTransition
    CandidateState = $stateAtTransition
  }
  if ($action -ceq "finalize") {
    $ledgerContent = Read-DanioGitTextBlob `
      -Root $Root `
      -Revision $stateParent `
      -Path $ledgerPath
    try {
      $ledgerRows = @(Read-DanioLedgerClosureRows -Content $ledgerContent)
    } catch {
      throw "PARENT_STATE_PROVENANCE_INVALID: finalizing parent ledger is malformed."
    }
    $transitionParameters.LedgerRows = @($ledgerRows)
    $transitionParameters.ActivePhaseLedgerIds = @(Get-DanioActivePhaseLedgerIds -Rows $ledgerRows)
    $transitionParameters.ExpectedCandidateAuthority = Get-DanioParentAuthority `
      -Root $Root `
      -ParentCommit $stateParent
  }
  $transitionValidation = Test-DanioRunStateTransition @transitionParameters
  if (-not $transitionValidation.valid) {
    throw "PARENT_STATE_PROVENANCE_INVALID: prior transition is invalid: $($transitionValidation.code)."
  }
  if ($action -ceq "claim") {
    $stateParentTree = Invoke-DanioGit `
      -Root $Root `
      -Arguments @("rev-parse", "$stateParent^{tree}")
    if (
      [string]$stateAtTransition.owner.claim_parent_commit -cne $stateParent -or
      [string]$stateAtTransition.owner.claim_staged_tree_hash -cne $stateParentTree
    ) {
      throw "PARENT_STATE_PROVENANCE_INVALID: claim owner is not bound to its exact parent tree."
    }
  }

  $treeHash = Invoke-DanioGit `
    -Root $Root `
    -Arguments @("rev-parse", "$stateCommit^{tree}")
  $message = Invoke-DanioGit `
    -Root $Root `
    -Arguments @("log", "-1", "--format=%B", $stateCommit)
  $messageLines = @($message -split "`r?`n")
  $lineIndex = $messageLines.Count - 1
  while ($lineIndex -ge 0 -and [string]::IsNullOrWhiteSpace($messageLines[$lineIndex])) {
    $lineIndex -= 1
  }
  $terminalTrailers = New-Object System.Collections.Generic.List[string]
  while (
    $lineIndex -ge 0 -and
    $messageLines[$lineIndex] -cmatch '^[A-Za-z0-9-]+:\s*[^\r\n]+$'
  ) {
    $terminalTrailers.Insert(0, [string]$messageLines[$lineIndex])
    $lineIndex -= 1
  }
  $requiredTrailers = @(
    "Danio-State-Tree",
    "Danio-State-Validation",
    "Danio-Docs-Profile",
    "Danio-Verified-At"
  )
  if ($action -ceq "finalize") {
    $requiredTrailers += "Danio-Evidence-Manifest"
  }
  $values = @{}
  foreach ($name in $requiredTrailers) {
    $matches = @($terminalTrailers | Where-Object {
      $_ -cmatch "^$([regex]::Escape($name)):\s*[^\r\n]+$"
    })
    if ($matches.Count -ne 1) {
      throw "PARENT_STATE_PROVENANCE_INVALID: prior transition trailers are incomplete or duplicated."
    }
    $values[$name] = $matches[0].Substring($matches[0].IndexOf(":" ) + 1).Trim()
  }
  $unexpectedEvidence = @($terminalTrailers | Where-Object {
    $_ -cmatch '^Danio-Evidence-Manifest:\s*[^\r\n]+$'
  })
  if (
    $values["Danio-State-Tree"] -cne $treeHash -or
    $values["Danio-State-Validation"] -cne "pass" -or
    $values["Danio-Docs-Profile"] -cne "pass" -or
    -not (Test-StrictUtc -Value $values["Danio-Verified-At"]) -or
    ($action -ceq "claim" -and $unexpectedEvidence.Count -ne 0) -or
    ($action -ceq "finalize" -and [string]::IsNullOrWhiteSpace($values["Danio-Evidence-Manifest"]))
  ) {
    throw "PARENT_STATE_PROVENANCE_INVALID: prior transition proof does not match its committed tree."
  }
  if ($action -ceq "finalize") {
    $historicalPath = [string]$stateAtTransition.last_verified_checkpoint.evidence_manifest_path
    if (
      [string]::IsNullOrWhiteSpace($historicalPath) -or
      [string]$values["Danio-Evidence-Manifest"] -cne $historicalPath
    ) {
      throw "PARENT_STATE_PROVENANCE_INVALID: prior finalize trailer is not bound to its historical checkpoint."
    }
    $historicalManifest = Read-DanioEvidenceJsonBlob `
      -Root $Root `
      -Revision $stateParent `
      -Path $historicalPath
    Assert-DanioEvidenceProbeShape -Manifest $historicalManifest
    $productProbe = Invoke-DanioGitProbe `
      -Root $Root `
      -Arguments @("rev-parse", "$($historicalManifest.product_commit)^{commit}")
    $ancestorProbe = Invoke-DanioGitProbe `
      -Root $Root `
      -Arguments @("merge-base", "--is-ancestor", [string]$historicalManifest.product_commit, $stateParent)
    if (
      $productProbe.exit_code -ne 0 -or
      [string]$productProbe.output -cne [string]$historicalManifest.product_commit -or
      $ancestorProbe.exit_code -ne 0
    ) {
      throw "PARENT_STATE_PROVENANCE_INVALID: prior finalize product checkpoint is unreachable."
    }
    $artifactObservations = @()
    foreach ($artifact in @($historicalManifest.artifacts)) {
      $artifactObservations += Get-DanioGitBlobSha256 `
        -Root $Root `
        -Revision ([string]$historicalManifest.product_commit) `
        -Path ([string]$artifact.path)
    }
    $historicalValidation = & $module {
      param($ManifestValue, $PathValue, $PreviousValue, $CandidateValue, $ParentValue, $Artifacts)
      Test-DanioEvidenceManifest `
        -Manifest $ManifestValue `
        -ManifestPath $PathValue `
        -PreviousState $PreviousValue `
        -CandidateState $CandidateValue `
        -ParentCommit $ParentValue `
        -ArtifactObservations @($Artifacts)
    } $historicalManifest $historicalPath $previousBeforeTransition $stateAtTransition $stateParent $artifactObservations
    if (-not $historicalValidation.valid) {
      throw "PARENT_STATE_PROVENANCE_INVALID: prior finalize evidence is invalid: $($historicalValidation.details -join '; ')."
    }
  }
  return $stateCommit
}

function Assert-DanioExactOwnershipSet {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string[]]$AllowedBranches,
    [Parameter(Mandatory = $true)][string[]]$AllowedWorktrees
  )

  $branchText = Invoke-DanioOwnershipGit `
    -Root $Root `
    -Arguments @("for-each-ref", "--format=%(refname:short)", "refs/heads")
  $observedBranches = @(
    $branchText -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
  )
  $registryText = Invoke-DanioOwnershipGit -Root $Root -Arguments @("worktree", "list", "--porcelain")
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
    if (@($normalizedAllowedWorktrees | Where-Object {
      [string]::Equals($_, $observedWorktree, [StringComparison]::OrdinalIgnoreCase)
    }).Count -ne 1) {
      throw "STOP_PENDING: foreign local branch or worktree ownership exists."
    }
  }
}

function Get-DanioLeaseProof {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)]$PreviousState,
    [Parameter(Mandatory = $true)][string]$Action,
    [Parameter(Mandatory = $true)][string]$ParentCommit,
    [AllowNull()][string]$CandidateCommit = $null,
    [AllowNull()][string]$ReleaseJson = $null
  )

  $releaseActions = @("closeout", "pause", "stop", "complete", "finalization_stop")
  if ($releaseActions -cnotcontains $Action) {
    if (-not [string]::IsNullOrWhiteSpace($ReleaseJson)) {
      throw "LEASE_RELEASE_INVALID: lease release JSON is forbidden for '$Action'."
    }
    $retainedOwnerProven = $false
    if ($Action -ceq "finalize") {
      if ($null -eq $PreviousState.owner) {
        throw "STOP_PENDING: finalization owner is missing."
      }
      $ownerPath = [string]$PreviousState.owner.worktree_path
      try {
        $ownerPathExists = Test-Path -LiteralPath $ownerPath -PathType Container
        $ownerItem = if ($ownerPathExists) {
          Get-Item -LiteralPath $ownerPath -Force
        } else {
          $null
        }
      } catch {
        throw "STOP_PENDING: retained owner filesystem observation failed: $($_.Exception.Message)"
      }
      if (-not $ownerPathExists) {
        throw "STOP_PENDING: retained owner worktree is missing."
      }
      if (($ownerItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "STOP_PENDING: retained owner worktree is reparsed."
      }
      $registryText = Invoke-DanioOwnershipGit -Root $Root -Arguments @("worktree", "list", "--porcelain")
      $normalizedOwnerPath = $ownerPath.Replace("\", "/").TrimEnd("/")
      $registeredOwnerCount = @(
        @($registryText -split "`r?`n") |
          Where-Object { $_ -clike "worktree *" } |
          ForEach-Object { $_.Substring("worktree ".Length).Replace("\", "/").TrimEnd("/") } |
          Where-Object {
            [string]::Equals($_, $normalizedOwnerPath, [StringComparison]::OrdinalIgnoreCase)
          }
      ).Count
      $ownerHead = Invoke-DanioOwnershipGit -Root $ownerPath -Arguments @("rev-parse", "HEAD")
      $ownerBranch = Invoke-DanioOwnershipGit -Root $ownerPath -Arguments @("branch", "--show-current")
      $ownerStatus = Invoke-DanioOwnershipGit `
        -Root $ownerPath `
        -Arguments @("--no-optional-locks", "status", "--short", "-uall")
      $branchCommit = Invoke-DanioOwnershipGit `
        -Root $Root `
        -Arguments @("rev-parse", "refs/heads/$($PreviousState.owner.branch_name)")
      $ownerAncestor = Invoke-DanioGitProbe `
        -Root $Root `
        -Arguments @("merge-base", "--is-ancestor", $ownerHead, $ParentCommit)
      $ownerAtCandidate = (
        (Test-GitOid -Value $CandidateCommit) -and
        $ownerHead -ceq $CandidateCommit
      )
      $ownerReachabilityProven = (
        $ownerAncestor.exit_code -eq 0 -or
        ($ownerAncestor.exit_code -eq 1 -and $ownerAtCandidate)
      )
      if (
        $registeredOwnerCount -ne 1 -or
        $ownerHead -cne $branchCommit -or
        $ownerBranch -cne [string]$PreviousState.owner.branch_name -or
        -not [string]::IsNullOrWhiteSpace($ownerStatus) -or
        -not $ownerReachabilityProven
      ) {
        throw "STOP_PENDING: retained owner branch/worktree is not exact, clean, and ancestral to the evidence parent."
      }
      Assert-DanioExactOwnershipSet `
        -Root $Root `
        -AllowedBranches @("main", [string]$PreviousState.owner.branch_name) `
        -AllowedWorktrees @($Root, $ownerPath)
      $retainedOwnerProven = $true
    }
    return [pscustomobject]@{
      lease_release = $null
      cleanup = $null
      retained_owner_proven = $retainedOwnerProven
    }
  }
  if ([string]::IsNullOrWhiteSpace($ReleaseJson)) {
    throw "STOP_PENDING: exact lease release proof is required."
  }
  try {
    $supplied = $ReleaseJson | ConvertFrom-Json
  } catch {
    throw "LEASE_RELEASE_INVALID: lease release JSON is malformed."
  }
  if ($null -eq $supplied) {
    throw "LEASE_RELEASE_INVALID: lease release JSON cannot be null."
  }
  $suppliedNames = @($supplied.PSObject.Properties | ForEach-Object { $_.Name })
  $requiredNames = @("owner_token", "android_released", "processes_released")
  if (
    $suppliedNames.Count -ne $requiredNames.Count -or
    @($requiredNames | Where-Object { $suppliedNames -cnotcontains $_ }).Count -ne 0 -or
    $null -eq $PreviousState.owner -or
    [string]$supplied.owner_token -cnotmatch '^[0-9a-f]{64}$' -or
    [string]$supplied.owner_token -cne [string]$PreviousState.owner.token_sha256 -or
    $supplied.android_released -isnot [bool] -or
    $supplied.processes_released -isnot [bool]
  ) {
    throw "LEASE_RELEASE_INVALID: lease release fields or owner token are invalid."
  }

  $worktreeLines = @(
    (Invoke-DanioOwnershipGit -Root $Root -Arguments @("worktree", "list", "--porcelain")) -split "`r?`n"
  )
  $registeredWorktreePaths = @(
    $worktreeLines | Where-Object { $_ -clike "worktree *" } | ForEach-Object {
      $_.Substring("worktree ".Length).Replace("\", "/").TrimEnd("/")
    }
  )
  $ownedWorktreePath = ([string]$PreviousState.owner.worktree_path).Replace("\", "/").TrimEnd("/")
  $worktreeRegistered = @(
    $registeredWorktreePaths | Where-Object {
      [string]::Equals($_, $ownedWorktreePath, [StringComparison]::OrdinalIgnoreCase)
    }
  ).Count -gt 0
  try {
    $worktreeExists = Test-Path -LiteralPath ([string]$PreviousState.owner.worktree_path)
  } catch {
    throw "STOP_PENDING: owned worktree release cannot be observed safely: $($_.Exception.Message)"
  }
  $branchProbe = Invoke-DanioGitProbe `
    -Root $Root `
    -Arguments @("show-ref", "--verify", "--quiet", "refs/heads/$($PreviousState.owner.branch_name)")
  if (@(0, 1) -cnotcontains $branchProbe.exit_code) {
    throw "STOP_PENDING: owned branch release cannot be observed safely."
  }
  $branchRemoved = $branchProbe.exit_code -eq 1
  $worktreeRemoved = -not $worktreeRegistered -and -not $worktreeExists
  $writerReleased = $branchRemoved -and $worktreeRemoved
  $leaseRelease = [pscustomobject]@{
    owner_token = [string]$supplied.owner_token
    writer_released = $writerReleased
    worktree_released = $worktreeRemoved
    android_released = [bool]$supplied.android_released
    processes_released = [bool]$supplied.processes_released
  }
  $cleanup = [pscustomobject]@{
    owner_token = [string]$supplied.owner_token
    branch_name = [string]$PreviousState.owner.branch_name
    worktree_id = [string]$PreviousState.owner.worktree_id
    worktree_path = [string]$PreviousState.owner.worktree_path
    branch_removed = $branchRemoved
    worktree_removed = $worktreeRemoved
    device_released = ([bool]$supplied.android_released -and [bool]$supplied.processes_released)
  }
  if (
    -not $leaseRelease.writer_released -or
    -not $leaseRelease.worktree_released -or
    -not $leaseRelease.android_released -or
    -not $leaseRelease.processes_released
  ) {
    throw "STOP_PENDING: exact owner branch, worktree, Android, and process release is unproven."
  }
  Assert-DanioExactOwnershipSet `
    -Root $Root `
    -AllowedBranches @("main") `
    -AllowedWorktrees @($Root)
  return [pscustomobject]@{
    lease_release = $leaseRelease
    cleanup = $cleanup
    retained_owner_proven = $false
  }
}

function Get-DanioTransitionProof {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$ParentCommit,
    [Parameter(Mandatory = $true)]$PreviousState,
    [Parameter(Mandatory = $true)]$CandidateState,
    [AllowNull()][string]$ManifestPath = $null,
    [AllowNull()][string]$ReleaseJson = $null,
    [AllowNull()][string]$CandidateCommit = $null,
    [AllowNull()][string]$OwningStateCommit = $null
  )

  $action = [string]$CandidateState.transition.action
  $evidenceActions = @("closeout", "pause", "stop", "finalize", "complete", "finalization_stop")
  $ledgerRows = @()
  $activePhaseLedgerIds = @()
  $evidenceValidation = $null
  if ($evidenceActions -ccontains $action) {
    $ledgerContent = Read-DanioGitTextBlob `
      -Root $Root `
      -Revision $ParentCommit `
      -Path $ledgerPath
    try {
      $ledgerRows = @(Read-DanioLedgerClosureRows -Content $ledgerContent)
    } catch {
      $ledgerFailureCode = if ($action -ceq "finalize") {
        "FINALIZATION_SCOPE_INVALID"
      } else {
        "EVIDENCE_MANIFEST_INVALID"
      }
      throw "$ledgerFailureCode`: parent ledger is malformed: $($_.Exception.Message)"
    }
    $ledgerValidation = Test-DanioLedgerClosureRows -Rows $ledgerRows
    if (-not $ledgerValidation.valid) {
      $ledgerFailureCode = if ($action -ceq "finalize") {
        "FINALIZATION_SCOPE_INVALID"
      } else {
        "EVIDENCE_MANIFEST_INVALID"
      }
      throw "$ledgerFailureCode`: parent ledger invariants fail: $($ledgerValidation.details -join '; ')"
    }
    $activePhaseLedgerIds = @(Get-DanioActivePhaseLedgerIds -Rows $ledgerRows)

    $manifest = $null
    $artifactObservations = @()
    if (-not [string]::IsNullOrWhiteSpace($ManifestPath)) {
      $manifest = Read-DanioEvidenceJsonBlob `
        -Root $Root `
        -Revision $ParentCommit `
        -Path $ManifestPath
      Assert-DanioEvidenceProbeShape -Manifest $manifest
      $productCommitProbe = Invoke-DanioGitProbe `
        -Root $Root `
        -Arguments @("rev-parse", "$($manifest.product_commit)^{commit}")
      if (
        $productCommitProbe.exit_code -ne 0 -or
        [string]$productCommitProbe.output -cne [string]$manifest.product_commit
      ) {
        throw "EVIDENCE_MANIFEST_INVALID: product_commit does not resolve to the exact commit."
      }
      $productAncestorProbe = Invoke-DanioGitProbe `
        -Root $Root `
        -Arguments @("merge-base", "--is-ancestor", [string]$manifest.product_commit, $ParentCommit)
      if ($productAncestorProbe.exit_code -ne 0) {
        throw "EVIDENCE_MANIFEST_INVALID: product_commit is not an ancestor of the evidence checkpoint parent."
      }
      $isNewOwnedCheckpoint = (
        @("closeout", "pause", "complete") -ccontains $action -or
        (
          $action -ceq "stop" -and
          [string]$CandidateState.transition.reason_code -ceq "BUDGET_EXHAUSTED" -and
          [int64]$CandidateState.budget.remaining_units_including_current -eq 0
        )
      )
      if ($isNewOwnedCheckpoint) {
        if (-not (Test-GitOid -Value $OwningStateCommit)) {
          throw "PARENT_STATE_PROVENANCE_INVALID: owning state transition commit is missing."
        }
        $ownedProductProbe = Invoke-DanioGitProbe `
          -Root $Root `
          -Arguments @("merge-base", "--is-ancestor", $OwningStateCommit, [string]$manifest.product_commit)
        $manifestCommit = Invoke-DanioGit `
          -Root $Root `
          -Arguments @("log", "-1", "--format=%H", $ParentCommit, "--", $ManifestPath)
        $ownedManifestProbe = Invoke-DanioGitProbe `
          -Root $Root `
          -Arguments @("merge-base", "--is-ancestor", $OwningStateCommit, $manifestCommit)
        $manifestParentProbe = Invoke-DanioGitProbe `
          -Root $Root `
          -Arguments @("merge-base", "--is-ancestor", $manifestCommit, $ParentCommit)
        if (
          $ownedProductProbe.exit_code -ne 0 -or
          [string]$manifest.product_commit -ceq $OwningStateCommit -or
          -not (Test-GitOid -Value $manifestCommit) -or
          $ownedManifestProbe.exit_code -ne 0 -or
          $manifestCommit -ceq $OwningStateCommit -or
          $manifestParentProbe.exit_code -ne 0
        ) {
          throw "EVIDENCE_MANIFEST_INVALID: new product and manifest checkpoints were not created after the owning state transition."
        }
      }
      foreach ($artifact in @($manifest.artifacts)) {
        $artifactObservations += Get-DanioGitBlobSha256 `
          -Root $Root `
          -Revision ([string]$manifest.product_commit) `
          -Path ([string]$artifact.path)
      }
    }

    $recoveryObservation = $null
    if (@("stop", "finalization_stop") -ccontains $action) {
      $recoveryCommitProbe = Invoke-DanioGitProbe `
        -Root $Root `
        -Arguments @("rev-parse", "$($CandidateState.recovery.last_clean_commit)^{commit}")
      if (
        $recoveryCommitProbe.exit_code -ne 0 -or
        [string]$recoveryCommitProbe.output -cne [string]$CandidateState.recovery.last_clean_commit
      ) {
        throw "EVIDENCE_MANIFEST_INVALID: recovery commit does not resolve exactly."
      }
      $recoveryReachability = Invoke-DanioGitProbe `
        -Root $Root `
        -Arguments @(
          "merge-base",
          "--is-ancestor",
          [string]$CandidateState.recovery.last_clean_commit,
          $ParentCommit
        )
      if (@(0, 1) -cnotcontains $recoveryReachability.exit_code) {
        throw "EVIDENCE_MANIFEST_INVALID: recovery reachability is unprovable."
      }
      $recoveryObservation = [pscustomobject]@{
        last_clean_commit = [string]$CandidateState.recovery.last_clean_commit
        reachable_from_parent = ($recoveryReachability.exit_code -eq 0)
      }
    }

    $evidenceValidation = & $module {
      param(
        $ManifestValue,
        $ManifestPathValue,
        $PreviousStateValue,
        $CandidateStateValue,
        $ParentCommitValue,
        $ArtifactObservationValues,
        $RecoveryObservationValue
      )
      Test-DanioEvidenceManifest `
        -Manifest $ManifestValue `
        -ManifestPath $ManifestPathValue `
        -PreviousState $PreviousStateValue `
        -CandidateState $CandidateStateValue `
        -ParentCommit $ParentCommitValue `
        -ArtifactObservations @($ArtifactObservationValues) `
        -RecoveryObservation $RecoveryObservationValue
    } $manifest $ManifestPath $PreviousState $CandidateState $ParentCommit $artifactObservations $recoveryObservation
    if (-not $evidenceValidation.valid) {
      throw "$($evidenceValidation.code): $($evidenceValidation.details -join '; ')"
    }

    if ($null -ne $manifest) {
      foreach ($ledgerId in @($manifest.ledger_row_ids)) {
        $matchingLedgerRows = @(
          $ledgerRows | Where-Object { [string]$_.Id -ceq [string]$ledgerId }
        )
        if ($matchingLedgerRows.Count -ne 1) {
          throw "EVIDENCE_MANIFEST_INVALID: manifest ledger row '$ledgerId' is absent from the parent ledger."
        }
        if (
          $action -ceq "complete" -and
          [string]$matchingLedgerRows[0].ClosureState -cne "closed"
        ) {
          throw "EVIDENCE_MANIFEST_INVALID: new-checkpoint ledger row '$ledgerId' is not closed in the parent ledger."
        }
      }
    }
    if ($action -ceq "closeout") {
      if ([string]$CandidateState.cursor.work_unit_id -ceq [string]$PreviousState.cursor.work_unit_id) {
        throw "FINALIZATION_SCOPE_INVALID: closeout must advance to a distinct finite work unit."
      }
      foreach ($nextLedgerId in @($CandidateState.cursor.ledger_row_ids)) {
        $nextRows = @($ledgerRows | Where-Object { [string]$_.Id -ceq [string]$nextLedgerId })
        if (
          $nextRows.Count -ne 1 -or
          [string]$nextRows[0].ClosureState -cne "open"
        ) {
          throw "FINALIZATION_SCOPE_INVALID: next cursor row '$nextLedgerId' is absent or not exactly open."
        }
      }
    }
  } elseif (-not [string]::IsNullOrWhiteSpace($ManifestPath)) {
    throw "EVIDENCE_MANIFEST_INVALID: transition '$action' cannot carry an evidence manifest."
  }

  $leaseProof = Get-DanioLeaseProof `
    -Root $Root `
    -PreviousState $PreviousState `
    -Action $action `
    -ParentCommit $ParentCommit `
    -CandidateCommit $CandidateCommit `
    -ReleaseJson $ReleaseJson
  return [pscustomobject]@{
    evidence_validation = $evidenceValidation
    ledger_rows = @($ledgerRows)
    active_phase_ledger_ids = @($activePhaseLedgerIds)
    lease_release = $leaseProof.lease_release
    cleanup = $leaseProof.cleanup
    retained_owner_proven = [bool]$leaseProof.retained_owner_proven
  }
}

function Assert-DanioTerminalCompletionReady {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$ParentCommit,
    [Parameter(Mandatory = $true)]$PreviousState,
    [Parameter(Mandatory = $true)]$CandidateState,
    [Parameter(Mandatory = $true)]$Proof
  )

  if ([string]$CandidateState.transition.action -cne "complete") {
    return
  }
  $originMainCommit = Invoke-DanioGit `
    -Root $Root `
    -Arguments @("rev-parse", "refs/remotes/origin/main")
  $countsText = Invoke-DanioGit `
    -Root $Root `
    -Arguments @("rev-list", "--left-right", "--count", "$ParentCommit...refs/remotes/origin/main")
  $counts = @($countsText -split '\s+' | Where-Object { $_ -ne "" })
  if ($counts.Count -ne 2) {
    throw "COMPLETION_NOT_READY: parent alignment count is malformed."
  }
  $repositoryObservation = [pscustomobject]@{
    parent_commit = $ParentCommit
    origin_main_commit = $originMainCommit
    ahead = [int64]$counts[0]
    behind = [int64]$counts[1]
    clean = (
      [int64]$counts[0] -eq 0 -and
      [int64]$counts[1] -eq 0 -and
      $ParentCommit -ceq $originMainCommit
    )
  }
  $completion = Test-DanioCompletionReadiness `
    -State $PreviousState `
    -LedgerRows @($Proof.ledger_rows) `
    -ActivePhaseLedgerIds @($Proof.active_phase_ledger_ids) `
    -Evidence $Proof.evidence_validation.evidence `
    -Cleanup $Proof.cleanup `
    -RepositoryObservation $repositoryObservation
  if (-not $completion.ready) {
    throw "COMPLETION_NOT_READY: $($completion.details -join '; ')"
  }
}

function Assert-DanioTransitionPreflight {
  param(
    [Parameter(Mandatory = $true)]$PreviousState,
    [Parameter(Mandatory = $true)]$CandidateState,
    [Parameter(Mandatory = $true)]$ExpectedCandidateAuthority
  )

  $preflightParameters = @{
    PreviousState = $PreviousState
    CandidateState = $CandidateState
    ExpectedCandidateAuthority = $ExpectedCandidateAuthority
  }
  if ($null -ne $PreviousState.owner) {
    $preflightParameters.LeaseRelease = [pscustomobject]@{
      owner_token = [string]$PreviousState.owner.token_sha256
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
}

$libraryOnlyVariable = Get-Variable `
  -Name DanioTransitionLibraryOnly `
  -Scope Script `
  -ErrorAction SilentlyContinue
if ($null -ne $libraryOnlyVariable -and [bool]$libraryOnlyVariable.Value) {
  return
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
  if ($Source -ceq "Staged" -and -not (Test-GitOid -Value $ExpectedStagedTreeHash)) {
    throw "TRANSITION_INPUT_INVALID: staged validation requires a precomputed tree hash."
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
    $stagedPathText = Invoke-DanioGit `
      -Root $resolvedRoot `
      -Arguments @("diff", "--cached", "--name-only", $observedParent, "--")
    Assert-DanioTransitionPathScope `
      -ChangedPaths @($stagedPathText -split "`r?`n") `
      -Action ([string]$candidateState.transition.action)
    $previousContext = Resolve-DanioPreviousStateContext `
      -Root $resolvedRoot `
      -ParentRevision $observedParent
    $previousState = $previousContext.state
    Assert-DanioBootstrapActivationOutputs `
      -Root $resolvedRoot `
      -Context $previousContext `
      -CandidateState $candidateState `
      -Index
    Assert-DanioClaimParentBinding `
      -Root $resolvedRoot `
      -ParentCommit $observedParent `
      -CandidateState $candidateState
    $task9Actions = @("closeout", "pause", "stop", "finalize", "complete", "finalization_stop")
    if ([string]$previousContext.origin -ceq "bootstrap_absent") {
      $expectedCandidateAuthority = $previousContext.parent_authority
      $owningStateCommit = $null
    } elseif (
      $task9Actions -ccontains [string]$candidateState.transition.action -and
      @("active", "finalizing") -ccontains [string]$previousState.mode
    ) {
      $owningStateCommit = Assert-DanioParentStateProvenance `
        -Root $resolvedRoot `
        -ParentCommit $observedParent `
        -ObservedState $previousState
      $expectedCandidateAuthority = Get-DanioParentAuthority `
        -Root $resolvedRoot `
        -ParentCommit $observedParent
    } else {
      $expectedCandidateAuthority = $previousState.authority
      $owningStateCommit = $null
    }
    $checks.Add((New-TransitionCheck `
      -Code "STATE_BLOB" `
      -Passed $true `
      -Detail "Parent and indexed candidate state blobs parse."))

    $treeTypeProbe = Invoke-DanioGitProbe `
      -Root $resolvedRoot `
      -Arguments @("cat-file", "-t", $ExpectedStagedTreeHash)
    if ($treeTypeProbe.exit_code -ne 0 -or $treeTypeProbe.output -cne "tree") {
      throw "STAGED_TREE_MISMATCH: expected staged object is not a tree."
    }
    $indexComparison = Invoke-DanioGitProbe `
      -Root $resolvedRoot `
      -Arguments @("diff", "--cached", "--quiet", $ExpectedStagedTreeHash, "--")
    if ($indexComparison.exit_code -eq 1) {
      throw "STAGED_TREE_MISMATCH: index differs from the precomputed staged tree."
    }
    if ($indexComparison.exit_code -ne 0) {
      throw "TRANSITION_INPUT_INVALID: staged tree comparison failed: $($indexComparison.output)"
    }
    $treeHash = $ExpectedStagedTreeHash
    Assert-DanioTransitionPreflight `
      -PreviousState $previousState `
      -CandidateState $candidateState `
      -ExpectedCandidateAuthority $expectedCandidateAuthority
    $transitionProof = Get-DanioTransitionProof `
      -Root $resolvedRoot `
      -ParentCommit $observedParent `
      -PreviousState $previousState `
      -CandidateState $candidateState `
      -ManifestPath $EvidenceManifestPath `
      -ReleaseJson $LeaseReleaseJson `
      -OwningStateCommit $owningStateCommit
    $transitionParameters = @{
      PreviousState = $previousState
      CandidateState = $candidateState
      LedgerRows = @($transitionProof.ledger_rows)
      ActivePhaseLedgerIds = @($transitionProof.active_phase_ledger_ids)
      ExpectedCandidateAuthority = $expectedCandidateAuthority
    }
    if ($null -ne $transitionProof.lease_release) {
      $transitionParameters.LeaseRelease = $transitionProof.lease_release
    }
    $transitionValidation = Test-DanioRunStateTransition @transitionParameters
    if (-not $transitionValidation.valid) {
      throw "$($transitionValidation.code): $($transitionValidation.details -join '; ')"
    }
    Assert-DanioTerminalCompletionReady `
      -Root $resolvedRoot `
      -ParentCommit $observedParent `
      -PreviousState $previousState `
      -CandidateState $candidateState `
      -Proof $transitionProof
    $checks.Add((New-TransitionCheck `
      -Code "STATE_TRANSITION" `
      -Passed $true `
      -Detail "Indexed state transition validates."))
    if ($null -ne $transitionProof.evidence_validation) {
      $checks.Add((New-TransitionCheck `
        -Code "EVIDENCE_MANIFEST" `
        -Passed $true `
        -Detail "Parent-committed transition evidence validates."))
    }

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
    $committedPathText = Invoke-DanioGit `
      -Root $resolvedRoot `
      -Arguments @("diff-tree", "--no-commit-id", "--name-only", "-r", $commitOid)
    Assert-DanioTransitionPathScope `
      -ChangedPaths @($committedPathText -split "`r?`n") `
      -Action ([string]$candidateState.transition.action)
    $previousContext = Resolve-DanioPreviousStateContext `
      -Root $resolvedRoot `
      -ParentRevision $observedParent
    $previousState = $previousContext.state
    Assert-DanioBootstrapActivationOutputs `
      -Root $resolvedRoot `
      -Context $previousContext `
      -CandidateState $candidateState `
      -CandidateRevision $commitOid
    Assert-DanioClaimParentBinding `
      -Root $resolvedRoot `
      -ParentCommit $observedParent `
      -CandidateState $candidateState
    $task9Actions = @("closeout", "pause", "stop", "finalize", "complete", "finalization_stop")
    if ([string]$previousContext.origin -ceq "bootstrap_absent") {
      $expectedCandidateAuthority = $previousContext.parent_authority
      $owningStateCommit = $null
    } elseif (
      $task9Actions -ccontains [string]$candidateState.transition.action -and
      @("active", "finalizing") -ccontains [string]$previousState.mode
    ) {
      $owningStateCommit = Assert-DanioParentStateProvenance `
        -Root $resolvedRoot `
        -ParentCommit $observedParent `
        -ObservedState $previousState
      $expectedCandidateAuthority = Get-DanioParentAuthority `
        -Root $resolvedRoot `
        -ParentCommit $observedParent
    } else {
      $expectedCandidateAuthority = $previousState.authority
      $owningStateCommit = $null
    }
    $checks.Add((New-TransitionCheck `
      -Code "STATE_BLOB" `
      -Passed $true `
      -Detail "Parent and committed candidate state blobs parse."))

    Assert-DanioTransitionPreflight `
      -PreviousState $previousState `
      -CandidateState $candidateState `
      -ExpectedCandidateAuthority $expectedCandidateAuthority
    $transitionProof = Get-DanioTransitionProof `
      -Root $resolvedRoot `
      -ParentCommit $observedParent `
      -PreviousState $previousState `
      -CandidateState $candidateState `
      -ManifestPath $EvidenceManifestPath `
      -ReleaseJson $LeaseReleaseJson `
      -CandidateCommit $commitOid `
      -OwningStateCommit $owningStateCommit
    $transitionParameters = @{
      PreviousState = $previousState
      CandidateState = $candidateState
      LedgerRows = @($transitionProof.ledger_rows)
      ActivePhaseLedgerIds = @($transitionProof.active_phase_ledger_ids)
      ExpectedCandidateAuthority = $expectedCandidateAuthority
    }
    if ($null -ne $transitionProof.lease_release) {
      $transitionParameters.LeaseRelease = $transitionProof.lease_release
    }
    $transitionValidation = Test-DanioRunStateTransition @transitionParameters
    if (-not $transitionValidation.valid) {
      throw "$($transitionValidation.code): $($transitionValidation.details -join '; ')"
    }
    Assert-DanioTerminalCompletionReady `
      -Root $resolvedRoot `
      -ParentCommit $observedParent `
      -PreviousState $previousState `
      -CandidateState $candidateState `
      -Proof $transitionProof
    $checks.Add((New-TransitionCheck `
      -Code "STATE_TRANSITION" `
      -Passed $true `
      -Detail "Committed state transition validates."))
    if ($null -ne $transitionProof.evidence_validation) {
      $checks.Add((New-TransitionCheck `
        -Code "EVIDENCE_MANIFEST" `
        -Passed $true `
        -Detail "Parent-committed transition evidence validates."))
    }

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
    $subject = Invoke-DanioGit -Root $resolvedRoot -Arguments @("log", "-1", "--format=%s", $commitOid)
    if (
      [string]$candidateState.transition.action -ceq "launch" -and
      $subject -cne "chore: activate autonomous phone completion"
    ) {
      throw "COMMIT_SUBJECT_INVALID: Task 13 launch requires the exact activation commit subject."
    }
    $trailerNames = @(
      "Danio-State-Tree",
      "Danio-State-Validation",
      "Danio-Docs-Profile",
      "Danio-Verified-At"
    )
    $evidenceTransitionActions = @("closeout", "pause", "stop", "finalize", "complete", "finalization_stop")
    $requiresEvidenceTrailer = $evidenceTransitionActions -ccontains [string]$candidateState.transition.action
    if ($requiresEvidenceTrailer) {
      $trailerNames += "Danio-Evidence-Manifest"
    }
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
    $unexpectedEvidenceTrailers = @(
      $terminalTrailerLines | Where-Object {
        $_ -cmatch '^Danio-Evidence-Manifest:\s*[^\r\n]+$'
      }
    )
    if (-not $requiresEvidenceTrailer -and $unexpectedEvidenceTrailers.Count -ne 0) {
      throw "COMMIT_TRAILER_INVALID: evidence trailer is forbidden for this transition."
    }
    $expectedEvidenceTrailer = if ([string]::IsNullOrWhiteSpace($EvidenceManifestPath)) {
      "none"
    } else {
      $EvidenceManifestPath
    }
    if (
      [string]$trailers["Danio-State-Tree"] -cne $treeHash -or
      [string]$trailers["Danio-State-Validation"] -cne "pass" -or
      [string]$trailers["Danio-Docs-Profile"] -cne "pass" -or
      -not (Test-StrictUtc -Value $trailers["Danio-Verified-At"]) -or
      (
        $requiresEvidenceTrailer -and
        [string]$trailers["Danio-Evidence-Manifest"] -cne $expectedEvidenceTrailer
      )
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
