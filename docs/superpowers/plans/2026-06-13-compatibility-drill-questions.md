# Compatibility Drill Questions Plan

## Goal

Make Compatibility Checks practise real stocking judgement: temperament, group size, adult size, temperature fit, and stress risk.

CL-P1-005D adds scenario-style multiple-choice questions for species and first-fish compatibility cards.

## Scope

- Extend `PracticeDrillQuestionService` for `PracticeDrillId.compatibility`.
- Cover betta tank mates, goldfish/tropical mismatch, schooling fish, territorial cichlids, and a general compatibility checklist.
- Keep advice practical and welfare-led without overloading the user with technical detail.
- Leave setup-planning and emergency drills on fallback until their slices.

## Tests First

- Verify betta cards resolve to a fin-nipping/temperament scenario.
- Verify goldfish cards catch temperature/waste/adult-size mismatch.
- Verify general compatibility cards require group size and adult-size checks.

## Verification

- `flutter test test/services/practice_drill_question_service_test.dart`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug --target lib/main.dart`
- `git diff --check`
