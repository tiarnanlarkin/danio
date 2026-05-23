import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/widgets/core/app_navigation.dart';

void main() {
  testWidgets('AppBarAction exposes one tappable semantic action', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                AppBarAction(
                  icon: Icons.tune,
                  tooltip: 'Tune',
                  semanticsLabel: 'Open filters',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      _expectSingleTappableLabel(tester, 'Open filters');
      expect(find.bySemanticsLabel('Tune'), findsNothing);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('AppBackButton exposes one tappable semantic action', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(appBar: AppBar(leading: const AppBackButton())),
        ),
      );

      _expectSingleTappableLabel(tester, 'Go back');
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('AppCloseButton exposes one tappable semantic action', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(appBar: AppBar(leading: const AppCloseButton())),
        ),
      );

      _expectSingleTappableLabel(tester, 'Close');
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('AppBottomNavBar items expose tappable semantic actions', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: 0,
              onTap: (_) {},
              items: const [
                AppBottomNavItem(icon: Icons.school, label: 'Learn'),
                AppBottomNavItem(icon: Icons.water, label: 'Tank'),
              ],
            ),
          ),
        ),
      );

      _expectSingleTappableLabel(tester, 'Learn');
      _expectSingleTappableLabel(tester, 'Tank');
    } finally {
      semantics.dispose();
    }
  });
}

void _expectSingleTappableLabel(WidgetTester tester, String label) {
  final finder = find.bySemanticsLabel(label);
  expect(finder, findsOneWidget);

  final data = tester.getSemantics(finder).getSemanticsData();
  expect(data.hasAction(SemanticsAction.tap), isTrue);
}
