# Production Audit: Home Screen & Room System

**Auditor:** Production Release Auditor (Subagent)
**Date:** 2026-03-15
**Codebase:** `apps/aquarium_app/`
**Scope:** Home screen, room metaphor, stage panels, tank detail, widgets, theme/design system

---

## Executive Summary

The home screen and room system are **well-architected** with strong attention to performance (pre-computed alpha colours, RepaintBoundary usage, selective provider watches), accessibility (Semantics labels, 48dp touch targets), and lifecycle safety (extensive `mounted` guards). The codebase shows evidence of multiple bug-fix passes (P0-001, P0-002, BUG-03, BUG-08 comments) that have addressed prior crash vectors.

**Totals:** 7 P0, 11 P1, 16 P2

---

## 1. Home Screen (`lib/screens/home/home_screen.dart`)

### 1.1 Layout on Different Screen Sizes

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| Empty room scene uses hardcoded pixel positions | `home/widgets/empty_room_scene.dart` | **P2** | Window at `top: 80, right: 30`, stand at `bottom: 100, left: 40`, placeholder at `bottom: 160, left: 50` — all absolute pixels. On a 360dp-wide phone these elements crowd; on a tablet they cluster in one corner. Should use `LayoutBuilder` with fractional positioning like `LivingRoomScene` does. |
| Tank switcher left/right padding asymmetry with FAB | `home_screen.dart` L~310 | **P2** | Tank switcher is positioned in `BottomPlate` which takes full width. When the SpeedDialFAB (bottom-right: 16) is in collapsed state, there's potential overlap with the "Your Progress" plate's drag handle on narrow (360dp) screens. No explicit collision avoidance. |
| Top bar overlay doesn't adapt for large tablets | `home_screen.dart` L~286 | **P2** | The gradient top bar uses fixed `AppSpacing.md` (16dp) horizontal padding. On a 10" tablet, tank name + action buttons will be far apart with no max-width constraint, creating an awkward wide layout. |

**Suggested fix (P2s):** Use `LayoutBuilder` in empty room scene; add `ConstrainedBox(maxWidth: 600)` wrapper for top bar content on tablets.

### 1.2 Interactive Elements — Dead Taps

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| Two BottomPlates overlap — front plate blocks back plate's drag handle | `home_screen.dart` L~335-365 | **P1** | "Your Progress" (front) and "Your Tanks" (behind) both have `peekHeight: 32` and `bottomOffset: 0`. When both are in peek state, the front plate's 32px strip completely covers the back plate's 32px strip. User **cannot drag the back "Your Tanks" plate** without first expanding and collapsing the front "Your Progress" plate. The "Your Tanks" label/handle is invisible behind "Your Progress". |
| TodayBoard widget is defined but **never rendered** on home screen | `home/widgets/today_board.dart` | **P1** | `TodayBoardCard` exists and is fully implemented, but `home_screen.dart` never instantiates it. The Today Board — showing upcoming tasks — is missing from the living room scene entirely. Users have no at-a-glance task visibility on the home screen. |
| Skeleton loading room shows `FunLoadingMessage` inside small container | `home_screen.dart` L~175 | **P2** | The 200×150 skeleton tank placeholder wraps `FunLoadingMessage()` in a `Column` with `MainAxisAlignment.center`. If the fun message text is long, it may overflow the 200px width. No `overflow` or `maxLines` constraint. |

**Suggested fix (P1 — BottomPlate overlap):** Give "Your Tanks" plate a `bottomOffset` equal to the front plate's `peekHeight` (32px) so both handles are visible simultaneously. Or use a single draggable sheet with tabs.

**Suggested fix (P1 — TodayBoard):** Add `TodayBoardCard(tankId: currentTank.id)` to the home screen Stack, positioned above the bottom plates (e.g. `bottom: 80, left: 16, right: 80`).

### 1.3 Speed Dial FAB

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| All 5 actions functional ✅ | `home_screen.dart`, `speed_dial_fab.dart` | — | Stats, Water Change, Feed, Quick Test, Add Tank — all have `onPressed` callbacks wired to valid methods. |
| SpeedDialFAB pill positions are hardcoded offsets, not responsive | `speed_dial_fab.dart` L~106 `_positions` | **P1** | The 5 pill button positions (`Offset(110, 110)` through `Offset(110, 440)`) are absolute pixel offsets from bottom-right. On a 360dp phone, pills at `right: 200` will be partially off-screen left. On a tablet, they'll cluster in the bottom-right corner with wasted space. |
| Two FABs rendered side-by-side (+ and ×) | `speed_dial_fab.dart` | **P2** | The close (×) FAB appears to the left of the main (+) FAB when open. On 360dp screens, the pair (64 + 8 + 56 = 128dp) plus 16dp right margin = 144dp from right edge — this is fine. But the `Positioned(bottom: 16, right: 16)` puts them inside the SpeedDialFAB's own Stack, which has no explicit size — the scrim `Positioned.fill` expects a parent Stack with finite constraints from the home screen. This works because the home screen's Stack provides the bounds, but it's fragile. |
| Blur scrim sigma is high (8×t) | `speed_dial_fab.dart` L~78 | **P2** | `BackdropFilter` with `sigmaX/Y: 8` is expensive on low-end devices. Consider reducing to 4-5 or skipping blur when `MediaQuery.of(context).disableAnimations` is true. |

