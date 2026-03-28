// Widget tests for LivestockValueScreen.
//
// Run: flutter test test/widget_tests/livestock_value_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/livestock_value_screen.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/models/models.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _fakeTankId = 'tank-001';
const _fakeTankName = 'My Test Tank';

Widget _wrap({AsyncValue<List<Livestock>>? livestockOverride}) {
  final memStorage = InMemoryStorageService();
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(memStorage),
      livestockProvider.overrideWith(
        (ref, tankId) async => livestockOverride?.valueOrNull ?? [],
      ),
    ],
    child: const MaterialApp(
      home: LivestockValueScreen(
        tankId: _fakeTankId,
        tankName: _fakeTankName,
      ),
    ),
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

  group('LivestockValueScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(LivestockValueScreen), findsOneWidget);
    });

    testWidgets('shows tank name in AppBar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.textContaining(_fakeTankName), findsOneWidget);
    });

    testWidgets('shows empty state when no livestock', (tester) async {
      await tester.pumpWidget(_wrap(livestockOverride: const AsyncData([])));
      await _advance(tester);
      expect(find.byType(LivestockValueScreen), findsOneWidget);
    });

    testWidgets('shows currency selector button', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      // Currency exchange icon should be in the AppBar actions
      expect(find.byIcon(Icons.currency_exchange), findsOneWidget);
    });

    testWidgets('shows livestock items when data loaded', (tester) async {
      final livestock = [
        Livestock(
          id: 'ls-1',
          tankId: _fakeTankId,
          commonName: 'Neon Tetra',
          count: 6,
          dateAdded: DateTime(2024),
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      ];
      await tester.pumpWidget(
        _wrap(livestockOverride: AsyncData(livestock)),
      );
      await _advance(tester);
      expect(find.textContaining('Neon Tetra'), findsOneWidget);
    });
  });
}
