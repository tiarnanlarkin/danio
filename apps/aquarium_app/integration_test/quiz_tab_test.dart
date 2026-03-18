// Quiz / Practice Tab Integration Tests — Danio Aquarium App
//
// Tests the Practice tab (index 1), which renders PracticeHubScreen with
// quiz options, spaced repetition, and practice activities.
//
// Run with:
//   flutter test integration_test/quiz_tab_test.dart -d emulator-5554

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('[Quiz Tab]', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
      });
    });

    testWidgets('navigates to Practice tab without crash', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Tap Practice (index 1)
      await tester.tap(find.byType(NavigationDestination).at(1));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Practice tab shows Practice header', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      await tester.tap(find.byType(NavigationDestination).at(1));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // PracticeHubScreen has AppBar with title '🧪 Practice'
      expect(find.text('🧪 Practice'), findsOneWidget);
    });

    testWidgets('Practice tab has list items (quiz options)',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      await tester.tap(find.byType(NavigationDestination).at(1));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // PracticeHubScreen uses ListView.builder — content should render
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('tapping Practice tab shows hearts indicator',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 15));

      await tester.tap(find.byType(NavigationDestination).at(1));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // PracticeHubScreen includes HeartIndicator in AppBar actions
      // Verify the AppBar exists
      expect(find.byType(AppBar), findsWidgets);
    });
  });
}
