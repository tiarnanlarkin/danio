# WF-2026-07-11-017 Claim Readiness JSON Transport Repair

## Slice

- ID: `WF-2026-07-11-017`
- Title: Preserve synchronization receipt JSON across the writer-claim child-process boundary
- Branch/worktree: `fix/wf-2026-07-11-017-claim-readiness-json` in the canonical checkout
- Coordinator: current saved-project `/launch/0` task
- Worker agents, if any: repository-read-only review only
- Owned files/modules: writer-claim invoker, autonomous script contract test, this contract, `ACTIVE_HANDOFF.md`, and `SLICE_LOG.md`
- Files/modules explicitly out of scope: product Dart behavior, live run state, budget accounting, installed skills, Android/runtime state, Figma, external services, and successor creation

## Product Goal

- User-visible outcome: none; this removes the fail-closed workflow blocker that prevents the authorized phone-completion writer claim.
- Complete-local requirement this advances: enables the already-authorized read-only `DCL-DR-001` restore-matrix audit to claim its writer safely.
- Finish Map row(s): no status change; `DCL-DR-001` remains open until product evidence closes it.
- Product backlog row(s): no status change.

## Research And Planning

- Fresh session recommended: No; the current task owns the reproduced failure and the user explicitly authorized this narrow repair.
- Repo context checked: installed runners, `AGENTS.md`, clean aligned Git, revision-1 ready state, active handoff, quality ladder, testing checklist, invoker source, claim fixtures, and current task/project binding.
- Current best-practice sources checked: repository-local working encoded-command patterns; no external API or platform decision is involved.
- Tool/plugin/MCP/account-backed lane considered: Not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: production freshness passes raw JSON through `powershell.exe -File`, while working repo helpers preserve JSON as UTF-8 Base64 inside `-EncodedCommand`; injected claim fixtures skip production freshness.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: Not applicable.
- Phone expectation: No app change.
- Tablet expectation: Parked and unchanged.
- Accessibility expectation: No change.
- Visual evidence required: No.

## Tests And Gates

- Focused test(s): autonomous Dart contract test must prove byte-safe receipt transport and reject the raw `-File` readiness call; then run the full autonomous Dart contract file.
- Required local gate: PowerShell parser check; full disposable Git claim fixture suite; Docs profile on the branch; clean-worktree Docs on the committed branch and merged `main`.
- Android evidence required: No.
- External review/tool lane: repository-read-only diff review.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: no app data; workflow source/tests/docs only.
- Failure states to test: synchronization receipt JSON containing quotes reaches readiness without command-line de-quoting.
- Rollback or retry behavior: no claim retry until the repair is committed, pushed, clean, and reverified; the real claim remains one-attempt CAS logic.
- No-fake-feature/product-honesty check: no product claim or completion status changes in this repair.

## Done Criteria

The slice is done only when:

- focused RED/GREEN proof passes;
- the full disposable writer-claim fixture suite passes;
- required branch and merged-main Docs gates pass;
- `git diff --check` passes;
- the repair is committed, fast-forwarded, pushed, and the temporary branch is removed;
- `main...origin/main` is `0 0` and the revision-1 ready state remains uncharged before the claim retry;
- reviewer findings are resolved or explicitly logged.

## Result

- Commit: This slice's closeout commit.
- Verification summary:
  - RED: the focused Dart contract failed because production freshness had no
    encoded receipt transport and still called readiness with raw JSON through
    `powershell.exe -File`.
  - GREEN: the focused contract passed after UTF-8 Base64 receipt transport
    inside a UTF-16LE `-EncodedCommand` child invocation.
  - The full autonomous Dart contract file passed 24 tests.
  - PowerShell parser checks and `git diff --check` passed.
  - The full disposable Git fixture passed 92 scenarios, including an
    authorized production-freshness path that preserved JSON, reached the
    deliberate `CLAIM_BASE_MOVED` guard, and performed no mutation or push.
  - Two repository-read-only audits found no implementation defect; their
    shared behavioral-test gap was resolved by the authorized disposable
    freshness scenario.
  - The dirty-branch Docs profile passed 65 focused checks, all 15 transition
    and 27 ledger behavior checks, dependency validation, custom lint, and
    Flutter analysis.
- Evidence path: command output plus `ACTIVE_HANDOFF.md` and `SLICE_LOG.md`.
- Follow-up created: None; retry the current `/launch/0` claim after clean repair closeout.
