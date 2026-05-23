import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/widgets/celebrations/level_up_overlay.dart';

void main() {
  test('level up sparkle palette uses shared celebration tokens', () {
    final source = File(
      'lib/widgets/celebrations/level_up_overlay.dart',
    ).readAsStringSync();

    expect(source, contains('DanioColors.confettiLightGold'));
    expect(source, isNot(contains('Color(\n        0xFFFFE082')));
    expect(source, isNot(contains('no shared token')));
  });

  testWidgets('level up overlay dismisses from Continue', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => LevelUpOverlay.show(
                context,
                newLevel: 2,
                levelTitle: 'Novice',
              ),
              child: const Text('Show overlay'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show overlay'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('LEVEL UP!'), findsOneWidget);
    expect(find.byIcon(Icons.workspace_premium), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 4));

    expect(tester.takeException(), isNull);
    expect(find.text('LEVEL UP!'), findsNothing);
  });
}
