# Danio Active Handoff

Status: manual lean workflow; product development paused
Updated: 2026-07-15
Maintenance epoch: `WF-2026-07-15-019`

## Current state

- Repository authority is local `main`; verify branch, tree, cleanliness, and
  `main...origin/main` live at startup.
- This maintenance epoch stops the autonomous chain, streamlines local gates,
  archives the former workflow context, and adopts lean manual epochs.
- No Flutter application API, persisted-data schema, dependency, UI, emulator,
  account, cloud, or release behavior changed.
- Product work remains paused until this maintenance epoch is clean, pushed,
  aligned, and reduced to one worktree.

## Frozen autonomy

- State file:
  `apps/aquarium_app/docs/agent/autonomous_completion/phone_completion_run_state.json`.
- Revision: 2.
- Mode: `stopped`.
- Transition: `preclaim_stop`.
- Reason: `USER_REQUESTED_WORKFLOW_SIMPLIFICATION`.
- Cursor: `DCL-DR-001-restore-matrix-audit`.
- Budget remains historical and uncharged: total 20, consumed 10, remaining 10.
- Owner is null and current charge status is `none`.
- Claim, launch, budget, closeout, and successor machinery is retained only for
  historical/recovery evidence. It is outside routine startup and gates.
- Reactivation requires a new explicit user request and reconciliation plan.

Never create an automatic successor task.

## Product authority

- `DCL-DR-001` is the next manual development task.
- `DCL-DR-001` remains `open`, was not claimed, and is unstarted.
- Its first action is an ordered read-only restore-matrix audit. Implement only
  if that audit proves one specific current gap.
- The closure ledger and Finish Map remain the authority for product status;
  read them only when selecting or updating a directly relevant product row.

## Release and external truth

- Danio is not listed in the Play Console account inspected on 2026-07-15.
- The exposed local signing key is retired and must never be used for a future
  release. Fresh signing material requires a separately authorized release task.
- Public Git-history exposure remains unresolved; do not rewrite history or
  force-push without an explicit recovery plan and user authorization.
- Public legal-page availability and other account-side release checks remain
  external/user-gated. Do not infer readiness from local gates.

## Routine startup

Read only the exact five files listed in root `AGENTS.md`. Load source, tests,
ledger rows, device guidance, archived history, or frozen autonomy material only
when the chosen task directly requires them.

## Verification policy

- Focused and Visual gates require explicit affected test paths.
- Product-code epochs get one Full gate on their final settled tree.
- Docs-only epochs get one Docs gate and no Full gate.
- `WF-2026-07-15-019` changes the Full-gate implementation, so its settled
  final tree requires one Full gate before landing.
- After an identical fast-forward/push, compare tree IDs and Git alignment; do
  not run the same Full gate again.

## Hard pause

Stop after `WF-2026-07-15-019` is clean, pushed, aligned, and reduced to one
worktree. Do not begin `DCL-DR-001` in the maintenance epoch.

Next manual action: open a fresh development task for the read-only
`DCL-DR-001` restore-matrix audit.
