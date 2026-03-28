# Audit Cycle 1 — Findings
_Date: 2026-03-28_
_Auditor: Argus (Quality Director, Mount Olympus)_
_Branch: openclaw/stage-system_

---

## Critical (must fix before ship)

- [ ] **[SECURITY] AI proxy key is client-side** — `lib/services/ai_proxy_service.dart:1-2` — The `TODO` has been here since day one: "Route through server-side proxy (Supabase Edge Function) before production release." OpenAI key is stored client-side with only local encryption. If this app ships with real users, anyone can extract and abuse the key. FIX: Deploy the Edge Function proxy before any public release.

- [ ] **[ARCHITECTURE] `lesson_screen.dart` is a 1,598-line god class** — `lib/screens/lesson_screen.dart` — Quiz logic, card rendering, progress tracking, hearts modal, hint system, animation controllers, and completion flow are all in a single file. This is unmaintainable and untestable. FIX: Extract at minimum `LessonQuizWidget`, `LessonCardWidget`, `LessonCompletionFlow` into separate files.

- [ ] **[ARCHITECTURE] `livestock_screen.dart` is a 1,580-line god class** — `lib/screens/livestock_screen.dart` — Mix of add/edit/delete dialogs, search, filter, compatibility checking, and list display. 14+ `setState` calls. FIX: Split into sub-widgets; move business logic to a dedicated service or provider.

- [ ] **[ARCHITECTURE] `settings_screen.dart` is a 1,631-line god class** — `lib/screens/settings_screen.dart` — Settings, account links, notification config, debug toggles, data management — all in one file. FIX: Split into section-based sub-files (already started with `guides_section.dart` and `tools_section.dart`).

- [ ] **[ARCHITECTURE] `room_scene.dart` is a 1,862-line file with 3 dead classes** — `lib/widgets/room_scene.dart:352,980,1061` — `_CozyRoomBackground`, `_RoomPlant`, `_ShelfPlant` are all suppressed with `// ignore: unused_element` and "Kept for reference" comments. These are dead code. FIX: Delete the dead classes and split the live room rendering into composable sub-widgets.

---

## High (should fix)

### Code Quality

- [ ] **[CODE] Raw `SnackBar` used in 48 places instead of `DanioSnackBar`** — Multiple screens including `account_screen.dart`, `home_screen.dart`, `create_tank_screen.dart`, `livestock_screen.dart` etc. The `DanioSnackBar` wrapper exists and has a comment saying "Hephaestus will migrate the remaining 100+ raw SnackBar call sites" — it never happened. The raw `SnackBar(content: Text(...))` calls have no semantic type, no consistent styling. FIX: Replace all raw `SnackBar` calls with `DanioSnackBar.show(context, ..., type: SnackType.xxx)`.

