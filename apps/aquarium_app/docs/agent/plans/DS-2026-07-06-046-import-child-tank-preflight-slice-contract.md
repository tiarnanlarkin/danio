# DS-2026-07-06-046 Import Child Tank Preflight

## Slice

- ID: DS-2026-07-06-046
- Title: Reject unknown child backup tank IDs before imported tank saves
- Branch/worktree: `ds-2026-07-06-046-import-child-tank-preflight` in the main
  repo worktree
- Coordinator: current Codex session
- Worker agents, if any: none
- Owned files/modules:
  - `lib/services/backup_import_service.dart`
  - `test/services/backup_import_service_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md`
  - `docs/agent/FINISH_MAP.md`
  - `docs/agent/SLICE_LOG.md`
  - `docs/product/danio-complete-local-current-audit-2026-06-13.md`
  - `docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
  - this slice contract
- Files/modules explicitly out of scope:
  - Android runtime/device ownership, UI layout, cloud/account restore, paid
    tools, API keys, providers, premium, store, deploy, optional-AI behavior,
    and unrelated backup/migration findings

## Product Goal

- User-visible outcome: invalid backup child rows that reference a tank absent
  from the backup are rejected before Danio writes any imported tank records,
  avoiding write-then-rollback work during restore/import failure handling.
- Complete-local requirement this advances: restore/import failure behavior has
  tighter pre-save proof as part of data-resilience closure.
- Finish Map row(s): Backup and restore; Data resilience
- Closure ledger ID(s): `DCL-DR-001`; `DCL-DR-004`
- Product backlog row(s): `CL-P1-009`; `CL-QA-006`

## Research And Planning

- Fresh session recommended: No; this successor rebuilt context from repo docs,
  clean git state, current source/tests, and current installed skill
  instructions.
- Repo context checked: `AGENTS.md`, `README.md`, app README, `GIT_WORKFLOW.md`,
  closure ledger, execution contract, forecast, active handoff, finish map,
  quality ladder, testing checklist, slice log, accelerated epoch plan, product
  audit/backlog data-resilience sections, backup restore source, backup import
  source, backup import tests, and device ownership doc.
- Current best-practice sources checked: repo-owned backup/import and
  data-safety patterns only; no external API or platform behavior is involved.
- Tool/plugin/MCP/account-backed lane considered: Not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: the existing
  `rejects child entries with unknown backup tank ids before reporting import
  success` test proves rollback after invalid child tank IDs, but does not prove
  pre-save rejection. Current source builds the tank ID map and saves imported
  tanks before `_mappedTankId` rejects invalid child `tankId` values.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: Not applicable; service and
  failure-boundary slice only.
- Phone expectation: No UI layout changes.
- Tablet expectation: No UI layout changes.
- Accessibility expectation: No UI surface changes.
- Visual evidence required: No.

## Tests And Gates

- Focused proof:
  - RED:
    `flutter test test/services/backup_import_service_test.dart --plain-name "rejects child entries with unknown backup tank ids before reporting import success" --reporter compact`
    should fail after adding `storage.savedTankIds` pre-save assertions because
    current code saves `new-tank` before rejecting the child row.
  - GREEN:
    the same named test should pass after import preflight validates all child
    `tankId` values before the tank save loop.
  - `flutter test test/services/backup_import_service_test.dart --reporter compact`
    must pass.
  - `flutter analyze lib/services/backup_import_service.dart test/services/backup_import_service_test.dart`
    must pass.
- Required local gate:
  - `git diff --check`
  - `flutter test test/copy/current_docs_local_truth_test.dart --reporter compact`
  - `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
  - `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full -RequireCleanWorktree`
- Android evidence required: No; no runtime/device behavior or visual surface
  changed.
- External review/tool lane: None.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: backup import service validation only.
- Failure states to test: imported child collection entries whose `tankId` is
  missing from the imported backup tank map.
- Rollback or retry behavior: invalid child tank references should fail before
  imported tank writes are attempted; existing rollback remains a later safety
  net for storage failures.
- No-fake-feature/product-honesty check: no provider, premium, cloud, AI, or
  fake capability added.

## Done Criteria

The slice is done only when:

- the focused RED/GREEN proof passes;
- the full touched service test file passes;
- targeted analyze passes;
- docs record the `DCL-DR-001` and `DCL-DR-004` import preflight evidence;
- required Full gates pass;
- `git diff --check` passes;
- work is committed, merged to `main`, pushed, and branch cleanup leaves
  `main...origin/main` at `0 0`.

## Result

- Commit: Current commit
- Verification summary:
  - RED named service test failed because the import saved `new-tank` before
    rejecting a child row whose backup `tankId` was absent.
  - GREEN named service test passed after child collection `tankId` values were
    preflighted against backup tank IDs before imported tank saves.
  - Full `backup_import_service_test.dart` passed with 14 tests.
  - Targeted service/test analyze passed.
  - Dirty-branch Full gate passed with 2128 Flutter tests, Flutter analyze, and
    debug APK build.
  - Post-doc `git diff --check`, docs guard, branch clean-worktree Full, and
    clean-main Full gate passed before push.
- Evidence path: this slice contract, `SLICE_LOG.md`, `ACTIVE_HANDOFF.md`,
  `COMPLETE_LOCAL_CLOSURE_LEDGER.md`, and product audit/backlog DS-046 notes.
- Follow-up created: next project-scoped successor should continue ledger-driven
  data-resilience selection with 4 remaining sequential sessions including that
  successor, unless the app reaches the complete-local bar first.
