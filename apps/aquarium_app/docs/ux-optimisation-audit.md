# UX / Design Optimisation Audit
**Branch:** `openclaw/stage-system`  
**Auditor:** Apollo (Design Agent)  
**Date:** 2026-03-29  
**Scope:** `lib/screens/`, `lib/widgets/`, key theme files

---

## Overall UX Quality Score: **7.5 / 10**

The app has a genuinely impressive design system — a proper token-based colour palette, a full spacing/radius scale, unified button and card components, reduced-motion support baked in, and meaningful micro-interactions throughout. The glassmorphism stage panel is a standout concept. Where points are lost: a clutch of hardcoded colours in the "learn" header bypass the token system, several tap targets in the onboarding flow sit below the 48dp floor, a handful of font sizes go below the legible mobile minimum, and the illustrated headers (`practice_header.png`, `learn_header.png`) are still flagged as needing regeneration in the art bible — a visible gap against the polished character assets.

---

## P1 — Ship Blockers

### P1-1 · Illustrated headers mismatch the art style
**Files:** `assets/images/illustrations/practice_header.png`, `learn_header.png`  
**What's wrong:** Both headers are explicitly flagged in `docs/art-bible.md` as `❌ REGEN NEEDED — flat cel style, thin outlines, different character proportions`. Users see these headers every time they open Learn and Practice — they create a visible split-personality between the polished canonical fish sprites and the header illustrations.  
**Suggested fix:** Regenerate both headers using the art bible's mandatory generation prompt. Use the style that matches `neon_tetra.png` / `guppy.png` — bold charcoal outlines, gradient shading, circular specular highlights, large expressive eyes.

---

### P1-2 · "Quick start with defaults" is a text-only tap target (~18px tall)
**File:** `lib/screens/onboarding/welcome_screen.dart` lines 247–272  
**What's wrong:** The secondary CTA on the Welcome screen is a bare `GestureDetector` wrapping a `Text` widget with `fontSize: 14`. A single line of 14sp text renders at roughly 17–18dp touch height — 30dp short of Material's 48dp minimum. Users with motor impairments, or anyone tapping on a moving device, will frequently miss it.  
**Suggested fix:** Replace with `TextButton` (which enforces minimum tap target via its theme) or wrap the `GestureDetector` in a `SizedBox(height: 48)` with `Align(alignment: Alignment.center)`.

```dart
// Before
GestureDetector(
  onTap: widget.onLogin?.call,
  child: Text('Quick start with defaults', ...),
)

// After
TextButton(
  onPressed: widget.onLogin,
  style: TextButton.styleFrom(
    minimumSize: const Size.fromHeight(48),
  ),
  child: Text('Quick start with defaults', ...),
)
```

---

### P1-3 · Learn header gradient colours are hardcoded, bypassing the token system
**File:** `lib/screens/learn/learn_screen.dart` lines 299–301  
**What's wrong:**
```dart
colors: [
  Color(0xFF5B8FA8), // Soft ocean blue
  Color(0xFF3D6B7A), // Deeper teal
  Color(0xFF2D5566), // Submarine depth
],
```
These three hex values are not mapped to any `DanioColors` or `AppColors` token. If the app's primary teal palette shifts, the Learn header won't update. This is the most prominent screen in the app.  
**Suggested fix:** Add three named tokens to `DanioColors` (e.g. `learnHeaderTop`, `learnHeaderMid`, `learnHeaderBottom`) and reference them here.

---

### P1-4 · XP/streak badge on Learn header: 12sp text with semi-transparent background
**File:** `lib/screens/learn/learn_screen.dart` lines 333–344, 358–369  
**What's wrong:**
```dart
style: const TextStyle(
  color: Colors.white,
  fontSize: 12,   // ← WCAG AA requires ≥14sp for bold, ≥18sp for regular
  fontWeight: FontWeight.w600,
),
```
The badge sits on a `Colors.black.withValues(alpha: 0.35)` overlay over a medium-toned gradient. At 12sp, this is below Flutter's minimum legible size for most Android densities and fails WCAG AA for smaller bold text at that contrast level.  
**Suggested fix:** Increase to `fontSize: 13` minimum (14 preferred). The badge container is already compact with `horizontal: 10, vertical: 4` padding — bumping to 13sp won't overflow.

