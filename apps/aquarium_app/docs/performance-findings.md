# Performance Findings — T-D-261

**Audit date:** 2026-03-29  
**Branch:** `openclaw/stage-system`  
**Auditor:** Daedalus

---

## Summary

| Anti-pattern | Count | Severity | Status |
|---|---|---|---|
| `setState` calls (widgets + screens) | 385 | P1 | Deferred — needs profiling, most are legit |
| `BackdropFilter` usages | 15 | P1 | Deferred — several in hot paths |
| `AnimationController` usages | 206 | P2 | Deferred — verify no unbounded rebuilds |
| `.withOpacity()` calls | 0 | — | ✅ Already eliminated |
| `Image.asset` without `cacheWidth`/`cacheHeight` | 2 | P2 | ✅ Fixed (practice hub, unlock celebration) |

---

## TASK 1 Findings

### 1.1 `.withOpacity()` — CLEARED ✅
Zero calls found in app code (only doc comments in `app_colors.dart`). This was fixed in a prior wave. No action needed.

### 1.2 BackdropFilter — 15 usages (P1, Deferred)

GPU-heavy blur compositing. Found in:
- `lib/screens/gem_shop_screen.dart:382`
- `lib/screens/inventory_screen.dart:293`
- `lib/screens/shop_street_screen.dart:406, 505, 634`
- `lib/widgets/core/glass_card.dart:152` ← **shared widget, high impact**
- `lib/widgets/room/interactive_object.dart:294`
- `lib/widgets/speed_dial_fab.dart:96`
- `lib/widgets/stage/bottom_sheet_panel.dart:132`
- `lib/widgets/stage/stage_scrim.dart:77`
- `lib/widgets/stage/swiss_army_panel.dart:136`
- `lib/widgets/stage/tank_glass_badge.dart:64`
- `lib/widgets/stage/temperature/temperature_gauge.dart:752`
- `lib/widgets/stage/water_quality/water_param_card.dart:338`

**Recommendation:** On mid-range devices, each `BackdropFilter` forces a compositor layer. The `glass_card.dart` filter is reused widely — consider replacing with a `BoxDecoration` with subtle gradient + opacity instead of actual blur for non-critical cards. **Estimated effort:** 1–2 hours per component. Prioritise `glass_card.dart` first.

### 1.3 setState — 385 calls (P1, Deferred)

High count but not inherently problematic. Key question is whether any are in tight animation loops.

Known-good fixes already in place:
- ✅ `species_fish.dart` — uses `AnimatedBuilder` (no `setState` in animation loop)
- ✅ `animated_swimming_fish.dart` — uses `AnimatedBuilder`
- ✅ `fish_tap_interaction.dart` — uses `AnimatedBuilder`

**Next step:** Use Flutter DevTools > Performance tab to identify which widgets rebuild most frequently during the tank home screen scroll. No code changes until real profiling data available.

### 1.4 AnimationController — 206 usages (P2, Deferred)

206 controllers exist. The `tab_navigator.dart` correctly wraps all 5 tabs in `TickerMode(enabled: ...)` — animations on non-active tabs are paused. **Wave 2 fix confirmed working.** No regressions.

**Remaining risk:** Any screen that creates an `AnimationController` without `TickerMode` while off-screen. Needs profiling to confirm. Deferred.

### 1.5 Image loading — Quick wins applied ✅

Two `Image.asset` calls without `cacheWidth`/`cacheHeight` in hot paths:
- `lib/screens/practice_hub_screen.dart` — practice header illustration: added `cacheWidth: 480, cacheHeight: 320`
- `lib/screens/learn/unlock_celebration_screen.dart` — species sprite: added dynamic `(spriteSize * 2).toInt()`

Other uncached images checked — either not in hot paths, or already had cache hints.

---

## TASK 2 Design Token Replacements (R-059)

### Files changed

| File | Hardcoded values replaced |
|---|---|
| `lib/screens/practice_hub_screen.dart` | `Color(0xFFFFF5E8)` → `AppColors.background`; `Color(0xFFFFF0DE)` → `AppColors.surfaceVariant` |
| `lib/screens/home/widgets/empty_room_scene.dart` | `Color(0xFFD4A574)` → `DanioColors.studyGold`; `Color(0xFF5D4037)` → `DanioColors.workshopBackground1`; `Color(0xFF4E342E)` → `DanioColors.substrateSoil` |
| `lib/screens/onboarding/xp_celebration_screen.dart` | `Color(0xFFE8934A)` → `DanioColors.topaz`; `Color(0xFFD4A574)` → `DanioColors.studyGold` |
| `lib/screens/learn/unlock_celebration_screen.dart` | `Color(0xFFFFD700)` → `AppAchievementColors.gold` |
| `lib/widgets/celebrations/confetti_overlay.dart` | `Color(0xFFE8A84A)` → `DanioColors.topaz`; `Color(0xFFD97706)` → `AppColors.xp`; `Color(0xFFB45309)` → `AppColors.primary`; `Color(0xFF2A3548)` → `AppColors.secondaryDark`; `Color(0xFF8B6BAE)` → `AppColors.accentAlt`; `Color(0xFFD946EF)` → `DanioColors.levelUpFuchsia` |

**Total replacements: 13 hardcoded hex values → design tokens**

### Values left hardcoded (intentional / no exact token)

| Value | Location | Reason |
|---|---|---|
| `Color(0xFFC49664)` | `empty_room_scene.dart` floor gradient | No token — floor ambient, not reused elsewhere |
| `Color(0xFFE8D8C8)`, `Color(0xFFF0E4D4)` | `empty_room_scene.dart` window | No token — decorative only |
| `Color(0xD0FFA000)` | `streak_hearts_overlay.dart` | No 82%-alpha orange token; FFA000 ≠ any named colour |
| `Color(0xFFFFD54F)` | `xp_celebration_screen.dart` confetti | Golden yellow — no full-opacity token |
| `Color(0xFFFFE082)` | `confetti_overlay.dart` | Light gold — no exact token; noted in comment |
| `Color(0xFFA855F7)` | `confetti_overlay.dart` level-up | Violet — no token |
| `Color(0xFF22D3EE)` | `confetti_overlay.dart` level-up | Cyan — no token |
| Learn screen ocean blues | `learn_screen.dart` | File locked — not touched |

---

## Deferred Work

| ID | Description | Priority | Effort |
|---|---|---|---|
| PERF-01 | Profile tank home scroll with DevTools — identify top rebuilding widgets | P1 | 1h |
| PERF-02 | Replace `glass_card.dart` BackdropFilter with gradient-only approach | P2 | 2h |
| PERF-03 | Audit `setState` hot paths via DevTools rebuild overlay | P2 | 2h |
| TOKEN-01 | Add `Color(0xFFFFF0DE)` surfaceVariant variant or clean up near-match | P3 | 30min |
| TOKEN-02 | Add tokens for `Color(0xFF22D3EE)` cyan and `Color(0xFFA855F7)` violet | P3 | 30min |
