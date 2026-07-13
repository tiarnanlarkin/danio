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

$script:DanioRunStatePath = "apps/aquarium_app/docs/agent/autonomous_completion/phone_completion_run_state.json"

$script:DanioAuthorityPaths = [ordered]@{
  phone_completion_program = "apps/aquarium_app/docs/agent/plans/2026-07-11-phone-complete-local-completion-program.md"
  closure_ledger = "apps/aquarium_app/docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md"
  finish_map = "apps/aquarium_app/docs/agent/FINISH_MAP.md"
  quality_ladder = "apps/aquarium_app/docs/agent/QUALITY_LADDER.md"
  verified_slice_execution_contract = "apps/aquarium_app/docs/agent/VERIFIED_SLICE_EXECUTION_CONTRACT.md"
  active_handoff = "apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md"
  device_ownership_policy = "apps/aquarium_app/docs/agent/DEVICE_OWNERSHIP.md"
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

function Test-DanioExactString {
  [CmdletBinding()]
  param(
    $Value,
    [Parameter(Mandatory = $true)][string]$Expected
  )

  return $Value -is [string] -and $Value -ceq $Expected
}

function Test-DanioExactStringSequence {
  [CmdletBinding()]
  param(
    $Value,
    [Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$Expected
  )

  if ($Value -isnot [System.Array]) {
    return $false
  }

  $actual = @($Value)
  if ($actual.Count -ne $Expected.Count) {
    return $false
  }

  for ($index = 0; $index -lt $Expected.Count; $index += 1) {
    if ($actual[$index] -isnot [string] -or $actual[$index] -cne $Expected[$index]) {
      return $false
    }
  }

  return $true
}

function Resolve-DanioPinnedInstallFile {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$InstallRoot,
    [Parameter(Mandatory = $true)][string]$RelativePath
  )

  if (
    -not [IO.Path]::IsPathRooted($InstallRoot) -or
    -not (Test-DanioRepoPath -Value $RelativePath)
  ) {
    return $null
  }

  try {
    $resolvedRoot = [IO.Path]::GetFullPath((Resolve-Path -LiteralPath $InstallRoot -ErrorAction Stop).Path)
    $resolvedRoot = $resolvedRoot.TrimEnd(
      [IO.Path]::DirectorySeparatorChar,
      [IO.Path]::AltDirectorySeparatorChar
    )
    $nativeRelativePath = $RelativePath.Replace(
      "/",
      [string][IO.Path]::DirectorySeparatorChar
    )
    $candidate = [IO.Path]::GetFullPath((Join-Path $resolvedRoot $nativeRelativePath))
    $cursor = $resolvedRoot
    foreach ($segment in @($nativeRelativePath.Split([IO.Path]::DirectorySeparatorChar))) {
      if ([string]::IsNullOrWhiteSpace($segment)) {
        return $null
      }
      $cursor = Join-Path $cursor $segment
      $item = Get-Item -LiteralPath $cursor -Force -ErrorAction Stop
      if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
        return $null
      }
    }
    $resolvedCandidate = [IO.Path]::GetFullPath(
      (Resolve-Path -LiteralPath $candidate -ErrorAction Stop).Path
    )
    $requiredPrefix = $resolvedRoot + [IO.Path]::DirectorySeparatorChar
    if (
      -not $resolvedCandidate.StartsWith(
        $requiredPrefix,
        [StringComparison]::OrdinalIgnoreCase
      ) -or
      -not (Test-Path -LiteralPath $resolvedCandidate -PathType Leaf)
    ) {
      return $null
    }

    return $resolvedCandidate
  }
  catch {
    return $null
  }
}

function Test-DanioSkillFrontmatter {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$ExpectedName
  )

  try {
    $lines = [IO.File]::ReadAllLines($Path)
  }
  catch {
    return $false
  }

  if ($lines.Count -lt 4 -or $lines[0] -cne "---") {
    return $false
  }

  $closingIndex = -1
  for ($index = 1; $index -lt $lines.Count; $index += 1) {
    if ($lines[$index] -ceq "---") {
      $closingIndex = $index
      break
    }
  }
  if ($closingIndex -lt 3) {
    return $false
  }

  $keys = @()
  $nameValue = $null
  $descriptionValue = $null
  for ($index = 1; $index -lt $closingIndex; $index += 1) {
    $line = $lines[$index]
    if ($line -cnotmatch '^([A-Za-z0-9_-]+):\s+(.+)$') {
      return $false
    }
    $key = $Matches[1]
    if ($keys -ccontains $key) {
      return $false
    }
    $keys += $key
    if ($key -ceq "name") {
      $nameValue = $Matches[2]
    }
    elseif ($key -ceq "description") {
      $descriptionValue = $Matches[2]
    }
  }

  return (
    $keys.Count -eq 2 -and
    ($keys -ccontains "name") -and
    ($keys -ccontains "description") -and
    $nameValue -ceq $ExpectedName -and
    -not [string]::IsNullOrWhiteSpace([string]$descriptionValue)
  )
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
  param([Parameter(Mandatory = $true)][AllowNull()]$Value)

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

  $authorityFields = @($script:DanioAuthorityPaths.Keys)
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
    if (
      -not (Test-DanioRepoPath -Value $reference.path) -or
      [string]$reference.path -cne [string]$script:DanioAuthorityPaths[$field]
    ) {
      return New-DanioValidationResult -Valid $false -Code "AUTHORITY_INVALID" -Details @("Authority '$field' path is not canonical.")
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

function New-DanioEvidenceValidationResult {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][bool]$Valid,
    [Parameter(Mandatory = $true)][string]$Code,
    [object[]]$Details = @(),
    [AllowNull()]$Evidence = $null
  )

  return [pscustomobject]@{
    valid = $Valid
    code = $Code
    details = @($Details)
    evidence = $Evidence
  }
}

