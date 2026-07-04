# AI-2026-07-04-010 OpenAI release key policy slice contract

## Slice

- ID: `AI-2026-07-04-010`
- Title: Enforce direct OpenAI build-time key release policy
- Branch/worktree: `qa/production-tool-audit-2026-05-25`
- Coordinator: Codex
- Worker agents, if any: none
- Owned files/modules:
  - `lib/services/ai_proxy_service.dart`
  - `lib/services/openai_service.dart`
  - `test/services/ai_proxy_service_test.dart`
  - `test/services/openai_service_test.dart`
  - `docs/agent/ACTIVE_HANDOFF.md`
  - `docs/agent/FINISH_MAP.md`
  - `docs/agent/SLICE_LOG.md`
  - `docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
  - `docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Files/modules explicitly out of scope: non-OpenAI provider connectors,
  Supabase/cloud setup, paid/account-backed tooling, UI redesign, emulator or
  screenshot evidence.

## Product Goal

- User-visible outcome: release builds cannot silently treat an app-owned
  build-time `OPENAI_API_KEY` as a valid Optional AI configuration. Local Smart
  Hub remains useful without AI, and user-supplied BYO OpenAI keys still work.
- Complete-local requirement this advances: Optional AI must be transparent,
  provider-aware, and safe by default.
- Finish Map row(s): Optional AI providers; Preferences; Data resilience.
- Product backlog row(s): `CL-P3-001`; `CL-P1-010`; `CL-P1-009`.

## Research And Planning

- Fresh session recommended: No; this is a narrow service/test/docs slice after
  a clean handoff and clean branch/remote preflight.
- Repo context checked: `AGENTS.md`, `ACTIVE_HANDOFF.md`, `SLICE_LOG.md`,
  `CODEX_SETUP.md`, `FINISH_MAP.md`, `AUTONOMOUS_QUALITY_SETUP.md`,
  `TESTING_CHECKLIST.md`, `MULTI_AGENT_WORKFLOW.md`, current audit/backlog AI
  and data-resilience rows, and the relevant OpenAI/proxy/privacy code/tests.
- Current best-practice sources checked:
  - OpenAI Help Center, "Best Practices for API Key Safety", current page
    checked on 2026-07-04.
- Tool/plugin/MCP/account-backed lane considered: no external execution lane
  needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: OpenAI's API key safety guidance says
  deployed client environments such as mobile apps should not expose OpenAI API
  keys; app-owned production keys should be kept behind a backend. Danio will
  preserve BYO local key support, but a build-time direct OpenAI key is dev-only
  and must not be considered configured in release mode.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: not required.
- Phone expectation: no UI layout change.
- Tablet expectation: no UI layout change.
- Accessibility expectation: no UI text/control change expected.
- Visual evidence required: none.

## Tests And Gates

- Focused test(s):
  - `flutter test test/services/ai_proxy_service_test.dart --reporter compact`
  - `flutter test test/services/openai_service_test.dart --reporter compact`
- Required local gate: `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused`
- Android evidence required: No; service/test/docs slice only.
- External review/tool lane: none.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: Optional AI key status logic only; stored BYO key format
  is unchanged.
- Failure states to test: release builds ignore build-time direct OpenAI keys;
  release builds still accept user-supplied BYO keys; proxy mode still wins over
  direct fallback.
- Rollback or retry behavior: existing Optional AI key save/remove retry
  behavior is unchanged.
- No-fake-feature/product-honesty check: no new provider path is enabled; no
  cloud/proxy service is configured.

## Done Criteria

The slice is done only when:

- focused tests pass;
- required local gate passes in the integration checkout;
- `git diff --check` passes;
- docs are updated with the release-key boundary;
- no unrelated dirty files are staged.

## Result

- Commit: Current commit
- Verification summary:
  - RED:
    `flutter test test/services/ai_proxy_service_test.dart test/services/openai_service_test.dart --reporter compact`
    failed before the service change because the release-key policy guard and
    OpenAIService centralisation were missing.
  - GREEN:
    `flutter test test/services/ai_proxy_service_test.dart test/services/openai_service_test.dart --reporter compact`
    passed.
  - Targeted analysis:
    `flutter analyze lib/services/ai_proxy_service.dart lib/services/openai_service.dart test/services/ai_proxy_service_test.dart test/services/openai_service_test.dart`
    passed.
  - Local quality gate:
    `.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused`
    passed.
- Evidence path: none required.
- Follow-up created: continue cloud backup encryption copy, privacy copy, and
  AI disclosure scope security/product-honesty slices.
