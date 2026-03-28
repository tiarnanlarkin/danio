import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../utils/logger.dart';

/// Service for creating and restoring backups with photos bundled.
///
/// Backups are ZIP archives containing:
/// - backup.json: All app data
/// - photos/: All referenced photos
///
/// IMPORTANT: Photo paths inside `backup.json` are stored in a **portable**
/// format (`photos/<filename>`), not device-specific absolute paths.
///
/// When reading a backup via [getBackupData], photo refs are resolved back to
/// absolute paths in the *current* app documents directory.
class BackupService {
  static const String _jsonFileName = 'backup.json';
  static const String _photosFolder = 'photos';

  /// Holds progress information for export/import operations.
  final void Function(String status, double progress)? onProgress;

  /// Dependency injection points for testing.
  final Future<Directory> Function()? getDocumentsDirectoryOverride;
  final Future<Directory> Function()? getTemporaryDirectoryOverride;

  BackupService({
    this.onProgress,
    Future<Directory> Function()? getDocumentsDirectory,
    Future<Directory> Function()? getTemporaryDirectory,
  }) : getDocumentsDirectoryOverride = getDocumentsDirectory,
       getTemporaryDirectoryOverride = getTemporaryDirectory;

  /// Create a backup ZIP file from all app data.
  /// Returns the path to the created ZIP file.
  Future<String> createBackup(Map<String, dynamic> exportData) async {
    _updateProgress('Preparing backup...', 0.0);

    // 1) Make JSON portable by replacing absolute photo paths with
    //    `photos/<filename>` references.
    final portableExportData = _makePhotoRefsPortable(exportData);

    // 2) Collect all photo refs from the portable JSON.
    final allPhotoRefs = <String>{};
    _extractPhotoPaths(portableExportData, allPhotoRefs);

    _updateProgress('Collecting photos...', 0.1);

    // 3) Also scan the photos directory to ensure we bundle everything.
    final photosDir = await _getPhotosDirectory();
    if (await photosDir.exists()) {
      await for (final entity in photosDir.list()) {
        if (entity is File) {
          allPhotoRefs.add('$_photosFolder/${p.basename(entity.path)}');
        }
      }
    }

    _updateProgress('Creating archive...', 0.2);

    final jsonString = const JsonEncoder.withIndent(
      '  ',
    ).convert(portableExportData);

    final tempDir = await _getTemporaryDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')[0];

    final zipPath = p.join(tempDir.path, 'aquarium_backup_$timestamp.zip');
    final jsonTempPath = p.join(
      tempDir.path,
      'aquarium_backup_$timestamp.json',
    );
    final jsonTempFile = File(jsonTempPath);
    await jsonTempFile.writeAsString(jsonString);

    final encoder = ZipFileEncoder();
    encoder.create(zipPath, level: ZipFileEncoder.GZIP);

    try {
      // Add JSON as backup.json (streamed).
      await encoder.addFile(jsonTempFile, _jsonFileName);

      _updateProgress('Adding photos...', 0.3);

      final photosList = allPhotoRefs.toList()..sort();
      final total = photosList.length;

      if (total == 0) {
        _updateProgress('No photos to add', 0.8);
      } else {
        for (var i = 0; i < total; i++) {
          final photoRef = photosList[i];
          final file = await _resolvePhotoRefToLocalFile(photoRef);
          if (file != null && await file.exists()) {
            final filename = p.basename(file.path);
            await encoder.addFile(file, '$_photosFolder/$filename');
          }

          final progress = 0.3 + ((i + 1) / total * 0.5);
          _updateProgress('Adding photos... (${i + 1}/$total)', progress);
        }
      }

      _updateProgress('Finalizing backup...', 0.9);
      await encoder.close();

      _updateProgress('Backup complete!', 1.0);
      return zipPath;
    } finally {
      // Best-effort cleanup of temp JSON.
      try {
        if (await jsonTempFile.exists()) {
          await jsonTempFile.delete();
        }
      } catch (e) {
        logError('Error cleaning up temp file: $e', tag: 'BackupService');
      }
    }
  }

  /// Restore a backup from a ZIP file.
  ///
  /// This extracts photos into the app's documents `photos/` directory.
  /// The caller is expected to separately import the JSON data.
  ///
  /// Returns the number of tanks present in the backup (for UI messaging).
  Future<int> restoreBackup(String zipPath) async {
    _updateProgress('Reading backup...', 0.0);

    final zipFile = File(zipPath);
    if (!await zipFile.exists()) {
      throw Exception('Backup file not found');
    }

    final archive = await _decodeZip(zipPath);

    _updateProgress('Extracting data...', 0.1);

    final jsonFile = archive.findFile(_jsonFileName);
    if (jsonFile == null) {
      throw Exception('Invalid backup: missing $_jsonFileName');
    }

    final jsonString = utf8.decode(jsonFile.content as List<int>);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    if (data['tanks'] == null || data['tanks'] is! List) {
      throw Exception('Invalid format: missing tanks array');
    }

    _updateProgress('Restoring photos...', 0.2);

    final photosDir = await _getPhotosDirectory();
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final photoFiles = archive.files
        .where((f) => f.isFile && f.name.startsWith('$_photosFolder/'))
        .toList();

    final totalPhotos = photoFiles.length;
    if (totalPhotos == 0) {
      _updateProgress('No photos found in backup', 0.9);
      _updateProgress('Import complete!', 1.0);
      return (data['tanks'] as List).length;
    }

    for (var i = 0; i < totalPhotos; i++) {
      final file = photoFiles[i];
      final filename = p.basename(file.name);
      final destPath = p.join(photosDir.path, filename);
      final destFile = File(destPath);

      // Only copy if file doesn't exist (don't overwrite existing photos).
      if (!await destFile.exists()) {
        final output = OutputFileStream(destPath);
        try {
          file.writeContent(output);
        } finally {
          await output.close();
        }
      }

      final progress = 0.2 + ((i + 1) / totalPhotos * 0.7);
      _updateProgress('Restoring photos... (${i + 1}/$totalPhotos)', progress);
    }

    _updateProgress('Import complete!', 1.0);
    return (data['tanks'] as List).length;
  }

