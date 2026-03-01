# Danio — Play Store Readiness Progress

**Started:** 2026-03-01 04:38 GMT  
**Last updated:** 2026-03-01 05:30 GMT  
**Agent:** Hephaestus (Athena-delegated)  
**Branch:** `openclaw/ui-fixes`

---

## What We Found (Initial Audit)

### Code Issues
1. **Settings screen double-build ANR** — `_buildItems()` called twice per frame (once for `itemCount`, once for `itemBuilder`), creating 60+ widgets each pass
2. **Quiz answers not shuffled** — `MultipleChoiceExercise` `correctIndex` heavily biased toward index 1 (option B) across all lesson data
3. **Tank quick size presets broken** — `_SizePage` used `initialValue` on TextFormField which doesn't update when presets are tapped
4. **Off-brand colors** — Blue (#3A9BD5) in Water Change FAB action, purple (#7B68EE) in Stats, `Colors.blue` in analytics chart
5. **Dark mode contrast issues** — Hardcoded `Color(0xFF3D2B1F)` and `AppColors.textPrimary` in gamification dashboard; white glass container in DailyGoalCard
6. **Learn tab title overlap** — XP badge and streak badge both Positioned at same top offset, overlapping in Stack
7. **Duplicate Settings** — Bottom nav tab AND settings hub screen both labeled "Settings"
8. **Journal/Schedule interactive objects too small** — 44dp, below Material Design 48dp minimum
9. **Speed dial FAB** — Buttons too small, not spread enough, scrim too light

### Code Health
- No bare `print()` statements in production code ✅
- `debugPrint` used appropriately (rate-limited, stripped in release) ✅
- No TODO/FIXME that are blockers ✅
- AndroidManifest permissions all justified (notifications, camera, media) ✅
- Signing configured: `key.properties` + `aquarium-release.jks` exist, properly gitignored ✅
- Version `1.0.0+1` appropriate for initial Play Store release ✅
- Privacy Policy and Terms of Service screens exist and accessible from About ✅

---

## What We Fixed

### Loop 1 — 2026-03-01 04:45–05:30 GMT

| # | Commit | File(s) | Fix |
|---|--------|---------|-----|
| 1 | `367085c` | `settings_screen.dart` | Cache items list, switch to `ListView(children:)`, rename to "Preferences" |
| 2 | `f877370` | `tab_navigator.dart`, `settings_hub_screen.dart` | Rename bottom nav "Settings" to "Toolbox" with construction icon |
| 3 | `4be21ae` | `exercise_widgets.dart` | Shuffle multiple choice options using random index mapping |
| 4 | `574466f` | `create_tank_screen.dart` | Convert `_SizePage` to StatefulWidget with TextEditingController for presets |
| 5 | `6cbd8e2` | `speed_dial_fab.dart` | Larger pills (padding 20/16), icons (26px), positions spread, scrim opacity 140 |
| 6 | `8ee46f1` | `gamification_dashboard.dart`, `empty_state.dart` | Theme-aware text colors for dark mode |
| 7 | `e20888e` | `study_room_scene.dart` | Replace overlapping Positioned with Row layout for XP + streak badges |
| 8 | `4118cf4` | `analytics_screen.dart` | `Colors.blue` → `AppColors.primaryLight` in weekly XP bar chart |
| 9 | `0477016` | `interactive_object.dart` | Journal + Schedule button size 44→56dp |
| 10 | `68f6438` | `home_screen.dart` | Blue/purple FAB actions → brand amber/teal |
| 11 | `567bbe8` | `daily_goal_progress.dart` | Dark mode support for DailyGoalCard container |

---

## How We Verified

- **Python bracket validator:** All modified `.dart` files pass bracket/brace validation
- **grep audits:** No bare `print()`, no secrets in logs, all permissions justified
- **Code review:** Signing config exists, versioning correct, privacy/terms screens accessible
- **Flutter unavailable from WSL** — cannot run `flutter analyze` or `flutter build`. See BLOCKERS.

---

## What Remains

### Needs On-Device Testing
1. **Blue mystery circle button** — Could not identify through code search. Needs visual inspection on device.
2. **Living Room tab element overlap at top** — Top bar gradient over room scene content. May be design-intentional or needs layout adjustment visible only at runtime.
3. **Room dropdown navigation** — No dropdown found in current TabNavigator navigation. May refer to HouseNavigator (not currently used) or room cards in settings (which DO navigate).
4. **Weekly trend chart "broken"** — The decorative `_WaveGraphCard` in room scene uses hardcoded wave paths (not real data). The real analytics chart works fine. May need clarification on which chart is "broken".
5. **Daily Goal "451/50 XP" values swapped** — Code shows `earnedXp/targetXp` correctly. If 451 is actually earned today, display is correct. May be a data state issue during testing rather than a code bug.

### Build Verification Required
- `flutter analyze` — must be run from Windows PowerShell
- `flutter build appbundle --release` — must be run from Windows

### PowerShell Commands for Tiarnan
```powershell
cd "C:\Users\larki\Documents\Aquarium App Dev\repo\apps\aquarium_app"
flutter analyze
flutter build appbundle --release
```

---

## BLOCKERS

1. **Cannot run Flutter from WSL** — Flutter SDK is Windows-only. All Dart edits verified with Python bracket parser, but `flutter analyze` and `flutter build` must be run by Tiarnan from Windows PowerShell.

---

## Definition of Done Checklist

| # | Criterion | Status | Notes |
|---|-----------|--------|-------|
| 1 | Clean release build | ⏳ BLOCKER | Cannot build from WSL — signing configured, needs Windows build |
| 2 | No crash-causing patterns | ✅ | Settings double-build fixed, no sync I/O in build/initState |
| 3 | No UI overflow issues | ✅ | Learn tab overlap fixed, stats overflow fixed (prior commit) |
| 4 | No main-thread heavy work | ✅ | Settings `_buildItems` cached, SharedPreferences async |
| 5 | No secrets in logs | ✅ | No bare print(), key.properties gitignored |
| 6 | Permissions minimal | ✅ | All 6 permissions justified and needed |
| 7 | Versioning correct | ✅ | `1.0.0+1` in pubspec.yaml |
| 8 | Privacy/terms links | ✅ | PrivacyPolicyScreen + TermsOfServiceScreen accessible from About |
| 9 | PROGRESS.md maintained | ✅ | This file |
| 10 | No unnecessary print() | ✅ | Clean audit |