- [ ] **[CODE] Mixed absolute/relative imports — 55 files use `package:danio/` while 963 relative imports exist** — e.g., `lib/screens/add_log_screen.dart:24` uses `package:danio/utils/logger.dart` while line 22 uses `'../utils/app_feedback.dart'`. Inconsistent across the codebase. FIX: Pick one convention (prefer relative, as it's the majority) and apply consistently.

- [ ] **[CODE] `TextButton`/`ElevatedButton` raw usage — 102 `TextButton` + 15 `ElevatedButton` instances instead of `AppButton`** — `AppButton` exists with full variant support (`primary`, `secondary`, `text`, `destructive`, `ghost`) but most screens still use raw Flutter buttons. Key offenders: `equipment_screen.dart`, `livestock_screen.dart`, `learn_screen.dart`, `lesson_screen.dart`, `add_log_screen.dart`. FIX: Migrate to `AppButton` — this is why it was built.

- [ ] **[CODE] `TextField`/`TextFormField` used directly — 18+ `TextField` + 20+ `TextFormField` instances** — `AppTextField` exists but is only used in 36 places. Screens like `symptom_triage_screen.dart`, `cost_tracker_screen.dart`, `reminders_screen.dart`, `settings_screen.dart` use raw text inputs with inconsistent decoration/styling. FIX: Migrate to `AppTextField`.

- [ ] **[CODE] `showModalBottomSheet` used raw 32 times** — `lib/screens/achievements_screen.dart:519`, `analytics_screen.dart:1230`, `equipment_screen.dart:235,248`, `livestock_screen.dart:627`, `reminders_screen.dart:54`, `search_screen.dart:304` etc. The `AppBottomSheet` wrapper exists. FIX: Use `AppBottomSheet.show()` for consistency in drag handles, corner radius, and scroll behaviour.

- [ ] **[CODE] `CircularProgressIndicator` used raw in 15+ screens** — `cycling_assistant_screen.dart:28,45`, `equipment_screen.dart:419`, `inventory_screen.dart:127`, `maintenance_checklist_screen.dart:475`, `practice_screen.dart:60`, `spaced_repetition_practice_screen.dart:883`, `tasks_screen.dart:375` etc. `BubbleLoader` and `FishLoader` exist as the on-brand alternatives. FIX: Replace all `CircularProgressIndicator` (outside `main.dart` splash) with `BubbleLoader`.

- [ ] **[CODE] `showDialog` used raw 30+ times with unstyled dialogs** — `lib/screens/equipment_screen.dart:328,390`, `charts_screen.dart:791`, `cost_tracker_screen.dart:284,329`, `inventory_screen.dart:249`, `learn_screen.dart:552,1190`, `lesson_screen.dart:90,111` etc. Dialogs use inconsistent `AlertDialog` with no brand styling. FIX: Create an `AppDialog` wrapper or at minimum standardise `shape`, `backgroundColor`, and button styles.

- [ ] **[CODE] Hardcoded hex color literals in screens** — `lib/screens/algae_guide_screen.dart:44,62,81,95,155` (`Color(0xFF81C784)`, `Color(0xFF43A047)`, `Color(0xFF424242)`, `Color(0xFF9E9E9E)`, `Color(0xFFA5D6A7)`); `analytics_screen.dart:838,840,844,871,872,874`; `inventory_screen.dart:32-34`; `shop_street_screen.dart:109,121`; `wishlist_screen.dart:36`; `workshop_screen.dart:127,147`. FIX: Add named constants to `DanioColors` or `AppColors` and reference by name.

- [ ] **[CODE] Hardcoded hex color literals in widgets** — `lib/widgets/celebrations/level_up_overlay.dart:293,416,468,472`; `widgets/core/glass_card.dart:225,276,287`; `widgets/decorative_elements.dart:166,177,236,251,290,291,424`; `widgets/mascot/mascot_bubble.dart:316,471`. FIX: Move to `DanioColors` palette.

### Architecture

- [ ] **[ARCH] `add_log_screen.dart` is 1,476 lines with embedded business logic** — Photo handling, water change calculations, AI suggestions, parameter parsing, achievement triggering, notification scheduling — all in the screen file. FIX: Extract `WaterChangeLogService`, `PhotoLogService`, and move parameter thresholds to `app_constants.dart`.

- [ ] **[ARCH] `analytics_screen.dart` is 1,367 lines** — Chart rendering, data aggregation, date filtering, legend building — all inline. FIX: Extract `AnalyticsService` for data aggregation; split chart widgets.

- [ ] **[ARCH] `app_theme.dart` is 1,843 lines** — This is the entire design system in one file. Already well-organised but crosses the 500-line maintainability threshold significantly. FIX: Split into `app_colors.dart`, `app_typography.dart`, `app_spacing.dart`, `app_component_themes.dart`.

- [ ] **[ARCH] `user_profile_provider.dart` is 1,242 lines** — Provider mixing data access, XP logic, gem logic, activity tracking, and analytics. FIX: Extract `XPService` and `ActivityTrackingService` out of the provider.

- [ ] **[ARCH] State management inconsistency: 24 screen classes use `StatefulWidget` instead of `ConsumerStatefulWidget`** — `co2_calculator_screen.dart`, `dosing_calculator_screen.dart`, `glossary_screen.dart`, `lighting_schedule_screen.dart`, `difficulty_settings_screen.dart`, `disease_guide_screen.dart` etc. When these screens later need providers, they'll need to be rewritten. FIX: Proactively convert to `ConsumerStatefulWidget` for consistency.

### Testing

- [ ] **[TEST] 52 out of ~60 screens have ZERO tests** — Core user journeys with no test coverage: `home_screen`, `tank_detail_screen`, `livestock_screen`, `add_log_screen`, `learn_screen` (complex), `lesson_screen`, `tasks_screen`, `reminders_screen`, `analytics_screen`, `journal_screen`, `equipment_screen`, `account_screen`, `achievements_screen`, and all guide screens. The only tested screens: `learn_screen` (partial), `settings_screen` (partial), `co2_calculator`, `compatibility_checker`, `cost_tracker`, `onboarding` (partial). FIX: Prioritise tests for `home_screen`, `add_log_screen`, `lesson_screen`, `tank_detail_screen`.

- [ ] **[TEST] No service-layer tests** — `achievement_service.dart`, `tank_health_service.dart`, `hearts_service.dart`, `stocking_calculator.dart`, `notification_service.dart`, `compatibility_service.dart` have no unit tests. FIX: Add unit tests for all services, especially the calculation-heavy ones.

---

## Medium (nice to have)

### UI/UX Consistency

- [ ] **[UI] 275 raw `EdgeInsets` literals in screens** — Multiple screens use `EdgeInsets.all(16)`, `EdgeInsets.fromLTRB(16, 0, 16, 16)`, `EdgeInsets.symmetric(...)` with bare numbers instead of `AppSpacing` constants. Key offenders: `settings_screen.dart:1011,1323,1334`, `notification_settings_screen.dart:145`, `achievements_screen.dart:354`, `algae_guide_screen.dart:432`, `breeding_guide_screen.dart:318`, `disease_guide_screen.dart:120`, `emergency_guide_screen.dart:275`. FIX: Replace literal values with `AppSpacing.md`, `AppSpacing.lg` etc.

- [ ] **[UI] `Colors.red`, `Colors.orange`, `Colors.green`, `Colors.grey`, `Colors.brown` used directly in production UI** — `substrate_guide_screen.dart:225,230,246,258` uses `Colors.brown.shade300/600/800/900`; `hobby_items.dart:193-214` uses `Colors.grey.shade300`, `Colors.yellow.shade200`, `Colors.green.shade300/600`, `Colors.orange.shade100/300/600`; `onboarding_screen.dart:408` uses `Colors.grey` for an error icon. FIX: Map these to `AppColors` or `DanioColors` named tokens.

- [ ] **[UI] `debug_menu_screen.dart` uses raw `Colors.orange`, `Colors.deepOrange`, `Colors.red`** — Lines 270, 279, 280, 286, 355, 387, 414. Acceptable for a debug screen but still inconsistent. FIX: Consider `AppColors.warning` and `AppColors.error`.

- [ ] **[UI] `achievement_unlocked_dialog.dart` uses raw `Colors.red`, `Colors.green`, `Colors.yellow`** — `lib/widgets/achievement_unlocked_dialog.dart:345,347,348` — confetti colors. FIX: Use `DanioColors` palette for brand consistency.

- [ ] **[UI] `confetti_overlay.dart` uses raw `Colors.red`, `Colors.orange`, `Colors.yellow`, `Colors.green`** — `lib/widgets/celebrations/confetti_overlay.dart:54-57`. FIX: Use `DanioColors` palette.

- [ ] **[UI] `performance_overlay.dart` uses raw `Colors.green`, `Colors.orange`, `Colors.red`** — Lines 97-100, 116, 122, 224, 232, 240-241, 318. This is a debug overlay so lower priority, but it's still inconsistent. Note: Performance overlay in production code is fine — confirm it's gated behind a debug flag.

- [ ] **[UI] `Image.asset` without `cacheWidth`/`cacheHeight`** — `lib/screens/about_screen.dart:37` (100×100 logo), `lib/screens/onboarding/aha_moment_screen.dart:251` (80×80 fish sprite), `lib/screens/onboarding/aha_moment_screen.dart:465` (34×34 sprite), `lib/screens/onboarding/fish_select_screen.dart:421` (fish sprite), `lib/screens/onboarding/paywall_stub_screen.dart:142`, `lib/screens/onboarding/warm_entry_screen.dart:411`, `lib/widgets/room_scene.dart:85,376`, `lib/screens/tank_detail/widgets/livestock_preview.dart:81`. FIX: Add `cacheWidth`/`cacheHeight` matching the rendered size to prevent unnecessary decoding.

- [ ] **[UI] `hex color strings` in model layer** — `lib/models/achievements.dart:46-52` returns `'#CD7F32'`, `'#C0C0C0'`, `'#FFD700'`, `'#E5E4E2'`; `lib/models/leaderboard.dart:40-46` returns `'#CD7F32'`, `'#C0C0C0'`, `'#FFD700'`, `'#B9F2FF'`. These are medal/league colours used for display. FIX: Move to `AppAchievementColors` or `DanioColors` and return `Color` objects instead of strings.

### Accessibility

- [ ] **[A11Y] 72 `GestureDetector` instances without wrapping `Semantics`** — Key ones: `account_screen.dart:41`, `add_log_screen.dart:204`, `home_screen.dart:499`, `onboarding/experience_level_screen.dart:319`, `onboarding/fish_select_screen.dart:466,558`, `onboarding/micro_lesson_screen.dart:314`, `smart_screen.dart:378`, `tank_detail_screen.dart:611,903`. Many of these are tappable cards, selection tiles, and action buttons — critical for screen reader users. FIX: Wrap each with `Semantics(label: '...', button: true, onTap: ...)` or replace with `InkWell` which has built-in accessibility.

- [ ] **[A11Y] `SizedBox.shrink()` missing `const`** — `livestock_screen.dart:146,211,267,326`, `photo_gallery_screen.dart:78,131,138`, `app_states.dart:334`. These are non-`const` where they could be. Minor but counts as missing const. FIX: `const SizedBox.shrink()`.

### Performance

- [ ] **[PERF] 321 `setState` calls across screens** — Many are fine but `livestock_screen.dart` (14+ calls), `add_log_screen.dart`, `lesson_screen.dart` (15+ calls) have setState calls that likely trigger large subtree rebuilds. FIX: Audit each setState in large screens; use `ValueNotifier`/`AnimatedBuilder` for animation state, keep `setState` for minimal local UI state.

- [ ] **[PERF] `species_database.dart` is 3,271 lines — a static data file loaded eagerly** — Already partially addressed with `lesson_content_lazy.dart` for lessons. FIX: Verify species data is lazy-loaded (only parsed when needed), not eagerly instantiated at startup.

### Code Quality

- [ ] **[CODE] `models/spaced_repetition.dart:337` has an orphaned `// REVIEW ATTEMPT` comment** — Looks like debugging residue. FIX: Remove.

- [ ] **[CODE] `lib/screens/debug_menu_screen.dart` accessible in production?** — This screen contains tank reset, gem manipulation, and streak override. Confirm it's only accessible in debug builds. `lib/main.dart` or router should gate with `kDebugMode`. FIX: Audit that `DebugMenuScreen` is unreachable in release builds.

- [ ] **[CODE] `PaywallStubScreen` name is misleading for v1** — `lib/screens/onboarding/paywall_stub_screen.dart` — The file/class is named "Paywall Stub" but the implementation is a "Feature Summary" with no paywall. The misleading name could confuse future developers. FIX: Rename to `FeatureSummaryScreen`.

---

## Low (future improvement)

- [ ] **[LOW] `google_fonts` import in `paywall_stub_screen.dart`** — `lib/screens/onboarding/paywall_stub_screen.dart:3` — If the rest of the app uses theme-level typography from `app_theme.dart`, this direct `GoogleFonts` import is inconsistent. FIX: Use `context.titleLarge` etc. from the theme.

- [ ] **[LOW] `lib/widgets/hobby_items.dart` is 1,019 lines** — Mix of water level indicators, fish value displays, stocking indicators, and custom painters. FIX: Split into `WaterLevelIndicator`, `FishValueDisplay` etc.

- [ ] **[LOW] `lib/services/notification_service.dart` is 1,054 lines** — Handles scheduling, payload parsing, channel creation, and permission requests. FIX: Split into `NotificationChannelService` and `NotificationScheduler` (partial split already exists with `notification_scheduler.dart` — complete the migration).

- [ ] **[LOW] `lib/screens/learn_screen.dart` is 1,317 lines** — Course list, search, filter, story cards, placement test flow, and achievement checks all inline. FIX: Extract `CourseCard`, `StoryCard`, `PlacementTestLauncher` into sub-widgets.

- [ ] **[LOW] `lib/screens/charts_screen.dart` is 1,079 lines** — Multiple chart types, date range pickers, and parameter selectors inline. FIX: Extract each chart type into its own widget.

- [ ] **[LOW] `lib/screens/spaced_repetition_practice_screen.dart` is 1,295 lines** — FIX: Extract card rendering, progress bar, and result modal into sub-widgets.

- [ ] **[LOW] `lib/screens/reminders_screen.dart` is 853 lines with inline dialog builders** — FIX: Extract reminder creation/edit dialog.

- [ ] **[LOW] `lib/screens/backup_restore_screen.dart` is 911 lines with progress tracking inline** — FIX: Extract backup/restore progress widget.

- [ ] **[LOW] Missing `prefer_const_constructors` lint rule in `analysis_options.yaml`** — The rule isn't enabled, so missing `const` constructors go undetected. FIX: Add `prefer_const_constructors: true` and `prefer_const_literals_to_create_immutables: true` to `analysis_options.yaml` and fix resulting warnings.

- [ ] **[LOW] Inconsistent use of `context.mounted` vs `mounted`** — Some async handlers check `context.mounted` (correct), others check `mounted` (only valid in `State<>`). FIX: Audit all async context usages; use `context.mounted` as the standard.

- [ ] **[LOW] `lib/models/analytics.dart` — verify no PII in analytics events** — With Supabase and Firebase Analytics both wired up, confirm event parameters don't accidentally include tank names, species names, or user-created content that could constitute PII.

- [ ] **[LOW] Integration tests thin** — Only `smoke_test.dart` and `smoke_test_v2.dart` exist. No integration tests for the core learning loop (onboarding → first lesson → quiz → XP award), tank creation, or log entry flow. FIX: Add integration tests for the 3 core flows.

---

## Stats

- **Total findings:** 47
- **Critical:** 5
- **High:** 18
- **Medium:** 12
- **Low:** 12
- **Files scanned:** 329 (all `.dart` files in `lib/`)
- **Screens audited:** ~60 screens + ~70 widget files
- **Test coverage:** ~8/60 screens have any test coverage (~13%)
- **Largest files:** `species_database.dart` (3,271 lines), `room_scene.dart` (1,862), `app_theme.dart` (1,843), `settings_screen.dart` (1,631), `lesson_screen.dart` (1,598), `livestock_screen.dart` (1,580)
- **Raw SnackBar calls not using DanioSnackBar:** 48
- **Raw Button calls not using AppButton:** 117 (102 TextButton + 15 ElevatedButton)
- **Raw EdgeInsets literals in screens:** 275
- **GestureDetectors without Semantics:** 72
- **Screens with zero tests:** ~52/60

---

## Top 10 Findings (priority order)

1. **[CRITICAL] AI proxy key is client-side** — Security risk before any public release
2. **[CRITICAL] `lesson_screen.dart` 1,598-line god class** — Untestable, unmaintainable core feature
3. **[CRITICAL] `livestock_screen.dart` 1,580-line god class** — Core feature with 14+ setState calls
4. **[CRITICAL] `room_scene.dart` has 3 dead classes suppressed with `ignore` comments** — Dead code deliberately kept
5. **[HIGH] 48 raw SnackBar calls ignoring DanioSnackBar** — Inconsistent UX, DanioSnackBar built but abandoned
6. **[HIGH] 117 raw button calls ignoring AppButton** — AppButton exists for this exact reason
7. **[HIGH] 52/60 screens have zero tests** — No safety net for the core app
8. **[HIGH] 32 raw `showModalBottomSheet` calls** — Inconsistent bottom sheet styling
9. **[HIGH] 72 GestureDetectors without Semantics** — Accessibility failure for screen reader users
10. **[HIGH] 55 files mix `package:danio/` absolute imports with relative imports** — Inconsistent, confusing codebase

---

_Argus sign-off: This codebase is not in a state I'd call shippable for a public v1. The security concern (item 1) is a hard blocker. The god classes (items 2-4) make the core learning loop impossible to test or maintain. The test coverage gap (item 7) means we're flying blind. Fix the Criticals, address the top 3 Highs, then reassess._
