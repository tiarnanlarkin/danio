/// Tank Health Score card - displays a 0-100 circular gauge
/// showing overall tank health based on water changes, params, and activity.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../models/log_entry.dart';
import '../../../models/tank.dart';
import '../../../services/tank_health_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/core/app_card.dart';

class TankHealthCard extends StatelessWidget {
  final Tank tank;
  final List<LogEntry> logs;

  const TankHealthCard({
    super.key,
    required this.tank,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    final health = TankHealthService.calculateScore(tank: tank, logs: logs);
    final theme = Theme.of(context);

    final Color scoreColor;
    switch (health.level) {
      case TankHealthLevel.excellent:
        scoreColor = AppColors.success;
      case TankHealthLevel.good:
        scoreColor = AppColors.warning;
      case TankHealthLevel.fair:
        scoreColor = DanioColors.coralAccent;
      case TankHealthLevel.poor:
        scoreColor = AppColors.error;
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.monitor_heart_outlined,
                  size: AppIconSizes.sm, color: scoreColor),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Tank Health Score',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: scoreColor.withAlpha(25),
                  borderRadius: AppRadius.smallRadius,
                ),
                child: Text(
                  health.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Score gauge + factors
          Row(
            children: [
              // Circular gauge
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: _HealthGaugePainter(
                    score: health.score,
                    color: scoreColor,
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${health.score}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scoreColor,
                          ),
                        ),
                        Text(
                          '/100',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),

              // Factor bullets
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: health.factors.take(4).map((factor) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _factorIcon(factor),
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              factor,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: context.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 400.ms,
        );
  }

  String _factorIcon(String factor) {
    if (factor.contains('great') || factor.contains('Excellent')) {
      return '\u2705'; // check
    }
    if (factor.contains('overdue') || factor.contains('dangerous') ||
        factor.contains('At Risk') || factor.contains('very high')) {
      return '\u26A0\uFE0F'; // warning
    }
    if (factor.contains('No ')) {
      return '\u2139\uFE0F'; // info
    }
    return '\u2022'; // bullet
  }
}

class _HealthGaugePainter extends CustomPainter {
  final int score;
  final Color color;
  final Color backgroundColor;

  _HealthGaugePainter({
    required this.score,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 10.0;
    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    // Background arc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Score arc
    final scorePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final scoreSweep = sweepAngle * (score / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      scoreSweep,
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HealthGaugePainter oldDelegate) =>
      oldDelegate.score != score || oldDelegate.color != color;
}
