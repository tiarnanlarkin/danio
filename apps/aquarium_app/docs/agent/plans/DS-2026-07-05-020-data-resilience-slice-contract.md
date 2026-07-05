# Danio Slice Contract: DS-2026-07-05-020

## Slice

- ID: `DS-2026-07-05-020`
- Title: Zero-tank backup restores must not copy photos
- Branch/worktree: `ds-2026-07-05-020-zero-tank-photo-restore`
- Coordinator: current Codex session
- Worker agents, if any: none
- Owned files/modules:
  - `lib/services/backup_service.dart`
  - `test/services/backup_service_photo_restore_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/SLICE_LOG.md`
  - `docs/agent/plans/DS-2026-07-05-020-data-resilience-slice-contract.md`
- Files/modules explicitly out of scope: Backup UI, account/cloud restore,
  SharedPreferences restore internals, Android screenshots, schema migration,
  and broader create/edit/delete/app-kill coverage.

## Product Goal

- User-visible outcome: importing a backup with no tanks cannot leave stray
  restored photo files while reporting that no tanks were found.
- Complete-local requirement this advances: local restore/import paths must not
  leave partial local data after a no-op restore.
- Finish Map row(s): Backup and restore; Data resilience.
- Product backlog row(s): `CL-P1-009`; `CL-QA-006`.

## Research And Planning

- Fresh session recommended: No; this is already a fresh delegated session and
  the startup checklist was rebuilt from repo docs and live git state.
- Repo context checked: `AGENTS.md`, README files, `ACTIVE_HANDOFF.md`,
  `FINISH_MAP.md`, `QUALITY_LADDER.md`, `TESTING_CHECKLIST.md`,
  `WORKFLOW_CHARTER.md`, `RESEARCH_PROTOCOL.md`, `DEVICE_OWNERSHIP.md`,
  `LIVE_PREVIEW_WORKFLOW.md`, `AUTONOMOUS_QUALITY_SETUP.md`,
  `CODEX_SETUP.md`, `SCREEN_INVENTORY.md`, `SLICE_LOG.md`, current product
  audit/backlog data-resilience sections, Backup service source/tests.
- Current best-practice sources checked: repo source and tests only; no
  framework/API decision requires current external docs.
- Tool/plugin/MCP/account-backed lane considered: not needed.
- Tool/plugin/MCP/account-backed lane approved: not needed.
- Decision-changing research notes: `BackupRestoreScreen` calls
  `BackupService.restoreBackup` before `BackupRestoreImportFlow` returns the
  imported tank count. `restoreBackup` extracts every `photos/` archive entry,
  so a zero-tank backup can copy photo files before the no-tanks warning.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: not applicable; service
  data-safety slice.
- Phone expectation: no UI/layout change.
- Tablet expectation: no UI/layout change.
- Accessibility expectation: no UI copy/control change.
- Visual evidence required: none.

## Tests And Gates

- Focused test(s):
  - RED/GREEN `flutter test test/services/backup_service_photo_restore_test.dart --plain-name "restoreBackup skips photo extraction when a backup has no tanks" --reporter compact`
  - `flutter test test/services/backup_service_photo_restore_test.dart --reporter compact`
- Required local gate: `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
- Android evidence required: No. `adb devices -l` showed no attached devices
  and live-preview `-CheckOnly` reported `danio_api36` was not running; this
  service-level slice does not need emulator ownership.
- External review/tool lane: none.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: backup restore photo extraction into local documents
  `photos/`.
- Failure states to test: zero-tank backup with bundled photo entries.
- Rollback or retry behavior: no photo files should be copied for a no-tank
  restore, so no cleanup should be required.
- No-fake-feature/product-honesty check: no cloud/account/API behavior added.

## Done Criteria

The slice is done only when:

- the focused test fails before production change for the expected restored-photo
  residue;
- the focused test and full backup photo restore test pass after the fix;
- the Full quality gate passes;
- `git diff --check` passes;
- active handoff and slice log record the result;
- only owned files are staged and committed;
- the branch is merged to `main`, pushed, and cleaned up if all gates pass.

## Result

- Commit: Current commit
- Verification summary:
  - RED: `flutter test test/services/backup_service_photo_restore_test.dart --plain-name "restoreBackup skips photo extraction when a backup has no tanks" --reporter compact` failed because an orphan photo was restored.
  - GREEN: same focused command passed after `BackupService.restoreBackup` returned before photo extraction for zero-tank backups.
  - `flutter test test/services/backup_service_photo_restore_test.dart --reporter compact`
  - `dart format lib/services/backup_service.dart test/services/backup_service_photo_restore_test.dart`
  - `flutter analyze lib/services/backup_service.dart test/services/backup_service_photo_restore_test.dart`
  - `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
  - Post-doc closeout checks: `git diff --check`; `flutter test test/copy/current_docs_local_truth_test.dart --reporter compact`
- Evidence path: not applicable; no screenshots.
- Follow-up created: Continue broader data-resilience restore, migration,
  create/delete, and future debounced-writer app-kill coverage.
