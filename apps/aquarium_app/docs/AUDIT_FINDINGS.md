# Danio Production Readiness — Audit Findings

**Date:** 2026-04-05
**Branch:** `openclaw/stage-system`
**Commit:** `6f282e18`

---

## Build Health

| Check | Result |
|-------|--------|
| `flutter pub get` | OK — all dependencies resolve |
| `flutter analyze lib/` | **0 issues** |
| `flutter analyze test/` | 4 issues (all in tab_navigator_test.dart) |
| `flutter test` | 820 pass, **6 fail** |
| `flutter build apk --release` | OK — 89.6 MB, signed, font tree-shaking 97.4% |
| Release APK install on emulator | OK — installs and launches |

## Test Failures (6)

| Test File | Failure | Root Cause |
|-----------|---------|------------|
| lesson_data_test.dart | Expected 72 lessons, actual 82 | Lesson content expanded (FQ-C1-C7), hardcoded count stale |
| lesson_provider_test.dart | Expected 72 lessons, actual 81 | Same — stale count in allPathMetadata test |
| golden_path_persistence_test.dart (gem) | Expected >= 100 gems, actual 0 | Provider async setup issue |
| golden_path_persistence_test.dart (XP) | XP not awarded after completeLesson | Provider async setup issue |
| smart_screen_test.dart (2x) | "Weekly Care Plan" text not found | Screen text changed |

## Lint Issues (4) — all in tab_navigator_test.dart

1. `depend_on_referenced_packages` — flutter_local_notifications_platform_interface not in dev_dependencies
2. `depend_on_referenced_packages` — plugin_platform_interface not in dev_dependencies
3. `override_on_non_overriding_member` — mock method doesn't match interface
4. `use_super_parameters` — ref parameter should use super syntax

## Asset Status

| Item | Status |
|------|--------|
| Badge icons (FQ-V6) | 4 present (early_bird, night_owl, perfectionist, legendary) |
| Fish sprites | 15/126 species — all .webp with alpha, no legacy .png |
| bristlenose_pleco (FQ-V7) | .webp RGBA 512x512 — resolved |
| placeholder.webp (FQ-V4) | Present — style TBD on emulator |
| Onboarding background (FQ-V3) | onboarding_journey_bg.webp present — style TBD |
| Room backgrounds | All 12 regenerated today via Gemini |
| Tab headers | All 36 (12 themes x 3 tabs) regenerated as .webp |

## Code Quality

| Metric | Value |
|--------|-------|
| Dart source files (lib/) | 400 |
| Test files | 110 |
| Total commits | 1,120 |
| TODOs in production code | 0 (stale one removed) |
| debugPrint/print calls | 20 across 6 files (all appropriate — logger, debug tools, error boundary) |
| BUG comments | 11 — all are already-fixed annotations |

## Dark Mode

- `AppTheme.dark` fully defined with warm charcoal palette
- `AdaptiveColors` extension provides 9 context-aware getters
- All raw `AppColors.textPrimary/background/surface` references migrated
- Settings toggle wired through `flutterThemeMode`
- Status: **Production-ready**

## Previous Work Completed

All 35 Finish Blockers resolved across Waves 1A-3. Most FQ items resolved in Wave 4 and post-wave polish. British English pass done. Performance optimisations applied. 78 tests added. Cross-tab theme system implemented.

## Remaining Items

See KNOWN_ISSUES.md for deferred items (DE-1 through DE-18).
