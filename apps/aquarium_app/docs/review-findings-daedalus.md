# Danio — Finish-Line Design Review
**Reviewer:** Daedalus (Polish & Design System Specialist)  
**Date:** 2026-03-29  
**Branch:** `openclaw/stage-system`  
**Scope:** Read-only audit — no code changes made

---

## Executive Summary

Danio is a genuinely well-crafted app that sits at roughly **78% of the finish line** from a design system and polish perspective. The foundations are excellent — a thorough design token system, well-structured shared components, consistent use of spacing and typography tokens, and a glassmorphism implementation that shows real discipline. What separates it from "shipped" are a scattering of typography bypasses (181 bare `fontSize:` usages, 374 bare `fontWeight:`), raw Material button instances in onboarding screens, residual `Colors.white` in places where `AppColors.whiteAlpha*` should live, and a handful of visual asset gaps that Iris already catalogued. The structure is sound; the craft-finishing is the remaining work.

---

## 1. Design Token System Assessment

### What Exists

| Token file | Scope | Verdict |
|------------|-------|---------|
| `lib/theme/app_colors.dart` | Full colour palette, alpha variants, gradients, semantic colours, dark-mode pairs | ✅ Comprehensive |
| `lib/theme/app_spacing.dart` | Spacing scale (hairline→xxxl), `AppTouchTargets`, `AppTouchPadding`, `AppDurations`, `AppCurves`, `AppIconSizes` | ✅ Comprehensive |
| `lib/theme/app_radius.dart` | Radius scale + pre-built `BorderRadius` helpers, `AppElevation`, `AppShadows`, `AppCardDecoration` | ✅ Comprehensive |
| `lib/theme/app_typography.dart` | 13 named styles across headlines/titles/body/labels plus `lessonBody` variants | ✅ Comprehensive |
| `lib/theme/room_themes.dart` | 12 room themes with per-theme colour token objects | ✅ Well structured |
| `lib/theme/room_identity.dart` | Room-theme identity data (names, preview colours) | ✅ Present |

The token system is genuinely excellent. `AppColors` alone contains 200+ named constants including pre-computed alpha variants (avoiding `.withOpacity()` GC pressure), WCAG AA contrast annotations, semantic "on" colours, and separate classes for `DanioColors` (brand palette), `AppOverlays` (pre-computed semi-transparent overlays), and `AppAchievementColors`. `AppSpacing` includes animation durations and curves aligned to Material 3 motion. This is above-industry-standard for an indie Flutter app.

### Token Coverage (approximate)

| Category | AppSpacing usage | Raw magic numbers |
|----------|-----------------|-------------------|
| Spacing tokens (`AppSpacing.*`) | **2,943** references | 197 `const EdgeInsets.*` without AppSpacing (~6%) |
| Typography tokens (`AppTypography.*`) | **1,216** references | 181 bare `fontSize:` + 374 bare `fontWeight:` bypasses (~33% of styled text) |
| Radius tokens (`AppRadius.*`) | **509** references | **16** raw `BorderRadius.circular(n)` bypasses (<3%) |
| Duration tokens (`AppDurations.*`) | ~200+ references | Occasional inline `Duration(milliseconds: 400)` |

**Overall token system health: ~90% coverage on spacing/radius; ~67% on typography (the weakest area).**

### Hardcoded Colour Bypass Audit

| Pattern | Count | Assessment |
|---------|-------|------------|
| `Colors.white` | **98** | Mixed. Majority are intentional glass-effect overlays. ~15–20 in non-glass contexts (buttons, streak overlay, settings) should use `AppColors.onPrimary` or `AppColors.whiteAlpha*` |
| `Colors.black` | **6** | Mostly intentional: eye pixels in `fish_painter.dart:80`, level-up overlay gradient, stage_handle drag shadow |
| `Colors.red/blue/green/grey/orange/etc.` | **27** | ~15 in `debug_menu_screen.dart` (debug-only, acceptable); ~5 in `confetti_overlay.dart` / `achievement_unlocked_dialog.dart` (celebration — intentional); ~7 borderline (performance overlay, `age_blocked_screen.dart`) |
| `.withOpacity()` | **2** | Nearly eliminated (down from ~378). Both are acceptable dynamic uses |
| `Color(0x...)` inline | ~16 in non-token files | Most in `glass_card.dart` auroraDecoration `.withAlpha()` calls — tint on dynamic colour. Some in `soft_card.dart` with inline comments explaining intent |

