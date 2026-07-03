# Danio Screen Inventory

Status: Bootstrap inventory
Created: 2026-07-03
Source: repo source inspection, `FINISH_MAP.md`, current audit/backlog docs,
existing widget tests, and committed screenshot folders.

Unknown visual or route state is recorded as `Needs evidence`. Do not replace
that with assumptions.

## Inventory Rules

- `Source` points to the primary implementation file. Re-export shims are noted
  only when they are the import path used by routes.
- `Route` is a practical navigation note, not a complete named-route contract.
  Danio currently uses nested tab navigators and `MaterialPageRoute` helpers
  rather than a full named-route map.
- `Tests` list focused tests where found during source inspection. Missing
  tests should be filled by future slices.
- `Evidence` is current only when it points to committed local screenshot,
  XML, golden, or documented QA evidence.

## Shell And Primary Tabs

| Surface | Source | Purpose | Route | Tests | Evidence | Phone/tablet state | Known gaps |
| --- | --- | --- | --- | --- | --- | --- | --- |
| App shell / tab navigator | `lib/screens/tab_navigator.dart` | Five-tab shell: Learn, Practice, Tank, Smart, More | App root after onboarding | `test/widget_tests/tab_navigator_test.dart` | Needs evidence | Tank is default tab in source | Whole-app current phone/tablet audit pending |
| Learn tab | `lib/screens/learn/learn_screen.dart` | Learning paths and progress | Tab 0 root | `test/widget_tests/learn_screen_test.dart`, `test/screens/learn_screen_test.dart` | Older and focused evidence exists; current whole-app evidence needs refresh | Tablet rail work recorded in backlog | Needs current full visual evidence |
| Practice tab | `lib/screens/practice_hub_screen.dart` | Practice hub and drills | Tab 1 root | `test/widget_tests/practice_hub_screen_test.dart` | Older phase3 evidence exists | Implemented for current scope | Needs current phone/tablet inventory evidence |
| Tank tab | `lib/screens/home/home_screen.dart` | Daily tank ritual, room scene, care actions | Tab 2 root | `test/widget_tests/home_screen_test.dart`, `test/widget_tests/home_screen_layout_test.dart` | `docs/qa/screenshots/2026-06-22/cl-p0-005-tank-daily-loop/` | P0 daily-loop evidence exists | Living tank seasonal/plant visual depth remains |
| Smart tab | `lib/screens/smart_screen.dart` | Local intelligence and optional AI entry points | Tab 3 root and `AppRoutes.toSmartTools` | `test/widget_tests/smart_screen_test.dart` | Needs current full evidence | No-AI intelligence marked Done | Optional AI provider expansion remains |
| More / settings hub | `lib/screens/settings_hub_screen.dart` | Settings, guides, tools, policy, debug entry | Tab 4 root | `test/widget_tests/settings_hub_screen_test.dart` | Older phase4 evidence exists | Tablet Settings Hub constrained | Needs current full evidence |

## Onboarding And First Run

