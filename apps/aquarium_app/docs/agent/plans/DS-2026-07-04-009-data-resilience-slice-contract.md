# Danio Slice Contract: DS-2026-07-04-009

## Slice

- ID: `DS-2026-07-04-009`
- Title: Local JSON migration stamp write failure must not report loaded success
- Branch/worktree: `qa/production-tool-audit-2026-05-25` integration checkout
- Coordinator: current Codex coordinator
- Worker agents, if any: none for implementation; read-only explorers only
- Owned files/modules:
  - `lib/services/local_json_storage_service.dart`
  - `test/storage_error_handling_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/FINISH_MAP.md`
  - `docs/agent/SLICE_LOG.md`
  - `docs/agent/plans/2026-07-04-complete-local-delivery.md`
  - `docs/agent/plans/DS-2026-07-04-009-data-resilience-slice-contract.md`
  - `docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
  - `docs/product/danio-complete-local-current-audit-2026-06-13.md`
  - `.gitignore`
- Files/modules explicitly out of scope: AI proxy, backup encryption, smoke
  tests, UI surfaces, Android devices, and store/release artifacts

## Product Goal

- User-visible outcome: if a legacy local JSON file migrates in memory but Danio
  cannot persist the current schema stamp, the storage layer surfaces a local
  load failure instead of claiming the app loaded cleanly.
- Complete-local requirement this advances: local data resilience and migration
  truthfulness.
- Finish Map row(s): Data resilience, Backup and restore.
- Product backlog row(s): `CL-P1-009`, `CL-QA-006`.

## Research And Planning

- Fresh session recommended: No; preflight confirmed branch and upstream
  alignment before implementation.
- Repo context checked: `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`,
  `QUALITY_LADDER.md`, `MULTI_AGENT_WORKFLOW.md`, `SLICE_LOG.md`, and storage
  tests/service code.
- Current best-practice sources checked: not needed; local bug is repo-specific
  and covered by existing atomic-write patterns.
- Tool/plugin/MCP/account-backed lane considered: not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: the quality auditor identified the local
  JSON migration stamp false-green as the highest-value next data-resilience
  slice.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: not visual.
- Phone expectation: no phone UI change.
- Tablet expectation: no tablet UI change.
- Accessibility expectation: no accessibility surface change.
- Visual evidence required: none.

## Tests And Gates

- Focused test(s):
  - `flutter test test/storage_error_handling_test.dart --reporter compact`
- Required local gate:
  - `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
- Android evidence required: none; no device ownership.
- External review/tool lane: none.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: `aquarium_data.json` migration load path.
- Failure states to test: `aquarium_data.json.tmp` write blocked during
  migration stamp persistence.
- Rollback or retry behavior: original legacy JSON file remains intact;
  in-memory migrated entities are cleared; service reports `StorageState.ioError`
  and throws `StorageMigrationPersistenceException`.
- No-fake-feature/product-honesty check: migration cannot report loaded success
  unless the durable version stamp is persisted.

## Done Criteria

The slice is done only when:

- the focused storage test passes;
- the `Full` local quality gate passes in the integration checkout;
- `git diff --check` passes;
- docs are updated with the current slice status and next queue;
- no unrelated dirty files are staged.

## Result

- Commit: current commit
- Verification summary: focused storage test passed; docs truth test,
  `git diff --check`, and the `Full` local quality gate passed.
- Evidence path: test output only; no screenshot evidence required.
- Follow-up created: next data-resilience candidates are bulk tank delete retry
  feedback and Backup & Restore import-flow executable coverage; next higher
  queue item after data resilience is integration-smoke truthfulness.
