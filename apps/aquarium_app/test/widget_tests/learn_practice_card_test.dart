import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/models/lesson_progress.dart';
import 'package:danio/models/user_profile.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/screens/learn/learn_practice_card.dart';
import 'package:danio/screens/tab_navigator.dart';

UserProfile _profileWithWeakLesson() {
  final now = DateTime(2026, 6, 27);
  return UserProfile(
    id: 'learn-practice-card-profile',
    name: 'Practice Tester',
    completedLessons: const ['tm_filter'],
    lessonProgress: {
      'tm_filter': LessonProgress(
        lessonId: 'tm_filter',
        completedDate: now.subtract(const Duration(days: 20)),
        strength: 30,
      ),
    },
    createdAt: now,
    updatedAt: now,
  );
}

Widget _wrap(
  ProviderContainer container, {
  double textScaleFactor = 1.0,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScaleFactor),
        ),
        child: child!,
      ),
      home: Scaffold(
        body: Consumer(
          builder: (context, ref, _) {
            final profile = ref.watch(userProfileProvider).valueOrNull;
            if (profile == null) return const SizedBox.shrink();
            return LearnPracticeCard(profile: profile);
          },
        ),
      ),
    ),
  );
}

Future<void> _advance(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'user_profile': jsonEncode(_profileWithWeakLesson().toJson()),
    });
  });

  testWidgets('opens the Practice hub instead of pushing review directly', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) async {
          return SharedPreferences.getInstance();
        }),
        currentTabProvider.overrideWith((ref) => 0),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(container));
    await _advance(tester);

    expect(find.text('Practice Mode'), findsOneWidget);
    expect(container.read(currentTabProvider), 0);

    await tester.tap(find.text('Practice Mode'));
    await tester.pumpAndSettle();

    expect(container.read(currentTabProvider), 1);
  });

  testWidgets('reflows the weak-lesson card at 2.0x on a phone', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) async {
          return SharedPreferences.getInstance();
        }),
        currentTabProvider.overrideWith((ref) => 0),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(container, textScaleFactor: 2.0));
    await _advance(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Practice Mode'), findsOneWidget);
    expect(find.text('Open Practice hub for weak-spot drills'), findsOneWidget);
  });
}
