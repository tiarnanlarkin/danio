# Danio — Production Readiness Sprint Changelog

**Date:** 2026-04-05
**Branch:** `openclaw/stage-system`

---

## Changes Made

### Test Fixes (6 failures → 0)
- **lesson_data_test.dart**: Updated expected lesson count from 72 to 82 (content expanded in FQ-C1-C7 wave)
- **lesson_provider_test.dart**: Updated expected allPathMetadata lesson count from 72 to 81
- **golden_path_persistence_test.dart**: Fixed gem purchase test — added proper async settling and flushPendingWrite after addGems()
- **golden_path_persistence_test.dart**: Fixed lesson XP test — added proper async settling after completeLesson()
- **smart_screen_test.dart**: Updated feature card text from "Weekly Care Plan" to "Weekly Plan" (2 assertions)

### Lint Fixes (4 issues → 0)
- **tab_navigator_test.dart**: Added flutter_local_notifications_platform_interface ^8.0.0 to dev_dependencies
- **tab_navigator_test.dart**: Added plugin_platform_interface ^2.1.0 to dev_dependencies
- **tab_navigator_test.dart**: Removed incorrect @override on initialize() method
- **tab_navigator_test.dart**: Converted `Ref ref` to `super.ref` syntax

### Code Cleanup
- **ai_proxy_service.dart**: Removed stale TODO comment (Supabase Edge Function already deployed)

### Documentation Created
- AUDIT_FINDINGS.md — baseline assessment
- WORKLOG.md — work tracking
- TEST_MATRIX.md — comprehensive test coverage matrix
- TEST_REPORT.md — test results and verification
- RELEASE_READINESS.md — ship/no-ship assessment
- KNOWN_ISSUES.md — all deferred and external items
- CHANGELOG_POLISH.md — this file

## Files Modified

| File | Change Type | Lines |
|------|------------|-------|
| lib/services/ai_proxy_service.dart | Removed stale TODO | -3 |
| pubspec.yaml | Added 2 dev_dependencies | +2 |
| pubspec.lock | Updated lockfile | +2/-2 |
| test/data/lesson_data_test.dart | Updated count | +2/-2 |
| test/providers/lesson_provider_test.dart | Updated count | +2/-2 |
| test/widget_tests/golden_path_persistence_test.dart | Fixed async settling | +33/-14 |
| test/widget_tests/smart_screen_test.dart | Updated text | +7/-6 |
| test/widget_tests/tab_navigator_test.dart | Fixed lint issues | +2/-1 |
| **Total** | | **+51/-29** |

## Result

| Before | After |
|--------|-------|
| 820 pass, 6 fail | **826 pass, 0 fail** |
| 4 lint issues | **0 lint issues** |
| 1 stale TODO | **0 TODOs** |
