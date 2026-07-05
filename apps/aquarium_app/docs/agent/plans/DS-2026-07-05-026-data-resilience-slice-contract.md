# DS-2026-07-05-026 Data-Resilience Slice Contract

## Slice

- ID: DS-2026-07-05-026
- Title: Surface local JSON load I/O failures instead of empty-data success
- Branch/worktree: `ds-2026-07-05-026-local-json-load-io-error` in the main repo worktree
- Coordinator: current Codex session
- Worker agents: none
- Owned files/modules:
  - `lib/services/local_json_storage_service.dart`
  - `test/storage_error_handling_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/SLICE_LOG.md`
  - this contract
- Out of scope:
  - Backup & Restore UI redesign
  - Android screenshot or install work
  - broader storage recovery UX changes
  - optional AI, cloud, paid/account-backed tools, release/store scope

## Product Goal

- User-visible outcome: if Danio cannot read the local JSON data file because the path is not a readable file, it must not silently present an empty aquarium as a successful load.
- Complete-local requirement: local-first data safety and honest recovery state.
- Finish Map rows: Data resilience; Backup and restore.
- Backlog rows: CL-P1-009 and CL-QA-006.

## Research And Planning

- Fresh session recommended: already started from a clean successor handoff with one-slice budget.
- Repo context checked: `AGENTS.md`, `README.md`, `GIT_WORKFLOW.md`, app README, `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`, `QUALITY_LADDER.md`, `TESTING_CHECKLIST.md`, `WORKFLOW_CHARTER.md`, `RESEARCH_PROTOCOL.md`, product audit/backlog, device/live-preview docs, relevant storage source/tests.
- Current best-practice sources checked: repo source and local tests are sufficient; no external API/framework decision needed.
- Tool/plugin/MCP/account-backed lane considered: not needed.
- Tool/plugin/MCP/account-backed lane approved: not needed.
- Decision-changing notes: current code records unexpected load I/O errors but then marks storage loaded with empty data, making a data-file path failure look like an empty successful aquarium.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: not required; service-level data-safety slice.
- Phone expectation: app providers see a storage error instead of empty tank data.
- Tablet expectation: same.
- Accessibility expectation: no UI/copy change in this slice.
- Visual evidence required: no.

## Tests And Gates

- Focused RED/GREEN test: `flutter test test/storage_error_handling_test.dart --plain-name "load I/O errors stay in ioError instead of reporting empty success" --reporter compact`
- Focused file test: `flutter test test/storage_error_handling_test.dart --reporter compact`
- Targeted static check: `flutter analyze lib/services/local_json_storage_service.dart test/storage_error_handling_test.dart`
- Required local gate: `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
- Android evidence required: no, service-level storage behavior only.
- External review/tool lane: none.
- Paid-tool ledger entry required: no.

## Data And Safety

- Local data touched: local JSON storage load state only; no real user files are modified by tests.
- Failure states to test: `aquarium_data.json` exists as a directory, so the data path is not a readable JSON file.
- Rollback or retry behavior: service remains `ioError`/`hasError` and `retryLoad()` remains the explicit retry path.
- Product honesty check: no fake empty-data success when local storage cannot be read.

## Done Criteria

- focused test fails RED for the expected false-success reason;
- smallest production fix makes focused test pass;
- full storage error test file passes;
- targeted analyze passes;
- Full gate passes;
- `git diff --check` passes;
- active handoff and slice log record the completed slice;
- branch is committed, merged to `main`, pushed, aligned, and cleaned up.
