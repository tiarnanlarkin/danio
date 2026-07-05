# Danio Active Handoff

Status: Clean DS-2026-07-05-037 checkpoint ready for next data-resilience audit
Last updated: 2026-07-05 after DS-2026-07-05-037 merge and clean-main Full gate

## Branch

- Source-of-truth branch: `main`.
- Current branch after closeout: `main`.
- DS-2026-07-05-037 behavior commit: `9f0f6303`
  (`Guard backup import duplicate tank IDs`).
- DS-2026-07-05-037 closeout docs commit: `dc2de19f`
  (`Update DS-037 handoff closeout`).
- Final state for the next session:
  - `git status --short -uall` is clean.
  - `main...origin/main` is `0 0`.
  - The temporary DS-037 branch has been deleted after merge.

## Completed Slice

- Slice: DS-2026-07-05-037, Backup Import Duplicate Tank ID Guard.
- Slice contract:
  `docs/agent/plans/DS-2026-07-05-037-import-duplicate-tank-id-guard-slice-contract.md`.
- Plan context: the session began with a read-only data-resilience gap
  selection audit against current docs, source, tests, git state, and the
  DS-036 handoff. Recent restore, migration, child-tank, relationship-ID, and
  duplicate-child import guards were rechecked before selecting another direct
  tank-scoped import boundary gap in the same service/test family.
- Gap selected: `BackupImportService.importTankScopedData` already had shared
  ZIP-preview duplicate tank-ID validation upstream, but the lower direct
  import boundary assigned `tankIdMap[oldTankId] = newTankId` without checking
  duplicate backup tank IDs. A malformed direct call could save two local
  imported tanks while relationships mapped only to the last duplicate backup
  tank ID.
- Behavior changed:
  - Direct tank-scoped backup imports now reject duplicate backup tank IDs
    before saving imported tanks.
  - Duplicate backup tank IDs throw `FormatException`, are wrapped as
    `BackupImportException`, and leave tank and child storage unchanged in the
    focused service proof.
  - Backup ZIP preview validation, SharedPreferences restore, UI layout,
    Android runtime behavior, cloud/account behavior, paid services, API keys,
    and optional-AI behavior were not changed.

## Dirty Files To Preserve

No dirty files are expected after final closeout. If future startup shows dirty
files, treat them as new/unrelated work unless current git history proves
otherwise.

## Verification Evidence

Startup:

- `git rev-parse --show-toplevel` confirmed
  `C:/Users/larki/OneDrive/Documents/App Projects/Danio Aquarium App Project/repo`.
- `git fetch --prune`
- `git status --short -uall` was clean before edits.
- `git rev-list --left-right --count main...origin/main` was `0 0`.
- `git branch -vv --all` showed local `main` tracking `origin/main`, aside
  from remote Dependabot branches.
- `git worktree list --porcelain` showed only the main repo worktree.
- No emulator, ADB, install, tap, screenshot, logcat, or live-preview action
  was used; this was a pure service data-safety slice.

Focused proof:

- RED:
  `flutter test test/services/backup_import_service_test.dart --name "rejects duplicate backup tank ids before reporting import success" --reporter compact`
  failed because the import returned `BackupImportResult` instead of throwing.
- GREEN: the same named service test passed after the duplicate-tank-ID guard.
- `dart format lib\services\backup_import_service.dart test\services\backup_import_service_test.dart`
  reported `0 changed`.
- `flutter test test/services/backup_import_service_test.dart --reporter compact`
  passed with 11 tests.
- `flutter analyze lib/services/backup_import_service.dart test/services/backup_import_service_test.dart`
  passed with no issues.
- `git diff --check` passed before the behavior commit.

Branch gate:

- Branch clean-worktree Full gate:
  `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full -RequireCleanWorktree`
  passed on behavior commit `9f0f6303`. This covered worktree visibility,
  whitespace, focused tests, dependency validation, custom lint, the full
  Flutter test suite, `flutter analyze`, and the debug APK build.

Docs and clean-main gate:

- `git diff --check` passed after DS-037 documentation updates.
- `flutter test test/copy/current_docs_local_truth_test.dart --reporter compact`
  passed after DS-037 documentation updates.
- Clean-main Full gate:
  `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full -RequireCleanWorktree`
  passed after DS-037 was merged to `main`. This covered worktree visibility,
  whitespace, focused tests, dependency validation, custom lint, the full
  Flutter test suite, `flutter analyze`, and the debug APK build.

