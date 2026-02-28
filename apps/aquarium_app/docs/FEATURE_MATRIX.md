# Danio Feature Matrix
Version: 1.0 | Date: 2026-02-28

Status: ✅ Working | ⚠️ Partial | 🔴 Broken | 🚧 Coming Soon | ❌ Missing

## Core Features

| Feature | Entry Screen | Key Files | Status | Known Issues |
|---------|-------------|-----------|--------|--------------|
| **Tank Management** | HomeScreen | `lib/screens/home/`, `providers/tank_provider.dart`, `models/tank.dart` | ✅ Working | — |
| **Tank Creation** | CreateTankScreen | `lib/screens/create_tank_screen.dart` | ✅ Working | — |
| **Tank Detail** | TankDetailScreen | `lib/screens/tank_detail/` | ✅ Working | — |
| **Tank Settings** | TankSettingsScreen | `lib/screens/tank_settings_screen.dart` | ✅ Working | — |
| **Tank Comparison** | TankComparisonScreen | `lib/screens/tank_comparison_screen.dart` | ✅ Working | — |
| **Water Logging** | AddLogScreen | `lib/screens/add_log_screen.dart`, `models/log_entry.dart` | ✅ Working | — |
| **Log History** | LogsScreen | `lib/screens/logs_screen.dart`, `log_detail_screen.dart` | ✅ Working | — |
| **Charts/Graphs** | ChartsScreen | `lib/screens/charts_screen.dart` | ✅ Working | — |
| **Livestock Tracking** | LivestockScreen | `lib/screens/livestock_screen.dart`, `livestock_detail_screen.dart` | ✅ Working | — |
| **Equipment Tracking** | EquipmentScreen | `lib/screens/equipment_screen.dart`, `models/equipment.dart` | ✅ Working | — |
| **Task/Maintenance** | TasksScreen | `lib/screens/tasks_screen.dart`, `models/task.dart` | ✅ Working | — |
| **Reminders** | RemindersScreen | `lib/screens/reminders_screen.dart`, `services/notification_service.dart` | ✅ Working | — |
| **Photo Gallery** | PhotoGalleryScreen | `lib/screens/photo_gallery_screen.dart` | ✅ Working | — |

## Learning System

| Feature | Entry Screen | Key Files | Status | Known Issues |
|---------|-------------|-----------|--------|--------------|
| **Learning Hub** | LearnScreen | `lib/screens/learn_screen.dart`, `data/lesson_content.dart` | ✅ Working | — |
| **Lessons (50+)** | LessonScreen | `lib/screens/lesson_screen.dart`, `providers/lesson_provider.dart` | ✅ Working | — |
| **Quizzes** | EnhancedQuizScreen | `lib/screens/enhanced_quiz_screen.dart`, `models/exercises.dart` | ✅ Working | — |
| **Placement Test** | PlacementTestScreen | `lib/screens/placement_test_screen.dart`, `data/placement_test_content.dart` | ✅ Working | — |
| **Spaced Repetition** | SpacedRepetitionPracticeScreen | `lib/screens/spaced_repetition_practice_screen.dart`, `providers/spaced_repetition_provider.dart` | ✅ Working | — |
| **Practice Hub** | PracticeHubScreen | `lib/screens/practice_hub_screen.dart`, `practice_screen.dart` | ✅ Working | — |
| **Stories** | StoriesScreen | `lib/screens/stories_screen.dart`, `story_player_screen.dart` | ✅ Working | — |
| **Difficulty Settings** | DifficultySettingsScreen | `lib/screens/difficulty_settings_screen.dart`, `services/difficulty_service.dart` | ✅ Working | — |

## Guides (14 total)

