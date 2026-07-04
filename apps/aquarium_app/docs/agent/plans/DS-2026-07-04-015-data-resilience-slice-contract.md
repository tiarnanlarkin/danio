# Danio Slice Contract: DS-2026-07-04-015

## Slice

- ID: `DS-2026-07-04-015`
- Title: Species care task creation must not create orphan tasks
- Branch/worktree: `qa/production-tool-audit-2026-05-25` integration checkout
- Coordinator: current Codex coordinator
- Worker agents, if any: none
- Owned files/modules:
  - `lib/screens/species_browser_screen.dart`
  - `test/widget_tests/species_browser_screen_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/FINISH_MAP.md`
  - `docs/agent/SLICE_LOG.md`
  - `docs/agent/plans/DS-2026-07-04-015-data-resilience-slice-contract.md`
  - `docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
  - `docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Files/modules explicitly out of scope: species database content, livestock
  add save behavior, Stocking Calculator, wishlist persistence, backup/restore,
  Android devices, screenshots, and broader migration/app-kill coverage.

## Product Goal

- User-visible outcome: if Species detail has a stale cached tank list after
  the durable tank was deleted, tapping `Create care task` shows retry feedback
  and does not create an orphan local task.
- Complete-local requirement this advances: child task saves must respect
  durable parent tank records before writing local data.
- Finish Map row(s): Data resilience; Backup and restore.
- Product backlog row(s): `CL-P1-009`; `CL-QA-006`.

## Research And Planning

- Fresh session recommended: No; this is a fresh resumed session, the checkout
  is clean and aligned with origin, and the slice is narrow.
- Repo context checked: `AGENTS.md`, `WORKFLOW_CHARTER.md`,
  `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`, `CODEX_SETUP.md`,
  `TESTING_CHECKLIST.md`, `QUALITY_LADDER.md`,
  `AUTONOMOUS_QUALITY_SETUP.md`, `MULTI_AGENT_WORKFLOW.md`, `SLICE_LOG.md`,
  product backlog/current audit, Species Browser source/tests, and recent
  parent-tank guard patterns.
- Current best-practice sources checked: not needed; this is a repo-local
  storage-boundary fix following existing missing-parent checks.
- Tool/plugin/MCP/account-backed lane considered: not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: the existing Species detail care-task test
  exposed a tank through `tanksProvider` without seeding that tank into durable
  storage, and `_createCareTask()` saved directly through `storage.saveTask()`
  without rechecking `storage.getTank(selectedTank.id)`.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: existing Species detail
  care-action sheet and snackbar feedback.
- Phone expectation: no layout change.
- Tablet expectation: no layout change.
- Accessibility expectation: existing snackbar semantics unchanged.
- Visual evidence required: none; non-visual data-safety slice.

## Tests And Gates

- Focused test(s):
  - `flutter test test/widget_tests/species_browser_screen_test.dart --name "stale tank selections do not create orphan species care tasks" --reporter compact`
  - `flutter test test/widget_tests/species_browser_screen_test.dart --reporter compact`
- Required local gate:
  - `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
- Android evidence required: none; no device ownership or visual behavior.
- External review/tool lane: none.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: Species detail weekly care `Task` saves.
- Failure states to test: `tanksProvider` still exposes a stale tank, but
  `storage.getTank(selectedTank.id)` returns `null` before the task save.
- Rollback or retry behavior: no task is saved, the detail sheet remains open,
  and existing retry feedback is shown.
- No-fake-feature/product-honesty check: Species detail cannot report a care
  task as added when no durable parent tank exists.

## Done Criteria

The slice is done only when:

- the focused stale-tank Species care-task test fails before the production
  change;
- the named test and full Species Browser widget test file pass after the
  change;
- targeted analysis passes;
- `Full` local quality gate passes in the integration checkout;
- post-doc `git diff --check` and docs truth test pass;
- docs are updated with the current slice result and next queue;
- no unrelated dirty files are staged.

## Result

- Commit: Current commit after this slice is committed.
- Verification summary: RED named widget test failed because an orphan `Task`
  was saved after the durable tank disappeared; GREEN named and full Species
  Browser widget tests passed; targeted analysis passed; `Full` local quality
  gate passed including full tests, analyzer, and debug APK build; post-doc
  `git diff --check` and current-docs truth test passed.
- Evidence path: test output only; no screenshot evidence required.
- Follow-up created: Continue broader data-resilience create/edit/delete,
  restore, migration, and future debounced-writer app-kill coverage before
  lower-priority polish.
