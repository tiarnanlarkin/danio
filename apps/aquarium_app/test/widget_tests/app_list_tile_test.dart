import 'dart:ui' show SemanticsAction;

import 'package:danio/widgets/core/app_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  testWidgets('interactive tiles expose a semantic tap action', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        _wrap(
          AppListTile(
            title: 'Daily Goal',
            subtitle: 'Set your daily XP target',
            onTap: () {},
          ),
        ),
      );

      final tile = find.bySemanticsLabel('Daily Goal');
      expect(tile, findsOneWidget);

      final node = tester.getSemantics(tile);
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    } finally {
      semantics.dispose();
    }
  });
}
