# Design Baselines

This file defines Danio's small baseline set for local visual work. Use it to
avoid broad, unfocused screenshot capture.

## Baseline Surfaces

Capture no more than these eight app surfaces for a broad visual pass:

| Surface | State | Evidence target |
| --- | --- | --- |
| Welcome/onboarding | Fresh install | `docs/screenshots/01_welcome.png` or new local capture |
| Home/tank dashboard | Post-onboarding local tank | `docs/qa/screenshots/whole-app-map-2026-05-18/post-fix/final-release-tank.png` |
| Learn | Lesson list or detail | `docs/qa/screenshots/whole-app-map-2026-05-18/post-fix/final-release-learn.png` |
| Practice | Weak-spots/session state | `docs/qa/screenshots/whole-app-map-2026-05-18/post-fix/final-release-practice.png` |
| Smart Hub | Local useful guidance without AI | `docs/qa/screenshots/whole-app-map-2026-05-18/post-fix/final-release-smart.png` |
| Workshop | Calculator hub or selected tool | `docs/qa/screenshots/whole-app-map-2026-05-18/post-fix/final-release-workshop.png` |
| Preferences | Privacy/data controls | `docs/qa/screenshots/whole-app-map-2026-05-18/post-fix/final-release-preferences.png` |
| Golden widgets | MC card and empty room scene | `test/golden_tests/` local golden runs |

For focused UI work, capture only the changed surface plus one adjacent
navigation surface. Temporary screenshots can remain outside Git unless they
are useful durable QA evidence.

## Golden Tests

Existing local golden tests:

```powershell
flutter test test/golden_tests/mc_card_golden_test.dart
flutter test test/golden_tests/empty_room_scene_golden_test.dart
```

Reference images under `test/golden_tests/goldens/` are ignored because Flutter
goldens differ across operating systems. Regenerate them locally only when the
task intentionally reviews visual output.

## Current Baseline Status

Initial baseline manifest added on 2026-06-13. Existing committed screenshots
and local golden-test harnesses are the baseline; no fresh device capture was
performed in this setup slice.