| Surface | Source | Purpose | Route | Tests | Evidence | Phone/tablet state | Known gaps |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Onboarding coordinator | `lib/screens/onboarding_screen.dart` | First-run flow orchestration | Startup before completed onboarding | `test/widget_tests/onboarding_test.dart` | `docs/qa/screenshots/2026-06-22/cl-p0-004-first-run/` | P0 evidence exists | Recheck if first-run flow changes |
| Consent | `lib/screens/onboarding/consent_screen.dart` | Privacy/age consent start | Onboarding step | `test/widget_tests/consent_screen_test.dart` | First-run evidence exists | Phone/tablet evidence exists | None current |
| Age blocked | `lib/screens/onboarding/age_blocked_screen.dart` | Under-age safe stop | Onboarding branch | `test/widget_tests/age_blocked_screen_test.dart` | Needs evidence | Copy honesty guarded | Needs current visual evidence |
| Welcome | `lib/screens/onboarding/welcome_screen.dart` | Intro to Danio | Onboarding step | `test/widget_tests/welcome_screen_test.dart` | First-run evidence exists | Phone/tablet evidence exists | None current |
| Region and units | `lib/screens/onboarding/region_units_screen.dart` | Region/unit preference capture | Onboarding step | `test/widget_tests/region_units_screen_test.dart` | First-run evidence exists | Phone/tablet evidence exists | None current |
| Experience level | `lib/screens/onboarding/experience_level_screen.dart` | Experience capture | Onboarding step | `test/widget_tests/experience_level_screen_test.dart` | First-run evidence exists | Phone evidence exists | Tablet exact step evidence partial |
| Tank status | `lib/screens/onboarding/tank_status_screen.dart` | Tank stage capture | Onboarding step | `test/widget_tests/tank_status_screen_test.dart` | First-run evidence exists | Phone/tablet evidence exists | None current |
| Goals | `lib/screens/onboarding/goals_screen.dart` | Multi-goal capture | Onboarding step | `test/widget_tests/goals_screen_test.dart` | First-run evidence exists | Phone/tablet evidence exists | None current |
| Micro lesson | `lib/screens/onboarding/micro_lesson_screen.dart` | Short learning moment | Onboarding step | `test/widget_tests/micro_lesson_screen_test.dart` | First-run evidence exists | Phone evidence exists | Tablet exact evidence partial |
| XP celebration | `lib/screens/onboarding/xp_celebration_screen.dart` | First reward feedback | Onboarding step | `test/widget_tests/xp_celebration_screen_test.dart` | First-run evidence exists | Phone/tablet evidence exists | None current |
| Fish select | `lib/screens/onboarding/fish_select_screen.dart` | Starter fish selection | Onboarding step | `test/widget_tests/fish_select_screen_test.dart` | First-run evidence exists | Phone/tablet evidence exists | None current |
| Aha moment | `lib/screens/onboarding/aha_moment_screen.dart` | Profile summary moment | Onboarding step | `test/widget_tests/aha_moment_screen_test.dart` | First-run evidence exists | Phone evidence exists | Tablet exact evidence partial |
| Feature summary | `lib/screens/onboarding/feature_summary_screen.dart` | Honest feature summary, no paywall | Onboarding step | `test/widget_tests/feature_summary_screen_test.dart` | First-run evidence exists | Phone evidence exists | Tablet exact evidence partial |
| Push permission | `lib/screens/onboarding/push_permission_screen.dart` | Optional notification step | Onboarding step | `test/widget_tests/push_permission_screen_test.dart` | First-run evidence exists | Phone evidence exists | Tablet exact evidence partial |
| Warm entry | `lib/screens/onboarding/warm_entry_screen.dart` | Return-to-app handoff | Onboarding/returning branch | `test/widget_tests/warm_entry_screen_test.dart` | First-run evidence exists | Phone evidence exists | Tablet evidence partial |

## Tank, Care, Timeline, And Data