| Feature | Entry Screen | Status |
|---------|-------------|--------|
| Nitrogen Cycle Guide | `nitrogen_cycle_guide_screen.dart` | ✅ Working |
| Disease Guide | `disease_guide_screen.dart` | ✅ Working |
| Feeding Guide | `feeding_guide_screen.dart` | ✅ Working |
| Breeding Guide | `breeding_guide_screen.dart` | ✅ Working |
| Algae Guide | `algae_guide_screen.dart` | ✅ Working |
| Equipment Guide | `equipment_guide_screen.dart` | ✅ Working |
| Substrate Guide | `substrate_guide_screen.dart` | ✅ Working |
| Hardscape Guide | `hardscape_guide_screen.dart` | ✅ Working |
| Lighting Schedule | `lighting_schedule_screen.dart` | ✅ Working |
| CO₂ Calculator | `co2_calculator_screen.dart` | ✅ Working |
| Acclimation Guide | `acclimation_guide_screen.dart` | ✅ Working |
| Quarantine Guide | `quarantine_guide_screen.dart` | ✅ Working |
| Quick Start Guide | `quick_start_guide_screen.dart` | ✅ Working |
| Parameter Guide | `parameter_guide_screen.dart` | ✅ Working |
| Vacation Guide | `vacation_guide_screen.dart` | ✅ Working |

## Gamification

| Feature | Entry Screen | Key Files | Status | Known Issues |
|---------|-------------|-----------|--------|--------------|
| **XP System** | (global) | `providers/user_profile_provider.dart`, `widgets/xp_progress_bar.dart` | ✅ Working | — |
| **XP Animations** | (overlay) | `services/xp_animation_service.dart`, `widgets/xp_award_animation.dart` | ✅ Working | — |
| **Gems Currency** | GemShopScreen | `lib/screens/gem_shop_screen.dart`, `providers/gems_provider.dart` | ✅ Working | — |
| **Hearts System** | (global) | `services/hearts_service.dart`, `providers/hearts_provider.dart`, `widgets/hearts_widgets.dart` | ⚠️ Partial | Refill edge cases in tests |
| **Streaks** | (home) | `widgets/streak_calendar.dart`, `providers/user_profile_provider.dart` | ✅ Working | — |
| **Levels/XP Ladder** | (global) | `widgets/level_up_dialog.dart`, `models/user_profile.dart` | ✅ Working | — |
| **Achievements (55)** | AchievementsScreen | `lib/screens/achievements_screen.dart`, `services/achievement_service.dart`, `data/achievements.dart` | ✅ Working | — |
| **Shop** | ShopStreetScreen | `lib/screens/shop_street_screen.dart`, `services/shop_service.dart`, `data/shop_catalog.dart` | ✅ Working | — |
| **Celebrations** | (overlay) | `services/celebration_service.dart`, `services/enhanced_celebration_service.dart`, `widgets/celebrations/` | ✅ Working | — |
| **Daily Goals** | (home) | `widgets/daily_goal_progress.dart`, `models/daily_goal.dart` | ✅ Working | — |

## Tools & Calculators

| Feature | Entry Screen | Status |
|---------|-------------|--------|
| Tank Volume Calculator | `tank_volume_calculator_screen.dart` | ✅ Working |
| Water Change Calculator | `water_change_calculator_screen.dart` | ✅ Working |
| Stocking Calculator | `stocking_calculator_screen.dart` | ✅ Working |
| CO₂ Calculator | `co2_calculator_screen.dart` | ✅ Working |
| Dosing Calculator | `dosing_calculator_screen.dart` | ✅ Working |
| Unit Converter | `unit_converter_screen.dart` | ✅ Working |
| Compatibility Checker | `compatibility_checker_screen.dart` | ✅ Working |
| Cost Tracker | `cost_tracker_screen.dart` | ✅ Working |

## Social Features

| Feature | Entry Screen | Key Files | Status | Known Issues |
|---------|-------------|-----------|--------|--------------|
| **Friends List** | FriendsScreen | `lib/screens/friends_screen.dart`, `providers/friends_provider.dart`, `data/mock_friends.dart` | ⚠️ Partial | Uses mock data only |
| **Friend Comparison** | FriendComparisonScreen | `lib/screens/friend_comparison_screen.dart` | ⚠️ Partial | Mock data |
| **Leaderboard** | LeaderboardScreen | `lib/screens/leaderboard_screen.dart`, `data/mock_leaderboard.dart` | ⚠️ Partial | Mock data |
| **Activity Feed** | ActivityFeedScreen | `lib/screens/activity_feed_screen.dart` | ⚠️ Partial | Mock data |

## Smart Features (AI-Powered)

