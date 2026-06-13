# Danio Complete Local Audit Backlog

Status: Initial working backlog  
Created: 2026-06-13  
Source: `danio-complete-local-product.md`, current code inspection, existing QA/audit docs

## 1. Purpose

This backlog turns the complete-local product definition into executable work.
It supersedes the older "ship v1" finish line as the active local-product bar.

Older audits are still valuable evidence, but they were aimed at launch
readiness. The new bar is higher: Danio should feel complete, premium,
content-rich, tank-centred, and coherent on Android phone and Android tablet
before public release work resumes.

## 2. Current App Snapshot

The current app is already a substantial Flutter product:

- Five-tab shell: Learn, Practice, Tank, Smart, More.
- Tank/room scene with animated aquarium, room themes, bottom activity panel,
  side panels, quick care actions, tank detail, logs, tasks, journal, livestock,
  equipment, analytics, and multi-tank support.
- Learning system with 12 learning paths, 82 lessons, 294 quiz questions, hearts,
  XP, gems, stories, spaced repetition, and achievements.
- Local content database with 127 fish species and 53 plant entries.
- Workshop tools for water changes, stocking, CO2, dosing, tank volume, units,
  lighting, compatibility, cycling, and cost tracking.
- Smart Hub with OpenAI-gated fish/plant ID, symptom checker, weekly plan,
  Ask Danio, AI history, anomaly history, and local compatibility fallback.
- Local-first backup/export/import, GDPR/COPPA gating, settings, notification
  preferences, debug QA tools, smoke/integration test harnesses, and extensive
  prior QA evidence.

## 3. Important State Found During The Initial Pass

- Initial finding: `currentTabProvider` defaulted to Learn (`0`), but the
  approved complete-local direction says the app should open on Tank while Tank
  remains the centre tab. Fixed in commit `f86a32c3`.
- AI is implemented as OpenAI-first. The finished direction is multiple visible
  provider options with a recommended default, user-supplied keys, and optional
  premium AI power later.
- Smart already has useful non-AI pieces, but it is not yet a full built-in
  Aquarium Intelligence hub with risks, suggestions, care plans, compatibility,
  anomaly history, and explainable next actions.
- The species and plant database has good breadth, but finished quality needs
  richer care pages, source-backed content, visual assets, tank-specific actions,
  compatibility explanations, and user request/contact flow for missing species.
- Older audits list many blockers that have since been fixed. This backlog
  should therefore be treated as a fresh complete-local tracker, not a blind
  copy of March findings.

## 4. Non-Negotiable Finished Bar

Danio is not complete until all of the following are true:

- Android phone and Android tablet are both intentionally designed and tested.
- Tank is the first landing screen for returning users and the emotional centre
  of the app.
- Every visible feature works end-to-end or is hidden/reframed honestly.
- Tropical freshwater, planted tropical, coldwater/goldfish, shrimp/nano,
  aquascaping, and breeding are all first-class local paths.
- Marine/brackish setup paths are not offered as normal flows.
- Core usefulness does not depend on AI.
- AI is optional, transparent, provider-aware, and asks before writing data.
- Content is broad, source-backed, safe, and actionable.
- Tank visuals respond meaningfully to care state without teaching bad care.
- Tools behave like guided workflows, not raw calculators.
- Emergency workflows are immediately reachable.
- Multi-tank, journal/timeline, backup/restore, settings, permissions, and data
  controls are polished enough for normal users.
- No public launch/store/legal hosting work resumes until this bar is met.

## 5. P0 Work - Product Spine

These establish the shape of the finished local product.

