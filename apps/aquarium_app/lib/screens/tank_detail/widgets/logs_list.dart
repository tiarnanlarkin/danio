import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../models/models.dart';
import '../../../widgets/core/app_card.dart';
import '../../../widgets/empty_state.dart';
import '../../../theme/app_theme.dart';

class LogsList extends StatelessWidget {
  final List<LogEntry> logs;
  final ValueChanged<LogEntry>? onTap;

  const LogsList({super.key, required this.logs, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: AppCard(
          padding: AppCardPadding.spacious,
          child: CompactEmptyState(
            icon: Icons.history,
            message: 'No activity logged yet',
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: AppCard(
        padding: AppCardPadding.none,
        child: Column(
          children: logs
              .asMap()
              .entries
              .map(
                (entry) => LogTile(log: entry.value, onTap: onTap)
                    .animate()
                    .fadeIn(delay: (50 * entry.key).ms, duration: 300.ms)
                    .slideX(begin: 0.1, end: 0, delay: (50 * entry.key).ms, duration: 300.ms),
              )
              .toList(),
        ),
      ),
    );
  }
}

class LogTile extends StatelessWidget {
  final LogEntry log;
  final ValueChanged<LogEntry>? onTap;

  const LogTile({super.key, required this.log, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getLogColor(log.type).withAlpha(51),
        child: Icon(
          _getLogIcon(log.type),
          color: _getLogColor(log.type),
          size: AppIconSizes.sm,
        ),
      ),
      title: Text(_getLogTitle(log)),
      subtitle: Text(DateFormat('MMM d, h:mm a').format(log.timestamp)),
      onTap: () => onTap?.call(log),
    );
  }

  IconData _getLogIcon(LogType type) {
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

  Color _getLogColor(LogType type) {
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
      case LogType.taskCompleted:
        return AppColors.success;
      case LogType.other:
        return AppColors.textHint;
    }
  }

  String _getLogTitle(LogEntry log) {
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
      case LogType.taskCompleted:
        return log.title != null ? 'Completed: ${log.title}' : 'Task completed';
      default:
        return log.title ?? log.typeName;
    }
  }
}
