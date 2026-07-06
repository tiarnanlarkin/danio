# DS-2026-07-06-049 Restore Cleanup Error Preserves Import Failure

## Slice

- ID: DS-2026-07-06-049
- Title: Restore cleanup errors do not mask tank import failures
- Branch/worktree: `ds-2026-07-06-049-restore-cleanup-error-preserves-import-failure` in the main repo worktree
- Coordinator: Codex
- Worker agents, if any: None
- Owned files/modules: `lib/services/backup_import_service.dart`, `test/services/backup_import_service_test.dart`, agent handoff/log/finish docs
- Files/modules explicitly out of scope: Android runtime/device ownership, UI layout, backup ZIP photo extraction internals, schema migrations, optional AI, cloud/account/provider/premium/store/deploy work

## Product Goal

- User-visible outcome: a restore that fails during tank import still reports the import failure even if best-effort restored-photo cleanup also fails.
- Complete-local requirement this advances: restore failure behavior remains honest and diagnosable without false success or masked failure causes.
- Finish Map row(s): Data resilience
- Closure ledger row(s): `DCL-DR-001`
- Product backlog row(s): `CL-P1-009`, `CL-QA-006`

## Research And Planning

- Fresh session recommended: No; this is the first narrow slice in this successor and the branch started clean.
- Repo context checked: `AGENTS.md`, `GIT_WORKFLOW.md`, closure ledger, verified slice contract, forecast, active handoff, finish map, quality ladder, testing checklist, slice log, accelerated epoch plan, product audit/backlog data-resilience entries, and current service/test source.
- Current best-practice sources checked: Repo source/tests only; no new framework/API choice is involved.
- Tool/plugin/MCP/account-backed lane considered: Not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: `BackupRestoreImportFlow.importBackupData` awaits `onImportFailureCleanup` inside the import-failure catch, so a cleanup callback error can replace the original `BackupImportException`.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: Not applicable; pure service failure-boundary slice.
- Phone expectation: No UI change.
- Tablet expectation: No UI change.
- Accessibility expectation: No UI change.
- Visual evidence required: No.

## Tests And Gates

- Focused RED test: `flutter test test/services/backup_import_service_test.dart --plain-name "preserves tank import failure when restored photo cleanup also fails" --reporter compact`
- Focused GREEN/full touched file: same named test, then `flutter test test/services/backup_import_service_test.dart --reporter compact`
- Required local gate: targeted analyze for touched Dart files, `git diff --check`, docs guard after docs update, and `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full` for data safety.
- Android evidence required: No; no emulator, install, tap, screenshot, or logcat action is needed.
- External review/tool lane: None.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: Backup restore/import service flow only.
- Failure states to test: tank import fails, restored-photo cleanup callback also fails.
- Rollback or retry behavior: the existing tank import rollback still runs inside `BackupImportService`; cleanup failure is logged and the original import failure is preserved.
- No-fake-feature/product-honesty check: No cloud/account/provider/premium/AI behavior is added or implied.

## Done Criteria

The slice is done only when:

- the focused RED fails for cleanup masking the original import failure;
- the focused GREEN passes after the smallest service change;
- the full touched service test file passes;
- targeted analyze, `git diff --check`, docs guard, and the Full local gate pass;
- `ACTIVE_HANDOFF.md`, `SLICE_LOG.md`, `FINISH_MAP.md`, and relevant product docs are updated with DS-049 evidence;
- the branch is committed, fast-forward merged to `main`, pushed, cleaned up, and `main...origin/main` is `0 0`.

## Result

- Commit: Current commit
- Verification summary: RED proved cleanup failure masked the original
  `BackupImportException`; GREEN preserved the original tank import failure,
  full `backup_import_service_test.dart` passed with 17 tests, targeted analyze
  passed, and dirty-branch Full gate passed with 2131 Flutter tests plus debug
  APK build.
- Evidence path: `test/services/backup_import_service_test.dart` and local
  quality gate output
- Follow-up created: Continue ledger-driven data-resilience selection with
  remaining chain budget 1.
