# Danio Aquarium App

## IMPORTANT: Read Before Modifying

Before making ANY code changes, you MUST understand the area you're modifying. Read the relevant screen, provider, and model files first. Do not guess at architecture - this is a large app with 166 screens, 20 providers, 22 models, and 33 services.

If the user asks to modify a feature, explore the relevant files BEFORE proposing changes. Use the Explore agent or read files directly.

## IMPORTANT: Update This File After Feature Work

After completing any feature that adds new screens, providers, models, or services, UPDATE this CLAUDE.md file before the final commit. Add new entries to the relevant maps (Screen Map, Provider Map, Model Map) and update counts. This ensures the next session starts with accurate context.

A Stop hook will remind you if new .dart files were added to key directories.

## IMPORTANT: Workflow Guardrails

**Canonical Codex workflow:** Follow `docs/development/CODEX_SAFE_WORKFLOW.md`. The default safety level is audit first: inspect, write a short risk note, then edit narrowly.

**Feature branches:** Before starting any new feature, create a branch: `git checkout -b feature/description`. Do NOT commit directly to `main` for new feature work. Only merge back via PR or explicit user request.

**Main is protected by process:** Do not commit, push, reset, rebase, or discard work on `main` unless the user explicitly asks. If local `main` is ahead of `origin/main`, preserve that commit.

**Scout agents:** Use subagents as read-only scouts for larger audits. The main Codex instance remains the only editor unless the user explicitly approves worker agents with disjoint file ownership.

**One feature per session:** If the user asks about a completely different feature than what you've been working on, suggest starting a new session or using `/clear` first. Mixing unrelated features in one session leads to context pollution and mistakes.

**Session scope check:** If the session has been going for a long time with many changes, proactively suggest committing current work before starting new tasks. Say: "We've built a lot — want me to commit and push what we have before we continue?"

**Test before final commit:** Always run `flutter test` before the final commit of a feature. The git pre-commit hook runs `flutter analyze` automatically, but tests must be run explicitly.

**No broken windows:** If you encounter failing tests that are pre-existing, note them but do not ignore them. Flag them to the user and offer to fix.

**High-risk areas:** Before navigation/layout work, read `main.dart`, `tab_navigator.dart`, and `navigation/app_routes.dart`. Before Tank UI work, read `home_screen.dart`, `bottom_sheet_panel.dart`, and relevant stage/home sheet widgets. Before persistence, backup, or sync work, read both JSON storage and SharedPreferences-backed providers. Before Smart/AI work, resolve the direct OpenAI vs proxy contract.

## Build & Test

```bash
# Working directory for all commands:
cd repo/apps/aquarium_app

# Dependencies
flutter pub get

# Run analysis (must pass before committing)
flutter analyze --no-pub

# Run tests (900+ tests, ~50s)
flutter test

# Build debug APK
flutter build apk --debug --target-platform android-arm64 --no-pub

# Build release app bundle for Play Store/release gating
flutter build appbundle --release

# Android smoke test on a connected emulator/device
flutter test integration_test/smoke_test_v2.dart -d <device-id>
```

Package name: `com.tiarnanlarkin.danio`
Package import: `package:danio/`

## Project Structure

```
repo/apps/aquarium_app/
  lib/
    main.dart                    # App entry point
    screens/                     # 164 screen files (see Screen Map below)
    providers/                   # 20 Riverpod providers (see Provider Map)
    models/                      # 22 data models (see Model Map)
    services/                    # 33 services (see Service Map)
    widgets/                     # Reusable widgets by domain
    theme/                       # Design system (app_theme.dart barrel exports)
    data/lessons/                # 14 lesson modules, 44 lessons
    navigation/app_routes.dart   # Centralised route definitions
    constants/                   # App-wide constants
    utils/                       # Utility functions
    painters/                    # Custom Canvas painters
    features/                    # Feature modules (auth, smart)
    supabase/                    # Backend integration
  test/                          # Unit + widget tests
  assets/                        # Images, fonts, Rive animations, backgrounds
```

## Architecture

- **State management:** Riverpod (StateNotifier + Provider pattern)
- **Backend:** Supabase (auth, database, realtime sync)
- **Analytics:** Firebase Crashlytics
- **AI features:** OpenAI API via `AiProxyService` (user provides own key)
- **Persistence:** JSON file storage for tank/log/task data; SharedPreferences for settings/profile/practice/gamification; Supabase/cloud sync scaffolding
- **Fonts:** Nunito (body), Fredoka (headers)
- **Animations:** Rive files, flutter_animate, custom painters

## 5-Tab Navigation

