# Danio Aquarium App — Accessibility, UX & Security Audit

**Auditor:** Argus  
**Branch:** `openclaw/stage-system`  
**Date:** 2026-03-19  
**Files scanned:** 330 Dart files in `lib/`

---

## Part 1: Accessibility (A11y)

### 1.1 Semantics

### [AX-001] 115 `Navigator.pop()` calls — only 1 uses `maybePop()`
- **Severity:** P1
- **File:** Multiple (115 occurrences across `lib/screens/`, `lib/widgets/`)
- **Description:** 115 instances of `Navigator.pop()` vs only 1 `Navigator.maybePop()`. If the user reaches the app's root navigator and triggers a `pop()`, it can crash the app or produce unexpected behaviour on deep-link entry. Examples: `tasks_screen.dart:440`, `settings_screen.dart:867`, `shop_street_screen.dart:195`, `tank_settings_screen.dart:381`.
- **Suggested Fix:** Replace all `Navigator.pop()` with `Navigator.maybePop()` or guard with `Navigator.canPop(context)` before calling `pop()`.

### [AX-002] GestureDetector/InkWell without Semantics wrapping in many screens
- **Severity:** P1
- **File:** Multiple — ~65 GestureDetector and ~35 InkWell occurrences
- **Description:** Many `GestureDetector` and `InkWell` widgets lack `Semantics` wrapping or `semanticLabel`. Positive examples exist (e.g., `create_tank_screen.dart`, `settings_hub_screen.dart`, `learn_screen.dart` all use Semantics extensively), but screens like `workshop_screen.dart:336`, `dosing_calculator_screen.dart:48`, `co2_calculator_screen.dart:95`, `account_screen.dart:41`, `cost_tracker_screen.dart:119`, `add_log_screen.dart:203` use bare `GestureDetector` without any semantic annotation. Screen readers will announce nothing when users tap these.
- **Suggested Fix:** Wrap every interactive `GestureDetector`/`InkWell` in `Semantics(button: true, label: '...')` or pass `tooltip` to `InkWell`.

### [AX-003] ~60+ IconButtons without semantic labels
- **Severity:** P1
- **File:** Multiple — see list in scan data
- **Description:** `IconButton` widgets across many screens lack `tooltip` or `semanticLabel` parameters. Notable examples: `tasks_screen.dart:521`, `journal_screen.dart:26`, `create_tank_screen.dart:94`, `charts_screen.dart:58`, `analytics_screen.dart:66`, `search_screen.dart:55`, `logs_screen.dart:42`, `tank_detail_screen.dart:481,492,503,514`. Screen readers will only say "button" with no description. Positive examples: `inventory_screen.dart:109` correctly uses `semanticLabel: 'Consumables'`.
- **Suggested Fix:** Add `tooltip: 'Descriptive label'` to all `IconButton` widgets.

### [AX-004] Image widgets without semantic labels
- **Severity:** P1
- **File:** `add_log_screen.dart:1316`, `about_screen.dart:37`, `welcome_screen.dart:129`, `fish_select_screen.dart:418`, `livestock_preview.dart:81`, `room_scene.dart:89,374`
- **Description:** `Image.file()` and `Image.asset()` used without `semanticLabel`. Screen readers will announce the file path or nothing. The app has a good `OptimizedImage` widget (with `excludeFromSemantics` pattern), but not all screens use it.
- **Suggested Fix:** Use `OptimizedImage` widget everywhere, or add `semanticLabel` to raw `Image` widgets. Decorative images should use `ExcludeSemantics`.

### [AX-005] FloatingActionButton without semantic label
- **Severity:** P2
- **File:** `tasks_screen.dart:140`, `equipment_screen.dart:226`, `logs_screen.dart:158`
- **Description:** Several `FloatingActionButton` usages only provide an `Icon` as `child` without `tooltip` or `heroTag`. While Material's FAB has a default label from child text, icon-only FABs are invisible to screen readers.
- **Suggested Fix:** Add `tooltip: 'Add task'` (or equivalent) to all icon-only FABs. Extended FABs (with text child) are fine.

### [AX-006] Icon widgets used as buttons without labels
- **Severity:** P2
- **File:** Various (e.g., `tutorial_overlay.dart:118`, `account_screen.dart:41`)
- **Description:** Icons wrapped in `GestureDetector` that act as buttons but have no semantic annotation.
- **Suggested Fix:** Wrap in `Semantics(button: true, label: 'Close tooltip')` or similar.

