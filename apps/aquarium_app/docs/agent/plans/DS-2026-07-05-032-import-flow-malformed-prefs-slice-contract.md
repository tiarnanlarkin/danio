# DS-2026-07-05-032 Import Flow Malformed Preference Payload Guard

## Slice

- ID: DS-2026-07-05-032
- Title: Report malformed Backup & Restore import preference payloads
- Branch/worktree: `ds-2026-07-05-032-import-flow-malformed-prefs`
- Coordinator: current Codex session
- Worker agents, if any: none
- Owned files/modules:
  - `lib/services/backup_import_service.dart`
  - `test/services/backup_import_service_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/FINISH_MAP.md`
  - `docs/agent/SLICE_LOG.md`
- Files/modules explicitly out of scope:
  - Android runtime interaction, screenshots, cloud/account restore, backup ZIP validation rules, storage API expansion, and visual/UI layout changes.

## Product Goal

- User-visible outcome: if a tank import receives a malformed app-wide preferences payload, Danio keeps the tank import result explicit and reports that profile/preferences could not be restored instead of silently treating the malformed payload as absent.
- Complete-local requirement this advances: backup/restore data resilience and normal-user restore honesty.
- Finish Map row(s): `Data resilience`; `Backup and restore`.
- Product backlog row(s): `CL-P1-009`; `CL-QA-006`.

## Research And Planning

- Fresh session recommended: no; this is already a fresh successor with clean aligned startup state.
- Repo context checked: `AGENTS.md`, `GIT_WORKFLOW.md`, active handoff, finish map, quality ladder, testing checklist, slice log, accelerated epoch plan, product audit/backlog, workflow charter, research protocol, device ownership, live preview workflow, and current backup import source/tests.
- Current best-practice sources checked: repo source/tests only; this is existing service behavior, not a framework/API decision.
- Tool/plugin/MCP/account-backed lane considered: none.
- Tool/plugin/MCP/account-backed lane approved: not needed.
- Decision-changing research notes: `BackupService.getBackupData` rejects malformed preference payloads on the ZIP path, and `CloudBackupService` reports malformed direct preference payloads as preference restore failures. `BackupRestoreImportFlow` currently skips non-map `sharedPreferences` payloads after importing tanks, leaving no warning flag for callers that use the flow boundary directly.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: not applicable; service-only data-safety behavior.
- Phone expectation: no UI layout changed.
- Tablet expectation: no UI layout changed.
- Accessibility expectation: no UI semantics changed.
- Visual evidence required: no.

## Tests And Gates

- Focused test(s):
  - RED/GREEN named test in `test/services/backup_import_service_test.dart` for malformed preference payload reporting.
  - Full touched file: `flutter test test/services/backup_import_service_test.dart --reporter compact`.
- Required local gate: `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full -RequireCleanWorktree`.
- Android evidence required: no; `run_danio_live_preview.ps1 -CheckOnly` was startup-only and no runtime interaction is required.
- External review/tool lane: none.
- Paid-tool ledger entry required: no.

## Data And Safety

- Local data touched: backup import result metadata only; imported tank data remains unchanged.
- Failure states to test: malformed non-map `sharedPreferences` payload with a successful tank import.
- Rollback or retry behavior: tank-scoped import remains governed by existing rollback tests; this slice only prevents false "no preference issue" reporting.
- No-fake-feature/product-honesty check: no cloud, paid, fake AI, premium, or account-backed behavior.

## Done Criteria

The slice is done only when:

- focused RED and GREEN proof pass;
- full touched test file passes;
- targeted analyze passes;
- required Full gate passes with a clean worktree;
- `git diff --check` passes;
- repo handoff/log docs are updated;
- branch is merged to `main`, pushed to `origin/main`, and temporary branch is deleted.

## Result

- Commit: current pushed `main` commit after closeout
- Verification summary:
  - RED:
    `flutter test test/services/backup_import_service_test.dart --name "reports malformed preference payloads after importing tanks" --reporter compact`
    failed because `preferencesRestoreFailed` remained `false`.
  - GREEN: the same named test passed after the guard.
  - `flutter test test/services/backup_import_service_test.dart --reporter compact`
    passed with 7 tests.
  - Targeted `flutter analyze` passed for the service and test file.
  - `git diff --check` passed.
  - `flutter test test/copy/current_docs_local_truth_test.dart --reporter compact`
    passed after docs closeout.
  - Branch and clean-main Full gates passed with
    `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full -RequireCleanWorktree`.
- Evidence path: not applicable
- Follow-up created: continue read-only data-resilience gap selection from
  fresh source/test evidence; remaining chain budget after this slice is 7
  sequential verified sessions.
