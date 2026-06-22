// Widget tests for BackupRestoreScreen.
//
// Run: flutter test test/widget_tests/backup_restore_screen_test.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/models/models.dart';
import 'package:danio/screens/backup_restore_screen.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/local_json_storage_service.dart';
import 'package:danio/services/storage_service.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap({StorageService? storage}) {
  return ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(
        storage ?? InMemoryStorageService(),
      ),
    ],
    child: const MaterialApp(home: BackupRestoreScreen()),
  );
}

class _RecoverableStorageService
    implements StorageService, StorageRecoveryService {
  final InMemoryStorageService _delegate = InMemoryStorageService();

  int retryCount = 0;
  int recoverCount = 0;

  @override
  StorageState state = StorageState.corrupted;

  @override
  StorageError? lastError = StorageError(
    state: StorageState.corrupted,
    message: 'JSON parsing failed',
    corruptedFilePath: 'aquarium_data.json.corrupted.1',
    timestamp: DateTime.utc(2026, 1, 1),
  );

  @override
  bool get hasError =>
      state == StorageState.corrupted || state == StorageState.ioError;

  @override
  Future<void> retryLoad() async {
    retryCount += 1;
    state = StorageState.loaded;
    lastError = null;
  }

  @override
  Future<void> recoverFromCorruption() async {
    recoverCount += 1;
    final tanks = await _delegate.getAllTanks();
    await _delegate.deleteAllTanks(tanks.map((tank) => tank.id).toList());
    state = StorageState.loaded;
    lastError = null;
  }

  @override
  Future<List<Tank>> getAllTanks() async => _delegate.getAllTanks();

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
  Future<void> deleteLog(String id) => _delegate.deleteLog(id);

  @override
  Future<List<Task>> getTasksForTank(String? tankId) =>
      _delegate.getTasksForTank(tankId);

  @override
  Future<void> saveTask(Task task) => _delegate.saveTask(task);

  @override
  Future<void> deleteTask(String id) => _delegate.deleteTask(id);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BackupRestoreScreen - basic rendering', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(BackupRestoreScreen), findsOneWidget);
    });

    testWidgets('shows Backup & Restore app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Backup & Restore'), findsOneWidget);
    });

    testWidgets('shows export button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('Export'), findsWidgets);
    });

    testWidgets('shows import/restore button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.textContaining('Import').evaluate().isNotEmpty ||
            find.textContaining('Restore').evaluate().isNotEmpty,
        isTrue,
        reason: 'Should have an import or restore button',
      );
    });

    testWidgets('shows info card about backup', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      // The info card explains what the backup does
      expect(find.byIcon(Icons.backup), findsWidgets);
    });

    testWidgets('shows clear import safety copy', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.drag(find.byType(ListView), const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(find.text('Import Safety'), findsOneWidget);
      expect(
        find.text(
          'Imports add backed-up tanks as new tanks. Existing tanks and logs stay on this device. App-wide profile, learning progress, gems, and preferences are replaced from the backup.',
        ),
        findsOneWidget,
      );
    });

    test('user-facing copy describes local ZIP backup only', () {
      final source = File(
        'lib/screens/backup_restore_screen.dart',
      ).readAsStringSync();

      expect(source, contains('ZIP file'));
      expect(RegExp(r'[^\x00-\x7F]').hasMatch(source), isFalse);
      expect(source, contains('Existing tanks and logs stay on this device'));
      expect(
        source,
        contains(
          'App-wide profile, learning progress, gems, and preferences are replaced',
        ),
      );
      expect(source, isNot(contains('sync your aquarium data')));
      expect(source, isNot(contains('cloud backup')));
      expect(source, isNot(contains('uploaded successfully')));
    });
  });

  group('BackupRestoreScreen - local storage recovery', () {
    testWidgets('shows local storage recovery actions when data is corrupted', (
      tester,
    ) async {
      final storage = _RecoverableStorageService();

      await tester.pumpWidget(_wrap(storage: storage));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Local Data Needs Attention'), findsOneWidget);
      expect(
        find.textContaining('Danio kept a recovery copy on this device'),
        findsOneWidget,
      );
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Start Fresh On This Device'), findsOneWidget);
    });

    testWidgets('start fresh confirms and clears corrupted local storage', (
      tester,
    ) async {
      final storage = _RecoverableStorageService();

      await tester.pumpWidget(_wrap(storage: storage));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Start Fresh On This Device'));
      await tester.pumpAndSettle();

      expect(find.text('Start Fresh On This Device?'), findsOneWidget);
      expect(find.text('Start Fresh'), findsOneWidget);

      await tester.tap(find.text('Start Fresh'));
      await tester.pumpAndSettle();

      expect(storage.recoverCount, 1);
      expect(storage.state, StorageState.loaded);
      expect(find.text('Local Data Needs Attention'), findsNothing);
      expect(find.text('0 tanks to export'), findsOneWidget);
    });

    testWidgets('try again reloads local storage and hides recovery card', (
      tester,
    ) async {
      final storage = _RecoverableStorageService();

      await tester.pumpWidget(_wrap(storage: storage));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      expect(storage.retryCount, 1);
      expect(storage.state, StorageState.loaded);
      expect(find.text('Local Data Needs Attention'), findsNothing);
      expect(find.text('0 tanks to export'), findsOneWidget);
    });
  });
}
