/// Golden tests for [EmptyRoomScene].
///
/// Captures the first-run room scene matching concept-A (cozy classic
/// interior). Also captures the [SetupPathSelector] in isolation so the
/// guided/expert card styling can be reviewed without the full scene.
///
/// Run:
///   flutter test test/golden_tests/empty_room_scene_golden_test.dart
///
/// Regenerate reference images after intentional UI changes:
///   flutter test --update-goldens test/golden_tests/empty_room_scene_golden_test.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/providers/settings_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/screens/create_tank_screen/setup_mode.dart';
import 'package:danio/screens/home/widgets/empty_room_scene.dart';
import 'package:danio/screens/home/widgets/setup_path_selector.dart';
import 'package:danio/services/storage_service.dart';

// Full-phone surface — the scene is layout-sensitive, so a real phone aspect
// ratio matters more than the 400x800 used for component tests.
const Size _sceneSurfaceSize = Size(400, 860);

// ---------------------------------------------------------------------------
// Fake SettingsNotifier — disables ambient lighting so the scene renders
// deterministically regardless of the wall-clock time bucket.
// ---------------------------------------------------------------------------
//
// AmbientLightingOverlay reads settingsProvider.ambientLightingEnabled and,
// when true, transitively watches ambientTimeProvider which is driven by
// DateTime.now().hour. That makes the golden match only when re-run in the
// same dawn/day/dusk/night bucket it was originally captured in. Forcing
// ambientLightingEnabled=false short-circuits the overlay to return the
// unmodified child, eliminating the time dependency entirely.
class _FakeSettingsNotifier extends StateNotifier<AppSettings>
    implements SettingsNotifier {
  _FakeSettingsNotifier()
      : super(const AppSettings(ambientLightingEnabled: false));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _fullScreenWrapper(Widget child) {
  SharedPreferences.setMockInitialValues({});
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(InMemoryStorageService()),
      settingsProvider.overrideWith((ref) => _FakeSettingsNotifier()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // disableAnimations collapses MascotAvatar's bob animation to a
        // 0ms duration so the golden capture doesn't race the tween.
        body: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  group('EmptyRoomScene golden', () {
    testWidgets('concept-A empty-tank scene', (tester) async {
      tester.view.physicalSize = _sceneSurfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _fullScreenWrapper(
          EmptyRoomScene(
            onCreateTank: (SetupMode _) {},
            onLoadDemo: () {},
          ),
        ),
      );
      // Pump a few frames to let gradients + the mascot's first frame render.
      // Don't use pumpAndSettle — MascotAvatar's repeat() never terminates.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await expectLater(
        find.byType(EmptyRoomScene),
        matchesGoldenFile('goldens/empty_room_scene.png'),
      );
    });
  });

  group('SetupPathSelector golden', () {
    testWidgets('guided + expert cards side-by-side', (tester) async {
      // 280 tall gives enough room for the cards to sit at their intrinsic
      // height without the test surface clipping the second subtitle line.
      tester.view.physicalSize = const Size(400, 280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _fullScreenWrapper(
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SetupPathSelector(onPathSelected: (SetupMode _) {}),
            ),
          ),
        ),
      );
      await tester.pump();

      await expectLater(
        find.byType(SetupPathSelector),
        matchesGoldenFile('goldens/setup_path_selector.png'),
      );
    });
  });
}
