# Danio Active Handoff

Status: user-directed manual phone RC chain; AI confirmation closed, secure Optional-AI key storage next
Updated: 2026-07-21
Implementation epoch: `DR-2026-07-21-065`
Marker: `danio-dcl-ai-001-compatibility-activity-consent-proof-2026-07-21/1`
Authority epoch: `DR-2026-07-19-057`
Historical E0 marker: `danio-completion-roadmap-authority-lock-2026-07-15/1`

## Current authority

- Ordered plan:
  `plans/2026-07-19-phone-release-candidate-finalization-plan.md`.
- User-directed continuation reconciliation:
  `plans/2026-07-21-user-directed-phone-rc-continuation-reconciliation.md`.
- Closure state: `COMPLETE_LOCAL_CLOSURE_LEDGER.md`.
- Category status: `FINISH_MAP.md`.
- Settled CRUD/undo history: `DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md`.
- Execution mechanics: `VERIFIED_SLICE_EXECUTION_CONTRACT.md` and
  `QUALITY_LADDER.md`.
- The older `plans/2026-07-11-phone-complete-local-completion-program.md` is
  superseded background and cannot select or resume work.
- The current plan owns the P0/P1 release selector. P2/P3 work is accepted or
  parked unless the user explicitly reopens it.

## Verified baseline

- Epoch `DR-2026-07-21-063` began from clean aligned `main` at `ee298466`, tree
  `22b0cc8b`; self-generated tombstone round-trip and normalization proof passed
  Focused (`GATE_TOTAL|PASS|9698|Focused`), review, and reset-assisted Full
  (`GATE_TOTAL|PASS|213027|Full`).
- `DCL-DR-001` is `closed`; `DCL-DR-002` is `closed`; and
  `DCL-DR-003` is `closed`. Findings `DCL-DR-003-F1`
  through `DCL-DR-003-F38` are settled evidence. F34 is complete and must not reopen without contradictory live evidence.
  Complete matrix reinspection found no other current P0/P1; closure passed
  `GATE_TOTAL|PASS|187023|Full` and `GATE_TOTAL|PASS|4551|Docs`.
- `DCL-DR-004` is `closed` under marker
  `danio-dcl-dr-004-backup-tombstone-relationship-proof-2026-07-21/1`:
  deleted-livestock tombstones survive backup without live-map entry or
  resurrection, while live normalization and invalid relationships stay safe.
- Epoch 064 started with 17 verified sessions from clean aligned `main` at
  `38b54ab`, tree `bb529aa9`, under marker
  `danio-dcl-ai-001-fish-id-activity-consent-proof-2026-07-21/1`. Fish ID keeps
  its result visible through consent/history failure; cancel/back writes
  nothing and confirmation writes once. Picker and rendering proof passed
  Focused (`GATE_TOTAL|PASS|16550|Focused`), review, reset-assisted Full with
  2,286 tests/lint/analyze/APK (`GATE_TOTAL|PASS|177895|Full`), and final Docs
  (`GATE_TOTAL|PASS|5603|Docs`).
- Epoch 065 began from freshly fetched, clean, aligned `main` at
  `f800b7033e30a4253b62d52742418e26ffb76f53`, tree
  `0531f909e2c073fd8f590a4e3044dadf17e3898a`, with one worktree, no Git lock,
  no active Danio gate/device command, and no competing writer. Compatibility
  now exposes its result before activity-save consent; cancel and system back
  write nothing, confirmation writes exactly once, and failed history
  persistence leaves the result visible. The valid RED observed one history
  write before consent; all five widget tests plus analyze passed
  (`GATE_TOTAL|PASS|10554|Focused`). Nine existing consent/history regressions
  reverified Symptom Triage, Weekly Plan, Ask Danio, and Fish ID. A source audit
  found exactly those four callers plus Compatibility, and independent
  settled-diff review found no findings. The first Full attempt found only stale
  generated Android transforms; reset-assisted Full passed signing, dependency
  validation, custom lint, the full Flutter suite, analyze, and the debug APK
  build (`GATE_TOTAL|PASS|183065|Full`). `DCL-AI-001` is closed.

## Fixed release sequence

The ten planned product/test epochs are:

1. Tasks completion compensation - complete in `DR-2026-07-19-058`.
2. Equipment Mark Serviced compensation - complete in `DR-2026-07-19-059`.
3. Single livestock-add compensation - complete in `DR-2026-07-19-060`.
4. Backup tombstone relationship - complete in `DR-2026-07-21-063`.
5. Fish ID activity consent - complete in `DR-2026-07-21-064`.
6. Compatibility activity consent - complete in `DR-2026-07-21-065`.
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
  sessions including epoch 061. Epoch 065 started with 16 verified sessions;
  its durable stop consumed one session. Resumed completion does not consume it
  twice and leaves 15 verified sessions for one duplicate-checked successor.
- Never create an automatic successor task. The former automation remains
  frozen; only the manual user-directed coordinator routing in the reconciliation
  plan may create one exact-marker successor from a clean pushed checkpoint.
- Do not touch cloud/accounts, Play Store signing or
  submission, iOS, tablet, public release, or unrelated branch
  `docs/danio-live-dev-workflow-spec-20260719`.
- Danio is not listed in the Play Console account inspected on 2026-07-15.
  Store release remains separately blocked and outside this local candidate.

## Next manual action

`DR-2026-07-21-065` closes `DCL-AI-001`: Compatibility retains its visible
result while consent is pending or history persistence fails; cancel/system
back write nothing, and explicit confirmation writes exactly once. The valid
RED, five-test Focused gate, nine bounded prior-surface regressions, independent
review, and reset-assisted Full provide the settled proof. The resumed durable
closeout leaves 15 verified sessions.

From clean pushed `main`, execute only secure Optional-AI key storage through
`ApiKeyStore` under marker
`danio-dcl-pref-001-secure-optional-ai-key-storage-2026-07-21/1`. Do not pull
rule coverage, haptics, performance, tablet, providers, accounts, keys, or
external work into that epoch.
