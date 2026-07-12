# Danio Autonomous Phone Completion Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> `superpowers:executing-plans` to implement this plan task-by-task. Every
> execution unit must also load `$danio-autonomous-slice-runner`, then
> `$verified-slice-runner`. Use `superpowers:test-driven-development` for
> scripts or behavior, `superpowers:verification-before-completion` before
> closeout, and `superpowers:finishing-a-development-branch` for Git closeout.
> One coordinator owns every repository write. Read-only auditors may run in
> parallel; write subagents are prohibited for this program.

**Goal:** Implement and prove the fail-closed coordination layer needed to run
Danio's remaining phone complete-local work as bounded, sequential, verified
Codex units without losing repository truth, budget integrity, or user control.

**Architecture:** Treat the accepted phone completion program as the ordered
scope authority, the closure ledger as the row-level issue authority, and live
Git/source/tests as factual truth. Add strict repository contracts and pure
PowerShell validators before adding any Git mutation. Keep installed-runner
changes separately reviewed, keep task creation capability-gated, and permit
activation only after a no-product-change rehearsal proves zero side effects.

**Tech Stack:** Markdown contracts, JSON Schema draft 2020-12, JSON fixtures,
Windows PowerShell 5.1-compatible scripts, Git CLI, Flutter/Dart contract tests,
the existing Danio quality-gate wrapper, and project-scoped Codex task tools.

## Global Constraints

- Product scope is Android phone complete-local only.
- Tablet implementation, tablet polish, and tablet performance remain parked.
- Cloud, accounts, hosted sync, provider/API-key expansion, premium,
  store/deploy, public release, and iOS remain parked.
- Optional AI must remain useful and calm without a provider key.
- One writing coordinator owns all repository edits, staging, commits, merges,
  pushes, and task creation.
- Parallel agents are repository-read-only auditors only. The Android QA owner
  may mutate an explicitly owned runtime but may not write repository files.
- No app Dart behavior, Android runtime, Figma file, paid service, account,
  secret, or external product state changes during Tasks 1 through 12.
- Every script must be ASCII-only, use `[CmdletBinding()]`,
  `Set-StrictMode -Version Latest`, `$ErrorActionPreference = "Stop"`, and
  `-LiteralPath` for filesystem paths.
- Machine scripts write exactly one compact JSON object to stdout. Diagnostics
  go to stderr or structured `checks`; exit `0` means accepted and exit `1`
  means rejected with a stable code.
- Schemas use `additionalProperties: false`, repository-relative forward-slash
  paths, strict UTC timestamps, explicit nulls, and no self-referential future
  commit hashes.
- The current user authorization is `Autonomous chain mode approved` with 20
  sequential units total, including the planning unit that produced this file.
  A clean closeout of this planning unit leaves 19. Units are sequential, not
  parallel.
- Until Task 12 passes and Task 13 activates the run, continuation uses only
  explicit current-task user authorization and paste-ready/project-scoped
  bootstrap handoff. The current chain template must not claim operational
  automatic chaining.

---

## Current Baseline

- Approved design commit:
  `81be4c93444cfd47a80cf47730cbc76e9b8464ff`.
- Planning baseline before this file: clean aligned `main` at
  `db51e24a7f1a442e024723f9f8d3791e9fce1c0b`.
- Saved Codex project:
  `C:\Users\larki\OneDrive\Documents\App Projects\Danio Aquarium App Project`.
- Repository root:
  `C:\Users\larki\OneDrive\Documents\App Projects\Danio Aquarium App Project\repo`.
- Highest product lane after workflow activation: `DCL-DR-001` through
  `DCL-DR-004`.
- Launch is currently blocked by `AUTHORITY_CONFLICT` and
  `RUNNER_INCOMPATIBLE`.

## File Structure

The implementation owns these focused surfaces:

```text
repo/
  .codex/
    config.toml
    agents/
      danio_android_qa_owner.toml
      danio_product_auditor.toml
      danio_quality_auditor.toml
      danio_reviewer.toml
      danio_ui_auditor.toml

  apps/aquarium_app/
    docs/agent/
      AUTONOMOUS_PHONE_COMPLETION_RUNBOOK.md
      autonomous_completion/
        runner_compatibility.json
        phone_completion_run_state.json          # created only at activation
        schemas/
          run_state.schema.json
          synchronization_receipt.schema.json
          readiness_report.schema.json
          transition_validation_report.schema.json
          writer_claim_plan.schema.json
          runner_compatibility.schema.json
          evidence_manifest.schema.json
          rehearsal_report.schema.json
          handoff_prompt_report.schema.json
        evidence/                                # real manifests only
      plans/
        2026-07-11-autonomous-phone-completion-operating-model-design.md
        2026-07-11-autonomous-phone-completion-workflow-implementation-plan.md

    scripts/autonomous_completion/
      DanioAutonomousCompletion.psm1
      sync_autonomous_completion.ps1
      check_autonomous_completion_readiness.ps1
      validate_autonomous_completion_transition.ps1
      plan_autonomous_writer_claim.ps1
      invoke_autonomous_writer_claim.ps1
      commit_autonomous_completion_transition.ps1
      new_autonomous_handoff_prompt.ps1
      run_autonomous_completion_rehearsal.ps1

    test/scripts/
      autonomous_completion_script_test.dart
      autonomous_completion_behavior_test.ps1
      autonomous_completion_git_fixture_test.ps1
      fixtures/autonomous_completion/
        inactive_run_state.json
        ready_run_state.json
        active_run_state.json
        handoff_ready_run_state.json
        finalizing_run_state.json
        complete_run_state.json
        runner_compatibility_unpinned.json
```

Do not create placeholder evidence files. Evidence appears only after a real
verified product/workflow checkpoint exists.

## Stable Interfaces

The pure module exports exactly these functions:

```text
Resolve-DanioRepositoryRoot
Get-DanioRepositoryObservation
Read-DanioLedgerClosureRows
Test-DanioLedgerClosureRows
Test-DanioRunnerCompatibility
New-DanioSynchronizationReceipt
Test-DanioSynchronizationReceipt
Test-DanioRunState
Test-DanioRunStateTransition
Test-DanioCompletionReadiness
Test-DanioAutonomousReadiness
New-DanioWriterClaimPlan
New-DanioRehearsalReport
```

The command parameters are:

```powershell
sync_autonomous_completion.ps1:
  RepositoryRoot: optional absolute string
  InvocationNonce: required 32-character lowercase hexadecimal string

check_autonomous_completion_readiness.ps1:
  Intent: Launch | Claim | Closeout | Finalization | AdministrativeSync
  SynchronizationReceiptJson: required JSON string
  ExpectedInvocationNonce: required 32-character hexadecimal string
  RepositoryRoot: optional absolute string
  MaxReceiptAgeSeconds: integer, default 120
  RuntimeRequired: optional switch
  EvidenceManifestPath: optional repository-relative path; required only for
    Finalization and loaded from the aligned HEAD checkpoint
  LeaseReleaseJson: optional compact JSON; required only for Finalization and
    limited to exact owner-token, Android-release, and process-release proof

validate_autonomous_completion_transition.ps1:
  Source: Staged | Committed
  RepositoryRoot: optional absolute string
  ExpectedParentCommit: optional 40-character Git object ID
  ExpectedStagedTreeHash: required Git tree object ID for Source=Staged;
    optional comparison input for Source=Committed
  Commit: Git revision string, default HEAD
  EvidenceManifestPath: optional repository-relative path; validation always
    loads it from the exact parent commit, never from the candidate tree
  LeaseReleaseJson: optional compact JSON; required for owner-releasing
    transitions and rejected for transitions that retain or have no owner

plan_autonomous_writer_claim.ps1:
  ReadinessReportJson: required JSON string
  TaskId: required stable Codex task identifier
  ExpectedStateRevision: required positive integer
  RepositoryRoot: optional absolute string
  WorktreeRoot: optional absolute string

invoke_autonomous_writer_claim.ps1:
  ClaimPlanJson: required JSON string from plan_autonomous_writer_claim.ps1
  RepositoryRoot: optional absolute string
  TestTransportOutcome: optional accepted | rejected | unknown_accepted |
    unknown_not_accepted | unknown_unresolved; rejected unless
    DANIO_AUTONOMY_TEST_MODE=1 and RepositoryRoot is a disposable fixture

commit_autonomous_completion_transition.ps1:
  NextRunStateJson: required JSON string
  ExpectedStateRevision: required positive integer
  ExpectedOriginMainCommit: required 40-character Git object ID
  EvidenceManifestPath: optional repository-relative path; required for
    closeout, pause, finalize, and complete; historical-only or null for stop
    and finalization_stop under Task 9's emergency-stop rules
  LeaseReleaseJson: optional compact JSON; required for closeout, pause, stop,
    finalization_stop, and complete
  RepositoryRoot: optional absolute string
  TestTransportOutcome: same fixture-only contract as writer claim

new_autonomous_handoff_prompt.ps1:
  PromptKind: Launch | Successor
  RunStateJson: required JSON string
  ReadinessReportJson: required JSON string
  TaskCapabilitiesJson: required strict JSON object with exactly the boolean
    properties list_threads, read_thread, and create_thread.project_target;
    these report live task-tool schema availability without claiming runner
    incompatibility
  SavedProjectJson: required strict JSON object with exactly project_id and
    root; both are null when identity is unavailable, otherwise project_id is
    a nonempty string and root is an absolute forward-slash Windows path;
    mixed null/non-null identity is invalid
  RepositoryRoot: optional absolute string

  Launch readiness binding: intent Launch; a generated fallback is allowed
    while ineligible, but explicit_launch_task_capable is true only when the
    report is eligible and fresh, the committed runner manifest authorizes
    launch, and the exact live ready state is clean and aligned
  Successor readiness binding: intent Claim; a generated fallback is allowed
    while ineligible, but automatic_successor_capable is true only when the
    report is eligible and fresh, the committed runner manifest authorizes
    launch, and the exact live handoff_ready state is clean and aligned

  Output: the handoff prompt report records accepted, code, the observed mode,
    nullable eligible state_mode/title/marker/prompt values, independent runner
    and selected task capability booleans, checks, and mutations_performed:
    false. Kind/state mismatch or malformed strict input returns accepted:
    false, a stable code, null generated fields, at least one failed check, and
    exit 1. A valid kind/state fallback returns accepted: true, the complete
    prompt, honest false capability checks, and exit 0 without state change.

run_autonomous_completion_rehearsal.ps1:
  SynchronizationReceiptJson: required JSON string
  ExpectedInvocationNonce: required 32-character hexadecimal string
  RehearsalRunId: required stable rehearsal identifier
  TaskId: required stable Codex task identifier
  ProposedAutonomousUnits: required positive integer
  ProposedWorkUnitId: required finite work-unit identifier
  ProposedLedgerRowIds: required nonempty string array
  RepositoryRoot: optional absolute string
  WorktreeRoot: optional absolute string
  RuntimeRequired: optional switch
```

