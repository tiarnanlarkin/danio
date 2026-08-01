/// Local visual-regression baseline for the Temperature instrument chassis.
///
/// This captures an owned widget-test rendering only. It intentionally does
/// not import, copy, or register the archived normative visual reference.
///
/// Regenerate after an intentional visual change:
///   flutter test --update-goldens test/golden_tests/temp_panel_chassis_golden_test.dart
library;

import 'package:danio/models/log_entry.dart';
import 'package:danio/models/tank.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/theme/room_themes.dart';
import 'package:danio/widgets/stage/temp_panel_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/danio_test_fonts.dart';
import 'golden_test_helpers.dart';

const _tankId = 'phase3r-temperature-golden';
const _surfaceSize = Size(400, 1180);

void main() {
  setUpAll(loadDanioTestFonts);

  testWidgets('manual reading in retro-aquatic instrument chassis', (
    tester,
  ) async {
    tester.view.physicalSize = _surfaceSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final timestamp = DateTime.utc(2026, 7, 30, 12);
    final tank = Tank(
      id: _tankId,
      name: 'Instrument Test Tank',
      type: TankType.freshwater,
      volumeLitres: 90,
      startDate: DateTime.utc(2026, 1, 1),
      targets: WaterTargets.freshwaterTropical(),
      createdAt: timestamp,
      updatedAt: timestamp,
    );
    final latestReading = LogEntry(
      id: 'phase3r-manual-temperature-reading',
      tankId: _tankId,
      type: LogType.waterTest,
      timestamp: timestamp,
      createdAt: timestamp,
      waterTest: WaterTestResults(temperature: 25.0),
    );

    await tester.pumpWidget(
      goldenWrapper(
        TempPanelContent(tankId: _tankId, theme: RoomTheme.ocean),
        overrides: [
          tankProvider(_tankId).overrideWith((_) => Future.value(tank)),
          latestWaterTestProvider(
            _tankId,
          ).overrideWith((_) => Future.value(latestReading.waterTest)),
          latestWaterTestEntryProvider(
            _tankId,
          ).overrideWith((_) => Future.value(latestReading)),
          testStreakProvider(_tankId).overrideWith((_) => Future.value(1)),
          logsProvider(
            _tankId,
          ).overrideWith((_) => Future.value(<LogEntry>[latestReading])),
          tankHeaterProvider(_tankId).overrideWith((_) => Future.value(null)),
        ],
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const ValueKey('temperature-instrument-chassis')),
      matchesGoldenFile('goldens/temp_panel_chassis_manual_reading.png'),
    );
  });
}
