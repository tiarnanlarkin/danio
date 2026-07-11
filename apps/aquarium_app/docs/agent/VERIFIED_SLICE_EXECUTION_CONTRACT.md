# Danio Verified Slice Execution Contract

Status: Active local-only execution contract
Created: 2026-07-05

## Purpose

This contract adapts `$verified-slice-runner` to Danio's local-first finish
line. It is mandatory for autonomous complete-local slices and should be read
with `COMPLETE_LOCAL_CLOSURE_LEDGER.md`, `COMPLETE_LOCAL_FORECAST.md`,
`ACTIVE_HANDOFF.md`, `FINISH_MAP.md`, `QUALITY_LADDER.md`,
`TESTING_CHECKLIST.md`, and `SLICE_LOG.md`.

For autonomous phone workflow setup and later product units, load
`$danio-autonomous-slice-runner` first, then load
`$verified-slice-runner` as its underlying verified-slice contract.

## Startup Contract

Every verified Danio slice starts by rebuilding truth from the repo and current
commands:

```powershell
git rev-parse --show-toplevel
git fetch --prune
git status --short -uall
git rev-list --left-right --count main...origin/main
```

Expected before implementation: clean worktree and `main...origin/main` is
`0 0`. Stop if the remote is ahead, the source branch is unclear, or dirty
files overlap the intended slice.

Read current repo docs before editing:

```text
AGENTS.md
GIT_WORKFLOW.md
apps/aquarium_app/docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md
apps/aquarium_app/docs/agent/VERIFIED_SLICE_EXECUTION_CONTRACT.md
apps/aquarium_app/docs/agent/COMPLETE_LOCAL_FORECAST.md
apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md
apps/aquarium_app/docs/agent/FINISH_MAP.md
apps/aquarium_app/docs/agent/QUALITY_LADDER.md
apps/aquarium_app/docs/agent/TESTING_CHECKLIST.md
apps/aquarium_app/docs/agent/SLICE_LOG.md
apps/aquarium_app/docs/agent/plans/2026-07-11-phone-complete-local-completion-program.md
apps/aquarium_app/docs/agent/plans/2026-07-11-autonomous-phone-completion-operating-model-design.md
apps/aquarium_app/docs/agent/plans/2026-07-11-autonomous-phone-completion-workflow-implementation-plan.md
```

Inspect runtime ownership before any Android, ADB, screenshot, Patrol, Maestro,
or live-preview action. Docs-only and pure service/test slices may skip device
work and record that no runtime ownership was needed.

## Bootstrap Continuation Contract

Until the no-product-change rehearsal passes and Task 13 creates the live run
state, automatic operational chaining remains disabled. The temporary
machine-readable budget block in `ACTIVE_HANDOFF.md` is the bootstrap accounting
authority only when that document is committed on clean, pushed, aligned
`main`.

Setup continuation is allowed only through an explicit user-authorized
project-scoped bootstrap handoff that names the exact unique marker, the
positive remaining integer budget including the next task, the saved Danio
project, the selected implementation-plan task(s), closeout rules, and stop
conditions. The handoff may create or reuse exactly one matching local task
only after durable closeout. Ambiguous lookup, project binding, or create
outcome means create nothing and return the paste-ready prompt.

Each cleanly closed setup unit increments `consumed_units`, decrements
`remaining_units_including_current`, records the same unique unit ID once in
`SLICE_LOG.md`, and updates `last_closed_unit_id`. A pre-closeout bootstrap
failure changes none of those fields. Task 13 atomically moves authority to the
live run state; the bootstrap block becomes historical after that transition.

## Selection Contract

- Before Task 13, select only the exact setup task(s) assigned by the autonomous
  workflow implementation plan. Do not select a product ledger target.
- After activation, the phone completion program is the only ordered phase
  authority. Pick exactly one eligible ledger target unless that program
  allows a small group of related micro-slices.
- The closure ledger owns row closure state, disposition, evidence, and done
  conditions. The Finish Map owns category status and quality-bar summaries;
  neither may reorder the phone program.
- Link the selected `DCL-*` ledger ID in the slice contract, handoff, or slice
  log before implementation.
- No implementation starts from "seems likely". The missing behavior must be
  supported by current source, tests, docs, or a current command result.
- New findings discovered during audit are added to
  `COMPLETE_LOCAL_CLOSURE_LEDGER.md` before they become implementation work.
- If multiple candidates are plausible, the next action needs runtime
  ownership, or user product direction is required, stop and ask one direct
  question.

## Proof Contract

Behavior and data-safety changes use TDD:

1. Write or update the focused failing test first.
2. Run the named test and confirm RED for the expected reason.
3. Implement the smallest production change.
4. Re-run the named test, then the full touched test file.
5. Run targeted analyze or the gate required by `QUALITY_LADDER.md`.

Data safety requires failure-path coverage and the Full gate before commit.
Docs-only workflow changes require:

```powershell
git diff --check
flutter test test/copy/current_docs_local_truth_test.dart --reporter compact
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs
```

Run Full when docs change launch/readiness claims, the handoff requires it, or
the slice follows a data-safety closeout chain where clean-main proof matters.

## Acceleration Contract

Faster is allowed only when proof stays clear:

- A session may bundle 2 to 3 micro-slices only when they share one module,
  one test family, one risk boundary, and one gate.
- Each micro-slice still gets immediate focused proof.
- Split the work when the diff crosses unrelated modules, a test fails twice
  for the same root cause, runtime ownership is required but unclear, or a user
  decision is needed.
- Do not trade away RED/GREEN, Full gate, handoff, merge, push, or clean
  alignment to save time.

## External And Cleanup Contract

- Keep tablet, cloud, account, paid, API-key, provider, premium, store, deploy,
  hosted CI, and iOS work parked unless the current thread explicitly approves
  it and the paid-tool ledger covers the exact external use.
- Do not delete, reset, clean, wipe, uninstall, or move unclear repo/device
  state. Cleanup must be scoped, safe, and supported by current evidence.
- Temporary branches and worktrees are deleted only after their verified work
  is merged, pushed, and `main...origin/main` is `0 0`.

## Closeout Contract

Before a slice is complete:

- Focused proof and required local gate passed.
- `ACTIVE_HANDOFF.md`, `SLICE_LOG.md`, `FINISH_MAP.md`, and the ledger are
  updated only where the slice changed recoverable state.
- Work is committed, fast-forward merged to `main`, pushed to `origin/main`,
  and temporary branches/worktrees are cleaned up.
- Final state is clean:

```powershell
git status --short -uall
git rev-list --left-right --count main...origin/main
git branch -vv
git worktree list --porcelain
```

Expected: clean status, `0 0`, only intended local branches, and no stale
worktree metadata.
