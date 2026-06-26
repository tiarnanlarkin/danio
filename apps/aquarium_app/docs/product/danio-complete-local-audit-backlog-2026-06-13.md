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
| CL-P0-004 | First-run flow | Redesign onboarding around experience, region/units, tank type/stage/goals, skip path, and contextual prompts. | Done; CL-P0-004A adds region/units capture, profile persistence, Preferences unit reset, and unguessed quick start. CL-P0-004B routes skipped users to the populated sample tank on the Tank tab. CL-P0-004C adds explicit multi-goal capture after tank stage. CL-P0-004D adds Preferences repair fields and a Smart-only context nudge. CL-P0-004E constrains the first-run privacy consent screen on tablet. CL-P0-004F constrains the main first-run onboarding reading/CTA surfaces on tablet. CL-P0-004G makes Fish Select use readable tablet search/list widths and adaptive compact grid tiles. CL-P0-004H adds final Android phone/tablet first-run walkthrough evidence under `docs/qa/screenshots/2026-06-22/cl-p0-004-first-run/`. |
| CL-P0-005 | Tank daily loop | Make Tank the daily ritual surface: next-best action, care status, quick log, feed, water change, tasks, and warnings close at hand. | Done; CL-P0-005A adds care priority and next-best action. CL-P0-005B makes the main Tank Feed action a direct log with safety feedback. CL-P0-005C adds a visible Today Board care rail for Feed, Test, Change, and Tasks. CL-P0-005D adds phone/tablet no-overflow and 48dp primary-control guardrails. CL-P0-005E adds final Android phone/tablet visual QA under `docs/qa/screenshots/2026-06-22/cl-p0-005-tank-daily-loop/`. |
| CL-P0-006 | Emergency access | Create accessible emergency flows for ammonia/nitrite spike, gasping, heater failure, filter failure, ich, injury, and poisoning. | Done; Emergency Guide is directly reachable from Tank top bar, unsafe-water Tank alerts, Smart Hub, global search, More, LessonScreen, species detail sheets, and unsafe water-test save flows. |
| CL-P0-007 | Non-AI intelligence | Build the rule-based Aquarium Intelligence hub before expanding AI. | Done; Smart now works as a no-AI Aquarium Intelligence hub with local risks, suggestions, compatibility signals, care-plan actions, anomaly history, equipment maintenance, checked reasons, full review screen, and action routes. Richer per-tank/save-apply depth belongs to P1 guided workflows. |

## 6. P1 Work - Depth And Polish

