# Danio Slice Contract: DS-2026-07-05-019

## Slice

- ID: `DS-2026-07-05-019`
- Title: Remove legacy direct JSON import/export from Preferences
- Branch/worktree: `ds-2026-07-05-019-remove-settings-json-import`
- Coordinator: current Codex coordinator
- Worker agents, if any: none
- Owned files/modules:
  - `lib/screens/settings/settings_data_section.dart`
  - `scripts/quality_gates/run_local_quality_gate.ps1`
  - `test/copy/settings_data_copy_test.dart`
  - `test/screens/tool_entry_points_contract_test.dart`
  - `test/scripts/local_quality_gate_script_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/SLICE_LOG.md`
  - `docs/agent/plans/DS-2026-07-05-019-data-resilience-slice-contract.md`
- Files/modules explicitly out of scope: Backup & Restore ZIP import internals,
  cloud backup, account restore, Android device walkthroughs, and broader
  release-candidate evidence.

## Product Goal

- User-visible outcome: Preferences no longer exposes the legacy direct JSON
  export/import controls that bypass the hardened Backup & Restore flow.
- Complete-local requirement this advances: local backup/restore paths should
  be clear, validated, and avoid destructive false-success restore paths.
- Finish Map row(s): Backup and restore; Data resilience.
- Product backlog row(s): `CL-P1-009`; `CL-QA-006`.

## Research And Planning

- Fresh session recommended: No; this is a fresh slice session on clean,
  origin-aligned `main`.
- Repo context checked: `AGENTS.md`, `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`,
  `QUALITY_LADDER.md`, `TESTING_CHECKLIST.md`, current audit, current backlog,
  Backup & Restore source/tests, schema migration source/tests, local JSON
  storage tests, restore invalidation, gem/achievement persistence tests, and
  Settings data entry-point tests.
- Current best-practice sources checked: not needed; this is a repo-local
  product/data-safety boundary.
- Tool/plugin/MCP/account-backed lane considered: not needed.
- Tool/plugin/MCP/account-backed lane approved: not needed.
- Decision-changing research notes: `SettingsDataSection` still exposed
  `Export All Data` and `Import Data` direct JSON controls even though the repo
  already has a hardened `BackupRestoreScreen` reachable from More/Settings Hub
  and tests state Preferences should not duplicate that backup hub.
- Verification-tooling note: the existing `Full` gate failed the debug APK step
  on Windows PowerShell 5.1 because Flutter printed the documented Kotlin
  Gradle Plugin warning to stderr while exiting 0. `TESTING_CHECKLIST.md`
  already says this warning is non-blocking unless it becomes a build failure,
  so the slice includes a narrow gate-wrapper fix that gates Flutter commands
  on exit code while preserving strict `flutter` command lookup.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: existing Settings and
  Settings Hub source/tests.
- Phone expectation: Preferences keeps non-destructive local photo storage
  information; backup/restore remains available through the existing Backup &
  Restore hub.
- Tablet expectation: no new layout pattern.
- Accessibility expectation: no new custom controls; removed controls cannot
  create stale semantics.
- Visual evidence required: none for this non-visual data-safety slice.

## Tests And Gates

- Focused RED/GREEN tests:
  - `flutter test test/copy/settings_data_copy_test.dart test/screens/tool_entry_points_contract_test.dart --reporter compact`
- Required local gate:
  - `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
- Android evidence required: none.
- External review/tool lane: none.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: none at runtime after the change; legacy direct
  `aquarium_data.json` overwrite code is removed from Preferences.
- Failure states to test: Preferences must not expose legacy JSON export/import
  labels or direct file overwrite logic.
- Rollback or retry behavior: users keep the existing Backup & Restore path for
  validated imports; Settings keeps only Photo Storage information.
- No-fake-feature/product-honesty check: Preferences no longer offers a backup
  path whose copy claims settings replacement while bypassing the current ZIP
  backup/import implementation.

## Done Criteria

The slice is done only when:

- focused tests fail before the production change for the legacy Settings
  export/import source;
- focused tests pass after the production change;
- targeted analysis passes for changed files;
- the `Full` local quality gate passes;
- post-doc `git diff --check` and docs truth test pass;
- `ACTIVE_HANDOFF.md` and `SLICE_LOG.md` record the slice result and next
  data-resilience action;
- no unrelated dirty files are staged.

## Result

- Commit: Current commit.
- Verification summary: RED source-contract tests failed while Preferences
  still exposed `Export All Data`; GREEN focused tests and targeted analysis
  passed after removing legacy JSON import/export; RED/GREEN local gate script
  guard covered the Windows PowerShell stderr-warning wrapper fix; `Full` gate
  passed after the wrapper aligned with the documented non-blocking KGP warning.
- Follow-up created: Continue broader data-resilience restore, migration,
  create/delete, and future debounced-writer app-kill coverage from
  `FINISH_MAP.md`.
