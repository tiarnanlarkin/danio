# Active Questions Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace passive self-assessment in practice sessions with active multiple-choice and matching-pairs questions generated from existing lesson content.

**Architecture:** A `QuestionResolver` service maps `ReviewCard`s to `ResolvedQuestion`s at session start. MC questions are sourced from existing `QuizQuestion` objects or auto-generated from `keyPoint` sections. Every ~5th card becomes a matching-pairs question grouping 3-4 concepts from the same learning path. Two new widgets (`McCardWidget`, `MatchingCardWidget`) replace the current Forgot/Remembered buttons.

**Tech Stack:** Flutter, Riverpod, existing models (`ReviewCard`, `QuizQuestion`, `LessonSection`), existing providers (`lessonProvider`, `spacedRepetitionProvider`).

---

### Task 1: Create ResolvedQuestion models

**Files:**
- Create: `apps/aquarium_app/lib/models/resolved_question.dart`
- Test: `apps/aquarium_app/test/models/resolved_question_test.dart`

**Step 1: Write the test**

```dart
// test: MultipleChoiceQuestion holds data correctly
// test: MatchingPairsQuestion holds pairs and cards
// test: MatchPair equality
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/models/resolved_question_test.dart -v`
Expected: FAIL — file not found

**Step 3: Write the models**

Create `resolved_question.dart` with:
- `sealed class ResolvedQuestion` with `ReviewCard card` field
- `class MultipleChoiceQuestion extends ResolvedQuestion` with `questionText`, `options` (List<String>), `correctIndex` (int), `explanation` (String?)
- `class MatchingPairsQuestion extends ResolvedQuestion` with `cards` (List<ReviewCard>), `pairs` (List<MatchPair>)
- `class MatchPair` with `left` (String), `right` (String)

Import from `models/spaced_repetition.dart` for `ReviewCard`.

**Step 4: Run test to verify it passes**

Run: `flutter test test/models/resolved_question_test.dart -v`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/aquarium_app/lib/models/resolved_question.dart apps/aquarium_app/test/models/resolved_question_test.dart
git commit -m "feat: add ResolvedQuestion models for active practice questions"
```

---

### Task 2: Create QuestionResolver service

**Files:**
- Create: `apps/aquarium_app/lib/services/question_resolver.dart`
- Test: `apps/aquarium_app/test/services/question_resolver_test.dart`
- Read: `apps/aquarium_app/lib/models/learning.dart` (Lesson, QuizQuestion, LessonSection, LessonSectionType)
- Read: `apps/aquarium_app/lib/models/spaced_repetition.dart` (ReviewCard, ConceptType)
- Read: `apps/aquarium_app/lib/providers/lesson_provider.dart` (LessonState.getLesson, getPath, loadedPaths)

**Step 1: Write tests for the resolver**

Test cases:
- `resolveQuestions` returns a `ResolvedQuestion` for each input `ReviewCard`
- Cards whose lesson has a `Quiz` get a `MultipleChoiceQuestion` sourced from `QuizQuestion`
- Cards whose lesson has no quiz but has `keyPoint` sections get an auto-generated MC question
- Every ~5th card becomes a `MatchingPairsQuestion` (when enough sibling concepts exist)
- Cards with no lesson data fallback to a simple self-assess question (backwards compat)
- Distractors for auto-generated MC are pulled from sibling lessons' key points

**Step 2: Run tests to verify they fail**

Run: `flutter test test/services/question_resolver_test.dart -v`
Expected: FAIL

**Step 3: Implement QuestionResolver**

```dart
class QuestionResolver {
  /// Resolve a list of review cards into active questions.
  /// [lessonState] provides access to loaded lesson content.
  static List<ResolvedQuestion> resolveQuestions({
    required List<ReviewCard> cards,
    required LessonState lessonState,
  }) { ... }
}
```

Resolution logic per card:
1. Extract `pathId` from the card's `conceptId` (format: `{pathId}_{lessonSlug}` or lookup via `lessonState.getLesson`)
2. Check if the card's lesson has a `Quiz` — if so, pick a `QuizQuestion` and wrap it in `MultipleChoiceQuestion`
3. If no quiz, find `keyPoint` sections in the lesson. Use the key point text as the correct answer, generate 3 distractors from other lessons' key points in the same path
4. Every 5th card (index % 5 == 4): if 3+ sibling concepts exist in the same path, group them into a `MatchingPairsQuestion` with concept name → key point pairs
5. Fallback: if no lesson data is loaded for this card, create a simple MC with the concept display name as the question and "I remember this" / "I need to review" / etc. as options (graceful degradation)

**Step 4: Run tests to verify they pass**

Run: `flutter test test/services/question_resolver_test.dart -v`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/aquarium_app/lib/services/question_resolver.dart apps/aquarium_app/test/services/question_resolver_test.dart
git commit -m "feat: add QuestionResolver service for active question generation"
```

---

### Task 3: Create McCardWidget

**Files:**
- Create: `apps/aquarium_app/lib/screens/spaced_repetition_practice/widgets/mc_card_widget.dart`
- Test: `apps/aquarium_app/test/widget_tests/mc_card_widget_test.dart`

