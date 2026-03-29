// Widget tests for TabNavigator.
//
// Run: flutter test test/widget_tests/tab_navigator_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/tab_navigator.dart';
import 'package:danio/providers/spaced_repetition_provider.dart';
import 'package:danio/models/spaced_repetition.dart';

// ---------------------------------------------------------------------------
// Stub
// ---------------------------------------------------------------------------

/// Returns a [SpacedRepetitionState] with zero cards — safe for tests.
SpacedRepetitionState _emptyState() => SpacedRepetitionState(
      cards: const [],
      stats: ReviewStats(
        totalCards: 0,
        dueCards: 0,
        weakCards: 0,
        masteredCards: 0,
        averageStrength: 0.0,
        cardsByMastery: const {},
        reviewsToday: 0,
        currentStreak: 0,
      ),
    );

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return ProviderScope(
    overrides: [
      // Replace the real notifier (which schedules notifications using the
      // unregistered FlutterLocalNotificationsPlugin) with a frozen stub.
      spacedRepetitionProvider
          .overrideWith((ref) => _FrozenSpacedRepetitionNotifier(ref)),
    ],
    child: const MaterialApp(home: TabNavigator()),
  );
}

/// A [SpacedRepetitionNotifier] sub-class that skips data loading and
/// notification scheduling.  We pass the real [Ref] so that the base class
/// `_ref` field is valid, but we override the constructor to immediately
/// set an empty state instead of calling `_loadData()` or
/// `_scheduleNotifications()`.
class _FrozenSpacedRepetitionNotifier extends SpacedRepetitionNotifier {
  _FrozenSpacedRepetitionNotifier(Ref ref) : super(ref) {
    // Immediately reset to the stub state so any in-flight async
    // work from the super constructor becomes a no-op (state is already set).
    state = _emptyState();
  }
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

  group('TabNavigator — smoke tests', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(TabNavigator), findsOneWidget);
    });

    testWidgets('shows bottom NavigationBar', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('shows 5 navigation destinations', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(NavigationDestination), findsNWidgets(5));
    });

    testWidgets('shows Learn tab label', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Learn'), findsWidgets);
    });

    testWidgets('shows Practice tab label', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Practice'), findsWidgets);
    });

    testWidgets('shows Tank tab label', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Tank'), findsWidgets);
    });

    testWidgets('shows More tab label', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('More'), findsWidgets);
    });

    testWidgets('tab 0 is selected by default', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 0);
    });

    testWidgets('tapping Practice tab switches selectedIndex', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      await tester.tap(find.text('Practice').first);
      await _advance(tester);
      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 1);
    });
  });
}
