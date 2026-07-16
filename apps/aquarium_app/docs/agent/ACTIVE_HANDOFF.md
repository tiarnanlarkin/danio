# Danio Active Handoff

Status: manual lean workflow; Phase 1 data resilience in progress
Updated: 2026-07-16
Product epoch: `DR-2026-07-16-008`
Marker: `danio-dcl-dr-002-recovery-copy-honesty-2026-07-16/1`
E0 authority marker: `danio-completion-roadmap-authority-lock-2026-07-15/1`

## Current state

- Repository authority is local `main`; verify branch, tree, cleanliness, and
  `main...origin/main` live at startup.
- E0 locks the seven ordered phone phases and finite done conditions across the
  completion program, ledger, Finish Map, forecast, performance, and visual
  baseline authorities.
- `DCL-DR-001` is `closed`. Its complete ordered source/test matrix and six
  focused epochs are recorded in `DCL_DR_001_RESTORE_BEHAVIOR_MATRIX.md`.
- The audit found and fixed one error-replacement boundary: if preference
  restore and snapshot rollback both fail, the initiating error and rollback
  error now remain separately inspectable with their original stack traces.
- `DCL-DR-001-F2` is locally fixed: only affirmative share success records
  `Last backup`; dismissed and unavailable outcomes get honest terminal
  warnings; completed ZIP cleanup now covers success, returned non-success,
  thrown share errors, and unmount while sharing.
- `DCL-DR-001-F3` is locally fixed: cancel and empty picker outcomes return
  idle without writes; pathless selections and Android `unknown_path` failures
  get access-specific feedback instead of being mislabeled as corrupt backups.
- `DCL-DR-001-F4` is locally proven with no current product gap: cancelling a
  valid preview returns idle before photo, tank, preference, or provider writes.
- `DCL-DR-001-F5` is locally proven with no current product gap: when an
  initiating tank import and `deleteAllTanks` rollback both fail, the original
  error, original stack, rollback error, and combined diagnostic remain
  inspectable.
- `DCL-DR-001-F6` is locally proven with no current product gap: one photo file
  exists before a later extraction failure, then cleanup removes that new file
  while preserving the pre-existing file and blocking directory.
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
- No persisted-data schema, provider, dependency, deletion behavior, emulator,
  account, cloud, or release configuration changed in F2. No later Phase 1 row
  was selected.

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

The current user explicitly authorized continued manual roadmap execution in
this task until the app is complete, stopping only when user input is genuinely
required. That permission does not reactivate, charge, or alter the retained
frozen-autonomy state and does not authorize automatic successor tasks.

## Product authority

- `DCL-DR-001` is `closed`. `DCL-DR-001-F1` through `DCL-DR-001-F3` are
  locally fixed and `DCL-DR-001-F4` through `DCL-DR-001-F6` are locally
  verified. Every ordered restore-matrix path has named current evidence and
  the required final Full gate passed.
- `DCL-DR-002` remains `open`. `DCL-DR-002-F1` and `DCL-DR-002-F2` are locally
  fixed under their recorded markers: both storage error states expose honest
  recovery actions, and only a successfully created corrupt-file copy is
  advertised to the user.
- The next matrix path is direct repaired-versus-still-malformed `retryLoad`
  service evidence. Continue it only under marker
  `danio-dcl-dr-002-corrupt-json-retry-proof-2026-07-16/1` after this F2
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

After this F2 checkpoint is clean, pushed, and aligned, continue
`DCL-DR-002-F3` under marker
`danio-dcl-dr-002-corrupt-json-retry-proof-2026-07-16/1`. Use real malformed
local JSON to prove a repaired file succeeds only through `retryLoad` and an
unchanged malformed reread remains blocked, without destructive writes or
empty-data false success. Do not bundle start-fresh or another matrix gap, and
do not start `DCL-DR-003`, `DCL-DR-004`, or a later phone phase while
`DCL-DR-002` remains open.
