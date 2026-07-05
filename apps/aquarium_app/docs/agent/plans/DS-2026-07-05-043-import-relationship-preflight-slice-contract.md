# DS-2026-07-05-043 Import Relationship Type Preflight

## Slice

- ID: DS-2026-07-05-043
- Title: Preflight Malformed Direct Import Relationship ID Types
- Branch/worktree: `ds-2026-07-05-043-import-relationship-preflight` in the main repo worktree
- Coordinator: current Codex session
- Worker agents, if any: none
- Owned files/modules:
  - `lib/services/backup_import_service.dart`
  - `test/services/backup_import_service_test.dart`
  - this slice contract
  - closeout updates to `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`, `SLICE_LOG.md`, and product audit/backlog notes if behavior changes
- Files/modules explicitly out of scope: UI, Android runtime control, backup photo handling, schema migration, cloud/account behavior, paid services, API keys, optional AI behavior

## Product Goal

- User-visible outcome: malformed direct backup relationship ID types are rejected before any imported tank data is written locally.
- Complete-local requirement this advances: no false or partial local backup/import success states.
- Finish Map row(s): Data resilience; Backup and restore.
- Product backlog row(s): `CL-P1-009`; `CL-QA-006`.

## Research And Planning

- Fresh session recommended: no; this is already a fresh successor with clean startup evidence.
- Repo context checked: `AGENTS.md`, `README.md`, `GIT_WORKFLOW.md`, app README, `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`, `QUALITY_LADDER.md`, `TESTING_CHECKLIST.md`, `SLICE_LOG.md`, accelerated epoch plan, product audit/backlog, and current backup import source/tests.
- Current best-practice sources checked: repo-owned tests and service contracts only; no external API or framework decision is needed.
- Tool/plugin/MCP/account-backed lane considered: not needed.
- Tool/plugin/MCP/account-backed lane approved: not needed.
- Decision-changing research notes: DS-042 rejects malformed direct relationship ID types, but current direct import service reaches that guard after saving imported tank rows and relies on rollback. The malformed value is knowable from backup data before local writes.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: not applicable; service data-safety slice.
- Phone expectation: unchanged.
- Tablet expectation: unchanged.
- Accessibility expectation: unchanged.
- Visual evidence required: no.

## Tests And Gates

- Focused test(s):
  - RED/GREEN named test in `test/services/backup_import_service_test.dart` proving malformed relationship ID types do not attempt any tank save before failing.
  - Full touched file after GREEN.
- Required local gate: `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`.
- Android evidence required: no; read-only `run_danio_live_preview.ps1 -CheckOnly` startup preflight was sufficient.
- External review/tool lane: none.
- Paid-tool ledger entry required: no.

## Data And Safety

- Local data touched: direct backup import transaction path.
- Failure states to test: malformed non-string `relatedEquipmentId`, `relatedLivestockId`, and `relatedTaskId` values in direct tank-scoped backup import.
- Rollback or retry behavior: malformed relationship IDs must fail before `saveTank` is called, so rollback is not needed for this known-invalid backup shape.
- No-fake-feature/product-honesty check: no visible feature or optional service behavior is added.

## Done Criteria

The slice is done only when:

- focused RED is observed for the expected missing preflight behavior;
- focused GREEN passes;
- full touched test file passes;
- targeted analyze passes;
- required Full gate passes before commit;
- `git diff --check` passes;
- closeout docs/logs are updated;
- branch is committed, merged to clean `main`, Full gate passes on clean `main`, pushed to `origin/main`, and the temporary branch is deleted.

## Result

- Commit: `8a290ef6`
- Verification summary: RED proved malformed relationship types attempted
  `saveTank` before rejection; GREEN rejects the malformed values in
  relationship preflight before any imported tank save. Full touched service
  test, targeted analyze, dirty-branch Full gate, and branch clean-worktree
  Full gate passed.
- Evidence path: none
- Follow-up created: after DS-043 reaches clean pushed `main`, implement the
  user-requested anti-circling workflow docs before creating a successor thread.
