[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$script:DanioModes = @(
  "inactive",
  "ready",
  "active",
  "handoff_ready",
  "paused",
  "stopped",
  "finalizing",
  "complete"
)

$script:DanioAllowedTransitions = @{
  "inactive>ready" = "launch"
  "ready>active" = "claim"
  "handoff_ready>active" = "claim"
  "ready>stopped" = "preclaim_stop"
  "handoff_ready>stopped" = "preclaim_stop"
  "active>handoff_ready" = "closeout"
  "active>paused" = "pause"
  "active>stopped" = "stop"
  "active>finalizing" = "finalize"
  "finalizing>complete" = "complete"
  "finalizing>stopped" = "finalization_stop"
  "paused>ready" = "resume"
  "stopped>ready" = "resume"
  "handoff_ready>handoff_ready" = "administrative_sync"
  "complete>complete" = "administrative_sync"
}

function New-DanioValidationResult {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][bool]$Valid,
    [Parameter(Mandatory = $true)][string]$Code,
    [object[]]$Details = @()
  )

  return [pscustomobject]@{
    valid = $Valid
    code = $Code
    details = @($Details)
  }
}

function Test-DanioInteger {
  [CmdletBinding()]
  param([Parameter(Mandatory = $true)]$Value)

  return (
    $Value -is [byte] -or
    $Value -is [sbyte] -or
    $Value -is [int16] -or
    $Value -is [uint16] -or
    $Value -is [int32] -or
    $Value -is [uint32] -or
    $Value -is [int64]
  )
}

function Test-DanioExactPropertySet {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]$Value,
    [Parameter(Mandatory = $true)][string[]]$Allowed,
    [Parameter(Mandatory = $true)][string[]]$Required
  )

  if ($null -eq $Value) {
    return [pscustomobject]@{
      valid = $false
      missing = @($Required)
      unknown = @()
    }
  }

  $names = @($Value.PSObject.Properties | ForEach-Object { $_.Name })
  $missing = @($Required | Where-Object { $names -cnotcontains $_ })
  $unknown = @($names | Where-Object { $Allowed -cnotcontains $_ })

  return [pscustomobject]@{
    valid = ($missing.Count -eq 0 -and $unknown.Count -eq 0)
    missing = $missing
    unknown = $unknown
  }
}

function ConvertTo-DanioCanonicalJson {
  [CmdletBinding()]
  param([Parameter(Mandatory = $true)]$Value)

  return $Value | ConvertTo-Json -Depth 100 -Compress
}

function Copy-DanioJsonValue {
  [CmdletBinding()]
  param([Parameter(Mandatory = $true)]$Value)

  return $Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json
}

function Get-DanioOwnerToken {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$RunId,
    [Parameter(Mandatory = $true)][string]$WorkUnitId,
    [Parameter(Mandatory = $true)][string]$TaskId,
    [Parameter(Mandatory = $true)][int]$ExpectedRevision
  )

  $tokenInput = @(
    $RunId,
    $WorkUnitId,
    $TaskId,
    [string]$ExpectedRevision
  ) -join "`n"
  $tokenBytes = [System.Text.Encoding]::UTF8.GetBytes($tokenInput)
  $sha256 = [System.Security.Cryptography.SHA256]::Create()
  try {
    $tokenHash = $sha256.ComputeHash($tokenBytes)
  } finally {
    $sha256.Dispose()
  }
  return ([System.BitConverter]::ToString($tokenHash)).Replace("-", "").ToLowerInvariant()
}

function Remove-DanioMarkdownFormatting {
  [CmdletBinding()]
  param([Parameter(Mandatory = $true)][string]$Value)

  return $Value.Replace([string][char]96, "").Trim()
}

function Split-DanioMarkdownRow {
  [CmdletBinding()]
  param([Parameter(Mandatory = $true)][string]$Line)

  $trimmed = $Line.Trim()
  if (-not $trimmed.StartsWith("|") -or -not $trimmed.EndsWith("|")) {
    throw "LEDGER_MALFORMED_ROW: table row must begin and end with a pipe."
  }

  $content = $trimmed.Substring(1, $trimmed.Length - 2)
  $cells = New-Object System.Collections.Generic.List[string]
  $builder = New-Object System.Text.StringBuilder
  $index = 0
  while ($index -lt $content.Length) {
    $character = $content[$index]
    if (
      $character -eq "\" -and
      ($index + 1) -lt $content.Length -and
      $content[$index + 1] -eq "|"
    ) {
      [void]$builder.Append("|")
      $index += 2
      continue
    }

    if ($character -eq "|") {
      $cells.Add($builder.ToString().Trim())
      [void]$builder.Clear()
      $index += 1
      continue
    }

    [void]$builder.Append($character)
    $index += 1
  }
  $cells.Add($builder.ToString().Trim())
  return $cells.ToArray()
}