| ID | Area | Work | Acceptance |
| --- | --- | --- | --- |
| CL-P1-001 | Living tank | Map care state to visual cues for clean/dirty water, feeding, temperature, stress, compatibility, plant presence, decorations, and theme. | In progress; CL-P1-001A adds latest-water-test visual state for unsafe nitrogen, high nitrate/stale water, and temperature extremes. CL-P1-001B adds stale-water visuals from old water-change logs. CL-P1-001C adds a food-particle aquarium pulse after successful feeding logs. CL-P1-001D adds health and compatibility review cues from current livestock. CL-P1-001E adds planted/decorated aquascape cues from current equipment records. CL-P1-001F adds earned species progression cues from real unlock state. CL-P1-001G makes Tank Detail QuickAdd feeding emit the same aquarium feeding pulse as the main Tank and Today Board feed actions. CL-P1-001H makes Livestock Feed emit the same aquarium feeding pulse after successful local feeding logs. CL-P1-001I makes Add Log feeding entries emit the same aquarium feeding pulse. CL-P1-001J prevents Add Log feeding edits from replaying a new feeding pulse. CL-P1-001K adds an equipped earned-decoration visual cue from local decoration state. Remaining: fuller dedicated plant inventory and seasonal variants if product demands them. |
| CL-P1-002 | Rewards | Connect progression to meaningful unlocks: rooms, tank vibes, decorations, seasonal themes, badges, and achievement-based cosmetics. | In progress; CL-P1-002A adds room vibe unlocks in the theme picker using local species, XP, streak, lesson, perfect-score, and achievement progress. CL-P1-002B polishes achievement badge/category display so visible reward surfaces use controlled icons and plain labels. CL-P1-002C surfaces achievement-linked room-vibe rewards in single and batch achievement celebrations. CL-P1-002D adds a real achievement-based badge/trophy cosmetic cue to the central aquarium. CL-P1-002E exposes earned room vibes in My Items/Permanent and lets unlocked vibes be applied from Inventory. CL-P1-002F adds a local earned tank-decoration inventory with equip controls and tank visuals. Remaining: seasonal cosmetics and deeper plant/decor collections. |
| CL-P1-003 | Species pages | Upgrade species/plant pages into beautiful actionable guides. | Done; CL-P1-003A adds a simple missing-species request path from Fish Database empty search. CL-P1-003B adds data-derived Care Actions to fish species detail sheets. CL-P1-003C hands species detail pages into a prefilled Stocking Calculator at the minimum group size. CL-P1-003D saves species into the local fish wishlist with realistic quantity and planning notes. CL-P1-003E adds plant Care Actions and local plant wishlist save. CL-P1-003F adds fish Watch For guidance for group size, tankmates, adult fit, care level, and treatment cautions. CL-P1-003G adds plant Watch For guidance for rhizomes, growth rate, size, CO2, and difficulty. CL-P1-003H adds species detail add-to-tank through the existing prefilled livestock flow. CL-P1-003I creates weekly tank care tasks from species detail pages. CL-P1-003J adds subtle source-trail cards to fish and plant detail sheets. CL-P1-003K adds fish Care Profile and plant Planting Profile cards. |
| CL-P1-004 | Learning depth | Expand lessons into richer pathways with visuals, examples, scenarios, quizzes, review, skill drills, and subtle citations. | In progress; CL-P1-004A adds structured lesson guide metadata and rendering for outcomes, real-tank scenarios, care drills, and references, with the Nitrogen Cycle path enriched first. CL-P1-004B adds shared lesson source references and extends structured guide coverage to Water Parameters. CL-P1-004C extends structured guides to First Fish beginner decision lessons. CL-P1-004D extends structured guides to Maintenance care-habit lessons. CL-P1-004E extends structured guides to Planted Tanks. CL-P1-004F extends structured guides to Equipment. CL-P1-004G extends structured guides to Fish Health. CL-P1-004H extends structured guides to Species Care. CL-P1-004I extends structured guides to Advanced Topics. CL-P1-004J extends structured guides to Aquascaping. CL-P1-004K extends structured guides to Breeding Basics. CL-P1-004L extends structured guides to Troubleshooting, completing guide coverage for all current learning paths. CL-P1-004M adds emergency lesson safety-boundary copy and content validation requiring educational positioning plus aquatic-vet/professional escalation language. CL-P1-004N removes prerequisites from emergency/distress lessons and adds validation that emergency learning content stays directly accessible. Remaining: richer visual depth, practice drills, and broader learning interactions across the catalog. |
| CL-P1-005 | Practice depth | Broaden Practice beyond SRS into diagnosis drills, compatibility drills, parameter interpretation, setup planning, and emergency decisions. | Done for current complete-local Practice scope; CL-P1-005A adds catalog-driven Skill Drills for parameter reading, diagnosis, compatibility checks, setup planning, and emergency decisions. CL-P1-005B adds scenario-style Parameter Reading questions for pH, temperature, chlorine/chloramine, cycling spikes, nitrate/maintenance, and general water-test interpretation. CL-P1-005C adds scenario-style Diagnosis Practice for ich, fin damage, fungal-looking growth, parasite-style symptoms, quarantine/prevention, and general triage. CL-P1-005D adds scenario-style Compatibility Checks for bettas, goldfish, schooling/social species, territorial species, and general compatibility checklists. CL-P1-005E adds scenario-style Emergency Decisions for gasping/unsafe water, power outage, temperature crash, pH crash, and general emergency triage. CL-P1-005F adds scenario-style Setup Planning for filter flow/bioload, lighting/photoperiod, first-tank checklists, and general setup planning. CL-P1-005G adds tank-context recommendation hints from water tests, care tasks, livestock health, and equipment records. Richer persisted tool-result context moves to CL-P1-006 guided tools. |
| CL-P1-006 | Guided tools | Convert calculators into guided workflows with prefill, explanation, warnings, save/apply, and confirmation. | In progress; CL-P1-006A turns Water Change into the first guided tool workflow with tank-volume prefill from Workshop, result explanation, safety guidance, and a prefilled water-change journal handoff. CL-P1-006B turns Tank Volume into a guided apply workflow that saves calculated litres back to the selected local tank profile. CL-P1-006C turns Dosing into a guided journal workflow with tank-volume prefill and a calculated liquid-product dose note. CL-P1-006D turns CO2 into a guided journal workflow with calculated estimate/status context. CL-P1-006E turns Lighting into a guided journal workflow with schedule, setup, and recommendation context. CL-P1-006F turns Stocking into a guided workflow with tank-volume prefill and a saveable stock-check summary. CL-P1-006G turns Compatibility into a guided workflow with selected-tank context and a saveable verdict summary. CL-P1-006H polishes Unit Converter labels so temperature and hardness units are readable and ASCII-safe. CL-P1-006I turns Cycling Assistant phase guidance into visible water-test logging and phase-aware task creation actions. CL-P1-006J hardens Cost Tracker currency settings for custom or locale-derived saved currency values. CL-P1-006K adds aquarium-use guidance to every Unit Converter tab. Remaining: any future tool-specific save/apply gaps found in walkthroughs. |
| CL-P1-007 | Multi-tank | Polish per-tank and all-tanks overview, comparisons, priorities, timelines, and switching. | Done for current complete-local multi-tank scope; CL-P1-007A adds an all-tanks priority strip to Compare Tanks so urgent tanks remain visible even when they are not part of the selected two-tank detail comparison. CL-P1-007B adds recent activity across all tanks to Compare Tanks. CL-P1-007C adds a one-tap accessible swap action for the two compared tanks. CL-P1-007D captures final phone/tablet Android walkthrough evidence under `docs/qa/screenshots/2026-06-22/cl-p1-007-multi-tank/`. |
| CL-P1-008 | Timeline | Merge logs, photos, tests, care tasks, tool results, accepted AI notes, and milestones into a coherent journal/timeline. | In progress; CL-P1-008A turns Tank Journal into a unified local timeline for all current log types, including water tests and completed care tasks. CL-P1-008B surfaces recent all-tanks activity from local logs in Compare Tanks. CL-P1-008C labels saved guided-tool notes as Tool Result entries. CL-P1-008D labels saved `Milestone:` journal notes as Milestone timeline entries. CL-P1-008E labels saved AI notes as AI Note timeline entries. CL-P1-008F makes Livestock Feed refresh all-log timeline data after successful local feeding logs. CL-P1-008G adds contextual detail strips for saved tool results, tank milestones, and optional AI notes. CL-P1-008H captures phone/tablet Android walkthrough evidence for Journal water-test, water-change, milestone rendering, and all-tanks activity under `docs/qa/screenshots/2026-06-22/cl-p1-008-timeline-walkthrough/`. Remaining: any future source-specific guided-tool or optional-AI Android save handoff walkthrough beyond existing focused widget coverage. |
| CL-P1-009 | Backup/data | Harden backup, restore, import validation, schema migration, edit/delete/undo, and normal-user explanations. | In progress; CL-P1-009A clarifies backup import safety copy, explains merge-vs-replace behavior for normal users, and protects Backup & Restore source copy from mojibake/non-ASCII glyphs. CL-P1-009B validates required backup data before preview/import. CL-P1-009C rejects malformed tank entries before backup preview/import. CL-P1-009D rejects duplicate tank IDs before preview/import. CL-P1-009E rejects logs, livestock, equipment, and tasks that reference missing backup tank IDs before preview/import. CL-P1-009F rejects non-array tank-scoped child collections before preview/import. CL-P1-009G rejects missing or duplicate child record IDs before preview/import. CL-P1-009H rejects child records missing import-required fields before preview/import. CL-P1-009I skips optional cloud-restore child records whose tanks are not present locally or in the backup. CL-P1-009J rejects malformed nested log water-test/photo data before preview/import. CL-P1-009K rejects non-numeric nested water-test readings before preview/import. CL-P1-009L rejects invalid log and livestock date strings before preview/import. CL-P1-009M rejects invalid optional equipment/task dates before preview/import. CL-P1-009N rejects non-numeric child fields before preview/import. CL-P1-009O rejects archive photo entries that would restore to duplicate local filenames. CL-P1-009P rejects decimal values for integer-only child fields before preview/import. CL-P1-009Q rejects malformed tank root fields and water-target fields before preview/import. CL-P1-009R rejects invalid enum values before preview/import. CL-P1-009S rejects child records missing import-required metadata dates before preview/import. CL-P1-009T rejects backup JSON photo references whose bundled files are missing from the archive. CL-P1-009U rejects malformed optional child string fields before preview/import. CL-P1-009V rejects malformed optional task boolean fields before preview/import. CL-P1-009W rejects malformed equipment settings objects before preview/import. CL-P1-009X rejects child relationship IDs that point at missing backup records. CL-P1-009Y rejects malformed profile/preferences backup payloads before preview/import. CL-P1-009Z rejects malformed profile/preferences entry values before preview/import. CL-P1-009AA validates profile/preferences restore values before clearing existing local preferences. CL-P1-009AB ignores malformed non-exportable profile/preferences entries during preview validation. CL-P1-009AC reports malformed optional-restore profile/preferences payloads as preference restore failures. CL-P1-009AD skips malformed optional-restore tank, livestock, equipment, log, and task records without aborting valid sibling imports. CL-P1-009AE rejects cross-tank backup relationship targets before preview/import. CL-P1-009AF rejects missing referenced photo files during backup export before an invalid ZIP is created. CL-P1-009AG rejects livestock records missing required count data before preview/import. CL-P1-009AH rejects missing required log/equipment/task enum-like fields before preview/import. CL-P1-009AI rejects out-of-range water-test readings before preview/import. CL-P1-009AJ rejects out-of-range child numeric fields before preview/import. CL-P1-009AK rejects out-of-range tank numeric fields before preview/import. CL-P1-009AL rejects inverted tank target ranges before preview/import. CL-P1-009AM rejects records updated before creation before preview/import. CL-P1-009AN rejects custom recurring tasks without positive interval days before preview/import. CL-P1-009AO rejects recurring tasks without due dates before preview/import. CL-P1-009AP rejects water-test and water-change logs without their type-specific payloads before preview/import. CL-P1-009AQ rejects observation and medication logs without notes or photos before preview/import. CL-P1-009AR rejects generated task/equipment/livestock timeline logs without their backing relationship IDs before preview/import. CL-P1-009AS gives task deletion a 5-second undo snackbar that restores the deleted task. CL-P1-009AT restores the linked auto-maintenance task when equipment removal is undone. CL-P1-009AU gives wishlist item deletion a 5-second undo snackbar that restores the same local planning item. CL-P1-009AV gives local fish shop deletion a 5-second undo snackbar that restores the same saved shop. CL-P1-009AW gives Cost Tracker clear-all a 5-second undo snackbar that restores the same saved expense records. CL-P1-009AX gives bulk tank deletion the same 5-second undo window as single-tank deletion before storage is permanently deleted. CL-P1-009AY catches failed Log Detail deletion and keeps the log visible with normal error feedback. CL-P1-009AZ makes Livestock removal count feedback ASCII-safe in confirmation, journal, and snackbar copy. CL-P1-009BA makes Livestock bulk-move success feedback report the selected count after selection mode is cleared. CL-P1-009BB makes expired bulk Livestock removal write local timeline removal logs. CL-P1-009BC rolls back equipment removal if a linked maintenance-task delete fails mid-flow. CL-P1-009BD skips stale maintenance-task deletion when equipment has no linked task. CL-P1-009BE makes Tasks screen completion show success feedback after local writes. CL-P1-009BF rolls back Tasks screen completion if the completion log write fails. CL-P1-009BG catches failed Task snooze saves with unchanged local data and normal error feedback. CL-P1-009BH catches failed Task delete-undo restore saves with stable-context error feedback. CL-P1-009BI makes successful Task snooze show task-and-duration success feedback. CL-P1-009BJ makes successful Task add show task-named success feedback. CL-P1-009BK makes successful Equipment add show equipment-named success feedback. CL-P1-009BL makes successful Livestock add show count-and-name success feedback and writes ASCII-safe added-log count copy. CL-P1-009BM makes successful Cost Tracker expense add wait for the local save and show expense-named success feedback. CL-P1-009BN makes local fish shop add enable after name entry, wait for the local save, and show shop-named success feedback. CL-P1-009BO makes Shop Street budget save wait for the local preference write and show normal success/error feedback. CL-P1-009BP makes Wishlist add enable after name entry, wait for the local item save, and show item-named success/error feedback. CL-P1-009BQ makes Wishlist purchase wait for the local item save before applying budget spend and show normal error feedback without changing local data when purchase save fails. CL-P1-009BR makes Wishlist delete and delete-undo failures show normal error feedback while keeping local data consistent. CL-P1-009BS makes local fish shop delete and delete-undo failures show normal error feedback while keeping local data consistent. CL-P1-009BT makes equipment delete-undo restore failures show normal error feedback while keeping equipment and linked maintenance-task data consistently deleted. CL-P1-009BU rolls back Equipment service timestamps when maintenance-log saves fail and shows normal error feedback. CL-P1-009BV restores linked maintenance-task and service-log side effects when Equipment service task-completion logging fails. CL-P1-009BW restores tank and livestock visibility when soft-delete expiry permanent local deletes fail. CL-P1-009BX rolls back new-tank and partial default-task data when default task creation fails. CL-P1-009BY rolls back earlier livestock moves when a later bulk-move save fails. CL-P1-009BZ restores previous demo tank data when replacement sample-tank creation fails. CL-P1-009CA restores partial tank sort-order writes when reorder saves fail. CL-P1-009CB cleans up partial first-run demo seed data when sample creation fails. CL-P1-009CC rolls back Tank Detail task completion when completion logging or equipment side effects fail. CL-P1-009CD catches Tank Detail quick-feeding save failures with normal error feedback and unchanged local journal data. CL-P1-009CE catches failed Log Detail delete-undo restore writes with normal feedback. CL-P1-009CF catches failed Cost Tracker delete/clear undo restore writes with normal feedback and consistent local UI state. CL-P1-009CG catches failed Reminder delete/undo writes before notification side effects and keeps local reminder UI consistent. CL-P1-009CH catches failed Reminder add writes before visible-list changes or notification scheduling. CL-P1-009DE makes backup tank-scoped imports run through a tested transaction service that remaps related IDs, preserves timeline relationships, and rolls back imported tanks/children if a later child save fails. CL-P1-009DF persists migrated local JSON schema stamps after loading v0/v1 files. CL-P1-009DG surfaces local JSON corruption recovery in Backup & Restore with normal-user retry/start-fresh actions. CL-P1-009DH cleans newly restored backup photo files if tank import fails after photo extraction. CL-P1-009DI rolls back profile/preferences restore writes if an exportable preference write fails mid-restore. CL-P1-009DK treats failed Optional AI API-key preference writes/removals as local failures instead of reporting success. CL-P1-009DL treats Add Log profile-activity failures after durable local log saves as non-blocking progress warnings instead of failed log saves. CL-P1-009DM treats Create Tank profile-activity failures after durable local tank creation as non-blocking progress warnings instead of failed tank creation. CL-P1-009DN makes Smart AI history, anomaly history, and weekly-plan cache providers expose updated state only after durable local preference writes succeed. Remaining: broader edit/delete/undo coverage and restore/migration walkthrough QA. |
| CL-P1-010 | Profile/preferences | Centralise experience, goals, interests, units, region, AI, privacy, reminder intensity, motion/haptics, and reset controls. | In progress; CL-P1-010A polishes Tank Settings water-profile labels so tropical/coldwater target copy is readable and source-safe. CL-P1-010B lets users edit experience level and goals from Preferences without replaying onboarding. CL-P1-010C makes the Haptic Feedback preference control shared AppFeedback haptics. CL-P1-010D applies the in-app Reduce Motion override to descendant MediaQuery animation checks. CL-P1-010E adds guided reminder intensity presets to Notification Settings. CL-P1-010F adds a direct Privacy Policy route in Preferences. CL-P1-010G centralises Optional AI disclosure reset in Preferences. CL-P1-010H links Optional AI setup directly to the Privacy Policy. CL-P1-010I keeps the Units picker open with retry feedback when local preference saves fail. CL-P1-010J fixes Smart setup-context nudge contrast on its light card. CL-P1-010K treats failed Optional AI disclosure preference reset writes as local failures with unchanged accepted state and retry feedback. Remaining: any final AI/provider walkthrough gaps. |
| CL-P1-011 | Global search | Make search a top-bar/contextual/More feature, not a bottom tab. | Done for current complete-local search scope; CL-P1-011A adds grouped app, tool, learning-path, guide, settings/privacy/backup, species, equipment, livestock, and local log search results. CL-P1-011B adds Tank top-bar and More hub entry points, route coverage, layout guardrails, and phone/tablet Android evidence under `docs/qa/screenshots/2026-06-22/cl-p1-011-global-search/`. Remaining: optional direct-per-lesson deep links only if future walkthroughs show users need them. |
| CL-P1-012 | Demo mode | Provide one polished sample tank, resettable and separate from real data. | Done for current complete-local demo scope; quick start and Settings can add the populated sample tank, clearly marked as demo data. CL-P1-012A makes sample-tank creation reset/replace existing demo tanks without touching real tanks. CL-P1-012B captures final phone/tablet Android screen evidence under `docs/qa/screenshots/2026-06-22/cl-p1-012-demo-mode/`. |

