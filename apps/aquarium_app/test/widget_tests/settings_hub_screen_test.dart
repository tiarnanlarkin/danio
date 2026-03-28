// Widget tests for SettingsHubScreen.
//
// Run: flutter test test/widget_tests/settings_hub_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/settings_hub_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const ProviderScope(
    child: MaterialApp(home: SettingsHubScreen()),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(seconds: 1));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsHubScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(SettingsHubScreen), findsOneWidget);
    });

    testWidgets('shows More title in AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('shows Shop Street category', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Shop Street'), findsOneWidget);
    });

    testWidgets('shows Achievements category', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Achievements'), findsOneWidget);
    });

    testWidgets('shows Workshop category', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Workshop'), findsOneWidget);
    });
  });
}
