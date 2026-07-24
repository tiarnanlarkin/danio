# Danio Active Handoff

Status: active asset provenance recorded; phone-quality cluster 1 remains open
Updated: 2026-07-24
Implementation epoch: `DR-2026-07-24-074`
Marker: `danio-active-asset-local-comfyui-provenance-2026-07-24/1`
Authority epoch: `DR-2026-07-19-057`
Historical E0 marker: `danio-completion-roadmap-authority-lock-2026-07-15/1`

## Current authority

- Ordered plan: `plans/2026-07-19-phone-release-candidate-finalization-plan.md`.
- User-directed continuation reconciliation: `plans/2026-07-21-user-directed-phone-rc-continuation-reconciliation.md`.
- Closure state: `COMPLETE_LOCAL_CLOSURE_LEDGER.md`.
- Category status: `FINISH_MAP.md`.
- Settled CRUD/undo history: `DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md`.
- Execution mechanics: `VERIFIED_SLICE_EXECUTION_CONTRACT.md` and `QUALITY_LADDER.md`.
- The older `plans/2026-07-11-phone-complete-local-completion-program.md` is superseded background and cannot select or resume work.
- The current plan owns the P0/P1 release selector; P2/P3 is accepted or parked unless explicitly reopened.

## Verified baseline

- `DCL-DR-001` is `closed`; `DCL-DR-002` is `closed`; `DCL-DR-003` is `closed`.
  `DCL-DR-003-F1` through `DCL-DR-003-F38` are settled evidence; F34 is complete; do not
  reopen without contradictory live evidence. Closure passed
  `GATE_TOTAL|PASS|187023|Full` and `GATE_TOTAL|PASS|4551|Docs`.
- `DCL-DR-004` is `closed` in `DR-2026-07-21-063` under marker
  `danio-dcl-dr-004-backup-tombstone-relationship-proof-2026-07-21/1`; its
  reset-assisted Full passed (`GATE_TOTAL|PASS|213027|Full`).
- Epoch 064 started with 17 verified sessions under marker `danio-dcl-ai-001-fish-id-activity-consent-proof-2026-07-21/1`; epochs 064-066
  closed Fish ID consent, Compatibility consent, and secure Optional-AI key storage; Full gates passed at
  `GATE_TOTAL|PASS|177895|Full`, `GATE_TOTAL|PASS|183065|Full`, and
  `GATE_TOTAL|PASS|243873|Full`. Detailed evidence remains in the ledger/log.
- Epoch 067 closed the Compatibility, calculation, content, and source rows
  under `danio-dcl-rule-001-compatibility-calculation-rule-coverage-2026-07-21/1`
  after direct executable coverage and reset-assisted Full
  (`GATE_TOTAL|PASS|233189|Full`). Detailed evidence remains in the ledger/log.
- Epoch 068 under `danio-dcl-motion-001-global-haptic-preference-enforcement-2026-07-22/1`
  routed every product haptic through the persisted preference adapter. Focused
  passed (`GATE_TOTAL|PASS|17006|Focused`) and reset-assisted Full passed
  (`GATE_TOTAL|PASS|202146|Full`). Its closeout left 11 verified sessions;
  `DCL-MOTION-001` remains open only for the five phone-quality clusters.
- Epoch 069 (`DR-2026-07-22-069`) under `danio-dcl-perf-001-profile-performance-harness-2026-07-22/1`
  added the profile-only harness and measured exact product commit
  `61dbb1748487b9111fa8f6e2cccc24100c71dba4` on
  `danio_api36 (emulator-5554)`. Cold start `2476 ms`, warm resume `313 ms`,
  and tab switching `241.501 ms` pass. Tank feedback (`26.249 ms`, `91.24%`
  dropped), scrolling (`28.437 ms`, `96.89%` dropped), and local-image paint
  (`540.258 ms`) fail. The single permitted bottom-dock blur fix did not
  materially shift the raster-bound traces, so no second product cause is
  proven. Report: `docs/qa/performance/2026-07-22/dcl-perf-001-phone-profile.json`;
  `DCL-PERF-001 remains open`.
- Epoch 070 (`DR-2026-07-22-070`) under
  `danio-dcl-perf-001-profile-attribution-triage-2026-07-22/1` added paired
  diagnostics at `docs/qa/performance/2026-07-22/dcl-perf-001-phone-profile-attribution.json` and exact commit
  `05c4d430f80b42e0d0e8a3ecae2930d80fe6e29e` isolated no incremental product
  P1. Epoch 071 (`DR-2026-07-23-071`) under `danio-dcl-perf-001-cold-boot-authoritative-rerun-2026-07-22/1` reran the unchanged harness at exact commit
  `cc7f533be583c5c6eaab3507d2ad308bb61b3365` on snapshot-disabled cold-booted
  `danio_api36 (emulator-5554)`. Cold `1583 ms`, warm `111 ms`, tabs
  `228.595 ms`, and image `216.87 ms` pass. Tank `15.935 ms`/`22.0%` dropped
  and scrolling `15.951 ms`/`26.616%` dropped fail only their original dropped-
  frame budgets. Report:
  `docs/qa/performance/2026-07-23/dcl-perf-001-phone-profile-cold-boot-rerun.json`
  (SHA-256 `ADC3D9C16AB26CE43EA5FD7667AAB73DBA404A6E42F5C7A0F28C4CDBC5EEB6E9`).
  No product code changed; `DCL-PERF-001 remains open`.
