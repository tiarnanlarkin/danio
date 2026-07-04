# Danio Slice Contract: DS-2026-07-04-017

## Slice

- ID: `DS-2026-07-04-017`
- Title: Tank Detail quick feeding must not create orphan logs
- Branch/worktree: `qa/production-tool-audit-2026-05-25` integration checkout
- Coordinator: current Codex coordinator
- Worker agents, if any: none
- Owned files/modules:
  - `lib/screens/tank_detail/tank_detail_screen.dart`
  - `test/widget_tests/tank_detail_screen_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/FINISH_MAP.md`
  - `docs/agent/SLICE_LOG.md`
  - `docs/agent/plans/DS-2026-07-04-017-data-resilience-slice-contract.md`
  - `docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
  - `docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Files/modules explicitly out of scope: Add Log, Journal, Today Board, Home
  feed actions, backup/restore, Android devices, screenshots, and broader
  migration/app-kill coverage.

## Product Goal

- User-visible outcome: if Tank Detail remains open after its durable parent
  tank was deleted, tapping quick feeding shows existing retry feedback and does
  not create an orphan local feeding log.
- Complete-local requirement this advances: tank-scoped quick-write actions
  must respect durable parent tank records before writing local data.
- Finish Map row(s): Data resilience; Timeline and journal.
- Product backlog row(s): `CL-P1-009`; `CL-QA-006`.

## Research And Planning

- Fresh session recommended: No; this is a narrow continuation after a fresh
  handoff and a clean, origin-aligned checkout.
- Repo context checked: `AGENTS.md`, `WORKFLOW_CHARTER.md`,
  `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`, `CODEX_SETUP.md`,
  `TESTING_CHECKLIST.md`, `QUALITY_LADDER.md`,
  `AUTONOMOUS_QUALITY_SETUP.md`, `MULTI_AGENT_WORKFLOW.md`, `SLICE_LOG.md`,
  product backlog/current audit, Tank Detail source/tests, and recent
  parent-tank guard patterns.
- Current best-practice sources checked: not needed; this is a repo-local
  storage-boundary fix following existing missing-parent checks.
- Tool/plugin/MCP/account-backed lane considered: not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: `TankDetailScreen._quickLogFeeding()`
  created a feeding `LogEntry` and called `storage.saveLog()` directly.
  Existing coverage only simulated thrown save failures, so a stale mounted
  Tank Detail route could create a feeding log after `storage.getTank(tankId)`
  returned `null`.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: existing Tank Detail quick
  actions menu and snackbar feedback.
- Phone expectation: no layout change.
- Tablet expectation: no layout change.
- Accessibility expectation: existing snackbar retry feedback remains the
  announced failure path.
- Visual evidence required: none; non-visual data-safety slice.

## Tests And Gates

- Focused test(s):
  - `flutter test test/widget_tests/tank_detail_screen_test.dart --name "missing tank ids do not create orphan quick feeding logs" --reporter compact`
  - `flutter test test/widget_tests/tank_detail_screen_test.dart --reporter compact`
- Required local gate:
  - `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
- Android evidence required: none; no device ownership or visual behavior.
- External review/tool lane: none.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: Tank Detail quick-feeding `LogEntry` saves.
- Failure states to test: Tank Detail remains mounted with a stale `tankId`,
  but `storage.getTank(tankId)` returns `null` before the feeding log save.
- Rollback or retry behavior: no log is saved, no feeding pulse or success
  feedback is emitted, and the existing retry feedback is shown.
- No-fake-feature/product-honesty check: quick feeding cannot report a saved
  feeding event when no durable parent tank exists.

## Done Criteria

The slice is done only when:

- the focused stale-parent Tank Detail quick-feeding test fails before the
  production change;
- the named test and full Tank Detail widget test file pass after the change;
- targeted analysis passes;
- `Full` local quality gate passes in the integration checkout;
- post-doc `git diff --check` and docs truth test pass;
- docs are updated with the current slice result and next queue;
- no unrelated dirty files are staged.

## Result

- Commit: Current commit after this slice is committed.
- Verification summary: RED named widget test failed because an orphan
  `LogEntry` was saved after the durable tank disappeared; GREEN named and full
  Tank Detail widget tests passed; targeted analysis passed; `Full` local
  quality gate passed including full tests, analyzer, and debug APK build;
  post-doc `git diff --check` and current-docs truth test passed.
- Evidence path: test output only; no screenshot evidence required.
- Follow-up created: Continue broader data-resilience create/edit/delete,
  restore, migration, and future debounced-writer app-kill coverage before
  lower-priority polish.
