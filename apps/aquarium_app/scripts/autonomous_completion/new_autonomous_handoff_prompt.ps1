[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("Launch", "Successor")]
  [string]$PromptKind,
  [Parameter(Mandatory = $true)][string]$RunStateJson,
  [Parameter(Mandatory = $true)][string]$ReadinessReportJson,
  [Parameter(Mandatory = $true)][string]$TaskCapabilitiesJson,
  [Parameter(Mandatory = $true)][string]$SavedProjectJson,
  [string]$RepositoryRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "DanioAutonomousCompletion.psm1"
Import-Module -Name $modulePath -Force
$stateRelativePath = "apps/aquarium_app/docs/agent/autonomous_completion/phone_completion_run_state.json"

function Format-StrictUtc {
  param([Parameter(Mandatory = $true)][DateTimeOffset]$Value)

  return $Value.ToUniversalTime().ToString(
    "yyyy-MM-dd'T'HH:mm:ss.fffffff'Z'",
    [Globalization.CultureInfo]::InvariantCulture
  )
}

function Test-StrictUtc {
  param([Parameter(Mandatory = $true)]$Value)

  if ($Value -isnot [string] -or $Value.Length -ne 28) {
    return $false
  }
  $parsed = [DateTimeOffset]::MinValue
  return [DateTimeOffset]::TryParseExact(
    $Value,
    "yyyy-MM-dd'T'HH:mm:ss.fffffff'Z'",
    [Globalization.CultureInfo]::InvariantCulture,
    [Globalization.DateTimeStyles]::AssumeUniversal,
    [ref]$parsed
  )
}

function Test-ExactProperties {
  param(
    [Parameter(Mandatory = $true)]$Value,
    [Parameter(Mandatory = $true)][string[]]$Expected
  )

  if ($Value -isnot [pscustomobject]) {
    return $false
  }
  $actual = @($Value.PSObject.Properties.Name)
  if ($actual.Count -ne $Expected.Count) {
    return $false
  }
  foreach ($name in $Expected) {
    if ($actual -cnotcontains $name) {
      return $false
    }
  }
  return $true
}

function Test-Boolean {
  param($Value)

  return $null -ne $Value -and $Value.GetType() -eq [bool]
}

function ConvertTo-ForwardSlashPath {
  param([Parameter(Mandatory = $true)][string]$Path)

  return $Path.Replace("\", "/").TrimEnd("/")
}

function New-Check {
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

function New-RejectedReport {
  param(
    [Parameter(Mandatory = $true)][string]$GeneratedAtUtc,
    [Parameter(Mandatory = $true)][string]$Code,
    [Parameter(Mandatory = $true)][string]$Detail,
    $ObservedMode
  )

  return [pscustomobject][ordered]@{
    document_type = "danio_handoff_prompt_report"
    schema_version = 1
    prompt_kind = $PromptKind
    generated_at_utc = $GeneratedAtUtc
    accepted = $false
    code = $Code
    observed_state_mode = $ObservedMode
    state_mode = $null
    title = $null
    marker = $null
    prompt = $null
    runner_compatible = $false
    explicit_launch_task_capable = $false
    automatic_successor_capable = $false
    mutations_performed = $false
    checks = @(
      New-Check -Code $Code -Passed $false -Detail $Detail
    )
  }
}

function Invoke-ReadOnlyGit {
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

function Test-LiveStateBinding {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)]$State,
    [Parameter(Mandatory = $true)][string]$SuppliedStateJson
  )

  $expectedRepository = ConvertTo-ForwardSlashPath -Path ([string]$State.authorization.repository_root)
  $actualRepository = ConvertTo-ForwardSlashPath -Path $Root
  if (-not [string]::Equals($expectedRepository, $actualRepository, [StringComparison]::OrdinalIgnoreCase)) {
    return $false
  }

  $branch = Invoke-ReadOnlyGit -Root $Root -Arguments @("branch", "--show-current")
  $head = Invoke-ReadOnlyGit -Root $Root -Arguments @("rev-parse", "HEAD")
  $main = Invoke-ReadOnlyGit -Root $Root -Arguments @("rev-parse", "main")
  $origin = Invoke-ReadOnlyGit -Root $Root -Arguments @("rev-parse", "origin/main")
  $status = Invoke-ReadOnlyGit -Root $Root -Arguments @("--no-optional-locks", "status", "--short", "-uall")
  foreach ($probe in @($branch, $head, $main, $origin, $status)) {
    if ($probe.exit_code -ne 0) {
      return $false
    }
  }
  if (
    $branch.output -cne "main" -or
    $head.output -cne $main.output -or
    $head.output -cne $origin.output -or
    -not [string]::IsNullOrWhiteSpace($status.output)
  ) {
    return $false
  }

  $statePath = Join-Path $Root $stateRelativePath
  if (-not (Test-Path -LiteralPath $statePath -PathType Leaf)) {
    return $false
  }
  $workingState = Get-Content -Raw -LiteralPath $statePath
  if ($workingState.Trim() -cne $SuppliedStateJson.Trim()) {
    return $false
  }
  $committedState = Invoke-ReadOnlyGit -Root $Root -Arguments @("show", "HEAD`:$stateRelativePath")
  return (
    $committedState.exit_code -eq 0 -and
    $committedState.output.Trim() -ceq $SuppliedStateJson.Trim()
  )
}

