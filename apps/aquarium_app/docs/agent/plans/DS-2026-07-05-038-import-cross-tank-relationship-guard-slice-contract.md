# DS-2026-07-05-038 Cross-Tank Import Relationship Guard

## Slice

- ID: DS-2026-07-05-038
- Title: Guard direct backup import cross-tank relationship IDs
- Branch/worktree: `ds-2026-07-05-038-import-cross-tank-relationship-guard`
- Coordinator: current Codex session
- Worker agents: none
- Owned files/modules: `BackupImportService`, backup import relationship tests, agent handoff/log docs
- Out of scope: ZIP preview validation, UI restore walkthroughs, Android screenshots, cloud/account backup behavior, optional AI, unrelated create/delete surfaces

## Product Goal

- User-visible outcome: malformed direct backup imports cannot create local logs or tasks whose relationship IDs point to records imported under another tank.
- Complete-local requirement: local backup/restore relationship integrity and no false success states.
- Finish Map rows: `Backup and restore`; `Data resilience`
- Backlog rows: `CL-P1-009`; `CL-QA-006`

## Research And Planning

- Fresh session recommended: No; this successor started from clean aligned `main` and is scoped to one service/test family.
- Repo context checked: `AGENTS.md`, `README.md`, `GIT_WORKFLOW.md`, `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`, `QUALITY_LADDER.md`, `TESTING_CHECKLIST.md`, `SLICE_LOG.md`, accelerated epoch plan, current audit/backlog, backup import source/tests, and relationship helper source/tests.
- Current best-practice sources checked: repo source/tests; no external API or framework decision needed.
- Tool/plugin/MCP/account-backed lane considered: Not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: ZIP preview validation already rejects cross-tank relationship targets, but `BackupImportService.importTankScopedData` only checks that relationship targets were imported. The lower direct service boundary can still remap a task/log relationship to a different imported tank.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: Not applicable; pure service data-safety slice.
- Phone expectation: No UI change.
- Tablet expectation: No UI change.
- Accessibility expectation: No UI change.
- Visual evidence required: No.

## Tests And Gates

- Focused test: `flutter test test/services/backup_import_service_test.dart --name "rejects cross-tank backup relationship ids before reporting import success" --reporter compact`
- Required local gate: `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full -RequireCleanWorktree`
- Android evidence required: No; service-only data-safety change.
- External review/tool lane: None.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: tank-scoped backup import transaction only.
- Failure states to test: backup task/log relationships that reference equipment, livestock, or tasks from another backup tank.
- Rollback or retry behavior: direct import throws `BackupImportException` and rolls back imported tanks/children instead of returning success.
- No-fake-feature/product-honesty check: No product copy or feature availability changed.

## Done Criteria

The slice is done only when:

- focused RED failure is observed for the missing direct import guard;
- focused GREEN and full touched service test pass;
- targeted analyze passes for touched Dart files;
- the Full gate passes with a clean worktree before merge;
- `git diff --check` passes;
- handoff/log docs record the result and remaining chain state;
- the branch is merged to `main`, clean-main Full gate passes, `origin/main` is pushed, and the temporary branch is deleted.

## Result

- Commit: Pending.
- Verification summary: Pending.
- Evidence path: Not applicable.
- Follow-up created: Pending closeout.
