import '../widgets/core/app_states.dart';
import 'dart:convert';
import 'dart:io';
import '../widgets/core/bubble_loader.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../models/models.dart';
import '../providers/storage_provider.dart';
import '../providers/restore_invalidation.dart';
import '../providers/tank_provider.dart';
import '../services/backup_import_service.dart';
import '../services/backup_service.dart';
import '../services/local_json_storage_service.dart';
import '../services/shared_preferences_backup.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart' show kAppVersion;
import '../utils/app_feedback.dart';
import '../widgets/core/app_card.dart';
import '../utils/logger.dart';
import '../widgets/core/app_button.dart';
import '../widgets/core/app_dialog.dart';
import 'tab_navigator.dart';

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
  bool _isRecoveringLocalData = false;

  String _progressStatus = '';
  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();
  }

  void _openTankTab() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    ref.read(currentTabProvider.notifier).state = 2;
  }

  @override
  Widget build(BuildContext context) {
    final tanksAsync = ref.watch(tanksProvider);
    final storageRecovery = ref.watch(storageRecoveryProvider);

    // Build item list once - ListView.builder calls itemCount and itemBuilder
    // separately, so evaluating inside each callback would double the work.
    final items = _buildItems(tanksAsync, storageRecovery);
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          MediaQuery.of(context).padding.bottom + AppSpacing.xxl,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) => items[index],
      ),
    );
  }

  List<Widget> _buildItems(
    AsyncValue<List<dynamic>> tanksAsync,
    StorageRecoveryService? storageRecovery,
  ) {
    final showRecovery = _shouldShowStorageRecovery(storageRecovery);
    final activeRecovery = showRecovery ? storageRecovery! : null;
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

      if (showRecovery) ...[
        _LocalStorageRecoveryCard(
          isRecovering: _isRecoveringLocalData,
          onRetry: () => _retryLocalStorageRecovery(activeRecovery!),
          onStartFresh: () => _confirmStartFreshLocalStorage(activeRecovery!),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],

      Text('Export Data', style: AppTypography.headlineSmall),
      const SizedBox(height: AppSpacing.sm2),

      tanksAsync.when(
        loading: () => const Center(child: BubbleLoader()),
        error: (e, _) {
          if (showRecovery) {
            return AppErrorState(
              message: 'Recover local data before exporting a backup.',
              onRetry: () => _retryLocalStorageRecovery(activeRecovery!),
            );
          }
          return AppErrorState(
            message: "Couldn't load your tanks. Tap to try again.",
            onRetry: () => ref.invalidate(tanksProvider),
          );
        },
        data: (tanks) {
          final hasTanks = tanks.isNotEmpty;
          return Card(
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
                  if (!hasTanks) ...[
                    Text(
                      'There are no tanks to export yet. Add a tank first, then come back here to create a backup.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'Go to Tank',
                      onPressed: _openTankTab,
                      leadingIcon: Icons.water,
                      isFullWidth: true,
                      variant: AppButtonVariant.secondary,
                    ),
                  ] else ...[
                    ...tanks
                        .take(5)
                        .map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(
                              left: AppSpacing.xl,
                              top: AppSpacing.xs,
                            ),
                            child: Text(
                              '- ${t.name}',
                              style: AppTypography.bodySmall,
                            ),
                          ),
                        ),
                    if (tanks.length > 5)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.xl,
                          top: AppSpacing.xs,
                        ),
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
                    AppButton(
                      label: _isExporting
                          ? 'Exporting...'
                          : 'Export Backup (ZIP)',
                      onPressed: (_isExporting || tanks.isEmpty)
                          ? null
                          : () => _exportData(tanks),
                      isLoading: _isExporting,
                      leadingIcon: Icons.file_download,
                      isFullWidth: true,
                      variant: AppButtonVariant.primary,
                    ),
                    if (_lastBackup != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Center(
                        child: Text(
                          'Last backup: $_lastBackup',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          );
        },
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
            AppButton(
              label: _isImporting ? 'Importing...' : 'Select Backup File',
              onPressed: _isImporting ? null : _importData,
              isLoading: _isImporting,
              leadingIcon: Icons.file_upload,
              isFullWidth: true,
              variant: AppButtonVariant.primary,
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
                  Text('Import Safety', style: AppTypography.labelLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Imports add backed-up tanks as new tanks. Existing tanks and logs stay on this device. App-wide profile, learning progress, gems, and preferences are replaced from the backup.',
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

  bool _shouldShowStorageRecovery(StorageRecoveryService? storageRecovery) {
    return storageRecovery != null &&
        storageRecovery.state == StorageState.corrupted;
  }

  Future<void> _retryLocalStorageRecovery(
    StorageRecoveryService storageRecovery,
  ) async {
    if (_isRecoveringLocalData) return;
    setState(() => _isRecoveringLocalData = true);

    try {
      await storageRecovery.retryLoad();
      ref.invalidate(tanksProvider);
      if (!mounted) return;
      AppFeedback.showSuccess(context, 'Local data loaded successfully.');
    } catch (e, st) {
      logError(
        'BackupRestoreScreen: local storage retry failed: $e',
        stackTrace: st,
        tag: 'BackupRestoreScreen',
      );
      if (!mounted) return;
      AppFeedback.showError(
        context,
        'Danio still could not load this local data.',
      );
    } finally {
      if (mounted) {
        setState(() => _isRecoveringLocalData = false);
      }
    }
  }

  Future<void> _confirmStartFreshLocalStorage(
    StorageRecoveryService storageRecovery,
  ) async {
    if (_isRecoveringLocalData) return;
    final confirmed = await showAppDestructiveDialog(
      context: context,
      title: 'Start Fresh On This Device?',
      message:
          'This clears the damaged local aquarium data file on this device. Danio keeps the recovery copy it made before stopping the load.',
      destructiveLabel: 'Start Fresh',
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isRecoveringLocalData = true);
    try {
      await storageRecovery.recoverFromCorruption();
      ref.invalidate(tanksProvider);
      if (!mounted) return;
      AppFeedback.showSuccess(context, 'Started fresh on this device.');
    } catch (e, st) {
      logError(
        'BackupRestoreScreen: local storage recovery failed: $e',
        stackTrace: st,
        tag: 'BackupRestoreScreen',
      );
      if (!mounted) return;
      AppFeedback.showError(
        context,
        'Start fresh did not complete. Try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isRecoveringLocalData = false);
      }
    }
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
      final prefsBackupJson = await SharedPreferencesBackup.exportAsJson();
      final prefsBackupData =
          jsonDecode(prefsBackupJson) as Map<String, dynamic>;

      final exportData = {
        'version': 3, // v3 includes SharedPreferences (profile, gems, settings)
        'exportDate': DateTime.now().toIso8601String(),
        'appVersion': kAppVersion,
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
        _lastBackup = DateFormat('d MMM y h:mm a').format(DateTime.now());
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
        logError('Backup cleanup failed: $e', tag: 'BackupRestoreScreen');
      }

      if (!mounted) return;

      if (result.status == ShareResultStatus.success) {
        AppFeedback.showSuccess(context, 'Backup exported successfully!');
      }
    } catch (e, st) {
      logError(
        'BackupRestoreScreen: backup export failed: $e',
        stackTrace: st,
        tag: 'BackupRestoreScreen',
      );
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
      final confirmed = await showAppConfirmDialog(
        context: context,
        title: 'Import Backup?',
        message:
            'This will import ${tanks.length} tank${tanks.length == 1 ? '' : 's'} with all photos.\n\n'
            'Existing tanks and logs stay on this device. App-wide profile, learning progress, gems, and preferences will be replaced with the backup values.',
        confirmLabel: 'Import',
      );

      if (confirmed != true) {
        if (mounted) setState(() => _isImporting = false);
        return;
      }

      // Restore photos first
      await backupService.restoreBackup(filePath);

      if (!mounted) return;

      // Import all tank-scoped data with proper tankId remapping.
      // NOTE: BackupService.getBackupData() already resolves portable photo
      // references (photos/<filename>) to this device's documents/photos path.
      final importResult = await BackupImportService(
        storage: ref.read(storageServiceProvider),
      ).importTankScopedData(backupData);
      final imported = importResult.importedTanks;
      if (imported > 0) {
        ref.invalidate(tanksProvider);
      }

      // Restore SharedPreferences (profile, gems, settings, etc.)
      var preferencesRestoreFailed = false;
      final prefsData = backupData['sharedPreferences'];
      if (prefsData != null && prefsData is Map<String, dynamic>) {
        try {
          await SharedPreferencesBackup.restoreFromJson(prefsData);
          invalidateRestoredPreferenceProviders(ref);
        } catch (e) {
          preferencesRestoreFailed = true;
          logError(
            'SharedPreferences restore warning: $e',
            tag: 'BackupRestoreScreen',
          );
        }
      }

      if (mounted) {
        if (imported > 0) {
          if (preferencesRestoreFailed) {
            AppFeedback.showWarning(
              context,
              'Imported $imported tank${imported == 1 ? '' : 's'}, but profile and preferences could not be restored.',
            );
          } else {
            AppFeedback.showSuccess(
              context,
              'Imported $imported tank${imported == 1 ? '' : 's'} with all data successfully!',
            );
          }
        } else {
          AppFeedback.showWarning(
            context,
            'No tanks found in this backup file.',
          );
        }
      }
    } catch (e, st) {
      logError(
        'BackupRestoreScreen: backup import failed: $e',
        stackTrace: st,
        tag: 'BackupRestoreScreen',
      );
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
    'healthStatus': l.healthStatus.name,
    'notes': l.notes,
    'imageUrl': l.imageUrl,
    'createdAt': l.createdAt.toIso8601String(),
    'updatedAt': l.updatedAt.toIso8601String(),
  };

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
    'purchaseDate': e.purchaseDate?.toIso8601String(),
    'expectedLifespanMonths': e.expectedLifespanMonths,
    'notes': e.notes,
    'createdAt': e.createdAt.toIso8601String(),
    'updatedAt': e.updatedAt.toIso8601String(),
  };

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
}

class _LocalStorageRecoveryCard extends StatelessWidget {
  const _LocalStorageRecoveryCard({
    required this.isRecovering,
    required this.onRetry,
    required this.onStartFresh,
  });

  final bool isRecovering;
  final VoidCallback onRetry;
  final VoidCallback onStartFresh;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppOverlays.warning10,
      padding: AppCardPadding.standard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.warning),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Local Data Needs Attention',
                      style: AppTypography.labelLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Danio stopped loading this device because the local data file looks damaged. Danio kept a recovery copy on this device before offering these options.',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Try again if you repaired or replaced the local file. Start fresh only clears aquarium data on this device.',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: isRecovering ? 'Checking...' : 'Try Again',
            onPressed: isRecovering ? null : onRetry,
            isLoading: isRecovering,
            leadingIcon: Icons.refresh,
            isFullWidth: true,
            variant: AppButtonVariant.secondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Start Fresh On This Device',
            onPressed: isRecovering ? null : onStartFresh,
            leadingIcon: Icons.delete_outline,
            isFullWidth: true,
            variant: AppButtonVariant.destructive,
          ),
        ],
      ),
    );
  }
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
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
