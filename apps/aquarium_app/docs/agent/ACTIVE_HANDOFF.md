# Danio Active Handoff

Status: Active current-session handoff
Last updated: 2026-07-05 during DS-2026-07-05-024 data-resilience closeout

## Branch

- Source-of-truth branch: `main`.
- Session preflight for DS-2026-07-05-024:
  - `git fetch --prune` completed.
  - `git status --short -uall` was clean before the slice.
  - `main...origin/main` was `0 0`, so local `main` was not behind the GitHub
    mirror.
  - `git worktree list` showed only the main worktree.
  - The slice branch was created from clean `main`.
- Slice branch used: `ds-2026-07-05-024-backup-import-id-collision`.
- Closeout result: verified work was merged into `main`, `main` was pushed, and
  the temporary slice branch was deleted after it was safely merged.

## Current Slice

- Slice: `DS-2026-07-05-024` Backup import must avoid generated tank ID
  collisions before saving.
- Scope:
  - Add a focused backup import service regression for a generated local import
    tank ID that already exists in storage.
  - Make `BackupImportService` regenerate imported tank IDs until it finds an
    unused local tank ID before saving imported tank data.
  - Keep child ID collision hardening, Backup & Restore UI redesign, and
    Android screenshots
    out of scope.
- Product behavior changes: a backup import cannot overwrite an existing local
  tank when the generated local import tank ID collides with saved data.
- New accounts/tools/plugins/MCP/hooks/automations: none.
- Live preview/device requirement: existing live preview was inspected with the
  repo-owned CheckOnly workflow. No install/reload/screenshot was required for
  this service-level data-safety slice.

## Dirty Files To Preserve

No dirty files are expected after DS-2026-07-05-024 is committed, merged,
pushed, and the temporary branch is cleaned up. If this slice is interrupted
before cleanup, preserve these paths:

- `apps/aquarium_app/lib/services/backup_import_service.dart`
- `apps/aquarium_app/test/services/backup_import_service_test.dart`
- `apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md`
- `apps/aquarium_app/docs/agent/SLICE_LOG.md`
- `apps/aquarium_app/docs/agent/plans/DS-2026-07-05-024-data-resilience-slice-contract.md`

## Last Checks

Passed for this slice:

- RED: `flutter test test/services/backup_import_service_test.dart --name
  "regenerates imported tank ids that already exist locally" --reporter
  compact` failed because the import mapped `old-tank` to the colliding
  `new-tank`.
- GREEN: same focused command passed after `BackupImportService` generated
  unused local tank IDs before saving imported tanks.
- `dart format lib/services/backup_import_service.dart
  test/services/backup_import_service_test.dart`
- `flutter test test/services/backup_import_service_test.dart --reporter
  compact`
- `flutter analyze lib/services/backup_import_service.dart
  test/services/backup_import_service_test.dart`
- Live preview/device preflight:
  - `.\scripts\run_danio_live_preview.ps1 -CheckOnly` passed.
  - `adb` confirmed `emulator-5556` is `danio_api36` with
    `com.tiarnanlarkin.danio/.MainActivity` foregrounded.
  - `adb` confirmed `emulator-5554` is `wgtr_codex_api36` with WGTR
    foregrounded; it was not touched.
  - No live-preview refresh was required because this slice changed
    service-level import behavior only.
- `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
  passed from the slice branch, including worktree visibility, whitespace diff
  check, focused Flutter tests, dependency validation, Danio custom lint, full
  Flutter test suite, Flutter analyze, and debug APK build.
- Post-doc closeout checks:
  - `git diff --check`
  - `flutter test test/copy/current_docs_local_truth_test.dart --reporter
    compact`

Notes:

- `main...origin/main` was `0 0` after push and only the main worktree remained.
- `FINISH_MAP.md` and the product backlog do not need status changes unless the
  final gate changes the Data resilience row's completion status.

## Device And Preview State

- Live preview was inspected and remains visible on the dedicated phone AVD:
  - `emulator-5556` is `danio_api36`.
  - `com.tiarnanlarkin.danio/.MainActivity` is foregrounded.
  - No live-preview terminal is owned by this session.
- The other connected emulator was confirmed as `wgtr_codex_api36` on
  `emulator-5554`, foregrounded on WGTR. Do not use or disturb that device.
- The first live-preview launch log surfaced an existing returning-user prompt
  exception from `lib/screens/home/home_screen.dart` around lines 148-149 after
  app launch/user interaction. It was recorded as a follow-up only, because
  DS-2026-07-05-023 is a provider-level bulk-move data-safety slice.
- If the next slice needs device work, use `DEVICE_OWNERSHIP.md` before
  installs, taps, screenshots, logcat, Patrol, Maestro, or live-preview control.

## Blockers

- No current roadmap blocker for the ranked data-resilience lane.
- Broader CL-P1-009/CL-QA-006 data resilience remains open for remaining
  create/edit/delete, restore, migration, and future app-kill flush coverage
  found in review.
- Remaining AI confirmation work is still any future AI changes to tank data,
  tasks, and reminders.
- Follow-up runtime bug: investigate the returning-user prompt context-after-
  dispose exception observed during live preview when that lane outranks the
  remaining data-resilience work.

## Next Action

DS-2026-07-05-024 is verified and pushed. Next:

1. Start the next fresh slice from `FINISH_MAP.md`, `QUALITY_LADDER.md`,
   `TESTING_CHECKLIST.md`, and the current `git status --short -uall`.
2. Stay in the ranked data-resilience lane unless a higher-priority local-first
   or product-honesty regression is found.
3. Pick one concrete remaining restore, migration, create/delete, child-ID
   collision, or future debounced-writer app-kill persistence gap.
4. Use the data-safety row in `QUALITY_LADDER.md`: focused failing test first,
   fix green, then `Full` gate before commit.