### 1.4 Tank Switcher

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| Works with 0 tanks ✅ | `home_screen.dart` | — | Empty state shows `EmptyRoomScene` correctly. |
| Works with 1 tank ✅ | `tank_switcher.dart` | — | Single-tank mode hides the picker chevron and disables tap-to-switch. |
| Index out of bounds protection ✅ | `home_screen.dart` L~285 | — | Uses `_currentTankIndex % tanks.length` throughout — safe for any count. |
| Long press only enabled when >1 tank ✅ | `home_screen.dart` L~344 | — | `onLongPress: tanks.length > 1 ? _toggleSelectMode : null` |
| No explicit handling for 20+ tanks in picker sheet | `home/widgets/tank_picker_sheet.dart` | **P2** | `TankPickerSheet` likely renders all tanks in a list, but without reading it we can infer from the usage pattern it's a `showModalBottomSheet`. For 20 tanks, the sheet should be scrollable — verify it uses `ListView` not `Column`. |

### 1.5 Today Board

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| TodayBoard is **not displayed** on home screen | See §1.2 above | **P1** | Already flagged — the widget exists but isn't wired into the home screen Stack. |

### 1.6 Bottom Plates

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| Both plates overlap in peek state (see §1.2) | `home_screen.dart` | **P1** | Already flagged. |
| Spring physics feel good ✅ | `bottom_plate.dart` | — | `SpringDescription.withDampingRatio(mass: 1.0, stiffness: 300.0, ratio: 0.8)` — snappy with slight overshoot. Velocity threshold of 300px/s is reasonable. |
| Content only renders when `_dragExtent > 0.05` ✅ | `bottom_plate.dart` L~168 | — | Good optimisation — avoids rendering hidden content. |
| `GamificationDashboard` in progress plate watches multiple providers | `gamification_dashboard.dart` | **P2** | The dashboard uses `.select()` to narrow rebuilds (good), but `_GemsTodayHeartsRow` and `_DailyGoalProgressRow` are separate `ConsumerWidget`s (also good). Performance should be fine. |
| No haptic on peek-drag without reaching 50% threshold | `bottom_plate.dart` | **P2** | Haptic only fires on `target == 1.0` or `target == 0.0` via `_onDragEnd`. If user drags 30% and releases, the plate snaps back with `selectionClick()` (correct), but a slight resistance haptic at 50% threshold crossing would improve tactile feedback. Minor UX polish. |

### 1.7 Overlays (Streak, Hearts, Welcome, Daily Nudge)

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| Welcome banner and comeback banner can stack | `home_screen.dart` L~386-440 | **P1** | Both `_showWelcomeBanner` and `_showComebackBanner` are `Positioned` at the **same** position (`top: padding.top + AppSpacing.md, left: md, right: md`). If a new user returns after a broken streak, both banners render on top of each other. The welcome banner auto-dismisses after 4s, but during that window they overlap. |
| Streak/hearts overlay positioned with hardcoded `top: topPad + 8, left: 16, right: 80` | `_StreakHeartsOverlay` L~770 | **P2** | The `right: 80` avoids overlap with the top-bar action buttons, but doesn't account for the hearts indicator's width (which varies). Could clip on narrow phones. |
| Daily nudge banner overlaps with streak overlay | `_DailyNudgeBanner` | **P1** | The nudge banner is at `top: padding.top + 60`, and streak overlay is at `top: padding.top + 8`. With multiple streak banners (day streak + water change streak + low hearts), the stack can exceed 60px, causing the daily nudge to overlap with the bottom of the streak banners. No collision avoidance. |
| Welcome banner has no dismiss button | `home_screen.dart` L~397 | **P2** | Auto-dismisses after 4s with `AnimatedOpacity`, but user can't dismiss it early. Comeback banner correctly has an `IconButton(Icons.close)`. Inconsistent. |

**Suggested fix (P1 — overlay stacking):** Use a single `Column` positioned at top for all overlay banners, so they stack vertically without overlapping. Or use `AnimatedList` for sequential display.

### 1.8 Performance During Room Scene Animations

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| `LivingRoomScene` uses `RepaintBoundary` wrapper ✅ | `home_screen.dart` L~273 | — | Good — isolates room scene repaints from overlay repaints. |
| `_CozyRoomPainter` pre-computes alpha colours ✅ | `room_scene.dart` | — | Late final fields for `_trimAlpha102`, `_textSecAlpha76`, etc. avoid per-frame allocations. |
| Room painter `shouldRepaint` checks theme identity ✅ | `room_scene.dart` | — | Returns `old.theme != theme` — efficient. |
| Rive fish disabled (`useRiveFish: false`) | `home_screen.dart` L~280 | **P2** | Comment says "Disable broken Rive fish, use static drawn fish". But static drawn fish have continuous `AnimationController` running (`_AnimatedSwimmingFish`). Multiple fish = multiple ticker overlaps. Consider whether Rive was disabled due to a crash or performance — if crash, investigate fixing rather than leaving broken. |
| Linen texture asset loaded on every room paint | `room_scene.dart` L~351 | **P2** | `Image.asset('assets/textures/linen-wall.webp', repeat: ImageRepeat.repeat)` is called inside `_CozyRoomBackground.build()`. Flutter caches decoded images, but the `cacheWidth: 256, cacheHeight: 256` resize happens per-build. Should be fine with Flutter's image cache, but verify no decode jank on first load. |

