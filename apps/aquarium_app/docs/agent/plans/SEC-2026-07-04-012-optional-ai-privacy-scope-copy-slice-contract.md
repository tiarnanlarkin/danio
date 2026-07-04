# SEC-2026-07-04-012 Optional AI privacy scope copy slice contract

## Slice

- ID: SEC-2026-07-04-012
- Title: Make Optional AI privacy scope copy complete
- Branch/worktree: `qa/production-tool-audit-2026-05-25`
- Coordinator: Codex in the integration checkout
- Worker agents, if any: none
- Owned files/modules: `lib/screens/privacy_policy_screen.dart`,
  `test/widget_tests/privacy_policy_screen_test.dart`, and relevant
  agent/product status docs
- Files/modules explicitly out of scope: AI provider implementation, OpenAI key
  storage behavior, disclosure gate behavior, cloud account setup, online
  hosted privacy-policy publishing, Android device evidence

## Product Goal

- User-visible outcome: the in-app Privacy Policy no longer describes Optional
  AI as Fish ID/photo-only when current Optional AI features can also send
  symptom descriptions, stocking or compatibility requests, and weekly-plan
  tank context after disclosure.
- Complete-local requirement this advances: no fake, stale, or incomplete
  privacy/security copy for local-first plus optional AI behavior.
- Finish Map row(s): Product honesty; Preferences; Optional AI providers.
- Product backlog row(s): CL-P0-003 Feature honesty; CL-P1-010
  Profile/preferences; CL-P3-001 Providers.

## Research And Planning

- Fresh session recommended: No. This is a narrow copy/test/doc slice after a
  clean current-session handoff.
- Repo context checked: `AGENTS.md`, `CODEX_SETUP.md`, `WORKFLOW_CHARTER.md`,
  `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`, `QUALITY_LADDER.md`, `SLICE_LOG.md`,
  current audit, backlog, Privacy Policy screen, Optional AI disclosure gate,
  Settings Optional AI copy, and nearby tests.
- Current best-practice sources checked:
  - OpenAI Platform data controls, checked 2026-07-04:
    https://developers.openai.com/api/docs/guides/your-data
  - OpenAI enterprise privacy, checked 2026-07-04:
    https://openai.com/enterprise-privacy/
- Tool/plugin/MCP/account-backed lane considered: No account-backed lane needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: OpenAI's current API docs describe API
  abuse-monitoring logs retained for up to 30 days by default unless longer
  retention is required, and OpenAI states API data is not used for training by
  default unless the API account explicitly opts in. The policy copy should
  avoid promising only image retention when current Optional AI request surfaces
  also send text and tank context.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: existing Privacy Policy
  screen and Preferences Optional AI privacy route.
- Phone expectation: policy copy remains plain and readable in the existing
  legal content layout.
- Tablet expectation: existing centered policy rail remains unchanged.
- Accessibility expectation: headings and bullet text remain plain text.
- Visual evidence required: none; copy/source-contract slice only.

## Tests And Gates

- Focused test(s): `flutter test test/widget_tests/privacy_policy_screen_test.dart --reporter compact`
- Required local gate: `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused`
- Android evidence required: No.
- External review/tool lane: No.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: none; copy only.
- Failure states to test: policy must not retain the stale Fish-ID-only AI
  processing/legal-basis wording, and must name current Optional AI request
  scope plus OpenAI API retention/training boundaries.
- Rollback or retry behavior: unchanged.
- No-fake-feature/product-honesty check: policy copy matches current request
  surfaces without enabling unsupported non-OpenAI providers.

## Done Criteria

The slice is done only when:

- focused tests pass;
- required local gate passes in the integration checkout;
- `git diff --check` passes;
- docs are updated for product truth and handoff recovery;
- no unrelated dirty files are staged.

## Result

- Commit: Current commit
- Verification summary: RED/GREEN Privacy Policy widget/source test, targeted
  analysis, Focused gate, docs truth test, smart AI copy contract test,
  whitespace check, and stale Fish-ID-only source/status-doc scan passed.
- Evidence path: Not applicable.
- Follow-up created: Continue data-resilience or AI confirmation slices per
  `FINISH_MAP.md` priority.
