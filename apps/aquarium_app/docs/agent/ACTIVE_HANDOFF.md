# Danio Active Handoff

Status: manual lean workflow; Phase 1 data resilience in progress
Updated: 2026-07-16
Product epoch: `DR-2026-07-16-023`
Marker: `danio-dcl-dr-003-task-completion-stale-id-proof-2026-07-16/1`
E0 authority marker: `danio-completion-roadmap-authority-lock-2026-07-15/1`

## Current state

- Repository authority is local `main`; verify branch, tree, cleanliness, and
  `main...origin/main` live at startup.
- E0 locks the seven ordered phone phases and finite done conditions across the
  completion program, ledger, Finish Map, forecast, performance, and visual
  baseline authorities.
- `DCL-DR-001` is `closed`: `DCL-DR-001-F1`, `DCL-DR-001-F2`, and
  `DCL-DR-001-F3` are locally fixed; `DCL-DR-001-F4`, `DCL-DR-001-F5`, and
  `DCL-DR-001-F6` are locally verified in `DCL_DR_001_RESTORE_BEHAVIOR_MATRIX.md`.
- `DCL-DR-002` is `closed` in `DCL_DR_002_MIGRATION_CORRUPTION_RECOVERY_MATRIX.md`.
- `DCL-DR-002-F1` is locally fixed under marker
  `danio-dcl-dr-002-migration-corruption-recovery-audit-2026-07-16/1`: both
  error states expose `retryLoad`; start fresh remains corruption-only.
- `DCL-DR-002-F2` is locally fixed under marker
  `danio-dcl-dr-002-recovery-copy-honesty-2026-07-16/1`: failed corrupt-file
  backup no longer exposes a nonexistent path; successful-copy behavior remains.
- `DCL-DR-002-F3` is locally verified with no current product gap under marker
  `danio-dcl-dr-002-corrupt-json-retry-proof-2026-07-16/1`: an unchanged real
  malformed file remains corrupted and blocks empty-data reads after retry,
  while a schema-v2 repair remains blocked until `retryLoad`, then loads without
  rewriting the repair or creating another corruption copy.
- `DCL-DR-002-F4` is locally verified with no current product gap under marker
  `danio-dcl-dr-002-start-fresh-cancel-back-proof-2026-07-16/1`: both the
  explicit Cancel action and system back dismiss the destructive dialog with
  zero recovery calls, provider refreshes, state changes, or success feedback.
- `DCL-DR-002-F5` is locally verified with no current product gap under marker
  `danio-dcl-dr-002-start-fresh-scoped-deletion-proof-2026-07-16/1`: real-file
  recovery deletes only the corrupt main store, preserves recovery/sibling
  evidence, clears all five entity maps, and only then exposes healthy emptiness.
- `DCL-DR-002-F6` is locally verified with no current product gap under marker
  `danio-dcl-dr-002-start-fresh-failure-proof-2026-07-16/1`: recovery failure
  retains the service error/card and retry actions, performs no provider reread,
  shows accurate failure feedback, and cannot show start-fresh success.
- `DCL-DR-002-F7` is locally verified with no current product gap under marker
  `danio-dcl-dr-002-v0-preference-preservation-proof-2026-07-16/1`: the v0
  stamp adds only schema version 1 and preserves every existing preference key,
  value, and primitive type.
- `DCL-DR-002-F8` is locally verified with no current product gap under marker
  `danio-dcl-dr-002-local-json-first-run-proof-2026-07-16/1`: missing,
  zero-byte, and whitespace-only local JSON stores load healthy and empty with
  no rewrite, corruption artifact, recovery state, or invented entity.
- `DCL-DR-003` is mapped in `DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md` and
  remains `open` because the fresh inventory proved independent current gaps.
- `DCL-DR-003-F1` is locally fixed under marker
  `danio-dcl-dr-003-crud-undo-resilience-audit-2026-07-16/1`: Today Board Feed
  rejects a missing tank before saving and cannot create an orphan/false success.
- `DCL-DR-003-F2` fixed: `danio-dcl-dr-003-equipment-undo-rollback-proof-2026-07-16/1`;
  task-restore rollback and post-route refresh are proven.
- `DCL-DR-003-F3` fixed: `danio-dcl-dr-003-review-answer-persistence-proof-2026-07-16/1`;
  failed saves stay pending and abandoned sessions cannot resurrect.
- `DCL-DR-003-F4` fixed: `danio-dcl-dr-003-normal-lesson-gem-retry-proof-2026-07-16/1`;
  rewards follow durable lesson progress with honest failure feedback.
