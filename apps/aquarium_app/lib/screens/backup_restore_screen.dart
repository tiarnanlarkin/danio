import '../widgets/core/app_states.dart';
import 'dart:convert';
import 'dart:io';
import '../widgets/core/bubble_loader.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../providers/storage_provider.dart';
import '../providers/tank_provider.dart';
import '../services/backup_service.dart';
import '../services/shared_preferences_backup.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import '../widgets/core/app_card.dart';

const _uuid = Uuid();

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  String? _lastBackup;
  bool _isExporting = false;
  bool _isImporting = false;

  String _progressStatus = '';
  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tanksAsync = ref.watch(tanksProvider);

    // Build item list once — ListView.builder calls itemCount and itemBuilder
    // separately, so evaluating inside each callback would double the work.
    final items = _buildItems(tanksAsync);
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: items.length,
        itemBuilder: (context, index) => items[index],
      ),
    );
  }

  List<Widget> _buildItems(AsyncValue<List<dynamic>> tanksAsync) {
    return [
      AppCard(
        backgroundColor: AppOverlays.info10,
        padding: AppCardPadding.standard,
        child: Row(
          children: [
            Icon(
              Icons.backup,
              size: AppIconSizes.lg,
              color: context.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm2),
            Expanded(
              child: Text(
                'Export your tank data and photos as a ZIP file to back up or transfer to another device.',
                style: AppTypography.bodyMedium,
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: AppSpacing.lg),

      Text('Export Data', style: AppTypography.headlineSmall),
      const SizedBox(height: AppSpacing.sm2),

      tanksAsync.when(
        loading: () => const Center(child: BubbleLoader()),
        error: (e, _) => AppErrorState(
          message: "Couldn't load your tanks. Tap to try again.",
          onRetry: () => ref.invalidate(tanksProvider),
        ),
        data: (tanks) => Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${tanks.length} tank${tanks.length == 1 ? '' : 's'} to export',
                      style: AppTypography.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ...tanks
                    .take(5)
                    .map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(left: 32, top: 4),
                        child: Text(
                          '• ${t.name}',
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    ),
                if (tanks.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(left: 32, top: 4),
                    child: Text(
                      '... and ${tanks.length - 5} more',
                      style: AppTypography.bodySmall,
                    ),
                  ),

                if (_isExporting) ...[
                  const SizedBox(height: AppSpacing.md),
                  LinearProgressIndicator(value: _progressValue),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _progressStatus,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: (_isExporting || tanks.isEmpty)
                        ? null
                        : () => _exportData(tanks),
                    icon: _isExporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.file_download),
                    label: Text(
                      _isExporting ? 'Exporting...' : 'Export Backup (ZIP)',
                    ),
                  ),
                ),
                if (_lastBackup != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: Text(
                      '✓ Last backup: $_lastBackup',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),

      const SizedBox(height: AppSpacing.lg),

      Text('Import Data', style: AppTypography.headlineSmall),
      const SizedBox(height: AppSpacing.sm2),

      AppCard(
        padding: AppCardPadding.standard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Restore a backup by selecting a ZIP file exported from this app.',
              style: AppTypography.bodyMedium,
            ),

            if (_isImporting) ...[
              const SizedBox(height: AppSpacing.md),
              LinearProgressIndicator(value: _progressValue),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _progressStatus,
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.sm2),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isImporting ? null : _importData,
                icon: _isImporting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.file_upload),
                label: Text(
                  _isImporting ? 'Importing...' : 'Select Backup File',
                ),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: AppSpacing.lg),

      Text('What Gets Exported', style: AppTypography.headlineSmall),
      const SizedBox(height: AppSpacing.sm2),

      AppCard(
        padding: AppCardPadding.standard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ExportItem(
              icon: Icons.water,
              text: 'All tanks and settings',
              included: true,
            ),
            _ExportItem(
              icon: Icons.set_meal,
              text: 'Livestock inventories',
              included: true,
            ),
            _ExportItem(
              icon: Icons.science,
              text: 'Water test logs',
              included: true,
            ),
            _ExportItem(
              icon: Icons.eco,
              text: 'Plant inventories',
              included: true,
            ),
            _ExportItem(
              icon: Icons.book,
              text: 'Journal entries',
              included: true,
            ),
            const Divider(),
            _ExportItem(
              icon: Icons.school,
              text: 'Learning progress & streaks',
              included: true,
            ),
            _ExportItem(
              icon: Icons.diamond,
              text: 'Gem balance & transactions',
              included: true,
            ),
            _ExportItem(
              icon: Icons.person,
              text: 'User profile & preferences',
              included: true,
            ),
            const Divider(),
            _ExportItem(
              icon: Icons.photo,
              text: 'All photos (bundled in ZIP)',
              included: true,
            ),
          ],
        ),
      ),

      const SizedBox(height: AppSpacing.lg),

      AppCard(
        backgroundColor: AppOverlays.warning10,
        padding: AppCardPadding.standard,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning, color: AppColors.warning),
            const SizedBox(width: AppSpacing.sm2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Import Warning', style: AppTypography.labelLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Importing will ADD tanks and RESTORE your learning progress, '
                    'gems, and profile from the backup.',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: AppSpacing.xxl),
    ];
  }

  Future<void> _exportData(List<dynamic> tanks) async {
    setState(() {
      _isExporting = true;
      _progressStatus = 'Initializing...';
      _progressValue = 0.0;
    });

    try {
      // Collect all data from storage
      final storage = ref.read(storageServiceProvider);

      // Get all related data for each tank
      final allLivestock = <Map<String, dynamic>>[];
      final allEquipment = <Map<String, dynamic>>[];
      final allLogs = <Map<String, dynamic>>[];
      final allTasks = <Map<String, dynamic>>[];

      for (final tank in tanks) {
        final tankId = (tank as Tank).id;

        // Collect livestock
        final livestock = await storage.getLivestockForTank(tankId);
        allLivestock.addAll(livestock.map((l) => _livestockToJson(l)));

        // Collect equipment
        final equipment = await storage.getEquipmentForTank(tankId);
        allEquipment.addAll(equipment.map((e) => _equipmentToJson(e)));

        // Collect all logs
        final logs = await storage.getLogsForTank(tankId);
        allLogs.addAll(logs.map((l) => _logToJson(l)));

        // Collect tasks
        final tasks = await storage.getTasksForTank(tankId);
        allTasks.addAll(tasks.map((t) => _taskToJson(t)));
      }

      // Create comprehensive export data
      final prefsBackupJson =
          await SharedPreferencesBackup.exportAsJson();
      final prefsBackupData = jsonDecode(prefsBackupJson) as Map<String, dynamic>;

      final exportData = {
        'version': 3, // v3 includes SharedPreferences (profile, gems, settings)
        'exportDate': DateTime.now().toIso8601String(),
        'appVersion': '1.0.0',
        'tanks': tanks.map((t) => (t as Tank).toJson()).toList(),
        'livestock': allLivestock,
        'equipment': allEquipment,
        'logs': allLogs,
        'tasks': allTasks,
        'sharedPreferences': prefsBackupData,
      };

      final backupService = BackupService(
        onProgress: (status, progress) {
          if (mounted) {
            setState(() {
              _progressStatus = status;
              _progressValue = progress;
            });
          }
        },
      );

      final zipPath = await backupService.createBackup(exportData);

      if (!mounted) return;

      setState(() {
        _lastBackup = DateFormat('MMM d, y h:mm a').format(DateTime.now());
      });

      // Share the ZIP file
      final result = await Share.shareXFiles(
        [XFile(zipPath)],
        subject: 'Danio Backup',
        text:
            'My aquarium backup - ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
      );

      if (!mounted) return;

      // Clean up temp file after sharing.
      try {
        await File(zipPath).delete();
      } catch (e) {
        debugPrint('Backup cleanup failed: $e');
      }

      if (!mounted) return;

      if (result.status == ShareResultStatus.success) {
        AppFeedback.showSuccess(context, 'Backup exported successfully!');
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(
          context,
          'Export didn\'t work. Give it another go!',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _progressStatus = '';
          _progressValue = 0.0;
        });
      }
    }
  }

  Future<void> _importData() async {
    setState(() {
      _isImporting = true;
      _progressStatus = 'Selecting file...';
      _progressValue = 0.0;
    });

    try {
      // Pick ZIP file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        if (mounted) setState(() => _isImporting = false);
        return;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        throw Exception('Could not access selected file');
      }

      final backupService = BackupService(
        onProgress: (status, progress) {
          if (mounted) {
            setState(() {
              _progressStatus = status;
              _progressValue = progress;
            });
          }
        },
      );

      // First, get backup data to show preview
      final backupData = await backupService.getBackupData(filePath);
      final tanks = backupData['tanks'] as List;

      if (!mounted) return;

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Import Backup?'),
          content: Text(
            'This will import ${tanks.length} tank${tanks.length == 1 ? '' : 's'} with all photos.\n\n'
            'Your existing data will NOT be affected.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Import'),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        if (mounted) setState(() => _isImporting = false);
        return;
      }

      // Restore photos first
      await backupService.restoreBackup(filePath);

      if (!mounted) return;

      // Import all data with proper tankId remapping
      // NOTE: BackupService.getBackupData() already resolves portable photo
      // references (photos/<filename>) to this device's documents/photos path.
      final imported = await _importAllData(backupData);

      // Restore SharedPreferences (profile, gems, settings, etc.)
      final prefsData = backupData['sharedPreferences'];
      if (prefsData != null && prefsData is Map<String, dynamic>) {
        try {
          await SharedPreferencesBackup.restoreFromJson(prefsData);
        } catch (e) {
          debugPrint('SharedPreferences restore warning: $e');
        }
      }

      if (mounted) {
        if (imported > 0) {
          AppFeedback.showSuccess(
            context,
            'Imported $imported tank${imported == 1 ? '' : 's'} with all data successfully!',
          );
        } else {
          AppFeedback.showWarning(
            context,
            'No tanks found in this backup file.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(
          context,
          'Import failed. The file may be invalid or corrupted.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
          _progressStatus = '';
          _progressValue = 0.0;
        });
      }
    }
  }

  /// Import all data from backup with proper tankId remapping
  Future<int> _importAllData(Map<String, dynamic> backupData) async {
    final storage = ref.read(storageServiceProvider);
    final now = DateTime.now();

    // Map old tank IDs to new tank IDs
    final tankIdMap = <String, String>{};

    // Import tanks first
    final tanksJson = backupData['tanks'] as List? ?? [];
    int imported = 0;

    for (final tankJson in tanksJson) {
      try {
        if (tankJson is! Map<String, dynamic>) continue;

        final oldTankId = tankJson['id'] as String;
        final newTankId = _uuid.v4();
        tankIdMap[oldTankId] = newTankId;

        final tank = Tank.fromJson({
          ...tankJson,
          'id': newTankId,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        });

        await storage.saveTank(tank);
        imported++;
      } catch (e) {
        debugPrint('Failed to import tank: $e');
        continue;
      }
    }

    // Import livestock with updated tankIds
    final livestockJson = backupData['livestock'] as List? ?? [];
    for (final lJson in livestockJson) {
      try {
        if (lJson is! Map<String, dynamic>) continue;
        final oldTankId = lJson['tankId'] as String;
        final newTankId = tankIdMap[oldTankId];
        if (newTankId == null) continue; // Skip if tank wasn't imported

        final livestock = _livestockFromJson({
          ...lJson,
          'id': _uuid.v4(),
          'tankId': newTankId,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        });

        await storage.saveLivestock(livestock);
      } catch (e) {
        debugPrint('Failed to import livestock: $e');
        continue;
      }
    }

    // Import equipment with updated tankIds
    final equipmentJson = backupData['equipment'] as List? ?? [];
    for (final eJson in equipmentJson) {
      try {
        if (eJson is! Map<String, dynamic>) continue;
        final oldTankId = eJson['tankId'] as String;
        final newTankId = tankIdMap[oldTankId];
        if (newTankId == null) continue;

        final equipment = _equipmentFromJson({
          ...eJson,
          'id': _uuid.v4(),
          'tankId': newTankId,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        });

        await storage.saveEquipment(equipment);
      } catch (e) {
        debugPrint('Failed to import equipment: $e');
        continue;
      }
    }

    // Import logs with updated tankIds
    final logsJson = backupData['logs'] as List? ?? [];
    for (final lJson in logsJson) {
      try {
        if (lJson is! Map<String, dynamic>) continue;
        final oldTankId = lJson['tankId'] as String;
        final newTankId = tankIdMap[oldTankId];
        if (newTankId == null) continue;

        final log = _logFromJson({
          ...lJson,
          'id': _uuid.v4(),
          'tankId': newTankId,
          'createdAt': now.toIso8601String(),
        });

        await storage.saveLog(log);
      } catch (e) {
        debugPrint('Failed to import log: $e');
        continue;
      }
    }

    // Import tasks with updated tankIds
    final tasksJson = backupData['tasks'] as List? ?? [];
    for (final tJson in tasksJson) {
      try {
        if (tJson is! Map<String, dynamic>) continue;
        final oldTankId = tJson['tankId'] as String;
        final newTankId = tankIdMap[oldTankId];
        if (newTankId == null) continue;

        final task = _taskFromJson({
          ...tJson,
          'id': _uuid.v4(),
          'tankId': newTankId,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        });

        await storage.saveTask(task);
      } catch (e) {
        debugPrint('Failed to import task: $e');
        continue;
      }
    }

    // Invalidate all providers to refresh UI
    if (imported > 0) {
      ref.invalidate(tanksProvider);
    }

    return imported;
  }

  // Serialization helpers (matching local_json_storage_service.dart format)
  Map<String, dynamic> _livestockToJson(Livestock l) => {
    'id': l.id,
    'tankId': l.tankId,
    'commonName': l.commonName,
    'scientificName': l.scientificName,
    'count': l.count,
    'sizeCm': l.sizeCm,
    'maxSizeCm': l.maxSizeCm,
    'dateAdded': l.dateAdded.toIso8601String(),
    'source': l.source,
    'temperament': l.temperament?.name,
    'notes': l.notes,
    'imageUrl': l.imageUrl,
    'createdAt': l.createdAt.toIso8601String(),
    'updatedAt': l.updatedAt.toIso8601String(),
  };

  Livestock _livestockFromJson(Map<String, dynamic> m) => Livestock(
    id: m['id'] as String,
    tankId: m['tankId'] as String,
    commonName: m['commonName'] as String,
    scientificName: m['scientificName'] as String?,
    count: (m['count'] as num?)?.toInt() ?? 1,
    sizeCm: (m['sizeCm'] as num?)?.toDouble(),
    maxSizeCm: (m['maxSizeCm'] as num?)?.toDouble(),
    dateAdded: DateTime.parse(m['dateAdded'] as String),
    source: m['source'] as String?,
    temperament: m['temperament'] == null
        ? null
        : Temperament.values.firstWhere(
            (e) => e.name == m['temperament'],
            orElse: () => Temperament.peaceful,
          ),
    notes: m['notes'] as String?,
    imageUrl: m['imageUrl'] as String?,
    createdAt: DateTime.parse(m['createdAt'] as String),
    updatedAt: DateTime.parse(m['updatedAt'] as String),
  );

  Map<String, dynamic> _equipmentToJson(Equipment e) => {
    'id': e.id,
    'tankId': e.tankId,
    'type': e.type.name,
    'name': e.name,
    'brand': e.brand,
    'model': e.model,
    'settings': e.settings,
    'maintenanceIntervalDays': e.maintenanceIntervalDays,
    'lastServiced': e.lastServiced?.toIso8601String(),
    'installedDate': e.installedDate?.toIso8601String(),
    'notes': e.notes,
    'createdAt': e.createdAt.toIso8601String(),
    'updatedAt': e.updatedAt.toIso8601String(),
  };

  Equipment _equipmentFromJson(Map<String, dynamic> m) => Equipment(
    id: m['id'] as String,
    tankId: m['tankId'] as String,
    type: EquipmentType.values.firstWhere(
      (e) => e.name == (m['type'] ?? 'other'),
      orElse: () => EquipmentType.other,
    ),
    name: m['name'] as String,
    brand: m['brand'] as String?,
    model: m['model'] as String?,
    settings: (m['settings'] as Map?)?.cast<String, dynamic>(),
    maintenanceIntervalDays: (m['maintenanceIntervalDays'] as num?)?.toInt(),
    lastServiced: m['lastServiced'] != null
        ? DateTime.parse(m['lastServiced'] as String)
        : null,
    installedDate: m['installedDate'] != null
        ? DateTime.parse(m['installedDate'] as String)
        : null,
    notes: m['notes'] as String?,
    createdAt: DateTime.parse(m['createdAt'] as String),
    updatedAt: DateTime.parse(m['updatedAt'] as String),
  );

  Map<String, dynamic> _logToJson(LogEntry l) => {
    'id': l.id,
    'tankId': l.tankId,
    'type': l.type.name,
    'timestamp': l.timestamp.toIso8601String(),
    'waterTest': l.waterTest != null ? _waterTestToJson(l.waterTest!) : null,
    'waterChangePercent': l.waterChangePercent,
    'title': l.title,
    'notes': l.notes,
    'photoUrls': l.photoUrls,
    'relatedEquipmentId': l.relatedEquipmentId,
    'relatedLivestockId': l.relatedLivestockId,
    'relatedTaskId': l.relatedTaskId,
    'createdAt': l.createdAt.toIso8601String(),
  };

  LogEntry _logFromJson(Map<String, dynamic> m) => LogEntry(
    id: m['id'] as String,
    tankId: m['tankId'] as String,
    type: LogType.values.firstWhere(
      (e) => e.name == (m['type'] ?? 'other'),
      orElse: () => LogType.other,
    ),
    timestamp: DateTime.parse(m['timestamp'] as String),
    waterTest: m['waterTest'] != null
        ? _waterTestFromJson(m['waterTest'])
        : null,
    waterChangePercent: (m['waterChangePercent'] as num?)?.toInt(),
    title: m['title'] as String?,
    notes: m['notes'] as String?,
    photoUrls: (m['photoUrls'] as List?)?.cast<String>(),
    relatedEquipmentId: m['relatedEquipmentId'] as String?,
    relatedLivestockId: m['relatedLivestockId'] as String?,
    relatedTaskId: m['relatedTaskId'] as String?,
    createdAt: DateTime.parse(m['createdAt'] as String),
  );

  Map<String, dynamic> _waterTestToJson(WaterTestResults t) => {
    'temperature': t.temperature,
    'ph': t.ph,
    'ammonia': t.ammonia,
    'nitrite': t.nitrite,
    'nitrate': t.nitrate,
    'gh': t.gh,
    'kh': t.kh,
    'phosphate': t.phosphate,
    'co2': t.co2,
  };

  WaterTestResults _waterTestFromJson(Map<String, dynamic> m) =>
      WaterTestResults(
        temperature: (m['temperature'] as num?)?.toDouble(),
        ph: (m['ph'] as num?)?.toDouble(),
        ammonia: (m['ammonia'] as num?)?.toDouble(),
        nitrite: (m['nitrite'] as num?)?.toDouble(),
        nitrate: (m['nitrate'] as num?)?.toDouble(),
        gh: (m['gh'] as num?)?.toDouble(),
        kh: (m['kh'] as num?)?.toDouble(),
        phosphate: (m['phosphate'] as num?)?.toDouble(),
        co2: (m['co2'] as num?)?.toDouble(),
      );

  Map<String, dynamic> _taskToJson(Task t) => {
    'id': t.id,
    'tankId': t.tankId,
    'title': t.title,
    'description': t.description,
    'recurrence': t.recurrence.name,
    'intervalDays': t.intervalDays,
    'dueDate': t.dueDate?.toIso8601String(),
    'priority': t.priority.name,
    'isEnabled': t.isEnabled,
    'isAutoGenerated': t.isAutoGenerated,
    'lastCompletedAt': t.lastCompletedAt?.toIso8601String(),
    'completionCount': t.completionCount,
    'relatedEquipmentId': t.relatedEquipmentId,
    'createdAt': t.createdAt.toIso8601String(),
    'updatedAt': t.updatedAt.toIso8601String(),
  };

  Task _taskFromJson(Map<String, dynamic> m) => Task(
    id: m['id'] as String,
    tankId: m['tankId'] as String?,
    title: m['title'] as String,
    description: m['description'] as String?,
    recurrence: RecurrenceType.values.firstWhere(
      (e) => e.name == (m['recurrence'] ?? 'none'),
      orElse: () => RecurrenceType.none,
    ),
    intervalDays: (m['intervalDays'] as num?)?.toInt(),
    dueDate: m['dueDate'] != null
        ? DateTime.parse(m['dueDate'] as String)
        : null,
    priority: TaskPriority.values.firstWhere(
      (e) => e.name == (m['priority'] ?? 'normal'),
      orElse: () => TaskPriority.normal,
    ),
    isEnabled: (m['isEnabled'] as bool?) ?? true,
    isAutoGenerated: (m['isAutoGenerated'] as bool?) ?? false,
    lastCompletedAt: m['lastCompletedAt'] != null
        ? DateTime.parse(m['lastCompletedAt'] as String)
        : null,
    completionCount: (m['completionCount'] as num?)?.toInt() ?? 0,
    relatedEquipmentId: m['relatedEquipmentId'] as String?,
    createdAt: DateTime.parse(m['createdAt'] as String),
    updatedAt: DateTime.parse(m['updatedAt'] as String),
  );
}

class _ExportItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool included;

  const _ExportItem({
    required this.icon,
    required this.text,
    required this.included,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.textSecondary),
          const SizedBox(width: AppSpacing.sm2),
          Expanded(child: Text(text, style: AppTypography.bodyMedium)),
          Icon(
            included ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: included ? AppColors.success : context.textHint,
          ),
        ],
      ),
    );
  }
}