Only `sync_autonomous_completion.ps1`,
`invoke_autonomous_writer_claim.ps1`, and
`commit_autonomous_completion_transition.ps1` may mutate Git. The first only
updates remote-tracking refs. The other two remain disabled until their fixture
race and unknown-outcome tests pass.

`commit_autonomous_completion_transition.ps1` owns exactly one state or
terminal commit push. The evidence checkpoint is a separate already committed,
pushed, and aligned parent while the owner remains active/finalizing. The
transition command never creates or pushes the evidence checkpoint and its
`push_attempt_count` is therefore at most one.

## Execution Unit Map

| Sequential unit | Plan tasks | Exit gate |
| --- | --- | --- |
| Planning unit (current) | This implementation plan and closeout | Docs profile; clean pushed `main`; remaining budget 19 |
| Setup unit 1 | Task 1 | Authority tests and Docs profile |
| Setup unit 2 | Tasks 2-3 | Schema/behavior tests and Docs profile |
| Setup unit 3 | Tasks 4-5 | Receipt/readiness/claim-plan fixture tests and Docs profile |
| Setup unit 4 | Tasks 6-7 | Skill validation, independent review, agent-policy tests, Docs profile |
| Setup unit 5 | Task 8 | Disposable writer-claim race, unknown-outcome tests, actual-length toolchain proof, and Docs profile |
| Setup unit 6 | Task 9 | Evidence, closeout, exactly-once charging, finalization fixtures, and Docs profile |
| Setup unit 7 | Tasks 10-11 | Handoff capability tests and integrated Docs profile |
| Setup unit 8 | Task 12 | Zero-side-effect rehearsal committed on clean pushed `main`; launch still inactive |
| Setup unit 9 | Task 13 | Fresh post-rehearsal activation gate and clean pushed live run state |
| Product units | Phone program Phases 1-7 | Lane-specific gates from `QUALITY_LADDER.md` |

If a setup unit expands beyond its risk boundary, split it and consume another
unit. Never compress work merely to preserve product-unit budget.

---

### Task 1: Contain Chaining And Reconcile Canonical Authority

**Files:**

- Modify: `AGENTS.md`
- Modify: `apps/aquarium_app/docs/agent/AUTONOMOUS_CHAIN_HANDOFF_PROMPT.md`
- Modify: `apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md`
- Modify: `apps/aquarium_app/docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md`
- Modify: `apps/aquarium_app/docs/agent/FINISH_MAP.md`
- Modify: `apps/aquarium_app/docs/agent/VERIFIED_SLICE_EXECUTION_CONTRACT.md`
- Modify: `apps/aquarium_app/docs/agent/QUALITY_LADDER.md`
- Modify: `apps/aquarium_app/docs/agent/plans/2026-07-11-phone-complete-local-completion-program.md`
- Modify: `apps/aquarium_app/docs/agent/plans/2026-07-11-autonomous-phone-completion-operating-model-design.md`
- Modify: `apps/aquarium_app/test/copy/current_docs_local_truth_test.dart`

**Interfaces:**

- Produces the only ordered phase authority: the phone completion program.
- Produces ledger closure enum `open|closed|parked|decision_required` in a
  formal `Closure State` Markdown-table column.
- Produces an exact category-to-ledger-ID map in `FINISH_MAP.md`.
- Produces the temporary machine-readable bootstrap-budget block in
  `ACTIVE_HANDOFF.md`; it is authoritative only until Task 13 creates live run
  state, then becomes a historical pointer.
- Leaves automatic successor creation disabled.

- [ ] **Step 1: Add failing authority and closure-state guard tests**

Add a strict table parser to `current_docs_local_truth_test.dart`:

```dart
List<Map<String, String>> _markdownRows(String source, String heading) {
  final section = source.split('## $heading').last.split('\n## ').first;
  final lines = section
      .split('\n')
      .where((line) => line.trim().startsWith('|'))
      .toList();
  final headers = lines.first
      .split('|')
      .map((cell) => cell.trim())
      .where((cell) => cell.isNotEmpty)
      .toList();
  return lines.skip(2).map((line) {
    final cells = line
        .split('|')
        .map((cell) => cell.trim())
        .where((cell) => cell.isNotEmpty)
        .toList();
    return {for (var index = 0; index < headers.length; index++)
      headers[index]: cells[index]};
  }).toList();
}
```

Assert:

```dart
const allowedStates = {'open', 'closed', 'parked', 'decision_required'};
expect(rows.map((row) => row['ID']).toSet().length, rows.length);
expect(rows.every((row) => allowedStates.contains(row['Closure State'])), isTrue);
expect(_statesFor(rows, parkedIds), everyElement('parked'));
expect(_statesFor(rows, acceptedOrArchivedIds), everyElement('closed'));
expect(rows.map((row) => row['ID']).toSet(), containsAll(programLedgerIds));
```

Define `parkedIds`, `acceptedOrArchivedIds`, and `programLedgerIds` as explicit
sets. Do not permanently assert 18 open or zero decision-required rows: those
counts are the bootstrap observation and must change as work closes or a real
product decision blocks progress.

Also assert that the phone program owns phase order, `DCL-PREF-001` is in
Phase 2, `DCL-RC-001` is last, the generic Finish Map selector defers to the
program, and the active chain prompt says automatic creation is disabled.
Parse the bootstrap-budget JSON block and assert `total = consumed + remaining`,
the planning unit is consumed once, and the operational state path is null.

- [ ] **Step 2: Run the guard and prove RED**

Run:

```powershell
flutter test test/copy/current_docs_local_truth_test.dart --reporter compact
```

Expected: FAIL because the ledger has no `Closure State` column and the chain
prompt still claims operational autonomous chaining.

- [ ] **Step 3: Reconcile authority and closure state**

Apply these exact closure states:

```text
open:
  DCL-DR-001 DCL-DR-002 DCL-DR-003 DCL-DR-004
  DCL-AI-001 DCL-P1-003 DCL-P1-004 DCL-P1-005 DCL-P1-006
  DCL-PREF-001 DCL-CONTENT-001 DCL-RULE-001 DCL-A11Y-001
  DCL-VIS-001 DCL-VIS-002 DCL-MOTION-001 DCL-PERF-001 DCL-RC-001

parked:
  DCL-TAB-001 DCL-QA-001 DCL-EXT-001 DCL-PREMIUM-001 DCL-EXT-002

closed:
  DCL-ARCH-001 DCL-DR-005 DCL-P1-001 DCL-P1-002

decision_required: none
```

Make `DCL-A11Y-001` and `DCL-PERF-001` phone-only; all later tablet
accessibility/performance belongs to `DCL-TAB-001`. Change the ledger authority
text so the phone program owns sequence, the ledger owns row closure and done
conditions, and the Finish Map owns category status only.

In the design, define:

```text
product_complete := run_state.mode == "complete"
canonical_reference := { path, commit, blob_oid }
```

Pin references for the phone program, closure ledger, Finish Map, quality
ladder, verified execution contract, active handoff, and device-ownership
policy. Do not add a second `product_complete` boolean.

- [ ] **Step 4: Align Finish Map and phone program**

Add a `Ledger IDs` column to the completion map. At minimum use these explicit
mappings:

```text
Living Tank -> DCL-P1-001
Rewards and collectibles -> DCL-P1-002
Species and plants -> DCL-P1-006
Learning -> DCL-P1-005
Practice -> DCL-P1-003
Guided tools -> DCL-P1-003
Timeline and journal -> DCL-P1-004
Backup and restore -> DCL-DR-001,DCL-DR-002,DCL-DR-004
Preferences -> DCL-PREF-001
Tablet layout / whole-app tablet audit -> DCL-TAB-001
Visual asset quality -> DCL-VIS-001
Accessibility -> DCL-A11Y-001
Motion and haptics -> DCL-MOTION-001
Performance -> DCL-PERF-001
Optional AI providers -> DCL-EXT-001
AI confirmation -> DCL-AI-001
Premium AI path -> DCL-PREMIUM-001
Citations -> DCL-P1-005,DCL-P1-006,DCL-CONTENT-001
Whole-app phone audit -> DCL-RC-001
Visual regression -> DCL-VIS-002
Rule tests -> DCL-RULE-001
Content validation -> DCL-CONTENT-001
Data resilience -> DCL-DR-001,DCL-DR-002,DCL-DR-003,DCL-DR-004
Debug QA seeds -> DCL-QA-001
```

Replace the legacy P0/P1/P2/P3 selector with a rule that delegates solely to
the phone program. Rename the program's immediate product heading to
`First Product Slice After Workflow Setup And Explicit Launch`.

- [ ] **Step 5: Mark bootstrap continuation fail-closed**

Set the chain prompt status to:

```text
Status: Bootstrap handoff only; automatic successor creation disabled until
runner compatibility, single-writer enforcement, readiness validation, and
the no-product-change rehearsal pass.
```

Require both runners in the template, but direct current setup sessions to use
explicit user-authorized project-scoped handoff only. Update the handoff to
record design approval and the 20-unit authorization without claiming the
operational run is active. Add this marked JSON block and require each setup
unit to update it exactly once at durable closeout:

```json
{
  "document_type": "danio_autonomy_bootstrap_budget",
  "schema_version": 1,
  "authorization_id": "danio-phone-complete-local-2026-07-11",
  "total_approved_units": 20,
  "consumed_units": 1,
  "remaining_units_including_current": 19,
  "last_closed_unit_id": "WF-2026-07-11-007",
  "operational_state_path": null
}
```

Until activation, a setup closeout requires the next unique unit ID, increments
`consumed_units` by one, decrements `remaining_units_including_current` by one,
and records the same unit ID in `SLICE_LOG.md`. A pre-claim/bootstrap failure
does not change the block. Task 13 atomically absorbs this block into run state;
afterward run state is the sole budget authority.

- [ ] **Step 6: Prove GREEN and commit**

Run:

```powershell
flutter test test/copy/current_docs_local_truth_test.dart --reporter compact
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs
```

Expected: all docs truth tests and the Docs profile pass.

