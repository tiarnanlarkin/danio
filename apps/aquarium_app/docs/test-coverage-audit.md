# Danio App — Test Coverage & Quality Audit

**Branch:** `openclaw/stage-system`  
**Audited:** 2026-03-29  
**Auditor:** Daedalus (T-D-292)

---

## 1. Test Inventory

### File counts

| Category | Test Files | Individual Tests |
|----------|-----------|-----------------|
| Unit — data integrity | 3 | 27 |
| Unit — providers/models | 3 | 72 |
| Unit — phase2 / architecture | 1 | 9 |
| Unit — storage error handling | 1 | 13 |
| Widget — `test/widget_tests/` | 88 | 503 |
| Widget — `test/widget/` | 1 | 16 |
| Behaviour — `test/screens/` | 2 | 16 |
| **TOTAL (unit + widget)** | **100** | **656** |
| Integration (Patrol + flutter_test) | 2 | ~10 |

### Integration / E2E

Two integration test files exist:

- `integration_test/smoke_test.dart` — Patrol-based, requires `patrol_cli` and a running emulator
- `integration_test/smoke_test_v2.dart` — Standard `flutter_test` integration runner

Both test: app launch, tab navigation, Learn tab load, basic smoke checks. No CI automation was found wiring these. They exist but are likely run manually.

---

## 2. Coverage Matrix

### Screens (top-level `lib/screens/`)

