import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/providers/lesson_provider.dart';
import 'package:danio/screens/learn/lazy_learning_path_card.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Center(child: SizedBox(width: 420, child: child)),
      ),
    ),
  );
}

PathMetadata _missingPathMeta() {
  return const PathMetadata(
    id: 'missing_path',
    title: 'Missing Path',
    description: 'A path that intentionally has no lesson bundle.',
    emoji: '!',
    orderIndex: 0,
    lessonIds: ['missing_lesson'],
  );
}

void main() {
  group('LazyLearningPathCard', () {
    testWidgets('shows a retryable error when path loading fails', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          LazyLearningPathCard(
            metadata: _missingPathMeta(),
            completedLessons: 0,
            totalLessons: 1,
            userCompletedLessons: const [],
            allPathMetadata: [_missingPathMeta()],
          ),
        ),
      );

      await tester.tap(find.text('Missing Path'));
      await tester.pumpAndSettle();

      expect(find.text('Couldn\'t load this path'), findsOneWidget);
      expect(find.text('Check your connection and try again.'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