Commit:

```powershell
git add AGENTS.md apps/aquarium_app/docs/agent apps/aquarium_app/test/copy/current_docs_local_truth_test.dart
git commit -m "docs: reconcile autonomous completion authority"
```

---

### Task 2: Define Strict Machine Contracts And Normative Fixtures

**Files:**

- Create: `apps/aquarium_app/docs/agent/AUTONOMOUS_PHONE_COMPLETION_RUNBOOK.md`
- Create: `apps/aquarium_app/docs/agent/autonomous_completion/runner_compatibility.json`
- Create: `apps/aquarium_app/docs/agent/autonomous_completion/schemas/run_state.schema.json`
- Create: `apps/aquarium_app/docs/agent/autonomous_completion/schemas/synchronization_receipt.schema.json`
- Create: `apps/aquarium_app/docs/agent/autonomous_completion/schemas/readiness_report.schema.json`
- Create: `apps/aquarium_app/docs/agent/autonomous_completion/schemas/transition_validation_report.schema.json`
- Create: `apps/aquarium_app/docs/agent/autonomous_completion/schemas/writer_claim_plan.schema.json`
- Create: `apps/aquarium_app/docs/agent/autonomous_completion/schemas/runner_compatibility.schema.json`
- Create: `apps/aquarium_app/docs/agent/autonomous_completion/schemas/evidence_manifest.schema.json`
- Create: `apps/aquarium_app/docs/agent/autonomous_completion/schemas/rehearsal_report.schema.json`
- Create: `apps/aquarium_app/docs/agent/autonomous_completion/schemas/handoff_prompt_report.schema.json`
- Create: `apps/aquarium_app/test/scripts/fixtures/autonomous_completion/inactive_run_state.json`
- Create: `apps/aquarium_app/test/scripts/fixtures/autonomous_completion/ready_run_state.json`
- Create: `apps/aquarium_app/test/scripts/fixtures/autonomous_completion/active_run_state.json`
- Create: `apps/aquarium_app/test/scripts/fixtures/autonomous_completion/handoff_ready_run_state.json`
- Create: `apps/aquarium_app/test/scripts/fixtures/autonomous_completion/finalizing_run_state.json`
- Create: `apps/aquarium_app/test/scripts/fixtures/autonomous_completion/complete_run_state.json`
- Create: `apps/aquarium_app/test/scripts/fixtures/autonomous_completion/runner_compatibility_unpinned.json`
- Create: `apps/aquarium_app/test/scripts/autonomous_completion_script_test.dart`
- Modify: `apps/aquarium_app/test/copy/current_docs_local_truth_test.dart`

**Interfaces:**

- Every schema is draft 2020-12 and rejects unknown fields.
- Fixtures define mode nullability before a live run-state file exists.
- Compatibility remains `authorizes_launch: false` and uses null hashes until
  the reviewed installed-skill update is pinned.

- [ ] **Step 1: Write failing contract tests**

Create `autonomous_completion_script_test.dart` with JSON decoding, ASCII
checks, schema existence checks, and these assertions:

```dart
expect(schema[r'$schema'], 'https://json-schema.org/draft/2020-12/schema');
expect(schema['additionalProperties'], isFalse);
expect(compatibility['authorizes_launch'], isFalse);
expect(compatibility['runner_compatible'], isFalse);
expect(compatibility['skills'].every((skill) => skill['skill_sha256'] == null), isTrue);
```

- [ ] **Step 2: Run and prove RED**

Run:

```powershell
flutter test test/scripts/autonomous_completion_script_test.dart --reporter compact
```

Expected: FAIL because the contract files do not exist.

- [ ] **Step 3: Add the compatibility manifest**

Use this initial shape:

```json
{
  "schema_version": 1,
  "manifest_id": "danio-phone-autonomy-runners",
  "manifest_revision": 1,
  "authorizes_launch": false,
  "runner_compatible": false,
  "launch_proof": null,
  "design": {
    "path": "apps/aquarium_app/docs/agent/plans/2026-07-11-autonomous-phone-completion-operating-model-design.md",
    "commit": "81be4c93444cfd47a80cf47730cbc76e9b8464ff",
    "blob_oid": "7a0921a215da64277d8141871008e556c8478bb3",
    "sha256": "E9AAFCD0B0E1A4D9261E6FE08FCD4306E396C1BA9FF0E921C0A240924496F928"
  },
  "install_root": {
    "environment": "CODEX_HOME",
    "fallback": "%USERPROFILE%\\.codex"
  },
  "runner_order": [
    "danio-autonomous-slice-runner",
    "verified-slice-runner"
  ],
  "skills": [
    {
      "name": "danio-autonomous-slice-runner",
      "role": "orchestrator",
      "skill_path": "skills/danio-autonomous-slice-runner/SKILL.md",
      "skill_sha256": null,
      "contract_path": "skills/danio-autonomous-slice-runner/references/compatibility-contract.json",
      "contract_sha256": null,
      "contract_version": "1.0.0"
    },
    {
      "name": "verified-slice-runner",
      "role": "base",
      "skill_path": "skills/verified-slice-runner/SKILL.md",
      "skill_sha256": null,
      "contract_path": "skills/verified-slice-runner/references/compatibility-contract.json",
      "contract_sha256": null,
      "contract_version": "1.0.0"
    }
  ],
  "writer_policy": {
    "repository_writer": "coordinator_only",
    "claim_required": true,
    "parallel_write_agents": false,
    "android_repository_writes": false
  },
  "budget_policy": {
    "unit": "claimed_task_unit",
    "remaining_includes_current": true,
    "claim_state": "pending",
    "consume_on": ["handoff_ready", "paused", "stopped", "finalizing"],
    "do_not_consume_on": ["preclaim_exit", "WRITER_CLAIM_LOST"],
    "abandoned_pending": "consume_on_user_approved_recovery",
    "exactly_once": true
  },
  "failure_policy": {
    "digest_or_semantic_mismatch": "RUNNER_INCOMPATIBLE",
    "successor_on_stop": false,
    "auto_repair_installed_skill": false
  },
  "handoff_policy": {
    "eligible_mode": "handoff_ready",
    "positive_remaining_required": true,
    "marker_format": "run_id/handoff_generation",
    "lookup_before_create": true,
    "saved_project_only": true,
    "decrement_on_transfer": false,
    "ambiguous_or_unavailable": "paste_ready_handoff_only",
    "unknown_create_result": "reconcile_without_retry"
  },
  "thread_capabilities": {
    "required": ["list_threads", "read_thread", "create_thread.project_target"],
    "recovery_only": ["send_message_to_thread"],
    "not_for_successors": ["fork_thread"]
  },
  "validation": {
    "hash_algorithm": "sha256",
    "hash_scope": "exact_file_bytes",
    "reject_path_escape": true,
    "reject_unknown_fields": true
  }
}
```

- [ ] **Step 4: Add schemas and fixtures**

The run-state schema requires:

```text
run_id, state_revision, mode, transition, authority, authorization, cursor,
owner, budget, handoff_generation, last_verified_checkpoint,
repeated_failure, stop_reason_code, recovery, control_surface_sync
```

The budget object is:

```json
{
  "total_approved_units": 20,
  "consumed_units": 1,
  "remaining_units_including_current": 19,
  "current_charge": {
    "work_unit_id": null,
    "status": "none",
    "claimed_revision": null,
    "consumed_revision": null
  }
}
```

Fixture values model bootstrap authorization only; no live state file is
created. Enforce `consumed_units + remaining_units_including_current ==
total_approved_units` in PowerShell behavior validation, not JSON Schema.
The compatibility schema requires `launch_proof: null` while
`authorizes_launch` is false; when true, `runner_compatible` must also be true
and `launch_proof` must contain a report path, exact-byte SHA-256, and commit.

- [ ] **Step 5: Document nullability and output contracts**

The runbook must define exact allowed modes:

```text
inactive ready active handoff_ready paused stopped finalizing complete
```

`owner` is non-null only in `active` and `finalizing`. Durable `stopped`
requires released writer/device leases. `product_complete` is derived from
`mode == complete`. The containing commit is the state commit; state never
stores its own future SHA.

- [ ] **Step 6: Prove GREEN and commit**

Run:

```powershell
flutter test test/scripts/autonomous_completion_script_test.dart --reporter compact
flutter test test/copy/current_docs_local_truth_test.dart --reporter compact
```

Commit:

```powershell
git add apps/aquarium_app/docs/agent apps/aquarium_app/test/scripts apps/aquarium_app/test/copy/current_docs_local_truth_test.dart
git commit -m "docs: define autonomous completion contracts"
```

---

### Task 3: Implement The Pure Validation Module And Transition Matrix

**Files:**

- Create: `apps/aquarium_app/scripts/autonomous_completion/DanioAutonomousCompletion.psm1`
- Create: `apps/aquarium_app/test/scripts/autonomous_completion_behavior_test.ps1`
- Modify: `apps/aquarium_app/test/scripts/autonomous_completion_script_test.dart`
- Modify: `apps/aquarium_app/test/scripts/fixtures/autonomous_completion/inactive_run_state.json`
- Modify: `apps/aquarium_app/test/scripts/fixtures/autonomous_completion/ready_run_state.json`
- Modify: `apps/aquarium_app/test/scripts/fixtures/autonomous_completion/active_run_state.json`
- Modify: `apps/aquarium_app/test/scripts/fixtures/autonomous_completion/handoff_ready_run_state.json`
- Modify: `apps/aquarium_app/test/scripts/fixtures/autonomous_completion/finalizing_run_state.json`
- Modify: `apps/aquarium_app/test/scripts/fixtures/autonomous_completion/complete_run_state.json`

**Interfaces:**

- The module performs no fetch, stage, commit, push, worktree creation, task
  creation, runtime mutation, or external call.
- `Read-DanioLedgerClosureRows` parses only the two formally named ledger
  tables and rejects malformed row width, duplicate IDs, unknown states, or
  literal unescaped pipes.
- `Test-DanioRunStateTransition` returns `{ valid, code, details }`.

- [ ] **Step 1: Write failing PowerShell behavior tests**

Use a dependency-free assertion helper:

```powershell
function Assert-True {
  param([bool]$Condition, [string]$Message)
  if (-not $Condition) { throw $Message }
}
```

Test all allowed transitions plus forbidden representatives. Test claim with no
decrement, ordinary closeout with one decrement, finalization with one
decrement, finalizing-to-complete with no second decrement, claim loss with no
decrement, and `STOP_PENDING` retaining the lease. Test
`Test-DanioCompletionReadiness` with normalized ledger, evidence, ownership,
cleanup, and repository observations.

