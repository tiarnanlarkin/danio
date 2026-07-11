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
  param($Value)

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

function Test-DanioBoolean {
  [CmdletBinding()]
  param($Value)

  return $Value -is [bool]
}

function Test-DanioStrictUtc {
  [CmdletBinding()]
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

function Test-DanioGitOid {
  [CmdletBinding()]
  param($Value)

  return $Value -is [string] -and $Value -cmatch '^[0-9a-f]{40}$'
}

function Test-DanioSha256 {
  [CmdletBinding()]
  param($Value)

  return $Value -is [string] -and $Value -cmatch '^[0-9a-f]{64}$'
}

function Test-DanioReasonCode {
  [CmdletBinding()]
  param($Value)

  return $Value -is [string] -and $Value -cmatch '^[A-Z][A-Z0-9_]*$'
}

function Test-DanioSafeIdentifier {
  [CmdletBinding()]
  param($Value)

  return (
    $Value -is [string] -and
    $Value.Length -ge 1 -and
    $Value.Length -le 160 -and
    $Value -cmatch '^[A-Za-z0-9][A-Za-z0-9._-]*$'
  )
}

function Test-DanioAbsoluteWindowsPath {
  [CmdletBinding()]
  param($Value)

  if (
    $Value -isnot [string] -or
    $Value -notmatch '^[A-Za-z]:/' -or
    $Value.Contains("\")
  ) {
    return $false
  }
  return @($Value.Split("/") | Where-Object { $_ -ceq ".." }).Count -eq 0
}

function Test-DanioRepoPath {
  [CmdletBinding()]
  param($Value)

  if (
    $Value -isnot [string] -or
    [string]::IsNullOrWhiteSpace($Value) -or
    $Value.StartsWith("/") -or
    $Value -match '^[A-Za-z]:' -or
    $Value.Contains("\") -or
    $Value -cnotmatch '^[A-Za-z0-9._/-]+$'
  ) {
    return $false
  }
  return @($Value.Split("/") | Where-Object { $_ -ceq ".." }).Count -eq 0
}

function Test-DanioExactPropertySet {
  [CmdletBinding()]
  param(
    $Value,
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
    [Parameter(Mandatory = $true)][int64]$ExpectedRevision
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

  $tableStart = -1
  for ($index = $sectionStart; $index -lt $sectionEnd; $index += 1) {
    if ($lines[$index].Trim().StartsWith("|")) {
      $tableStart = $index
      break
    }
  }
  if ($tableStart -lt 0) {
    throw "LEDGER_TABLE_INVALID: '$Heading' has no table."
  }

  $tableLineList = New-Object System.Collections.Generic.List[string]
  for ($index = $tableStart; $index -lt $sectionEnd; $index += 1) {
    $trimmedLine = $lines[$index].Trim()
    if ([string]::IsNullOrWhiteSpace($trimmedLine)) {
      break
    }
    if (-not $trimmedLine.StartsWith("|") -or -not $trimmedLine.EndsWith("|")) {
      throw "LEDGER_MALFORMED_ROW: '$Heading' table row must begin and end with a pipe."
    }
    $tableLineList.Add($lines[$index])
  }
  $tableLines = @($tableLineList.ToArray())
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

function Test-DanioActiveScope {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]]$Rows,
    [Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$ActivePhaseLedgerIds,
    [switch]$RequireAllClosed,
    [switch]$RequireNonReleaseCandidateClosed
  )

  if ($ActivePhaseLedgerIds.Count -eq 0) {
    return New-DanioValidationResult -Valid $false -Code "ACTIVE_SCOPE_INVALID" -Details @("Active scope cannot be empty.")
  }
  $ledgerValidation = Test-DanioLedgerClosureRows `
    -Rows $Rows `
    -ActivePhaseLedgerIds $ActivePhaseLedgerIds
  if (-not $ledgerValidation.valid) {
    return $ledgerValidation
  }

  $expectedRows = @(
    $Rows | Where-Object {
      (
        [string]$_.Table -ceq "Active Findings" -and
        [string]$_.ClosureState -cne "parked"
      ) -or
      [string]$_.Disposition -ceq "ACCEPTED_LOCAL_LIMITATION"
    }
  )
  $expectedIds = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
  foreach ($row in $expectedRows) {
    [void]$expectedIds.Add([string]$row.Id)
  }
  if ($expectedIds.Count -ne $ActivePhaseLedgerIds.Count) {
    return New-DanioValidationResult -Valid $false -Code "ACTIVE_SCOPE_INVALID" -Details @("Active scope does not match canonical non-parked active-table rows plus accepted limitations.")
  }
  foreach ($id in $ActivePhaseLedgerIds) {
    if (-not $expectedIds.Contains($id)) {
      return New-DanioValidationResult -Valid $false -Code "ACTIVE_SCOPE_INVALID" -Details @("Unexpected active-scope ID '$id'.")
    }
  }

  foreach ($id in $ActivePhaseLedgerIds) {
    $row = $Rows | Where-Object { $_.Id -ceq $id } | Select-Object -First 1
    if (
      $RequireAllClosed -and
      [string]$row.ClosureState -cne "closed"
    ) {
      return New-DanioValidationResult -Valid $false -Code "ACTIVE_SCOPE_OPEN" -Details @("Active row '$id' is not closed.")
    }
    if (
      $RequireNonReleaseCandidateClosed -and
      $id -cne "DCL-RC-001" -and
      [string]$row.ClosureState -cne "closed"
    ) {
      return New-DanioValidationResult -Valid $false -Code "FINALIZATION_SCOPE_INVALID" -Details @("Non-RC row '$id' is not closed.")
    }
  }

  if ($RequireNonReleaseCandidateClosed) {
    $releaseCandidate = $Rows | Where-Object { $_.Id -ceq "DCL-RC-001" } | Select-Object -First 1
    if ($null -eq $releaseCandidate -or [string]$releaseCandidate.ClosureState -cne "open") {
      return New-DanioValidationResult -Valid $false -Code "FINALIZATION_SCOPE_INVALID" -Details @("DCL-RC-001 must be the open terminal row when finalization begins.")
    }
  }

  return New-DanioValidationResult -Valid $true -Code "ACTIVE_SCOPE_VALID"
}

function Test-DanioRunState {
  [CmdletBinding()]
  param([Parameter(Mandatory = $true)][AllowNull()]$State)

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

  if (
    $State.document_type -isnot [string] -or
    $State.document_type -cne "danio_phone_completion_run_state" -or
    -not (Test-DanioInteger -Value $State.schema_version) -or
    [int64]$State.schema_version -ne 1
  ) {
    return New-DanioValidationResult -Valid $false -Code "STATE_SCHEMA_INVALID" -Details @("Document type or schema version is invalid.")
  }
  if (-not (Test-DanioSafeIdentifier -Value $State.run_id)) {
    return New-DanioValidationResult -Valid $false -Code "STATE_SCHEMA_INVALID" -Details @("run_id is invalid.")
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
  if (
    -not (Test-DanioInteger -Value $State.handoff_generation) -or
    [int64]$State.handoff_generation -lt 0
  ) {
    return New-DanioValidationResult -Valid $false -Code "HANDOFF_GENERATION_INVALID" -Details @("handoff_generation must be a non-negative integer.")
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
    if (-not (Test-DanioRepoPath -Value $reference.path)) {
      return New-DanioValidationResult -Valid $false -Code "AUTHORITY_INVALID" -Details @("Authority '$field' path is unsafe.")
    }
    if (
      -not (Test-DanioGitOid -Value $reference.commit) -or
      -not (Test-DanioGitOid -Value $reference.blob_oid)
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
  if (-not (Test-DanioSafeIdentifier -Value $State.authorization.authorization_id)) {
    return New-DanioValidationResult -Valid $false -Code "AUTHORIZATION_INVALID" -Details @("Authorization ID is invalid.")
  }
  foreach ($pathField in @("saved_project_root", "repository_root")) {
    if (-not (Test-DanioAbsoluteWindowsPath -Value $State.authorization.$pathField)) {
      return New-DanioValidationResult -Valid $false -Code "AUTHORIZATION_INVALID" -Details @("Authorization path '$pathField' is unsafe.")
    }
  }
  if (-not (Test-DanioStrictUtc -Value $State.authorization.authorized_at_utc)) {
    return New-DanioValidationResult -Valid $false -Code "AUTHORIZATION_INVALID" -Details @("Authorization timestamp is not strict UTC.")
  }

  $cursorFields = @("phase", "work_unit_id", "ledger_row_ids")
  $cursorSet = Test-DanioExactPropertySet -Value $State.cursor -Allowed $cursorFields -Required $cursorFields
  if (-not $cursorSet.valid) {
    return New-DanioValidationResult -Valid $false -Code "CURSOR_INVALID" -Details @("Cursor fields are missing or unknown.")
  }
  if (
    -not (Test-DanioSafeIdentifier -Value $State.cursor.phase) -or
    -not (Test-DanioSafeIdentifier -Value $State.cursor.work_unit_id)
  ) {
    return New-DanioValidationResult -Valid $false -Code "CURSOR_INVALID" -Details @("Cursor phase and work unit are required.")
  }
  if ($State.cursor.ledger_row_ids -isnot [System.Array]) {
    return New-DanioValidationResult -Valid $false -Code "CURSOR_INVALID" -Details @("Cursor ledger row IDs must be an array.")
  }
  $cursorIds = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
  foreach ($id in @($State.cursor.ledger_row_ids)) {
    if ($id -isnot [string] -or $id -cnotmatch '^DCL-[A-Z0-9]+-[0-9]{3}$' -or -not $cursorIds.Add($id)) {
      return New-DanioValidationResult -Valid $false -Code "CURSOR_INVALID" -Details @("Cursor ledger row IDs are invalid or duplicated.")
    }
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
      -not (Test-DanioSafeIdentifier -Value $charge.work_unit_id) -or
      -not (Test-DanioInteger -Value $charge.claimed_revision) -or
      [int64]$charge.claimed_revision -lt 1 -or
      $null -ne $charge.consumed_revision
    )
  ) {
    return New-DanioValidationResult -Valid $false -Code "BUDGET_CHARGE_INVALID" -Details @("A pending charge needs a claim revision and no consumed revision.")
  }
  if (
    $charge.status -ceq "consumed" -and
    (
      -not (Test-DanioSafeIdentifier -Value $charge.work_unit_id) -or
      -not (Test-DanioInteger -Value $charge.claimed_revision) -or
      [int64]$charge.claimed_revision -lt 1 -or
      -not (Test-DanioInteger -Value $charge.consumed_revision) -or
      [int64]$charge.consumed_revision -lt 1
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
    if (
      -not (Test-DanioSafeIdentifier -Value $State.owner.task_id) -or
      -not (Test-DanioGitOid -Value $State.owner.claim_parent_commit) -or
      -not (Test-DanioGitOid -Value $State.owner.claim_staged_tree_hash) -or
      -not (Test-DanioStrictUtc -Value $State.owner.claimed_at_utc) -or
      -not (Test-DanioBoolean -Value $State.owner.writer_lease_released) -or
      -not (Test-DanioBoolean -Value $State.owner.android_lease_released)
    ) {
      return New-DanioValidationResult -Valid $false -Code "OWNER_INVALID" -Details @("Owner identity types or evidence are invalid.")
    }
    if (
      [int64]$State.owner.claim_revision -ne [int64]$charge.claimed_revision -or
      [int64]$State.owner.claim_revision -ge [int64]$State.state_revision -or
      (
        $mode -ceq "active" -and
        $null -ne $State.transition -and
        [string]$State.transition.action -ceq "claim" -and
        [int64]$State.owner.claim_revision -ne [int64]$State.transition.parent_state_revision
      )
    ) {
      return New-DanioValidationResult -Valid $false -Code "OWNER_REVISION_INVALID" -Details @("Owner revision must match the charge and claim parent revision.")
    }
    $expectedToken = Get-DanioOwnerToken `
      -RunId ([string]$State.run_id) `
      -WorkUnitId ([string]$State.cursor.work_unit_id) `
      -TaskId ([string]$State.owner.task_id) `
      -ExpectedRevision ([int64]$State.owner.claim_revision)
    if ([string]$State.owner.token_sha256 -cne $expectedToken) {
      return New-DanioValidationResult -Valid $false -Code "OWNER_TOKEN_INVALID" -Details @("Owner token does not match its exact input.")
    }
    $token12 = $expectedToken.Substring(0, 12)
    $expectedBranch = "autonomy/$($State.run_id)/$($State.cursor.work_unit_id)/$token12"
    $expectedWorktreeId = "$($State.run_id)-$($State.cursor.work_unit_id)-$token12"
    $expectedWorktreePath = "$($State.authorization.saved_project_root)/.codex-worktrees/$expectedWorktreeId"
    if (
      [string]$State.owner.branch_name -cne $expectedBranch -or
      [string]$State.owner.worktree_id -cne $expectedWorktreeId -or
      [string]$State.owner.worktree_path -cne $expectedWorktreePath
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

  if ($null -ne $State.last_verified_checkpoint) {
    $checkpointFields = @("product_commit", "evidence_manifest_path", "verified_at_utc")
    $checkpointSet = Test-DanioExactPropertySet `
      -Value $State.last_verified_checkpoint `
      -Allowed $checkpointFields `
      -Required $checkpointFields
    if (
      -not $checkpointSet.valid -or
      -not (Test-DanioGitOid -Value $State.last_verified_checkpoint.product_commit) -or
      -not (Test-DanioRepoPath -Value $State.last_verified_checkpoint.evidence_manifest_path) -or
      -not (Test-DanioStrictUtc -Value $State.last_verified_checkpoint.verified_at_utc) -or
      [string]$State.last_verified_checkpoint.evidence_manifest_path -cne
        "apps/aquarium_app/docs/agent/autonomous_completion/evidence/$($State.last_verified_checkpoint.product_commit).json"
    ) {
      return New-DanioValidationResult -Valid $false -Code "VERIFIED_CHECKPOINT_INVALID" -Details @("Verified checkpoint is malformed or not commit-keyed.")
    }
  } elseif (@("handoff_ready", "paused", "finalizing", "complete") -ccontains $mode) {
    return New-DanioValidationResult -Valid $false -Code "VERIFIED_CHECKPOINT_REQUIRED" -Details @("Mode '$mode' requires a verified checkpoint.")
  }

  if ($null -ne $State.repeated_failure) {
    $failureFields = @("signature", "attempt_count", "last_failed_at_utc")
    $failureSet = Test-DanioExactPropertySet `
      -Value $State.repeated_failure `
      -Allowed $failureFields `
      -Required $failureFields
    if (
      -not $failureSet.valid -or
      -not (Test-DanioSha256 -Value $State.repeated_failure.signature) -or
      -not (Test-DanioInteger -Value $State.repeated_failure.attempt_count) -or
      [int64]$State.repeated_failure.attempt_count -lt 1 -or
      -not (Test-DanioStrictUtc -Value $State.repeated_failure.last_failed_at_utc)
    ) {
      return New-DanioValidationResult -Valid $false -Code "REPEATED_FAILURE_INVALID" -Details @("Repeated-failure evidence is malformed.")
    }
  }

  if ($null -ne $State.recovery) {
    $recoveryFields = @(
      "branch_name",
      "worktree_path",
      "dirty_paths",
      "relevant_processes",
      "commands",
      "last_clean_commit"
    )
    $recoverySet = Test-DanioExactPropertySet `
      -Value $State.recovery `
      -Allowed $recoveryFields `
      -Required $recoveryFields
    if (-not $recoverySet.valid) {
      return New-DanioValidationResult -Valid $false -Code "RECOVERY_INVALID" -Details @("Recovery fields are missing or unknown.")
    }
    if (
      ($null -ne $State.recovery.branch_name -and $State.recovery.branch_name -isnot [string]) -or
      ($null -ne $State.recovery.worktree_path -and -not (Test-DanioAbsoluteWindowsPath -Value $State.recovery.worktree_path)) -or
      $State.recovery.dirty_paths -isnot [System.Array] -or
      $State.recovery.relevant_processes -isnot [System.Array] -or
      $State.recovery.commands -isnot [System.Array] -or
      @($State.recovery.commands).Count -lt 1 -or
      -not (Test-DanioGitOid -Value $State.recovery.last_clean_commit)
    ) {
      return New-DanioValidationResult -Valid $false -Code "RECOVERY_INVALID" -Details @("Recovery values are malformed.")
    }
    $recoveryPaths = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
    foreach ($path in @($State.recovery.dirty_paths)) {
      if (-not (Test-DanioRepoPath -Value $path) -or -not $recoveryPaths.Add([string]$path)) {
        return New-DanioValidationResult -Valid $false -Code "RECOVERY_INVALID" -Details @("Recovery dirty path is unsafe.")
      }
    }
    $recoveryProcesses = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
    foreach ($entry in @($State.recovery.relevant_processes)) {
      if (
        $entry -isnot [string] -or
        [string]::IsNullOrWhiteSpace($entry) -or
        -not $recoveryProcesses.Add([string]$entry)
      ) {
        return New-DanioValidationResult -Valid $false -Code "RECOVERY_INVALID" -Details @("Recovery process entry is invalid or duplicated.")
      }
    }
    foreach ($entry in @($State.recovery.commands)) {
      if ($entry -isnot [string] -or [string]::IsNullOrWhiteSpace($entry)) {
        return New-DanioValidationResult -Valid $false -Code "RECOVERY_INVALID" -Details @("Recovery process or command entry is invalid.")
      }
    }
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
      -not (Test-DanioInteger -Value $State.transition.parent_state_revision) -or
      [int64]$State.transition.parent_state_revision -lt 0 -or
      -not (Test-DanioStrictUtc -Value $State.transition.occurred_at_utc) -or
      (
        $null -ne $State.transition.work_unit_id -and
        -not (Test-DanioSafeIdentifier -Value $State.transition.work_unit_id)
      ) -or
      (
        $null -ne $State.transition.reason_code -and
        -not (Test-DanioReasonCode -Value $State.transition.reason_code)
      )
    ) {
      return New-DanioValidationResult -Valid $false -Code "STATE_TRANSITION_INVALID" -Details @("Transition field types are invalid.")
    }
    if (
      [string]$State.transition.to_mode -cne $mode -or
      [int64]$State.transition.parent_state_revision -ne ([int64]$State.state_revision - 1)
    ) {
      return New-DanioValidationResult -Valid $false -Code "STATE_TRANSITION_INVALID" -Details @("Transition metadata does not match state revision/mode.")
    }
    if ($null -ne $State.last_verified_checkpoint) {
      $checkpointTime = [DateTimeOffset]::ParseExact(
        [string]$State.last_verified_checkpoint.verified_at_utc,
        "yyyy-MM-dd'T'HH:mm:ss.fffffff'Z'",
        [Globalization.CultureInfo]::InvariantCulture,
        [Globalization.DateTimeStyles]::AssumeUniversal -bor [Globalization.DateTimeStyles]::AdjustToUniversal
      )
      $transitionTime = [DateTimeOffset]::ParseExact(
        [string]$State.transition.occurred_at_utc,
        "yyyy-MM-dd'T'HH:mm:ss.fffffff'Z'",
        [Globalization.CultureInfo]::InvariantCulture,
        [Globalization.DateTimeStyles]::AssumeUniversal -bor [Globalization.DateTimeStyles]::AdjustToUniversal
      )
      if ($checkpointTime -gt $transitionTime) {
        return New-DanioValidationResult -Valid $false -Code "VERIFIED_CHECKPOINT_INVALID" -Details @("Verified checkpoint cannot be later than its containing transition.")
      }
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
  if ($State.control_surface_sync.figma_node_ids -isnot [System.Array]) {
    return New-DanioValidationResult -Valid $false -Code "CONTROL_SURFACE_INVALID" -Details @("Control-surface node IDs must be an array.")
  }
  $controlNodeIds = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
  foreach ($nodeId in @($State.control_surface_sync.figma_node_ids)) {
    if (
      $nodeId -isnot [string] -or
      [string]::IsNullOrWhiteSpace($nodeId) -or
      -not $controlNodeIds.Add([string]$nodeId)
    ) {
      return New-DanioValidationResult -Valid $false -Code "CONTROL_SURFACE_INVALID" -Details @("Control-surface node ID is invalid.")
    }
  }
  $controlStatus = [string]$State.control_surface_sync.status
  $controlHasOutcomeIdentity = (
    $State.control_surface_sync.figma_file_id -is [string] -and
    -not [string]::IsNullOrWhiteSpace([string]$State.control_surface_sync.figma_file_id) -and
    @($State.control_surface_sync.figma_node_ids).Count -gt 0 -and
    (Test-DanioStrictUtc -Value $State.control_surface_sync.attempted_at_utc)
  )
  switch ($controlStatus) {
    "not_required" {
      if (
        $null -ne $State.control_surface_sync.target_commit -or
        $null -ne $State.control_surface_sync.figma_file_id -or
        @($State.control_surface_sync.figma_node_ids).Count -ne 0 -or
        $null -ne $State.control_surface_sync.attempted_at_utc -or
        $null -ne $State.control_surface_sync.evidence_sha256 -or
        $null -ne $State.control_surface_sync.failure_code
      ) {
        return New-DanioValidationResult -Valid $false -Code "CONTROL_SURFACE_INVALID" -Details @("not_required control-surface state must use null/empty metadata.")
      }
    }
    "pending" {
      if (
        -not (Test-DanioGitOid -Value $State.control_surface_sync.target_commit) -or
        $null -ne $State.control_surface_sync.figma_file_id -or
        @($State.control_surface_sync.figma_node_ids).Count -ne 0 -or
        $null -ne $State.control_surface_sync.attempted_at_utc -or
        $null -ne $State.control_surface_sync.evidence_sha256 -or
        $null -ne $State.control_surface_sync.failure_code
      ) {
        return New-DanioValidationResult -Valid $false -Code "CONTROL_SURFACE_INVALID" -Details @("pending control-surface state is malformed.")
      }
    }
    "synced" {
      if (
        -not (Test-DanioGitOid -Value $State.control_surface_sync.target_commit) -or
        -not $controlHasOutcomeIdentity -or
        -not (Test-DanioSha256 -Value $State.control_surface_sync.evidence_sha256) -or
        $null -ne $State.control_surface_sync.failure_code
      ) {
        return New-DanioValidationResult -Valid $false -Code "CONTROL_SURFACE_INVALID" -Details @("synced control-surface evidence is malformed.")
      }
    }
    "failed" {
      if (
        -not (Test-DanioGitOid -Value $State.control_surface_sync.target_commit) -or
        -not $controlHasOutcomeIdentity -or
        $null -ne $State.control_surface_sync.evidence_sha256 -or
        -not (Test-DanioReasonCode -Value $State.control_surface_sync.failure_code)
      ) {
        return New-DanioValidationResult -Valid $false -Code "CONTROL_SURFACE_INVALID" -Details @("failed control-surface evidence is malformed.")
      }
    }
  }

  if ($null -ne $State.stop_reason_code -and -not (Test-DanioReasonCode -Value $State.stop_reason_code)) {
    return New-DanioValidationResult -Valid $false -Code "STOP_REASON_INVALID" -Details @("Stop reason is malformed.")
  }
  if ($mode -ceq "stopped") {
    if ($null -eq $State.stop_reason_code) {
      return New-DanioValidationResult -Valid $false -Code "STOP_REASON_REQUIRED" -Details @("Durable stopped mode requires a stop reason.")
    }
    if ([string]$State.transition.reason_code -cne [string]$State.stop_reason_code) {
      return New-DanioValidationResult -Valid $false -Code "STOP_REASON_INVALID" -Details @("Stopped state and transition reasons must agree.")
    }
    if ([string]$State.transition.action -ceq "finalization_stop" -and $null -eq $State.recovery) {
      return New-DanioValidationResult -Valid $false -Code "RECOVERY_REQUIRED" -Details @("Finalization stop requires exact recovery evidence.")
    }
  }

  return New-DanioValidationResult -Valid $true -Code "STATE_VALID"
}

function Test-DanioRunStateTransition {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][AllowNull()]$PreviousState,
    [Parameter(Mandatory = $true)][AllowNull()]$CandidateState,
    $LeaseRelease = $null,
    [object[]]$LedgerRows = @(),
    [string[]]$ActivePhaseLedgerIds = @()
  )

  $previousValidation = Test-DanioRunState -State $PreviousState
  if (-not $previousValidation.valid) {
    return New-DanioValidationResult `
      -Valid $false `
      -Code "PREVIOUS_STATE_INVALID" `
      -Details @("$($previousValidation.code): $($previousValidation.details -join '; ')")
  }

  $candidateRootFields = @(
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
  $candidateRootSet = Test-DanioExactPropertySet `
    -Value $CandidateState `
    -Allowed $candidateRootFields `
    -Required $candidateRootFields
  if (-not $candidateRootSet.valid) {
    return New-DanioValidationResult -Valid $false -Code "CANDIDATE_STATE_INVALID" -Details @("Candidate state fields are missing or unknown.")
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
  $transitionFields = @(
    "action",
    "from_mode",
    "to_mode",
    "parent_state_revision",
    "work_unit_id",
    "reason_code",
    "occurred_at_utc"
  )
  $candidateTransitionSet = Test-DanioExactPropertySet `
    -Value $CandidateState.transition `
    -Allowed $transitionFields `
    -Required $transitionFields
  if (-not $candidateTransitionSet.valid) {
    return New-DanioValidationResult -Valid $false -Code "STATE_TRANSITION_INVALID" -Details @("Candidate transition fields are missing or unknown.")
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
    -not (Test-DanioInteger -Value $CandidateState.transition.parent_state_revision) -or
    [int64]$CandidateState.transition.parent_state_revision -ne [int64]$PreviousState.state_revision
  ) {
    return New-DanioValidationResult -Valid $false -Code "STATE_TRANSITION_INVALID" -Details @("Transition parent/mode metadata is invalid.")
  }
  if ([string]$CandidateState.transition.work_unit_id -cne [string]$PreviousState.cursor.work_unit_id) {
    return New-DanioValidationResult -Valid $false -Code "WORK_UNIT_ATTRIBUTION_INVALID" -Details @("Transition must name the previously authorized work unit.")
  }

  $candidateValidation = Test-DanioRunState -State $CandidateState
  if (-not $candidateValidation.valid) {
    return New-DanioValidationResult `
      -Valid $false `
      -Code $candidateValidation.code `
      -Details $candidateValidation.details
  }

  if (@("closeout", "pause", "stop", "complete", "finalization_stop") -ccontains $expectedAction) {
    $releaseFields = @(
      "owner_token",
      "writer_released",
      "worktree_released",
      "android_released",
      "processes_released"
    )
    $releaseSet = Test-DanioExactPropertySet `
      -Value $LeaseRelease `
      -Allowed $releaseFields `
      -Required $releaseFields
    if (
      -not $releaseSet.valid -or
      $null -eq $PreviousState.owner -or
      [string]$LeaseRelease.owner_token -cne [string]$PreviousState.owner.token_sha256 -or
      -not (Test-DanioBoolean -Value $LeaseRelease.writer_released) -or
      -not (Test-DanioBoolean -Value $LeaseRelease.worktree_released) -or
      -not (Test-DanioBoolean -Value $LeaseRelease.android_released) -or
      -not (Test-DanioBoolean -Value $LeaseRelease.processes_released) -or
      -not $LeaseRelease.writer_released -or
      -not $LeaseRelease.worktree_released -or
      -not $LeaseRelease.android_released -or
      -not $LeaseRelease.processes_released
    ) {
      return New-DanioValidationResult `
        -Valid $false `
        -Code "STOP_PENDING" `
        -Details @("Writer, worktree, Android, and process lease release must be proven for the exact owner token.")
    }
  }

  if ($expectedAction -ceq "finalize") {
    if (
      [string]$PreviousState.cursor.work_unit_id -cnotmatch '^DCL-RC-001(?:-|$)' -or
      @($PreviousState.cursor.ledger_row_ids).Count -ne 1 -or
      [string]$PreviousState.cursor.ledger_row_ids[0] -cne "DCL-RC-001"
    ) {
      return New-DanioValidationResult -Valid $false -Code "FINALIZATION_SCOPE_INVALID" -Details @("Only the DCL-RC-001 work unit may enter finalization.")
    }
    $finalizationScope = Test-DanioActiveScope `
      -Rows $LedgerRows `
      -ActivePhaseLedgerIds $ActivePhaseLedgerIds `
      -RequireNonReleaseCandidateClosed
    if (-not $finalizationScope.valid) {
      return New-DanioValidationResult -Valid $false -Code "FINALIZATION_SCOPE_INVALID" -Details $finalizationScope.details
    }
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
      $previousClaimScope = [ordered]@{
        run_id = $PreviousState.run_id
        authority = $PreviousState.authority
        authorization = $PreviousState.authorization
        cursor = $PreviousState.cursor
        handoff_generation = $PreviousState.handoff_generation
        last_verified_checkpoint = $PreviousState.last_verified_checkpoint
        repeated_failure = $PreviousState.repeated_failure
        stop_reason_code = $PreviousState.stop_reason_code
        recovery = $PreviousState.recovery
        control_surface_sync = $PreviousState.control_surface_sync
      }
      $candidateClaimScope = [ordered]@{
        run_id = $CandidateState.run_id
        authority = $CandidateState.authority
        authorization = $CandidateState.authorization
        cursor = $CandidateState.cursor
        handoff_generation = $CandidateState.handoff_generation
        last_verified_checkpoint = $CandidateState.last_verified_checkpoint
        repeated_failure = $CandidateState.repeated_failure
        stop_reason_code = $CandidateState.stop_reason_code
        recovery = $CandidateState.recovery
        control_surface_sync = $CandidateState.control_surface_sync
      }
      if (
        (ConvertTo-DanioCanonicalJson -Value $candidateClaimScope) -cne
          (ConvertTo-DanioCanonicalJson -Value $previousClaimScope)
      ) {
        return New-DanioValidationResult -Valid $false -Code "CLAIM_SCOPE_INVALID" -Details @("Claim cannot replace committed run, authority, authorization, cursor, generation, or control identity.")
      }
      if ([int64]$previousBudget.remaining_units_including_current -le 0) {
        return New-DanioValidationResult -Valid $false -Code "BUDGET_EXHAUSTED" -Details @("A writer claim requires positive remaining budget.")
      }
      if (
        -not $budgetUnchanged -or
        [string]$candidateBudget.current_charge.status -cne "pending" -or
        $null -eq $CandidateState.owner -or
        [string]$CandidateState.cursor.work_unit_id -cne [string]$PreviousState.cursor.work_unit_id -or
        [string]$candidateBudget.current_charge.work_unit_id -cne [string]$PreviousState.cursor.work_unit_id -or
        [int64]$candidateBudget.current_charge.claimed_revision -ne [int64]$PreviousState.state_revision -or
        [int64]$CandidateState.owner.claim_revision -ne [int64]$PreviousState.state_revision
      ) {
        return New-DanioValidationResult -Valid $false -Code "OWNER_REVISION_INVALID" -Details @("Claim must bind owner, charge, cursor, and token input to the exact parent revision and work unit.")
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
        [string]$previousBudget.current_charge.work_unit_id -cne [string]$PreviousState.cursor.work_unit_id -or
        [string]$candidateBudget.current_charge.work_unit_id -cne [string]$PreviousState.cursor.work_unit_id -or
        [int64]$candidateBudget.current_charge.claimed_revision -ne [int64]$previousBudget.current_charge.claimed_revision
      ) {
        return New-DanioValidationResult -Valid $false -Code "WORK_UNIT_ATTRIBUTION_INVALID" -Details @("Consumed charge must belong to the previously owned work unit.")
      }
      if (
        $expectedAction -ceq "closeout" -and
        [int64]$candidateBudget.remaining_units_including_current -le 0
      ) {
        return New-DanioValidationResult -Valid $false -Code "BUDGET_EXHAUSTED" -Details @("Zero post-closeout budget requires durable stop without handoff.")
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
      if (
        [string]$candidateBudget.current_charge.work_unit_id -cne [string]$PreviousState.cursor.work_unit_id -or
        [string]$previousBudget.current_charge.work_unit_id -cne [string]$PreviousState.cursor.work_unit_id
      ) {
        return New-DanioValidationResult -Valid $false -Code "WORK_UNIT_ATTRIBUTION_INVALID" -Details @("Finalization exit changed work-unit attribution.")
      }
      if (
        $expectedAction -ceq "complete" -and
        (ConvertTo-DanioCanonicalJson -Value $CandidateState.last_verified_checkpoint) -ceq
          (ConvertTo-DanioCanonicalJson -Value $PreviousState.last_verified_checkpoint)
      ) {
        return New-DanioValidationResult -Valid $false -Code "VERIFIED_CHECKPOINT_INVALID" -Details @("Terminal completion must advance from candidate-parent proof to final evidence.")
      }
    }
    "resume" {
      $approvedIncrease = [int64]$candidateBudget.total_approved_units - [int64]$previousBudget.total_approved_units
      if (
        $approvedIncrease -lt 0 -or
        [int64]$candidateBudget.consumed_units -ne [int64]$previousBudget.consumed_units -or
        [int64]$candidateBudget.remaining_units_including_current -ne
          ([int64]$previousBudget.remaining_units_including_current + $approvedIncrease) -or
        (ConvertTo-DanioCanonicalJson -Value $candidateBudget.current_charge) -cne
          (ConvertTo-DanioCanonicalJson -Value $previousBudget.current_charge) -or
        (
          $approvedIncrease -gt 0 -and
          (
            [string]$CandidateState.authorization.authorization_id -ceq [string]$PreviousState.authorization.authorization_id -or
            [string]$CandidateState.authorization.authorized_at_utc -ceq [string]$PreviousState.authorization.authorized_at_utc
          )
        )
      ) {
        return New-DanioValidationResult -Valid $false -Code "RESUME_BUDGET_INVALID" -Details @("Resume may only preserve budget or add explicitly approved units without changing prior consumption.")
      }
      if ([int64]$candidateBudget.remaining_units_including_current -le 0) {
        return New-DanioValidationResult -Valid $false -Code "BUDGET_EXHAUSTED" -Details @("Resume requires positive remaining or newly approved budget.")
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
    [Parameter(Mandatory = $true)][AllowNull()]$State,
    [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]]$LedgerRows,
    [Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$ActivePhaseLedgerIds,
    [Parameter(Mandatory = $true)][AllowNull()]$Evidence,
    [Parameter(Mandatory = $true)][AllowNull()]$Cleanup,
    [Parameter(Mandatory = $true)][AllowNull()]$RepositoryObservation
  )

  $details = New-Object System.Collections.Generic.List[string]
  $stateIsValid = $false
  try {
    $stateValidation = Test-DanioRunState -State $State
    $stateIsValid = [bool]$stateValidation.valid
    if (-not $stateIsValid) {
      $details.Add("State: $($stateValidation.code).")
    }
  } catch {
    $details.Add("State validation rejected malformed input.")
  }
  if ($stateIsValid) {
    if ([string]$State.mode -cne "finalizing") {
      $details.Add("Candidate parent mode must be finalizing.")
    }
    if ($null -eq $State.owner) {
      $details.Add("Finalizing owner token is missing.")
    }
  }

  try {
    $activeScope = Test-DanioActiveScope `
      -Rows $LedgerRows `
      -ActivePhaseLedgerIds $ActivePhaseLedgerIds `
      -RequireAllClosed
    if (-not $activeScope.valid) {
      $details.Add("Ledger: $($activeScope.code).")
    }
  } catch {
    $details.Add("Ledger validation rejected malformed input.")
  }

  $evidenceFields = @("product_commit", "manifest_path", "checkpoint_commit", "checks")
  $evidenceSet = Test-DanioExactPropertySet -Value $Evidence -Allowed $evidenceFields -Required $evidenceFields
  $evidenceIsValid = $evidenceSet.valid
  if (
    -not $evidenceIsValid -or
    -not (Test-DanioGitOid -Value $Evidence.product_commit) -or
    -not (Test-DanioRepoPath -Value $Evidence.manifest_path) -or
    -not (Test-DanioGitOid -Value $Evidence.checkpoint_commit) -or
    $Evidence.checks -isnot [System.Array] -or
    [string]$Evidence.manifest_path -cne
      "apps/aquarium_app/docs/agent/autonomous_completion/evidence/$($Evidence.product_commit).json"
  ) {
    $evidenceIsValid = $false
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
    $seenEvidenceCodes = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
    foreach ($check in @($Evidence.checks)) {
      $checkFields = @("code", "status", "product_commit")
      $checkSet = Test-DanioExactPropertySet -Value $check -Allowed $checkFields -Required $checkFields
      if (
        -not $checkSet.valid -or
        $requiredChecks -cnotcontains [string]$check.code -or
        -not $seenEvidenceCodes.Add([string]$check.code) -or
        [string]$check.status -cne "pass" -or
        -not (Test-DanioGitOid -Value $check.product_commit) -or
        [string]$check.product_commit -cne [string]$Evidence.product_commit
      ) {
        $evidenceIsValid = $false
        $details.Add("Evidence check is malformed, duplicated, stale, or failed.")
      }
    }
    foreach ($code in $requiredChecks) {
      if (-not $seenEvidenceCodes.Contains($code)) {
        $evidenceIsValid = $false
        $details.Add("Evidence '$code' must appear exactly once.")
      }
    }
  }

  if ($stateIsValid -and $evidenceIsValid) {
    $priorFinalizingCommit = [string]$State.last_verified_checkpoint.product_commit
    $finalProductCommit = [string]$Evidence.product_commit
    $evidenceLedgerParentCommit = [string]$Evidence.checkpoint_commit
    if (
      $priorFinalizingCommit -ceq $finalProductCommit -or
      $finalProductCommit -ceq $evidenceLedgerParentCommit -or
      $priorFinalizingCommit -ceq $evidenceLedgerParentCommit
    ) {
      $details.Add("Prior finalizing, final product, and evidence-ledger parent commits must be pairwise distinct.")
    }
  }

  if ($evidenceIsValid) {
    $releaseCandidate = $LedgerRows | Where-Object { $_.Id -ceq "DCL-RC-001" } | Select-Object -First 1
    $releaseCandidateFields = if ($null -eq $releaseCandidate) {
      @()
    } else {
      @($releaseCandidate.PSObject.Properties | ForEach-Object { $_.Name })
    }
    if (
      $null -eq $releaseCandidate -or
      $releaseCandidateFields -cnotcontains "Evidence" -or
      [string]$releaseCandidate.ClosureState -cne "closed" -or
      (
        [string]$releaseCandidate.Evidence -cnotlike "*$($Evidence.product_commit)*" -and
        [string]$releaseCandidate.Evidence -cnotlike "*$($Evidence.manifest_path)*"
      )
    ) {
      $details.Add("DCL-RC-001 is not closed by the final evidence checkpoint.")
    }
  }

  $repositoryFields = @("parent_commit", "origin_main_commit", "ahead", "behind", "clean")
  $repositorySet = Test-DanioExactPropertySet `
    -Value $RepositoryObservation `
    -Allowed $repositoryFields `
    -Required $repositoryFields
  if (
    -not $repositorySet.valid -or
    -not (Test-DanioGitOid -Value $RepositoryObservation.parent_commit) -or
    -not (Test-DanioGitOid -Value $RepositoryObservation.origin_main_commit) -or
    -not (Test-DanioInteger -Value $RepositoryObservation.ahead) -or
    -not (Test-DanioInteger -Value $RepositoryObservation.behind) -or
    -not (Test-DanioBoolean -Value $RepositoryObservation.clean)
  ) {
    $details.Add("Repository observation fields are missing or unknown.")
  } elseif (
    -not $RepositoryObservation.clean -or
    [int64]$RepositoryObservation.ahead -ne 0 -or
    [int64]$RepositoryObservation.behind -ne 0 -or
    [string]$RepositoryObservation.parent_commit -cne [string]$RepositoryObservation.origin_main_commit -or
    -not $evidenceIsValid -or
    [string]$RepositoryObservation.parent_commit -cne [string]$Evidence.checkpoint_commit
  ) {
    $details.Add("Repository parent checkpoint is not clean and aligned with evidence.")
  }

  $cleanupFields = @(
    "owner_token",
    "branch_name",
    "worktree_id",
    "worktree_path",
    "branch_removed",
    "worktree_removed",
    "device_released"
  )
  $cleanupSet = Test-DanioExactPropertySet -Value $Cleanup -Allowed $cleanupFields -Required $cleanupFields
  if (
    -not $cleanupSet.valid -or
    -not (Test-DanioSha256 -Value $Cleanup.owner_token) -or
    $Cleanup.branch_name -isnot [string] -or
    -not (Test-DanioSafeIdentifier -Value $Cleanup.worktree_id) -or
    -not (Test-DanioAbsoluteWindowsPath -Value $Cleanup.worktree_path) -or
    -not (Test-DanioBoolean -Value $Cleanup.branch_removed) -or
    -not (Test-DanioBoolean -Value $Cleanup.worktree_removed) -or
    -not (Test-DanioBoolean -Value $Cleanup.device_released)
  ) {
    $details.Add("Cleanup fields are missing or unknown.")
  } elseif (
    -not $stateIsValid -or
    $null -eq $State.owner -or
    [string]$Cleanup.owner_token -cne [string]$State.owner.token_sha256 -or
    [string]$Cleanup.branch_name -cne [string]$State.owner.branch_name -or
    [string]$Cleanup.worktree_id -cne [string]$State.owner.worktree_id -or
    [string]$Cleanup.worktree_path -cne [string]$State.owner.worktree_path -or
    -not $Cleanup.branch_removed -or
    -not $Cleanup.worktree_removed -or
    -not $Cleanup.device_released
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