**Summary:** ~98 `Colors.white` usages sounds alarming but roughly 75% are legitimate glassmorphism/celebration/button overlay contexts. Genuine bypass count is nearer **20–25 non-intentional** hardcodings out of an estimated 3,500+ colour assignments — approximately **0.7% bypass rate**. Excellent for this codebase size.

### Notable Gaps

1. **`AppColors.whiteAlpha*` vs `Colors.white`** — `streak_hearts_overlay.dart:126,149,225` and `settings_screen.dart:616,628` use `Colors.white` directly for text on dark backgrounds. Should use `AppColors.onPrimary` or `AppColors.textPrimaryDark` depending on context.
2. **`onboarding_screen.dart:478`** — `BorderRadius.circular(3)` progress pill should use `AppRadius.xxsRadius`.
3. **`app_radius.dart:AppCardDecoration`** contains `.withValues(alpha: 0.1)` — should use pre-computed alpha. Minor.

---

## 2. Component Library Assessment

### What Exists

| Component | File | Quality |
|-----------|------|---------|
| `AppButton` (5 variants, 3 sizes) | `widgets/core/app_button.dart` | ✅ Best-in-class |
| `AppCard` (5 variants) | `widgets/core/app_card.dart` | ✅ Solid |
| `GlassCard` (5 variants) | `widgets/core/glass_card.dart` | ✅ Premium |
| `SoftCard` | `widgets/core/glass_card.dart` | ✅ Good |
| `CozyCard` (wrapper around AppCard) | `widgets/common/cozy_card.dart` | ✅ Correct |
| `AppChip` / `AppBadge` | `widgets/core/app_chip.dart` | ✅ Present |
| `AppTextField` | `widgets/core/app_text_field.dart` | ✅ Present |
| `AppListTile` | `widgets/core/app_list_tile.dart` | ✅ Present |
| `AppDialog` | `widgets/core/app_dialog.dart` | ✅ Present |
| `AppEmptyState` / `AppLoadingState` | `widgets/core/app_states.dart` | ✅ Present |
| `DanioSnackBar` (5 types) | `widgets/danio_snack_bar.dart` | ✅ Clean API |
| `showAppBottomSheet` / `showAppDragSheet` / `showAppScrollableSheet` | `widgets/app_bottom_sheet.dart` | ✅ 3 patterns documented |
| `BubbleLoader` / `FishLoader` | `widgets/core/bubble_loader.dart`, `fish_loader.dart` | ✅ Themed |
| `QuizAnswerOption` | `widgets/quiz/quiz_answer_option.dart` | ✅ Polished |
| `SkeletonLoader` / `ShimmerLoading` | `widgets/skeleton_loader.dart` | ✅ Reduced-motion aware |
| `PrimaryButton` (shim around AppButton) | `widgets/common/buttons.dart` | ✅ Documented |
| `AnimatedSwimmingFish` / `SpeciesFish` | `widgets/room/` | ✅ Two implementations (painter + sprite) |
| `GlassCard` semanticLabel | `widgets/core/glass_card.dart:44` | ✅ Optional semantic label |

**Component library coverage is strong.** 95+ shared widgets catalogued. `widgets/core/core_widgets.dart` provides a clean barrel export. Documentation in `docs/widgets.md` is current.

### Consistency Issues

