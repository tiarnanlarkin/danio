# Danio Slice Contract: DS-2026-07-04-018

## Slice

- ID: `DS-2026-07-04-018`
- Title: Backup import must roll back partially persisted tanks
- Branch/worktree: `ds-2026-07-04-018-import-tank-rollback`
- Coordinator: current Codex coordinator
- Worker agents, if any: none
- Owned files/modules:
  - `lib/services/backup_import_service.dart`
  - `test/services/backup_import_service_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/SLICE_LOG.md`
  - `docs/agent/plans/DS-2026-07-04-018-data-resilience-slice-contract.md`
- Files/modules explicitly out of scope: Backup UI, ZIP photo restore,
  `FINISH_MAP.md`, product backlog status rows, Android devices, screenshots,
  and broader restore/migration/app-kill coverage.

## Product Goal

- User-visible outcome: a failed Backup & Restore import cannot leave a
  partially imported tank visible if local storage persisted it and then
  reported failure.
- Complete-local requirement this advances: local restore/import paths must not
  expose false success or leave partial local data after failed writes.
- Finish Map row(s): Data resilience.
- Product backlog row(s): `CL-P1-009`; `CL-QA-006`.

## Research And Planning

- Fresh session recommended: No; this was a narrow continuation from a fresh
  handoff and clean, origin-aligned `main`.
- Repo context checked: `AGENTS.md`, `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`,
  `QUALITY_LADDER.md`, `TESTING_CHECKLIST.md`, the complete-local audit and
  backlog, Backup & Restore source/tests, backup import service/tests, schema
  migration source/tests, and app lifecycle contract test.
- Current best-practice sources checked: not needed; this is a repo-local
  storage transaction boundary.
- Tool/plugin/MCP/account-backed lane considered: not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: `BackupImportService` tracked imported
  tank IDs only after `storage.saveTank()` returned. A storage implementation
  can persist the tank and then throw, leaving rollback without the new tank ID.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: not applicable.
- Phone expectation: no layout change.
- Tablet expectation: no layout change.
- Accessibility expectation: no UI change.
- Visual evidence required: none; non-visual service data-safety slice.

## Tests And Gates

- Focused test(s):
  - `flutter test test/services/backup_import_service_test.dart --name "rolls back a tank when saveTank persists then reports failure" --reporter compact`
  - `flutter test test/services/backup_import_service_test.dart --reporter compact`
- Required local gate:
  - `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
- Android evidence required: none.
- External review/tool lane: none.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: tank-scoped backup import writes.
- Failure states to test: `saveTank` persists a newly imported tank and then
  throws before reporting success.
- Rollback or retry behavior: the import throws `BackupImportException` and
  rollback deletes the partially persisted imported tank and any tank-scoped
  children.
- No-fake-feature/product-honesty check: failed import cannot leave partial
  local data while reporting failure to the UI.

## Done Criteria

The slice is done only when:

- the focused backup import rollback test fails before the production change;
- the named test and full backup import service test file pass after the
  change;
- targeted analysis passes;
- the `Full` local quality gate passes in the integration checkout;
- post-doc `git diff --check` and current-doc truth test pass;
- docs are updated with the current slice result and next queue;
- no unrelated dirty files are staged.

## Result

- Commit: Current commit after this slice is committed.
- Verification summary: RED named service test failed because the partially
  persisted `new-tank` remained after a simulated `saveTank` failure; GREEN
  named and full backup import service tests passed; targeted analysis passed;
  `Full` local quality gate passed including full tests, analyzer, and debug
  APK build; post-doc checks passed.
- Evidence path: test output only; no screenshot evidence required.
- Follow-up created: Continue broader data-resilience restore, migration,
  create/delete, and future debounced-writer app-kill coverage.
