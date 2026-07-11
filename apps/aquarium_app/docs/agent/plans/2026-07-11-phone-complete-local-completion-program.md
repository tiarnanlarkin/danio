# Danio Phone Complete-Local Completion Program

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> `$verified-slice-runner` for each implementation slice and
> `superpowers:test-driven-development` for behavior or data-safety changes.
> Use `superpowers:verification-before-completion` before closeout. This
> document controls sequence; it does not authorize broad implementation.

**Goal:** Finish Danio as a polished, resilient, local-first Android phone app
while keeping tablet and external product lanes explicitly parked.

**Architecture:** This program is the only authority for ordered phase sequence.
The closure ledger owns row closure state, disposition, evidence, and exact done
conditions; the Finish Map owns category status and quality-bar summaries; live
Git, source, tests, and fresh commands own factual truth. The Figma phone atlas
is the downstream visual control surface. Work through one authorized closure
lane at a time on a short-lived branch, using a focused read-only audit before
each implementation slice and RED/GREEN proof for every behavior or persistence
change.

**Tech Stack:** Flutter, Dart, Riverpod, local JSON and SharedPreferences
storage, PowerShell quality wrappers, Android local debug builds, local Figma
phone atlas evidence.

## Global Constraints

- Active completion target: Android phone only.
- Tablet implementation, tablet polish, and tablet performance are parked
  until phone complete-local closes.
- Cloud, accounts, hosted sync, API-key/provider expansion, premium,
  store/deploy, public release, and iOS remain outside this program.
- Danio must remain useful without Optional AI or a provider key.
- Do not create fake provider, premium, cloud, social, or release behavior.
- Repository code, tests, ledger, and fresh gates remain authoritative when
  Figma or older docs disagree.
- This program orders the phases. The ledger and Finish Map must not apply a
  competing P0/P1/P2/P3 or disposition-based selector.
- Every implementation slice must advance a named `DCL-*` row or close it by
  fresh verification.
- Data safety, accessibility, visual, and performance rows cannot close from
  documentation alone.
- Use Android runtime only after `DEVICE_OWNERSHIP.md` and scoped preflight.

---

## Current Evidence Baseline

- Source branch checkpoint before this plan: clean `main` at
  `12a68376775d1d3b820aeb6fcb906a22853bc169`, aligned with `origin/main`.
- Latest verified product slice: `DS-2026-07-06-050` / `DCL-DR-001`.
- Planning-checkpoint Full gate: 2,133 Flutter tests, Flutter analyze, and
  debug APK build passed.
- Figma phone atlas:
  `https://www.figma.com/design/JnSwJlWnisxF6xtiwK6nFc`
- Atlas evidence: 14 pages total (13 audit/atlas pages plus the phone
  completion plan), all 96 screen-inventory rows accounted for, 98 numbered
  phone captures, 2 additional live variants, and 100 phone evidence images
  across pages 02 through 11.
- The atlas state matrix identifies uncaptured or unclosed success, empty,
  validation, failure, confirmation, destructive, locked, theme,
  accessibility, and performance states without claiming they are defects.
- A fresh APK rebuild during atlas capture was blocked by dependency DNS
  resolution. Captures used the already installed app from the same clean
  source checkpoint. The planning-checkpoint Full gate later rebuilt the debug
  APK successfully.

## Product Decision Record

Resolved on 2026-07-11. The user accepted both recommended phone-complete
boundaries:

| ID | Accepted phone-complete boundary | Parked expansion |
| --- | --- | --- |
| `DCL-P1-001` | Current data-derived plant, aquascape, decoration, progression, and seasonal cues are sufficient. Fix concrete defects only. | Dedicated plant inventory and broader seasonal variants require a fresh user-approved plan. |
| `DCL-P1-002` | Current room vibes, badges, inventory, earned decorations, and equip controls are sufficient. Fix concrete defects only. | Seasonal cosmetics and deeper plant/decor collections require a fresh user-approved plan. |

Both ledger rows are closed as `ACCEPTED_LOCAL_LIMITATION`. These boundaries
constrain Phase 3 but do not bypass later phone visual, accessibility, motion,
performance, or final-candidate checks.

## Recalibrated Working Range

This replaces the older post-DS-044 directional estimate for planning
purposes. It is still a range, not a delivery promise.