- `DR-2026-07-23-072` under `danio-phone-quality-cluster-1-tank-daily-care-2026-07-23/1`
  fixed only the Tank-root energy target at 48 x 48 dp. Focused, Visual, reset-
  assisted Full, and Docs passed; evidence is in
  `docs/qa/phone-quality/2026-07-23/dcl-a11y-001-tank-daily-care.md`.
- `DR-2026-07-24-074` under
  `danio-active-asset-local-comfyui-provenance-2026-07-24/1` records the user's
  confirmed local ComfyUI generation and permitted model/checkpoint/input basis
  for the exact active ocean-room and Neon Tetra bytes. Their rights HOLD is
  resolved in substance; Tank detail/Add Log 2.0x overflows keep cluster 1 open.

## Fixed release sequence

The ten planned product/test epochs are:

1. Tasks completion compensation - complete in `DR-2026-07-19-058`.
2. Equipment Mark Serviced compensation - complete in `DR-2026-07-19-059`.
3. Single livestock-add compensation - complete in `DR-2026-07-19-060`.
4. Backup tombstone relationship - complete in `DR-2026-07-21-063`.
5. Fish ID activity consent - complete in `DR-2026-07-21-064`.
6. Compatibility activity consent - complete in `DR-2026-07-21-065`.
7. Secure Optional-AI key storage through `ApiKeyStore` - complete in `DR-2026-07-21-066`.
8. Compatibility and calculation rule coverage - complete in `DR-2026-07-22-067`.
9. Global haptic-preference enforcement - complete in `DR-2026-07-22-068`.
10. Profile performance harness on `danio_api36` - baseline and cold-boot
    authoritative rerun recorded; Tank and scrolling dropped-frame budgets remain open.

After epochs 1-3, run the bounded Wishlist replay probe. Add an epoch only if a
focused RED proves P0/P1 duplicate or replay behavior. After epoch 8, close only
those product/content/rule rows backed by executable evidence. After epochs
9-10, complete the five phone-quality clusters and final device evidence.

## Severity boundary

- P0: crash/ANR, corruption/data loss, serious privacy/security failure,
  unreachable critical journey, or required-gate failure.
- P1: uncertain durability or duplicate risk, false success, broken core
  journey, wrong safety-critical calculation/advice, essential accessibility
  failure, reduced-motion/haptic bypass, material clipping, or reproducible
  performance-budget miss.
- P2/P3: accepted limitation or post-v1 work; no release extension without
  explicit user reopening.

## Execution boundary

- One repository-writing coordinator. Parallel auditors remain read-only.
- Start every epoch from fetched, clean, aligned `main`, one worktree, and no
  competing writer; allocate the next unused live `DR` identifier.
- One temporary branch and one product finding per implementation epoch.
- Product: focused RED, minimal fix, focused GREEN, settled-diff review, Full,
  fast-forward `main`, one push, clean/aligned/worktree proof, branch cleanup.
- Documentation: guard RED, docs edit, guard GREEN, review, Docs gate, the same
  Git closeout.
- Only the coordinator runs Flutter, Gradle, Git integration, or device work.
- `phone_completion_run_state.json` remains historically `stopped` for
  `USER_REQUESTED_WORKFLOW_SIMPLIFICATION`; frozen autonomy, claims, budgets,
  launch, closeout, and successor machinery cannot authorize work.
- The distinct user-directed continuation plan started with 20 verified
  sessions including epoch 061. Epoch 065 started with 16 verified sessions;
  its durable stop consumed one session. Epoch 066 started with 15 verified
  sessions; its durable closeout consumes one session and leaves 14 verified
  sessions for one duplicate-checked successor. Epoch 067 started with 14
  verified sessions; its durable stop left 13. The fresh-direction diagnostic
  continuation consumed one at clean closeout and left 12 verified sessions.
  Epoch 068 consumes one at clean closeout and leaves 11 verified sessions for
  one duplicate-checked successor. Epoch 069 consumes one at durable closeout
  and leaves 10 verified sessions. Epoch 070's first durable environment stop
  left 9; its user-directed repaired continuation consumes the next session at
  clean closeout and leaves 8 verified sessions. Epoch 071 consumes one at
  clean closeout and leaves 7 verified sessions. Epoch 072 consumes one at
  clean closeout and leaves 6 verified sessions.
- Never create an automatic successor task. The former automation remains
  frozen; only the manual user-directed coordinator routing in the reconciliation
  plan may create one exact-marker successor from a clean pushed checkpoint.
- Do not touch cloud/accounts, Play Store signing or submission, iOS, tablet,
  public release, or unrelated branch `docs/danio-live-dev-workflow-spec-20260719`.
- Danio is not listed in the Play Console account inspected on 2026-07-15.
  Store release remains separately blocked and outside this local candidate.

## Next manual action

Next only run `DR-2026-07-24-075` under
`danio-phone-quality-cluster-1-tank-large-text-visual-bundle-2026-07-24/1`:
preserve the Tank detail/Add Log 2.0x REDs, make the smallest fixes, and collect
affected Visual proof. Do not advance to cluster 2 or include excluded work.
