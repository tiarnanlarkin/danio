// Widget tests for HeartIndicator.
//
// Run: flutter test test/widget_tests/heart_indicator_test.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/widgets/hearts_widgets.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/models/user_profile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

UserProfile _fakeProfile({int hearts = 5}) => UserProfile(
      id: 'u_hearts',
      name: 'Test User',
      hearts: hearts,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

Widget _wrap({
  bool compact = false,
  bool enforceMinimumTapTarget = false,
  int hearts = 5,
}) {
  SharedPreferences.setMockInitialValues({
    'user_profile': jsonEncode(_fakeProfile(hearts: hearts).toJson()),
  });
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        return SharedPreferences.getInstance();
      }),
    ],
    child: MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          actions: [
            HeartIndicator(
              compact: compact,
              enforceMinimumTapTarget: enforceMinimumTapTarget,
            ),
          ],
        ),
        body: const SizedBox.shrink(),
      ),
    ),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(seconds: 1));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HeartIndicator', () {
    test('energy surfaces use accessible brand amber tokens', () {
      final sources = [
        File('lib/widgets/hearts_widgets.dart'),
        File('lib/widgets/gamification_dashboard.dart'),
        File('lib/widgets/hearts_overlay.dart'),
      ].map((file) => MapEntry(file.path, file.readAsStringSync()));

      for (final source in sources) {
        expect(source.value, contains('AppColors.primary'), reason: source.key);
        expect(
          source.value,
          isNot(contains('0xFFFFA000')),
          reason: source.key,
        );
        expect(
          source.value,
          isNot(contains('0x80FFA000')),
          reason: source.key,
        );
        expect(
          source.value,
          isNot(contains('0x4DFFA000')),
          reason: source.key,
        );
        expect(
          source.value,
          isNot(contains('0x33FFA000')),
          reason: source.key,
        );
        expect(
          source.value,
          isNot(contains('0x26FFA000')),
          reason: source.key,
        );
        expect(
          source.value,
          isNot(contains('0x1AFFA000')),
          reason: source.key,
        );
        expect(
          source.value,
          isNot(contains('0x0DFFA000')),
          reason: source.key,
        );
        expect(source.value, isNot(contains('âš¡')), reason: source.key);
        expect(source.value, isNot(contains('ðŸ')), reason: source.key);
        expect(source.value, isNot(contains('⚡')), reason: source.key);
        expect(source.value, isNot(contains('🎉')), reason: source.key);
        expect(source.value, isNot(contains('💪')), reason: source.key);
      }

      final heartsSource = sources
          .singleWhere((source) => source.key.endsWith('hearts_widgets.dart'))
          .value;
      expect(heartsSource, contains('AppColors.primaryAlpha05'));
      expect(heartsSource, contains('AppColors.primaryAlpha10'));
      expect(heartsSource, contains('AppColors.primaryAlpha15'));
      expect(heartsSource, contains('AppColors.primaryAlpha20'));
      expect(heartsSource, contains('AppColors.primaryAlpha30'));
      expect(heartsSource, contains('AppColors.primaryAlpha50'));
    });

    testWidgets('renders in normal mode without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(HeartIndicator), findsOneWidget);
    });

    testWidgets('renders in compact mode without throwing', (tester) async {
      await tester.pumpWidget(_wrap(compact: true));
      await _advance(tester);
      expect(find.byType(HeartIndicator), findsOneWidget);
    });

    testWidgets('opted-in compact energy control keeps a 48dp touch target',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _wrap(compact: true, enforceMinimumTapTarget: true),
      );
      await _advance(tester);

      final control = find.bySemanticsLabel(RegExp('energy remaining'));
      expect(control, findsOneWidget);
      final size = tester.getSize(control);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      semantics.dispose();
    });

    test('minimum target opt-in stays scoped to the Tank root', () {
      final homeSource = File(
        'lib/screens/home/home_screen.dart',
      ).readAsStringSync();
      expect(homeSource, contains('enforceMinimumTapTarget: true'));

      for (final path in [
        'lib/screens/practice_hub_screen.dart',
        'lib/screens/lesson/lesson_screen.dart',
        'lib/screens/spaced_repetition_practice/review_session_screen.dart',
      ]) {
        expect(
          File(path).readAsStringSync(),
          isNot(contains('enforceMinimumTapTarget')),
          reason: path,
        );
      }
    });

    testWidgets('shows energy count for a profile with full hearts (5/5)',
        (tester) async {
      await tester.pumpWidget(_wrap(hearts: 5));
      await _advance(tester);
      // HeartIndicator displays "current/max" energy, e.g. "5/5"
      expect(find.textContaining('5/5'), findsOneWidget);
    });

    testWidgets('shows correct count for a profile with 3 hearts',
        (tester) async {
      await tester.pumpWidget(_wrap(hearts: 3));
      await _advance(tester);
      expect(find.textContaining('3/'), findsOneWidget);
    });
  });
}