function Get-DanioMarkdownTable {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$Content,
    [Parameter(Mandatory = $true)][string]$Heading,
    [Parameter(Mandatory = $true)][string[]]$ExpectedHeaders
  )

  $lines = @($Content -split "`r?`n")
  $headingLine = "## $Heading"
  $headingIndexes = New-Object System.Collections.Generic.List[int]
  for ($index = 0; $index -lt $lines.Count; $index += 1) {
    if ($lines[$index].Trim() -ceq $headingLine) {
      $headingIndexes.Add($index)
    }
  }
  if ($headingIndexes.Count -ne 1) {
    throw "LEDGER_SECTION_INVALID: expected one '$headingLine' heading."
  }

  $sectionStart = $headingIndexes[0] + 1
  $sectionEnd = $lines.Count
  for ($index = $sectionStart; $index -lt $lines.Count; $index += 1) {
    if ($lines[$index].StartsWith("## ")) {
      $sectionEnd = $index
      break
    }
  }

  $tableLines = @(
    $lines[$sectionStart..($sectionEnd - 1)] |
      Where-Object { $_.Trim().StartsWith("|") }
  )
  if ($tableLines.Count -lt 2) {
    throw "LEDGER_TABLE_INVALID: '$Heading' needs a header and separator."
  }

  $headers = @(Split-DanioMarkdownRow -Line $tableLines[0])
  $separator = @(Split-DanioMarkdownRow -Line $tableLines[1])
  if ($headers.Count -ne $ExpectedHeaders.Count -or $separator.Count -ne $ExpectedHeaders.Count) {
    throw "LEDGER_TABLE_INVALID: '$Heading' table width is invalid."
  }
  for ($index = 0; $index -lt $ExpectedHeaders.Count; $index += 1) {
    if ($headers[$index] -cne $ExpectedHeaders[$index]) {
      throw "LEDGER_TABLE_INVALID: '$Heading' header '$($headers[$index])' is invalid."
    }
    if ($separator[$index] -notmatch '^:?-{3,}:?$') {
      throw "LEDGER_TABLE_INVALID: '$Heading' separator is invalid."
    }
  }

  $rows = New-Object System.Collections.Generic.List[object]
  foreach ($line in @($tableLines | Select-Object -Skip 2)) {
    $cells = @(Split-DanioMarkdownRow -Line $line)
    if ($cells.Count -ne $ExpectedHeaders.Count) {
      throw "LEDGER_MALFORMED_ROW: '$Heading' expected $($ExpectedHeaders.Count) cells and found $($cells.Count)."
    }

    $values = [ordered]@{}
    for ($index = 0; $index -lt $ExpectedHeaders.Count; $index += 1) {
      $values[$ExpectedHeaders[$index]] = $cells[$index]
    }
    $rows.Add([pscustomobject]$values)
  }

  return $rows.ToArray()
}

function Resolve-DanioRepositoryRoot {
  [CmdletBinding()]
  param([string]$RepositoryRoot)

  $candidate = $RepositoryRoot
  if ([string]::IsNullOrWhiteSpace($candidate)) {
    $candidate = Join-Path $PSScriptRoot "../../../.."
  }

  $resolved = (Resolve-Path -LiteralPath $candidate).Path
  $gitMarker = Join-Path $resolved ".git"
  $appMarker = Join-Path $resolved "apps/aquarium_app"
  if (
    -not (Test-Path -LiteralPath $gitMarker) -or
    -not (Test-Path -LiteralPath $appMarker -PathType Container)
  ) {
    throw "REPO_ROOT_INVALID: '$resolved' is not the nested Danio repository root."
  }

  return $resolved
}

function Read-DanioLedgerClosureRows {
  [CmdletBinding(DefaultParameterSetName = "Path")]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = "Path")]
    [string]$LedgerPath,

    [Parameter(Mandatory = $true, ParameterSetName = "Content")]
    [string]$Content
  )

  if ($PSCmdlet.ParameterSetName -eq "Path") {
    $resolvedLedgerPath = (Resolve-Path -LiteralPath $LedgerPath).Path
    $Content = Get-Content -Raw -LiteralPath $resolvedLedgerPath
  }

  $activeHeaders = @(
    "ID",
    "Finding",
    "How Found",
    "Evidence",
    "Disposition",
    "Closure State",
    "Lane",
    "User Input",
    "Done Condition"
  )
  $closedHeaders = @(
    "ID",
    "Finding",
    "Superseding Evidence",
    "Disposition",
    "Closure State",
    "Rule"
  )

  $activeRows = @(Get-DanioMarkdownTable `
    -Content $Content `
    -Heading "Active Findings" `
    -ExpectedHeaders $activeHeaders)
  $closedRows = @(Get-DanioMarkdownTable `
    -Content $Content `
    -Heading "Closed, Accepted, Or Superseded Findings" `
    -ExpectedHeaders $closedHeaders)

  $normalized = New-Object System.Collections.Generic.List[object]
  foreach ($row in $activeRows) {
    $normalized.Add([pscustomobject]@{
      Id = Remove-DanioMarkdownFormatting -Value ([string]$row.ID)
      Finding = [string]$row.Finding
      HowFound = [string]$row.'How Found'
      Evidence = [string]$row.Evidence
      SupersedingEvidence = $null
      Disposition = Remove-DanioMarkdownFormatting -Value ([string]$row.Disposition)
      ClosureState = Remove-DanioMarkdownFormatting -Value ([string]$row.'Closure State')
      Lane = [string]$row.Lane
      UserInput = [string]$row.'User Input'
      DoneCondition = [string]$row.'Done Condition'
      Rule = $null
      Table = "Active Findings"
    })
  }
  foreach ($row in $closedRows) {
    $normalized.Add([pscustomobject]@{
      Id = Remove-DanioMarkdownFormatting -Value ([string]$row.ID)
      Finding = [string]$row.Finding
      HowFound = $null
      Evidence = $null
      SupersedingEvidence = [string]$row.'Superseding Evidence'
      Disposition = Remove-DanioMarkdownFormatting -Value ([string]$row.Disposition)
      ClosureState = Remove-DanioMarkdownFormatting -Value ([string]$row.'Closure State')
      Lane = $null
      UserInput = $null
      DoneCondition = $null
      Rule = [string]$row.Rule
      Table = "Closed, Accepted, Or Superseded Findings"
    })
  }

  $allowedStates = @("open", "closed", "parked", "decision_required")
  $seenIds = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
  foreach ($row in $normalized) {
    if (-not $seenIds.Add([string]$row.Id)) {
      throw "LEDGER_DUPLICATE_ID: duplicate ledger ID '$($row.Id)'."
    }
    if ($allowedStates -cnotcontains [string]$row.ClosureState) {
      throw "LEDGER_UNKNOWN_STATE: '$($row.ClosureState)' is not allowed."
    }
  }

  return $normalized.ToArray()
}

