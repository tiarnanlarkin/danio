import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
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

    test(
      'restoreBackup restores Windows-style photo archive entries',
      () async {
        final zipPath = p.join(tempDir.path, 'windows_photo_backup.zip');
        await _writeBackupZip(
          zipPath,
          data: {
            'tanks': [
              {'id': 'tank-1', 'imageUrl': r'photos\fish.jpg'},
            ],
          },
          files: {r'photos\fish.jpg': 'backup photo'},
        );

        final restoreService = BackupService(
          getDocumentsDirectory: () async => restoreDocs,
          getTemporaryDirectory: () async => tempDir,
        );

        final resolvedData = await restoreService.getBackupData(zipPath);
        final resolvedPhotoPath =
            (resolvedData['tanks'] as List).first['imageUrl'] as String;

        await restoreService.restoreBackup(zipPath);

        expect(await File(resolvedPhotoPath).readAsString(), 'backup photo');
      },
    );

    test(
      'getBackupData rejects photo entries with duplicate restored filenames',
      () async {
        final zipPath = p.join(tempDir.path, 'duplicate_photo_backup.zip');
        await _writeBackupZip(
          zipPath,
          data: {
            'tanks': [
              {'id': 'tank-1', 'imageUrl': 'photos/left/fish.jpg'},
              {'id': 'tank-2', 'imageUrl': 'photos/right/fish.jpg'},
            ],
          },
          files: {
            'photos/left/fish.jpg': 'left photo',
            'photos/right/fish.jpg': 'right photo',
          },
        );

        final restoreService = BackupService(
          getDocumentsDirectory: () async => restoreDocs,
          getTemporaryDirectory: () async => tempDir,
        );

        await expectLater(
          restoreService.getBackupData(zipPath),
          throwsA(
            isA<Exception>().having(
              (error) => error.toString(),
              'message',
              contains('Invalid backup: duplicate photo filename "fish.jpg"'),
            ),
          ),
        );
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

    test(
      'getBackupData rejects log waterTest readings that are not numbers',
      () async {
        final service = BackupService(
          getDocumentsDirectory: () async => sourceDocs,
          getTemporaryDirectory: () async => tempDir,
        );
        final zipPath = await service.createBackup({
          'tanks': [
            {'id': 'tank-1', 'name': 'Main tank'},
          ],
          'logs': [
            {
              ..._validChildEntry('logs', 'log-1'),
              'waterTest': {'ammonia': 'high'},
            },
          ],
        });

        await expectLater(
          service.getBackupData(zipPath),
          throwsA(
            isA<Exception>().having(
              (error) => error.toString(),
              'message',
              contains(
                'Invalid format: logs waterTest ammonia values must be numbers',
              ),
            ),
          ),
        );
      },
    );

    for (final scenario in [
      (
        collection: 'logs',
        field: 'timestamp',
        entry: {..._validChildEntry('logs', 'log-1'), 'timestamp': 'not-date'},
      ),
      (
        collection: 'livestock',
        field: 'dateAdded',
        entry: {
          ..._validChildEntry('livestock', 'livestock-1'),
          'dateAdded': 'not-date',
        },
      ),
    ]) {
      test(
        'getBackupData rejects ${scenario.collection} entries with invalid ${scenario.field} dates',
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
                  'Invalid format: ${scenario.collection} ${scenario.field} values must be valid dates',
                ),
              ),
            ),
          );
        },
      );
    }

    for (final scenario in [
      (
        collection: 'equipment',
        field: 'lastServiced',
        entry: {
          ..._validChildEntry('equipment', 'equipment-1'),
          'lastServiced': 'not-date',
        },
      ),
      (
        collection: 'equipment',
        field: 'installedDate',
        entry: {
          ..._validChildEntry('equipment', 'equipment-1'),
          'installedDate': 'not-date',
        },
      ),
      (
        collection: 'equipment',
        field: 'purchaseDate',
        entry: {
          ..._validChildEntry('equipment', 'equipment-1'),
          'purchaseDate': 'not-date',
        },
      ),
      (
        collection: 'tasks',
        field: 'dueDate',
        entry: {..._validChildEntry('tasks', 'task-1'), 'dueDate': 'not-date'},
      ),
      (
        collection: 'tasks',
        field: 'lastCompletedAt',
        entry: {
          ..._validChildEntry('tasks', 'task-1'),
          'lastCompletedAt': 'not-date',
        },
      ),
    ]) {
      test(
        'getBackupData rejects ${scenario.collection} entries with invalid optional ${scenario.field} dates',
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
                  'Invalid format: ${scenario.collection} ${scenario.field} values must be valid dates',
                ),
              ),
            ),
          );
        },
      );
    }

    for (final scenario in [
      (
        collection: 'logs',
        field: 'waterChangePercent',
        entry: {
          ..._validChildEntry('logs', 'log-1'),
          'waterChangePercent': 'half',
        },
      ),
      (
        collection: 'livestock',
        field: 'count',
        entry: {
          ..._validChildEntry('livestock', 'livestock-1'),
          'count': 'many',
        },
      ),
      (
        collection: 'equipment',
        field: 'maintenanceIntervalDays',
        entry: {
          ..._validChildEntry('equipment', 'equipment-1'),
          'maintenanceIntervalDays': 'weekly',
        },
      ),
      (
        collection: 'tasks',
        field: 'intervalDays',
        entry: {
          ..._validChildEntry('tasks', 'task-1'),
          'intervalDays': 'weekly',
        },
      ),
    ]) {
      test(
        'getBackupData rejects ${scenario.collection} entries with invalid ${scenario.field} numbers',
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
                  'Invalid format: ${scenario.collection} ${scenario.field} values must be numbers',
                ),
              ),
            ),
          );
        },
      );
    }

    for (final scenario in [
      (
        collection: 'logs',
        field: 'waterChangePercent',
        entry: {
          ..._validChildEntry('logs', 'log-1'),
          'waterChangePercent': 12.5,
        },
      ),
      (
        collection: 'livestock',
        field: 'count',
        entry: {..._validChildEntry('livestock', 'livestock-1'), 'count': 2.5},
      ),
      (
        collection: 'equipment',
        field: 'expectedLifespanMonths',
        entry: {
          ..._validChildEntry('equipment', 'equipment-1'),
          'expectedLifespanMonths': 24.5,
        },
      ),
      (
        collection: 'tasks',
        field: 'completionCount',
        entry: {..._validChildEntry('tasks', 'task-1'), 'completionCount': 1.5},
      ),
    ]) {
      test(
        'getBackupData rejects ${scenario.collection} entries with decimal ${scenario.field} integers',
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
                  'Invalid format: ${scenario.collection} ${scenario.field} values must be whole numbers',
                ),
              ),
            ),
          );
        },
      );
    }
  });
}

Future<void> _writeBackupZip(
  String zipPath, {
  required Map<String, dynamic> data,
  Map<String, String> files = const {},
}) async {
  final archive = Archive()
    ..addFile(
      ArchiveFile.string(
        'backup.json',
        const JsonEncoder.withIndent('  ').convert(data),
      ),
    );

  for (final entry in files.entries) {
    archive.addFile(ArchiveFile.string(entry.key, entry.value));
  }

  final zipBytes = ZipEncoder().encode(archive)!;
  await File(zipPath).writeAsBytes(zipBytes);
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
