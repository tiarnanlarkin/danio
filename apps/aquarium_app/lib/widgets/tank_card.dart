import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';

class TankCard extends ConsumerWidget {
  final Tank tank;
  final VoidCallback? onTap;

  const TankCard({super.key, required this.tank, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider(tank.id));
    final logsAsync = ref.watch(logsProvider(tank.id));
    final equipmentAsync = ref.watch(equipmentProvider(tank.id));

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
                          final lastTest = logs
                              .where((l) => l.type == LogType.waterTest)
                              .firstOrNull;
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

                  // Status badges
                  _StatusBadgesRow(
                    tasksAsync: tasksAsync,
                    logsAsync: logsAsync,
                    equipmentAsync: equipmentAsync,
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

  const _StatChip({required this.icon, required this.label, this.tooltip});

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

/// Consolidated status badges for tank card
class _StatusBadgesRow extends StatelessWidget {
  final AsyncValue<List<Task>> tasksAsync;
  final AsyncValue<List<LogEntry>> logsAsync;
  final AsyncValue<List<Equipment>> equipmentAsync;

  const _StatusBadgesRow({
    required this.tasksAsync,
    required this.logsAsync,
    required this.equipmentAsync,
  });

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[];

    // Task badges
    tasksAsync.whenData((tasks) {
      final overdue = tasks.where((t) => t.isOverdue && t.isEnabled).length;
      final dueToday = tasks
          .where((t) => t.isDueToday && t.isEnabled && !t.isOverdue)
          .length;

      if (overdue > 0) {
        badges.add(
          _Badge(
            icon: Icons.warning_amber,
            label: '$overdue overdue',
            color: AppColors.warning,
          ),
        );
      }
      if (dueToday > 0) {
        badges.add(
          _Badge(
            icon: Icons.today,
            label: '$dueToday today',
            color: AppColors.info,
          ),
        );
      }
    });

    // Equipment maintenance badges
    equipmentAsync.whenData((equipment) {
      final maintenanceDue = equipment
          .where((e) => e.isMaintenanceOverdue)
          .length;
      if (maintenanceDue > 0) {
        badges.add(
          _Badge(
            icon: Icons.build,
            label: '$maintenanceDue service due',
            color: AppColors.warning,
          ),
        );
      }
    });

    // Test overdue badge
    logsAsync.whenData((logs) {
      final lastTest = logs
          .where((l) => l.type == LogType.waterTest)
          .firstOrNull;
      if (lastTest != null) {
        final daysSinceTest = DateTime.now()
            .difference(lastTest.timestamp)
            .inDays;
        if (daysSinceTest >= 14) {
          badges.add(
            _Badge(
              icon: Icons.science_outlined,
              label: 'Test overdue',
              color: AppColors.info,
            ),
          );
        }
      } else {
        // No tests at all
        badges.add(
          _Badge(
            icon: Icons.science_outlined,
            label: 'No tests yet',
            color: AppColors.textHint,
          ),
        );
      }
    });

    // If no badges, show all good
    if (badges.isEmpty) {
      return Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: AppColors.success),
          const SizedBox(width: 6),
          Text(
            'All caught up!',
            style: AppTypography.bodySmall.copyWith(color: AppColors.success),
          ),
        ],
      );
    }

    return Wrap(spacing: 8, runSpacing: 6, children: badges);
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
