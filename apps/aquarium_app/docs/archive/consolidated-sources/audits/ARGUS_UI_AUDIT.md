# Argus UI Polish Audit — Danio Aquarium App

**Date:** 2026-03-01  
**Branch:** `openclaw/ui-fixes`  
**Auditor:** Argus (QA & Design Systems Agent)

---

## Design System Overview

| Token | System | Details |
|-------|--------|---------|
| **Colors** | `AppColors`, `DanioColors` | Amber/gold primary, blue-slate secondary, teal accent |
| **Typography** | `AppTypography` | Fredoka (headlines), Nunito (body/labels) |
| **Spacing** | `AppSpacing` | xs=4, sm=8, sm2=12, md=16, lg2=20, lg=24, xl=32, xl2=40, xxl=48, xxxl=64 |
| **Radii** | `AppRadius` | xs=4, sm=8, md2=12, md=16, lg=24, xl=32, pill=100 |
| **Elevation** | `AppElevation` | 5 levels (0, 2, 4, 8, 12, 24) |
| **Shadows** | `AppShadows` | subtle, soft, medium, elevated, dreamy, glass, cozy |
| **Animations** | `AppDurations`, `AppCurves` | Material 3 aligned |
| **Touch targets** | `AppTouchTargets` | 48dp minimum, adaptive sizing |
| **Icons** | `AppIconSizes` | xs=16, sm=20, md=24, lg=32, xl=48, xxl=64 |

---

## Design System Consistency Score: 72%

| Area | Score | Rationale |
|------|-------|-----------|
| Color Consistency | 85% ✅ | Fixed 45+ off-brand color instances. 13 remain in decorative contexts (confetti, book colors) — acceptable |
| Typography | 72% | 1,122 AppTypography uses vs 426 hardcoded fontSize. Core screens use theme; analytics, gem shop, difficulty settings lag |
| Spacing & Padding | 76% | 1,829 AppSpacing uses vs 583 hardcoded. Good adoption; EdgeInsets.all(16) and EdgeInsets.only(bottom: 12) most common violations |
| Border Radii | 88% ✅ | 513 AppRadius uses vs 67 hardcoded. Most hardcoded are small progress-bar radii (2-4px) — contextually fine |
| Elevation | 96% ✅ | 22 AppElevation uses, only 1 hardcoded remaining (pre-existing) |
| Icons | 90% ✅ | Replaced all 10 Icons.pets (paw) with Icons.set_meal (fish). AppIconSizes well adopted |
| Loading States | 80% | AppLoadingState/AppErrorState used in ~15 screens. Some screens still use raw CircularProgressIndicator |
| Error States | 85% ✅ | AppErrorState used consistently across 14+ screens |
| Animations | 70% | 26 flutter_animate usages. AppDurations and AppCurves defined but inconsistently referenced |
| Overflow Safety | 85% ✅ | TextOverflow.ellipsis used extensively (30+ instances). No RenderFlex issues found |

---

## Fixes Applied (2 commits)

### Commit 1: ccc88c0
**45 off-brand color replacements + icon fixes across 24 files**

| Before | After | Files affected |
|--------|-------|----------------|
| Colors.blue | AppColors.info | analytics (9x), account, charts |
| Colors.purple | AppColors.accentAlt | 12 screens (quiz, friends, logs, practice, etc.) |
| Colors.indigo | AppColors.secondaryDark | charts, study |
| Colors.pink | DanioColors.coralAccent | gem shop, study, shop street |
| Colors.cyan | AppColors.accent | stories, leaderboard, study |
| Colors.deepOrange | AppColors.primary | analytics |
| Colors.yellow | AppColors.warning | workshop, co2 calculator |
| Colors.blueGrey | AppColors.secondary | study |
| Icons.pets | Icons.set_meal | 10 screens (about, backup, search, etc.) |
| elevation: 2 | AppElevation.level1 | anomaly_card |

### Commit 2: 67734e2
**7 remaining off-brand colors in trends, wishlist, stories card**

---

## Top 10 Most Impactful UI Improvements (prioritised)

### 1. 🔴 analytics_screen.dart — Typography overhaul
**Impact: HIGH | Effort: MEDIUM**
- 33 hardcoded fontSize values — the worst offender in the codebase
- Uses raw TextStyle(fontSize: 18, fontWeight: FontWeight.bold) instead of AppTypography.titleMedium
- Completely bypasses the Fredoka/Nunito type scale
- **Fix:** Replace all inline TextStyle constructors with AppTypography equivalents

### 2. 🔴 gem_shop_screen.dart — Typography & spacing
**Impact: HIGH | Effort: MEDIUM**
- 19 hardcoded fontSize values
- Mix of raw padding values alongside AppSpacing
- Gem prices, labels, and descriptions all use ad-hoc sizes

### 3. 🟡 difficulty_settings_screen.dart — Full design system adoption
**Impact: MEDIUM | Effort: LOW-MEDIUM**
- 18 hardcoded fontSize values
- Uses TextStyle(fontSize: 18, fontWeight: FontWeight.bold) for section headers

