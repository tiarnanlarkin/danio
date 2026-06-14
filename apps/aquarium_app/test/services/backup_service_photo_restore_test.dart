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

    test('createBackup rejects missing referenced photo files', () async {
      final missingPhoto = File(p.join(sourceDocs.path, 'photos', 'gone.jpg'));
      final service = BackupService(
        getDocumentsDirectory: () async => sourceDocs,
        getTemporaryDirectory: () async => tempDir,
      );

      await expectLater(
        service.createBackup({
          'tanks': [
            {'id': 'tank-1', 'imageUrl': missingPhoto.path},
          ],
        }),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains(
              'Cannot create backup: referenced photo "gone.jpg" was not found',
            ),
          ),
        ),
      );
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

    for (final scenario in [
      (
        field: 'tank imageUrl',
        data: {
          'tanks': [
            {'id': 'tank-1', 'imageUrl': 'photos/missing-tank.jpg'},
          ],
        },
        message:
            'Invalid backup: referenced photo "missing-tank.jpg" is missing from archive',
      ),
      (
        field: 'log photoUrls',
        data: {
          'tanks': [
            {'id': 'tank-1', 'name': 'Main tank'},
          ],
          'logs': [
            {
              ..._validChildEntry('logs', 'log-1'),
              'photoUrls': ['photos/missing-log.jpg'],
            },
          ],
        },
        message:
            'Invalid backup: referenced photo "missing-log.jpg" is missing from archive',
      ),
    ]) {
      test(
        'getBackupData rejects ${scenario.field} refs without archive files',
        () async {
          final zipPath = p.join(
            tempDir.path,
            '${scenario.field.replaceAll(' ', '_')}_missing_photo.zip',
          );
          await _writeBackupZip(zipPath, data: scenario.data);

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
                contains(scenario.message),
              ),
            ),
          );
        },
      );
    }

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

    test('getBackupData rejects tank entries updated before creation', () async {
      final service = BackupService(
        getDocumentsDirectory: () async => sourceDocs,
        getTemporaryDirectory: () async => tempDir,
      );
      final zipPath = await service.createBackup({
        'tanks': [
          {
            'id': 'tank-1',
            'name': 'Main tank',
            'createdAt': '2026-06-14T09:00:00.000',
            'updatedAt': '2026-06-13T09:00:00.000',
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
              'Invalid format: tank updatedAt values must be on or after createdAt',
            ),
          ),
        ),
      );
    });

    for (final scenario in [
      (
        field: 'root',
        sharedPreferences: 'not-preferences',
        message: 'Invalid format: sharedPreferences must be an object',
      ),
      (
        field: 'entries',
        sharedPreferences: {'entries': 'not-entries'},
        message: 'Invalid format: sharedPreferences entries must be an object',
      ),
    ]) {
      test(
        'getBackupData rejects invalid sharedPreferences ${scenario.field} data',
        () async {
          final service = BackupService(
            getDocumentsDirectory: () async => sourceDocs,
            getTemporaryDirectory: () async => tempDir,
          );
          final zipPath = await service.createBackup({
            'tanks': [
              {'id': 'tank-1', 'name': 'Main tank'},
            ],
            'sharedPreferences': scenario.sharedPreferences,
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

    for (final scenario in [
      (
        field: 'object',
        sharedPreferences: {
          'entries': {
            'theme_mode': {'mode': 1},
          },
        },
        message:
            'Invalid format: sharedPreferences entry values must be strings, numbers, booleans, or string arrays',
      ),
      (
        field: 'mixed list',
        sharedPreferences: {
          'entries': {
            'aquarium_reminders': ['morning', 9],
          },
        },
        message:
            'Invalid format: sharedPreferences string-list values must contain only strings',
      ),
    ]) {
      test(
        'getBackupData rejects invalid sharedPreferences ${scenario.field} entry values',
        () async {
          final service = BackupService(
            getDocumentsDirectory: () async => sourceDocs,
            getTemporaryDirectory: () async => tempDir,
          );
          final zipPath = await service.createBackup({
            'tanks': [
              {'id': 'tank-1', 'name': 'Main tank'},
            ],
            'sharedPreferences': scenario.sharedPreferences,
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
      'getBackupData ignores malformed non-exportable sharedPreferences values',
      () async {
        final service = BackupService(
          getDocumentsDirectory: () async => sourceDocs,
          getTemporaryDirectory: () async => tempDir,
        );
        final zipPath = await service.createBackup({
          'tanks': [
            {'id': 'tank-1', 'name': 'Main tank'},
          ],
          'sharedPreferences': {
            'entries': {
              'theme_mode': 1,
              'user_openai_api_key': {'ignored': true},
              'flutter.internal': ['ignored', 9],
            },
          },
        });

        final data = await service.getBackupData(zipPath);

        final prefs = data['sharedPreferences'] as Map<String, dynamic>;
        final entries = prefs['entries'] as Map<String, dynamic>;
        expect(entries['theme_mode'], 1);
        expect(entries['user_openai_api_key'], {'ignored': true});
        expect(entries['flutter.internal'], ['ignored', 9]);
      },
    );

    for (final scenario in [
      (
        field: 'name',
        tank: {'id': 'tank-1', 'name': 42},
        message: 'Invalid format: tank name values must be strings',
      ),
      (
        field: 'type',
        tank: {'id': 'tank-1', 'type': 'brackish'},
        message: 'Invalid format: tank type values must be known values',
      ),
      (
        field: 'volumeLitres',
        tank: {'id': 'tank-1', 'volumeLitres': 'large'},
        message: 'Invalid format: tank volumeLitres values must be numbers',
      ),
      (
        field: 'sortOrder',
        tank: {'id': 'tank-1', 'sortOrder': 1.5},
        message: 'Invalid format: tank sortOrder values must be whole numbers',
      ),
      (
        field: 'isDemoTank',
        tank: {'id': 'tank-1', 'isDemoTank': 'yes'},
        message: 'Invalid format: tank isDemoTank values must be booleans',
      ),
      (
        field: 'startDate',
        tank: {'id': 'tank-1', 'startDate': 'not-date'},
        message: 'Invalid format: tank startDate values must be valid dates',
      ),
      (
        field: 'targets',
        tank: {'id': 'tank-1', 'targets': 'soft'},
        message: 'Invalid format: tank targets values must be objects',
      ),
      (
        field: 'targets.tempMin',
        tank: {
          'id': 'tank-1',
          'targets': {'tempMin': 'warm'},
        },
        message: 'Invalid format: tank targets tempMin values must be numbers',
      ),
    ]) {
      test(
        'getBackupData rejects tank entries with invalid ${scenario.field}',
        () async {
          final service = BackupService(
            getDocumentsDirectory: () async => sourceDocs,
            getTemporaryDirectory: () async => tempDir,
          );
          final zipPath = await service.createBackup({
            'tanks': [scenario.tank],
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

    for (final scenario in [
      (
        field: 'volumeLitres',
        tank: {'id': 'tank-1', 'name': 'Main tank', 'volumeLitres': 0},
        message:
            'Invalid format: tank volumeLitres values must be between 1 and 10000',
      ),
      (
        field: 'lengthCm',
        tank: {'id': 'tank-1', 'name': 'Main tank', 'lengthCm': -10},
        message: 'Invalid format: tank lengthCm values must be zero or greater',
      ),
      (
        field: 'targets.tempMin',
        tank: {
          'id': 'tank-1',
          'name': 'Main tank',
          'targets': {'tempMin': -1},
        },
        message:
            'Invalid format: tank targets tempMin values must be zero or greater',
      ),
      (
        field: 'targets.phMax',
        tank: {
          'id': 'tank-1',
          'name': 'Main tank',
          'targets': {'phMax': 15},
        },
        message:
            'Invalid format: tank targets phMax values must be between 0 and 14',
      ),
    ]) {
      test(
        'getBackupData rejects tank entries with out-of-range ${scenario.field}',
        () async {
          final service = BackupService(
            getDocumentsDirectory: () async => sourceDocs,
            getTemporaryDirectory: () async => tempDir,
          );
          final zipPath = await service.createBackup({
            'tanks': [scenario.tank],
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

    for (final scenario in [
      (
        field: 'temperature',
        targets: {'tempMin': 28, 'tempMax': 24},
        message:
            'Invalid format: tank targets tempMin values must be less than or equal to tempMax',
      ),
      (
        field: 'pH',
        targets: {'phMin': 8, 'phMax': 6.5},
        message:
            'Invalid format: tank targets phMin values must be less than or equal to phMax',
      ),
      (
        field: 'GH',
        targets: {'ghMin': 12, 'ghMax': 4},
        message:
            'Invalid format: tank targets ghMin values must be less than or equal to ghMax',
      ),
      (
        field: 'KH',
        targets: {'khMin': 8, 'khMax': 3},
        message:
            'Invalid format: tank targets khMin values must be less than or equal to khMax',
      ),
    ]) {
      test(
        'getBackupData rejects tank entries with inverted ${scenario.field} target ranges',
        () async {
          final service = BackupService(
            getDocumentsDirectory: () async => sourceDocs,
            getTemporaryDirectory: () async => tempDir,
          );
          final zipPath = await service.createBackup({
            'tanks': [
              {
                'id': 'tank-1',
                'name': 'Main tank',
                'targets': scenario.targets,
              },
            ],
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
        collection: 'livestock',
        missingField: 'count',
        entry: {
          'id': 'livestock-1',
          'tankId': 'tank-1',
          'commonName': 'Neon tetra',
          'dateAdded': '2026-06-14T09:00:00.000',
          'createdAt': '2026-06-14T09:00:00.000',
          'updatedAt': '2026-06-14T09:00:00.000',
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

    for (final scenario in const [
      (
        collection: 'logs',
        missingField: 'createdAt',
        entry: {
          'id': 'log-1',
          'tankId': 'tank-1',
          'timestamp': '2026-06-14T09:00:00.000',
        },
      ),
      (
        collection: 'livestock',
        missingField: 'createdAt',
        entry: {
          'id': 'livestock-1',
          'tankId': 'tank-1',
          'commonName': 'Neon tetra',
          'dateAdded': '2026-06-14T09:00:00.000',
          'updatedAt': '2026-06-14T09:00:00.000',
        },
      ),
      (
        collection: 'livestock',
        missingField: 'updatedAt',
        entry: {
          'id': 'livestock-1',
          'tankId': 'tank-1',
          'commonName': 'Neon tetra',
          'dateAdded': '2026-06-14T09:00:00.000',
          'createdAt': '2026-06-14T09:00:00.000',
        },
      ),
      (
        collection: 'equipment',
        missingField: 'createdAt',
        entry: {
          'id': 'equipment-1',
          'tankId': 'tank-1',
          'name': 'Filter',
          'updatedAt': '2026-06-14T09:00:00.000',
        },
      ),
      (
        collection: 'equipment',
        missingField: 'updatedAt',
        entry: {
          'id': 'equipment-1',
          'tankId': 'tank-1',
          'name': 'Filter',
          'createdAt': '2026-06-14T09:00:00.000',
        },
      ),
      (
        collection: 'tasks',
        missingField: 'createdAt',
        entry: {
          'id': 'task-1',
          'tankId': 'tank-1',
          'title': 'Test water',
          'updatedAt': '2026-06-14T09:00:00.000',
        },
      ),
      (
        collection: 'tasks',
        missingField: 'updatedAt',
        entry: {
          'id': 'task-1',
          'tankId': 'tank-1',
          'title': 'Test water',
          'createdAt': '2026-06-14T09:00:00.000',
        },
      ),
    ]) {
      test(
        'getBackupData rejects ${scenario.collection} entries without required ${scenario.missingField} metadata',
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
        collection: 'livestock',
        entry: {
          ..._validChildEntry('livestock', 'livestock-1'),
          'createdAt': '2026-06-14T09:00:00.000',
          'updatedAt': '2026-06-13T09:00:00.000',
        },
      ),
      (
        collection: 'equipment',
        entry: {
          ..._validChildEntry('equipment', 'equipment-1'),
          'createdAt': '2026-06-14T09:00:00.000',
          'updatedAt': '2026-06-13T09:00:00.000',
        },
      ),
      (
        collection: 'tasks',
        entry: {
          ..._validChildEntry('tasks', 'task-1'),
          'createdAt': '2026-06-14T09:00:00.000',
          'updatedAt': '2026-06-13T09:00:00.000',
        },
      ),
    ]) {
      test(
        'getBackupData rejects ${scenario.collection} entries updated before creation',
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
                  'Invalid format: ${scenario.collection} updatedAt values must be on or after createdAt',
                ),
              ),
            ),
          );
        },
      );
    }

    for (final scenario in const [
      (
        collection: 'logs',
        missingField: 'type',
        entry: {
          'id': 'log-1',
          'tankId': 'tank-1',
          'timestamp': '2026-06-14T09:00:00.000',
          'createdAt': '2026-06-14T09:00:00.000',
        },
      ),
      (
        collection: 'equipment',
        missingField: 'type',
        entry: {
          'id': 'equipment-1',
          'tankId': 'tank-1',
          'name': 'Filter',
          'createdAt': '2026-06-14T09:00:00.000',
          'updatedAt': '2026-06-14T09:00:00.000',
        },
      ),
      (
        collection: 'tasks',
        missingField: 'recurrence',
        entry: {
          'id': 'task-1',
          'tankId': 'tank-1',
          'title': 'Test water',
          'createdAt': '2026-06-14T09:00:00.000',
          'updatedAt': '2026-06-14T09:00:00.000',
        },
      ),
    ]) {
      test(
        'getBackupData rejects ${scenario.collection} entries without required ${scenario.missingField} enum data',
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
          if (scenario.field == 'photoUrls') {
            final sourcePhotos = Directory(p.join(sourceDocs.path, 'photos'));
            await sourcePhotos.create(recursive: true);
            await File(
              p.join(sourcePhotos.path, 'fish.jpg'),
            ).writeAsBytes([1, 2, 3]);
          }
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
      'getBackupData rejects equipment settings that are not objects',
      () async {
        final service = BackupService(
          getDocumentsDirectory: () async => sourceDocs,
          getTemporaryDirectory: () async => tempDir,
        );
        final zipPath = await service.createBackup({
          'tanks': [
            {'id': 'tank-1', 'name': 'Main tank'},
          ],
          'equipment': [
            {
              ..._validChildEntry('equipment', 'equipment-1'),
              'settings': 'warm',
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
                'Invalid format: equipment settings values must be objects',
              ),
            ),
          ),
        );
      },
    );

    for (final scenario in [
      (
        collection: 'logs',
        field: 'title',
        entry: {..._validChildEntry('logs', 'log-1'), 'title': 42},
      ),
      (
        collection: 'livestock',
        field: 'scientificName',
        entry: {
          ..._validChildEntry('livestock', 'livestock-1'),
          'scientificName': 42,
        },
      ),
      (
        collection: 'equipment',
        field: 'brand',
        entry: {..._validChildEntry('equipment', 'equipment-1'), 'brand': 42},
      ),
      (
        collection: 'tasks',
        field: 'description',
        entry: {..._validChildEntry('tasks', 'task-1'), 'description': 42},
      ),
    ]) {
      test(
        'getBackupData rejects ${scenario.collection} entries with invalid optional ${scenario.field} strings',
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
                  'Invalid format: ${scenario.collection} ${scenario.field} values must be strings',
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
        field: 'relatedEquipmentId',
        data: {
          'tanks': [
            {'id': 'tank-1', 'name': 'Main tank'},
          ],
          'logs': [
            {
              ..._validChildEntry('logs', 'log-1'),
              'relatedEquipmentId': 'missing-equipment',
            },
          ],
        },
      ),
      (
        collection: 'logs',
        field: 'relatedLivestockId',
        data: {
          'tanks': [
            {'id': 'tank-1', 'name': 'Main tank'},
          ],
          'logs': [
            {
              ..._validChildEntry('logs', 'log-1'),
              'relatedLivestockId': 'missing-livestock',
            },
          ],
        },
      ),
      (
        collection: 'logs',
        field: 'relatedTaskId',
        data: {
          'tanks': [
            {'id': 'tank-1', 'name': 'Main tank'},
          ],
          'logs': [
            {
              ..._validChildEntry('logs', 'log-1'),
              'relatedTaskId': 'missing-task',
            },
          ],
        },
      ),
      (
        collection: 'tasks',
        field: 'relatedEquipmentId',
        data: {
          'tanks': [
            {'id': 'tank-1', 'name': 'Main tank'},
          ],
          'tasks': [
            {
              ..._validChildEntry('tasks', 'task-1'),
              'relatedEquipmentId': 'missing-equipment',
            },
          ],
        },
      ),
    ]) {
      test(
        'getBackupData rejects ${scenario.collection} entries with missing ${scenario.field} targets',
        () async {
          final service = BackupService(
            getDocumentsDirectory: () async => sourceDocs,
            getTemporaryDirectory: () async => tempDir,
          );
          final zipPath = await service.createBackup(scenario.data);

          await expectLater(
            service.getBackupData(zipPath),
            throwsA(
              isA<Exception>().having(
                (error) => error.toString(),
                'message',
                contains(
                  'Invalid format: ${scenario.collection} ${scenario.field} values must reference existing backup records',
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
        field: 'relatedEquipmentId',
        source: {
          ..._validChildEntry('logs', 'log-1'),
          'relatedEquipmentId': 'equipment-other-tank',
        },
        targetCollection: 'equipment',
        target: {
          ..._validChildEntry('equipment', 'equipment-other-tank'),
          'tankId': 'tank-2',
        },
      ),
      (
        collection: 'logs',
        field: 'relatedLivestockId',
        source: {
          ..._validChildEntry('logs', 'log-1'),
          'relatedLivestockId': 'livestock-other-tank',
        },
        targetCollection: 'livestock',
        target: {
          ..._validChildEntry('livestock', 'livestock-other-tank'),
          'tankId': 'tank-2',
        },
      ),
      (
        collection: 'logs',
        field: 'relatedTaskId',
        source: {
          ..._validChildEntry('logs', 'log-1'),
          'relatedTaskId': 'task-other-tank',
        },
        targetCollection: 'tasks',
        target: {
          ..._validChildEntry('tasks', 'task-other-tank'),
          'tankId': 'tank-2',
        },
      ),
      (
        collection: 'tasks',
        field: 'relatedEquipmentId',
        source: {
          ..._validChildEntry('tasks', 'task-1'),
          'relatedEquipmentId': 'equipment-other-tank',
        },
        targetCollection: 'equipment',
        target: {
          ..._validChildEntry('equipment', 'equipment-other-tank'),
          'tankId': 'tank-2',
        },
      ),
    ]) {
      test(
        'getBackupData rejects ${scenario.collection} entries with cross-tank ${scenario.field} targets',
        () async {
          final service = BackupService(
            getDocumentsDirectory: () async => sourceDocs,
            getTemporaryDirectory: () async => tempDir,
          );
          final zipPath = await service.createBackup({
            'tanks': [
              {'id': 'tank-1', 'name': 'Main tank'},
              {'id': 'tank-2', 'name': 'Other tank'},
            ],
            scenario.collection: [scenario.source],
            scenario.targetCollection: [scenario.target],
          });

          await expectLater(
            service.getBackupData(zipPath),
            throwsA(
              isA<Exception>().having(
                (error) => error.toString(),
                'message',
                contains(
                  'Invalid format: ${scenario.collection} ${scenario.field} values must reference records in the same backup tank',
                ),
              ),
            ),
          );
        },
      );
    }

    for (final scenario in [
      (
        field: 'isEnabled',
        entry: {..._validChildEntry('tasks', 'task-1'), 'isEnabled': 'yes'},
      ),
      (
        field: 'isAutoGenerated',
        entry: {..._validChildEntry('tasks', 'task-1'), 'isAutoGenerated': 1},
      ),
    ]) {
      test(
        'getBackupData rejects tasks entries with invalid optional ${scenario.field} booleans',
        () async {
          final service = BackupService(
            getDocumentsDirectory: () async => sourceDocs,
            getTemporaryDirectory: () async => tempDir,
          );
          final zipPath = await service.createBackup({
            'tanks': [
              {'id': 'tank-1', 'name': 'Main tank'},
            ],
            'tasks': [scenario.entry],
          });

          await expectLater(
            service.getBackupData(zipPath),
            throwsA(
              isA<Exception>().having(
                (error) => error.toString(),
                'message',
                contains(
                  'Invalid format: tasks ${scenario.field} values must be booleans',
                ),
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
        field: 'temperature',
        value: 99,
        message:
            'Invalid format: logs waterTest temperature values must be between 0 and 50',
      ),
      (
        field: 'ph',
        value: 15,
        message:
            'Invalid format: logs waterTest ph values must be between 0 and 14',
      ),
      (
        field: 'ammonia',
        value: -0.25,
        message:
            'Invalid format: logs waterTest ammonia values must be zero or greater',
      ),
    ]) {
      test(
        'getBackupData rejects out-of-range log waterTest ${scenario.field} readings',
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
                'waterTest': {scenario.field: scenario.value},
              },
            ],
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
        field: 'type',
        entry: {..._validChildEntry('logs', 'log-1'), 'type': 'mystery'},
      ),
      (
        collection: 'livestock',
        field: 'temperament',
        entry: {
          ..._validChildEntry('livestock', 'livestock-1'),
          'temperament': 'spiky',
        },
      ),
      (
        collection: 'livestock',
        field: 'healthStatus',
        entry: {
          ..._validChildEntry('livestock', 'livestock-1'),
          'healthStatus': 'missing',
        },
      ),
      (
        collection: 'equipment',
        field: 'type',
        entry: {
          ..._validChildEntry('equipment', 'equipment-1'),
          'type': 'reactor',
        },
      ),
      (
        collection: 'tasks',
        field: 'recurrence',
        entry: {..._validChildEntry('tasks', 'task-1'), 'recurrence': 'often'},
      ),
      (
        collection: 'tasks',
        field: 'priority',
        entry: {..._validChildEntry('tasks', 'task-1'), 'priority': 'urgent'},
      ),
    ]) {
      test(
        'getBackupData rejects ${scenario.collection} entries with invalid ${scenario.field} enum values',
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
                  'Invalid format: ${scenario.collection} ${scenario.field} values must be known values',
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

    for (final scenario in [
      (
        collection: 'logs',
        field: 'waterChangePercent',
        entry: {..._validChildEntry('logs', 'log-1'), 'waterChangePercent': 0},
        message:
            'Invalid format: logs waterChangePercent values must be between 1 and 100',
      ),
      (
        collection: 'logs',
        field: 'waterChangePercent',
        entry: {
          ..._validChildEntry('logs', 'log-1'),
          'waterChangePercent': 101,
        },
        message:
            'Invalid format: logs waterChangePercent values must be between 1 and 100',
      ),
      (
        collection: 'livestock',
        field: 'count',
        entry: {..._validChildEntry('livestock', 'livestock-1'), 'count': 0},
        message:
            'Invalid format: livestock count values must be between 1 and 9999',
      ),
      (
        collection: 'livestock',
        field: 'sizeCm',
        entry: {..._validChildEntry('livestock', 'livestock-1'), 'sizeCm': -1},
        message:
            'Invalid format: livestock sizeCm values must be zero or greater',
      ),
      (
        collection: 'equipment',
        field: 'maintenanceIntervalDays',
        entry: {
          ..._validChildEntry('equipment', 'equipment-1'),
          'maintenanceIntervalDays': -7,
        },
        message:
            'Invalid format: equipment maintenanceIntervalDays values must be zero or greater',
      ),
      (
        collection: 'tasks',
        field: 'completionCount',
        entry: {..._validChildEntry('tasks', 'task-1'), 'completionCount': -1},
        message:
            'Invalid format: tasks completionCount values must be zero or greater',
      ),
    ]) {
      test(
        'getBackupData rejects ${scenario.collection} entries with out-of-range ${scenario.field} values',
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
                contains(scenario.message),
              ),
            ),
          );
        },
      );
    }

    for (final scenario in [
      (
        label: 'missing interval',
        entry: {..._validChildEntry('tasks', 'task-1'), 'recurrence': 'custom'},
      ),
      (
        label: 'zero interval',
        entry: {
          ..._validChildEntry('tasks', 'task-1'),
          'recurrence': 'custom',
          'intervalDays': 0,
        },
      ),
    ]) {
      test(
        'getBackupData rejects custom task recurrence with ${scenario.label}',
        () async {
          final service = BackupService(
            getDocumentsDirectory: () async => sourceDocs,
            getTemporaryDirectory: () async => tempDir,
          );
          final zipPath = await service.createBackup({
            'tanks': [
              {'id': 'tank-1', 'name': 'Main tank'},
            ],
            'tasks': [scenario.entry],
          });

          await expectLater(
            service.getBackupData(zipPath),
            throwsA(
              isA<Exception>().having(
                (error) => error.toString(),
                'message',
                contains(
                  'Invalid format: tasks custom recurrence entries must include positive intervalDays',
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

Map<String, dynamic> _validChildEntry(String collectionName, String id) {
  const timestamp = '2026-06-14T09:00:00.000';
  final base = {'id': id, 'tankId': 'tank-1', 'createdAt': timestamp};
  return switch (collectionName) {
    'logs' => {...base, 'type': 'observation', 'timestamp': timestamp},
    'livestock' => {
      ...base,
      'commonName': 'Neon tetra',
      'count': 6,
      'dateAdded': timestamp,
      'updatedAt': timestamp,
    },
    'equipment' => {
      ...base,
      'type': 'filter',
      'name': 'Filter',
      'updatedAt': timestamp,
    },
    'tasks' => {
      ...base,
      'title': 'Test water',
      'recurrence': 'none',
      'updatedAt': timestamp,
    },
    _ => base,
  };
}
