# Danio Aquarium App — Accessibility & Inclusivity Audit
**Branch:** `openclaw/stage-system`  
**Audit Date:** 2026-03-29  
**Standard:** WCAG 2.1 AA  
**Auditor:** Apollo (automated static analysis)

---

## Executive Summary

The Danio app has **strong accessibility foundations** — a dedicated `accessibility_utils.dart` with label helpers, pervasive `disableAnimations` / reduce-motion checks, and meaningful semantic annotations across the codebase. The primary outstanding issues are a handful of **contrast failures** with warning-amber colours used as text, a few **missing tooltips on IconButton**, and secondary-text opacity values that fall slightly below the 4.5:1 AA threshold for small text.

**Overall Accessibility Score: 7 / 10**

---

## WCAG 2.1 AA Checklist

| Criterion | Description | Result | Notes |
|-----------|-------------|--------|-------|
| **1.1.1** | Non-text content has text alternatives | ⚠️ PARTIAL | Most images have `semanticLabel` or `excludeFromSemantics`. 2 edge-case areas noted below. |
| **1.3.1** | Info & relationships conveyed via semantics | ✅ PASS | `Semantics`, `A11ySemantics`, `MergeSemantics`, `ExcludeSemantics` used throughout (312 references). |
| **1.3.2** | Meaningful sequence | ✅ PASS | Reading order follows visual layout; no RTL issues detected. |
| **1.3.3** | Sensory characteristics | ✅ PASS | Instructions do not rely solely on colour or icon shape. |
| **1.4.1** | Use of colour | ⚠️ PARTIAL | Status indicators (warning/danger/safe) use colour only in some charts. No secondary non-colour indicator confirmed. |
| **1.4.3** | Contrast (minimum) — normal text | ❌ FAIL | `AppColors.warning` (0xFFC99524) used as text colour: 2.69:1 on white — fails 4.5:1. `onSurface.withAlpha(153)` (~60% opacity): ~3.73:1 on white — fails 4.5:1 for small text. `AppColors.primaryLight` (0xFFD97706) as body text: 3.19:1 on white — fails. |
| **1.4.4** | Resize text (200%) | ✅ PASS | All `Text` widgets use `overflow: TextOverflow.ellipsis` alongside `maxLines: 1`; no `textScaleFactor` clamping found. |
| **1.4.5** | Images of text | ✅ PASS | No images of text detected; all text rendered as Flutter `Text` widgets. |
| **1.4.10** | Reflow | ✅ PASS | `Expanded`, `Flexible`, and `ListView`/`SingleChildScrollView` used throughout — no hard horizontal overflow containers. |
| **1.4.11** | Non-text contrast | ⚠️ PARTIAL | `AppColors.warning` icons at 14dp: 2.69:1 — fails 3:1 for UI components. Warning icons at 18–28dp likely pass as large-text equivalent. |
| **1.4.12** | Text spacing | ✅ PASS | No custom letter-spacing or line-height restrictions that would block user overrides. |
| **1.4.13** | Content on hover/focus | ✅ PASS | Tooltips do not obscure content; no hover-only content. |
| **2.1.1** | Keyboard accessible | ✅ PASS | `FocusTraversalGroup` / `FocusTraversalOrder` used in forms and dialogs. All interactive elements are Flutter Material widgets with inherent focus support. |
| **2.1.2** | No keyboard trap | ✅ PASS | No custom focus traps detected. Dialogs use `AlertDialog`/`showModalBottomSheet` which Flutter handles correctly. |
| **2.4.3** | Focus order | ✅ PASS | `NumericFocusOrder` used explicitly in Create Tank, Equipment, Livestock Add screens. |
| **2.4.4** | Link purpose | ✅ PASS | `IconButton` tooltips and `Semantics.label` cover link purpose. |
| **2.4.7** | Focus visible | ✅ PASS | Flutter Material default focus rings present. |
| **2.5.3** | Label in name | ✅ PASS | `A11yLabels` helper ensures accessible names match visible labels. |
| **2.5.5** | Target size (minimum 44×44pt) | ⚠️ PARTIAL | Most `IconButton` widgets set `constraints: BoxConstraints(minWidth: 48, minHeight: 48)` via `app_navigation.dart`. Three areas below 48dp noted. |
| **3.1.1** | Language of page | ✅ PASS | Not directly testable in Flutter static analysis; no language override that would break TTS. |
| **3.2.1** | On focus | ✅ PASS | No context changes on focus detected. |
| **3.2.2** | On input | ✅ PASS | Form submissions are user-initiated. |
| **3.3.1** | Error identification | ✅ PASS | Error states include `Semantics(liveRegion: true)` in several screens; `SemanticsService.sendAnnouncement` used for quiz results. |
| **3.3.2** | Labels or instructions | ✅ PASS | `A11yLabels.textField()` with `required: true` annotations present in form screens. |

