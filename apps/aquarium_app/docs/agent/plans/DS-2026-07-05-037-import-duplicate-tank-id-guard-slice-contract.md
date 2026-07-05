# DS-2026-07-05-037 Import Duplicate Tank ID Guard Slice Contract

## Slice

- ID: DS-2026-07-05-037
- Title: Guard direct backup import duplicate tank IDs
- Branch/worktree: `ds-2026-07-05-037-import-duplicate-tank-id-guard`
- Coordinator: Codex
- Worker agents, if any: None
- Owned files/modules:
  - `lib/services/backup_import_service.dart`
  - `test/services/backup_import_service_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/FINISH_MAP.md`
  - `docs/agent/SLICE_LOG.md`
  - product audit/backlog data-resilience notes if status text changes
- Files/modules explicitly out of scope: Backup ZIP preview validation, SharedPreferences restore, UI, Android runtime, cloud/account paths, paid tools, optional AI.

## Product Goal

- User-visible outcome: A malformed backup cannot report successful tank-scoped import while duplicate backup tank IDs collapse relationship mapping.
- Complete-local requirement this advances: Local-first backup/restore data safety and no false success states.
- Finish Map row(s): `Data resilience`, `Backup and restore`
- Product backlog row(s): `CL-P1-009`, `CL-QA-006`

## Research And Planning

- Fresh session recommended: No; this successor starts from clean aligned `main` and is scoped to one service/test family.
- Repo context checked: `AGENTS.md`, `GIT_WORKFLOW.md`, `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`, `QUALITY_LADDER.md`, `TESTING_CHECKLIST.md`, `SLICE_LOG.md`, accelerated epoch plan, product audit/backlog data-resilience notes, current backup import source/tests.
- Current best-practice sources checked: Not needed; this is an existing local service boundary and test-pattern extension.
- Tool/plugin/MCP/account-backed lane considered: None.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: Backup ZIP preview already rejects duplicate tank IDs, but `BackupImportService.importTankScopedData` directly assigns `tankIdMap[oldTankId] = newTankId`; direct callers can save multiple imported tanks while the old ID maps only to the last one.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: Not applicable; pure service/data-safety slice.
- Phone expectation: No UI behavior change.
- Tablet expectation: No UI behavior change.
- Accessibility expectation: No UI behavior change.
- Visual evidence required: No.

## Tests And Gates

- Focused test(s):
  - RED/GREEN: `flutter test test/services/backup_import_service_test.dart --name "rejects duplicate backup tank ids before reporting import success" --reporter compact`
  - Full touched file: `flutter test test/services/backup_import_service_test.dart --reporter compact`
- Required local gate: `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full -RequireCleanWorktree`
- Android evidence required: No; service-only data-safety slice.
- External review/tool lane: None.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: Imported tank and child records through the local storage service.
- Failure states to test: Duplicate backup tank IDs throw before reporting import success and leave no imported tank or child records.
- Rollback or retry behavior: The existing import rollback wrapper must remove any imported tanks if a malformed direct import is detected after any save.
- No-fake-feature/product-honesty check: No visible feature claims, cloud behavior, paid service, or optional-AI path is changed.

## Done Criteria

The slice is done only when:

- the named focused test is observed RED before production code changes;
- the named focused test and full service test file pass after the fix;
- targeted analysis passes for touched Dart files;
- the required Full local quality gate passes on the branch and on merged `main`;
- `git diff --check` passes;
- handoff/log/finish-map docs are updated;
- no unrelated dirty files are staged.

## Result

- Commit: Pending
- Verification summary: Pending
- Evidence path: Not applicable
- Follow-up created: Pending