  /// Get the JSON data from a backup.
  ///
  /// Photo references in the backup are portable (`photos/<filename>`). This
  /// method resolves them into absolute paths inside the current app documents
  /// directory.
  Future<Map<String, dynamic>> getBackupData(String zipPath) async {
    final zipFile = File(zipPath);
    if (!await zipFile.exists()) {
      throw Exception('Backup file not found');
    }

    final archive = await _decodeZip(zipPath);

    final jsonFile = archive.findFile(_jsonFileName);
    if (jsonFile == null) {
      throw Exception('Invalid backup: missing $_jsonFileName');
    }

    final jsonString = utf8.decode(jsonFile.content as List<int>);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    // Resolve any photo refs to current device paths.
    return _resolvePhotoRefsToAbsolute(data);
  }

  Future<Archive> _decodeZip(String zipPath) async {
    final input = InputFileStream(zipPath);
    try {
      return ZipDecoder().decodeBuffer(input);
    } finally {
      await input.close();
    }
  }

  Future<Directory> _getPhotosDirectory() async {
    final docs = await _getDocumentsDirectory();
    return Directory(p.join(docs.path, _photosFolder));
  }

  Future<Directory> _getDocumentsDirectory() async {
    return (getDocumentsDirectoryOverride ??
        getApplicationDocumentsDirectory)();
  }

  Future<Directory> _getTemporaryDirectory() async {
    return (getTemporaryDirectoryOverride ?? getTemporaryDirectory)();
  }

  void _updateProgress(String status, double progress) {
    onProgress?.call(status, progress.clamp(0.0, 1.0));
  }

  /// Extract all photo paths/refs from export data.
  void _extractPhotoPaths(dynamic data, Set<String> paths) {
    if (data is Map) {
      for (final value in data.values) {
        if (value is String && _isPhotoRef(value)) {
          paths.add(value);
        } else if (value is List || value is Map) {
          _extractPhotoPaths(value, paths);
        }
      }
    } else if (data is List) {
      for (final item in data) {
        _extractPhotoPaths(item, paths);
      }
    }
  }

  bool _isPhotoRef(String value) {
    final lower = value.toLowerCase();
    final isInPhotosFolder =
        lower.startsWith('$_photosFolder/') ||
        lower.startsWith('$_photosFolder\\') ||
        lower.contains('/$_photosFolder/') ||
        lower.contains('\\$_photosFolder\\');

    if (!isInPhotosFolder) return false;

    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  /// Convert any photo path string into a portable ref `photos/<filename>`.
  ///
  /// If [value] isn't a photo path/ref, it is returned unchanged.
  String _toPortablePhotoRef(String value) {
    if (!_isPhotoRef(value)) return value;
    return '$_photosFolder/${p.basename(value)}';
  }

  /// Returns a deep-copied structure where any photo paths are converted into
  /// portable refs.
  dynamic _makePhotoRefsPortable(dynamic data) {
    if (data is Map) {
      return {
        for (final entry in data.entries)
          entry.key.toString(): _makePhotoRefsPortable(entry.value),
      };
    }

    if (data is List) {
      return data.map(_makePhotoRefsPortable).toList();
    }

    if (data is String) {
      return _toPortablePhotoRef(data);
    }

    return data;
  }

  /// Resolve any photo refs in [data] to absolute paths under the current
  /// documents directory.
  Future<Map<String, dynamic>> _resolvePhotoRefsToAbsolute(
    Map<String, dynamic> data,
  ) async {
    final photosDir = await _getPhotosDirectory();

    dynamic resolve(dynamic v) {
      if (v is Map) {
        return {
          for (final entry in v.entries)
            entry.key.toString(): resolve(entry.value),
        };
      }
      if (v is List) {
        return v.map(resolve).toList();
      }
      if (v is String && _isPhotoRef(v)) {
        final filename = p.basename(v);
        return p.join(photosDir.path, filename);
      }
      return v;
    }

    return (resolve(data) as Map).cast<String, dynamic>();
  }

  /// Given a photo ref/path from the JSON (portable or absolute), find a local
  /// file that should be added to the ZIP.
  ///
  /// This is intentionally forgiving:
  /// - If it is already an absolute path and exists, we use it.
  /// - Otherwise, we look for the basename inside the current photos directory.
  Future<File?> _resolvePhotoRefToLocalFile(String photoRef) async {
    // Try absolute path first.
    final maybeAbsolute = File(photoRef);
    if (await maybeAbsolute.exists()) return maybeAbsolute;

    // Fallback: treat as portable ref, or map any old absolute paths into the
    // current photos directory by basename.
    final photosDir = await _getPhotosDirectory();
    final filename = p.basename(photoRef);
    final inPhotosDir = File(p.join(photosDir.path, filename));
    if (await inPhotosDir.exists()) return inPhotosDir;

    return null;
  }
}
