import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:danio/services/backup_service.dart';

void main() {
  group('BackupService photo restore', () {
    late Directory root;
    late Directory sourceDocs;
    late Directory restoreDocs;
    late Directory tempDir;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('danio_backup_photo_test_');
      sourceDocs = Directory(p.join(root.path, 'source_docs'));
      restoreDocs = Directory(p.join(root.path, 'restore_docs'));
      tempDir = Directory(p.join(root.path, 'temp'));
      await sourceDocs.create(recursive: true);
      await restoreDocs.create(recursive: true);
      await tempDir.create(recursive: true);
    });

    tearDown(() async {
      if (await root.exists()) {
        await root.delete(recursive: true);
      }
    });

    test(
      'restores same-basename photos without overwriting local files',
      () async {
        final sourcePhotos = Directory(p.join(sourceDocs.path, 'photos'));
        final restorePhotos = Directory(p.join(restoreDocs.path, 'photos'));
        await sourcePhotos.create(recursive: true);
        await restorePhotos.create(recursive: true);

        final sourcePhoto = File(p.join(sourcePhotos.path, 'fish.jpg'));
        final existingLocalPhoto = File(p.join(restorePhotos.path, 'fish.jpg'));
        await sourcePhoto.writeAsString('backup photo');
        await existingLocalPhoto.writeAsString('local photo');

        final createService = BackupService(
          getDocumentsDirectory: () async => sourceDocs,
          getTemporaryDirectory: () async => tempDir,
        );
        final zipPath = await createService.createBackup({
          'tanks': [
            {'id': 'tank-1', 'imageUrl': sourcePhoto.path},
          ],
        });

        final restoreService = BackupService(
          getDocumentsDirectory: () async => restoreDocs,
          getTemporaryDirectory: () async => tempDir,
        );

        final resolvedData = await restoreService.getBackupData(zipPath);
        final resolvedPhotoPath =
            (resolvedData['tanks'] as List).first['imageUrl'] as String;

        expect(resolvedPhotoPath, isNot(existingLocalPhoto.path));
        expect(p.basename(resolvedPhotoPath), startsWith('import_'));
        expect(p.basename(resolvedPhotoPath), endsWith('_fish.jpg'));

        await restoreService.restoreBackup(zipPath);

        expect(await existingLocalPhoto.readAsString(), 'local photo');
        expect(await File(resolvedPhotoPath).readAsString(), 'backup photo');
      },
    );

    test('getBackupData rejects backups without a tanks array', () async {
      final service = BackupService(
        getDocumentsDirectory: () async => sourceDocs,
        getTemporaryDirectory: () async => tempDir,
      );
      final zipPath = await service.createBackup({
        'version': 3,
        'logs': const [],
      });

      await expectLater(
        service.getBackupData(zipPath),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Invalid format: missing tanks array'),
          ),
        ),
      );
    });

    test('getBackupData rejects non-object tank entries', () async {
      final service = BackupService(
        getDocumentsDirectory: () async => sourceDocs,
        getTemporaryDirectory: () async => tempDir,
      );
      final zipPath = await service.createBackup({
        'tanks': ['not-a-tank'],
      });

      await expectLater(
        service.getBackupData(zipPath),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Invalid format: tank entries must be objects'),
          ),
        ),
      );
    });

    test('getBackupData rejects tank entries without ids', () async {
      final service = BackupService(
        getDocumentsDirectory: () async => sourceDocs,
        getTemporaryDirectory: () async => tempDir,
      );
      final zipPath = await service.createBackup({
        'tanks': [
          {'name': 'Missing ID'},
        ],
      });

      await expectLater(
        service.getBackupData(zipPath),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Invalid format: tank entries must include an id'),
          ),
        ),
      );
    });

    test('getBackupData rejects duplicate tank ids', () async {
      final service = BackupService(
        getDocumentsDirectory: () async => sourceDocs,
        getTemporaryDirectory: () async => tempDir,
      );
      final zipPath = await service.createBackup({
        'tanks': [
          {'id': 'tank-1', 'name': 'First copy'},
          {'id': 'tank-1', 'name': 'Duplicate copy'},
        ],
      });

      await expectLater(
        service.getBackupData(zipPath),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Invalid format: duplicate tank id'),
          ),
        ),
      );
    });

    for (final childCollection in const [
      'logs',
      'livestock',
      'equipment',
      'tasks',
    ]) {
      test(
        'getBackupData rejects $childCollection for unknown tank ids',
        () async {
          final service = BackupService(
            getDocumentsDirectory: () async => sourceDocs,
            getTemporaryDirectory: () async => tempDir,
          );
          final zipPath = await service.createBackup({
            'tanks': [
              {'id': 'tank-1', 'name': 'Main tank'},
            ],
            childCollection: [
              {'id': '$childCollection-1', 'tankId': 'missing-tank'},
            ],
          });

          await expectLater(
            service.getBackupData(zipPath),
            throwsA(
              isA<Exception>().having(
                (error) => error.toString(),
                'message',
                contains(
                  'Invalid format: $childCollection entries reference unknown tank id',
                ),
              ),
            ),
          );
        },
      );
    }

    for (final childCollection in const [
      'logs',
      'livestock',
      'equipment',
      'tasks',
    ]) {
      test('getBackupData rejects non-array $childCollection data', () async {
        final service = BackupService(
          getDocumentsDirectory: () async => sourceDocs,
          getTemporaryDirectory: () async => tempDir,
        );
        final zipPath = await service.createBackup({
          'tanks': [
            {'id': 'tank-1', 'name': 'Main tank'},
          ],
          childCollection: {'id': '$childCollection-1', 'tankId': 'tank-1'},
        });

        await expectLater(
          service.getBackupData(zipPath),
          throwsA(
            isA<Exception>().having(
              (error) => error.toString(),
              'message',
              contains('Invalid format: $childCollection must be an array'),
            ),
          ),
        );
      });
    }

    for (final childCollection in const [
      'logs',
      'livestock',
      'equipment',
      'tasks',
    ]) {
      test(
        'getBackupData rejects $childCollection entries without ids',
        () async {
          final service = BackupService(
            getDocumentsDirectory: () async => sourceDocs,
            getTemporaryDirectory: () async => tempDir,
          );
          final zipPath = await service.createBackup({
            'tanks': [
              {'id': 'tank-1', 'name': 'Main tank'},
            ],
            childCollection: [
              {'tankId': 'tank-1'},
            ],
          });

          await expectLater(
            service.getBackupData(zipPath),
            throwsA(
              isA<Exception>().having(
                (error) => error.toString(),
                'message',
                contains(
                  'Invalid format: $childCollection entries must include an id',
                ),
              ),
            ),
          );
        },
      );

      test('getBackupData rejects duplicate $childCollection ids', () async {
        final service = BackupService(
          getDocumentsDirectory: () async => sourceDocs,
          getTemporaryDirectory: () async => tempDir,
        );
        final zipPath = await service.createBackup({
          'tanks': [
            {'id': 'tank-1', 'name': 'Main tank'},
          ],
          childCollection: [
            _validChildEntry(childCollection, '$childCollection-1'),
            _validChildEntry(childCollection, '$childCollection-1'),
          ],
        });

        await expectLater(
          service.getBackupData(zipPath),
          throwsA(
            isA<Exception>().having(
              (error) => error.toString(),
              'message',
              contains('Invalid format: duplicate $childCollection id'),
            ),
          ),
        );
      });
    }

    for (final scenario in const [
      (
        collection: 'logs',
        missingField: 'timestamp',
        entry: {'id': 'log-1', 'tankId': 'tank-1'},
      ),
      (
        collection: 'livestock',
        missingField: 'commonName',
        entry: {'id': 'livestock-1', 'tankId': 'tank-1'},
      ),
      (
        collection: 'livestock',
        missingField: 'dateAdded',
        entry: {
          'id': 'livestock-1',
          'tankId': 'tank-1',
          'commonName': 'Neon tetra',
        },
      ),
      (
        collection: 'equipment',
        missingField: 'name',
        entry: {'id': 'equipment-1', 'tankId': 'tank-1'},
      ),
      (
        collection: 'tasks',
        missingField: 'title',
        entry: {'id': 'task-1', 'tankId': 'tank-1'},
      ),
    ]) {
      test(
        'getBackupData rejects ${scenario.collection} entries without ${scenario.missingField}',
        () async {
          final service = BackupService(
            getDocumentsDirectory: () async => sourceDocs,
            getTemporaryDirectory: () async => tempDir,
          );
          final zipPath = await service.createBackup({
            'tanks': [
              {'id': 'tank-1', 'name': 'Main tank'},
            ],
            scenario.collection: [scenario.entry],
          });

          await expectLater(
            service.getBackupData(zipPath),
            throwsA(
              isA<Exception>().having(
                (error) => error.toString(),
                'message',
                contains(
                  'Invalid format: ${scenario.collection} entries must include ${scenario.missingField}',
                ),
              ),
            ),
          );
        },
      );
    }

    for (final scenario in [
      (
        field: 'waterTest',
        entry: {..._validChildEntry('logs', 'log-1'), 'waterTest': 'unsafe'},
        message: 'Invalid format: logs waterTest values must be objects',
      ),
      (
        field: 'photoUrls',
        entry: {
          ..._validChildEntry('logs', 'log-1'),
          'photoUrls': ['photos/fish.jpg', 42],
        },
        message:
            'Invalid format: logs photoUrls values must be arrays of strings',
      ),
    ]) {
      test(
        'getBackupData rejects log entries with invalid ${scenario.field}',
        () async {
          final service = BackupService(
            getDocumentsDirectory: () async => sourceDocs,
            getTemporaryDirectory: () async => tempDir,
          );
          final zipPath = await service.createBackup({
            'tanks': [
              {'id': 'tank-1', 'name': 'Main tank'},
            ],
            'logs': [scenario.entry],
          });

          await expectLater(
            service.getBackupData(zipPath),
            throwsA(
              isA<Exception>().having(
                (error) => error.toString(),
                'message',
                contains(scenario.message),
              ),
            ),
          );
        },
      );
    }
  });
}

Map<String, String> _validChildEntry(String collectionName, String id) {
  final base = {'id': id, 'tankId': 'tank-1'};
  return switch (collectionName) {
    'logs' => {...base, 'timestamp': '2026-06-14T09:00:00.000'},
    'livestock' => {
      ...base,
      'commonName': 'Neon tetra',
      'dateAdded': '2026-06-14T09:00:00.000',
    },
    'equipment' => {...base, 'name': 'Filter'},
    'tasks' => {...base, 'title': 'Test water'},
    _ => base,
  };
}
