# Danio Slice Contract: DS-2026-07-04-011

## Slice

- ID: `DS-2026-07-04-011`
- Title: Backup imports with no tanks must not replace app-wide preferences
- Branch/worktree: `qa/production-tool-audit-2026-05-25` integration checkout
- Coordinator: current Codex coordinator
- Worker agents, if any: none
- Owned files/modules:
  - `lib/services/backup_import_service.dart`
  - `lib/screens/backup_restore_screen.dart`
  - `test/services/backup_import_service_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/FINISH_MAP.md`
  - `docs/agent/SLICE_LOG.md`
  - `docs/agent/plans/2026-07-04-complete-local-delivery.md`
  - `docs/agent/plans/DS-2026-07-04-011-data-resilience-slice-contract.md`
  - `docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
  - `docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Files/modules explicitly out of scope: backup ZIP validator expansion,
  BackupImportService relationship remapping, Android devices, screenshots,
  AI/security slices, and integration-smoke truthfulness work.

## Product Goal

- User-visible outcome: if a selected backup contributes no local tanks, Danio
  reports that no tanks were found without replacing profile, learning,
  preference, or gem data from that backup.
- Complete-local requirement this advances: Backup & Restore import-flow data
  safety and no false success or misleading partial-success states.
- Finish Map row(s): Data resilience; Backup and restore.
- Product backlog row(s): `CL-P1-009`, `CL-QA-006`.

## Research And Planning

- Fresh session recommended: No; this resume is clean, aligned with upstream,
  and the slice is narrow.
- Repo context checked: `AGENTS.md`, `CODEX_SETUP.md`, `ACTIVE_HANDOFF.md`,
  `FINISH_MAP.md`, `AUTONOMOUS_QUALITY_SETUP.md`, `TESTING_CHECKLIST.md`,
  `MULTI_AGENT_WORKFLOW.md`, `SLICE_LOG.md`, product backlog/current audit, and
  Backup & Restore source/tests.
- Current best-practice sources checked: not needed; this is a repo-local data
  safety fix using existing Backup & Restore import behavior.
- Tool/plugin/MCP/account-backed lane considered: not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: current screen code restores
  `sharedPreferences` after `BackupImportService.importTankScopedData` even when
  that import returns zero tanks, then shows "No tanks found in this backup
  file." That can silently overwrite app-wide data while showing no tank import.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: existing Backup & Restore
  import card and warning snackbar path.
- Phone expectation: no layout change.
- Tablet expectation: no layout change.
- Accessibility expectation: existing snackbar semantics unchanged.
- Visual evidence required: none; non-visual flow/data-safety slice.

## Tests And Gates

- Focused test(s):
  - `flutter test test/services/backup_import_service_test.dart --name "skips preference restore when backup imports no tanks" --reporter compact`
  - `flutter test test/services/backup_import_service_test.dart --reporter compact`
- Required local gate:
  - `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
- Android evidence required: none; no device ownership.
- External review/tool lane: none.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: Backup & Restore ZIP import flow, tank-scoped import
  result handling, and app-wide SharedPreferences restore boundary.
- Failure states to test: backup preview succeeds and user confirms import, but
  tank-scoped import returns zero imported tanks while the backup includes
  `sharedPreferences`.
- Rollback or retry behavior: no app-wide preferences are restored when no
  tanks are imported; the existing no-tanks warning remains the user feedback.
- No-fake-feature/product-honesty check: the UI cannot imply "no tanks found"
  while silently replacing app-wide local data.

## Done Criteria

The slice is done only when:

- the executable import-flow service test fails before the production change;
- the focused service and screen tests pass after the production change;
- the `Full` local quality gate passes in the integration checkout;
- `git diff --check` passes;
- docs are updated with the current slice result and next queue;
- no unrelated dirty files are staged.

## Result

- Commit: Current commit after this slice is committed.
- Verification summary: RED named service test failed before the production
  helper existed; GREEN named service test passed after implementation; full
  backup import service tests passed; Backup & Restore screen tests passed;
  targeted analysis passed; Full local quality gate passed; post-doc diff/docs
  truth checks passed.
- Evidence path: test output only; no screenshot evidence required.
- Follow-up created: Harden integration smoke truthfulness before
  security/product-honesty slices.