| Screen | Has Test | Notes |
|--------|----------|-------|
| `about_screen.dart` | ✅ | Smoke |
| `acclimation_guide_screen.dart` | ✅ | Smoke |
| `account_screen.dart` | ✅ | Smoke |
| `achievements_screen.dart` | ✅ | 2 interactions |
| `add_log_screen.dart` | ✅ | 1 interaction |
| `add_log/` (sub-screens) | ❌ | `log_type_selector`, `photo_grid`, `water_param_fields` — no tests |
| `algae_guide_screen.dart` | ✅ | Good — expand/collapse interactions |
| `analytics/analytics_screen.dart` | ✅ | Smoke |
| `analytics/` sub-components | ❌ | `analytics_insight_card`, `analytics_prediction_card`, etc. — no tests |
| `backup_restore_screen.dart` | ✅ | Smoke |
| `breeding_guide_screen.dart` | ✅ | Smoke |
| `charts_screen.dart` | ✅ | Smoke |
| `co2_calculator_screen.dart` | ✅ | 7 interactions (good) |
| `compatibility_checker_screen.dart` | ✅ | 13 interactions (good) |
| `cost_tracker_screen.dart` | ✅ | 9 interactions |
| `create_tank_screen.dart` | ✅ | Validation test present |
| `cycling_assistant_screen.dart` | ✅ | Smoke |
| `debug_menu_screen.dart` | ✅ | Smoke |
| `difficulty_settings_screen.dart` | ✅ | Smoke |
| `disease_guide_screen.dart` | ✅ | 8 interactions |
| `dosing_calculator_screen.dart` | ✅ | 4 interactions |
| `emergency_guide_screen.dart` | ✅ | 4 interactions |
| `equipment_guide_screen.dart` | ✅ | Smoke |
| `equipment_screen.dart` | ✅ | Smoke |
| `faq_screen.dart` | ✅ | Smoke |
| `feeding_guide_screen.dart` | ✅ | Smoke |
| `friends_screen.dart` | ✅ | Smoke |
| `gem_shop_screen.dart` | ✅ | Smoke |
| `glossary_screen.dart` | ✅ | Smoke |
| `hardscape_guide_screen.dart` | ✅ | Smoke |
| `home/home_screen.dart` | ✅ | Smoke |
| `home/home_sheets*.dart` | ❌ | 7 home_sheets files — no tests |
| `home/widgets/` | ❌ | 12 widget files — no tests |
| `inventory_screen.dart` | ✅ | Smoke |
| `journal_screen.dart` | ✅ | Smoke |
| `learn/learn_screen.dart` | ❌ | `learn_screen_test` tests `lesson_provider`, not the widget |
| `learn/` sub-components | ❌ | `learn_practice_card`, `learn_review_banner`, `learn_streak_card`, etc. |
| `learn_screen.dart` (root alias) | ❌ | Not tested as a widget |
| `lesson/lesson_screen.dart` | ✅ | Smoke |
| `lesson/lesson_completion_flow.dart` | ❌ | No tests |
| `lesson/lesson_hearts_modal.dart` | ❌ | No tests |
| `lesson/lesson_quiz_widget.dart` | ❌ | Indirectly tested via quiz_test.dart |
| `livestock/livestock_screen.dart` | ✅ | Smoke |
| `livestock/livestock_add_dialog.dart` | ❌ | No tests |
| `livestock/livestock_bulk_add_dialog.dart` | ❌ | No tests |
| `livestock/livestock_edit_dialog.dart` | ❌ | No tests |
| `livestock/livestock_compatibility_check.dart` | ❌ | No tests |
| `livestock_detail_screen.dart` | ✅ | Smoke |
| `livestock_screen.dart` (root alias) | ✅ | Smoke |
| `livestock_value_screen.dart` | ✅ | Smoke |
| `log_detail_screen.dart` | ✅ | Smoke |
| `logs_screen.dart` | ✅ | Smoke |
| `maintenance_checklist_screen.dart` | ✅ | Smoke |
| `nitrogen_cycle_guide_screen.dart` | ✅ | Smoke |
| `notification_settings_screen.dart` | ✅ | Smoke |
| `onboarding/consent_screen.dart` | ✅ | Tested (both `consent_screen_test` and `onboarding_test`) |
| `onboarding/experience_level_screen.dart` | ✅ | 2 interactions |
| `onboarding/fish_select_screen.dart` | ✅ | 5 interactions |
| `onboarding/welcome_screen.dart` | ✅ | 1 interaction |
| `onboarding/push_permission_screen.dart` | ✅ | 2 interactions |
| `onboarding/warm_entry_screen.dart` | ✅ | 1 interaction |
| `onboarding/aha_moment_screen.dart` | ✅ | Smoke |
| `onboarding/micro_lesson_screen.dart` | ✅ | Smoke |
| `onboarding/feature_summary_screen.dart` | ✅ | 1 interaction |
| `onboarding/tank_status_screen.dart` | ✅ | Smoke |
| `onboarding/xp_celebration_screen.dart` | ✅ | 1 interaction |
| `onboarding/returning_user_flows.dart` | ❌ | No tests |
| `onboarding/unlock_celebration_screen.dart` | ❌ | No tests |
| `onboarding_screen.dart` (orchestrator) | ❌ | No test for the full flow controller |
| `parameter_guide_screen.dart` | ✅ | Smoke |
| `photo_gallery_screen.dart` | ✅ | Smoke |
| `plant_browser_screen.dart` | ✅ | Smoke |
| `practice_hub_screen.dart` | ✅ | Smoke |
| `privacy_policy_screen.dart` | ✅ | Smoke |
| `quarantine_guide_screen.dart` | ✅ | Smoke |
| `quick_start_guide_screen.dart` | ✅ | Smoke |
| `reminders_screen.dart` | ✅ | Smoke |
| `search_screen.dart` | ✅ | Smoke |
| `settings/settings_screen.dart` | ✅ | `test/widget/settings_screen_test.dart` |
| `settings_screen.dart` (root alias) | ✅ | `test/widget/settings_screen_test.dart` |
| `settings_hub_screen.dart` | ✅ | Smoke |
| `shop_street_screen.dart` | ✅ | Smoke |
| `smart_screen.dart` | ✅ | Smoke |
| `spaced_repetition_practice/review_session_screen.dart` | ✅ | Smoke |
| `spaced_repetition_practice/spaced_repetition_practice_screen.dart` | ✅ | Smoke |
| `species_browser_screen.dart` | ✅ | Smoke |
| `stocking_calculator_screen.dart` | ✅ | Smoke |
| `story/story_browser_screen.dart` | ✅ | Smoke |
| `story/story_play_screen.dart` | ❌ | **No tests** |
| `substrate_guide_screen.dart` | ✅ | Smoke |
| `tab_navigator.dart` | ❌ | **No tests** |
| `tank_comparison_screen.dart` | ✅ | Smoke |
| `tank_detail/tank_detail_screen.dart` | ✅ | Smoke |
| `tank_detail/widgets/` | ❌ | 12 sub-widgets — no direct tests |
| `tank_settings_screen.dart` | ✅ | Smoke |
| `tank_volume_calculator_screen.dart` | ✅ | Smoke |
| `tasks_screen.dart` | ✅ | Smoke |
| `terms_of_service_screen.dart` | ✅ | Smoke |
| `theme_gallery_screen.dart` | ✅ | Smoke |
| `troubleshooting_screen.dart` | ✅ | Smoke |
| `unit_converter_screen.dart` | ✅ | 1 interaction |
| `vacation_guide_screen.dart` | ✅ | Smoke |
| `water_change_calculator_screen.dart` | ✅ | Smoke |
| `wishlist_screen.dart` | ✅ | Smoke |
| `workshop_screen.dart` | ✅ | Smoke |

