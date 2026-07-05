# DS-2026-07-05-034 Backup Import Child Tank Guard

## Slice

- ID: DS-2026-07-05-034
- Title: Reject backup import child rows for unknown tank IDs
- Branch/worktree: `ds-2026-07-05-034-import-child-tank-guard`
- Coordinator: current Codex session
- Worker agents: none
- Owned files/modules:
  - `lib/services/backup_import_service.dart`
  - `test/services/backup_import_service_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/FINISH_MAP.md`
  - `docs/agent/SLICE_LOG.md`
  - `docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
  - `docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Out of scope:
  - Backup ZIP preview validation changes
  - SharedPreferences restore behavior
  - Android install, tap, screenshot, or live-preview refresh
  - Product copy or visual changes
  - Paid, cloud, account-backed, provider-key, or release work

## Product Goal

- User-visible outcome: the lower tank-scoped backup import boundary cannot
  report a successful partial tank import while silently skipping child rows
  whose `tankId` does not belong to an imported backup tank.
- Complete-local requirement: close one CL-P1-009 / CL-QA-006 restore and
  relationship-integrity gap.
- Finish Map rows: Data resilience; Backup and restore.
- Product backlog rows: CL-P1-009 and CL-QA-006.

## Read-Only Selection Audit

- Startup state was clean `main` aligned with `origin/main` (`main...origin/main`
  was `0 0`) before the slice branch.
- Current handoff and Finish Map rank data resilience first and name restore,
  migration, create/edit/delete, relationship mapping, and future debounced
  writers as the remaining lane.
- Recent slices already cover preference restore type guards, import-flow
  malformed preferences, tank/child ID collisions, local JSON load errors,
  schema stamp failures, and several parent/undo relationship gaps.
- `BackupService.getBackupData` rejects orphan child `tankId` values before ZIP
  preview/import, but `BackupImportService.importTankScopedData` currently
  returns success after importing tanks and skipping child rows whose `tankId`
  is absent from `tankIdMap`.
- `test/services/backup_import_service_test.dart` has focused storage fakes and
  rollback assertions, so the gap can be proven in one service/test family.

## Tests And Gates

- RED test:
  `flutter test test/services/backup_import_service_test.dart --name "rejects child entries with unknown backup tank ids before reporting import success" --reporter compact`
- GREEN proof: same named test, then full `test/services/backup_import_service_test.dart`.
- Targeted analyze:
  `flutter analyze lib/services/backup_import_service.dart test/services/backup_import_service_test.dart`
- Required local gate: `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full -RequireCleanWorktree`
- Docs checks after doc updates:
  - `git diff --check`
  - `flutter test test/copy/current_docs_local_truth_test.dart --reporter compact`
- Android evidence required: no; this is pure service data-safety behavior and
  live-preview `-CheckOnly` already passed at startup.
- External review/tool lane: none.
- Paid-tool ledger entry required: no.

## Data And Safety

- Local data touched: tank-scoped backup import transaction behavior only.
- Failure state to test: imported backup data includes at least one valid tank
  plus a child row in `livestock`, `equipment`, `tasks`, or `logs` that
  references a tank ID absent from the imported tank list.
- Expected behavior: import throws a `BackupImportException`, rolls back the
  newly imported tank and any saved children, and leaves no false partial
  success state.
- Rollback safety: existing `deleteAllTanks(importedTankIds)` rollback remains
  the cleanup path; no unrelated local data should be removed.
- Risk tier: 2, data safety / restore and relationship integrity.

## Done Criteria

The slice is done only when the RED/GREEN focused proof passes, the full
touched test file passes, targeted analyze passes, the required Full gate
passes on a clean worktree, docs/logs are updated, the branch is merged to
`main`, `origin/main` is pushed and aligned, and temporary branch cleanup is
complete.
