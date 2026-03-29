# Wave 2A — Hephaestus Part 1: Lighting Crash + Dead CTAs

**Date:** 2026-03-29  
**Status:** ✅ Complete  
**Analyze result:** 0 app-code issues (4 pre-existing info/warning in test file only)

---

## FB-B1: Lighting Schedule midnight crash — FIXED

**File:** `lib/screens/lighting_schedule_screen.dart`

**Root cause:** CO2 Timing section constructed `TimeOfDay(hour: _lightsOn.hour - 1, ...)` and `TimeOfDay(hour: _lightsOff.hour - 1, ...)` directly. When lights-on or lights-off is set to 00:xx, hour becomes `-1`, which crashes `TimeOfDay`'s assertion (`hour >= 0 && hour < 24`).

**Fix:** Applied `(hour - 1 + 24) % 24` modulo wrapping on both expressions so midnight wraps to 23:xx instead of going negative.

```dart
// Before (crash when hour == 0):
TimeOfDay(hour: _lightsOn.hour - 1, minute: _lightsOn.minute)

// After (safe wrap):
TimeOfDay(hour: (_lightsOn.hour - 1 + 24) % 24, minute: _lightsOn.minute)
```

---

## FB-B3: Day7MilestoneCard CTA dead — FIXED

**Files:**  
- `lib/screens/home/home_screen.dart`  
- `lib/screens/compatibility_checker_screen.dart` (added import)

**Root cause:** `onFeatureTap` callback was wired as `() => Navigator.of(context).pop()` — this closed the dialog but never navigated anywhere.

**Fix:** Updated the callback to pop the dialog first, then push `CompatibilityCheckerScreen` via `NavigationThrottle.push`.

```dart
// Before (single pop, no navigation):
milestoneCard = Day7MilestoneCard(onFeatureTap: () => Navigator.of(context).pop());

// After (pop + navigate):
milestoneCard = Day7MilestoneCard(onFeatureTap: () {
  Navigator.of(context).pop();
  NavigationThrottle.push(context, const CompatibilityCheckerScreen());
});
```

---

## FB-B4: Day30CommittedCard CTA dead — FIXED (CTA hidden)

**Files:**  
- `lib/screens/onboarding/returning_user_flows.dart`  
- `lib/screens/home/home_screen.dart`

**Root cause:** `onUpgrade` callback was `() => Navigator.of(context).pop()` — the button did nothing visible except close the dialog.

**Decision:** No upgrade/paywall screen exists yet. CTA is hidden rather than showing a dead button. When a real destination is ready, wire `onUpgrade` in `home_screen.dart` to navigate there.

**Fix:**
- Made `onUpgrade` nullable in `Day30CommittedCard` (was `required VoidCallback`)
- Wrapped the upgrade button in `if (onUpgrade != null)` — button hidden when null
- `home_screen.dart` now passes `onUpgrade: null` with a comment marking where to wire the real destination

```dart
// Day30CommittedCard — onUpgrade is now optional:
final VoidCallback? onUpgrade;

// Button hidden when null:
if (onUpgrade != null) ...[
  // ... OutlinedButton ...
],

// home_screen.dart — CTA suppressed until destination exists:
onUpgrade: null, // FB-B4: wire to paywall/upgrade screen when available
```

---

## Analyze Summary

```
4 issues found (ran in 65.5s)
```

All 4 issues are pre-existing in `test/widget_tests/tab_navigator_test.dart` (2× `depend_on_referenced_packages` info, 1× `override_on_non_overriding_member` warning, 1× `use_super_parameters` info). Zero issues in app source code.