Recent CL-P1-009 continuation note:

- CL-P1-009CI catches failed Reminder completion writes before visible-list
  changes or notification side effects.
- CL-P1-009CJ makes first-run profile creation wait for the immediate local
  `user_profile` save before exposing the new profile state.
- CL-P1-009CK makes profile edits wait for the immediate local `user_profile`
  save before exposing edited profile state.
- CL-P1-009CL makes placement-test skip wait for the immediate local
  `user_profile` save before exposing skipped placement state.
- CL-P1-009CM makes streak-freeze grants wait for the immediate local
  `user_profile` save before exposing granted freeze state.
- CL-P1-009CN makes achievement progress updates wait for the immediate local
  `user_profile` save before exposing achievement/XP state.
- CL-P1-009CO makes energy/hearts updates wait for the immediate local
  `user_profile` save before exposing heart-count/refill state.
- CL-P1-009CP makes story progress updates wait for the immediate local
  `user_profile` save before exposing story-progress/completion state.
- CL-P1-009CQ makes gem refunds wait for the immediate local `gems_state`
  save before exposing restored balance/transaction state.
- CL-P1-009CR makes gem grants wait for the immediate local `gems_state`
  save before exposing granted balance/transaction state.
- CL-P1-009CS makes consumable inventory effects wait for the local
  `shop_inventory` consumption save before applying profile/energy effects.
