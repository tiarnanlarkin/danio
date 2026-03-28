// Widget tests for EmergencyGuideScreen.
//
// Run: flutter test test/widget_tests/emergency_guide_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/emergency_guide_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const MaterialApp(
    home: EmergencyGuideScreen(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('EmergencyGuideScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(EmergencyGuideScreen), findsOneWidget);
    });

    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Emergency Guide'), findsOneWidget);
    });

    testWidgets('shows intro card with quick reference text', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(
        find.textContaining('large water change'),
        findsOneWidget,
      );
    });

    testWidgets('shows emergency category titles', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Ammonia spike card is near top of list
      expect(find.text('🚨 Ammonia/Nitrite Spike'), findsOneWidget);
      expect(find.text('🌡️ Heater Malfunction (Too Hot)'), findsOneWidget);
    });

    testWidgets('shows urgency badges', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('CRITICAL'), findsWidgets);
    });
  });

  group('EmergencyGuideScreen — expandable sections', () {
    testWidgets('emergency cards are collapsed by default', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      // "IMMEDIATE ACTIONS:" only appears inside expanded cards
      expect(find.text('IMMEDIATE ACTIONS:'), findsNothing);
    });

    testWidgets('tapping card reveals immediate actions', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.text('🚨 Ammonia/Nitrite Spike'));
      await tester.pumpAndSettle();

      expect(find.text('IMMEDIATE ACTIONS:'), findsOneWidget);
      expect(find.textContaining('water change'), findsWidgets);
    });

    testWidgets('expanded card shows follow-up advice', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.text('🚨 Ammonia/Nitrite Spike'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Follow-up:'), findsOneWidget);
    });
  });

  group('EmergencyGuideScreen — emergency kit section', () {
    testWidgets('shows emergency kit checklist at bottom', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      // Scroll to the bottom
      await tester.drag(find.byType(ListView), const Offset(0, -5000));
      await tester.pump();

      expect(find.text('Emergency Kit Checklist'), findsOneWidget);
    });

    testWidgets('emergency kit contains key items', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.drag(find.byType(ListView), const Offset(0, -5000));
      await tester.pump();

      expect(find.text('Spare heater'), findsOneWidget);
      expect(find.text('Test kit'), findsOneWidget);
    });
  });
}