| Index | Tab | Screen | Purpose |
|-------|-----|--------|---------|
| 0 | Learn | `screens/learn/` | Learning hub: lessons, paths, XP, streaks, review banners |
| 1 | Practice | `screens/spaced_repetition_practice/` | Spaced repetition with MC + matching questions |
| 2 | Tank/Home | `screens/home/` | Room scene with aquarium, theme picker, tank management |
| 3 | Smart | `features/smart/` | AI tools: Fish ID, Symptom Triage, Weekly Plan |
| 4 | Settings | `screens/settings/` | Preferences, account, notifications, data management |

## Screen Map (Key Screens)

### Tank Management
- `home/home_screen.dart` — Main room scene with animated aquarium
- `home/widgets/empty_room_scene.dart` — First-run scene (reuses `buildRoomBackground` + `AquariumStand` with a ghost-glass outline; content panel hosts `SetupPathSelector`)
- `home/widgets/setup_path_selector.dart` — Two-card guided vs. expert picker for first tank creation
- `tank_detail/` — Individual tank view with logs and parameters
- `add_log/` — Water test, feeding, cleaning, maintenance log entry
- `create_tank_screen.dart` — Tank creation; accepts a `SetupMode` to switch between the 3-page wizard (`SetupMode.guided`) and a single expert form (`SetupMode.expert`)
- `create_tank_screen/setup_mode.dart` — `enum SetupMode { guided, expert }` passed from `EmptyRoomScene`
- `livestock/` — Fish/plant species management per tank

### Learning System
- `learn/learn_screen.dart` — Learning hub with paths, streak, XP badges
- `lesson/` — Individual lesson display with sections and quiz
- `spaced_repetition_practice/` — Practice sessions with active questions
- `story/` — Interactive story content with branching

### Smart/AI Features
- `features/smart/` — Smart Hub with AI-powered tools
- Fish ID (image recognition), Symptom Triage (diagnosis), Weekly Plan (task suggestions)

### Settings & Account
- `settings/settings_screen.dart` — 10-section preferences screen
- `onboarding/` — First-time user flow with consent, age verification
- `achievements_screen.dart` — Badges and completion tracking
- `gem_shop_screen.dart` — Premium currency shop

### Tools & Guides
- `compatibility_checker_screen.dart`, `co2_calculator_screen.dart`, `dosing_calculator_screen.dart`
- `emergency_guide_screen.dart`, `disease_guide_screen.dart`, `feeding_guide_screen.dart`
- `cycling_assistant_screen.dart`, `algae_guide_screen.dart`
- `glossary_screen.dart`, `faq_screen.dart`

## Provider Map

| Provider | File | Manages |
|----------|------|---------|
| `tankProvider` | `tank_provider.dart` | Tank CRUD, tank list, active tank |
| `userProfileProvider` | `user_profile_provider.dart` | User profile, XP, level, daily goal |
| `lessonProvider` | `lesson_provider.dart` | Lazy-loaded lesson paths, progress tracking |
| `spacedRepetitionProvider` | `spaced_repetition_provider.dart` | Review cards, sessions, resolved questions, stats |
| `roomThemeProvider` | `room_theme_provider.dart` | Active room theme (12 themes) |
| `settingsProvider` | `settings_provider.dart` | App settings: theme mode, haptics, ambient lighting |
| `heartsProvider` | `hearts_provider.dart` | Hearts/lives system for practice |
| `achievementProvider` | `achievement_provider.dart` | Achievement unlock checking |
| `celebrationProvider` | `celebration_provider.dart` | XP celebrations, level-up animations |
| `gemsProvider` | `gems_provider.dart` | Gem currency balance and transactions |
| `syncProvider` | `sync_provider.dart` | Cloud sync state |
| `onboardingProvider` | `onboarding_provider.dart` | Onboarding completion state |
| `reducedMotionProvider` | `reduced_motion_provider.dart` | Accessibility: animation preferences |
| `inventoryProvider` | `inventory_provider.dart` | XP boost items |
| `wishlistProvider` | `wishlist_provider.dart` | Fish/plant wishlist |
| `speciesUnlockProvider` | `species_unlock_provider.dart` | Species unlock progression |
| `ambientTimeProvider` | `ambient_time_provider.dart` | Day/night ambient lighting |
| `storageProvider` | `storage_provider.dart` | SharedPreferences instance |

## Model Map

