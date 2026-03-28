// Widget tests for AchievementsScreen.
//
// Run: flutter test test/widget_tests/achievements_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/achievements_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const ProviderScope(
    child: MaterialApp(
      home: AchievementsScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AchievementsScreen — basic rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(AchievementsScreen), findsOneWidget);
    });

    testWidgets('shows Trophy Case app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      // Title contains trophy emoji + text
      expect(find.textContaining('Trophy Case'), findsOneWidget);
    });

    testWidgets('shows progress header with unlock counts', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      // Should show "X / Y" format for achievement count
      expect(find.textContaining('/'), findsWidgets);
    });

    testWidgets('shows filter chips for All, Unlocked, Locked', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Unlocked'), findsOneWidget);
      expect(find.text('Locked'), findsOneWidget);
    });

    testWidgets('has sort menu button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byIcon(Icons.sort), findsOneWidget);
    });
  });

  group('AchievementsScreen — filtering', () {
    testWidgets('tapping Locked filter chip changes selection', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Tap the "Locked" filter chip
      await tester.tap(find.text('Locked'));
      await tester.pumpAndSettle();

      // Screen should still be present (no crash)
      expect(find.byType(AchievementsScreen), findsOneWidget);
    });

    testWidgets('sort menu opens on tap', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      expect(find.text('Sort by Rarity'), findsOneWidget);
      expect(find.text('Sort by Name'), findsOneWidget);
    });
  });
}
