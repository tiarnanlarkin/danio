# Danio Active Handoff

Status: Active current-session handoff
Last updated: 2026-07-05 during DS-2026-07-05-022 data-resilience slice

## Branch

- Source-of-truth branch: `main`.
- Session preflight for DS-2026-07-05-022:
  - `git fetch --prune` completed.
  - `git status --short -uall` was clean before the slice.
  - `main...origin/main` was `0 0`, so local `main` was not behind the GitHub
    mirror.
  - `git worktree list` showed only the main worktree.
  - The slice branch was created from clean `main`.
- Slice branch used: `ds-2026-07-05-022-bulk-move-target-guard`.
- Closeout target: merge verified work into `main`, push `main`, then delete
  the temporary slice branch if safely merged.

## Current Slice

- Slice: `DS-2026-07-05-022` Bulk livestock move must reject missing target
  tanks before saving.
- Scope:
  - Add a focused provider regression for selecting a bulk livestock move
    target, deleting that target tank before the move executes, and then calling
    `bulkMoveLivestock`.
  - Make `TankActions.bulkMoveLivestock` recheck the target tank in durable
    storage before saving any moved livestock.
  - Keep source-tank deletion variants, broad backup/restore internals, Android
    evidence, and UI redesign out of scope.
- Product behavior changes: stale bulk livestock move actions can no longer
  create orphan local livestock under a tank that has already been deleted.
- New accounts/tools/plugins/MCP/hooks/automations: none.
- Live preview/device requirement: not required; this is a non-visual
  provider-level data-safety slice.

## Dirty Files To Preserve

No dirty files are expected after DS-2026-07-05-022 is committed, merged,
pushed, and the temporary branch is cleaned up. If this slice is interrupted
before cleanup, preserve these paths:

- `apps/aquarium_app/lib/providers/tank_provider.dart`
- `apps/aquarium_app/test/providers/tank_provider_test.dart`
- `apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md`
- `apps/aquarium_app/docs/agent/SLICE_LOG.md`
- `apps/aquarium_app/docs/agent/plans/DS-2026-07-05-022-data-resilience-slice-contract.md`

## Last Checks

Passed so far for this slice:

- RED: `flutter test test/providers/tank_provider_test.dart --name "rejects
  missing target tank ids before moving livestock" --reporter compact` failed
  because the move completed instead of throwing.
- GREEN: same focused command passed after `bulkMoveLivestock` rechecked the
  target tank before any move writes.
- `dart format lib/providers/tank_provider.dart
  test/providers/tank_provider_test.dart`
- `flutter test test/providers/tank_provider_test.dart --reporter compact`
- `flutter analyze lib/providers/tank_provider.dart
  test/providers/tank_provider_test.dart`
- `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
  passed from the slice branch, including worktree visibility, whitespace diff
  check, focused Flutter tests, dependency validation, Danio custom lint, full
  Flutter test suite, Flutter analyze, and debug APK build.
- Post-doc closeout checks:
  - `git diff --check`
  - `flutter test test/copy/current_docs_local_truth_test.dart --reporter
    compact`

Notes:

- A final Full gate rerun on merged `main` is required before pushing if the
  merge completes.
- `FINISH_MAP.md` and the product backlog do not need status changes unless the
  final gate changes the Data resilience row's completion status.

## Device And Preview State

- No emulator, screenshot, logcat evidence, or live-preview ownership was used
  for this non-visual provider data-safety slice.
- Startup runtime preflight:
  - `adb devices -l` showed `emulator-5554` attached.
  - `.\scripts\run_danio_live_preview.ps1 -CheckOnly` reported AVD
    `danio_api36` was not running; no device control was taken.
- If the next slice needs device work, use `DEVICE_OWNERSHIP.md` before
  installs, taps, screenshots, logcat, Patrol, Maestro, or live-preview control.

## Blockers

- No current roadmap blocker.
- Broader CL-P1-009/CL-QA-006 data resilience remains open for remaining
  create/edit/delete, restore, migration, and future app-kill flush coverage
  found in review.
- Remaining AI confirmation work is still any future AI changes to tank data,
  tasks, and reminders.

## Next Action

After DS-2026-07-05-022 closes, next:

1. Start the next fresh slice from `FINISH_MAP.md`, `QUALITY_LADDER.md`,
   `TESTING_CHECKLIST.md`, and the current `git status --short -uall`.
2. Stay in the ranked data-resilience lane unless a higher-priority local-first
   or product-honesty regression is found.
3. Pick one concrete remaining restore, migration, create/delete, or future
   debounced-writer app-kill persistence gap.
4. Use the data-safety row in `QUALITY_LADDER.md`: focused failing test first,
   fix green, then `Full` gate before commit.