## Device And Preview State

- No live-preview refresh, install, tap, screenshot, or logcat capture was
  required for this service data-safety slice.
- If a future slice needs device work, use `DEVICE_OWNERSHIP.md` before
  installs, taps, screenshots, logcat, Patrol, Maestro, or live-preview
  control.

## Blockers

- No blocker remains for DS-2026-07-05-037 itself.
- Broader CL-P1-009/CL-QA-006 data resilience remains open for remaining
  restore, migration, create/delete, any remaining relationship-mapping gaps
  found from fresh evidence, and future debounced-writer app-kill coverage.
- The previously observed returning-user prompt context-after-dispose exception
  remains a follow-up only if current repo/runtime evidence shows it outranks
  remaining data-resilience work.

## Next Action

Remaining autonomous chain budget after DS-2026-07-05-037: 2 sequential
verified sessions, if final merge, push, cleanup, and source alignment complete
cleanly.

Recommended next action: continue the read-only data-resilience gap selection
audit from fresh repo evidence, starting with current restore, migration,
create/delete, relationship integrity, and future debounced-writer surfaces.
Implement exactly one small TDD-verifiable slice only if the next target is
unambiguous, local-only, and safe within one service/test family. If multiple
candidates remain plausible, runtime ownership is needed, the target is already
covered, or the next action requires product direction, ask one direct question
instead of guessing.

Paste-ready successor prompt:

```text
Use $verified-slice-runner for the next Danio Aquarium complete-local epoch.

Continuation mode: autonomous chain approved.
Remaining sequential session budget: 2 total, including this successor. Do not
run parallel repo sessions after this successor is running. Stop early if the
app reaches the complete-local bar before the budget is exhausted. If more than
the remaining budget would be needed, stop at a clean checkpoint and ask the
user.

Saved Codex project:
C:\Users\larki\OneDrive\Documents\App Projects\Danio Aquarium App Project

Start from:
C:\Users\larki\OneDrive\Documents\App Projects\Danio Aquarium App Project\repo

Current checkpoint evidence from predecessor session:
- Final source-of-truth branch: clean `main` tracking `origin/main`.
- DS-037 behavior commit: `9f0f6303` (`Guard backup import duplicate tank IDs`).
- DS-037 was merged, clean-main gated, pushed, and branch-cleaned before this
  successor was created; do not trust this as current state, re-run the
  startup checks below.
- DS-037 closed a direct `BackupImportService.importTankScopedData` lower-boundary
  gap: duplicate backup tank IDs are rejected before imported tanks are saved,
  so direct imports cannot report success while duplicate backup tanks collapse
  relationship mapping to one regenerated local ID.

Do not rely on prior chat memory. Rebuild context from repo-owned files, live
git state, current command output, current installed skill instructions, and
this prompt.

Required startup:
1. Load and follow the latest installed $verified-slice-runner skill from disk.
2. Confirm the actual repo root with git.
3. Read applicable AGENTS.md / repo instructions from root to working
   directory.
4. Run git fetch --prune.
5. Run git status --short -uall.
6. Confirm source branch and upstream alignment first; stop if main...origin/main
   is not 0 0.
7. Read README, GIT_WORKFLOW.md,
   apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md, FINISH_MAP.md,
   QUALITY_LADDER.md, TESTING_CHECKLIST.md, SLICE_LOG.md, and
   apps/aquarium_app/docs/agent/plans/2026-07-05-accelerated-complete-local-epoch-plan.md
   before editing. Also read any docs those files require.
8. Preserve unrelated dirty work and inspect emulator/device/debug-server state
   before any runtime action.

Goal: continue Danio toward local-first, phone-first complete-local quality.
Begin with a read-only data-resilience gap selection audit against the current
Finish Map and DS-037 handoff. Prefer restore, migration, create-delete,
relationship integrity, and future debounced-writer gaps only when fresh source
and test evidence proves the specific missing behavior and proof setup.
Implement exactly one small slice only if the next target is unambiguous,
local-only, product-safe, and TDD-verifiable in one service/test family. If
multiple candidates remain plausible, runtime ownership is needed, the target is
already covered, or the next action requires product direction, stop and ask one
direct question.

Closeout: update repo-owned handoff/log docs, run focused proof and the
documented local gates, commit, merge to main, push origin/main, clean temporary
branches/worktrees, and decrement remaining chain budget if creating exactly
one successor from a clean pushed aligned checkpoint.
```