**Summary:** ~85 of ~100 distinct screens/top-level components have at least a smoke test. ~15 notable gaps remain, mostly sub-screen components and flow orchestrators.

---

### Services (`lib/services/`)

| Service | Has Test | Notes |
|---------|----------|-------|
| `achievement_service.dart` | ❌ | No unit or integration test |
| `ai_proxy_service.dart` | ❌ | |
| `ambient_time_service.dart` | ❌ | |
| `analytics_service.dart` | ❌ | |
| `api_rate_limiter.dart` | ❌ | |
| `backup_service.dart` | ❌ | |
| `celebration_service.dart` | ❌ | |
| `cloud_backup_service.dart` | ❌ | |
| `cloud_sync_service.dart` | ❌ | |
| `compatibility_service.dart` | ❌ | |
| `conflict_resolver.dart` | ❌ | |
| `debug_deep_link_service.dart` | ❌ | |
| `difficulty_service.dart` | ❌ | |
| `firebase_analytics_service.dart` | ❌ | |
| `hearts_service.dart` | ❌ | |
| `image_cache_service.dart` | ❌ | |
| `local_json_storage_service.dart` | ✅ | `storage_error_handling_test.dart` (model layer only — no real I/O tests) |
| `notification_scheduler.dart` | ❌ | |
| `notification_service.dart` | ❌ | |
| `offline_aware_service.dart` | ❌ | |
| `onboarding_service.dart` | ❌ | |
| `openai_service.dart` | ❌ | |
| `rate_service.dart` | ❌ | |
| `review_queue_service.dart` | ❌ | |
| `shared_preferences_backup.dart` | ❌ | |
| `shop_service.dart` | ❌ | |
| `stocking_calculator.dart` | ❌ | Used in widget test but no unit test |
| `storage_service.dart` | ✅ | `InMemoryStorageService` used broadly in widget tests (indirectly tested) |
| `supabase_service.dart` | ❌ | |
| `sync_service.dart` | ❌ | |
| `tank_health_service.dart` | ❌ | Pure calculation logic — easy to unit test, never tested |
| `xp_animation_service.dart` | ❌ | |

**0 of 32 services have dedicated unit tests.** Two (`local_json_storage_service`, `storage_service`) have partial indirect coverage.

---

### Providers (`lib/providers/`)

| Provider | Has Direct Test |
|----------|----------------|
| `lesson_provider.dart` | ✅ |
| `spaced_repetition_provider.dart` | ✅ (model only) |
| `user_profile_provider.dart` | ✅ (model only) |
| `achievement_provider.dart` | ❌ |
| `gems_provider.dart` | ❌ |
| `hearts_provider.dart` | ❌ |
| `inventory_provider.dart` | ❌ |
| `onboarding_provider.dart` | ❌ |
| `reduced_motion_provider.dart` | ❌ |
| `room_theme_provider.dart` | ❌ |
| `settings_provider.dart` | ❌ |
| `species_unlock_provider.dart` | ❌ |
| `storage_provider.dart` | ❌ |
| `tank_provider.dart` | ❌ |
| `user_profile_derived_providers.dart` | ❌ |
| `user_profile_notifier.dart` | ❌ |
| `wishlist_provider.dart` | ❌ |