- CL-P1-009CT rejects duplicate permanent shop-item purchases before any
  `gems_state` spend write is attempted.
- CL-P1-009CU rolls back in-memory gem cumulative earned/spent counters when
  immediate local `gems_state` saves fail.
- CL-P1-009CV restores persisted `gems_state` after gem earn/spend/refund/grant
  partial writes where `gems_cumulative` fails.
- CL-P1-009CW makes app settings wait for local preference writes before
  exposing updated theme/unit/toggle state.
- CL-P1-009CX makes wishlist item changes wait for local `wishlist_items`
  preference writes before exposing added/removed/updated planning state.
- CL-P1-009CY makes Shop Street budget and local shop changes wait for local
  SharedPreferences writes before exposing updated planning state.
- CL-P1-009CZ makes earned species unlocks wait for local
  `unlocked_species_v1` writes before exposing updated unlock state.
- CL-P1-009DA catches failed Tank Journal new-entry saves with inline feedback
  and keeps the entry sheet open for retry.
- CL-P1-009DB catches failed Inventory item-use writes with normal retry
  feedback while keeping the owned item visible.
- CL-P1-009DC catches failed Crash Reports consent writes from Preferences
  before the visible switch changes or diagnostics consent is applied.
- CL-P1-009DD makes local JSON entity saves/deletes expose in-memory state only
  after the durable file write succeeds.