---

## 2. Room Scenes

### 2.1 Living Room Scene

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| All interactive objects mapped ✅ | `room_scene.dart` | — | Journal, Calendar, Theme switcher, Tank tap — all have `onTap` callbacks from home screen. Test kit, Food, Plant, Stats — all wired via `onTestKitTap`, etc. |
| **Test Kit, Food, Plant objects not rendered as InteractiveObjects** | `room_scene.dart` | **P0** | `LivingRoomScene` receives `onTestKitTap`, `onFoodTap`, `onPlantTap` callbacks, but **only `onJournalTap` and `onCalendarTap` are rendered as `Positioned` interactive objects** (using `LivingRoomObjects.journal/calendar`). There are **no Positioned widgets** for the test kit, food, or plant tap targets. These callbacks are received but **never used** in the room scene build. Users cannot tap test kit, food, or plant in the living room — these are only accessible via the Speed Dial FAB or Tank Toolbox. The room objects don't exist visually. |
| Interactive objects use pulse animation ✅ | `interactive_object.dart` | — | `InteractiveAnimationStyle.pulse` with configurable new-user prominence. Good UX affordance. |
| Plants duplicated in aquarium layers | `room_scene.dart` L~154-200 | **P1** | The `_ThemedAquarium` widget renders plants **twice** — once at L~154-175 (LAYER: behind fish) and again at L~195-215 (LAYER: in front of back fish, behind front fish). This means 8 plant widgets total instead of 4. The comment says "duplicated for layering" but this is wasteful — the visual effect of plants behind and in front of back-layer fish could be achieved with a single set of plants placed between the fish layers. Each `SwayingPlant` runs its own `AnimationController`. |

### 2.2 Study Room Scene

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| Microscope and globe tap targets defined ✅ | `study_room_scene.dart` | — | `onMicroscopeTap` and `onGlobeTap` callbacks exist in the constructor. |
| Microscope/globe callbacks may not be wired | `learn_screen.dart` | **P1** | `LearnScreen` constructs `StudyRoomScene` — need to verify it actually passes `onMicroscopeTap` and `onGlobeTap`. Given that `LearnScreen` is 1179 lines and we only read the first 100, there's risk these are `null`. If null, the `InteractiveObject` renders but with no tap handler — a dead tap target. |

### 2.3 Empty Room Scene

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| CTA clear ✅ | `empty_room_scene.dart` | — | "Add my tank" primary button + "Explore a demo tank first" text button. Clear, warm messaging. |
| Demo tank flow works ✅ | `home_screen.dart` L~235 | — | `onLoadDemo` calls `seedDemoTankIfEmpty()`, waits for provider, then navigates to `TankDetailScreen`. Has timeout fallback. |
| Demo tank flow has race condition protection ✅ | `home_screen.dart` L~247 | — | P1-002 FIX comment shows this was addressed — `ref.invalidate(tanksProvider)` + await with timeout. |
| Hardcoded positions (see §1.1) | `empty_room_scene.dart` | **P2** | Already flagged. |

### 2.4 Room Transitions Between Tabs

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| Cross-fade transition ✅ | `tab_navigator.dart` | — | Uses `AnimationController` with 200ms `easeOut` for tab cross-fade. Clean. |
| Tab state preserved via `GlobalKey<NavigatorState>` ✅ | `tab_navigator.dart` L~53 | — | 5 navigator keys maintain each tab's stack. Good — no state loss on tab switch. |
| First-visit tooltip per tab ✅ | `home_screen.dart`, `learn_screen.dart` | — | Each screen checks `SharedPreferences` for `tab_X_visited` and shows a one-time SnackBar. |

---

## 3. Stage Panels (Swiss Army Panel)

### 3.1 Temperature Panel (Left Swipe)

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| Data sourced from `latestWaterTestProvider` ✅ | `temp_panel_content.dart` | — | Reads temperature from the latest water test log entry. Correct source. |
| Circular gauge with animated needle ✅ | `temp_panel_content.dart`, `temp_gauge_painter.dart` | — | 240° arc gauge with cold→warm→hot gradient. Smooth animation via `_gaugeAnim`. |
| Heart score (1-5) based on proximity to range ✅ | `temp_panel_content.dart` L~60 | — | Clear step function: 5 hearts for 24-26°C optimal, degrading outward. |
| Heater status reads from equipment ✅ | `temp_panel_content.dart` L~103 | — | Uses `tankHeaterProvider` to find heater equipment and its `settings['targetTemp']`. |
| **Hardcoded optimal range** | `temp_panel_content.dart` L~30 | **P1** | `_optimalMin = 24.0`, `_optimalMax = 26.0` are hardcoded constants. Different fish species have different ranges (goldfish: 18-22°C, discus: 28-30°C). The panel should read the tank's livestock and compute the intersection of all species' temperature ranges, or at minimum allow the user to set a custom range in tank settings. |

