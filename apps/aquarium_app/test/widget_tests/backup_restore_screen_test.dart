// Widget tests for BackupRestoreScreen.
//
// Run: flutter test test/widget_tests/backup_restore_screen_test.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/models/models.dart';
import 'package:danio/screens/backup_restore_screen.dart';
import 'package:danio/providers/storage_provider.dart';
import 'package:danio/services/local_json_storage_service.dart';
import 'package:danio/services/storage_service.dart';
import 'package:danio/widgets/core/app_card.dart';

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

Tank _makeTank() {
  final now = DateTime.utc(2026, 7, 16);
  return Tank(
    id: 'backup-tank',
    name: 'Backup Tank',
    type: TankType.freshwater,
    volumeLitres: 100,
    startDate: now,
    targets: WaterTargets.freshwaterTropical(),
    createdAt: now,
    updatedAt: now,
  );
}

const _pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
const _shareChannel = MethodChannel('dev.fluttercommunity.plus/share');

class _StartedExport {
  const _StartedExport({required this.zipPath, required this.existedAtShare});

  final String zipPath;
  final bool existedAtShare;
}

Future<_StartedExport> _startExport(
  WidgetTester tester, {
  required Future<Object?> Function() shareResponse,
}) async {
  late final Directory root;
  late final Directory documentsDirectory;
  late final Directory temporaryDirectory;
  await tester.runAsync(() async {
    root = await Directory.systemTemp.createTemp('danio_backup_share_test_');
    documentsDirectory = await Directory(
      '${root.path}${Platform.pathSeparator}documents',
    ).create();
    temporaryDirectory = await Directory(
      '${root.path}${Platform.pathSeparator}temporary',
    ).create();
  });

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final shareInvoked = Completer<void>();
  String? sharedZipPath;
  var zipExistedWhenShared = false;

  addTearDown(() {
    messenger.setMockMethodCallHandler(_pathProviderChannel, null);
    messenger.setMockMethodCallHandler(_shareChannel, null);
    if (root.existsSync()) {
      try {
        root.deleteSync(recursive: true);
      } on FileSystemException {
        // Preserve the primary test failure when a leaking archive is still
        // briefly held by the export operation.
      }
    }
  });

  messenger.setMockMethodCallHandler(_pathProviderChannel, (call) async {
    switch (call.method) {
      case 'getApplicationDocumentsDirectory':
        return documentsDirectory.path;
      case 'getTemporaryDirectory':
        return temporaryDirectory.path;
      default:
        throw MissingPluginException(
          'Unexpected path_provider call: ${call.method}',
        );
    }
  });
  messenger.setMockMethodCallHandler(_shareChannel, (call) async {
    expect(call.method, 'shareFiles');
    final arguments = Map<String, dynamic>.from(call.arguments as Map);
    sharedZipPath = (arguments['paths'] as List).single as String;
    zipExistedWhenShared = File(sharedZipPath!).existsSync();
    shareInvoked.complete();
    return shareResponse();
  });

  final storage = InMemoryStorageService();
  await storage.saveTank(_makeTank());
  await tester.pumpWidget(_wrap(storage: storage));
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.tap(find.text('Export Backup (ZIP)'));
  await tester.pump();

  for (var i = 0; i < 300 && !shareInvoked.isCompleted; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 10));
  }

  expect(shareInvoked.isCompleted, isTrue);
  expect(sharedZipPath, isNotNull);
  return _StartedExport(
    zipPath: sharedZipPath!,
    existedAtShare: zipExistedWhenShared,
  );
}

