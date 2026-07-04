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

## Status Values

| Status | Meaning |
| --- | --- |
| Not started | No committed implementation exists for the complete-local bar. |
| In progress | Implementation exists, but product depth, tests, visual proof, or Android evidence is incomplete. |
| Implemented | The feature exists and works in source-level review or focused tests. |
| Locally verified | Focused tests and the relevant local gate passed in the integration checkout. |
| Externally reviewed | Optional external review or device-lab evidence has been collected after local gates. |
| Done | Product, content, UI, accessibility, data safety, phone/tablet evidence, and tests meet the complete-local bar. |

## Definition Of Done By Slice Type

| Slice type | Required proof before Done |
| --- | --- |
| Product behavior | Focused test, `Focused` gate, relevant widget/service coverage, no fake/dormant copy, and product docs updated when behavior changes. |
| UI or visual | Current screenshot/golden/mockup target, focused UI test or golden where practical, `Visual` gate, phone check, tablet check, and no clipped/overlapping text. |
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
| Living Tank | In progress | Water, stale-change, feeding, health, compatibility, aquascape, progression, and decoration cues exist. | Finish dedicated plant inventory, seasonal variants, and final phone/tablet visual QA. |
| Rewards and collectibles | In progress | Room vibes, achievement cosmetics, inventory access, and earned decoration equip controls exist. | Add seasonal cosmetics and deeper plant/decor collections only when grounded in reward rules and visual targets. |
| Species and plants | Implemented | Current guide pass includes profiles, care actions, wishlist/tank/task handoffs, source trails, and missing-species request path. | Expand database depth, image quality, and content sources during content-polish passes. |
| Learning | In progress | Structured guide coverage exists for all current paths, placeholder placement CTA is hidden until a real flow exists, path-load failures show retryable errors, story play asks before leaving mid-story progress, locked story cards explain unlock requirements, and path cards now open a dedicated full-screen sequence view from a short inline preview. | Add richer visuals, practice links, scenarios, citations, and broader interaction variety. |
| Practice | Implemented | Skill Drills and scenario practice cover parameters, diagnosis, compatibility, setup, and emergency decisions, with distinct Learn entry points, SR provider error coverage, and fallback-card reveal prompts. | Add persisted tool-result context only where walkthroughs prove it improves flow. |
| Guided tools | In progress | Major calculators have tank-context handoffs, explanations, warnings, and save/apply paths. | Close any remaining tool-specific save/apply gaps found by walkthroughs. |
| Multi-tank | Done | Current local scope has priority overview, recent activity, swap action, and Android walkthrough evidence. | Recheck if tank switching, comparison, or all-tanks priority logic changes. |
| Timeline and journal | In progress | Unified timeline, tool result labels, milestone labels, AI note labels, and contextual strips exist. | Finish future source-specific guided-tool and optional-AI save handoff walkthroughs. |
| Backup and restore | In progress | Extensive validation, rollback, undo, import transaction, migration, and corruption recovery work exists. | Continue edit/delete/undo coverage plus restore and migration Android walkthrough QA. |
| Preferences | In progress | Units, region, tank stage, goals, haptics, reduced motion, reminder intensity, privacy, and AI disclosure controls exist. | Finish final AI/provider walkthrough gaps. |
| Global search | Done | Search covers destinations, tools, paths, guides, settings, species, equipment, livestock, logs, Tank entry, and More entry. | Add direct per-lesson deep links only if walkthrough evidence shows need. |
| Demo mode | Done | Resettable sample tank exists with final phone/tablet evidence. | Recheck only if sample data, onboarding skip, or tank seeding changes. |
| Tablet layout | In progress | Many surfaces have CL-P2-002 tablet readability slices through livestock detail. | Continue remaining stretched phone surfaces, starting with the next unaudited high-traffic screen. |
| Visual asset quality | Not started | Older audit notes still identify weak or mismatched assets. | Audit current screenshots, regenerate weak headers/backgrounds/sprites, and add missing badges/decorations. |
| Accessibility | In progress | Some 48dp, contrast, semantics, reduced-motion, and layout guardrails exist. | Run an app-wide accessibility pass with phone/tablet screenshots and focused tests. |
| Motion and haptics | In progress | Feeding pulse, reduced motion, and haptics preference integration exist. | Add purposeful motion to rewards, warnings, onboarding, and tank life only where it improves clarity. |
| Performance | In progress | Complete-local Android targets are recorded in `docs/agent/PERFORMANCE_TARGETS.md` and enforced by `test/utils/performance_targets_test.dart`; the debug performance monitor now uses the shared 60 FPS frame-budget constant. | Measure startup, tab switching, tank animation, scrolling, and image loading on Android phone/tablet when device ownership is clear. |
| Optional AI providers | In progress | Optional AI setup names OpenAI as current BYO provider and disables other provider paths honestly. | Implement real non-OpenAI connectors before enabling those key paths. |
| AI confirmation | In progress | Symptom Triage journal saves, Symptom Triage AI history writes, and Weekly Plan care-plan cache saves now require confirmation before AI output becomes saved app data. | Continue confirm-before-write coverage for AI changes to tank data, tasks, and reminders. |
| Premium AI path | Not started | Premium remains conceptual and must not appear as fake product behavior. | Design only after core app is excellent locally and real extra capability exists. |
| Citations | In progress | Species/plant source trails and lesson references exist in limited form. | Add subtle source trails where they improve trust without damaging visual quality. |
| Whole-app phone audit | In progress | Current phone screenshot/XML pass exists under `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/`, with notes in `docs/qa/whole-app-phone-map-2026-07-04.md`; the Smart/Fish ID bottom-dock overlap and smoke tap false positive are fixed locally with tests, the phone black-box smoke rerun passed, `phone-04b-smart-root-after-dock-fix` recaptures Fish & Plant ID clearing the dock by `47px`, QA-006 added 39 standalone deep-link captures, QA-007 added 24 fixed-build seeded tank/learning/story/cycling captures and fixed the Livestock skeleton duplicate-Hero regression, and all 96 `SCREEN_INVENTORY.md` rows now have phone `Pass` or `Gap` accounting with 80 passes and 16 gaps. | Capture or route-smoke the 16 phone gap rows, prioritizing onboarding/first-run states before Debug QA Seeds. |
| Whole-app tablet audit | In progress | Current tablet screenshot/XML pass exists under `docs/qa/screenshots/2026-07-04/cl-qa-002-tablet-whole-app-map/`, with notes in `docs/qa/whole-app-tablet-map-2026-07-04.md`; smoke route assertions/tap handling and lower More hub tablet swipes are hardened locally with tests, the tablet black-box smoke rerun passed, QA-006 added 39 standalone deep-link captures, QA-007 added 24 fixed-build seeded tank/learning/story/cycling captures and fixed the Livestock skeleton duplicate-Hero regression, and all 96 `SCREEN_INVENTORY.md` rows now have tablet `Pass` or `Gap` accounting with 80 passes and 16 gaps. | Capture or route-smoke the 16 tablet gap rows, prioritizing onboarding/first-run states before Debug QA Seeds. |
| Visual regression | In progress | Golden tests and visual baseline manifest exist. | Add selective core-surface goldens/screenshots after visual targets stabilize. |
| Rule tests | In progress | Rule coverage exists for some local intelligence and tool paths. | Expand recommendation, compatibility, emergency, unit, and calculation tests. |
| Content validation | In progress | Content validator exists and runs in the focused gate, including emergency/distress lesson checks for educational positioning, aquatic-vet/professional escalation copy, direct prerequisite-free access, UK-style litre/litres volume spelling, metric context for gallon and Fahrenheit references in learning copy, warning-section coverage for medical/emergency lessons, unsafe/product-endorsing care copy, brand-specific emergency-product certainty claims, brand-specific conditioner/test-kit product names, learning graph IDs/prerequisites, per-lesson source density, quiz answer indexes, lesson section presence, and lesson reward/duration ranges. | Expand validation for broader locked-content coverage and any remaining source/content-risk gaps found during future audits. |
| Data resilience | In progress | Backup/data hardening has broad coverage; achievement progress has lifecycle flush/restore-cancel and false-write retry coverage, achievement resetAll rejects failed local progress removal before clearing visible progress, lesson-completion achievement checks use persisted completed-lesson and perfect-score profile state, debug achievement reset rejects failed progress removal/profile writes and restores progress on profile-write failure, DebugMenu profile-write actions reject false local `user_profile` saves before showing success, Debug species reset rejects false local unlock writes, Debug Clear All Data rejects false local preference-clear results before showing restart copy, Debug Force SR Cards Due rejects false review-card writes before showing due-now success, Settings theme/notification/ambient/haptic writes now report durable-save failures, theme selection stays retryable when local theme persistence fails, Phone Notifications avoids false disabled-success feedback when local persistence fails, ambient/haptic switches show retry feedback when local saves fail, Preferences region/tank-stage/experience/goals edits stay retryable when profile persistence fails, and Reminder Settings review/streak toggles, reminder-intensity presets, and reminder-time edits show retry feedback when profile persistence fails, review-card create/seed/delete paths rollback on failed local writes, review reset keeps visible cards/stats and restores partially removed cards/stats/streak/session JSON when reset removal fails, gem and inventory resets reject false local removal results, room-vibe applies require durable preference saves before showing success, Reduce Motion override changes stay aligned with saved preferences, guidance and seasonal prompt dismissals only report dismissal after the local flag is saved, Tank returning-user prompt dismissals check failed seen-flag writes, the stage sheet hint uses the shared preferences provider and restores visible retry state when its seen-flag save fails, the energy explainer prompt is marked seen only after dismissal, all current OpenAI request surfaces stop before AI requests when the local disclosure flag cannot be saved, first-run consent/under-13 actions wait for durable preference writes before advancing, user-profile saves and resets treat false preference write/remove results as failures, schema migration stamps fail loudly when the version marker cannot be saved, onboarding completion/reset/replay wait for durable local flag writes or show retry feedback, Delete My Data rejects false preference-clear results before destructive follow-up steps, Clear All Data copy matches its narrower local tank/log/task/photo scope, Add Log edits skip duplicate reward/progress side effects, Tank Settings saved edits close without dirty-prompt loops, equipment adds roll back partial equipment saves when maintenance-task sync fails, equipment-add, livestock-add, Quick Water Test, and practice-lesson progress failures no longer undo durable saves or show generic/false save success, single and bulk livestock adds roll back partial livestock/log saves when timeline-log persistence fails, and gem, inventory, legacy inventory migration, review-card, review-session count, review-streak, reminder, cost-tracker, maintenance-checklist, difficulty-setting, review-request tracking, and API rate-limit writes reject false local save results. | Finish remaining create/edit/delete/app-kill flush and migration walkthrough coverage. |
| Weekly Plan cache clear | Locally verified | Weekly Plan cache clear now waits for durable local `weekly_plan_cache` removal before hiding the visible plan, and failed removals leave the plan visible with a surfaced error. | Recheck if Weekly Plan cache, restore invalidation, or optional-AI save flows change. |
| Debug QA seeds | In progress | Existing debug QA seeds now include demo tank, lesson quiz/practice, unlock/progression controls, emergency unsafe-water, incompatible-fish, skipped-onboarding quick-start, no-AI Smart Hub, partial unlock-edge, and tablet visual-stress seeds. | Add any real keyed-AI seed only when it can avoid fake provider readiness. |

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
