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
}
