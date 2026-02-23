import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/models.dart';
import '../../../widgets/core/app_card.dart';
import '../../../theme/app_theme.dart';

class QuickStats extends StatelessWidget {
  final Tank tank;
  final AsyncValue<List<LogEntry>> logsAsync;

  const QuickStats({super.key, required this.tank, required this.logsAsync});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppCardPadding.standard,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          StatItem(
            label: 'Volume',
            value: '${tank.volumeLitres.toStringAsFixed(0)}L',
            icon: Icons.straighten,
          ),
          StatItem(
            label: 'Age',
            value: _formatAge(tank.startDate),
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
    );
  }

  String _formatAge(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days < 7) return '${days}d';
    if (days < 30) return '${(days / 7).floor()}w';
    if (days < 365) return '${(days / 30).floor()}mo';
    return '${(days / 365).floor()}y';
  }

  String _formatRelative(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return '1d ago';
    if (days < 7) return '${days}d ago';
    return DateFormat('MMM d').format(date);
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