- CL-P1-009DE makes backup tank-scoped imports run through a tested
  transaction service that remaps related IDs, preserves timeline relationships,
  and rolls back imported tanks and children if a later child save fails.
- CL-P1-009DF persists migrated local JSON schema stamps after loading v0/v1
  files, so restore and migration walkthroughs do not re-run the same migration
  on every launch.
- CL-P1-009DG surfaces local JSON corruption recovery in Backup & Restore with
  normal-user copy, retry, and confirmed start-fresh actions.
- CL-P1-009DH cleans up newly restored backup photo files if a tank-scoped
  import fails after photo extraction, while preserving any pre-existing local
  photos.
- CL-P1-009DI rolls back previous exportable profile/preferences values if a
  platform preference write fails mid-restore.
- CL-P1-009DJ shows normal retry feedback when single livestock removal expiry
  restores the fish after the permanent local delete write fails, and avoids a
  false removal timeline log.
- CL-P1-009DK treats failed Optional AI API-key `SharedPreferences` save/remove
  return values as real local write failures instead of reporting success.
- CL-P1-009DL treats Add Log profile-activity failures after durable local log
  saves as non-blocking progress warnings instead of failed log saves.
- CL-P1-009DM treats Create Tank profile-activity failures after durable local
  tank creation as non-blocking progress warnings instead of failed tank
  creation.
- CL-P1-009DN makes Smart AI history, anomaly history, and weekly-plan cache
  providers expose updated state only after durable local preference writes
  succeed.
- CL-P1-009DO flushes pending debounced achievement progress to local
  `SharedPreferences` on app pause/detach so earned-progress writes are not
  left behind if Android kills the app before the debounce timer fires. Restore
  cancellation also clears pending progress so backup imports cannot be
  overwritten by a stale lifecycle flush.
- CL-P1-009DP rolls back visible spaced-repetition review-card changes when
  create, lesson auto-seed, or delete writes fail, preventing unsaved practice
  progress from appearing in local state.
- CL-P1-009DQ makes room-vibe apply flows wait for the local `room_theme`
  preference write before exposing the changed theme or showing success
  feedback.
- CL-P1-009DR makes Reduce Motion preference changes wait for successful local
  writes/removals, clears manual overrides correctly, and reports retry
  feedback instead of false success when the preference save fails.
- CL-P1-009DS makes first-visit guidance prompts call their dismissal callback
  only after the local guidance-seen flag is saved, keeping prompts retryable
  when local persistence fails.
- CL-P1-009DT makes seasonal tip dismissals wait for the monthly local
  dismissal flag save before hiding the card, keeping the tip retryable when
  local persistence fails.
- CL-P1-009DU makes first-run consent and under-13 block actions wait for
  durable local preference writes before advancing, showing retry feedback
  instead of false completion when local persistence fails.
- CL-P1-009DV treats false `user_profile` preference write results as local
  profile save failures before exposing created or updated profile state.
- CL-P1-009DW treats false schema-version stamp writes as migration failures,
  preventing startup migrations from silently claiming completion without a
  durable local version marker.
- CL-P1-009DX treats false onboarding completion preference writes as setup
  save failures, so the router cannot advance as if first-run setup was
  durably completed.
- CL-P1-009DY treats false shared guidance dismissal writes as local dismissal
  failures for both forever and one-day prompt scopes.
- CL-P1-009DZ treats false gem balance, cumulative counter, and rollback
  preference writes as local save failures instead of exposing false reward
  progress.
- CL-P1-009EA treats false inventory preference writes as local item-use and
  purchase save failures, preserving visible inventory state and refunding gems
  when the purchased item cannot be saved.
