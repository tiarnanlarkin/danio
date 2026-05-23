import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/widgets/common/primary_action_tile.dart';

void main() {
  testWidgets('subtitle uses accessible secondary text contrast', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PrimaryActionTile(
            icon: Icons.settings,
            title: 'Preferences',
            subtitle: 'Theme, sounds and notifications',
          ),
        ),
      ),
    );

    final subtitle = tester.widget<Text>(
      find.text('Theme, sounds and notifications'),
    );

    expect(subtitle.style?.color?.a, closeTo(178 / 255, 0.001));
  });
}
