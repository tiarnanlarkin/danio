# Danio Active Handoff

Status: manual lean workflow; Phase 1 data resilience in progress
Updated: 2026-07-16
Product epoch: `DR-2026-07-16-011`
Marker: `danio-dcl-dr-002-start-fresh-scoped-deletion-proof-2026-07-16/1`
E0 authority marker: `danio-completion-roadmap-authority-lock-2026-07-15/1`

## Current state

- Repository authority is local `main`; verify branch, tree, cleanliness, and
  `main...origin/main` live at startup.
- E0 locks the seven ordered phone phases and finite done conditions across the
  completion program, ledger, Finish Map, forecast, performance, and visual
  baseline authorities.
- `DCL-DR-001` is `closed`: `DCL-DR-001-F1`, `DCL-DR-001-F2`, and
  `DCL-DR-001-F3` are locally fixed; `DCL-DR-001-F4`, `DCL-DR-001-F5`, and
  `DCL-DR-001-F6` are locally verified. Its complete ordered evidence remains in
  `DCL_DR_001_RESTORE_BEHAVIOR_MATRIX.md`.
- `DCL-DR-002` is now mapped in
  `DCL_DR_002_MIGRATION_CORRUPTION_RECOVERY_MATRIX.md` and remains `open`.
- `DCL-DR-002-F1` is locally fixed under marker
  `danio-dcl-dr-002-migration-corruption-recovery-audit-2026-07-16/1`: both
  corrupted and I/O-failed local storage expose the real `retryLoad` action,
  while destructive start fresh remains exclusive to confirmed corruption.
- `DCL-DR-002-F2` is locally fixed under marker
  `danio-dcl-dr-002-recovery-copy-honesty-2026-07-16/1`: failed corrupt-file
  backup no longer exposes a nonexistent recovery path, and the card/dialog
  warn honestly while keeping the damaged original until explicit start fresh.
  Successful copies retain their path and copy-preserved wording.
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
- F5 changed no product code, schema, provider, dependency, deletion behavior,
  emulator, account, cloud, or release configuration; no later row was selected.

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
- Frozen material cannot select, reorder, authorize, charge, resume, or hand
  off any completion phase.

Never create an automatic successor task.

The user authorized continued manual roadmap execution in this task until the
app is complete, stopping only when genuinely needed. This does not reactivate,
charge, or alter frozen autonomy or authorize automatic successor tasks.

## Product authority

- `DCL-DR-001` is `closed`. `DCL-DR-001-F1` through `DCL-DR-001-F3` are
  locally fixed and `DCL-DR-001-F4` through `DCL-DR-001-F6` are locally
  verified. Every ordered restore-matrix path has named current evidence and
  the required final Full gate passed.
- `DCL-DR-002` remains `open`. `DCL-DR-002-F1` and `DCL-DR-002-F2` are locally
  fixed, and `DCL-DR-002-F3` through `DCL-DR-002-F5` are locally verified:
  retries and cancellation stay non-destructive, while confirmed recovery is
  main-file scoped and cannot expose empty success before deletion.
- The next matrix path is start-fresh failure/no-false-success evidence.
  Continue it only under marker
  `danio-dcl-dr-002-start-fresh-failure-proof-2026-07-16/1` after this F5
  checkpoint is clean, pushed, and aligned; do not assume a product gap.
- The locked completion program is the only ordered phase authority; the
  closure ledger owns row state/done conditions and the Finish Map owns category
  status. Read them only for the directly relevant row.
- `DCL-DR-003` is verification-first until a current source/test inventory
  proves one concrete gap.
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
- Tablet, keyed-AI seed, providers, premium, store/deploy, public release,
  cloud/accounts, signing, legal hosting, public-history recovery, and iOS all
  remain parked outside the phone roadmap.

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

After this F5 checkpoint is clean, pushed, and aligned, continue
`DCL-DR-002-F6` under marker
`danio-dcl-dr-002-start-fresh-failure-proof-2026-07-16/1`. Force confirmed
recovery to fail and prove the recovery error/card remains retryable with no
provider refresh or false success. Do not bundle preference or first-run proof,
and do not start `DCL-DR-003`, `DCL-DR-004`, or a later phone phase while
`DCL-DR-002` remains open.
