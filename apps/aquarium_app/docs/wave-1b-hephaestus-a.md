# Wave 1B — Hephaestus Subagent A
**Date:** 2026-03-29  
**Scope:** FB-H2 (Onboarding personalisation) + FB-H3 (Weekend Amulet)

---

## FB-H2: Onboarding Personalisation — FIXED ✅

**Problem:** Tank was always created as "New Tank" / 60L regardless of what the user selected during onboarding.

**Changes made:** `lib/screens/onboarding_screen.dart`

### Tank Name
Derived from the user's fish selection with friendly suffixes:
- Betta → "Betta Paradise"
- Goldfish → "Goldfish Bowl"
- Guppy → "Guppy Garden"
- Neon Tetra → "Neon Tetra Shoal"
- Angelfish → "Angelfish Reef"
- Discus → "Discus Display"
- Axolotl → "Axolotl Lagoon"
- Any other fish → "[Fish Name] Tank"
- No fish selected → fallback to status-based name ("Cycling Tank" / "My Tank" / "New Tank")

### Tank Volume
- Uses `SpeciesInfo.minTankLitres` from the selected fish, clamped to 20–500 L
- Falls back to 60 L if no fish selected

### Fish Pre-population
- Creates a `Livestock` entry in the new tank for the selected species
- Count = `minSchoolSize` (so schooling fish get a proper group), minimum 1
- Scientific name, adult size included from species database
- Notes: "Added during setup"
- Non-fatal: if livestock creation fails, tank still exists and user can add fish manually

**New import:** `package:uuid/uuid.dart`, `../models/livestock.dart`

---

## FB-H3: Weekend Amulet — FIXED ✅

**Problem:** `isItemActive('weekend_amulet')` was never read anywhere. Users spent 20 gems for zero effect.

**Changes made:** `lib/providers/user_profile_derived_providers.dart`

### What it does now
In `todaysDailyGoalProvider`:
- Watches `inventoryProvider` for the `weekend_amulet` item
- If the item is active AND today is Saturday or Sunday → the effective daily XP goal is **halved** (minimum 5 XP)
- Weekdays and inactive amulet: no change, goal is normal
- Calculation: `(dailyXpGoal ~/ 2).clamp(5, dailyXpGoal)`

**Example:** 20 XP daily goal → 10 XP on weekends with active amulet. Visible immediately in the daily goal progress widget since it reads `todaysDailyGoalProvider`.

**New import:** `inventory_provider.dart`

---

## Flutter Analyze Results

```
4 issues found (ran in 19.3s)
```

All 4 issues are **pre-existing** in `test/widget_tests/tab_navigator_test.dart`:
- 2× `depend_on_referenced_packages` (info)
- 1× `override_on_non_overriding_member` (warning)  
- 1× `use_super_parameters` (info)

**Zero issues introduced by Wave 1B changes.**

---

## Files Modified

| File | Change |
|------|--------|
| `lib/screens/onboarding_screen.dart` | Personalised tank name/volume/fish pre-population |
| `lib/providers/user_profile_derived_providers.dart` | Weekend Amulet wired into daily goal |