| Surface | Source | Purpose | Route | Tests | Evidence | Phone/tablet state | Known gaps |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Today Board | `lib/screens/home/widgets/today_board.dart` | Priority, warnings, care rail | Tank root component | `test/widget_tests/today_board_test.dart` | Tank daily-loop evidence exists | P0 evidence exists | Recheck if task/water logic changes |
| Create Tank | `lib/screens/create_tank_screen.dart` | New tank setup | `AppRoutes.toCreateTank` and inline routes | `test/widget_tests/create_tank_screen_test.dart` | Needs evidence | Source enforces freshwater scope | Needs current phone/tablet evidence |
| Tank Detail | `lib/screens/tank_detail/tank_detail_screen.dart` | Per-tank dashboard and quick adds | `AppRoutes.toTankDetail` | `test/widget_tests/tank_detail_screen_test.dart` | Needs evidence | Widget coverage exists | Current phone/tablet evidence needed |
| Tank Settings | `lib/screens/tank_settings_screen.dart` | Edit selected tank | Inline route | `test/widget_tests/tank_settings_screen_test.dart` | Older phase2 evidence exists | Data save loops fixed in docs | Needs current tablet evidence |
| Add Log | `lib/screens/add_log/add_log_screen.dart` | Water, feed, change, observation, medication logs | `AppRoutes.toAddLog` | `test/widget_tests/add_log_screen_test.dart` | Needs evidence | Data resilience coverage exists | Current visual evidence needed |
| Logs | `lib/screens/logs_screen.dart` | Legacy/per-tank log list | Inline route | `test/widget_tests/logs_screen_test.dart` | Needs evidence | Widget coverage exists | Route/evidence needs refresh |
| Log Detail | `lib/screens/log_detail_screen.dart` | Inspect/delete a log | Inline route | `test/widget_tests/log_detail_screen_test.dart` | Needs evidence | Delete failure fixed in docs | Current evidence needed |
| Tank Journal | `lib/screens/journal_screen.dart` | Unified local timeline | Inline route | `test/widget_tests/journal_screen_test.dart` | `docs/qa/screenshots/2026-06-22/cl-p1-008-timeline-walkthrough/` | Timeline walkthrough exists | Future tool/AI save handoff evidence |
| Photo Gallery | `lib/screens/photo_gallery_screen.dart` | Log photo viewing | Inline route | `test/widget_tests/photo_gallery_screen_test.dart` | Needs evidence | Widget coverage exists | Current evidence needed |
| Water Charts | `lib/screens/charts_screen.dart` | Water parameter charts | Inline route | `test/widget_tests/charts_screen_test.dart` | Needs evidence | Tablet rail recorded in backlog | Current evidence needed |
| Analytics | `lib/screens/analytics/analytics_screen.dart` | Progress and care analytics | Inline route | `test/widget_tests/analytics_screen_test.dart` | Needs evidence | Tablet rail recorded in backlog | Current evidence needed |
| Compare Tanks | `lib/screens/tank_comparison_screen.dart` | Multi-tank priority/history comparison | Inline route | `test/widget_tests/tank_comparison_screen_test.dart` | `docs/qa/screenshots/2026-06-22/cl-p1-007-multi-tank/` | Phone/tablet evidence exists | Recheck if comparison logic changes |
| Tasks | `lib/screens/tasks_screen.dart` | Care tasks and due actions | Inline route | `test/widget_tests/tasks_screen_test.dart` | Needs evidence | Tablet rail recorded in backlog | Current evidence needed |
| Maintenance Checklist | `lib/screens/maintenance_checklist_screen.dart` | Task checklist surface | Inline route | `test/widget_tests/maintenance_checklist_screen_test.dart` | Needs evidence | Tablet rail recorded in backlog | Current evidence needed |
| Equipment | `lib/screens/equipment_screen.dart` | Equipment list and maintenance | Inline route | `test/widget_tests/equipment_screen_test.dart` | Needs evidence | Tablet rail recorded in backlog | Current evidence needed |
| Livestock | `lib/screens/livestock/livestock_screen.dart` | Tank livestock management | Inline route | `test/widget_tests/livestock_screen_test.dart` | Needs evidence | Tablet rail recorded in backlog | Current evidence needed |
| Livestock Detail | `lib/screens/livestock_detail_screen.dart` | Animal detail, compatibility, care guide | Inline route | `test/widget_tests/livestock_detail_screen_test.dart` | Needs evidence | Tablet rail recorded in backlog | Current evidence needed |
| Livestock Value | `lib/screens/livestock_value_screen.dart` | Livestock value/cost support | Inline route | `test/widget_tests/livestock_value_screen_test.dart` | Needs evidence | Widget coverage exists | Current evidence needed |
| Reminders | `lib/screens/reminders_screen.dart` | Reminder list and settings entry | Inline route | `test/widget_tests/reminders_screen_test.dart` | Needs evidence | Paused resilience test is dirty | Preserve paused test change |
| Backup and Restore | `lib/screens/backup_restore_screen.dart` | Local export/import/recovery | More/settings route | `test/widget_tests/backup_restore_screen_test.dart`, `test/widget_tests/backup_restore_screen_empty_state_test.dart` | Older phase4 evidence exists | Extensive data validation in docs | Restore/migration Android walkthrough pending |

## Learning, Practice, And Stories

