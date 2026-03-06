# 🐠 Aquarium App — Master Developer Document

> **Generated:** 2026-02-23 by Mount Olympus (Argus + Hephaestus + Apollo + Athena)  
> **Repo:** `aquarium_app_mirror` | **Flutter SDK:** ≥3.10.8 | **Dart SDK:** ≥3.10.8  
> **Status:** Feature-complete. Pre-launch polish pass complete. Known issues documented below.

---

## Table of Contents

1. [Vision & Concept](#1-vision--concept)
2. [Feature Summary](#2-feature-summary)
3. [Tech Stack](#3-tech-stack)
4. [Architecture](#4-architecture)
5. [Screen Inventory](#5-screen-inventory)
6. [Data Models](#6-data-models)
7. [Assets](#7-assets)
8. [Build & Setup](#8-build--setup)
9. [Known Issues & TODOs](#9-known-issues--todos)
10. [Roadmap to Ship](#10-roadmap-to-ship)

---

## 1. Vision & Concept

**"The Duolingo of Aquariums."**

A Duolingo-style mobile app for fishkeeping. Teaches complete beginners how to keep fish properly through gamified, bite-sized lessons — while doubling as a full aquarium management tool. Users track their tanks, log water parameters, schedule maintenance, manage livestock, and now get AI-powered guidance via the Smart layer.

**Target user:** Beginner to intermediate freshwater/marine aquarists who want to learn properly and stay on top of their tank care.

**Core loop:** Daily habit → Learn a lesson → Complete a task → Log your parameters → Stay consistent via streaks and XP.

---

## 2. Feature Summary

### 2.1 Learning System (Duolingo-style)

| Feature | Detail |
|---------|--------|
| **9 Learning Paths** | Nitrogen Cycle, Water Parameters, First Fish, Maintenance, Planted Tank, Equipment, Fish Health, Species Care, Advanced Topics |
| **Lessons** | Multi-section (text, images, tips) + inline quizzes |
| **5 Quiz Types** | Multiple choice, fill-in-blank, true/false, matching, ordering |
| **Placement Test** | 20-question knowledge assessment to skip known content |
| **Spaced Repetition** | Forgetting-curve algorithm schedules review cards per concept |
| **Lesson Decay** | Lesson strength degrades over 30 days (100→70→40→0) to drive re-review |
| **Adaptive Difficulty** | Adjusts question difficulty based on performance history |
| **Story Mode** | Interactive branching narrative scenarios with educational content |
| **Lazy Loading** | 347KB lesson data only loaded on demand — zero startup cost |

### 2.2 Tank Management

| Feature | Detail |
|---------|--------|
| **Multi-tank** | Create and manage unlimited tanks |
| **Water Targets** | Configurable target ranges per tank (temp, pH, GH, KH) with presets |
| **Livestock** | Track fish/invertebrates by species, count, size, temperament, source |
| **Equipment** | Track filters, heaters, lights etc. with maintenance intervals |
| **Compatibility Checker** | Fish compatibility analysis by temperament + water params |
| **Stocking Calculator** | Tank stocking level with warnings (understocked → overstocked) |
| **Tank Comparison** | Side-by-side comparison of two tanks |
| **Species & Plant Database** | Built-in reference for fish species and aquatic plants |
| **Soft Delete** | Undo-able deletion with 5-second recovery window |

### 2.3 Water Parameter Tracking

| Feature | Detail |
|---------|--------|
| **Log Entries** | Record water tests (temp, pH, ammonia, nitrite, nitrate, GH, KH, phosphate, CO2), water changes, feeding, medication, observations |
| **Trend Charts** | fl_chart graphs per parameter over time |
| **Parameter Alerts** | Visual alerts when readings are outside target range |
| **Snapshot Cards** | At-a-glance dashboard for current readings |

### 2.4 Task Scheduling & Reminders

| Feature | Detail |
|---------|--------|
| **Recurring Tasks** | Daily, weekly, biweekly, monthly, custom intervals |
| **Auto-Generated Tasks** | System creates tasks from equipment maintenance schedules |
| **Push Notifications** | flutter_local_notifications for task due dates + streak reminders (morning/evening/night configurable) |
| **Exact Alarm Fallback** | Handles Android 12/13 exact alarm permission gracefully with inexact fallback |
| **Maintenance Checklist** | Step-by-step guided maintenance workflow |

### 2.5 Gamification

| Feature | Detail |
|---------|--------|
| **XP System** | Earn XP for lessons, quizzes, practice, logging, tasks — with daily goals |
| **7 Levels** | Newbie → Beginner → Hobbyist → Aquarist → Expert → Master → Guru |
| **Streaks** | Daily streak with streak freeze (1 free skip/week) |
| **Hearts / Lives** | 5 hearts max; lost on wrong quiz answers; auto-refill every 5 minutes |
| **Gems Economy** | Earn gems for milestones; full transaction ledger; spendable in shop |
| **Shop** | Power-ups (XP boost, streak freeze, hearts refill), cosmetics (badges, themes, effects) |
| **Achievements** | 4 rarity tiers (Bronze/Silver/Gold/Platinum), 5 categories, 30+ achievements |
| **Leaderboard** | Weekly leagues (Bronze/Silver/Gold/Diamond) with promotion/relegation |
| **Celebrations** | Confetti, level-up overlays, floating XP animations, sound effects, haptics |
| **Daily Goals** | Configurable daily XP target with history tracking |

### 2.6 Journal & Photo Timeline

- Photo journal timeline per tank
- Photo gallery with image picker
- LRU image cache with compression

### 2.7 Inventory, Wishlist & Expenses

- Wishlist (fish, plants, equipment with estimated prices)
- Expense tracking per tank
- Livestock financial value tracking
- In-app item inventory (purchased shop items)
- Local fish shop directory

### 2.8 Social / Friends

> ⚠️ **Currently uses mock data.** Real backend not wired up.

- Friends list with emoji avatars
- Friend requests (send/accept/reject)
- Activity feed (friends' lessons, achievements, streaks)
- Friend stats comparison
- Mock friends and mock leaderboard pre-populated for demo

### 2.9 Offline-First Architecture

- App is **100% functional without internet**
- Primary storage: local JSON files (`LocalJsonStorageService`)
- Key-value store: SharedPreferences for settings, gems, achievements
- Sync queue: offline actions queued, flushed on reconnect
- Conflict resolution: multiple strategies (last-write-wins, local-wins, merge)
- Visual indicator: `OfflineIndicator` + `SyncStatus` widget in AppBar

### 2.10 Cloud Layer (Supabase)

> ⚠️ **Requires Supabase project setup.** See [cloud_setup.md](./cloud_setup.md) for SQL + config.

- Auth: email/password + Google OAuth (Supabase Auth)
- Encrypted backup: AES-256-CBC, uploaded to Supabase Storage
- Multi-device sync: bi-directional via Supabase Realtime
- Conflict resolution: last-write-wins on `updated_at`, water params always append
- Offline-first preserved: cloud is additive, never blocking

### 2.11 Smart Layer (OpenAI)

> ⚠️ **Requires `--dart-define=OPENAI_API_KEY=sk-...` at build time.** See BUILD_INSTRUCTIONS.md.  
> ⚠️ **Smart Hub screen is built but NOT yet wired into bottom nav.** See [§9.2](#92-navigation-bugs) for exact fix.

| Feature | Model | Detail |
|---------|-------|--------|
| **Fish & Plant ID** | GPT-4o Vision | Camera/gallery → common name, scientific name, care level, water params, compatibility notes, care tips → "Add to My Tank" |
| **Symptom Triage** | GPT-4o-mini | Chip-based symptom picker + water params entry → AI diagnosis with urgency, immediate actions, vet advice (streaming) |
| **Anomaly Detection** | GPT-4o-mini | Rules-based first pass (pH drift, temp spike, ammonia alert, high nitrate) + AI explanation and recommendation |
| **Weekly Plan Generator** | GPT-4o-mini | Personalised 7-day maintenance plan from tank data → expandable calendar UI → "Add all to schedule" |

All features degrade gracefully when offline or API key is missing.

### 2.12 Accessibility

- Reduced motion: system detection + user override
- WCAG AA colour contrast: all semantic colours verified ≥4.5:1
- 60+ pre-computed alpha colours (eliminates `.withOpacity()` GC pressure — partially migrated)
- Haptic feedback: contextual, respects preferences
- Touch targets: 48dp minimum enforced (AppTouchTargets)

> ⚠️ **Screen reader / Semantics coverage is poor.** Only `ProfileCreationScreen` has proper `Semantics` wrapping. All other screens need work before claiming accessibility compliance.

### 2.13 Settings

| Setting | Options |
|---------|---------|
| Theme Mode | System / Light / Dark |
| Units | Metric / Imperial |
| Notifications | Enable/disable, per-type |
| Ambient Lighting | Time-of-day overlay (dawn/day/dusk/night) |
| Haptic Feedback | Enable/disable |
| Room Theme | 12 themes (Ocean, Pastel, Sunset, Midnight, Forest, Dreamy, Watercolor, Cotton, Aurora, Golden, Cozy Living, Evening Glow) |
| Daily XP Goal | Configurable (default 50 XP) |
| Reduced Motion | System / Force on / Force off |
| Streak Reminders | Morning/evening/night times |

---

## 3. Tech Stack

### Core

| Component | Technology | Version |
|-----------|-----------|---------|
| Framework | Flutter | SDK ≥3.10.8 |
| Language | Dart | SDK ≥3.10.8 |
| State Management | flutter_riverpod | ^2.6.1 |
| Routing | go_router declared but **imperative Navigator.push used in practice** | ^14.8.1 |

### Full Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^2.6.1 | State management |
| `riverpod_annotation` | ^2.6.1 | Riverpod codegen annotations |
| `go_router` | ^14.8.1 | Declared; **not actively used for routing** |
| `http` | ^1.2.2 | OpenAI API calls |
| `uuid` | ^4.5.1 | Model ID generation |
| `intl` | ^0.20.2 | Date formatting, i18n |
| `collection` | ^1.19.1 | groupBy, etc. |
| `synchronized` | ^3.3.0+3 | Serialised async storage writes |
| `connectivity_plus` | ^6.1.2 | Online/offline monitoring |
| `fl_chart` | ^0.69.2 | Parameter trend charts |
| `flutter_animate` | ^4.5.0 | Declarative animations |
| `rive` | ^0.13.0 | Rive interactive animations |
| `confetti` | ^0.7.0 | Confetti particle effects |
| `skeletonizer` | ^2.1.2 | Skeleton loading states |
| `floating_bubbles` | ^2.6.2 | Ambient bubble effects |
| `animations` | ^2.0.11 | Material motion animations |
| `lottie` | ^3.0.0 | Lottie JSON animation playback |
| `audioplayers` | ^6.1.0 | Celebration sounds |
| `vibration` | ^2.0.0 | Haptic feedback |
| `path_provider` | ^2.1.5 | Platform file paths |
| `share_plus` | ^10.1.4 | Share to other apps |
| `image_picker` | ^1.1.2 | Camera/gallery access |
| `path` | ^1.9.0 | File path utilities |
| `shared_preferences` | ^2.3.3 | Key-value persistent storage |
| `url_launcher` | ^6.3.1 | Open URLs |
| `file_picker` | ^8.1.7 | File selection |
| `flutter_local_notifications` | ^18.0.1 | Push notifications |
| `timezone` | ^0.10.0 | Timezone-aware scheduling |
| `archive` | ^3.6.1 | ZIP backup creation |
| `cached_network_image` | ^3.4.1 | Network image caching |
| `supabase_flutter` | ^2.8.4 | Auth, database, storage |
| `encrypt` | ^5.0.3 | AES-256 encryption |
| `crypto` | ^3.0.6 | SHA key derivation |
| `pointycastle` | ^3.9.1 | Cryptographic algorithms |
| `cupertino_icons` | ^1.0.8 | iOS icons |

### Disabled / Pending

| Package | Status |
|---------|--------|
| Firebase Core/Analytics/Crashlytics/Performance | Commented out — pending Firebase project setup |
| Hive | Commented out — listed as future local DB option |

---

## 4. Architecture

### 4.1 Navigation

**Active shell:** `TabNavigator` — 4-tab bottom nav

```
Tab 0: Learn        → LearnScreen
Tab 1: Quiz         → PracticeHubScreen  (badge: SRS cards due)
Tab 2: Tank         → HomeScreen
Tab 3: Settings     → SettingsHubScreen
```

Each tab has its own `GlobalKey<NavigatorState>` for independent navigation stacks. Double-back-to-exit at root level.

**App entry flow:**
```
main.dart → _AppRouter
  ├── No profile → ProfileCreationScreen → onboarding flow
  └── Has profile → TabNavigator
```

**Legacy shell (still exists, should be removed):** `HouseNavigator` — old 6-room horizontal swipe. Still referenced by onboarding screens. See §9.2.

### 4.2 State Management

All state managed via `flutter_riverpod` `StateNotifierProvider` pattern.

| Provider | Manages |
|----------|---------|
| `tankProvider` | All tanks, livestock, equipment, logs, tasks |
| `userProfileProvider` | XP, streaks, hearts, goals, lesson progress, achievements, inventory |
| `lessonProvider` | Lazy-loaded lesson content (deferred imports per path) |
| `settingsProvider` | Theme, units, notifications, ambient, haptics |
| `heartsProvider` | Hearts/lives state and auto-refill timer |
| `gemsProvider` | Gem balance + transaction history |
| `achievementProvider` | Achievement progress + unlock checking |
| `spacedRepetitionProvider` | SRS cards, sessions, stats |
| `friendsProvider` | Friends list + activity feed |
| `roomThemeProvider` | Selected room visual theme |
| `reducedMotionProvider` | Reduced motion state |
| `authProvider` | Supabase auth state |
| `aiHistoryProvider` | Last 10 AI interactions |
| `anomalyHistoryProvider` | Last 50 anomalies |
| `weeklyPlanProvider` | Cached AI weekly plan |

### 4.3 Storage

| Layer | Technology | Use |
|-------|-----------|-----|
| Primary (local) | `LocalJsonStorageService` — JSON files via path_provider | Tanks, livestock, equipment, logs, tasks |
| Key-Value (local) | `SharedPreferences` | Settings, gems, achievements, SRS state, inventory |
| Cloud (additive) | Supabase (Postgres + Realtime + Storage) | Sync, backup, auth |
| Image cache | LRU in-memory + disk cache | Photos |

Storage writes are serialised via `synchronized` package to prevent race conditions. Corruption recovery: auto-backup + `StorageState.corrupted` transition.

### 4.4 Services Layer

```
lib/services/
├── local_json_storage_service.dart  — primary storage
├── supabase_service.dart            — cloud client
├── cloud_sync_service.dart          — bi-directional sync
├── cloud_backup_service.dart        — AES-256 encrypted backup
├── backup_service.dart              — local ZIP backup
├── offline_aware_service.dart       — offline action queue
├── sync_service.dart                — sync-on-reconnect
├── conflict_resolver.dart           — multi-strategy conflict resolution
├── openai_service.dart              — GPT-4o / GPT-4o-mini API client
├── notification_service.dart        — local push notifications
├── hearts_service.dart              — hearts/lives system
├── celebration_service.dart         — confetti + level-up
├── enhanced_celebration_service.dart— celebrations + audio + haptics
├── xp_animation_service.dart        — floating XP gain animations
├── achievement_service.dart         — achievement checking/unlocking
├── shop_service.dart                — purchase + inventory management
├── compatibility_service.dart       — fish compatibility analysis
├── stocking_calculator.dart         — stocking level calculation
├── difficulty_service.dart          — adaptive difficulty
├── review_queue_service.dart        — SRS priority scoring
├── analytics_service.dart           — progress aggregation + insights
├── onboarding_service.dart          — first-launch state
├── haptic_service.dart              — haptic feedback
├── ambient_time_service.dart        — time-of-day lighting
├── image_cache_service.dart         — LRU image cache
├── sample_data.dart                 — demo tank generation
└── firebase_analytics_service.dart  — DISABLED (pending config)
```

### 4.5 Design Token System

```
AppColors          — 60+ pre-computed colours incl. full alpha variants
  ├── Primary: #3D7068 (teal), Secondary: #9F6847 (brown)
  ├── Semantic: success, warning, error, info, xp
  ├── onX tokens: onPrimary, onSecondary, onSurface, onBackground, onError, onSuccess, onWarning
  ├── Dark mode: full dark variants for all light-mode colours
  └── Alpha pre-computation: AppOverlays.*

AppTypography      — headlineLarge/Medium/Small, titleLarge/Medium/Small,
                     bodyLarge/Medium/Small, labelLarge/Medium/Small
                     + aliases: display, headline, title, body, label, caption, overline
                     Font: 'SF Pro Display' → system fallback

AppSpacing         — xs(4) sm(8) sm2(12) md(16) lg2(20) lg(24) xl(32) xl2(40) xxl(48) xxxl(64)

AppRadius          — xs(4) sm(8) md2(12) md(16) lg(24) xl(32) pill(100)

AppElevation       — level0(0) level1(2) level2(4) level3(8) level4(12) level5(24)
                     ⚠️ Defined but NOT yet adopted in screens

AppDurations       — animation duration constants  ⚠️ Defined but not used
AppCurves          — animation curve constants      ⚠️ Defined but not used
AppIconSizes       — icon size constants            ⚠️ Defined but not used
AppTouchTargets    — 48/56/64dp touch targets       ⚠️ Defined but not used

RoomTheme          — 12 visual themes with full colour palettes
AppShadows         — soft, medium BoxShadow presets
```

---

## 5. Screen Inventory

### Navigation Tabs

| Tab | Screen | File |
|-----|--------|------|
| Learn | `LearnScreen` | `lib/screens/learn_screen.dart` |
| Quiz | `PracticeHubScreen` | `lib/screens/practice_hub_screen.dart` |
| Tank | `HomeScreen` | `lib/screens/home/home_screen.dart` |
| Settings | `SettingsHubScreen` | `lib/screens/settings_hub_screen.dart` |

### Home / Tank

`HomeScreen` → `TankDetailScreen` → Logs, Livestock, Equipment, Tasks, Charts, Cost Tracker, Journal, Maintenance Checklist, Photo Gallery, Tank Settings, Tank Comparison, Livestock Value

Also: `CreateTankScreen`, `TankVolumeCalculatorScreen`

### Learning

`LearnScreen` → `LessonScreen` → `PracticeScreen`  
`PracticeHubScreen` → `SpacedRepetitionPracticeScreen`  
`StoriesScreen` → `StoryPlayerScreen`  
`PlacementResultScreen` (after placement test)

### Onboarding

`OnboardingScreen` → `ExperienceAssessmentScreen` → `FirstTankWizardScreen`  
`ProfileCreationScreen` → `EnhancedPlacementTestScreen` → `PlacementResultScreen`  
`TutorialWalkthroughScreen`, `EnhancedTutorialWalkthroughScreen`

### Smart (AI) — ⚠️ NOT YET WIRED INTO NAV

`SmartScreen` → `FishIdScreen`, `SymptomTriageScreen`, `WeeklyPlanScreen`  
Anomaly cards surfaced on `TankDetailScreen`

### Reference Guides (17 screens)

Nitrogen Cycle, Water Parameters, Feeding, Breeding, Disease, Algae, Equipment, Substrate, Hardscape, Lighting Schedule, Acclimation, Quarantine, Vacation, Emergency, Troubleshooting, Quick Start, Glossary, FAQ

### Tools & Calculators (5 screens)

Water Change Calculator, Dosing Calculator, CO2 Calculator, Unit Converter, Cost Tracker

### Settings & Account

`SettingsHubScreen` → `SettingsScreen` → `AccountScreen`, `NotificationSettingsScreen`, `ThemeGalleryScreen`, `DifficultySettingsScreen`, `AboutScreen` → Privacy, Terms  
`BackupRestoreScreen`

### Social / Gamification

`AchievementsScreen`, `LeaderboardScreen`, `FriendsScreen`, `FriendComparisonScreen`, `ActivityFeedScreen`, `ShopStreetScreen`, `AnalyticsScreen`

### Orphaned Screens (built but unreachable)

| Screen | Notes |
|--------|-------|
| `EnhancedOnboardingScreen` | Superseded by `OnboardingScreen` |
| `EnhancedQuizScreen` | Never routed to |
| `PlacementTestScreen` | Superseded by `EnhancedPlacementTestScreen` |
| `GemShopScreen` | No route |
| `SearchScreen` | No route |
| `StudyScreen` (rooms/) | Only in old `HouseNavigator` |

---

## 6. Data Models

| Model | Key Fields |
|-------|------------|
| `Tank` | id, name, type (freshwater/marine), volumeLitres, waterTargets, createdAt |
| `WaterTargets` | tempMin/Max, phMin/Max, ghMin/Max, khMin/Max — factory presets |
| `Livestock` | id, tankId, commonName, scientificName, count, sizeCm, temperament, imageUrl |
| `Equipment` | id, tankId, type, name, maintenanceIntervalDays, lastServiced, expectedLifespanMonths |
| `LogEntry` | id, tankId, type, date, waterTestResults (all nullable params), notes |
| `Task` | id, tankId, title, recurrence, dueDate, priority, isAutoGenerated |
| `UserProfile` | id, name, experienceLevel, totalXp, currentStreak, hearts, league, weeklyXP, completedLessons, lessonProgress, inventory |
| `LessonProgress` | lessonId, strength (0-100, decays over 30 days), reviewCount, lastReviewDate |
| `LearningPath` | id, title, emoji, lessons, recommendedFor |
| `Lesson` | id, pathId, xpReward, estimatedMinutes, sections, quiz, prerequisites |
| `Exercise` (abstract) | 5 subclasses: MultipleChoice, FillBlank, TrueFalse, Matching, Ordering |
| `Achievement` | id, rarity (bronze/silver/gold/platinum), category, xpReward |
| `Friend` | id, username, avatarEmoji, totalXp, currentStreak, isOnline |
| `ReviewCard` | id, conceptId, strength, nextReview, currentInterval (SRS) |
| `ShopItem` | id, category, type, gemCost, isConsumable, durationHours |
| `WishlistItem` | id, category (fish/plant/equipment), estimatedPrice, purchased |
| `GemTransaction` | id, type (earn/spend/refund), amount, reason, balanceAfter |
| `IdentificationResult` | commonName, scientificName, careLevel, phMin/Max, tempMin/Max, careTips, isPlant |
| `Anomaly` | id, tankId, parameter, severity (warning/alert/critical), aiExplanation, dismissed |

---

## 7. Assets

### Rive Animations (`assets/rive/`)

| File | Description |
|------|-------------|
| `water_effect.riv` | Animated water surface/ripple |
| `emotional_fish.riv` | Fish with emotional expressions |
| `joystick_fish.riv` | Interactive fish (input-driven) |
| `puffer_fish.riv` | Animated puffer fish character |

### Image Assets — ⚠️ MISSING

All image directories contain only `.gitkeep` files. **No actual illustration assets exist yet.**

| Directory | Intended Content |
|-----------|-----------------|
| `assets/images/empty_states/` | Empty state illustrations |
| `assets/images/onboarding/` | Onboarding illustrations |
| `assets/images/illustrations/` | General illustrations |
| `assets/images/error_states/` | Error state illustrations |
| `assets/images/features/` | Feature graphics |
| `assets/icons/badges/` | Achievement badge icons |

### Audio Assets — ⚠️ MISSING

No audio files exist. `AUDIO_README.md` specifies 5 sounds needed:
- `fanfare.mp3` (2-3s) — lesson completion
- `chime.mp3` (1-2s) — achievement unlock
- `applause.mp3` (2-4s) — streak milestones
- `fireworks.mp3` (3-5s) — level up
- `whoosh.mp3` (0.5-1s) — small XP gains

The celebration service degrades gracefully when audio is absent.

### Fonts

No custom fonts bundled. `'SF Pro Display'` declared, falls back to system font.

---

## 8. Build & Setup

### Prerequisites

- Flutter SDK ≥3.10.8
- Android Studio / Xcode for device builds
- Supabase project (optional — app works offline without it)
- OpenAI API key (optional — Smart features disabled gracefully)

### Quick Build

```bash
# Debug APK (no Smart features)
flutter build apk --debug

# Debug APK with Smart features
flutter build apk --debug \
  --dart-define=OPENAI_API_KEY=sk-your-key-here

# Release APK (requires signing config in android/key.properties)
flutter build apk --release \
  --dart-define=OPENAI_API_KEY=sk-your-key-here
```

### Environment Variables

| Variable | Required | Purpose |
|----------|----------|---------|
| `OPENAI_API_KEY` | Optional | Enables all Smart (AI) features |

### Supabase Setup

1. Create a new Supabase project at https://supabase.com
2. Run SQL from `aquarium-roadmap/cloud_setup.md` in the Supabase SQL Editor
3. Update `lib/services/supabase_service.dart` lines 32-33:
   ```dart
   static const String _supabaseUrl = 'https://YOUR_PROJECT_REF.supabase.co';
   static const String _supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```
4. Configure Google OAuth in Supabase Auth settings (optional)

### Android Signing

Keystore file: `android/app/aquarium-release.jks`  
Key properties: `android/key.properties` (gitignored — do not commit)

---

## 9. Known Issues & TODOs

### 9.1 Critical — Fix Before Ship

| # | Issue | File(s) | Fix |
|---|-------|---------|-----|
| C1 | **Onboarding routes to wrong nav shell** | `onboarding_screen.dart`, `profile_creation_screen.dart`, `first_tank_wizard_screen.dart`, `tutorial_walkthrough_screen.dart`, `enhanced_tutorial_walkthrough_screen.dart` | Replace all `HouseNavigator` references with `TabNavigator` (or route through `_AppRouter`). 5 files affected. |
| C2 | **Smart Hub has no navigation route** | `lib/screens/tab_navigator.dart` | Add as 5th bottom nav tab. Full implementation: add import, add 5th `GlobalKey`, add `Navigator` in `IndexedStack`, update Settings index 3→4, add `NavigationDestination` (see `ux_review.md §5` for exact code) |
| C3 | **Cloud sync data merge incomplete** | `lib/services/cloud_sync_service.dart` lines 193, 207, 211 | 3 TODO items: merge water parameter history, conflict notification UI, per-table merge into LocalJsonStorageService |

### 9.2 High — Quality Bar

| # | Issue | Detail |
|---|-------|--------|
| H1 | **150+ `.withOpacity()` calls** | Creates GC pressure in build/paint. Worst offenders: `room_scene.dart` (~30), `app_theme.dart` (~12), `glass_card.dart` (~7), screens (~60+). Replace with `AppOverlays.*` pre-computed constants or `Color.fromARGB()`. |
| H2 | **12% test coverage** | 37 tests for 304 source files. Critical paths with ZERO tests: cloud sync, auth flows, all AI features, notification/reminder system, calculators. See `audit_report.md` for full list. |
| H3 | **Leaderboard uses entirely mock data** | `LeaderboardScreen` calls `MockLeaderboard.generate()`. Either connect to real data or label clearly as demo. |
| H4 | **No real images or audio** | All image dirs contain `.gitkeep` only. Audio files absent. App works (graceful degradation) but looks/sounds incomplete. |

### 9.3 Medium — Polish

| # | Issue | Detail |
|---|-------|--------|
| M1 | **4 new design tokens unused** | `AppElevation`, `AppDurations`, `AppCurves`, `AppIconSizes` defined but zero screen adoption. Either adopt or remove. |
| M2 | **4 common widgets unused** | `CozyCard`, `RoomHeader`, `PrimaryActionTile`, `DrawerListItem` defined but never imported by any screen. Either adopt or delete. |
| M3 | **Deprecated widget files linger** | `loading_state.dart`, `error_state.dart`, `empty_state.dart`, `confetti_overlay.dart` marked `@deprecated` — confirm no imports remain then delete. |
| M4 | **Orphaned screens** | 6 screens (see §5) built but unreachable. Delete or route to them. |
| M5 | **"Dev User" quick-start profile** | `ProfileCreationScreen._skipToHome()` creates profile named "Dev User". Should prompt for name or use "Aquarist". |
| M6 | **78 `.withOpacity()` calls in screens** | Subset of H1 — specifically in screen files (not widgets). |
| M7 | **123 `Colors.white` hardcodes** | Some are intentional (white-on-primary), ~40 should use `AppColors.onPrimary` semantic token. |
| M8 | **Markdown files in `lib/`** | `lib/HEARTS_SYSTEM_README.md`, `lib/ADAPTIVE_DIFFICULTY_README.md`, `lib/INTEGRATION_CHECKLIST.md` add to app bundle. Move to `docs/`. |
| M9 | **Themed room screens bypass dark mode** | `InventoryScreen`, `ShopStreetScreen`, `WorkshopScreen` use fixed gradients with private color classes. Won't respond to dark mode toggle. |
| M10 | **Empty `setState({})` calls** | `reminders_screen.dart:591`, `analytics_screen.dart:65` — empty callbacks force rebuild with no state change. Refactor to Riverpod. |
| M11 | **Hardcoded UI strings** | Labels and messages throughout UI should be extracted to constants for consistency and future i18n readiness. |
| M12 | **Firebase dead code** | Firebase imports commented out everywhere. Either configure or remove all dead code. |
| M13 | **go_router not used** | Listed as dependency; routing is imperative Navigator.push. Either migrate to go_router or remove the dependency. |

### 9.4 Low — Nice-to-Have

| # | Issue |
|---|-------|
| L1 | Accessibility / Semantics — only `ProfileCreationScreen` has proper screen reader support |
| L2 | Delete `HouseNavigator` entirely after fixing onboarding (C1 above) |
| L3 | `PlacementTestScreen` orphaned and superseded — delete |
| L4 | Keystore password in `key.properties` — migrate to CI env vars |
| L5 | Dyslexia font and colour-blind mode referenced in docs but not implemented in code |
| L6 | `GemShopScreen` fully built — add route from Settings or Shop Street |

---

## 10. Roadmap to Ship

### Phase A — Critical Fixes (est. 1 day)

- [ ] Fix onboarding → TabNavigator routing (5 files)
- [ ] Wire Smart Hub into bottom nav (tab_navigator.dart)
- [ ] Complete cloud sync TODO items (3 in cloud_sync_service.dart)

### Phase B — Assets (est. variable)

- [ ] Create/source illustration assets (empty states, onboarding, error states, features)
- [ ] Record or source 5 celebration audio files
- [ ] Create achievement badge icons

### Phase C — Quality & Cleanup (est. 2-3 days)

- [ ] Batch-replace `.withOpacity()` calls with AppOverlays constants (150+)
- [ ] Delete deprecated widget files
- [ ] Delete/route orphaned screens
- [ ] Fix "Dev User" in quick-start
- [ ] Move docs out of lib/
- [ ] Remove Firebase dead code OR configure Firebase

### Phase D — Testing (est. 2-3 days)

- [ ] Add tests for cloud sync + auth flows
- [ ] Add tests for AI features (mock OpenAI responses)
- [ ] Add tests for notification system
- [ ] Add tests for critical calculator screens

### Phase E — Store Launch Prep

- [ ] Set up Supabase project and wire credentials
- [ ] Privacy policy + Terms of Service (screens exist, need real content)
- [ ] App name (TBD)
- [ ] App icon
- [ ] Store listing screenshots + description
- [ ] Play Store app signing

---

## Summary Stats

| Metric | Value |
|--------|-------|
| Total Dart source files | 304 |
| Screen files | ~95 |
| Widget files | ~60 |
| Provider files | 15 |
| Service files | 24 |
| Data files | 22 |
| Test files | 38 |
| Learning paths | 9 |
| Rive animations | 4 |
| Room themes | 12 |
| Achievement categories | 5 |
| Quiz exercise types | 5 |
| Architecture score | 8/10 |
| Code quality score | 6/10 |
| UX score | 6.5/10 |
| Test coverage | ~12% |
| **Overall readiness** | **~70% — Pre-launch work remaining** |

---

*Document compiled from: audit_report.md, feature_inventory.md, ux_review.md, polish_complete.md, lazyload_complete.md, cloud_complete.md, smart_complete.md*