| Range | Verified sessions | Assumptions |
| --- | --- | --- |
| Lower bound | 10 to 13 | Several verification rows close without code, both accepted product-depth boundaries remain stable, and no material accessibility or performance defects appear. |
| Planning range | 13 to 22 | Data resilience needs targeted fixes, phone visual/accessibility work finds bounded defects, and each high-risk phase receives its own closeout evidence. |
| Expanded scope | 18 to 30 | The accepted plant/reward boundary is later reopened, visual assets need broad replacement, or performance/accessibility evidence requires iteration. |

Recalibrate after the data-resilience phase.

## Ordered Completion Phases

| Phase | Ledger rows | Working sessions | Exit condition |
| --- | --- | --- | --- |
| 0. Scope lock | `DCL-P1-001`, `DCL-P1-002` | Complete | Both current product-depth boundaries were accepted on 2026-07-11; broader expansion is parked. |
| 1. Data resilience | `DCL-DR-001` through `DCL-DR-004` | 3 to 5 | Restore, migration/corruption, broader CRUD/undo, and import relationship mapping are fixed or closed by fresh proof; Full gate passes. |
| 2. Optional AI and preferences | `DCL-AI-001`, `DCL-PREF-001` | 1 to 2 | Every real current AI write is confirmed-before-write or proven absent; keyless/provider/privacy preferences are honest and persistent. |
| 3. Normal-user depth | `DCL-P1-003` through `DCL-P1-006`, constrained by Phase 0 | 2 to 5 | Guided tools, timeline, learning, and species/plants meet the accepted phone scope while Living Tank and rewards remain within their accepted boundaries. |
| 4. Content and rules | `DCL-CONTENT-001`, `DCL-RULE-001` | 2 to 3 | The next concrete source, locked-content, recommendation, compatibility, emergency, unit, and calculator risk clusters have executable coverage. |
| 5. Phone accessibility and visual quality | `DCL-A11Y-001`, `DCL-VIS-001`, `DCL-VIS-002`, `DCL-MOTION-001` | 3 to 5 | High-traffic phone clusters meet accessibility, visual, reduced-motion, and haptic acceptance with stable targeted baselines. |
| 6. Phone performance | `DCL-PERF-001` | 1 to 2 | Owned Android phone evidence covers the recorded startup, resume, tab, animation, scrolling, and image targets. |
| 7. Final phone candidate | `DCL-RC-001` | 1 to 2 | No higher phone row remains open; clean main passes the final local gate set and phone signoff packet. |

`DCL-TAB-001` owns all later tablet implementation, tablet accessibility,
tablet visual polish, and tablet performance. It is phase-parked and does not
block Phase 7. `DCL-QA-001`, `DCL-EXT-001`, `DCL-PREMIUM-001`, and
`DCL-EXT-002` remain externally parked.

## Phase 1: Data Resilience

### Task 1.1: Close the restore behavior matrix (`DCL-DR-001`)

**Inspect:**

- `lib/screens/backup_restore_screen.dart`
- `lib/services/backup_import_service.dart`
- `lib/services/backup_service.dart`
- `lib/services/shared_preferences_backup.dart`
- `test/widget_tests/backup_restore_screen_test.dart`
- `test/services/backup_import_service_test.dart`
- `test/services/backup_service_photo_restore_test.dart`
- `test/services/shared_preferences_backup_test.dart`

**Actions:**

- [ ] Enumerate export, preview, confirm, cancel, success, no-tank, invalid ZIP,
  malformed backup, partial-write, rollback, photo-cleanup, and user-visible
  failure paths from source.
- [ ] Map every path to an existing named test and the state-matrix evidence.
- [ ] Add a new ledger finding before code if a distinct false-success,
  rollback, or error-replacement boundary is found.
- [ ] For each real gap, write the focused failing test first, prove RED for
  that boundary, implement the smallest fix, then prove GREEN.
- [ ] Close `DCL-DR-001` only when the matrix has no unexplained path and the
  Full gate passes.

**Focused commands:**

```powershell
flutter test test/widget_tests/backup_restore_screen_test.dart --reporter compact
flutter test test/services/backup_import_service_test.dart --reporter compact
flutter test test/services/backup_service_photo_restore_test.dart --reporter compact
flutter test test/services/shared_preferences_backup_test.dart --reporter compact
```

### Task 1.2: Close migration and corruption recovery (`DCL-DR-002`)

**Inspect:**