**3 of 17 providers have direct tests.**

---

## 3. Test Quality Assessment

### Quality Score: **5 / 10**

#### What's done well ✅

- **Coverage breadth is impressive.** ~85% of screens have at least a smoke test. This is much better than the average Flutter app.
- **Good use of `InMemoryStorageService`.** Most widget tests correctly avoid real I/O by overriding the storage provider with an in-memory stub.
- **Provider overrides are used correctly.** Fake notifiers (e.g., `_FakeSrNotifier`) isolate complex providers cleanly.
- **Some tests verify real behaviour.** The `quiz_test.dart` (15 interactions), `compatibility_checker_test.dart` (13), and `disease_guide_screen_test.dart` (8) test actual user flows, not just rendering.
- **Unit tests for models are solid.** `spaced_repetition_test.dart` and `user_profile_provider_test.dart` test algorithmic logic thoroughly with edge cases.
- **Data integrity tests are valuable.** `fish_facts_test.dart`, `species_unlock_map_test.dart`, and `lesson_data_test.dart` catch regression in content data.

#### What's lacking ⚠️

- **~70 widget tests are pure smoke tests** ("renders without throwing", "shows app bar title"). They confirm the widget tree doesn't explode, but verify no user-visible behaviour. If a button stops working, these tests still pass.
- **0 service unit tests.** The service layer — which contains the most complex, testable business logic (`TankHealthService`, `StockingCalculator`, `HeartsService`, `AchievementService`) — has zero dedicated unit tests.
- **No interaction tests for critical flows.** There are no tests that: add a tank → add a log → verify it persists, or complete a lesson → verify XP updates, or toggle a setting → verify it saves.
- **No error path tests.** Only `storage_error_handling_test.dart` touches error states. There are no tests for: network failures, corrupt data recovery, empty states when no tanks exist, or app launch with missing data.
- **No navigation flow tests.** No test verifies that tapping a button in screen A correctly navigates to screen B.
- **Integration tests require manual setup.** Neither integration test file has evidence of CI automation. They require a running emulator and manual invocation.
- **Duplicate consent screen tests.** Both `onboarding_test.dart` and `consent_screen_test.dart` test the same screen with near-identical assertions. No unique value added.

---

## 4. Top 15 Missing Tests (Ranked by Risk)

| Rank | Missing Test | Risk | Why it matters |
|------|-------------|------|----------------|
| 1 | **Tank creation → data persists across restart** | 🔴 Critical | Core app value. If a user creates a tank and data doesn't survive app restart, retention drops to zero. Currently zero persistence tests. |
| 2 | **Water log entry → shows in logs screen** | 🔴 Critical | The primary daily action in the app. No test verifies the full Add Log → storage → display loop. |
| 3 | **Onboarding flow orchestrator** (`onboarding_screen.dart`) | 🔴 Critical | This controller directs every new user through consent, experience selection, and tank setup. Breakage means no user can ever complete setup. No flow-level test. |
| 4 | **Consent accepted → `hasConsent` flag persists** | 🔴 Critical | GDPR/Play Store compliance. If the flag fails to persist, Firebase Analytics fires without consent on every launch. Tests exist for ConsentScreen UI but not the persistence outcome. |
| 5 | **`TankHealthService.calculate()` correctness** | 🔴 Critical | The "health score" is prominently displayed. Pure function, trivially testable. A bug here silently shows wrong health scores to every user. |
| 6 | **`StockingCalculator.calculate()` correctness** | 🔴 Critical | Used in the stocking indicator and stocking screen. Pure static function — easy to unit test. Incorrect stocking advice is a real-world fish welfare issue. |
| 7 | **Lesson completion → XP awarded and persisted** | 🟠 High | Core gamification loop. If completing a lesson doesn't grant XP, the engagement model breaks. No test verifies the full lesson complete → XP update chain. |
| 8 | **Hearts deduction on incorrect quiz answer** | 🟠 High | Hearts gate quiz retries. If hearts don't deduct or the provider misbehaves, the paywall model is broken silently. `HeartsService` has zero tests. |
| 9 | **Tab navigator renders all 5 tabs without crash** | 🟠 High | `tab_navigator.dart` has no test at all. A broken import or missing provider in the navigator kills the entire app's navigation. |
| 10 | **Livestock add dialog — validation & save** | 🟠 High | `livestock_add_dialog.dart` has no test. Form validation and save are the critical paths for adding fish, but they're completely untested. |
| 11 | **`StoryPlayScreen` renders and advances** | 🟠 High | `story_play_screen.dart` has no test. If the story play screen crashes, the entire stories feature is broken invisibly. |
| 12 | **`returning_user_flows.dart` — warm re-entry** | 🟠 High | Handles users returning after days/weeks absent. Broken returning-user logic could misfire onboarding or show stale data. No test. |
| 13 | **Settings toggle → persists after hot restart** | 🟠 High | Settings like reduced motion, dark mode, notifications are all untested for persistence. Users changing settings and having them revert is a top 1-star review trigger. |
| 14 | **`LearnScreen` widget renders correct path cards** | 🟡 Medium | `test/screens/learn_screen_test.dart` only tests metadata via provider — it never renders the `LearnScreen` widget. A broken `LearnScreen` wouldn't be caught. |
| 15 | **Backup export → file contains all tank data** | 🟡 Medium | `backup_service.dart` and `cloud_backup_service.dart` have no tests. Backup is in the UI but untested — users relying on backup could silently lose data. |

