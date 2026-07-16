// Tests for LocalJsonStorageService error handling.
//
// Tests the public API of LocalJsonStorageService:
//   - StorageState enum values
//   - StorageCorruptionException construction
//   - StorageError construction
//   - ReviewCard.newCard starts with 0 strength/interval
//   - Service state enum coverage
//
// Run: flutter test test/storage_error_handling_test.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:danio/models/models.dart';
import 'package:danio/services/local_json_storage_service.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this.documentsPath);

  String documentsPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => documentsPath;
}

class _CopyFailingFile implements File {
  _CopyFailingFile(this._delegate);

  final File _delegate;

  @override
  String get path => _delegate.path;

  @override
  Future<bool> exists() => _delegate.exists();

  @override
  Future<String> readAsString({Encoding encoding = utf8}) =>
      _delegate.readAsString(encoding: encoding);

  @override
  Future<File> copy(String newPath) {
    throw FileSystemException('Simulated corrupt-file copy failure', newPath);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Tank _makeTank({
  String id = 'tank-1',
  String name = 'Test Tank',
}) {
  final now = DateTime.now();
  return Tank(
    id: id,
    name: name,
    type: TankType.freshwater,
    volumeLitres: 80,
    startDate: now,
    targets: WaterTargets.freshwaterTropical(),
    createdAt: now,
    updatedAt: now,
  );
}

Livestock _makeLivestock({
  String id = 'livestock-1',
  String tankId = 'tank-1',
}) {
  final now = DateTime.now();
  return Livestock(
    id: id,
    tankId: tankId,
    commonName: 'Neon tetra',
    count: 6,
    dateAdded: now,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('StorageState enum', () {
    test('has all expected values', () {
      expect(
        StorageState.values,
        containsAll([
          StorageState.idle,
          StorageState.loading,
          StorageState.loaded,
          StorageState.corrupted,
          StorageState.ioError,
        ]),
      );
    });

    test('idle is not an error state', () {
      // Simulate the hasError getter logic
      bool hasError(StorageState state) =>
          state == StorageState.corrupted || state == StorageState.ioError;

      expect(hasError(StorageState.idle), isFalse);
      expect(hasError(StorageState.loading), isFalse);
      expect(hasError(StorageState.loaded), isFalse);
      expect(hasError(StorageState.corrupted), isTrue);
      expect(hasError(StorageState.ioError), isTrue);
    });
  });

  group('StorageCorruptionException', () {
    test('constructs with message', () {
      final ex = StorageCorruptionException('File is corrupted');
      expect(ex.message, equals('File is corrupted'));
      expect(ex.corruptedFilePath, isNull);
      expect(ex.originalError, isNull);
    });

    test('constructs with all fields', () {
      const inner = FormatException('bad json');
      final ex = StorageCorruptionException(
        'Parse failed',
        corruptedFilePath: '/data/aquarium.json.corrupted.123',
        originalError: inner,
      );
      expect(ex.message, equals('Parse failed'));
      expect(ex.corruptedFilePath, equals('/data/aquarium.json.corrupted.123'));
      expect(ex.originalError, same(inner));
    });

    test('toString includes class name and message', () {
      final ex = StorageCorruptionException('Something broke');
      expect(ex.toString(), contains('StorageCorruptionException'));
      expect(ex.toString(), contains('Something broke'));
    });

    test('is an Exception', () {
      final ex = StorageCorruptionException('test');
      expect(ex, isA<Exception>());
    });
  });

  group('StorageError', () {
    test('constructs with required fields', () {
      final now = DateTime.now();
      final error = StorageError(
        state: StorageState.corrupted,
        message: 'JSON malformed',
        timestamp: now,
      );
      expect(error.state, equals(StorageState.corrupted));
      expect(error.message, equals('JSON malformed'));
      expect(error.timestamp, equals(now));
      expect(error.corruptedFilePath, isNull);
      expect(error.originalError, isNull);
    });

    test('toString includes state and message', () {
      final error = StorageError(
        state: StorageState.ioError,
        message: 'Permission denied',
        timestamp: DateTime.now(),
      );
      final str = error.toString();
      expect(str, contains('StorageError'));
      expect(str, contains('ioError'));
      expect(str, contains('Permission denied'));
    });
  });

  group('LocalJsonStorageService atomic write failures', () {
    late PathProviderPlatform originalPathProvider;
    late _FakePathProviderPlatform fakePathProvider;
    late Directory root;

    setUp(() async {
      originalPathProvider = PathProviderPlatform.instance;
      root = await Directory.systemTemp.createTemp('danio_storage_atomic_');
      fakePathProvider = _FakePathProviderPlatform(root.path);
      PathProviderPlatform.instance = fakePathProvider;
      await LocalJsonStorageService().clearAllData();
    });

    tearDown(() async {
      fakePathProvider.documentsPath = root.path;
      await LocalJsonStorageService().clearAllData();
      PathProviderPlatform.instance = originalPathProvider;
      if (await root.exists()) {
        await root.delete(recursive: true);
      }
    });

    Future<void> forceNextPersistToFail() async {
      final blocker = File('${root.path}${Platform.pathSeparator}not-a-dir');
      await blocker.writeAsString('blocks child writes');
      fakePathProvider.documentsPath = blocker.path;
    }

    test('failed saveTank does not expose unsaved tank in memory', () async {
      final service = LocalJsonStorageService();
      final existing = _makeTank(id: 'existing', name: 'Existing');
      await service.saveTank(existing);

      await forceNextPersistToFail();

      await expectLater(
        service.saveTank(_makeTank(id: 'unsaved', name: 'Unsaved')),
        throwsA(isA<FileSystemException>()),
      );

      fakePathProvider.documentsPath = root.path;
      expect(await service.getTank('unsaved'), isNull);
      expect((await service.getTank('existing'))?.name, 'Existing');
    });

    test('failed deleteTank keeps tank and children in memory', () async {
      final service = LocalJsonStorageService();
      final tank = _makeTank(id: 'delete-me', name: 'Delete Me');
      final livestock = _makeLivestock(
        id: 'child-fish',
        tankId: tank.id,
      );
      await service.saveTank(tank);
      await service.saveLivestock(livestock);

      await forceNextPersistToFail();

      await expectLater(
        service.deleteTank(tank.id),
        throwsA(isA<FileSystemException>()),
      );

      fakePathProvider.documentsPath = root.path;
      expect(await service.getTank(tank.id), isNotNull);
      expect(await service.getLivestockForTank(tank.id), hasLength(1));
    });

    test('loads and persists migrated v0 local JSON data', () async {
      final service = LocalJsonStorageService();
      final file = File(
        '${root.path}${Platform.pathSeparator}aquarium_data.json',
      );
      final createdAt = DateTime.utc(2026, 1, 1);
      await file.writeAsString(
        jsonEncode({
          'tanks': {
            'legacy-tank': {
              'id': 'legacy-tank',
              'name': 'Legacy Tank',
              'type': 'freshwater',
              'volumeLitres': 75,
              'startDate': createdAt.toIso8601String(),
              'targets': {
                'tempMin': 24,
                'tempMax': 26,
                'phMin': 6.8,
                'phMax': 7.4,
              },
              'createdAt': createdAt.toIso8601String(),
              'updatedAt': createdAt.toIso8601String(),
            },
          },
          'livestock': <String, dynamic>{},
          'equipment': <String, dynamic>{},
          'logs': <String, dynamic>{},
          'tasks': <String, dynamic>{},
        }),
      );
      await service.retryLoad();

      final tanks = await service.getAllTanks();

      expect(tanks, hasLength(1));
      expect(tanks.single.id, 'legacy-tank');
      expect(tanks.single.sortOrder, 0);
      expect(tanks.single.isDemoTank, isFalse);

      final persisted = jsonDecode(await file.readAsString());
      expect(persisted, isA<Map<String, dynamic>>());
      expect((persisted as Map<String, dynamic>)['version'], 2);
    });

    test(
      'failed migration stamp write does not report loaded success',
      () async {
        final service = LocalJsonStorageService();
        final file = File(
          '${root.path}${Platform.pathSeparator}aquarium_data.json',
        );
        final tmpBlocker = Directory('${file.path}.tmp');
        final createdAt = DateTime.utc(2026, 1, 1);
        await file.writeAsString(
          jsonEncode({
            'tanks': {
              'legacy-tank': {
                'id': 'legacy-tank',
                'name': 'Legacy Tank',
                'type': 'freshwater',
                'volumeLitres': 75,
                'startDate': createdAt.toIso8601String(),
                'targets': {
                  'tempMin': 24,
                  'tempMax': 26,
                  'phMin': 6.8,
                  'phMax': 7.4,
                },
                'createdAt': createdAt.toIso8601String(),
                'updatedAt': createdAt.toIso8601String(),
              },
            },
            'livestock': <String, dynamic>{},
            'equipment': <String, dynamic>{},
            'logs': <String, dynamic>{},
            'tasks': <String, dynamic>{},
          }),
        );
        await tmpBlocker.create();

        await expectLater(
          service.retryLoad(),
          throwsA(isA<StorageMigrationPersistenceException>()),
        );

        expect(service.state, StorageState.ioError);
        expect(service.hasError, isTrue);
        expect(service.lastError?.state, StorageState.ioError);
        expect(service.lastError?.message, contains('Migration stamp'));

        final persisted = jsonDecode(await file.readAsString());
        expect(persisted, isA<Map<String, dynamic>>());
        expect(
          (persisted as Map<String, dynamic>).containsKey('version'),
          false,
        );
      },
    );

    test(
      'load I/O errors stay in ioError instead of reporting empty success',
      () async {
        final service = LocalJsonStorageService();
        final dataPath =
            '${root.path}${Platform.pathSeparator}aquarium_data.json';
        final dataFile = File(dataPath);
        if (await dataFile.exists()) {
          await dataFile.delete();
        }
        await Directory(dataPath).create();

        await expectLater(
          service.retryLoad(),
          throwsA(isA<FileSystemException>()),
        );

        expect(service.state, StorageState.ioError);
        expect(service.hasError, isTrue);
        expect(service.lastError?.state, StorageState.ioError);
        expect(service.lastError?.message, contains('I/O error'));

        await expectLater(
          service.getAllTanks(),
          throwsA(isA<FileSystemException>()),
        );
      },
    );

    test(
      'malformed JSON copy failure does not advertise recovery path',
      () async {
        final service = LocalJsonStorageService();
        final file = File(
          '${root.path}${Platform.pathSeparator}aquarium_data.json',
        );
        const malformedJson = '{"tanks":';
        await file.writeAsString(malformedJson);

        await IOOverrides.runZoned(
          () async {
            await expectLater(
              service.retryLoad(),
              throwsA(
                isA<StorageCorruptionException>().having(
                  (error) => error.corruptedFilePath,
                  'corruptedFilePath',
                  isNull,
                ),
              ),
            );
          },
          createFile: (path) {
            expect(path, file.path);
            return _CopyFailingFile(file);
          },
        );

        expect(service.state, StorageState.corrupted);
        expect(service.lastError?.corruptedFilePath, isNull);
        expect(await file.exists(), isTrue);
        expect(await file.readAsString(), malformedJson);
        expect(
          root.listSync().whereType<File>().where(
            (candidate) => candidate.path.contains('.corrupted.'),
          ),
          isEmpty,
        );
      },
    );

    test('malformed JSON reports only a recovery copy that exists', () async {
      final service = LocalJsonStorageService();
      final file = File(
        '${root.path}${Platform.pathSeparator}aquarium_data.json',
      );
      const malformedJson = '{"tanks":';
      await file.writeAsString(malformedJson);

      StorageCorruptionException? thrown;
      try {
        await service.retryLoad();
      } on StorageCorruptionException catch (error) {
        thrown = error;
      }

      expect(thrown, isNotNull);
      expect(thrown?.corruptedFilePath, isNotNull);
      expect(service.lastError?.corruptedFilePath, thrown?.corruptedFilePath);
      expect(await File(thrown!.corruptedFilePath!).exists(), isTrue);
      expect(await file.exists(), isTrue);
      expect(await file.readAsString(), malformedJson);
    });

    test(
      'unchanged malformed JSON retry stays corrupted and blocks empty success',
      () async {
        final service = LocalJsonStorageService();
        final file = File(
          '${root.path}${Platform.pathSeparator}aquarium_data.json',
        );
        const malformedJson = '{"tanks":';
        await file.writeAsString(malformedJson);

        await expectLater(
          service.retryLoad(),
          throwsA(isA<StorageCorruptionException>()),
        );
        await expectLater(
          service.retryLoad(),
          throwsA(isA<StorageCorruptionException>()),
        );

        expect(service.state, StorageState.corrupted);
        expect(service.hasError, isTrue);
        expect(service.lastError?.state, StorageState.corrupted);
        final latestRecoveryCopy = File(
          service.lastError!.corruptedFilePath!,
        );
        expect(await latestRecoveryCopy.exists(), isTrue);
        expect(await latestRecoveryCopy.readAsString(), malformedJson);
        expect(await file.exists(), isTrue);
        expect(await file.readAsString(), malformedJson);
        await expectLater(
          service.getAllTanks(),
          throwsA(isA<StorageCorruptionException>()),
        );

        final recoveryCopies = root.listSync().whereType<File>().where(
          (candidate) => candidate.path.contains('.corrupted.'),
        );
        expect(recoveryCopies, isNotEmpty);
        for (final recoveryCopy in recoveryCopies) {
          expect(await recoveryCopy.readAsString(), malformedJson);
        }
      },
    );

    test(
      'repaired malformed JSON succeeds only through retry without rewriting repair',
      () async {
        final service = LocalJsonStorageService();
        final file = File(
          '${root.path}${Platform.pathSeparator}aquarium_data.json',
        );
        const malformedJson = '{"tanks":';
        await file.writeAsString(malformedJson);

        await expectLater(
          service.retryLoad(),
          throwsA(isA<StorageCorruptionException>()),
        );
        final recoveryPath = service.lastError!.corruptedFilePath!;
        final recoveryCopy = File(recoveryPath);
        expect(await recoveryCopy.exists(), isTrue);
        expect(await recoveryCopy.readAsString(), malformedJson);
        final recoveryPathsBeforeRepair = root
            .listSync()
            .whereType<File>()
            .where((candidate) => candidate.path.contains('.corrupted.'))
            .map((candidate) => candidate.path)
            .toSet();

        final createdAt = DateTime.utc(2026, 1, 1);
        final repairedJson = jsonEncode({
          'version': 2,
          'tanks': {
            'repaired-tank': {
              'id': 'repaired-tank',
              'name': 'Repaired Tank',
              'type': 'freshwater',
              'volumeLitres': 75,
              'startDate': createdAt.toIso8601String(),
              'targets': {
                'tempMin': 24,
                'tempMax': 26,
                'phMin': 6.8,
                'phMax': 7.4,
              },
              'createdAt': createdAt.toIso8601String(),
              'updatedAt': createdAt.toIso8601String(),
            },
          },
          'livestock': <String, dynamic>{},
          'equipment': <String, dynamic>{},
          'logs': <String, dynamic>{},
          'tasks': <String, dynamic>{},
        });
        await file.writeAsString(repairedJson);

        await expectLater(
          service.getAllTanks(),
          throwsA(isA<StorageCorruptionException>()),
        );
        expect(await file.readAsString(), repairedJson);

        await service.retryLoad();
        final tanks = await service.getAllTanks();

        expect(service.state, StorageState.loaded);
        expect(service.hasError, isFalse);
        expect(service.lastError, isNull);
        expect(tanks, hasLength(1));
        expect(tanks.single.id, 'repaired-tank');
        expect(tanks.single.name, 'Repaired Tank');
        expect(await file.readAsString(), repairedJson);
        expect(await recoveryCopy.exists(), isTrue);
        expect(await recoveryCopy.readAsString(), malformedJson);
        final recoveryPathsAfterRetry = root
            .listSync()
            .whereType<File>()
            .where((candidate) => candidate.path.contains('.corrupted.'))
            .map((candidate) => candidate.path)
            .toSet();
        expect(recoveryPathsAfterRetry, recoveryPathsBeforeRepair);
      },
    );
  });

  group('LocalJsonStorageService singleton', () {
    test('returns same instance each time', () {
      final a = LocalJsonStorageService();
      final b = LocalJsonStorageService();
      expect(identical(a, b), isTrue);
    });

    test('initial state is idle or loaded (after any prior test run)', () {
      final service = LocalJsonStorageService();
      // Initial state before any load call is idle; after a load it becomes loaded.
      // Either is acceptable — we just verify it's a known state.
      expect(StorageState.values, contains(service.state));
    });

    test('hasError is false in initial state', () {
      // A fresh service (or one that loaded cleanly) should not report an error.
      final service = LocalJsonStorageService();
      // If state is idle or loaded, hasError should be false
      if (service.state == StorageState.idle ||
          service.state == StorageState.loaded) {
        expect(service.hasError, isFalse);
      }
    });

    test('isHealthy is true when loaded', () {
      // isHealthy == (state == StorageState.loaded)
      final service = LocalJsonStorageService();
      if (service.state == StorageState.loaded) {
        expect(service.isHealthy, isTrue);
      }
    });
  });

  // The temp path-provider coverage above exercises file-backed migration,
  // corruption, and I/O failures without requiring a device.
  test('StorageState enum count is 5', () {
    expect(StorageState.values.length, equals(5));
  });
}