- [ ] **Step 2: Run and prove RED**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File test/scripts/autonomous_completion_behavior_test.ps1
```

Expected: FAIL because the module is missing.

- [ ] **Step 3: Implement owner identity and transition guards**

Use this exact owner-token input:

```powershell
$tokenInput = @(
  $RunId,
  $WorkUnitId,
  $TaskId,
  [string]$ExpectedRevision
) -join "`n"
$tokenBytes = [System.Text.Encoding]::UTF8.GetBytes($tokenInput)
$tokenHash = [System.Security.Cryptography.SHA256]::Create().ComputeHash($tokenBytes)
$tokenSha256 = ([System.BitConverter]::ToString($tokenHash)).Replace("-", "").ToLowerInvariant()
```

Allowed transition keys are:

```powershell
$allowed = @{
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
```

- [ ] **Step 4: Implement ledger and state invariants**

Enforce:

```text
the bootstrap fixtures report 18 open, 5 parked, 4 closed, 0 decision_required
runtime validation never freezes those counts or rejects newly recorded rows
DCL-RC-001 is the last active phase row
parked disposition is compatible only with parked closure state
accepted/archive dispositions are compatible only with closed state
consumed + remaining == total
state_revision increments by exactly one
all modes except active/finalizing have no owner and released leases
same-mode administrative update changes only transition metadata,
state_revision, and control_surface_sync
```

An absent live state path is accepted only for `Intent Launch`. The validator
uses the normative inactive fixture as the conceptual parent, requires staged
creation at revision 1, and applies the Task 13 bootstrap charge arithmetic;
it never writes an `inactive` live file.

`Test-DanioCompletionReadiness` returns false unless the candidate is
`finalizing`, the retained owner token is still valid, every active phone row
other than `DCL-RC-001` is closed, `DCL-RC-001` is closed by the final evidence
checkpoint, no active-scope row is `open` or `decision_required`, every parked
row remains outside the active scope, the required Full/AndroidPrep/content/
visual/product-truth/phone-QA evidence matches the aligned parent checkpoint,
and exact owned branch/worktree/device cleanup is proven. The function consumes
normalized inputs and performs no Git, file, runtime, task, or external action.

- [ ] **Step 5: Prove GREEN and commit**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File test/scripts/autonomous_completion_behavior_test.ps1
flutter test test/scripts/autonomous_completion_script_test.dart --reporter compact
```

Commit:

```powershell
git add apps/aquarium_app/scripts/autonomous_completion apps/aquarium_app/test/scripts
git commit -m "test: add autonomous completion state validation"
```

---

### Task 4: Add Synchronization Receipts And Pure Readiness

**Files:**

- Create: `apps/aquarium_app/scripts/autonomous_completion/sync_autonomous_completion.ps1`
- Create: `apps/aquarium_app/scripts/autonomous_completion/check_autonomous_completion_readiness.ps1`
- Modify: `apps/aquarium_app/scripts/autonomous_completion/DanioAutonomousCompletion.psm1`
- Create: `apps/aquarium_app/test/scripts/autonomous_completion_git_fixture_test.ps1`
- Modify: `apps/aquarium_app/test/scripts/autonomous_completion_behavior_test.ps1`

**Interfaces:**

- Synchronization is the only preflight action allowed to fetch.
- The receipt is ephemeral stdout JSON and is never committed.
- Readiness accepts receipt JSON and performs no network/ref/file/device or
  external mutation.
- `Get-DanioRepositoryObservation` sets `GIT_OPTIONAL_LOCKS=0` around
  observational Git commands and restores the previous environment value.

- [ ] **Step 1: Add failing receipt and readiness tests**

Cover these exact cases:

```text
receipt age 120 seconds -> eligible
receipt age 121 seconds -> STALE_SYNC_RECEIPT
future timestamp -> INVALID_SYNC_RECEIPT
wrong nonce/root/origin SHA/command -> INVALID_SYNC_RECEIPT
ahead or behind nonzero -> REMOTE_DIVERGED
dirty or untracked path -> DIRTY_UNOWNED
wrong source branch -> WRONG_SOURCE_BRANCH
authority mismatch -> AUTHORITY_CONFLICT
runner mismatch -> RUNNER_INCOMPATIBLE
remaining budget zero -> BUDGET_EXHAUSTED
runtime flag with unclear ownership -> RUNTIME_OWNERSHIP_CONFLICT
Finalization intent with an open active row -> COMPLETION_NOT_READY
Finalization intent with stale/missing required evidence -> COMPLETION_NOT_READY
Finalization intent with retained foreign lease or cleanup gap -> COMPLETION_NOT_READY
```

- [ ] **Step 2: Run and prove RED**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File test/scripts/autonomous_completion_behavior_test.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File test/scripts/autonomous_completion_git_fixture_test.ps1
```

Expected: FAIL because the wrapper scripts are missing.

- [ ] **Step 3: Implement synchronization output**

The receipt shape is:

```json
{
  "document_type": "danio_synchronization_receipt",
  "schema_version": 1,
  "invocation_nonce": "0123456789abcdef0123456789abcdef",
  "repository_root": "C:/absolute/repo/path",
  "command": {
    "executable": "git",
    "arguments": ["fetch", "--prune"]
  },
  "exit_code": 0,
  "completed_at_utc": "2026-07-11T12:00:00.0000000Z",
  "origin_main_commit": "40-hex-sha",
  "ahead_behind": {"ahead": 0, "behind": 0}
}
```

The script must capture native stdout/stderr without contaminating its own
stdout. A nonzero fetch returns structured rejection and exit `1`.

- [ ] **Step 4: Implement pure readiness**

Return all checks, not only the first failure:

```json
{
  "document_type": "danio_readiness_report",
  "schema_version": 1,
  "intent": "Claim",
  "checked_at_utc": "2026-07-11T12:00:30.0000000Z",
  "eligible": false,
  "stop_reason_code": "AUTHORITY_CONFLICT",
  "checks": [
    {"code": "REPO_ROOT", "status": "pass", "detail": "nested repo resolved"},
    {"code": "AUTHORITY_CONFLICT", "status": "fail", "detail": "program blob moved"}
  ]
}
```

Stop-reason precedence is: invalid receipt, wrong root/branch, remote
divergence, dirt/foreign ownership, invalid state/authority, runner mismatch,
budget, then runtime ownership.

- [ ] **Step 5: Prove no mutation in a disposable Git fixture**

The fixture test creates a local bare remote and two temporary clones under
`[System.IO.Path]::GetTempPath()`. Capture refs, index hash, worktree list, and
status before and after readiness. Assert they are byte-for-byte identical.

- [ ] **Step 6: Prove GREEN and commit**

Run both PowerShell suites, then:

```powershell
flutter test test/scripts/autonomous_completion_script_test.dart --reporter compact
```

Commit:

```powershell
git add apps/aquarium_app/scripts/autonomous_completion apps/aquarium_app/test/scripts
git commit -m "feat: add autonomous completion readiness"
```

---

### Task 5: Add Staged Transition Validation And Pure Claim Planning

**Files:**

- Create: `apps/aquarium_app/scripts/autonomous_completion/validate_autonomous_completion_transition.ps1`
- Create: `apps/aquarium_app/scripts/autonomous_completion/plan_autonomous_writer_claim.ps1`
- Modify: `apps/aquarium_app/scripts/autonomous_completion/DanioAutonomousCompletion.psm1`
- Modify: `apps/aquarium_app/test/copy/current_docs_local_truth_test.dart`
- Modify: `apps/aquarium_app/test/scripts/autonomous_completion_behavior_test.ps1`
- Modify: `apps/aquarium_app/test/scripts/autonomous_completion_git_fixture_test.ps1`

**Interfaces:**

- The claim planner performs no mutation and always reports
  `mutations_performed: false`.
- Deterministic identity uses run ID, work-unit ID, task ID, and expected state
  revision.
- Worktrees are permitted only below
  `<saved-project-root>/.codex-worktrees/<worktree_id>`.

- [ ] **Step 1: Write failing planner/transition tests**

Cover exact determinism, distinct task IDs, exact-match reuse only, resolved
path containment, revision mismatch, forbidden transition, staged-tree hash
mismatch, dirty-after-gate detection, and administrative deep comparison.

- [ ] **Step 2: Run and prove RED**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File test/scripts/autonomous_completion_behavior_test.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File test/scripts/autonomous_completion_git_fixture_test.ps1
```

Expected: FAIL because planner/validator entry points are missing.

- [ ] **Step 3: Implement claim-plan naming**

Derive names using lowercase safe tokens and a 12-character owner-token prefix:

```text
branch_name = autonomy/<run_id>/<work_unit_id>/<token12>
worktree_id = <run_id>-<work_unit_id>-<token12>
worktree_path = <saved-project-root>/.codex-worktrees/<worktree_id>
```

Reject path separators, `..`, drive changes, reparse-point escape, or an
existing identity whose token/revision/commit/process evidence does not match.

- [ ] **Step 4: Implement staged-tree verification**

For `-Source Staged`, compare parent state to the state blob in the index using
`git show ":$StatePath"`, not the worktree file. Capture `git write-tree`, run the
state validator, then require the caller to recheck both tree hash and clean
unstaged/untracked state after the Docs profile.

For `-Source Committed`, load state from `"$Commit`:$StatePath"` and validate its
parent transition and commit trailers.

- [ ] **Step 5: Prove GREEN and commit**

Run both PowerShell suites and the Dart script test. Commit:

```powershell
git add apps/aquarium_app/scripts/autonomous_completion apps/aquarium_app/test/scripts
git commit -m "feat: validate autonomous writer claims"
```

---

### Task 6: Reconcile And Validate The Installed Runner Contracts

**Approved correction (2026-07-12):** Task 6 also owns the existing
compatibility validator, runbook/bootstrap truth tests, and its Dart contract
test so the manifest pin is validated against installed bytes rather than
trusted as self-asserted evidence. Proof of `automatic_successor_capable` is
deferred to Task 10, which owns task-tool capability inspection; Task 6 does
not change that readiness field.

**Files outside the product repository:**

- Modify: `C:\Users\larki\.codex\skills\danio-autonomous-slice-runner\SKILL.md`
- Modify: `C:\Users\larki\.codex\skills\danio-autonomous-slice-runner\agents\openai.yaml`
- Create: `C:\Users\larki\.codex\skills\danio-autonomous-slice-runner\references\compatibility-contract.json`
- Modify: `C:\Users\larki\.codex\skills\verified-slice-runner\SKILL.md`
- Modify: `C:\Users\larki\.codex\skills\verified-slice-runner\agents\openai.yaml`
- Modify: `C:\Users\larki\.codex\skills\verified-slice-runner\references\pressure-tests.md`
- Create: `C:\Users\larki\.codex\skills\verified-slice-runner\references\compatibility-contract.json`

**Repository files:**

- Modify: `apps/aquarium_app/docs/agent/autonomous_completion/runner_compatibility.json`
- Modify: `apps/aquarium_app/docs/agent/AUTONOMOUS_PHONE_COMPLETION_RUNBOOK.md`
- Modify: `apps/aquarium_app/docs/agent/plans/2026-07-11-autonomous-phone-completion-workflow-implementation-plan.md`
- Modify: `apps/aquarium_app/scripts/autonomous_completion/DanioAutonomousCompletion.psm1`
- Modify: `apps/aquarium_app/test/copy/current_docs_local_truth_test.dart`
- Modify: `apps/aquarium_app/test/scripts/autonomous_completion_behavior_test.ps1`
- Modify: `apps/aquarium_app/test/scripts/autonomous_completion_script_test.dart`

**Interfaces:**

- Use `superpowers:writing-skills` before editing installed skills.
- Do not add custom YAML frontmatter fields.
- Sidecars contain only `schema_version`, `skill_name`, `contract_version`,
  `runner_role`, `extends`, and `capabilities`.
- Repo manifest pins exact-byte SHA-256 after independent review.

- [ ] **Step 1: Extend the failing compatibility fixture**

Assert unpinned or forged installed-skill digests produce
`RUNNER_INCOMPATIBLE`, while the reviewed exact-byte pins produce
`RUNNER_COMPATIBLE`. Task 10 will prove that missing task tools produce
`automatic_successor_capable: false` without changing `runner_compatible`.

- [ ] **Step 2: Define exact sidecars**

Danio sidecar:

```json
{
  "schema_version": 1,
  "skill_name": "danio-autonomous-slice-runner",
  "contract_version": "1.0.0",
  "runner_role": "orchestrator",
  "extends": "verified-slice-runner@1.0.0",
  "capabilities": [
    "coordinator_only_writer",
    "read_only_auditors",
    "claimed_task_unit_budget",
    "duplicate_safe_project_handoff",
    "stop_pending",
    "push_outcome_unknown"
  ]
}
```

Verified sidecar uses `runner_role: "base"`, `extends: null`, and the same
budget/recovery capability vocabulary.

- [ ] **Step 3: Reconcile skill prose and pressure tests**

Both skills must state:

```text
remaining budget includes the current claimed task unit
claim does not decrement
durable handoff/pause/stop/finalizing consumes exactly once
preclaim exit and WRITER_CLAIM_LOST consume zero
abandoned pending unit is consumed only by user-approved recovery
PUSH_OUTCOME_UNKNOWN preserves artifacts and never retries blindly
STOP_PENDING retains the lease and creates no successor
autonomous chain approval plus saved-project binding permits one successor
only from a clean pushed handoff_ready checkpoint
```

The Danio runner must allow the explicit chain mode defined by the verified
runner; it must no longer require a new ad hoc user request at every clean
checkpoint when a valid committed chain authorization remains.

- [ ] **Step 4: Validate installed skills**

Run:

```powershell
python C:\Users\larki\.codex\skills\.system\skill-creator\scripts\quick_validate.py C:\Users\larki\.codex\skills\danio-autonomous-slice-runner
python C:\Users\larki\.codex\skills\.system\skill-creator\scripts\quick_validate.py C:\Users\larki\.codex\skills\verified-slice-runner
```

Run non-ASCII, placeholder, and stale-policy scans. Dispatch one read-only
reviewer against both skill diffs/content snapshots.

- [ ] **Step 5: Pin reviewed hashes in the repo manifest**

Use:

```powershell
Get-FileHash -Algorithm SHA256 -LiteralPath C:\Users\larki\.codex\skills\danio-autonomous-slice-runner\SKILL.md
Get-FileHash -Algorithm SHA256 -LiteralPath C:\Users\larki\.codex\skills\danio-autonomous-slice-runner\references\compatibility-contract.json
Get-FileHash -Algorithm SHA256 -LiteralPath C:\Users\larki\.codex\skills\verified-slice-runner\SKILL.md
Get-FileHash -Algorithm SHA256 -LiteralPath C:\Users\larki\.codex\skills\verified-slice-runner\references\compatibility-contract.json
```

Set `runner_compatible: true` only when exact paths, frontmatter names,
sidecars, semantic values, and hashes all pass. Keep `authorizes_launch: false`.
The shared schema continues to admit either hexadecimal case for the approved
design digest; the Task 6 runtime semantic validator and Dart pin assertion
require the two installed-skill hash pairs to be lowercase.

- [ ] **Step 6: Prove GREEN and commit the repo pin**

Run compatibility behavior tests and Docs profile. Commit only the Task 6
repository-owned compatibility changes:

```powershell
git add apps/aquarium_app/docs/agent/autonomous_completion/runner_compatibility.json apps/aquarium_app/docs/agent/AUTONOMOUS_PHONE_COMPLETION_RUNBOOK.md apps/aquarium_app/docs/agent/plans/2026-07-11-autonomous-phone-completion-workflow-implementation-plan.md apps/aquarium_app/scripts/autonomous_completion/DanioAutonomousCompletion.psm1 apps/aquarium_app/test/copy/current_docs_local_truth_test.dart apps/aquarium_app/test/scripts/autonomous_completion_behavior_test.ps1 apps/aquarium_app/test/scripts/autonomous_completion_script_test.dart
git commit -m "chore: pin autonomous runner contracts"
```

Record installed-skill validation and hashes in the slice log; never copy
installed skill files into the product repo.

---

### Task 7: Enforce The Coordinator-Only Agent Overlay

**Files:**

- Modify: `.codex/config.toml`
- Modify: `.codex/agents/danio_product_auditor.toml`
- Modify: `.codex/agents/danio_ui_auditor.toml`
- Modify: `.codex/agents/danio_quality_auditor.toml`
- Modify: `.codex/agents/danio_reviewer.toml`
- Modify: `.codex/agents/danio_android_qa_owner.toml`
- Modify: `AGENTS.md`
- Modify: `apps/aquarium_app/docs/agent/MULTI_AGENT_WORKFLOW.md`
- Modify: `apps/aquarium_app/docs/agent/CODEX_SETUP.md`
- Modify: `apps/aquarium_app/docs/agent/AUTONOMOUS_CHAIN_HANDOFF_PROMPT.md`
- Modify: `apps/aquarium_app/test/scripts/autonomous_completion_script_test.dart`

**Interfaces:**

- `danio_worker` is de-registered for the phone completion program; its file is
  retained and not deleted.
- All auditors use `sandbox_mode = "read-only"`.
- Android QA is repository-read-only; coordinator provides immutable APK/commit
  identity and owns durable evidence-file writes.

- [ ] **Step 1: Add failing agent-policy assertions**

Assert the config has no `[agents.danio_worker]`, Android QA uses read-only
sandbox, all auditor prompts contain the command allowlist and mutation ban,
and the chain prompt invokes Danio runner before verified runner.

- [ ] **Step 2: Run and prove RED**

```powershell
flutter test test/scripts/autonomous_completion_script_test.dart --reporter compact
```

Expected: FAIL because worker/Android write access is still registered.

- [ ] **Step 3: Apply the overlay**

Auditor allowlist:

```text
rg, Get-Content, git show, git log, git diff --no-ext-diff,
git --no-optional-locks status with GIT_OPTIONAL_LOCKS=0
```

Auditor denylist:

```text
fetch, checkout, add, commit, push, package resolution, Flutter/Gradle
test/build/analyze, generators, quality wrappers, ADB/emulator, background
processes, Figma writes, task creation, and account-backed actions
```

Android QA may use only the assigned serial/runtime commands after
`DEVICE_OWNERSHIP.md`; it may not edit/stage/commit repository files.

- [ ] **Step 4: Prove GREEN and commit**

Run script contract tests, current docs tests, and Docs profile. Commit:

```powershell
git add .codex AGENTS.md apps/aquarium_app/docs/agent apps/aquarium_app/test/scripts
git commit -m "chore: enforce autonomous single-writer policy"
```

---

### Task 8: Implement CAS Writer Claim And Unknown-Push Reconciliation

**Files:**

- Create: `apps/aquarium_app/scripts/autonomous_completion/invoke_autonomous_writer_claim.ps1`
- Modify: `apps/aquarium_app/scripts/autonomous_completion/DanioAutonomousCompletion.psm1`
- Modify: `apps/aquarium_app/test/scripts/autonomous_completion_git_fixture_test.ps1`
- Modify: `apps/aquarium_app/docs/agent/AUTONOMOUS_PHONE_COMPLETION_RUNBOOK.md`

**Interfaces:**

- Requires an eligible Claim readiness report.
- Creates one deterministic branch/worktree, stages only run state, validates
  the staged transition, commits with verification trailers, then performs one
  normal `HEAD:main` push.
- Never force-pushes, rebases after rejection, or deletes ambiguous paths.

- [ ] **Step 1: Add failing disposable-race tests**

In two temporary clones of one local bare remote, produce two valid claim
commits from the same state revision. Assert exactly one fast-forward push wins,
the loser returns `WRITER_CLAIM_LOST`, and neither path decrements budget.

Add an injected transport-result mode for tests:

```text
accepted rejected unknown_accepted unknown_not_accepted unknown_unresolved
```

- [ ] **Step 2: Run and prove RED**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File test/scripts/autonomous_completion_git_fixture_test.ps1
```

Expected: FAIL because the mutation entry point is missing.

- [ ] **Step 3: Implement exact claim transaction**

Required commit trailers:

```text
Danio-State-Tree: <git-write-tree-oid>
Danio-State-Validation: pass
Danio-Docs-Profile: pass
Danio-Verified-At: <UTC timestamp>
```

After a definite rejection, remove only the resolved isolated branch/worktree
whose token and expected revision match. After timeout/disconnection, return
`PUSH_OUTCOME_UNKNOWN`, preserve every artifact, fetch when possible, and
compare exact candidate reachability:

```text
origin tip == candidate -> accepted
origin contains candidate but advanced -> REMOTE_MOVED
origin proves candidate absent -> rejected
cannot prove -> PUSH_OUTCOME_UNKNOWN, no retry/cleanup
```

- [ ] **Step 4: Prove GREEN and commit**

Run Git fixture, behavior, and Dart script tests. Commit:

```powershell
git add apps/aquarium_app/scripts/autonomous_completion apps/aquarium_app/test/scripts apps/aquarium_app/docs/agent/AUTONOMOUS_PHONE_COMPLETION_RUNBOOK.md
git commit -m "feat: enforce autonomous writer claims"
```

---

### Task 9: Implement Evidence Checkpoints, Closeout, And Finalization

**Approved correction (2026-07-12):** The user authorized a narrow Task 9
contract correction after read-only review proved that the existing public
transition validator omitted the lease/finalization inputs required by the
pure guard and the Finalization readiness wrapper always supplied null evidence
and cleanup. Task 9 owns the exact wrapper, schema, and static-contract changes
below so implementation cannot bypass or duplicate those public interfaces.
The pure module's exported function list remains unchanged.

**Files:**

- Create: `apps/aquarium_app/scripts/autonomous_completion/commit_autonomous_completion_transition.ps1`
- Modify: `apps/aquarium_app/scripts/autonomous_completion/DanioAutonomousCompletion.psm1`
- Modify: `apps/aquarium_app/scripts/autonomous_completion/check_autonomous_completion_readiness.ps1`
- Modify: `apps/aquarium_app/scripts/autonomous_completion/validate_autonomous_completion_transition.ps1`
- Modify: `apps/aquarium_app/docs/agent/autonomous_completion/schemas/evidence_manifest.schema.json`
- Modify: `apps/aquarium_app/test/scripts/autonomous_completion_behavior_test.ps1`
- Modify: `apps/aquarium_app/test/scripts/autonomous_completion_git_fixture_test.ps1`
- Modify: `apps/aquarium_app/test/scripts/autonomous_completion_script_test.dart`
- Modify: `apps/aquarium_app/docs/agent/AUTONOMOUS_PHONE_COMPLETION_RUNBOOK.md`
- Modify: `apps/aquarium_app/docs/agent/plans/2026-07-11-autonomous-phone-completion-workflow-implementation-plan.md`
- Modify at closeout only: `apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md`
- Modify at closeout only: `apps/aquarium_app/docs/agent/SLICE_LOG.md`

**Interfaces:**

- Product/workflow commit and evidence-manifest checkpoint are pushed while the
  owner remains active.
- Owned branch/worktree cleanup occurs only after that checkpoint is aligned.
- State closeout then consumes the pending unit once and releases ownership.
- DCL-RC uses `active -> finalizing -> complete`, never direct completion.
- The linked-worktree test harness uses the fixture's canonical authorized
  repository root for synthetic readiness and resolves the index through
  `git rev-parse --path-format=absolute --git-path index`; it never assumes
  `<worktree>/.git/index`.
- `LeaseReleaseJson` has exactly these fields:

```json
{
  "owner_token": "64-lowercase-hex",
  "android_released": true,
  "processes_released": true
}
```

  The token must match the exact previous owner. The transition validator
  derives branch/worktree/writer release from the retained owner identity plus
  current Git registration, ref, and filesystem observations. Caller JSON
  cannot name or claim removal of a different branch or worktree.
- The validator loads the ledger and evidence manifest from the exact parent
  commit (`HEAD` for staged validation, `Commit^` for committed validation).
  Caller-supplied ledger rows, active-scope IDs, normalized completion checks,
  cleanup identity, or checkpoint commit are forbidden.
- A new evidence checkpoint is owned by the current durable lease: the exact
  product commit and its manifest commit must be strict descendants of the
  typed `claim`/`finalize` state transition that established the parent owner,
  and both must be ancestors of the candidate parent. Reusing a pre-owner,
  side-branch, or merely local object is forbidden.
- The last commit that changed the parent run-state path must itself be the
  typed `claim` or `finalize` transition, with exact transition-only path scope,
  tree, trailers, and historical manifest proof. The run-state bytes must stay
  unchanged from that commit through the evidence parent.
- Task 9 transition path scope is exact: the run-state path is required and
  only `ACTIVE_HANDOFF.md` and `SLICE_LOG.md` may accompany it for launch or
  closeout bookkeeping. Product paths never belong in a state transition.
- Task 9 derives the candidate authority snapshot from the exact parent commit.
  Each reference binds the canonical path, exact reachable commit, and exact
  blob bytes; it need not equal the newest `origin/main` blob and it must not
  create a self-reference to the candidate transition.
- Evidence-bearing Task 9 transition commits add exactly one terminal trailer:

```text
Danio-Evidence-Manifest: <repository-relative path>
```

  An emergency `active -> stopped` transition with no historical checkpoint
  uses `Danio-Evidence-Manifest: none`. Claim, launch, resume, and
  administrative commits remain on the existing four-trailer contract.
- The compact transition command result has this exact property set:

```text
document_type = danio_transition_commit_result
schema_version
completed_at_utc
accepted
code
details
transition_action
from_mode
to_mode
run_id
work_unit_id
expected_state_revision
candidate_state_revision
evidence_manifest_path
owner_token_sha256
mutations_performed
push_attempted
push_attempt_count
push_timed_out
push_termination_confirmed
push_rejection_proven
retry_performed
reconciliation_status
candidate_charge_consumed
durable_charge_consumption_proven
owner_retained
owner_released
owned_cleanup_proven
artifacts_preserved
candidate_commit
staged_tree_hash
origin_main_commit
test_transport_outcome
```

  Success is `TRANSITION_COMMITTED`. Stable fail-closed results include
  `EVIDENCE_MANIFEST_REQUIRED`, `EVIDENCE_MANIFEST_INVALID`,
  `LEASE_RELEASE_INVALID`, `PARENT_STATE_PROVENANCE_INVALID`, `STOP_PENDING`,
  `FINALIZATION_SCOPE_INVALID`,
  `COMPLETION_NOT_READY`, `TRANSITION_VALIDATION_FAILED`,
  `DOCS_PROFILE_FAILED`, `REMOTE_MOVED`, `PUSH_OUTCOME_UNKNOWN`, and
  `TRANSITION_TRANSACTION_INVALID`. `accepted` is true only when the exact
  candidate is the clean aligned local and remote `main` tip.
- A rejected or indeterminate state push preserves the candidate commit and
  never runs claim-style branch/worktree deletion. Exact stdout porcelain
  rejection plus fresh candidate absence returns `REMOTE_MOVED`; timeout,
  unclassified failure, unconfirmed process-tree termination, or unprovable
  reachability returns `PUSH_OUTCOME_UNKNOWN`. No path retries a push.
- The transaction pushes the immutable raw candidate object ID to `main`; it
  never pushes a moving symbolic `HEAD`. The nullable durable-charge and
  `owner_retained`/`owner_released` fields describe the exact prior or candidate
  transition outcome whose origin reachability is proven: `STOP_PENDING` or a
  definite rejection may prove the aligned prior owner; an exact candidate or
  reachable candidate ancestor may prove the candidate's charge and owner
  effect; and local-alignment failure does not erase remote proof. They remain
  null when reachability is ambiguous. `owned_cleanup_proven` separately
  reports physical branch/worktree cleanup, and local alignment failure remains
  fail closed.

- [x] **Step 1: Add failing closeout/finalization tests**

Cover:

```text
ordinary closeout consumes once and advances generation once
budget 1 becomes 0 and stops without successor
paused clean closeout consumes once
emergency stopped consumes once only after lease release
unsafe release returns STOP_PENDING and preserves charge/owner
active -> finalizing consumes once and retains owner
finalizing -> complete consumes zero and releases owner
finalizing failure never consumes twice
same-mode Figma admin update changes only allowed fields
```

Do not duplicate the existing pure transition arithmetic. Add RED coverage for
the newly connected boundaries:

```text
linked-worktree behavior fixture uses canonical authorized repository root
linked-worktree index snapshot resolves through git --git-path
transition commit entry point exists and has the exact static contract
manifest check indexes, timestamps, cursor binding, artifact blobs, and hashes
staged and committed validator receive exact release proof
finalize derives ledger scope from the parent commit
complete derives terminal evidence and cleanup from the parent commit
Finalization readiness accepts committed manifest plus exact release proof
missing, malformed, wrong-owner, or caller-spoofed proof fails closed
evidence trailer is terminal, unique, action-conditional, and path-exact
evidence checkpoint precedes cleanup and state push in disposable history
budget-one closeout selects stopped and exposes no successor eligibility
unknown evidence/state push preserves the correct phase artifacts with no retry
```

The Dart static contract list includes both mutation entry points,
`invoke_autonomous_writer_claim.ps1` and
`commit_autonomous_completion_transition.ps1`.

- [x] **Step 2: Run and prove RED**

Run behavior, Git fixture, and Dart script suites. Expected: FAIL because the
transition commit entry point and corrected proof/schema interfaces are absent.

- [x] **Step 3: Implement evidence manifest validation**

Each real manifest requires:

```json
{
  "schema_version": 1,
  "product_commit": "40-hex-sha",
  "work_unit_id": "DCL-DR-001-audit",
  "ledger_row_ids": ["DCL-DR-001"],
  "commands": [
    {
      "command": "flutter test test/services/backup_service_test.dart --reporter compact",
      "exit_code": 0,
      "started_at_utc": "strict UTC",
      "completed_at_utc": "strict UTC"
    }
  ],
  "environment": {"platform": "windows", "device_id": null},
  "artifacts": [],
  "checks": [
    {
      "code": "FOCUSED",
      "status": "pass",
      "command_indexes": [0],
      "artifact_indexes": []
    }
  ],
  "overall_status": "pass"
}
```

File name is the exact product commit plus `.json`. Reject manifests whose
content commit and filename disagree.

`checks` is required and each entry has exactly `code`, `status`,
`command_indexes`, and `artifact_indexes`. Codes use uppercase reason-code
syntax, statuses are `pass|fail`, indexes are unique nonnegative integers, and
each check references at least one command or artifact. Runtime validation
bounds-checks every index, requires a passing check's commands to exit `0`, and
requires its artifacts to exist at `product_commit` with matching exact-byte
SHA-256. Duplicate check codes are rejected.

Runtime evidence validation also requires:

```text
manifest path == evidence/<product_commit>.json
manifest work_unit_id and ledger_row_ids == the owned cursor for a new checkpoint
strict UTC timestamps parse semantically
started_at_utc <= completed_at_utc <= last_verified_checkpoint.verified_at_utc
last_verified_checkpoint.verified_at_utc <= transition.occurred_at_utc
environment is exactly windows plus string-or-null device_id
overall_status == pass and every command exits 0
no duplicate artifact paths and every artifact blob/hash matches product_commit
```

For `complete`, the committed manifest must contain exactly one passing
`FULL`, `ANDROID_PREP`, `CONTENT`, `VISUAL`, `PRODUCT_TRUTH`, and `PHONE_QA`
check. The wrapper maps those committed checks to the existing normalized
completion-readiness input and derives `checkpoint_commit` from the aligned
parent `HEAD`; no caller may supply a parallel completion summary.

Evidence rules by transition are exact:

```text
closeout, pause:
  require a new owned-cursor manifest and advance last_verified_checkpoint
stop with reason BUDGET_EXHAUSTED and post-transition remaining budget 0:
  require a new owned-cursor manifest and advance last_verified_checkpoint;
  do not advance generation or expose successor eligibility
finalize:
  require the unchanged historical candidate-parent manifest; do not claim a
  completed DCL-RC manifest and do not advance last_verified_checkpoint
complete:
  require the new owned DCL-RC manifest and advance last_verified_checkpoint
stop, finalization_stop with a historical checkpoint:
  preserve last_verified_checkpoint byte-for-byte and validate that exact
  historical path without rebinding it to the current cursor
active -> stopped with no historical checkpoint:
  require no manifest, keep last_verified_checkpoint null, require recovery,
  and prove recovery.last_clean_commit reachable from the parent checkpoint
finalizing -> stopped:
  cannot use the null-manifest exception because finalizing requires a
  historical checkpoint
```

`closeout` and `complete` may either preserve control-surface state or schedule
`pending` for their newly verified product commit. Later nonvisual checkpoints
may preserve an older pending target. A same-mode `administrative_sync` may
only resolve the exact pending target to `synced` or `failed`; it cannot retarget
Figma fields or change product, budget, cursor, owner, or recovery state.

Unsafe or unproven release returns `STOP_PENDING` before writing, staging,
charging, committing, or pushing candidate state.

- [x] **Step 4: Implement the two-phase closeout**

For normal units:

```text
merge verified unit -> clean-main proof -> commit/push evidence checkpoint
-> verify 0 0 -> remove exact owned worktree/branch -> stage state/handoff
-> validate staged tree and post-gate dirt -> commit/push state -> verify 0 0
```

The public staged and committed validator must pass the same derived ledger,
evidence, release, and completion-readiness inputs in both modes. The state
script stages only the run-state path plus existing dirty
`ACTIVE_HANDOFF.md`/`SLICE_LOG.md` closeout updates, rejects every other dirty
or staged path, runs the Docs profile, proves the staged tree did not move,
commits with the five required transition trailers, validates the committed
candidate, and attempts one bounded noninteractive normal push to one captured
immutable endpoint.

For DCL-RC:

```text
active -> finalizing (charge consumed, owner retained)
-> final proof and DCL-RC closure -> push aligned evidence checkpoint
-> cleanup while owner retained -> finalizing -> complete
-> push terminal transition -> clean 0 0, no successor
```

- [x] **Step 5: Prove GREEN and commit**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File test/scripts/autonomous_completion_behavior_test.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File test/scripts/autonomous_completion_git_fixture_test.ps1
flutter test test/scripts/autonomous_completion_script_test.dart --reporter compact
flutter test test/copy/current_docs_local_truth_test.dart --reporter compact
git diff --check
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs
```

Then commit:

```powershell
git add apps/aquarium_app/scripts/autonomous_completion apps/aquarium_app/test/scripts apps/aquarium_app/docs/agent
git commit -m "feat: close autonomous units safely"
```

---

### Task 10: Generate Duplicate-Safe Project Handoffs

**Files:**

- Create: `apps/aquarium_app/scripts/autonomous_completion/new_autonomous_handoff_prompt.ps1`
- Modify: `apps/aquarium_app/docs/agent/autonomous_completion/schemas/handoff_prompt_report.schema.json`
- Modify: `apps/aquarium_app/docs/agent/AUTONOMOUS_CHAIN_HANDOFF_PROMPT.md`
- Modify: `apps/aquarium_app/docs/agent/AUTONOMOUS_PHONE_COMPLETION_RUNBOOK.md`
- Modify: `apps/aquarium_app/test/scripts/autonomous_completion_behavior_test.ps1`
- Modify: `apps/aquarium_app/test/scripts/autonomous_completion_script_test.dart`

**Interfaces:**

- PowerShell generates a title, exact marker, and paste-ready prompt only.
- Codex task lookup/creation is an explicit coordinator action using live tool
  schemas; PowerShell never pretends to create tasks.
- Output separates `runner_compatible` from
  `explicit_launch_task_capable` and `automatic_successor_capable`.
- `TaskCapabilitiesJson` and `SavedProjectJson` use the strict property sets
  defined by the stable interface above; unknown fields or wrong types reject
  the request without mutation. All-false task capabilities or an all-null
  saved-project identity are valid fallback inputs that keep the selected
  capability false and preserve the complete prompt.
- `Launch` consumes a `Launch` readiness report. `Successor` consumes a
  `Claim` readiness report. Positive capability additionally requires a report
  no older than 120 seconds, the exact committed live state bytes matching the
  supplied state, clean `HEAD == main == origin/main`, the checked-out branch
  `main`, exact repository/project binding, positive remaining budget, and a
  launch-authorized compatible runner manifest. Missing live state during
  bootstrap still permits deterministic fallback prompt generation, but both
  operational task capabilities remain false.
- `PromptKind Launch` renders only from `ready` and uses marker
  `<run_id>/launch/0`; it is not a successor. Its capability remains false
  until the state is launch-authorized and live-bound.
- `PromptKind Successor` renders only from `handoff_ready` and uses marker
  `<run_id>/<handoff_generation>`. Its capability remains false until that
  state is live, pushed, and aligned.
- The report schema represents both outcomes. A kind/state mismatch or
  malformed strict input is `accepted: false`, includes the actual observed
  mode when parseable, nulls generated fields, emits a stable failure code,
  and exits `1`. A valid kind/state request is `accepted: true` and exits `0`
  even when capability is false and only a paste-ready fallback is possible.

- [ ] **Step 1: Add failing prompt/capability tests**

Assert exactly one kind-specific marker appears in title and prompt:

```text
Launch -> <run_id>/launch/0
Successor -> <run_id>/<handoff_generation>
```

Missing `list_threads`, `read_thread`, project-scoped `create_thread`, or saved
project identity must set the selected capability false and return a full
paste-ready prompt without changing state. Reject `Launch` from
`handoff_ready`, `Successor` from `ready`, and either kind from `active`,
`finalizing`, `stopped`, or `complete`.

- [ ] **Step 2: Run and prove RED**

Run behavior and Dart script tests. Expected: FAIL because the generator is
missing.

- [ ] **Step 3: Implement the coordinator algorithm in the runbook**

The live coordinator must:

```text
1. Resolve the saved Danio project.
2. Select the exact launch or successor marker from the validated prompt kind.
3. Exhaust list_threads pagination for that exact marker.
4. read_thread each exact candidate.
5. Reuse one queued/running match without messaging it again.
6. Inspect stopped/completed matches and preserve their real stop reason.
7. Create once only when zero matches and project binding is exact.
8. Verify the returned task with read_thread.
9. On multiple matches, ambiguous binding, or unknown create outcome, create
   nothing, preserve the current eligible mode, and return the prompt.
```

For `Launch`, step 9 leaves state `ready`; for `Successor`, it leaves state
`handoff_ready`. A launch task must begin with fresh synchronization and win
the `ready -> active` compare-and-swap claim before any product audit or edit.

`send_message_to_thread` is recovery-only. Do not use `fork_thread` for
successors. Use a native idempotency key only if the live create schema exposes
one.

- [ ] **Step 4: Prove GREEN and commit**

Run behavior, script, and current docs tests. Commit:

```powershell
git add apps/aquarium_app/scripts/autonomous_completion apps/aquarium_app/docs/agent apps/aquarium_app/test/scripts
git commit -m "feat: generate duplicate-safe handoffs"
```

---

### Task 11: Integrate Autonomous Proof Into The Docs Gate

**Files:**

- Modify: `apps/aquarium_app/scripts/quality_gates/run_local_quality_gate.ps1`
- Modify: `apps/aquarium_app/test/scripts/local_quality_gate_script_test.dart`
- Modify: `apps/aquarium_app/test/scripts/autonomous_completion_script_test.dart`
- Modify: `apps/aquarium_app/test/copy/current_docs_local_truth_test.dart`
- Modify: `apps/aquarium_app/docs/agent/QUALITY_LADDER.md`
- Modify: `apps/aquarium_app/docs/agent/TESTING_CHECKLIST.md`

**Interfaces:**

- Add the Dart script test to `$FocusedTests`.
- Add `Invoke-AutonomousCompletionTests` to Docs and Full profiles.
- The PowerShell behavior suite is pure; the Git fixture suite runs only in
  disposable temp repositories and must clean its own verified temp paths.

- [ ] **Step 1: Add failing gate-contract assertions**

Assert the gate contains:

```powershell
function Invoke-AutonomousCompletionTests {
  Invoke-Step -Name "Autonomous completion behavior tests" -Command {
    & powershell -NoProfile -ExecutionPolicy Bypass -File `
      "test/scripts/autonomous_completion_behavior_test.ps1"
    if ($global:LASTEXITCODE -ne 0) {
      throw "Autonomous completion behavior tests failed."
    }
  }
}
```

Also assert Docs and Full invoke it and the focused list contains
`test/scripts/autonomous_completion_script_test.dart`.

- [ ] **Step 2: Run and prove RED**

```powershell
flutter test test/scripts/local_quality_gate_script_test.dart --reporter compact
```

Expected: FAIL because the gate lacks the autonomy suite.

- [ ] **Step 3: Integrate and document gate tiers**

Add Quality Ladder rows for:

```text
Authority/schema change -> docs truth + script contract + Docs
Pure state/readiness change -> behavior + disposable fixture + Docs
Git mutation/claim/closeout change -> race fixtures + Docs + clean-main Docs
No-product rehearsal -> all autonomy suites + Docs -RequireCleanWorktree
Phone release candidate -> Full + AndroidPrep + evidence manifest + phone QA
```

- [ ] **Step 4: Prove GREEN and commit**

Run focused gate tests, then:

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs
```