- `lib/utils/schema_migration.dart`
- `lib/services/local_json_storage_service.dart`
- `lib/providers/storage_provider.dart`
- `lib/screens/backup_restore_screen.dart`
- `test/utils/schema_migration_test.dart`
- `test/storage_error_handling_test.dart`
- `test/widget_tests/backup_restore_screen_test.dart`

**Actions:**

- [ ] Verify first-run migration, idempotence, failed version stamp, migrated
  v0 data, corrupted JSON, retry, and confirmed start-fresh behavior.
- [ ] Confirm failure states never become empty-data success and start-fresh
  never runs without destructive confirmation.
- [ ] Add RED/GREEN proof for each uncovered behavior.
- [ ] Use owned Android phone walkthrough evidence only when widget/service
  proof cannot establish the interaction contract.

**Focused commands:**

```powershell
flutter test test/utils/schema_migration_test.dart --reporter compact
flutter test test/storage_error_handling_test.dart --reporter compact
flutter test test/widget_tests/backup_restore_screen_test.dart --reporter compact
```

### Task 1.3: Close CRUD/undo and relationship mapping (`DCL-DR-003`, `DCL-DR-004`)

**Inspect:** current tank, log, task, equipment, livestock, wishlist, cost,
review-card, reward, and direct-import providers/screens/tests selected by the
source inventory.

**Actions:**

- [ ] Inventory each create, edit, delete, bulk delete, undo, and partial-save
  boundary against existing DS slice evidence.
- [ ] Prefer verification closure when current tests already prove the path.
- [ ] Fix only one shared module/test-family boundary per slice.
- [ ] Re-run import relationship tests after any import mapping change.

**Inventory and focused commands:**

```powershell
rg -n "missing parent|orphan|stale|delete|undo|relationship|tankId|false success" lib test
flutter test test/services/backup_import_relationships_test.dart --reporter compact
flutter test test/services/backup_import_service_test.dart --reporter compact
```

**Phase gate:**

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full
```

## Phase 2: Optional AI And Preferences

### Task 2.1: Audit real current AI writes (`DCL-AI-001`)

**Inspect:**

- `lib/screens/smart_screen.dart`
- `lib/features/smart/symptom_triage/symptom_triage_screen.dart`
- `lib/features/smart/weekly_plan/weekly_plan_screen.dart`
- `lib/features/smart/fish_id/fish_id_screen.dart`
- `lib/features/smart/smart_providers.dart`
- `test/widget_tests/smart_screen_test.dart`
- `test/widget_tests/symptom_triage_screen_test.dart`
- `test/widget_tests/weekly_plan_screen_test.dart`

**Actions:**

- [ ] Classify every current AI output as no-write, confirmed local write, or
  unconfirmed local write.
- [ ] Verify cancel leaves storage unchanged and confirm writes exactly once.
- [ ] Close by audit evidence if no unconfirmed current write exists. Do not
  invent a write path to satisfy the row.

### Task 2.2: Close provider/privacy preference truth (`DCL-PREF-001`)

**Inspect:**

- `lib/screens/settings/settings_screen.dart`
- `lib/screens/privacy_policy_screen.dart`
- `lib/features/smart/ai_disclosure_preferences.dart`
- `lib/features/smart/openai_disclosure_gate.dart`
- `test/widget_tests/settings_hub_screen_test.dart`
- `test/widget_tests/privacy_policy_screen_test.dart`
- `test/widget_tests/smart_ai_setup_copy_contract_test.dart`

**Exit:** keyless state, provider status, disclosure persistence, release key
policy, and privacy copy are verified without enabling parked providers.

## Phase 3: Accepted Normal-User Depth

- [x] Treat `DCL-P1-001` and `DCL-P1-002` as accepted current-scope
  boundaries; do not reopen their parked expansion during Phase 3.
- [ ] Audit guided-tool save/apply handoffs for `DCL-P1-003` using calculator
  widget tests and page 07 atlas evidence.
- [ ] Audit timeline/journal source labels and save handoffs for `DCL-P1-004`
  using `lib/screens/journal_screen.dart` and
  `test/widget_tests/journal_screen_test.dart`.
- [ ] Select one learning path cluster for `DCL-P1-005`; ground any visual
  work in the current lesson/practice screenshots and add focused widget or
  content proof.
- [ ] Select one concrete species/plant source, image, or depth gap for
  `DCL-P1-006`; run database/content validation after the change.
- [ ] Do not combine Living Tank, rewards, learning, and species expansion in
  one slice.

## Phase 4: Content And Rule Confidence

**Primary tests:**

- `test/quality/content_validation_test.dart`
- current compatibility, stocking, emergency, unit, calculator, species, and
  local-intelligence service tests selected by the audit.

**Actions:**

- [ ] Pick one related risk cluster per slice.
- [ ] Write the failing validator/rule test before content or rule changes.
- [ ] Preserve educational positioning and professional escalation language.
- [ ] Run content validation and the Focused gate after each cluster.

```powershell
flutter test test/quality/content_validation_test.dart --reporter compact
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused
```

## Phase 5: Phone Accessibility, Visual Quality, And Motion

Use Figma pages 02 through 11 as the current visual target and gap register.
Tablet evidence is not part of this phase.

**Inspect:**

- `lib/utils/accessibility_utils.dart`
- `lib/widgets/reduced_motion_media_query.dart`
- `lib/providers/reduced_motion_provider.dart`
- `lib/utils/haptic_feedback.dart`
- `lib/widgets/room/`
- `docs/design/BASELINES.md`
- `docs/design/VISUAL_QA_CHECKLIST.md`
- `test/quality/visual_baseline_manifest_test.dart`
- `test/golden_tests/`

**Cluster order:**

1. Tank and daily-care actions.
2. Learn, Practice, and story interactions.
3. Smart local/no-key surfaces.
4. More, tools, species, rewards, and preferences.
5. First run and destructive/data-recovery dialogs.

**Per-cluster checks:** contrast, 48dp targets, semantics, large text, reduced
motion, non-colour-only state, clipping, asset quality, and stable selective
goldens. Add motion or haptics only when it clarifies feedback.

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Visual
```