function Test-DanioLedgerClosureRows {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][object[]]$Rows,
    [string[]]$ActivePhaseLedgerIds = @()
  )

  $seenIds = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
  $allowedStates = @("open", "closed", "parked", "decision_required")
  foreach ($row in $Rows) {
    $required = @("Id", "Disposition", "ClosureState")
    $names = @($row.PSObject.Properties | ForEach-Object { $_.Name })
    foreach ($name in $required) {
      if ($names -cnotcontains $name) {
        return New-DanioValidationResult -Valid $false -Code "LEDGER_ROW_INVALID" -Details @("Missing '$name'.")
      }
    }

    $id = [string]$row.Id
    $state = [string]$row.ClosureState
    $disposition = [string]$row.Disposition
    if (-not $seenIds.Add($id)) {
      return New-DanioValidationResult -Valid $false -Code "LEDGER_DUPLICATE_ID" -Details @("Duplicate ID '$id'.")
    }
    if ($allowedStates -cnotcontains $state) {
      return New-DanioValidationResult -Valid $false -Code "LEDGER_UNKNOWN_STATE" -Details @("Unknown state '$state'.")
    }
    if (
      @("PHASE_PARKED", "EXTERNAL_PARKED") -ccontains $disposition -and
      $state -cne "parked"
    ) {
      return New-DanioValidationResult -Valid $false -Code "LEDGER_DISPOSITION_STATE_MISMATCH" -Details @("$id must be parked.")
    }
    if (
      @("ACCEPTED_LOCAL_LIMITATION", "NOT_CURRENT_ARCHIVED") -ccontains $disposition -and
      $state -cne "closed"
    ) {
      return New-DanioValidationResult -Valid $false -Code "LEDGER_DISPOSITION_STATE_MISMATCH" -Details @("$id must be closed.")
    }
  }

  if ($ActivePhaseLedgerIds.Count -gt 0) {
    if ($ActivePhaseLedgerIds[-1] -cne "DCL-RC-001") {
      return New-DanioValidationResult -Valid $false -Code "RELEASE_CANDIDATE_ORDER" -Details @("DCL-RC-001 must be last in active phase order.")
    }
    $phaseSeen = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
    foreach ($id in $ActivePhaseLedgerIds) {
      if (-not $phaseSeen.Add($id)) {
        return New-DanioValidationResult -Valid $false -Code "ACTIVE_SCOPE_INVALID" -Details @("Duplicate active-scope ID '$id'.")
      }
      if (-not $seenIds.Contains($id)) {
        return New-DanioValidationResult -Valid $false -Code "ACTIVE_SCOPE_INVALID" -Details @("Missing active-scope ID '$id'.")
      }
      $row = $Rows | Where-Object { $_.Id -ceq $id } | Select-Object -First 1
      if ($row.ClosureState -ceq "parked") {
        return New-DanioValidationResult -Valid $false -Code "ACTIVE_SCOPE_INVALID" -Details @("Parked row '$id' is in active scope.")
      }
    }
  }

  $counts = [pscustomobject]@{
    open = @($Rows | Where-Object { $_.ClosureState -ceq "open" }).Count
    parked = @($Rows | Where-Object { $_.ClosureState -ceq "parked" }).Count
    closed = @($Rows | Where-Object { $_.ClosureState -ceq "closed" }).Count
    decision_required = @($Rows | Where-Object { $_.ClosureState -ceq "decision_required" }).Count
  }
  return [pscustomobject]@{
    valid = $true
    code = "LEDGER_VALID"
    details = @()
    counts = $counts
  }
}

