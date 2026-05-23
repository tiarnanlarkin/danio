import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/widgets/stage/water_quality/water_health_card.dart';

void main() {
  group('WqPerfectBadge', () {
    testWidgets('uses icons instead of decorative text symbols', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: WqPerfectBadge())),
        ),
      );

      expect(find.text('Perfect!'), findsOneWidget);
      expect(find.byIcon(Icons.set_meal), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);

      final visibleText = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data ?? '')
          .where((text) => text.isNotEmpty)
          .join(' ');
      expect(visibleText, 'Perfect!');
    });
  });
}