**Step 1: Write widget test**

Test cases:
- Renders question text and 4 option buttons
- Tapping correct option shows green highlight and explanation
- Tapping wrong option shows red highlight and explanation
- After answering, shows "Next Card" button
- `onAnswered(bool correct)` callback fires with correct value

**Step 2: Run test to verify it fails**

Run: `flutter test test/widget_tests/mc_card_widget_test.dart -v`
Expected: FAIL

**Step 3: Implement McCardWidget**

`ConsumerStatefulWidget` that takes:
- `MultipleChoiceQuestion question`
- `VoidCallback onAnswered(bool correct)` — called after user taps an option
- `VoidCallback onNext` — called when user taps "Next Card"

UI layout:
- Question text at top (`AppTypography.headlineMedium`)
- If `question.questionText` has detail, show it in a tinted box below
- 4 option buttons as `Container`s with `InkWell` — each shows option text
- Before answering: all options neutral colour
- After answering: correct option turns green, selected wrong option turns red, other options grey out
- Explanation text appears in a card below options
- "Next Card" / "Complete Session" button at bottom

Use `AppButton`, `AppRadius`, `AppSpacing`, `AppTypography`, `AppColors.success`, `AppColors.error` from design system.

**Step 4: Run tests to verify they pass**

Run: `flutter test test/widget_tests/mc_card_widget_test.dart -v`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/aquarium_app/lib/screens/spaced_repetition_practice/widgets/mc_card_widget.dart apps/aquarium_app/test/widget_tests/mc_card_widget_test.dart
git commit -m "feat: add McCardWidget for multiple choice practice questions"
```

---

### Task 4: Create MatchingCardWidget

**Files:**
- Create: `apps/aquarium_app/lib/screens/spaced_repetition_practice/widgets/matching_card_widget.dart`
- Test: `apps/aquarium_app/test/widget_tests/matching_card_widget_test.dart`

**Step 1: Write widget test**

Test cases:
- Renders left and right columns with correct number of items
- Tapping a left item selects it (highlighted)
- Tapping matching right item locks the pair (green)
- Tapping wrong right item flashes red briefly
- Completes when all pairs matched
- `onCompleted(double score)` fires with proportional score (e.g. 0.75 for 3/4)

**Step 2: Run test to verify it fails**

Run: `flutter test test/widget_tests/matching_card_widget_test.dart -v`
Expected: FAIL

**Step 3: Implement MatchingCardWidget**

`StatefulWidget` that takes:
- `MatchingPairsQuestion question`
- `void Function(double score) onCompleted` — fires with 0.0-1.0 proportional score
- `VoidCallback onNext`

UI layout:
- Title: "Match the pairs" (`AppTypography.headlineMedium`)
- Two columns side by side (left: concepts, right: facts — both shuffled)
- Each item is a tappable card showing text
- State: `selectedLeft` (index?), `matchedPairs` (Set<int>), `mistakes` (int)
- Interaction: tap left → highlight it → tap right → if correct pair, lock both green and add to `matchedPairs`; if wrong, flash right item red for 300ms, increment mistakes
- When `matchedPairs.length == pairs.length`, calculate score and call `onCompleted`
- Score = `(pairs.length - mistakes) / pairs.length` clamped to 0.0-1.0

**Step 4: Run tests to verify they pass**

Run: `flutter test test/widget_tests/matching_card_widget_test.dart -v`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/aquarium_app/lib/screens/spaced_repetition_practice/widgets/matching_card_widget.dart apps/aquarium_app/test/widget_tests/matching_card_widget_test.dart
git commit -m "feat: add MatchingCardWidget for pair-matching practice questions"
```

---

### Task 5: Integrate QuestionResolver into session start

**Files:**
- Modify: `apps/aquarium_app/lib/providers/spaced_repetition_provider.dart:464-481` (startSession method)
- Read: `apps/aquarium_app/lib/providers/lesson_provider.dart` (lessonProvider, LessonState)

**Step 1: Add resolvedQuestions to SpacedRepetitionState**

Add a `List<ResolvedQuestion> resolvedQuestions` field to `SpacedRepetitionState` (defaults to `const []`). Update `copyWith` to include it.

**Step 2: Update startSession to resolve questions**

After creating the `ReviewSession` via `ReviewQueueService.createSession(...)`, call:
```dart
final lessonState = _ref.read(lessonProvider);
final resolved = QuestionResolver.resolveQuestions(
  cards: session.cards,
  lessonState: lessonState,
);
state = state.copyWith(
  currentSession: session,
  resolvedQuestions: resolved,
  clearError: true,
);
```

Import `question_resolver.dart` and `resolved_question.dart`.

**Step 3: Run existing tests**

Run: `flutter test test/providers/spaced_repetition_provider_test.dart -v`
Expected: PASS (existing tests should still work — resolvedQuestions defaults to empty)

**Step 4: Commit**

```bash
git add apps/aquarium_app/lib/providers/spaced_repetition_provider.dart
git commit -m "feat: integrate QuestionResolver into session start"
```

---

### Task 6: Rewrite ReviewSessionScreen to use active questions

