# Wave 3 — Heph-3 Summary

**Task:** FB-O6, RF-4, RF-6  
**Status:** ✅ Complete — 0 errors on flutter analyze

---

## FB-O6: SRS achievements → route through checkAchievements()

**Problem:** `SpacedRepetitionNotifier` had two private methods — `_checkStreakAchievements()` and `_checkSessionCountAchievements()` — that directly called `updateProgress()` on `achievementProgressProvider`. This bypassed the full achievement pipeline: no XP award, no gem award, no unlock dialog.

**Fix:**
- Removed both dead private methods
- In `completeSession()`, replaced the `_checkSessionCountAchievements(sessionCount)` call with:
  ```dart
  await _ref.read(achievementCheckerProvider).checkAfterReview(
    reviewsCompleted: sessionCount,
    reviewStreak: state.stats.currentStreak,
  );
  ```
- `checkAfterReview()` routes through `checkAchievements()` which handles XP, gems, and the unlock dialog.
- Removed now-unused `import '../models/achievements.dart'` from the provider.
- The `_updateReviewStreak()` call to `_checkStreakAchievements(newStreak)` was also removed; streak achievements are now covered by `checkAfterReview()` in `completeSession()` (which has access to the updated streak after `_updateReviewStreak()` runs).

**Files changed:** `lib/providers/spaced_repetition_provider.dart`

---

## RF-4: Remove ThemeGalleryScreen dead code

**Decision:** Remove — orphaned dead code.

**Fix:** Deleted the screen file and test file, and removed all references:

| File | Change |
|------|--------|
| `lib/screens/theme_gallery_screen.dart` | **Deleted** |
| `test/widget_tests/theme_gallery_screen_test.dart` | **Deleted** |
| `lib/screens/settings/settings_screen.dart` | Removed import + Room Themes NavListTile |
| `lib/screens/debug_menu_screen.dart` | Removed import + `_DebugTile('Theme Gallery')` |
| `lib/services/debug_deep_link_service.dart` | Removed import + `'theme-gallery'` case block |

---

## RF-6: Remove dead Light Intensity button

**Decision:** Remove — dead UI worse than absent UI.

**Fix:** In `LightingScheduleScreen`:
- Removed `String _lightIntensity = 'Medium'` state field
- Removed the `ListTile` containing the `SegmentedButton<String>` (Low/Med/High) whose selection was stored but never used anywhere — no logic, no output, no effect.

**File changed:** `lib/screens/lighting_schedule_screen.dart`

---

## flutter analyze result

```
4 issues found (pre-existing in tab_navigator_test.dart only):
  - 2× info: depend_on_referenced_packages
  - 1× warning: override_on_non_overriding_member
  - 1× info: use_super_parameters
0 errors. 0 warnings introduced by this wave.
```

---

## Commit

`8293ddd` — Wave 3 Heph-3: FB-O6 SRS achievement routing, RF-4 ThemeGallery removal, RF-6 Light Intensity removal
