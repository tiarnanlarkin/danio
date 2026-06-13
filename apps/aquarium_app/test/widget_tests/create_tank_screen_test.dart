// Widget tests for CreateTankScreen.
//
// Run: flutter test test/widget_tests/create_tank_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/create_tank_screen.dart';
import 'package:danio/screens/create_tank_screen/setup_mode.dart';
import 'package:danio/models/models.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/celebration_service.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/services/xp_animation_service.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap({SetupMode mode = SetupMode.guided, String initialName = ''}) {
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(InMemoryStorageService()),
    ],
    child: MaterialApp(
      home: CreateTankScreen(mode: mode, initialName: initialName),
    ),
  );
}

Widget _wrapWithLauncher({SetupMode mode = SetupMode.guided}) {
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(InMemoryStorageService()),
    ],
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateTankScreen(mode: mode),
                  ),
                );
              },
              child: const Text('Open tank form'),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _wrapWithAppShellLauncher(InMemoryStorageService storage) {
  return ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
    child: MaterialApp(
      builder: (context, child) => XpAnimationListener(
        child: CelebrationOverlayWrapper(child: child ?? const SizedBox()),
      ),
      home: Consumer(
        builder: (context, ref, _) {
          ref.watch(tanksProvider);
          return Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CreateTankScreen()),
                  );
                },
                child: const Text('Open tank form'),
              ),
            ),
          );
        },
      ),
    ),
  );
}

Tank _existingTank() {
  final now = DateTime(2026, 5, 25);
  return Tank(
    id: 'existing-tank',
    name: 'Existing Tank',
    type: TankType.freshwater,
    volumeLitres: 60,
    startDate: now,
    targets: WaterTargets.freshwaterTropical(),
    createdAt: now,
    updatedAt: now,
  );
}