function Test-DanioRunState {
  [CmdletBinding()]
  param([Parameter(Mandatory = $true)]$State)

  $rootFields = @(
    "document_type",
    "schema_version",
    "run_id",
    "state_revision",
    "mode",
    "transition",
    "authority",
    "authorization",
    "cursor",
    "owner",
    "budget",
    "handoff_generation",
    "last_verified_checkpoint",
    "repeated_failure",
    "stop_reason_code",
    "recovery",
    "control_surface_sync"
  )
  $rootSet = Test-DanioExactPropertySet -Value $State -Allowed $rootFields -Required $rootFields
  if ($rootSet.unknown.Count -gt 0) {
    return New-DanioValidationResult -Valid $false -Code "STATE_UNKNOWN_FIELD" -Details @("Unknown state fields: $($rootSet.unknown -join ', ').")
  }
  if ($rootSet.missing.Count -gt 0) {
    return New-DanioValidationResult -Valid $false -Code "STATE_MISSING_FIELD" -Details @("Missing state fields: $($rootSet.missing -join ', ').")
  }

  if ($State.document_type -cne "danio_phone_completion_run_state" -or [int]$State.schema_version -ne 1) {
    return New-DanioValidationResult -Valid $false -Code "STATE_SCHEMA_INVALID" -Details @("Document type or schema version is invalid.")
  }
  if (
    -not (Test-DanioInteger -Value $State.state_revision) -or
    [int64]$State.state_revision -lt 0
  ) {
    return New-DanioValidationResult -Valid $false -Code "STATE_REVISION_INVALID" -Details @("state_revision must be a non-negative integer.")
  }
  if ($script:DanioModes -cnotcontains [string]$State.mode) {
    return New-DanioValidationResult -Valid $false -Code "STATE_MODE_INVALID" -Details @("Unknown mode '$($State.mode)'.")
  }

  $authorityFields = @(
    "phone_completion_program",
    "closure_ledger",
    "finish_map",
    "quality_ladder",
    "verified_slice_execution_contract",
    "active_handoff",
    "device_ownership_policy"
  )
  $authoritySet = Test-DanioExactPropertySet -Value $State.authority -Allowed $authorityFields -Required $authorityFields
  if (-not $authoritySet.valid) {
    return New-DanioValidationResult -Valid $false -Code "AUTHORITY_INVALID" -Details @("Authority fields are missing or unknown.")
  }
  foreach ($field in $authorityFields) {
    $reference = $State.authority.$field
    $referenceFields = @("path", "commit", "blob_oid")
    $referenceSet = Test-DanioExactPropertySet -Value $reference -Allowed $referenceFields -Required $referenceFields
    if (-not $referenceSet.valid) {
      return New-DanioValidationResult -Valid $false -Code "AUTHORITY_INVALID" -Details @("Authority '$field' is malformed.")
    }
    $path = [string]$reference.path
    if (
      [string]::IsNullOrWhiteSpace($path) -or
      $path.Contains("\") -or
      $path.StartsWith("/") -or
      $path -match '^[A-Za-z]:' -or
      "/$path/" -match '/\.\./'
    ) {
      return New-DanioValidationResult -Valid $false -Code "AUTHORITY_INVALID" -Details @("Authority '$field' path is unsafe.")
    }
    if (
      [string]$reference.commit -notmatch '^[0-9a-f]{40}$' -or
      [string]$reference.blob_oid -notmatch '^[0-9a-f]{40}$'
    ) {
      return New-DanioValidationResult -Valid $false -Code "AUTHORITY_INVALID" -Details @("Authority '$field' Git identity is invalid.")
    }
  }

  $authorizationFields = @(
    "authorization_id",
    "continuation_mode",
    "saved_project_root",
    "repository_root",
    "authorized_at_utc"
  )
  $authorizationSet = Test-DanioExactPropertySet `
    -Value $State.authorization `
    -Allowed $authorizationFields `
    -Required $authorizationFields
  if (-not $authorizationSet.valid) {
    return New-DanioValidationResult -Valid $false -Code "AUTHORIZATION_INVALID" -Details @("Authorization fields are missing or unknown.")
  }
  if ($State.authorization.continuation_mode -cne "autonomous_chain_approved") {
    return New-DanioValidationResult -Valid $false -Code "AUTHORIZATION_INVALID" -Details @("Continuation mode is invalid.")
  }
  foreach ($pathField in @("saved_project_root", "repository_root")) {
    $absolutePath = [string]$State.authorization.$pathField
    if ($absolutePath -notmatch '^[A-Za-z]:/' -or $absolutePath.Contains("\") -or "/$absolutePath/" -match '/\.\./') {
      return New-DanioValidationResult -Valid $false -Code "AUTHORIZATION_INVALID" -Details @("Authorization path '$pathField' is unsafe.")
    }
  }
  if ([string]$State.authorization.authorized_at_utc -notmatch '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{7}Z$') {
    return New-DanioValidationResult -Valid $false -Code "AUTHORIZATION_INVALID" -Details @("Authorization timestamp is not strict UTC.")
  }

  $cursorFields = @("phase", "work_unit_id", "ledger_row_ids")
  $cursorSet = Test-DanioExactPropertySet -Value $State.cursor -Allowed $cursorFields -Required $cursorFields
  if (-not $cursorSet.valid) {
    return New-DanioValidationResult -Valid $false -Code "CURSOR_INVALID" -Details @("Cursor fields are missing or unknown.")
  }
  if (
    [string]::IsNullOrWhiteSpace([string]$State.cursor.phase) -or
    [string]::IsNullOrWhiteSpace([string]$State.cursor.work_unit_id)
  ) {
    return New-DanioValidationResult -Valid $false -Code "CURSOR_INVALID" -Details @("Cursor phase and work unit are required.")
  }

  $budgetFields = @(
    "total_approved_units",
    "consumed_units",
    "remaining_units_including_current",
    "current_charge"
  )
  $budgetSet = Test-DanioExactPropertySet -Value $State.budget -Allowed $budgetFields -Required $budgetFields
  if (-not $budgetSet.valid) {
    return New-DanioValidationResult -Valid $false -Code "BUDGET_INVALID" -Details @("Budget fields are missing or unknown.")
  }
  foreach ($field in @("total_approved_units", "consumed_units", "remaining_units_including_current")) {
    if (-not (Test-DanioInteger -Value $State.budget.$field) -or [int64]$State.budget.$field -lt 0) {
      return New-DanioValidationResult -Valid $false -Code "BUDGET_INVALID" -Details @("Budget '$field' must be a non-negative integer.")
    }
  }
  if ([int64]$State.budget.total_approved_units -lt 1) {
    return New-DanioValidationResult -Valid $false -Code "BUDGET_INVALID" -Details @("Approved unit count must be positive.")
  }
  if (
    [int64]$State.budget.consumed_units +
    [int64]$State.budget.remaining_units_including_current -ne
    [int64]$State.budget.total_approved_units
  ) {
    return New-DanioValidationResult -Valid $false -Code "BUDGET_INVARIANT" -Details @("Consumed plus remaining must equal total.")
  }

  $chargeFields = @("work_unit_id", "status", "claimed_revision", "consumed_revision")
  $charge = $State.budget.current_charge
  $chargeSet = Test-DanioExactPropertySet -Value $charge -Allowed $chargeFields -Required $chargeFields
  if (-not $chargeSet.valid) {
    return New-DanioValidationResult -Valid $false -Code "BUDGET_CHARGE_INVALID" -Details @("Current charge fields are missing or unknown.")
  }
  if (@("none", "pending", "consumed") -cnotcontains [string]$charge.status) {
    return New-DanioValidationResult -Valid $false -Code "BUDGET_CHARGE_INVALID" -Details @("Unknown charge status '$($charge.status)'.")
  }
  if (
    $charge.status -ceq "none" -and
    (
      $null -ne $charge.work_unit_id -or
      $null -ne $charge.claimed_revision -or
      $null -ne $charge.consumed_revision
    )
  ) {
    return New-DanioValidationResult -Valid $false -Code "BUDGET_CHARGE_INVALID" -Details @("A none charge must use explicit null fields.")
  }
  if (
    $charge.status -ceq "pending" -and
    (
      [string]::IsNullOrWhiteSpace([string]$charge.work_unit_id) -or
      $null -eq $charge.claimed_revision -or
      $null -ne $charge.consumed_revision
    )
  ) {
    return New-DanioValidationResult -Valid $false -Code "BUDGET_CHARGE_INVALID" -Details @("A pending charge needs a claim revision and no consumed revision.")
  }
  if (
    $charge.status -ceq "consumed" -and
    (
      [string]::IsNullOrWhiteSpace([string]$charge.work_unit_id) -or
      $null -eq $charge.claimed_revision -or
      $null -eq $charge.consumed_revision
    )
  ) {
    return New-DanioValidationResult -Valid $false -Code "BUDGET_CHARGE_INVALID" -Details @("A consumed charge needs claim and consumed revisions.")
  }

  $mode = [string]$State.mode
  if (@("active", "finalizing") -ccontains $mode) {
    if ($null -eq $State.owner) {
      return New-DanioValidationResult -Valid $false -Code "OWNER_REQUIRED" -Details @("Mode '$mode' requires an owner.")
    }
  } elseif ($null -ne $State.owner) {
    return New-DanioValidationResult -Valid $false -Code "OWNER_NOT_ALLOWED" -Details @("Mode '$mode' must release the owner.")
  }

  if ($null -ne $State.owner) {
    $ownerFields = @(
      "task_id",
      "token_sha256",
      "claim_revision",
      "claim_parent_commit",
      "claim_staged_tree_hash",
      "branch_name",
      "worktree_id",
      "worktree_path",
      "claimed_at_utc",
      "writer_lease_released",
      "android_lease_released"
    )
    $ownerSet = Test-DanioExactPropertySet -Value $State.owner -Allowed $ownerFields -Required $ownerFields
    if (-not $ownerSet.valid) {
      return New-DanioValidationResult -Valid $false -Code "OWNER_INVALID" -Details @("Owner fields are missing or unknown.")
    }
    if (
      -not (Test-DanioInteger -Value $State.owner.claim_revision) -or
      [int64]$State.owner.claim_revision -lt 1
    ) {
      return New-DanioValidationResult -Valid $false -Code "OWNER_INVALID" -Details @("Owner claim revision is invalid.")
    }
    $expectedToken = Get-DanioOwnerToken `
      -RunId ([string]$State.run_id) `
      -WorkUnitId ([string]$State.cursor.work_unit_id) `
      -TaskId ([string]$State.owner.task_id) `
      -ExpectedRevision ([int]$State.owner.claim_revision)
    if ([string]$State.owner.token_sha256 -cne $expectedToken) {
      return New-DanioValidationResult -Valid $false -Code "OWNER_TOKEN_INVALID" -Details @("Owner token does not match its exact input.")
    }
    $token12 = $expectedToken.Substring(0, 12)
    $expectedBranch = "autonomy/$($State.run_id)/$($State.cursor.work_unit_id)/$token12"
    $expectedWorktreeId = "$($State.run_id)-$($State.cursor.work_unit_id)-$token12"
    if (
      [string]$State.owner.branch_name -cne $expectedBranch -or
      [string]$State.owner.worktree_id -cne $expectedWorktreeId -or
      -not ([string]$State.owner.worktree_path).Replace("\", "/").EndsWith("/.codex-worktrees/$expectedWorktreeId")
    ) {
      return New-DanioValidationResult -Valid $false -Code "OWNER_IDENTITY_INVALID" -Details @("Owner branch or worktree identity is invalid.")
    }
    if ([bool]$State.owner.writer_lease_released) {
      return New-DanioValidationResult -Valid $false -Code "OWNER_LEASE_INVALID" -Details @("Active/finalizing writer lease cannot be released.")
    }
  }

  if ($mode -ceq "active" -and $charge.status -cne "pending") {
    return New-DanioValidationResult -Valid $false -Code "BUDGET_CHARGE_INVALID" -Details @("Active mode requires a pending charge.")
  }
  if ($mode -ceq "finalizing" -and $charge.status -cne "consumed") {
    return New-DanioValidationResult -Valid $false -Code "BUDGET_CHARGE_INVALID" -Details @("Finalizing mode requires an already consumed charge.")
  }
  if (
    @("active", "finalizing") -ccontains $mode -and
    [string]$charge.work_unit_id -cne [string]$State.cursor.work_unit_id
  ) {
    return New-DanioValidationResult -Valid $false -Code "BUDGET_CHARGE_INVALID" -Details @("Owner and charge work units must agree.")
  }

  if ($mode -ceq "inactive") {
    if ([int64]$State.state_revision -ne 0 -or $null -ne $State.transition) {
      return New-DanioValidationResult -Valid $false -Code "STATE_TRANSITION_INVALID" -Details @("Inactive fixture must be revision zero with null transition.")
    }
  } else {
    $transitionFields = @(
      "action",
      "from_mode",
      "to_mode",
      "parent_state_revision",
      "work_unit_id",
      "reason_code",
      "occurred_at_utc"
    )
    $transitionSet = Test-DanioExactPropertySet -Value $State.transition -Allowed $transitionFields -Required $transitionFields
    if (-not $transitionSet.valid) {
      return New-DanioValidationResult -Valid $false -Code "STATE_TRANSITION_INVALID" -Details @("Transition fields are missing or unknown.")
    }
    if (
      [string]$State.transition.to_mode -cne $mode -or
      [int64]$State.transition.parent_state_revision -ne ([int64]$State.state_revision - 1)
    ) {
      return New-DanioValidationResult -Valid $false -Code "STATE_TRANSITION_INVALID" -Details @("Transition metadata does not match state revision/mode.")
    }
    $transitionKey = "$($State.transition.from_mode)>$($State.transition.to_mode)"
    if (-not $script:DanioAllowedTransitions.ContainsKey($transitionKey)) {
      return New-DanioValidationResult -Valid $false -Code "TRANSITION_NOT_ALLOWED" -Details @("Transition '$transitionKey' is forbidden.")
    }
    if ([string]$State.transition.action -cne [string]$script:DanioAllowedTransitions[$transitionKey]) {
      return New-DanioValidationResult -Valid $false -Code "TRANSITION_ACTION_INVALID" -Details @("Transition action is invalid.")
    }
  }

  $controlFields = @(
    "status",
    "target_commit",
    "figma_file_id",
    "figma_node_ids",
    "attempted_at_utc",
    "evidence_sha256",
    "failure_code"
  )
  $controlSet = Test-DanioExactPropertySet `
    -Value $State.control_surface_sync `
    -Allowed $controlFields `
    -Required $controlFields
  if (-not $controlSet.valid) {
    return New-DanioValidationResult -Valid $false -Code "CONTROL_SURFACE_INVALID" -Details @("Control-surface fields are missing or unknown.")
  }
  if (@("not_required", "pending", "synced", "failed") -cnotcontains [string]$State.control_surface_sync.status) {
    return New-DanioValidationResult -Valid $false -Code "CONTROL_SURFACE_INVALID" -Details @("Control-surface status is invalid.")
  }

  if ($mode -ceq "stopped" -and $null -eq $State.stop_reason_code) {
    return New-DanioValidationResult -Valid $false -Code "STOP_REASON_REQUIRED" -Details @("Durable stopped mode requires a stop reason.")
  }

  return New-DanioValidationResult -Valid $true -Code "STATE_VALID"
}

function Test-DanioRunStateTransition {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]$PreviousState,
    [Parameter(Mandatory = $true)]$CandidateState
  )

  $previousValidation = Test-DanioRunState -State $PreviousState
  if (-not $previousValidation.valid) {
    return New-DanioValidationResult `
      -Valid $false `
      -Code "PREVIOUS_STATE_INVALID" `
      -Details @("$($previousValidation.code): $($previousValidation.details -join '; ')")
  }

  if (
    @("active", "finalizing") -ccontains [string]$PreviousState.mode -and
    [string]$CandidateState.mode -ceq "stopped" -and
    $null -ne $CandidateState.owner
  ) {
    return New-DanioValidationResult `
      -Valid $false `
      -Code "STOP_PENDING" `
      -Details @("Writer lease release is unsafe or unproven; retain the durable owner.")
  }

  if (
    -not (Test-DanioInteger -Value $CandidateState.state_revision) -or
    [int64]$CandidateState.state_revision -ne ([int64]$PreviousState.state_revision + 1)
  ) {
    return New-DanioValidationResult `
      -Valid $false `
      -Code "STATE_REVISION_INVALID" `
      -Details @("State revision must increment by exactly one.")
  }
  if ($null -eq $CandidateState.transition) {
    return New-DanioValidationResult -Valid $false -Code "STATE_TRANSITION_INVALID" -Details @("Candidate transition is required.")
  }

  $transitionKey = "$($PreviousState.mode)>$($CandidateState.mode)"
  if (-not $script:DanioAllowedTransitions.ContainsKey($transitionKey)) {
    return New-DanioValidationResult -Valid $false -Code "TRANSITION_NOT_ALLOWED" -Details @("Transition '$transitionKey' is forbidden.")
  }
  $expectedAction = [string]$script:DanioAllowedTransitions[$transitionKey]
  if ([string]$CandidateState.transition.action -cne $expectedAction) {
    return New-DanioValidationResult -Valid $false -Code "TRANSITION_ACTION_INVALID" -Details @("Expected action '$expectedAction'.")
  }
  if (
    [string]$CandidateState.transition.from_mode -cne [string]$PreviousState.mode -or
    [string]$CandidateState.transition.to_mode -cne [string]$CandidateState.mode -or
    [int64]$CandidateState.transition.parent_state_revision -ne [int64]$PreviousState.state_revision
  ) {
    return New-DanioValidationResult -Valid $false -Code "STATE_TRANSITION_INVALID" -Details @("Transition parent/mode metadata is invalid.")
  }

  $candidateValidation = Test-DanioRunState -State $CandidateState
  if (-not $candidateValidation.valid) {
    return New-DanioValidationResult `
      -Valid $false `
      -Code $candidateValidation.code `
      -Details $candidateValidation.details
  }

  $previousBudget = $PreviousState.budget
  $candidateBudget = $CandidateState.budget
  $budgetUnchanged = (
    [int64]$candidateBudget.total_approved_units -eq [int64]$previousBudget.total_approved_units -and
    [int64]$candidateBudget.consumed_units -eq [int64]$previousBudget.consumed_units -and
    [int64]$candidateBudget.remaining_units_including_current -eq [int64]$previousBudget.remaining_units_including_current
  )

  switch ($expectedAction) {
    "launch" {
      if (
        [int64]$candidateBudget.total_approved_units -ne [int64]$previousBudget.total_approved_units -or
        [int64]$candidateBudget.consumed_units -ne ([int64]$previousBudget.consumed_units + 1) -or
        [int64]$candidateBudget.remaining_units_including_current -ne ([int64]$previousBudget.remaining_units_including_current - 1) -or
        [string]$candidateBudget.current_charge.status -cne "none"
      ) {
        return New-DanioValidationResult -Valid $false -Code "BOOTSTRAP_CHARGE_INVALID" -Details @("Launch must absorb one setup unit while current charge stays none.")
      }
    }
    "claim" {
      if (
        -not $budgetUnchanged -or
        [string]$candidateBudget.current_charge.status -cne "pending" -or
        $null -eq $CandidateState.owner
      ) {
        return New-DanioValidationResult -Valid $false -Code "CLAIM_BUDGET_INVALID" -Details @("Claim must set pending ownership without decrement.")
      }
    }
    "preclaim_stop" {
      if (
        -not $budgetUnchanged -or
        (ConvertTo-DanioCanonicalJson -Value $candidateBudget.current_charge) -cne
          (ConvertTo-DanioCanonicalJson -Value $previousBudget.current_charge)
      ) {
        return New-DanioValidationResult -Valid $false -Code "PRECLAIM_STOP_INVALID" -Details @("Pre-claim stop must consume zero units.")
      }
    }
    { @("closeout", "pause", "stop", "finalize") -ccontains $_ } {
      if (
        [string]$previousBudget.current_charge.status -cne "pending" -or
        [int64]$candidateBudget.total_approved_units -ne [int64]$previousBudget.total_approved_units -or
        [int64]$candidateBudget.consumed_units -ne ([int64]$previousBudget.consumed_units + 1) -or
        [int64]$candidateBudget.remaining_units_including_current -ne ([int64]$previousBudget.remaining_units_including_current - 1) -or
        [string]$candidateBudget.current_charge.status -cne "consumed" -or
        [int64]$candidateBudget.current_charge.consumed_revision -ne [int64]$CandidateState.state_revision
      ) {
        return New-DanioValidationResult -Valid $false -Code "UNIT_CONSUMPTION_INVALID" -Details @("Closeout/stop/finalize must consume the pending unit exactly once.")
      }
      if (
        $expectedAction -ceq "finalize" -and
        [string]$CandidateState.owner.token_sha256 -cne [string]$PreviousState.owner.token_sha256
      ) {
        return New-DanioValidationResult -Valid $false -Code "OWNER_TOKEN_INVALID" -Details @("Finalization must retain the exact owner token.")
      }
      if (
        $expectedAction -ceq "closeout" -and
        [int64]$CandidateState.handoff_generation -ne ([int64]$PreviousState.handoff_generation + 1)
      ) {
        return New-DanioValidationResult -Valid $false -Code "HANDOFF_GENERATION_INVALID" -Details @("Closeout must advance handoff generation once.")
      }
    }
    { @("complete", "finalization_stop") -ccontains $_ } {
      if (
        -not $budgetUnchanged -or
        (ConvertTo-DanioCanonicalJson -Value $candidateBudget.current_charge) -cne
          (ConvertTo-DanioCanonicalJson -Value $previousBudget.current_charge)
      ) {
        return New-DanioValidationResult -Valid $false -Code "FINALIZATION_DOUBLE_CHARGE" -Details @("Finalization exit must not consume twice.")
      }
    }
    "resume" {
      if (-not $budgetUnchanged) {
        return New-DanioValidationResult -Valid $false -Code "RESUME_BUDGET_INVALID" -Details @("Resume cannot silently change budget.")
      }
    }
    "administrative_sync" {
      $expectedCandidate = Copy-DanioJsonValue -Value $PreviousState
      $expectedCandidate.state_revision = $CandidateState.state_revision
      $expectedCandidate.transition = Copy-DanioJsonValue -Value $CandidateState.transition
      $expectedCandidate.control_surface_sync = Copy-DanioJsonValue -Value $CandidateState.control_surface_sync
      if (
        (ConvertTo-DanioCanonicalJson -Value $expectedCandidate) -cne
        (ConvertTo-DanioCanonicalJson -Value $CandidateState)
      ) {
        return New-DanioValidationResult -Valid $false -Code "ADMINISTRATIVE_CHANGE_FORBIDDEN" -Details @("Administrative update changed a protected field.")
      }
    }
  }

  return New-DanioValidationResult -Valid $true -Code "TRANSITION_VALID"
}

