import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';

class TankCard extends ConsumerWidget {
  final Tank tank;
  final VoidCallback? onTap;

  const TankCard({
    super.key,
    required this.tank,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider(tank.id));
    final logsAsync = ref.watch(logsProvider(tank.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with tank image or gradient
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.8),
                    AppColors.secondary.withOpacity(0.6),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Tank icon
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Icon(
                      Icons.water,
                      size: 48,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  // Tank name
                  Positioned(
                    left: 16,
                    bottom: 16,
                    right: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tank.name,
                          style: AppTypography.headlineSmall.copyWith(
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${tank.volumeLitres.toStringAsFixed(0)}L • ${tank.type.name}',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick stats row
                  Row(
                    children: [
                      _StatChip(
                        icon: Icons.calendar_today,
                        label: _formatAge(tank.startDate),
                        tooltip: 'Tank age',
                      ),
                      const SizedBox(width: 8),
                      logsAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (logs) {
                          final lastTest = logs.where((l) => l.type == LogType.waterTest).firstOrNull;
                          if (lastTest == null) return const SizedBox.shrink();
                          return _StatChip(
                            icon: Icons.science_outlined,
                            label: _formatRelativeDate(lastTest.timestamp),
                            tooltip: 'Last water test',
                          );
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Tasks due
                  tasksAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (tasks) {
                      final overdue = tasks.where((t) => t.isOverdue && t.isEnabled).length;
                      final dueToday = tasks.where((t) => t.isDueToday && t.isEnabled).length;
                      
                      if (overdue == 0 && dueToday == 0) {
                        return Row(
                          children: [
                            Icon(Icons.check_circle, size: 16, color: AppColors.success),
                            const SizedBox(width: 6),
                            Text(
                              'All caught up!',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        );
                      }
                      
                      return Row(
                        children: [
                          if (overdue > 0) ...[
                            Icon(Icons.warning_amber, size: 16, color: AppColors.warning),
                            const SizedBox(width: 4),
                            Text(
                              '$overdue overdue',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (dueToday > 0) const SizedBox(width: 12),
                          ],
                          if (dueToday > 0) ...[
                            Icon(Icons.today, size: 16, color: AppColors.info),
                            const SizedBox(width: 4),
                            Text(
                              '$dueToday due today',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAge(DateTime startDate) {
    final days = DateTime.now().difference(startDate).inDays;
    if (days < 7) return '${days}d old';
    if (days < 30) return '${(days / 7).floor()}w old';
    if (days < 365) return '${(days / 30).floor()}mo old';
    return '${(days / 365).floor()}y old';
  }

  String _formatRelativeDate(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '${days}d ago';
    return DateFormat('MMM d').format(date);
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? tooltip;

  const _StatChip({
    required this.icon,
    required this.label,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: AppTypography.bodySmall),
        ],
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: chip);
    }
    return chip;
  }
}
