# DS-2026-07-05-035 Import Relationship Guard Slice Contract

## Slice

- ID: DS-2026-07-05-035
- Title: Guard direct backup import relationship IDs
- Branch/worktree: `ds-2026-07-05-035-import-relationship-guard` in the main repo worktree
- Coordinator: current Codex session
- Worker agents, if any: none
- Owned files/modules:
  - `lib/services/backup_import_service.dart`
  - `lib/services/backup_import_relationships.dart` if helper behavior must change
  - `test/services/backup_import_service_test.dart`
  - closeout docs under `docs/agent/` and product audit/backlog rows only if status evidence changes
- Files/modules explicitly out of scope:
  - UI, live preview control, backup ZIP preview validation, SharedPreferences restore, Android install/tap/screenshot, optional AI, cloud/account flows

## Product Goal

- User-visible outcome: malformed backup imports cannot report success after silently dropping task/log relationship links.
- Complete-local requirement this advances: no false success states or silent relationship loss during local backup/import.
- Finish Map row(s): Data resilience; Backup and restore.
- Product backlog row(s): CL-P1-009; CL-QA-006.

## Research And Planning

- Fresh session recommended: No. This session began from a clean successor checkpoint and is selecting one narrow service slice.
- Repo context checked:
  - `AGENTS.md`
  - `README.md`
  - `GIT_WORKFLOW.md`
  - `apps/aquarium_app/README.md`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/FINISH_MAP.md`
  - `docs/agent/QUALITY_LADDER.md`
  - `docs/agent/TESTING_CHECKLIST.md`
  - `docs/agent/WORKFLOW_CHARTER.md`
  - `docs/agent/RESEARCH_PROTOCOL.md`
  - `docs/agent/DEVICE_OWNERSHIP.md`
  - `docs/agent/LIVE_PREVIEW_WORKFLOW.md`
  - `docs/agent/plans/2026-07-05-accelerated-complete-local-epoch-plan.md`
  - current data-resilience source and nearby tests
- Current best-practice sources checked: repo source/tests only; this is a local service invariant using existing project patterns.
- Tool/plugin/MCP/account-backed lane considered: not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes:
  - `BackupService` preview validation rejects relationship IDs that point at missing backup records.
  - `BackupImportService.importTankScopedData` currently uses `remapBackupRelatedId`, which returns null when the old related ID is absent from the import ID maps.
  - DS-2026-07-05-034 already proved the same direct-import boundary should reject missing child tank IDs and roll back.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: not applicable; service-only data-safety slice.
- Phone expectation: no visual change.
- Tablet expectation: no visual change.
- Accessibility expectation: no visual change.
- Visual evidence required: none.

## Tests And Gates

- Focused test(s):
  - RED/GREEN named service test in `test/services/backup_import_service_test.dart`.
  - Full touched test file after the fix.
- Required local gate:
  - `flutter analyze lib/services/backup_import_service.dart lib/services/backup_import_relationships.dart test/services/backup_import_service_test.dart`
  - `git diff --check`
  - `flutter test test/copy/current_docs_local_truth_test.dart --reporter compact`
  - `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full -RequireCleanWorktree`
- Android evidence required: No. Startup `-CheckOnly` passed, but this service slice does not need device interaction.
- External review/tool lane: none.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: backup import service behavior for tank-scoped local data.
- Failure states to test: related equipment, livestock, and task IDs that reference records absent from the imported backup relationship maps.
- Rollback or retry behavior: import throws `BackupImportException` and rolls back any newly imported tanks/children.
- No-fake-feature/product-honesty check: no feature copy or provider behavior changed.

## Done Criteria

The slice is done only when:

- the focused test fails RED for the missing relationship guard;
- the focused test and full touched file pass GREEN;
- targeted analyze passes;
- Full clean-worktree gate passes before product-code commit;
- docs closeout checks pass;
- docs/logs record the exact verification and next action;
- merged `main` is clean, pushed, aligned with `origin/main`, and the temporary branch is cleaned up.

## Result

- Commit: pending
- Verification summary: pending
- Evidence path: not applicable
- Follow-up created: pending
