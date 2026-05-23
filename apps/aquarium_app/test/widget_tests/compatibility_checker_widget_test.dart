import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:danio/features/smart/smart_providers.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/services/openai_service.dart';
import 'package:danio/widgets/compatibility_checker_widget.dart';
import 'package:danio/widgets/offline_indicator.dart';

Widget _wrap() {
  return ProviderScope(
    overrides: [
      tanksProvider.overrideWith((ref) async => []),
      openAIServiceProvider.overrideWithValue(OpenAIService(directApiKey: '')),
      openAIConfiguredProvider.overrideWith((ref) async => false),
      isOnlineProvider.overrideWithValue(true),
      aiHistoryProvider.overrideWith((ref) => AIHistoryNotifier(ref)),
    ],
    child: const MaterialApp(
      home: Scaffold(body: CompatibilityCheckerWidget()),
    ),
  );
}

void main() {
  group('CompatibilityCheckerWidget', () {
    testWidgets('empty submit has clear action label and inline feedback', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.byTooltip('Check compatibility'), findsOneWidget);

      await tester.tap(find.byTooltip('Check compatibility'));
      await tester.pump();

      expect(find.text('Enter a species to check first.'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
