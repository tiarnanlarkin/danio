import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';
import 'add_log_screen.dart';
import 'log_detail_screen.dart';

class LogsScreen extends ConsumerStatefulWidget {
  final String tankId;

  const LogsScreen({super.key, required this.tankId});

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  LogType? _filter; // null = all

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(allLogsProvider(widget.tankId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Log'),
        actions: [
          PopupMenuButton<LogType?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onSelected: (v) => setState(() => _filter = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('All')),
              ...LogType.values.map(
                (t) => PopupMenuItem(value: t, child: Text(_typeName(t))),
              ),
            ],
          ),
        ],
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (logs) {
          final filtered = _filter == null
              ? logs
              : logs.where((l) => l.type == _filter).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.list_alt, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('No logs yet', style: AppTypography.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Start logging tests and events', style: AppTypography.bodyMedium),
                ],
              ),
            );
          }

          // Already returned descending by storage; keep that order.
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final log = filtered[index];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getLogColor(log.type).withOpacity(0.2),
                    child: Icon(_getLogIcon(log.type), color: _getLogColor(log.type), size: 20),
                  ),
                  title: Text(_titleFor(log)),
                  subtitle: Text(DateFormat('MMM d, yyyy  •  h:mm a').format(log.timestamp)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LogDetailScreen(tankId: widget.tankId, logId: log.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Log',
        child: const Icon(Icons.add),
        onPressed: () => _showAddLogSheet(context),
      ),
    );
  }

  void _showAddLogSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.science),
              title: const Text('Water Test'),
              onTap: () {
                Navigator.pop(ctx);
                _openAdd(context, LogType.waterTest);
              },
            ),
            ListTile(
              leading: const Icon(Icons.water_drop),
              title: const Text('Water Change'),
              onTap: () {
                Navigator.pop(ctx);
                _openAdd(context, LogType.waterChange);
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Observation'),
              onTap: () {
                Navigator.pop(ctx);
                _openAdd(context, LogType.observation);
              },
            ),
            ListTile(
              leading: const Icon(Icons.medication),
              title: const Text('Medication'),
              onTap: () {
                Navigator.pop(ctx);
                _openAdd(context, LogType.medication);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openAdd(BuildContext context, LogType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddLogScreen(tankId: widget.tankId, initialType: type),
      ),
    );
  }

  static String _typeName(LogType type) {
    switch (type) {
      case LogType.waterTest:
        return 'Water Test';
      case LogType.waterChange:
        return 'Water Change';
      case LogType.feeding:
        return 'Feeding';
      case LogType.medication:
        return 'Medication';
      case LogType.observation:
        return 'Observation';
      case LogType.livestockAdded:
        return 'Livestock Added';
      case LogType.livestockRemoved:
        return 'Livestock Removed';
      case LogType.equipmentMaintenance:
        return 'Equipment Maintenance';
      case LogType.other:
        return 'Other';
    }
  }

  static IconData _getLogIcon(LogType type) {
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
      case LogType.other:
        return Icons.note;
    }
  }

  static Color _getLogColor(LogType type) {
    switch (type) {
      case LogType.waterTest:
        return AppColors.primary;
      case LogType.waterChange:
        return AppColors.secondary;
      case LogType.feeding:
        return Colors.orange;
      case LogType.medication:
        return Colors.red;
      case LogType.observation:
        return Colors.purple;
      case LogType.livestockAdded:
        return AppColors.success;
      case LogType.livestockRemoved:
        return AppColors.error;
      case LogType.equipmentMaintenance:
        return Colors.brown;
      case LogType.other:
        return AppColors.textHint;
    }
  }

  static String _titleFor(LogEntry log) {
    switch (log.type) {
      case LogType.waterTest:
        final test = log.waterTest;
        if (test != null) {
          final parts = <String>[];
          if (test.ammonia != null) parts.add('NH₃: ${test.ammonia}');
          if (test.nitrite != null) parts.add('NO₂: ${test.nitrite}');
          if (test.nitrate != null) parts.add('NO₃: ${test.nitrate}');
          if (test.ph != null) parts.add('pH: ${test.ph}');
          if (parts.isNotEmpty) return parts.take(2).join(', ');
        }
        return 'Water Test';
      case LogType.waterChange:
        return 'Water Change${log.waterChangePercent != null ? ' (${log.waterChangePercent}%)' : ''}';
      default:
        return log.title ?? log.typeName;
    }
  }
}