---

### 1.2 Touch Targets

### [AX-007] Small tap targets on speed dial FAB items
- **Severity:** P2
- **File:** `speed_dial_fab.dart:77,223,289`
- **Description:** Speed dial child items are wrapped in `GestureDetector` without explicit minimum size constraints. Depending on the icon/padding used, these may be < 48x48dp.
- **Suggested Fix:** Wrap in `ConstrainedBox(constraints: BoxConstraints(minWidth: 48, minHeight: 48))`.

### [AX-008] No minimum size enforcement on core interactive widgets
- **Severity:** P2
- **File:** `app_button.dart`, `app_chip.dart`
- **Description:** `AppButton` and `AppChip` don't enforce a minimum tap target of 48x48dp in their layout constraints. Custom usage may produce smaller-than-required touch targets.
- **Suggested Fix:** Add `constraints: BoxConstraints(minWidth: 48, minHeight: 48)` in the widget's build method, or document that callers must ensure this.

---

### 1.3 Color & Contrast

### [AX-009] Extensive hardcoded colors throughout the codebase
- **Severity:** P2
- **File:** Multiple — ~80+ instances of `Colors.white`, `Colors.black`, `Colors.transparent`, `Color(0x...)`
- **Description:** `room_scene.dart` alone has 40+ hardcoded `Color(0x...)` values. `workshop_screen.dart` defines its own color palette with 15+ hardcoded constants. `achievement_unlocked_dialog.dart` uses `Colors.white` 7 times. These bypass the theme system and won't adapt to dark/light theme changes or future theme overhauls.
- **Suggested Fix:** Migrate all screen-level hardcoded colors to `AppColors` or `DanioColors`. Room scene custom colors should be centralized into a `RoomColors` token class.

### [AX-010] `Colors.transparent` used as backgrounds
- **Severity:** P3
- **File:** `workshop_screen.dart:104`, `wishlist_screen.dart:111,127,184`, `achievements_screen.dart:520`, `animated_flame.dart:245`, `xp_progress_bar.dart:285,287,358`, `water_change_celebration.dart:110,150`
- **Description:** `Colors.transparent` backgrounds mean content is rendered over whatever is below, which can reduce contrast unpredictably. Not all of these are problematic (some are intentional overlays), but several (e.g., `workshop_screen.dart:104` Scaffold background) could cause readability issues.
- **Suggested Fix:** Review each usage; where content needs guaranteed contrast, use a semi-transparent themed color instead of pure transparent.

### [AX-011] Color-only status indicators
- **Severity:** P2
- **File:** `achievement_unlocked_dialog.dart:343-351` (Colors.red/green/amber for tier), `tank_health_card.dart` (if present)
- **Description:** Achievement tiers use color alone (red, green, amber) to indicate status without text fallback. Color-blind users cannot distinguish these.
- **Suggested Fix:** Add text labels, icons, or patterns alongside color indicators.

---

### 1.4 Screen Reader

### [AX-012] Good live region coverage — but gaps exist
- **Severity:** P2
- **File:** Various screens
- **Description:** Live regions are used in 16 places (hearts, sync indicator, lesson scores, streaks, learn progress, offline indicator, smart screen). This is good. However, dynamic content in `home_screen.dart` (daily goals, streak counts), `tasks_screen.dart` (task completion status), and `gem_shop_screen.dart` (gem count changes) lacks `liveRegion: true`.
- **Suggested Fix:** Add `Semantics(liveRegion: true)` to dynamic counters and status indicators on the home screen, tasks screen, and gem shop.

### [AX-013] Dialogs lack explicit focus management
- **Severity:** P3
- **File:** Multiple `showDialog`/`showModalBottomSheet` calls (30+)
- **Description:** Flutter's `showDialog` handles basic focus trapping, but several bottom sheets (`room_navigation.dart:138`, `equipment_screen.dart:235,248`, `cost_tracker_screen.dart:51`, `wishlist_screen.dart:108,124,182`) open without setting `isScrollControlled` or managing initial focus. Focus may land on the first tappable element rather than the dialog title.
- **Suggested Fix:** Set `isScrollControlled: true` on bottom sheets with variable content height. Use `FocusScopeNode` to manage initial focus where needed.

---

### 1.5 Reduced Motion

