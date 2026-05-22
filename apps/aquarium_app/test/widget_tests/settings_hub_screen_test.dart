// Widget tests for SettingsHubScreen.
//
// Run: flutter test test/widget_tests/settings_hub_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/settings_hub_screen.dart';
import 'package:danio/screens/settings_screen.dart';

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

    testWidgets('shows Shop Street category', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Shop Street'), findsOneWidget);
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

      final subtitle = find.text('Spend gems on rewards and cosmetics');
      expect(subtitle, findsOneWidget);
      expect(tester.widget<Text>(subtitle).maxLines, greaterThanOrEqualTo(2));
    });

    testWidgets('shows Achievements category', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
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
        'Shop Street',
        'Gem Shop',
        'Achievements',
        'Workshop',
        'Analytics',
        'Preferences',
      ]) {
        await _scrollUntilTextVisible(tester, label);
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
  });
}
