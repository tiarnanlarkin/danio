// Widget tests for XpProgressBar.
//
// Run: flutter test test/widget_tests/xp_progress_bar_test.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/widgets/xp_progress_bar.dart';
import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/models/user_profile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

UserProfile _fakeProfile({int totalXp = 0}) => UserProfile(
      id: 'u_test',
      name: 'Test User',
      totalXp: totalXp,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

Widget _wrap({int totalXp = 0, bool showLabels = true, bool showLevel = true}) {
  SharedPreferences.setMockInitialValues({
    'user_profile': jsonEncode(_fakeProfile(totalXp: totalXp).toJson()),
  });
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        return SharedPreferences.getInstance();
      }),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: XpProgressBar(showLabels: showLabels, showLevel: showLevel),
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

  group('XpProgressBar', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(XpProgressBar), findsOneWidget);
    });

    testWidgets('shows Level label when showLabels and showLevel are true',
        (tester) async {
      await tester.pumpWidget(_wrap(totalXp: 0));
      await _advance(tester);
      // A new profile starts at Level 1
      expect(find.textContaining('Level'), findsOneWidget);
    });

    testWidgets('hides level text when showLabels is false', (tester) async {
      await tester.pumpWidget(
        _wrap(totalXp: 50, showLabels: false, showLevel: false),
      );
      await _advance(tester);
      expect(find.textContaining('Level'), findsNothing);
    });
  });
}