### [AX-014] 100+ AnimationControllers — most don't check reduced motion
- **Severity:** P1
- **File:** Multiple — see full list in scan data
- **Description:** 100+ `AnimationController` instances found across the codebase. Only ~15 files check `MediaQuery.of(context).disableAnimations` or `reducedMotionProvider`. Notable missing checks: `level_up_dialog.dart`, `level_up_overlay.dart`, `streak_milestone_celebration.dart`, `hearts_overlay.dart`, `tutorial_overlay.dart`, `first_visit_tooltip.dart`, `all onboarding screens` (welcome, fish_select, experience_level, tank_status, warm_entry, micro_lesson, xp_celebration, aha_moment, push_permission, paywall_stub), `xp_award_animation.dart` (partially checks), `confetti_overlay.dart`, `animated_flame.dart`, `room_scene.dart`.
- **Suggested Fix:** Create a shared `ReducedMotionAnimationBuilder` or hook that all animation controllers check. Priority: onboarding screens (first impression) and celebration overlays (frequent triggers).

---

## Part 2: UX Consistency

### 2.1 Theme & Colors

### [AX-015] `workshop_screen.dart` has its own parallel color system
- **Severity:** P2
- **File:** `workshop_screen.dart:27-42`
- **Description:** Defines 15 hardcoded color constants (`_WorkshopColors`) with light/dark variants, completely bypassing `AppColors`/`DanioColors`. Also reads SharedPreferences directly (`workshop_screen.dart:69-72`) for visited state instead of using the provider system.
- **Suggested Fix:** Move workshop colors into the theme system. Use a provider for visited state.

### [AX-016] Hardcoded text styles in several screens
- **Severity:** P3
- **File:** `charts_screen.dart:1`, `difficulty_settings_screen.dart:3`, `placement_result_screen.dart:1`, `terms_of_service_screen.dart:1`, `gem_shop_screen.dart:1`, `quick_start_guide_screen.dart:1`, `inventory_screen.dart:1`
- **Description:** 7 screen files contain hardcoded `TextStyle(fontWeight: ...)` instead of using `AppTypography` tokens. These files have 1-3 instances each.
- **Suggested Fix:** Replace with `AppTypography` equivalents.

### [AX-017] Hardcoded dimensions throughout
- **Severity:** P3
- **File:** Pervasive — most screen files use literal `EdgeInsets` and `SizedBox` values
- **Description:** Most screens use literal `EdgeInsets.all(16)`, `SizedBox(height: 8)` etc. instead of `AppSpacing` tokens. This is a systemic consistency issue.
- **Suggested Fix:** Incremental migration to `AppSpacing` tokens. Prioritize new code and frequently-edited screens.

---

### 2.2 Responsive Design

### [AX-018] No responsive breakpoints detected in screen layouts
- **Severity:** P2
- **File:** Multiple screens
- **Description:** No evidence of `LayoutBuilder`, `MediaQuery` width checks, or `Breakpoint` usage for responsive layouts. All screens use fixed layouts. On tablets (600dp+), content will stretch uncomfortably. On Z Fold cover screen (280dp), content will overflow.
- **Suggested Fix:** Add a `ResponsiveBuilder` utility that constrains max-width for tablet and handles narrow screens. At minimum, wrap main content in `ConstrainedBox(maxWidth: 600)` for phone-first screens.

---

### 2.3 Edge Cases

### [AX-019] Good empty state coverage — some gaps
- **Severity:** P2
- **File:** Various
- **Description:** Many screens have empty states (`EmptyState.withMascot` used in `livestock_screen.dart:108`, `gem_shop_screen.dart:430`, `journal_screen.dart:50`, `charts_screen.dart:82`, `equipment_screen.dart:135`, `wishlist_screen.dart:67`, `inventory_screen.dart:156`). However, `logs_screen.dart`, `search_screen.dart`, `leaderboard_screen.dart`, `friends_screen.dart`, `plant_browser_screen.dart` lack visible empty state handling.
- **Suggested Fix:** Add empty state widgets to remaining list screens.

### [AX-020] Error handling varies by screen
- **Severity:** P2
- **File:** Multiple providers and screens
- **Description:** Some providers (inventory: 7 catch blocks, home_screen: 8, lesson_provider: 2) have error handling. Others appear to let errors propagate silently. The `error_boundary.dart` widget exists but isn't wrapping all async screens.
- **Suggested Fix:** Ensure all provider-level async operations are wrapped in try/catch with user-visible error feedback. Wrap async screen content in `ErrorBoundary`.

---

### 2.4 Navigation

