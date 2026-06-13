# Parameter Reading Drill Questions Plan

## Goal

Make the first Skill Drill feel like actual aquarium decision practice, not only filtered flashcard recall.

CL-P1-005B adds scenario-style multiple-choice questions for the Parameter Reading drill. The questions should reuse the existing review session UI, stay local/offline, and remain conservative about fish care.

## Scope

- Add a drill-question resolver service.
- For `PracticeDrillId.parameterInterpretation`, convert related review cards into parameter scenarios.
- Cover pH, temperature, chlorine/chloramine, cycling spikes, nitrate/maintenance, and a general water-reading fallback.
- Keep all other drill types on the existing `QuestionResolver` fallback for now.
- Route `startDrillSession` through the new resolver.

## Tests First

- Verify pH cards resolve to a pH scenario with four options and an explanation.
- Verify nitrogen spike cards ask for an immediate water-safety action.
- Verify non-parameter drills still fall back to the normal question resolver.

## Verification

- `flutter test test/services/practice_drill_question_service_test.dart`
- `flutter test test/services/practice_drill_service_test.dart test/widget_tests/practice_hub_screen_test.dart`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug --target lib/main.dart`
- `git diff --check`