---

## P2 — Should Fix

### P2-1 · BottomSheetPanel uses `Colors.white` (12 instances) instead of tokens
**File:** `lib/widgets/stage/bottom_sheet_panel.dart`  
**What's wrong:** Twelve direct references to `Colors.white` and `Colors.white.withValues(alpha: …)` in the sheet's glassmorphism implementation. While these are intentional for the frosted-glass effect, they're not theme-adaptive and won't invert correctly if a custom dark-glass theme is ever applied. Key offenders:
- Line 122: `color: Colors.white.withValues(alpha: 0.2)` (border)
- Line 135: `color: Colors.white.withValues(alpha: 0.28)` (backdrop fill)
- Lines 246–247: Tab bar `labelColor: Colors.white` / `unselectedLabelColor`
- Lines 473, 549, 551, 587, 590, 608: Tool cards

**Suggested fix:** Introduce `AppColors.glassWhite`, `AppColors.glassWhiteDim`, etc. in `app_colors.dart` (matching the current values for now) and reference those tokens throughout the sheet.

---

### P2-2 · `placeholder.webp` is visually incongruent
**File:** `assets/placeholder.webp` (flagged in `docs/art-bible.md`)  
**What's wrong:** The art bible flags this as `❌ REVIEW — amber watercolor wash, not matching illustrated style`. This placeholder is shown whenever a species image fails to load — in the Livestock screen, Species Browser, and fish select grids. A mismatched placeholder cheapens the overall polish.  
**Suggested fix:** Regenerate as a simple silhouette of a fish in the canonical charcoal outline style, or use the existing `Icons.set_meal_rounded` icon treatment (as used in `EmptyRoomScene`) consistently.

---

### P2-3 · Fish select grid tiles use `fontSize: 13` for common name and `fontSize: 12` label
**File:** `lib/screens/onboarding/fish_select_screen.dart` lines 493–515  
**What's wrong:**  
- Common name: `fontSize: 13` (borderline — acceptable at bold weight but cramped in a 3-column grid)
- "Popular starter fish" label: `fontSize: 12` at `textSecondary` colour — likely to wash out at low-brightness displays
- Scientific name: even smaller (truncated to 1 line at a grid tile ~109px wide)

At 3 columns in a standard-width phone, the tiles are ~109dp wide. A 13sp bold name with `maxLines: 1` will frequently truncate mid-species. This is bad on an onboarding step where the user is making their *first* meaningful choice.  
**Suggested fix:** Reduce to 2 columns in the popular grid, or increase the grid's `childAspectRatio` to allow more height. Move to `AppTypography.labelMedium` / `AppTypography.bodySmall` for type consistency.

---

### P2-4 · Aha Moment screen has 6 hardcoded `fontSize` values outside the type scale
**File:** `lib/screens/onboarding/aha_moment_screen.dart` lines 272, 284, 330, 343, 387, 399, 461, 511, 520, 529  
**What's wrong:** The screen mixes `fontSize: 12`, `13`, `15`, `16`, `17`, `22`, `24`, `28` ad hoc via `GoogleFonts.nunito(fontSize: …)` rather than `AppTypography.*` tokens. There's no single AppTypography token for `fontSize: 12` or `fontSize: 13` — these are below `AppTypography.bodySmall`.  
**Suggested fix:** Map all sizes to nearest `AppTypography` equivalent. Use `AppTypography.labelSmall` for the stat label (12sp equivalent), `AppTypography.bodyMedium` for descriptive text, `AppTypography.titleMedium` for the stat value.

---

### P2-5 · Lesson card has hardcoded `bottomPadding: 160` magic number
**File:** `lib/screens/lesson/lesson_card_widget.dart` line 33  
**What's wrong:**
```dart
padding: EdgeInsets.fromLTRB(
  AppSpacing.lg2, AppSpacing.lg2, AppSpacing.lg2,
  160,  // ← magic number, not a token
),
```
160dp is used as a fixed buffer so the last content item isn't hidden behind the bottom CTA button. This will be too large on some phones (wasted scroll space) and potentially too small on others if the button renders taller.  
**Suggested fix:** Replace with a responsive measurement. Obtain the actual button height using `LayoutBuilder` or `MediaQuery.padding.bottom + kBottomNavigationBarHeight + AppSpacing.xxl`.