Commit:

```powershell
git add apps/aquarium_app/scripts/quality_gates apps/aquarium_app/test apps/aquarium_app/docs/agent
git commit -m "test: gate autonomous completion workflow"
```

---

### Task 12: Run The No-Product-Change, No-Successor Rehearsal

**Files:**

- Create: `apps/aquarium_app/scripts/autonomous_completion/run_autonomous_completion_rehearsal.ps1`
- Modify: `apps/aquarium_app/scripts/autonomous_completion/DanioAutonomousCompletion.psm1`
- Modify: `apps/aquarium_app/docs/agent/AUTONOMOUS_PHONE_COMPLETION_RUNBOOK.md`
- Modify: `apps/aquarium_app/docs/agent/autonomous_completion/runner_compatibility.json`
- Modify: `apps/aquarium_app/test/scripts/autonomous_completion_behavior_test.ps1`
- Modify: `apps/aquarium_app/test/scripts/autonomous_completion_git_fixture_test.ps1`
- Modify: `apps/aquarium_app/test/scripts/autonomous_completion_script_test.dart`
- Create after a real rehearsal: `apps/aquarium_app/docs/agent/autonomous_completion/rehearsal-<UTC-date>.json`

**Interfaces:**

- The rehearsal may fetch through the synchronization wrapper.
- It must not change tracked/untracked files, index, local/remote refs, branches,
  worktrees, tasks, Android runtime, Figma, or external services.
