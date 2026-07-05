# Danio Active Handoff

Status: Active current-session handoff
Last updated: 2026-07-05 during DS-2026-07-05-030 closeout

## Branch

- Source-of-truth branch: `main`.
- Current slice branch:
  `ds-2026-07-05-030-single-livestock-move-parent`.
- Session preflight for DS-2026-07-05-030:
  - Repo root confirmed as
    `C:\Users\larki\OneDrive\Documents\App Projects\Danio Aquarium App Project\repo`.
  - `git fetch --prune` completed.
  - `git status --short -uall` was clean before the slice.
  - `main...origin/main` was `0 0`, so local `main` was aligned with the
    GitHub mirror.
  - `git worktree list --porcelain` showed only the main worktree.
  - Repo workflow, quality, testing, handoff, finish-map, and accelerated epoch
    docs were reread before edits.
  - Runtime ownership was checked before any app/runtime action:
    `adb devices` showed `emulator-5554` and `emulator-5556`, and
    `.\scripts\run_danio_live_preview.ps1 -CheckOnly` selected
    `emulator-5556` as `danio_api36` with
    `com.tiarnanlarkin.danio` foregrounded.

## Current Slice

- Slice: DS-2026-07-05-030, Single Livestock Move Parent Guard.
- Slice contract:
  `docs/agent/plans/DS-2026-07-05-030-single-livestock-move-parent-slice-contract.md`.
- Plan context: Epoch 1 restore/migration candidates were inspected first.
  Current backup import, photo restore, preferences rollback, schema migration,
  and local JSON load-error tests already cover the nearest narrow service
  gaps, so this session fell back to one smaller ranked data-resilience
  relationship-mapping guard.
- Behavior changed: `TankActions.moveLivestock` now rejects missing target tank
  IDs before saving the moved livestock record, matching the existing guarded
  bulk-move target behavior.
- Scope note: current source search shows `moveLivestock` is a provider API and
  not a live UI caller today; this hardens the local data action but does not
  count as restore/migration walkthrough evidence.
- Product behavior outside this provider guard: unchanged.
- New accounts/tools/plugins/MCP/hooks/automations: none.

## Dirty Files To Preserve

Until DS-2026-07-05-030 is committed, merged to `main`, pushed, and the
temporary branch is deleted, preserve these paths:

- `apps/aquarium_app/lib/providers/tank_provider.dart`
- `apps/aquarium_app/test/providers/tank_provider_test.dart`
- `apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md`
- `apps/aquarium_app/docs/agent/FINISH_MAP.md`
- `apps/aquarium_app/docs/agent/SLICE_LOG.md`
- `apps/aquarium_app/docs/agent/plans/DS-2026-07-05-030-single-livestock-move-parent-slice-contract.md`

## Last Checks

Passed so far in DS-2026-07-05-030:

- RED:
  `flutter test test/providers/tank_provider_test.dart --name "rejects missing target tank ids before moving single livestock" --reporter compact`
  failed for the expected reason: the future completed normally instead of
  throwing.
- GREEN:
  `flutter test test/providers/tank_provider_test.dart --name "rejects missing target tank ids before moving single livestock" --reporter compact`
- `dart format lib/providers/tank_provider.dart test/providers/tank_provider_test.dart`
- `flutter test test/providers/tank_provider_test.dart --reporter compact`
- `flutter analyze lib/providers/tank_provider.dart test/providers/tank_provider_test.dart`

Closeout checks still required in this session:

- `git diff --check`
- `flutter test test/copy/current_docs_local_truth_test.dart --reporter compact`
- Commit the branch.
- Branch clean-worktree Full gate:
  `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full -RequireCleanWorktree`
- Fast-forward merge to `main`.
- Post-merge clean `main` Full gate with the same command.
- Push `origin/main`, delete the temporary branch, and confirm
  `main...origin/main` is `0 0`.

## Device And Preview State

- Startup live-preview CheckOnly passed before edits.
- No live-preview refresh, install, tap, screenshot, or logcat capture is
  required for this provider/test slice.
- The previously observed returning-user prompt context-after-dispose exception
  remains a follow-up only if current repo/runtime evidence shows it outranks
  remaining data-resilience work.
- If a future slice needs device work, use `DEVICE_OWNERSHIP.md` before
  installs, taps, screenshots, logcat, Patrol, Maestro, or live-preview
  control.

## Blockers

- No blocker for completing DS-2026-07-05-030 closeout if the remaining gates
  pass.
- Broader CL-P1-009/CL-QA-006 data resilience remains open for remaining
  restore, migration, create/edit/delete, relationship-mapping, and future
  debounced-writer app-kill coverage.
- The next autonomous implementation target is not clear enough for automatic
  chain creation after this slice unless the current session finds stronger
  repo evidence before final closeout. The single-move provider source guard is
  a possible follow-up, but `moveLivestock` currently has no live UI caller.

## Next Action

Current session:

1. Finish the DS-2026-07-05-030 closeout checks listed above.
2. Commit, merge to `main`, push, delete the temporary branch, and confirm
   `main...origin/main` is `0 0` if all gates pass.
3. Remaining autonomous chain budget after this session will be 9 sequential
   verified sessions, but do not create a successor unless a clear next action
   is proven from repo evidence and project-scoped thread creation is available.

For a future manual session:

1. Use `$verified-slice-runner`, rebuild context from repo-owned docs and live
   git/device state, and stay in the saved Danio project.
2. Read
   `docs/agent/plans/2026-07-05-accelerated-complete-local-epoch-plan.md`.
3. Continue the ranked data-resilience lane only after selecting a concrete,
   current gap. Prefer restore/migration Android walkthrough QA if ownership
   and commands are clear; otherwise inspect remaining create/edit/delete or
   relationship-mapping gaps and prove one with RED/GREEN before production
   edits.
4. Consider the returning-user prompt context-after-dispose runtime follow-up
   only if fresh repo/runtime evidence shows it outranks remaining data
   resilience.
