# DS-2026-07-05-025 Data Resilience Slice Contract

## Slice

- ID: DS-2026-07-05-025
- Title: Guard backup import child ID collisions before saving
- Branch/worktree: `ds-2026-07-05-025-backup-import-child-id-collisions` in the main repo checkout
- Coordinator: current Codex session
- Worker agents, if any: none
- Owned files/modules:
  - `apps/aquarium_app/lib/services/backup_import_service.dart`
  - `apps/aquarium_app/test/services/backup_import_service_test.dart`
  - `apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md`
  - `apps/aquarium_app/docs/agent/SLICE_LOG.md`
- Files/modules explicitly out of scope:
  - Backup & Restore UI redesign
  - Android screenshots or install/reload work
  - General restore/migration walkthrough QA outside child import IDs

## Product Goal

- User-visible outcome: importing a backup cannot overwrite existing local livestock, equipment, task, or log records if a generated local child ID collides with saved data.
- Complete-local requirement this advances: local backup/restore must avoid data loss and false restore success states.
- Finish Map row(s): Data resilience
- Product backlog row(s): CL-P1-009 / CL-QA-006

## Research And Planning

- Fresh session recommended: No; this is a fresh successor session with clean repo state and one narrow service-level slice.
- Repo context checked: `AGENTS.md`, `README.md`, `GIT_WORKFLOW.md`, `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`, `QUALITY_LADDER.md`, `TESTING_CHECKLIST.md`, `SLICE_LOG.md`, product audit/backlog data-resilience sections, device/live-preview docs, current git state, branch/worktree state, and scoped ADB live-preview state.
- Current best-practice sources checked: Not needed; this is a local service data-safety fix using existing repo patterns.
- Tool/plugin/MCP/account-backed lane considered: Not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: `FINISH_MAP.md` and `ACTIVE_HANDOFF.md` still rank data resilience above the recorded returning-user prompt runtime follow-up. `BackupImportService` guards tank ID collisions but still generates child IDs without checking existing local children.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: Not applicable; pure service/import behavior.
- Phone expectation: Existing visible preview remains undisturbed.
- Tablet expectation: Not applicable.
- Accessibility expectation: Not applicable.
- Visual evidence required: No.

## Tests And Gates

- Focused test(s): `flutter test test/services/backup_import_service_test.dart --name "regenerates imported child ids that already exist locally" --reporter compact`
- Required local gate: `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
- Android evidence required: No; no UI/runtime behavior changes.
- External review/tool lane: None.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: backup import remapping into local tank-scoped child storage.
- Failure states to test: generated import livestock, equipment, task, and log IDs collide with existing local child IDs.
- Rollback or retry behavior: import should choose fresh generated child IDs before saving and preserve existing local child records.
- No-fake-feature/product-honesty check: No new feature claims or external services.

## Done Criteria

The slice is done only when:

- the focused child-ID collision regression is verified RED before implementation;
- the focused regression and full backup import service test file pass after implementation;
- targeted analysis passes for the touched Dart files;
- the Full local quality gate passes;
- `git diff --check` and docs truth test pass after doc updates;
- active handoff and slice log are updated;
- only slice-owned files are staged;
- work is committed, merged to `main`, pushed, and the temporary branch is safely deleted.

## Result

- Commit: current slice commit
- Verification summary: RED/GREEN child-ID collision regression, full backup
  import service test file, targeted analyzer, Full local quality gate, post-doc
  whitespace check, and docs truth test passed.
- Evidence path: not applicable
- Follow-up created: continue broader data-resilience restore, migration,
  create/delete, and future debounced-writer app-kill coverage; keep the
  returning-user prompt context-after-dispose runtime exception as a separate
  follow-up.
