# Wave 1B — Hephaestus-B: XP Boost + Placement Test
**Date:** 2026-03-29  
**Commit:** `2922a25`  
**Branch:** `openclaw/stage-system`

---

## FB-H4: XP Boost broken for lessons ✅ FIXED

**File:** `lib/screens/lesson/lesson_screen.dart`

**Root cause:** `_completeLesson()` computed `totalXp = widget.lesson.xpReward + bonusXp` with no boost check, then passed that raw value to `completeLesson()`. The `xpBoostActiveProvider` was never consulted.

**Fix applied:**
- Added import: `../../providers/inventory_provider.dart`
- At the start of the try block in `_completeLesson()`, reads `xpBoostActiveProvider`
- Splits calculation into `baseXp` (lesson reward + bonusXp) and `totalXp` (baseXp × 2 if boost active)
- `totalXp` flows into both practice-mode path (`reviewLesson`, `addXp`) and normal completion (`completeLesson`)

```dart
// FB-H4: Apply XP boost if active
final isBoostActive = ref.read(xpBoostActiveProvider);
final baseXp = widget.lesson.xpReward + bonusXp;
final totalXp = isBoostActive ? baseXp * 2 : baseXp;
```

---

## FB-H5: Placement Test is fake — HIDDEN ✅ FIXED

**File:** `lib/widgets/placement_challenge_card.dart`

**Root cause:** `PlacementChallengeCard` showed a "Take the test" CTA that pushed `SpacedRepetitionPracticeScreen` — completely wrong destination. No real placement flow exists. `hasCompletedPlacementTest` can never be set via any UI path, so `placement_complete` achievement is permanently locked.

**Fix applied:**
- Gutted the widget body — `build()` now returns `const SizedBox.shrink()` immediately
- Removed all dead imports (user_profile, spaced_repetition_practice_screen, navigation_throttle, app_button, app_theme)
- 134 lines deleted, 5 added
- `placement_complete` achievement stays in catalog (data model unchanged) but remains locked — acceptable for v1

**Deferred:** DE-19 — Build real placement test flow in a future sprint.

---

## Flutter Analyze Results

**Run 1** (after initial fix): 6 issues — 1 `dead_code` warning in placement_challenge_card.dart from `// ignore: dead_code` approach  
**Run 2** (after full card cleanup): **5 issues** — dead_code warning eliminated

### Remaining issues (all pre-existing, not introduced by this wave):
| Severity | File | Issue |
|----------|------|-------|
| info | `lib/screens/onboarding_screen.dart:190` | `_nameSuffixes` leading underscore |
| info | `test/widget_tests/tab_navigator_test.dart:8` | `flutter_local_notifications_platform_interface` not in deps |
| info | `test/widget_tests/tab_navigator_test.dart:9` | `plugin_platform_interface` not in deps |
| warning | `test/widget_tests/tab_navigator_test.dart:23` | `override_on_non_overriding_member` |
| info | `test/widget_tests/tab_navigator_test.dart:64` | `use_super_parameters` |

**No new issues introduced. Zero errors.**

---

## Summary

| Item | Status |
|------|--------|
| FB-H4: XP Boost in lessons | ✅ Fixed |
| FB-H5: Placement Test hidden | ✅ Fixed |
| Analyze: clean (no new issues) | ✅ Pass |
| Committed | ✅ `2922a25` |
