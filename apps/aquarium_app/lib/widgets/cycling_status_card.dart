import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

/// Cycling status for a tank
enum CyclingStatus {
  notStarted,
  earlyStage,
  midCycle,
  almostDone,
  cycled,
  unknown,
}

/// Simple cycling tracker based on tank age and water test history.
class CyclingStatusCard extends StatelessWidget {
  final Tank tank;
  final List<LogEntry> logs;

  const CyclingStatusCard({super.key, required this.tank, required this.logs});

  CyclingStatus _calculateStatus() {
    final tankAgeDays = DateTime.now().difference(tank.startDate).inDays;

    // Get water tests sorted by date
    final waterTests =
        logs
            .where((l) => l.type == LogType.waterTest && l.waterTest != null)
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (waterTests.isEmpty) {
      // No tests - estimate by tank age
      if (tankAgeDays < 7) return CyclingStatus.earlyStage;
      if (tankAgeDays < 21) return CyclingStatus.midCycle;
      if (tankAgeDays < 42) return CyclingStatus.almostDone;
      return CyclingStatus.unknown;
    }

    // Get the most recent test
    final latest = waterTests.first.waterTest!;

    // Check ammonia and nitrite
    final ammonia = latest.ammonia ?? 0;
    final nitrite = latest.nitrite ?? 0;
    final nitrate = latest.nitrate;

    // Cycled: ammonia = 0, nitrite = 0, nitrate present
    if (ammonia < 0.25 && nitrite < 0.25 && nitrate != null && nitrate > 0) {
      return CyclingStatus.cycled;
    }

    // Almost done: ammonia dropping, some nitrate
    if (ammonia < 0.5 && nitrite < 1 && nitrate != null) {
      return CyclingStatus.almostDone;
    }

    // Mid cycle: ammonia present, nitrite rising
    if (ammonia > 0 || nitrite > 0.25) {
      return CyclingStatus.midCycle;
    }

    // Early stage: ammonia present, no nitrite yet
    if (ammonia > 0 && nitrite < 0.25) {
      return CyclingStatus.earlyStage;
    }

    // If tank is old but we can't determine, assume cycled
    if (tankAgeDays > 60) {
      return CyclingStatus.cycled;
    }

    return CyclingStatus.unknown;
  }

  @override
  Widget build(BuildContext context) {
    final status = _calculateStatus();
    final tankAgeDays = DateTime.now().difference(tank.startDate).inDays;

    // Don't show for tanks older than 90 days that are cycled
    if (status == CyclingStatus.cycled && tankAgeDays > 90) {
      return const SizedBox.shrink();
    }

    // Don't show if status is unknown and tank is old
    if (status == CyclingStatus.unknown && tankAgeDays > 60) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusIcon(status: status),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusTitle(status),
                        style: AppTypography.labelLarge,
                      ),
                      Text(
                        _statusSubtitle(status, tankAgeDays),
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _CyclingProgressBar(status: status),
            const SizedBox(height: 12),
            Text(_statusAdvice(status), style: AppTypography.bodySmall),
          ],
        ),
      ),
    );
  }

  String _statusTitle(CyclingStatus status) {
    switch (status) {
      case CyclingStatus.notStarted:
        return 'Cycling Not Started';
      case CyclingStatus.earlyStage:
        return 'Early Cycling Stage';
      case CyclingStatus.midCycle:
        return 'Mid-Cycle';
      case CyclingStatus.almostDone:
        return 'Almost Cycled!';
      case CyclingStatus.cycled:
        return 'Tank is Cycled ✓';
      case CyclingStatus.unknown:
        return 'Cycling Status Unknown';
    }
  }

  String _statusSubtitle(CyclingStatus status, int days) {
    switch (status) {
      case CyclingStatus.notStarted:
        return 'Add an ammonia source to begin';
      case CyclingStatus.earlyStage:
        return 'Day $days — ammonia is being produced';
      case CyclingStatus.midCycle:
        return 'Day $days — beneficial bacteria growing';
      case CyclingStatus.almostDone:
        return 'Day $days — almost there!';
      case CyclingStatus.cycled:
        return 'Safe to add fish gradually';
      case CyclingStatus.unknown:
        return 'Log water tests to track progress';
    }
  }

  String _statusAdvice(CyclingStatus status) {
    switch (status) {
      case CyclingStatus.notStarted:
        return 'Add fish food or pure ammonia to start the nitrogen cycle. Test water every 2-3 days.';
      case CyclingStatus.earlyStage:
        return 'Ammonia-eating bacteria are colonizing. Don\'t add fish yet. Keep testing every 2-3 days.';
      case CyclingStatus.midCycle:
        return 'Nitrite is appearing as ammonia converts. This is normal! Continue testing and be patient.';
      case CyclingStatus.almostDone:
        return 'Nitrite is dropping and nitrate is rising. You\'re almost there! A few more days.';
      case CyclingStatus.cycled:
        return 'Your tank can now process ammonia → nitrite → nitrate. Add fish slowly over several weeks.';
      case CyclingStatus.unknown:
        return 'Log regular water tests (ammonia, nitrite, nitrate) to track your cycling progress.';
    }
  }
}

class _StatusIcon extends StatelessWidget {
  final CyclingStatus status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case CyclingStatus.notStarted:
        color = AppColors.textHint;
        icon = Icons.hourglass_empty;
        break;
      case CyclingStatus.earlyStage:
        color = AppColors.warning;
        icon = Icons.science;
        break;
      case CyclingStatus.midCycle:
        color = AppColors.paramWarning;
        icon = Icons.autorenew;
        break;
      case CyclingStatus.almostDone:
        color = AppColors.info;
        icon = Icons.trending_up;
        break;
      case CyclingStatus.cycled:
        color = AppColors.success;
        icon = Icons.check_circle;
        break;
      case CyclingStatus.unknown:
        color = AppColors.textHint;
        icon = Icons.help_outline;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _CyclingProgressBar extends StatelessWidget {
  final CyclingStatus status;

  const _CyclingProgressBar({required this.status});

  double get _progress {
    switch (status) {
      case CyclingStatus.notStarted:
        return 0.0;
      case CyclingStatus.earlyStage:
        return 0.25;
      case CyclingStatus.midCycle:
        return 0.5;
      case CyclingStatus.almostDone:
        return 0.75;
      case CyclingStatus.cycled:
        return 1.0;
      case CyclingStatus.unknown:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (status == CyclingStatus.unknown) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: AppRadius.xsRadius,
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation(
              status == CyclingStatus.cycled
                  ? AppColors.success
                  : AppColors.primary,
            ),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Start', style: AppTypography.bodySmall),
            Text('Ammonia', style: AppTypography.bodySmall),
            Text('Nitrite', style: AppTypography.bodySmall),
            Text('Cycled', style: AppTypography.bodySmall),
          ],
        ),
      ],
    );
  }
}
