// Widget tests for SmartScreen.
//
// Run: flutter test test/widget_tests/smart_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/smart_screen.dart';
import 'package:danio/screens/workshop_screen.dart';
import 'package:danio/features/smart/smart_providers.dart';
import 'package:danio/services/openai_service.dart';
import 'package:danio/widgets/offline_indicator.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap({bool isOnline = true, bool aiConfigured = false}) {
  return ProviderScope(
    overrides: [
      openAIServiceProvider.overrideWithValue(
        OpenAIService(directApiKey: aiConfigured ? 'sk-test' : ''),
      ),
      openAIConfiguredProvider.overrideWith((ref) async => aiConfigured),
      isOnlineProvider.overrideWithValue(isOnline),
      aiHistoryProvider.overrideWith((ref) => AIHistoryNotifier(ref)),
      anomalyHistoryProvider.overrideWith((ref) => AnomalyHistoryNotifier(ref)),
      // apiRateLimiterProvider is built by the framework — not overridden here
    ],
    child: const MaterialApp(home: SmartScreen()),
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
      expect(find.text('Smart'), findsOneWidget);
    });

    testWidgets('shows feature cards when API not configured', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.textContaining('coming soon'), findsNothing);
      expect(find.textContaining('AI is configured'), findsOneWidget);

      // When not configured, feature cards are rendered but may be offstage
      // (below the viewport fold in the SliverList). Use skipOffstage: false.
      expect(find.text('Fish & Plant ID', skipOffstage: false), findsOneWidget);
      expect(find.text('Symptom Checker', skipOffstage: false), findsOneWidget);
      expect(
        find.text('Weekly Care Plan', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('shows AI feature section cards', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      // Weekly Care Plan card should be present (may be offstage in SliverList)
      expect(
        find.text('Weekly Care Plan', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('shows AI-only controls when Smart features are configured', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(aiConfigured: true));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Ask Danio', skipOffstage: false), findsOneWidget);
      expect(
        find.text('Snap a photo to identify species', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('locked AI cards open Smart setup guidance', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.scrollUntilVisible(
        find.text('Fish & Plant ID'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Fish & Plant ID'));
      await tester.pumpAndSettle();

      expect(find.text('Set up Smart Hub'), findsOneWidget);
      expect(find.text('Open Preferences'), findsWidgets);
    });

    testWidgets('locked AI cards expose setup action to semantics', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(_wrap());
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        await tester.scrollUntilVisible(
          find.text('Fish & Plant ID'),
          500,
          scrollable: find.byType(Scrollable).first,
        );

        final cardSemantics = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              (widget.properties.label?.contains('Fish & Plant ID') ?? false),
        );
        expect(cardSemantics, findsOneWidget);

        final widget = tester.widget<Semantics>(cardSemantics);
        expect(widget.properties.label, contains('Fish & Plant ID'));
        expect(widget.properties.label, contains('Requires AI setup'));
        expect(widget.properties.label, contains('Open Preferences'));
        expect(widget.properties.button, isTrue);
        expect(widget.properties.enabled, isTrue);
        final node = tester.getSemantics(
          find.bySemanticsLabel(
            RegExp(r'Fish & Plant ID[\s\S]*Open Preferences'),
          ),
        );
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('tap-to-dismiss background is hidden from semantics', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final backgroundTapLayer = find.ancestor(
        of: find.byType(Scaffold),
        matching: find.byType(GestureDetector),
      );
      expect(backgroundTapLayer, findsOneWidget);

      final detector = tester.widget<GestureDetector>(backgroundTapLayer);
      expect(detector.excludeFromSemantics, isTrue);
    });

    testWidgets(
      'offline compatibility entry points to Workshop instead of duplicating the checker',
      (tester) async {
        await tester.pumpWidget(_wrap());
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(
          find.text('Compatibility Checker', skipOffstage: false),
          findsNothing,
        );
        expect(
          find.text('Compatibility Advice', skipOffstage: false),
          findsOneWidget,
        );
        expect(
          find.text(
            'Use the Workshop checker with local species data',
            skipOffstage: false,
          ),
          findsOneWidget,
        );

        await tester.scrollUntilVisible(
          find.text('Compatibility Advice'),
          500,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Compatibility Advice'));
        await tester.pumpAndSettle();

        expect(find.byType(WorkshopScreen), findsOneWidget);
      },
    );

    testWidgets('configured Smart labels AI compatibility as advice', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(aiConfigured: true));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(
        find.text('Compatibility Checker', skipOffstage: false),
        findsNothing,
      );
      expect(
        find.text('AI Compatibility Advice', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('Ask Danio empty submit gives inline feedback', (tester) async {
      await tester.pumpWidget(_wrap(aiConfigured: true));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.scrollUntilVisible(
        find.text('Ask Danio'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byTooltip('Send question'));
      await tester.pump();

      expect(find.text('Ask a fishkeeping question first.'), findsOneWidget);
    });
  });
}