function New-PasteReadyPrompt {
  param(
    [Parameter(Mandatory = $true)]$State,
    [Parameter(Mandatory = $true)][string]$Marker,
    [Parameter(Mandatory = $true)][string]$Kind
  )

  $ledgerRows = @($State.cursor.ledger_row_ids) -join ", "
  $checkpoint = if ($null -eq $State.last_verified_checkpoint) {
    "none"
  } else {
    "$($State.last_verified_checkpoint.product_commit) at $($State.last_verified_checkpoint.evidence_manifest_path)"
  }
  $claimSource = if ($Kind -ceq "Launch") { "ready" } else { "handoff_ready" }
  return @"
Load and follow `$danio-autonomous-slice-runner first.
Then load and follow `$verified-slice-runner underneath it.

Continuation mode: autonomous chain approved
Autonomous chain mode approved for this committed phone completion run only.
Operational marker: $Marker
Prompt kind: $Kind

Saved Codex project:
$($State.authorization.saved_project_root)

Actual repository root:
$($State.authorization.repository_root)

Live run-state path:
$stateRelativePath

Expected state revision: $($State.state_revision)
Required source mode: $claimSource
Authorized work unit: $($State.cursor.work_unit_id)
Ledger rows: $ledgerRows
Remaining units including this task: $($State.budget.remaining_units_including_current)
Last verified checkpoint: $checkpoint

Rebuild truth from the installed runner skills, repo-owned authorities, the
committed live state, git fetch --prune, clean status, and main...origin/main
alignment. One coordinator owns all repository, Git, installed-skill, durable
evidence, and task writes. Parallel agents are repository-read-only auditors.

Before product audit or edits, perform fresh synchronization and win the
$claimSource -> active compare-and-swap writer claim. Stop without mutation on
dirty or diverged Git, stale or mismatched state, ambiguous authority, runner
incompatibility, unavailable project binding, missing task capability, unknown
task-create outcome, paid/cloud/account/secret requirements, runtime ownership
conflict, product decision, scope drift, or repeated gate failure.

Keep tablet, cloud, accounts, providers, premium, store/deploy, public release,
and iOS parked. Do not decrement budget during task transfer and do not create
a duplicate task.
"@
}

$generatedAtUtc = Format-StrictUtc -Value ([DateTimeOffset]::UtcNow)
$report = $null
$exitCode = 1
$observedMode = $null

