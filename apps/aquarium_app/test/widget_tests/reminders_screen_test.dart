// Widget tests for RemindersScreen.
//
// Run: flutter test test/widget_tests/reminders_screen_test.dart
//
// Note: The EmptyState widget (contains MascotBubble) uses a repeating
// fish-bob animation, so pumpAndSettle never settles. We advance time
// with pump(Duration) calls instead.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/reminders_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const ProviderScope(
    child: MaterialApp(
      home: RemindersScreen(),
    ),
  );
}

/// Advance far enough for async prefs load and animations to settle.
Future<void> _advance(WidgetTester tester) async {
  // First frame renders loading state
  await tester.pump();
  // Let the async prefs load complete and re-render
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RemindersScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(RemindersScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Reminders'), findsOneWidget);
    });

    testWidgets('shows scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows add button (FAB or icon)', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(
        find.byType(FloatingActionButton).evaluate().isNotEmpty ||
            find.byIcon(Icons.add).evaluate().isNotEmpty ||
            find.textContaining('Add').evaluate().isNotEmpty,
        isTrue,
        reason: 'Should have some way to add a reminder',
      );
    });

    testWidgets('shows reminder when data exists in prefs', (tester) async {
      // Use full JSON matching _Reminder.fromJson schema
      SharedPreferences.setMockInitialValues({
        'aquarium_reminders':
            '[{"id":"1","title":"Water Change","notes":null,"category":"water",'
            '"nextDue":"${DateTime.now().add(const Duration(days: 2)).toIso8601String()}",'
            '"lastCompleted":null,"isRecurring":true,"frequency":"weekly"}]',
      });

      await tester.pumpWidget(_wrap());
      await _advance(tester);

      expect(find.text('Water Change'), findsOneWidget);
    });
  });
}
