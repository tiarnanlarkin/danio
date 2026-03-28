// Widget tests for DebugMenuScreen.
//
// Run: flutter test test/widget_tests/debug_menu_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/debug_menu_screen.dart';
import 'package:danio/providers/user_profile_provider.dart';

Widget _wrap() {
  SharedPreferences.setMockInitialValues({});
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        return SharedPreferences.getInstance();
      }),
    ],
    child: const MaterialApp(home: DebugMenuScreen()),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DebugMenuScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(DebugMenuScreen), findsOneWidget);
    });

    testWidgets('shows Debug Menu app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('🐛 Debug Menu'), findsOneWidget);
    });

    testWidgets('shows Onboarding section header', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Onboarding'), findsOneWidget);
    });

    testWidgets('shows ListView', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows Complete Onboarding tile', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Complete Onboarding'), findsOneWidget);
    });
  });
}
