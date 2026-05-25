import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lesson completion does not stack separate celebration dialogs', () {
    final lessonScreen = File(
      'lib/screens/lesson/lesson_screen.dart',
    ).readAsStringSync();
    final completionFlow = File(
      'lib/screens/lesson/lesson_completion_flow.dart',
    ).readAsStringSync();

    expect(lessonScreen, isNot(contains('LessonCelebrationOverlay.show(')));
    expect(completionFlow, isNot(contains('LevelUpDialog.show(')));
    expect(completionFlow, isNot(contains('showLevelUpCelebration(')));
  });

  test('next lesson reward sheet clears the persistent bottom dock', () {
    final completionFlow = File(
      'lib/screens/lesson/lesson_completion_flow.dart',
    ).readAsStringSync();

    expect(completionFlow, contains('SingleChildScrollView'));
    expect(completionFlow, contains('DanioBottomDock.height'));
    expect(completionFlow, contains('viewPadding.bottom'));
    expect(completionFlow, contains('_completionSheetBottomClearance(ctx)'));
  });
}