- The durable rehearsal report is created only after the external script exits;
  it records before/after observations proving equality.
- `authorizes_launch` stays false during rehearsal and may become true only in
  a later commit that pins the committed rehearsal report path, SHA-256, and
  containing commit.

- [ ] **Step 1: Add failing zero-side-effect test**

The report requires:

```json
{
  "mutations": {
    "repository_files": false,
    "index": false,
    "local_refs": false,
    "remote_refs": false,
    "worktrees": false,
    "successor_tasks": false,
    "android_runtime": false,
    "figma": false,
    "external_services": false
  }
}
```

- [ ] **Step 2: Run and prove RED**

Run behavior/Git fixtures. Expected: FAIL because the rehearsal script is
missing.

- [ ] **Step 3: Implement and run the actual rehearsal**

Use a 32-hex nonce and the current setup task ID. Pass a proposed positive
budget but do not write live state. The report must show launch/claim/closeout
previews and exact blocking codes, then prove repository observations match.
Launch preview must report `LAUNCH_NOT_AUTHORIZED` while every prerequisite
other than the still-false authorization bit passes.

- [ ] **Step 4: Materialize and validate the durable report**

Create the report from the completed ephemeral output, validate its schema and
hash, then run all autonomy suites and the normal Docs profile. Do not use
`-RequireCleanWorktree` while the new report is intentionally uncommitted.

