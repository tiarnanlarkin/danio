import 'package:flutter/material.dart';
import '../widgets/core/bubble_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../models/models.dart';
import '../providers/storage_provider.dart';
import '../providers/tank_provider.dart';
import '../services/image_cache_service.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_states.dart';
import 'add_log_screen.dart';

class LogDetailScreen extends ConsumerWidget {
  final String tankId;
  final String logId;

  const LogDetailScreen({super.key, required this.tankId, required this.logId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(allLogsProvider(tankId));

    return logsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: BubbleLoader())),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Log')),
        body: AppErrorState(
          title: 'Failed to load log',
          message: 'Could not load log details.',
          onRetry: () => ref.invalidate(allLogsProvider(tankId)),
        ),
      ),
      data: (logs) {
        final log = logs
            .where((l) => l.id == logId)
            .cast<LogEntry?>()
            .firstOrNull;
        if (log == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Log')),
            body: const Center(child: Text('Log not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(log.typeName),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddLogScreen(
                      tankId: tankId,
                      initialType: log.type,
                      existingLog: log,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(context, ref, log),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_iconFor(log.type), color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _titleFor(log),
                        style: AppTypography.headlineSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('MMM d, yyyy  •  h:mm a').format(log.timestamp),
                  style: AppTypography.bodySmall,
                ),

                const SizedBox(height: AppSpacing.md),

                if (log.type == LogType.waterTest && log.waterTest != null)
                  _WaterTestCard(test: log.waterTest!),

                if (log.type == LogType.waterChange)
                  _WaterChangeCard(percent: log.waterChangePercent),

                if (log.notes != null && log.notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text('Notes', style: AppTypography.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(log.notes!, style: AppTypography.bodyLarge),
                ],

                if (log.photoUrls != null && log.photoUrls!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text('Photos', style: AppTypography.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: log.photoUrls!.map((path) {
                      return ClipRRect(
                        borderRadius: AppRadius.mediumRadius,
                        child: CachedImage(
                          imagePath: path,
                          thumbnail: true,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorWidget: Container(
                            width: 120,
                            height: 120,
                            color: AppColors.surfaceVariant,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    LogEntry log,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete log?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await ref.read(storageServiceProvider).deleteLog(log.id);
    ref.invalidate(logsProvider(tankId));
    ref.invalidate(allLogsProvider(tankId));

    if (context.mounted) Navigator.pop(context);
  }

  static IconData _iconFor(LogType type) {
    switch (type) {
      case LogType.waterTest:
        return Icons.science;
      case LogType.waterChange:
        return Icons.water_drop;
      case LogType.feeding:
        return Icons.restaurant;
      case LogType.medication:
        return Icons.medication;
      case LogType.observation:
        return Icons.visibility;
      case LogType.livestockAdded:
        return Icons.add_circle;
      case LogType.livestockRemoved:
        return Icons.remove_circle;
      case LogType.equipmentMaintenance:
        return Icons.build;
      case LogType.taskCompleted:
        return Icons.task_alt;
      case LogType.other:
        return Icons.note;
    }
  }

  static String _titleFor(LogEntry log) {
    if (log.type == LogType.waterTest && log.waterTest != null) {
      final t = log.waterTest!;
      final parts = <String>[];
      if (t.temperature != null) {
        parts.add('${t.temperature!.toStringAsFixed(1)}°C');
      }
      if (t.ph != null) parts.add('pH ${t.ph!.toStringAsFixed(1)}');
      if (t.ammonia != null) parts.add('NH₃ ${t.ammonia}');
      if (t.nitrite != null) parts.add('NO₂ ${t.nitrite}');
      if (t.nitrate != null) parts.add('NO₃ ${t.nitrate}');
      if (parts.isNotEmpty) return parts.take(3).join(' • ');
    }

    if (log.type == LogType.waterChange) {
      return 'Water Change${log.waterChangePercent != null ? ' (${log.waterChangePercent}%)' : ''}';
    }

    if (log.type == LogType.taskCompleted) {
      return log.title != null ? 'Completed: ${log.title}' : 'Task completed';
    }

    return log.title ?? log.typeName;
  }
}

class _WaterTestCard extends StatelessWidget {
  final WaterTestResults test;

  const _WaterTestCard({required this.test});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Water Test', style: AppTypography.labelLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _kv('Temp', test.temperature?.toStringAsFixed(1), '°C'),
                _kv('pH', test.ph?.toStringAsFixed(1), null),
                _kv('NH₃', test.ammonia?.toStringAsFixed(2), 'ppm'),
                _kv('NO₂', test.nitrite?.toStringAsFixed(2), 'ppm'),
                _kv('NO₃', test.nitrate?.toStringAsFixed(0), 'ppm'),
                _kv('GH', test.gh?.toStringAsFixed(0), 'dGH'),
                _kv('KH', test.kh?.toStringAsFixed(0), 'dKH'),
                _kv('PO₄', test.phosphate?.toStringAsFixed(2), 'ppm'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String? v, String? unit) {
    final value = (v == null || v == 'null') ? '—' : v;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.mediumRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k, style: AppTypography.bodySmall),
          const SizedBox(height: 2),
          Text(
            unit == null ? value : '$value $unit',
            style: AppTypography.labelLarge,
          ),
        ],
      ),
    );
  }
}

class _WaterChangeCard extends StatelessWidget {
  final int? percent;

  const _WaterChangeCard({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Water Change', style: AppTypography.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              percent != null ? '$percent%' : '—',
              style: AppTypography.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
