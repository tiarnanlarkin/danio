# Danio Finish Map

Status: Active completion control layer
Created: 2026-06-24
Source of truth: `docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
and `docs/product/danio-complete-local-current-audit-2026-06-13.md`

## Purpose

This file keeps autonomous Danio completion work objective. Use it before each
slice to choose the next highest-value gap, define done criteria, and record the
evidence needed before a feature can be called complete.

Do not use this file as a replacement for the detailed product backlog. The
backlog owns feature history and acceptance details. This map owns current
completion status, evidence expectations, and the quality bar for each work
category.

## Current Completion Boundary

The user confirmed on 2026-07-11 that the active complete-local target is a
polished, resilient, local-first Android phone app. Tablet implementation,
tablet polish, and tablet performance are parked until the phone phase closes.
Cloud/accounts, API-key/provider expansion, premium, store/deploy, public
release, and iOS also remain parked.

Use `docs/agent/plans/2026-07-11-phone-complete-local-completion-program.md`
for the ordered execution phases and the Danio phone atlas in Figma for the
visual state/gap control surface. Repository source, tests, ledger, and fresh
gates remain authoritative.

On 2026-07-11 the user accepted the current Living Tank and rewards depth for
phone complete-local. Dedicated plant inventory, broader seasonal variants,
seasonal cosmetics, and deeper plant/decor collections are parked product
expansion rather than phone completion blockers.

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

| Area | Status | Current evidence | Next completion action |
| --- | --- | --- | --- |
| Product spine P0 | Done | Backlog marks CL-P0-001 through CL-P0-007 done with tests and Android evidence where required. | Keep regression coverage active while later work changes shared flows. |
| First-run onboarding | Done | Final phone/tablet evidence exists under `docs/qa/screenshots/2026-06-22/cl-p0-004-first-run/`. | Recheck only if onboarding, profile, units, or first-run navigation changes. |
| Tank daily loop | Done | Final phone/tablet evidence exists under `docs/qa/screenshots/2026-06-22/cl-p0-005-tank-daily-loop/`. | Recheck whenever Tank, Today Board, tasks, or feed/test/change actions change. |
| Emergency access | Done | Emergency Guide is reachable from Tank, Smart, Search, More, lessons, species sheets, and unsafe water logging. | Keep emergency routes in smoke and search coverage. |
| No-AI Smart Hub | Done | Local Aquarium Intelligence exists with risks, suggestions, compatibility, anomaly history, and checked reasons. | Expand only through guided save/apply depth and optional AI confirmation work. |
| Living Tank | Implemented | Water, stale-change, feeding, health, compatibility, aquascape, progression, and decoration cues exist; the user accepted this current depth for phone complete-local on 2026-07-11. | Keep the accepted scope stable and fix only concrete defects found during phone visual, accessibility, motion, or final-candidate checks. |
| Rewards and collectibles | Implemented | Room vibes, achievement cosmetics, inventory access, and earned decoration equip controls exist; the user accepted this current depth for phone complete-local on 2026-07-11. | Keep the accepted scope stable and fix only concrete defects found during phone visual, accessibility, motion, or final-candidate checks. |
| Species and plants | Implemented | Current guide pass includes profiles, care actions, wishlist/tank/task handoffs, source trails, and missing-species request path. | Expand database depth, image quality, and content sources during content-polish passes. |
| Learning | In progress | Structured guide coverage exists for all current paths, placeholder placement CTA is hidden until a real flow exists, path-load failures show retryable errors, story play asks before leaving mid-story progress, locked story cards explain unlock requirements, and path cards now open a dedicated full-screen sequence view from a short inline preview. | Add richer visuals, practice links, scenarios, citations, and broader interaction variety. |
| Practice | Implemented | Skill Drills and scenario practice cover parameters, diagnosis, compatibility, setup, and emergency decisions, with distinct Learn entry points, SR provider error coverage, and fallback-card reveal prompts. | Add persisted tool-result context only where walkthroughs prove it improves flow. |
| Guided tools | In progress | Major calculators have tank-context handoffs, explanations, warnings, and save/apply paths. | Close any remaining tool-specific save/apply gaps found by walkthroughs. |
| Multi-tank | Done | Current local scope has priority overview, recent activity, swap action, and Android walkthrough evidence. | Recheck if tank switching, comparison, or all-tanks priority logic changes. |
| Timeline and journal | In progress | Unified timeline, tool result labels, milestone labels, AI note labels, and contextual strips exist. | Finish future source-specific guided-tool and optional-AI save handoff walkthroughs. |
| Backup and restore | In progress | Extensive validation, rollback, undo, import transaction, referenced-photo-only restore extraction, referenced-photo duplicate archive validation, photo-field-scoped backup photo handling, restored-photo cleanup on tank-import failure, best-effort restored-photo cleanup failure reporting in both import flow and screen catch, no-tank preference-restore guard, malformed import preference-payload reporting, direct child-tank import guard, direct relationship-ID import guards including malformed-type, trim-empty required ID preflight, pre-save malformed-type preflight, and cross-tank relationship rejection, migration, corruption recovery, and account-keyed cloud backup copy honesty work exists. | Continue edit/delete/undo coverage plus restore and migration Android walkthrough QA. |
| Preferences | In progress | Units, region, tank stage, goals, haptics, reduced motion, reminder intensity, privacy, AI disclosure controls, and Optional AI privacy-policy scope copy exist. | Finish final AI/provider walkthrough gaps. |
| Global search | Done | Search covers destinations, tools, paths, guides, settings, species, equipment, livestock, logs, Tank entry, and More entry. | Add direct per-lesson deep links only if walkthrough evidence shows need. |
| Demo mode | Done | Resettable sample tank exists with final phone/tablet evidence. | Recheck only if sample data, onboarding skip, or tank seeding changes. |
| Tablet layout | Parked | Many surfaces have CL-P2-002 readability slices and the 96-row tablet map is locally verified. | No current action. Reopen after phone complete-local and define tablet polish/accessibility/performance from retained evidence. |
| Visual asset quality | Not started | Older audit notes still identify weak or mismatched assets. | Audit current screenshots, regenerate weak headers/backgrounds/sprites, and add missing badges/decorations. |
| Accessibility | In progress | Some 48dp, contrast, semantics, reduced-motion, and layout guardrails exist. | Run the ordered phone-cluster accessibility pass from the 2026-07-11 completion program with current screenshots and focused tests. |
| Motion and haptics | In progress | Feeding pulse, reduced motion, and haptics preference integration exist. | Add purposeful motion to rewards, warnings, onboarding, and tank life only where it improves clarity. |
| Performance | In progress | Complete-local Android targets are recorded in `docs/agent/PERFORMANCE_TARGETS.md` and enforced by `test/utils/performance_targets_test.dart`; the debug performance monitor now uses the shared 60 FPS frame-budget constant. | Measure startup, warm resume, tab switching, tank animation, scrolling, and image loading on the owned Android phone target. Tablet measurement is parked. |
| Optional AI providers | Parked | Optional AI setup names OpenAI as current BYO provider, disables other provider paths honestly, and treats build-time `OPENAI_API_KEY` as a local-dev-only fallback that is ignored in release builds. | No current action. Implement real non-OpenAI connectors only after explicit reopening. |
| AI confirmation | In progress | Symptom Triage journal saves, Symptom Triage AI history writes, Weekly Plan care-plan cache saves, and Ask Danio Recent AI Activity saves now require confirmation before AI output becomes saved app data. | Audit every current AI write; add confirmation only for a real unconfirmed tank-data, task, or reminder write, or close the row with no-current-gap evidence. |
| Premium AI path | Parked | Premium remains conceptual and must not appear as fake product behavior. | No current action. Reopen only after the local phone app is excellent and real extra capability exists. |
| Citations | In progress | Species/plant source trails and lesson references exist in limited form. | Add subtle source trails where they improve trust without damaging visual quality. |
| Whole-app phone audit | Locally verified | Current phone screenshot/XML pass exists under `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/`, with notes in `docs/qa/whole-app-phone-map-2026-07-04.md`; the Smart/Fish ID bottom-dock overlap and smoke tap false positive are fixed locally with tests, the phone black-box smoke rerun passed, `phone-04b-smart-root-after-dock-fix` recaptures Fish & Plant ID clearing the dock by `47px`, QA-006 added 39 standalone deep-link captures, QA-007 added 24 fixed-build seeded tank/learning/story/cycling captures and fixed the Livestock skeleton duplicate-Hero regression, QA-008 added 16 first-run/onboarding/debug captures, and all 96 `SCREEN_INVENTORY.md` rows now have phone `Pass` accounting with 96 passes and 0 current gaps. | Recheck when app surfaces change or before release signoff. |
| Whole-app tablet audit | Locally verified | Current tablet screenshot/XML pass exists under `docs/qa/screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/`, with notes in `docs/qa/whole-app-tablet-map-2026-07-04.md`; smoke route assertions/tap handling and lower More hub tablet swipes are hardened locally with tests, the tablet black-box smoke rerun passed, QA-006 added 39 standalone deep-link captures, QA-007 added 24 fixed-build seeded tank/learning/story/cycling captures and fixed the Livestock skeleton duplicate-Hero regression, QA-008 added 16 first-run/onboarding/debug captures, and all 96 `SCREEN_INVENTORY.md` rows now have tablet `Pass` accounting with 96 passes and 0 current gaps. | Retain as later-phase evidence; do not recheck for the phone candidate unless tablet scope is explicitly reopened. |
| Visual regression | In progress | Golden tests and visual baseline manifest exist. | Add selective core-surface goldens/screenshots after visual targets stabilize. |
| Rule tests | In progress | Rule coverage exists for some local intelligence and tool paths. | Expand recommendation, compatibility, emergency, unit, and calculation tests. |
| Content validation | In progress | Content validator exists and runs in the focused gate, including emergency/distress lesson checks for educational positioning, aquatic-vet/professional escalation copy, direct prerequisite-free access, UK-style litre/litres volume spelling, metric context for gallon and Fahrenheit references in learning copy, warning-section coverage for medical/emergency lessons, unsafe/product-endorsing care copy, brand-specific emergency-product certainty claims, brand-specific conditioner/test-kit product names, learning graph IDs/prerequisites, per-lesson source density, quiz answer indexes, lesson section presence, and lesson reward/duration ranges. | Expand validation for broader locked-content coverage and any remaining source/content-risk gaps found during future audits. |
| Data resilience | In progress | Backup/data hardening has broad coverage; achievement progress has lifecycle flush/restore-cancel and false-write retry coverage, achievement resetAll rejects failed local progress removal before clearing visible progress, lesson-completion achievement checks use persisted completed-lesson and perfect-score profile state, debug achievement reset rejects failed progress removal/profile writes and restores progress on profile-write failure, DebugMenu profile-write actions reject false local `user_profile` saves before showing success, Debug species reset rejects false local unlock writes, Debug Clear All Data rejects false local preference-clear results before showing restart copy, Debug Force SR Cards Due rejects false review-card writes before showing due-now success, Settings theme/notification/ambient/haptic writes now report durable-save failures, theme selection stays retryable when local theme persistence fails, Phone Notifications avoids false disabled-success feedback when local persistence fails, ambient/haptic switches show retry feedback when local saves fail, Preferences region/tank-stage/experience/goals edits stay retryable when profile persistence fails, and Reminder Settings review/streak toggles, reminder-intensity presets, and reminder-time edits show retry feedback when profile persistence fails, review-card create/seed/delete paths rollback on failed local writes, review reset keeps visible cards/stats and restores partially removed cards/stats/streak/session JSON when reset removal fails, gem and inventory resets reject false local removal results, room-vibe applies require durable preference saves before showing success, Reduce Motion override changes stay aligned with saved preferences, guidance and seasonal prompt dismissals only report dismissal after the local flag is saved, Tank returning-user prompt dismissals check failed seen-flag writes, the stage sheet hint uses the shared preferences provider and restores visible retry state when its seen-flag save fails, the energy explainer prompt is marked seen only after dismissal, all current OpenAI request surfaces including Ask Danio typed questions use the shared disclosure gate and stop before AI requests when the local disclosure flag cannot be saved, first-run consent/under-13 actions wait for durable preference writes before advancing, user-profile saves and resets treat false preference write/remove results as failures, schema migration stamps fail loudly when the version marker cannot be saved, backup preview and SharedPreferences restore reject wrong primitive value types for exportable preference keys before import/restore, backup restore extracts only archive photo files referenced by validated backup data, ignores duplicate archive-only photo basenames that backup data does not reference, scopes photo reference handling to current `imageUrl` and `photoUrls` fields so free-text path-like strings do not block valid backup operations, and now has executable proof that restored-photo cleanup runs when tank import fails after photo extraction and remains best-effort if cleanup fails in either the import flow or screen catch, direct tank-scoped backup imports reject child rows whose tank IDs are not imported, trim-empty required tank and child IDs, missing relationship targets, malformed relationship ID types, duplicate tank and child IDs, and cross-tank relationship targets before imported tank saves or success, bulk tank delete failures restore visible tanks and surface retry feedback, onboarding completion/reset/replay wait for durable local flag writes or show retry feedback, Delete My Data rejects false preference-clear results before destructive follow-up steps, Clear All Data copy matches its narrower local tank/log/task/photo scope, Add Log edits skip duplicate reward/progress side effects, Tank Settings saved edits close without dirty-prompt loops, equipment adds roll back partial equipment saves when maintenance-task sync fails, equipment-add, livestock-add, Quick Water Test, and practice-lesson progress failures no longer undo durable saves or show generic/false save success, single and bulk livestock adds roll back partial livestock/log saves when timeline-log persistence fails, livestock removal expiry skips timeline logs when the parent tank is missing, single livestock moves reject missing target tank IDs before saving moved livestock, Wishlist purchase rejects missing local item IDs before reporting success or applying budget spend, tank, log, task, equipment, and livestock edit submissions reject missing local record IDs before saving, Add Log, Livestock, Task, Equipment, Cycling Assistant reminder, bulk Livestock, Symptom Triage journal, Species detail care-task, Tank Journal manual-entry, and Tank Detail quick-feeding child save paths reject missing parent tank IDs before saving, Equipment delete Undo rejects missing parent tanks before restoring equipment or generated maintenance tasks, root lifecycle detach flushes pending gem writes before app-kill can skip the debounce timer, DS-2026-07-05-044 verified the current durable debounced-writer inventory as gems and achievement progress with lifecycle evidence, and gem, inventory, legacy inventory migration, review-card, review-session count, review-streak, reminder, cost-tracker, maintenance-checklist, difficulty-setting, review-request tracking, and API rate-limit writes reject false local save results. | Finish remaining restore, migration, create/edit/delete, and relationship-mapping walkthrough coverage. Re-open debounced-writer app-kill work only when a new durable debounced local writer is added or lifecycle evidence changes. |
| Weekly Plan cache clear | Locally verified | Weekly Plan cache clear now waits for durable local `weekly_plan_cache` removal before hiding the visible plan, and failed removals leave the plan visible with a surfaced error. | Recheck if Weekly Plan cache, restore invalidation, or optional-AI save flows change. |
| Debug QA seeds | In progress | Existing debug QA seeds now include demo tank, lesson quiz/practice, unlock/progression controls, emergency unsafe-water, incompatible-fish, skipped-onboarding quick-start, no-AI Smart Hub, partial unlock-edge, and tablet visual-stress seeds. | Add any real keyed-AI seed only when it can avoid fake provider readiness. |

## Finish-Line Roadmap Snapshot - 2026-07-04

This roadmap was written after the housekeeping handoff was resumed on `main`,
the remote was fetched, and the current source, tests, screen inventory, phone
map, tablet map, backlog, and audit docs were re-read. It ranks the remaining
work from the current local completion bar; it is not a replacement for the
detailed backlog acceptance history.

Current baseline:

- Source of truth is `main`; it was fetched and confirmed aligned with
  `origin/main` before this roadmap was written, and this planning slice is
  intended to leave `main` pushed and clean.
- Current phone and tablet whole-app maps are locally verified with all 96
  `SCREEN_INVENTORY.md` rows accounted for and 0 current visual capture gaps.
- The last broad product/docs verification passed `git diff --check`,
  `flutter test test/copy/current_docs_local_truth_test.dart --reporter
  compact`, `flutter analyze`, and
  `flutter build apk --debug --target lib/main.dart`.
- The next development push should not reopen broad screen-mapping work unless
  a surface changes or release signoff begins.

Acceleration note:

- The current phone-only path is documented in
  `docs/agent/plans/2026-07-11-phone-complete-local-completion-program.md`.
  Future agents may use bounded epoch mode for 1 to 3 related micro-slices per
  session when the plan's startup checks, proof requirements, stop conditions,
  and closeout gates are satisfied. This changes session shape only; it does
  not lower the test, Full gate, docs, merge, push, or device-ownership bar.

Traceability note:

- The finite closure list is now owned by
  `docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md`. Future implementation slices
  must link to the ledger finding ID they advance before editing product code.
  The local proof rules are in
  `docs/agent/VERIFIED_SLICE_EXECUTION_CONTRACT.md`, and the expected remaining
  epoch count is in `docs/agent/COMPLETE_LOCAL_FORECAST.md`. If this roadmap,
  the ledger, handoff, and source/test evidence disagree, stop and reconcile
  the docs before implementing.

### Ranked Roadmap

| Rank | Lane | Why it comes here | Exit evidence |
| --- | --- | --- | --- |
| 1 | Data resilience closeout (`CL-P1-009`, `CL-QA-006`) | This remains the highest-priority open local-first risk. Recent slices closed stale edit IDs, missing parent tanks, false local writes, import no-tank preference restore, schema stamp failure, app-kill gem flush gaps, and current debounced-writer inventory, but restore, migration, broader create/delete walkthroughs, and relationship mapping still need closure evidence. | Focused failure-path tests, `Full` gate before commit, updated backlog/finish map entries, and Android walkthrough evidence only when device ownership is clear. |
| 2 | Optional AI confirmation closeout (`CL-P3-002`, Preferences/Smart) | Current AI writes to journal/history/cache now require confirmation, but the finish bar still requires confirmation before any AI-driven tank data, task, or reminder write. Do not create fake AI write paths just to close this; audit current surfaces and only add confirmation where a real current write exists. | Focused no-write/cancel tests, keyless/no-AI path test, relevant Focused or Full gate, and product docs updated if behavior changes. |
| 3 | Normal-user P1 depth (`Guided tools`, `Timeline`, `Learning`, `Species and plants`) | Living Tank and rewards breadth are accepted for the current phone scope. Remaining P1 work should stay narrow and be grounded in current screenshots, tests, or walkthrough findings. | Per-surface focused tests, visual or Android evidence for UI changes, and status updates only when a row genuinely advances. |
| 4 | Content and rule confidence (`CL-QA-005`, `Rule tests`, `Citations`) | The app has broad learning/species content and validation, but launch confidence still needs broader locked-content/source-risk checks and more rule coverage for recommendations, compatibility, emergency, units, and calculator behavior. | Content validation tests, targeted service/rule tests, source-trail updates where useful, and no unsafe care or veterinary-positioning drift. |
| 5 | Phone accessibility and visual polish (`CL-P2-001`, `CL-P2-003` through `CL-P2-005`, `CL-QA-003`) | Phone routes are mapped, but accessibility, selective visual regression, weak assets, and motion/haptic acceptance remain open. Any material UI or asset change must start from a current screenshot, golden, Figma frame, or design doc. | Visual gate, focused accessibility/widget tests, selective goldens or screenshots, and updated evidence for changed phone surfaces. |
| 6 | Phone performance measurement (`CL-P2-006`) | Performance targets and constants exist, but owned Android phone measurement has not yet closed the active complete-local bar. This follows reliability and major UI churn so measurements are stable. | Profile or release evidence for cold start, warm resume, tab switching, tank animation, scrolling, and local image first paint, recorded without noisy raw logs. |
| 7 | Final phone release-candidate evidence | This is last because it only has value after the open phone quality lanes above are closed or explicitly accepted/parked. | `Full` gate, `AndroidPrep`, affected phone-state recheck, content validation, visual baseline checks, product-truth scan, and a final phone QA note. |

Tablet, non-OpenAI provider, premium, keyed-AI seed, store/release, cloud,
deploy, account-backed, and iOS work remain outside this ranked phone roadmap.

### Next Development Push

Recommended next push: continue `CL-P1-009` / `CL-QA-006` data-resilience
closeout from fresh repo evidence. Pick one concrete current restore,
migration, create/delete, or relationship-mapping gap and prove it RED/GREEN
before production edits.

First files to inspect:

- `lib/screens/backup_restore_screen.dart`
- `lib/services/backup_import_service.dart`
- `lib/utils/schema_migration.dart`
- `test/services/backup_import_service_test.dart`
- `test/widget_tests/backup_restore_screen_test.dart`
- `test/utils/schema_migration_test.dart`
- `test/screens/app_lifecycle_contract_test.dart`

Done for the next slice means one concrete restore, migration, create/delete,
or relationship-mapping gap is proven red, fixed green, or verified as
no-current-gap with focused evidence, and then checked with the data-safety
row of `QUALITY_LADDER.md`. Prefer
local tests and `Full` gate first; use Android walkthrough evidence only after
`DEVICE_OWNERSHIP.md` preflight is clear.

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

Choose the next slice in this order:

1. Any P0 regression or broken local-first/product-honesty rule.
2. Any data-loss, restore, backup, or false-success risk.
3. Any phone/tablet blocker on a main workflow.
4. Remaining P1 depth needed for normal users.
5. P2 visual, accessibility, motion, and performance polish.
6. P3 optional AI and premium readiness.
7. Final whole-app evidence pass.

Do not open a broad redesign or AI expansion slice while a higher-priority
local reliability or data-safety gap is known.

## Evidence Recording Rule

Each completed slice should update one of these sources:

- This file, when the overall completion status changes.
- The detailed product backlog, when feature acceptance history changes.
- `WORKFLOW_CHARTER.md`, `RESEARCH_PROTOCOL.md`, `QUALITY_LADDER.md`,
  `HOUSEKEEPING.md`, or `SOURCE_REFERENCES.md`, when the operating model or
  research policy changes.
- `ACTIVE_HANDOFF.md`, when a future agent needs current branch, dirty-file,
  live-preview, blocker, or next-action state.
- `SCREEN_INVENTORY.md`, when screens, routes, tests, evidence, or visual gaps
  change.
- `SLICE_LOG.md`, when a completed slice needs a durable breadcrumb.
- `docs/qa/screenshots/...`, when phone/tablet visual evidence is captured.
- `PAID_TOOL_APPROVAL_LEDGER.md`, when an external paid or account-backed lane
  is approved or used.
- `DEVICE_OWNERSHIP.md`, when the slice uses emulator, ADB, Patrol, Firebase
  Test Lab, live preview, or local screenshot capture.

Keep evidence concise. Do not add screenshots or logs that do not prove a
decision, fix, or completed acceptance criterion.