---

### P2-6 · Onboarding has no progress indicator
**File:** `lib/screens/onboarding_screen.dart` — 10-screen PageView  
**What's wrong:** The onboarding flow is 10 screens long but has no step dots, progress bar, or "Step X of Y" indicator. Users don't know how much further they need to go, which increases drop-off. This is a first-use experience failure — users may abandon before reaching the fish selection screen.  
**Suggested fix:** Add a minimal step indicator (e.g. the small dot row used in onboarding flows à la Duolingo) in the top-centre of each onboarding screen. Use `PageController.page` to drive dot highlighting.

---

### P2-7 · Empty room scene text is not anchored to safe area on notched phones
**File:** `lib/screens/home/widgets/empty_room_scene.dart`  
**What's wrong:** The `Positioned` elements (window at `top: 80`, empty stand at `bottom: 100`) use fixed offsets that don't account for the device's safe area insets. On iPhones with a Dynamic Island (top inset ~59dp) or tall gesture bars (bottom inset ~34dp), the window could overlap the status bar and the stand could be partially hidden.  
**Suggested fix:** Read `MediaQuery.of(context).padding` and add the appropriate inset to each `Positioned.top` / `Positioned.bottom` value.

---

### P2-8 · `Colors.white` in `streak_hearts_overlay.dart` and `welcome_banner.dart`
**Files:** `lib/screens/home/widgets/streak_hearts_overlay.dart` lines 126, 149, 225; `welcome_banner.dart` line 63  
**What's wrong:** Hard `Colors.white` references in home UI widgets. These won't adapt if the app gains a dark-mode home screen variant. `streak_hearts_overlay.dart` line 144 also has a hard `Color(0xD0FFA000)` amber.  
**Suggested fix:** `Colors.white` → `AppColors.onPrimary` or `AppColors.textOnDark`. The amber `0xD0FFA000` → `DanioColors.amberGold.withAlpha(208)`.

---

### P2-9 · `empty_room_scene.dart` has two raw hex colours
**File:** `lib/screens/home/widgets/empty_room_scene.dart` lines 42, 61  
**What's wrong:**
```dart
colors: [Color(0xFFE8D8C8), Color(0xFFF0E4D4)],  // line 42
colors: [DanioColors.studyGold, Color(0xFFC49664)],  // line 61
```
The window gradient uses two unlabelled warm creams, and the floor gradient mixes one token with one raw hex. These are decorative but still bypass the palette.  
**Suggested fix:** Add `DanioColors.windowLight`, `DanioColors.windowShadow`, `DanioColors.floorShadow` tokens or reuse existing cream/ivory tokens already in the palette.

---

### P2-10 · XP celebration screen has `Color(0xFFFFD54F)` with explanatory comment
**File:** `lib/screens/onboarding/xp_celebration_screen.dart` line 378  
**What's wrong:**
```dart
Color(0xFFFFD54F), // golden yellow — no exact token
```
The developer *knew* there was no token for this and left a comment. This yellow is used in the confetti particle effect.  
**Suggested fix:** Add `DanioColors.confettiGold` token, which is distinct from `DanioColors.amberGold` by intent.

---

### P2-11 · Bottom sheet panel: 4-tab count in code but TabController initialised correctly — verify smoke test
**File:** `lib/widgets/stage/bottom_sheet_panel.dart` line 60  
**What's wrong:** The `_BottomSheetPanelState.initState()` correctly creates `TabController(length: 4)` for the 4 tabs (Progress, Tanks, Today, Tools). However, the docstring at the top of the file was not updated when the 4th Tools tab was added — it still describes "three tabs: Progress | Tanks | Today". This is a documentation drift that can mislead maintainers.  
**Suggested fix:** Update the class-level docstring to reflect the 4-tab design.

---

## P3 — Nice to Have