| Feature | Entry Screen | Key Files | Status | Known Issues |
|---------|-------------|-----------|--------|--------------|
| **Fish ID** | FishIdScreen | `lib/features/smart/fish_id/fish_id_screen.dart` | 🚧 Coming Soon | Requires OpenAI API |
| **Symptom Triage** | SymptomTriageScreen | `lib/features/smart/symptom_triage/symptom_triage_screen.dart` | 🚧 Coming Soon | Requires OpenAI API |
| **Weekly Plan** | WeeklyPlanScreen | `lib/features/smart/weekly_plan/weekly_plan_screen.dart` | 🚧 Coming Soon | Requires OpenAI API |
| **Anomaly Detector** | AnomalyCard | `lib/features/smart/anomaly_detector/` | 🚧 Coming Soon | Requires backend |

## Data & Backend

| Feature | Key Files | Status | Known Issues |
|---------|-----------|--------|--------------|
| **Local Storage** | `services/storage_service.dart`, `services/local_json_storage_service.dart` | ✅ Working | — |
| **Backup/Restore** | `services/backup_service.dart`, `screens/backup_restore_screen.dart` | ✅ Working | — |
| **Cloud Sync (Supabase)** | `services/supabase_service.dart`, `services/cloud_sync_service.dart`, `services/sync_service.dart` | ⚠️ Partial | Graceful offline fallback; Supabase credentials may be placeholder |
| **Firebase Analytics** | `services/firebase_analytics_service.dart` | 🚧 Coming Soon | Firebase not configured yet |
| **Offline Mode** | `services/offline_aware_service.dart`, `widgets/offline_indicator.dart` | ✅ Working | — |

## Settings & Meta

| Feature | Entry Screen | Status |
|---------|-------------|--------|
| Settings Hub | `settings_hub_screen.dart` | ✅ Working |
| Account Settings | `account_screen.dart` | ✅ Working |
| Notification Settings | `notification_settings_screen.dart` | ✅ Working |
| Theme Gallery | `theme_gallery_screen.dart` | ✅ Working |
| About | `about_screen.dart` | ✅ Working |
| Privacy Policy | `privacy_policy_screen.dart` | ✅ Working |
| Terms of Service | `terms_of_service_screen.dart` | ✅ Working |
| FAQ | `faq_screen.dart` | ✅ Working |
| Glossary | `glossary_screen.dart` | ✅ Working |
| Troubleshooting | `troubleshooting_screen.dart` | ✅ Working |

## Onboarding

| Feature | Entry Screen | Status |
|---------|-------------|--------|
| Enhanced Onboarding | `enhanced_onboarding_screen.dart` | ✅ Working |
| Profile Creation | `onboarding/profile_creation_screen.dart` | ⚠️ Partial | Layout overflow on tank type cards (P0) |
| Experience Assessment | `onboarding/experience_assessment_screen.dart` | ✅ Working |
| Enhanced Placement Test | `onboarding/enhanced_placement_test_screen.dart` | ✅ Working |
| Tutorial Walkthrough | `onboarding/tutorial_walkthrough_screen.dart` | ✅ Working |
| First Tank Wizard | `onboarding/first_tank_wizard_screen.dart` | ✅ Working |

## Room System (Cozy Home Metaphor)

| Feature | Key Files | Status |
|---------|-----------|--------|
| Study Room | `screens/rooms/study_screen.dart` | ✅ Working |
| Room Themes | `theme/room_themes.dart`, `theme/room_identity.dart` | ✅ Working |
| Room Navigation | `widgets/room_navigation.dart`, `widgets/room_scene.dart` | ✅ Working |
| Hobby Desk | `widgets/hobby_desk.dart`, `widgets/hobby_items.dart` | ✅ Working |

## Databases

| Database | Location | Count |
|----------|----------|-------|
| Species | `data/species_database.dart` | 122 species |
| Plants | `data/plant_database.dart` | 52 plants |
| Lessons | `data/lesson_content.dart` + `data/lessons/` | 50+ lessons |
| Achievements | `data/achievements.dart` | 55 achievements |
| Shop Items | `data/shop_catalog.dart` + `data/shop_directory.dart` | Multiple categories |
| Stories | `data/stories.dart` | Multiple interactive stories |