- [ ] **Step 5: Independent review and commit the rehearsal proof**

Dispatch a repository-read-only reviewer for the full setup diff and rehearsal
report. Resolve findings, rerun the normal Docs gate, and commit while launch
authorization remains false:

```powershell
git add apps/aquarium_app/scripts/autonomous_completion apps/aquarium_app/test/scripts apps/aquarium_app/docs/agent
git commit -m "test: rehearse autonomous completion safely"
```

Capture this exact commit and the report's exact-byte SHA-256.

- [ ] **Step 6: Authorize launch from committed proof**

Update `runner_compatibility.json` to set `authorizes_launch: true` and add:

```json
{
  "launch_proof": {
    "report_path": "apps/aquarium_app/docs/agent/autonomous_completion/rehearsal-2026-07-11.json",
    "report_sha256": "64-lowercase-hex",
    "report_commit": "40-lowercase-hex"
  }
}
```

The validator must load that report from `report_commit`, verify path/blob/hash,
require every mutation flag false, and reject a working-tree-only report. Run
all autonomy suites and Docs, increment `manifest_revision`, then commit. The
Task 12 module change must replace the bootstrap-only unconditional rejection
of `authorizes_launch: true` with this exact committed rehearsal-proof
validation; no other launch path is accepted:

```powershell
git add apps/aquarium_app/scripts/autonomous_completion/DanioAutonomousCompletion.psm1 apps/aquarium_app/docs/agent/autonomous_completion/runner_compatibility.json apps/aquarium_app/test/scripts
git commit -m "chore: authorize autonomous phone launch"
```