---

## 1. Semantic Labels

### Missing / At-Risk Image Labels

All `Image.asset` / `Image.file` / `Image.network` instances were audited. The `OptimizedImage` widget correctly passes through `semanticLabel` and auto-sets `excludeFromSemantics: semanticLabel == null`. **No unhandled images found** — all image usages either have a `semanticLabel` parameter or are wrapped in `ExcludeSemantics`.

**Status: ✅ PASS**

### `A11yLabels` / Semantics Utility Usage

- `lib/utils/accessibility_utils.dart` — dedicated utility with `A11yLabels`, `A11ySemantics`, `A11yFocus`, `A11yMerge`, `A11yExclude`
- **15 call sites** using `A11yLabels.*` across Create Tank flow
- **312 total** semantics / a11y annotations in non-test code
- `liveRegion: true` used in: streak overlay, learn screen, lesson completion, quiz widget, smart screen, bubble loader, hearts widget

### Remaining Gaps

| File | Line | Issue |
|------|------|-------|
| `lib/screens/settings/settings_screen.dart` | 1133 | `IconButton` (show/hide password) — no `tooltip` parameter |

---

## 2. Touch Targets

### Minimum Size Analysis (≥48dp required per Material / WCAG 2.5.5)

The core `AppNavButton` / `app_navigation.dart` correctly enforces:
```dart
constraints: const BoxConstraints(minWidth: 48, minHeight: 48)
```

All 54 `IconButton` instances in main screens include a `tooltip`. **Two exceptions found:**

| File | Line | Issue |
|------|------|-------|
| `lib/screens/settings/settings_screen.dart` | 1133 | Password visibility toggle `IconButton` — no tooltip and no explicit size constraints |
| `lib/widgets/core/app_button.dart` | 379 | `AppIconButton` constructor — needs review to confirm min constraints propagated |

### Small Interactive Areas

Three potential under-sized touch targets identified (below 48dp physical size):

| File | Line | Size | Context |
|------|------|------|---------|
| `lib/screens/home/widgets/tank_switcher.dart` | 51 | 36×36dp container inside `InkWell` | Tank switcher icon — `InkWell` wraps it but the tappable zone may not extend to 48dp |
| `lib/screens/shop_street_screen.dart` | 694 | 40dp within `GestureDetector` | Shop action element |
| `lib/widgets/gamification_dashboard.dart` | 103 | Wraps `Card` via `GestureDetector` | Full-card tap — likely ≥48dp due to card height, but no explicit min constraint |

> **Note:** Flutter `InkWell` by default only covers its child's bounding box. If the child is 36×36dp, the tap zone is 36×36dp — below the 48dp WCAG minimum. Recommend wrapping with `ConstrainedBox(constraints: BoxConstraints(minWidth: 48, minHeight: 48))`.

---

## 3. Colour Contrast

### ❌ FAILURES

| Colour | Usage | Context | Contrast | Required | Verdict |
|--------|-------|---------|----------|----------|---------|
| `AppColors.warning` (0xFFC99524) | Text foreground | `co2_calculator_screen.dart:398` — status label text | **2.69:1** on white | 4.5:1 | ❌ FAIL |
| `AppColors.warning` (0xFFC99524) | Text foreground | `livestock_last_fed.dart:28` — bodySmall text | **2.69:1** on white | 4.5:1 | ❌ FAIL |
| `AppColors.warning` (0xFFC99524) | Text foreground | `livestock_detail_screen.dart:63` — bodySmall text | **2.69:1** on white | 4.5:1 | ❌ FAIL |
| `AppColors.warning` (0xFFC99524) | Text foreground | `home/widgets/today_board.dart:46` — bodySmall text | **2.69:1** on white | 4.5:1 | ❌ FAIL |
| `AppColors.primaryLight` (0xFFD97706) | `bodySmall` text | `learn_streak_card.dart:63` on orange-tinted bg | **2.93:1** on `orange10` bg | 4.5:1 | ❌ FAIL |
| `AppColors.primaryLight` (0xFFD97706) | `bodySmall` text | `shop_street_screen.dart:739` | **3.19:1** on white | 4.5:1 | ❌ FAIL |
| `onSurface.withAlpha(153)` (~60% opacity) | Secondary label text | `analytics_stat_card.dart:61,84` — bodySmall/labelSmall | **3.73:1** on white | 4.5:1 | ❌ FAIL |
| `onSurface.withAlpha(153)` (~60% opacity) | Secondary label text | `analytics_topic_card.dart:51,96` — bodySmall | **3.73:1** on white | 4.5:1 | ❌ FAIL |