### [AX-021] Back-button handling via WillPopScope/PopScope not auditable
- **Severity:** P2
- **File:** `create_tank_screen.dart:63`, `add_log_screen.dart:180`
- **Description:** Only 2 screens have custom back-button handling (unsaved changes dialog). Other screens with forms (`tank_settings_screen.dart`, `account_screen.dart`) will silently discard changes on back press.
- **Suggested Fix:** Add `PopScope` with unsaved changes detection to all form-based screens.

### [AX-022] No deep link handling found
- **Severity:** P3
- **File:** N/A
- **Description:** No deep link handler, `uni_links`, `AppLinks`, or `FirebaseDynamicLinks` references found. This means the app cannot be navigated to directly from external sources.
- **Suggested Fix:** If deep links aren't needed for V1, this is acceptable. Add to roadmap for V2.

---

## Part 3: Security & Data Integrity

### 3.1 Input Validation

### [AX-023] Several TextField/TextFormField inputs lack inputFormatters
- **Severity:** P1
- **File:** `symptom_triage_screen.dart:277,296,307,322,333,345` (6 TextField instances), `wishlist_screen.dart:422,434,492` (3 TextField instances)
- **Description:** Text fields in symptom triage and wishlist screens accept any input without length limits or character restrictions. Very long strings could cause layout overflow or storage issues. No `inputFormatters` on these fields.
- **Suggested Fix:** Add `LengthLimitingTextInputFormatter(500)` at minimum. Consider character restrictions where appropriate.

### [AX-024] Numeric inputs missing upper-bound validation
- **Severity:** P2
- **File:** `water_change_calculator_screen.dart:158-214`, `unit_converter_screen.dart:78-332`, `tank_volume_calculator_screen.dart:411`, `co2_calculator_screen.dart:149-150`, `cost_tracker_screen.dart:629,639`
- **Description:** Numeric fields use `FilteringTextInputFormatter.digitsOnly` or `allow(r'[\d.]')` but don't validate upper bounds. Users can enter extremely large numbers (e.g., 999999999 gallons) that produce nonsensical results or overflow.
- **Suggested Fix:** Add `validator` callbacks that check for reasonable ranges (e.g., tank size 0.5–10000 litres).

### [AX-025] Negative values allowed in temperature converter
- **Severity:** P3
- **File:** `unit_converter_screen.dart:155-156`
- **Description:** Temperature converter allows negative values (`allow(r'[\d.\-]')`) which is actually correct for temperatures, but the regex doesn't enforce proper number formatting (e.g., "1.2.3.4" or "---5" would be accepted).
- **Suggested Fix:** Use a more restrictive regex: `RegExp(r'^-?\d*\.?\d+$')`.

---

### 3.2 Data Persistence

### [AX-026] SharedPreferences stores user data unencrypted
- **Severity:** P2
- **File:** `main.dart:114-115`, `workshop_screen.dart:69-72`, `wishlist_provider.dart:65-255`
- **Description:** GDPR consent flag, workshop visited state, wishlist data, and budget data are stored in `SharedPreferences` (unencrypted XML on Android). This is acceptable for non-sensitive data (visited flags) but wishlist data containing personal preferences could be considered sensitive under GDPR.
- **Suggested Fix:** Non-sensitive flags (consent, visited) are fine in SharedPreferences. Consider `flutter_secure_storage` for wishlist/budget data if it contains PII.

### [AX-027] No schema versioning or migration logic in models
- **Severity:** P2
- **File:** `lib/models/` (all model files)
- **Description:** No `schemaVersion`, `fromJson`/`toJson` version checks, or migration logic found in any model. If a model's fields change between app versions, existing user data could fail to deserialize or produce corrupted state.
- **Suggested Fix:** Add `int version` to models stored in SharedPreferences. Implement migration in a `MigrationService` that runs on app startup.

### [AX-028] JSON serialization round-trip safety
- **Severity:** P2
- **File:** `wishlist_provider.dart:80-82`, `wishlist_provider.dart:177-178`
- **Description:** Wishlist data is serialized to JSON via `jsonEncode` and deserialized via `jsonDecode` with type casting. No try/catch around deserialization — corrupted data would crash the app.
- **Suggested Fix:** Wrap `jsonDecode` calls in try/catch with fallback to empty/default data.

---

### 3.3 Deep Link Security

