# AI-2026-07-04-012 Ask Danio history confirmation slice contract

## Slice

- ID: AI-2026-07-04-012
- Title: Confirm Ask Danio activity before saving local AI history
- Branch/worktree: `qa/production-tool-audit-2026-05-25`
- Coordinator: Codex in the integration checkout
- Worker agents, if any: none
- Owned files/modules: `lib/screens/smart_screen.dart`,
  `test/widget_tests/smart_screen_test.dart`, and relevant agent/product status
  docs
- Files/modules explicitly out of scope: new AI providers, prompt expansion,
  tank/task/reminder AI apply flows, Android screenshot evidence

## Product Goal

- User-visible outcome: Ask Danio still shows the AI answer immediately, but
  saving the question summary into Recent AI Activity now requires explicit
  confirmation.
- Complete-local requirement this advances: Optional AI output must not become
  saved local app data without confirmation.
- Finish Map row(s): AI confirmation; Optional AI providers.
- Product backlog row(s): CL-P3-002 Confirm writes; CL-P1-009 local data
  resilience.

## Research And Planning

- Fresh session recommended: No. This is a narrow continuation after a clean
  checkpoint and current handoff.
- Repo context checked: `AGENTS.md`, `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`,
  `SLICE_LOG.md`, current audit, backlog, Smart screen, Smart providers, and
  nearby Symptom Triage/Weekly Plan confirmation tests.
- Current best-practice sources checked: repo source of truth only. The slice
  applies the existing confirmation pattern to a missing current Ask Danio
  local-history write.
- Tool/plugin/MCP/account-backed lane considered: No account-backed lane needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: Ask Danio already used the shared OpenAI
  disclosure gate before requests, but still wrote `ai_interaction_history`
  immediately after a response. Symptom Triage and Weekly Plan already had
  confirmation coverage for saved AI data.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: existing Ask Danio card
  and shared confirmation dialog pattern.
- Phone expectation: unchanged layout; the existing confirmation dialog appears
  after the answer when local activity can be saved.
- Tablet expectation: unchanged layout.
- Accessibility expectation: existing dialog semantics remain unchanged.
- Visual evidence required: none; behavior/source-contract slice only.

## Tests And Gates

- Focused test(s):
  `flutter test test/widget_tests/smart_screen_test.dart --name "Ask Danio activity" --reporter compact`
- Required local gate: `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused`
- Android evidence required: No.
- External review/tool lane: No.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: `ai_interaction_history` is written only when the user
  confirms saving Ask Danio activity. The OpenAI request/disclosure behavior and
  API rate-limit storage are unchanged.
- Failure states to test: canceling the save confirmation must leave
  `ai_interaction_history` empty; confirming must write one `ask_danio` entry.
- Rollback or retry behavior: if local history save fails after confirmation,
  the answer remains visible and the failure is logged, matching the existing
  non-critical AI-history behavior.
- No-fake-feature/product-honesty check: Ask Danio remains optional OpenAI and
  does not claim new provider support.

## Done Criteria

The slice is done only when:

- focused tests pass;
- required local gate passes in the integration checkout;
- `git diff --check` passes;
- docs are updated for product truth and handoff recovery;
- no unrelated dirty files are staged.

## Result

- Commit: Current commit
- Verification summary: RED/GREEN Ask Danio activity confirmation tests, full
  `smart_screen_test.dart`, targeted Smart screen analysis, whitespace check,
  docs truth test, Focused local quality gate, and debug APK build passed.
- Evidence path: Not applicable.
- Follow-up created: Continue data-resilience or AI confirmation slices per
  `FINISH_MAP.md` priority.
