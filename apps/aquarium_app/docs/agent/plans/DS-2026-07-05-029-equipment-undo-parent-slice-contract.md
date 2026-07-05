# DS-2026-07-05-029 Equipment Undo Parent Guard

## Slice

- ID: DS-2026-07-05-029
- Title: Prevent Equipment undo from restoring orphan records after parent tank deletion
- Branch/worktree: `ds-2026-07-05-029-equipment-undo-parent` in the main repo checkout
- Coordinator: current Codex session
- Worker agents, if any: none
- Owned files/modules: `lib/screens/equipment_screen.dart`, `test/widget_tests/equipment_screen_test.dart`, `docs/agent/ACTIVE_HANDOFF.md`, `docs/agent/SLICE_LOG.md`, product data-resilience docs if status wording changes
- Files/modules explicitly out of scope: live preview install/reload, visual redesign, optional AI, cloud/account tooling, release/store work

## Product Goal

- User-visible outcome: undoing an equipment deletion cannot recreate equipment or an auto maintenance task after the parent tank has been deleted.
- Complete-local requirement this advances: local data safety and no orphan local records.
- Finish Map row(s): Data resilience
- Product backlog row(s): CL-P1-009 Backup/data

## Research And Planning

- Fresh session recommended: No; this is the final approved chain session and a narrow continuation slice.
- Repo context checked: `AGENTS.md`, root/app README, `GIT_WORKFLOW.md`, `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`, `QUALITY_LADDER.md`, `TESTING_CHECKLIST.md`, `SLICE_LOG.md`, device/live-preview docs, workflow/research docs, and CL-P1-009 product docs.
- Current best-practice sources checked: repo source/tests are sufficient; no framework API change is needed.
- Tool/plugin/MCP/account-backed lane considered: none.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: recent DS-021 and DS-027 fixed the same parent-tank undo invariant for logs and tasks; equipment undo still saves the captured equipment/task directly.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: existing Equipment screen behavior and snackbars.
- Phone expectation: no visual layout change.
- Tablet expectation: no visual layout change.
- Accessibility expectation: no control changes.
- Visual evidence required: No; data-safety widget test coverage is the proof.

## Tests And Gates

- Focused test(s): `flutter test test/widget_tests/equipment_screen_test.dart --plain-name "undo does not restore equipment after its parent tank was deleted" --reporter compact`
- Required local gate: `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full -RequireCleanWorktree`
- Android evidence required: No; CheckOnly runtime preflight was sufficient and this slice does not install/reload/capture.
- External review/tool lane: none.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: tank-scoped equipment and auto maintenance task records.
- Failure states to test: parent tank deleted after equipment deletion but before snackbar Undo.
- Rollback or retry behavior: Undo rejects the restore, leaves equipment/tasks deleted, invalidates providers, and shows retry/error feedback.
- No-fake-feature/product-honesty check: no visible product claims added.

## Done Criteria

The slice is done only when:

- the focused test fails before the production fix for the expected orphan-restore reason;
- the focused test and full equipment widget test file pass after the fix;
- targeted analyze passes for touched Dart files;
- the required Full quality gate passes with `-RequireCleanWorktree`;
- `git diff --check` and docs truth checks pass after doc updates;
- docs/logs record the completed slice and next handoff;
- the branch is committed, merged to `main`, pushed, aligned, and cleaned up.

## Result

- Commit: Current commit after closeout.
- Verification summary: RED named equipment undo test failed because orphan
  equipment was restored; GREEN named test passed after the parent-tank guard;
  full equipment widget test file passed; targeted analyzer passed; Full local
  quality gate passed before commit; post-doc `git diff --check` and docs
  truth tests passed.
- Evidence path: none
- Follow-up created: stop autonomous chain mode after this final approved
  successor; continue broader data-resilience work only in a future manual
  session.