| ID | Area | Work | Acceptance |
| --- | --- | --- | --- |
| CL-P0-001 | Navigation | Default returning users to Tank while keeping Tank as centre tab. | Done in `f86a32c3`; fresh returning-user shell opens with Tank selected and tests were updated. |
| CL-P0-002 | Product truth | Update canonical docs so complete-local replaces store-launch as the active finish line. | Done; March finish docs now point future agents at `danio-complete-local-product.md` and this backlog. |
| CL-P0-003 | Feature honesty | Re-audit all visible dormant/future/cloud/social/premium/unsupported-scope surfaces. | Done; local/offline account copy, optional account/cloud backup copy, optional cloud account failure copy, signed-in account cloud-data copy, weekly-progress tier copy, returning-user milestone upgrade wording, age-blocked account-setup wording, generic server-error wording, onboarding feature-summary paywall-stub/subscription wording, settings data feedback copy, bulk livestock feedback copy, reward/shop mechanics, More and Shop Street copy, stale social comments, visible debug-crash controls, debug sync shell diagnostics, dead sync-status scaffolds, dormant backend-sync queue code, dormant social reward/referral mechanics, Privacy local-build/local-version copy, Delete My Data privacy/help copy, unsupported marine setup choices/scope copy, legacy marine profile copy, Optional AI server-config/setup/version copy, Smart optional-AI copy, and current README/registry/data-resilience docs honesty were fixed on 2026-06-13. Future walkthrough findings should be filed against their feature area. |
| CL-P0-004 | First-run flow | Redesign onboarding around experience, region/units, tank type/stage/goals, skip path, and contextual prompts. | In progress; CL-P0-004A adds region/units capture, profile persistence, Preferences unit reset, and unguessed quick start. CL-P0-004B routes skipped users to the populated sample tank on the Tank tab. CL-P0-004C adds explicit multi-goal capture after tank stage. CL-P0-004D adds Preferences repair fields and a Smart-only context nudge. Remaining: final Android phone/tablet first-run screen QA. |
| CL-P0-005 | Tank daily loop | Make Tank the daily ritual surface: next-best action, care status, quick log, feed, water change, tasks, and warnings close at hand. | In progress; CL-P0-005A adds care priority and next-best action. CL-P0-005B makes the main Tank Feed action a direct log with safety feedback. CL-P0-005C adds a visible Today Board care rail for Feed, Test, Change, and Tasks. Remaining: final Android phone/tablet visual QA. |
| CL-P0-006 | Emergency access | Create accessible emergency flows for ammonia/nitrite spike, gasping, heater failure, filter failure, ich, injury, and poisoning. | Done; Emergency Guide is directly reachable from Tank top bar, unsafe-water Tank alerts, Smart Hub, global search, More, LessonScreen, species detail sheets, and unsafe water-test save flows. |
| CL-P0-007 | Non-AI intelligence | Build the rule-based Aquarium Intelligence hub before expanding AI. | Done; Smart now works as a no-AI Aquarium Intelligence hub with local risks, suggestions, compatibility signals, care-plan actions, anomaly history, equipment maintenance, checked reasons, full review screen, and action routes. Richer per-tank/save-apply depth belongs to P1 guided workflows. |

## 6. P1 Work - Depth And Polish

