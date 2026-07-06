# DS-2026-07-06-047 Import Missing Relationship Preflight Slice Contract

## Slice

- ID: DS-2026-07-06-047
- Title: Preflight missing direct-import relationship targets
- Branch/worktree: `ds-2026-07-06-047-import-missing-relationship-preflight` in the main repo worktree
- Coordinator: Codex
- Worker agents, if any: none
- Owned files/modules:
  - `apps/aquarium_app/lib/services/backup_import_service.dart`
  - `apps/aquarium_app/test/services/backup_import_service_test.dart`
  - agent handoff/log docs for closeout
- Files/modules explicitly out of scope: UI, Android runtime, optional AI, cloud/account/provider, backup ZIP photo handling, schema migration

## Product Goal

- User-visible outcome: malformed direct backup imports fail before local tank data is written when relationship fields point at missing backup records.
- Complete-local requirement this advances: no false-success or write-then-rollback relationship-mapping gaps in local backup import.
- Finish Map row(s): Data resilience; Backup and restore.
- Closure ledger ID: `DCL-DR-004` with `DCL-DR-001` data-resilience restore/import failure evidence.
- Product backlog row(s): `CL-P1-009`; `CL-QA-006`.

## Research And Planning

- Fresh session recommended: No; this is the first product slice in this fresh successor.
- Repo context checked: `AGENTS.md`, `README.md`, `GIT_WORKFLOW.md`, closure ledger, verified-slice contract, forecast, active handoff, finish map, quality ladder, testing checklist, slice log tail, accelerated epoch plan.
- Current best-practice sources checked: Not needed; this is local service/test behavior using existing repo patterns.
- Tool/plugin/MCP/account-backed lane considered: No.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: Source audit found `_validateSameTankRelationshipTargets` runs before imported tank saves but only checks malformed types and cross-tank references. Missing relationship target IDs are still rejected later by `remapBackupRelatedId`, after imported tank saves begin and rollback is needed.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: Not applicable.
- Phone expectation: No UI change.
- Tablet expectation: No UI change.
- Accessibility expectation: No UI change.
- Visual evidence required: No.

## Tests And Gates

- Focused RED test:
  - `flutter test test/services/backup_import_service_test.dart --plain-name "rejects missing backup relationship ids before imported tank saves" --reporter compact`
  - Expected RED: import throws, but `storage.savedTankIds` contains `new-tank`, proving the missing relationship target is detected after imported tank saves begin.
- GREEN/full focused file:
  - same named test passes
  - `flutter test test/services/backup_import_service_test.dart --reporter compact`
- Required local gate:
  - targeted `flutter analyze`
  - `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
  - post-doc `git diff --check`
  - `flutter test test/copy/current_docs_local_truth_test.dart --reporter compact`
  - branch clean-worktree Full gate and clean-main Full gate before push
- Android evidence required: No; pure service data-safety slice.
- External review/tool lane: No.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: Direct backup import of tanks, livestock, equipment, tasks, and logs.
- Failure states to test: `tasks.relatedEquipmentId`, `logs.relatedEquipmentId`, `logs.relatedLivestockId`, and `logs.relatedTaskId` values referencing missing backup records.
- Rollback or retry behavior: The import must reject these backup files before any imported tank save is attempted, avoiding reliance on rollback for a preflight-detectable relationship error.
- No-fake-feature/product-honesty check: No visible feature, provider, cloud, premium, or AI behavior changed.

## Done Criteria

The slice is done only when:

- focused RED/GREEN proof passes for missing relationship target preflight;
- full `backup_import_service_test.dart` passes;
- required data-safety local gates pass;
- `git diff --check` passes;
- docs are updated with the DS-047 evidence;
- no unrelated dirty files are staged;
- branch is committed, fast-forward merged to `main`, pushed to `origin/main`, and temporary branch cleanup leaves `main...origin/main` at `0 0`.

## Result

- Commit: Current commit
- Verification summary: RED/GREEN named service test, full `backup_import_service_test.dart`, targeted analyze, dirty-branch Full gate, post-doc checks, branch clean-worktree Full gate, and clean-main Full gate.
- Evidence path: this contract, `ACTIVE_HANDOFF.md`, and `SLICE_LOG.md`
- Follow-up created: next project-scoped successor prompt with remaining budget 3 total, including that successor
