import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'lesson completion achievement stats derive from persisted profile state',
    () {
      final source = File(
        'lib/screens/lesson/lesson_screen.dart',
      ).readAsStringSync();

      expect(
        source,
        isNot(
          contains('lessonsCompleted: profile.completedLessons.length + 1'),
        ),
      );
      expect(
        source,
        isNot(
          contains(
            'completedLessonIds: [...profile.completedLessons, widget.lesson.id]',
          ),
        ),
      );
      expect(
        source,
        isNot(
          matches(
            RegExp(
              r'unawaited\s*\(\s*ref\.read\(userProfileProvider\.notifier\)\s*'
              r'\.incrementPerfectScoreCount\(\)\s*,?\s*\)',
            ),
          ),
        ),
      );
      expect(
        source,
        matches(
          RegExp(
            r'await\s+ref\s*\.read\(userProfileProvider\.notifier\)\s*'
            r'\.incrementPerfectScoreCount\(\)',
          ),
        ),
      );
    },
  );
}
