// Widget tests for FriendsScreen.
//
// Run: flutter test test/widget_tests/friends_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/screens/friends_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap() => const ProviderScope(
      child: MaterialApp(home: FriendsScreen()),
    );

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('FriendsScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(FriendsScreen), findsOneWidget);
    });

    testWidgets('shows Friends app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Friends'), findsOneWidget);
    });

    testWidgets('shows Social Features heading', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('Social Features'), findsOneWidget);
    });

    testWidgets('shows On the Way badge', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.text('On the Way!'), findsOneWidget);
    });

    testWidgets('shows people outline icon', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
    });
  });
}
