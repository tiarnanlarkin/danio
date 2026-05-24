import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/co2_calculator_screen.dart';
import 'package:danio/screens/dosing_calculator_screen.dart';
import 'package:danio/screens/lighting_schedule_screen.dart';
import 'package:danio/screens/tank_volume_calculator_screen.dart';
import 'package:danio/screens/unit_converter_screen.dart';
import 'package:danio/screens/water_change_calculator_screen.dart';

Widget _wrapWithGestureInset(Widget child) {
  return MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData(
        padding: EdgeInsets.only(bottom: 34),
        viewPadding: EdgeInsets.only(bottom: 34),
      ),
      child: child,
    ),
  );
}

void main() {
  const viewport = Size(390, 844);
  final safeBottom = viewport.height - 34;

  final toolScreens = <String, Widget>{
    'Water Change Calculator': const WaterChangeCalculatorScreen(),
    'CO2 Calculator': const Co2CalculatorScreen(),
    'Dosing Calculator': const DosingCalculatorScreen(),
    'Tank Volume Calculator': const TankVolumeCalculatorScreen(),
    'Unit Converter': const UnitConverterScreen(),
    'Lighting Schedule': const LightingScheduleScreen(),
  };

  for (final entry in toolScreens.entries) {
    testWidgets('${entry.key} keeps scrollable content above gesture nav', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(viewport);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrapWithGestureInset(entry.value));
      await tester.pump();

      final scrollableRect = tester.getRect(find.byType(Scrollable).first);
      expect(scrollableRect.bottom, lessThanOrEqualTo(safeBottom));
    });
  }
}
