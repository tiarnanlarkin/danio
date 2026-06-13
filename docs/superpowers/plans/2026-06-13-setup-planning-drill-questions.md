# Setup Planning Drill Questions Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add scenario-style Setup Planning practice questions so this drill teaches equipment, lighting, layout, and first-tank planning decisions instead of generic card recall.

**Architecture:** Keep the existing `PracticeDrillQuestionService` resolver shape. Add a setup-planning branch in `resolveQuestions`, backed by a private `_setupPlanningQuestion` helper that returns `MultipleChoiceQuestion` instances and falls back to `QuestionResolver` only when another drill is selected.

**Tech Stack:** Flutter, Dart, `flutter_test`, existing spaced repetition and resolved question models.

---

### Task 1: Setup Planning Scenarios

**Files:**
- Modify: `apps/aquarium_app/test/services/practice_drill_question_service_test.dart`
- Modify: `apps/aquarium_app/lib/services/practice_drill_question_service.dart`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
- Modify: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`

- [ ] **Step 1: Write the failing tests**

Add these tests to the `PracticeDrillQuestionService` group:

```dart
test('turns filter cards into a flow and bioload planning scenario', () {
  final questions = PracticeDrillQuestionService.resolveQuestions(
    drillId: PracticeDrillId.setupPlanning,
    cards: [_card('eq_filters_section_0')],
    lessonState: const LessonState(),
  );

  final question = questions.single as MultipleChoiceQuestion;
  expect(question.questionText, contains('filter'));
  expect(question.options[question.correctIndex], contains('bioload'));
  expect(question.options[question.correctIndex], contains('flow'));
  expect(question.explanation, contains('maintenance'));
});

test('turns lighting cards into a photoperiod planning scenario', () {
  final questions = PracticeDrillQuestionService.resolveQuestions(
    drillId: PracticeDrillId.setupPlanning,
    cards: [_card('planted_light_section_0')],
    lessonState: const LessonState(),
  );

  final question = questions.single as MultipleChoiceQuestion;
  expect(question.questionText, contains('lighting'));
  expect(question.options[question.correctIndex], contains('photoperiod'));
  expect(question.options[question.correctIndex], contains('plants'));
  expect(question.explanation, contains('algae'));
});

test('turns first setup cards into a full checklist scenario', () {
  final questions = PracticeDrillQuestionService.resolveQuestions(
    drillId: PracticeDrillId.setupPlanning,
    cards: [_card('eq_setup_guide_section_0')],
    lessonState: const LessonState(),
  );

  final question = questions.single as MultipleChoiceQuestion;
  expect(question.questionText, contains('new tank'));
  expect(question.options[question.correctIndex], contains('equipment'));
  expect(question.options[question.correctIndex], contains('maintenance'));
  expect(question.explanation, contains('livestock'));
});
```

- [ ] **Step 2: Verify the tests fail for the missing setup resolver**

Run:

```powershell
flutter test test/services/practice_drill_question_service_test.dart
```

Expected: the three new setup-planning tests fail because `PracticeDrillId.setupPlanning` still uses the generic fallback questions.

- [ ] **Step 3: Implement the minimal setup-planning resolver**

Add a setup branch before the emergency branch in `resolveQuestions`:

```dart
if (drillId == PracticeDrillId.setupPlanning) {
  return [
    for (var index = 0; index < cards.length; index++)
      _setupPlanningQuestion(cards[index]) ?? fallback[index],
  ];
}
```

Add `_setupPlanningQuestion` with cases for:
- `eq_filters`: filter, bioload, flow, maintenance.
- `eq_lighting`, `planted_light`: lighting, photoperiod, plants, algae.
- `eq_setup_guide`, `eq_heaters`, `eq_test_kits`, `eq_air_pumps`, `eq_substrate`: new-tank checklist, equipment, maintenance, livestock.
- General setup fallback: adult size, water needs, equipment, maintenance rhythm.

- [ ] **Step 4: Format and run focused tests**

Run:

```powershell
dart format apps/aquarium_app/lib/services/practice_drill_question_service.dart apps/aquarium_app/test/services/practice_drill_question_service_test.dart
flutter test test/services/practice_drill_question_service_test.dart test/services/practice_drill_service_test.dart test/widget_tests/practice_hub_screen_test.dart
```

Expected: all focused Practice tests pass.

- [ ] **Step 5: Update audit docs**

Update CL-P1-005 to include CL-P1-005F and change the current audit test count only after a fresh full `flutter test` confirms it.

- [ ] **Step 6: Full verification**

Run:

```powershell
flutter analyze
flutter test
flutter test test/copy/current_docs_local_truth_test.dart
flutter build apk --debug --target lib/main.dart
git diff --check
```

Expected: analyzer clean, full suite passes with the new test count, docs truth passes, debug APK builds with only the existing Kotlin Gradle Plugin warning, and diff check is clean.

- [ ] **Step 7: Commit**

Stage only the expected setup-planning files and commit:

```powershell
git add apps/aquarium_app/lib/services/practice_drill_question_service.dart apps/aquarium_app/test/services/practice_drill_question_service_test.dart apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md docs/superpowers/plans/2026-06-13-setup-planning-drill-questions.md
git diff --cached --check
git commit -m "feat: add setup planning drill scenarios"
```

Expected: one scoped commit for CL-P1-005F.
