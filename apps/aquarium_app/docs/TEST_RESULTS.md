# Milestone 3 — On-Device Audit Test Results

**Date:** 2026-02-28  
**Device:** SM-F966B (Galaxy Z Fold3), Android 16  
**Branch:** `polish/milestone-3`

---

## Build Info

| Metric | Value |
|--------|-------|
| APK size (debug) | 185.2 MB |
| Initial build time | 4m 41s |
| Incremental build time | ~68s |
| Flutter analyze | 0 errors, 2 warnings (unused test vars), 85 infos (test `print`s) |
| Flutter test | 798 passed, 40 skipped, 0 failures |

---

## Screens Audited (Code-Level)

Due to ADB device authorization issue (device shows `unauthorized` — needs manual USB debug confirmation on device), on-device screenshot walkthrough was **not completed**. Code-level audit was performed instead.

### Screens Reviewed (12/12)

| # | Screen | Code Reviewed | On-Device | Notes |
|---|--------|--------------|-----------|-------|
| 1 | Home (Tab 3) | ✅ | ❌ ADB auth | Semantics wrappers present, tooltips on all IconButtons |
| 2 | Learn (Tab 1) | ✅ | ❌ ADB auth | InkWell banners have text children for SR |
| 3 | Shop Street (Tab 2) | ✅ | ❌ ADB auth | Tooltip added for remove item button |
| 4 | Smart Hub (Tab 4) | ✅ | ❌ ADB auth | No missing accessibility issues found |
| 5 | Settings Hub (Tab 5) | ✅ | ❌ ADB auth | Edit button tooltip added |
| 6 | Tank Detail | ✅ | ❌ ADB auth | Task preview tooltip added |
| 7 | Lesson Screen | ✅ | ❌ ADB auth | No IconButton accessibility gaps |
| 8 | Achievements | ✅ | ❌ ADB auth | No issues found |
| 9 | Friends | ✅ | ❌ ADB auth | Clear search tooltip added |
| 10 | Leaderboard | ✅ | ❌ ADB auth | No issues found |
| 11 | Profile Creation | ✅ | ❌ ADB auth | Well-structured with Semantics, FittedBox, overflow protection |
| 12 | Wishlist | ✅ | ❌ ADB auth | Quantity +/- tooltips added |

---

## Issues Found & Fixed

### By Severity

| Severity | Found | Fixed | Remaining |
|----------|-------|-------|-----------|
| P0 (layout/overflow) | 0 new | 0 | 0 (ProfileCreation overflow appears previously resolved) |
| P1 (accessibility labels) | 17 | 17 | 0 |
| P2 (contrast) | 0 | 0 | 0 |
| P3 (empty/error states) | ? | N/A | Cannot verify without on-device testing |

### Accessibility Fixes (17 tooltips added)

| File | Widget | Tooltip Added |
|------|--------|--------------|
| account_screen.dart | Password visibility toggle | "Show/Hide password" |
| account_screen.dart | Sync retry button | "Retry sync" |
| cost_tracker_screen.dart | Clear data button | "Clear all data" |
| friends_screen.dart | Clear search button | "Clear search" |
| reminders_screen.dart | Complete reminder button | "Complete reminder" |
| settings_hub_screen.dart | Edit settings button | "Edit settings" |
| shop_street_screen.dart | Remove item button | "Remove item" |
| stocking_calculator_screen.dart | Decrease count | "Decrease count" |
| stocking_calculator_screen.dart | Increase count | "Increase count" |
| story_player_screen.dart | Close story button | "Close story" |
| tasks_screen.dart | Complete task button | "Complete task" |
| wishlist_screen.dart | Decrease quantity | "Decrease quantity" |
| wishlist_screen.dart | Increase quantity | "Increase quantity" |
| task_preview.dart | Complete task button | "Complete task" |
| app_navigation.dart | Back button | "Go back" |
| app_navigation.dart | Close button | "Close" |
| mascot_bubble.dart | Dismiss button | "Dismiss" |

---

## Contrast Audit

All color pairs pass WCAG AA (4.5:1 for body text):

| Pair | Ratio | WCAG AA |
|------|-------|---------|
| textPrimary on background | 11.87:1 | ✅ |
| textSecondary on background | 4.91:1 | ✅ |
| textHint on background | 4.91:1 | ✅ |
| textHint on white | 5.25:1 | ✅ |
| textPrimaryDark on backgroundDark | 13.62:1 | ✅ |
| textSecondaryDark on backgroundDark | 8.71:1 | ✅ |
| textHintDark on backgroundDark | 6.46:1 | ✅ |
| textHintDark on surfaceDark | 5.34:1 | ✅ |
| textDisabled on background | 7.75:1 | ✅ |

---

## Performance Baseline

| Metric | Value | Notes |
|--------|-------|-------|
| APK size (debug) | 185.2 MB | Normal for debug with all Flutter overhead |
| Total `setState` calls | 382 | Across all screens — not excessive |
| Total `build` methods | 622 | Normal for app this size |
| Existing Semantics/a11y annotations | 163 | Good baseline |
| IconButtons in codebase | 62 | All now have tooltips |
| Expensive ops in build | 8 matches | Mostly in performance monitoring code (expected) |

---

## Remaining Work

1. **On-device screenshot walkthrough** — Blocked by ADB authorization. Tiarnan needs to accept the USB debugging prompt on SM-F966B.
2. **Error state verification** — Cannot verify without on-device testing (ErrorBoundary exists in code).
3. **Dark mode visual verification** — Theme system is robust but needs visual check.
4. **Font scaling test** — Needs on-device testing at 1.5× text size.
5. **TalkBack walkthrough** — Needs device access.

---

## Overall Assessment

**Code quality: STRONG.** The app has excellent accessibility foundations:
- 163 existing Semantics annotations
- Custom `A11yLabels` class for consistent labeling
- `AppTouchTargets` system ensuring 48dp minimums
- All WCAG AA contrast ratios met
- `EmptyState`, `ErrorBoundary`, `SkeletonLoader` widgets available

The 17 missing IconButton tooltips were the main gap — now fixed. On-device visual verification is the key remaining step.