- CL-P1-009EB treats false spaced-repetition card/stat preference writes as
  local review-card save failures, keeping create, auto-seed, and delete paths
  rollback-safe.
- CL-P1-009EC treats false Reminder and Cost Tracker preference writes as local
  save failures, keeping add/complete/clear paths rollback-safe with normal
  retry feedback.
- CL-P1-009ED treats false Maintenance Checklist preference writes as local
  save failures, keeping weekly/monthly checklist progress rollback-safe and
  exporting the versioned checklist snapshot in local backups.
- CL-P1-009EE treats false Difficulty Settings preference writes as local save
  failures, keeping manual difficulty override selections unchanged with normal
  retry feedback.
- CL-P1-009EF treats false review-request preference writes as local tracking
  failures, using `RateService` for both service and lesson-completion review
  prompts.
- CL-P1-009EG treats false API rate-limit preference writes as non-durable
  local saves while keeping the current app session rate-limited.
- CL-P1-009EH preserves legacy `UserProfile.inventory` during failed
  `shop_inventory` migration writes so retryable migration cannot lose owned
  items.
- CL-P1-009EI saves spaced-repetition session counts before streak/achievement
  side effects, keeping the active review session retryable when the local
  session-count write fails.
- CL-P1-009EJ treats false spaced-repetition streak writes as local streak
  update failures, preserving the previous visible streak and saving completed
  review sessions without recording fake streak progress.
- CL-P1-009EK keeps debounced achievement progress pending after a false
  `achievement_progress` preference write, so the lifecycle flush can retry
  instead of dropping the latest local reward progress.
- CL-P1-009EL treats false Delete My Data preference-clear results as local
  deletion failures, preventing the destructive privacy flow from continuing to
  file deletion, onboarding reset, or navigation after preferences reject the
  clear.
- CL-P1-009EM treats false onboarding reset preference removals as local reset
  failures, so settings/debug/data-deletion reset paths can use their existing
  retry handling instead of reporting a reset when `onboarding_completed`
  remains saved.
- CL-P1-009EN makes Preferences Replay Onboarding catch failed onboarding reset
  writes, keep the user on Settings, and show retry feedback instead of
  navigating away after an unsaved reset.
- CL-P1-009EO makes Preferences Clear All Data describe the actual local
  tanks/logs/tasks/photos scope instead of implying settings are deleted by
  that narrower action.
- CL-P1-009EP makes Add Log edits save the existing local log without awarding
  duplicate XP/streak/achievement progress, replaying new-entry visual effects,
  or leaving the saved edit form open behind the dirty-form guard.
- CL-P1-009EQ makes successful Tank Settings edits mark the form as saved before
  closing so durable tank updates are not trapped behind the unsaved-changes
  prompt.
- CL-P1-009ER rolls back newly saved equipment when auto maintenance-task sync
  fails during add, preventing the equipment list from showing a partial add
  after the user sees failure feedback.
- CL-P1-009ES keeps newly added equipment saved when only the secondary
  profile-progress write fails, showing progress-specific feedback instead of a
  generic add failure.
- CL-P1-009ET keeps newly added livestock and its readable timeline log saved
  when only the secondary profile-progress write fails, showing
  progress-specific feedback instead of a generic add failure.
- CL-P1-009EU rolls back bulk livestock add records when a readable timeline
  log save fails mid-add, preventing partial livestock without matching local
  journal evidence.
- CL-P1-009EV rolls back single livestock add records when the readable
  timeline log save fails, preventing partial livestock without matching local
  journal evidence.
- CL-P1-009EW keeps Quick Water Test logs saved when only the secondary
  profile-XP write fails, showing progress-specific feedback instead of a
  false water-test save failure.
- CL-P1-009EX makes profile reset reject failed local preference removals
  before exposing a reset profile state.
- CL-P1-009EY stops practice-mode lesson completion from claiming XP when the
  profile XP write fails or cannot be applied.
- CL-P1-009EZ marks the energy explainer as seen only after the user dismisses
  the dialog, and avoids saving the seen flag when the lesson screen unmounts
  before the prompt can be shown.
- CL-P1-009FA routes the Tank stage sheet first-use hint through the shared
  preferences provider so hint persistence uses the same local boundary as the
  rest of the app.
- CL-P1-009FB stops Weekly Plan before any Optional AI request when the local
  AI disclosure acceptance flag cannot be saved, keeping the flag unset and the
  care-plan cache empty with normal retry feedback.
- CL-P1-009FC stops Symptom Triage before any Optional AI diagnosis stream when
  the local AI disclosure acceptance flag cannot be saved, keeping the flag
  unset with normal retry feedback.
- CL-P1-009FD stops Fish ID before any Optional AI image-identification request
  when the local AI disclosure acceptance flag cannot be saved, keeping the flag
  unset with normal retry feedback.
- CL-P1-009FE routes all current Optional AI OpenAI request surfaces through a
  shared disclosure gate, including stocking suggestions and compatibility
  advice, so failed disclosure acceptance writes stop before any request.
- CL-P1-009FF keeps the Tank stage sheet first-use hint visible and retryable
  when the local `hasSeenSheetHint` write returns false.
- CL-P1-009FG makes spaced-repetition reset reject failed local removals,
  restore any partially removed review JSON, and keep visible cards/stats
  unchanged with retry feedback.
- CL-P1-009FH checks failed Tank returning-user prompt dismissal writes so
  day-2, day-7, and day-30 cards do not silently consume their seen flags when
  local preference persistence fails.
- CL-P1-009FI makes spaced-repetition reset own card, stats, streak, and
  session preference removals, restoring partially removed JSON when any reset
  removal fails.
- CL-P1-009FJ makes gem and inventory reset helpers reject failed local
  preference removals before reporting reset success.
