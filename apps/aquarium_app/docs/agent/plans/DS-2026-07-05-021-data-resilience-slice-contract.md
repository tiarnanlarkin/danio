# Danio Slice Contract: DS-2026-07-05-021

## Slice

- ID: `DS-2026-07-05-021`
- Title: Log undo must not recreate orphan journal data
- Branch/worktree: `ds-2026-07-05-021-log-undo-parent-guard`
- Coordinator: current Codex session
- Worker agents, if any: none
- Owned files/modules:
  - `lib/screens/log_detail_screen.dart`
  - `test/widget_tests/log_detail_screen_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/SLICE_LOG.md`
  - `docs/agent/plans/DS-2026-07-05-021-data-resilience-slice-contract.md`
- Files/modules explicitly out of scope: backup import internals, schema
  migration, Android screenshots, broader log editing, task/livestock/equipment
  undo behavior, UI redesign, and optional AI.

## Product Goal

- User-visible outcome: Undoing a deleted log cannot recreate local journal data
  after the parent tank has been deleted.
- Complete-local requirement this advances: local delete/undo flows must not
  create orphan child records or false restored states.
- Finish Map row(s): Data resilience.
- Product backlog row(s): `CL-P1-009`; `CL-QA-006`.

## Research And Planning

- Fresh session recommended: No; startup was rebuilt from repo docs and live
  git state in this session.
- Repo context checked: `AGENTS.md`, root/app README, `GIT_WORKFLOW.md`,
  `WORKFLOW_CHARTER.md`, `RESEARCH_PROTOCOL.md`, `ACTIVE_HANDOFF.md`,
  `FINISH_MAP.md`, `QUALITY_LADDER.md`, `TESTING_CHECKLIST.md`,
  `DEVICE_OWNERSHIP.md`, `LIVE_PREVIEW_WORKFLOW.md`, current product
  audit/backlog, `SLICE_LOG.md`, Log Detail source/tests, storage interface, and
  nearby backup/migration tests.
- Current best-practice sources checked: repo source/tests only; no external
  framework decision needed.
- Tool/plugin/MCP/account-backed lane considered: not needed.
- Tool/plugin/MCP/account-backed lane approved: not needed.
- Decision-changing research notes: `LogDetailScreen` deletes a log, offers a
  snackbar Undo, then calls `storage.saveLog(log)` without checking the durable
  parent tank. Other recent data-resilience slices guard stale child creates
  against missing parent tanks, so Log Detail undo should follow that safety
  boundary.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: existing Log Detail delete
  snackbar flow.
- Phone expectation: no layout change.
- Tablet expectation: no layout change.
- Accessibility expectation: no control or copy semantics change beyond existing
  retry/error feedback.
- Visual evidence required: none; this is a data-safety widget behavior slice.

## Tests And Gates

- Focused test(s):
  - RED/GREEN `flutter test test/widget_tests/log_detail_screen_test.dart --plain-name "undo does not restore a log after its parent tank was deleted" --reporter compact`
  - `flutter test test/widget_tests/log_detail_screen_test.dart --reporter compact`
- Required local gate: `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
- Android evidence required: No. Startup preflight found an offline
  `emulator-5554`, and live-preview `-CheckOnly` reported `danio_api36` was not
  usable. This non-visual data-safety slice can close on local tests/gates.
- External review/tool lane: none.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: Log Detail undo restore path for tank-scoped journal logs.
- Failure states to test: parent tank deleted between log deletion and snackbar
  Undo.
- Rollback or retry behavior: Undo should refuse to restore the log, leave
  storage unchanged, and show normal retry/error feedback.
- No-fake-feature/product-honesty check: no cloud/account/API behavior added.

## Done Criteria

The slice is done only when:

- the focused test fails before production change for the expected orphan-log
  restore;
- the focused test and full Log Detail widget test pass after the fix;
- the Full quality gate passes;
- `git diff --check` passes;
- active handoff and slice log record the result;
- only owned files are staged and committed;
- the branch is merged to `main`, pushed, and cleaned up if all gates pass.

## Result

- Commit: Current commit
- Verification summary:
  - RED: `flutter test test/widget_tests/log_detail_screen_test.dart --plain-name "undo does not restore a log after its parent tank was deleted" --reporter compact` failed before the fix because the deleted log was restored even though its parent tank was missing.
  - GREEN: same focused command passed after Log Detail rechecked `storage.getTank(log.tankId)` before `saveLog`.
  - `flutter test test/widget_tests/log_detail_screen_test.dart --reporter compact`
  - `dart format lib/screens/log_detail_screen.dart test/widget_tests/log_detail_screen_test.dart`
  - `flutter analyze lib/screens/log_detail_screen.dart test/widget_tests/log_detail_screen_test.dart`
  - `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
- Evidence path: not applicable; no screenshots.
- Follow-up created: no successor thread created; continuation mode is
  ask-before-thread-creation.
