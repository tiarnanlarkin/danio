# Wave 1B — Argus Adversarial Verification

**Date:** 2026-03-29  
**Verifier:** Argus (QA Director)  
**Scope:** 4 high-severity fixes from Wave 1A findings (FB-H2, FB-H3, FB-H4, FB-H5)

---

## FB-H2: Onboarding Personalisation Wired

**Original finding:** 10+ screens of personalisation collected → tank hardcoded "New Tank" 60L for everyone.  
**File verified:** `lib/screens/onboarding_screen.dart` → `_completeOnboarding()`

### Checklist

| Criterion | Result | Evidence |
|---|---|---|
| Tank name derived from selected fish species | ✅ | `nameSuffixes` map produces names like "Betta Paradise", "Guppy Garden", etc. |
| Tank volume from species data (not hardcoded 60L) | ✅ | `_selectedFish!.minTankLitres.clamp(20.0, 500.0)` — species data drives the value |
| Fish species pre-populated as livestock | ✅ | `Livestock` object created from `_selectedFish` and `addLivestock()` called immediately after `createTank()` |
| Fallback exists when no fish selected | ✅ | Name falls back to `'Cycling Tank'` / `'My Tank'` / `'New Tank'` based on `_tankStatus`; volume falls back to `60.0`; livestock step is skipped (`if (_selectedFish != null)` guard) |

### Detail

The hardcoded path is gone from `_completeOnboarding()`. The full personalised path:
- Derives a friendly tank name using an explicit species → suffix map, with a generic `'Tank'` suffix as catch-all for unlisted species.
- Reads `_selectedFish!.minTankLitres` clamped to `[20, 500]` for the volume.
- Constructs a `Livestock` record using species data (`commonName`, `scientificName`, `adultSizeCm`) and adds it via `tankNotifier.addLivestock()`.
- The `_quickStart()` path (skip-onboarding) still creates a default 60L "My Tank" — that is correct and expected for that path, and a disclosure snackbar is shown.

**VERDICT: ✅ PASS**

---

## FB-H3: Weekend Amulet Works

**Original finding:** Zero code reads `isItemActive('weekend_amulet')`. Daily goals ignore it.  
**File verified:** `lib/providers/user_profile_derived_providers.dart` → `todaysDailyGoalProvider`

### Checklist

| Criterion | Result | Evidence |
|---|---|---|
| `todaysDailyGoalProvider` reads inventory/item state | ✅ | `ref.watch(inventoryProvider)` called inside the provider |
| Weekend Amulet active + Sat/Sun → reduced XP goal | ✅ | `item.itemId == 'weekend_amulet' && item.isActive && !item.isExpired` checked; `today.weekday == DateTime.saturday \|\| today.weekday == DateTime.sunday` checked |
| Reduction is meaningful (halved or similar) | ✅ | `dailyXpGoal ~/ 2` with `.clamp(5, dailyXpGoal)` floor — exactly halved |
| Loading/error states handled safely | ✅ | `inventory.when(loading: () => false, error: (_, __) => false, ...)` — defaults to no reduction on failure |

### Detail

`todaysDailyGoalProvider` now watches `inventoryProvider`, locates the `weekend_amulet` item, and verifies both `isActive` and `!isExpired` before applying the reduction. The reduction is `dailyXpGoal ~/ 2`, minimum 5 XP. The day-of-week check uses `DateTime.saturday` and `DateTime.sunday` constants. No reduction applies on weekdays or when the item is absent/inactive/expired.

**VERDICT: ✅ PASS**

---

## FB-H4: XP Boost Works for Lessons

**Original finding:** `lesson_screen.dart` calls `completeLesson(id, xp)` with no boost applied.  
**File verified:** `lib/screens/lesson/lesson_screen.dart` → `_completeLesson()`

### Checklist

| Criterion | Result | Evidence |
|---|---|---|
| `_completeLesson()` reads boost state | ✅ | `final isBoostActive = ref.read(xpBoostActiveProvider);` — first line of XP calculation |
| XP doubled when boost active | ✅ | `final totalXp = isBoostActive ? baseXp * 2 : baseXp;` |
| Boosted XP passed to `completeLesson()` | ✅ | `completeLesson(widget.lesson.id, totalXp)` — `totalXp` is the boosted value |
| Boost applies in practice mode too | ✅ | `practiceXp = totalXp ~/ 2` — `totalXp` is already boosted before the halving |

### Detail

The boost is applied before any branching: `baseXp = widget.lesson.xpReward + bonusXp`, then `totalXp = isBoostActive ? baseXp * 2 : baseXp`. Both practice mode (`reviewLesson(id, practiceXp)`) and normal mode (`completeLesson(id, totalXp)`) receive the boosted figure. The XP shown in the app bar header (`'up to +${widget.lesson.xpReward + quiz.bonusXp} XP'`) does not reflect the boost in the UI label, which is a minor display-only gap — the actual reward is correctly doubled at completion.

**VERDICT: ✅ PASS**

> **P3 observation:** The XP badge in the `AppBar` shows pre-boost XP. When a boost is active, this underrepresents what the user will actually earn. Consider appending a "×2" indicator when `xpBoostActiveProvider` is true.

---

## FB-H5: Placement Test Hidden

**Original finding:** Fake CTA opened the wrong screen. Achievement locked permanently.  
**File verified:** `lib/widgets/placement_challenge_card.dart`

### Checklist

| Criterion | Result | Evidence |
|---|---|---|
| Widget renders `SizedBox.shrink()` | ✅ | `return const SizedBox.shrink();` — unconditional, single line |
| No user-visible path to fake placement test | ✅ | `build()` method returns immediately; no buttons, no navigation |
| Commented rationale present | ✅ | `// FB-H5: Placement test is not yet implemented (DE-19). Hide this CTA until a real placement flow exists.` |

### Detail

The entire widget body is a single `return const SizedBox.shrink()`. The widget is still wired into the widget tree wherever it was previously placed (no import or call-site removal needed — zero-size widget is the canonical Flutter approach for conditional hiding). The `library;` directive and file-level comment make the intent unambiguous for future developers. The achievement that depended on this CTA was previously permanently locked; the proper fix (DE-19) is tracked.

**VERDICT: ✅ PASS**

---

## Summary

| ID | Finding | Verdict |
|---|---|---|
| FB-H2 | Onboarding personalisation wired to tank creation | ✅ **PASS** |
| FB-H3 | Weekend Amulet reduces daily XP goal on weekends | ✅ **PASS** |
| FB-H4 | XP Boost doubles lesson reward at completion | ✅ **PASS** |
| FB-H5 | Placement Test CTA hidden via `SizedBox.shrink()` | ✅ **PASS** |

**All 4 fixes verified. No regressions detected. One P3 cosmetic observation logged (FB-H4 AppBar XP label does not reflect active boost).**

Wave 1B: **APPROVED** — all high-severity fixes are correctly implemented.
