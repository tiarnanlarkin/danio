# Danio Finish Map

Status: Active phone release-candidate control layer
Created: 2026-06-24
Authority lock: `danio-completion-roadmap-authority-lock-2026-07-15/1`
Current authority marker: `danio-phone-rc-authority-reset-2026-07-19/1`
Ordered authority: `plans/2026-07-19-phone-release-candidate-finalization-plan.md`
Superseded authority: `plans/2026-07-11-phone-complete-local-completion-program.md`
Closure authority: `COMPLETE_LOCAL_CLOSURE_LEDGER.md`
Historical sources: `docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
and `docs/product/danio-complete-local-current-audit-2026-06-13.md`

## Purpose

This file keeps Danio's category status and quality bar objective. Use it to
record whether each product/quality category is complete and what evidence is
still missing. It does not choose or reorder the next phase.

Do not use this file as a replacement for the detailed product backlog. The
backlog owns feature history and acceptance details. This map owns current
category completion status, evidence expectations, and the quality bar. The
phone release-candidate finalization plan is the only ordered authority, and the
closure ledger owns row closure state, disposition, evidence, and exact done
conditions.

The `Ledger IDs` column is an exact traceability map. `none` means the category
closed before the DCL ledger existed and has no current ledger row; it is not an
untracked implementation target.

## Current Completion Boundary

The user confirmed on 2026-07-11 that the active complete-local target is a
polished, resilient, local-first Android phone app. Tablet implementation,
tablet polish, and tablet performance are parked until the phone phase closes.
Cloud/accounts, new Optional-AI provider connectors, premium, store/deploy,
public release, and iOS also remain parked. Android Keystore-backed secure-storage migration is closed under `DCL-PREF-001`.

Use `docs/agent/plans/2026-07-19-phone-release-candidate-finalization-plan.md`
for the finite P0/P1 release selector and ten planned product/test epochs. P2/P3
work is accepted or parked unless the user explicitly reopens it. Current repo
screenshots and assets govern
visual defects; Figma is optional downstream context. Repository source, tests,
ledger, and fresh gates remain authoritative.

On 2026-07-11 the user accepted the current Living Tank and rewards depth for
phone complete-local. Dedicated plant inventory, broader seasonal variants,
seasonal cosmetics, and deeper plant/decor collections are parked product
expansion rather than phone completion blockers.

On 2026-07-15 the user also accepted the current 82 lessons, 75+ species, and
40+ plants as sufficient breadth for phone completion. Additional content is
required only for a current audited defect or validator failure. Visual and
motion completion is likewise defect-based: there is no mandatory asset or
animation quota.

## Status Values

| Status | Meaning |
| --- | --- |
| Not started | No committed implementation exists for the complete-local bar. |
| In progress | Implementation exists, but product depth, tests, visual proof, or Android evidence is incomplete. |
| Parked | Intentionally outside the active phone phase; retained for later work and not a phone completion blocker. |
| Implemented | The feature exists and works in source-level review or focused tests. |
| Locally verified | Focused tests and the relevant local gate passed in the integration checkout. |
| Externally reviewed | Optional external review or device-lab evidence has been collected after local gates. |
| Done | Product, content, UI, accessibility, data safety, phone evidence, and tests meet the active complete-local bar. |

## Definition Of Done By Slice Type

| Slice type | Required proof before Done |
| --- | --- |
| Product behavior | Focused test, `Focused` gate, relevant widget/service coverage, no fake/dormant copy, and product docs updated when behavior changes. |
| UI or visual | Current screenshot/golden/mockup target, focused UI test or golden where practical, `Visual` gate, phone check, and no clipped/overlapping text. Tablet proof resumes only when the tablet phase reopens. |
| Content | Content validator passes, sources are traceable where claims need support, no placeholders, no unsafe care claims, and normal-user copy is readable. |
| Data safety | Failure-path tests, rollback or retry behavior, no false success states, and `Full` gate before commit. |
| Android QA | Device ownership is clear, `AndroidPrep` passes, screenshots or Patrol evidence are captured only from owned devices. |
| Optional AI | No-AI path still works, keyless state is calm and useful, writes require confirmation, and no unimplemented provider path is presented as working. |
| Paid/cloud quality lane | Local gates pass first, user approval is recorded in `PAID_TOOL_APPROVAL_LEDGER.md`, secrets stay outside Git, and results are treated as review evidence only. |

## Current Completion Map

| Area | Ledger IDs | Status | Current evidence | Next completion action |
| --- | --- | --- | --- | --- |
| Product spine P0 | none | Done | Backlog marks CL-P0-001 through CL-P0-007 done with tests and Android evidence where required. | Keep regression coverage active while later work changes shared flows. |
| First-run onboarding | none | Done | Final phone/tablet evidence exists under `docs/qa/screenshots/2026-06-22/cl-p0-004-first-run/`. | Recheck only if onboarding, profile, units, or first-run navigation changes. |
| Tank daily loop | none | Done | Final phone/tablet evidence exists under `docs/qa/screenshots/2026-06-22/cl-p0-005-tank-daily-loop/`. | Recheck whenever Tank, Today Board, tasks, or feed/test/change actions change. |
| Emergency access | none | Done | Emergency Guide is reachable from Tank, Smart, Search, More, lessons, species sheets, and unsafe water logging. | Keep emergency routes in smoke and search coverage. |
| No-AI Smart Hub | none | Done | Local Aquarium Intelligence exists with risks, suggestions, compatibility, anomaly history, and checked reasons. | Expand only through guided save/apply depth and optional AI confirmation work. |
| Living Tank | `DCL-P1-001` | Implemented | Water, stale-change, feeding, health, compatibility, aquascape, progression, and decoration cues exist; the user accepted this current depth for phone complete-local on 2026-07-11. | Keep the accepted scope stable and fix only concrete defects found during phone visual, accessibility, motion, or final-candidate checks. |
| Rewards and collectibles | `DCL-P1-002` | Implemented | Room vibes, achievement cosmetics, inventory access, and earned decoration equip controls exist; the user accepted this current depth for phone complete-local on 2026-07-11. | Keep the accepted scope stable and fix only concrete defects found during phone visual, accessibility, motion, or final-candidate checks. |
| Species and plants | `DCL-P1-006` | Done | Current 75+ species and 40+ plants include profiles, care actions, wishlist/tank/task handoffs, source trails, and a missing-entry request path; their accepted browser/validator suites and the reset-assisted Full gate passed in `DR-2026-07-22-067`. | Preserve accepted breadth; recheck only for changed paths or a concrete defect. |
| Learning | `DCL-P1-005` | Done | The current 82 lessons and structured guide paths are accepted breadth; validators, representative paths, and the reset-assisted Full gate passed in `DR-2026-07-22-067`. | Preserve accepted breadth; recheck only for changed paths or a concrete defect. |
| Practice | `DCL-P1-003` | Done | Skill Drills and scenario practice cover parameters, diagnosis, compatibility, setup, and emergency decisions, with distinct Learn entry points, SR provider error coverage, fallback-card prompts, and settled required gates in `DR-2026-07-22-067`. | Recheck only if practice or guided-tool behavior changes. |
| Guided tools | `DCL-P1-003` | Done | Major calculators have tank-context handoffs, explanations, warnings, and save/apply paths; accepted Workshop proof, all five Tank Volume shapes, and the reset-assisted Full gate passed in `DR-2026-07-22-067` without a concrete defect. | Recheck only for changed save/apply paths or contradictory current evidence. |
| Multi-tank | none | Done | Current local scope has priority overview, recent activity, swap action, and Android walkthrough evidence. | Recheck if tank switching, comparison, or all-tanks priority logic changes. |
| Timeline and journal | `DCL-P1-004` | Done | Unified timeline, tool result labels, milestone labels, AI note labels, contextual strips, and persistence paths passed focused proof and the reset-assisted Full gate in `DR-2026-07-22-067`. | Recheck only for changed label/context/persistence behavior or a concrete defect. |
| Backup and restore | `DCL-DR-001,DCL-DR-002,DCL-DR-004` | Done | `DR-2026-07-16-001` through `DR-2026-07-16-014` close restore, migration, and corruption recovery. `DR-2026-07-21-063` preserves deleted-livestock tombstones through self-generated preview/import without live-map entry or resurrection, while live and invalid relationships retain their required behavior; reset-assisted Full passed. | Recheck only if backup schema, preview/restore, relationship validation/remapping, or local storage behavior changes. |
| Preferences | `DCL-PREF-001` | Done | Units, region, tank stage, goals, haptics, reduced motion, reminder intensity, privacy, and AI disclosure controls exist. `DR-2026-07-21-066` routes Optional-AI credentials through Android Keystore-backed `ApiKeyStore`, safely migrates and clears the legacy preference, attempts both locations on deletion, disables automatic deletion on secure-store errors, and preserves keyless/provider/privacy honesty. | Recheck only if preferences, credential storage, migration/deletion, backup exclusion, provider/privacy behavior, or Android secure-storage configuration changes. |
| Global search | none | Done | Search covers destinations, tools, paths, guides, settings, species, equipment, livestock, logs, Tank entry, and More entry. | Add direct per-lesson deep links only if walkthrough evidence shows need. |
| Demo mode | none | Done | Resettable sample tank exists with final phone/tablet evidence. | Recheck only if sample data, onboarding skip, or tank seeding changes. |
| Tablet layout | `DCL-TAB-001` | Parked | Many surfaces have CL-P2-002 readability slices and the 96-row tablet map is locally verified. | No current action. Reopen after phone complete-local and define tablet polish/accessibility/performance from retained evidence. |
| Visual asset quality | `DCL-VIS-001` | In progress | The March visual asset audit is historical evidence, not current defect authority. July phone screenshots and current repo assets govern. | Inspect current phone evidence; fix each concrete asset, clipping, contrast, or source/licence defect found, or close with no-current-gap evidence. There is no replacement quota. |
| Accessibility | `DCL-A11Y-001` | In progress | Some 48dp, contrast, semantics, reduced-motion, and layout guardrails exist. | Run the five-cluster phone pass from the 2026-07-19 release-candidate plan with current screenshots and focused tests. |
| Motion and haptics | `DCL-MOTION-001` | In progress | Feeding pulse, reduced motion, and haptics preference integration exist. | Audit current animated and haptic flows; fix reduced-motion failures, haptic-preference bypasses, or concrete clarity defects only. No new-animation quota applies. |
| Performance | `DCL-PERF-001` | In progress | Complete-local Android targets are recorded in `docs/agent/PERFORMANCE_TARGETS.md` and enforced by `test/utils/performance_targets_test.dart`; the debug performance monitor now uses the shared 60 FPS frame-budget constant. | Add the profile-mode machine-readable harness and measure startup, warm resume, tab switching, tank feedback, scrolling, and local-image paint on `danio_api36`. Later tablet performance is tracked by `DCL-TAB-001`. |
| Optional AI providers | `DCL-EXT-001` | Parked | Optional AI setup names OpenAI as current BYO provider, disables other provider paths honestly, and treats build-time `OPENAI_API_KEY` as a local-dev-only fallback that is ignored in release builds. | No current action. Implement real non-OpenAI connectors only after explicit reopening. |
| AI confirmation | `DCL-AI-001` | Done | Symptom Triage, Weekly Plan, Ask Danio, Fish ID, and AI Compatibility persistence require confirmation. Fish ID and Compatibility have focused cancel/dismiss/no-write, confirm-once, and failure-visible proof; the bounded prior-surface regressions pass, and a source audit found no sixth AI-history caller. | Recheck only if a new AI-output persistence path is added or contradictory live evidence appears. |
| Premium AI path | `DCL-PREMIUM-001` | Parked | Premium remains conceptual and must not appear as fake product behavior. | No current action. Reopen only after the local phone app is excellent and real extra capability exists. |
| Citations | `DCL-P1-005,DCL-P1-006,DCL-CONTENT-001` | Done | Species/plant source trails and lesson/care HTTPS references passed focused proof and the reset-assisted Full gate in `DR-2026-07-22-067`; no concrete trust-critical source gap was exposed. | Recheck only when source/content paths change or a concrete trust gap is proven. |
| Whole-app phone audit | `DCL-RC-001` | Locally verified | Current phone screenshot/XML pass exists under `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/`, with notes in `docs/qa/whole-app-phone-map-2026-07-04.md`; the Smart/Fish ID bottom-dock overlap and smoke tap false positive are fixed locally with tests, the phone black-box smoke rerun passed, `phone-04b-smart-root-after-dock-fix` recaptures Fish & Plant ID clearing the dock by `47px`, QA-006 added 39 standalone deep-link captures, QA-007 added 24 fixed-build seeded tank/learning/story/cycling captures and fixed the Livestock skeleton duplicate-Hero regression, QA-008 added 16 first-run/onboarding/debug captures, and all 96 `SCREEN_INVENTORY.md` rows now have phone `Pass` accounting with 96 passes and 0 current gaps. | Recheck when app surfaces change or before release signoff. |
| Whole-app tablet audit | `DCL-TAB-001` | Locally verified | Current tablet screenshot/XML pass exists under `docs/qa/screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/`, with notes in `docs/qa/whole-app-tablet-map-2026-07-04.md`; smoke route assertions/tap handling and lower More hub tablet swipes are hardened locally with tests, the tablet black-box smoke rerun passed, QA-006 added 39 standalone deep-link captures, QA-007 added 24 fixed-build seeded tank/learning/story/cycling captures and fixed the Livestock skeleton duplicate-Hero regression, QA-008 added 16 first-run/onboarding/debug captures, and all 96 `SCREEN_INVENTORY.md` rows now have tablet `Pass` accounting with 96 passes and 0 current gaps. | Retain as later-phase evidence; do not recheck for the phone candidate unless tablet scope is explicitly reopened. |
| Visual regression | `DCL-VIS-002` | In progress | Current July phone screenshots, golden tests, and the visual baseline manifest provide a bounded baseline. | Validate the manifest and add targeted proof only for changed high-risk surfaces; close when current checks pass. No new-golden quota applies. |
| Rule tests | `DCL-RULE-001` | Done | `DR-2026-07-22-067` added the complete requested CompatibilityService matrix, all five Tank Volume values, and displayed Unit Converter numeric families; focused proof, independent review, and reset-assisted Full passed without exposing wrong behavior. | Reopen only for changed governed rules or contradictory executable evidence. |
| Content validation | `DCL-CONTENT-001` | Done | The finite accepted validator/source inventory passed in `DR-2026-07-22-067` without a content defect; the reset-assisted Full gate also passed. | Reopen only for changed content/source risks or a concrete uncovered validator gap. |
| Data resilience | `DCL-DR-001,DCL-DR-002,DCL-DR-003,DCL-DR-004` | Done | `DCL-DR-001` and `DCL-DR-002` are closed by complete ordered restore, migration, and corruption-recovery matrices. Backup/data hardening has broad coverage; achievement progress has lifecycle flush/restore-cancel and false-write retry coverage, achievement resetAll rejects failed local progress removal before clearing visible progress, lesson-completion achievement checks use persisted completed-lesson and perfect-score profile state, debug achievement reset rejects failed progress removal/profile writes and restores progress on profile-write failure, DebugMenu profile-write actions reject false local `user_profile` saves before showing success, Debug species reset rejects false local unlock writes, Debug Clear All Data rejects false local preference-clear results before showing restart copy, Debug Force SR Cards Due rejects false review-card writes before showing due-now success, Settings theme/notification/ambient/haptic writes now report durable-save failures, theme selection stays retryable when local theme persistence fails, Phone Notifications avoids false disabled-success feedback when local persistence fails, ambient/haptic switches show retry feedback when local saves fail, Preferences region/tank-stage/experience/goals edits stay retryable when profile persistence fails, and Reminder Settings review/streak toggles, reminder-intensity presets, and reminder-time edits show retry feedback when profile persistence fails, review-card create/seed/delete paths rollback on failed local writes, review reset keeps visible cards/stats and restores partially removed cards/stats/streak/session JSON when reset removal fails, gem and inventory resets reject false local removal results, room-vibe applies require durable preference saves before showing success, Reduce Motion override changes stay aligned with saved preferences, guidance and seasonal prompt dismissals only report dismissal after the local flag is saved, Tank returning-user prompt dismissals check failed seen-flag writes, the stage sheet hint uses the shared preferences provider and restores visible retry state when its seen-flag save fails, the energy explainer prompt is marked seen only after dismissal, all current OpenAI request surfaces including Ask Danio typed questions use the shared disclosure gate and stop before AI requests when the local disclosure flag cannot be saved, first-run consent/under-13 actions wait for durable preference writes before advancing, user-profile saves and resets treat false preference write/remove results as failures, schema migration stamps fail loudly when the version marker cannot be saved, backup preview and SharedPreferences restore reject wrong primitive value types for exportable preference keys before import/restore, backup restore extracts only archive photo files referenced by validated backup data, ignores duplicate archive-only photo basenames that backup data does not reference, scopes photo reference handling to current `imageUrl` and `photoUrls` fields so free-text path-like strings do not block valid backup operations, and now has executable proof that restored-photo cleanup runs when tank import fails after photo extraction and remains best-effort if cleanup fails in either the import flow or screen catch, direct tank-scoped backup imports reject child rows whose tank IDs are not imported, trim-empty required tank and child IDs, missing relationship targets, malformed relationship ID types, duplicate tank and child IDs, and cross-tank relationship targets before imported tank saves or success, bulk tank delete failures restore visible tanks and surface retry feedback, onboarding completion/reset/replay wait for durable local flag writes or show retry feedback, Delete My Data rejects false preference-clear results before destructive follow-up steps, Clear All Data copy matches its narrower local tank/log/task/photo scope, Add Log edits skip duplicate reward/progress side effects, Tank Settings saved edits close without dirty-prompt loops, equipment adds roll back partial equipment saves when maintenance-task sync fails, equipment-add, livestock-add, Quick Water Test, and practice-lesson progress failures no longer undo durable saves or show generic/false save success, single and bulk livestock adds roll back partial livestock/log saves when timeline-log persistence fails, livestock removal expiry skips timeline logs when the parent tank is missing, single livestock moves reject missing target tank IDs before saving moved livestock, Wishlist purchase rejects missing local item IDs before reporting success or applying budget spend, tank, log, task, equipment, and livestock edit submissions reject missing local record IDs before saving, Add Log, Livestock, Task, Equipment, Cycling Assistant reminder, bulk Livestock, Symptom Triage journal, Species detail care-task, Tank Journal manual-entry, and Tank Detail quick-feeding child save paths reject missing parent tank IDs before saving, Equipment delete Undo rejects missing parent tanks before restoring equipment or generated maintenance tasks, root lifecycle detach flushes pending gem writes before app-kill can skip the debounce timer, DS-2026-07-05-044 verified the current durable debounced-writer inventory as gems and achievement progress with lifecycle evidence, and gem, inventory, legacy inventory migration, review-card, review-session count, review-streak, reminder, cost-tracker, maintenance-checklist, difficulty-setting, review-request tracking, and API rate-limit writes reject false local save results. | F1 through F38 are settled and `DCL-DR-003` is closed. `DR-2026-07-21-062` proves and fixes Wishlist captured-callback replay; the complete matrix reinspection found no other current P0/P1 and parked lower-severity omission-only gaps. `DR-2026-07-21-063` closes `DCL-DR-004` with self-generated tombstone round-trip, live-normalization, non-resurrection, and preserved invalid-relationship proof; reset-assisted Full passed in 213,027 ms. All four data-resilience rows are closed; recheck only when their governed behavior changes. |
| Weekly Plan cache clear | none | Locally verified | Weekly Plan cache clear now waits for durable local `weekly_plan_cache` removal before hiding the visible plan, and failed removals leave the plan visible with a surfaced error. | Recheck if Weekly Plan cache, restore invalidation, or optional-AI save flows change. |
| Debug QA seeds | `DCL-QA-001` | Parked | Existing local seeds cover demo tank, lesson quiz/practice, unlock/progression, emergency unsafe-water, incompatible fish, skipped-onboarding quick start, no-AI Smart Hub, partial unlock edge, and visual stress. | No current action. Keyed-AI seed work remains parked unless explicitly reopened with an honest no-secret plan. |

## Historical Evidence Boundary

The 2026-07-04 roadmap snapshot, the superseded 2026-07-11 completion program,
and the March visual asset audit are historical evidence, not current defect
authority or executable work queues. They cannot rank, reopen, or create work.
The 2026-07-19 release-candidate plan owns the fixed sequence and P0/P1 release
selector; the closure ledger owns row state and done conditions; current source,
tests, validators, July phone screenshots, repo assets, and fresh commands own
factual truth.

The March visual asset audit may help explain an asset's history, but only a
defect reproduced in current phone evidence can require replacement. The same
rule applies to older accessibility, motion, content, and performance findings.

## Current Data-Resilience Note

- DS-2026-07-06-050 advances `DCL-DR-001` restore failure evidence:
  `BackupRestoreScreen` now routes screen-level restored-photo cleanup through
  a best-effort helper, so cleanup failures are logged and cannot prevent the
  normal import-failed reporting path.
- DS-2026-07-06-049 advances `DCL-DR-001` restore failure evidence:
  `BackupRestoreImportFlow` now treats restored-photo cleanup as best-effort
  after tank import failure, logs cleanup errors, and preserves the original
  tank import failure for user-visible/error handling.
- DS-2026-07-06-048 advances `DCL-DR-001` and `DCL-DR-004` import preflight
  evidence: direct tank-scoped imports now reject whitespace-only required
  backup tank and child record IDs before any imported tank save is attempted.
- DS-2026-07-06-047 advances `DCL-DR-004` import preflight evidence:
  direct tank-scoped imports now reject task/log relationship IDs whose backup
  targets are absent from imported child ID maps during relationship preflight,
  before any imported tank save is attempted.
- DS-2026-07-05-045 advances `DCL-DR-001` restore failure evidence:
  `BackupRestoreImportFlow` now accepts an import-failure cleanup callback,
  Backup & Restore wires it to `BackupService.cleanupLastRestoredPhotos()` for
  restore attempts that created local photo files, and focused service coverage
  verifies the callback runs when tank import fails after photo extraction.
- DS-2026-07-06-046 advances `DCL-DR-001` and `DCL-DR-004` import preflight
  evidence: direct tank-scoped imports now validate every child row `tankId`
  against the backup tank IDs before saving imported tanks, so known-invalid
  child references fail before any imported tank write is attempted.
- DS-2026-07-05-044 closes the current debounced-writer inventory gap:
  source audit found the durable debounced local writers are gems and
  achievement progress; gems flush on root paused/inactive/detached, achievement
  progress flushes on paused/detached, and focused lifecycle/persistence tests
  cover the current paths. The profile lifecycle observer flushes the
  already-visible profile snapshot after immediate saves, so it is not an open
  debounced-writer target. Future app-kill work should reopen only when a new
  durable debounced local writer is added or lifecycle evidence changes.
- DS-2026-07-05-043 closes a Backup Import relationship-type preflight gap:
  direct tank-scoped imports now reject malformed non-string
  `relatedEquipmentId`, `relatedLivestockId`, and `relatedTaskId` values during
  relationship validation before any imported tank save is attempted.
- DS-2026-07-05-042 closes a Backup Import malformed relationship-ID type gap:
  direct tank-scoped imports now reject non-string `relatedEquipmentId`,
  `relatedLivestockId`, and `relatedTaskId` values before reporting success,
  so malformed backup relationship fields cannot be silently cleared.
- DS-2026-07-05-041 closes a BackupService photo-field scope gap: backup
  export, preview, and restore now collect, convert, validate, and resolve
  photo references only from current `imageUrl` and `photoUrls` fields, so
  normal free-text fields can mention old `photos/` paths without blocking a
  valid backup while real missing or duplicate referenced photos still fail
  safely.
- DS-2026-07-05-040 closes a Backup Restore duplicate archive-photo validation
  gap: duplicate `photos/` basenames are now checked only when that filename is
  referenced by validated backup data, so stale archive-only duplicate photo
  entries do not block preview or restore while duplicate referenced photo
  sources still fail safely.
- DS-2026-07-05-039 closes a Backup Restore archive-only photo extraction gap:
  `BackupService.restoreBackup` now restores only archive `photos/` entries
  whose filenames are referenced by validated backup data, so valid tank
  restores do not leave unrelated archive-only photo files in local app storage
  or `lastRestoredPhotoPaths`.
- DS-2026-07-05-038 closes a Backup Import cross-tank relationship guard gap:
  `BackupImportService` now rejects task/log relationship IDs whose backup
  targets belong to a different backup tank from the source task/log, so direct
  tank-scoped imports cannot report success while preserving cross-tank
  `relatedEquipmentId`, `relatedLivestockId`, or `relatedTaskId` links.
- DS-2026-07-05-037 closes a Backup Import duplicate tank-ID guard gap:
  `BackupImportService` now rejects duplicate backup tank IDs before saving
  imported tanks, so direct tank-scoped imports cannot report success while
  duplicate backup tanks collapse relationship mapping onto one regenerated
  local tank ID.
- DS-2026-07-05-036 closes a Backup Import duplicate child-ID guard gap:
  `BackupImportService` now rejects duplicate `livestock`, `equipment`,
  `tasks`, and `logs` backup IDs before saving imported tanks, so direct
  tank-scoped imports cannot report success while duplicate backup child
  records collapse onto one regenerated local ID.
- DS-2026-07-05-035 closes a Backup Import relationship-ID guard gap:
  `BackupImportService` now rejects task/log relationship IDs whose backup
  targets were not imported, so direct tank-scoped imports roll back instead of
  reporting success while silently clearing `relatedEquipmentId`,
  `relatedLivestockId`, or `relatedTaskId` links.
- DS-2026-07-05-034 closes a Backup Import child-tank guard gap:
  `BackupImportService` now rejects livestock, equipment, task, and log rows
  whose backup `tankId` is absent from the imported tank map, so direct
  tank-scoped imports roll back instead of reporting success while silently
  skipping child rows.
- DS-2026-07-05-033 closes a Livestock removal expiry parent-tank gap:
  delayed `livestockRemoved` timeline logs now recheck the durable parent tank
  before saving, so a stale Livestock route cannot create an orphan local log
  after the tank is deleted during the undo window.
- DS-2026-07-05-032 closes a Backup Restore import-flow malformed-preferences
  warning gap: after a tank import succeeds, non-object `sharedPreferences`
  payloads now set `preferencesRestoreFailed` with a `FormatException` instead
  of being silently treated as absent.
- DS-2026-07-05-031 closes a backup preference type-restore gap:
  backup preview and SharedPreferences restore now reject exact exportable
  preference keys backed by the wrong primitive value type before preview,
  import, restore, or clearing existing preferences.
- DS-2026-07-05-030 closes a single livestock move stale-target gap:
  `TankActions.moveLivestock` now rechecks the durable target tank before
  saving the moved livestock record, so provider-level single moves cannot
  create orphan local livestock under a deleted target tank ID.
- DS-2026-07-05-029 closes an Equipment delete Undo orphan-record gap:
  equipment undo now rechecks the durable parent tank before restoring the
  deleted equipment or generated maintenance task, so stale snackbar undo
  actions cannot recreate orphan local records after tank deletion.
- DS-2026-07-04-017 closes a Tank Detail quick-feeding orphan-log gap: quick
  feeding now rechecks the durable tank in storage before saving the feeding
  log, so a stale open Tank Detail route cannot create local journal data after
  tank deletion.
- DS-2026-07-04-016 closes a Tank Journal orphan-log gap: manual journal entry
  saves now recheck the durable tank in storage before saving the observation
  log, so a stale open Journal route cannot create local journal data after tank
  deletion.
- DS-2026-07-04-015 closes a Species detail orphan-task gap: care-task create
  actions now recheck the durable tank in storage before creating or updating
  the task, so stale cached tank lists cannot create local species care tasks
  after tank deletion.
- DS-2026-07-04-014 closes a Symptom Triage orphan-log gap: confirmed AI
  diagnosis journal saves now recheck the durable tank in storage before saving
  the log or AI history, so stale cached tank lists cannot create orphan local
  journal data after tank deletion.
- DS-2026-07-04-013 closes a bulk livestock orphan-child gap: bulk add now
  rechecks the parent tank in storage before saving livestock or timeline logs,
  so a stale open sheet cannot create local child data after its tank was
  deleted.
- DS-2026-07-04-012 closes a guided-tool orphan-task gap: Cycling Assistant now
  rechecks the parent tank in storage before saving a phase-aware reminder, so a
  stale open assistant cannot create a local task after its tank was deleted.
- DS-2026-07-04-011 closes a Backup & Restore import-flow false-write gap:
  backups that import zero local tanks now skip app-wide SharedPreferences
  restore, so profile, learning, gem, and settings data are not silently
  replaced while the UI reports "No tanks found in this backup file."

## Current Optional AI Note

- `DR-2026-07-21-066` closes `DCL-PREF-001`: Optional-AI credentials use
  Android Keystore-backed secure storage through `ApiKeyStore`; migration
  retains the legacy value until secure persistence succeeds, deletion attempts
  both locations, and secure-store errors cannot silently reset the key. The
  128-test Focused gate, independent review, no-added-plaintext audit, and
  reset-assisted Full with 2,303 tests/analyze/APK pass.
- Fish ID and AI Compatibility now display their result before asking to save
  Recent AI Activity; Cancel and system back write nothing, Save Activity
  writes once, and a failed history write leaves the result visible. Fish ID
  proof uses an injected picker seam and never invokes the platform picker.
  The bounded existing regressions for Symptom Triage, Weekly Plan, Ask Danio,
  and Fish ID pass, the source audit found exactly five AI-history callers, and
  `DCL-AI-001` is closed.
- AI-2026-07-04-012 closes the Ask Danio local-history confirmation gap: typed
  Ask Danio answers remain visible immediately, but saving the question summary
  to Recent AI Activity now requires explicit confirmation.
- AI-2026-07-04-011 closes the Ask Danio disclosure-gate gap: typed Ask Danio
  questions now use the shared Optional AI disclosure gate before any OpenAI
  request can send text off-device.
- AI-2026-07-04-010 closes the direct OpenAI release-key policy gap:
  app-owned build-time `OPENAI_API_KEY` values are local-development only and
  are ignored in release builds. Release Optional AI must use a user-supplied
  BYO key or a configured proxy path.

## Current Product-Honesty Note

- SEC-2026-07-04-011 closes the cloud backup keying copy gap: signed-in Account
  backup actions no longer call the cloud backup "encrypted" in user-facing
  copy, and `CloudBackupService` documents that the current backup blob
  encryption is account-keyed rather than user-held or end-to-end.
- SEC-2026-07-04-012 closes the Optional AI Privacy Policy scope gap: the policy
  now names Fish ID photos, symptom descriptions, stocking or compatibility
  requests, and weekly-plan tank context instead of describing Optional AI as
  Fish ID/photo-only.

## Slice Selection Rule

`DCL-DR-001` and `DCL-DR-002` are closed. `DCL-DR-003-F1` through
`DCL-DR-003-F38` are settled evidence. Epoch `DR-2026-07-21-062` fixes the
Wishlist double-submit/captured-callback replay P1 and the complete current
matrix reinspection found no contradictory P0/P1. Settled findings F1 through F38
have no contradictory live evidence. Lower-severity omission-only
evidence gaps are parked under the P2/P3 selector. The reset-assisted Full gate
passed 2,279 tests/lint/analyze/APK at `GATE_TOTAL|PASS|187023|Full`, so
`DCL-DR-003` is closed and `DCL-DR-004` is next.
The P0/P1 release selector retains `DCL-DR-003-F34` as settled Tank Detail
history and does not reopen it while executing the remaining fixed sequence.

This map may record a newly discovered regression or higher-risk category, but
it cannot silently select a different product row. Frozen claim, budget,
launch, closeout, and successor material cannot select, reorder, resume, or
authorize product work. Stop for a product decision when live evidence would
change phase order or the locked scope.

## Evidence Recording Rule

Update `ACTIVE_HANDOFF.md` once per epoch and add one concise `SLICE_LOG.md`
row at epoch closeout. Update other evidence only when its underlying truth
changes:

- This file only when an overall completion status, product selection rule, or
  quality-bar summary changes.
- The closure ledger only when a finding's state, disposition, evidence, or done
  condition changes.
- Product/backlog, research, workflow, screen, screenshot, approval, or device
  docs only when the corresponding acceptance, policy, evidence, approval, or
  ownership state changes.

Keep evidence concise. Do not add screenshots or logs that do not prove a
decision, fix, or completed acceptance criterion.
