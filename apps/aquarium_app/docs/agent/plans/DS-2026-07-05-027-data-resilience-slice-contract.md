# DS-2026-07-05-027 Data Resilience Slice Contract

## Slice

- ID: DS-2026-07-05-027
- Title: Prevent Task undo from restoring orphan tasks after parent tank deletion
- Branch/worktree: `ds-2026-07-05-027-task-undo-parent-check` in the main repo checkout
- Coordinator: current Codex session
- Worker agents, if any: none
- Owned files/modules:
  - `lib/screens/tasks_screen.dart`
  - `test/widget_tests/tasks_screen_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/SLICE_LOG.md`
  - this slice contract
- Files/modules explicitly out of scope:
  - Backup & Restore UI redesign
  - Android screenshot capture
  - Optional AI, cloud/account, release, and store scope

## Product Goal

- User-visible outcome: deleting a task and tapping Undo after the parent tank has disappeared must not recreate orphan local task data.
- Complete-local requirement this advances: local data safety and no false success states for delete/undo paths.
- Finish Map row(s): Data resilience
- Product backlog row(s): CL-P1-009 and CL-QA-006

## Research And Planning

- Fresh session recommended: No; this successor session starts clean and is scoped to one narrow slice.
- Repo context checked: `AGENTS.md`, root and app README, `GIT_WORKFLOW.md`, `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`, `QUALITY_LADDER.md`, `TESTING_CHECKLIST.md`, `WORKFLOW_CHARTER.md`, `RESEARCH_PROTOCOL.md`, current audit/backlog data-resilience rows, `SLICE_LOG.md`, device ownership/live-preview docs, and current git/runtime state.
- Current best-practice sources checked: Repo source/tests only; this is an existing local Flutter widget pattern and does not need external API research.
- Tool/plugin/MCP/account-backed lane considered: Not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: `LogDetailScreen` already rechecks the parent tank before undo-restore; `TasksScreen` currently restores the saved task directly.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: Existing Tasks screen delete snackbar flow.
- Phone expectation: No visual layout change.
- Tablet expectation: No visual layout change.
- Accessibility expectation: Existing snackbar action semantics unchanged.
- Visual evidence required: No; this is a service-backed widget data-safety path with no layout change.

## Tests And Gates

- Focused test(s): Add a failing `tasks_screen_test.dart` widget test for task delete Undo after parent tank deletion.
- Required local gate: `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`.
- Android evidence required: No; live-preview CheckOnly is enough for startup ownership awareness and this slice changes data-safety behavior covered by widget tests.
- External review/tool lane: None.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: Local task rows and parent tank existence checks through `StorageService`.
- Failure states to test: The parent tank is deleted after task deletion but before Undo.
- Rollback or retry behavior: Undo should leave the task deleted and surface existing restore-failure feedback.
- No-fake-feature/product-honesty check: No visible product claims changed.

## Done Criteria

The slice is done only when:

- the focused test fails for the expected orphan-restore behavior before the fix;
- the focused test passes after the fix;
- the full `tasks_screen_test.dart` file passes;
- targeted analyze passes;
- the Full local quality gate passes;
- `git diff --check` passes;
- repo-owned handoff/log docs are updated;
- the branch is committed, fast-forwarded into `main`, pushed, cleaned up, and `main...origin/main` is `0 0`.

## Result

- Commit: Current commit after closeout
- Verification summary: focused RED failed because the orphan task was restored; focused GREEN passed after `TasksScreen` rechecked the durable parent tank; full `tasks_screen_test.dart`, targeted analyze, and the branch Full quality gate passed.
- Evidence path: not applicable
- Follow-up created: queued next font-stabilization candidate in the handoff; successor creation is handled after clean closeout if no stop condition is hit.