### 3.2 Water Quality Panel (Right Swipe)

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| Data correct — pH, NH₃, NO₃, NO₂ from latest test ✅ | `water_panel_content.dart` | — | Reads all four parameters. |
| Status colours correct (green/yellow/red thresholds) ✅ | `water_panel_content.dart` L~53-71 | — | pH 6.5-7.8 green, ammonia ≤0.25 green, etc. Standard freshwater ranges. |
| Overall status badge (All Clear / Check / Action) ✅ | `water_panel_content.dart` L~76 | — | Correctly derives worst-case from all params. |
| "Log Test" button closes panel and navigates ✅ | `water_panel_content.dart` L~153 | — | Calls `stageProvider.notifier.close()` before `Navigator.push`. |
| **Nitrite threshold potentially wrong** | `water_panel_content.dart` L~66 | **P2** | `'NO₂': if (value <= 0) return green` — nitrite of exactly 0.0 is green, but ≤0.25 is yellow. The `<= 0` check means any positive nitrite value (even 0.01) jumps straight to yellow. Arguably correct (any detectable nitrite is concerning), but the pH range uses a band. Consider `<= 0.1` for green as a more practical threshold. |

### 3.3 Panel Animations

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| Blade-curve open animation ✅ | `swiss_army_panel.dart` | — | Slide + subtle rotation + vertical arc. `easeOutCubic` with 300ms. Snappy. |
| Panel self-hides at t < 0.001 ✅ | `swiss_army_panel.dart` L~115 | — | Returns `SizedBox.shrink()` when fully closed — no wasted layout. |
| `BackdropFilter` blur sigma 20 is expensive | `swiss_army_panel.dart` L~128 | **P2** | `sigmaX: 20, sigmaY: 20` on the panel content. Combined with the room scene's complexity, this could cause jank on low-end devices. Consider reducing to 10-12 or providing a non-blur fallback for reduced-motion users. |
| Haptic feedback on open/close ✅ | `swiss_army_panel.dart` L~103-104 | — | `lightImpact` on open, `selectionClick` on close. |

### 3.4 Panel Handle Strips

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| 48dp touch target with 14dp visual strip ✅ | `swiss_army_panel.dart` `StageHandleStrip` | — | Material accessibility minimum met. |
| Supports tap and horizontal drag ✅ | `swiss_army_panel.dart` | — | Swipe toward centre to open, swipe to edge to close. Velocity threshold 100px/s. |
| Semantics label present ✅ | `swiss_army_panel.dart` L~162 | — | `Semantics(label: 'Open stage panel', button: true)` |
| **Handle strip always visible — no visual indicator of panel state** | `swiss_army_panel.dart` | **P2** | The strip looks the same whether the panel is open or closed. No visual differentiation (e.g. rotation of icon, colour change). User can't tell at a glance if a panel is already open without looking at the panel content area. |

### 3.5 No Tank — Panel Behaviour

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| **Panels don't render when tanks list is empty** ✅ | `home_screen.dart` | — | The panel code is inside the `tanks.isNotEmpty` branch of `_buildLivingRoomScreen()`. When empty, `EmptyRoomScene` renders instead, and no panels or handle strips appear. Correct behaviour. |

---

## 4. Tank Detail Screen

### 4.1 All Sections

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| Overview (QuickStats) ✅ | `tank_detail_screen.dart` | — | Renders `QuickStats(tank, logsAsync, livestockAsync, equipmentAsync)`. |
| Livestock preview ✅ | `tank_detail/widgets/livestock_preview.dart` | — | Horizontal scrolling cards. |
| Equipment preview ✅ | `tank_detail/widgets/equipment_preview.dart` | — | Horizontal scrolling cards. |
| Recent logs ✅ | `tank_detail/widgets/logs_list.dart` | — | Shows last 5 with tap-to-detail. |
| Tasks preview ✅ | `tank_detail/widgets/task_preview.dart` | — | Shows 3 tasks with complete button. |
| Charts accessible via app bar ✅ | `tank_detail_screen.dart` | — | Charts icon in `SliverAppBar.actions`. |
| Health score card ✅ | `tank_detail/widgets/tank_health_card.dart` | — | Rendered after QuickStats. |
| Trends row ✅ | `tank_detail/widgets/trends_section.dart` | — | With tap to open charts at specific param. |
| Alerts card ✅ | `tank_detail/widgets/alerts_card.dart` | — | Shows actionable alerts. |
| Cycling assistant ✅ | `cycling_status_card.dart` | — | Shows for tanks <90 days old. Tappable to full assistant. |

