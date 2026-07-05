# DS-2026-07-05-039 Restore Referenced Photos Only Slice Contract

## Slice

- ID: DS-2026-07-05-039
- Title: Restore only backup photos referenced by validated backup data
- Branch/worktree: `ds-2026-07-05-039-restore-referenced-photos-only` in the main checkout
- Coordinator: current Codex session
- Worker agents, if any: none
- Owned files/modules:
  - `lib/services/backup_service.dart`
  - `test/services/backup_service_photo_restore_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/FINISH_MAP.md`
  - `docs/agent/SLICE_LOG.md`
  - `docs/product/danio-complete-local-current-audit-2026-06-13.md`
  - `docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Files/modules explicitly out of scope: backup import transaction mapping, SharedPreferences restore semantics, UI copy/layout, Android runtime evidence, cloud/account behavior, optional AI, paid/account-backed lanes.

## Product Goal

- User-visible outcome: importing a valid backup restores the photos referenced by the backup data without leaving unrelated archive-only photo files in local app storage.
- Complete-local requirement this advances: restore/data resilience with no false local data side effects.
- Finish Map row(s): Data resilience; Backup and restore.
- Product backlog row(s): CL-P1-009 Backup/data; CL-QA-006 Data resilience.

## Research And Planning

- Fresh session recommended: No; this is the final approved autonomous successor and starts from a clean aligned branch.
- Repo context checked: `AGENTS.md`, `README.md`, `GIT_WORKFLOW.md`, app README, `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`, `QUALITY_LADDER.md`, `TESTING_CHECKLIST.md`, `SLICE_LOG.md`, accelerated epoch plan, product audit/backlog, workflow charter, research protocol, device ownership, live-preview workflow, slice template, `backup_service.dart`, `backup_service_photo_restore_test.dart`, and related import-service tests.
- Current best-practice sources checked: repo source/tests only; the slice uses existing Dart/Flutter and archive patterns already present in the service.
- Tool/plugin/MCP/account-backed lane considered: not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: existing DS-020 coverage skips photo extraction for zero-tank restores, and the screen cleans up newly restored photos when later tank-data import fails. No focused test covers a valid with-tank restore whose ZIP contains unreferenced `photos/` entries, and current `restoreBackup` iterates every archive `photos/` file.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: not applicable; pure service restore behavior.
- Phone expectation: no UI/layout change.
- Tablet expectation: no UI/layout change.
- Accessibility expectation: no UI/accessibility change.
- Visual evidence required: no.

## Tests And Gates

- Focused test(s):
  - RED/GREEN named test in `test/services/backup_service_photo_restore_test.dart`: `restoreBackup ignores archive photos that backup data does not reference`
  - Full touched file: `flutter test test/services/backup_service_photo_restore_test.dart --reporter compact`
- Required local gate: data-safety row of `QUALITY_LADDER.md`, including `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full -RequireCleanWorktree` before behavior commit and again on clean merged `main`.
- Android evidence required: no; service-only local restore behavior, no runtime interaction.
- External review/tool lane: none.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: backup photo files restored under the app documents `photos/` directory.
- Failure states to test: a valid backup with one referenced photo and one unreferenced archive photo restores only the referenced photo and tracks only that file for cleanup.
- Rollback or retry behavior: existing `cleanupLastRestoredPhotos` remains responsible for newly restored referenced files if a later import step fails.
- No-fake-feature/product-honesty check: no new feature claims, no cloud/account/provider behavior, no secret or paid lane.

## Done Criteria

The slice is done only when:

- focused RED/GREEN proof passes;
- the full touched service test file passes;
- targeted analyze passes;
- the required Full gate passes on the branch and clean merged `main`;
- `git diff --check` passes;
- docs are updated with the slice evidence;
- no unrelated dirty files are staged;
- branch is merged to `main`, pushed to `origin/main`, temporary branch is deleted, and `main...origin/main` is `0 0`.

## Result

- Commit: `31738cd7` (`Restore only referenced backup photos`).
- Verification summary: focused RED/GREEN service proof passed, full
  `backup_service_photo_restore_test.dart` passed with 134 tests, targeted
  analyze passed, dirty-branch Full gate passed, branch clean-worktree Full
  gate passed, docs checks passed, and clean-main Full gate passed after merge.
- Evidence path: not applicable.
- Follow-up created: none; autonomous chain budget is exhausted after this
  successor.
