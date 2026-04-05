# Danio — Test Report

**Date:** 2026-04-05
**Branch:** `openclaw/stage-system`
**Commit:** `3b01de61`

---

## Unit & Widget Tests

| Metric | Value |
|--------|-------|
| Total tests | 826 |
| Passed | 826 |
| Failed | 0 |
| Skipped | 0 |
| Runtime | ~53 seconds |

### Test Breakdown by Category

| Category | Files | Tests | Status |
|----------|-------|-------|--------|
| Data validation | 3 | ~30 | All pass |
| Model serialization | 1 | ~15 | All pass |
| Provider tests | 5 | ~60 | All pass |
| Service tests | 3 | ~25 | All pass |
| Widget tests | 55+ | ~680 | All pass |
| Integration persistence | 1 | 3 | All pass |
| Screen smoke tests | 40+ | ~400 | All pass |
| Utility tests | 1 | ~10 | All pass |

### Previously Failing Tests (Fixed This Sprint)

| Test | Root Cause | Fix |
|------|-----------|-----|
| lesson_data_test: count = 72 | Lesson content expanded to 82 | Updated expected count |
| lesson_provider_test: count = 72 | Same — allPathMetadata now 81 | Updated expected count |
| golden_path: gem purchase | Provider async settling issue | Added proper settle + flush |
| golden_path: lesson XP | Provider async settling issue | Added proper settle + flush |
| smart_screen: "Weekly Care Plan" (2x) | Feature renamed to "Weekly Plan" | Updated text assertions |

## Static Analysis

| Scope | Issues |
|-------|--------|
| `flutter analyze lib/` | 0 |
| `flutter analyze test/` | 0 |
| `flutter analyze` (entire project) | **0** |

### Previously Fixed Lint Issues

| Issue | File | Fix |
|-------|------|-----|
| depend_on_referenced_packages (2x) | tab_navigator_test.dart | Added to dev_dependencies |
| override_on_non_overriding_member | tab_navigator_test.dart | Removed incorrect @override |
| use_super_parameters | tab_navigator_test.dart | Used super.ref syntax |

## Integration Tests

| Test File | Target | Status |
|-----------|--------|--------|
| smoke_test_v2.dart | Emulator (no Patrol) | Available — covers app launch, tab navigation, learn content |
| smoke_test.dart | Patrol CLI | Available — requires patrol_cli setup |

## Build Verification

| Build | Status | Size |
|-------|--------|------|
| `flutter build apk --release` | Success | 89.6 MB |
| `flutter build appbundle --release` | Success | 67.7 MB |
| Font tree-shaking | 97.4% reduction | MaterialIcons: 1.6 MB → 42 KB |

## Emulator Verification

| Check | Status |
|-------|--------|
| Release APK installs | Pass |
| App launches to consent screen | Pass |
| No Flutter errors in logcat | Pass |
| No crashes | Pass |
| Impeller rendering active | Yes (OpenGLES) |
| Cold start frame skip | 60 frames skipped (expected for init chain) |
