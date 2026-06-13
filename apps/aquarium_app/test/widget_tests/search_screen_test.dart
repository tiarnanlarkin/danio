// Widget tests for SearchScreen.
//
// Run: flutter test test/widget_tests/search_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/emergency_guide_screen.dart';
import 'package:danio/screens/search_screen.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/utils/navigation_throttle.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  final memStorage = InMemoryStorageService();
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(memStorage),
      tanksProvider.overrideWith((ref) async => []),
    ],
    child: const MaterialApp(home: SearchScreen()),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    NavigationThrottle.reset();
  });

  group('SearchScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(SearchScreen), findsOneWidget);
    });

    testWidgets('shows a text field for search input', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows hint text in search field', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(
        find.text('Search tanks, fish, equipment, guides...'),
        findsOneWidget,
      );
    });

    testWidgets('shows scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('does not show clear button when query is empty', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('emergency searches open the Emergency Guide', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.enterText(find.byType(TextField), 'ammonia emergency');
      await _advance(tester);

      expect(find.text('Guides'), findsOneWidget);
      expect(find.text('Emergency Guide'), findsOneWidget);
      expect(
        find.text(
          'Urgent steps for water spikes, gasping, illness, injury, and equipment failure',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Emergency Guide'));
      await tester.pumpAndSettle();

      expect(find.byType(EmergencyGuideScreen), findsOneWidget);
    });
  });
}
