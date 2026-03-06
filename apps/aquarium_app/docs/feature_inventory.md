# Aquarium App — Complete Feature & Architecture Inventory

> Generated 2026-02-23. Codebase: 304 Dart files, 38 test files.

---

## Table of Contents

1. [Screen Inventory](#1-screen-inventory)
2. [Feature Inventory](#2-feature-inventory)
3. [Architecture Map](#3-architecture-map)
4. [Tech Stack](#4-tech-stack)
5. [Data Models](#5-data-models)
6. [Assets Inventory](#6-assets-inventory)

---

## 1. Screen Inventory

### 1.1 Navigation Shells

| Screen | File | Purpose | Entry Point |
|--------|------|---------|-------------|
| **TabNavigator** | `lib/screens/tab_navigator.dart` | 4-tab bottom navigation shell (Learn, Quiz, Tank, Settings) | Main app entry after onboarding |
| **HouseNavigator** | `lib/screens/house_navigator.dart` | 6-room swipe navigation (Study, Living Room, Friends, Leaderboard, Workshop, Shop Street) — older pattern | Alternative navigation shell |

### 1.2 Home & Tank Screens

| Screen | File | Purpose | Providers |
|--------|------|---------|-----------|
| **HomeScreen** | `lib/screens/home/home_screen.dart` | Main dashboard — tank overview, quick actions, daily progress | `tankProvider`, `userProfileProvider`, `settingsProvider` |
| **EmptyRoomScene** | `lib/screens/home/widgets/empty_room_scene.dart` | Illustrated empty state when no tanks exist | — |
| **TankSwitcher** | `lib/screens/home/widgets/tank_switcher.dart` | Swipeable tank carousel for multi-tank users | `tankProvider` |
| **TankPickerSheet** | `lib/screens/home/widgets/tank_picker_sheet.dart` | Bottom sheet for selecting a tank | `tankProvider` |
| **SelectionModePanel** | `lib/screens/home/widgets/selection_mode_panel.dart` | Multi-select panel for bulk actions | — |
| **XPSourceRow** | `lib/screens/home/widgets/xp_source_row.dart` | Displays XP breakdown by source | `userProfileProvider` |
| **TankDetailScreen** | `lib/screens/tank_detail/tank_detail_screen.dart` | Full tank dashboard — stats, livestock preview, logs, alerts, trends | `tankProvider`, `userProfileProvider` |
| **CreateTankScreen** | `lib/screens/create_tank_screen.dart` | Form to create a new tank | `tankProvider` |
| **TankSettingsScreen** | `lib/screens/tank_settings_screen.dart` | Edit tank name, type, targets, delete | `tankProvider` |
| **TankComparisonScreen** | `lib/screens/tank_comparison_screen.dart` | Side-by-side comparison of two tanks | `tankProvider` |
| **TankVolumeCalculatorScreen** | `lib/screens/tank_volume_calculator_screen.dart` | Calculator for tank volume by dimensions | — |

#### Tank Detail Sub-Widgets (`lib/screens/tank_detail/widgets/`)

| Widget | Purpose |
|--------|---------|
| `action_button.dart` | Reusable action button for tank actions |
| `alerts_card.dart` | Parameter alerts card |
| `dashboard_loading_card.dart` | Skeleton loading state for dashboard |
| `equipment_preview.dart` | Equipment summary card |
| `livestock_preview.dart` | Livestock summary card |
| `logs_list.dart` | Recent log entries list |
| `quick_add_fab.dart` | Floating action button for quick-add |
| `quick_stats.dart` | Key stats summary (pH, temp, etc.) |
| `section_header.dart` | Reusable section header |
| `snapshot_card.dart` | Tank parameter snapshot card |
| `stocking_indicator.dart` | Visual stocking level indicator |
| `task_preview.dart` | Upcoming tasks preview |
| `trends_section.dart` | Parameter trend charts |

### 1.3 Learning Screens

| Screen | File | Purpose | Providers |
|--------|------|---------|-----------|
| **LearnScreen** | `lib/screens/learn_screen.dart` | Learning paths overview — Duolingo-style lesson tree | `lessonProvider`, `userProfileProvider` |
| **LessonScreen** | `lib/screens/lesson_screen.dart` | Individual lesson viewer with sections and quiz | `lessonProvider`, `userProfileProvider` |
| **EnhancedQuizScreen** | `lib/screens/enhanced_quiz_screen.dart` | Interactive quiz with multiple exercise types | `userProfileProvider`, `heartsProvider` |
| **PracticeHubScreen** | `lib/screens/practice_hub_screen.dart` | Central hub for practice activities | `spacedRepetitionProvider`, `userProfileProvider` |
| **PracticeScreen** | `lib/screens/practice_screen.dart` | Individual practice session | `spacedRepetitionProvider` |
| **SpacedRepetitionPracticeScreen** | `lib/screens/spaced_repetition_practice_screen.dart` | SRS review session with card flipping | `spacedRepetitionProvider` |
| **PlacementTestScreen** | `lib/screens/placement_test_screen.dart` | Initial knowledge assessment | `userProfileProvider` |
| **PlacementResultScreen** | `lib/screens/placement_result_screen.dart` | Results after placement test completion | `userProfileProvider` |
| **StoriesScreen** | `lib/screens/stories_screen.dart` | Story mode selection — interactive narrative scenarios | `userProfileProvider` |
| **StoryPlayerScreen** | `lib/screens/story_player_screen.dart` | Interactive story playback with branching choices | `userProfileProvider` |

### 1.4 Onboarding Screens

| Screen | File | Purpose |
|--------|------|---------|
| **OnboardingScreen** | `lib/screens/onboarding_screen.dart` | Initial onboarding flow entry |
| **EnhancedOnboardingScreen** | `lib/screens/enhanced_onboarding_screen.dart` | Improved onboarding with animations |
| **ProfileCreationScreen** | `lib/screens/onboarding/profile_creation_screen.dart` | User profile setup (name, experience level, goals) |
| **ExperienceAssessmentScreen** | `lib/screens/onboarding/experience_assessment_screen.dart` | Assess user's fishkeeping experience |
| **EnhancedPlacementTestScreen** | `lib/screens/onboarding/enhanced_placement_test_screen.dart` | Knowledge placement test during onboarding |
| **FirstTankWizardScreen** | `lib/screens/onboarding/first_tank_wizard_screen.dart` | Guided first tank creation wizard |
| **TutorialWalkthroughScreen** | `lib/screens/onboarding/tutorial_walkthrough_screen.dart` | App feature walkthrough |
| **EnhancedTutorialWalkthroughScreen** | `lib/screens/onboarding/enhanced_tutorial_walkthrough_screen.dart` | Improved tutorial with Rive animations |

### 1.5 Tank Management Screens

| Screen | File | Purpose | Providers |
|--------|------|---------|-----------|
| **LivestockScreen** | `lib/screens/livestock_screen.dart` | List of all livestock in a tank | `tankProvider` |
| **LivestockDetailScreen** | `lib/screens/livestock_detail_screen.dart` | Individual fish/invertebrate details | `tankProvider` |
| **LivestockValueScreen** | `lib/screens/livestock_value_screen.dart` | Financial value tracking for livestock | `tankProvider` |
| **EquipmentScreen** | `lib/screens/equipment_screen.dart` | Equipment list and maintenance status | `tankProvider` |
| **CompatibilityCheckerScreen** | `lib/screens/compatibility_checker_screen.dart` | Fish compatibility analysis | `tankProvider` |
| **StockingCalculatorScreen** | `lib/screens/stocking_calculator_screen.dart` | Tank stocking level calculator | `tankProvider` |
| **PlantBrowserScreen** | `lib/screens/plant_browser_screen.dart` | Browse aquatic plant database | — |
| **SpeciesBrowserScreen** | `lib/screens/species_browser_screen.dart` | Browse fish species database | — |

### 1.6 Water Parameters & Logging

| Screen | File | Purpose | Providers |
|--------|------|---------|-----------|
| **LogsScreen** | `lib/screens/logs_screen.dart` | Log history for a tank | `tankProvider` |
| **LogDetailScreen** | `lib/screens/log_detail_screen.dart` | Individual log entry details | `tankProvider` |
| **AddLogScreen** | `lib/screens/add_log_screen.dart` | Form to add a new log entry (water test, observation, etc.) | `tankProvider` |
| **ChartsScreen** | `lib/screens/charts_screen.dart` | Parameter trend charts over time (fl_chart) | `tankProvider` |

### 1.7 Tasks & Reminders

| Screen | File | Purpose | Providers |
|--------|------|---------|-----------|
| **TasksScreen** | `lib/screens/tasks_screen.dart` | Task list with due dates and completion | `tankProvider` |
| **RemindersScreen** | `lib/screens/reminders_screen.dart` | Reminder management and scheduling | `tankProvider`, `settingsProvider` |
| **MaintenanceChecklistScreen** | `lib/screens/maintenance_checklist_screen.dart` | Step-by-step maintenance checklist | `tankProvider` |

### 1.8 Gamification & Social

| Screen | File | Purpose | Providers |
|--------|------|---------|-----------|
| **AchievementsScreen** | `lib/screens/achievements_screen.dart` | Achievement gallery with progress | `achievementProvider`, `userProfileProvider` |
| **LeaderboardScreen** | `lib/screens/leaderboard_screen.dart` | Weekly XP leaderboard with league system | `leaderboardProvider`, `userProfileProvider` |
| **FriendsScreen** | `lib/screens/friends_screen.dart` | Friends list, activity feed, friend requests | `friendsProvider` |
| **FriendComparisonScreen** | `lib/screens/friend_comparison_screen.dart` | Compare stats with a specific friend | `friendsProvider`, `userProfileProvider` |
| **ActivityFeedScreen** | `lib/screens/activity_feed_screen.dart` | Social activity feed | `friendsProvider` |
| **GemShopScreen** | `lib/screens/gem_shop_screen.dart` | In-app gem shop for power-ups and cosmetics | `gemsProvider`, `inventoryProvider` |
| **ShopStreetScreen** | `lib/screens/shop_street_screen.dart` | Shop "street" browsing experience | `gemsProvider`, `inventoryProvider` |
| **AnalyticsScreen** | `lib/screens/analytics_screen.dart` | Detailed learning analytics and insights | `userProfileProvider` |
| **DifficultySettingsScreen** | `lib/screens/difficulty_settings_screen.dart` | Adaptive difficulty preferences | `userProfileProvider` |

### 1.9 Smart (AI) Screens

| Screen | File | Purpose | Providers |
|--------|------|---------|-----------|
| **SmartScreen** | `lib/screens/smart_screen.dart` | AI hub — fish ID, symptom triage, anomaly detection, weekly plan | `openAIServiceProvider`, `aiHistoryProvider`, `anomalyHistoryProvider` |
| **FishIdScreen** | `lib/features/smart/fish_id/fish_id_screen.dart` | Camera-based fish/plant identification using GPT-4o vision | `openAIServiceProvider` |
| **SymptomTriageScreen** | `lib/features/smart/symptom_triage/symptom_triage_screen.dart` | AI symptom checker for sick fish | `openAIServiceProvider` |
| **WeeklyPlanScreen** | `lib/features/smart/weekly_plan/weekly_plan_screen.dart` | AI-generated weekly maintenance plan | `weeklyPlanProvider`, `openAIServiceProvider` |

### 1.10 Reference & Guide Screens

| Screen | File | Purpose |
|--------|------|---------|
| **ParameterGuideScreen** | `lib/screens/parameter_guide_screen.dart` | Water parameter reference guide |
| **NitrogenCycleGuideScreen** | `lib/screens/nitrogen_cycle_guide_screen.dart` | Interactive nitrogen cycle explanation |
| **FeedingGuideScreen** | `lib/screens/feeding_guide_screen.dart` | Feeding schedules and tips |
| **BreedingGuideScreen** | `lib/screens/breeding_guide_screen.dart` | Fish breeding guide |
| **DiseaseGuideScreen** | `lib/screens/disease_guide_screen.dart` | Common fish diseases reference |
| **AlgaeGuideScreen** | `lib/screens/algae_guide_screen.dart` | Algae identification and treatment |
| **EquipmentGuideScreen** | `lib/screens/equipment_guide_screen.dart` | Equipment buying and setup guide |
| **SubstrateGuideScreen** | `lib/screens/substrate_guide_screen.dart` | Substrate selection guide |
| **HardscapeGuideScreen** | `lib/screens/hardscape_guide_screen.dart` | Hardscape arrangement guide |
| **LightingScheduleScreen** | `lib/screens/lighting_schedule_screen.dart` | Lighting schedule setup |
| **AcclimationGuideScreen** | `lib/screens/acclimation_guide_screen.dart` | New fish acclimation instructions |
| **QuarantineGuideScreen** | `lib/screens/quarantine_guide_screen.dart` | Quarantine procedures |
| **VacationGuideScreen** | `lib/screens/vacation_guide_screen.dart` | Vacation tank care tips |
| **EmergencyGuideScreen** | `lib/screens/emergency_guide_screen.dart` | Emergency fish care procedures |
| **TroubleshootingScreen** | `lib/screens/troubleshooting_screen.dart` | Common problem troubleshooting |
| **QuickStartGuideScreen** | `lib/screens/quick_start_guide_screen.dart` | Quick start for new users |
| **GlossaryScreen** | `lib/screens/glossary_screen.dart` | Fishkeeping terminology glossary |
| **FAQScreen** | `lib/screens/faq_screen.dart` | Frequently asked questions |

### 1.11 Tools & Calculators

| Screen | File | Purpose |
|--------|------|---------|
| **WaterChangeCalculatorScreen** | `lib/screens/water_change_calculator_screen.dart` | Calculate water change volumes |
| **DosingCalculatorScreen** | `lib/screens/dosing_calculator_screen.dart` | Fertilizer/medication dosing calculator |
| **CO2CalculatorScreen** | `lib/screens/co2_calculator_screen.dart` | CO2 injection calculator |
| **UnitConverterScreen** | `lib/screens/unit_converter_screen.dart` | Temperature, volume, hardness unit converter |
| **CostTrackerScreen** | `lib/screens/cost_tracker_screen.dart` | Track expenses per tank |

### 1.12 Settings & Account

| Screen | File | Purpose | Providers |
|--------|------|---------|-----------|
| **SettingsHubScreen** | `lib/screens/settings_hub_screen.dart` | Settings categories hub | `settingsProvider` |
| **SettingsScreen** | `lib/screens/settings_screen.dart` | Full settings list | `settingsProvider`, `userProfileProvider` |
| **AccountScreen** | `lib/screens/account_screen.dart` | Account management (Supabase auth) | `authProvider` |
| **NotificationSettingsScreen** | `lib/screens/notification_settings_screen.dart` | Notification preferences | `settingsProvider`, `userProfileProvider` |
| **BackupRestoreScreen** | `lib/screens/backup_restore_screen.dart` | Local/cloud backup and restore | `storageProvider` |
| **ThemeGalleryScreen** | `lib/screens/theme_gallery_screen.dart` | Browse and select room themes | `roomThemeProvider` |
| **PrivacyPolicyScreen** | `lib/screens/privacy_policy_screen.dart` | Privacy policy display | — |
| **TermsOfServiceScreen** | `lib/screens/terms_of_service_screen.dart` | Terms of service display | — |
| **AboutScreen** | `lib/screens/about_screen.dart` | App version and credits | — |

### 1.13 Miscellaneous

| Screen | File | Purpose |
|--------|------|---------|
| **InventoryScreen** | `lib/screens/inventory_screen.dart` | User's purchased items inventory |
| **WishlistScreen** | `lib/screens/wishlist_screen.dart` | Fish/plant/equipment wishlist |
| **JournalScreen** | `lib/screens/journal_screen.dart` | Photo journal / timeline |
| **PhotoGalleryScreen** | `lib/screens/photo_gallery_screen.dart` | Tank photo gallery |
| **SearchScreen** | `lib/screens/search_screen.dart` | Global search across app content |
| **WorkshopScreen** | `lib/screens/workshop_screen.dart` | Workshop room (tools & calculators) |
| **StudyScreen** | `lib/screens/rooms/study_screen.dart` | Study room (learning hub within house metaphor) |

---

## 2. Feature Inventory

### 2.1 Learning System

**Duolingo-style fishkeeping education platform.**

| Sub-Feature | Description | Key Files |
|-------------|-------------|-----------|
| **Learning Paths** | 9 structured paths: Nitrogen Cycle, Water Parameters, First Fish, Maintenance, Planted Tank, Equipment, Fish Health, Species Care, Advanced Topics | `lib/data/lessons/*.dart`, `lib/models/learning.dart` |
| **Lessons** | Multi-section lessons with text, images, tips, and optional quizzes | `lib/screens/lesson_screen.dart`, `lib/models/learning.dart` |
| **Quizzes** | Multiple choice, fill-in-blank, true/false, matching, ordering exercises | `lib/models/exercises.dart`, `lib/screens/enhanced_quiz_screen.dart` |
| **Placement Test** | 20-question assessment spanning all paths to skip known content | `lib/models/placement_test.dart`, `lib/data/placement_test_content.dart` |
| **Spaced Repetition** | Forgetting curve algorithm with review cards, priority scoring, and session scheduling | `lib/models/spaced_repetition.dart`, `lib/providers/spaced_repetition_provider.dart`, `lib/services/review_queue_service.dart` |
| **Lesson Progress** | Per-lesson strength tracking with decay over time (100→70→40→0 over 30 days) | `lib/models/lesson_progress.dart` |
| **Lazy Loading** | Deferred imports for lesson content — eliminates 347KB startup bottleneck | `lib/providers/lesson_provider.dart`, `lib/data/lesson_content_lazy.dart` |
| **Adaptive Difficulty** | AI-powered difficulty adjustment based on performance history | `lib/models/adaptive_difficulty.dart`, `lib/services/difficulty_service.dart` |
| **Story Mode** | Interactive branching narrative scenarios with educational content | `lib/models/story.dart`, `lib/data/stories.dart`, `lib/screens/story_player_screen.dart` |
| **Daily Tips** | Curated fishkeeping tips surfaced daily | `lib/data/daily_tips.dart` |
| **Sample Exercises** | Pre-built exercise sets for practice | `lib/data/sample_exercises.dart` |

### 2.2 Tank Management

| Sub-Feature | Description | Key Files |
|-------------|-------------|-----------|
| **Tank CRUD** | Create, read, update, delete tanks with type (freshwater/marine) and water targets | `lib/models/tank.dart`, `lib/providers/tank_provider.dart` |
| **Water Targets** | Configurable target ranges for temperature, pH, GH, KH per tank — with presets (tropical, coldwater) | `lib/models/tank.dart` (WaterTargets class) |
| **Livestock Tracking** | Track fish/invertebrate species with count, size, temperament, source, photos | `lib/models/livestock.dart` |
| **Equipment Tracking** | Track filters, heaters, lights, etc. with maintenance schedules and lifespan tracking | `lib/models/equipment.dart` |
| **Compatibility Checker** | Analyse fish compatibility by temperament, water parameters, species data | `lib/services/compatibility_service.dart`, `lib/screens/compatibility_checker_screen.dart` |
| **Stocking Calculator** | Calculate stocking level (understocked → overstocked) with warnings and suggestions | `lib/services/stocking_calculator.dart` |
| **Tank Comparison** | Side-by-side comparison of two tanks | `lib/screens/tank_comparison_screen.dart` |
| **Species Database** | Built-in fish species reference data | `lib/data/species_database.dart` |
| **Plant Database** | Built-in aquatic plant reference data | `lib/data/plant_database.dart` |
| **Soft Delete** | Undo-able deletion with 5-second timer before permanent removal | `lib/providers/tank_provider.dart` (SoftDeleteState) |
| **Sample Data** | Pre-populated demo freshwater tank for onboarding | `lib/services/sample_data.dart` |

### 2.3 Water Parameter Tracking

| Sub-Feature | Description | Key Files |
|-------------|-------------|-----------|
| **Log Entries** | Record water tests (temp, pH, ammonia, nitrite, nitrate, GH, KH, phosphate, CO2), water changes, feeding, medication, observations | `lib/models/log_entry.dart` |
| **Trend Charts** | fl_chart-powered parameter graphs over time | `lib/screens/charts_screen.dart` |
| **Alerts** | Visual alerts when parameters are out of target range | `lib/screens/tank_detail/widgets/alerts_card.dart` |
| **Snapshot Cards** | At-a-glance current parameter readings | `lib/screens/tank_detail/widgets/snapshot_card.dart` |
| **Trends Section** | Embedded trend visualisation in tank detail | `lib/screens/tank_detail/widgets/trends_section.dart` |

### 2.4 Task Scheduling

| Sub-Feature | Description | Key Files |
|-------------|-------------|-----------|
| **Task System** | Recurring/one-time tasks with priority levels (low/normal/high) | `lib/models/task.dart` |
| **Recurrence** | Daily, weekly, biweekly, monthly, and custom-interval recurrence | `lib/models/task.dart` (RecurrenceType) |
| **Auto-Generated Tasks** | System creates tasks from equipment maintenance schedules | `lib/models/task.dart` |
| **Local Notifications** | Flutter local notifications for task reminders and streak reminders (morning/evening/night) | `lib/services/notification_service.dart` |
| **Maintenance Checklist** | Step-by-step maintenance workflow | `lib/screens/maintenance_checklist_screen.dart` |

### 2.5 Gamification

| Sub-Feature | Description | Key Files |
|-------------|-------------|-----------|
| **XP System** | Earn XP for lessons, quizzes, practice, logging, tasks — with daily XP goals | `lib/models/user_profile.dart`, `lib/models/daily_goal.dart` |
| **Level Progression** | 7+ levels: Newbie → Beginner → Hobbyist → Aquarist → Expert → Master → Guru | `lib/models/user_profile.dart` |
| **Streaks** | Daily streak tracking with streak freeze (1 free skip/week) | `lib/models/user_profile.dart` |
| **Hearts/Lives** | Duolingo-style hearts system — 5 max, lose hearts on wrong quiz answers, auto-refill every 5 minutes | `lib/services/hearts_service.dart`, `lib/providers/hearts_provider.dart` |
| **Gems Economy** | Earn gems for milestones, spend in shop — full transaction ledger | `lib/models/gem_economy.dart`, `lib/models/gem_transaction.dart`, `lib/providers/gems_provider.dart` |
| **Shop System** | Purchase power-ups (XP boost, streak freeze, hearts refill), cosmetics (badges, themes, effects) | `lib/models/shop_item.dart`, `lib/services/shop_service.dart`, `lib/data/shop_catalog.dart` |
| **Achievements** | Badge system with 4 rarity tiers (Bronze/Silver/Gold/Platinum) across 5 categories | `lib/models/achievements.dart`, `lib/data/achievements.dart`, `lib/services/achievement_service.dart`, `lib/providers/achievement_provider.dart` |
| **Leaderboard** | Weekly competitive leagues (Bronze/Silver/Gold/Diamond) with promotion/relegation | `lib/models/leaderboard.dart`, `lib/screens/leaderboard_screen.dart` |
| **Celebrations** | Confetti, level-up overlays, sound effects, haptic feedback for milestones | `lib/services/celebration_service.dart`, `lib/services/enhanced_celebration_service.dart`, `lib/widgets/celebrations/` |
| **XP Animations** | Floating "+50 XP" animations on XP gain | `lib/services/xp_animation_service.dart`, `lib/widgets/xp_award_animation.dart` |
| **Daily Goals** | Configurable daily XP target with progress tracking and history | `lib/models/daily_goal.dart` |

### 2.6 Journal / Photo Timeline

| Sub-Feature | Description | Key Files |
|-------------|-------------|-----------|
| **Journal** | Photo journal timeline per tank | `lib/screens/journal_screen.dart` |
| **Photo Gallery** | Tank photo gallery with image picker integration | `lib/screens/photo_gallery_screen.dart` |
| **Image Caching** | LRU in-memory image cache with optimised loading | `lib/services/image_cache_service.dart` |

### 2.7 Inventory & Expenses

| Sub-Feature | Description | Key Files |
|-------------|-------------|-----------|
| **Wishlist** | Track desired fish, plants, equipment with estimated prices | `lib/models/wishlist.dart`, `lib/providers/wishlist_provider.dart` |
| **Cost Tracker** | Track expenses per tank | `lib/screens/cost_tracker_screen.dart` |
| **Livestock Value** | Track financial value of livestock collection | `lib/screens/livestock_value_screen.dart` |
| **Shop Inventory** | User's purchased in-app items | `lib/providers/inventory_provider.dart` |
| **Shop Directory** | Local fish shop directory | `lib/data/shop_directory.dart` |

### 2.8 Friends / Social

| Sub-Feature | Description | Key Files |
|-------------|-------------|-----------|
| **Friends List** | Add/remove friends with emoji avatars | `lib/models/friend.dart`, `lib/providers/friends_provider.dart` |
| **Friend Requests** | Send/accept/reject friend requests | `lib/models/social.dart` |
| **Activity Feed** | See friends' recent activity (lessons, achievements, streaks) | `lib/screens/activity_feed_screen.dart` |
| **Friend Comparison** | Compare stats (XP, streaks, achievements) with individual friends | `lib/screens/friend_comparison_screen.dart` |
| **Mock Data** | Pre-populated mock friends for demo/development | `lib/data/mock_friends.dart`, `lib/data/mock_leaderboard.dart` |

### 2.9 Offline Mode

| Sub-Feature | Description | Key Files |
|-------------|-------------|-----------|
| **Offline-First Architecture** | App fully functional without internet — local JSON storage as primary | `lib/services/local_json_storage_service.dart` |
| **Connectivity Monitoring** | Real-time online/offline status via connectivity_plus | `lib/widgets/offline_indicator.dart` |
| **Sync Queue** | Actions queued while offline, synced when reconnected | `lib/services/sync_service.dart`, `lib/services/offline_aware_service.dart` |
| **Conflict Resolution** | Multiple strategies: last-write-wins, local-wins, remote-wins, merge | `lib/services/conflict_resolver.dart` |

### 2.10 Cloud Sync (Supabase)

| Sub-Feature | Description | Key Files |
|-------------|-------------|-----------|
| **Supabase Client** | Singleton wrapper with safe offline-first fallback | `lib/services/supabase_service.dart` |
| **Authentication** | Email+password and Google OAuth via Supabase Auth | `lib/features/auth/auth_service.dart`, `lib/features/auth/auth_provider.dart` |
| **Cloud Sync** | Bi-directional sync with local/remote change tracking | `lib/services/cloud_sync_service.dart` |
| **Cloud Backup** | AES-256 encrypted backup uploaded to Supabase Storage (crypto + encrypt libraries) | `lib/services/cloud_backup_service.dart` |
| **Local Backup** | ZIP archive with JSON data + photos, portable path format | `lib/services/backup_service.dart` |

### 2.11 Smart Layer (OpenAI)

| Sub-Feature | Description | Key Files |
|-------------|-------------|-----------|
| **OpenAI Service** | GPT-4o-mini for chat, GPT-4o for vision — API key via dart-define | `lib/services/openai_service.dart` |
| **Fish/Plant ID** | Camera-based identification using GPT-4o vision API | `lib/features/smart/fish_id/fish_id_screen.dart` |
| **Symptom Triage** | AI-powered sick fish symptom analysis and recommendations | `lib/features/smart/symptom_triage/symptom_triage_screen.dart` |
| **Anomaly Detection** | Detect unusual parameter patterns in log history | `lib/features/smart/anomaly_detector/anomaly_detector_service.dart`, `lib/features/smart/anomaly_detector/anomaly_card.dart` |
| **Weekly Plan** | AI-generated personalised weekly maintenance plan | `lib/features/smart/weekly_plan/weekly_plan_screen.dart` |
| **Smart Models** | IdentificationResult, Anomaly, WeeklyPlan data models | `lib/features/smart/models/smart_models.dart` |
| **Smart Providers** | AI interaction history (last 10), anomaly history (last 50), weekly plan cache | `lib/features/smart/smart_providers.dart` |
| **Usage Tracking** | Monthly API call counter | `lib/services/openai_service.dart` |

### 2.12 Accessibility

| Sub-Feature | Description | Key Files |
|-------------|-------------|-----------|
| **Reduced Motion** | System-level detection + user override; disables animations when enabled | `lib/providers/reduced_motion_provider.dart` |
| **Accessibility Helpers** | Semantic labels, contrast checking utilities | `lib/utils/accessibility_helpers.dart`, `lib/utils/accessibility_extensions.dart`, `lib/utils/accessibility_utils.dart` |
| **Colour Contrast** | WCAG AA colour contrast checker utility | `lib/utils/color_contrast_checker.dart` |
| **WCAG-Compliant Colours** | All semantic colours verified ≥4.5:1 contrast ratio | `lib/theme/app_theme.dart` |
| **Haptic Feedback** | Contextual vibration with respect for reduced motion and user preference | `lib/services/haptic_service.dart`, `lib/utils/haptic_feedback.dart`, `lib/utils/haptic_helper.dart` |
| **Touch Targets** | Material Design 3 minimum 48dp touch targets enforced | `lib/theme/app_theme.dart` (AppTouchTargets) |

> **Note:** Dyslexia font and colour-blind mode are referenced in design docs but not yet implemented in code.

### 2.13 Settings

| Setting | Description | Location |
|---------|-------------|----------|
| **Theme Mode** | System / Light / Dark | `settingsProvider` |
| **Units** | Metric / Imperial | `settingsProvider` |
| **Notifications** | Enable/disable push notifications | `settingsProvider` |
| **Ambient Lighting** | Time-of-day ambient colour overlay (dawn/day/dusk/night) | `settingsProvider`, `lib/services/ambient_time_service.dart` |
| **Haptic Feedback** | Enable/disable vibration | `settingsProvider` |
| **Room Theme** | 12 visual themes (Ocean, Pastel, Sunset, Midnight, Forest, Dreamy, Watercolor, Cotton, Aurora, Golden, Cozy Living, Evening Glow) | `roomThemeProvider`, `lib/theme/room_themes.dart` |
| **Daily XP Goal** | Configurable target (default 50 XP) | `userProfileProvider` |
| **Daily Tips** | Enable/disable daily tips | `userProfileProvider` |
| **Streak Reminders** | Morning/evening/night reminder times | `userProfileProvider` |
| **Reduced Motion** | Override system reduced-motion preference | `reducedMotionProvider` |

---

## 3. Architecture Map

### 3.1 State Management — Providers (`lib/providers/`)

| Provider | File | Type | Manages |
|----------|------|------|---------|
| `storageServiceProvider` | `storage_provider.dart` | `Provider<StorageService>` | Global storage service instance (LocalJsonStorageService) |
| `userProfileProvider` | `user_profile_provider.dart` | `StateNotifierProvider<..., AsyncValue<UserProfile?>>` | Full user profile: XP, streaks, hearts, goals, lesson progress, achievements, inventory |
| `tankProvider` | `tank_provider.dart` | `StateNotifierProvider` | All tanks, livestock, equipment, logs, tasks — with soft-delete support |
| `lessonProvider` | `lesson_provider.dart` | `StateNotifierProvider` | Lazy-loaded lesson content with deferred imports per learning path |
| `settingsProvider` | `settings_provider.dart` | `StateNotifierProvider<..., AppSettings>` | Theme mode, units, notifications, ambient lighting, haptic preferences |
| `heartsProvider` | `hearts_provider.dart` | `StateNotifierProvider<..., HeartsState>` | Hearts/lives system state (current hearts, refill timer) |
| `gemsProvider` | `gems_provider.dart` | `StateNotifierProvider<..., AsyncValue<GemsState>>` | Gem balance and transaction history |
| `inventoryProvider` | `inventory_provider.dart` | `StateNotifierProvider<..., AsyncValue<List<InventoryItem>>>` | Purchased shop items |
| `friendsProvider` | `friends_provider.dart` | `StateNotifierProvider<..., AsyncValue<List<Friend>>>` | Friends list with persistence |
| `friendActivitiesProvider` | `friends_provider.dart` | `StateNotifierProvider` | Friend activity feed (regenerated on friends change) |
| `achievementProvider` | `achievement_provider.dart` | `StateNotifierProvider<..., Map<String, AchievementProgress>>` | Achievement progress and unlock checking |
| `spacedRepetitionProvider` | `spaced_repetition_provider.dart` | `StateNotifierProvider<..., SpacedRepetitionState>` | SRS review cards, sessions, and stats |
| `wishlistProvider` | `wishlist_provider.dart` | `StateNotifierProvider<..., List<WishlistItem>>` | Wishlist items with category filters |
| `roomThemeProvider` | `room_theme_provider.dart` | `StateNotifierProvider<..., RoomThemeType>` | Selected room visual theme |
| `currentRoomThemeProvider` | `room_theme_provider.dart` | `Provider<RoomTheme>` | Resolved theme data from type |
| `reducedMotionProvider` | `reduced_motion_provider.dart` | `StateNotifierProvider<..., ReducedMotionState>` | Reduced motion system + user override |
| `leaderboardResetProvider` | `leaderboard_provider.dart` | `Provider<LeaderboardReset>` | Weekly leaderboard reset logic (UNUSED — functionality in userProfileProvider) |
| `currentTabProvider` | `tab_navigator.dart` | `StateProvider<int>` | Current bottom tab index |
| `currentRoomProvider` | `house_navigator.dart` | `StateProvider<int>` | Current room index (house metaphor) |

#### Smart Layer Providers (`lib/features/smart/smart_providers.dart`)

| Provider | Type | Manages |
|----------|------|---------|
| `aiHistoryProvider` | `StateNotifierProvider<..., List<AIInteraction>>` | Last 10 AI interactions |
| `anomalyHistoryProvider` | `StateNotifierProvider<..., List<Anomaly>>` | Last 50 anomalies with dismiss support |
| `weeklyPlanProvider` | `StateNotifierProvider<..., WeeklyPlan?>` | Cached AI weekly maintenance plan |

#### Auth Provider (`lib/features/auth/auth_provider.dart`)

| Provider | Manages |
|----------|---------|
| `authProvider` | Supabase auth state (sign in, sign up, sign out) |

### 3.2 Services (`lib/services/`)

| Service | File | Responsibility |
|---------|------|----------------|
| **StorageService** | `storage_service.dart` | Abstract storage interface for tanks, livestock, equipment, logs, tasks |
| **LocalJsonStorageService** | `local_json_storage_service.dart` | JSON file-based storage implementation with synchronized writes and corruption recovery |
| **SupabaseService** | `supabase_service.dart` | Singleton Supabase client wrapper with offline-first guarantee |
| **CloudSyncService** | `cloud_sync_service.dart` | Bi-directional cloud sync with status tracking |
| **CloudBackupService** | `cloud_backup_service.dart` | AES-256 encrypted backup to Supabase Storage |
| **BackupService** | `backup_service.dart` | Local ZIP backup with photos (portable path format) |
| **SyncService** | `sync_service.dart` | Offline action queue with sync-on-reconnect |
| **OfflineAwareService** | `offline_aware_service.dart` | Wrapper that queues actions when offline |
| **ConflictResolver** | `conflict_resolver.dart` | Multi-strategy conflict resolution (last-write-wins, local-wins, remote-wins, merge) |
| **OpenAIService** | `openai_service.dart` | OpenAI API client — GPT-4o-mini (chat) and GPT-4o (vision) |
| **NotificationService** | `notification_service.dart` | Flutter local notifications for tasks and streak reminders |
| **HeartsService** | `hearts_service.dart` | Hearts/lives system — deduction, auto-refill, practice rewards |
| **CelebrationService** | `celebration_service.dart` | Confetti, level-up overlays, celebration state management |
| **EnhancedCelebrationService** | `enhanced_celebration_service.dart` | Celebrations + sound effects (audioplayers) + haptic feedback (vibration) |
| **XpAnimationService** | `xp_animation_service.dart` | Floating XP gain animation events |
| **AchievementService** | `achievement_service.dart` | Achievement checking and unlocking logic |
| **ShopService** | `shop_service.dart` | Shop purchase and inventory management |
| **CompatibilityService** | `compatibility_service.dart` | Fish compatibility analysis (compatible/warning/incompatible) |
| **StockingCalculator** | `stocking_calculator.dart` | Tank stocking level calculation with warnings |
| **DifficultyService** | `difficulty_service.dart` | Adaptive difficulty adjustment based on performance |
| **ReviewQueueService** | `review_queue_service.dart` | Spaced repetition priority scoring and session scheduling |
| **AnalyticsService** | `analytics_service.dart` | Progress aggregation, trends, and AI-like insights |
| **OnboardingService** | `onboarding_service.dart` | First-launch state management |
| **HapticService** | `haptic_service.dart` | Contextual haptic feedback with settings awareness |
| **AmbientTimeService** | `ambient_time_service.dart` | Time-of-day ambient lighting (dawn/day/dusk/night) |
| **ImageCacheService** | `image_cache_service.dart` | LRU image cache with compression |
| **SampleData** | `sample_data.dart` | Demo tank generation for onboarding |
| **FirebaseAnalyticsService** | `firebase_analytics_service.dart` | Firebase Analytics wrapper (DISABLED — pending configuration) |

### 3.3 Data Layer (`lib/data/`)

| File | Type | Content |
|------|------|---------|
| `lesson_content.dart` | Static data | Original lesson content loader |
| `lesson_content_lazy.dart` | Static data | Lazy-loading lesson content resolver |
| `lessons/nitrogen_cycle.dart` | Lesson data | Nitrogen cycle path lessons |
| `lessons/water_parameters.dart` | Lesson data | Water parameters path lessons |
| `lessons/first_fish.dart` | Lesson data | First fish path lessons |
| `lessons/maintenance.dart` | Lesson data | Maintenance path lessons |
| `lessons/planted_tank.dart` | Lesson data | Planted tank path lessons |
| `lessons/equipment.dart` | Lesson data | Equipment path lessons |
| `lessons/fish_health.dart` | Lesson data | Fish health path lessons |
| `lessons/species_care.dart` | Lesson data | Species care path lessons |
| `lessons/advanced_topics.dart` | Lesson data | Advanced topics path lessons |
| `placement_test_content.dart` | Static data | 20 placement test questions |
| `achievements.dart` | Static data | Achievement definitions with categories and rarity tiers |
| `daily_tips.dart` | Static data | Daily fishkeeping tips |
| `sample_exercises.dart` | Static data | Pre-built exercise sets |
| `species_database.dart` | Reference data | Fish species database |
| `plant_database.dart` | Reference data | Aquatic plant database |
| `shop_catalog.dart` | Static data | Shop item catalog |
| `shop_directory.dart` | Static data | Local fish shop directory |
| `stories.dart` | Static data | Interactive story definitions |
| `mock_friends.dart` | Mock data | Mock friend profiles for development |
| `mock_leaderboard.dart` | Mock data | Mock leaderboard data |

### 3.4 Navigation

**Primary Navigation: 4-Tab Bottom Navigation (TabNavigator)**

```
[Learn] [Quiz] [Tank] [Settings]
   │       │      │       │
   │       │      │       └─ SettingsHubScreen
   │       │      └─ HomeScreen (tank dashboard)
   │       └─ PracticeHubScreen
   └─ LearnScreen (learning paths)
```

Each tab has its own `GlobalKey<NavigatorState>` for independent navigation stacks. Double-back-to-exit at root.

**Alternative Navigation: 6-Room Horizontal Swipe (HouseNavigator)**

```
[Study] [Living Room] [Friends] [Leaderboard] [Workshop] [Shop Street]
```

PageController-based swipe between "rooms" — a cozy house metaphor.

**App Entry Flow:**
1. `main.dart` → check `OnboardingService.isOnboardingCompleted`
2. If not completed → `OnboardingScreen` → `ProfileCreation` → `PlacementTest` → `FirstTankWizard`
3. If completed → `TabNavigator` (or `HouseNavigator`)

**Screen-level navigation:** Standard `Navigator.push` with custom page transitions (`lib/utils/page_transitions.dart`, `lib/utils/app_page_routes.dart`).

> **Note:** go_router is listed as a dependency but routing is currently done via imperative Navigator.push, not declarative GoRouter.

### 3.5 Theme System

**Design Token Hierarchy:**

```
AppColors          — Full colour palette (primary, secondary, semantic, neutrals, dark mode, pre-computed alpha variants)
  ├── Light mode:  background (#F5F1EB), surface (#FFFFFF), textPrimary (#2D3436)
  ├── Dark mode:   backgroundDark (#1A2634), surfaceDark (#243447), textPrimaryDark (#F5F1EB)
  └── 60+ pre-computed alpha colours (eliminates withOpacity() GC pressure)

AppTypography      — Text styles: headlineLarge/Medium/Small, titleLarge/Medium/Small, bodyLarge/Medium/Small, labelLarge/Medium/Small
  └── Font family: 'SF Pro Display' (falls back to system)

AppSpacing         — Spacing scale: xs(4), sm(8), sm2(12), md(16), lg2(20), lg(24), xl(32), xl2(40), xxl(48), xxxl(64)

AppRadius          — Border radii: xs(4), sm(8), md2(12), md(16), lg(24), xl(32), pill(100)

AppElevation       — Shadow levels: level0(0), level1(2), level2(4), level3(8), level4(12), level5(24)

AppShadows         — Pre-defined BoxShadow lists: soft, medium

AppTouchTargets    — MD3 touch targets: minimum(48), small(48), medium(56), large(64)

AppOverlays        — Pre-computed overlay colours

RoomTheme          — 12 room themes with full colour palettes (wave, blob, water, sand, plant, fish, glass, gauge, button colours)
```

**Theme Application:** Both light and dark `ThemeData` constructed from design tokens, applied via `MaterialApp` in `main.dart`.

---

## 4. Tech Stack

### 4.1 Core

| Component | Technology | Version |
|-----------|-----------|---------|
| **Framework** | Flutter | SDK ≥3.10.8 |
| **Language** | Dart | SDK ≥3.10.8 |
| **State Management** | flutter_riverpod | ^2.6.1 |
| **Code Generation** | riverpod_annotation | ^2.6.1 |
| **Navigation** | go_router (declared but not used for routing) | ^14.8.1 |

### 4.2 Dependencies (Full List)

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^2.6.1 | State management |
| `riverpod_annotation` | ^2.6.1 | Riverpod code generation annotations |
| `go_router` | ^14.8.1 | Declarative routing (declared, not actively used) |
| `http` | ^1.2.2 | HTTP client for OpenAI API calls |
| `uuid` | ^4.5.1 | UUID generation for model IDs |
| `intl` | ^0.20.2 | Internationalisation and date formatting |
| `collection` | ^1.19.1 | Collection utilities (groupBy, etc.) |
| `synchronized` | ^3.3.0+3 | Synchronized async operations (storage writes) |
| `connectivity_plus` | ^6.1.2 | Network connectivity monitoring |
| `fl_chart` | ^0.69.2 | Interactive charts for parameter trends |
| `flutter_animate` | ^4.5.0 | Declarative animation framework |
| `rive` | ^0.13.0 | Rive runtime for interactive animations |
| `confetti` | ^0.7.0 | Confetti particle effects |
| `skeletonizer` | ^2.1.2 | Skeleton loading placeholders |
| `floating_bubbles` | ^2.6.2 | Ambient floating bubble effects |
| `animations` | ^2.0.11 | Material Design animation utilities |
| `lottie` | ^3.0.0 | Lottie animation playback |
| `audioplayers` | ^6.1.0 | Audio playback for celebration sounds |
| `vibration` | ^2.0.0 | Haptic feedback / vibration |
| `path_provider` | ^2.1.5 | Platform-specific file paths |
| `share_plus` | ^10.1.4 | Share content to other apps |
| `image_picker` | ^1.1.2 | Camera/gallery image selection |
| `path` | ^1.9.0 | File path manipulation |
| `shared_preferences` | ^2.3.3 | Key-value persistent storage |
| `url_launcher` | ^6.3.1 | Open URLs in browser |
| `file_picker` | ^8.1.7 | File selection dialog |
| `flutter_local_notifications` | ^18.0.1 | Local push notifications |
| `timezone` | ^0.10.0 | Timezone support for scheduled notifications |
| `archive` | ^3.6.1 | ZIP archive creation/extraction for backups |
| `cached_network_image` | ^3.4.1 | Optimised network image loading with cache |
| `supabase_flutter` | ^2.8.4 | Supabase client (auth, database, storage) |
| `encrypt` | ^5.0.3 | AES-256 encryption for cloud backups |
| `crypto` | ^3.0.6 | SHA hashing for encryption key derivation |
| `pointycastle` | ^3.9.1 | Cryptographic algorithms |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

### 4.3 Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | SDK | Unit and widget testing |
| `integration_test` | SDK | Integration testing |
| `flutter_lints` | ^6.0.0 | Lint rules |

### 4.4 Disabled / Pending

| Package | Status | Notes |
|---------|--------|-------|
| Firebase Core/Analytics/Crashlytics/Performance | Commented out in pubspec.yaml | Pending Firebase project configuration — see `docs/setup/FIREBASE_SETUP_GUIDE.md` |
| Hive | Commented out | Listed as future local storage option |

### 4.5 Architecture Summary

| Layer | Approach |
|-------|----------|
| **State Management** | flutter_riverpod with StateNotifierProvider pattern |
| **Storage (Primary)** | Local JSON files via LocalJsonStorageService (offline-first) |
| **Storage (KV)** | SharedPreferences for settings, achievements, gems, etc. |
| **Backend** | Supabase (auth, database, storage) — additive, app works without it |
| **AI** | OpenAI API (GPT-4o-mini chat, GPT-4o vision) via dart-define API key |
| **Notifications** | flutter_local_notifications with timezone scheduling |
| **Animation** | Rive (.riv files), Lottie (.json), flutter_animate, confetti |
| **Testing** | 38 test files — unit tests for models, services, providers; widget tests; integration flow tests |

---

## 5. Data Models

### `lib/models/`

| Model | File | Key Fields |
|-------|------|------------|
| **Tank** | `tank.dart` | `id`, `name`, `type` (TankType), `volumeLitres`, `waterTargets` (WaterTargets), `createdAt`, `updatedAt` |
| **WaterTargets** | `tank.dart` | `tempMin/Max`, `phMin/Max`, `ghMin/Max`, `khMin/Max` — with factory presets |
| **Livestock** | `livestock.dart` | `id`, `tankId`, `commonName`, `scientificName`, `count`, `sizeCm`, `maxSizeCm`, `dateAdded`, `source`, `temperament`, `imageUrl` |
| **Equipment** | `equipment.dart` | `id`, `tankId`, `type` (EquipmentType: filter/heater/light/etc.), `name`, `brand`, `model`, `maintenanceIntervalDays`, `lastServiced`, `purchaseDate`, `expectedLifespanMonths` |
| **LogEntry** | `log_entry.dart` | `id`, `tankId`, `type` (LogType: waterTest/waterChange/feeding/etc.), `date`, `waterTestResults` (WaterTestResults), `notes` |
| **WaterTestResults** | `log_entry.dart` | `temperature`, `ph`, `ammonia`, `nitrite`, `nitrate`, `gh`, `kh`, `phosphate`, `co2` — all nullable |
| **Task** | `task.dart` | `id`, `tankId`, `title`, `recurrence` (RecurrenceType), `dueDate`, `priority` (TaskPriority), `isAutoGenerated`, `lastCompletedAt`, `relatedEquipmentId` |
| **UserProfile** | `user_profile.dart` | `id`, `name`, `experienceLevel`, `primaryTankType`, `goals`, `totalXp`, `currentStreak`, `longestStreak`, `hearts`, `league`, `weeklyXP`, `dailyXpGoal`, `dailyXpHistory`, `completedLessons`, `lessonProgress`, `completedStories`, `inventory`, `hasCompletedPlacementTest`, `hasStreakFreeze` |
| **LessonProgress** | `lesson_progress.dart` | `lessonId`, `completedDate`, `lastReviewDate`, `reviewCount`, `strength` — with forgetting curve decay |
| **DailyGoal** | `daily_goal.dart` | `date`, `targetXp`, `earnedXp`, `isCompleted`, `isToday` — with progress/remaining calculations |
| **LearningPath** | `learning.dart` | `id`, `title`, `description`, `emoji`, `recommendedFor`, `relevantTankTypes`, `lessons`, `orderIndex` |
| **Lesson** | `learning.dart` | `id`, `pathId`, `title`, `description`, `orderIndex`, `xpReward`, `estimatedMinutes`, `sections`, `quiz`, `prerequisites` |
| **LessonSection** | `learning.dart` | `type` (LessonSectionType), `content`, `imageUrl`, `caption` |
| **Quiz** | `learning.dart` | (embedded in Lesson) |
| **Exercise** (abstract) | `exercises.dart` | `id`, `question`, `explanation`, `type` — subclasses: MultipleChoiceExercise, FillBlankExercise, TrueFalseExercise, MatchingExercise, OrderingExercise |
| **PlacementTest** | `placement_test.dart` | `id`, `title`, `questions`, `timeLimit` |
| **PlacementQuestion** | `placement_test.dart` | `id`, `pathId`, `question`, `options`, `correctIndex`, `explanation`, `difficulty` |
| **Story** | `story.dart` | `id`, `title`, `description`, `difficulty`, `estimatedMinutes`, `xpReward`, `scenes`, `prerequisites`, `minLevel` |
| **StoryScene** | `story.dart` | (nested in Story) |
| **ReviewCard** | `spaced_repetition.dart` | `id`, `conceptId`, `conceptType`, `strength`, `lastReviewed`, `nextReview`, `reviewCount`, `correctCount`, `incorrectCount`, `currentInterval`, `history` |
| **ReviewSession** | `spaced_repetition.dart` | (nested in spaced repetition state) |
| **ReviewStats** | `spaced_repetition.dart` | (aggregated stats) |
| **ReviewAttempt** | `spaced_repetition.dart` | (review history entry) |
| **Achievement** | `achievements.dart` | `id`, `title`, `description`, `rarity` (AchievementRarity: bronze/silver/gold/platinum), `category` (AchievementCategory), `xpReward` |
| **AchievementProgress** | `achievements.dart` | (progress tracking for each achievement) |
| **Friend** | `friend.dart` | `id`, `username`, `displayName`, `avatarEmoji`, `totalXp`, `currentStreak`, `longestStreak`, `levelTitle`, `currentLevel`, `friendsSince`, `isOnline`, `achievements` |
| **FriendRequest** | `social.dart` | `id`, `fromUserId`, `fromUsername`, `toUserId`, `toUsername`, `status`, `message` |
| **FriendActivity** | `friend.dart` | (activity feed entries) |
| **WishlistItem** | `wishlist.dart` | `id`, `category` (WishlistCategory: fish/plant/equipment), `name`, `species`, `estimatedPrice`, `quantity`, `purchased` |
| **ShopItem** | `shop_item.dart` | `id`, `name`, `description`, `emoji`, `category` (powerUps/extras/cosmetics), `type` (ShopItemType), `gemCost`, `isConsumable`, `durationHours` |
| **InventoryItem** | `shop_item.dart` | (purchased shop item with quantity) |
| **PurchaseResult** | `purchase_result.dart` | `success`, `errorMessage`, `item`, `requiredGems`, `availableGems` |
| **GemTransaction** | `gem_transaction.dart` | `id`, `type` (earn/spend/refund/grant), `amount`, `reason`, `itemId`, `timestamp`, `balanceAfter` |
| **GemRewards** | `gem_economy.dart` | Static constants for gem earn amounts (lessons, quizzes, streaks, milestones) |
| **League** | `leaderboard.dart` | Enum: bronze/silver/gold/diamond — with promotion thresholds and min weekly XP |
| **DailyStats** | `analytics.dart` | `date`, `xp`, `lessonsCompleted`, `practiceMinutes`, `timeSpentSeconds`, `topicXp` |
| **WeeklyStats** | `analytics.dart` | `weekStart`, `totalXP`, `lessonsCompleted`, `avgDailyXP`, `daysActive`, `topicXp` |
| **AdaptiveDifficulty** models | `adaptive_difficulty.dart` | `DifficultyLevel` (easy/medium/hard/expert), `PerformanceTrend`, `PerformanceHistory` |

### `lib/features/smart/models/smart_models.dart`

| Model | Key Fields |
|-------|------------|
| **IdentificationResult** | `commonName`, `scientificName`, `careLevel`, `phMin/Max`, `tempMin/Max`, `hardness`, `compatibilityNotes`, `careTips`, `isPlant` |
| **Anomaly** | `id`, `tankId`, `parameter`, `description`, `severity` (warning/alert/critical), `aiExplanation`, `recommendation`, `dismissed` |
| **AIInteraction** | `id`, `type`, `summary`, `timestamp` |
| **WeeklyPlan** | (cached weekly maintenance plan) |

---

## 6. Assets Inventory

### 6.1 Rive Animations (`assets/rive/`)

| File | Description |
|------|-------------|
| `water_effect.riv` | Animated water surface/ripple effect |
| `emotional_fish.riv` | Fish with emotional expressions (happy, sad, etc.) |
| `joystick_fish.riv` | Interactive fish controlled by input |
| `puffer_fish.riv` | Animated puffer fish character |

**Rive widgets:** `lib/widgets/rive/rive_fish.dart`, `lib/widgets/rive/rive_water_effect.dart`

### 6.2 Image Assets (`assets/images/`)

All directories contain only `.gitkeep` placeholder files — **no actual images have been added yet.**

| Directory | Intended Content |
|-----------|-----------------|
| `assets/images/empty_states/` | Illustrations for empty content states |
| `assets/images/onboarding/` | Onboarding flow illustrations |
| `assets/images/illustrations/` | General illustrations |
| `assets/images/error_states/` | Error/status illustrations |
| `assets/images/features/` | Feature-specific graphics |

### 6.3 Icon Assets (`assets/icons/`)

| Directory | Content |
|-----------|---------|
| `assets/icons/badges/` | Achievement badge icons (`.gitkeep` only — no actual badges yet) |

### 6.4 Audio Assets (`assets/audio/celebrations/`)

**No actual audio files exist yet.** Only `AUDIO_README.md` with specifications for 5 planned sounds:

| Planned File | Duration | Use Case |
|-------------|----------|----------|
| `fanfare.mp3` | 2-3s | Lesson completion, perfect score |
| `chime.mp3` | 1-2s | Achievement unlock, XP milestone |
| `applause.mp3` | 2-4s | Streak milestones |
| `fireworks.mp3` | 3-5s | Level up, platinum achievements |
| `whoosh.mp3` | 0.5-1s | Quick XP gains, small victories |

The celebration service degrades gracefully when audio files are missing.

### 6.5 Animation Assets (`assets/animations/`)

`.gitkeep` only — intended for Lottie JSON animation files (confetti, celebrations, etc.)

### 6.6 Fonts

**No custom fonts bundled.** Uses `'SF Pro Display'` as the declared font family, which falls back to system font on all platforms.

---

## Summary Statistics

| Metric | Count |
|--------|-------|
| Total Dart files | 304 |
| Screen files | ~95 |
| Widget files | ~60 |
| Model files | 20 |
| Provider files | 15 |
| Service files | 24 |
| Data files | 22 |
| Utility files | ~19 |
| Feature module files | 9 |
| Test files | 38 |
| Rive animations | 4 |
| Room themes | 12 |
| Learning paths | 9 |
| Achievement categories | 5 |
| Exercise types | 5 |
