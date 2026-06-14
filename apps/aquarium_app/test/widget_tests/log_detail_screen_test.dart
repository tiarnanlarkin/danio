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

class _ThrowingLogDeleteStorage implements StorageService {
  final InMemoryStorageService _delegate = InMemoryStorageService();

  @override
  Future<List<Tank>> getAllTanks() => _delegate.getAllTanks();
  @override
  Future<Tank?> getTank(String id) => _delegate.getTank(id);
  @override
  Future<void> saveTank(Tank tank) => _delegate.saveTank(tank);
  @override
  Future<void> saveTanks(List<Tank> tanks) => _delegate.saveTanks(tanks);
  @override
  Future<void> deleteTank(String id) => _delegate.deleteTank(id);
  @override
  Future<void> deleteAllTanks(List<String> ids) =>
      _delegate.deleteAllTanks(ids);
  @override
  Future<List<Livestock>> getLivestockForTank(String tankId) =>
      _delegate.getLivestockForTank(tankId);
  @override
  Future<void> saveLivestock(Livestock livestock) =>
      _delegate.saveLivestock(livestock);
  @override
  Future<void> deleteLivestock(String id) => _delegate.deleteLivestock(id);
  @override
  Future<List<Equipment>> getEquipmentForTank(String tankId) =>
      _delegate.getEquipmentForTank(tankId);
  @override
  Future<void> saveEquipment(Equipment equipment) =>
      _delegate.saveEquipment(equipment);
  @override
  Future<void> deleteEquipment(String id) => _delegate.deleteEquipment(id);
  @override
  Future<List<LogEntry>> getLogsForTank(
    String tankId, {
    int? limit,
    DateTime? after,
  }) => _delegate.getLogsForTank(tankId, limit: limit, after: after);
  @override
  Future<LogEntry?> getLatestWaterTest(String tankId) =>
      _delegate.getLatestWaterTest(tankId);
  @override
  Future<void> saveLog(LogEntry log) => _delegate.saveLog(log);
  @override
  Future<void> deleteLog(String id) async {
    throw StateError('local log storage unavailable');
  }

  @override
  Future<List<Task>> getTasksForTank(String? tankId) =>
      _delegate.getTasksForTank(tankId);
  @override
  Future<void> saveTask(Task task) => _delegate.saveTask(task);
  @override
  Future<void> deleteTask(String id) => _delegate.deleteTask(id);
}

Widget _wrap({List<LogEntry>? logs, StorageService? storage}) {
  final memStorage = storage ?? InMemoryStorageService();
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

    testWidgets('delete failure shows feedback and keeps log visible', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(storage: _ThrowingLogDeleteStorage()));
      await _advance(tester);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete Log'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(
        find.text("Couldn't delete that log. Try again in a moment."),
        findsOneWidget,
      );
      expect(find.text('Changed 30% of water'), findsOneWidget);
    });
  });
}