### P3-1 · Learn header gradient colours don't match the app's primary teal
**File:** `lib/screens/learn/learn_screen.dart` lines 299–301  
**What's wrong:** The three hardcoded blues (`#5B8FA8`, `#3D6B7A`, `#2D5566`) are a slightly cooler, greyer teal than `AppColors.primary` / `DanioColors.tealWater`. While aesthetically fine, they create a subtle inconsistency between the Learn header and the rest of the teal-primary UI.  
**Suggested fix:** Tie to the primary teal family. Even if kept as separate named tokens, consider deriving them from `AppColors.primary` with HSL adjustments so future palette shifts propagate automatically.

---

### P3-2 · `_SheetToolCard` in the bottom sheet has no press animation
**File:** `lib/widgets/stage/bottom_sheet_panel.dart` lines 560–615  
**What's wrong:** The `_SheetToolCard` is a `GestureDetector` wrapping a plain `Container` with no scale/opacity feedback on tap. All other interactive cards in the app (GlassCard, PressableCard, AppCard) use a scale-down or opacity-fade on press. This tool card feels unresponsive by comparison.  
**Suggested fix:** Use `PressableCard` from `lib/widgets/core/pressable_card.dart` instead of a raw `GestureDetector`, or add a scale animation (0.97 on tap-down, 1.0 on tap-up) mirroring the `GlassCard` implementation.

---

### P3-3 · Onboarding "Quick start with defaults" label is vague
**File:** `lib/screens/onboarding/welcome_screen.dart` line 258  
**What's wrong:** "Quick start with defaults" is an engineering term. New users (the target audience for this screen) won't know what "defaults" means in context. Does it skip setup? Does it create a tank automatically?  
**Suggested fix:** Rename to something like "Skip setup, I'll explore first" or "Just browse for now →".

---

### P3-4 · Practice Hub header gradient is plain AppColors, no personality
**File:** `lib/screens/practice_hub_screen.dart` lines 51–57  
**What's wrong:** The Practice header uses a flat `AppColors.background → AppColors.surfaceVariant` gradient — essentially off-white to off-white. Combined with the flagged `practice_header.png` illustration, the Practice tab's header has the least visual personality of all main tabs.  
**Suggested fix:** Adopt a coral/amber gradient (matching the "Practice" energy) similar to how the Workshop uses `DanioColors.workshopBackground1/2`. Or replace with an illustrated header matching the Learn tab treatment once `practice_header.png` is regenerated.

---

### P3-5 · `SoftCard` box shadows use raw `Color(0x08000000)` / `Color(0x05000000)` instead of tokens
**File:** `lib/widgets/core/glass_card.dart` lines 337–358 (SoftCard shadow implementation)  
**What's wrong:**
```dart
BoxShadow(
  color: isDark ? AppColors.blackAlpha15 : const Color(0x08000000), // 0.03
  ...
),
BoxShadow(
  color: isDark ? AppColors.blackAlpha10 : const Color(0x05000000), // 0.02
  ...
),
```
Light mode shadows use raw `Color(0x08000000)` and `Color(0x05000000)` instead of tokens, while dark mode uses `AppColors.blackAlpha*`. `AppShadows` class already has `dreamySoft` which is nearly identical.  
**Suggested fix:** Replace inline shadows with `AppShadows.dreamySoft` or add `AppColors.blackAlpha03` / `AppColors.blackAlpha02` tokens.

---

### P3-6 · Analytics screen bar chart uses hardcoded `BorderRadius.vertical(top: Radius.circular(4))`
**File:** `lib/screens/analytics/analytics_screen.dart` line 647  
**What's wrong:**
```dart
borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
```
The `4dp` value is in the radius scale (`AppRadius.xs = 4`) but isn't referenced as `AppRadius.xs`.  
**Suggested fix:** `Radius.circular(AppRadius.xs)`.

---

### P3-7 · No "swipe up to explore" affordance on fresh home screen
**File:** `lib/screens/home/home_screen.dart` / `bottom_sheet_panel.dart`  
**What's wrong:** The bottom sheet panel shows a chevron hint (`_BouncingChevronHint`) on first launch — good. But new users who just completed onboarding land on the empty room scene, which has its own CTA overlaid. The two competing affordances (EmptyRoomScene CTA + bouncing sheet chevron) may cause confusion about what to tap first.  
**Suggested fix:** Delay the sheet chevron hint by 2 seconds so the EmptyRoomScene CTA is seen first. Or suppress the sheet chevron entirely on first launch and only show it after the first tank is created.