**25 raw Material button usages** bypassing `AppButton`:
- `account_screen.dart:246,326` — `OutlinedButton.icon`
- `home_sheets_stats.dart:88,101` — `OutlinedButton.icon` (XP stats panel)
- `logs_screen.dart:323` — `OutlinedButton.icon` (clear filters)
- `notification_settings_screen.dart:271` — `OutlinedButton.icon`
- `onboarding/age_blocked_screen.dart:34` — `TextButton` (legal link)
- `onboarding/consent_screen.dart:149,150` — `TextButton` (privacy/ToS links)
- `onboarding/welcome_screen.dart:249,254` — `TextButton` (skip)
- `onboarding/returning_user_flows.dart:401,406` — `OutlinedButton`
- `reminders_screen.dart:348` — `FilledButton.icon`
- `tank_settings_screen.dart:348` — `OutlinedButton.icon`
- `widgets/room/fish_tap_interaction.dart:340,342` — `TextButton` (snooze)
- `widgets/stage/bottom_sheet_panel.dart:541` — `OutlinedButton.icon`
- Plus ~10 more scattered instances

**5 `GlassCard` usages in screens** (vs 112 `AppCard` usages) — GlassCard is underutilised in non-tank screens. This may be intentional (GlassCard is for the room/tank context; AppCard for content screens), but not explicitly documented.

**`common/standard_input.dart` vs `core/app_text_field.dart`** — two input components exist. The standard_input appears to be a lighter wrapper; prefer AppTextField for new code.

**`widgets/empty_state.dart` vs `core/empty_state_widget.dart` vs `core/app_states.dart`** — three empty state implementations. `core/app_states.dart` is canonical but the others remain. Minor duplication risk.

### `DanioSnackBar` adoption

The snack bar system is clean. `app_feedback.dart` is the implementation; `danio_snack_bar.dart` wraps it. Per handoff notes, one raw `SnackBar` remains in `smart_screen.dart` — should be migrated.

---

## 3. Visual Consistency Assessment

### Screen-by-Screen Assessment

| Screen | Consistency | Notes |
|--------|-------------|-------|
| **Home (tank view)** | ✅ Excellent | Room theme system works; stage panels feel premium |
| **Learn screen** | ✅ Good | Illustrated header, streak card, path cards — cohesive. 2 raw `Colors.white` on fade gradient at lines 288, 340, 367; raw `fontSize: 14` at lines 341, 368 |
| **Lesson screen** | ✅ Good | Progress bar, card layouts, XP animations — tight |
| **Quiz** | ✅ Excellent | `QuizAnswerOption` is one of the most polished components |
| **Practice Hub** | ✅ Good | Consistent with learn screen |
| **Settings screens** | ⚠️ Partial | `settings_screen.dart:616,628` uses `Colors.white` directly. Overall structure is consistent but some section cards look slightly flatter than the rest of the app |
| **Onboarding flow** | ⚠️ Partial | 58 direct `GoogleFonts.nunito()` calls bypassing `AppTypography` across 10 screens. Visually cohesive but typography token adoption is lowest here |
| **Tank detail** | ✅ Good | Consistent card patterns, GlassCard for water params |
| **Livestock screens** | ✅ Good | `livestock_card.dart:86` uses `Colors.white` border on image — minor |
| **Analytics** | ✅ Good | Uses theme tokens; no obvious bypasses |
| **Smart screens** (Fish ID, Triage, Weekly Plan) | ✅ Good | `context.textSecondary` / `context.surfaceVariant` used throughout |
| **Add Log** | ✅ Good | Uses AppSpacing, context extensions consistently |
| **Guides (algae, disease, equipment, etc.)** | ✅ Good | Template-style screens; consistent |
| **Debug menu** | ✅ Acceptable | 7 raw `Colors.orange/red/grey` — debug-only, acceptable |

**Overall visual consistency: HIGH.** The design language is unmistakably unified. The warm cream/amber palette, Fredoka/Nunito font pairing, 24dp card radius, and teal accent work together coherently across 90+ screens. Padding scale is overwhelmingly `AppSpacing.*`-driven (2,943 usages vs 197 raw insets, ~93% token adherence).

