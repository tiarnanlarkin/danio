# Danio Slice Contract: DS-2026-07-04-014

## Slice

- ID: `DS-2026-07-04-014`
- Title: Symptom Triage journal save must not create orphan logs
- Branch/worktree: `qa/production-tool-audit-2026-05-25` integration checkout
- Coordinator: current Codex coordinator
- Worker agents, if any: none
- Owned files/modules:
  - `lib/features/smart/symptom_triage/symptom_triage_screen.dart`
  - `test/widget_tests/symptom_triage_screen_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/FINISH_MAP.md`
  - `docs/agent/SLICE_LOG.md`
  - `docs/agent/plans/DS-2026-07-04-014-data-resilience-slice-contract.md`
  - `docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
  - `docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Files/modules explicitly out of scope: OpenAI request behavior, diagnosis
  generation, Symptom Triage disclosure gating, Ask Danio, Weekly Plan,
  backup/restore, Android devices, screenshots, and broader migration/app-kill
  coverage.

## Product Goal

- User-visible outcome: if the Symptom Triage screen has a stale cached tank
  list after the durable tank was deleted, confirming `Save to Journal` shows
  normal retry feedback and does not create an orphan journal log or local AI
  history entry.
- Complete-local requirement this advances: AI-confirmed local writes must
  still respect durable parent records before saving child data.
- Finish Map row(s): Data resilience; AI confirmation.
- Product backlog row(s): `CL-P1-009`; `CL-QA-006`; `CL-P3-002`.

## Research And Planning

- Fresh session recommended: No; this is a fresh resumed session, the checkout
  is clean and aligned with origin, and the slice is narrow.
- Repo context checked: `AGENTS.md`, `WORKFLOW_CHARTER.md`,
  `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`, `CODEX_SETUP.md`,
  `TESTING_CHECKLIST.md`, `QUALITY_LADDER.md`,
  `AUTONOMOUS_QUALITY_SETUP.md`, `MULTI_AGENT_WORKFLOW.md`, `SLICE_LOG.md`,
  product backlog/current audit, Symptom Triage source/tests, and recent
  parent-tank guard patterns.
- Current best-practice sources checked: not needed; this is a repo-local
  storage-boundary fix following existing missing-parent checks.
- Tool/plugin/MCP/account-backed lane considered: not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: Symptom Triage already asks for
  confirmation before saving the AI diagnosis, but the confirmed journal save
  selected a tank from the cached provider and wrote the log without rechecking
  that the tank still existed in durable storage.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: existing Symptom Triage
  save-confirmation dialog and retry snackbar path.
- Phone expectation: no layout change.
- Tablet expectation: no layout change.
- Accessibility expectation: existing dialog/snackbar semantics unchanged.
- Visual evidence required: none; non-visual data-safety slice.

## Tests And Gates

- Focused test(s):
  - `flutter test test/widget_tests/symptom_triage_screen_test.dart --name "stale tanks do not create orphan symptom triage journal logs" --reporter compact`
  - `flutter test test/widget_tests/symptom_triage_screen_test.dart --reporter compact`
- Required local gate:
  - `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full`
- Android evidence required: none; no device ownership or visual behavior.
- External review/tool lane: none.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: Symptom Triage observation `LogEntry` saves and
  `ai_interaction_history` writes after confirmed journal saves.
- Failure states to test: the tanks provider still exposes a stale tank, but
  `storage.getTank(tankId)` returns `null` before the journal log save.
- Rollback or retry behavior: no journal log is saved, AI history is not
  recorded, the screen remains open, and existing retry feedback is shown.
- No-fake-feature/product-honesty check: Symptom Triage cannot report a saved
  AI diagnosis when no durable parent tank exists.

## Done Criteria

The slice is done only when:

- the focused stale-tank Symptom Triage journal-save test fails before the
  production change;
- the named test and full Symptom Triage widget test file pass after the
  change;
- targeted analysis passes;
- `Full` local quality gate passes in the integration checkout;
- post-doc `git diff --check` and docs truth test pass;
- docs are updated with the current slice result and next queue;
- no unrelated dirty files are staged.

## Result

- Commit: Current commit after this slice is committed.
- Verification summary: RED named widget test failed because an orphan
  `LogEntry` was saved after the durable tank disappeared; GREEN named and full
  Symptom Triage widget tests passed; targeted analysis passed; `Full` local
  quality gate passed including full tests, analyzer, and debug APK build;
  post-doc `git diff --check` and current-docs truth test passed.
- Evidence path: test output only; no screenshot evidence required.
- Follow-up created: Continue broader data-resilience create/edit/delete,
  restore, migration, and future debounced-writer app-kill coverage before
  lower-priority polish.
