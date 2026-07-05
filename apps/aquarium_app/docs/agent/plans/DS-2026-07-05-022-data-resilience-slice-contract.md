# DS-2026-07-05-022 Data Resilience Slice Contract

## Slice

- ID: DS-2026-07-05-022
- Title: Bulk livestock move must reject missing target tanks before saving.
- Branch/worktree: `ds-2026-07-05-022-bulk-move-target-guard` in the main repo worktree.
- Coordinator: Codex current session.
- Worker agents, if any: None.
- Owned files/modules: `lib/providers/tank_provider.dart`, `test/providers/tank_provider_test.dart`, `docs/agent/ACTIVE_HANDOFF.md`, `docs/agent/SLICE_LOG.md`, this contract.
- Files/modules explicitly out of scope: UI redesign, Android screenshots/live preview, optional cloud/account backup paths, broad restore/migration refactors.

## Product Goal

- User-visible outcome: A stale bulk livestock move cannot create local livestock under a tank that has already been deleted.
- Complete-local requirement this advances: local data safety and no orphan child records.
- Finish Map row(s): Data resilience.
- Product backlog row(s): CL-P1-009 / CL-QA-006 remaining create/edit/delete coverage.

## Research And Planning

- Fresh session recommended: No. This is one narrow provider-level slice from a clean, aligned source branch.
- Repo context checked: `AGENTS.md`, `README.md`, `GIT_WORKFLOW.md`, `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`, `QUALITY_LADDER.md`, `TESTING_CHECKLIST.md`, `SLICE_LOG.md`, current product audit/backlog references, device/live-preview docs, and relevant provider/tests/source.
- Current best-practice sources checked: Repo-owned source and test patterns only; no new framework or platform API decision.
- Tool/plugin/MCP/account-backed lane considered: Not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: `TankActions.bulkMoveLivestock` currently saves moved livestock to the selected target tank id without rechecking that the target tank still exists in durable storage.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: Not required; provider-level data-safety behavior.
- Phone expectation: No visual change.
- Tablet expectation: No visual change.
- Accessibility expectation: No visual change.
- Visual evidence required: No.

## Tests And Gates

- Focused test(s): Add a RED provider test in `test/providers/tank_provider_test.dart` for a stale bulk-move target tank.
- Required local gate: `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`.
- Android evidence required: No. Live preview skipped because this is non-visual provider data-safety work and `danio_api36` is not currently the running AVD.
- External review/tool lane: None.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: Tank and livestock records through `StorageService`.
- Failure states to test: Target tank deleted after selection but before bulk move save.
- Rollback or retry behavior: Throw before any livestock move is saved; existing source livestock remains unchanged.
- No-fake-feature/product-honesty check: No new feature claims or provider-backed behavior.

## Done Criteria

The slice is done only when:

- focused RED then GREEN evidence exists;
- full provider test file passes;
- targeted analyzer passes;
- required Full local gate passes;
- `git diff --check` passes;
- docs/logs are updated for handoff and slice history;
- no unrelated dirty files are staged.

## Result

- Commit: Current commit after closeout.
- Verification summary: RED focused provider regression failed because the
  stale target move completed; GREEN passed after `bulkMoveLivestock` rechecked
  the target tank before any move writes. The full provider test file, targeted
  analyzer, and required Full local quality gate passed. Post-doc `git diff
  --check` and docs local-truth test are part of closeout.
- Evidence path: Not applicable.
- Follow-up created: Continue broader data-resilience restore, migration,
  create/delete, and future debounced-writer app-kill coverage.
