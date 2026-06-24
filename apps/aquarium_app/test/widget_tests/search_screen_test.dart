// Widget tests for SearchScreen.
//
// Run: flutter test test/widget_tests/search_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/models/models.dart';
import 'package:danio/screens/emergency_guide_screen.dart';
import 'package:danio/screens/search_screen.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/utils/navigation_throttle.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap({
  List<Tank> tanks = const [],
  Map<String, List<LogEntry>> logsByTankId = const {},
}) {
  final memStorage = InMemoryStorageService();
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(memStorage),
      tanksProvider.overrideWith((ref) async => tanks),
      for (final entry in logsByTankId.entries)
        allLogsProvider(entry.key).overrideWith((ref) async => entry.value),
    ],
    child: const MaterialApp(home: SearchScreen()),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

Tank _tank({String id = 'tank-1', String name = 'River Tank'}) {
  final now = DateTime(2026, 6, 13);
  return Tank(
    id: id,
    name: name,
    type: TankType.freshwater,
    volumeLitres: 120,
    startDate: now,
    targets: WaterTargets.freshwaterTropical(),
    createdAt: now,
    updatedAt: now,
  );
}

LogEntry _log({
  String id = 'log-1',
  required String tankId,
  required String title,
  required String notes,
  LogType type = LogType.observation,
}) {
  final now = DateTime(2026, 6, 13, 9);
  return LogEntry(
    id: id,
    tankId: tankId,
    type: type,
    timestamp: now,
    title: title,
    notes: notes,
    createdAt: now,
  );
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

    testWidgets('backup searches find app destinations', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.enterText(find.byType(TextField), 'backup');
      await _advance(tester);

      expect(find.text('App'), findsOneWidget);
      expect(find.text('Backup & Restore'), findsOneWidget);
      expect(
        find.text('Export, import, and protect local aquarium backups'),
        findsOneWidget,
      );
    });

    testWidgets('tablet keeps search result cards in a readable rail', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.enterText(find.byType(TextField), 'backup');
      await _advance(tester);

      expect(
        tester.getSize(find.byType(Card).first).width,
        lessThanOrEqualTo(720),
      );
    });

    testWidgets('tool searches find calculator destinations', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.enterText(find.byType(TextField), 'unit converter');
      await _advance(tester);

      expect(find.text('Tools'), findsOneWidget);
      expect(find.text('Unit Converter'), findsOneWidget);
      expect(
        find.text('Convert litres, gallons, cm, inches, and temperature'),
        findsOneWidget,
      );
    });

    testWidgets('learning searches find lesson path destinations', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.enterText(find.byType(TextField), 'nitrogen cycle');
      await _advance(tester);

      expect(find.text('Learning'), findsOneWidget);
      expect(find.text('The Nitrogen Cycle'), findsOneWidget);
      expect(
        find.text(
          'The #1 thing every fishkeeper must understand. Master this and your fish will thrive.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('log searches find matching tank history', (tester) async {
      final tank = _tank();
      await tester.pumpWidget(
        _wrap(
          tanks: [tank],
          logsByTankId: {
            tank.id: [
              _log(
                tankId: tank.id,
                title: 'Brown algae on glass',
                notes: 'Diatoms spreading near the filter outlet',
              ),
            ],
          },
        ),
      );
      await _advance(tester);

      await tester.enterText(find.byType(TextField), 'diatoms');
      await _advance(tester);

      expect(find.text('Logs'), findsOneWidget);
      expect(find.text('Brown algae on glass'), findsOneWidget);
      expect(
        find.text('River Tank - Diatoms spreading near the filter outlet'),
        findsOneWidget,
      );
    });
  });
}
