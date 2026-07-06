# DS-2026-07-06-050 Restore Screen Cleanup Best Effort

## Slice

- ID: DS-2026-07-06-050
- Title: Restore screen cleanup errors do not mask import failures
- Branch/worktree: `ds-2026-07-06-050-restore-screen-cleanup-best-effort` in the main repo worktree
- Coordinator: Codex
- Worker agents, if any: None
- Owned files/modules: `lib/screens/backup_restore_screen.dart`, `test/widget_tests/backup_restore_screen_test.dart`, agent handoff/log/finish docs
- Files/modules explicitly out of scope: Android runtime/device ownership, UI layout or visual polish, backup ZIP extraction internals, schema migrations, optional AI, cloud/account/provider/premium/store/deploy work

## Product Goal

- User-visible outcome: a restore that fails during tank import still reaches the normal import-failed error path even if restored-photo cleanup also fails in the screen catch.
- Complete-local requirement this advances: restore failure behavior remains honest and diagnosable without false success or masked failure causes.
- Finish Map row(s): Data resilience
- Closure ledger row(s): `DCL-DR-001`
- Product backlog row(s): `CL-P1-009`, `CL-QA-006`

## Research And Planning

- Fresh session recommended: No; this is one narrow verified slice in the final approved successor budget.
- Repo context checked: `AGENTS.md`, `GIT_WORKFLOW.md`, closure ledger, verified slice contract, forecast, active handoff, finish map, quality ladder, testing checklist, slice log, accelerated epoch plan, app README, and current screen/service/test source.
- Current best-practice sources checked: Repo source/tests only; no new framework/API choice is involved.
- Tool/plugin/MCP/account-backed lane considered: Not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: `BackupRestoreImportFlow` now treats cleanup failures as best effort, but `BackupRestoreScreen._importData` still has an outer catch that awaits `cleanupLastRestoredPhotos()` before logging/showing import failure. A cleanup exception there can still mask the original restore/import failure.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: Not applicable; this is a screen failure-boundary code path with no intended layout or visual copy change.
- Phone expectation: No UI layout change.
- Tablet expectation: No UI layout change.
- Accessibility expectation: No UI change.
- Visual evidence required: No.

## Tests And Gates

- Focused RED test: `flutter test test/widget_tests/backup_restore_screen_test.dart --plain-name "restore screen cleanup helper keeps cleanup failures best effort" --reporter compact`
- Focused GREEN/full touched file: same named test, then `flutter test test/widget_tests/backup_restore_screen_test.dart --reporter compact`
- Required local gate: targeted analyze for touched Dart files, `git diff --check`, docs guard after docs update, and `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full` for data safety.
- Android evidence required: No; no emulator, install, tap, screenshot, or logcat action is needed for this non-visual failure-boundary slice.
- External review/tool lane: None.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: Backup restore screen error handling only.
- Failure states to test: restored-photo cleanup callback throws while the screen is already handling a failed restore/import path.
- Rollback or retry behavior: tank import rollback remains owned by `BackupImportService`; screen cleanup is best-effort and logged without replacing the original user-visible import failure path.
- No-fake-feature/product-honesty check: No cloud/account/provider/premium/AI behavior is added or implied.

## Done Criteria

The slice is done only when:

- the focused RED proves the screen cleanup guard is missing;
- the focused GREEN passes after the smallest screen error-handling change;
- the full touched widget test file passes;
- targeted analyze, `git diff --check`, docs guard, and the Full local gate pass;
- `ACTIVE_HANDOFF.md`, `SLICE_LOG.md`, `FINISH_MAP.md`, and relevant product docs are updated with DS-050 evidence;
- the branch is committed, fast-forward merged to `main`, pushed, cleaned up, and `main...origin/main` is `0 0`;
- the remaining autonomous chain budget is decremented to 0 and no successor is created.

## Result

- Commit: Current commit
- Verification summary: RED proved the screen cleanup helper/wiring was
  missing; GREEN made restored-photo cleanup best-effort in the Backup &
  Restore screen catch, the full touched widget test file passed with 13 tests,
  targeted analyze passed, and dirty-branch Full gate passed with 2132 Flutter
  tests plus debug APK build.
- Evidence path: `test/widget_tests/backup_restore_screen_test.dart` and local
  quality gate output
- Follow-up created: Autonomous chain budget is 0 after this slice; do not
  create another successor without fresh user approval.
