// Widget tests for SmartScreen.
//
// Run: flutter test test/widget_tests/smart_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/smart_screen.dart';
import 'package:danio/features/smart/smart_providers.dart';
import 'package:danio/features/smart/models/smart_models.dart';
import 'package:danio/services/openai_service.dart';
import 'package:danio/widgets/offline_indicator.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap({bool isOnline = true}) {
  return ProviderScope(
    overrides: [
      openAIServiceProvider.overrideWithValue(OpenAIService()),
      isOnlineProvider.overrideWithValue(isOnline),
      aiHistoryProvider.overrideWith((ref) => AIHistoryNotifier(ref)),
      anomalyHistoryProvider.overrideWith((ref) => AnomalyHistoryNotifier(ref)),
      // apiRateLimiterProvider is built by the framework — not overridden here
    ],
    child: const MaterialApp(
      home: SmartScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SmartScreen — renders', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(SmartScreen), findsOneWidget);
    });

    testWidgets('shows Smart app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('🧠 Smart'), findsOneWidget);
    });

    testWidgets('shows feature cards when API not configured', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // When not configured, "coming soon" cards are shown with these titles
      expect(find.text('Fish & Plant ID'), findsOneWidget);
      expect(find.text('Symptom Checker'), findsOneWidget);
      expect(find.text('Weekly Care Plan'), findsOneWidget);
    });

    testWidgets('shows AI feature section cards', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      // Weekly Care Plan card should be present
      expect(find.text('Weekly Care Plan'), findsOneWidget);
    });
  });
}
