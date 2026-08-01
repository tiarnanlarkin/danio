/// Local visual-regression baseline for the Water Parameters instrument.
///
/// This captures an owned native-overlay rendering at Danio's real drawer
/// width. It intentionally does not import, copy, or register the archived
/// sibling visual reference.
///
/// Regenerate after an intentional visual change:
///   flutter test --update-goldens test/golden_tests/water_panel_instrument_golden_test.dart
library;

import 'package:danio/models/log_entry.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/theme/room_themes.dart';
import 'package:danio/widgets/stage/water_panel_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/danio_test_fonts.dart';
import 'golden_test_helpers.dart';

const _tankId = 'phase4-water-golden';
const _surfaceSize = Size(390, 844);
const _drawerWidth = 390 * 0.66;

void main() {
  setUpAll(loadDanioTestFonts);

  testWidgets('manual Water Parameters in the retro-aquatic instrument', (
    tester,
  ) async {
    tester.view.physicalSize = _surfaceSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Keep the manual timestamp and two history points in the panel's rolling
    // seven-day window so this visual baseline does not depend on wall-clock
    // date or a relative-time label changing after it is recorded.
    final timestamp = DateTime.now();
    final latestReading = LogEntry(
      id: 'phase4-water-latest-reading',
      tankId: _tankId,
      type: LogType.waterTest,
      timestamp: timestamp,
      createdAt: timestamp,
      waterTest: WaterTestResults(
        ph: 7.2,
        ammonia: 0,
        nitrite: 0,
        nitrate: 12,
        gh: 8,
        kh: 5,
      ),
    );
    final previousReading = LogEntry(
      id: 'phase4-water-previous-reading',
      tankId: _tankId,
      type: LogType.waterTest,
      timestamp: timestamp.subtract(const Duration(days: 1)),
      createdAt: timestamp.subtract(const Duration(days: 1)),
      waterTest: WaterTestResults(ph: 7.1, nitrate: 10),
    );

    await tester.pumpWidget(
      goldenWrapper(
        SizedBox(
          width: _drawerWidth,
          child: WaterPanelContent(tankId: _tankId, theme: RoomTheme.ocean),
        ),
        overrides: [
          latestWaterTestProvider(
            _tankId,
          ).overrideWith((_) => Future.value(latestReading.waterTest)),
          latestWaterTestEntryProvider(
            _tankId,
          ).overrideWith((_) => Future.value(latestReading)),
          logsProvider(
            _tankId,
          ).overrideWith((_) => Future.value([latestReading, previousReading])),
        ],
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const ValueKey('water-hybrid-skin')),
      matchesGoldenFile('goldens/water_panel_instrument_manual_test.png'),
    );
  });
}