| Surface | Source | Purpose | Route | Tests | Evidence | Phone/tablet state | Known gaps |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Learning path detail | `lib/screens/learn/learning_path_detail_screen.dart` | Path overview and lessons | Inline from Learn | Covered by Learn/Lesson tests | Needs evidence | Tablet rail recorded | Current evidence needed |
| Lesson reader | `lib/screens/lesson/lesson_screen.dart` | Lesson, quiz, completion, emergency action | Inline and `AppRoutes.toLessonReplacement` | `test/widget_tests/lesson_screen_test.dart` | Needs evidence | Tablet rail recorded | Richer visual depth remains |
| Unlock celebration | `lib/screens/learn/unlock_celebration_screen.dart` | Unlock reward feedback | Inline from learning/rewards | Needs focused test confirmation | Needs evidence | Needs evidence | Add inventory row when tested |
| Story Browser | `lib/screens/story/story_browser_screen.dart` | Story catalog and locks | `AppRoutes.toStoryBrowser` | `test/widget_tests/story_browser_screen_test.dart` | Needs evidence | Widget coverage exists | Current visual evidence needed |
| Story Play | `lib/screens/story/story_play_screen.dart` | Interactive story play | `AppRoutes.toStoryPlay` | `test/widget_tests/story_browser_screen_test.dart` | Needs evidence | Exit confirmation covered | Current visual evidence needed |
| Spaced Repetition | `lib/screens/spaced_repetition_practice/spaced_repetition_practice_screen.dart` | Review queue entry | `AppRoutes.toSpacedRepetition` | `test/widget_tests/spaced_repetition_practice_screen_test.dart` | Needs evidence | Widget coverage exists | Current visual evidence needed |
| Review Session | `lib/screens/spaced_repetition_practice/review_session_screen.dart` | Active review session | Inline from SRS | `test/widget_tests/review_session_screen_test.dart` | Needs evidence | Widget coverage exists | Current visual evidence needed |
| Difficulty Settings | `lib/screens/difficulty_settings_screen.dart` | Practice difficulty controls | Inline route | `test/widget_tests/difficulty_settings_screen_test.dart` | Needs evidence | Data safety covered in docs | Current evidence needed |

## Smart And Optional AI

| Surface | Source | Purpose | Route | Tests | Evidence | Phone/tablet state | Known gaps |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Aquarium Intelligence | `lib/features/smart/intelligence/aquarium_intelligence_screen.dart` | No-AI local risk/care review | Inline from Smart | Covered by Smart/service tests | Needs evidence | P0 no-AI status Done | Current visual evidence needed |
| Symptom Triage | `lib/features/smart/symptom_triage/symptom_triage_screen.dart` | Optional AI symptom workflow | `AppRoutes.toSymptomTriage` | `test/widget_tests/symptom_triage_screen_test.dart` | Needs evidence | Confirm-before-write started | More AI data-write confirmation gaps |
| Weekly Plan | `lib/features/smart/weekly_plan/weekly_plan_screen.dart` | Optional AI care plan workflow | `AppRoutes.toWeeklyPlan` | `test/widget_tests/weekly_plan_screen_test.dart` | Needs evidence | Cache clear locally verified | Current visual evidence needed |
| Fish ID | `lib/features/smart/fish_id/fish_id_screen.dart` | Optional AI fish/plant ID entry | `AppRoutes.toFishId` | Needs focused test confirmation | Needs evidence | Optional AI keyless path required | Current test/evidence needed |

## Workshop, Tools, And Calculators

