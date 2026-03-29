// Widget tests for HeartIndicator.
//
// Run: flutter test test/widget_tests/heart_indicator_test.dart

import 'dart:convert';

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

Widget _wrap({bool compact = false, int hearts = 5}) {
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
          actions: [HeartIndicator(compact: compact)],
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