try {
  try {
    $state = $RunStateJson | ConvertFrom-Json
  } catch {
    throw "RUN_STATE_INVALID: run-state JSON is malformed."
  }
  if ($state.PSObject.Properties.Name -ccontains "mode") {
    $observedMode = [string]$state.mode
  }
  $stateValidation = Test-DanioRunState -State $state
  if (-not $stateValidation.valid) {
    throw "RUN_STATE_INVALID: $($stateValidation.code)."
  }

  $expectedMode = if ($PromptKind -ceq "Launch") { "ready" } else { "handoff_ready" }
  if ([string]$state.mode -cne $expectedMode) {
    throw "PROMPT_KIND_STATE_INVALID: $PromptKind cannot render from '$($state.mode)'."
  }
  if ($PromptKind -ceq "Successor" -and [int64]$state.handoff_generation -lt 1) {
    throw "PROMPT_KIND_STATE_INVALID: Successor requires a positive handoff generation."
  }

  try {
    $readiness = $ReadinessReportJson | ConvertFrom-Json
  } catch {
    throw "READINESS_REPORT_INVALID: readiness JSON is malformed."
  }
  $readinessFields = @(
    "document_type",
    "schema_version",
    "intent",
    "checked_at_utc",
    "eligible",
    "stop_reason_code",
    "checks"
  )
  if (-not (Test-ExactProperties -Value $readiness -Expected $readinessFields)) {
    throw "READINESS_REPORT_INVALID: readiness fields are not exact."
  }
  $expectedIntent = if ($PromptKind -ceq "Launch") { "Launch" } else { "Claim" }
  if (
    [string]$readiness.document_type -cne "danio_readiness_report" -or
    [int64]$readiness.schema_version -ne 1 -or
    [string]$readiness.intent -cne $expectedIntent -or
    -not (Test-StrictUtc -Value $readiness.checked_at_utc) -or
    -not (Test-Boolean -Value $readiness.eligible) -or
    @($readiness.checks).Count -lt 1
  ) {
    throw "READINESS_REPORT_INVALID: readiness shape or intent is invalid."
  }
  foreach ($check in @($readiness.checks)) {
    if (
      -not (Test-ExactProperties -Value $check -Expected @("code", "status", "detail")) -or
      [string]$check.code -cnotmatch '^[A-Z][A-Z0-9_]*$' -or
      @("pass", "fail") -cnotcontains [string]$check.status -or
      [string]::IsNullOrWhiteSpace([string]$check.detail)
    ) {
      throw "READINESS_REPORT_INVALID: readiness checks are invalid."
    }
  }
  if (
    [bool]$readiness.eligible -and
    (
      $null -ne $readiness.stop_reason_code -or
      @($readiness.checks | Where-Object { [string]$_.status -cne "pass" }).Count -gt 0
    )
  ) {
    throw "READINESS_REPORT_INVALID: eligible readiness is contradictory."
  }
  if (
    -not [bool]$readiness.eligible -and
    (
      [string]$readiness.stop_reason_code -cnotmatch '^[A-Z][A-Z0-9_]*$' -or
      @($readiness.checks | Where-Object { [string]$_.status -ceq "fail" }).Count -lt 1
    )
  ) {
    throw "READINESS_REPORT_INVALID: ineligible readiness is contradictory."
  }

  try {
    $taskCapabilities = $TaskCapabilitiesJson | ConvertFrom-Json
  } catch {
    throw "TASK_CAPABILITIES_INVALID: task-capability JSON is malformed."
  }
  $taskCapabilityFields = @("list_threads", "read_thread", "create_thread.project_target")
  if (-not (Test-ExactProperties -Value $taskCapabilities -Expected $taskCapabilityFields)) {
    throw "TASK_CAPABILITIES_INVALID: task-capability fields are not exact."
  }
  foreach ($field in $taskCapabilityFields) {
    if (-not (Test-Boolean -Value $taskCapabilities.PSObject.Properties[$field].Value)) {
      throw "TASK_CAPABILITIES_INVALID: task-capability values must be boolean."
    }
  }

  try {
    $savedProject = $SavedProjectJson | ConvertFrom-Json
  } catch {
    throw "SAVED_PROJECT_INVALID: saved-project JSON is malformed."
  }
  if (-not (Test-ExactProperties -Value $savedProject -Expected @("project_id", "root"))) {
    throw "SAVED_PROJECT_INVALID: saved-project fields are not exact."
  }
  $projectUnavailable = $null -eq $savedProject.project_id -and $null -eq $savedProject.root
  $projectPresent = (
    $savedProject.project_id -is [string] -and
    -not [string]::IsNullOrWhiteSpace([string]$savedProject.project_id) -and
    $savedProject.root -is [string] -and
    [string]$savedProject.root -cmatch '^(?!.*\\)(?!.*(?:^|/)\.\.(?:/|$))[A-Za-z]:/.+$'
  )
  if (-not $projectUnavailable -and -not $projectPresent) {
    throw "SAVED_PROJECT_INVALID: project identity must be all-null or exact."
  }

  $resolvedRoot = Resolve-DanioRepositoryRoot -RepositoryRoot $RepositoryRoot
  $runnerManifestPath = Join-Path $resolvedRoot "apps/aquarium_app/docs/agent/autonomous_completion/runner_compatibility.json"
  try {
    $runnerManifest = Get-Content -Raw -LiteralPath $runnerManifestPath | ConvertFrom-Json
    $runnerValidation = Test-DanioRunnerCompatibility -Manifest $runnerManifest
  } catch {
    $runnerValidation = [pscustomobject]@{
      valid = $false
      code = "RUNNER_INCOMPATIBLE"
      details = @("Runner manifest could not be validated.")
    }
    $runnerManifest = $null
  }
  $runnerCompatible = $runnerValidation.valid -and [string]$runnerValidation.code -ceq "RUNNER_COMPATIBLE"
  $launchAuthorized = (
    $runnerCompatible -and
    $null -ne $runnerManifest -and
    (Test-Boolean -Value $runnerManifest.authorizes_launch) -and
    [bool]$runnerManifest.authorizes_launch
  )

  $readinessTime = [DateTimeOffset]::ParseExact(
    [string]$readiness.checked_at_utc,
    "yyyy-MM-dd'T'HH:mm:ss.fffffff'Z'",
    [Globalization.CultureInfo]::InvariantCulture,
    [Globalization.DateTimeStyles]::AssumeUniversal
  )
  $readinessAge = ([DateTimeOffset]::UtcNow - $readinessTime.ToUniversalTime()).TotalSeconds
  $readinessFresh = $readinessAge -ge 0 -and $readinessAge -le 120
  $toolsAvailable = (
    [bool]$taskCapabilities.list_threads -and
    [bool]$taskCapabilities.read_thread -and
    [bool]$taskCapabilities.PSObject.Properties["create_thread.project_target"].Value
  )
  $savedProjectRoot = if ($projectPresent) {
    ConvertTo-ForwardSlashPath -Path ([string]$savedProject.root)
  } else {
    ""
  }
  $authorizedProjectRoot = ConvertTo-ForwardSlashPath `
    -Path ([string]$state.authorization.saved_project_root)
  $savedProjectBound = (
    $projectPresent -and
    [string]::Equals(
      $savedProjectRoot,
      $authorizedProjectRoot,
      [StringComparison]::OrdinalIgnoreCase
    )
  )
  $liveStateBound = Test-LiveStateBinding `
    -Root $resolvedRoot `
    -State $state `
    -SuppliedStateJson $RunStateJson
  $positiveBudget = [int64]$state.budget.remaining_units_including_current -gt 0
  $selectedCapability = (
    $runnerCompatible -and
    $launchAuthorized -and
    [bool]$readiness.eligible -and
    $readinessFresh -and
    $toolsAvailable -and
    $savedProjectBound -and
    $liveStateBound -and
    $positiveBudget
  )

  $marker = if ($PromptKind -ceq "Launch") {
    "$($state.run_id)/launch/0"
  } else {
    "$($state.run_id)/$($state.handoff_generation)"
  }
  $title = if ($PromptKind -ceq "Launch") {
    "Danio autonomous phone launch [$marker]"
  } else {
    "Danio autonomous phone successor [$marker]"
  }
  $prompt = New-PasteReadyPrompt -State $state -Marker $marker -Kind $PromptKind
  $runnerDetail = if (@($runnerValidation.details).Count -gt 0) {
    [string]($runnerValidation.details -join "; ")
  } else {
    "The installed runner bytes match the pinned compatibility manifest."
  }
  $checks = @(
    New-Check -Code "RUN_STATE_VALID" -Passed $true -Detail "The supplied run state is structurally valid for $PromptKind."
    New-Check -Code "RUNNER_COMPATIBLE" -Passed $runnerCompatible -Detail $runnerDetail
    New-Check -Code "LAUNCH_AUTHORIZED" -Passed $launchAuthorized -Detail "The committed runner manifest must authorize launch from rehearsal proof."
    New-Check -Code "READINESS_ELIGIBLE" -Passed ([bool]$readiness.eligible) -Detail "The $expectedIntent readiness report must be eligible."
    New-Check -Code "READINESS_FRESH" -Passed $readinessFresh -Detail "The readiness report must be no older than 120 seconds."
    New-Check -Code "TASK_CAPABILITIES" -Passed $toolsAvailable -Detail "list_threads, read_thread, and project-targeted create_thread must all be available."
    New-Check -Code "SAVED_PROJECT_BOUND" -Passed $savedProjectBound -Detail "The saved-project root must exactly match the committed authorization."
    New-Check -Code "LIVE_STATE_BOUND" -Passed $liveStateBound -Detail "The exact supplied live state must be committed on clean aligned main."
    New-Check -Code "POSITIVE_BUDGET" -Passed $positiveBudget -Detail "The remaining unit budget must be positive."
  )
  $report = [pscustomobject][ordered]@{
    document_type = "danio_handoff_prompt_report"
    schema_version = 1
    prompt_kind = $PromptKind
    generated_at_utc = $generatedAtUtc
    accepted = $true
    code = "HANDOFF_PROMPT_GENERATED"
    observed_state_mode = [string]$state.mode
    state_mode = [string]$state.mode
    title = $title
    marker = $marker
    prompt = $prompt
    runner_compatible = $runnerCompatible
    explicit_launch_task_capable = ($PromptKind -ceq "Launch" -and $selectedCapability)
    automatic_successor_capable = ($PromptKind -ceq "Successor" -and $selectedCapability)
    mutations_performed = $false
    checks = $checks
  }
  $exitCode = 0
} catch {
  $message = $_.Exception.Message
  $code = if ($message -match '^([A-Z][A-Z0-9_]*):') {
    $Matches[1]
  } else {
    "HANDOFF_PROMPT_INVALID"
  }
  $report = New-RejectedReport `
    -GeneratedAtUtc $generatedAtUtc `
    -Code $code `
    -Detail $message `
    -ObservedMode $observedMode
  $exitCode = 1
}

Write-Output ($report | ConvertTo-Json -Depth 100 -Compress)
exit $exitCode