### ⚠️ BORDERLINE (passes large text / 3:1, fails normal text / 4.5:1)

| Colour | Contrast on white | Usage |
|--------|------------------|-------|
| `AppColors.warning` icons at 14dp | 2.69:1 | Icon-only indicators — **fails** non-text 3:1 too |
| `AppColors.primaryLight` | 3.19:1 | Only acceptable if used exclusively for **large text** (≥24pt or ≥18.67pt bold) |
| `AppColors.accentText` (0xFF3D7F88) | 4.24:1 on warm background | Barely fails — use on white (4.58:1) only |
| `AppColors.secondaryLight` (0xFF6B7F8E) | 3.86:1 on background | Fails for normal text; check actual usage context |

### ✅ PASSES

| Colour | Contrast | Usage |
|--------|----------|-------|
| `AppColors.primary` (0xFFB45309) on white | **5.02:1** | Primary brand text/icons |
| `AppColors.textPrimary` (0xFF2D3436) on white | ~**14:1** | Body text |
| `AppColors.textSecondary` (0xFF636E72) on white | **5.24:1** | Secondary body text |
| `AppColors.textHint` (0xFF5D6F76) on white | **5.25:1** | Hint text |
| `AppColors.success` (0xFF1E8449) on white | **7.3:1** | Success states |
| `AppColors.error` (0xFFC0392B) on white | **5.9:1** | Error states |
| `AppColors.info` (0xFF2E86AB) on white | **5.2:1** | Info states |
| `onSurface.withAlpha(178)` (~70% opacity) | **4.95:1** on white | `analytics_insight_card.dart` — PASS |
| `AppColors.onboardingAmberText` (0xFF9E6008) on warmCream | **4.83:1** | Onboarding amber text |

### Fix Recommendation for Warning Colour

`AppColors.warning` (0xFFC99524) is the single largest contrast failure. The comment in `app_colors.dart` claims "4.52:1 ratio" but the computed value is **2.69:1**. This appears to be an error in the original comment. Use `AppColors.primary` (0xFFB45309 — 5.02:1) or darken `warning` to approximately `0xFF8B6914` to achieve 4.5:1.

---

## 4. Reduced Motion

### ✅ EXCELLENT — Best-in-Class Implementation

The app has a **comprehensive and consistent** reduced motion implementation:

- **141 references** to `MediaQuery.of(context).disableAnimations` across non-test code
- Every animation widget checks this flag:
  - All celebration overlays: confetti, level-up, streak milestone, water change
  - Fish room: swimming fish, sparkle effects, water ripple, ambient plants
  - UI effects: shimmer glow, skeleton loaders, animated counters
  - Core widgets: `AppButton`, `AppCard`, `AppChip`, `GlassCard`, `PressableCard`
  - Onboarding flows: all 10+ screens check `disableAnimations`

**No animation widgets found that bypass this check.**

```dart
// Example of correct pattern used throughout:
final reduceMotion = MediaQuery.of(context).disableAnimations;
if (reduceMotion) return widget.child; // static fallback
```

---

## 5. Focus Order & Navigation

### ✅ PASS (with minor gaps)

**Strengths:**
- `FocusTraversalGroup` with `OrderedTraversalPolicy` used in:
  - `add_log_screen.dart` (line 214)
  - `create_tank_screen.dart` (line 90)
  - `equipment_screen.dart` (line 626)
  - `livestock_add_dialog.dart` (line 98)
  - `tank_settings_screen.dart` (line 111)
- `NumericFocusOrder` explicit sequencing in Create Tank wizard (basic_info, size_page, water_type_page)
- `autofocus: true` used correctly in dialogs and search screens
- `A11yFocus.createGroup()` utility available for consistent application

**Gaps:**
- Focus traversal only formally implemented in **form-heavy screens** — the main tab navigation, tank detail, and learn screen rely on Flutter's default traversal (reading order). This is acceptable for simple linear layouts but may be inconsistent in grid-based screens.
- `search_screen.dart` correctly uses `autofocus: true` — good.
- No detected focus traps.

---

## 6. Text Scaling

### ✅ PASS

