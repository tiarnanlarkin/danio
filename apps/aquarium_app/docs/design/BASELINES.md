# Design Baselines

Authority lock: `danio-completion-roadmap-authority-lock-2026-07-15/1`

This file defines Danio's small baseline set for local visual work. Use it to
avoid broad, unfocused screenshot capture.

Current July phone screenshots and current repo assets govern visual defects.
The March visual asset audit is historical evidence, not current defect
authority. There is no asset-replacement, screenshot, golden, or new-animation
quota; add or replace evidence only for a concrete current defect or changed
high-risk surface.

## Baseline Surfaces

Capture no more than these eight app surfaces for a broad visual pass:

| Surface | State | Evidence target |
| --- | --- | --- |
| Welcome/onboarding | Fresh install | `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-86-welcome.png` |
| Home/tank dashboard | Post-onboarding local tank | `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-03-tank-root.png` |
| Learn | Lesson list or detail | `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-01-learn-root.png` |
| Practice | Weak-spots/session state | `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-02-practice-root.png` |
| Smart Hub | Local useful guidance without AI | `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-04b-smart-root-after-dock-fix.png` |
| Workshop | Calculator hub or selected tool | `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-06-workshop-root.png` |
| Preferences | Privacy/data controls | `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-07-preferences-root.png` |
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

The baseline manifest now points at the current 2026-07-04 phone map plus the
local golden-test harnesses. Refresh only a changed surface or one whose current
defect audit requires new evidence.
