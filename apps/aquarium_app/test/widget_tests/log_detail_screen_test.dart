// Widget tests for LogDetailScreen.
//
// Run: flutter test test/widget_tests/log_detail_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/screens/log_detail_screen.dart';
import 'package:danio/providers/tank_provider.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/models/models.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _fakeTankId = 'tank-log-detail-001';
const _fakeLogId = 'log-001';

LogEntry _fakeLog() => LogEntry(
      id: _fakeLogId,
      tankId: _fakeTankId,
      type: LogType.waterChange,
      timestamp: DateTime(2024, 6, 15),
      notes: 'Changed 30% of water',
      createdAt: DateTime(2024, 6, 15),
    );

Widget _wrap({List<LogEntry>? logs}) {
  final memStorage = InMemoryStorageService();
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(memStorage),
      allLogsProvider.overrideWith((ref, tankId) async => logs ?? [_fakeLog()]),
    ],
    child: const MaterialApp(
      home: LogDetailScreen(tankId: _fakeTankId, logId: _fakeLogId),
    ),
  );
}

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LogDetailScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(LogDetailScreen), findsOneWidget);
    });

    testWidgets('shows scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows edit icon button in app bar', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('shows delete icon button in app bar', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('shows not found message when log is missing', (tester) async {
      await tester.pumpWidget(_wrap(logs: []));
      await _advance(tester);
      expect(find.text('Log not found'), findsOneWidget);
    });
  });
}
