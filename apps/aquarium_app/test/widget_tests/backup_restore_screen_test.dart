// Widget tests for BackupRestoreScreen.
//
// Run: flutter test test/widget_tests/backup_restore_screen_test.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

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

class _StartedImportPreview {
  const _StartedImportPreview({
    required this.picker,
    required this.zipPath,
    required this.documentsDirectory,
  });

  final _FakeFilePicker picker;
  final String zipPath;
  final Directory documentsDirectory;
}

class _FakeFilePicker extends FilePicker {
  _FakeFilePicker(this.result, {this.error});

  final FilePickerResult? result;
  final Object? error;
  int pickCalls = 0;
  FileType? requestedType;
  List<String>? requestedExtensions;
  bool? requestedAllowMultiple;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    pickCalls += 1;
    requestedType = type;
    requestedExtensions = allowedExtensions;
    requestedAllowMultiple = allowMultiple;
    if (error != null) {
      throw error!;
    }
    return result;
  }
}

class _WriteTrackingStorageService extends _RecoverableStorageService {
  _WriteTrackingStorageService() {
    state = StorageState.loaded;
    lastError = null;
  }

  int importWriteCount = 0;

  @override
  Future<void> saveTank(Tank tank) async {
    importWriteCount += 1;
    await super.saveTank(tank);
  }

  @override
  Future<void> saveLivestock(Livestock livestock) async {
    importWriteCount += 1;
    await super.saveLivestock(livestock);
  }

  @override
  Future<void> saveEquipment(Equipment equipment) async {
    importWriteCount += 1;
    await super.saveEquipment(equipment);
  }

  @override
  Future<void> saveLog(LogEntry log) async {
    importWriteCount += 1;
    await super.saveLog(log);
  }

  @override
  Future<void> saveTask(Task task) async {
    importWriteCount += 1;
    await super.saveTask(task);
  }

  @override
  Future<void> deleteAllTanks(List<String> ids) async {
    importWriteCount += 1;
    await super.deleteAllTanks(ids);
  }
}

class _WriteTrackingSharedPreferencesStore
    extends InMemorySharedPreferencesStore {
  _WriteTrackingSharedPreferencesStore.withData(super.data) : super.withData();

  int writeCount = 0;

  @override
  Future<bool> setValue(String valueType, String key, Object value) {
    writeCount += 1;
    return super.setValue(valueType, key, value);
  }

  @override
  Future<bool> remove(String key) {
    writeCount += 1;
    return super.remove(key);
  }

  @override
  Future<bool> clear() {
    writeCount += 1;
    return super.clear();
  }
}

