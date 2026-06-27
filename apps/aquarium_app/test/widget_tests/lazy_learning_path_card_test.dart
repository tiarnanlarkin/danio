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

PathMetadata _lockedPathWithRawPrereqTitle() {
  return const PathMetadata(
    id: 'advanced_path',
    title: 'Advanced Path',
    description: 'A path that needs another path first.',
    emoji: '!',
    orderIndex: 1,
    lessonIds: ['advanced_intro'],
    prerequisitePathIds: ['missing_path'],
  );
}

PathMetadata _rawPrereqPathMeta() {
  return const PathMetadata(
    id: 'missing_path',
    title: 'missing_path',
    description: 'A prerequisite path with a raw ID-style title.',
    emoji: '!',
    orderIndex: 0,
    lessonIds: ['missing_lesson'],
  );
}

void main() {
  group('LazyLearningPathCard', () {
    testWidgets('locked path fallback formats raw prerequisite IDs', (
      tester,
    ) async {
      final lockedPath = _lockedPathWithRawPrereqTitle();
      final rawPrereq = _rawPrereqPathMeta();

      await tester.pumpWidget(
        _wrap(
          LazyLearningPathCard(
            metadata: lockedPath,
            completedLessons: 0,
            totalLessons: 1,
            userCompletedLessons: const [],
            allPathMetadata: [lockedPath, rawPrereq],
          ),
        ),
      );

      expect(find.text('Advanced Path'), findsOneWidget);
      expect(find.textContaining('Missing Path'), findsOneWidget);
      expect(find.textContaining('missing_path'), findsNothing);
    });

    testWidgets('opens a full-screen path detail view after path loads', (
      tester,
    ) async {
      final metadata = LessonProvider.allPathMetadata.firstWhere(
        (path) => path.id == 'nitrogen_cycle',
      );

      await tester.pumpWidget(
        _wrap(
          LazyLearningPathCard(
            metadata: metadata,
            completedLessons: 1,
            totalLessons: metadata.lessonIds.length,
            userCompletedLessons: const ['nc_intro'],
            allPathMetadata: LessonProvider.allPathMetadata,
          ),
        ),
      );

      await tester.tap(find.text(metadata.title));
      await tester.pumpAndSettle();

      expect(find.text('Open full path'), findsOneWidget);

      await tester.tap(find.text('Open full path'));
      await tester.pumpAndSettle();

      expect(find.text('Path overview'), findsOneWidget);
      expect(find.text('Why New Tanks Kill Fish'), findsOneWidget);
    });

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
