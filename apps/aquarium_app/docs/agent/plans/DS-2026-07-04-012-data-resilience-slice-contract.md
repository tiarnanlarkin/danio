# Danio Slice Contract: DS-2026-07-04-012

## Slice

- ID: `DS-2026-07-04-012`
- Title: Cycling Assistant reminders must not create orphan tasks
- Branch/worktree: `qa/production-tool-audit-2026-05-25` integration checkout
- Coordinator: current Codex coordinator
- Worker agents, if any: none
- Owned files/modules:
  - `lib/screens/cycling_assistant_screen.dart`
  - `test/widget_tests/cycling_assistant_screen_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/FINISH_MAP.md`
  - `docs/agent/SLICE_LOG.md`
  - `docs/agent/plans/DS-2026-07-04-012-data-resilience-slice-contract.md`
  - `docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
  - `docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Files/modules explicitly out of scope: task form behavior, Android devices,
  screenshots, AI-generated reminder flows, and broader restore/migration QA.

## Product Goal

- User-visible outcome: if Cycling Assistant is open for a tank that is deleted
  before the user taps `Create cycling reminder`, Danio shows retry feedback and
  does not save an orphan local reminder task.
- Complete-local requirement this advances: guided-tool create actions must not
  report success or create child data for missing parent tanks.
- Finish Map row(s): Data resilience; Guided tools.
- Product backlog row(s): `CL-P1-009`, `CL-QA-006`.

## Research And Planning

- Fresh session recommended: No; the checkout was clean, aligned with origin,
  and the slice is narrow.
- Repo context checked: `AGENTS.md`, `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`,
  `CODEX_SETUP.md`, `TESTING_CHECKLIST.md`, `QUALITY_LADDER.md`,
  `AUTONOMOUS_QUALITY_SETUP.md`, `SLICE_LOG.md`, product backlog/current audit,
  Cycling Assistant source/tests, and the existing Tasks parent-tank guard.
- Current best-practice sources checked: not needed; this is a repo-local
  storage-boundary fix following the existing task form pattern.
- Tool/plugin/MCP/account-backed lane considered: not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: `TasksScreen` already checks
  `storage.getTank(...)` before task form saves, but Cycling Assistant's guided
  reminder action saved directly through `storage.saveTask(...)`.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: existing Cycling Assistant
  guided action card and snackbar feedback path.
- Phone expectation: no layout change.
- Tablet expectation: no layout change.
- Accessibility expectation: existing button/snackbar semantics unchanged.
- Visual evidence required: none; non-visual data-safety slice.

## Tests And Gates

- Focused test(s):
  - `flutter test test/widget_tests/cycling_assistant_screen_test.dart --name "missing tank ids do not create orphan cycling reminders" --reporter compact`
  - `flutter test test/widget_tests/cycling_assistant_screen_test.dart --name "guided action creates a phase-aware cycling reminder" --reporter compact`
  - `flutter test test/widget_tests/cycling_assistant_screen_test.dart --reporter compact`
- Required local gate:
  - `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
- Android evidence required: none; no device ownership or visual behavior.
- External review/tool lane: none.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: Cycling Assistant creates local `Task` records through
  `storageServiceProvider`.
- Failure states to test: the open assistant still has a tank snapshot, but the
  storage service no longer has that parent tank when the create-reminder action
  runs.
- Rollback or retry behavior: no task is saved, `tasksProvider` is not
  invalidated as a success path, and the existing retry snackbar appears.
- No-fake-feature/product-honesty check: the guided tool cannot report reminder
  creation when no durable parent tank exists.

## Done Criteria

The slice is done only when:

- the focused stale-parent test fails before the production change;
- focused named and full Cycling Assistant widget tests pass after the change;
- targeted analysis passes;
- `Full` local quality gate passes in the integration checkout;
- post-doc `git diff --check` and docs truth test pass;
- docs are updated with the current slice result and next queue;
- no unrelated dirty files are staged.

## Result

- Commit: Current commit after this slice is committed.
- Verification summary: RED named widget test failed because an orphan task was
  saved; GREEN named stale-parent and happy-path tests passed; full Cycling
  Assistant widget tests passed; targeted analysis passed; `Full` local quality
  gate passed including full tests, analyzer, and debug APK build. Post-doc
  checks passed after docs were updated.
- Evidence path: test output only; no screenshot evidence required.
- Follow-up created: Continue broader data-resilience create/edit/delete,
  restore, migration, and future debounced-writer app-kill coverage before
  lower-priority polish.