---

### P3-8 · `difficulty_settings_screen.dart` uses `size: 14` for icon in badge
**File:** `lib/screens/difficulty_settings_screen.dart` line 318  
**What's wrong:** `Icon(icon, size: 14, color: color)` is below `AppIconSizes.xs = 16`. An icon at 14dp becomes unrecognisable on non-retina screens.  
**Suggested fix:** Replace with `AppIconSizes.xs` (16dp).

---

### P3-9 · `equipment_screen.dart` uses `size: 14` for history icon
**File:** `lib/screens/equipment_screen.dart` line 541  
**What's wrong:** Same issue as P3-8.  
**Suggested fix:** `size: AppIconSizes.xs`.

---

### P3-10 · `acclimation_guide_screen.dart` uses `size: 12` for an icon
**File:** `lib/screens/acclimation_guide_screen.dart` line 289  
**What's wrong:** `size: 12` icon. Below any recognisable threshold on most screens.  
**Suggested fix:** Replace with `AppIconSizes.xs` (16dp).

---

### P3-11 · Quiz answer `maxLines: 4` with `TextOverflow.ellipsis` can silently truncate correct answers
**File:** `lib/widgets/quiz/quiz_answer_option.dart` line 177  
**What's wrong:** Long quiz answers (e.g. species scientific names + descriptions) are capped at 4 lines and ellipsed. A truncated correct answer that reads ambiguous creates a learning mistake rather than a knowledge test.  
**Suggested fix:** Change to `overflow: TextOverflow.visible` with no `maxLines` clamp, or implement a `ReadMore` expand if overflow is genuinely needed for layout reasons.

---

### P3-12 · `BottomSheetPanel` docstring still describes three tabs
**File:** `lib/widgets/stage/bottom_sheet_panel.dart` line 14  
**What's wrong:** The class-level comment reads:
> "Contains a horizontal TabBar with three tabs: Progress | Tanks | Today."

The implementation has 4 tabs: Progress | Tanks | Today | Tools.  
**Suggested fix:** Update to four tabs.

---

### P3-13 · `learn_screen.dart` and `lesson_screen.dart` root-level barrel files are silent duplicates
**Files:** `lib/screens/learn_screen.dart`, `lib/screens/lesson_screen.dart`  
**What's wrong:** These root-level files are pure `export` shims. They exist so old import paths don't break, but they add cognitive overhead when navigating the codebase. There's no deprecation comment pointing to the canonical location.  
**Suggested fix:** Add a `// @Deprecated: use screens/learn/learn_screen.dart directly` comment to each barrel, or migrate all imports to the canonical subpath and delete the shims.

---

## Summary Table