**Files:**
- Modify: `apps/aquarium_app/lib/screens/spaced_repetition_practice/review_session_screen.dart`
- Read: `apps/aquarium_app/lib/screens/spaced_repetition_practice/widgets/mc_card_widget.dart`
- Read: `apps/aquarium_app/lib/screens/spaced_repetition_practice/widgets/matching_card_widget.dart`

**Step 1: Replace _buildCardContent and _buildAnswerButtons**

The current flow is:
- `_buildCardContent()` shows concept name + "Review this concept:" text
- `_buildAnswerButtons()` shows Forgot / Remembered buttons
- `_recordAnswer(bool correct)` handles the response

Replace with:
- Read `resolvedQuestions` from `ref.read(spacedRepetitionProvider).resolvedQuestions`
- Get current question: `resolvedQuestions[_currentCardIndex]`
- If `MultipleChoiceQuestion`: render `McCardWidget` with `onAnswered: (correct) => _recordAnswer(correct)` and `onNext: _nextCard`
- If `MatchingPairsQuestion`: render `MatchingCardWidget` with `onCompleted: (score) => _recordMatchingResult(score)` and `onNext: _nextCard`

Remove `_showingAnswer` state — the individual card widgets handle their own reveal state.

**Step 2: Add _recordMatchingResult method**

For matching pairs, convert the proportional score to a boolean for `recordSessionResult`:
```dart
void _recordMatchingResult(double score) {
  // Score >= 0.5 counts as correct for strength calculation
  _recordAnswer(score >= 0.5);
}
```

**Step 3: Keep the progress bar, mastery indicator, exit dialog, and completion dialog unchanged**

These work well as-is. Only the card content area and answer buttons change.

**Step 4: Verify manually**

Open app → Practice tab → start a session → verify MC questions show with 4 options → verify matching pairs appear periodically → verify session completion still works.

**Step 5: Run all tests**

Run: `flutter test`
Expected: All pass (826+)

**Step 6: Commit**

```bash
git add apps/aquarium_app/lib/screens/spaced_repetition_practice/review_session_screen.dart
git commit -m "feat: rewrite review session to use active MC and matching questions"
```

---

### Task 7: Ensure lesson data is loaded before session starts

**Files:**
- Modify: `apps/aquarium_app/lib/providers/spaced_repetition_provider.dart` (startSession)
- Read: `apps/aquarium_app/lib/providers/lesson_provider.dart` (ensurePathLoaded)

**Step 1: Pre-load lesson paths needed for session cards**

Before calling `QuestionResolver.resolveQuestions`, ensure the relevant learning paths are loaded:

```dart
// Collect unique path IDs from session cards
final pathIds = session.cards.map((c) => c.conceptId.split('_').first).toSet();
final lessonNotifier = _ref.read(lessonProvider.notifier);
for (final pathId in pathIds) {
  await lessonNotifier.ensurePathLoaded(pathId);
}
final lessonState = _ref.read(lessonProvider);
```

This ensures `QuestionResolver` has access to lesson content for question generation.

**Step 2: Test and commit**

Run: `flutter test`
Expected: All pass

```bash
git add apps/aquarium_app/lib/providers/spaced_repetition_provider.dart
git commit -m "fix: pre-load lesson paths before resolving session questions"
```

---

### Task 8: Run full verification

**Step 1: Static analysis**

Run: `flutter analyze`
Expected: No issues

**Step 2: Full test suite**

Run: `flutter test`
Expected: All pass

**Step 3: Manual testing on device**

1. Open app → Practice tab → Start Standard Practice session
2. Verify MC questions appear with 4 tappable options
3. Tap correct answer → green highlight, explanation shown, "Next Card" appears
4. Tap wrong answer → red highlight, correct answer shown green, explanation shown
5. After ~5 cards, verify a matching pairs question appears
6. Complete matching pairs → verify proportional scoring
7. Complete session → verify completion dialog shows correct stats
8. Test from Settings → Replay Onboarding → go through fresh to verify cold start

**Step 4: Install on device**

Run: `flutter install -d emulator-5554`

**Step 5: Final commit if any fixes**

---

## Critical Files Reference

| File | Role |
|------|------|
| `lib/models/resolved_question.dart` | NEW — Question data models |
| `lib/services/question_resolver.dart` | NEW — Resolution logic |
| `lib/screens/.../widgets/mc_card_widget.dart` | NEW — MC question UI |
| `lib/screens/.../widgets/matching_card_widget.dart` | NEW — Matching pairs UI |
| `lib/providers/spaced_repetition_provider.dart` | MODIFY — Add resolution to session start |
| `lib/screens/.../review_session_screen.dart` | MODIFY — Use active questions |
| `lib/models/learning.dart` | READ — Lesson, QuizQuestion, LessonSection |
| `lib/models/spaced_repetition.dart` | READ — ReviewCard, ReviewSession |
| `lib/providers/lesson_provider.dart` | READ — LessonState, getLesson, getPath |
| `lib/utils/concept_display_names.dart` | READ — conceptDisplayName() |
| `lib/theme/app_theme.dart` | READ — Design system tokens |
