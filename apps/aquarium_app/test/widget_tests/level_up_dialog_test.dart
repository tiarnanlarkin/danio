import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/widgets/level_up_dialog.dart';

void main() {
  testWidgets('confetti renders without invalid decoration assertions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => LevelUpDialog.show(
                context,
                newLevel: 2,
                levelTitle: 'Care Builder',
                totalXp: 120,
              ),
              child: const Text('Show level up'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show level up'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 250));

    expect(tester.takeException(), isNull);
    expect(find.text('Level Up!'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
