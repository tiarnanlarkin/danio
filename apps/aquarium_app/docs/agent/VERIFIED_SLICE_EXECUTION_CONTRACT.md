# Verified Slice Execution Contract

Status: active lean manual contract
Epoch: `WF-2026-07-15-019`

## Routine startup (exact)

Read these five files, in order:

1. `AGENTS.md`
2. `GIT_WORKFLOW.md`
3. `apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md`
4. `apps/aquarium_app/docs/agent/VERIFIED_SLICE_EXECUTION_CONTRACT.md`
5. `apps/aquarium_app/docs/agent/QUALITY_LADDER.md`

Do not add routine startup reads. Ledger rows, Finish Map, source, tests, device
docs, archives, old plans, forecasts, and frozen autonomy material are
task-triggered references only.

## Define the epoch

- Confirm clean/aligned Git and preserve unrelated work.
- Name the exact behavior, maintenance purpose, or directly relevant ledger row.
- Group two or three closely related micro-slices into one ordinary epoch.
- Keep high-risk work to one slice: data safety, persistence, security,
  lifecycle/concurrency, destructive actions, release truth, or broad
  multi-module changes.
- State the expected files, focused tests, gate, and stop boundary before edits.
- Use one repository-writing coordinator. Auditors and reviewers are read-only.

## Implement

For each behavior change:

1. Write or update the narrow test first.
2. Run it and prove RED for the intended missing behavior.
3. Make the smallest implementation change.
4. Run Focused once with the affected path; that invocation is the GREEN proof,
   `flutter analyze`, worktree visibility, and diff check.

Docs and workflow contract changes also start with a focused guard that fails
for the intended reason.

Run Focused from `apps/aquarium_app` with explicit paths:

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused -FocusedTests test/path/to/affected_test.dart
```

Do not turn a narrow fix into a full-suite loop. Read nearby source/tests only
as needed, and do not repeatedly reload project history.

## Settle and review

- Inspect `git status --short -uall`, the complete diff, and staged paths.
- Ordinary narrow work needs coordinator review only.
- Require one independent read-only settled-diff review for high-risk or broad
  work. Resolve findings before the final broad gate.
- Update `ACTIVE_HANDOFF.md` and add one concise `SLICE_LOG.md` row.
- Update the Finish Map or closure ledger only when actual status changes.

## Final gate

Choose the smallest profile from `QUALITY_LADDER.md`:

- Product-code epoch: one Full gate on the final settled tree.
- Docs-only epoch: one Docs gate and no Full gate.
- Visual epoch: explicit affected tests and visual proof, followed by Full only
  when product code changed.
- Android evidence: AndroidPrep after device-ownership checks.
- Frozen-autonomy proof: opt in with `-RunAutonomyTests` only when directly
  relevant.

Do not run a preliminary Focused bundle, autonomy suite, and then the same tests
again inside Full. The gate profiles own their documented composition.

## Close

1. Commit only the intended, verified bytes.
2. Record the tested commit and tree ID.
3. Fast-forward to local `main`.
4. Prove the merged tree equals the tested tree.
5. Push once without force.
6. Confirm clean status, `main...origin/main = 0 0`, and intended worktrees.
7. Remove only safely merged temporary branches/worktrees.

Do not rerun Full after an identical fast-forward or push. Tree identity and Git
alignment are the closeout proof.

Never create an automatic successor task. Stop at the documented manual action.
