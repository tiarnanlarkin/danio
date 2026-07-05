# Danio Active Handoff

Status: Active current-session handoff
Last updated: 2026-07-05 during DS-2026-07-05-029 equipment undo parent-guard closeout

## Branch

- Source-of-truth branch: `main`.
- Session preflight for DS-2026-07-05-029:
  - Repo root confirmed as
    `C:\Users\larki\OneDrive\Documents\App Projects\Danio Aquarium App Project\repo`.
  - `git fetch --prune` completed.
  - `git status --short -uall` was clean before the slice.
  - `main...origin/main` was `0 0`, so local `main` was aligned with the
    GitHub mirror.
  - `git worktree list --porcelain` showed only the main worktree.
  - Local branches/worktrees were clean except remote Dependabot branches.
  - Repo/device workflow docs were reread before edits.
- Slice branch used: `ds-2026-07-05-029-equipment-undo-parent`.
- Closeout expectation: after the documented gates, merge this verified branch
  into `main`, push `origin/main`, confirm `main...origin/main` is `0 0`, and
  delete the temporary branch after it is safely merged.

## Current Slice

- Slice: `DS-2026-07-05-029` Prevent Equipment undo from restoring orphan
  records after parent tank deletion.
- Scope:
  - Add widget coverage for deleting equipment, deleting the parent tank before
    snackbar Undo, and confirming Undo does not recreate the equipment or its
    generated maintenance task.
  - Recheck the durable parent tank before Equipment delete Undo restores
    captured equipment/task records.
  - Update CL-P1-009 data-resilience breadcrumbs in agent/product docs.
  - Keep visual redesign, live-preview install/reload/screenshot, optional AI,
    cloud/account tooling, release/store work, and broader restore/migration
    walkthrough QA out of scope.
- Product behavior changes: Equipment delete Undo now fails safely if the
  parent tank no longer exists, leaving local equipment/task records deleted and
  showing the existing restore-failure feedback.
- New accounts/tools/plugins/MCP/hooks/automations: none.
- Live preview/device requirement: CheckOnly workflow was inspected before work.
  No install/reload/screenshot was required for this data-safety widget slice.

## Dirty Files To Preserve

No dirty files are expected after DS-2026-07-05-029 is committed, merged,
pushed, and the temporary branch is cleaned up. If this slice is interrupted
before cleanup, preserve these paths:

- `apps/aquarium_app/lib/screens/equipment_screen.dart`
- `apps/aquarium_app/test/widget_tests/equipment_screen_test.dart`
- `apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md`
- `apps/aquarium_app/docs/agent/FINISH_MAP.md`
- `apps/aquarium_app/docs/agent/SLICE_LOG.md`
- `apps/aquarium_app/docs/agent/plans/DS-2026-07-05-029-equipment-undo-parent-slice-contract.md`
- `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`

## Last Checks

Passed for this slice before final clean-branch gate:

- Runtime preflight: `adb devices` showed `emulator-5554` and `emulator-5556`;
  `.\scripts\run_danio_live_preview.ps1 -CheckOnly` selected `emulator-5556`
  as `danio_api36` with `com.tiarnanlarkin.danio` foregrounded.
- RED: `flutter test test/widget_tests/equipment_screen_test.dart --plain-name
  "undo does not restore equipment after its parent tank was deleted" --reporter
  compact` failed because orphan equipment was restored after the parent tank
  was deleted.
- GREEN after implementation:
  `flutter test test/widget_tests/equipment_screen_test.dart --plain-name
  "undo does not restore equipment after its parent tank was deleted" --reporter
  compact`
- `dart format lib/screens/equipment_screen.dart
  test/widget_tests/equipment_screen_test.dart`
- `flutter test test/widget_tests/equipment_screen_test.dart --reporter compact`
- `flutter analyze lib/screens/equipment_screen.dart
  test/widget_tests/equipment_screen_test.dart`
- `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full` passed,
  including worktree visibility, whitespace diff check, focused Flutter tests,
  dependency validation, Danio custom lint, full Flutter suite, Flutter analyze,
  and debug APK build.
- `git diff --check`
- `flutter test test/copy/current_docs_local_truth_test.dart --reporter compact`

Clean-checkout gates still required before merge/push:

- clean branch gate: `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full -RequireCleanWorktree`
- post-merge clean `main` gate with `-RequireCleanWorktree`

## Device And Preview State

- Startup live-preview CheckOnly passed before edits:
  - `emulator-5556` is `danio_api36`.
  - `com.tiarnanlarkin.danio` is foregrounded.
  - `emulator-5554` is also connected and was not touched.
- No live-preview refresh, install, tap, screenshot, or logcat capture was
  needed for DS-2026-07-05-029.
- The previously observed returning-user prompt context-after-dispose exception
  around `lib/screens/home/home_screen.dart` lines 148-149 remains a follow-up
  only if current repo evidence shows it outranks remaining data-resilience
  work.
- If a future slice needs device work, use `DEVICE_OWNERSHIP.md` before
  installs, taps, screenshots, logcat, Patrol, Maestro, or live-preview control.

## Blockers

- No current roadmap blocker for the ranked data-resilience lane.
- Broader CL-P1-009/CL-QA-006 data resilience remains open for remaining
  restore, migration, create/edit/delete, relationship-mapping, and future
  debounced-writer app-kill coverage found in review.
- Remaining AI confirmation work is still any future AI changes to tank data,
  tasks, and reminders.

## Next Action

Autonomous chain mode stops after DS-2026-07-05-029 because the approved
remaining session budget reaches zero. Do not create another successor thread.

For a future manual session:

1. Use `$verified-slice-runner`, rebuild context from repo-owned docs and live
   git/device state, and stay in this saved Danio project.
2. Treat the equipment undo parent-guard candidate as completed by
   DS-2026-07-05-029 unless current repo evidence proves otherwise.
3. Pick one concrete remaining slice from the ranked data-resilience lane in
   `FINISH_MAP.md`: restore, migration, create/delete, relationship mapping, or
   future debounced-writer app-kill persistence coverage.
4. Consider the returning-user prompt context-after-dispose runtime follow-up
   only if fresh repo/runtime evidence shows it outranks the remaining
   data-resilience lane.
5. Run focused failing/guard proof first where behavior changes, then the
   required `QUALITY_LADDER.md` gate before commit.