- [ ] **Step 7: Run the clean gate and publish Task 12**

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs -RequireCleanWorktree
```

Fast-forward both exact Task 12 commits to `main`, push, and verify clean
`main...origin/main = 0 0`. Do not activate the live run in the rehearsal
branch or before that checkpoint. The original user authorization permits the
coordinator to create/reuse one explicit project-scoped Task 13 bootstrap task
after this proof; this is not yet an operational automatic successor.

---

### Task 13: Activate The Run From The Existing User Authorization

**Files:**

- Create: `apps/aquarium_app/docs/agent/autonomous_completion/phone_completion_run_state.json`
- Modify: `apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md`
- Modify: `apps/aquarium_app/docs/agent/SLICE_LOG.md`

**Interfaces:**

- Activation is allowed only after Tasks 1-12 pass on clean aligned `main`.
- Use the remaining integer budget from the current committed handoff; do not
  reset it to 20 after setup units have consumed units.
- Initial mode is `ready`, with no owner/current charge.
- The Task 13 activation commit is itself the durable closeout of a setup unit:
  count it once in `consumed_units` and exclude it from the remaining product
  budget. Do not represent it as a claimed product charge.
- Activation is an atomic absent-state `inactive -> ready` bootstrap. It is
  rejected if the state path already exists, the bootstrap authorization ID
  mismatches, or the Task 13 unit ID is already recorded.
- First authorized product work unit is a read-only `DCL-DR-001` restore matrix
  audit.

- [ ] **Step 1: Run synchronization and Launch readiness**

Generate a fresh receipt, then run readiness with `-Intent Launch`. Expected:
`eligible: true`, no authority/runner/budget/ownership blockers, a committed
rehearsal-backed `authorizes_launch: true`, and no existing live state file.

- [ ] **Step 2: Prepare the live run state**

Set:

```text
run_id = danio-phone-complete-local-2026-07-11
mode = ready
state_revision = 1
total_approved_units = 20
consumed_units = number of cleanly closed planning/setup units
remaining_units_including_current = 20 - consumed_units
current_charge.status = none
handoff_generation = 0
owner = null
cursor.phase = 1-data-resilience
cursor.work_unit_id = DCL-DR-001-restore-matrix-audit
cursor.ledger_row_ids = [DCL-DR-001]
```

The committed activation state includes the planning unit and every setup unit
through Task 13 in `consumed_units`. With the current risk-split unit map in
this plan that is 10 consumed and 10 remaining; if any earlier setup unit is
split again, derive the larger consumed count from the committed
bootstrap-budget block and matching unique `SLICE_LOG.md` unit IDs.
Specifically:

```text
consumed_units = bootstrap.consumed_units + 1
remaining_units_including_current =
  bootstrap.remaining_units_including_current - 1
last consumed unit = Task 13 unit ID
```

Require positive pre-activation remaining budget and validate both arithmetic
identities. In the same commit, replace the bootstrap block's null
`operational_state_path` with the run-state path and mark it historical; after
that commit, only run state may authorize or account for units. Never hardcode
the sample counts in the validator.

- [ ] **Step 3: Validate staged activation and Docs profile**

Use the staged transition validator with expected absent state, capture
`git write-tree`, run Docs, prove the tree and dirt state remain unchanged,
then commit with verification trailers. The validator proves the Task 13 setup
charge is absorbed exactly once while `current_charge.status` remains `none`.

- [ ] **Step 4: Push, align, and create/reuse the next product task**

After clean `main...origin/main = 0 0`, call the generator with
`PromptKind Launch` and apply the duplicate-safe algorithm to marker
`<run_id>/launch/0`. This is the explicitly authorized first product task from
`ready`, not an automatic successor and not a budget transfer. If task
capabilities or project binding are unavailable/ambiguous, leave mode `ready`
and return the paste-ready launch prompt; do not fabricate handoff readiness.
The created/reused task must synchronize, run Claim readiness, and win
`ready -> active` before auditing or editing `DCL-DR-001`.

Commit message:

```powershell
git commit -m "chore: activate autonomous phone completion"
```

---

## Product Execution After Activation

After Task 13, follow
`2026-07-11-phone-complete-local-completion-program.md` exactly:

1. Data resilience: `DCL-DR-001` through `DCL-DR-004`.
2. Optional AI and preferences: `DCL-AI-001`, `DCL-PREF-001`.
3. Normal-user depth: `DCL-P1-003` through `DCL-P1-006`.
4. Content/rules: `DCL-CONTENT-001`, `DCL-RULE-001`.
5. Phone accessibility/visual/motion: `DCL-A11Y-001`, `DCL-VIS-001`,
   `DCL-VIS-002`, `DCL-MOTION-001`.
6. Phone performance: `DCL-PERF-001`.
7. Terminal evidence: `DCL-RC-001` through `finalizing -> complete`.

Use a high-risk micro-slice for data, migration, destructive, Optional AI
write, and release-candidate work. Use a maximum three-micro-slice epoch only
for tightly related low-risk surfaces sharing one proof setup.

## Plan Self-Review Checklist

- [x] Every approved design section maps to Task 1-13.
- [x] No unresolved implementation markers or omitted code steps are present.
- [x] File and function names are consistent across all tasks.
- [x] Closure state is represented once in the ledger, not duplicated in a
  companion state file.
- [x] Installed-skill changes are separate, reviewed, validated, and pinned.
- [x] Mutation scripts appear only after pure contracts and fixture proof.
- [x] Automatic task creation remains disabled until capability and rehearsal
  gates pass.
- [x] Budget includes the current unit and is decremented exactly once at
  durable unit closeout/stop, never at claim or transfer.
- [x] No setup task touches app product behavior, Android runtime, Figma, paid
  services, accounts, provider keys, or secrets.
- [x] Every setup execution unit ends clean, pushed, aligned, and documented.

## Execution Handoff

Implementation uses **Inline Execution** with
`superpowers:executing-plans`, because the approved operating model prohibits
write subagents. Read-only auditors remain available for independent checks.

The next fresh project-scoped task starts with Task 1, setup unit 1, and a
remaining sequential budget of 19 including that successor. It must rebuild
truth from the repository and installed skills before editing. It must not
start `DCL-DR-001`, Android runtime, or automatic chaining.
