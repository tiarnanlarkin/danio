import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/widgets/core/glass_card.dart';

void main() {
  testWidgets('tap-only cards do not expose a long-press action', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GlassCard(
                semanticLabel: 'Card action',
                onTap: () {},
                child: const SizedBox(width: 120, height: 80),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final node = tester.getSemantics(find.bySemanticsLabel('Card action'));
      final data = node.getSemanticsData();

      expect(data.hasAction(SemanticsAction.tap), isTrue);
      expect(data.hasAction(SemanticsAction.longPress), isFalse);
    } finally {
      semantics.dispose();
    }
  });
}
