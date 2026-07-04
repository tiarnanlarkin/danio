# AI-2026-07-04-011 Ask Danio disclosure gate slice contract

## Slice

- ID: AI-2026-07-04-011
- Title: Gate Ask Danio typed questions behind Optional AI disclosure
- Branch/worktree: `qa/production-tool-audit-2026-05-25`
- Coordinator: Codex in the integration checkout
- Worker agents, if any: none
- Owned files/modules: `lib/screens/smart_screen.dart`,
  `test/widget_tests/smart_ai_setup_copy_contract_test.dart`, and relevant
  agent/product status docs
- Files/modules explicitly out of scope: new AI providers, API-key storage,
  proxy configuration, prompt design expansion, Android device evidence

## Product Goal

- User-visible outcome: Ask Danio now asks for the shared Optional AI data
  disclosure before sending typed aquarium questions to OpenAI.
- Complete-local requirement this advances: Optional AI text requests must not
  bypass the disclosure gate or contradict the Privacy Policy request-scope
  copy.
- Finish Map row(s): Data resilience; Optional AI providers.
- Product backlog row(s): CL-P1-009 Backup/data; CL-P3-001 Providers.

## Research And Planning

- Fresh session recommended: No. This is a narrow behavior/source-contract fix
  after a clean handoff.
- Repo context checked: `AGENTS.md`, `CODEX_SETUP.md`, `ACTIVE_HANDOFF.md`,
  `FINISH_MAP.md`, `TESTING_CHECKLIST.md`, `SLICE_LOG.md`, current audit,
  backlog, Smart screen, shared OpenAI disclosure gate, and nearby AI tests.
- Current best-practice sources checked: repo source of truth only. The slice
  applies the already-reviewed disclosure gate to a missing current request
  surface rather than changing provider, privacy, or API policy.
- Tool/plugin/MCP/account-backed lane considered: No account-backed lane needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: the Smart screen's Ask Danio path called
  `openai.chatCompletion` for typed questions without
  `ensureOpenAIDisclosureAccepted`, while the existing disclosure contract did
  not include `lib/screens/smart_screen.dart`.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: existing Ask Danio card and
  shared OpenAI disclosure dialog.
- Phone expectation: unchanged layout; the existing modal disclosure appears
  before the request.
- Tablet expectation: unchanged layout.
- Accessibility expectation: existing dialog semantics remain unchanged.
- Visual evidence required: none; behavior/source-contract slice only.

## Tests And Gates

- Focused test(s):
  `flutter test test/widget_tests/smart_ai_setup_copy_contract_test.dart --reporter compact`
- Required local gate: `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused`
- Android evidence required: No.
- External review/tool lane: No.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: `openai_disclosure_accepted` may be written only after
  user acceptance; `ai_interaction_history` remains written only after a
  successful Ask Danio response.
- Failure states to test: source contract must fail if any current OpenAI
  request surface omits the shared disclosure gate.
- Rollback or retry behavior: disclosure-save failures keep the request stopped
  and show retryable Ask Danio feedback through the shared gate.
- No-fake-feature/product-honesty check: Ask Danio remains optional AI and does
  not claim non-OpenAI provider support.

## Done Criteria

The slice is done only when:

- focused tests pass;
- required local gate passes in the integration checkout;
- `git diff --check` passes;
- docs are updated for product truth and handoff recovery;
- no unrelated dirty files are staged.

## Result

- Commit: Current commit
- Verification summary: RED/GREEN smart AI setup copy contract test, targeted
  Smart screen analysis, whitespace check, and Focused local quality gate
  passed.
- Evidence path: Not applicable.
- Follow-up created: Continue data-resilience or AI confirmation slices per
  `FINISH_MAP.md` priority.
