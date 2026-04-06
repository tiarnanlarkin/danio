/// Golden test helpers — shared wrapper and sizing for screenshot tests.
///
/// Golden tests capture a rendered widget as a PNG and compare it against a
/// saved reference image. Any visual diff causes the test to fail, which
/// catches unintended UI regressions.
///
/// ## How to add a new golden test
///
/// 1. Create a file in `test/golden_tests/` (e.g. `my_widget_golden_test.dart`).
/// 2. Import this helper file.
/// 3. Use [goldenWrapper] to wrap the widget under test.
/// 4. Call `matchesGoldenFile('goldens/my_widget_variant.png')`.
/// 5. Generate the initial reference image:
///    ```
///    flutter test --update-goldens test/golden_tests/my_widget_golden_test.dart
///    ```
/// 6. Verify the generated PNG looks correct, then commit.
///
/// ## Important notes
///
/// - Golden files are **platform-dependent** (font rendering differs across
///   OSes). The `goldens/` directory is gitignored. Each developer regenerates
///   locally with `--update-goldens` on first checkout.
/// - The standard test surface is 400x800 (a typical phone). Override with
///   [goldenWrapper]'s `surfaceSize` parameter if needed.
/// - If your widget reads from providers, pass overrides to [goldenWrapper].
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/storage_service.dart';

/// Standard phone-sized surface for golden tests (width x height).
const Size kGoldenTestSurfaceSize = Size(400, 800);

/// Wraps [child] in the minimal widget tree needed for golden rendering:
///
/// - [ProviderScope] with [storageServiceProvider] overridden to an in-memory
///   implementation (prevents file-system access during tests).
/// - [MaterialApp] for theming, media queries, and directionality.
/// - [Scaffold] so widgets that depend on a scaffold ancestor render correctly.
/// - [SingleChildScrollView] so content taller than the surface doesn't
///   overflow.
///
/// Pass additional [overrides] for any extra providers your widget needs.
Widget goldenWrapper(
  Widget child, {
  List<Override> overrides = const [],
}) {
  // SharedPreferences must be mocked before any provider reads it.
  SharedPreferences.setMockInitialValues({});

  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(InMemoryStorageService()),
      ...overrides,
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    ),
  );
}
