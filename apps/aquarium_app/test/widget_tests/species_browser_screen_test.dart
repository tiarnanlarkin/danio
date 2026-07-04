// Widget tests for SpeciesBrowserScreen.
//
// Run: flutter test test/widget_tests/species_browser_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/models/models.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/screens/emergency_guide_screen.dart';
import 'package:danio/screens/species_browser_screen.dart';
import 'package:danio/screens/stocking_calculator_screen.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/utils/navigation_throttle.dart';
import 'package:danio/widgets/core/app_card.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const ProviderScope(child: MaterialApp(home: SpeciesBrowserScreen()));
}

Tank _speciesTestTank() {
  final now = DateTime(2026, 6, 13);
  return Tank(
    id: 'species-test-tank',
    name: 'Species Test Tank',
    type: TankType.freshwater,
    volumeLitres: 120,
    startDate: now,
    targets: WaterTargets.freshwaterTropical(),
    createdAt: now,
    updatedAt: now,
  );
}

Widget _wrapWithTank({required InMemoryStorageService storage}) {
  final tank = _speciesTestTank();

  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(storage),
      tanksProvider.overrideWith((ref) async => [tank]),
    ],
    child: const MaterialApp(home: SpeciesBrowserScreen()),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _clearStorage() async {
  final storage = InMemoryStorageService();
  final tanks = await storage.getAllTanks();
  await storage.deleteAllTanks(tanks.map((tank) => tank.id).toList());
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    NavigationThrottle.reset();
    await _clearStorage();
  });

  group('SpeciesBrowserScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(SpeciesBrowserScreen), findsOneWidget);
    });

    testWidgets('shows app bar title Fish Database', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Fish Database'), findsOneWidget);
    });

    testWidgets('shows search field', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      // The search hint text should be visible
      expect(find.text('Search fish by name...'), findsOneWidget);
    });

    testWidgets('shows care level filter chips', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Beginner'), findsWidgets);
      expect(find.text('Intermediate'), findsWidgets);
    });

    testWidgets('shows species list items', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      // Species database is static — at least one card should be present
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('tablet keeps species list and detail cards readable', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await _advance(tester);

      final speciesCard = find
          .ancestor(of: find.text('Neon Tetra'), matching: find.byType(Card))
          .first;
      expect(tester.getSize(speciesCard).width, lessThanOrEqualTo(720));

      await tester.tap(find.text('Neon Tetra'));
      await tester.pumpAndSettle();

      final careActionsCard = find
          .ancestor(
            of: find.text('Care Actions'),
            matching: find.byType(AppCard),
          )
          .first;
      expect(tester.getSize(careActionsCard).width, lessThanOrEqualTo(720));
    });

    testWidgets('species detail opens Emergency Guide', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.tap(find.text('Neon Tetra'));
      await tester.pumpAndSettle();

      expect(find.text('Emergency Guide'), findsOneWidget);
      expect(
        find.text('Urgent steps for illness, injury, gasping, or unsafe water'),
        findsOneWidget,
      );

      await tester.tap(find.text('Emergency Guide'));
      await tester.pumpAndSettle();

      expect(find.byType(EmergencyGuideScreen), findsOneWidget);
    });

    testWidgets('species detail shows actionable care plan', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.tap(find.text('Neon Tetra'));
      await tester.pumpAndSettle();

      expect(find.text('Care Actions'), findsOneWidget);
      expect(find.text('Use a tank of at least 40 L.'), findsOneWidget);
      expect(find.text('Plan a group of 6 or more.'), findsOneWidget);
      expect(
        find.text('Keep water around 20-26 C and pH 6.0-7.0.'),
        findsOneWidget,
      );
      expect(
        find.text('Check the avoid list before adding tankmates.'),
        findsOneWidget,
      );
    });

    testWidgets('species detail shows care profile', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.tap(find.text('Neon Tetra'));
      await tester.pumpAndSettle();

      expect(find.text('Care Profile'), findsOneWidget);
      expect(
        find.text('Tank fit: 40 L+, middle swimmer, peaceful temperament.'),
        findsOneWidget,
      );
      expect(find.text('Group plan: keep 6 or more together.'), findsOneWidget);
      expect(
        find.text('Water window: 20-26 C, pH 6.0-7.0, GH 1-10.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Feeding style: Omnivore - flakes, micro pellets, frozen/live foods',
        ),
        findsOneWidget,
      );
    });

    testWidgets('species detail shows watch-for guidance', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.tap(find.text('Neon Tetra'));
      await tester.pumpAndSettle();

      expect(find.text('Watch For'), findsOneWidget);
      expect(
        find.text('Small groups: plan 6 or more, not a lone fish.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Tankmates: review Angelfish, Bettas, Large Cichlids before mixing.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Adult fit: plan around 3.5 cm adult size and 40 L minimum tank.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('species detail shows source trail', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.tap(find.text('Neon Tetra'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Source trail'));
      await tester.pumpAndSettle();

      expect(find.text('Source trail'), findsOneWidget);
      expect(find.text('FishBase'), findsOneWidget);
      expect(find.text('Merck Veterinary Manual'), findsOneWidget);
      expect(find.text('RSPCA fish welfare advice'), findsOneWidget);
    });

    testWidgets('species detail opens prefilled stocking calculator', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.tap(find.text('Neon Tetra'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Plan stocking fit'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Plan stocking fit'));
      await tester.pumpAndSettle();

      expect(find.byType(StockingCalculatorScreen), findsOneWidget);
      expect(find.text('Stocking Calculator'), findsOneWidget);
      expect(find.text('Neon Tetra'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
    });

    testWidgets('species detail opens prefilled add-to-tank dialog', (
      tester,
    ) async {
      final storage = InMemoryStorageService();

      await tester.pumpWidget(_wrapWithTank(storage: storage));
      await _advance(tester);

      await tester.tap(find.text('Neon Tetra'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Add to tank'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add to tank'));
      await tester.pumpAndSettle();

      expect(find.text('Add Livestock'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Neon Tetra'), findsOneWidget);
      expect(
        find.widgetWithText(TextField, 'Paracheirodon innesi'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextField, '6'), findsOneWidget);
    });

    testWidgets('species detail creates a tank care task', (tester) async {
      final storage = InMemoryStorageService();
      await storage.saveTank(_speciesTestTank());

      await tester.pumpWidget(_wrapWithTank(storage: storage));
      await _advance(tester);

      await tester.tap(find.text('Neon Tetra'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Create care task'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create care task'));
      await tester.pumpAndSettle();

      final tasks = await storage.getTasksForTank('species-test-tank');
      final task = tasks.singleWhere(
        (task) => task.title == 'Review Neon Tetra care plan',
      );

      expect(task.description, contains('Minimum group: 6'));
      expect(task.description, contains('Minimum tank: 40 L'));
      expect(task.description, contains('Temperature: 20-26 C'));
      expect(task.description, contains('pH: 6.0-7.0'));
      expect(task.recurrence, RecurrenceType.weekly);
      expect(task.priority, TaskPriority.normal);
      expect(task.isAutoGenerated, isTrue);
      expect(find.text('Neon Tetra care task added'), findsOneWidget);
    });

    testWidgets(
      'stale tank selections do not create orphan species care tasks',
      (tester) async {
        final storage = InMemoryStorageService();

        await tester.pumpWidget(_wrapWithTank(storage: storage));
        await _advance(tester);

        await tester.tap(find.text('Neon Tetra'));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Create care task'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Create care task'));
        await tester.pumpAndSettle();

        final tasks = await storage.getTasksForTank('species-test-tank');
        expect(tasks, isEmpty);
        expect(
          find.text('Could not create a care task for Neon Tetra'),
          findsOneWidget,
        );
      },
    );

    testWidgets('species detail saves fish to wishlist', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.tap(find.text('Neon Tetra'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Save to wishlist'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save to wishlist'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final prefs = await SharedPreferences.getInstance();
      final savedItems = prefs.getString('wishlist_items') ?? '';

      expect(savedItems, contains('Neon Tetra'));
      expect(savedItems, contains('Paracheirodon innesi'));
      expect(find.text('Saved to wishlist'), findsOneWidget);
    });

    testWidgets(
      'empty search state uses iconography instead of raw emoji text',
      (tester) async {
        await tester.pumpWidget(_wrap());
        await _advance(tester);

        await tester.enterText(find.byType(TextField), 'no_such_fish_zz');
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();

        expect(find.text('No matches'), findsOneWidget);
        expect(find.byIcon(Icons.search_off), findsOneWidget);
        expect(find.textContaining(String.fromCharCode(0x1F50D)), findsNothing);
      },
    );

    testWidgets('empty search opens species request guidance', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.enterText(find.byType(TextField), 'blue dragon tetra');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      expect(find.text('Request species'), findsOneWidget);

      await tester.tap(find.text('Request species'));
      await tester.pumpAndSettle();

      expect(find.text('Request Species'), findsOneWidget);
      expect(
        find.text(
          'We could not find "blue dragon tetra" in the local fish database.',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('larkintiarnanbizz@gmail.com'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Danio does not send this automatically'),
        findsOneWidget,
      );
    });
  });
}
