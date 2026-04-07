// Widget tests for SetupPathSelector.
//
// Run: flutter test test/widget_tests/setup_path_selector_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/create_tank_screen/setup_mode.dart';
import 'package:danio/screens/home/widgets/setup_path_selector.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SetupPathSelector', () {
    testWidgets('renders both guided and expert cards', (tester) async {
      await tester.pumpWidget(
        _wrap(SetupPathSelector(onPathSelected: (_) {})),
      );
      await tester.pump();

      expect(find.text('Guide me'), findsOneWidget);
      expect(find.text('I know the ropes'), findsOneWidget);
      expect(find.text('3 quick steps with tips along the way'), findsOneWidget);
      expect(find.text('Skip the wizard — just the essentials'), findsOneWidget);
    });

    testWidgets('tapping guided card fires callback with SetupMode.guided',
        (tester) async {
      SetupMode? captured;
      await tester.pumpWidget(
        _wrap(SetupPathSelector(
          onPathSelected: (mode) => captured = mode,
          // Disable haptics to avoid platform channel noise in tests.
          enableHaptics: false,
        )),
      );
      await tester.pump();

      await tester.tap(find.text('Guide me'));
      await tester.pump();

      expect(captured, SetupMode.guided);
    });

    testWidgets('tapping expert card fires callback with SetupMode.expert',
        (tester) async {
      SetupMode? captured;
      await tester.pumpWidget(
        _wrap(SetupPathSelector(
          onPathSelected: (mode) => captured = mode,
          enableHaptics: false,
        )),
      );
      await tester.pump();

      await tester.tap(find.text('I know the ropes'));
      await tester.pump();

      expect(captured, SetupMode.expert);
    });

  });
}