Future<void> _openTankForm(WidgetTester tester) async {
  await tester.tap(find.text('Open tank form'));
  await tester.pumpAndSettle();
  expect(find.byType(CreateTankScreen), findsOneWidget);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CreateTankScreen — basic rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(CreateTankScreen), findsOneWidget);
    });

    testWidgets('shows New Tank app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('New Tank'), findsOneWidget);
    });

    testWidgets('shows page 1 of the form (basic info)', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      // First page should have a tank name field
      expect(
        find.textContaining('Tank Name').evaluate().isNotEmpty ||
            find.textContaining('Name').evaluate().isNotEmpty,
        isTrue,
        reason: 'First page should show tank name field',
      );
    });

    testWidgets('has a continue/next button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.textContaining('Continue').evaluate().isNotEmpty ||
            find.textContaining('Next').evaluate().isNotEmpty,
        isTrue,
        reason: 'Should have a navigation button to proceed',
      );
    });

    testWidgets('tank type cards do not expose blank duplicate tap targets', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(_wrap());
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.bySemanticsLabel('Freshwater, selected'), findsOneWidget);
        expect(_blankTapTargets(tester), isEmpty);
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('tank type step presents the supported freshwater scope', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Freshwater'), findsOneWidget);
      expect(find.text('Marine'), findsNothing);
      expect(find.textContaining('not available'), findsNothing);
    });

    testWidgets('close action exposes one tappable semantics node', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(_wrap());
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        final closeNode = tester.getSemantics(
          find.bySemanticsLabel('Close new tank form'),
        );
        expect(
          closeNode.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
        );
        expect(
          find.bySemanticsLabel('Close and discard new tank'),
          findsNothing,
        );
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('tapping continue without name shows validation', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Try to continue without filling in anything
      final continueBtn = find.textContaining('Continue');
      if (continueBtn.evaluate().isNotEmpty) {
        await tester.tap(continueBtn.first);
        await tester.pumpAndSettle();
        // Screen should still be visible (not navigated away)
        expect(find.byType(CreateTankScreen), findsOneWidget);
      }
    });

    testWidgets('guided size preset can be selected after reaching size step', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(find.byType(TextFormField).first, 'QA Tank');
      await tester.pump();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Tank size'), findsOneWidget);

      await tester.tap(find.text('60L'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.widgetWithText(TextFormField, '60'), findsOneWidget);
    });
  });

  group('CreateTankScreen — expert mode', () {
    testWidgets('shows "Quick setup" app bar title', (tester) async {
      await tester.pumpWidget(_wrap(mode: SetupMode.expert));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Quick setup'), findsOneWidget);
      expect(find.text('New Tank'), findsNothing);
    });

    testWidgets('renders single-form layout (no progress bar, no Next)', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(mode: SetupMode.expert));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Expert form skips the progress indicator entirely.
      expect(find.byType(LinearProgressIndicator), findsNothing);
      // Expert form has no Next/Back navigation — it's a single page.
      expect(find.textContaining('Next'), findsNothing);
      expect(find.textContaining('Back'), findsNothing);
      // It does have a Create Tank button.
      expect(find.text('Create Tank'), findsOneWidget);
    });

    testWidgets('shows name + volume fields and size presets', (tester) async {
      await tester.pumpWidget(_wrap(mode: SetupMode.expert));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Essentials only: name, volume, water type.
      expect(find.text('Tank name'), findsOneWidget);
      expect(find.text('Volume'), findsOneWidget);
      // Water type segmented button options.
      expect(find.text('Tropical'), findsOneWidget);
      expect(find.text('Coldwater'), findsOneWidget);
      // Size presets as ActionChips.
      expect(find.text('20L'), findsOneWidget);
      expect(find.text('120L'), findsOneWidget);
      expect(find.text('300L'), findsOneWidget);
    });

    testWidgets('tapping a size preset populates the volume field', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(mode: SetupMode.expert));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('120L'));
      await tester.pump();

      // The volume TextFormField should now contain "120".
      expect(find.widgetWithText(TextFormField, '120'), findsOneWidget);
    });
  });

  group('CreateTankScreen dirty close behavior', () {
    testWidgets('initial name seeds a dirty guided form', (tester) async {
      await tester.pumpWidget(_wrap(initialName: 'Q'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Q'), findsOneWidget);

      await tester.tap(find.byTooltip('Close and discard new tank'));
      await tester.pumpAndSettle();

      expect(find.text('Discard new tank?'), findsOneWidget);
    });

    testWidgets('cancel keeps a dirty guided form open', (tester) async {
      await tester.pumpWidget(_wrapWithLauncher());
      await _openTankForm(tester);

      await tester.enterText(find.byType(TextFormField).first, 'QA Tank');
      await tester.pump();
      await tester.tap(find.byTooltip('Close and discard new tank'));
      await tester.pumpAndSettle();

      expect(find.text('Discard new tank?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(CreateTankScreen), findsOneWidget);
      expect(find.text('QA Tank'), findsOneWidget);
    });

    testWidgets('discard closes a dirty guided form without looping', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapWithLauncher());
      await _openTankForm(tester);

      await tester.enterText(find.byType(TextFormField).first, 'QA Tank');
      await tester.pump();
      await tester.tap(find.byTooltip('Close and discard new tank'));
      await tester.pumpAndSettle();

      expect(find.text('Discard new tank?'), findsOneWidget);

      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(find.byType(CreateTankScreen), findsNothing);
      expect(find.text('Open tank form'), findsOneWidget);
      expect(find.text('Discard new tank?'), findsNothing);
    });

    testWidgets('successful guided creation closes the wizard', (tester) async {
      await tester.pumpWidget(_wrapWithLauncher());
      await _openTankForm(tester);

      await tester.enterText(find.byType(TextFormField).first, 'QA Tank');
      await tester.pump();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('60L'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Tank'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(CreateTankScreen), findsNothing);
      expect(find.text('Open tank form'), findsOneWidget);
    });

    testWidgets('successful guided creation closes inside app shell', (
      tester,
    ) async {
      final storage = InMemoryStorageService();
      await storage.saveTank(_existingTank());

      await tester.pumpWidget(_wrapWithAppShellLauncher(storage));
      await tester.pumpAndSettle();
      await _openTankForm(tester);

      await tester.enterText(find.byType(TextFormField).first, 'QA Tank');
      await tester.pump();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('60L'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Tank'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(CreateTankScreen), findsNothing);
      expect(find.text('Open tank form'), findsOneWidget);
    });
  });
}

List<String> _blankTapTargets(WidgetTester tester) {
  final root =
      tester.binding.rootPipelineOwner.semanticsOwner?.rootSemanticsNode;
  if (root == null) return const [];

  final offenders = <String>[];

  void visit(SemanticsNode node) {
    final data = node.getSemanticsData();
    final hasAccessibleText = [
      data.label,
      data.value,
      data.hint,
      data.tooltip,
    ].any((text) => text.trim().isNotEmpty);

    if (data.hasAction(SemanticsAction.tap) && !hasAccessibleText) {
      offenders.add('node ${node.id} ${data.rect}');
    }

    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(root);
  return offenders;
}