- `DCL-DR-003-F5` fixed: `danio-dcl-dr-003-home-quick-feed-parent-preflight-proof-2026-07-16/1`; Home main-Tank Feed rejects a missing parent before saving.
- `DCL-DR-003-F6` fixed: `danio-dcl-dr-003-livestock-quick-feed-parent-preflight-proof-2026-07-16/1`; Livestock Feed rejects a missing parent before saving or rewarding.
- `DCL-DR-003-F7` fixed: `danio-dcl-dr-003-home-quick-water-parent-preflight-proof-2026-07-16/1`; Home Quick Water Test rejects a missing parent before saving or rewarding.
- `DCL-DR-003-F8` verified: `danio-dcl-dr-003-task-delete-failure-proof-2026-07-16/1`; failed deletion keeps the task visible with no success or Undo.
- `DCL-DR-003-F9` fixed: `danio-dcl-dr-003-task-completion-stale-id-proof-2026-07-16/1`;
  stale Completion cannot recreate a task or create completion side effects.
- F9 added no schema, dependency, emulator, account, cloud, or release change.

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
- Claim, launch, budget, closeout, and successor machinery is retained only as
  historical evidence outside routine startup and gates.
- Reactivation requires a new explicit request and reconciliation plan; frozen
  material cannot select, authorize, charge, resume, or hand off a phase.

Never create an automatic successor task.

The user authorized continued manual roadmap execution here until completion,
stopping only when needed; frozen autonomy and automatic tasks remain inactive.

## Product authority

- `DCL-DR-001` is `closed`. `DCL-DR-001-F1` through `DCL-DR-001-F3` are
  locally fixed and `DCL-DR-001-F4` through `DCL-DR-001-F6` are locally
  verified. Every ordered restore-matrix path has named current evidence and
  the required final Full gate passed.
- `DCL-DR-002` is `closed`. `DCL-DR-002-F1` and `DCL-DR-002-F2` are locally
  fixed, `DCL-DR-002-F3` through `DCL-DR-002-F8` are locally verified, every
  matrix path has named executable evidence, and the required Full gate passed.
- `DCL-DR-003` remains `open`; F1-F7/F9 fixes and F8 proof are recorded.
  Continue its next ordered gap under marker
  `danio-dcl-dr-003-task-completion-parent-preflight-proof-2026-07-16/1` after F9
  checkpoint is clean, pushed, and aligned.
- The locked completion program is the only ordered phase authority; the
  closure ledger owns row state/done conditions and the Finish Map owns category
  status. Read them only for the directly relevant row.
- The completed fresh `DCL-DR-003` matrix owns its remaining ordered findings;
  each proven gap stays a separate data-safety slice.
- The current 82 lessons, 75+ species, and 40+ plants are sufficient for phone
  completion. Only audited defects or validator failures require more content.
- Visual and motion work has no asset-replacement or new-animation quota.
  Current screenshot, accessibility, reduced-motion, and haptic-preference
  defects govern.
- Fish ID and AI Compatibility each have a known unconfirmed AI-history
  persistence gap and require separate future single-slice epochs.

## Release and external truth

- Danio is not listed in the Play Console account inspected on 2026-07-15.
- The exposed local signing key is retired and must never be used for a future
  release. Fresh signing material requires a separately authorized release task.
- Public Git-history exposure remains unresolved; do not rewrite history or
  force-push without an explicit recovery plan and user authorization.
- Public legal-page availability and other account-side release checks remain
  external/user-gated. Do not infer readiness from local gates.
- Tablet, keyed-AI seed, providers, premium, deploy/release, cloud/accounts,
  signing, legal hosting, public-history recovery, and iOS remain parked.

## Routine startup

Read only the exact five files listed in root `AGENTS.md`. Load source, tests,
ledger rows, device guidance, archived history, or frozen autonomy material only
when the chosen task directly requires them.

## Verification policy

- Focused and Visual gates require explicit affected test paths.
- Product-code epochs get one Full gate on their final settled tree.
- Docs-only epochs get one Docs gate and no Full gate.
- A row-closing data-safety epoch runs Full when its ledger done condition
  explicitly requires it, even when the final proof changes tests/docs only.
- After an identical fast-forward/push, compare tree IDs and Git alignment; do
  not rerun an identical gate.

## Next manual action

After clean F9 alignment, continue `DCL-DR-003-F10` under marker
`danio-dcl-dr-003-task-completion-parent-preflight-proof-2026-07-16/1`;
reject Completion when the durable tank is missing even if the task remains.
Do not bundle equipment-completion rollback or a later task action.
