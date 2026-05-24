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

    testWidgets('tool cards expose one concise screen reader label', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      expect(
        find.bySemanticsLabel('Water Change, Calculate changes'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'Water Change\s+Water Change')),
        findsNothing,
      );
    });

    testWidgets('shows Stocking tool', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Stocking'), findsOneWidget);
    });

    testWidgets('shows multiple calculator tools in grid', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.textContaining('Calculator'), findsWidgets);
      expect(find.text('Dosing'), findsOneWidget);
    });

    testWidgets('Workshop remains the primary calculators hub', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      for (final label in const [
        'Water Change',
        'Stocking',
        'Dosing',
        'Unit Converter',
        'Tank Volume',
        'Lighting',
        'Compatibility',
        'Cycling Assistant',
        'Cost Tracker',
      ]) {
        final finder = find.text(label);
        if (finder.evaluate().isEmpty) {
          await tester.scrollUntilVisible(finder, 300);
          await tester.pumpAndSettle();
        }
        expect(finder, findsOneWidget);
      }
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

    testWidgets('tool cards fit a phone-sized screen without render overflow', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final flutterErrors = <FlutterErrorDetails>[];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = flutterErrors.add;

      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.scrollUntilVisible(find.text('Cost Tracker'), 300);
      await tester.pumpAndSettle();

      FlutterError.onError = originalOnError;

      final overflowErrors = flutterErrors.where(
        (details) => details.exceptionAsString().contains('overflowed'),
      );
      expect(overflowErrors, isEmpty);
    });

    testWidgets('keeps tool grid above the Android gesture navigation inset', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(InMemoryStorageService()),
          ],
          child: const MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                padding: EdgeInsets.only(bottom: 34),
                viewPadding: EdgeInsets.only(bottom: 34),
              ),
              child: WorkshopScreen(),
            ),
          ),
        ),
      );
      await _advance(tester);

      final scrollViewRect = tester.getRect(find.byType(CustomScrollView));
      expect(scrollViewRect.bottom, lessThanOrEqualTo(844 - 34));
    });
  });
}
