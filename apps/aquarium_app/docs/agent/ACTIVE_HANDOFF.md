# Danio Active Handoff

Status: user-directed manual phone RC chain; Fish ID consent closed, Compatibility consent next
Updated: 2026-07-21
Implementation epoch: `DR-2026-07-21-064`
Marker: `danio-dcl-ai-001-fish-id-activity-consent-proof-2026-07-21/1`
Authority epoch: `DR-2026-07-19-057`
Historical E0 marker: `danio-completion-roadmap-authority-lock-2026-07-15/1`

## Current authority

- Ordered plan:
  `plans/2026-07-19-phone-release-candidate-finalization-plan.md`.
- User-directed continuation reconciliation:
  `plans/2026-07-21-user-directed-phone-rc-continuation-reconciliation.md`.
- Closure state: `COMPLETE_LOCAL_CLOSURE_LEDGER.md`.
- Category status: `FINISH_MAP.md`.
- Execution mechanics: `VERIFIED_SLICE_EXECUTION_CONTRACT.md` and
  `QUALITY_LADDER.md`.
- The older `plans/2026-07-11-phone-complete-local-completion-program.md` is
  superseded background and cannot select or resume work.
- The current plan owns the P0/P1 release selector. P2/P3 work is accepted or
  parked unless the user explicitly reopens it.

## Verified baseline

- Epoch 063 began after a fresh successful fetch from clean, aligned `main` at
  `ee298466699259c0865a47884011627396ea2d43`, tree
  `22b0cc8b24a63d1c97ec93add286e6d66e5b4189`, with one worktree, no Git locks,
  no active Danio gate/device command, and no competing writer.
- Epoch 063 product verification is clean: the self-generated tombstone round
  trip and both preview/import normalization directions pass with the other 18
  import-service tests plus analyze (`GATE_TOTAL|PASS|9698|Focused`). Independent
  settled-diff review found no remaining findings. The first Full attempt found
  stale generated Android transforms in dependency validation and custom lint,
  not a product failure; reset-assisted Full then passed signing, dependency
  validation, custom lint, the full Flutter suite, analyze, and debug APK build
  (`GATE_TOTAL|PASS|213027|Full`).
- `DCL-DR-001` is `closed` in `DCL_DR_001_RESTORE_BEHAVIOR_MATRIX.md`.
- `DCL-DR-002` is `closed` in
  `DCL_DR_002_MIGRATION_CORRUPTION_RECOVERY_MATRIX.md`.
- `DCL-DR-003` is `closed` in
  `DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md`. Findings `DCL-DR-003-F1`
  through `DCL-DR-003-F38` are settled evidence. F38 fixes the Wishlist
  double-submit/captured-callback replay defect; complete matrix reinspection
  found no other current P0/P1, and the required Full gate passed. F34 is complete
  and must not reopen without contradictory live evidence; the same
  boundary applies to F1 through F37. Closure evidence remains
  `GATE_TOTAL|PASS|187023|Full` and `GATE_TOTAL|PASS|4551|Docs`.
- `DCL-DR-004` is `closed` under marker
  `danio-dcl-dr-004-backup-tombstone-relationship-proof-2026-07-21/1`. A
  nonblank missing-livestock ID on
  `livestockRemoved` history survives self-generated backup preview/import
  verbatim without entering the live ID map or resurrecting livestock. Live
  targets still remap, including preview-normalized IDs; every other invalid
  relationship remains rejected.
- Epoch 064 began from freshly fetched, clean, aligned `main` at
  `38b54ab1e84458dac4c99d99739f7fdb031e0d56`, tree
  `bb529aa95c52bf7416ea1ddd148cbd96dc8601ad`, with one worktree, no Git lock,
  no active Danio gate/device command, and no competing writer. Fish ID now
  displays the result before activity-save consent; cancel and system back
  write nothing, confirmation writes once, and failed history persistence
  leaves the result visible. Tests use the injected picker seam and also prove
  the selected-image/result card renders at the exercised widget surface
  without infinite cache sizing or footer overflow. Four focused tests and
  analyze passed
  (`GATE_TOTAL|PASS|16550|Focused`); independent settled-diff review found no
  findings. The first Full exposed only stale current-doc evidence, whose named
  guard then passed; the next attempt found stale generated Android transforms.
  Reset-assisted Full passed signing, dependency validation, custom lint, all
  2,286 Flutter tests, analyze, and the debug APK build
  (`GATE_TOTAL|PASS|177895|Full`). The final documentation contract and signing
  guard also pass (`GATE_TOTAL|PASS|5603|Docs`).

## Fixed release sequence

The ten planned product/test epochs are:

1. Tasks completion compensation - complete in `DR-2026-07-19-058`.
2. Equipment Mark Serviced compensation - complete in `DR-2026-07-19-059`.
3. Single livestock-add compensation - complete in `DR-2026-07-19-060`.
4. Backup tombstone relationship - complete in `DR-2026-07-21-063`.
5. Fish ID activity consent - complete in `DR-2026-07-21-064`.
6. Compatibility activity consent.
7. Secure Optional-AI key storage through `ApiKeyStore`.
8. Compatibility and calculation rule coverage.
9. Global haptic-preference enforcement.
10. Profile performance harness on `danio_api36`.

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
  sessions including epoch 061. Epoch 064 starts with 17 verified sessions;
  its clean durable closeout consumes one session, leaving 16 verified sessions
  for one duplicate-checked successor.
- Never create an automatic successor task. The former automation remains
  frozen; only the manual user-directed coordinator routing in the reconciliation
  plan may create one exact-marker successor from a clean pushed checkpoint.
- Do not touch cloud/accounts, Play Store signing or
  submission, iOS, tablet, public release, or unrelated branch
  `docs/danio-live-dev-workflow-spec-20260719`.
- Danio is not listed in the Play Console account inspected on 2026-07-15.
  Store release remains separately blocked and outside this local candidate.

## Next manual action

`DR-2026-07-21-064` closes only the Fish ID portion of `DCL-AI-001`. Focused
RED/GREEN, independent review, and reset-assisted Full prove the result remains
visible before/during activity-save consent and after history failure; Cancel
and system back write nothing, while `Save Activity` writes exactly once. The
picker seam keeps automated proof away from the platform picker. This clean
durable closeout consumes one session and leaves 16 verified sessions.

From clean pushed `main`, execute only AI Compatibility activity consent under
marker
`danio-dcl-ai-001-compatibility-activity-consent-proof-2026-07-21/1`. Keep
`DCL-AI-001` open until Compatibility has the same dismiss/cancel no-write,
confirm-once, and history-failure-visible proof. Do not pull key storage, rules,
haptics, performance, tablet, or external work into that epoch.
