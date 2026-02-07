import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:aquarium_app/services/backup_service.dart';

void main() {
  group('BackupService photo ZIP backups', () {
    test('createBackup stores portable photo refs and includes photo bytes', () async {
      final root = await Directory.systemTemp.createTemp('aquarium_backup_test_');
      addTearDown(() async {
        try {
          await root.delete(recursive: true);
        } catch (_) {
          // ignore
        }
      });

      final docs = Directory(p.join(root.path, 'docs'));
      final temp = Directory(p.join(root.path, 'temp'));
      await docs.create(recursive: true);
      await temp.create(recursive: true);

      final photosDir = Directory(p.join(docs.path, 'photos'));
      await photosDir.create(recursive: true);

      final photoFile = File(p.join(photosDir.path, 'abc.jpg'));
      await photoFile.writeAsBytes([1, 2, 3, 4]);

      final service = BackupService(
        getDocumentsDirectory: () async => docs,
        getTemporaryDirectory: () async => temp,
      );

      final zipPath = await service.createBackup({
        'version': 2,
        'tanks': <dynamic>[],
        'logs': [
          {
            'id': 'log1',
            'photoUrls': [photoFile.path],
          },
        ],
      });

      final zipBytes = await File(zipPath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(zipBytes);

      final jsonFile = archive.findFile('backup.json');
      expect(jsonFile, isNotNull);

      final jsonMap = jsonDecode(utf8.decode(jsonFile!.content as List<int>)) as Map<String, dynamic>;
      final firstPhotoRef = (jsonMap['logs'] as List).first['photoUrls'][0] as String;

      // Portable reference stored in backup.json.
      expect(firstPhotoRef, 'photos/abc.jpg');

      // Photo bytes included in the ZIP.
      final zippedPhoto = archive.findFile('photos/abc.jpg');
      expect(zippedPhoto, isNotNull);
      expect(zippedPhoto!.content as List<int>, [1, 2, 3, 4]);
    });

    test('getBackupData resolves portable photo refs to current docs/photos paths', () async {
      final root = await Directory.systemTemp.createTemp('aquarium_backup_test_');
      addTearDown(() async {
        try {
          await root.delete(recursive: true);
        } catch (_) {
          // ignore
        }
      });

      final docs = Directory(p.join(root.path, 'docs'));
      final temp = Directory(p.join(root.path, 'temp'));
      await docs.create(recursive: true);
      await temp.create(recursive: true);

      // Build a minimal ZIP with a portable photo ref.
      final archive = Archive();
      final backupJson = jsonEncode({
        'version': 2,
        'tanks': <dynamic>[],
        'logs': [
          {
            'id': 'log1',
            'photoUrls': ['photos/abc.jpg'],
          },
        ],
      });
      archive.addFile(ArchiveFile('backup.json', backupJson.length, utf8.encode(backupJson)));
      archive.addFile(ArchiveFile('photos/abc.jpg', 4, [1, 2, 3, 4]));

      final zipBytes = ZipEncoder().encode(archive);
      expect(zipBytes, isNotNull);

      final zipFile = File(p.join(temp.path, 'in.zip'));
      await zipFile.writeAsBytes(zipBytes!);

      final service = BackupService(
        getDocumentsDirectory: () async => docs,
        getTemporaryDirectory: () async => temp,
      );

      final data = await service.getBackupData(zipFile.path);
      final resolved = ((data['logs'] as List).first['photoUrls'] as List).first as String;

      expect(resolved, p.join(docs.path, 'photos', 'abc.jpg'));
    });

    test('restoreBackup extracts photos into current docs/photos directory', () async {
      final root = await Directory.systemTemp.createTemp('aquarium_backup_test_');
      addTearDown(() async {
        try {
          await root.delete(recursive: true);
        } catch (_) {
          // ignore
        }
      });

      final docs = Directory(p.join(root.path, 'docs'));
      final temp = Directory(p.join(root.path, 'temp'));
      await docs.create(recursive: true);
      await temp.create(recursive: true);

      final archive = Archive();
      final backupJson = jsonEncode({
        'version': 2,
        'tanks': <dynamic>[],
      });
      archive.addFile(ArchiveFile('backup.json', backupJson.length, utf8.encode(backupJson)));
      archive.addFile(ArchiveFile('photos/abc.jpg', 4, [1, 2, 3, 4]));

      final zipBytes = ZipEncoder().encode(archive);
      expect(zipBytes, isNotNull);

      final zipFile = File(p.join(temp.path, 'in.zip'));
      await zipFile.writeAsBytes(zipBytes!);

      final service = BackupService(
        getDocumentsDirectory: () async => docs,
        getTemporaryDirectory: () async => temp,
      );

      final tankCount = await service.restoreBackup(zipFile.path);
      expect(tankCount, 0);

      final restoredPhoto = File(p.join(docs.path, 'photos', 'abc.jpg'));
      expect(await restoredPhoto.exists(), isTrue);
      expect(await restoredPhoto.readAsBytes(), [1, 2, 3, 4]);
    });
  });
}
