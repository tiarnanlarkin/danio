// Widget tests for ThemeGalleryScreen.
//
// Run: flutter test test/widget_tests/theme_gallery_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/theme_gallery_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const ProviderScope(
    child: MaterialApp(
      home: ThemeGalleryScreen(),
    ),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeGalleryScreen — rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(ThemeGalleryScreen), findsOneWidget);
    });

    testWidgets('shows Theme Gallery title', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Theme Gallery'), findsOneWidget);
    });

    testWidgets('shows FREE section label', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('FREE'), findsOneWidget);
    });

    testWidgets('shows Included Themes section', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Included Themes'), findsOneWidget);
    });

    testWidgets('shows theme cards in a scrollable view', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      // CustomScrollView wraps the content
      expect(find.byType(CustomScrollView), findsOneWidget);
    });
  });
}