| ID | Area | Work | Acceptance |
| --- | --- | --- | --- |
| CL-P1-001 | Living tank | Map care state to visual cues for clean/dirty water, feeding, temperature, stress, compatibility, plant presence, decorations, and theme. | In progress; CL-P1-001A adds latest-water-test visual state for unsafe nitrogen, high nitrate/stale water, and temperature extremes. CL-P1-001B adds stale-water visuals from old water-change logs. CL-P1-001C adds a food-particle aquarium pulse after successful feeding logs. CL-P1-001D adds health and compatibility review cues from current livestock. CL-P1-001E adds planted/decorated aquascape cues from current equipment records. CL-P1-001F adds earned species progression cues from real unlock state. Remaining: a fuller dedicated plant/decor inventory model if product demands it. |
| CL-P1-002 | Rewards | Connect progression to meaningful unlocks: rooms, tank vibes, decorations, seasonal themes, badges, and achievement-based cosmetics. | In progress; CL-P1-002A adds room vibe unlocks in the theme picker using local species, XP, streak, lesson, perfect-score, and achievement progress. CL-P1-002B polishes achievement badge/category display so visible reward surfaces use controlled icons and plain labels. CL-P1-002C surfaces achievement-linked room-vibe rewards in single and batch achievement celebrations. CL-P1-002D adds a real achievement-based badge/trophy cosmetic cue to the central aquarium. Remaining: deeper decoration inventory and seasonal cosmetics. |
| CL-P1-003 | Species pages | Upgrade species/plant pages into beautiful actionable guides. | Done; CL-P1-003A adds a simple missing-species request path from Fish Database empty search. CL-P1-003B adds data-derived Care Actions to fish species detail sheets. CL-P1-003C hands species detail pages into a prefilled Stocking Calculator at the minimum group size. CL-P1-003D saves species into the local fish wishlist with realistic quantity and planning notes. CL-P1-003E adds plant Care Actions and local plant wishlist save. CL-P1-003F adds fish Watch For guidance for group size, tankmates, adult fit, care level, and treatment cautions. CL-P1-003G adds plant Watch For guidance for rhizomes, growth rate, size, CO2, and difficulty. CL-P1-003H adds species detail add-to-tank through the existing prefilled livestock flow. CL-P1-003I creates weekly tank care tasks from species detail pages. CL-P1-003J adds subtle source-trail cards to fish and plant detail sheets. CL-P1-003K adds fish Care Profile and plant Planting Profile cards. |
| CL-P1-004 | Learning depth | Expand lessons into richer pathways with visuals, examples, scenarios, quizzes, review, skill drills, and subtle citations. | In progress; CL-P1-004A adds structured lesson guide metadata and rendering for outcomes, real-tank scenarios, care drills, and references, with the Nitrogen Cycle path enriched first. CL-P1-004B adds shared lesson source references and extends structured guide coverage to Water Parameters. CL-P1-004C extends structured guides to First Fish beginner decision lessons. CL-P1-004D extends structured guides to Maintenance care-habit lessons. CL-P1-004E extends structured guides to Planted Tanks. CL-P1-004F extends structured guides to Equipment. CL-P1-004G extends structured guides to Fish Health. CL-P1-004H extends structured guides to Species Care. CL-P1-004I extends structured guides to Advanced Topics. CL-P1-004J extends structured guides to Aquascaping. CL-P1-004K extends structured guides to Breeding Basics. CL-P1-004L extends structured guides to Troubleshooting, completing guide coverage for all current learning paths. Remaining: richer visual depth, practice drills, and broader learning interactions across the catalog. |
| CL-P1-005 | Practice depth | Broaden Practice beyond SRS into diagnosis drills, compatibility drills, parameter interpretation, setup planning, and emergency decisions. | Done for current complete-local Practice scope; CL-P1-005A adds catalog-driven Skill Drills for parameter reading, diagnosis, compatibility checks, setup planning, and emergency decisions. CL-P1-005B adds scenario-style Parameter Reading questions for pH, temperature, chlorine/chloramine, cycling spikes, nitrate/maintenance, and general water-test interpretation. CL-P1-005C adds scenario-style Diagnosis Practice for ich, fin damage, fungal-looking growth, parasite-style symptoms, quarantine/prevention, and general triage. CL-P1-005D adds scenario-style Compatibility Checks for bettas, goldfish, schooling/social species, territorial species, and general compatibility checklists. CL-P1-005E adds scenario-style Emergency Decisions for gasping/unsafe water, power outage, temperature crash, pH crash, and general emergency triage. CL-P1-005F adds scenario-style Setup Planning for filter flow/bioload, lighting/photoperiod, first-tank checklists, and general setup planning. CL-P1-005G adds tank-context recommendation hints from water tests, care tasks, livestock health, and equipment records. Richer persisted tool-result context moves to CL-P1-006 guided tools. |
| CL-P1-006 | Guided tools | Convert calculators into guided workflows with prefill, explanation, warnings, save/apply, and confirmation. | In progress; CL-P1-006A turns Water Change into the first guided tool workflow with tank-volume prefill from Workshop, result explanation, safety guidance, and a prefilled water-change journal handoff. CL-P1-006B turns Tank Volume into a guided apply workflow that saves calculated litres back to the selected local tank profile. CL-P1-006C turns Dosing into a guided journal workflow with tank-volume prefill and a calculated liquid-product dose note. CL-P1-006D turns CO2 into a guided journal workflow with calculated estimate/status context. CL-P1-006E turns Lighting into a guided journal workflow with schedule, setup, and recommendation context. CL-P1-006F turns Stocking into a guided workflow with tank-volume prefill and a saveable stock-check summary. CL-P1-006G turns Compatibility into a guided workflow with selected-tank context and a saveable verdict summary. CL-P1-006H polishes Unit Converter labels so temperature and hardness units are readable and ASCII-safe. CL-P1-006I turns Cycling Assistant phase guidance into visible water-test logging and phase-aware task creation actions. CL-P1-006J hardens Cost Tracker currency settings for custom or locale-derived saved currency values. Remaining: add broader tool-result timeline/task handoffs and any future tool-specific save/apply gaps found in walkthroughs. |
| CL-P1-007 | Multi-tank | Polish per-tank and all-tanks overview, comparisons, priorities, timelines, and switching. | In progress; CL-P1-007A adds an all-tanks priority strip to Compare Tanks so urgent tanks remain visible even when they are not part of the selected two-tank detail comparison. CL-P1-007B adds recent activity across all tanks to Compare Tanks. Remaining: switching polish and final Android phone/tablet QA. |
| CL-P1-008 | Timeline | Merge logs, photos, tests, care tasks, tool results, accepted AI notes, and milestones into a coherent journal/timeline. | In progress; CL-P1-008A turns Tank Journal into a unified local timeline for all current log types, including water tests and completed care tasks. CL-P1-008B surfaces recent all-tanks activity from local logs in Compare Tanks. CL-P1-008C labels saved guided-tool notes as Tool Result entries. Remaining: accepted AI-note and milestone history surfaces, plus richer tool-result detail cards if walkthroughs need them. |
| CL-P1-009 | Backup/data | Harden backup, restore, import validation, schema migration, edit/delete/undo, and normal-user explanations. | In progress; CL-P1-009A clarifies backup import safety copy, explains merge-vs-replace behavior for normal users, and protects Backup & Restore source copy from mojibake/non-ASCII glyphs. CL-P1-009B validates required backup data before preview/import. Remaining: deeper import validation UX, edit/delete/undo coverage, and restore/migration walkthrough QA. |
| CL-P1-010 | Profile/preferences | Centralise experience, goals, interests, units, region, AI, privacy, reminder intensity, motion/haptics, and reset controls. | In progress; CL-P1-010A polishes Tank Settings water-profile labels so tropical/coldwater target copy is readable and source-safe. Remaining: centralised reset/edit controls for all onboarding preferences, AI, privacy, reminder intensity, motion, and haptics. |
| CL-P1-011 | Global search | Make search a top-bar/contextual/More feature, not a bottom tab. | Done for current complete-local search scope; CL-P1-011A adds grouped app, tool, learning-path, guide, settings/privacy/backup, species, equipment, livestock, and local log search results. Remaining: Android phone/tablet walkthrough QA and optional direct-per-lesson deep links if needed. |
| CL-P1-012 | Demo mode | Provide one polished sample tank, resettable and separate from real data. | Partially done; quick start and Settings can add the populated sample tank, clearly marked as demo data. Remaining: reset/replace polish and final screen QA. |

