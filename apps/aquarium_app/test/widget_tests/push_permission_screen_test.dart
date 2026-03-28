// Widget tests for PushPermissionScreen.
//
// Run: flutter test test/widget_tests/push_permission_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/onboarding/push_permission_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap({VoidCallback? onAllow, VoidCallback? onSkip}) {
  return MaterialApp(
    home: PushPermissionScreen(
      onAllow: onAllow ?? () {},
      onSkip: onSkip ?? () {},
    ),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PushPermissionScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(PushPermissionScreen), findsOneWidget);
    });

    testWidgets('shows allow button', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Yes, keep me informed →'), findsOneWidget);
    });

    testWidgets('shows skip button', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Not right now'), findsOneWidget);
    });

    testWidgets('calls onAllow when primary button tapped', (tester) async {
      bool allowed = false;
      await tester.pumpWidget(_wrap(onAllow: () => allowed = true));
      await _advance(tester);

      await tester.tap(find.text('Yes, keep me informed →'));
      await tester.pump();

      expect(allowed, isTrue);
    });

    testWidgets('calls onSkip when skip button tapped', (tester) async {
      bool skipped = false;
      await tester.pumpWidget(_wrap(onSkip: () => skipped = true));
      await _advance(tester);

      await tester.tap(find.text('Not right now'));
      await tester.pump();

      expect(skipped, isTrue);
    });
  });
}
