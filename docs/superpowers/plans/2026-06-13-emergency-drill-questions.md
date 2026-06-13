# Emergency Drill Questions Plan

## Goal

Make Emergency Decisions practise fast, safe prioritisation for urgent aquarium problems.

CL-P1-005E adds scenario-style multiple-choice questions for emergency and troubleshooting cards.

## Scope

- Extend `PracticeDrillQuestionService` for `PracticeDrillId.emergencyDecision`.
- Cover fish gasping/unsafe water, power outage, temperature crash, pH crash, and a general emergency triage fallback.
- Keep advice practical, immediate, and local: protect oxygen, temperature, dilution, water conditioner, and retesting.
- Leave setup-planning scenarios for the next slice.

## Tests First

- Verify emergency distress cards prioritise water tests, oxygen, and immediate dilution.
- Verify power-outage cards prioritise oxygen/temperature preservation and reduced feeding.
- Verify general emergency cards use a clear triage order.

## Verification

- `flutter test test/services/practice_drill_question_service_test.dart`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug --target lib/main.dart`
- `git diff --check`