| ID | Severity | Area | Screen / File | One-liner |
|----|----------|------|---------------|-----------|
| P1-1 | 🔴 P1 | Visual consistency | `assets/illustrations/` | Illustrated headers must be regenerated to match art bible |
| P1-2 | 🔴 P1 | Interaction | `welcome_screen.dart:247` | "Quick start" text-only tap target ~18dp, fails 48dp floor |
| P1-3 | 🔴 P1 | Visual consistency | `learn_screen.dart:299` | Learn header gradient uses 3 raw hex colours, no tokens |
| P1-4 | 🔴 P1 | Typography | `learn_screen.dart:338` | 12sp badge text on semi-opaque background, fails WCAG AA |
| P2-1 | 🟡 P2 | Visual consistency | `bottom_sheet_panel.dart` | 12× `Colors.white` hardcoded, no theme tokens |
| P2-2 | 🟡 P2 | Visual consistency | `assets/placeholder.webp` | Watercolour placeholder mismatches illustrated app style |
| P2-3 | 🟡 P2 | Typography / Layout | `fish_select_screen.dart:493` | 13sp species names in tight 3-column grid; consider 2 cols |
| P2-4 | 🟡 P2 | Typography | `aha_moment_screen.dart` | 10+ ad-hoc fontSize values outside AppTypography scale |
| P2-5 | 🟡 P2 | Layout | `lesson_card_widget.dart:33` | Magic number `160` bottom padding not tied to actual button size |
| P2-6 | 🟡 P2 | First-use experience | `onboarding_screen.dart` | 10-screen flow has no progress indicator |
| P2-7 | 🟡 P2 | Layout | `empty_room_scene.dart` | Fixed Positioned values ignore safe area insets |
| P2-8 | 🟡 P2 | Visual consistency | `streak_hearts_overlay.dart`, `welcome_banner.dart` | Hard `Colors.white` / amber hex in home widgets |
| P2-9 | 🟡 P2 | Visual consistency | `empty_room_scene.dart:42,61` | Two raw hex colours in window/floor gradients |
| P2-10 | 🟡 P2 | Visual consistency | `xp_celebration_screen.dart:378` | `Color(0xFFFFD54F)` with dev note "no exact token" |
| P2-11 | 🟡 P2 | Documentation | `bottom_sheet_panel.dart:14` | Docstring says 3 tabs, implementation has 4 |
| P3-1 | 🟢 P3 | Visual consistency | `learn_screen.dart:299` | Gradient teal slightly cooler than app primary |
| P3-2 | 🟢 P3 | Micro-interaction | `bottom_sheet_panel.dart:560` | `_SheetToolCard` has no press feedback animation |
| P3-3 | 🟢 P3 | First-use experience | `welcome_screen.dart:258` | "Quick start with defaults" label is engineering speak |
| P3-4 | 🟢 P3 | Visual polish | `practice_hub_screen.dart:51` | Practice header gradient is visually flat/blank |
| P3-5 | 🟢 P3 | Visual consistency | `glass_card.dart:337` | `SoftCard` light-mode shadows use raw hex not tokens |
| P3-6 | 🟢 P3 | Visual consistency | `analytics_screen.dart:647` | `Radius.circular(4)` not using `AppRadius.xs` |
| P3-7 | 🟢 P3 | First-use experience | `home_screen.dart` | Sheet chevron hint competes with EmptyRoomScene CTA |
| P3-8 | 🟢 P3 | Visual polish | `difficulty_settings_screen.dart:318` | `size: 14` icon below AppIconSizes.xs minimum |
| P3-9 | 🟢 P3 | Visual polish | `equipment_screen.dart:541` | `size: 14` history icon below minimum |
| P3-10 | 🟢 P3 | Visual polish | `acclimation_guide_screen.dart:289` | `size: 12` icon, unrecognisable at small densities |
| P3-11 | 🟢 P3 | Interaction | `quiz_answer_option.dart:177` | `maxLines: 4` ellipsis can silently clip correct answers |
| P3-12 | 🟢 P3 | Documentation | `bottom_sheet_panel.dart:14` | Class docstring outdated (three → four tabs) |
| P3-13 | 🟢 P3 | Codebase hygiene | `screens/learn_screen.dart` etc. | Barrel shims have no deprecation comments |

---

## What's Working Well (Don't Break It)

- **GlassCard** is beautifully implemented — reduced-motion respect, scale-on-press, haptics, full `GlassVariant` system, accessibility labels. This is the best component in the app.
- **AppButton** enforces 48dp minimum height across all sizes (`small`, `medium`, `large`) — no tap-target issues from this component.
- **QuizAnswerOption** has a lovely bounce+checkmark animation on correct answers; reduced-motion support is correct.
- **AppTypography** / **AppSpacing** / **AppRadius** token systems are coherent and well-documented. The codebase is 95% token-clean.
- **BottomSheetPanel** — the concept and execution of the draggable glass sheet with snap points and first-use chevron hint is excellent.
- **Empty state** on the home screen (`EmptyRoomScene`) is warm, welcoming, and gives two clear CTAs. Solid first-impression work.
- **Onboarding flow** overall is well-thought-out — micro-lesson, XP celebration, fish selection, and push-permission sequencing is smart product design.
- **Reduced-motion support** is pervasive and consistent — every animation controller checks `MediaQuery.disableAnimations`. This is rare and commendable.
- **Accessibility** is mostly excellent — Semantics labels on buttons, live regions on loading states, `header: true` on headings.

---

*End of audit — 28 findings, 4 ship-blockers, 11 should-fix, 13 nice-to-have.*
