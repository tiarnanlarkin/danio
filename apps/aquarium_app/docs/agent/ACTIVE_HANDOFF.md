# Danio Active Handoff

Status: Active current-session handoff
Last updated: 2026-07-04 during HSK-2026-07-04-001 repository housekeeping

## Branch

- Source-of-truth branch: `main`.
- `main` was fast-forwarded to `qa/production-tool-audit-2026-05-25` at
  `9d64de38 fix: guard tank quick feeding against missing tanks`.
- Housekeeping commit: `8e1e0ac0 chore: consolidate main and archive legacy
  docs`.
- The former QA branch had no commits missing from `main` after the
  fast-forward.
- The former QA branch was deleted locally and from `origin` after `main` was
  pushed.

## Current Slice

- Slice: `HSK-2026-07-04-001` repository housekeeping and source-of-truth
  consolidation.
- Scope:
  - Make `main` the single buildable branch source of truth.
  - Archive stale root-level reports, old roadmap/workflow files, old
    top-level `memory/` plans, and stray top-level `danio/` research files.
  - Replace root/docs entry points with short links to the current app,
    product, and agent control docs.
  - Leave unclear functional references, such as `contracts/`, in place.
- Product behavior changes: none intended.
- New accounts/tools/plugins/MCP/hooks/automations: none.
- Live preview/device requirement: not required for the housekeeping slice.

## Dirty Files To Preserve

All dirty files should belong to `HSK-2026-07-04-001` until the housekeeping
commit lands. Preserve these paths if interrupted:

- `README.md`
- `CLAUDE.md`
- `GIT_WORKFLOW.md`
- `save_work.bat`
- `save_work.sh`
- `docs/README.md`
- `docs/ROADMAP.md`
- `docs/development/CODEX_SAFE_WORKFLOW.md`
- `docs/archive/root-legacy-2026-07-04/`
- `apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md`
- `apps/aquarium_app/docs/agent/HOUSEKEEPING.md`
- `apps/aquarium_app/docs/agent/SLICE_LOG.md`
- `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`

## Last Checks

Passed for this slice:

- `git diff --check`
- `flutter test test/copy/current_docs_local_truth_test.dart --reporter compact`
- `flutter analyze`
- `flutter build apk --debug --target lib/main.dart`

Notes:

- `flutter test`, `flutter analyze`, and `flutter build apk --debug` reported
  existing dependency update notices.
- The debug APK build also reported Flutter's existing Kotlin Gradle Plugin
  migration warning for the app/plugins; the build still completed.

The immediately prior data-safety slice, `DS-2026-07-04-017`, passed its
focused Tank Detail tests, targeted analysis, `Full` quality gate, post-doc
`git diff --check`, and current-doc truth test before being fast-forwarded into
`main`.

## Device And Preview State

- The connected physical phone `RFCY8022D5R` was used before this housekeeping
  slice to clean-install and launch a release APK from `9d64de38`.
- No emulator, screenshot, logcat evidence, or live-preview ownership was used
  for this housekeeping slice.
- If the next slice needs device work, use `DEVICE_OWNERSHIP.md` before
  installs, taps, screenshots, logcat, Patrol, Maestro, or live-preview control.

## Blockers

- No current housekeeping blocker.
- Broader CL-P1-009/CL-QA-006 data resilience remains open for remaining
  create/edit/delete, restore, migration, and future app-kill flush coverage
  found in review.
- Remaining AI confirmation work is still any future AI changes to tank data,
  tasks, and reminders.

## Next Action

Housekeeping is committed, pushed, and temporary branches are removed. Next:

1. Start a fresh session.
2. Rebuild context from `AGENTS.md`, this handoff, `FINISH_MAP.md`,
   `QUALITY_LADDER.md`, `SCREEN_INVENTORY.md`, and the product audit/backlog.
3. Study the current build from source, tests, and available device evidence.
4. Produce the updated finish-line roadmap before starting the next development
   push.
