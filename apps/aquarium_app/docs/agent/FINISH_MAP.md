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
| Learning | In progress | Structured guide coverage exists for all current paths. | Add richer visuals, practice links, scenarios, citations, and broader interaction variety. |
| Practice | Implemented | Skill Drills and scenario practice cover parameters, diagnosis, compatibility, setup, and emergency decisions. | Add persisted tool-result context only where walkthroughs prove it improves flow. |
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
| Performance | Not started | No formal complete-local performance target is recorded. | Define mid-range Android targets and measure startup, tab switching, tank animation, scrolling, and image loading. |
| Optional AI providers | In progress | Optional AI setup names OpenAI as current BYO provider and disables other provider paths honestly. | Implement real non-OpenAI connectors before enabling those key paths. |
| AI confirmation | Not started | Writes are not yet fully governed by a complete confirm-before-write contract. | Require confirmation before AI changes tank data, tasks, journal, reminders, or care plans. |
| Premium AI path | Not started | Premium remains conceptual and must not appear as fake product behavior. | Design only after core app is excellent locally and real extra capability exists. |
| Citations | In progress | Species/plant source trails and lesson references exist in limited form. | Add subtle source trails where they improve trust without damaging visual quality. |
| Whole-app phone audit | Not started | Prior focused screenshots exist, but no current whole-app map is complete. | Run CL-QA-001 when phone device ownership is clear. |
| Whole-app tablet audit | Not started | Prior focused tablet evidence exists, but no current whole-app map is complete. | Run CL-QA-002 when tablet device ownership is clear. |
| Visual regression | In progress | Golden tests and visual baseline manifest exist. | Add selective core-surface goldens/screenshots after visual targets stabilize. |
| Rule tests | In progress | Rule coverage exists for some local intelligence and tool paths. | Expand recommendation, compatibility, emergency, unit, and calculation tests. |
| Content validation | In progress | Content validator exists and runs in the focused gate. | Expand validation for spelling style, warnings, sources, duplicate IDs, bad ranges, and emergency locked content. |
| Data resilience | In progress | Backup/data hardening has broad coverage; achievement progress has lifecycle flush/restore-cancel coverage, review-card create/seed/delete paths rollback on failed local writes, room-vibe applies require durable preference saves before showing success, Reduce Motion override changes stay aligned with saved preferences, guidance and seasonal prompt dismissals only report dismissal after the local flag is saved, first-run consent/under-13 actions wait for durable preference writes before advancing, user-profile saves treat false preference write results as failures, schema migration stamps fail loudly when the version marker cannot be saved, onboarding completion waits for a durable local flag write, and gem, inventory, review-card, reminder, cost-tracker, maintenance-checklist, and difficulty-setting writes reject false local save results. | Finish remaining create/edit/delete/app-kill flush and migration walkthrough coverage. |
| Debug QA seeds | In progress | Existing debug QA seeds are useful but shallow. | Add seed states for emergencies, bad water, incompatible fish, skipped onboarding, demo, unlocks, tablet, and AI/no-AI. |

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
- `docs/qa/screenshots/...`, when phone/tablet visual evidence is captured.
- `PAID_TOOL_APPROVAL_LEDGER.md`, when an external paid or account-backed lane
  is approved or used.
- `DEVICE_OWNERSHIP.md`, when the slice uses emulator, ADB, Patrol, Firebase
  Test Lab, live preview, or local screenshot capture.

Keep evidence concise. Do not add screenshots or logs that do not prove a
decision, fix, or completed acceptance criterion.
