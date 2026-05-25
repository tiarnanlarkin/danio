import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/models/models.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/screens/home/home_sheets_tank.dart';
import 'package:danio/services/storage_service.dart';

Tank _tank() {
  final now = DateTime(2026, 1, 1);
  return Tank(
    id: 'tank-1',
    name: 'Test Tank',
    type: TankType.freshwater,
    volumeLitres: 100,
    startDate: now,
    targets: WaterTargets.freshwaterTropical(),
    createdAt: now,
    updatedAt: now,
  );
}

Widget _wrap() {
  final storage = InMemoryStorageService();
  return ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
    child: MaterialApp(
      home: Scaffold(
        body: Consumer(
          builder: (context, ref, _) => TextButton(
            onPressed: () => showQuickLogSheet(context, ref, _tank()),
            child: const Text('Open quick test'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('quick water test keeps compact field labels readable', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());

    await tester.tap(find.text('Open quick test'));
    await tester.pumpAndSettle();

    expect(find.text('Quick Water Test'), findsOneWidget);
    expect(find.text('pH'), findsOneWidget);
    expect(find.text('Temp'), findsOneWidget);
    expect(find.text('NH3'), findsOneWidget);
    expect(find.textContaining('Temp ('), findsNothing);
  });
}
