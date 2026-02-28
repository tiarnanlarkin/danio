/// Daily goal progress widget - circular progress indicator
/// Shows today's XP progress toward daily goal
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../models/daily_goal.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';

/// Circular progress indicator showing daily XP goal completion.
///
/// Displays current XP progress toward daily goal with percentage indicator
/// and optional label. Updates reactively as user earns XP throughout the day.
class DailyGoalProgress extends ConsumerWidget {
  final double size;
  final bool showLabel;

  const DailyGoalProgress({super.key, this.size = 80, this.showLabel = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyGoal = ref.watch(todaysDailyGoalProvider);

    if (dailyGoal == null) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _CircularProgressPainter(
              progress: dailyGoal.progress,
              isCompleted: dailyGoal.isCompleted,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${dailyGoal.earnedXp}',
                    style: TextStyle(
                      fontSize: size * 0.22,
                      fontWeight: FontWeight.bold,
                      color: dailyGoal.isCompleted
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                  ),
                  Text(
                    'XP',
                    style: TextStyle(
                      fontSize: size * 0.12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            dailyGoal.isCompleted
                ? 'Goal complete! 🎉'
                : 'Daily goal: ${dailyGoal.targetXp}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          if (!dailyGoal.isCompleted)
            Text(
              '${dailyGoal.remainingXp} XP to go',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ],
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final bool isCompleted;

  _CircularProgressPainter({required this.progress, required this.isCompleted});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 6;

    // Background circle
    final backgroundPaint = Paint()
      ..color = AppColors.surfaceVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: isCompleted
            ? [AppColors.success, const Color(0xFF66BB6A)]
            : [AppColors.primary, AppColors.secondary],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );

    // Completion glow effect
    if (isCompleted) {
      final glowPaint = Paint()
        ..color = AppColors.successAlpha30
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(center, radius, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isCompleted != isCompleted;
  }
}

/// Compact daily goal card for home screen
class DailyGoalCard extends ConsumerWidget {
  final VoidCallback? onTap;

  const DailyGoalCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyGoal = ref.watch(todaysDailyGoalProvider);

    if (dailyGoal == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppOverlays.white95,
            AppOverlays.white88,
          ],
        ),
        borderRadius: AppRadius.mediumRadius,
        boxShadow: [
          BoxShadow(
            color: AppOverlays.black8,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppOverlays.white60, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mediumRadius,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Circular progress
                DailyGoalProgress(size: 60, showLabel: false),
                const SizedBox(width: AppSpacing.md),

                // Text info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dailyGoal.isCompleted
                            ? 'Daily Goal Complete!'
                            : 'Today\'s Goal',
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: dailyGoal.isCompleted
                              ? AppColors.success
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        dailyGoal.isCompleted
                            ? '+${dailyGoal.bonusXp} bonus XP earned!'
                            : '${dailyGoal.earnedXp}/${dailyGoal.targetXp} XP',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (!dailyGoal.isCompleted) ...[
                        const SizedBox(height: AppSpacing.xs),
                        LinearProgressIndicator(
                          value: dailyGoal.progress,
                          backgroundColor: AppColors.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ],
                  ),
                ),

                // Icon
                Icon(
                  dailyGoal.isCompleted
                      ? Icons.check_circle
                      : Icons.trending_up,
                  color: dailyGoal.isCompleted
                      ? AppColors.success
                      : AppColors.primary,
                  size: AppIconSizes.md,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