## 7. P2 Work - Presentation System

| ID | Area | Work | Acceptance |
| --- | --- | --- | --- |
| CL-P2-001 | Design system | Run a full visual redesign pass while preserving the current illustrated watercolor/tank-room direction. | Every screen has a clear primary job, custom-fit visual, and consistent hierarchy. |
| CL-P2-002 | Tablet | Design tablet layouts instead of stretching phone screens. | Tank, Learn, Smart, tools, species, and timeline use tablet space intentionally. |
| CL-P2-003 | Assets | Regenerate weak headers/backgrounds/sprites and add missing badges/decorations in the established style. | No first-class surface uses mismatched or low-quality art. |
| CL-P2-004 | Accessibility | Meet baseline contrast, 48dp touch targets, labels/tooltips, text scaling, reduced motion, and non-colour-only status. | Basic accessibility audit passes on phone and tablet. |
| CL-P2-005 | Motion/haptics | Add purposeful motion to tank life, feeding, rewards, warnings, onboarding, and feedback; keep haptics subtle and optional. | Motion adds charm and clarity without noise. |
| CL-P2-006 | Performance | Create and meet a formal performance target on a mid-range Android phone. | Startup, tab switching, tank animation, scrolling, and image loads remain smooth. |

## 8. P3 Work - AI Expansion