### 4. 🟡 friends_screen.dart + friend_comparison_screen.dart — Typography
**Impact: MEDIUM | Effort: LOW**
- 16 hardcoded fontSize each
- Social features visible to users — should feel polished

### 5. 🟡 Hardcoded EdgeInsets migration
**Impact: MEDIUM | Effort: HIGH (583 instances)**
- 45 instances of EdgeInsets.all(16) should be EdgeInsets.all(AppSpacing.md)
- 43 instances of EdgeInsets.only(bottom: 12) should use AppSpacing.sm2
- Creates inconsistency if spacing scale ever changes
- **Priority files:** analytics, inventory, onboarding, gem shop

### 6. 🟡 Raw CircularProgressIndicator → AppLoadingState
**Impact: MEDIUM | Effort: LOW**
- ~20 raw spinners found across screens
- AppLoadingState exists with .spinner() and .linear() constructors
- Key offenders: fish_id_screen, symptom_triage_screen, activity_feed_screen, aquarium_supply_screen

### 7. 🟢 onboarding_screen.dart — Hardcoded radii
**Impact: LOW-MEDIUM | Effort: LOW**
- 7 hardcoded BorderRadius.circular() calls
- Uses BorderRadius.circular(40), BorderRadius.circular(5), BorderRadius.circular(16)
- Should use AppRadius.xl, AppRadius.xs, AppRadius.md

### 8. 🟢 smart_screen.dart — Hardcoded radii
**Impact: LOW | Effort: LOW**
- 8 hardcoded BorderRadius.circular() — mostly 12.0 and 16.0
- Should be AppRadius.md2 and AppRadius.md

### 9. 🟢 Celebration widgets — Intentional palette diversity
**Impact: NONE (leave as-is)**
- confetti_overlay.dart, achievement_notification.dart use Colors.purple, Colors.pink
- These are decorative confetti/celebration colors — variety is intentional
- **No action needed**

### 10. 🟢 study_room_scene.dart — Book/furniture colors
**Impact: NONE (leave as-is)**
- Uses StudyColors.bookBlue — a room-specific palette for decorative book spines
- Contextually correct — books should have varied colors
- **No action needed**

---

## Screens Needing Most Attention

| Screen | Issues | Priority |
|--------|--------|----------|
| analytics_screen.dart | 33 hardcoded fontSize, inconsistent chart styles | 🔴 P0 |
| gem_shop_screen.dart | 19 hardcoded fontSize, spacing inconsistencies | 🔴 P0 |
| difficulty_settings_screen.dart | 18 hardcoded fontSize | 🟡 P1 |
| friends_screen.dart | 16 hardcoded fontSize | 🟡 P1 |
| friend_comparison_screen.dart | 16 hardcoded fontSize | 🟡 P1 |
| inventory_screen.dart | 14 hardcoded fontSize | 🟡 P1 |
| shop_street_screen.dart | 12 hardcoded fontSize | 🟡 P1 |
| onboarding_screen.dart | 7 hardcoded BorderRadius, 16 hardcoded fontSize | 🟡 P1 |
| activity_feed_screen.dart | 8 hardcoded fontSize, raw loading indicators | 🟢 P2 |
| smart_screen.dart | 8 hardcoded BorderRadius | 🟢 P2 |

---

## Design System Strengths ✅

1. **Comprehensive color system** — pre-computed alpha colors eliminate withOpacity() GC pressure (378+ allocations saved per frame)
2. **Well-defined type scale** — Fredoka for headlines, Nunito for body. Clear semantic aliases
3. **Room theme system** — 12 themes with consistent color slots. Excellent extensibility
4. **Touch target compliance** — Material 3 minimum 48dp enforced via AppTouchTargets
5. **Glass/card decoration presets** — GlassStyles and AppShadows provide consistent depth
6. **WCAG AA compliance** — semantic colors verified for 4.5:1 contrast ratios
7. **Dark mode** — warm charcoal palette (not cold blue-grey). Thoughtful

## Design System Gaps 🔧

1. **No spacing constants for common compound values** — e.g. EdgeInsets.symmetric(horizontal: 16, vertical: 8) repeated 14 times
2. **No AppTextStyle helper** — screens create TextStyle(fontSize: X, fontWeight: Y) instead of using AppTypography.bodyMedium.copyWith()
3. **Animation duration inconsistency** — AppDurations defined but many screens hardcode Duration(milliseconds: 300) etc.
4. **No lint rule enforcement** — no custom lint to catch Colors.blue or hardcoded fontSize

---

## Recommendations

1. **Add custom lint rules** (via custom_lint or analysis_options.yaml) to flag:
   - Colors.blue, Colors.purple, Colors.indigo etc.
   - Hardcoded fontSize outside theme files
   - BorderRadius.circular() outside theme files

2. **Create AppPadding presets** for the 10 most common EdgeInsets patterns

3. **Migrate analytics_screen.dart** to AppTypography — it's the most visible data-heavy screen and currently the worst typography offender

4. **Document the type scale** in a design system reference for future contributors