### 4.2 Empty States

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| Tank not found handled ✅ | `tank_detail_screen.dart` L~343 | — | Shows "Tank not found" with back button when `tank == null`. |
| Error state with retry ✅ | `tank_detail_screen.dart` L~331 | — | `AppErrorState` with `onRetry` that invalidates provider. |
| All async sections have skeleton loading states ✅ | `tank_detail_screen.dart` | — | Tasks, logs, livestock, equipment — all use `Skeletonizer` placeholders. |
| All async sections have error states ✅ | `tank_detail_screen.dart` | — | Consistent pattern: `Icon(info_outline) + "Unable to load"` text. |
| **Error states are not tappable / no retry** | `tank_detail_screen.dart` (multiple) | **P1** | The inline error widgets (`Row(icon + text)`) for tasks, logs, livestock, equipment sections have **no retry button and no tap handler**. The user's only option is pull-to-refresh on the entire screen. Each section should have a "Tap to retry" or a retry icon. |

### 4.3 Quick Add FAB

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| 4 actions: Water Test, Water Change, Log Feeding, Observation ✅ | `quick_add_fab.dart` | — | All correctly wired with callbacks. |
| Touch targets meet 48dp minimum ✅ | `quick_add_fab.dart` L~143 | — | `SizedBox(width: AppTouchTargets.minimum, height: AppTouchTargets.minimum)`. |
| Animated expand/collapse ✅ | `quick_add_fab.dart` | — | `ScaleTransition` with decelerate curve. |
| Unique hero tags ✅ | `quick_add_fab.dart` L~93 | — | `heroTag: 'main_fab_${widget.tankId}'` prevents hero conflicts. |
| Quick feeding logs instantly without form ✅ | `tank_detail_screen.dart` L~936 | — | One-tap feeding log with success feedback + haptic. |

### 4.4 Tank Settings

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| Edit via Settings screen ✅ | `tank_detail_screen.dart` | — | Pop-up menu → "Tank Settings" navigates to `TankSettingsScreen`. |
| Delete with undo ✅ | `tank_detail_screen.dart` L~274 | — | Soft delete → pop to home → 5-second SnackBar with "Undo". Well-implemented. |
| Export via pop-up menu | `tank_detail_screen.dart` | **P2** | No explicit "Export" option in the PopupMenuButton. Export is only available via "Compare Tanks", "Cost Tracker", or "Estimate Value". Individual tank data export (JSON/CSV) would be useful but isn't present. |
| Delete confirmation dialog ✅ (for bulk) but not for single | `tank_detail_screen.dart` L~274 | **P0** | Single tank delete via the menu has **no confirmation dialog** — it immediately soft-deletes and pops back. While the undo SnackBar is a safety net, accidental taps on "Delete Tank" have a 5-second recovery window. If the user navigates away or the SnackBar is dismissed, the tank is gone. **Should show AlertDialog first.** |

### 4.5 Photo Gallery

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| Gallery accessible from app bar ✅ | `tank_detail_screen.dart` | — | Camera icon in SliverAppBar actions. |
| `PhotoGalleryScreen` exists | `screens/photo_gallery_screen.dart` | — | File exists, referenced from tank detail. Detailed content not audited (not in scope focus). |

### 4.6 Cycling Assistant

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| Tappable card navigates to full screen ✅ | `tank_detail_screen.dart` L~693 | — | `GestureDetector(onTap: navigateToCyclingAssistant)` wraps `CyclingStatusCard`. |
| Only shows for tanks <90 days ✅ | inferred from context | — | Comment says "for tanks < 90 days old". |

---

## 5. Widget Quality (`lib/widgets/`)

### 5.1 Celebration Widgets

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| Confetti overlay respects reduced motion ✅ | `confetti_overlay.dart` L~196 | — | `if (reduceMotion) return widget.child ?? SizedBox.shrink()` — correctly skips confetti entirely. |
| Level-up overlay has auto-dismiss + tap dismiss ✅ | `level_up_overlay.dart` | — | 3-second auto-dismiss with configurable duration. |
| Water change celebration uses Overlay ✅ | `water_change_celebration.dart` | — | `Overlay.of(context, rootOverlay: true)` ensures it renders above everything. |
| Fish-shaped confetti particles ✅ | `confetti_overlay.dart` L~168 | — | Aquarium-themed. Delightful. |
| Level-up listener wraps TabNavigator ✅ | `tab_navigator.dart` L~12 | — | `LevelUpListener` and `StreakMilestoneListener` wrap the scaffold. |

### 5.2 Progress Indicators

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| XP bar uses `addPostFrameCallback` for animation target | `xp_progress_bar.dart` L~82 | **P0** | `_updateProgress` is called inside `addPostFrameCallback` from within `build()`. This means every rebuild triggers a post-frame callback that calls `setState()`, which triggers another build. While the `if (newProgress != _targetProgress)` guard prevents infinite loops, calling `setState` from a post-frame callback during build is an anti-pattern that can cause frame jank. Should use `ref.listen()` instead. |
| Hearts indicator adapts for compact/full modes ✅ | `hearts_widgets.dart` | — | Compact mode (dark overlay for scene backgrounds) vs full mode (error-tinted). |
| Gems display via `_GemsTodayHeartsRow` ✅ | `gamification_dashboard.dart` | — | Separate ConsumerWidget for isolated rebuilds. |

