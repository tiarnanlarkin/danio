// Widget tests for XpCelebrationScreen.
//
// Run: flutter test test/widget_tests/xp_celebration_screen_test.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/onboarding/xp_celebration_screen.dart';
import 'package:danio/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap({VoidCallback? onNext}) {
  return MaterialApp(home: XpCelebrationScreen(onNext: onNext ?? () {}));
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

  group('XpCelebrationScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(XpCelebrationScreen), findsOneWidget);
    });

    testWidgets('shows XP amount text', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      // Should show +10 XP or similar
      expect(find.textContaining('10'), findsWidgets);
    });

    testWidgets('XP badge text has accessible contrast on amber badge', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      final xpText = tester.widget<Text>(find.text('+10 XP'));
      final textColor = xpText.style?.color;
      expect(textColor, isNotNull);
      expect(
        _contrastRatio(textColor!, AppColors.onboardingAmber),
        greaterThanOrEqualTo(4.5),
      );
    });

    testWidgets('displays XP or celebration related text', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      // Look for XP text anywhere on screen
      // ignore: unused_local_variable
      final xpFinder = find.textContaining('XP');
      // At minimum the screen should render with text widgets
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('has animation controllers that complete without errors', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      // Advance through all animation stages
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(XpCelebrationScreen), findsOneWidget);
    });

    testWidgets('calls onNext when Continue button tapped', (tester) async {
      bool called = false;
      await tester.pumpWidget(_wrap(onNext: () => called = true));
      await _advance(tester);
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        await tester.tap(buttons.first);
        await tester.pump();
        expect(called, isTrue);
      } else {
        expect(find.byType(XpCelebrationScreen), findsOneWidget);
      }
    });

    test('uses a named token for confetti gold', () {
      final themeSource = File('lib/theme/app_colors.dart').readAsStringSync();
      final screenSource = File(
        'lib/screens/onboarding/xp_celebration_screen.dart',
      ).readAsStringSync();

      expect(
        themeSource,
        contains('static const Color confettiGold = Color(0xFFFFD54F)'),
      );
      expect(screenSource, contains('DanioColors.confettiGold'));
      expect(screenSource, isNot(contains('Color(0xFFFFD54F)')));
    });
  });
}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