### Inconsistencies to Fix

1. **Typography bypasses in onboarding** — 58 direct `GoogleFonts.nunito()` calls in `onboarding/` should go through `AppTypography.*`. These screens are the first thing users see.
2. **`fontSize: 14`** in `learn_screen.dart:341,368` — should be `AppTypography.bodySmall` (13sp) or `bodyMedium` (15sp). Stray magic number.
3. **`home_sheets_care.dart:36,116` and `home_sheets_water.dart:31`** — emoji `Text` with inline `fontSize: 40` — this is an emoji so no font token applies, but using `AppIconSizes.xl` (48) as reference would be more consistent.
4. **`BorderRadius.circular(12)` in `learn_screen.dart:335,362`** — should be `AppRadius.md2Radius`.
5. **`welcome_banner.dart:54`** — `fontSize: 28` for emoji. Should be documented as intentional or use a display size token.

---

## 4. Animation & Interaction Quality Assessment

### Fish Swimming Animations

- **`AnimatedSwimmingFish`** — Custom painter fish with sine-wave bobbing. Wrapped in `RepaintBoundary`. Reduced-motion support via `didChangeDependencies` (uses 5-minute duration instead of zero to avoid Flutter assertions). Direction flip logic is clean. Position clamping added (BUG-08) to keep fish within glass walls. ✅
- **`SpeciesFish`** — Sprite-based (uses actual species PNG), procedural swimming with depth-layered speed/opacity/scale. Includes speed jitter to prevent lockstep. Also wrapped in `RepaintBoundary`. Bounce-pause on wall contact. ✅
- **RepaintBoundary count: 20** — Strategic placement on fish, celebration overlays, animated counters.

### GlassCard Interactions

- Scale bounce on tap (1.0→0.98, 100ms) using `AnimationController`.
- `HapticFeedback.lightImpact()` on tap, `mediumImpact()` on long press.
- Reduced motion: `_controller.duration = Duration.zero` in `didChangeDependencies()`. ✅
- `semanticLabel` parameter for accessibility. ✅

### Quiz Answer Animations

- `QuizAnswerOption` — scale bounce on correct answer (1.0→1.05→1.0 over 300ms), with checkmark fade-in starting at 30% of bounce animation. `_bouncePlayed` guard prevents re-triggering. Respects `MediaQuery.disableAnimations`. ✅ — This is genuinely polished.

### Page Transitions

- **Global transition theme:** `_kDanioPageTransitionsTheme` applied to all platforms via `pageTransitionsTheme`. Uses `_DanioPageTransitionsBuilder` (custom slide+fade). ✅
- **Custom routes in use:** `RoomSlideRoute` (room navigation), `ModalScaleRoute` (modal screens), `TankDetailRoute` (Hero-enabled). ✅
- **37 `MaterialPageRoute` usages remaining** — These bypass the custom transitions and fall back to default Material behaviour. The global `pageTransitionsTheme` intercepts them, but direct `MaterialPageRoute` usage is inconsistent. Should be `AppPageRoute` or `RoomSlideRoute`.

### Loading States

- `ShimmerLoading` — skeleton loader with shimmer animation, reduced-motion fallback (static 40% opacity). ✅
- `BubbleLoader` / `FishLoader` — aquarium-themed. ✅
- `CircularProgressIndicator` — **7 usages** in non-AppButton contexts. `maintenance_checklist_screen.dart:464`, `sync_indicator.dart:72,163`, `sync_status_widget.dart:59` — sync indicators are reasonable use cases. `app_feedback.dart:191` is in a loading SnackBar. Most are acceptable but could be `BubbleLoader.small()` for theme consistency.
- `Skeletonizer` (skeletonizer package) used in learn screen — proper skeleton screens rather than spinners. ✅

### Tab Transitions

