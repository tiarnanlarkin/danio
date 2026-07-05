# DS-2026-07-05-028 Local Font Runtime Stabilization

## Slice

- ID: DS-2026-07-05-028
- Title: Stabilize local font tests and remove `google_fonts`
- Branch/worktree: `ds-2026-07-05-028-local-fonts` in the main repo worktree
- Coordinator: current Codex session
- Worker agents, if any: none
- Owned files/modules: `lib/theme/app_typography.dart`, `lib/theme/app_theme.dart`, `lib/main.dart`, `pubspec.yaml`, `pubspec.lock`, `test/theme/app_theme_test.dart`, active handoff/log docs
- Files/modules explicitly out of scope: visual redesign, typography scale changes, Android install/reload, data-resilience behavior, optional AI/cloud/account-backed work

## Product Goal

- User-visible outcome: Danio keeps the same bundled Nunito/Fredoka typography while tests and local builds no longer depend on the `google_fonts` runtime loader.
- Complete-local requirement this advances: local-first/no-network quality and faster, more stable local gates.
- Finish Map row(s): Visual regression / local quality infrastructure; Data resilience remains the ranked fallback lane only.
- Product backlog row(s): no completion-status row should advance unless verification reveals a broader product-truth change.

## Research And Planning

- Fresh session recommended: No. This is one narrow dependency/test-infra slice from a clean branch.
- Repo context checked: `AGENTS.md`, root `README.md`, `GIT_WORKFLOW.md`, app `README.md`, `ACTIVE_HANDOFF.md`, `FINISH_MAP.md`, `QUALITY_LADDER.md`, `TESTING_CHECKLIST.md`, `SLICE_LOG.md`, device/live-preview docs, current git state.
- Current best-practice sources checked: `google_fonts` package docs, Flutter AssetManifest breaking-change docs, Flutter custom-font cookbook.
- Tool/plugin/MCP/account-backed lane considered: none needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: Danio declares Nunito and Fredoka under `flutter.fonts`, while `google_fonts` bundled-file auto-loading expects matching files listed as `assets`; Flutter supports direct `TextStyle(fontFamily: ...)` for fonts declared under `flutter.fonts`.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: existing theme/golden tests and bundled font declarations are the target.
- Phone expectation: no intended visible typography change.
- Tablet expectation: no intended visible typography change.
- Accessibility expectation: no copy, scale, semantics, or contrast changes.
- Visual evidence required: focused golden checks named in the handoff; no Android screenshot required unless a visual/golden diff appears.

## Tests And Gates

- Focused test(s): add/update `test/theme/app_theme_test.dart` to assert representative Nunito/Fredoka font families and guard against `GoogleFonts` imports/calls in `lib/theme/app_typography.dart`, `lib/theme/app_theme.dart`, and `lib/main.dart`.
- Required local gate: user-requested focused tests, targeted analyze, `dart run dependency_validator`, `git diff --check`, and `./scripts/quality_gates/run_local_quality_gate.ps1 -Profile Full -RequireCleanWorktree`.
- Android evidence required: no install/tap/screenshot planned; CheckOnly preflight only unless a gate reveals runtime-only risk.
- External review/tool lane: none.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: none.
- Failure states to test: source guard fails while `GoogleFonts` imports/calls remain; font-family assertions fail if theme or typography stops using bundled font names directly.
- Rollback or retry behavior: normal git branch rollback; `flutter pub get` updates only dependency lockfiles.
- No-fake-feature/product-honesty check: no cloud, paid, optional AI, or fake provider behavior involved.

## Done Criteria

The slice is done only when:

- the font guard fails before production changes for the expected `GoogleFonts` reason;
- the guard and requested focused tests pass after implementation;
- `flutter pub get` removes the `google_fonts` dependency path;
- targeted analyze, dependency validator, golden checks, `git diff --check`, and Full quality gate pass;
- active handoff and slice log are updated;
- the branch is committed, merged to `main`, pushed, cleaned up, and `main...origin/main` is `0 0`.

## Result

- Commit:
- Verification summary: RED theme/source guard failed on current
  `GoogleFonts` usage; GREEN guard passed after direct bundled font families;
  `flutter pub get` removed `google_fonts`; requested widget and golden groups
  passed with bundled test fonts; targeted analyze, dependency validator,
  whitespace, local-gate script guard, and Full quality gate passed.
- Evidence path: local command output only.
- Follow-up created: continue the ranked data-resilience lane after clean
  closeout unless fresh repo evidence shows the returning-user prompt
  context-after-dispose runtime issue outranks it.
