// Widget tests for ShopStreetScreen.
//
// Run: flutter test test/widget_tests/shop_street_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/shop_street_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() {
  return const ProviderScope(
    child: MaterialApp(
      home: ShopStreetScreen(),
    ),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(seconds: 1));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ShopStreetScreen — renders', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(ShopStreetScreen), findsOneWidget);
    });

    testWidgets('shows Shop Street app bar', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.textContaining('Shop Street'), findsWidgets);
    });

    testWidgets('shows fish wishlist section', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.textContaining('Fish Wishlist'), findsWidgets);
    });

    testWidgets('shows plant wishlist section', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.textContaining('Plant Wishlist'), findsWidgets);
    });

    testWidgets('shows equipment wishlist section', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.textContaining('Equipment Wishlist'), findsWidgets);
    });
  });
}