- CL-P1-009FK makes the Debug achievement reset reject failed local progress
  removals/profile writes and restore achievement progress if the profile write
  fails after removal.

## 7. P2 Work - Presentation System

| ID | Area | Work | Acceptance |
| --- | --- | --- | --- |
| CL-P2-001 | Design system | Run a full visual redesign pass while preserving the current illustrated watercolor/tank-room direction. | Every screen has a clear primary job, custom-fit visual, and consistent hierarchy. |
| CL-P2-002 | Tablet | Design tablet layouts instead of stretching phone screens. | In progress; CL-P2-002A makes Workshop use bounded adaptive tool columns on tablet portrait/landscape and keeps phone large-text tool cards overflow-safe. CL-P2-002B constrains Lesson reader and quiz content/actions to a readable tablet width. CL-P2-002C constrains Learn hub cards, progress copy, and learning path cards to the same readable tablet rail while preserving the full-bleed illustrated header. CL-P2-002D constrains Smart Hub content cards to the same readable tablet rail while preserving the full-bleed illustrated header. CL-P2-002E constrains fish species and plant database browser/detail content to the same readable tablet rail. CL-P2-002F constrains Tank Journal, Activity Log, and Log Detail timeline content to the same readable tablet rail. CL-P2-002G constrains Livestock summary/list/skeleton/bulk-action surfaces to the same readable tablet rail. CL-P2-002H constrains Tasks and Maintenance checklist cards/headers to the same readable tablet rail. CL-P2-002I constrains Equipment warning, loading, and equipment-card surfaces to the same readable tablet rail. CL-P2-002J constrains Water Change Calculator inputs, results, guidance, and reference cards to the same readable tablet rail. CL-P2-002K constrains Cycling Assistant phase, guided-action, diagram, education, and action cards to the same readable tablet rail. CL-P2-002L constrains Compatibility Checker search, selection, verdict, issue, setup, and guided-log surfaces to the same readable tablet rail. CL-P2-002M constrains Lighting Schedule setup, schedule, timeline, recommendation, guided-log, guide, and CO2 timing surfaces to the same readable tablet rail. CL-P2-002N constrains Dosing Calculator safety, input, validation, result, guided-log, and product preset surfaces to the same readable tablet rail. CL-P2-002O constrains CO2 Calculator intro, input, validation, result, guided-log, reference, drop-checker, tips, and table surfaces to the same readable tablet rail. CL-P2-002P constrains Tank Volume Calculator unit, shape, dimension, result, apply, and tips surfaces to the same readable tablet rail. CL-P2-002Q constrains Stocking Calculator setup, validation, meter, search, result list, advice, and guided-log surfaces to the same readable tablet rail. CL-P2-002R constrains Unit Converter guidance, input, conversion result, and reference surfaces across all converter tabs to the same readable tablet rail. CL-P2-002S constrains Cost Tracker empty, summary, category, and expense surfaces to the same readable tablet rail. CL-P2-002T constrains Acclimation Guide intro, method, step, tip, and sensitive-species surfaces to the same readable tablet rail. CL-P2-002U constrains Feeding Guide intro, frequency, food-type, mistake, and fasting surfaces to the same readable tablet rail. CL-P2-002V constrains Emergency Guide intro, emergency, expansion, and kit checklist surfaces to the same readable tablet rail. CL-P2-002W constrains Quarantine Guide intro, setup, protocol, symptom, medication, and tips surfaces to the same readable tablet rail. CL-P2-002X constrains Disease Guide search, disclaimer, disease-card, expanded treatment, and prevention surfaces to the same readable tablet rail. CL-P2-002Y constrains Parameter Guide intro, parameter cards, expanded tips, and quick-reference surfaces to the same readable tablet rail while cleaning source-unsafe chemistry/temperature copy. CL-P2-002Z constrains Equipment Guide category headers, equipment cards, and expanded pros/cons/maintenance surfaces to the same readable tablet rail. CL-P2-002AA constrains Algae Guide intro, algae cards, algae-eating crew cards, and prevention checklist surfaces to the same readable tablet rail. CL-P2-002AB constrains Breeding Guide intro, method, conditioning, fry-stage, easy-breeder, and warning surfaces to the same readable tablet rail while cleaning source-unsafe breeding copy. CL-P2-002AC constrains Vacation Guide intro, duration, checklist, feeding-option, sitter, extended-absence, and return-step surfaces to the same readable tablet rail while cleaning source-unsafe vacation checklist copy. CL-P2-002AD constrains Quick Start Guide hero, setup-step, cycle-warning, and beginner-mistake surfaces to the same readable tablet rail while cleaning source-unsafe beginner bullet and mistake-arrow copy. CL-P2-002AE constrains Nitrogen Cycle Guide intro, cycle-stage, cycling-method, completion-check, and tip surfaces to the same readable tablet rail while cleaning source-unsafe chemistry, temperature, and method bullet copy. CL-P2-002AF constrains Substrate Guide intro, substrate-card, tank-type, layering, and pro-tip surfaces to the same readable tablet rail while cleaning source-unsafe substrate bullet and amount-formula copy. CL-P2-002AG constrains Hardscape Guide intro, rock-card, wood-card, preparation, design-tip, and safety-note surfaces to the same readable tablet rail while cleaning source-unsafe hardscape safety bullets. CL-P2-002AH constrains Backup & Restore intro, export, import, exported-item, recovery, and import-safety surfaces to the same readable tablet rail. CL-P2-002AI constrains Account offline-local, signed-out, and signed-in surfaces to the same readable tablet rail while cleaning Account success copy. CL-P2-002AJ constrains Achievements progress/filter surfaces and uses a bounded adaptive trophy grid on tablet while cleaning Achievements source copy. CL-P2-002AK constrains Inventory owned-item grids and permanent reward collections with bounded adaptive tablet layouts while preserving narrow horizontal collection behavior. CL-P2-002AL constrains Gem Shop category grids with a centered bounded adaptive tablet layout while preserving compact phone behavior. CL-P2-002AM constrains Shop Street header, wishlist entry points, budget summary, and local-shop planning card to a centered readable tablet rail. CL-P2-002AN constrains Wishlist saved-item lists to a centered readable tablet rail while preserving compact phone list behavior. CL-P2-002AO constrains About identity, feature rows, community copy, and policy actions to a centered readable tablet rail. CL-P2-002AP constrains FAQ question cards and expanded answer copy to a centered readable tablet rail. CL-P2-002AQ constrains Privacy Policy header, summary, legal sections, data-rights cards, and contact card to a centered readable tablet rail. CL-P2-002AR constrains Terms of Service legal sections, action buttons, and agreement notice to a centered readable tablet rail. CL-P2-002AS constrains Glossary search, category filters, term count, and term cards to a centered readable tablet rail. CL-P2-002AT constrains Settings Hub profile, section headers, destination tiles, and footer to a centered readable tablet rail. CL-P2-002AU constrains Reminders overdue/upcoming headers and reminder cards to a centered readable tablet rail. CL-P2-002AV constrains Search result section headers, spacers, and cards to a centered readable tablet rail. CL-P2-002AW constrains Water Charts parameter chips, chart controls, alerts, chart area, summary card, and recent values table to a centered readable tablet rail. CL-P2-002AX constrains Analytics loading skeletons, time range chips, overview stats, charts, insights, topic breakdown, and prediction surfaces to a centered readable tablet rail. CL-P2-002AY constrains Livestock Detail header, compatibility, care guide, parameter, tankmate, and missing-species cards to a centered readable tablet rail. Remaining: full tablet pass across any remaining stretched phone surfaces. |
| CL-P2-003 | Assets | Regenerate weak headers/backgrounds/sprites and add missing badges/decorations in the established style. | No first-class surface uses mismatched or low-quality art. |
| CL-P2-004 | Accessibility | Meet baseline contrast, 48dp touch targets, labels/tooltips, text scaling, reduced motion, and non-colour-only status. | Basic accessibility audit passes on phone and tablet. |
| CL-P2-005 | Motion/haptics | Add purposeful motion to tank life, feeding, rewards, warnings, onboarding, and feedback; keep haptics subtle and optional. | Motion adds charm and clarity without noise. |
| CL-P2-006 | Performance | Create and meet a formal performance target on a mid-range Android phone. | Startup, tab switching, tank animation, scrolling, and image loads remain smooth. |

