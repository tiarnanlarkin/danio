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
  });
}
