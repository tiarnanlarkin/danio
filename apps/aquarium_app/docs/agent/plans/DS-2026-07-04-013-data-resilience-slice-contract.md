# Danio Slice Contract: DS-2026-07-04-013

## Slice

- ID: `DS-2026-07-04-013`
- Title: Bulk livestock add must not create orphan livestock or logs
- Branch/worktree: `qa/production-tool-audit-2026-05-25` integration checkout
- Coordinator: current Codex coordinator
- Worker agents, if any: none
- Owned files/modules:
  - `lib/screens/livestock/livestock_bulk_add_dialog.dart`
  - `test/widget_tests/livestock_screen_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/FINISH_MAP.md`
  - `docs/agent/SLICE_LOG.md`
  - `docs/agent/plans/DS-2026-07-04-013-data-resilience-slice-contract.md`
  - `docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
  - `docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Files/modules explicitly out of scope: single livestock add/edit behavior,
  bulk move/delete behavior, Android devices, screenshots, backup/restore, and
  broader migration/app-kill coverage.

## Product Goal

- User-visible outcome: if the bulk livestock sheet is open for a tank that is
  deleted before the user taps `Add livestock`, Danio shows existing retry
  feedback and does not save orphan local livestock or timeline logs.
- Complete-local requirement this advances: create actions must not report
  success or create child data for missing parent tanks.
- Finish Map row(s): Data resilience; Livestock.
- Product backlog row(s): `CL-QA-006`.

## Research And Planning

- Fresh session recommended: No; the checkout is clean, aligned with origin,
  and this is a narrow continuation of the active data-resilience handoff.
- Repo context checked: `AGENTS.md`, `README.md`, app `README.md`,
  `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`, `CODEX_SETUP.md`,
  `TESTING_CHECKLIST.md`, `QUALITY_LADDER.md`,
  `AUTONOMOUS_QUALITY_SETUP.md`, `MULTI_AGENT_WORKFLOW.md`, `SLICE_LOG.md`,
  product backlog/current audit, Livestock bulk-add source/tests, and recent
  parent-tank guard patterns.
- Current best-practice sources checked: not needed; this is a repo-local
  storage-boundary fix following existing missing-parent checks.
- Tool/plugin/MCP/account-backed lane considered: not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: `LivestockAddDialog` already rejects
  missing parent tanks before writes, but `LivestockBulkAddDialog` writes
  multiple livestock records and acquisition logs directly with only the
  original `tankId`.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: existing bulk livestock
  bottom sheet and retry snackbar path.
- Phone expectation: no layout change.
- Tablet expectation: no layout change.
- Accessibility expectation: existing button/snackbar semantics unchanged.
- Visual evidence required: none; non-visual data-safety slice.

## Tests And Gates

- Focused test(s):
  - `flutter test test/widget_tests/livestock_screen_test.dart --name "bulk add rejects missing parent tanks before saving" --reporter compact`
  - `flutter test test/widget_tests/livestock_screen_test.dart --name "failed bulk-add log save rolls back new livestock" --reporter compact`
  - `flutter test test/widget_tests/livestock_screen_test.dart --reporter compact`
- Required local gate:
  - `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
- Android evidence required: none; no device ownership or visual behavior.
- External review/tool lane: none.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: bulk livestock writes through `storageServiceProvider`,
  plus acquisition `LogEntry` records.
- Failure states to test: the open bulk-add dialog still has a tank id, but
  the storage service no longer has that parent tank when save runs.
- Rollback or retry behavior: no livestock/log records are saved, existing
  retry feedback appears, and relevant livestock/log providers refresh after
  failure.
- No-fake-feature/product-honesty check: the bulk add sheet cannot report
  success when no durable parent tank exists.

## Done Criteria

The slice is done only when:

- the focused stale-parent bulk-add test fails before the production change;
- focused named and full Livestock widget tests pass after the change;
- targeted analysis passes;
- `Full` local quality gate passes in the integration checkout;
- post-doc `git diff --check` and docs truth test pass;
- docs are updated with the current slice result and next queue;
- no unrelated dirty files are staged.

## Result

- Commit: Current commit after this slice is committed.
- Verification summary: RED named widget test failed because orphan livestock
  records were saved after the parent tank was deleted; GREEN named
  stale-parent and existing rollback tests passed; full Livestock widget tests
  passed; targeted analysis passed; `Full` local quality gate passed including
  full tests, analyzer, and debug APK build. Post-doc checks passed after docs
  were updated.
- Evidence path: test output only; no screenshot evidence required.
- Follow-up created: Continue broader data-resilience create/edit/delete,
  restore, migration, and future debounced-writer app-kill coverage before
  lower-priority polish.