## 8. P3 Work - AI Expansion

AI expansion comes after the local core is strong.

| ID | Area | Work | Acceptance |
| --- | --- | --- | --- |
| CL-P3-001 | Providers | Add provider model: OpenAI, Anthropic, Gemini, OpenRouter, Mistral, and recommended default. | In progress; CL-P3-001A makes Optional AI setup provider-aware by naming OpenAI as the current recommended BYO key provider, listing Anthropic, Google Gemini, OpenRouter, and Mistral as unavailable local key paths in this version, and fixing tall dialog overflow. Remaining: implement real non-OpenAI provider connectors before enabling those key paths. |
| CL-P3-002 | Confirm writes | Require confirmation before AI changes tank data, tasks, journal, reminders, or care plans. | In progress; CL-P3-002A makes Symptom Triage ask for confirmation before saving an AI-generated diagnosis to the tank journal, and focused widget coverage verifies canceling the dialog writes no log. CL-P3-002B makes Weekly Plan ask before caching an AI-generated care plan, and focused widget coverage verifies canceling the dialog leaves `weekly_plan_cache` empty. Remaining: confirm-before-write coverage for AI changes to tank data, tasks, and reminders. |
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
| CL-QA-007 | Debug tools | Expand QA seed states for emergencies, bad water, incompatible fish, skipped onboarding, demo mode, unlocks, tablet, and AI/no-AI. | In progress; CL-QA-007A adds a debug-only emergency unsafe-water seed that creates `QA Emergency Water Spike`, a sick livestock entry, and an unsafe ammonia/nitrite/nitrate water-test log through local storage. CL-QA-007B adds a debug-only incompatible-fish seed that creates `QA Incompatible Fish Tank` with Betta plus Guppy and verifies the existing livestock visual service reports `compatibilityConcern`. CL-QA-007C adds a skipped-onboarding quick-start seed that writes a beginner freshwater profile, creates the populated `Sample Tank`, selects the Tank tab, and persists the onboarding-completed flag. CL-QA-007D adds a no-AI Smart Hub seed that clears local Optional AI key/disclosure state and creates `QA No-AI Smart Hub` with a high-nitrate water-test log, without adding fake provider readiness. CL-QA-007E adds a partial unlock-edge seed that writes 900 XP, a 6-day streak, 9 completed lessons, Betta species unlock, Driftwood Arch unlock/equip, and Evening Glow room theme while keeping later unlock thresholds locked. CL-QA-007F adds a tablet visual-stress seed that creates `QA Tablet Long Layout Community Tank` with long-copy livestock, equipment, tasks, and varied logs for dense tablet walkthroughs. Remaining seed state: any real keyed-AI state only when it can avoid fake provider readiness. |

Current QA note: `danio_api36` exists and boots, but ADB transport dropped
during blackbox and focused verification on 2026-06-13. See
`danio-complete-local-current-audit-2026-06-13.md`.

Current verification note: as of the wishlist provider save-ordering slice
on 2026-06-21, `flutter test` passes 1747 tests,
`flutter analyze` is clean, and a debug APK builds successfully.
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
