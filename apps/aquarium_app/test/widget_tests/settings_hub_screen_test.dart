// Widget tests for SettingsHubScreen.
//
// Run: flutter test test/widget_tests/settings_hub_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/emergency_guide_screen.dart';
import 'package:danio/screens/privacy_policy_screen.dart';
import 'package:danio/screens/search_screen.dart';
import 'package:danio/screens/settings_hub_screen.dart';
import 'package:danio/screens/settings_screen.dart';
import 'package:danio/utils/navigation_throttle.dart';
import 'package:danio/widgets/common/primary_action_tile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const ProviderScope(child: MaterialApp(home: SettingsHubScreen()));
}

Widget _wrapWithTextScale(double textScale) {
  return ProviderScope(
    child: MaterialApp(
      home: const SettingsHubScreen(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        );
      },
    ),
  );
}

Widget _wrapPreferences() {
  return const ProviderScope(child: MaterialApp(home: SettingsScreen()));
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(seconds: 1));
}

Future<void> _scrollUntilTextVisible(WidgetTester tester, String text) async {
  final finder = find.text(text);
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      400,
      scrollable: find.byType(Scrollable).first,
    );
  }
  expect(finder, findsOneWidget);
}

Future<Set<String>> _visibleWhileScrolling(
  WidgetTester tester,
  Set<String> labels,
) async {
  final seen = <String>{};
  final scrollable = find.byType(Scrollable).first;

  for (var i = 0; i < 16; i++) {
    for (final label in labels) {
      if (find.text(label).evaluate().isNotEmpty) {
        seen.add(label);
      }
    }
    await tester.drag(scrollable, const Offset(0, -700));
    await tester.pump(const Duration(milliseconds: 200));
  }

  return seen;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    NavigationThrottle.reset();
  });

  group('SettingsHubScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(SettingsHubScreen), findsOneWidget);
    });

    testWidgets('shows More title in AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('profile card fits phone width with larger text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_wrapWithTextScale(1.3));
      await _advance(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('0-day streak'), findsOneWidget);
    });

    testWidgets('tablet keeps hub destination tiles in a readable rail', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await _advance(tester);

      expect(
        tester.getSize(find.byType(PrimaryActionTile).first).width,
        lessThanOrEqualTo(720),
      );
    });

    testWidgets('profile card exposes one summary semantics node', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(_wrap());
        await _advance(tester);

        expect(
          find.bySemanticsLabel('Aquarist, Level 1, 0 XP, 0-day streak'),
          findsOneWidget,
        );
        expect(find.bySemanticsLabel('A'), findsNothing);
        expect(find.bySemanticsLabel('Aquarist'), findsNothing);
        final settingsNode = tester.getSemantics(
          find.bySemanticsLabel('Edit profile settings'),
        );
        expect(
          settingsNode.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
        );
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('shows Shop Street category', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Shop Street'), findsOneWidget);
      expect(find.text('Plan wishlists, budgets, and shops'), findsOneWidget);
    });

    testWidgets('shows Gem Shop as a clear More hub destination', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Gem Shop'), findsOneWidget);
    });

    testWidgets('Gem Shop subtitle can wrap in the More hub tile', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      final subtitle = find.text('Useful boosts and collectible badges');
      expect(subtitle, findsOneWidget);
      expect(tester.widget<Text>(subtitle).maxLines, greaterThanOrEqualTo(2));
    });

    testWidgets('shows Achievements category', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      await tester.scrollUntilVisible(
        find.text('Achievements'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Achievements'), findsOneWidget);
    });

    testWidgets('shows Workshop category', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      await tester.scrollUntilVisible(
        find.text('Workshop'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Workshop'), findsOneWidget);
    });

    testWidgets('More exposes the primary destination set', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      for (final label in const [
        'Emergency Guide',
        'Shop Street',
        'Gem Shop',
        'Achievements',
        'Workshop',
        'Analytics',
        'Search',
        'Preferences',
      ]) {
        await _scrollUntilTextVisible(tester, label);
      }
    });

    testWidgets('opens Emergency Guide from the More hub', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      expect(find.text('Emergency Guide'), findsOneWidget);
      expect(
        find.text('Urgent steps for water or fish problems'),
        findsOneWidget,
      );

      await tester.tap(find.text('Emergency Guide'));
      await tester.pumpAndSettle();

      expect(find.byType(EmergencyGuideScreen), findsOneWidget);
    });

    testWidgets('opens Search from the More hub', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await _scrollUntilTextVisible(tester, 'Search');
      expect(find.text('Find tanks, fish, guides, and logs'), findsOneWidget);

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      expect(find.byType(SearchScreen), findsOneWidget);
      expect(
        find.text('Search tanks, fish, equipment, guides...'),
        findsOneWidget,
      );
    });

    testWidgets('Backup & Restore is described as local export and import', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(_wrap());
        await _advance(tester);

        await tester.scrollUntilVisible(
          find.text('Backup & Restore'),
          300,
          scrollable: find.byType(Scrollable).first,
        );

        expect(
          find.text('Export or import your aquarium data'),
          findsOneWidget,
        );
        expect(find.textContaining('sync'), findsNothing);
        expect(
          find.bySemanticsLabel(
            'Backup and Restore, Export or import your aquarium data',
          ),
          findsOneWidget,
        );
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('Preferences does not duplicate the Workshop calculator hub', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapPreferences());
      await _advance(tester);

      expect(
        await _visibleWhileScrolling(tester, const {
          'Water Change Calculator',
          'Dosing Calculator',
          'Unit Converter',
          'Tank Volume Calculator',
          'Compatibility Checker',
          'Lighting Schedule',
          'Stocking Calculator',
          'Shop Street',
        }),
        isEmpty,
      );
    });

    testWidgets('Configure AI empty save shows inline feedback', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapPreferences());
      await _advance(tester);

      await _scrollUntilTextVisible(tester, 'Optional AI');
      await tester.tap(find.text('Optional AI'));
      await tester.pumpAndSettle();

      expect(find.text('OpenAI API key'), findsOneWidget);

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Enter an OpenAI API key first.'), findsOneWidget);
    });

    testWidgets('Configure AI links directly to privacy policy', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapPreferences());
      await _advance(tester);

      await _scrollUntilTextVisible(tester, 'Optional AI');
      await tester.tap(find.text('Optional AI'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Review AI privacy'));
      await tester.pumpAndSettle();

      expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
    });

    testWidgets('More action tiles expose one concise semantics node', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(_wrap());
        await _advance(tester);

        await tester.scrollUntilVisible(
          find.text('Preferences'),
          300,
          scrollable: find.byType(Scrollable).first,
        );

        final finder = find.bySemanticsLabel(
          'Preferences, Theme, sounds and notifications',
        );
        expect(finder, findsOneWidget);

        final node = tester.getSemantics(finder);
        expect(node.childrenCount, 0);
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('More action semantics match visible tile subtitles', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(_wrap());
        await _advance(tester);

        await tester.scrollUntilVisible(
          find.text('Achievements'),
          300,
          scrollable: find.byType(Scrollable).first,
        );

        expect(
          find.bySemanticsLabel('Achievements, Your badges and milestones'),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel(
            'Shop Street, Plan wishlists, budgets, and shops',
          ),
          findsOneWidget,
        );
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('version footer is not announced as a tappable control', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(_wrap());
        await _advance(tester);

        await tester.scrollUntilVisible(
          find.text('Danio v1.0.0'),
          300,
          scrollable: find.byType(Scrollable).first,
        );

        final footer = find.bySemanticsLabel('Danio v1.0.0');
        expect(footer, findsOneWidget);

        final node = tester.getSemantics(footer);
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
      } finally {
        semantics.dispose();
      }
    });
  });
}
