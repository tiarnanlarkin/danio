# Phase 1 UI Design Audit — Aquarium App
**Completed:** 2026-02-23  
**Auditor:** Hephaestus (Design System Subagent)  
**Repo:** `apps/aquarium_app/lib/`

---

## Executive Summary

The Aquarium App is **architecturally mature**. A comprehensive design system already exists in `lib/theme/app_theme.dart` with strong token adoption throughout screens (3,360+ token usages). A full core widget library exists in `lib/widgets/core/`. The app does NOT need a rebuild — it needs targeted token completion and a `lib/widgets/common/` alias layer for Phase 1.3 widgets.

**Overall Design System Health: 8/10**

---

## 1. Existing Design Token Inventory

### AppColors (lib/theme/app_theme.dart)
- ✅ **Primary palette**: `primary` (#3D7068), `primaryLight`, `primaryDark`
- ✅ **Secondary palette**: `secondary` (#9F6847), `secondaryLight`, `secondaryDark`
- ✅ **Accent colors**: `accent` (sky blue), `accentAlt` (soft lavender)
- ✅ **Semantic colors**: `success`, `warning`, `error`, `info`, `xp`
- ✅ **Neutral palette**: `background`, `surface`, `surfaceVariant`, `card`
- ✅ **Text colors**: `textPrimary`, `textSecondary`, `textHint`
- ✅ **Dark mode variants**: all light-mode colors have dark equivalents
- ✅ **WCAG AA compliance**: documented contrast ratios (4.5:1+)
- ✅ **Pre-computed alpha colors**: extensive (AppColors.*Alpha*, AppOverlays.*)  
- ✅ **Gradients**: `primaryGradient`, `warmGradient`, `oceanGradient`, `sunsetGradient`, `darkGradient`
- ⚠️ **Missing explicit semantic "on" tokens**: `onPrimary`, `onSecondary`, `onSurface`, `onBackground`, `onError`, `onSuccess`, `onWarning` not in AppColors (only in ThemeData's ColorScheme)

### AppTypography
- ✅ **Headline scale**: `headlineLarge` (32px/700), `headlineMedium` (24px/600), `headlineSmall` (20px/600)
- ✅ **Title scale**: `titleLarge` (22px/600), `titleMedium` (18px/500), `titleSmall` (16px/500)
- ✅ **Body scale**: `bodyLarge` (17px/400), `bodyMedium` (15px/400), `bodySmall` (13px/400)
- ✅ **Label scale**: `labelLarge` (15px/600), `labelMedium` (13px/500), `labelSmall` (11px/500)
- ⚠️ **Missing roadmap-required aliases**: `display`, `headline`, `title`, `body`, `label`, `caption`, `overline`
- ⚠️ **Inline typography in screens**: 620 instances of raw `TextStyle`/`fontSize` in screens (not using AppTypography) — most are in room/ambient rendering code

### AppSpacing
- ✅ **Current**: `xs`=4, `sm`=8, `md`=16, `lg`=24, `xl`=32, `xxl`=48
- ⚠️ **Missing**: `sm2`=12, `lg2`=20, `xl2`=40, `xxxl`=64 from roadmap scale

### AppRadius
- ✅ **Current**: `xs`=4, `sm`=8, `md`=16, `lg`=24, `xl`=32, `pill`=100
- ⚠️ **Missing**: `md2`=12 from roadmap radius scale

### Elevation Scale
- ❌ **Completely missing** — no `AppElevation` class exists
- Workaround: `AppShadows` class provides shadow presets (`soft`, `medium`, `elevated`, `subtle`)

---

## 2. Core Widget Inventory (lib/widgets/core/)

All core widgets are **production-quality** with accessibility semantics, dark mode, and token usage.

| Widget | File | Quality | Notes |
|--------|------|---------|-------|
| `AppCard` | `app_card.dart` | ⭐⭐⭐⭐⭐ | 5 variants (elevated, outlined, filled, glass, gradient) |
| `AppButton` | `app_button.dart` | ⭐⭐⭐⭐⭐ | 5 variants, haptics, loading state, a11y |
| `AppIconButton` | `app_button.dart` | ⭐⭐⭐⭐⭐ | Requires semanticsLabel (enforced by assert) |
| `AppTextField` | `app_text_field.dart` | ⭐⭐⭐⭐⭐ | Error/success/loading states, focus management |
| `AppSearchField` | `app_text_field.dart` | ⭐⭐⭐⭐ | Clear button, semantic label |
| `AppListTile` | `app_list_tile.dart` | ⭐⭐⭐⭐⭐ | Swipe, disabled, destructive, dividers |
| `NavListTile` | `app_list_tile.dart` | ⭐⭐⭐⭐ | Chevron, badge support |
| `AppEmptyState` | `app_states.dart` | ⭐⭐⭐⭐⭐ | Factories for noItems, noResults, offline, error |
| `AppLoadingState` | `app_states.dart` | ⭐⭐⭐⭐ | Circular, linear, dots variants |
| `AppErrorState` | `app_states.dart` | ⭐⭐⭐⭐ | Network/server factories |
| `GlassCard` | `app_theme.dart` | ⭐⭐⭐ | Basic glass card, limited options |
| `AppChip` | `app_chip.dart` | ⭐⭐⭐⭐ | Multiple variants |
| `AppNavigation` | `app_navigation.dart` | ⭐⭐⭐⭐ | Drawer, bottom nav |
| `BubbleLoader` | `bubble_loader.dart` | ⭐⭐⭐⭐ | Aquatic themed loader |

---

## 3. UI Pattern Inventory from Screens

### Padding/Spacing Patterns (Top inconsistencies)
| Pattern | Count | Status |
|---------|-------|--------|
| `EdgeInsets.all(AppSpacing.md)` | 189 | ✅ Tokenized |
| `EdgeInsets.all(20)` | 46 | ⚠️ Raw value (should be AppSpacing.*) |
| `EdgeInsets.symmetric(horizontal: 16)` | 45 | ⚠️ Should use AppSpacing.md |
| `EdgeInsets.all(12)` | 45 | ⚠️ Raw value (missing token for 12) |
| `EdgeInsets.only(bottom: 12)` | 41 | ⚠️ Raw value |
| `EdgeInsets.all(AppSpacing.lg)` | 27 | ✅ Tokenized |
| `EdgeInsets.all(10)` | 7 | ⚠️ Raw value |

**Root cause**: Missing spacing tokens for 12, 20, 40, 64. Adding these will allow migration.

### Typography Patterns (Inline styles)
| Raw Size | Count | Suggested Token |
|----------|-------|----------------|
| `fontSize: 12` | 37 | → `AppTypography.labelSmall` |
| `fontSize: 14` | 28 | → `AppTypography.bodySmall` or new `caption` |
| `fontSize: 16` | 25 | → `AppTypography.titleSmall` |
| `fontSize: 13` | 23 | → `AppTypography.bodySmall` |
| `fontSize: 18` | 20 | → `AppTypography.titleMedium` |
| `fontSize: 11` | 17 | → `AppTypography.labelSmall` or `overline` |

**620 inline TextStyle usages** — mostly in complex room/scene rendering widgets (visual art code) and some screens. Not all are migratable; room scene visuals legitimately use raw sizes.

### Border Radius Patterns
| Pattern | Count | Status |
|---------|-------|--------|
| `AppRadius.*` | ~150+ | ✅ Tokenized |
| `Radius.circular(20)` | 9 | ⚠️ Should be AppRadius.lg or new 20 token |
| `Radius.circular(16)` | 7 | ⚠️ Should be AppRadius.md |
| `Radius.circular(12)` | 4 | ⚠️ Missing token |

---

## 4. Widget Duplication / Inconsistency Issues

### Duplicate/Redundant Widgets
| Issue | Files | Recommendation |
|-------|-------|---------------|
| Two button files | `app_button.dart` + `app_button_new.dart` | Merge or delete `app_button_new.dart` |
| Duplicate empty state | `widgets/empty_state.dart` + `widgets/core/app_states.dart` | Deprecate `empty_state.dart` |
| Duplicate error state | `widgets/error_state.dart` + `AppErrorState` in `app_states.dart` | Deprecate `error_state.dart` |
| Duplicate loading | `widgets/loading_state.dart` + `AppLoadingState` | Deprecate `loading_state.dart` |
| Two confetti overlays | `confetti_overlay.dart` + `celebrations/confetti_overlay.dart` | Consolidate |
| GlassCard in theme + core | `app_theme.dart` + `widgets/core/glass_card.dart` | Use `glass_card.dart`; remove from theme |

### Inconsistency Issues
- **withOpacity() usage**: Some older widgets still use `.withOpacity()` instead of pre-computed alpha constants. Performance risk on low-end devices.
- **Mixed typography**: 620 inline TextStyle usages in screens vs 3360 AppTypography usages
- **Mixed spacing**: ~450 raw EdgeInsets values vs tokenized usage
- **Room scene complexity**: `room_scene.dart` is 63KB — complex but legitimate visual code

---

## 5. Missing Components (Phase 1.3 Targets)

No `lib/widgets/common/` directory exists. The following need to be created:

| Component | Status | Plan |
|-----------|--------|------|
| `CozyCard` | ❌ Missing | Wrapper around `AppCard` with warm defaults |
| `RoomHeader` | ❌ Missing | New widget for room screen headers |
| `PrimaryActionTile` | ❌ Missing | AppCard+Row pattern found in screens |
| `DrawerListItem` | ❌ Missing | NavListTile wrapper with icon badge |
| `EmptyState` | ❌ Missing | Alias for `AppEmptyState` |
| `StandardInput` | ❌ Missing | Alias for `AppTextField` with app defaults |
| `PrimaryButton` | ❌ Missing | AppButton(variant: primary) wrapper |
| `SecondaryButton` | ❌ Missing | AppButton(variant: secondary) wrapper |

---

## 6. Design Token Gaps Summary

| Category | Status | Action Needed |
|----------|--------|---------------|
| Colour semantic | ✅ Mostly complete | Add explicit `onX` tokens |
| Spacing scale | ⚠️ Partial | Add 12, 20, 40, 64 |
| Radius scale | ⚠️ Partial | Add 12 |
| Elevation scale | ❌ Missing | Add `AppElevation` class |
| Typography aliases | ⚠️ Partial | Add `display`, `headline`, `title`, `body`, `label`, `caption`, `overline` |

---

## 7. Recommendations

### High Priority
1. **Add missing spacing tokens** (12, 20, 40, 64) — enables migration of ~130 raw EdgeInsets
2. **Add elevation scale** — unify card/shadow management
3. **Add typography aliases** — match roadmap naming convention
4. **Create `lib/widgets/common/`** — Phase 1.3 requirements

### Medium Priority
5. **Delete `app_button_new.dart`** — dead code
6. **Deprecate `widgets/empty_state.dart`**, `error_state.dart`, `loading_state.dart`
7. **Migrate raw `withOpacity()` in key widgets** to pre-computed constants

### Low Priority
8. **Migrate 620 inline TextStyle usages** — gradual, screen by screen
9. **Migrate ~450 raw EdgeInsets** — gradual, as screens are touched

---

*Report generated from scan of 160+ lib/ files. Token adoption is strong; app is in excellent structural shape.*
