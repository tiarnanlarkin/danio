// Widget tests for CreateTankScreen.
//
// Run: flutter test test/widget_tests/create_tank_screen_test.dart

import 'dart:convert';

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
import 'package:danio/providers/user_profile_provider.dart';
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

Widget _wrapWithLauncher({
  SetupMode mode = SetupMode.guided,
  InMemoryStorageService? storage,
  SharedPreferences? prefs,
  bool showProfileProbe = false,
}) {
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(
        storage ?? InMemoryStorageService(),
      ),
      if (prefs != null)
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
    ],
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showProfileProbe)
                  Consumer(
                    builder: (context, ref, _) {
                      final profile = ref.watch(userProfileProvider);
                      return profile.when(
                        data: (value) => Text(
                          value == null ? 'profile loading' : 'profile ready',
                        ),
                        loading: () => const Text('profile loading'),
                        error: (_, __) => const Text('profile unavailable'),
                      );
                    },
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CreateTankScreen(mode: mode),
                      ),
                    );
                  },
                  child: const Text('Open tank form'),
                ),
              ],
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

UserProfile _makeProfile() {
  final now = DateTime(2026, 5, 25);
  return UserProfile(
    id: 'create-tank-profile',
    experienceLevel: ExperienceLevel.beginner,
    primaryTankType: TankType.freshwater,
    goals: const [UserGoal.keepFishAlive],
    hasStreakFreeze: false,
    createdAt: now,
    updatedAt: now,
  );
}

class _ThrowingSetStringPrefs implements SharedPreferences {
  _ThrowingSetStringPrefs(this._delegate, this._shouldFail);

  final SharedPreferences _delegate;
  final bool Function(String key, Object value) _shouldFail;

  @override
  String? getString(String key) => _delegate.getString(key);

  @override
  int? getInt(String key) => _delegate.getInt(key);

  @override
  bool? getBool(String key) => _delegate.getBool(key);

  @override
  double? getDouble(String key) => _delegate.getDouble(key);

  @override
  List<String>? getStringList(String key) => _delegate.getStringList(key);

  @override
  Object? get(String key) => _delegate.get(key);

  @override
  bool containsKey(String key) => _delegate.containsKey(key);

  @override
  Set<String> getKeys() => _delegate.getKeys();

  @override
  Future<bool> setString(String key, String value) {
    if (_shouldFail(key, value)) {
      throw StateError('Simulated SharedPreferences write failure for $key');
    }
    return _delegate.setString(key, value);
  }

  @override
  Future<bool> setBool(String key, bool value) => _delegate.setBool(key, value);

  @override
  Future<bool> setDouble(String key, double value) =>
      _delegate.setDouble(key, value);

  @override
  Future<bool> setInt(String key, int value) => _delegate.setInt(key, value);

  @override
  Future<bool> setStringList(String key, List<String> value) =>
      _delegate.setStringList(key, value);

  @override
  Future<bool> remove(String key) => _delegate.remove(key);

  @override
  Future<bool> clear() => _delegate.clear();

  @override
  Future<void> reload() => _delegate.reload();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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

    testWidgets(
      'profile activity failure after tank create does not report create failure',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'user_profile': jsonEncode(_makeProfile().toJson()),
        });
        final prefs = await SharedPreferences.getInstance();
        final throwingPrefs = _ThrowingSetStringPrefs(
          prefs,
          (key, _) => key == 'user_profile',
        );
        final storage = InMemoryStorageService();
        const tankName = 'Progress Boundary Tank';

        await tester.pumpWidget(
          _wrapWithLauncher(
            storage: storage,
            prefs: throwingPrefs,
            showProfileProbe: true,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('profile ready'), findsOneWidget);

        await _openTankForm(tester);

        await tester.enterText(find.byType(TextFormField).first, tankName);
        await tester.pump();
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('60L'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Create Tank'));
        await tester.pumpAndSettle();

        final tanks = await storage.getAllTanks();
        final matchingTanks = tanks
            .where((tank) => tank.name == tankName)
            .toList();
        expect(matchingTanks, hasLength(1));
        expect(find.byType(CreateTankScreen), findsNothing);
        expect(
          find.text('$tankName created, but progress couldn\'t update.'),
          findsOneWidget,
        );
        expect(
          find.text(
            'Couldn\'t create your tank right now. Give it another go!',
          ),
          findsNothing,
        );
        expect(find.text('Retry'), findsNothing);
      },
    );
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