function Test-DanioCompletionReadiness {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]$State,
    [Parameter(Mandatory = $true)][object[]]$LedgerRows,
    [Parameter(Mandatory = $true)][string[]]$ActivePhaseLedgerIds,
    [Parameter(Mandatory = $true)]$Evidence,
    [Parameter(Mandatory = $true)]$Cleanup,
    [Parameter(Mandatory = $true)]$RepositoryObservation
  )

  $details = New-Object System.Collections.Generic.List[string]
  $stateValidation = Test-DanioRunState -State $State
  if (-not $stateValidation.valid) {
    $details.Add("State: $($stateValidation.code).")
  }
  if ([string]$State.mode -cne "finalizing") {
    $details.Add("Candidate parent mode must be finalizing.")
  }

  $ledgerValidation = Test-DanioLedgerClosureRows `
    -Rows $LedgerRows `
    -ActivePhaseLedgerIds $ActivePhaseLedgerIds
  if (-not $ledgerValidation.valid) {
    $details.Add("Ledger: $($ledgerValidation.code).")
  } else {
    foreach ($id in $ActivePhaseLedgerIds) {
      $row = $LedgerRows | Where-Object { $_.Id -ceq $id } | Select-Object -First 1
      if ($null -eq $row -or [string]$row.ClosureState -cne "closed") {
        $details.Add("Active row '$id' is not closed.")
      }
    }
    foreach ($row in @($LedgerRows | Where-Object { $_.ClosureState -ceq "parked" })) {
      if ($ActivePhaseLedgerIds -ccontains [string]$row.Id) {
        $details.Add("Parked row '$($row.Id)' is inside active scope.")
      }
    }
  }

  $evidenceFields = @("checkpoint_commit", "checks")
  $evidenceSet = Test-DanioExactPropertySet -Value $Evidence -Allowed $evidenceFields -Required $evidenceFields
  if (-not $evidenceSet.valid) {
    $details.Add("Evidence fields are missing or unknown.")
  } else {
    $requiredChecks = @(
      "FULL",
      "ANDROID_PREP",
      "CONTENT",
      "VISUAL",
      "PRODUCT_TRUTH",
      "PHONE_QA"
    )
    foreach ($code in $requiredChecks) {
      $matches = @($Evidence.checks | Where-Object { $_.code -ceq $code })
      if ($matches.Count -ne 1) {
        $details.Add("Evidence '$code' must appear exactly once.")
        continue
      }
      if (
        [string]$matches[0].status -cne "pass" -or
        [string]$matches[0].checkpoint_commit -cne [string]$Evidence.checkpoint_commit
      ) {
        $details.Add("Evidence '$code' is stale or failed.")
      }
    }
  }

  $repositoryFields = @("parent_commit", "origin_main_commit", "ahead", "behind", "clean")
  $repositorySet = Test-DanioExactPropertySet `
    -Value $RepositoryObservation `
    -Allowed $repositoryFields `
    -Required $repositoryFields
  if (-not $repositorySet.valid) {
    $details.Add("Repository observation fields are missing or unknown.")
  } elseif (
    -not [bool]$RepositoryObservation.clean -or
    [int64]$RepositoryObservation.ahead -ne 0 -or
    [int64]$RepositoryObservation.behind -ne 0 -or
    [string]$RepositoryObservation.parent_commit -cne [string]$RepositoryObservation.origin_main_commit -or
    [string]$RepositoryObservation.parent_commit -cne [string]$Evidence.checkpoint_commit
  ) {
    $details.Add("Repository parent checkpoint is not clean and aligned with evidence.")
  }

  $cleanupFields = @("owner_token", "branch_removed", "worktree_removed", "device_released")
  $cleanupSet = Test-DanioExactPropertySet -Value $Cleanup -Allowed $cleanupFields -Required $cleanupFields
  if (-not $cleanupSet.valid) {
    $details.Add("Cleanup fields are missing or unknown.")
  } elseif (
    $null -eq $State.owner -or
    [string]$Cleanup.owner_token -cne [string]$State.owner.token_sha256 -or
    -not [bool]$Cleanup.branch_removed -or
    -not [bool]$Cleanup.worktree_removed -or
    -not [bool]$Cleanup.device_released
  ) {
    $details.Add("Owned branch, worktree, device, or owner-token cleanup is unproven.")
  }

  if ($details.Count -gt 0) {
    return [pscustomobject]@{
      ready = $false
      code = "COMPLETION_NOT_READY"
      details = @($details.ToArray())
    }
  }

  return [pscustomobject]@{
    ready = $true
    code = "COMPLETION_READY"
    details = @()
  }
}

Export-ModuleMember -Function @(
  "Resolve-DanioRepositoryRoot",
  "Read-DanioLedgerClosureRows",
  "Test-DanioLedgerClosureRows",
  "Test-DanioRunState",
  "Test-DanioRunStateTransition",
  "Test-DanioCompletionReadiness"
)