- **No `textScaleFactor` clamping** found in the codebase — the app does not suppress system text scaling.
- All `maxLines: 1` usages (16 found) correctly pair with `overflow: TextOverflow.ellipsis` — text scales up but never clips invisibly.
- Layouts use `Expanded` / `Flexible` rather than fixed-width text containers.
- Fixed-size widgets (`SizedBox(height: 80)` etc.) are used only for spacing/decorative containers, not around text.

**Recommendation:** Verify at 200% system text scale on a physical device — charts (`charts_screen.dart`) and the room scene (`room_background.dart`) contain fixed-dimension custom painters that may not adapt to very large text sizes. These are ambient/decorative, so failure would not block functionality.

---

## Additional Accessibility Features Found

| Feature | Location | Quality |
|---------|----------|---------|
| `SemanticsService.sendAnnouncement()` | `lesson_quiz_widget.dart:321` | ✅ Screen reader result announcements |
| `liveRegion: true` | 15 locations | ✅ Dynamic content auto-announced |
| `MergeSemantics` | `accessibility_utils.dart:200` via `A11yMerge` | ✅ Complex widgets merged correctly |
| `ExcludeSemantics` | 49 locations | ✅ Decorative elements hidden from tree |
| `button: true` semantic role | Multiple widgets | ✅ Correct role assignment |
| `header: true` semantic role | Available in `A11ySemantics` | ⚠️ Not confirmed used — check section headers |
| Accessibility utilities | `lib/utils/accessibility_utils.dart` | ✅ Centralised and reusable |

---

## Prioritised Remediation List

### 🔴 Critical (WCAG AA Failures)

1. **`AppColors.warning` as text colour** — Fix the colour definition or replace with `AppColors.primary` for text uses. Affects 20+ files. The `app_colors.dart` comment claiming 4.52:1 is incorrect.

2. **`onSurface.withAlpha(153)` for `bodySmall` text** (`analytics_stat_card.dart:61,84`, `analytics_topic_card.dart:51,96`) — Increase opacity to `withAlpha(178)` (70%) which achieves 4.95:1.

3. **`AppColors.primaryLight` as `bodySmall` text** (`learn_streak_card.dart:63`, `shop_street_screen.dart:739`) — Replace with `AppColors.primary` (5.02:1) for small text.

### 🟡 Moderate (Partial Compliance)

4. **`tank_switcher.dart:51`** — Inner icon container is 36×36dp. Ensure the full `InkWell` click zone is at least 48×48dp by adding padding or `ConstrainedBox(constraints: BoxConstraints(minWidth: 48, minHeight: 48))`.

5. **`settings/settings_screen.dart:1133`** — Password visibility `IconButton` missing `tooltip`. Add `tooltip: 'Show/hide password'`.

6. **Warning icons at 14dp** (e.g., `today_board.dart:40`, `livestock_last_fed.dart:22`) — Small icons using `AppColors.warning` fail the 3:1 non-text contrast. Increase icon size to ≥18dp or use a higher-contrast colour.

### 🟢 Low (Best Practice)

7. **Section headers** — Audit use of `header: true` in `Semantics` for screen section titles. This aids TalkBack navigation by landmark.

8. **`AppColors.accentText` (0xFF3D7F88)** — 4.24:1 on warm background, 4.58:1 on white. Safe on white surfaces; avoid on warm-tinted cards.

9. **Charts screen** — Chart lines use colour only to differentiate data series. Ensure chart legend and tooltip text provide non-colour alternatives (currently partially implemented via `_LegendItem` labels).

10. **Keyboard/Switch Access on home/room scene** — The fish room (`living_room_scene.dart`) uses `GestureDetector` for fish taps. Confirm these are supplementary interactions with non-gesture equivalents.

---

## Score Breakdown

| Category | Score | Notes |
|----------|-------|-------|
| Semantic Labels | 9/10 | Near-complete; `A11yLabels` utility excellent |
| Touch Targets | 7/10 | Most correct; 2–3 under-size gaps |
| Colour Contrast | 4/10 | Warning amber is a systemic failure across 20+ files |
| Reduced Motion | 10/10 | Best-in-class; 141 checks throughout |
| Focus Order | 8/10 | Good in forms; implicit elsewhere |
| Text Scaling | 9/10 | No clamping; all overflow handled |

**Overall: 7 / 10**

The app is significantly more accessible than typical Flutter apps at this stage of development. The reduced motion implementation is exceptional. The primary blocker to full AA compliance is the `AppColors.warning` colour — fixing this single system colour would resolve the majority of contrast failures.
