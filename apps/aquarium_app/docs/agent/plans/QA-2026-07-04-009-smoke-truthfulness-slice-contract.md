# Danio Slice Contract: QA-2026-07-04-009

## Slice

- ID: `QA-2026-07-04-009`
- Title: Integration smoke tab flows must fail if main tabs are not exercised
- Branch/worktree: `qa/production-tool-audit-2026-05-25` integration checkout
- Coordinator: current Codex coordinator
- Worker agents, if any: none
- Owned files/modules:
  - `integration_test/smoke_test.dart`
  - `integration_test/smoke_test_v2.dart`
  - `integration_test/smoke_test_harness.dart`
  - `test/integration_smoke_contract_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/SLICE_LOG.md`
  - `docs/agent/plans/QA-2026-07-04-009-smoke-truthfulness-slice-contract.md`
- Files/modules explicitly out of scope: app UI/product behavior, Android
  screenshot evidence, Patrol device execution, black-box PowerShell smoke
  route expansion, security/product-honesty slices, and data-resilience code.

## Product Goal

- User-visible outcome: no direct app UI change; Danio's smoke verification is
  more truthful before release signoff.
- Complete-local requirement this advances: Android QA and rule/test
  reliability for main-tab flows.
- Finish Map row(s): Whole-app phone audit; Whole-app tablet audit; Rule tests.
- Product backlog row(s): `CL-QA-001`, `CL-QA-002`, `CL-QA-004`.

## Research And Planning

- Fresh session recommended: No; current session is fresh enough, the repo is
  clean, and the slice is bounded to smoke-harness files.
- Repo context checked: `AGENTS.md`, `CODEX_SETUP.md`, `ACTIVE_HANDOFF.md`,
  `FINISH_MAP.md`, `AUTONOMOUS_QUALITY_SETUP.md`, `TESTING_CHECKLIST.md`,
  `MULTI_AGENT_WORKFLOW.md`, `SLICE_LOG.md`, product backlog/current audit, and
  current smoke tests/scripts.
- Current best-practice sources checked: not needed; this is a repo-local
  harness truthfulness fix using existing Flutter/Patrol smoke conventions.
- Tool/plugin/MCP/account-backed lane considered: none.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: the PowerShell black-box smoke already
  asserts selected main tabs, but both Flutter integration smoke files can pass
  tab-flow tests when the bottom dock is absent by treating onboarding as a
  no-crash pass. The fix should make the named tab-flow tests fail unless the
  main tab shell is present and every tab is tapped.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: existing main tab shell
  selectors under `integration_test/smoke_test_harness.dart`.
- Phone expectation: no layout change.
- Tablet expectation: no layout change.
- Accessibility expectation: no semantics change.
- Visual evidence required: none; executable QA-harness slice.

## Tests And Gates

- Focused test(s):
  - `flutter test test/integration_smoke_contract_test.dart --reporter compact`
  - `flutter test test/scripts/android_blackbox_smoke_script_test.dart --reporter compact`
- Required local gate:
  - `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused`
- Android evidence required: none; no device ownership for this harness-only
  slice.
- External review/tool lane: none.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: none.
- Failure states to test: integration smoke source must not contain an
  onboarding/no-crash fallback for named main-tab tests, and it must require
  all configured smoke tab IDs.
- Rollback or retry behavior: not applicable.
- No-fake-feature/product-honesty check: tab smoke cannot report tab-flow
  coverage when the tabs were not available or tapped.

## Done Criteria

The slice is done only when:

- the focused smoke contract test fails before the harness change;
- the focused smoke contract test passes after the harness change;
- related smoke script/source tests pass;
- the `Focused` local quality gate passes;
- `git diff --check` passes;
- docs are updated with the slice result and next queue;
- no unrelated dirty files are staged.

## Result

- Commit: Current commit after this slice is committed.
- Verification summary: RED `flutter test test/integration_smoke_contract_test.dart --reporter compact`
  failed because Patrol smoke could still pass a named tab-flow test through an
  onboarding/no-crash skip path; GREEN same command passed after both smoke
  files required main tab shell coverage. The adjacent smoke source tests,
  targeted analysis, `git diff --check`, and `Focused` local quality gate
  passed.
- Evidence path: test output only; no screenshot evidence required.
- Follow-up created: Continue security/product-honesty slices for AI proxy,
  direct OpenAI release policy, cloud backup encryption copy, privacy copy, and
  AI disclosure scope unless a higher-priority data-safety gap is found.
