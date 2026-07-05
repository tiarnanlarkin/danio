# DS-2026-07-05-033 Livestock Removal Log Parent Guard

## Slice

- ID: DS-2026-07-05-033
- Title: Prevent livestock removal expiry logs after parent tank deletion
- Branch/worktree: `ds-2026-07-05-033-livestock-removal-log-parent`
- Coordinator: current Codex session
- Worker agents: none
- Owned files/modules:
  - `lib/screens/livestock/livestock_screen.dart`
  - `test/widget_tests/livestock_screen_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/FINISH_MAP.md`
  - `docs/agent/SLICE_LOG.md`
  - `docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
  - `docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Out of scope:
  - Backup import validation and schema migration code
  - Android install, tap, screenshot, or live-preview refresh
  - Product copy or visual changes
  - Paid, cloud, account-backed, provider-key, or release work

## Product Goal

- User-visible outcome: a stale Livestock route cannot create a new local
  timeline log after its parent tank has already been deleted.
- Complete-local requirement: close one CL-P1-009 / CL-QA-006 relationship
  integrity gap in create/edit/delete data resilience.
- Finish Map rows: Data resilience; Backup and restore remains unchanged.
- Product backlog rows: CL-P1-009 and CL-QA-006.

## Read-Only Selection Audit

- Startup state was clean `main` aligned with `origin/main` (`main...origin/main`
  was `0 0`) before the slice branch.
- Current handoff and Finish Map rank data resilience first and name restore,
  migration, create/edit/delete, relationship mapping, and future debounced
  writers as the remaining lane.
- Backup import, backup restore, preference restore, schema-stamp failure,
  tank/child ID collision, missing parent save, and Equipment/Task/Log undo
  parent-guard candidates already have focused source/test coverage.
- Fresh source review found `_saveLivestockRemovalLog` writes
  `LogType.livestockRemoved` after the undo window without checking
  `storage.getTank(widget.tankId)`.
- Existing Livestock tests cover successful expired removal logs and failed
  permanent livestock deletes, but not parent tank deletion during the livestock
  undo window.

## Tests And Gates

- RED test:
  `flutter test test/widget_tests/livestock_screen_test.dart --plain-name "expired livestock removal does not log after parent tank deletion" --reporter compact`
- GREEN proof: same named test, then full `test/widget_tests/livestock_screen_test.dart`.
- Targeted analyze:
  `flutter analyze lib/screens/livestock/livestock_screen.dart test/widget_tests/livestock_screen_test.dart`
- Required local gate: `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full -RequireCleanWorktree`
- Docs checks after doc updates:
  - `git diff --check`
  - `flutter test test/copy/current_docs_local_truth_test.dart --reporter compact`
- Android evidence required: no; pure data-safety widget/service behavior with
  read-only live-preview `-CheckOnly` already passed at startup.
- External review/tool lane: none.
- Paid-tool ledger entry required: no.

## Data And Safety

- Local data touched: livestock removal timeline logs only.
- Failure state to test: parent tank is deleted while a livestock delete is
  waiting for undo expiry.
- Expected behavior: the livestock deletion may settle, but no orphan
  `livestockRemoved` log is saved for the missing tank.
- Rollback/retry behavior: no destructive cleanup; the change only skips a
  secondary timeline-log side effect when its parent tank is absent.
- Risk tier: 2, data safety / relationship integrity.

## Done Criteria

The slice is done only when the RED/GREEN focused proof passes, the full
touched test file passes, targeted analyze passes, the required Full gate
passes on a clean worktree, docs/logs are updated, the branch is merged to
`main`, `origin/main` is pushed and aligned, and temporary branch cleanup is
complete.
