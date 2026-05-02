// Widget tests for WorkshopScreen.
//
// Run: flutter test test/widget_tests/workshop_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/providers/storage_provider.dart';
import 'package:danio/screens/workshop_screen.dart';
import 'package:danio/services/storage_service.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(InMemoryStorageService()),
    ],
    child: const MaterialApp(home: WorkshopScreen()),
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

  group('WorkshopScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(WorkshopScreen), findsOneWidget);
    });

    testWidgets('shows Workshop title', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      // Title contains Workshop (with emoji prefix in SliverAppBar)
      expect(find.textContaining('Workshop'), findsWidgets);
    });

    testWidgets('does not show an automatic first-visit snackbar', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('shows Water Change tool', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Water Change'), findsOneWidget);
    });

    testWidgets('shows Stocking tool', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Stocking'), findsOneWidget);
    });

    testWidgets('shows multiple calculator tools in grid', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      // Multiple tool cards should be present (first visible ones)
      expect(find.text('CO₂ Calculator'), findsOneWidget);
      expect(find.text('Dosing'), findsOneWidget);
    });

    testWidgets(
      'shows Cycling Assistant as tank-dependent when no tanks exist',
      (tester) async {
        await tester.pumpWidget(_wrap());
        await _advance(tester);

        await tester.scrollUntilVisible(find.text('Cycling Assistant'), 300);
        await tester.pumpAndSettle();

        expect(find.text('Cycling Assistant'), findsOneWidget);
        expect(find.text('Add a tank first'), findsOneWidget);
        expect(find.byIcon(Icons.lock_outline), findsWidgets);
      },
    );
  });
}