AI expansion comes after the local core is strong.

| ID | Area | Work | Acceptance |
| --- | --- | --- | --- |
| CL-P3-001 | Providers | Add provider model: OpenAI, Anthropic, Gemini, OpenRouter, Mistral, and recommended default. | Users can understand capabilities and choose/configure provider keys. |
| CL-P3-002 | Confirm writes | Require confirmation before AI changes tank data, tasks, journal, reminders, or care plans. | AI never silently mutates user data. |
| CL-P3-003 | Premium path | Design premium AI power as optional, not required for core app usefulness. | Local/free app still feels complete. |
| CL-P3-004 | Citations | Add source/citation support where it helps learning/trust without damaging the visual style. | Learning and advice screens can show source trail subtly. |

## 9. QA And Automation Work

| ID | Area | Work | Acceptance |
| --- | --- | --- | --- |
| CL-QA-001 | Screen audit | Re-run a whole-app phone screenshot and XML audit against the complete-local bar. | Every screen logged with pass/fail/gap notes. |
| CL-QA-002 | Tablet audit | Add tablet emulator/screenshot audit. | Tablet-specific failures become tracked blockers. |
| CL-QA-003 | Visual regression | Add selective golden/screenshot checks for core surfaces. | Tank, onboarding, Learn, Smart, species, tools, and More have visual guardrails. |
| CL-QA-004 | Rule tests | Unit test recommendation, compatibility, risk, emergency, units, and tool calculations. | Rule-based intelligence is explainable and regression-tested. |
| CL-QA-005 | Content validation | Add content linting for units, spelling style, missing warnings, missing sources, duplicate IDs, bad ranges, and locked emergency content. | Unsafe or sloppy content fails automated checks. |
| CL-QA-006 | Data resilience | Test create/edit/delete tank, log, task, livestock, lesson completion, backup/restore, migration, and app-kill flush paths. | Critical local data paths are covered. |
| CL-QA-007 | Debug tools | Expand QA seed states for emergencies, bad water, incompatible fish, skipped onboarding, demo mode, unlocks, tablet, and AI/no-AI. | Manual QA can jump straight to every important state. |

Current QA note: `danio_api36` exists and boots, but ADB transport dropped
during blackbox and focused verification on 2026-06-13. See
`danio-complete-local-current-audit-2026-06-13.md`.

Current verification note: as of the Tool Result timeline-label slice on
2026-06-13, `flutter test` passes 1530 tests and `flutter analyze` is clean,
and a debug APK builds successfully.
Android blackbox QA should only run after confirming emulator/device ownership
because parallel Codex sessions may also be using Android targets.

## 10. First Execution Order

1. Lock docs and landing behaviour.
2. Re-run current analyzer/tests after the landing change.
3. Create a screen-by-screen complete-local audit from the latest build.
4. Tackle P0 product spine in order: onboarding, Tank daily loop, emergencies,
   non-AI intelligence, feature honesty.
5. Only then move into broad content, visual, tablet, and AI expansion work.

## 11. Final Acceptance Scenarios

The app is not complete until these day-in-life scenarios pass on Android phone
and Android tablet:

- Beginner with no tank skips onboarding, explores the sample tank, learns what
  to do next, and starts a guided tropical plan.
- Tropical community owner adds livestock, logs water, sees next-best actions,
  gets a safe compatibility warning, and saves useful tasks.
- Planted/shrimp user gets stability-aware guidance, plant advice, dosing/light
  help, and no unsafe shortcuts.
- Goldfish user gets protective tank-size, temperature, waste, and treatment
  guidance without tropical assumptions.
- Emergency user can reach actionable help quickly without lesson locks.
- No-AI user receives meaningful risks, suggestions, compatibility, and care
  plans.
- AI user can configure a provider, ask for help, understand disclosure, and
  confirm before anything changes data.
- Multi-tank user can compare priorities and history across tanks.
- User exports data, restores it, and sees clear validation/error handling.
- Accessibility basics hold under large text and reduced motion.
