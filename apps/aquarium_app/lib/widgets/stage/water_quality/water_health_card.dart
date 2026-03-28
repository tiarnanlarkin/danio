import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import 'water_param_card.dart';

// ── Overall health ────────────────────────────────────────────────────────────

enum WqHealthStatus { excellent, good, needsAttention, noData }

WqHealthStatus wqComputeHealth(List<WqParamStatus> statuses) {
  final known = statuses.where((s) => s != WqParamStatus.unknown).toList();
  if (known.isEmpty) return WqHealthStatus.noData;
  if (known.any((s) => s == WqParamStatus.danger)) {
    return WqHealthStatus.needsAttention;
  }
  if (known.any((s) => s == WqParamStatus.watch)) return WqHealthStatus.good;
  return WqHealthStatus.excellent;
}

String wqHealthLabel(WqHealthStatus h) => switch (h) {
  WqHealthStatus.excellent => 'Excellent',
  WqHealthStatus.good => 'Good',
  WqHealthStatus.needsAttention => 'Needs Attention',
  WqHealthStatus.noData => 'No Data',
};

Color wqHealthColor(WqHealthStatus h) => switch (h) {
  WqHealthStatus.excellent => kWqGreen,
  WqHealthStatus.good => kWqAmber,
  WqHealthStatus.needsAttention => kWqRed,
  WqHealthStatus.noData => kWqGrey,
};

double wqHealthScore(WqHealthStatus h) => switch (h) {
  WqHealthStatus.excellent => 1.0,
  WqHealthStatus.good => 0.65,
  WqHealthStatus.needsAttention => 0.3,
  WqHealthStatus.noData => 0.0,
};

// ── Health Score Card ─────────────────────────────────────────────────────────

class WqHealthScoreCard extends StatelessWidget {
  final WqHealthStatus health;
  final AnimationController ringAnim;

  const WqHealthScoreCard({
    super.key,
    required this.health,
    required this.ringAnim,
  });

  @override
  Widget build(BuildContext context) {
    final color = wqHealthColor(health);
    final score = wqHealthScore(health);
    final label = wqHealthLabel(health);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.whiteAlpha70,
        borderRadius: AppRadius.largeRadius,
        border: Border.all(color: color.withAlpha(60)),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Progress ring
          SizedBox(
            width: 72,
            height: 72,
            child: AnimatedBuilder(
              animation: ringAnim,
              builder: (context, _) {
                final animScore =
                    Curves.easeOutCubic.transform(ringAnim.value) * score;
                return CustomPaint(
                  painter: WqProgressRingPainter(
                    progress: animScore,
                    color: color,
                  ),
                  child: Center(
                    child: Text(
                      health == WqHealthStatus.noData
                          ? '--'
                          : '${(score * 100).round()}%',
                      style: AppTypography.labelLarge.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Water Health',
                  style: AppTypography.bodySmall.copyWith(
                    color: kWqCharcoal.withAlpha(120),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: AppTypography.titleMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  health == WqHealthStatus.noData
                      ? 'Log a water test to get started'
                      : health == WqHealthStatus.excellent
                      ? 'All parameters in range 🎉'
                      : health == WqHealthStatus.good
                      ? 'Some parameters need watching'
                      : 'Action required — check parameters',
                  style: AppTypography.bodySmall.copyWith(
                    color: kWqCharcoal.withAlpha(140),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Perfect Badge ─────────────────────────────────────────────────────────────

class WqPerfectBadge extends StatelessWidget {
  const WqPerfectBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: kWqGreen,
        borderRadius: AppRadius.largeRadius,
        boxShadow: [
          BoxShadow(
            color: kWqGreen.withAlpha(100),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🐟', style: TextStyle(fontSize: 22)),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Perfect!',
            style: AppTypography.titleSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Text('✨', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

// ── Progress Ring Painter ─────────────────────────────────────────────────────

class WqProgressRingPainter extends CustomPainter {
  final double progress; // 0.0 – 1.0
  final Color color;

  const WqProgressRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 6;
    const startAngle = -math.pi / 2;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: centre, radius: radius),
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = color.withAlpha(30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: centre, radius: radius),
        startAngle,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WqProgressRingPainter old) =>
      old.progress != progress || old.color != color;
}
