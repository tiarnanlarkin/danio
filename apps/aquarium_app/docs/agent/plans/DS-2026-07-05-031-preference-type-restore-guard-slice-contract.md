# DS-2026-07-05-031 Preference Type Restore Guard

## Slice

- ID: DS-2026-07-05-031
- Title: Reject malformed backup preference value types before restore
- Branch/worktree: `ds-2026-07-05-031-preference-type-restore-guard` in the
  saved Danio project checkout
- Coordinator: current Codex session
- Worker agents, if any: none
- Owned files/modules:
  - `lib/services/shared_preferences_backup.dart`
  - `lib/services/backup_service.dart`
  - `test/services/shared_preferences_backup_test.dart`
  - `test/services/backup_service_photo_restore_test.dart`
- Files/modules explicitly out of scope: UI import flow, Android device
  interaction, backup ZIP photo extraction behavior, unrelated preference keys

## Product Goal

- User-visible outcome: malformed backup files cannot restore exportable
  preferences under the wrong primitive type, preventing silent local
  preference corruption during Backup & Restore.
- Complete-local requirement this advances: local-first data resilience.
- Finish Map row(s): Data resilience; Backup and restore.
- Product backlog row(s): CL-P1-009 / CL-QA-006 backup/data hardening.

## Research And Planning

- Fresh session recommended: No; this is one bounded service/test slice after a
  clean startup and read-only gap audit.
- Repo context checked: `AGENTS.md`, `GIT_WORKFLOW.md`, `ACTIVE_HANDOFF.md`,
  `FINISH_MAP.md`, `QUALITY_LADDER.md`, `TESTING_CHECKLIST.md`, `SLICE_LOG.md`,
  accelerated epoch plan, app README, device ownership, live preview workflow,
  workflow charter, research protocol, backup/preference source, and nearby
  tests.
- Current best-practice sources checked: repo source/tests only; this slice
  changes local validation policy and does not depend on unstable external API
  behavior.
- Tool/plugin/MCP/account-backed lane considered: Not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: current source reads exact exportable keys
  through typed `SharedPreferences` getters (`getBool`, `getInt`, `getString`,
  and `getStringList`), while backup restore validation accepted any primitive
  type for any exportable key.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: Not applicable.
- Phone expectation: No UI layout change.
- Tablet expectation: No UI layout change.
- Accessibility expectation: No UI change.
- Visual evidence required: No.

## Tests And Gates

- Focused RED tests:
  - `flutter test test/services/shared_preferences_backup_test.dart --name "restore rejects integer preference with decimal value before clearing theme_mode" --reporter compact`
  - `flutter test test/services/backup_service_photo_restore_test.dart --name "getBackupData rejects sharedPreferences entries with invalid integer type" --reporter compact`
- Focused GREEN tests:
  - same named tests
  - `flutter test test/services/shared_preferences_backup_test.dart test/services/backup_service_photo_restore_test.dart --reporter compact`
- Required local gate: Full profile with clean-worktree requirement for data
  safety.
- Android evidence required: No; service-only data validation.
- External review/tool lane: None.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: Backup preview validation and SharedPreferences restore
  validation for exportable preference entries.
- Failure states to test: integer preference backed up as decimal, boolean
  preference backed up as string, and string preference backed up as string
  list.
- Rollback or retry behavior: `restoreFromJson` rejects malformed values before
  clearing existing exportable preferences; `getBackupData` rejects malformed
  backup files before import preview.
- No-fake-feature/product-honesty check: no new feature surface or external
  service introduced.

## Done Criteria

The slice is done only when:

- focused RED/GREEN evidence exists;
- full touched service tests pass;
- targeted analyze passes for touched Dart files;
- `git diff --check` passes;
- the required Full gate passes on the branch and clean `main`;
- repo-owned handoff/log docs are updated;
- the branch is merged to `main`, pushed, cleaned up, and aligned with
  `origin/main`.

## Result

- Commit: pending
- Verification summary: pending
- Evidence path: not applicable
- Follow-up created: pending
