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
  try {
    return $probe.output | ConvertFrom-Json
  } catch {
    throw "STATE_BLOB_INVALID: state blob '$objectSpec' is malformed."
  }
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
    [AllowNull()][string]$CandidateCommit = $null
  )

  $releaseActions = @("closeout", "pause", "stop", "complete", "finalization_stop")
  if ($releaseActions -cnotcontains $Action) {
    if (-not [string]::IsNullOrWhiteSpace($LeaseReleaseJson)) {
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
  if ([string]::IsNullOrWhiteSpace($LeaseReleaseJson)) {
    throw "STOP_PENDING: exact lease release proof is required."
  }
  try {
    $supplied = $LeaseReleaseJson | ConvertFrom-Json
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
    if (-not [string]::IsNullOrWhiteSpace($EvidenceManifestPath)) {
      $manifest = Read-DanioEvidenceJsonBlob `
        -Root $Root `
        -Revision $ParentCommit `
        -Path $EvidenceManifestPath
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
          -Arguments @("log", "-1", "--format=%H", $ParentCommit, "--", $EvidenceManifestPath)
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
    } $manifest $EvidenceManifestPath $PreviousState $CandidateState $ParentCommit $artifactObservations $recoveryObservation
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
  } elseif (-not [string]::IsNullOrWhiteSpace($EvidenceManifestPath)) {
    throw "EVIDENCE_MANIFEST_INVALID: transition '$action' cannot carry an evidence manifest."
  }

  $leaseProof = Get-DanioLeaseProof `
    -Root $Root `
    -PreviousState $PreviousState `
    -Action $action `
    -ParentCommit $ParentCommit `
    -CandidateCommit $CandidateCommit
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
    $previousState = Read-DanioPreviousState `
      -Root $resolvedRoot `
      -ParentRevision $observedParent
    Assert-DanioClaimParentBinding `
      -Root $resolvedRoot `
      -ParentCommit $observedParent `
      -CandidateState $candidateState
    $task9Actions = @("closeout", "pause", "stop", "finalize", "complete", "finalization_stop")
    if (
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
    $previousState = Read-DanioPreviousState `
      -Root $resolvedRoot `
      -ParentRevision $observedParent
    Assert-DanioClaimParentBinding `
      -Root $resolvedRoot `
      -ParentCommit $observedParent `
      -CandidateState $candidateState
    $task9Actions = @("closeout", "pause", "stop", "finalize", "complete", "finalization_stop")
    if (
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