---

## 5. Recommendations

### Immediate (before next Play Store release)

1. **Add 3 golden-path integration tests** using `smoke_test_v2.dart` pattern (no Patrol dependency):
   - Create tank → verify it appears on home screen
   - Complete onboarding → verify `onboardingComplete` flag is set
   - Add water log → verify it appears in logs screen
   
2. **Unit test the pure service functions** — these are zero-cost wins:
   ```dart
   // TankHealthService
   test('full tank with recent water changes gets >80 score', ...)
   test('tank with no logs gets <40 score', ...)
   
   // StockingCalculator
   test('empty tank returns understocked', ...)
   test('overstocked tank returns overstocked with warnings', ...)
   ```

3. **Test the consent persistence outcome**, not just the UI:
   ```dart
   test('tapping Accept Analytics sets hasConsent=true in SharedPreferences', ...)
   ```

### Medium term (within 1 month)

4. **Convert ~20 highest-risk smoke tests into behaviour tests.** Priority order: `create_tank_screen`, `add_log_screen`, `lesson_screen`, `livestock_add_dialog`, `settings_screen`.

5. **Add provider state tests for `TankProvider` and `UserProfileNotifier`** — the two providers that gate the most app behaviour. Test state transitions, not just initial values.

6. **Wire integration tests to CI.** Add a GitHub Actions (or equivalent) step that runs `flutter test integration_test/smoke_test_v2.dart` on a Firebase Test Lab device or emulator, at minimum on PRs to `main`.

### Long term

7. **Adopt a test pyramid discipline.** Currently: 90% widget, 10% unit, <1% integration. Target: 50% unit, 40% widget (behaviour-heavy), 10% integration.

8. **Add golden screenshot tests** for screens with complex custom rendering (home room scene, XP bar, tank health card). These catch visual regressions that logic tests can't.

9. **Add `_FakeSupabaseService` and `_FakeNotificationService`** fakes so widget tests can verify calls to external services (analytics, notifications) without real I/O.

10. **Remove test duplication.** `onboarding_test.dart` and `consent_screen_test.dart` test the same component — merge or differentiate.

---

## Summary

The Danio test suite has **impressive breadth at the smoke-test level** — nearly every screen has at least a render check. However, it has two major structural gaps:

1. **The service layer (business logic) is entirely untested.** Services like `TankHealthService`, `StockingCalculator`, `HeartsService`, and `AchievementService` are pure functions sitting unguarded.

2. **Widget tests mostly verify rendering, not behaviour.** ~70% of widget tests check that the widget renders without crashing. A regression that breaks a button, form validation, or data flow would pass most of these tests undetected.

For a Play Store app, the highest-risk scenarios (data loss on restart, broken onboarding, incorrect health scores) are currently uncovered. The recommended priority is: persistence tests first, service unit tests second, behaviour-level widget tests third.
