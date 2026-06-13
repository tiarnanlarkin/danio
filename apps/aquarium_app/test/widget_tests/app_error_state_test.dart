import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/widgets/core/app_states.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  group('AppErrorState', () {
    testWidgets('server state uses local-first online service copy', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(AppErrorState.server()));

      expect(find.text('Online service unavailable'), findsOneWidget);
      expect(find.textContaining('online feature'), findsOneWidget);
      expect(find.textContaining('Server Error'), findsNothing);
      expect(find.textContaining('Our servers'), findsNothing);
    });
  });
}
