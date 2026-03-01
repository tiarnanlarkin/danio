import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/models.dart';
import '../../../widgets/core/app_card.dart';
import '../../../theme/app_theme.dart';

class QuickStats extends StatelessWidget {
  final Tank tank;
  final AsyncValue<List<LogEntry>> logsAsync;
  final AsyncValue<List<Livestock>>? livestockAsync;
  final AsyncValue<List<Equipment>>? equipmentAsync;

  const QuickStats({
    super.key,
    required this.tank,
    required this.logsAsync,
    this.livestockAsync,
    this.equipmentAsync,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Quick count chips bar
        _buildCountChips(),
        const SizedBox(height: AppSpacing.sm),
        // Main stats card
        AppCard(
          padding: AppCardPadding.standard,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatItem(
                    label: 'Volume',
                    value: '${tank.volumeLitres.toStringAsFixed(0)}L',
                    icon: Icons.straighten,
                  ),
                  StatItem(
                    label: 'Established',
                    value: _formatAgeLong(tank.startDate),
                    icon: Icons.calendar_today,
                  ),
                  logsAsync.when(
                    loading: () => const StatItem(
                      label: 'Last Test',
                      value: '...',
                      icon: Icons.science,
                    ),
                    error: (_, __) => const StatItem(
                      label: 'Last Test',
                      value: '-',
                      icon: Icons.science,
                    ),
                    data: (logs) {
                      final lastTest = logs
                          .where((l) => l.type == LogType.waterTest)
                          .firstOrNull;
                      return StatItem(
                        label: 'Last Test',
                        value: lastTest != null
                            ? _formatRelative(lastTest.timestamp)
                            : 'Never',
                        icon: Icons.science,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Water change indicator
              logsAsync.when(
                loading: () => const _WaterChangeIndicator(label: '...', isOverdue: false),
                error: (_, __) => const SizedBox.shrink(),
                data: (logs) {
                  final lastChange = logs
                      .where((l) => l.type == LogType.waterChange)
                      .firstOrNull;
                  if (lastChange == null) {
                    return const _WaterChangeIndicator(
                      label: 'No water changes logged',
                      isOverdue: true,
                    );
                  }
                  final days = DateTime.now().difference(lastChange.timestamp).inDays;
                  final isOverdue = days > 7;
                  final label = days == 0
                      ? 'Last water change: Today'
                      : days == 1
                          ? 'Last water change: Yesterday'
                          : 'Last water change: $days days ago';
                  return _WaterChangeIndicator(
                    label: label,
                    isOverdue: isOverdue,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountChips() {
    final fishCount = livestockAsync?.whenOrNull(
      data: (livestock) => livestock.fold<int>(0, (sum, l) => sum + l.count),
    );
    final equipCount = equipmentAsync?.whenOrNull(
      data: (equipment) => equipment.length,
    );

    final chips = <Widget>[];
    if (fishCount != null) {
      chips.add(_CountChip(icon: Icons.set_meal, label: '$fishCount fish'));
    }
    if (equipCount != null) {
      chips.add(_CountChip(icon: Icons.filter_alt, label: '$equipCount equipment'));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: AppSpacing.sm,
      children: chips,
    );
  }

  String _formatAgeLong(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return '1 day ago';
    if (days < 30) return '$days days ago';
    if (days < 365) {
      final months = (days / 30).floor();
      return '$months mo ago';
    }
    final years = (days / 365).floor();
    return '$years yr ago';
  }

  String _formatRelative(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return '1d ago';
    if (days < 7) return '${days}d ago';
    return DateFormat('MMM d').format(date);
  }
}

class _WaterChangeIndicator extends StatelessWidget {
  final String label;
  final bool isOverdue;

  const _WaterChangeIndicator({required this.label, required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isOverdue
            ? AppColors.warning.withValues(alpha: 0.12)
            : AppColors.success.withValues(alpha: 0.12),
        borderRadius: AppRadius.mediumRadius,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isOverdue ? Icons.warning_amber_rounded : Icons.water_drop,
            size: AppIconSizes.sm,
            color: isOverdue ? AppColors.warning : AppColors.success,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            isOverdue ? '$label \u26a0\ufe0f' : label,
            style: AppTypography.bodySmall.copyWith(
              color: isOverdue ? AppColors.warning : AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CountChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(label, style: AppTypography.bodySmall),
      backgroundColor: AppColors.primary.withValues(alpha: 0.08),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const StatItem({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: AppIconSizes.md),
        const SizedBox(height: AppSpacing.sm),
        Text(value, style: AppTypography.headlineSmall),
        Text(label, style: AppTypography.bodySmall),
      ],
    );
  }
}