| Surface | Source | Purpose | Route | Tests | Evidence | Phone/tablet state | Known gaps |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Workshop | `lib/screens/workshop_screen.dart` | Tool hub | `AppRoutes.toWorkshop` | `test/widget_tests/workshop_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Water Change | `lib/screens/water_change_calculator_screen.dart` | Guided water-change calculation/log handoff | Workshop | `test/widget_tests/water_change_calculator_screen_test.dart` | Needs evidence | Tablet rail recorded | Save/apply walkthrough if changed |
| Tank Volume | `lib/screens/tank_volume_calculator_screen.dart` | Volume calculator and apply to tank | Workshop | `test/widget_tests/tank_volume_calculator_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Dosing | `lib/screens/dosing_calculator_screen.dart` | Dose estimate and guided note | Workshop | `test/widget_tests/dosing_calculator_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| CO2 | `lib/screens/co2_calculator_screen.dart` | CO2 estimate/status | Workshop | `test/widget_tests/co2_calculator_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Lighting | `lib/screens/lighting_schedule_screen.dart` | Lighting schedule and guidance | Workshop | `test/widget_tests/lighting_schedule_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Stocking | `lib/screens/stocking_calculator_screen.dart` | Stocking calculator and species handoff | Workshop/species | `test/widget_tests/stocking_calculator_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Compatibility | `lib/screens/compatibility_checker_screen.dart` | Tankmate compatibility checks | Workshop/Smart/species | `test/widget_tests/compatibility_checker_test.dart`, `test/widget_tests/compatibility_checker_widget_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Cycling Assistant | `lib/screens/cycling_assistant_screen.dart` | Cycle phase guidance and actions | Workshop | `test/widget_tests/cycling_assistant_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Unit Converter | `lib/screens/unit_converter_screen.dart` | Aquarium unit conversion | Workshop | `test/widget_tests/unit_converter_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Cost Tracker | `lib/screens/cost_tracker_screen.dart` | Local expense tracking | Workshop/Shop | `test/widget_tests/cost_tracker_test.dart` | Needs evidence | Recent delete rollback fixed | Current evidence needed |

## Species, Plants, Rewards, And Shop

| Surface | Source | Purpose | Route | Tests | Evidence | Phone/tablet state | Known gaps |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Fish Species Browser | `lib/screens/species_browser_screen.dart` | Fish database and detail sheets | More/Learn/Search | `test/widget_tests/species_browser_screen_test.dart` | Needs evidence | Species guide pass implemented | Content/image depth remains |
| Plant Browser | `lib/screens/plant_browser_screen.dart` | Plant database and detail sheets | More/Learn/Search | `test/widget_tests/plant_browser_screen_test.dart` | Needs evidence | Plant guide pass implemented | Content/image depth remains |
| Shop Street | `lib/screens/shop_street_screen.dart` | Local planning, wishlist, budget, saved shops | More | `test/widget_tests/shop_street_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Wishlist | `lib/screens/wishlist_screen.dart` | Saved fish/plant/gear planning | Shop/species/plants | `test/widget_tests/wishlist_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Gem Shop | `lib/screens/gem_shop_screen.dart` | Useful boosts and collectibles | More/rewards | `test/widget_tests/gem_shop_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Inventory | `lib/screens/inventory_screen.dart` | Owned boosts, badges, room vibes, decorations | More/rewards | `test/widget_tests/inventory_screen_test.dart` | Needs evidence | Tablet rail recorded | Seasonal/deeper collections remain |
| Achievements | `lib/screens/achievements_screen.dart` | Achievement progress and reward display | `AppRoutes.toAchievements` | `test/widget_tests/achievements_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |

## Guides, Reference, And Legal

| Surface | Source | Purpose | Route | Tests | Evidence | Phone/tablet state | Known gaps |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Emergency Guide | `lib/screens/emergency_guide_screen.dart` | Urgent care actions | Many direct entries | `test/widget_tests/emergency_guide_screen_test.dart` | Needs evidence | P0 access Done | Current visual evidence needed |
| Acclimation Guide | `lib/screens/acclimation_guide_screen.dart` | Acclimation advice | More/Search | `test/widget_tests/acclimation_guide_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Feeding Guide | `lib/screens/feeding_guide_screen.dart` | Feeding guidance | More/Search | `test/widget_tests/feeding_guide_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Quarantine Guide | `lib/screens/quarantine_guide_screen.dart` | Quarantine process | More/Search | `test/widget_tests/quarantine_guide_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Disease Guide | `lib/screens/disease_guide_screen.dart` | Disease reference | More/Search | `test/widget_tests/disease_guide_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Parameter Guide | `lib/screens/parameter_guide_screen.dart` | Water parameter reference | More/Search | `test/widget_tests/parameter_guide_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Equipment Guide | `lib/screens/equipment_guide_screen.dart` | Equipment reference | More/Search | `test/widget_tests/equipment_guide_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Algae Guide | `lib/screens/algae_guide_screen.dart` | Algae reference | More/Search | `test/widget_tests/algae_guide_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Breeding Guide | `lib/screens/breeding_guide_screen.dart` | Breeding reference | More/Search | `test/widget_tests/breeding_guide_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Vacation Guide | `lib/screens/vacation_guide_screen.dart` | Away-care checklist | More/Search | `test/widget_tests/vacation_guide_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Quick Start Guide | `lib/screens/quick_start_guide_screen.dart` | Beginner setup reference | More/Search | `test/widget_tests/quick_start_guide_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Nitrogen Cycle Guide | `lib/screens/nitrogen_cycle_guide_screen.dart` | Cycling reference | More/Search | `test/widget_tests/nitrogen_cycle_guide_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Substrate Guide | `lib/screens/substrate_guide_screen.dart` | Substrate reference | More/Search | `test/widget_tests/substrate_guide_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Hardscape Guide | `lib/screens/hardscape_guide_screen.dart` | Hardscape reference | More/Search | `test/widget_tests/hardscape_guide_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Troubleshooting | `lib/screens/troubleshooting_screen.dart` | Troubleshooting reference | More/Search | `test/widget_tests/troubleshooting_screen_test.dart` | Needs evidence | Learning enrichment recorded | Current evidence needed |
| Search | `lib/screens/search_screen.dart` | Global search across app/content | `AppRoutes.toSearch`, Tank/More entries | `test/widget_tests/search_screen_test.dart` | `docs/qa/screenshots/2026-06-22/cl-p1-011-global-search/` | Done for current scope | Recheck if destinations change |
| Notification Settings | `lib/screens/notification_settings_screen.dart` | Reminder/notification preferences | Settings | `test/widget_tests/notification_settings_screen_test.dart` | Older phase4 evidence exists | Data safety recorded | Current tablet evidence needed |
| Account / Offline Data | `lib/screens/account_screen.dart` | Local/offline account and data guidance | Settings | `test/widget_tests/account_screen_test.dart` | Needs evidence | Honesty copy fixed | Current evidence needed |
| About | `lib/screens/about_screen.dart` | App information | More/settings | `test/widget_tests/about_screen_test.dart` | Older phase4 evidence exists | Tablet rail recorded | Current evidence needed |
| FAQ | `lib/screens/faq_screen.dart` | Frequently asked questions | More/settings | `test/widget_tests/faq_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Privacy Policy | `lib/screens/privacy_policy_screen.dart` | Local-first privacy policy | More/settings/onboarding/AI setup | `test/widget_tests/privacy_policy_screen_test.dart` | Older phase4 evidence exists | Tablet rail recorded | Current evidence needed |
| Terms of Service | `lib/screens/terms_of_service_screen.dart` | Terms copy | More/settings | `test/widget_tests/terms_of_service_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Glossary | `lib/screens/glossary_screen.dart` | Searchable aquarium terms | More/Search | `test/widget_tests/glossary_screen_test.dart` | Needs evidence | Tablet rail recorded | Current evidence needed |
| Debug Menu | `lib/screens/debug_menu_screen.dart` | Debug-only tools | Debug-only hidden entry | `test/widget_tests/debug_menu_screen_test.dart` | Needs evidence | Debug only | Avoid normal-user exposure |
| Debug QA Seeds | `lib/screens/debug_qa_seed_screen.dart` | Debug-only repeatable QA states | Debug-only route | `test/widget_tests/debug_qa_seed_screen_test.dart` | Needs evidence | Seed states recorded in backlog | Real keyed-AI seed only if honest |

## Open Inventory Work

- Complete CL-QA-001 phone whole-app screenshot/XML audit.
- Complete CL-QA-002 tablet whole-app screenshot/XML audit.
- Replace `Needs evidence` rows only with committed local evidence.
- Add route/deep-link details as navigation is centralized beyond the current
  partial `AppRoutes` helper.
- Keep this file updated when screens are added, removed, renamed, or given new
  current evidence.

