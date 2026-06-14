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

    final data = _readValidatedBackupData(archive);

    _updateProgress('Restoring photos...', 0.2);

    final photosDir = await _getPhotosDirectory();
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    final restorePrefix = await _restorePhotoPrefix(zipPath);

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
      final filename = _restoredPhotoFilename(restorePrefix, file.name);
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

    final data = _readValidatedBackupData(archive);

    // Resolve any photo refs to current device paths.
    return _resolvePhotoRefsToAbsolute(data, zipPath: zipPath);
  }

  Map<String, dynamic> _readValidatedBackupData(Archive archive) {
    final jsonFile = archive.findFile(_jsonFileName);
    if (jsonFile == null) {
      throw Exception('Invalid backup: missing $_jsonFileName');
    }
    _validatePhotoArchiveEntries(archive);

    final jsonString = utf8.decode(jsonFile.content as List<int>);
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map) {
      throw Exception('Invalid format: backup data must be a JSON object');
    }

    final data = Map<String, dynamic>.from(decoded);
    if (data['tanks'] == null || data['tanks'] is! List) {
      throw Exception('Invalid format: missing tanks array');
    }

    final tanks = data['tanks'] as List;
    final seenTankIds = <String>{};
    for (final tank in tanks) {
      if (tank is! Map) {
        throw Exception('Invalid format: tank entries must be objects');
      }
      final id = tank['id'];
      if (id is! String || id.trim().isEmpty) {
        throw Exception('Invalid format: tank entries must include an id');
      }
      final normalizedId = id.trim();
      if (!seenTankIds.add(normalizedId)) {
        throw Exception('Invalid format: duplicate tank id "$normalizedId"');
      }
    }

    for (final collectionName in const [
      'logs',
      'livestock',
      'equipment',
      'tasks',
    ]) {
      _validateTankScopedCollection(data, collectionName, seenTankIds);
    }

    return data;
  }

  void _validatePhotoArchiveEntries(Archive archive) {
    final seenPhotoFilenames = <String>{};
    for (final file in archive.files) {
      if (!file.isFile) continue;

      final normalizedName = file.name.replaceAll(r'\', '/');
      if (!normalizedName.startsWith('$_photosFolder/')) continue;

      final filename = _photoEntryFilename(file.name);
      if (filename.isEmpty) {
        throw Exception(
          'Invalid backup: photo entries must include a filename',
        );
      }

      final normalizedFilename = filename.toLowerCase();
      if (!seenPhotoFilenames.add(normalizedFilename)) {
        throw Exception('Invalid backup: duplicate photo filename "$filename"');
      }
    }
  }

  void _validateTankScopedCollection(
    Map<String, dynamic> data,
    String collectionName,
    Set<String> tankIds,
  ) {
    final entries = data[collectionName];
    if (entries == null) return;
    if (entries is! List) {
      throw Exception('Invalid format: $collectionName must be an array');
    }

    final seenIds = <String>{};
    for (final entry in entries) {
      if (entry is! Map) {
        throw Exception(
          'Invalid format: $collectionName entries must be objects',
        );
      }
      final id = entry['id'];
      if (id is! String || id.trim().isEmpty) {
        throw Exception(
          'Invalid format: $collectionName entries must include an id',
        );
      }
      final normalizedId = id.trim();
      if (!seenIds.add(normalizedId)) {
        throw Exception(
          'Invalid format: duplicate $collectionName id "$normalizedId"',
        );
      }
      final tankId = entry['tankId'];
      if (tankId is! String || tankId.trim().isEmpty) {
        throw Exception(
          'Invalid format: $collectionName entries must include a tankId',
        );
      }
      final normalizedTankId = tankId.trim();
      if (!tankIds.contains(normalizedTankId)) {
        throw Exception(
          'Invalid format: $collectionName entries reference unknown tank id "$normalizedTankId"',
        );
      }
      for (final field in _requiredChildFields(collectionName)) {
        final value = entry[field];
        if (value is! String || value.trim().isEmpty) {
          throw Exception(
            'Invalid format: $collectionName entries must include $field',
          );
        }
      }
      for (final field in _dateChildFields(collectionName)) {
        final value = entry[field] as String;
        if (DateTime.tryParse(value) == null) {
          throw Exception(
            'Invalid format: $collectionName $field values must be valid dates',
          );
        }
      }
      for (final field in _optionalDateChildFields(collectionName)) {
        final value = entry[field];
        if (value == null) continue;
        if (value is! String || DateTime.tryParse(value) == null) {
          throw Exception(
            'Invalid format: $collectionName $field values must be valid dates',
          );
        }
      }
      for (final field in _numericChildFields(collectionName)) {
        final value = entry[field];
        if (value != null && value is! num) {
          throw Exception(
            'Invalid format: $collectionName $field values must be numbers',
          );
        }
      }
      if (collectionName == 'logs') {
        _validateLogNestedFields(entry);
      }
    }
  }

  void _validateLogNestedFields(Map<dynamic, dynamic> entry) {
    final waterTest = entry['waterTest'];
    if (waterTest != null && waterTest is! Map) {
      throw Exception('Invalid format: logs waterTest values must be objects');
    }
    if (waterTest is Map) {
      for (final field in const [
        'temperature',
        'ph',
        'ammonia',
        'nitrite',
        'nitrate',
        'gh',
        'kh',
        'phosphate',
        'co2',
      ]) {
        final value = waterTest[field];
        if (value != null && value is! num) {
          throw Exception(
            'Invalid format: logs waterTest $field values must be numbers',
          );
        }
      }
    }

    final photoUrls = entry['photoUrls'];
    if (photoUrls != null &&
        (photoUrls is! List || photoUrls.any((value) => value is! String))) {
      throw Exception(
        'Invalid format: logs photoUrls values must be arrays of strings',
      );
    }
  }

  List<String> _requiredChildFields(String collectionName) {
    return switch (collectionName) {
      'logs' => const ['timestamp'],
      'livestock' => const ['commonName', 'dateAdded'],
      'equipment' => const ['name'],
      'tasks' => const ['title'],
      _ => const [],
    };
  }

  List<String> _dateChildFields(String collectionName) {
    return switch (collectionName) {
      'logs' => const ['timestamp'],
      'livestock' => const ['dateAdded'],
      _ => const [],
    };
  }

  List<String> _optionalDateChildFields(String collectionName) {
    return switch (collectionName) {
      'equipment' => const ['lastServiced', 'installedDate', 'purchaseDate'],
      'tasks' => const ['dueDate', 'lastCompletedAt'],
      _ => const [],
    };
  }

  List<String> _numericChildFields(String collectionName) {
    return switch (collectionName) {
      'logs' => const ['waterChangePercent'],
      'livestock' => const ['count', 'sizeCm', 'maxSizeCm'],
      'equipment' => const [
        'maintenanceIntervalDays',
        'expectedLifespanMonths',
      ],
      'tasks' => const ['intervalDays', 'completionCount'],
      _ => const [],
    };
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

  Future<String> _restorePhotoPrefix(String zipPath) async {
    final zipFile = File(zipPath);
    final modified = await zipFile.lastModified();
    final baseName = p.basenameWithoutExtension(zipPath);
    final safeBaseName = baseName
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    return 'import_${safeBaseName}_${modified.millisecondsSinceEpoch}';
  }

  String _restoredPhotoFilename(String restorePrefix, String photoRef) {
    return '${restorePrefix}_${_photoEntryFilename(photoRef)}';
  }

  String _photoEntryFilename(String photoRef) {
    return photoRef.replaceAll(r'\', '/').split('/').last;
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
    Map<String, dynamic> data, {
    required String zipPath,
  }) async {
    final photosDir = await _getPhotosDirectory();
    final restorePrefix = await _restorePhotoPrefix(zipPath);

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
        final filename = _restoredPhotoFilename(restorePrefix, v);
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