Future<void> _waitForExportUi(WidgetTester tester) async {
  for (
    var i = 0;
    i < 300 && find.text('Exporting...').evaluate().isNotEmpty;
    i++
  ) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 10));
  }
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _waitForZipCleanup(WidgetTester tester, String zipPath) async {
  for (var i = 0; i < 300 && File(zipPath).existsSync(); i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 10));
  }
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

    testWidgets('tablet keeps backup and restore surfaces readable', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final introCard = find
          .ancestor(
            of: find.textContaining('Export your tank data and photos'),
            matching: find.byType(AppCard),
          )
          .first;
      final exportCard = find
          .ancestor(
            of: find.text('0 tanks to export'),
            matching: find.byType(Card),
          )
          .first;
      final introWidth = tester.getSize(introCard).width;
      final exportWidth = tester.getSize(exportCard).width;

      await tester.scrollUntilVisible(
        find.text('Select Backup File'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final importCard = find
          .ancestor(
            of: find.text('Select Backup File'),
            matching: find.byType(AppCard),
          )
          .first;
      final importWidth = tester.getSize(importCard).width;

      await tester.scrollUntilVisible(
        find.text('All tanks and settings'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final exportedItemsCard = find
          .ancestor(
            of: find.text('All tanks and settings'),
            matching: find.byType(AppCard),
          )
          .first;
      final exportedItemsWidth = tester.getSize(exportedItemsCard).width;

      await tester.scrollUntilVisible(
        find.text('Import Safety'),
        900,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      final importSafetyCard = find
          .ancestor(
            of: find.text('Import Safety'),
            matching: find.byType(AppCard),
          )
          .first;

      expect(introWidth, lessThanOrEqualTo(720));
      expect(exportWidth, lessThanOrEqualTo(720));
      expect(importWidth, lessThanOrEqualTo(720));
      expect(exportedItemsWidth, lessThanOrEqualTo(720));
      expect(tester.getSize(importSafetyCard).width, lessThanOrEqualTo(720));
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

    test('import failure path cleans newly restored photos', () {
      final source = File(
        'lib/screens/backup_restore_screen.dart',
      ).readAsStringSync();

      expect(source, contains('restoredPhotosForImport'));
      expect(source, contains('cleanupLastRestoredPhotos'));
      expect(
        source.indexOf('cleanupLastRestoredPhotos'),
        lessThan(source.indexOf('BackupRestoreScreen: backup import failed')),
      );
    });

    test(
      'restore screen cleanup helper keeps cleanup failures best effort',
      () async {
        var cleanupCalls = 0;

        await cleanupRestoredPhotosBestEffort(
          shouldCleanup: true,
          cleanup: () async {
            cleanupCalls += 1;
            throw StateError('cleanup failed');
          },
        );

        expect(cleanupCalls, 1);

        final source = File(
          'lib/screens/backup_restore_screen.dart',
        ).readAsStringSync();
        final failureLogIndex = source.indexOf(
          'BackupRestoreScreen: backup import failed',
        );
        expect(failureLogIndex, isNonNegative);
        final catchIndex = source.lastIndexOf(
          '} catch (e, st) {',
          failureLogIndex,
        );
        expect(catchIndex, isNonNegative);

        final catchBody = source.substring(catchIndex, failureLogIndex);
        expect(catchBody, contains('cleanupRestoredPhotosBestEffort'));
        expect(
          catchBody,
          isNot(
            contains('await importBackupService?.cleanupLastRestoredPhotos()'),
          ),
        );
      },
    );
  });

  group('BackupRestoreScreen - export outcomes', () {
    testWidgets(
      'dismissed export leaves no Last backup and explains it was not saved',
      (tester) async {
        final export = await _startExport(
          tester,
          shareResponse: () async => '',
        );
        await _waitForExportUi(tester);

        expect(export.existedAtShare, isTrue);
        expect(find.textContaining('Last backup:'), findsNothing);
        expect(
          find.text(
            "Backup wasn't saved. Choose a destination and try again.",
          ),
          findsOneWidget,
        );
        expect(File(export.zipPath).existsSync(), isFalse);
      },
    );

    testWidgets(
      'unavailable export explains that saved status could not be confirmed',
      (tester) async {
        final export = await _startExport(
          tester,
          shareResponse: () async =>
              'dev.fluttercommunity.plus/share/unavailable',
        );
        await _waitForExportUi(tester);

        expect(export.existedAtShare, isTrue);
        expect(find.textContaining('Last backup:'), findsNothing);
        expect(
          find.text(
            "Danio couldn't confirm that the backup was saved. Check your destination before trying again.",
          ),
          findsOneWidget,
        );
        expect(File(export.zipPath).existsSync(), isFalse);
      },
    );

    testWidgets(
      'share failure cleans the ZIP and keeps error feedback honest',
      (
        tester,
      ) async {
        final export = await _startExport(
          tester,
          shareResponse: () async => throw PlatformException(
            code: 'share-failed',
            message: 'simulated share failure',
          ),
        );
        await _waitForExportUi(tester);

        expect(export.existedAtShare, isTrue);
        expect(find.textContaining('Last backup:'), findsNothing);
        expect(
          find.text("Export didn't work. Give it another go!"),
          findsOneWidget,
        );
        expect(File(export.zipPath).existsSync(), isFalse);
      },
    );

    testWidgets('successful share records Last backup and cleans the ZIP', (
      tester,
    ) async {
      final export = await _startExport(
        tester,
        shareResponse: () async => 'selected.destination',
      );
      await _waitForExportUi(tester);

      expect(export.existedAtShare, isTrue);
      expect(find.textContaining('Last backup:'), findsOneWidget);
      expect(find.text('Backup exported successfully!'), findsOneWidget);
      expect(File(export.zipPath).existsSync(), isFalse);
    });

    testWidgets('unmount while sharing still cleans the completed ZIP', (
      tester,
    ) async {
      final shareResponse = Completer<Object?>();
      final export = await _startExport(
        tester,
        shareResponse: () => shareResponse.future,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      shareResponse.complete('');
      await _waitForZipCleanup(tester, export.zipPath);

      expect(export.existedAtShare, isTrue);
      expect(File(export.zipPath).existsSync(), isFalse);
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
