// Widget tests for LearnScreen.
//
// Run: flutter test test/widget_tests/learn_screen_test.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/models/spaced_repetition.dart';
import 'package:danio/models/user_profile.dart';
import 'package:danio/providers/spaced_repetition_provider.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/screens/learn/lazy_learning_path_card.dart';
import 'package:danio/screens/learn/learn_screen.dart';
import 'package:danio/widgets/core/glass_card.dart';

const _tabletSurface = Size(2000, 1200);
const _maxReadableLearnWidth = 720.0;

class _FakeSrNotifier extends StateNotifier<SpacedRepetitionState>
    implements SpacedRepetitionNotifier {
  _FakeSrNotifier()
    : super(
        SpacedRepetitionState(
          cards: const [],
          stats: ReviewStats(
            totalCards: 0,
            dueCards: 0,
            weakCards: 0,
            masteredCards: 0,
            averageStrength: 0.0,
            cardsByMastery: const {},
            reviewsToday: 0,
            currentStreak: 0,
          ),
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

UserProfile _profile() {
  final now = DateTime(2026, 6, 23);
  return UserProfile(
    id: 'learn-screen-profile',
    name: 'Local Learner',
    completedLessons: const ['nc_intro'],
    createdAt: now,
    updatedAt: now,
  );
}

Widget _wrap() {
  SharedPreferences.setMockInitialValues({
    'user_profile': jsonEncode(_profile().toJson()),
    'guidance_seen_learnFirstVisit': true,
  });

  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        return SharedPreferences.getInstance();
      }),
      spacedRepetitionProvider.overrideWith((ref) => _FakeSrNotifier()),
    ],
    child: const MaterialApp(home: LearnScreen()),
  );
}

Future<void> _advance(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LearnScreen', () {
    testWidgets('keeps primary learning surfaces readable on tablet', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(_tabletSurface);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await _advance(tester);

      expect(tester.takeException(), isNull);

      final nextLessonCard = find.ancestor(
        of: find.text('Today\'s lesson'),
        matching: find.byType(GlassCard),
      );
      final storiesCard = find.ancestor(
        of: find.text('Interactive Stories'),
        matching: find.byType(GlassCard),
      );
      final firstPathCard = find.byType(LazyLearningPathCard).first;

      expect(nextLessonCard, findsOneWidget);
      expect(storiesCard, findsOneWidget);
      expect(firstPathCard, findsOneWidget);

      expect(
        tester.getSize(nextLessonCard).width,
        lessThanOrEqualTo(_maxReadableLearnWidth),
      );
      expect(
        tester.getSize(storiesCard).width,
        lessThanOrEqualTo(_maxReadableLearnWidth),
      );
      expect(
        tester.getSize(firstPathCard).width,
        lessThanOrEqualTo(_maxReadableLearnWidth),
      );
    });
  });
}
