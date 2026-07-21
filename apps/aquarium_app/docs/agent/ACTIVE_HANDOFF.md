# Danio Active Handoff

Status: user-directed manual phone RC chain; reconciliation docs prepared
Updated: 2026-07-21
Implementation epoch: `DR-2026-07-21-061`
Marker: `danio-user-directed-continuation-reconciliation-2026-07-21/1`
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

- Startup checkpoint: local and remote `main` at `ded4771a`, tree
  `e59ea2ca36abac3b512cd2e6b8196a6f7a369982`, clean and aligned with one
  worktree before epoch 057.
- Fresh post-F34 Full gate on the unchanged checkpoint passed on 2026-07-19:
  signing-secret guard, dependency validation, custom lint, 2,263 tests,
  analyze, and debug APK build; `GATE_TOTAL|PASS|183016|Full`.
- Epoch 060 began from clean, aligned `main` at `d4320536` with one worktree
  and no competing writer.
- Epoch 061 began after a fresh successful fetch from clean, aligned `main` at
  `7505319db818a42155334a24802cab70fbfba7b0`, with one worktree and no competing
  Danio writer. It is documentation-only and completes no Wishlist or product
  task.
- Epoch 060 product verification is clean: 30 Livestock tests plus analyze passed
  through Focused (`GATE_TOTAL|PASS|14350|Focused`); independent settled-diff
  review has no remaining findings; reset-assisted Full passed dependency
  validation, custom lint, 2,276 tests, analyze, and debug APK build
  (`GATE_TOTAL|PASS|218361|Full`); final Docs passed 24 contract/signing checks
  (`GATE_TOTAL|PASS|4610|Docs`).
- `DCL-DR-001` is `closed` in `DCL_DR_001_RESTORE_BEHAVIOR_MATRIX.md`.
- `DCL-DR-002` is `closed` in
  `DCL_DR_002_MIGRATION_CORRUPTION_RECOVERY_MATRIX.md`.
- `DCL-DR-003` remains `open` in
  `DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md`. Findings `DCL-DR-003-F1`
  through `DCL-DR-003-F37` are settled evidence. F34 is complete and must not
  reopen without contradictory live evidence. F35 through F37 are also complete;
  none may reopen without contradictory live evidence.
- `DCL-DR-004` remains after DCL-DR-003 and owns the livestock-removal backup
  tombstone relationship.

## Fixed release sequence

The ten planned product/test epochs are:

1. Tasks completion compensation - complete in `DR-2026-07-19-058`.
2. Equipment Mark Serviced compensation - complete in `DR-2026-07-19-059`.
3. Single livestock-add compensation - complete in `DR-2026-07-19-060`.
4. Backup tombstone relationship.
5. Fish ID activity consent.
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
- The distinct user-directed continuation plan starts with 20 verified sessions
  including epoch 061. A clean durable closeout consumes this session, so 19
  verified sessions remain for one duplicate-checked successor.
- Never create an automatic successor task. The former automation remains
  frozen; only the manual user-directed coordinator routing in the reconciliation
  plan may create one exact-marker successor from a clean pushed checkpoint.
- Do not touch cloud/accounts, Play Store signing or
  submission, iOS, tablet, public release, or unrelated branch
  `docs/danio-live-dev-workflow-spec-20260719`.
- Danio is not listed in the Play Console account inspected on 2026-07-15.
  Store release remains separately blocked and outside this local candidate.
- Never create an automatic successor task.

## Next manual action

`DR-2026-07-21-061` only reconciles the new manual continuation authority. It
does not claim the Wishlist replay probe or any product task complete.

`DR-2026-07-19-060` closes `DCL-DR-003-F37`. Focused RED/GREEN proves
persisted-then-failed activity history plus failed log and livestock deletion
preserves the initiating and rollback failures/stacks with tank, livestock, and
activity-log IDs. Tank, livestock, recent-log, and full-log authority reloads;
in-flight, visible, dismissed, and stale callbacks cannot duplicate the write;
uncertain feedback has no success or unsafe Retry. Focused, Full, and independent
review pass. On clean aligned main, run the bounded Wishlist replay probe next.
Add an epoch only if focused RED proves P0/P1 duplicate or replay behavior; keep
`DCL-DR-004` separate and do not infer `DCL-DR-003` closure from F37.

From the clean pushed epoch-061 checkpoint, the Wishlist replay probe next uses
marker `danio-dcl-dr-003-wishlist-replay-probe-2026-07-21/1` with 19 verified
sessions remaining. Apply the exact lookup/create and fail-closed rules in the
reconciliation plan.

Stop after `DCL-RC-001` closes with the final APK/evidence packet and no P0/P1.
