# DS-2026-07-06-048 Import Required ID Trim Preflight

## Slice

- ID: DS-2026-07-06-048
- Title: Reject trim-empty required backup IDs before direct import saves
- Branch/worktree: `ds-2026-07-06-048-import-required-id-trim-preflight`
- Coordinator: Codex
- Worker agents, if any: None
- Owned files/modules:
  - `lib/services/backup_import_service.dart`
  - `test/services/backup_import_service_test.dart`
  - agent handoff/log docs at closeout
- Files/modules explicitly out of scope:
  - Android runtime, UI, backup ZIP photo extraction, schema migrations, optional AI, cloud/account/provider paths

## Product Goal

- User-visible outcome: malformed local backup data with blank-looking required IDs fails safely before any local tank import save is attempted.
- Complete-local requirement this advances: backup/import false-success and relationship-mapping closure evidence.
- Finish Map row(s): Backup and restore; Data resilience.
- Ledger ID(s): `DCL-DR-001`, `DCL-DR-004`.

## Research And Planning

- Fresh session recommended: No; this is the first slice in a fresh successor.
- Repo context checked: startup docs, closure ledger, active handoff, Finish Map, quality ladder, test checklist, accelerated plan, slice log, product audit/backlog data-resilience sections, current source/tests.
- Current best-practice sources checked: Not needed; this is a local service validation alignment with existing repo patterns.
- Tool/plugin/MCP/account-backed lane considered: None.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: `BackupService` preview validation rejects trim-empty required tank/child IDs, while `BackupImportService._requiredString` currently accepts whitespace-only strings. Direct import can therefore treat blank-looking backup IDs as valid and save regenerated local records.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: Not applicable; pure service/data-safety slice.
- Phone expectation: No UI change.
- Tablet expectation: No UI change.
- Accessibility expectation: No UI change.
- Visual evidence required: No.

## Tests And Gates

- Focused test(s):
  - RED/GREEN: `flutter test test/services/backup_import_service_test.dart --plain-name "rejects trim-empty required backup ids before imported tank saves" --reporter compact`
  - Full touched file: `flutter test test/services/backup_import_service_test.dart --reporter compact`
- Required local gate: Data safety row, `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`.
- Android evidence required: No; no runtime/UI behavior changed.
- External review/tool lane: None.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: backup import validation only; no local storage schema change.
- Failure states to test: whitespace-only backup tank IDs and child record IDs fail before `saveTank`.
- Rollback or retry behavior: no imported tanks should be saved, so rollback should not need to delete a newly imported tank.
- No-fake-feature/product-honesty check: no new visible feature/copy or provider behavior.

## Done Criteria

The slice is done only when:

- the focused test fails before production changes for the expected saved-tank false-success boundary;
- the focused test and full service test file pass after the fix;
- targeted analyze and Full gate pass;
- `git diff --check` and docs guard pass after doc updates;
- docs record the slice and no unrelated files are staged;
- branch is fast-forward merged to `main`, pushed, clean, and aligned.

## Result

- Commit: Pending.
- Verification summary: RED confirmed the direct import service returned
  `BackupImportResult` for a whitespace-only tank ID; GREEN passed after
  required strings became trim-nonempty. Full service test file, targeted
  analyze, and dirty-branch Full gate passed.
- Evidence path: Not applicable.
- Follow-up created: Pending next successor prompt.
