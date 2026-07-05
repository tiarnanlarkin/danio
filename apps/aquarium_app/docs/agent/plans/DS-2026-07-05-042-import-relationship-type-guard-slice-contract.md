# DS-2026-07-05-042 Import Relationship Type Guard Slice Contract

## Slice

- ID: DS-2026-07-05-042
- Title: Guard malformed direct import relationship ID types
- Branch/worktree: `ds-2026-07-05-042-import-relationship-type-guard`
- Coordinator: current Codex session
- Worker agents: none
- Owned files/modules:
  - `lib/services/backup_import_relationships.dart`
  - `test/services/backup_import_relationships_test.dart`
  - `test/services/backup_import_service_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/FINISH_MAP.md`
  - `docs/agent/SLICE_LOG.md`
  - `docs/product/danio-complete-local-current-audit-2026-06-13.md`
  - `docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Out of scope: backup photo handling, schema migration, UI layout, Android runtime ownership, optional AI, paid/cloud/account-backed tools, provider keys, release work, and unrelated cleanup.

## Product Goal

- User-visible outcome: direct tank-scoped backup imports cannot report success while malformed non-string relationship IDs are silently cleared.
- Complete-local requirement this advances: local backup/import relationship integrity and no false success states.
- Finish Map rows: `Backup and restore`, `Data resilience`.
- Product backlog rows: `CL-P1-009`, `CL-QA-006`.

## Research And Planning

- Fresh session recommended: No; this is the fresh autonomous successor and startup checks were clean.
- Repo context checked: `AGENTS.md`, `README.md`, `GIT_WORKFLOW.md`, app README, `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`, `QUALITY_LADDER.md`, `TESTING_CHECKLIST.md`, `SLICE_LOG.md`, accelerated epoch plan, device ownership/live preview docs, product audit/backlog relationship sections, current source, and nearby tests.
- Current best-practice sources checked: repo-owned source and tests; no external framework/API change required.
- Tool/plugin/MCP/account-backed lane considered: Not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: `BackupImportService` already rejects missing and cross-tank relationship IDs, but `remapBackupRelatedId` treats non-string non-null IDs as absent. The direct service can therefore preserve an import success path while clearing malformed relationships.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: Not applicable; pure service/data-safety slice.
- Phone expectation: No UI change.
- Tablet expectation: No UI change.
- Accessibility expectation: No UI change.
- Visual evidence required: No.

## Tests And Gates

- Focused RED test:
  - `flutter test test/services/backup_import_relationships_test.dart --plain-name "rejects malformed relationship id types instead of clearing them" --reporter compact`
- Focused GREEN tests:
  - same named test
  - `flutter test test/services/backup_import_relationships_test.dart --reporter compact`
  - `flutter test test/services/backup_import_service_test.dart --reporter compact`
- Required local gate: data-safety row of `QUALITY_LADDER.md`, including Full gate before commit and clean-main Full gate after merge.
- Android evidence required: No; preview preflight only.
- External review/tool lane: None.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: backup-import relationship ID remapping logic only.
- Failure states to test: non-string `relatedEquipmentId`, `relatedLivestockId`, and `relatedTaskId` values in direct import relationship remapping.
- Rollback or retry behavior: invalid backup data throws before imported data is saved; existing `BackupImportService` rollback remains responsible for already-imported tank cleanup.
- No-fake-feature/product-honesty check: no visible product claims, cloud behavior, paid services, provider keys, or fake features changed.

## Done Criteria

The slice is done only when:

- focused RED is observed before production code changes;
- focused tests pass after the fix;
- required Full gates pass on branch and clean `main`;
- `git diff --check` passes;
- repo-owned handoff/log/product docs are updated;
- only DS-042 files are staged;
- `main` is pushed, clean, and aligned with `origin/main`.

## Result

- Commit: `87112c00` (`Guard backup import relationship id types`).
- Verification summary: focused RED/GREEN service tests passed; touched service
  test files passed; targeted analyzer passed; dirty-branch Full gate passed;
  branch clean-worktree Full gate passed; post-doc `git diff --check` and
  current-docs truth test passed; clean-main Full gate passed after merge and
  closeout docs.
- Evidence path: Not applicable.
- Follow-up created: Pending project-scoped successor creation.
