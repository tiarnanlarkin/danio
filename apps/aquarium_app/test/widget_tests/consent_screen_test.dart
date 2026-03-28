// Widget tests for ConsentScreen.
//
// Run: flutter test test/widget_tests/consent_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/onboarding/consent_screen.dart';
import 'package:danio/providers/user_profile_provider.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap({VoidCallback? onConsentGiven}) {
  SharedPreferences.setMockInitialValues({});
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async {
        return SharedPreferences.getInstance();
      }),
    ],
    child: MaterialApp(
      home: ConsentScreen(onConsentGiven: onConsentGiven ?? () {}),
    ),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ConsentScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(ConsentScreen), findsOneWidget);
    });

    testWidgets('shows Your Privacy Matters heading', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Your Privacy Matters'), findsOneWidget);
    });

    testWidgets('shows age confirmation checkbox', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(
        find.text('I confirm I am 13 years of age or older'),
        findsOneWidget,
      );
    });

    testWidgets('shows Accept Analytics button', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Accept Analytics'), findsOneWidget);
    });

    testWidgets('shows No Thanks button', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('No Thanks'), findsOneWidget);
    });

    testWidgets('shows privacy tip icon', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byIcon(Icons.privacy_tip_outlined), findsOneWidget);
    });
  });
}