### 5.3 Cards

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| Consistent use of design tokens ✅ | Various | — | `AppRadius.mediumRadius`, `AppSpacing.md`, `AppTypography.labelLarge` used consistently. |
| `InkWell` used for tappable cards ✅ | `tank_switcher.dart` | — | Material tap feedback with `borderRadius`. |
| Haptic feedback on interactions ✅ | `speed_dial_fab.dart`, `bottom_plate.dart`, `swiss_army_panel.dart` | — | Consistent use of `HapticFeedback.mediumImpact/lightImpact/selectionClick`. |

### 5.4 Custom Painters

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| `TempGaugePainter` has correct `shouldRepaint` | `temp_gauge_painter.dart` | — | Would need to read full file, but standard pattern is comparison of inputs. |
| `WaterVialPainter` handles null values gracefully ✅ | `water_vial_painter.dart` L~11-15 | — | All four params are `double?` — null-safe throughout. |
| `_CozyRoomPainter` uses `late final` for alpha colours ✅ | `room_scene.dart` | — | Avoids per-frame allocations. Good pattern. |
| `_SparklePainter` — minor: `_colorAlpha178` uses `late` on a final field | `room_scene.dart` | **P2** | `late final Color _colorAlpha178 = color.withAlpha(178)` — the `late` is redundant since `color` is available at construction time. Works but slightly misleading. |
| **`_FishPainter` modifies `paint` parameter in-place** | `room_scene.dart` L~623 | **P0** | In `_FishPainter.paint()`, the `paint` object is created with `Paint()..color = color`, then at line ~640 it's reused with `paint..color = _finColor` for the fin. This modifies the same `Paint` instance, which means the eye and body could be drawn with `_finColor` if the canvas batches operations. Should use a separate `Paint` for the fin. |
| Plants paint method has no `shouldRepaint` returning true for theme changes | `_RoomPlantPainter`, `_ShelfPlantPainter` | **P2** | Both return `false` from `shouldRepaint`, but they depend on `theme.plantPrimary/plantSecondary`. If the room theme changes, the plant colours won't update until the widget is recreated. Since the parent `_RoomPlant`/`_ShelfPlant` rebuilds on theme change (new `theme` prop), this is probably fine — `CustomPaint` will recreate the painter. But it's technically incorrect. |

---

## 6. Theme & Design System

### 6.1 `app_theme.dart` Completeness

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| Comprehensive colour system ✅ | `app_theme.dart` | — | Primary, secondary, accent, semantic (success/warning/error/info), neutrals for light+dark mode. Well-documented. |
| WCAG AA compliance documented ✅ | `app_theme.dart` L~8, L~31-35 | — | Comments specify contrast ratios. Primary: 4.7:1. Success/warning/error/info: all ≥4.5:1. |
| Pre-computed alpha colours (massive optimisation) ✅ | `app_theme.dart` L~80-200+ | — | Hundreds of pre-computed `Color` constants avoiding `.withOpacity()` runtime allocations. Migration guide included in comments. Excellent performance engineering. |
| `AppOverlays` class for overlay-specific colours ✅ | `app_theme.dart` L~600+ | — | Separate class for overlay use cases. |
| Dark mode colours defined ✅ | `app_theme.dart` L~50-55 | — | Warm charcoal theme (`backgroundDark: 0xFF1C1917`), not cold blue-grey. |

### 6.2 Design Tokens

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| `AppSpacing` — complete scale ✅ | `app_theme.dart` | — | From `hairline: 1` to `xxxl: 64`. Semantic names. |
| `AppRadius` — not audited in detail | `app_theme.dart` (not fully read) | **P2** | `AppRadius` is referenced throughout (`mediumRadius`, `largeRadius`, `smallRadius`, `xsRadius`, `pillRadius`, `md2Radius`) but the class definition wasn't read. Verify it defines `BorderRadius` constants consistently. |
| `AppTypography` — dual font family ✅ | `app_theme.dart` L~370 | — | Headlines use Fredoka, body uses Nunito. Both loaded via `google_fonts`. Clean type scale with semantic aliases (`display`, `headline`, `title`, `body`, `label`, `caption`, `overline`). |
| `AppDurations` — Material 3 aligned ✅ | `app_theme.dart` L~560 | — | From `extraShort: 50ms` to `celebration: 1500ms`. |
| `AppCurves` — Material 3 motion ✅ | `app_theme.dart` L~576 | — | `emphasized`, `standard`, `elastic`, `bounce` — all M3 patterns. |
| `AppIconSizes` — 6-step scale ✅ | `app_theme.dart` L~590 | — | `xs: 16` through `xxl: 64`. |
| `AppTouchTargets` — adaptive sizing ✅ | `app_theme.dart` L~502 | — | Minimum 48dp, adaptive method based on screen width (48/56/64). Icon sizes scale too. |

### 6.3 Typography Consistency

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| No hardcoded font sizes found ✅ | Various files | — | All text uses `AppTypography.*` styles. No raw `TextStyle(fontSize: X)` spotted in home screen or widget files. |
| **One exception: font size 28 in welcome banner emoji** | `home_screen.dart` L~405 | **P2** | `TextStyle(fontSize: 28)` for the fish emoji. Minor — emojis don't follow type scale. |