| Model | File | Key classes |
|-------|------|-------------|
| `tank.dart` | Tank, TankType, WaterType | Tank configuration |
| `log_entry.dart` | LogEntry, LogType | Water tests, feedings, maintenance |
| `user_profile.dart` | UserProfile, ExperienceLevel | User data, XP, streaks |
| `learning.dart` | LearningPath, Lesson, Quiz, QuizQuestion, LessonSection | Educational content |
| `spaced_repetition.dart` | ReviewCard, ReviewSession, MasteryLevel, ReviewInterval | Spaced repetition algorithm |
| `resolved_question.dart` | ResolvedQuestion, MultipleChoiceQuestion, MatchingPairsQuestion, MatchPair | Active practice questions |
| `achievements.dart` | Achievement, AchievementType | Badge definitions |
| `gem_economy.dart` | GemBalance, GemTransaction | Virtual currency |
| `story.dart` | Story, StoryChapter | Interactive narrative content |
| `livestock.dart` | FishSpecies, PlantSpecies | Species data |
| `adaptive_difficulty.dart` | UserSkillProfile | Difficulty adjustment |

## Theme System

12 room themes controlled by `roomThemeProvider`. Each theme has ~30 colour properties (waves, water, sand, plants, fish, glass, buttons, text). Themes carry across Learn, Practice, and Smart tabs via `ThemedTabHeader`.

Themes: ocean, pastel, sunset, midnight, forest, dreamy, watercolor, cotton, aurora, golden, cozyLiving, eveningGlow

Theme picker: stacked-card browser in a bottom sheet (`screens/home/theme_picker_sheet.dart`) with room background images + painted mini-aquarium overlay.

**When adding new themes:** Add to `RoomThemeType` enum, add static getter to `RoomTheme`, add WebP background to `assets/backgrounds/room-bg-{slug}.webp`, add header assets to `assets/images/headers/{tab}-header-{slug}.webp`.

## Learning System

- 14 learning paths with 44 lessons (lazy-loaded via deferred imports)
- Each lesson has sections (text, heading, keyPoint, tip, warning, funFact) and optional Quiz
- QuizQuestion has question text, 4 options, correctIndex, explanation
- Spaced repetition with 5 mastery levels (new -> learning -> familiar -> proficient -> mastered)
- Practice sessions use active MC and matching-pairs questions generated by `QuestionResolver`
- Strength: +0.2 correct, -0.3 incorrect. Interval scheduling: 1d -> 3d -> 7d -> 14d -> 30d

## Design System

Import `theme/app_theme.dart` for all design tokens (barrel exports `app_colors.dart`, `app_spacing.dart`, `app_typography.dart`, `app_radius.dart`).

- `AppColors` — Color palette with light/dark variants
- `AppSpacing` — Spacing scale (xxs through xl)
- `AppTypography` — Text styles (headlineLarge through bodySmall)
- `AppRadius` — Border radius presets
- `AppOverlays` — Semi-transparent overlay colours
- `context.textPrimary`, `context.surfaceColor`, etc. — Adaptive colour extensions
- `AppButton` with variants: primary, destructive, text
- `AppHaptics` — Haptic feedback (light, medium, selection, success, error)
- `showAppBottomSheet()`, `showAppDragSheet()`, `showAppScrollableSheet()` — Sheet primitives
- **Side panels (Phase 5):** `BrassMedallion` (`widgets/stage/water_quality/brass_medallion.dart`) for water params; `BrassGauge` + `BrassGaugePainter` (`widgets/stage/temperature/brass_gauge.dart`, `brass_gauge_painter.dart`) for the temperature dial. Panels render on a σ:14 glass frame (`SwissArmyPanel`) with no inner card wrappers.

## Key Conventions

- **Imports:** Use `package:danio/` for all internal imports
- **State:** Riverpod `StateNotifierProvider` pattern. Read with `ref.read()`, watch with `ref.watch()`
- **Persistence:** JSON file storage for tank/log/task data; SharedPreferences for local prefs/profile/practice/gamification; Supabase/cloud sync scaffolding
- **Error handling:** `logError()` from `utils/logger.dart`, `DanioSnackBar.error()` for user-facing
- **Navigation:** `NavigationThrottle.push()` to prevent duplicate pushes, `AppRoutes` for named routes
- **Accessibility:** `Semantics` on interactive elements, `reducedMotionProvider` for animation preferences, WCAG AA contrast
- **Testing:** Widget tests in `test/widget_tests/`, unit tests in `test/models/` and `test/providers/`
- **Commits:** Conventional commits (feat:, fix:, docs:, refactor:)
- **Painters:** Custom painters live in `widgets/room/` (not a separate painters/ dir)

## Git

- Default branch: `main` (renamed from `openclaw/stage-system` on 2026-04-07 — see `docs/planning/2026-04-master-merge-strategy.md` for migration details)
- Old `master` branch is frozen, preserved as tag `master-archive-2026-04-07`
- Remote: `origin` → `https://github.com/tiarnanlarkin/danio.git`
- Always run `flutter analyze` and `flutter test` before committing
- Feature branches branch off `main` and merge back via PR
