# WF-2026-07-15-018 Windows Drive-Root Claim Repair

## Slice

- ID: `WF-2026-07-15-018`
- Title: Preserve Windows drive roots across autonomous path normalization
- Branch/worktree: `maintenance/danio-predevelopment-clearance-2026-07-15`
  in the canonical checkout
- Coordinator: current pre-development maintenance/security clearance task
- Worker agents, if any: repository-read-only recovery and root-cause audits
- Owned files/modules: autonomous completion module, behavior test, this
  contract, `ACTIVE_HANDOFF.md`, and `SLICE_LOG.md`
- Files/modules explicitly out of scope: product Dart behavior, live run-state
  mutation, writer claiming, `DCL-DR-001`, Android/runtime state, Figma,
  external services, and successor creation

## Product Goal

- User-visible outcome: none; remove the Windows-only Docs-gate blocker while
  keeping product development paused.
- Complete-local requirement this advances: workflow reliability only;
  `DCL-DR-001` remains open and unstarted.
- Finish Map row(s): no completion-status change.
- Product backlog row(s): no completion-status change.

## Research And Planning

- Fresh session recommended: No; this task exists solely to recover and repair
  the proven failed launch boundary.
- Repo context checked: runners, repo instructions, clean aligned Git, live
  revision-1 state, stopped launch task, recovery authority, claim/Docs path,
  path helper, behavior tests, quality ladder, and testing checklist.
- Current best-practice sources checked: repository-local path contracts and
  production call chain; no external API or platform choice is involved.
- Tool/plugin/MCP/account-backed lane considered: Not needed.
- Tool/plugin/MCP/account-backed lane approved: Not needed.
- Decision-changing research notes: the real Docs path maps the deterministic
  writer checkout to a drive root such as `R:\`; the behavior suite preserves
  that as `R:/`, but `ConvertTo-DanioForwardSlashPath` removes the final slash
  and creates invalid drive-relative `R:`.

## Design And Visual Target

- Current screenshot/golden/mockup/existing surface: Not applicable.
- Phone expectation: No app change.
- Tablet expectation: Parked and unchanged.
- Accessibility expectation: No change.
- Visual evidence required: No.

## Tests And Gates

- Focused test(s): the real `New-DanioRehearsalReport` boundary must accept
  `R:\` as canonical `R:/`, while an ordinary path still loses redundant
  trailing separators.
- Required local gate: autonomous behavior, Dart contract, activation fixture,
  disposable Git fixture, `git diff --check`, Docs on the branch, and
  clean-worktree Docs on the committed branch and merged `main`.
- Android evidence required: No; no device behavior changes.
- External review/tool lane: repository-read-only final diff review.
- Paid-tool ledger entry required: No.

## Data And Safety

- Local data touched: no app data; workflow source/tests/docs only.
- Failure states to test: a valid drive root must not become a drive-relative
  path; bare `R:` remains invalid because validation is unchanged.
- Rollback or retry behavior: no real claim is attempted in this session.
- No-fake-feature/product-honesty check: no product or release claim changes.

## Recovery Evidence

- The exact failed deterministic branch/worktree resolved inside the
  non-reparse project-owned `.codex-worktrees` root.
- Long-path-safe inspection found only the staged run-state path, no unstaged
  or untracked files, no branch commit ahead of `main`, no exact remote branch,
  no relevant process, and no durable device owner.
- The repo validator accepted the staged revision-1 `ready` to revision-2
  `active` proposal without mutation; committed `main` stayed revision 1,
  `ready`, owner null, charge `none`, and remaining units `10`.
- The user-authorized exact failed identity was removed; nothing else was
  cleaned or pruned.

## Done Criteria

The slice is done only when:

- focused RED/GREEN proof passes through the production report function;
- all required autonomous and Docs checks pass;
- `git diff --check` passes;
- final docs keep run state ready/uncharged and product work paused;
- the change is committed separately from signing-secret containment;
- merged `main` is clean, pushed, aligned `0 0`, and has one worktree;
- reviewer findings are resolved or explicitly logged.

## Result

- Commit: This slice's focused workflow-repair commit.
- Verification summary:
  - RED: the behavior suite threw `REHEARSAL_INPUT_INVALID` when the real
    rehearsal-report function received `R:\`.
  - GREEN: the behavior suite passed 15 transitions and 27 ledger rows after
    the central normalizer preserved `R:/`; the ordinary-path control also
    proved redundant trailing separators are still removed.
  - The autonomous Dart contract passed 24 tests.
  - The activation fixture passed 24 scenarios with no mutation.
  - The disposable Git fixture passed 92 scenarios with
    `mutations_performed_by_readiness: false`.
  - PowerShell parsing and `git diff --check` passed.
  - The dirty-branch Docs profile passed 65 focused checks, the behavior and
    dependency checks, custom lint, and Flutter analysis.
- Evidence path: command output, `ACTIVE_HANDOFF.md`, and `SLICE_LOG.md`.
- Follow-up created: None; this clearance task creates no successor.