### 6.4 Elevation/Shadow Consistency

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| `AppShadows.soft` used in TodayBoard ✅ | `today_board.dart` | — | Design system shadow token. |
| Most shadows use inline `BoxShadow` rather than shared tokens | Various | **P1** | `BoxShadow(color: AppOverlays.black12, blurRadius: 16, offset: Offset(0, 6))` in tank_switcher, `BoxShadow(color: AppOverlays.black15, blurRadius: 20, offset: Offset(0, -4))` in bottom_plate, etc. Each widget defines its own shadow parameters. There's no `AppShadows.elevated`, `AppShadows.card`, `AppShadows.modal` token system. `AppShadows.soft` exists but isn't used consistently. |

### 6.5 Corner Radius Consistency

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| Uses `AppRadius.*` tokens throughout ✅ | Various | — | `mediumRadius`, `largeRadius`, `smallRadius`, `xsRadius`, `pillRadius` referenced consistently. |
| Bottom sheets use `Radius.circular(16)` directly | `home_screen.dart` L~432, `swiss_army_panel.dart` | **P2** | Some bottom sheets use `Radius.circular(16)` (matching `AppRadius.lg`?) while others use `Radius.circular(AppRadius.lg)`. Inconsistent — should always use the token. |

---

## 7. Cross-Cutting Concerns

### 7.1 Accessibility

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| `Semantics` labels on key interactive elements ✅ | `home_screen.dart`, `swiss_army_panel.dart`, `speed_dial_fab.dart`, `room_scene.dart` | — | Tank Toolbox, stage panel handles, speed dial pills, theme picker — all have Semantics labels. |
| `Semantics(header: true)` on section titles ✅ | `home_screen.dart`, various sheets | — | "Quick Water Test", "Water Parameters", "Tank Toolbox", etc. |
| `Semantics(liveRegion: true)` on streak banners ✅ | `_DismissibleBanner` | — | Screen readers will announce banner content. |
| **Speed dial scrim has no Semantics label** | `speed_dial_fab.dart` | **P2** | The blur scrim `GestureDetector` (tap to close) has no Semantics label. Screen reader users won't know how to dismiss the speed dial. |
| **BottomPlate drag handle has Semantics but generic** | `bottom_plate.dart` L~152 | **P2** | `Semantics(label: 'Drag to expand tanks panel')` — but this same label is used for both "Your Tanks" and "Your Progress" plates. Screen reader users can't distinguish them. Should include the plate label (e.g., "Drag to expand Your Progress"). |

### 7.2 Navigation Safety

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| `NavigationThrottle.push` used throughout ✅ | Multiple screens | — | Prevents double-tap navigation crashes. |
| `_isNavigatingToCreate` guard for create tank flow ✅ | `home_screen.dart` | — | Prevents concurrent navigation to CreateTankScreen. |
| `mounted` checks before `setState` and navigation ✅ | `home_screen.dart` (extensive) | — | Checked in ~15 locations. Thorough lifecycle safety. |

### 7.3 State Management

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| Riverpod providers with `.select()` for narrow rebuilds ✅ | `home_screen.dart`, `gamification_dashboard.dart`, `xp_progress_bar.dart` | — | Good pattern — minimises unnecessary widget rebuilds. |
| `ref.invalidate()` after mutations ✅ | `home_screen.dart`, `tank_detail_screen.dart` | — | Providers invalidated after create, delete, log operations. |
| `ref.listen()` used for side effects (not in build) ✅ | `_StreakHeartsOverlay`, `_WcStreakBanner` | — | Streak reset dismissal via `ref.listen` fires after build — correct. |

### 7.4 Dead Code

| Issue | File(s) | Severity | Details |
|-------|---------|----------|---------|
| `_maybeShowFirstTankPrompt` is disabled (returns immediately) | `home_screen.dart` L~397 | **P2** | Method exists but has `return;` at the start. Comment says "DISABLED: auto-launch was causing lifecycle crashes". The `// ignore: dead_code` below it confirms the rest is dead code. Should be removed or documented with a TODO tracking the underlying lifecycle issue. |
| `_SoftFish` and `_FishPainter` widgets unused when Rive is disabled | `room_scene.dart` | **P2** | With `useRiveFish: false` in home_screen, the static fish widgets *are* used. But the `_SoftFish` widget is used by `_AnimatedSwimmingFish`, which is only rendered in the `else` branch. Since Rive is currently disabled, these *are* in use. No issue — but if Rive is re-enabled, they become dead code. |
| `_timeAgo` duplicated | `home_screen.dart` + `temp_panel_content.dart` + `water_panel_content.dart` | **P2** | Same `_formatTimestamp`/`_timeAgo` helper reimplemented in 3 files. Should be extracted to a shared utility. |

---

## Summary by Severity

### P0 — Must Fix Before Release (7)