### [AX-029] No deep link surface — low risk
- **Severity:** P3
- **File:** N/A
- **Description:** No deep link handling found in the codebase. This means no deep link attack surface exists, which is good for security. However, it also means no deferred deep link attribution for marketing.
- **Suggested Fix:** When adding deep links in future, validate URLs against an allowlist and use `Uri.resolve()` to prevent open redirects.

---

## Summary Table

| Category | P0 | P1 | P2 | P3 | Total |
|----------|----|----|----|----|----|
| **A11y — Semantics** | 0 | 4 | 2 | 0 | 6 |
| **A11y — Touch Targets** | 0 | 0 | 2 | 0 | 2 |
| **A11y — Color/Contrast** | 0 | 0 | 2 | 1 | 3 |
| **A11y — Screen Reader** | 0 | 0 | 1 | 1 | 2 |
| **A11y — Reduced Motion** | 0 | 1 | 0 | 0 | 1 |
| **UX — Theme/Consistency** | 0 | 0 | 1 | 2 | 3 |
| **UX — Responsive** | 0 | 0 | 1 | 0 | 1 |
| **UX — Edge Cases** | 0 | 0 | 2 | 0 | 2 |
| **UX — Navigation** | 0 | 0 | 1 | 1 | 2 |
| **Security — Input Validation** | 0 | 1 | 1 | 1 | 3 |
| **Security — Data Persistence** | 0 | 0 | 3 | 0 | 3 |
| **Security — Deep Links** | 0 | 0 | 0 | 1 | 1 |
| **TOTAL** | **0** | **6** | **16** | **7** | **29** |

---

## Top 10 Most Impactful Fixes

| # | Finding | Impact |
|---|---------|--------|
| 1 | **AX-001** — Replace `Navigator.pop()` with `maybePop()` | Prevents crashes when user pops below root. 115 instances = systematic fix needed. |
| 2 | **AX-014** — Reduced motion for 100+ AnimationControllers | Major a11y requirement. Affects users with vestibular disorders. Onboarding screens are the first impression. |
| 3 | **AX-002** — Semantics on ~65 GestureDetector/35 InkWell | Core WCAG 2.1 AA requirement. Screen readers can't use the app without this. |
| 4 | **AX-003** — ~60+ IconButtons without labels | Quick win — add `tooltip` parameter. Same effort pattern for all. |
| 5 | **AX-004** — Image widgets without semantic labels | Quick win — 6 files. Use `OptimizedImage` or add labels. |
| 6 | **AX-023** — TextField inputs without formatters | Security/data integrity. Very long strings could overflow layouts or storage. |
| 7 | **AX-012** — Live regions on dynamic counters | Home screen, tasks, and gem shop counters don't announce changes to screen readers. |
| 8 | **AX-009** — Hardcoded colors → theme tokens | Systematic. Room scene (40+) and workshop (15+) are the biggest offenders. |
| 9 | **AX-028** — JSON deserialization without error handling | One corrupted SharedPreferences entry could crash on app launch. |
| 10 | **AX-021** — Unsaved changes on back press | Users lose form data silently in tank_settings, account, and other form screens. |

---

## Positive Observations

1. **Excellent Semantics usage in key screens** — `create_tank_screen.dart`, `settings_hub_screen.dart`, `learn_screen.dart`, `lesson_screen.dart`, and all onboarding screens have thorough Semantics annotations. This is well above average for Flutter apps.

2. **Live regions in 16 places** — Hearts, sync status, lesson scores, streaks, and offline indicator all use `liveRegion: true`. Good coverage of critical dynamic content.

3. **Reduced motion infrastructure exists** — `reduced_motion_provider.dart` provides a proper `ReducedMotionState` with `disableDecorativeAnimations` and `curve()` helper. Several widgets (shimmer, skeleton, water ripple, ambient effects) respect it. The foundation is solid.

4. **`A11ySemantics` utility class** — `accessibility_utils.dart` provides reusable a11y helpers (`ExcludeSemantics`, `MergeSemantics`, labeled semantics). This shows intentional a11y investment.

5. **Good empty state pattern** — `EmptyState.withMascot` is consistently used across list screens. `CompactEmptyState` exists for space-constrained areas.

6. **`OptimizedImage` with proper semantics** — Custom image widget with `semanticLabel` and `excludeFromSemantics` parameters is well-designed and used in many places.

7. **AppIconButton enforces semantic labels** — `app_button.dart:400` has an assertion: `'AppIconButton requires a semanticsLabel for accessibility'`. This is excellent preventive design.

8. **No deep link attack surface** — While limiting for marketing, this is a security positive for V1.
