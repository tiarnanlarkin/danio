# SEC-2026-07-04-011 Cloud Backup Keying Copy slice contract

## Slice

- ID: SEC-2026-07-04-011
- Title: Make cloud backup keying copy honest
- Branch/worktree: `qa/production-tool-audit-2026-05-25`
- Coordinator: Codex in the integration checkout
- Worker agents, if any: none
- Owned files/modules: `lib/screens/account_screen.dart`,
  `lib/services/cloud_backup_service.dart`,
  `test/widget_tests/account_screen_test.dart`,
  `test/services/cloud_backup_service_test.dart`, and relevant agent/product
  status docs
- Files/modules explicitly out of scope: cloud account setup, Supabase
  configuration, backup cryptography redesign, privacy-policy rewrite, Optional
  AI disclosure copy, Android device evidence

## Product Goal

- User-visible outcome: signed-in Account backup actions stop telling users
  they are creating or restoring an "encrypted cloud backup" when the current
  implementation is account-keyed rather than user-held or end-to-end.
- Complete-local requirement this advances: no fake, overstated, or
  misleading cloud/security promises.
- Finish Map row(s): Backup and restore; Product honesty.
- Product backlog row(s): CL-P0-003 Feature honesty; CL-P1-009 Backup/data.

## Research And Planning

- Fresh session recommended: No. This is a narrow copy/source-contract slice
  after a clean fresh-session handoff.
- Repo context checked: `AGENTS.md`, `CODEX_SETUP.md`, `FINISH_MAP.md`,
  `ACTIVE_HANDOFF.md`, `SLICE_LOG.md`, current audit, backlog, account screen,
  cloud backup service, and nearby tests.
- Current best-practice sources checked:
  - OWASP MASVS, current official page:
    https://mas.owasp.org/MASVS/
  - OWASP MASVS-STORAGE, current official page:
    https://mas.owasp.org/MASVS/05-MASVS-STORAGE/
  - OWASP MASTG cryptographic key storage guidance, current official page:
    https://mas.owasp.org/MASTG/knowledge/android/MASVS-STORAGE/MASTG-KNOW-0047/
- Tool/plugin/MCP/account-backed lane considered: No account-backed lane needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: OWASP treats sensitive storage and
  cryptographic key handling as explicit mobile security concerns. Danio's
  current cloud backup key is derived deterministically from the signed-in
  account id and app salt, so user-facing copy should avoid stronger
  user-held/end-to-end encryption claims until the product has a real recovery
  key or equivalent design.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: existing Account signed-in
  backup list tiles and snackbar copy.
- Phone expectation: wording remains short enough for the existing Account card.
- Tablet expectation: no layout change; existing readable Account width remains.
- Accessibility expectation: labels stay plain and do not rely on hidden
  security assumptions.
- Visual evidence required: none; copy/source contract slice only.

## Tests And Gates

- Focused test(s): `flutter test test/widget_tests/account_screen_test.dart
  test/services/cloud_backup_service_test.dart --reporter compact`
- Required local gate: `.\scripts\quality_gates\run_local_quality_gate.ps1
  -Profile Focused`
- Android evidence required: No.
- External review/tool lane: No.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: none; copy/comments only.
- Failure states to test: stale Account copy must not claim encrypted cloud
  backup; service source must name the account-keyed, non-end-to-end boundary.
- Rollback or retry behavior: unchanged.
- No-fake-feature/product-honesty check: Account no longer promises a stronger
  encryption model than the current backup keying supports.

## Done Criteria

The slice is done only when:

- focused tests pass;
- required local gate passes in the integration checkout;
- `git diff --check` passes;
- docs are updated for product truth and handoff recovery;
- no unrelated dirty files are staged.

## Result

- Commit: Current commit
- Verification summary: RED/GREEN focused copy/source tests, targeted analysis,
  Focused gate, docs truth test, and whitespace check passed.
- Evidence path: Not applicable.
- Follow-up created: Continue privacy copy and AI disclosure scope slices unless
  a higher-priority data-safety gap is found.
