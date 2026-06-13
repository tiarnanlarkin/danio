# Diagnosis Drill Questions Plan

## Goal

Make Diagnosis Practice behave like fishkeeping triage rather than generic recall.

CL-P1-005C adds scenario-style multiple-choice questions for common health and troubleshooting cards, using the existing review session UI.

## Scope

- Extend `PracticeDrillQuestionService` for `PracticeDrillId.diagnosis`.
- Cover ich/white spot, fin damage, fungal-looking growth, parasite-style symptoms, quarantine/prevention, and general diagnosis workflow.
- Keep advice practical and educational: check water, observe symptoms, isolate when appropriate, and avoid random medication.
- Leave compatibility/setup/emergency drills on fallback until their own slices.

## Tests First

- Verify ich cards resolve to a white-spot/flashing scenario.
- Verify troubleshooting diagnosis cards ask for water tests and symptom history before treatment.
- Verify unrelated diagnosis cards still get a useful general diagnosis scenario.

## Verification

- `flutter test test/services/practice_drill_question_service_test.dart`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug --target lib/main.dart`
- `git diff --check`