- `TabNavigator` uses `AnimationController` for cross-fade between tabs (200ms, easeOut). Respects `reducedMotionProvider`. ✅

### Panel Animations (Stage system)

- `SwissArmyPanel` — blade-curve hinge animation, `AppDurations.medium4` (300ms). Reduced motion: `Duration.zero`. ✅
- `BottomSheetPanel` — `DraggableScrollableSheet` with 3 snap points (0.16 peek, 0.45 half, 0.92 full). `BackdropFilter` inside. First-use hint with `AnimatedOpacity` fade-out after 3s. ✅

---

## 5. Glassmorphism Assessment

### Implementation Quality

```
BackdropFilter count: 5 total
  1. GlassCard         — lib/widgets/core/glass_card.dart:152
  2. SpeedDialFab      — lib/widgets/speed_dial_fab.dart:96
  3. BottomSheetPanel  — lib/widgets/stage/bottom_sheet_panel.dart:132
  4. StageScrim        — lib/widgets/stage/stage_scrim.dart:77
  5. SwissArmyPanel    — lib/widgets/stage/swiss_army_panel.dart:136
```

**5 BackdropFilter instances is excellent discipline.** Many Flutter apps bloat to 20-30 filters and suffer frame drops. The Danio stage system concentrates blur on the panels that appear over the room background — the primary place where glassmorphism makes visual sense.

### GlassCard Variant Consistency

Five variants cover the full design vocabulary:

| Variant | Background | Border | Use |
|---------|-----------|--------|-----|
| `frosted` | `whiteAlpha70` (light) / `whiteAlpha08` (dark) | `whiteAlpha50` / `whiteAlpha12` | Default glass |
| `soft` | `whiteAlpha90` | None — soft shadows only | Floating card over light backgrounds |
| `aurora` | Primary-to-ivory gradient | Teal accent border | Onboarding / highlight cards |
| `cozy` | `0xFFFFFBF5` ivory / `0xFF2A2220` charcoal | Warm amber border | Room/home content |
| `watercolor` | Primary tint gradient | Primary at 10-15% | Subtle branded containers |

**All variants use `AppColors.*` tokens** (no hardcoded hex in variant logic except intentional dark-mode charcoal `0xFF2A2220` in cozy which maps to `AppColors.cardDark` — could be tokenised).

### Background Compatibility

The room theme system provides per-theme `glassCard` and `glassBorder` tokens, but the `GlassCard` widget draws on global `AppColors` rather than the room theme. This means GlassCard white overlays (`whiteAlpha70`) will read differently against dark room backgrounds (midnight, gem shop deep navy) vs light ones (cotton, pastel). On dark themes, the `isDark` check falls to `whiteAlpha08` which is very subtle — this is correct behaviour, but confirm frosted GlassCard on Midnight/Aurora backgrounds against the full design intent.

### Opacity Consistency

The frosted variant's opacity is consistent (`whiteAlpha70`/`whiteAlpha08`). The blur sigma (default `10.0`) is the same throughout. No cases of opacity drift between instances.

### Performance

- All `BackdropFilter` widgets are properly wrapped in `ClipRRect` (required for correct blur clipping).
- GlassCard wraps in `AnimatedBuilder` which rebuilds only on scale animation, not on every parent rebuild.
- SpeedDialFab and panel blurs are conditionally rendered (only when their parent panels are visible).

---

## 6. Asset Consistency Assessment