function Test-DanioEvidenceManifest {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][AllowNull()]$Manifest,
    [Parameter(Mandatory = $true)][AllowEmptyString()][string]$ManifestPath,
    [Parameter(Mandatory = $true)][AllowNull()]$PreviousState,
    [Parameter(Mandatory = $true)][AllowNull()]$CandidateState,
    [Parameter(Mandatory = $true)][string]$ParentCommit,
    [AllowEmptyCollection()][object[]]$ArtifactObservations = @(),
    [AllowNull()]$RecoveryObservation = $null
  )

  if (-not (Test-DanioGitOid -Value $ParentCommit)) {
    return New-DanioEvidenceValidationResult `
      -Valid $false `
      -Code "EVIDENCE_MANIFEST_INVALID" `
      -Details @("Evidence parent commit is malformed.")
  }
  if ($null -eq $PreviousState -or $null -eq $CandidateState -or $null -eq $CandidateState.transition) {
    return New-DanioEvidenceValidationResult `
      -Valid $false `
      -Code "EVIDENCE_MANIFEST_INVALID" `
      -Details @("Evidence transition state is missing.")
  }

  $action = [string]$CandidateState.transition.action
  $supportedActions = @("closeout", "pause", "stop", "finalize", "complete", "finalization_stop")
  if ($supportedActions -cnotcontains $action) {
    return New-DanioEvidenceValidationResult `
      -Valid $false `
      -Code "EVIDENCE_MANIFEST_INVALID" `
      -Details @("Transition '$action' does not carry Task 9 evidence.")
  }

  $previousCheckpoint = $PreviousState.last_verified_checkpoint
  $candidateCheckpoint = $CandidateState.last_verified_checkpoint
  $isBudgetCloseoutStop = (
    $action -ceq "stop" -and
    [string]$CandidateState.transition.reason_code -ceq "BUDGET_EXHAUSTED" -and
    [int64]$CandidateState.budget.remaining_units_including_current -eq 0
  )
  $nullManifestStop = (
    $action -ceq "stop" -and
    -not $isBudgetCloseoutStop -and
    $null -eq $previousCheckpoint -and
    $null -eq $candidateCheckpoint
  )
  if ($nullManifestStop) {
    if ($null -ne $Manifest -or -not [string]::IsNullOrWhiteSpace($ManifestPath)) {
      return New-DanioEvidenceValidationResult `
        -Valid $false `
        -Code "EVIDENCE_MANIFEST_INVALID" `
        -Details @("An emergency stop without historical evidence must not name a manifest.")
    }
    $recoveryFields = @("last_clean_commit", "reachable_from_parent")
    $recoverySet = Test-DanioExactPropertySet `
      -Value $RecoveryObservation `
      -Allowed $recoveryFields `
      -Required $recoveryFields
    if (
      $null -eq $CandidateState.recovery -or
      -not $recoverySet.valid -or
      -not (Test-DanioGitOid -Value $RecoveryObservation.last_clean_commit) -or
      -not (Test-DanioBoolean -Value $RecoveryObservation.reachable_from_parent) -or
      -not $RecoveryObservation.reachable_from_parent -or
      [string]$RecoveryObservation.last_clean_commit -cne [string]$CandidateState.recovery.last_clean_commit
    ) {
      return New-DanioEvidenceValidationResult `
        -Valid $false `
        -Code "EVIDENCE_MANIFEST_INVALID" `
        -Details @("Emergency stop recovery is not reachable from the parent checkpoint.")
    }
    return New-DanioEvidenceValidationResult `
      -Valid $true `
      -Code "EVIDENCE_MANIFEST_VALID" `
      -Evidence $null
  }

  if ($null -eq $Manifest -or [string]::IsNullOrWhiteSpace($ManifestPath)) {
    return New-DanioEvidenceValidationResult `
      -Valid $false `
      -Code "EVIDENCE_MANIFEST_REQUIRED" `
      -Details @("Transition '$action' requires committed evidence.")
  }

  $manifestFields = @(
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
  $manifestSet = Test-DanioExactPropertySet `
    -Value $Manifest `
    -Allowed $manifestFields `
    -Required $manifestFields
  if (
    -not $manifestSet.valid -or
    -not (Test-DanioInteger -Value $Manifest.schema_version) -or
    [int64]$Manifest.schema_version -ne 1 -or
    -not (Test-DanioGitOid -Value $Manifest.product_commit) -or
    -not (Test-DanioSafeIdentifier -Value $Manifest.work_unit_id) -or
    $Manifest.ledger_row_ids -isnot [System.Array] -or
    $Manifest.commands -isnot [System.Array] -or
    $Manifest.artifacts -isnot [System.Array] -or
    $Manifest.checks -isnot [System.Array] -or
    [string]$Manifest.overall_status -cne "pass" -or
    -not (Test-DanioRepoPath -Value $ManifestPath)
  ) {
    return New-DanioEvidenceValidationResult `
      -Valid $false `
      -Code "EVIDENCE_MANIFEST_INVALID" `
      -Details @("Evidence manifest fields are missing, unknown, or malformed.")
  }

  $expectedManifestPath = "apps/aquarium_app/docs/agent/autonomous_completion/evidence/$($Manifest.product_commit).json"
  if ([string]$ManifestPath -cne $expectedManifestPath) {
    return New-DanioEvidenceValidationResult `
      -Valid $false `
      -Code "EVIDENCE_MANIFEST_INVALID" `
      -Details @("Evidence manifest filename does not match product commit.")
  }

  $isNewCheckpoint = (
    @("closeout", "pause", "complete") -ccontains $action -or
    $isBudgetCloseoutStop
  )
  $isHistoricalCheckpoint = (
    @("finalize", "finalization_stop") -ccontains $action -or
    ($action -ceq "stop" -and -not $isBudgetCloseoutStop)
  )
  if ($isNewCheckpoint) {
    if (
      $null -eq $candidateCheckpoint -or
      [string]$candidateCheckpoint.product_commit -cne [string]$Manifest.product_commit -or
      [string]$candidateCheckpoint.evidence_manifest_path -cne $expectedManifestPath -or
      [string]$Manifest.work_unit_id -cne [string]$PreviousState.cursor.work_unit_id -or
      -not (Test-DanioExactStringSequence `
        -Value $Manifest.ledger_row_ids `
        -Expected @($PreviousState.cursor.ledger_row_ids))
    ) {
      return New-DanioEvidenceValidationResult `
        -Valid $false `
        -Code "EVIDENCE_MANIFEST_INVALID" `
        -Details @("New evidence is not bound to the owned cursor and candidate checkpoint.")
    }
    if (
      $null -ne $previousCheckpoint -and
      (
        [string]$candidateCheckpoint.product_commit -ceq [string]$previousCheckpoint.product_commit -or
        [string]$candidateCheckpoint.evidence_manifest_path -ceq [string]$previousCheckpoint.evidence_manifest_path
      )
    ) {
      return New-DanioEvidenceValidationResult `
        -Valid $false `
        -Code "EVIDENCE_MANIFEST_INVALID" `
        -Details @("New evidence must advance product and manifest identity.")
    }
  }
  elseif ($isHistoricalCheckpoint) {
    if (
      $null -eq $previousCheckpoint -or
      $null -eq $candidateCheckpoint -or
      (ConvertTo-DanioCanonicalJson -Value $candidateCheckpoint) -cne
        (ConvertTo-DanioCanonicalJson -Value $previousCheckpoint) -or
      [string]$previousCheckpoint.product_commit -cne [string]$Manifest.product_commit -or
      [string]$previousCheckpoint.evidence_manifest_path -cne $expectedManifestPath
    ) {
      return New-DanioEvidenceValidationResult `
        -Valid $false `
        -Code "EVIDENCE_MANIFEST_INVALID" `
        -Details @("Historical evidence checkpoint was missing, changed, or rebound.")
    }
    if (
      [string]$Manifest.work_unit_id -ceq [string]$PreviousState.cursor.work_unit_id -and
      (Test-DanioExactStringSequence `
        -Value $Manifest.ledger_row_ids `
        -Expected @($PreviousState.cursor.ledger_row_ids))
    ) {
      return New-DanioEvidenceValidationResult `
        -Valid $false `
        -Code "EVIDENCE_MANIFEST_INVALID" `
        -Details @("Historical evidence cannot be rebound to the currently owned cursor.")
    }
  }

  if (@("stop", "finalization_stop") -ccontains $action) {
    $recoveryFields = @("last_clean_commit", "reachable_from_parent")
    $recoverySet = Test-DanioExactPropertySet `
      -Value $RecoveryObservation `
      -Allowed $recoveryFields `
      -Required $recoveryFields
    if (
      $null -eq $CandidateState.recovery -or
      -not $recoverySet.valid -or
      -not (Test-DanioGitOid -Value $RecoveryObservation.last_clean_commit) -or
      -not (Test-DanioBoolean -Value $RecoveryObservation.reachable_from_parent) -or
      -not $RecoveryObservation.reachable_from_parent -or
      [string]$RecoveryObservation.last_clean_commit -cne
        [string]$CandidateState.recovery.last_clean_commit
    ) {
      return New-DanioEvidenceValidationResult `
        -Valid $false `
        -Code "EVIDENCE_MANIFEST_INVALID" `
        -Details @("Stop recovery commit is not exactly reachable from the parent checkpoint.")
    }
  }

  if (
    $null -eq $candidateCheckpoint -or
    -not (Test-DanioStrictUtc -Value $candidateCheckpoint.verified_at_utc) -or
    -not (Test-DanioStrictUtc -Value $CandidateState.transition.occurred_at_utc)
  ) {
    return New-DanioEvidenceValidationResult `
      -Valid $false `
      -Code "EVIDENCE_MANIFEST_INVALID" `
      -Details @("Evidence checkpoint chronology is malformed.")
  }
  $verifiedAt = [DateTimeOffset]::ParseExact(
    [string]$candidateCheckpoint.verified_at_utc,
    "yyyy-MM-dd'T'HH:mm:ss.fffffff'Z'",
    [Globalization.CultureInfo]::InvariantCulture,
    [Globalization.DateTimeStyles]::AssumeUniversal -bor [Globalization.DateTimeStyles]::AdjustToUniversal
  )
  $transitionedAt = [DateTimeOffset]::ParseExact(
    [string]$CandidateState.transition.occurred_at_utc,
    "yyyy-MM-dd'T'HH:mm:ss.fffffff'Z'",
    [Globalization.CultureInfo]::InvariantCulture,
    [Globalization.DateTimeStyles]::AssumeUniversal -bor [Globalization.DateTimeStyles]::AdjustToUniversal
  )
  if ($verifiedAt -gt $transitionedAt) {
    return New-DanioEvidenceValidationResult `
      -Valid $false `
      -Code "EVIDENCE_MANIFEST_INVALID" `
      -Details @("Evidence checkpoint occurs after the transition.")
  }
  $newEvidenceNotBefore = $null
  if ($isNewCheckpoint) {
    if (-not (Test-DanioStrictUtc -Value $PreviousState.transition.occurred_at_utc)) {
      return New-DanioEvidenceValidationResult `
        -Valid $false `
        -Code "EVIDENCE_MANIFEST_INVALID" `
        -Details @("Previous transition chronology is malformed.")
    }
    $newEvidenceNotBefore = [DateTimeOffset]::ParseExact(
      [string]$PreviousState.transition.occurred_at_utc,
      "yyyy-MM-dd'T'HH:mm:ss.fffffff'Z'",
      [Globalization.CultureInfo]::InvariantCulture,
      [Globalization.DateTimeStyles]::AssumeUniversal -bor [Globalization.DateTimeStyles]::AdjustToUniversal
    )
    if ($null -ne $previousCheckpoint) {
      $previousVerifiedAt = [DateTimeOffset]::ParseExact(
        [string]$previousCheckpoint.verified_at_utc,
        "yyyy-MM-dd'T'HH:mm:ss.fffffff'Z'",
        [Globalization.CultureInfo]::InvariantCulture,
        [Globalization.DateTimeStyles]::AssumeUniversal -bor [Globalization.DateTimeStyles]::AdjustToUniversal
      )
      if ($verifiedAt -lt $previousVerifiedAt) {
        return New-DanioEvidenceValidationResult `
          -Valid $false `
          -Code "EVIDENCE_MANIFEST_INVALID" `
          -Details @("A new checkpoint cannot regress verified chronology.")
      }
      if ($previousVerifiedAt -gt $newEvidenceNotBefore) {
        $newEvidenceNotBefore = $previousVerifiedAt
      }
    }
  }

  $ledgerIds = @($Manifest.ledger_row_ids)
  if ($ledgerIds.Count -lt 1) {
    return New-DanioEvidenceValidationResult `
      -Valid $false `
      -Code "EVIDENCE_MANIFEST_INVALID" `
      -Details @("Evidence must identify at least one ledger row.")
  }
  $seenLedgerIds = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
  foreach ($ledgerId in $ledgerIds) {
    if (
      $ledgerId -isnot [string] -or
      $ledgerId -cnotmatch '^DCL-[A-Z0-9]+-[0-9]{3}$' -or
      -not $seenLedgerIds.Add([string]$ledgerId)
    ) {
      return New-DanioEvidenceValidationResult `
        -Valid $false `
        -Code "EVIDENCE_MANIFEST_INVALID" `
        -Details @("Evidence ledger rows are malformed or duplicated.")
    }
  }

  $environmentFields = @("platform", "device_id")
  $environmentSet = Test-DanioExactPropertySet `
    -Value $Manifest.environment `
    -Allowed $environmentFields `
    -Required $environmentFields
  if (
    -not $environmentSet.valid -or
    [string]$Manifest.environment.platform -cne "windows" -or
    ($null -ne $Manifest.environment.device_id -and $Manifest.environment.device_id -isnot [string])
  ) {
    return New-DanioEvidenceValidationResult `
      -Valid $false `
      -Code "EVIDENCE_MANIFEST_INVALID" `
      -Details @("Evidence environment is malformed.")
  }

  $commands = @($Manifest.commands)
  if ($commands.Count -lt 1) {
    return New-DanioEvidenceValidationResult `
      -Valid $false `
      -Code "EVIDENCE_MANIFEST_INVALID" `
      -Details @("Evidence must contain at least one command.")
  }
  $commandFields = @("command", "exit_code", "started_at_utc", "completed_at_utc")
  foreach ($command in $commands) {
    $commandSet = Test-DanioExactPropertySet `
      -Value $command `
      -Allowed $commandFields `
      -Required $commandFields
    if (
      -not $commandSet.valid -or
      $command.command -isnot [string] -or
      [string]::IsNullOrWhiteSpace([string]$command.command) -or
      -not (Test-DanioInteger -Value $command.exit_code) -or
      [int64]$command.exit_code -ne 0 -or
      -not (Test-DanioStrictUtc -Value $command.started_at_utc) -or
      -not (Test-DanioStrictUtc -Value $command.completed_at_utc)
    ) {
      return New-DanioEvidenceValidationResult `
        -Valid $false `
        -Code "EVIDENCE_MANIFEST_INVALID" `
        -Details @("Evidence command is malformed or failed.")
    }
    $startedAt = [DateTimeOffset]::ParseExact(
      [string]$command.started_at_utc,
      "yyyy-MM-dd'T'HH:mm:ss.fffffff'Z'",
      [Globalization.CultureInfo]::InvariantCulture,
      [Globalization.DateTimeStyles]::AssumeUniversal -bor [Globalization.DateTimeStyles]::AdjustToUniversal
    )
    $completedAt = [DateTimeOffset]::ParseExact(
      [string]$command.completed_at_utc,
      "yyyy-MM-dd'T'HH:mm:ss.fffffff'Z'",
      [Globalization.CultureInfo]::InvariantCulture,
      [Globalization.DateTimeStyles]::AssumeUniversal -bor [Globalization.DateTimeStyles]::AdjustToUniversal
    )
    if (
      $startedAt -gt $completedAt -or
      $completedAt -gt $verifiedAt -or
      ($null -ne $newEvidenceNotBefore -and $startedAt -lt $newEvidenceNotBefore)
    ) {
      return New-DanioEvidenceValidationResult `
        -Valid $false `
        -Code "EVIDENCE_MANIFEST_INVALID" `
        -Details @("Evidence command interval is not chronological.")
    }
  }

  $artifacts = @($Manifest.artifacts)
  if ($ArtifactObservations.Count -ne $artifacts.Count) {
    return New-DanioEvidenceValidationResult `
      -Valid $false `
      -Code "EVIDENCE_MANIFEST_INVALID" `
      -Details @("Artifact observations do not match the manifest.")
  }
  $artifactFields = @("kind", "path", "sha256")
  $observationFields = @("path", "exists_at_product_commit", "sha256")
  $seenArtifactPaths = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
  foreach ($artifact in $artifacts) {
    $artifactSet = Test-DanioExactPropertySet `
      -Value $artifact `
      -Allowed $artifactFields `
      -Required $artifactFields
    if (
      -not $artifactSet.valid -or
      $artifact.kind -isnot [string] -or
      [string]::IsNullOrWhiteSpace([string]$artifact.kind) -or
      -not (Test-DanioRepoPath -Value $artifact.path) -or
      -not (Test-DanioSha256 -Value $artifact.sha256) -or
      -not $seenArtifactPaths.Add([string]$artifact.path)
    ) {
      return New-DanioEvidenceValidationResult `
        -Valid $false `
        -Code "EVIDENCE_MANIFEST_INVALID" `
        -Details @("Evidence artifact is malformed or duplicated.")
    }
    $matchingObservations = @(
      $ArtifactObservations | Where-Object { [string]$_.path -ceq [string]$artifact.path }
    )
    if ($matchingObservations.Count -ne 1) {
      return New-DanioEvidenceValidationResult `
        -Valid $false `
        -Code "EVIDENCE_MANIFEST_INVALID" `
        -Details @("Evidence artifact observation is missing or duplicated.")
    }
    $observation = $matchingObservations[0]
    $observationSet = Test-DanioExactPropertySet `
      -Value $observation `
      -Allowed $observationFields `
      -Required $observationFields
    if (
      -not $observationSet.valid -or
      -not (Test-DanioBoolean -Value $observation.exists_at_product_commit) -or
      -not $observation.exists_at_product_commit -or
      -not (Test-DanioSha256 -Value $observation.sha256) -or
      [string]$observation.sha256 -cne [string]$artifact.sha256
    ) {
      return New-DanioEvidenceValidationResult `
        -Valid $false `
        -Code "EVIDENCE_MANIFEST_INVALID" `
        -Details @("Evidence artifact blob or hash is unproven.")
    }
  }

  $checks = @($Manifest.checks)
  if ($checks.Count -lt 1) {
    return New-DanioEvidenceValidationResult `
      -Valid $false `
      -Code "EVIDENCE_MANIFEST_INVALID" `
      -Details @("Evidence must contain at least one named check.")
  }
  $checkFields = @("code", "status", "command_indexes", "artifact_indexes")
  $seenCheckCodes = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
  foreach ($check in $checks) {
    $checkSet = Test-DanioExactPropertySet `
      -Value $check `
      -Allowed $checkFields `
      -Required $checkFields
    if (
      -not $checkSet.valid -or
      -not (Test-DanioReasonCode -Value $check.code) -or
      ([string]$check.code).Length -gt 64 -or
      -not $seenCheckCodes.Add([string]$check.code) -or
      [string]$check.status -cne "pass" -or
      $check.command_indexes -isnot [System.Array] -or
      $check.artifact_indexes -isnot [System.Array]
    ) {
      return New-DanioEvidenceValidationResult `
        -Valid $false `
        -Code "EVIDENCE_MANIFEST_INVALID" `
        -Details @("Evidence check is malformed, duplicated, or failed.")
    }
    $commandIndexes = @($check.command_indexes)
    $artifactIndexes = @($check.artifact_indexes)
    if (($commandIndexes.Count + $artifactIndexes.Count) -lt 1) {
      return New-DanioEvidenceValidationResult `
        -Valid $false `
        -Code "EVIDENCE_MANIFEST_INVALID" `
        -Details @("Evidence check does not reference a command or artifact.")
    }
    $seenCommandIndexes = New-Object 'System.Collections.Generic.HashSet[int64]'
    foreach ($commandIndex in $commandIndexes) {
      if (
        -not (Test-DanioInteger -Value $commandIndex) -or
        [int64]$commandIndex -lt 0 -or
        [int64]$commandIndex -ge $commands.Count -or
        -not $seenCommandIndexes.Add([int64]$commandIndex) -or
        [int64]$commands[[int]$commandIndex].exit_code -ne 0
      ) {
        return New-DanioEvidenceValidationResult `
          -Valid $false `
          -Code "EVIDENCE_MANIFEST_INVALID" `
          -Details @("Evidence check command index is invalid.")
      }
    }
    $seenArtifactIndexes = New-Object 'System.Collections.Generic.HashSet[int64]'
    foreach ($artifactIndex in $artifactIndexes) {
      if (
        -not (Test-DanioInteger -Value $artifactIndex) -or
        [int64]$artifactIndex -lt 0 -or
        [int64]$artifactIndex -ge $artifacts.Count -or
        -not $seenArtifactIndexes.Add([int64]$artifactIndex)
      ) {
        return New-DanioEvidenceValidationResult `
          -Valid $false `
          -Code "EVIDENCE_MANIFEST_INVALID" `
          -Details @("Evidence check artifact index is invalid.")
      }
    }
  }

  if ($action -ceq "complete") {
    $requiredTerminalChecks = @(
      "FULL",
      "ANDROID_PREP",
      "CONTENT",
      "VISUAL",
      "PRODUCT_TRUTH",
      "PHONE_QA"
    )
    if ($seenCheckCodes.Count -ne $requiredTerminalChecks.Count) {
      return New-DanioEvidenceValidationResult `
        -Valid $false `
        -Code "EVIDENCE_MANIFEST_INVALID" `
        -Details @("Terminal evidence must contain exactly six required checks.")
    }
    foreach ($requiredCheck in $requiredTerminalChecks) {
      if (-not $seenCheckCodes.Contains($requiredCheck)) {
        return New-DanioEvidenceValidationResult `
          -Valid $false `
          -Code "EVIDENCE_MANIFEST_INVALID" `
          -Details @("Terminal evidence is missing '$requiredCheck'.")
      }
    }
  }

  $normalizedChecks = @(
    $checks | ForEach-Object {
      [pscustomobject]@{
        code = [string]$_.code
        status = [string]$_.status
        product_commit = [string]$Manifest.product_commit
      }
    }
  )
  $normalizedEvidence = [pscustomobject]@{
    product_commit = [string]$Manifest.product_commit
    manifest_path = [string]$ManifestPath
    checkpoint_commit = [string]$ParentCommit
    checks = $normalizedChecks
  }
  return New-DanioEvidenceValidationResult `
    -Valid $true `
    -Code "EVIDENCE_MANIFEST_VALID" `
    -Evidence $normalizedEvidence
}

function Test-DanioRunStateTransition {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][AllowNull()]$PreviousState,
    [Parameter(Mandatory = $true)][AllowNull()]$CandidateState,
    $LeaseRelease = $null,
    [object[]]$LedgerRows = @(),
    [string[]]$ActivePhaseLedgerIds = @(),
    [AllowNull()]$ExpectedCandidateAuthority = $null
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
  $protectedScopeCode = if ($expectedAction -ceq "claim") {
    "CLAIM_SCOPE_INVALID"
  } else {
    "TRANSITION_SCOPE_INVALID"
  }
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

  if ([string]$CandidateState.run_id -cne [string]$PreviousState.run_id) {
    return New-DanioValidationResult `
      -Valid $false `
      -Code $protectedScopeCode `
      -Details @("A post-launch transition cannot replace run identity.")
  }
  $previousAuthorizationRoot = [ordered]@{
    continuation_mode = $PreviousState.authorization.continuation_mode
    saved_project_root = $PreviousState.authorization.saved_project_root
    repository_root = $PreviousState.authorization.repository_root
  }
  $candidateAuthorizationRoot = [ordered]@{
    continuation_mode = $CandidateState.authorization.continuation_mode
    saved_project_root = $CandidateState.authorization.saved_project_root
    repository_root = $CandidateState.authorization.repository_root
  }
  if (
    (ConvertTo-DanioCanonicalJson -Value $candidateAuthorizationRoot) -cne
      (ConvertTo-DanioCanonicalJson -Value $previousAuthorizationRoot)
  ) {
    return New-DanioValidationResult `
      -Valid $false `
      -Code $protectedScopeCode `
      -Details @("A transition cannot replace continuation mode or repository/project roots.")
  }
  $authorizationRefresh = (
    $expectedAction -ceq "resume" -and
    [int64]$CandidateState.budget.total_approved_units -gt
      [int64]$PreviousState.budget.total_approved_units
  )
  if (
    -not $authorizationRefresh -and
    (
      [string]$CandidateState.authorization.authorization_id -cne
        [string]$PreviousState.authorization.authorization_id -or
      [string]$CandidateState.authorization.authorized_at_utc -cne
        [string]$PreviousState.authorization.authorized_at_utc
    )
  ) {
    return New-DanioValidationResult `
      -Valid $false `
      -Code $protectedScopeCode `
      -Details @("Authorization identity may change only with an approved resume budget increase.")
  }
  $requiredAuthority = if ($null -eq $ExpectedCandidateAuthority) {
    $PreviousState.authority
  } else {
    $ExpectedCandidateAuthority
  }
  if (
    (ConvertTo-DanioCanonicalJson -Value $CandidateState.authority) -cne
      (ConvertTo-DanioCanonicalJson -Value $requiredAuthority)
  ) {
    return New-DanioValidationResult `
      -Valid $false `
      -Code $(if ($expectedAction -ceq "claim") { "CLAIM_SCOPE_INVALID" } else { "AUTHORITY_CONFLICT" }) `
      -Details @("Candidate authority is not the exact protected or parent-derived snapshot.")
  }

  if (@("pause", "stop", "finalize", "complete", "finalization_stop") -ccontains $expectedAction) {
    if (
      (ConvertTo-DanioCanonicalJson -Value $CandidateState.cursor) -cne
        (ConvertTo-DanioCanonicalJson -Value $PreviousState.cursor)
    ) {
      return New-DanioValidationResult `
        -Valid $false `
        -Code "TRANSITION_SCOPE_INVALID" `
        -Details @("This transition cannot replace the authorized cursor.")
    }
  }
  if (@("pause", "stop", "finalize", "complete", "finalization_stop") -ccontains $expectedAction) {
    if ([int64]$CandidateState.handoff_generation -ne [int64]$PreviousState.handoff_generation) {
      return New-DanioValidationResult `
        -Valid $false `
        -Code "HANDOFF_GENERATION_INVALID" `
        -Details @("Only ordinary handoff closeout advances handoff generation.")
    }
  }
  if (@("pause", "stop", "finalize", "finalization_stop") -ccontains $expectedAction) {
    if (
      (ConvertTo-DanioCanonicalJson -Value $CandidateState.control_surface_sync) -cne
        (ConvertTo-DanioCanonicalJson -Value $PreviousState.control_surface_sync)
    ) {
      return New-DanioValidationResult `
        -Valid $false `
        -Code "TRANSITION_SCOPE_INVALID" `
        -Details @("This transition cannot replace control-surface administration state.")
    }
  }
  if (@("closeout", "pause", "finalize", "complete") -ccontains $expectedAction) {
    if (
      (ConvertTo-DanioCanonicalJson -Value $CandidateState.repeated_failure) -cne
        (ConvertTo-DanioCanonicalJson -Value $PreviousState.repeated_failure)
    ) {
      return New-DanioValidationResult `
        -Valid $false `
        -Code "TRANSITION_SCOPE_INVALID" `
        -Details @("A successful closeout/finalization transition cannot replace failure state.")
    }
  }
  if (@("closeout", "pause", "finalize", "complete") -ccontains $expectedAction) {
    if (
      [string]$CandidateState.stop_reason_code -cne [string]$PreviousState.stop_reason_code -or
      (ConvertTo-DanioCanonicalJson -Value $CandidateState.recovery) -cne
        (ConvertTo-DanioCanonicalJson -Value $PreviousState.recovery)
    ) {
      return New-DanioValidationResult `
        -Valid $false `
        -Code "TRANSITION_SCOPE_INVALID" `
        -Details @("A successful transition cannot replace stop or recovery history.")
    }
  }
  if ($expectedAction -ceq "complete") {
    $controlChanged = (
      (ConvertTo-DanioCanonicalJson -Value $CandidateState.control_surface_sync) -cne
        (ConvertTo-DanioCanonicalJson -Value $PreviousState.control_surface_sync)
    )
    if (
      $controlChanged -and
      (
        [string]$CandidateState.control_surface_sync.status -cne "pending" -or
        $null -eq $CandidateState.last_verified_checkpoint -or
        [string]$CandidateState.control_surface_sync.target_commit -cne
          [string]$CandidateState.last_verified_checkpoint.product_commit
      )
    ) {
      return New-DanioValidationResult `
        -Valid $false `
        -Code "TRANSITION_SCOPE_INVALID" `
        -Details @("Completion may only preserve control state or schedule its verified terminal product commit.")
    }
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

  if (@("stop", "finalization_stop") -ccontains $expectedAction) {
    if (
      $null -eq $PreviousState.owner -or
      $null -eq $CandidateState.recovery -or
      [string]$CandidateState.recovery.branch_name -cne [string]$PreviousState.owner.branch_name -or
      [string]$CandidateState.recovery.worktree_path -cne [string]$PreviousState.owner.worktree_path
    ) {
      return New-DanioValidationResult `
        -Valid $false `
        -Code "RECOVERY_INVALID" `
        -Details @("Durable stop recovery must name the exact previous owner branch and worktree.")
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
        $expectedAction -ceq "stop" -and
        [string]$CandidateState.transition.reason_code -ceq "BUDGET_EXHAUSTED" -and
        [int64]$candidateBudget.remaining_units_including_current -ne 0
      ) {
        return New-DanioValidationResult -Valid $false -Code "BUDGET_EXHAUSTED" -Details @("Budget-exhausted closeout requires an exact zero post-decrement balance.")
      }
      if (
        $expectedAction -ceq "finalize" -and
        (ConvertTo-DanioCanonicalJson -Value $CandidateState.owner) -cne
          (ConvertTo-DanioCanonicalJson -Value $PreviousState.owner)
      ) {
        return New-DanioValidationResult -Valid $false -Code "OWNER_TOKEN_INVALID" -Details @("Finalization must retain the exact owner identity and lease provenance.")
      }
      if (
        $expectedAction -ceq "closeout" -and
        [int64]$CandidateState.handoff_generation -ne ([int64]$PreviousState.handoff_generation + 1)
      ) {
        return New-DanioValidationResult -Valid $false -Code "HANDOFF_GENERATION_INVALID" -Details @("Closeout must advance handoff generation once.")
      }
      if ($expectedAction -ceq "closeout") {
        $controlChanged = (
          (ConvertTo-DanioCanonicalJson -Value $CandidateState.control_surface_sync) -cne
            (ConvertTo-DanioCanonicalJson -Value $PreviousState.control_surface_sync)
        )
        if (
          $controlChanged -and
          (
            [string]$CandidateState.control_surface_sync.status -cne "pending" -or
            $null -eq $CandidateState.last_verified_checkpoint -or
            [string]$CandidateState.control_surface_sync.target_commit -cne
              [string]$CandidateState.last_verified_checkpoint.product_commit
          )
        ) {
          return New-DanioValidationResult `
            -Valid $false `
            -Code "TRANSITION_SCOPE_INVALID" `
            -Details @("Closeout may only preserve control state or schedule the verified product commit.")
        }
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
      if ($null -ne $ExpectedCandidateAuthority) {
        $expectedCandidate.authority = Copy-DanioJsonValue -Value $CandidateState.authority
      }
      $expectedCandidate.control_surface_sync = Copy-DanioJsonValue -Value $CandidateState.control_surface_sync
      if (
        (ConvertTo-DanioCanonicalJson -Value $expectedCandidate) -cne
        (ConvertTo-DanioCanonicalJson -Value $CandidateState)
      ) {
        return New-DanioValidationResult -Valid $false -Code "ADMINISTRATIVE_CHANGE_FORBIDDEN" -Details @("Administrative update changed a protected field.")
      }
      if (
        [string]$PreviousState.control_surface_sync.status -cne "pending" -or
        @("synced", "failed") -cnotcontains [string]$CandidateState.control_surface_sync.status -or
        [string]$CandidateState.control_surface_sync.target_commit -cne
          [string]$PreviousState.control_surface_sync.target_commit
      ) {
        return New-DanioValidationResult `
          -Valid $false `
          -Code "ADMINISTRATIVE_CHANGE_FORBIDDEN" `
          -Details @("Administrative sync must resolve the exact previously pending visual target.")
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
      [string]$releaseCandidate.Evidence -cnotlike "*$($Evidence.manifest_path)*"
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

function ConvertTo-DanioForwardSlashPath {
  [CmdletBinding()]
  param([Parameter(Mandatory = $true)][string]$Path)

  return $Path.Replace("\", "/").TrimEnd("/")
}

function Invoke-DanioGitReadOnly {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string[]]$Arguments
  )

  $priorPreference = $ErrorActionPreference
  try {
    $ErrorActionPreference = "Continue"
    $output = @(& git -C $RepositoryRoot @Arguments 2>&1)
    $exitCode = $LASTEXITCODE
  } finally {
    $ErrorActionPreference = $priorPreference
  }
  if ($exitCode -ne 0) {
    throw "GIT_OBSERVATION_FAILED: command exited ${exitCode}: $($output -join '; ')"
  }
  return ($output -join "`n").TrimEnd()
}

function ConvertTo-DanioOutputLines {
  [CmdletBinding()]
  param([AllowNull()][string]$Value)

  if ([string]::IsNullOrWhiteSpace($Value)) {
    return @()
  }
  return @($Value -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Test-DanioAuthorityReferences {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [AllowNull()]$State
  )

  if ($null -eq $State) {
    $requiredPaths = @(
      "apps/aquarium_app/docs/agent/plans/2026-07-11-phone-complete-local-completion-program.md",
      "apps/aquarium_app/docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md",
      "apps/aquarium_app/docs/agent/FINISH_MAP.md",
      "apps/aquarium_app/docs/agent/QUALITY_LADDER.md",
      "apps/aquarium_app/docs/agent/VERIFIED_SLICE_EXECUTION_CONTRACT.md",
      "apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md",
      "apps/aquarium_app/docs/agent/DEVICE_OWNERSHIP.md"
    )
    $missing = @(
      $requiredPaths | Where-Object {
        -not (Test-Path -LiteralPath (Join-Path $RepositoryRoot $_) -PathType Leaf)
      }
    )
    if ($missing.Count -gt 0) {
      return New-DanioValidationResult `
        -Valid $false `
        -Code "AUTHORITY_CONFLICT" `
        -Details @("Missing authority paths: $($missing -join ', ').")
    }
    return New-DanioValidationResult -Valid $true -Code "AUTHORITY_VALID"
  }

  $stateProperties = @($State.PSObject.Properties | ForEach-Object { $_.Name })
  if ($stateProperties -cnotcontains "authority" -or $null -eq $State.authority) {
    return New-DanioValidationResult -Valid $false -Code "AUTHORITY_CONFLICT" -Details @("State authority is missing.")
  }

  foreach ($authorityProperty in @($State.authority.PSObject.Properties)) {
    $reference = $authorityProperty.Value
    $referenceFields = @("path", "commit", "blob_oid")
    $referenceSet = Test-DanioExactPropertySet `
      -Value $reference `
      -Allowed $referenceFields `
      -Required $referenceFields
    if (
      -not $referenceSet.valid -or
      -not (Test-DanioRepoPath -Value $reference.path) -or
      -not $script:DanioAuthorityPaths.Contains([string]$authorityProperty.Name) -or
      [string]$reference.path -cne [string]$script:DanioAuthorityPaths[[string]$authorityProperty.Name] -or
      -not (Test-DanioGitOid -Value $reference.commit) -or
      -not (Test-DanioGitOid -Value $reference.blob_oid)
    ) {
      return New-DanioValidationResult `
        -Valid $false `
        -Code "AUTHORITY_CONFLICT" `
        -Details @("Authority '$($authorityProperty.Name)' is malformed.")
    }

    try {
      $resolvedCommit = Invoke-DanioGitReadOnly `
        -RepositoryRoot $RepositoryRoot `
        -Arguments @("rev-parse", "$($reference.commit)^{commit}")
      $originMain = Invoke-DanioGitReadOnly `
        -RepositoryRoot $RepositoryRoot `
        -Arguments @("rev-parse", "origin/main")
      if ([string]$resolvedCommit -cne [string]$reference.commit) {
        throw "Authority commit does not resolve exactly."
      }
      [void](Invoke-DanioGitReadOnly `
        -RepositoryRoot $RepositoryRoot `
        -Arguments @("merge-base", "--is-ancestor", [string]$reference.commit, $originMain))
    } catch {
      return New-DanioValidationResult `
        -Valid $false `
        -Code "AUTHORITY_CONFLICT" `
        -Details @("Authority '$($authorityProperty.Name)' is not a reachable committed snapshot.")
    }

    try {
      $observedBlob = Invoke-DanioGitReadOnly `
        -RepositoryRoot $RepositoryRoot `
        -Arguments @("rev-parse", "$($reference.commit):$($reference.path)")
    } catch {
      return New-DanioValidationResult `
        -Valid $false `
        -Code "AUTHORITY_CONFLICT" `
        -Details @("Authority '$($authorityProperty.Name)' cannot be resolved.")
    }
    if ([string]$observedBlob -cne [string]$reference.blob_oid) {
      return New-DanioValidationResult `
        -Valid $false `
        -Code "AUTHORITY_CONFLICT" `
        -Details @("Authority '$($authorityProperty.Name)' blob moved.")
    }

  }

  return New-DanioValidationResult -Valid $true -Code "AUTHORITY_VALID"
}

function Get-DanioRepositoryObservation {
  [CmdletBinding()]
  param(
    [string]$RepositoryRoot,
    [AllowNull()]$State = $null
  )

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
    $resolvedRoot = Resolve-DanioRepositoryRoot -RepositoryRoot $RepositoryRoot
    $normalizedRoot = ConvertTo-DanioForwardSlashPath -Path $resolvedRoot
    $observedRoot = ConvertTo-DanioForwardSlashPath -Path (
      Invoke-DanioGitReadOnly -RepositoryRoot $resolvedRoot -Arguments @("rev-parse", "--show-toplevel")
    )
    if ($observedRoot -cne $normalizedRoot) {
      throw "REPO_ROOT_INVALID: expected '$normalizedRoot', found '$observedRoot'."
    }

    $branch = Invoke-DanioGitReadOnly -RepositoryRoot $resolvedRoot -Arguments @("branch", "--show-current")
    $headCommit = Invoke-DanioGitReadOnly -RepositoryRoot $resolvedRoot -Arguments @("rev-parse", "HEAD")
    $originMainCommit = Invoke-DanioGitReadOnly -RepositoryRoot $resolvedRoot -Arguments @("rev-parse", "origin/main")
    $countsText = Invoke-DanioGitReadOnly `
      -RepositoryRoot $resolvedRoot `
      -Arguments @("rev-list", "--left-right", "--count", "main...origin/main")
    $countParts = @($countsText -split '\s+' | Where-Object { $_ -ne "" })
    if ($countParts.Count -ne 2) {
      throw "GIT_OBSERVATION_FAILED: ahead/behind output was malformed."
    }

    $statusText = Invoke-DanioGitReadOnly `
      -RepositoryRoot $resolvedRoot `
      -Arguments @("--no-optional-locks", "status", "--short", "-uall")
    $statusPaths = @(ConvertTo-DanioOutputLines -Value $statusText)
    $worktreeText = Invoke-DanioGitReadOnly `
      -RepositoryRoot $resolvedRoot `
      -Arguments @("worktree", "list", "--porcelain")
    $worktrees = @(
      ConvertTo-DanioOutputLines -Value $worktreeText |
        Where-Object { $_.StartsWith("worktree ", [StringComparison]::Ordinal) } |
        ForEach-Object { ConvertTo-DanioForwardSlashPath -Path $_.Substring(9) }
    )
    $branchText = Invoke-DanioGitReadOnly `
      -RepositoryRoot $resolvedRoot `
      -Arguments @("branch", "--format=%(refname:short)")
    $temporaryBranches = @(
      ConvertTo-DanioOutputLines -Value $branchText |
        Where-Object { $_ -cne "main" }
    )
    $allowedWorktrees = @($normalizedRoot)
    $allowedTemporaryBranches = @()
    $stateHasOwner = (
      $null -ne $State -and
      @($State.PSObject.Properties.Name) -ccontains "owner" -and
      $null -ne $State.owner -and
      @($State.owner.PSObject.Properties.Name) -ccontains "branch_name" -and
      @($State.owner.PSObject.Properties.Name) -ccontains "worktree_path" -and
      -not [string]::IsNullOrWhiteSpace([string]$State.owner.branch_name) -and
      -not [string]::IsNullOrWhiteSpace([string]$State.owner.worktree_path)
    )
    if ($stateHasOwner) {
      $allowedTemporaryBranches = @([string]$State.owner.branch_name)
      $allowedWorktrees += @(
        ConvertTo-DanioForwardSlashPath -Path ([string]$State.owner.worktree_path)
      )
    }

    $ownershipClear = $worktrees -ccontains $normalizedRoot
    foreach ($worktree in $worktrees) {
      if ($allowedWorktrees -cnotcontains [string]$worktree) {
        $ownershipClear = $false
      }
    }
    foreach ($temporaryBranch in $temporaryBranches) {
      if ($allowedTemporaryBranches -cnotcontains [string]$temporaryBranch) {
        $ownershipClear = $false
      }
    }
    $activeOwnerRequired = (
      $stateHasOwner -and
      @($State.PSObject.Properties.Name) -ccontains "mode" -and
      [string]$State.mode -ceq "active"
    )
    if (
      $activeOwnerRequired -and
      (
        $worktrees -cnotcontains [string]$allowedWorktrees[1] -or
        $temporaryBranches -cnotcontains [string]$allowedTemporaryBranches[0]
      )
    ) {
      $ownershipClear = $false
    }

    $handoffPath = Join-Path $resolvedRoot "apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md"
    $bootstrapRemaining = $null
    if (Test-Path -LiteralPath $handoffPath -PathType Leaf) {
      $handoffContent = Get-Content -Raw -LiteralPath $handoffPath
      $budgetMatch = [regex]::Match(
        $handoffContent,
        '"remaining_units_including_current"\s*:\s*(?<remaining>[0-9]+)'
      )
      if ($budgetMatch.Success) {
        $bootstrapRemaining = [int64]$budgetMatch.Groups["remaining"].Value
      }
    }

    return [pscustomobject]@{
      repository_root = $normalizedRoot
      branch = [string]$branch
      head_commit = [string]$headCommit
      origin_main_commit = [string]$originMainCommit
      ahead = [int64]$countParts[0]
      behind = [int64]$countParts[1]
      clean = ($statusPaths.Count -eq 0)
      status_paths = @($statusPaths)
      worktrees = @($worktrees)
      temporary_branches = @($temporaryBranches)
      ownership_clear = [bool]$ownershipClear
      authority_validation = Test-DanioAuthorityReferences `
        -RepositoryRoot $resolvedRoot `
        -State $State
      bootstrap_remaining_units = $bootstrapRemaining
    }
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
}

function New-DanioSynchronizationReceipt {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$InvocationNonce,
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][int]$ExitCode,
    [Parameter(Mandatory = $true)][string]$CompletedAtUtc,
    [AllowNull()][string]$OriginMainCommit,
    [AllowNull()]$Ahead,
    [AllowNull()]$Behind
  )

  $normalizedRoot = ConvertTo-DanioForwardSlashPath -Path $RepositoryRoot
  if ($InvocationNonce -cnotmatch '^[0-9a-f]{32}$') {
    throw "INVALID_SYNC_RECEIPT: invocation nonce is malformed."
  }
  if (-not (Test-DanioAbsoluteWindowsPath -Value $normalizedRoot)) {
    throw "INVALID_SYNC_RECEIPT: repository root is malformed."
  }
  if (-not (Test-DanioStrictUtc -Value $CompletedAtUtc)) {
    throw "INVALID_SYNC_RECEIPT: completion timestamp is malformed."
  }

  $aheadBehind = $null
  if ($ExitCode -eq 0) {
    if (
      -not (Test-DanioGitOid -Value $OriginMainCommit) -or
      -not (Test-DanioInteger -Value $Ahead) -or
      -not (Test-DanioInteger -Value $Behind) -or
      [int64]$Ahead -lt 0 -or
      [int64]$Behind -lt 0
    ) {
      throw "INVALID_SYNC_RECEIPT: successful synchronization evidence is malformed."
    }
    $aheadBehind = [pscustomobject]@{
      ahead = [int64]$Ahead
      behind = [int64]$Behind
    }
  } else {
    $OriginMainCommit = $null
  }

  return [pscustomobject]@{
    document_type = "danio_synchronization_receipt"
    schema_version = 1
    invocation_nonce = $InvocationNonce
    repository_root = $normalizedRoot
    command = [pscustomobject]@{
      executable = "git"
      arguments = @("fetch", "--prune")
    }
    exit_code = $ExitCode
    completed_at_utc = $CompletedAtUtc
    origin_main_commit = $OriginMainCommit
    ahead_behind = $aheadBehind
  }
}

function Test-DanioSynchronizationReceipt {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][AllowNull()]$Receipt,
    [Parameter(Mandatory = $true)][string]$ExpectedInvocationNonce,
    [Parameter(Mandatory = $true)][string]$ExpectedRepositoryRoot,
    [Parameter(Mandatory = $true)][string]$ExpectedOriginMainCommit,
    [Parameter(Mandatory = $true)][int64]$ExpectedAhead,
    [Parameter(Mandatory = $true)][int64]$ExpectedBehind,
    [Parameter(Mandatory = $true)][string]$CheckedAtUtc,
    [int64]$MaxReceiptAgeSeconds = 120
  )

  $details = New-Object System.Collections.Generic.List[string]
  $receiptFields = @(
    "document_type",
    "schema_version",
    "invocation_nonce",
    "repository_root",
    "command",
    "exit_code",
    "completed_at_utc",
    "origin_main_commit",
    "ahead_behind"
  )
  $receiptSet = Test-DanioExactPropertySet `
    -Value $Receipt `
    -Allowed $receiptFields `
    -Required $receiptFields
  if (-not $receiptSet.valid) {
    return New-DanioValidationResult -Valid $false -Code "INVALID_SYNC_RECEIPT" -Details @("Receipt fields are missing or unknown.")
  }

  $commandFields = @("executable", "arguments")
  $commandSet = Test-DanioExactPropertySet `
    -Value $Receipt.command `
    -Allowed $commandFields `
    -Required $commandFields
  $aheadBehindFields = @("ahead", "behind")
  $aheadBehindSet = Test-DanioExactPropertySet `
    -Value $Receipt.ahead_behind `
    -Allowed $aheadBehindFields `
    -Required $aheadBehindFields
  $normalizedExpectedRoot = ConvertTo-DanioForwardSlashPath -Path $ExpectedRepositoryRoot
  if (
    [string]$Receipt.document_type -cne "danio_synchronization_receipt" -or
    -not (Test-DanioInteger -Value $Receipt.schema_version) -or
    [int64]$Receipt.schema_version -ne 1 -or
    [string]$Receipt.invocation_nonce -cne $ExpectedInvocationNonce -or
    [string]$Receipt.repository_root -cne $normalizedExpectedRoot -or
    -not $commandSet.valid -or
    [string]$Receipt.command.executable -cne "git" -or
    $Receipt.command.arguments -isnot [System.Array] -or
    $Receipt.command.arguments.Count -ne 2 -or
    [string]$Receipt.command.arguments[0] -cne "fetch" -or
    [string]$Receipt.command.arguments[1] -cne "--prune" -or
    -not (Test-DanioInteger -Value $Receipt.exit_code) -or
    [int64]$Receipt.exit_code -ne 0 -or
    -not (Test-DanioStrictUtc -Value $Receipt.completed_at_utc) -or
    [string]$Receipt.origin_main_commit -cne $ExpectedOriginMainCommit -or
    -not (Test-DanioGitOid -Value $Receipt.origin_main_commit) -or
    -not $aheadBehindSet.valid -or
    -not (Test-DanioInteger -Value $Receipt.ahead_behind.ahead) -or
    -not (Test-DanioInteger -Value $Receipt.ahead_behind.behind) -or
    [int64]$Receipt.ahead_behind.ahead -ne $ExpectedAhead -or
    [int64]$Receipt.ahead_behind.behind -ne $ExpectedBehind -or
    $MaxReceiptAgeSeconds -lt 0 -or
    -not (Test-DanioStrictUtc -Value $CheckedAtUtc)
  ) {
    return New-DanioValidationResult -Valid $false -Code "INVALID_SYNC_RECEIPT" -Details @("Receipt does not match the current invocation and repository observation.")
  }

  $completed = [DateTimeOffset]::MinValue
  $checked = [DateTimeOffset]::MinValue
  [void][DateTimeOffset]::TryParseExact(
    [string]$Receipt.completed_at_utc,
    "yyyy-MM-dd'T'HH:mm:ss.fffffff'Z'",
    [Globalization.CultureInfo]::InvariantCulture,
    [Globalization.DateTimeStyles]::AssumeUniversal -bor [Globalization.DateTimeStyles]::AdjustToUniversal,
    [ref]$completed
  )
  [void][DateTimeOffset]::TryParseExact(
    $CheckedAtUtc,
    "yyyy-MM-dd'T'HH:mm:ss.fffffff'Z'",
    [Globalization.CultureInfo]::InvariantCulture,
    [Globalization.DateTimeStyles]::AssumeUniversal -bor [Globalization.DateTimeStyles]::AdjustToUniversal,
    [ref]$checked
  )
  $age = $checked.ToUniversalTime() - $completed.ToUniversalTime()
  if ($age.Ticks -lt 0) {
    return New-DanioValidationResult -Valid $false -Code "INVALID_SYNC_RECEIPT" -Details @("Receipt completion time is in the future.")
  }
  if ($age.Ticks -gt [TimeSpan]::FromSeconds($MaxReceiptAgeSeconds).Ticks) {
    return New-DanioValidationResult -Valid $false -Code "STALE_SYNC_RECEIPT" -Details @("Receipt is older than $MaxReceiptAgeSeconds seconds.")
  }

  return New-DanioValidationResult -Valid $true -Code "SYNC_RECEIPT_VALID"
}

function Test-DanioRunnerCompatibility {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][AllowNull()]$Manifest,
    [switch]$RequireLaunchAuthorization
  )

  $manifestFields = @(
    "schema_version",
    "manifest_id",
    "manifest_revision",
    "authorizes_launch",
    "runner_compatible",
    "launch_proof",
    "design",
    "install_root",
    "runner_order",
    "skills",
    "writer_policy",
    "budget_policy",
    "failure_policy",
    "handoff_policy",
    "thread_capabilities",
    "validation"
  )
  $manifestSet = Test-DanioExactPropertySet `
    -Value $Manifest `
    -Allowed $manifestFields `
    -Required $manifestFields
  if (
    -not $manifestSet.valid -or
    ($Manifest.schema_version -isnot [long] -and $Manifest.schema_version -isnot [int]) -or
    [int64]$Manifest.schema_version -ne 1 -or
    -not (Test-DanioExactString -Value $Manifest.manifest_id -Expected "danio-phone-autonomy-runners") -or
    ($Manifest.manifest_revision -isnot [long] -and $Manifest.manifest_revision -isnot [int]) -or
    [int64]$Manifest.manifest_revision -lt 2 -or
    -not (Test-DanioBoolean -Value $Manifest.runner_compatible) -or
    -not (Test-DanioBoolean -Value $Manifest.authorizes_launch) -or
    -not $Manifest.runner_compatible -or
    $Manifest.authorizes_launch -or
    ($RequireLaunchAuthorization -and -not $Manifest.authorizes_launch) -or
    (-not $Manifest.authorizes_launch -and $null -ne $Manifest.launch_proof) -or
    $Manifest.skills -isnot [System.Array] -or
    -not (Test-DanioExactStringSequence `
      -Value $Manifest.runner_order `
      -Expected @("danio-autonomous-slice-runner", "verified-slice-runner"))
  ) {
    return New-DanioValidationResult -Valid $false -Code "RUNNER_INCOMPATIBLE" -Details @("Runner compatibility is false, malformed, or unpinned.")
  }

  $nestedContracts = @(
    @{
      Value = $Manifest.design
      Fields = @("path", "commit", "blob_oid", "sha256")
    },
    @{
      Value = $Manifest.install_root
      Fields = @("environment", "fallback")
    },
    @{
      Value = $Manifest.writer_policy
      Fields = @("repository_writer", "claim_required", "parallel_write_agents", "android_repository_writes")
    },
    @{
      Value = $Manifest.budget_policy
      Fields = @("unit", "remaining_includes_current", "claim_state", "consume_on", "do_not_consume_on", "abandoned_pending", "exactly_once")
    },
    @{
      Value = $Manifest.failure_policy
      Fields = @("digest_or_semantic_mismatch", "successor_on_stop", "auto_repair_installed_skill")
    },
    @{
      Value = $Manifest.handoff_policy
      Fields = @("eligible_mode", "positive_remaining_required", "marker_format", "lookup_before_create", "saved_project_only", "decrement_on_transfer", "ambiguous_or_unavailable", "unknown_create_result")
    },
    @{
      Value = $Manifest.thread_capabilities
      Fields = @("required", "recovery_only", "not_for_successors")
    },
    @{
      Value = $Manifest.validation
      Fields = @("hash_algorithm", "hash_scope", "reject_path_escape", "reject_unknown_fields")
    }
  )
  foreach ($contract in $nestedContracts) {
    $propertySet = Test-DanioExactPropertySet `
      -Value $contract.Value `
      -Allowed $contract.Fields `
      -Required $contract.Fields
    if (-not $propertySet.valid) {
      return New-DanioValidationResult -Valid $false -Code "RUNNER_INCOMPATIBLE" -Details @("Runner policy fields are malformed.")
    }
  }

  if (
    -not (Test-DanioExactString -Value $Manifest.design.path -Expected "apps/aquarium_app/docs/agent/plans/2026-07-11-autonomous-phone-completion-operating-model-design.md") -or
    -not (Test-DanioExactString -Value $Manifest.design.commit -Expected "81be4c93444cfd47a80cf47730cbc76e9b8464ff") -or
    -not (Test-DanioExactString -Value $Manifest.design.blob_oid -Expected "7a0921a215da64277d8141871008e556c8478bb3") -or
    -not (Test-DanioExactString -Value $Manifest.design.sha256 -Expected "E9AAFCD0B0E1A4D9261E6FE08FCD4306E396C1BA9FF0E921C0A240924496F928") -or
    -not (Test-DanioExactString -Value $Manifest.install_root.environment -Expected "CODEX_HOME") -or
    -not (Test-DanioExactString -Value $Manifest.install_root.fallback -Expected '%USERPROFILE%\.codex') -or
    -not (Test-DanioExactString -Value $Manifest.writer_policy.repository_writer -Expected "coordinator_only") -or
    -not (Test-DanioBoolean -Value $Manifest.writer_policy.claim_required) -or
    -not $Manifest.writer_policy.claim_required -or
    -not (Test-DanioBoolean -Value $Manifest.writer_policy.parallel_write_agents) -or
    $Manifest.writer_policy.parallel_write_agents -or
    -not (Test-DanioBoolean -Value $Manifest.writer_policy.android_repository_writes) -or
    $Manifest.writer_policy.android_repository_writes -or
    -not (Test-DanioExactString -Value $Manifest.budget_policy.unit -Expected "claimed_task_unit") -or
    -not (Test-DanioBoolean -Value $Manifest.budget_policy.remaining_includes_current) -or
    -not $Manifest.budget_policy.remaining_includes_current -or
    -not (Test-DanioExactString -Value $Manifest.budget_policy.claim_state -Expected "pending") -or
    -not (Test-DanioExactStringSequence -Value $Manifest.budget_policy.consume_on -Expected @("handoff_ready", "paused", "stopped", "finalizing")) -or
    -not (Test-DanioExactStringSequence -Value $Manifest.budget_policy.do_not_consume_on -Expected @("preclaim_exit", "WRITER_CLAIM_LOST")) -or
    -not (Test-DanioExactString -Value $Manifest.budget_policy.abandoned_pending -Expected "consume_on_user_approved_recovery") -or
    -not (Test-DanioBoolean -Value $Manifest.budget_policy.exactly_once) -or
    -not $Manifest.budget_policy.exactly_once -or
    -not (Test-DanioExactString -Value $Manifest.failure_policy.digest_or_semantic_mismatch -Expected "RUNNER_INCOMPATIBLE") -or
    -not (Test-DanioBoolean -Value $Manifest.failure_policy.successor_on_stop) -or
    $Manifest.failure_policy.successor_on_stop -or
    -not (Test-DanioBoolean -Value $Manifest.failure_policy.auto_repair_installed_skill) -or
    $Manifest.failure_policy.auto_repair_installed_skill -or
    -not (Test-DanioExactString -Value $Manifest.handoff_policy.eligible_mode -Expected "handoff_ready") -or
    -not (Test-DanioBoolean -Value $Manifest.handoff_policy.positive_remaining_required) -or
    -not $Manifest.handoff_policy.positive_remaining_required -or
    -not (Test-DanioExactString -Value $Manifest.handoff_policy.marker_format -Expected "run_id/handoff_generation") -or
    -not (Test-DanioBoolean -Value $Manifest.handoff_policy.lookup_before_create) -or
    -not $Manifest.handoff_policy.lookup_before_create -or
    -not (Test-DanioBoolean -Value $Manifest.handoff_policy.saved_project_only) -or
    -not $Manifest.handoff_policy.saved_project_only -or
    -not (Test-DanioBoolean -Value $Manifest.handoff_policy.decrement_on_transfer) -or
    $Manifest.handoff_policy.decrement_on_transfer -or
    -not (Test-DanioExactString -Value $Manifest.handoff_policy.ambiguous_or_unavailable -Expected "paste_ready_handoff_only") -or
    -not (Test-DanioExactString -Value $Manifest.handoff_policy.unknown_create_result -Expected "reconcile_without_retry") -or
    -not (Test-DanioExactStringSequence -Value $Manifest.thread_capabilities.required -Expected @("list_threads", "read_thread", "create_thread.project_target")) -or
    -not (Test-DanioExactStringSequence -Value $Manifest.thread_capabilities.recovery_only -Expected @("send_message_to_thread")) -or
    -not (Test-DanioExactStringSequence -Value $Manifest.thread_capabilities.not_for_successors -Expected @("fork_thread")) -or
    -not (Test-DanioExactString -Value $Manifest.validation.hash_algorithm -Expected "sha256") -or
    -not (Test-DanioExactString -Value $Manifest.validation.hash_scope -Expected "exact_file_bytes") -or
    -not (Test-DanioBoolean -Value $Manifest.validation.reject_path_escape) -or
    -not $Manifest.validation.reject_path_escape -or
    -not (Test-DanioBoolean -Value $Manifest.validation.reject_unknown_fields) -or
    -not $Manifest.validation.reject_unknown_fields
  ) {
    return New-DanioValidationResult -Valid $false -Code "RUNNER_INCOMPATIBLE" -Details @("Runner policy semantics do not match the reviewed contract.")
  }

  $installRoot = [Environment]::GetEnvironmentVariable("CODEX_HOME")
  if ([string]::IsNullOrWhiteSpace($installRoot)) {
    $installRoot = Join-Path ([Environment]::GetFolderPath("UserProfile")) ".codex"
  }

  $expectedSkills = @(
    @{
      Name = "danio-autonomous-slice-runner"
      Role = "orchestrator"
      SkillPath = "skills/danio-autonomous-slice-runner/SKILL.md"
      ContractPath = "skills/danio-autonomous-slice-runner/references/compatibility-contract.json"
      Extends = "verified-slice-runner@1.0.0"
    },
    @{
      Name = "verified-slice-runner"
      Role = "base"
      SkillPath = "skills/verified-slice-runner/SKILL.md"
      ContractPath = "skills/verified-slice-runner/references/compatibility-contract.json"
      Extends = $null
    }
  )
  $expectedCapabilities = @(
    "coordinator_only_writer",
    "read_only_auditors",
    "claimed_task_unit_budget",
    "duplicate_safe_project_handoff",
    "stop_pending",
    "push_outcome_unknown"
  )

  $skills = @($Manifest.skills)
  if ($skills.Count -ne $expectedSkills.Count) {
    return New-DanioValidationResult -Valid $false -Code "RUNNER_INCOMPATIBLE" -Details @("Runner skill order is malformed.")
  }

  for ($index = 0; $index -lt $expectedSkills.Count; $index += 1) {
    $skill = $skills[$index]
    $expected = $expectedSkills[$index]
    $skillSet = Test-DanioExactPropertySet `
      -Value $skill `
      -Allowed @("name", "role", "skill_path", "skill_sha256", "contract_path", "contract_sha256", "contract_version") `
      -Required @("name", "role", "skill_path", "skill_sha256", "contract_path", "contract_sha256", "contract_version")
    if (
      -not $skillSet.valid -or
      -not (Test-DanioExactString -Value $skill.name -Expected $expected.Name) -or
      -not (Test-DanioExactString -Value $skill.role -Expected $expected.Role) -or
      -not (Test-DanioExactString -Value $skill.skill_path -Expected $expected.SkillPath) -or
      -not (Test-DanioExactString -Value $skill.contract_path -Expected $expected.ContractPath) -or
      -not (Test-DanioExactString -Value $skill.contract_version -Expected "1.0.0") -or
      -not (Test-DanioSha256 -Value $skill.skill_sha256) -or
      -not (Test-DanioSha256 -Value $skill.contract_sha256)
    ) {
      return New-DanioValidationResult -Valid $false -Code "RUNNER_INCOMPATIBLE" -Details @("Runner digest evidence is missing.")
    }

    $skillFile = Resolve-DanioPinnedInstallFile -InstallRoot $installRoot -RelativePath $skill.skill_path
    $contractFile = Resolve-DanioPinnedInstallFile -InstallRoot $installRoot -RelativePath $skill.contract_path
    if ($null -eq $skillFile -or $null -eq $contractFile) {
      return New-DanioValidationResult -Valid $false -Code "RUNNER_INCOMPATIBLE" -Details @("Pinned runner files are missing or escape CODEX_HOME.")
    }

    if (-not (Test-DanioSkillFrontmatter -Path $skillFile -ExpectedName $skill.name)) {
      return New-DanioValidationResult -Valid $false -Code "RUNNER_INCOMPATIBLE" -Details @("Runner skill frontmatter is incompatible.")
    }

    try {
      $actualSkillHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $skillFile -ErrorAction Stop).Hash.ToLowerInvariant()
      $actualContractHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $contractFile -ErrorAction Stop).Hash.ToLowerInvariant()
      $sidecar = Get-Content -Raw -LiteralPath $contractFile -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
      return New-DanioValidationResult -Valid $false -Code "RUNNER_INCOMPATIBLE" -Details @("Pinned runner files could not be validated.")
    }

    if ($actualSkillHash -cne $skill.skill_sha256 -or $actualContractHash -cne $skill.contract_sha256) {
      return New-DanioValidationResult -Valid $false -Code "RUNNER_INCOMPATIBLE" -Details @("Pinned runner file bytes do not match reviewed digests.")
    }

    $sidecarSet = Test-DanioExactPropertySet `
      -Value $sidecar `
      -Allowed @("schema_version", "skill_name", "contract_version", "runner_role", "extends", "capabilities") `
      -Required @("schema_version", "skill_name", "contract_version", "runner_role", "extends", "capabilities")
    if (
      -not $sidecarSet.valid -or
      ($sidecar.schema_version -isnot [long] -and $sidecar.schema_version -isnot [int]) -or
      [int64]$sidecar.schema_version -ne 1 -or
      -not (Test-DanioExactString -Value $sidecar.skill_name -Expected $expected.Name) -or
      -not (Test-DanioExactString -Value $sidecar.contract_version -Expected "1.0.0") -or
      -not (Test-DanioExactString -Value $sidecar.runner_role -Expected $expected.Role) -or
      (($null -eq $expected.Extends -and $null -ne $sidecar.extends) -or
        ($null -ne $expected.Extends -and -not (Test-DanioExactString -Value $sidecar.extends -Expected $expected.Extends))) -or
      -not (Test-DanioExactStringSequence -Value $sidecar.capabilities -Expected $expectedCapabilities)
    ) {
      return New-DanioValidationResult -Valid $false -Code "RUNNER_INCOMPATIBLE" -Details @("Runner compatibility sidecar is malformed or semantically incompatible.")
    }
  }

  return New-DanioValidationResult -Valid $true -Code "RUNNER_COMPATIBLE"
}

function New-DanioReadinessCheck {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$Code,
    [Parameter(Mandatory = $true)][bool]$Passed,
    [Parameter(Mandatory = $true)][string]$Detail
  )

  return [pscustomobject]@{
    code = $Code
    status = if ($Passed) { "pass" } else { "fail" }
    detail = $Detail
  }
}

function Test-DanioAutonomousReadiness {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$Intent,
    [Parameter(Mandatory = $true)][AllowNull()]$SynchronizationReceipt,
    [Parameter(Mandatory = $true)][string]$ExpectedInvocationNonce,
    [Parameter(Mandatory = $true)][string]$ExpectedRepositoryRoot,
    [Parameter(Mandatory = $true)]$RepositoryObservation,
    [Parameter(Mandatory = $true)][AllowNull()]$State,
    [Parameter(Mandatory = $true)]$AuthorityValidation,
    [Parameter(Mandatory = $true)]$RunnerValidation,
    [Parameter(Mandatory = $true)][int64]$RemainingUnitsIncludingCurrent,
    [Parameter(Mandatory = $true)][string]$CheckedAtUtc,
    [int64]$MaxReceiptAgeSeconds = 120,
    [bool]$RuntimeRequired = $false,
    [bool]$RuntimeOwnershipClear = $true,
    [AllowEmptyCollection()][object[]]$LedgerRows = @(),
    [AllowEmptyCollection()][string[]]$ActivePhaseLedgerIds = @(),
    [AllowNull()]$Evidence = $null,
    [AllowNull()]$Cleanup = $null
  )

  $checks = New-Object System.Collections.Generic.List[object]
  $allowedIntents = @("Launch", "Claim", "Closeout", "Finalization", "AdministrativeSync")
  if ($allowedIntents -cnotcontains $Intent) {
    $checks.Add((New-DanioReadinessCheck -Code "AUTHORITY_CONFLICT" -Passed $false -Detail "Intent is not supported."))
  }

  $observationFields = @(
    "repository_root",
    "branch",
    "head_commit",
    "origin_main_commit",
    "ahead",
    "behind",
    "clean",
    "status_paths",
    "worktrees",
    "temporary_branches",
    "ownership_clear"
  )
  $observationNames = if ($null -eq $RepositoryObservation) {
    @()
  } else {
    @($RepositoryObservation.PSObject.Properties | ForEach-Object { $_.Name })
  }
  $observationShapeValid = $true
  foreach ($field in $observationFields) {
    if ($observationNames -cnotcontains $field) {
      $observationShapeValid = $false
    }
  }

  $receiptValidation = if ($observationShapeValid) {
    Test-DanioSynchronizationReceipt `
      -Receipt $SynchronizationReceipt `
      -ExpectedInvocationNonce $ExpectedInvocationNonce `
      -ExpectedRepositoryRoot $ExpectedRepositoryRoot `
      -ExpectedOriginMainCommit ([string]$RepositoryObservation.origin_main_commit) `
      -ExpectedAhead ([int64]$RepositoryObservation.ahead) `
      -ExpectedBehind ([int64]$RepositoryObservation.behind) `
      -CheckedAtUtc $CheckedAtUtc `
      -MaxReceiptAgeSeconds $MaxReceiptAgeSeconds
  } else {
    New-DanioValidationResult -Valid $false -Code "INVALID_SYNC_RECEIPT" -Details @("Repository observation is malformed.")
  }
  $checks.Add((New-DanioReadinessCheck `
    -Code $(if ($receiptValidation.valid) { "SYNC_RECEIPT" } else { [string]$receiptValidation.code }) `
    -Passed ([bool]$receiptValidation.valid) `
    -Detail $(if ($receiptValidation.valid) { "Synchronization receipt is valid and fresh." } else { $receiptValidation.details -join "; " })))

  $normalizedExpectedRoot = ConvertTo-DanioForwardSlashPath -Path $ExpectedRepositoryRoot
  $rootValid = (
    $observationShapeValid -and
    [string]$RepositoryObservation.repository_root -ceq $normalizedExpectedRoot
  )
  $checks.Add((New-DanioReadinessCheck `
    -Code $(if ($rootValid) { "REPO_ROOT" } else { "REPO_ROOT_INVALID" }) `
    -Passed $rootValid `
    -Detail $(if ($rootValid) { "Nested repository root matches." } else { "Nested repository root does not match." })))

  $branchValid = $observationShapeValid -and [string]$RepositoryObservation.branch -ceq "main"
  $checks.Add((New-DanioReadinessCheck `
    -Code $(if ($branchValid) { "SOURCE_BRANCH" } else { "WRONG_SOURCE_BRANCH" }) `
    -Passed $branchValid `
    -Detail $(if ($branchValid) { "Source branch is main." } else { "Source branch is not main." })))

  $remoteValid = (
    $observationShapeValid -and
    (Test-DanioGitOid -Value $RepositoryObservation.head_commit) -and
    (Test-DanioGitOid -Value $RepositoryObservation.origin_main_commit) -and
    (Test-DanioInteger -Value $RepositoryObservation.ahead) -and
    (Test-DanioInteger -Value $RepositoryObservation.behind) -and
    [int64]$RepositoryObservation.ahead -eq 0 -and
    [int64]$RepositoryObservation.behind -eq 0
  )
  $checks.Add((New-DanioReadinessCheck `
    -Code $(if ($remoteValid) { "REMOTE_ALIGNMENT" } else { "REMOTE_DIVERGED" }) `
    -Passed $remoteValid `
    -Detail $(if ($remoteValid) { "Main and origin/main are aligned." } else { "Main and origin/main diverged." })))

  $cleanValid = (
    $observationShapeValid -and
    (Test-DanioBoolean -Value $RepositoryObservation.clean) -and
    [bool]$RepositoryObservation.clean -and
    $RepositoryObservation.status_paths -is [System.Array] -and
    $RepositoryObservation.status_paths.Count -eq 0
  )
  $checks.Add((New-DanioReadinessCheck `
    -Code $(if ($cleanValid) { "WORKTREE_CLEAN" } else { "DIRTY_UNOWNED" }) `
    -Passed $cleanValid `
    -Detail $(if ($cleanValid) { "Tracked and untracked status is clean." } else { "Tracked or untracked dirt is present." })))

  $ownershipValid = (
    $observationShapeValid -and
    (Test-DanioBoolean -Value $RepositoryObservation.ownership_clear) -and
    [bool]$RepositoryObservation.ownership_clear
  )
  $checks.Add((New-DanioReadinessCheck `
    -Code $(if ($ownershipValid) { "OWNERSHIP_CLEAR" } else { "DIRTY_UNOWNED" }) `
    -Passed $ownershipValid `
    -Detail $(if ($ownershipValid) { "No foreign temporary branch or worktree is present." } else { "Foreign branch or worktree ownership is present." })))

  $stateValid = $false
  $stateDetail = "State is invalid for intent '$Intent'."
  if ($Intent -ceq "Launch" -and $null -eq $State) {
    $stateValid = $true
    $stateDetail = "Absent live state is valid for Launch."
  } elseif ($null -ne $State) {
    try {
      $stateValidation = Test-DanioRunState -State $State
      if ($stateValidation.valid) {
        $allowedModes = switch ($Intent) {
          "Launch" { @("inactive", "ready") }
          "Claim" { @("ready", "handoff_ready") }
          "Closeout" { @("active") }
          "Finalization" { @("finalizing") }
          "AdministrativeSync" { @("handoff_ready", "complete") }
          default { @() }
        }
        $stateValid = (
          $allowedModes -ccontains [string]$State.mode -and
          [string]$State.authorization.repository_root -ceq $normalizedExpectedRoot
        )
        if ($stateValid) {
          $stateDetail = "Run state is valid for intent '$Intent'."
        }
      } else {
        $stateDetail = "State validation failed: $($stateValidation.code)."
      }
    } catch {
      $stateDetail = "State validation rejected malformed input."
    }
  }
  $checks.Add((New-DanioReadinessCheck `
    -Code $(if ($stateValid) { "RUN_STATE" } else { "AUTHORITY_CONFLICT" }) `
    -Passed $stateValid `
    -Detail $stateDetail))

  $authorityValid = (
    $null -ne $AuthorityValidation -and
    ($AuthorityValidation.PSObject.Properties.Name -ccontains "valid") -and
    [bool]$AuthorityValidation.valid
  )
  $checks.Add((New-DanioReadinessCheck `
    -Code $(if ($authorityValid) { "AUTHORITY" } else { "AUTHORITY_CONFLICT" }) `
    -Passed $authorityValid `
    -Detail $(if ($authorityValid) { "Canonical authority references validate." } else { $AuthorityValidation.details -join "; " })))

  if ($Intent -ceq "Finalization") {
    $completionRepositoryObservation = [pscustomobject]@{
      parent_commit = if ($observationShapeValid) { [string]$RepositoryObservation.head_commit } else { "" }
      origin_main_commit = if ($observationShapeValid) { [string]$RepositoryObservation.origin_main_commit } else { "" }
      ahead = if ($observationShapeValid) { $RepositoryObservation.ahead } else { -1 }
      behind = if ($observationShapeValid) { $RepositoryObservation.behind } else { -1 }
      clean = if ($observationShapeValid) { $RepositoryObservation.clean } else { $false }
    }
    $completionValidation = Test-DanioCompletionReadiness `
      -State $State `
      -LedgerRows $LedgerRows `
      -ActivePhaseLedgerIds $ActivePhaseLedgerIds `
      -Evidence $Evidence `
      -Cleanup $Cleanup `
      -RepositoryObservation $completionRepositoryObservation
    $checks.Add((New-DanioReadinessCheck `
      -Code $(if ($completionValidation.ready) { "COMPLETION" } else { "COMPLETION_NOT_READY" }) `
      -Passed ([bool]$completionValidation.ready) `
      -Detail $(if ($completionValidation.ready) { "Terminal completion proof is ready." } else { $completionValidation.details -join "; " })))
  } else {
    $checks.Add((New-DanioReadinessCheck -Code "COMPLETION" -Passed $true -Detail "Completion proof is not required for this intent."))
  }

  $runnerValid = (
    $null -ne $RunnerValidation -and
    ($RunnerValidation.PSObject.Properties.Name -ccontains "valid") -and
    [bool]$RunnerValidation.valid
  )
  $checks.Add((New-DanioReadinessCheck `
    -Code $(if ($runnerValid) { "RUNNER" } else { "RUNNER_INCOMPATIBLE" }) `
    -Passed $runnerValid `
    -Detail $(if ($runnerValid) { "Runner compatibility validates." } else { $RunnerValidation.details -join "; " })))

  $budgetRequired = @("Launch", "Claim") -ccontains $Intent
  $budgetValid = -not $budgetRequired -or $RemainingUnitsIncludingCurrent -gt 0
  $checks.Add((New-DanioReadinessCheck `
    -Code $(if ($budgetValid) { "BUDGET" } else { "BUDGET_EXHAUSTED" }) `
    -Passed $budgetValid `
    -Detail $(if ($budgetValid) { "Autonomous unit budget permits this intent." } else { "No autonomous units remain for a new claim." })))

  $runtimeValid = -not $RuntimeRequired -or $RuntimeOwnershipClear
  $checks.Add((New-DanioReadinessCheck `
    -Code $(if ($runtimeValid) { "RUNTIME" } else { "RUNTIME_OWNERSHIP_CONFLICT" }) `
    -Passed $runtimeValid `
    -Detail $(if ($runtimeValid) { "Runtime ownership is not required or is clear." } else { "Required runtime ownership is unclear." })))

  $failedChecks = @($checks.ToArray() | Where-Object { $_.status -ceq "fail" })
  $stopReason = $null
  $precedence = @(
    "INVALID_SYNC_RECEIPT",
    "STALE_SYNC_RECEIPT",
    "REPO_ROOT_INVALID",
    "WRONG_SOURCE_BRANCH",
    "REMOTE_DIVERGED",
    "DIRTY_UNOWNED",
    "AUTHORITY_CONFLICT",
    "RUNNER_INCOMPATIBLE",
    "BUDGET_EXHAUSTED",
    "RUNTIME_OWNERSHIP_CONFLICT",
    "COMPLETION_NOT_READY"
  )
  foreach ($code in $precedence) {
    if (@($failedChecks | Where-Object { $_.code -ceq $code }).Count -gt 0) {
      $stopReason = $code
      break
    }
  }
  if ($failedChecks.Count -gt 0 -and $null -eq $stopReason) {
    $stopReason = "AUTHORITY_CONFLICT"
  }

  return [pscustomobject]@{
    document_type = "danio_readiness_report"
    schema_version = 1
    intent = $Intent
    checked_at_utc = $CheckedAtUtc
    eligible = ($failedChecks.Count -eq 0)
    stop_reason_code = $stopReason
    checks = @($checks.ToArray())
  }
}

function New-DanioWriterClaimPlanResult {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][bool]$Valid,
    [Parameter(Mandatory = $true)][string]$Code,
    [Parameter(Mandatory = $true)][string]$PlannedAtUtc,
    [object[]]$Details = @(),
    [AllowNull()]$Identity = $null,
    [AllowNull()]$NextRunState = $null
  )

  return [pscustomobject][ordered]@{
    document_type = "danio_writer_claim_plan"
    schema_version = 1
    planned_at_utc = $PlannedAtUtc
    valid = $Valid
    code = $Code
    details = @($Details)
    mutations_performed = $false
    run_id = if ($Valid) { [string]$Identity.run_id } else { $null }
    work_unit_id = if ($Valid) { [string]$Identity.work_unit_id } else { $null }
    task_id = if ($Valid) { [string]$Identity.task_id } else { $null }
    expected_state_revision = if ($Valid) { [int64]$Identity.expected_state_revision } else { $null }
    owner_token_sha256 = if ($Valid) { [string]$Identity.owner_token_sha256 } else { $null }
    branch_name = if ($Valid) { [string]$Identity.branch_name } else { $null }
    worktree_id = if ($Valid) { [string]$Identity.worktree_id } else { $null }
    worktree_path = if ($Valid) { [string]$Identity.worktree_path } else { $null }
    base_commit = if ($Valid) { [string]$Identity.base_commit } else { $null }
    state_path = $script:DanioRunStatePath
    next_run_state = if ($Valid) { $NextRunState } else { $null }
  }
}

function New-DanioWriterClaimPlan {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]$ReadinessReport,
    [Parameter(Mandatory = $true)]$CurrentState,
    [Parameter(Mandatory = $true)][string]$TaskId,
    [Parameter(Mandatory = $true)][int64]$ExpectedStateRevision,
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string]$WorktreeRoot,
    [Parameter(Mandatory = $true)][string]$BaseCommit,
    [Parameter(Mandatory = $true)][string]$BaseTreeHash,
    [Parameter(Mandatory = $true)][string]$PlannedAtUtc,
    [Parameter(Mandatory = $true)]$ExistingIdentityObservation
  )

  $readinessFields = @(
    "document_type",
    "schema_version",
    "intent",
    "checked_at_utc",
    "eligible",
    "stop_reason_code",
    "checks"
  )
  $readinessSet = Test-DanioExactPropertySet `
    -Value $ReadinessReport `
    -Allowed $readinessFields `
    -Required $readinessFields
  $readinessShapeValid = (
    $readinessSet.valid -and
    [string]$ReadinessReport.document_type -ceq "danio_readiness_report" -and
    (Test-DanioInteger -Value $ReadinessReport.schema_version) -and
    [int64]$ReadinessReport.schema_version -eq 1 -and
    [string]$ReadinessReport.intent -ceq "Claim" -and
    (Test-DanioStrictUtc -Value $ReadinessReport.checked_at_utc) -and
    (Test-DanioBoolean -Value $ReadinessReport.eligible) -and
    $ReadinessReport.checks -is [System.Array] -and
    $ReadinessReport.checks.Count -gt 0
  )
  if ($readinessShapeValid) {
    foreach ($check in @($ReadinessReport.checks)) {
      $checkSet = Test-DanioExactPropertySet `
        -Value $check `
        -Allowed @("code", "status", "detail") `
        -Required @("code", "status", "detail")
      if (
        -not $checkSet.valid -or
        -not (Test-DanioReasonCode -Value $check.code) -or
        @("pass", "fail") -cnotcontains [string]$check.status -or
        $check.detail -isnot [string] -or
        [string]::IsNullOrWhiteSpace([string]$check.detail)
      ) {
        $readinessShapeValid = $false
      }
    }
  }
  if (
    -not $readinessShapeValid -or
    (
      [bool]$ReadinessReport.eligible -and
      (
        $null -ne $ReadinessReport.stop_reason_code -or
        @($ReadinessReport.checks | Where-Object { [string]$_.status -cne "pass" }).Count -gt 0
      )
    ) -or
    (
      -not [bool]$ReadinessReport.eligible -and
      (
        -not (Test-DanioReasonCode -Value $ReadinessReport.stop_reason_code) -or
        @($ReadinessReport.checks | Where-Object { [string]$_.status -ceq "fail" }).Count -eq 0
      )
    )
  ) {
    return New-DanioWriterClaimPlanResult `
      -Valid $false `
      -Code "INVALID_READINESS_REPORT" `
      -PlannedAtUtc $PlannedAtUtc `
      -Details @("Readiness report is malformed or does not authorize Claim.")
  }
  if (-not [bool]$ReadinessReport.eligible) {
    return New-DanioWriterClaimPlanResult `
      -Valid $false `
      -Code ([string]$ReadinessReport.stop_reason_code) `
      -PlannedAtUtc $PlannedAtUtc `
      -Details @("Readiness report is ineligible for Claim.")
  }

  $stateValidation = Test-DanioRunState -State $CurrentState
  if (-not $stateValidation.valid) {
    return New-DanioWriterClaimPlanResult `
      -Valid $false `
      -Code ([string]$stateValidation.code) `
      -PlannedAtUtc $PlannedAtUtc `
      -Details $stateValidation.details
  }
  if (@("ready", "handoff_ready") -cnotcontains [string]$CurrentState.mode) {
    return New-DanioWriterClaimPlanResult `
      -Valid $false `
      -Code "TRANSITION_NOT_ALLOWED" `
      -PlannedAtUtc $PlannedAtUtc `
      -Details @("Only ready or handoff_ready state may claim a writer.")
  }
  if ([int64]$CurrentState.state_revision -ne $ExpectedStateRevision) {
    return New-DanioWriterClaimPlanResult `
      -Valid $false `
      -Code "STATE_REVISION_INVALID" `
      -PlannedAtUtc $PlannedAtUtc `
      -Details @("Expected state revision does not match the committed state.")
  }
  if ([int64]$CurrentState.budget.remaining_units_including_current -le 0) {
    return New-DanioWriterClaimPlanResult `
      -Valid $false `
      -Code "BUDGET_EXHAUSTED" `
      -PlannedAtUtc $PlannedAtUtc `
      -Details @("A writer claim requires positive remaining budget.")
  }

  $normalizedRepositoryRoot = ConvertTo-DanioForwardSlashPath -Path $RepositoryRoot
  $normalizedStateRepositoryRoot = ConvertTo-DanioForwardSlashPath `
    -Path ([string]$CurrentState.authorization.repository_root)
  $normalizedSavedProjectRoot = ConvertTo-DanioForwardSlashPath `
    -Path ([string]$CurrentState.authorization.saved_project_root)
  $normalizedWorktreeRoot = ConvertTo-DanioForwardSlashPath -Path $WorktreeRoot
  $expectedWorktreeRoot = "$normalizedSavedProjectRoot/.codex-worktrees"
  $runId = [string]$CurrentState.run_id
  $workUnitId = [string]$CurrentState.cursor.work_unit_id
  if (
    -not (Test-DanioStrictUtc -Value $PlannedAtUtc) -or
    -not (Test-DanioSafeIdentifier -Value $TaskId) -or
    -not (Test-DanioSafeIdentifier -Value $runId) -or
    -not (Test-DanioSafeIdentifier -Value $workUnitId) -or
    -not (Test-DanioGitOid -Value $BaseCommit) -or
    -not (Test-DanioGitOid -Value $BaseTreeHash) -or
    -not (Test-DanioAbsoluteWindowsPath -Value $normalizedRepositoryRoot) -or
    -not (Test-DanioAbsoluteWindowsPath -Value $normalizedSavedProjectRoot) -or
    -not (Test-DanioAbsoluteWindowsPath -Value $normalizedWorktreeRoot) -or
    -not [string]::Equals(
      $normalizedRepositoryRoot,
      $normalizedStateRepositoryRoot,
      [StringComparison]::OrdinalIgnoreCase
    ) -or
    -not [string]::Equals(
      $normalizedWorktreeRoot,
      $expectedWorktreeRoot,
      [StringComparison]::OrdinalIgnoreCase
    )
  ) {
    return New-DanioWriterClaimPlanResult `
      -Valid $false `
      -Code "OWNER_IDENTITY_INVALID" `
      -PlannedAtUtc $PlannedAtUtc `
      -Details @("Claim identity, roots, commit, tree, or timestamp are invalid.")
  }
  $normalizedWorktreeRoot = $expectedWorktreeRoot

  $ownerToken = Get-DanioOwnerToken `
    -RunId $runId `
    -WorkUnitId $workUnitId `
    -TaskId $TaskId `
    -ExpectedRevision $ExpectedStateRevision
  $token12 = $ownerToken.Substring(0, 12)
  $branchName = "autonomy/$runId/$workUnitId/$token12"
  $worktreeId = "$runId-$workUnitId-$token12"
  $worktreePath = "$normalizedWorktreeRoot/$worktreeId"
  if (
    -not (Test-DanioSafeIdentifier -Value $worktreeId) -or
    $branchName.Length -gt 240 -or
    -not (Test-DanioAbsoluteWindowsPath -Value $worktreePath) -or
    -not $worktreePath.StartsWith("$normalizedWorktreeRoot/", [StringComparison]::Ordinal)
  ) {
    return New-DanioWriterClaimPlanResult `
      -Valid $false `
      -Code "OWNER_IDENTITY_INVALID" `
      -PlannedAtUtc $PlannedAtUtc `
      -Details @("Derived branch or worktree identity is invalid.")
  }

  $identityObservationSet = Test-DanioExactPropertySet `
    -Value $ExistingIdentityObservation `
    -Allowed @("status", "details") `
    -Required @("status", "details")
  $identityObservationValid = (
    $identityObservationSet.valid -and
    @("absent", "exact_reusable", "conflict", "ambiguous") -ccontains [string]$ExistingIdentityObservation.status -and
    $ExistingIdentityObservation.details -is [System.Array]
  )
  if ($identityObservationValid) {
    foreach ($detail in @($ExistingIdentityObservation.details)) {
      if ($detail -isnot [string] -or [string]::IsNullOrWhiteSpace([string]$detail)) {
        $identityObservationValid = $false
      }
    }
  }
  if (-not $identityObservationValid) {
    return New-DanioWriterClaimPlanResult `
      -Valid $false `
      -Code "OWNER_IDENTITY_INVALID" `
      -PlannedAtUtc $PlannedAtUtc `
      -Details @("Existing writer identity observation is malformed.")
  }
  if (@("absent", "exact_reusable") -cnotcontains [string]$ExistingIdentityObservation.status) {
    return New-DanioWriterClaimPlanResult `
      -Valid $false `
      -Code "WRITER_IDENTITY_CONFLICT" `
      -PlannedAtUtc $PlannedAtUtc `
      -Details @($ExistingIdentityObservation.details)
  }

  $nextRunState = Copy-DanioJsonValue -Value $CurrentState
  $nextRunState.state_revision = [int64]$CurrentState.state_revision + 1
  $nextRunState.mode = "active"
  $nextRunState.transition = [pscustomobject][ordered]@{
    action = "claim"
    from_mode = [string]$CurrentState.mode
    to_mode = "active"
    parent_state_revision = [int64]$CurrentState.state_revision
    work_unit_id = $workUnitId
    reason_code = $null
    occurred_at_utc = $PlannedAtUtc
  }
  $nextRunState.owner = [pscustomobject][ordered]@{
    task_id = $TaskId
    token_sha256 = $ownerToken
    claim_revision = $ExpectedStateRevision
    claim_parent_commit = $BaseCommit
    claim_staged_tree_hash = $BaseTreeHash
    branch_name = $branchName
    worktree_id = $worktreeId
    worktree_path = $worktreePath
    claimed_at_utc = $PlannedAtUtc
    writer_lease_released = $false
    android_lease_released = $true
  }
  $nextRunState.budget.current_charge.work_unit_id = $workUnitId
  $nextRunState.budget.current_charge.status = "pending"
  $nextRunState.budget.current_charge.claimed_revision = $ExpectedStateRevision
  $nextRunState.budget.current_charge.consumed_revision = $null

  $transitionValidation = Test-DanioRunStateTransition `
    -PreviousState $CurrentState `
    -CandidateState $nextRunState
  if (-not $transitionValidation.valid) {
    return New-DanioWriterClaimPlanResult `
      -Valid $false `
      -Code ([string]$transitionValidation.code) `
      -PlannedAtUtc $PlannedAtUtc `
      -Details $transitionValidation.details
  }

  $identity = [pscustomobject]@{
    run_id = $runId
    work_unit_id = $workUnitId
    task_id = $TaskId
    expected_state_revision = $ExpectedStateRevision
    owner_token_sha256 = $ownerToken
    branch_name = $branchName
    worktree_id = $worktreeId
    worktree_path = $worktreePath
    base_commit = $BaseCommit
  }
  return New-DanioWriterClaimPlanResult `
    -Valid $true `
    -Code "CLAIM_PLAN_VALID" `
    -PlannedAtUtc $PlannedAtUtc `
    -Identity $identity `
    -NextRunState $nextRunState
}

function Test-DanioWriterClaimPlan {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]$Plan,
    [Parameter(Mandatory = $true)]$CurrentState,
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string]$ExpectedBaseCommit,
    [Parameter(Mandatory = $true)][string]$ExpectedBaseTreeHash,
    [switch]$AllowDisposableRepositoryRootOverride
  )

  $planFields = @(
    "document_type",
    "schema_version",
    "planned_at_utc",
    "valid",
    "code",
    "details",
    "mutations_performed",
    "run_id",
    "work_unit_id",
    "task_id",
    "expected_state_revision",
    "owner_token_sha256",
    "branch_name",
    "worktree_id",
    "worktree_path",
    "base_commit",
    "state_path",
    "next_run_state"
  )
  $planSet = Test-DanioExactPropertySet `
    -Value $Plan `
    -Allowed $planFields `
    -Required $planFields
  if (-not $planSet.valid) {
    return New-DanioValidationResult `
      -Valid $false `
      -Code "CLAIM_PLAN_INVALID" `
      -Details $planSet.details
  }

  $shapeValid = (
    [string]$Plan.document_type -ceq "danio_writer_claim_plan" -and
    (Test-DanioInteger -Value $Plan.schema_version) -and
    [int64]$Plan.schema_version -eq 1 -and
    (Test-DanioStrictUtc -Value $Plan.planned_at_utc) -and
    (Test-DanioBoolean -Value $Plan.valid) -and
    [bool]$Plan.valid -and
    [string]$Plan.code -ceq "CLAIM_PLAN_VALID" -and
    $Plan.details -is [System.Array] -and
    (Test-DanioBoolean -Value $Plan.mutations_performed) -and
    -not [bool]$Plan.mutations_performed -and
    (Test-DanioSafeIdentifier -Value $Plan.run_id) -and
    (Test-DanioSafeIdentifier -Value $Plan.work_unit_id) -and
    (Test-DanioSafeIdentifier -Value $Plan.task_id) -and
    (Test-DanioInteger -Value $Plan.expected_state_revision) -and
    [int64]$Plan.expected_state_revision -ge 1 -and
    (Test-DanioSha256 -Value $Plan.owner_token_sha256) -and
    $Plan.branch_name -is [string] -and
    $Plan.branch_name -cmatch '^autonomy/[A-Za-z0-9._-]+/[A-Za-z0-9._-]+/[0-9a-f]{12}$' -and
    (Test-DanioSafeIdentifier -Value $Plan.worktree_id) -and
    (Test-DanioAbsoluteWindowsPath -Value $Plan.worktree_path) -and
    (Test-DanioGitOid -Value $Plan.base_commit) -and
    [string]$Plan.state_path -ceq $script:DanioRunStatePath -and
    $null -ne $Plan.next_run_state
  )
  if ($shapeValid) {
    foreach ($detail in @($Plan.details)) {
      if ($detail -isnot [string] -or [string]::IsNullOrWhiteSpace([string]$detail)) {
        $shapeValid = $false
      }
    }
  }
  if (-not $shapeValid) {
    return New-DanioValidationResult `
      -Valid $false `
      -Code "CLAIM_PLAN_INVALID" `
      -Details @("Writer claim plan shape is invalid.")
  }

  $currentValidation = Test-DanioRunState -State $CurrentState
  if (-not $currentValidation.valid) {
    return New-DanioValidationResult `
      -Valid $false `
      -Code ([string]$currentValidation.code) `
      -Details $currentValidation.details
  }
  $candidateValidation = Test-DanioRunState -State $Plan.next_run_state
  if (-not $candidateValidation.valid) {
    return New-DanioValidationResult `
      -Valid $false `
      -Code ([string]$candidateValidation.code) `
      -Details $candidateValidation.details
  }
  $transitionValidation = Test-DanioRunStateTransition `
    -PreviousState $CurrentState `
    -CandidateState $Plan.next_run_state
  if (-not $transitionValidation.valid) {
    return New-DanioValidationResult `
      -Valid $false `
      -Code ([string]$transitionValidation.code) `
      -Details $transitionValidation.details
  }

  $normalizedRepositoryRoot = ConvertTo-DanioForwardSlashPath -Path $RepositoryRoot
  $authorizedRepositoryRoot = ConvertTo-DanioForwardSlashPath `
    -Path ([string]$CurrentState.authorization.repository_root)
  if (
    -not $AllowDisposableRepositoryRootOverride -and
    -not [string]::Equals(
      $normalizedRepositoryRoot,
      $authorizedRepositoryRoot,
      [StringComparison]::OrdinalIgnoreCase
    )
  ) {
    return New-DanioValidationResult `
      -Valid $false `
      -Code "REPO_ROOT_INVALID" `
      -Details @("Writer claim repository root does not match durable authorization.")
  }

  $runId = [string]$CurrentState.run_id
  $workUnitId = [string]$CurrentState.cursor.work_unit_id
  $expectedRevision = [int64]$CurrentState.state_revision
  $expectedToken = Get-DanioOwnerToken `
    -RunId $runId `
    -WorkUnitId $workUnitId `
    -TaskId ([string]$Plan.task_id) `
    -ExpectedRevision $expectedRevision
  $token12 = $expectedToken.Substring(0, 12)
  $expectedBranch = "autonomy/$runId/$workUnitId/$token12"
  $expectedWorktreeId = "$runId-$workUnitId-$token12"
  $savedProjectRoot = ConvertTo-DanioForwardSlashPath `
    -Path ([string]$CurrentState.authorization.saved_project_root)
  $expectedWorktreePath = "$savedProjectRoot/.codex-worktrees/$expectedWorktreeId"
  $owner = $Plan.next_run_state.owner

  $identityValid = (
    [string]$Plan.run_id -ceq $runId -and
    [string]$Plan.work_unit_id -ceq $workUnitId -and
    [int64]$Plan.expected_state_revision -eq $expectedRevision -and
    [string]$Plan.owner_token_sha256 -ceq $expectedToken -and
    [string]$Plan.branch_name -ceq $expectedBranch -and
    [string]$Plan.worktree_id -ceq $expectedWorktreeId -and
    [string]$Plan.worktree_path -ceq $expectedWorktreePath -and
    [string]$Plan.base_commit -ceq $ExpectedBaseCommit -and
    [string]$owner.task_id -ceq [string]$Plan.task_id -and
    [string]$owner.token_sha256 -ceq $expectedToken -and
    [int64]$owner.claim_revision -eq $expectedRevision -and
    [string]$owner.claim_parent_commit -ceq $ExpectedBaseCommit -and
    [string]$owner.claim_staged_tree_hash -ceq $ExpectedBaseTreeHash -and
    [string]$owner.branch_name -ceq $expectedBranch -and
    [string]$owner.worktree_id -ceq $expectedWorktreeId -and
    [string]$owner.worktree_path -ceq $expectedWorktreePath -and
    [string]$owner.claimed_at_utc -ceq [string]$Plan.planned_at_utc -and
    [string]$Plan.next_run_state.transition.occurred_at_utc -ceq
      [string]$Plan.planned_at_utc -and
    [int64]$Plan.next_run_state.budget.total_approved_units -eq
      [int64]$CurrentState.budget.total_approved_units -and
    [int64]$Plan.next_run_state.budget.consumed_units -eq
      [int64]$CurrentState.budget.consumed_units -and
    [int64]$Plan.next_run_state.budget.remaining_units_including_current -eq
      [int64]$CurrentState.budget.remaining_units_including_current
  )
  if (-not $identityValid) {
    return New-DanioValidationResult `
      -Valid $false `
      -Code "CLAIM_PLAN_INVALID" `
      -Details @("Writer claim plan identity, base, owner, or budget is invalid.")
  }

  return New-DanioValidationResult `
    -Valid $true `
    -Code "CLAIM_PLAN_VALID" `
    -Details @()
}

function Test-DanioRehearsalObservation {
  [CmdletBinding()]
  param([Parameter(Mandatory = $true)][AllowNull()]$Observation)

  $fields = @(
    "status_sha256",
    "index_tree",
    "local_refs_sha256",
    "remote_refs_sha256",
    "worktrees_sha256"
  )
  $propertySet = Test-DanioExactPropertySet `
    -Value $Observation `
    -Allowed $fields `
    -Required $fields
  return (
    $propertySet.valid -and
    (Test-DanioSha256 -Value $Observation.status_sha256) -and
    (Test-DanioGitOid -Value $Observation.index_tree) -and
    (Test-DanioSha256 -Value $Observation.local_refs_sha256) -and
    (Test-DanioSha256 -Value $Observation.remote_refs_sha256) -and
    (Test-DanioSha256 -Value $Observation.worktrees_sha256)
  )
}

function Test-DanioRehearsalPreview {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][AllowNull()]$Preview,
    [Parameter(Mandatory = $true)][string]$ExpectedCode
  )

  $fields = @("eligible", "code", "mutations_performed")
  $propertySet = Test-DanioExactPropertySet `
    -Value $Preview `
    -Allowed $fields `
    -Required $fields
  return (
    $propertySet.valid -and
    (Test-DanioBoolean -Value $Preview.eligible) -and
    -not [bool]$Preview.eligible -and
    (Test-DanioExactString -Value $Preview.code -Expected $ExpectedCode) -and
    (Test-DanioBoolean -Value $Preview.mutations_performed) -and
    -not [bool]$Preview.mutations_performed
  )
}

function New-DanioRehearsalReport {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$RehearsalRunId,
    [Parameter(Mandatory = $true)][string]$TaskId,
    [Parameter(Mandatory = $true)][string]$CreatedAtUtc,
    [Parameter(Mandatory = $true)][string]$RepositoryRoot,
    [Parameter(Mandatory = $true)][string]$BaseCommit,
    [Parameter(Mandatory = $true)][int64]$ProposedAutonomousUnits,
    [Parameter(Mandatory = $true)][string]$ProposedWorkUnitId,
    [Parameter(Mandatory = $true)][string[]]$ProposedLedgerRowIds,
    [Parameter(Mandatory = $true)]$Before,
    [Parameter(Mandatory = $true)]$After,
    [Parameter(Mandatory = $true)]$LaunchPreview,
    [Parameter(Mandatory = $true)]$ClaimPreview,
    [Parameter(Mandatory = $true)]$CloseoutPreview
  )

  $normalizedRoot = ConvertTo-DanioForwardSlashPath -Path $RepositoryRoot
  if (
    -not (Test-DanioSafeIdentifier -Value $RehearsalRunId) -or
    -not (Test-DanioSafeIdentifier -Value $TaskId) -or
    -not (Test-DanioStrictUtc -Value $CreatedAtUtc) -or
    -not (Test-DanioAbsoluteWindowsPath -Value $normalizedRoot) -or
    -not (Test-DanioGitOid -Value $BaseCommit) -or
    $ProposedAutonomousUnits -lt 1 -or
    -not (Test-DanioSafeIdentifier -Value $ProposedWorkUnitId) -or
    $ProposedLedgerRowIds.Count -lt 1
  ) {
    throw "REHEARSAL_INPUT_INVALID: rehearsal identity, time, root, commit, budget, or work unit is invalid."
  }

  $seenLedgerRows = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
  foreach ($ledgerRowId in @($ProposedLedgerRowIds)) {
    if (
      $ledgerRowId -isnot [string] -or
      $ledgerRowId -cnotmatch '^DCL-[A-Z0-9]+-[0-9]{3}$' -or
      -not $seenLedgerRows.Add($ledgerRowId)
    ) {
      throw "REHEARSAL_INPUT_INVALID: proposed ledger rows are malformed or duplicated."
    }
  }

  if (
    -not (Test-DanioRehearsalObservation -Observation $Before) -or
    -not (Test-DanioRehearsalObservation -Observation $After)
  ) {
    throw "REHEARSAL_OBSERVATION_INVALID: before or after observation is malformed."
  }
  if ((ConvertTo-DanioCanonicalJson -Value $Before) -cne (ConvertTo-DanioCanonicalJson -Value $After)) {
    throw "REHEARSAL_OBSERVATION_CHANGED: before and after repository observations differ."
  }

  if (
    -not (Test-DanioRehearsalPreview -Preview $LaunchPreview -ExpectedCode "LAUNCH_NOT_AUTHORIZED") -or
    -not (Test-DanioRehearsalPreview -Preview $ClaimPreview -ExpectedCode "AUTHORITY_CONFLICT") -or
    -not (Test-DanioRehearsalPreview -Preview $CloseoutPreview -ExpectedCode "AUTHORITY_CONFLICT")
  ) {
    throw "REHEARSAL_PREVIEW_INVALID: Launch, Claim, or Closeout did not return the required no-mutation blocking code."
  }

  return [pscustomobject][ordered]@{
    document_type = "danio_autonomous_completion_rehearsal_report"
    schema_version = 1
    rehearsal_run_id = $RehearsalRunId
    task_id = $TaskId
    created_at_utc = $CreatedAtUtc
    repository_root = $normalizedRoot
    base_commit = $BaseCommit
    proposed = [pscustomobject][ordered]@{
      autonomous_units = $ProposedAutonomousUnits
      work_unit_id = $ProposedWorkUnitId
      ledger_row_ids = @($ProposedLedgerRowIds)
    }
    before = Copy-DanioJsonValue -Value $Before
    after = Copy-DanioJsonValue -Value $After
    previews = [pscustomobject][ordered]@{
      launch = Copy-DanioJsonValue -Value $LaunchPreview
      claim = Copy-DanioJsonValue -Value $ClaimPreview
      closeout = Copy-DanioJsonValue -Value $CloseoutPreview
    }
    mutations = [pscustomobject][ordered]@{
      repository_files = $false
      index = $false
      local_refs = $false
      remote_refs = $false
      worktrees = $false
      successor_tasks = $false
      android_runtime = $false
      figma = $false
      external_services = $false
    }
    overall_status = "pass"
  }
}

Export-ModuleMember -Function @(
  "Resolve-DanioRepositoryRoot",
  "Get-DanioRepositoryObservation",
  "Read-DanioLedgerClosureRows",
  "Test-DanioLedgerClosureRows",
  "Test-DanioRunnerCompatibility",
  "New-DanioSynchronizationReceipt",
  "Test-DanioSynchronizationReceipt",
  "Test-DanioRunState",
  "Test-DanioRunStateTransition",
  "Test-DanioCompletionReadiness",
  "Test-DanioAutonomousReadiness",
  "New-DanioWriterClaimPlan",
  "New-DanioRehearsalReport"
)