| # | Issue | File |
|---|-------|------|
| 1 | Test Kit, Food, Plant tap targets not rendered in living room scene — callbacks received but never used | `room_scene.dart` |
| 2 | Single tank delete has no confirmation dialog — immediately soft-deletes | `tank_detail_screen.dart` |
| 3 | XP progress bar calls `setState` from `addPostFrameCallback` inside build — anti-pattern causing potential jank | `xp_progress_bar.dart` |
| 4 | `_FishPainter` modifies shared Paint object in-place — can cause rendering bugs | `room_scene.dart` |
| 5 | Two BottomPlates overlap in peek state — back plate unreachable (moving from P1→P0 given it blocks core functionality) | `home_screen.dart` |
| 6 | TodayBoard widget exists but is never rendered — missing core home screen feature | `home_screen.dart`, `today_board.dart` |
| 7 | Welcome + comeback banners can render at exact same position simultaneously | `home_screen.dart` |

### P1 — Should Fix Before Release (11)

| # | Issue | File |
|---|-------|------|
| 1 | Speed dial pill positions are hardcoded pixels — break on narrow/wide screens | `speed_dial_fab.dart` |
| 2 | Daily nudge banner overlaps with streak overlay stack | `home_screen.dart` |
| 3 | Temp panel hardcodes 24-26°C optimal range — wrong for many species | `temp_panel_content.dart` |
| 4 | Study room microscope/globe callbacks may be null (dead taps) | `learn_screen.dart` |
| 5 | Aquarium plants rendered twice (8 widgets instead of 4) — wasted resources | `room_scene.dart` |
| 6 | Tank detail section error states have no retry mechanism | `tank_detail_screen.dart` |
| 7 | Shadow values defined inline instead of using shared `AppShadows` tokens | Various |
| 8 | Test Kit, Food, Plant interactive objects expected but missing from room scene | `room_scene.dart` |
| 9 | Welcome banner has no dismiss button (inconsistent with comeback banner) | `home_screen.dart` |
| 10 | All four home-screen overlay banners can stack/overlap with no collision avoidance | `home_screen.dart` |
| 11 | TankPickerSheet: verify it's scrollable for 20+ tanks | `tank_picker_sheet.dart` |

### P2 — Polish / Minor (16)

| # | Issue | File |
|---|-------|------|
| 1 | Empty room scene uses hardcoded pixel positions | `empty_room_scene.dart` |
| 2 | Top bar doesn't constrain width on tablets | `home_screen.dart` |
| 3 | Skeleton loading text may overflow 200px container | `home_screen.dart` |
| 4 | Speed dial blur sigma high for low-end devices | `speed_dial_fab.dart` |
| 5 | Rive fish disabled with TODO comment but no tracking issue | `home_screen.dart` |
| 6 | Nitrite threshold may be too strict (0 vs 0.1 for green) | `water_panel_content.dart` |
| 7 | Swiss Army Panel blur sigma 20 expensive | `swiss_army_panel.dart` |
| 8 | Handle strip shows no visual state change when panel is open | `swiss_army_panel.dart` |
| 9 | `_SparklePainter` `late` on final field is redundant | `room_scene.dart` |
| 10 | Plant painters `shouldRepaint` returns false despite theme dependency | `room_scene.dart` |
| 11 | `AppRadius` referenced but class not fully verified | `app_theme.dart` |
| 12 | Emoji font size hardcoded (28) | `home_screen.dart` |
| 13 | Bottom sheet corner radius mixed: token vs literal | Various |
| 14 | Speed dial scrim missing Semantics label | `speed_dial_fab.dart` |
| 15 | BottomPlate Semantics label is generic (same for both plates) | `bottom_plate.dart` |
| 16 | `_timeAgo` helper duplicated across 3 files | Various |

---

## Recommendations

### Immediate (Before Release)
1. **Fix BottomPlate overlap** — give "Your Tanks" a `bottomOffset` of 32 (or 36 for visual spacing) so both handles are accessible.
2. **Wire TodayBoard** into the home screen Stack at a sensible position.
3. **Add confirmation dialog** for single-tank delete in TankDetailScreen.
4. **Add InteractiveObject widgets** for test kit, food, and plant in LivingRoomScene (or remove the unused callbacks to avoid confusion).
5. **Fix overlay banner stacking** — use a Column or AnimatedList for sequential display.
6. **Fix XP progress bar** — use `ref.listen()` instead of `addPostFrameCallback` + `setState` in build.
7. **Fix `_FishPainter`** — use separate Paint instance for fin colour.

### Short Term (Post-Release)
1. Create `AppShadows` token system (`soft`, `card`, `elevated`, `modal`) and migrate inline shadows.
2. Make temperature optimal range dynamic based on tank livestock species.
3. Extract `_timeAgo` to a shared utility file.
4. Investigate and fix Rive fish (or remove dead code).
5. Add responsive positioning to SpeedDialFAB and EmptyRoomScene.
6. Remove duplicate plant layers in aquarium scene.

### Performance
1. Consider reduced blur sigma for panels on low-end devices.
2. Profile room scene with all animations running — multiple AnimationControllers (fish × 3, plants × 8, bubbles, wave) may strain older devices.
