# DS-2026-07-05-045 Restore Import Photo Cleanup Proof

## Slice

- ID: DS-2026-07-05-045
- Title: Prove restored-photo cleanup when tank import fails
- Branch/worktree: `ds-2026-07-05-045-restore-import-photo-cleanup-proof` in
  the main repo worktree
- Coordinator: current Codex session
- Worker agents, if any: none
- Owned files/modules:
  - `lib/services/backup_import_service.dart`
  - `lib/screens/backup_restore_screen.dart`
  - `test/services/backup_import_service_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md`
  - `docs/agent/FINISH_MAP.md`
  - `docs/agent/SLICE_LOG.md`
  - `docs/product/danio-complete-local-current-audit-2026-06-13.md`
  - `docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
  - this slice contract
- Files/modules explicitly out of scope:
  - Android runtime/device ownership, cloud/account restore, paid tools, API
    keys, providers, premium, store, deploy, optional-AI behavior, and unrelated
    backup/migration findings

## Product Goal

- User-visible outcome: when a backup restores photo files and then tank import
  fails, Danio cleans the newly restored photo files instead of leaving orphaned
  local files from a failed restore.
- Complete-local requirement this advances: restore failure behavior has
  executable local proof as part of data-resilience closure.
- Finish Map row(s): Backup and restore; Data resilience
- Closure ledger ID: `DCL-DR-001`
- Product backlog row(s): `CL-P1-009`; `CL-P1-009DH`; `CL-QA-006`

## Research And Planning

- Fresh session recommended: No; this successor rebuilt context from repo docs,
  clean git state, and current source/tests.
- Repo context checked: `AGENTS.md`, `README.md`, `GIT_WORKFLOW.md`, closure
  ledger, execution contract, forecast, active handoff, finish map, quality
  ladder, testing checklist, slice log, accelerated epoch plan, backup restore
  source, backup import source, and backup import tests.
- Current best-practice sources checked: repo-owned backup/import and
  data-safety patterns only; no external API or platform behavior is involved.
- Tool/plugin/MCP/account-backed lane considered: Not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: `BackupService.restoreBackup` already tracks
  restored photo paths and can clean them up, while `BackupImportService`
  already rolls back imported tanks on import failure. Fresh test evidence found
  no executable service-level proof that `BackupRestoreImportFlow` invokes photo
  cleanup when tank import fails after photo extraction.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: Not applicable; service and
  failure-boundary slice only.
- Phone expectation: No UI layout changes.
- Tablet expectation: No UI layout changes.
- Accessibility expectation: No UI surface changes.
- Visual evidence required: No.

## Tests And Gates

- Focused proof:
  - RED:
    `flutter test test/services/backup_import_service_test.dart --plain-name "runs restored photo cleanup when tank import fails" --reporter compact`
    failed because `BackupRestoreImportFlow` did not expose
    `onImportFailureCleanup`.
  - GREEN:
    `flutter test test/services/backup_import_service_test.dart --plain-name "runs restored photo cleanup when tank import fails" --reporter compact`
    passed.
  - `flutter test test/services/backup_import_service_test.dart --reporter compact`
    passed.
  - `flutter analyze lib/services/backup_import_service.dart lib/screens/backup_restore_screen.dart test/services/backup_import_service_test.dart`
    passed.
- Required local gate:
  - `git diff --check`
  - `flutter test test/copy/current_docs_local_truth_test.dart --reporter compact`
  - `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
  - `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full -RequireCleanWorktree`
- Android evidence required: No; no runtime/device behavior or visual surface
  changed.
- External review/tool lane: None.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: backup-import service flow and restore-screen cleanup
  callback only.
- Failure states to test: tank-scoped import failure after photos have already
  been restored.
- Rollback or retry behavior: `BackupImportService` still rolls back imported
  tanks, and `BackupRestoreImportFlow` now calls the restore-screen cleanup hook
  before rethrowing the original import failure.
- No-fake-feature/product-honesty check: no provider, premium, cloud, AI, or
  fake capability added.

## Done Criteria

The slice is done only when:

- the focused RED/GREEN proof passes;
- the full touched service test file passes;
- targeted analyze passes;
- docs record the `DCL-DR-001` restore failure cleanup evidence;
- required Full gates pass;
- `git diff --check` passes;
- work is committed, merged to `main`, pushed, and branch cleanup leaves
  `main...origin/main` at `0 0`.

## Result

- Commit: Current commit
- Verification summary: focused import-flow cleanup test and full backup import
  service test file passed; targeted analyze passed; docs guard and Full gates
  are recorded in the slice log after closeout.
- Evidence path: `test/services/backup_import_service_test.dart` covers the
  tank-import failure cleanup callback through `BackupRestoreImportFlow`.
- Follow-up created: pending successor after clean pushed checkpoint.