## Phase 6: Phone Performance

**Inspect:**

- `docs/agent/PERFORMANCE_TARGETS.md`
- `lib/utils/performance_targets.dart`
- `lib/utils/performance_monitor.dart`
- `test/utils/performance_targets_test.dart`

**Measure on the owned Danio phone target:** cold startup, warm resume, tab
switching, tank animation, representative long-list scrolling, and first local
image paint. Summarize measurements without committing noisy raw logs. Fix only
reproducible target misses.

```powershell
.\scripts\run_danio_live_preview.ps1 -CheckOnly
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep
flutter test test/utils/performance_targets_test.dart --reporter compact
```

## Phase 7: Final Phone Candidate

- [ ] Confirm every higher phone ledger row is closed, accepted, or explicitly
  parked.
- [ ] Confirm the Figma state matrix matches the ledger.
- [ ] Run Full, AndroidPrep, content validation, visual baseline, and product
  truth checks from clean `main`.
- [ ] Recheck phone routes/states affected since the atlas baseline.
- [ ] Write the final local phone QA note with commit, gates, Android evidence,
  accepted limits, and parked work.
- [ ] Do not start store, deploy, cloud, provider, premium, tablet, or iOS work
  from the phone release-candidate checkpoint.

## Slice Closeout Contract

Every implementation slice must:

1. Start from clean, aligned `main` on a short-lived branch.
2. Name the exact ledger row and state-matrix gap it advances.
3. Write the focused failing test first for behavior/data changes.
4. Run the smallest focused proof, then the ladder-required gate.
5. Update `ACTIVE_HANDOFF.md` and `SLICE_LOG.md`.
6. Update the ledger/Finish Map only when status genuinely changes.
7. Fast-forward merge, rerun required clean-main proof, push, and remove the
   temporary branch.
8. Leave `git status --short -uall` clean and `main...origin/main` at `0 0`.

## Figma Synchronization Contract

- Repo truth changes first; Figma status changes after verified merge.
- Keep current screenshots; do not replace evidence with speculative mockups.
- Mark a state `Verified` only after the corresponding repo proof exists.
- Mark accepted product limits explicitly rather than deleting the gap.
- Keep tablet and external lanes on the parked page until the user reopens
  them.

## First Product Slice After Workflow Setup And Explicit Launch

Product work remains blocked until the autonomous workflow setup, rehearsal,
Task 13 activation, and explicit launch readiness all pass. Automatic product
successor creation is disabled during bootstrap.

After explicit launch, start with a fresh read-only `DCL-DR-001` restore matrix
audit using Task 1.1. Implement only if that audit proves one specific current
false-success, rollback, cleanup, or failure-feedback gap.