Future<_FakeFilePicker> _startImportWithPickerResult(
  WidgetTester tester, {
  required FilePickerResult? result,
  required StorageService storage,
  Object? error,
}) async {
  final originalFilePicker = FilePicker.platform;
  final fakeFilePicker = _FakeFilePicker(result, error: error);
  FilePicker.platform = fakeFilePicker;
  addTearDown(() => FilePicker.platform = originalFilePicker);

  await tester.pumpWidget(_wrap(storage: storage));
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.tap(find.text('Select Backup File'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  return fakeFilePicker;
}

Future<_StartedImportPreview> _startValidImportPreview(
  WidgetTester tester, {
  required StorageService storage,
}) async {
  late final Directory root;
  late final Directory documentsDirectory;
  late final String zipPath;
  late final int zipSize;

  await tester.runAsync(() async {
    root = await Directory.systemTemp.createTemp(
      'danio_backup_confirm_cancel_test_',
    );
    documentsDirectory = await Directory(
      '${root.path}${Platform.pathSeparator}documents',
    ).create();
    zipPath = '${root.path}${Platform.pathSeparator}confirmation-cancel.zip';

    const timestamp = '2026-07-16T12:00:00.000Z';
    final archive = Archive()
      ..addFile(
        ArchiveFile.string(
          'backup.json',
          jsonEncode({
            'tanks': [
              {
                'id': 'confirmation-cancel-tank',
                'name': 'Confirmation Cancel Tank',
                'type': 'freshwater',
                'volumeLitres': 100,
                'startDate': timestamp,
                'createdAt': timestamp,
                'updatedAt': timestamp,
                'imageUrl': 'photos/confirmation-cancel.jpg',
              },
            ],
            'livestock': <Object>[],
            'equipment': <Object>[],
            'logs': <Object>[],
            'tasks': <Object>[],
            'sharedPreferences': {
              '__backup_version': 1,
              'exportDate': timestamp,
              'entries': {'use_metric': false},
            },
          }),
        ),
      )
      ..addFile(
        ArchiveFile.string(
          'photos/confirmation-cancel.jpg',
          'confirmation cancel photo fixture',
        ),
      );
    final zipBytes = ZipEncoder().encode(archive)!;
    final zipFile = File(zipPath);
    await zipFile.writeAsBytes(zipBytes);
    zipSize = await zipFile.length();
  });

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  addTearDown(() {
    messenger.setMockMethodCallHandler(_pathProviderChannel, null);
    if (root.existsSync()) {
      root.deleteSync(recursive: true);
    }
  });
  messenger.setMockMethodCallHandler(_pathProviderChannel, (call) async {
    if (call.method == 'getApplicationDocumentsDirectory') {
      return documentsDirectory.path;
    }
    throw MissingPluginException(
      'Unexpected path_provider call during import preview: ${call.method}',
    );
  });

  final picker = await _startImportWithPickerResult(
    tester,
    result: FilePickerResult([
      PlatformFile(
        name: 'confirmation-cancel.zip',
        size: zipSize,
        path: zipPath,
      ),
    ]),
    storage: storage,
  );

  for (
    var i = 0;
    i < 300 && find.text('Import Backup?').evaluate().isEmpty;
    i++
  ) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 10));
  }

  return _StartedImportPreview(
    picker: picker,
    zipPath: zipPath,
    documentsDirectory: documentsDirectory,
  );
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
    FilePickerIO.registerWith();
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

  group('BackupRestoreScreen - file selection outcomes', () {
    testWidgets('picker cancel returns idle without restore writes', (
      tester,
    ) async {
      final storage = _WriteTrackingStorageService();
      final picker = await _startImportWithPickerResult(
        tester,
        result: null,
        storage: storage,
      );
      final preferences = await SharedPreferences.getInstance();

      expect(picker.pickCalls, 1);
      expect(picker.requestedType, FileType.custom);
      expect(picker.requestedExtensions, ['zip']);
      expect(picker.requestedAllowMultiple, isFalse);
      expect(storage.importWriteCount, 0);
      expect(preferences.getKeys(), isEmpty);
      expect(find.text('Select Backup File'), findsOneWidget);
      expect(find.text('Importing...'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('Import Backup?'), findsNothing);
      expect(
        find.text('Import failed. The file may be invalid or corrupted.'),
        findsNothing,
      );
    });

    testWidgets('empty picker result returns idle without restore writes', (
      tester,
    ) async {
      final storage = _WriteTrackingStorageService();
      final picker = await _startImportWithPickerResult(
        tester,
        result: const FilePickerResult([]),
        storage: storage,
      );
      final preferences = await SharedPreferences.getInstance();

      expect(picker.pickCalls, 1);
      expect(storage.importWriteCount, 0);
      expect(preferences.getKeys(), isEmpty);
      expect(find.text('Select Backup File'), findsOneWidget);
      expect(find.text('Importing...'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('Import Backup?'), findsNothing);
      expect(
        find.text('Import failed. The file may be invalid or corrupted.'),
        findsNothing,
      );
    });

    testWidgets(
      'pathless selection returns idle with access feedback and no writes',
      (tester) async {
        final storage = _WriteTrackingStorageService();
        final picker = await _startImportWithPickerResult(
          tester,
          result: FilePickerResult([
            PlatformFile(name: 'danio-backup.zip', size: 1024),
          ]),
          storage: storage,
        );
        final preferences = await SharedPreferences.getInstance();

        expect(picker.pickCalls, 1);
        expect(storage.importWriteCount, 0);
        expect(preferences.getKeys(), isEmpty);
        expect(find.text('Select Backup File'), findsOneWidget);
        expect(find.text('Importing...'), findsNothing);
        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(find.text('Import Backup?'), findsNothing);
        expect(
          find.text(
            "Danio couldn't access that backup file. Choose it again or try another ZIP.",
          ),
          findsOneWidget,
        );
        expect(
          find.text('Import failed. The file may be invalid or corrupted.'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'unknown-path picker error returns idle with access feedback and no writes',
      (tester) async {
        final storage = _WriteTrackingStorageService();
        final picker = await _startImportWithPickerResult(
          tester,
          result: null,
          storage: storage,
          error: PlatformException(
            code: 'unknown_path',
            message: 'Failed to retrieve path.',
          ),
        );
        final preferences = await SharedPreferences.getInstance();

        expect(picker.pickCalls, 1);
        expect(storage.importWriteCount, 0);
        expect(preferences.getKeys(), isEmpty);
        expect(find.text('Select Backup File'), findsOneWidget);
        expect(find.text('Importing...'), findsNothing);
        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(find.text('Import Backup?'), findsNothing);
        expect(
          find.text(
            "Danio couldn't access that backup file. Choose it again or try another ZIP.",
          ),
          findsOneWidget,
        );
        expect(
          find.text('Import failed. The file may be invalid or corrupted.'),
          findsNothing,
        );
      },
    );
  });

  group('BackupRestoreScreen - confirmation outcomes', () {
    testWidgets(
      'canceling a valid preview returns idle without restore writes',
      (tester) async {
        final originalPreferencesStore =
            SharedPreferencesStorePlatform.instance;
        final preferenceStore = _WriteTrackingSharedPreferencesStore.withData({
          'flutter.use_metric': true,
        });
        SharedPreferences.resetStatic();
        SharedPreferencesStorePlatform.instance = preferenceStore;
        addTearDown(() {
          SharedPreferences.resetStatic();
          SharedPreferencesStorePlatform.instance = originalPreferencesStore;
        });
        final storage = _WriteTrackingStorageService();
        final started = await _startValidImportPreview(
          tester,
          storage: storage,
        );
        final preferences = await SharedPreferences.getInstance();
        final photosDirectory = Directory(
          '${started.documentsDirectory.path}${Platform.pathSeparator}photos',
        );

        expect(started.picker.pickCalls, 1);
        expect(File(started.zipPath).existsSync(), isTrue);
        expect(find.text('Import Backup?'), findsOneWidget);
        expect(
          find.textContaining('This will import 1 tank with all photos.'),
          findsOneWidget,
        );
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Import'), findsOneWidget);
        expect(storage.importWriteCount, 0);
        expect(preferenceStore.writeCount, 0);
        expect(preferences.getBool('use_metric'), isTrue);
        expect(preferences.getKeys(), {'use_metric'});
        expect(photosDirectory.existsSync(), isFalse);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.text('Import Backup?'), findsNothing);
        expect(find.text('Select Backup File'), findsOneWidget);
        expect(find.text('Importing...'), findsNothing);
        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(storage.importWriteCount, 0);
        expect(preferenceStore.writeCount, 0);
        expect(preferences.getBool('use_metric'), isTrue);
        expect(preferences.getKeys(), {'use_metric'});
        expect(photosDirectory.existsSync(), isFalse);
        expect(File(started.zipPath).existsSync(), isTrue);
        expect(
          find.text('Imported 1 tank with all data successfully!'),
          findsNothing,
        );
        expect(
          find.text('Import failed. The file may be invalid or corrupted.'),
          findsNothing,
        );
      },
    );
  });

  group('BackupRestoreScreen - local storage recovery', () {
    testWidgets(
      'I/O load error offers real retry without destructive start fresh',
      (tester) async {
        final storage = _RecoverableStorageService()
          ..state = StorageState.ioError
          ..lastError = StorageError(
            state: StorageState.ioError,
            message: 'Migration stamp persistence failed',
            timestamp: DateTime.utc(2026, 1, 1),
          );

        await tester.pumpWidget(_wrap(storage: storage));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Local Data Needs Attention'), findsOneWidget);
        expect(
          find.textContaining('could not safely read or update'),
          findsOneWidget,
        );
        expect(find.text('Try Again'), findsOneWidget);
        expect(find.text('Start Fresh On This Device'), findsNothing);

        await tester.tap(find.text('Try Again'));
        await tester.pumpAndSettle();

        expect(storage.retryCount, 1);
        expect(storage.state, StorageState.loaded);
        expect(find.text('Local Data Needs Attention'), findsNothing);
      },
    );

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

    testWidgets(
      'corruption without recovery path never claims a copy exists',
      (tester) async {
        final storage = _RecoverableStorageService()
          ..lastError = StorageError(
            state: StorageState.corrupted,
            message: 'JSON parsing failed after backup copy failed',
            timestamp: DateTime.utc(2026, 1, 1),
          );

        await tester.pumpWidget(_wrap(storage: storage));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Local Data Needs Attention'), findsOneWidget);
        expect(
          find.textContaining('could not make a recovery copy'),
          findsOneWidget,
        );
        expect(find.textContaining('kept a recovery copy'), findsNothing);
        expect(find.text('Try Again'), findsOneWidget);
        expect(find.text('Start Fresh On This Device'), findsOneWidget);

        await tester.tap(find.text('Start Fresh On This Device'));
        await tester.pumpAndSettle();

        expect(find.text('Start Fresh On This Device?'), findsOneWidget);
        expect(
          find.textContaining('no recovery copy will remain'),
          findsOneWidget,
        );
        expect(find.textContaining('keeps the recovery copy'), findsNothing);
      },
    );

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
      expect(
        find.textContaining('keeps the recovery copy'),
        findsOneWidget,
      );

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
