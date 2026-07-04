# Danio Slice Contract: DS-2026-07-04-010

## Slice

- ID: `DS-2026-07-04-010`
- Title: Bulk tank delete failures must surface retry feedback
- Branch/worktree: `qa/production-tool-audit-2026-05-25` integration checkout
- Coordinator: current Codex coordinator
- Worker agents, if any: none
- Owned files/modules:
  - `lib/providers/tank_provider.dart`
  - `test/providers/tank_provider_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/FINISH_MAP.md`
  - `docs/agent/SLICE_LOG.md`
  - `docs/agent/plans/2026-07-04-complete-local-delivery.md`
  - `docs/agent/plans/DS-2026-07-04-010-data-resilience-slice-contract.md`
  - `docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
  - `docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Files/modules explicitly out of scope: backup import transaction coverage,
  AI/security slices, smoke tests, visual surfaces, Android devices, and release
  artifacts

## Product Goal

- User-visible outcome: if a bulk tank delete expires and the durable local
  delete write fails, Danio restores the tank and shows normal retry feedback
  instead of only logging the failure.
- Complete-local requirement this advances: local data resilience and no false
  success states.
- Finish Map row(s): Data resilience.
- Product backlog row(s): `CL-P1-009`, `CL-QA-006`.

## Research And Planning

- Fresh session recommended: No; this fresh resume is clean, aligned with
  upstream, and the slice is narrow.
- Repo context checked: `AGENTS.md`, `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`,
  `CODEX_SETUP.md`, `AUTONOMOUS_QUALITY_SETUP.md`, `TESTING_CHECKLIST.md`,
  `MULTI_AGENT_WORKFLOW.md`, `QUALITY_LADDER.md`, `WORKFLOW_CHARTER.md`,
  `RESEARCH_PROTOCOL.md`, `SLICE_LOG.md`, local data-resilience backlog, and
  relevant provider/tests.
- Current best-practice sources checked: not needed; this is a repo-local
  failure-path consistency fix using existing provider feedback patterns.
- Tool/plugin/MCP/account-backed lane considered: not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: single-tank soft delete already emits
  `tankDeleteFailureFeedbackProvider` on permanent delete failure, while bulk
  soft delete restores visibility but only logs the failure.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: existing snackbar feedback
  listener and single-tank delete failure behavior.
- Phone expectation: no layout change; failed bulk delete uses existing retry
  snackbar.
- Tablet expectation: same as phone.
- Accessibility expectation: existing snackbar semantics unchanged.
- Visual evidence required: none; no visual layout change.

## Tests And Gates

- Focused test(s):
  - `flutter test test/providers/tank_provider_test.dart --name "failed permanent bulk soft delete restores tank visibility" --reporter compact`
  - `flutter test test/providers/tank_provider_test.dart --reporter compact`
- Required local gate:
  - `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
- Android evidence required: none; no device ownership.
- External review/tool lane: none.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: tank permanent delete failure handling through
  `TankActions.bulkDeleteTanks`.
- Failure states to test: one selected tank's durable delete write throws after
  the undo window expires.
- Rollback or retry behavior: the tank becomes visible again because the
  soft-delete state settles, and a retryable user-facing error is published.
- No-fake-feature/product-honesty check: failed durable delete writes cannot
  look like silent success.

## Done Criteria

The slice is done only when:

- the focused provider test fails before the production change;
- the focused provider tests pass after the production change;
- the `Full` local quality gate passes in the integration checkout;
- `git diff --check` passes;
- docs are updated with the current slice status and next queue;
- no unrelated dirty files are staged.

## Result

- Commit: current commit
- Verification summary: RED named provider test failed before the production
  change because the feedback provider stayed null; GREEN named provider test
  passed; full provider test file passed; `Full` local quality gate passed;
  post-doc `git diff --check` and docs truth test passed.
- Evidence path: test output only; no screenshot evidence required.
- Follow-up created: Backup & Restore import-flow executable coverage remains
  the next data-resilience candidate, then integration-smoke truthfulness.
