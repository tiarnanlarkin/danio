# Danio — Test Matrix

**Date:** 2026-04-05
**Method:** Automated tests (826 unit/widget) + emulator verification + static analysis

---

## Automated Test Coverage

### Core Flows (Widget + Provider Tests)

| Flow | Test File | Result |
|------|-----------|--------|
| App renders | tab_navigator_test | Pass |
| Bottom navigation (5 tabs) | tab_navigator_test | Pass |
| Tab labels (Learn/Practice/Tank/More/Settings) | tab_navigator_test | Pass |
| Learn screen renders | learn_screen_test | Pass |
| Lesson screen renders | lesson_screen_test | Pass |
| Practice hub renders | practice_hub_screen_test, practice_screen_test | Pass |
| Home screen renders | home_screen_test | Pass |
| Smart screen renders | smart_screen_test | Pass |
| Settings screen renders | settings_hub_screen_test, settings_screen_test | Pass |

### Onboarding Screens

| Screen | Test File | Result |
|--------|-----------|--------|
| Welcome | welcome_screen_test | Pass |
| Consent | consent_screen_test | Pass |
| Age blocked | age_blocked_screen_test | Pass |
| Experience level | experience_level_screen_test | Pass |
| Fish select | fish_select_screen_test | Pass |
| Micro lesson | micro_lesson_screen_test | Pass |
| Push permission | push_permission_screen_test | Pass |
| Feature summary | feature_summary_screen_test | Pass |
| Aha moment | aha_moment_screen_test | Pass |
| XP celebration | xp_celebration_screen_test | Pass |
| Warm entry | warm_entry_screen_test | Pass |
| Tank status | tank_status_screen_test | Pass |

### Tank Management

| Screen | Test File | Result |
|--------|-----------|--------|
| Tank detail | tank_detail_screen_test | Pass |
| Create tank | create_tank_screen_test | Pass |
| Tank settings | tank_settings_screen_test | Pass |
| Tank comparison | tank_comparison_screen_test | Pass |
| Tank volume calculator | tank_volume_calculator_screen_test | Pass |
| Livestock screen | livestock_screen_test | Pass |
| Livestock detail | livestock_detail_screen_test | Pass |
| Livestock value | livestock_value_screen_test | Pass |
| Add log | add_log_screen_test | Pass |
| Log detail | log_detail_screen_test | Pass |
| Logs screen | logs_screen_test | Pass |
| Equipment | equipment_screen_test | Pass |
| Tasks | tasks_screen_test | Pass |
| Charts | charts_screen_test | Pass |
| Journal | journal_screen_test | Pass |

### Tools & Calculators

| Screen | Test File | Result |
|--------|-----------|--------|
| Stocking calculator | stocking_calculator_screen_test | Pass |
| Water change calculator | water_change_calculator_screen_test | Pass |
| Dosing calculator | dosing_calculator_screen_test | Pass |
| CO2 calculator | co2_calculator_test | Pass |
| Unit converter | unit_converter_screen_test | Pass |
| Compatibility checker | compatibility_checker_test | Pass |
| Cost tracker | cost_tracker_test | Pass |

### Guides

| Screen | Test File | Result |
|--------|-----------|--------|
| Feeding guide | feeding_guide_screen_test | Pass |
| Breeding guide | breeding_guide_screen_test | Pass |
| Quarantine guide | quarantine_guide_screen_test | Pass |
| Acclimation guide | acclimation_guide_screen_test | Pass |
| Disease guide | disease_guide_screen_test | Pass |
| Algae guide | algae_guide_screen_test | Pass |
| Emergency guide | emergency_guide_screen_test | Pass |
| Equipment guide | equipment_guide_screen_test | Pass |
| Substrate guide | substrate_guide_screen_test | Pass |
| Hardscape guide | hardscape_guide_screen_test | Pass |
| Nitrogen cycle | nitrogen_cycle_guide_screen_test | Pass |
| Parameter guide | parameter_guide_screen_test | Pass |
| Quick start | quick_start_guide_screen_test | Pass |
| Troubleshooting | troubleshooting_screen_test | Pass |
| Vacation guide | vacation_guide_screen_test | Pass |
| Cycling assistant | cycling_assistant_screen_test | Pass |
| Lighting schedule | lighting_schedule_screen_test | Pass |
| Maintenance checklist | maintenance_checklist_screen_test | Pass |

### Economy & Social

| Screen | Test File | Result |
|--------|-----------|--------|
| Gem shop | gem_shop_screen_test | Pass |
| Shop street | shop_street_screen_test | Pass |
| Inventory | inventory_screen_test | Pass |
| Wishlist | wishlist_screen_test | Pass |
| Achievements | achievements_screen_test | Pass |
| Workshop | workshop_screen_test | Pass |

### Other Screens

| Screen | Test File | Result |
|--------|-----------|--------|
| About | about_screen_test | Pass |
| Account | account_screen_test | Pass |
| Analytics | analytics_screen_test | Pass |
| Backup/restore | backup_restore_screen_test | Pass |
| Debug menu | debug_menu_screen_test | Pass |
| Difficulty settings | difficulty_settings_screen_test | Pass |
| FAQ | faq_screen_test | Pass |
| Glossary | glossary_screen_test | Pass |
| Notification settings | notification_settings_screen_test | Pass |
| Photo gallery | photo_gallery_screen_test | Pass |
| Plant browser | plant_browser_screen_test | Pass |
| Privacy policy | privacy_policy_screen_test | Pass |
| Reminders | reminders_screen_test | Pass |
| Search | search_screen_test | Pass |
| Species browser | species_browser_screen_test | Pass |
| Story browser | story_browser_screen_test | Pass |
| Terms of service | terms_of_service_screen_test | Pass |
| Spaced repetition | spaced_repetition_practice_screen_test | Pass |
| Review session | review_session_screen_test | Pass |
| XP progress bar | xp_progress_bar_test | Pass |
| Heart indicator | heart_indicator_test | Pass |
| Error boundary | error_boundary_test | Pass |

### Provider Tests

| Provider | Test File | Result |
|----------|-----------|--------|
| Tank provider | tank_provider_test | Pass |
| User profile notifier | user_profile_notifier_test | Pass |
| User profile provider | user_profile_provider_test | Pass |
| User profile XP/level | user_profile_xp_level_test | Pass |
| Lesson provider | lesson_provider_test | Pass |
| Spaced repetition provider | spaced_repetition_provider_test, spaced_repetition_test | Pass |

### Service Tests

| Service | Test File | Result |
|---------|-----------|--------|
| Stocking calculator | stocking_calculator_test | Pass |
| Shop service | shop_service_test | Pass |
| Tank health service | tank_health_service_test | Pass |

### Data & Model Tests

| Area | Test File | Result |
|------|-----------|--------|
| Lesson data integrity | lesson_data_test | Pass |
| Fish facts | fish_facts_test | Pass |
| Species unlock map | species_unlock_map_test | Pass |
| Model serialization | serialization_test | Pass |
| Schema migration | schema_migration_test | Pass |
| Storage error handling | storage_error_handling_test | Pass |
| Data deletion | data_deletion_test | Pass |
| Golden path persistence | golden_path_persistence_test | Pass |

### Emulator Verification

| Check | Result |
|-------|--------|
| Release APK installs | Pass |
| Cold start → consent screen | Pass |
| No Flutter errors in logcat | Pass |
| No crashes | Pass |
| Rendering backend (Impeller) | Active |