*(Defers to Iris's prior visual asset audit — 2026-03-29 — which covers this in full. Summary below.)*

### Fish Sprites

- 15 species present in both full (512×512) and thumb (128×128) sizes.
- `bristlenose_pleco.png` — **Palette mode (P) not RGBA** — will render incorrectly in some contexts. Must be re-saved as RGBA.
- 13/15 match the chibi art bible style; `angelfish` and `amano_shrimp` flagged as style outliers.
- **Overall: 8.5/10**

### Room Backgrounds

- 12 WebP backgrounds present. 10/12 at quality bar.
- `room-bg-cozy-living.webp` (66 KB, 5.5/10) — legacy, visually weaker than Wave 4 set.
- `room-bg-forest.webp` (88 KB, 6.75/10) — legacy, acceptable but inconsistent.
- **Overall: 8/10**

### Illustration Headers

- `learn_header.webp` and `practice_header.webp` — previously flagged as style mismatches (flat cel art vs chibi). Confirmed not regenerated as of this audit.
- **Overall: 4/10** — blocking quality items

### Badges

- `assets/icons/badges/` has `badge_early_bird.png`, `badge_night_owl.png`, `badge_perfectionist.png`, and `legendary_badge_display.png` — 4 files present. Per Iris's earlier audit these were "EMPTY" — they may have been added since. Verify quality and art style consistency with fish sprites.

### Placeholder

- `assets/images/placeholder.webp` — amber watercolour texture. Style mismatch with illustrated app (not a chibi illustration). Acceptable as a temporary fallback, but ideally replaced with a chibi fish silhouette.

### Onboarding Background

- `assets/images/onboarding/onboarding_journey_bg.webp` — photorealistic render in an otherwise illustrated app. Style friction on first impression.

### Rive Animations

- 4 Rive files: `emotional_fish.riv`, `joystick_fish.riv`, `puffer_fish.riv`, `water_effect.riv`. These power the mascot and loading states. Not audited in detail here.

### Fonts

- Fredoka (Bold, Regular, SemiBold) and Nunito (Bold, ExtraBold, Italic, Medium, Regular, SemiBold) — local fallbacks present. `GoogleFonts.config.allowRuntimeFetching = false` set in `main.dart`. ✅

---

## 7. Copy / Text Consistency Assessment

### British English Compliance

The app is **overwhelmingly British English**. A search of lesson content, UI strings, and widget copy confirmed:

| British form | Occurrences | American form | Occurrences |
|-------------|-------------|---------------|-------------|
| `behaviour` / `behaviours` | 157 in data/ | `behavior` as user-facing text | 0 |
| `colour` / `colours` | Many in data/ | `color` as user-facing copy | 0 |
| `favourite` | 1 (stories.dart:1179) | `favorite` as user-facing copy | 0 |

The 4 `Icons.favorite` usages are Flutter SDK icon names (API code), not user-facing copy. The `behavior` found (17 usages) are all Flutter API terms (`HitTestBehavior`, `SnackBarBehavior`, `ScrollBehavior`) — correct, unavoidable.

**British English compliance: ✅ PASS**

### Tone Consistency

The lesson content is warm, authoritative, and hobbyist-appropriate. Sample from `equipment_expanded.dart`: *"Beginners think lighting is about seeing their fish. Wrong! Lighting affects fish behaviour, plant growth, and algae levels."* — punchy, direct, consistent with Duolingo-style pedagogy.

UI copy in buttons, toasts, and onboarding is encouraging without being saccharine. The `fun_loading_messages.dart` widget adds personality to loading states.

### Formatting Issues

Per handoff notes: ~5 hyphens used as em dashes remain in lesson content. Not verified in this pass but should be caught in final content review.

### Button Label Conventions

- Consistent: Title case for primary actions ("Save Changes", "Add Tank", "Complete Lesson").
- Consistent: Sentence case for secondary text and descriptions.
- Minor: Some bottom sheet action labels use all-caps which clashes with the app's warm tone.

---

## 8. Accessibility Assessment

*(Apollo's prior audit — 2026-03-29 — covers WCAG 2.1 AA compliance in detail. Summary:)*

### Semantic Labels

- 264 `Semantics`/`semanticLabel`/`MergeSemantics`/`ExcludeSemantics` references.
- `OptimizedImage` wrapper handles `semanticLabel` / `excludeFromSemantics` propagation.
- `QuizAnswerOption` has explicit `Semantics(button: true, label: ..., selected: ...)`. ✅
- `GlassCard` has optional `semanticLabel` parameter and wraps in `Semantics` when interactive. ✅
- `AppButton` has `semanticsLabel` parameter with haptic feedback. ✅
- **Gap:** `settings_screen.dart:1133` — password toggle `IconButton` has no `tooltip`. **1 known missing label.**

### Reduced Motion

- `MediaQuery.of(context).disableAnimations` checked in **159 places**.
- `reducedMotionProvider` (Riverpod) wraps system preference.
- `ShimmerLoading` falls back to static 40% opacity.
- `AnimatedSwimmingFish` uses 5-minute duration (not zero) to avoid Flutter assertions — correct pattern.
- `GlassCard`, `QuizAnswerOption`, `SwissArmyPanel`, `BottomSheetPanel`, `TabNavigator` all respond. ✅

### Touch Targets

- `AppTouchTargets.minimum = 48.0` defined and used.
- `app_navigation.dart` enforces `BoxConstraints(minWidth: 48, minHeight: 48)` on all `IconButton` instances.
- Apollo found 2 specific areas below 48dp (not named in this pass — see `docs/accessibility-audit.md`).

### Colour Contrast (Known Failures)

Per Apollo's audit:
- `AppColors.warning` (0xFF8B6914 — _corrected_ WCAG-AA amber in `app_colors.dart`) **vs** the older `AppColors.primaryLight` (0xFFD97706) used as body text — fails 4.5:1.
- `onSurface.withAlpha(153)` (~60% opacity): ~3.73:1 on white — borderline fail for small text.
- Warning icon at 14dp: 2.69:1 against background — fails non-text 3:1.

**Note:** `app_colors.dart` documents `AppColors.warning = Color(0xFF8B6914)` as "~4.5:1 on white — WCAG AA" which is borderline. The older `AppColors.primaryLight = Color(0xFFD97706)` used in some body text contexts does fail.

### Font Scaling

- No `textScaleFactor` clamping found. Text overflows handled with `overflow: TextOverflow.ellipsis` and `maxLines`. ✅

---

## 9. Polish Scores (1–10)

| Area | Score | Rationale |
|------|-------|-----------|
| **Design token system** | **9/10** | Near-complete, excellently organised, pre-computed alphas, WCAG annotations. Deducted 1 for 181 bare fontSize bypasses |
| **Component library** | **8/10** | AppButton/AppCard/GlassCard are genuinely premium. Deducted 2 for 25 raw Material button usages (mostly onboarding) and 3 overlapping empty-state components |
| **Visual consistency** | **8/10** | Coherent across 90+ screens. Deducted 2 for onboarding typography bypasses (58 direct GoogleFonts calls) and scattered magic numbers in 10–15 screens |
| **Animation & interaction** | **8.5/10** | Fish animations performant, quiz bounce polished, tab transitions smooth, reduce-motion pervasive. Deducted 1.5 for 37 MaterialPageRoute bypassing custom transitions, and 7 CircularProgressIndicator off-brand |
| **Glassmorphism** | **9/10** | Disciplined 5-filter count, consistent blur sigma, all variants token-driven. Deducted 1 for potential dark-background readability on frosted variant not confirmed across all 12 room themes |
| **Asset consistency** | **6.5/10** | Per Iris audit. Fish sprites strong, 2 headers need regen, 2 legacy backgrounds below bar, bristlenose palette-mode bug, illustration placeholders wrong style |
| **Copy/text consistency** | **9/10** | British English essentially complete. Lesson content is substantive and tonally consistent. Deducted 1 for ~5 remaining hyphen-as-em-dash instances and 1 raw SnackBar in smart_screen |
| **Accessibility** | **7/10** | Per Apollo audit. Reduce-motion excellent, semantics pervasive, touch targets mostly 48dp. Deducted 3 for warning contrast failures, 2 below-48dp target areas, 1 missing password toggle tooltip |

**Weighted average: 8.1 / 10**

---

## 10. Recommended Polish Finish Line

The following items are ordered by **impact vs effort** — highest bang for the finish-line sprint.

### P0 — Blockers (must fix before launch)

1. **`bristlenose_pleco.png`** — re-save as RGBA (30 seconds, file replace)
2. **Warning colour contrast** — `AppColors.primaryLight` used as body text fails WCAG AA. Audit which screens use `primaryLight` as text colour and swap to `AppColors.amberText` (`0xFFB45309`, 4.7:1) or `DanioColors.amberText`
3. **Password toggle tooltip** — add `tooltip: 'Show/hide password'` at `settings_screen.dart:1133`

### P1 — High impact, low effort (1–2 hours each)

4. **Learn/practice illustration headers** — Re-generate in chibi art style to match fish sprites. These appear on the app's primary content screen.
5. **Onboarding typography** — Replace 58 `GoogleFonts.nunito(...)` calls in `lib/screens/onboarding/` with the appropriate `AppTypography.*` token. First-impression polish.
6. **Raw Material buttons in onboarding** — Replace `TextButton`/`OutlinedButton` in `welcome_screen.dart`, `consent_screen.dart`, `age_blocked_screen.dart` with `AppButton(variant: .text)` or `.secondary`. 8 usages.
7. **2 magic radius in learn_screen** — `BorderRadius.circular(12)` at lines 335/362 → `AppRadius.md2Radius`
8. **Raw SnackBar in `smart_screen.dart`** — replace with `DanioSnackBar.show()`

### P2 — Medium impact, medium effort (half-day each)

9. **Onboarding progress indicator** — Users don't know where they are in the 10-screen flow. Add a step indicator (dots or "3 of 10").
10. **`room-bg-cozy-living.webp`** — Replace with Wave 4 quality background. The 66 KB file size compared to 147+ KB for Wave 4 images tells the whole story.
11. **Raw `MaterialPageRoute` audit** — 37 usages. Where these are pushing content screens, wrap in `RoomSlideRoute` or `ModalScaleRoute` as appropriate. Not all need changing (navigation from debug menu is fine), but main flows (Create Tank, Tank Detail, Lesson) should use the custom route.
12. **`CircularProgressIndicator` in content screens** — Replace `maintenance_checklist_screen.dart:464` and any non-sync usages with `BubbleLoader.small()` for theme consistency.

### P3 — Nice to have (if time permits)

13. **Onboarding background** — Replace photorealistic `onboarding_journey_bg.webp` with illustrated/watercolour equivalent.
14. **Placeholder.webp** — Replace with chibi fish silhouette.
15. **`_auroraDecoration` in `glass_card.dart`** — The `.withAlpha()` calls on inline `Color(0xFF5B9EA6)` should reference `AppColors.accentAlpha40/38` directly.
16. **`soft_card.dart` inline shadow colours** — `const Color(0x08000000)` and `const Color(0x05000000)` shadow variants already exist as `AppColors.blackAlpha08` / `AppColors.blackAlpha05` — use those.
17. **`cozy` GlassCard variant** — `const Color(0xFF2A2220)` dark background should reference `AppColors.cardDark`.
18. **Em dash corrections** — 5 remaining hyphen-as-em-dash instances in lesson content.

---

## Summary

Danio is **finish-line ready except for the P0/P1 items**. The design system is one of the strongest I've seen in a Flutter indie app — the pre-computed alpha token table alone shows unusual craft attention. The primary remaining gap is **typography token bypasses in onboarding** (the most visible screen sequence) and **2–3 visual asset replacements** that Iris flagged. Fix those, resolve the 3 P0 accessibility items, and this ships clean.

The glassmorphism implementation in particular is excellent — 5 `BackdropFilter` instances total, consistent opacity, proper `ClipRRect` wrapping, haptics, reduced-motion support. This is what separates a craftsman from a developer.

*— Daedalus*
