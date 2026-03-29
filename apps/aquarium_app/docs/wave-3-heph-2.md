# Wave 3 — Input + Safe Area Fixes (Hephaestus, Subagent 2)

**Date:** 2026-03-29  
**Status:** ✅ All 3 items resolved

---

## FB-O3: FishSelectScreen Safe Area Padding

**Finding:** `FishSelectScreen` (`lib/screens/onboarding/fish_select_screen.dart`) already correctly wraps its `Scaffold` body in a `SafeArea` widget (line 146). Content is properly protected from the notch/status bar. The bottom tray is `Positioned(bottom: 0)` inside the `SafeArea`, meaning it also respects the home indicator boundary.

**Action:** No changes needed — safe area was already implemented correctly.

---

## FB-O4: Decimal Input on Calculators

**Files changed:**
- `lib/screens/water_change_calculator_screen.dart`
- `lib/screens/stocking_calculator_screen.dart`

**Changes:**
- `water_change_calculator_screen.dart`: Fixed 4 `AppTextField` fields:
  - Tank Volume (litres)
  - Current Nitrate (ppm)
  - Target Nitrate (ppm)
  - Tap Water Nitrate (ppm)
  
  All changed from `keyboardType: TextInputType.number` + `digitsOnly` formatter → `TextInputType.numberWithOptions(decimal: true)` + `FilteringTextInputFormatter.allow(RegExp(r'[\d.']))`

- `stocking_calculator_screen.dart`: Fixed Tank (L) field from `TextInputType.number` + `digitsOnly` → decimal variant.

**Other calculators (already correct):**
- `dosing_calculator_screen.dart` — already using `numberWithOptions(decimal: true)` ✅
- `co2_calculator_screen.dart` — already using `numberWithOptions(decimal: true)` ✅
- `tank_volume_calculator_screen.dart` — already using `numberWithOptions(decimal: true)` ✅

---

## FB-O5: Numeric Keyboard on Symptom Triage

**File changed:** `lib/features/smart/symptom_triage/symptom_triage_screen.dart`

**Changes:** Fixed 5 `TextField` fields in `_buildParamsStep()`:
- pH
- Temp (°C)
- Ammonia (ppm)
- Nitrite (ppm)
- Nitrate (ppm)

All changed from `keyboardType: TextInputType.number` → `keyboardType: const TextInputType.numberWithOptions(decimal: true)`. This ensures decimal values (e.g. pH 7.4, temp 24.5°C, ammonia 0.25 ppm) can be entered correctly on mobile.

---

## Flutter Analyze Result

```
4 issues found. (ran in 55.5s)
```

All 4 issues are **pre-existing** in test files (`tab_navigator_test.dart`) — unrelated to Wave 3 changes. **Zero new issues introduced.**
