import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../navigation/app_routes.dart';
import '../../../models/log_entry.dart';
import '../../../theme/app_theme.dart';
import 'temperature_gauge.dart';

// ── Header ────────────────────────────────────────────────────────────────────

class TempHeader extends StatelessWidget {
  final int streak;
  final Color foregroundColor;

  const TempHeader({
    super.key,
    required this.streak,
    this.foregroundColor = kTempCharcoal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: kTempTeal,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.thermostat_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Temperature',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleMedium.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        if (streak > 0) ...[
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm3,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: kTempAmberGold.withAlpha(30),
              borderRadius: AppRadius.pillRadius,
              border: Border.all(color: kTempAmberGold.withAlpha(80)),
            ),
            child: Text(
              '🔥 $streak-day streak',
              maxLines: 2,
              style: AppTypography.labelSmall.copyWith(
                color: kTempAmberGold,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Log Button ────────────────────────────────────────────────────────────────

class TempLogButton extends ConsumerWidget {
  final String tankId;

  const TempLogButton({super.key, required this.tankId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () {
          AppRoutes.toAddLog(context, tankId, initialType: LogType.waterTest);
        },
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text(
          'Log Temperature',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: kTempCharcoal,
          side: const BorderSide(color: kTempAmberGold, width: 1.5),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
      ),
    );
  }
}

// ── Heater Status Pill ────────────────────────────────────────────────────────

class HeaterStatusPill extends StatelessWidget {
  final bool heaterOn;
  final String? lastTestLabel;

  const HeaterStatusPill({
    super.key,
    required this.heaterOn,
    required this.lastTestLabel,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = heaterOn
        ? const Color(0xFFE67E22)
        : const Color(0xFF9E9E9E);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm2,
        vertical: AppSpacing.xs2,
      ),
      decoration: BoxDecoration(
        color: AppColors.whiteAlpha50,
        borderRadius: AppRadius.pillRadius,
        border: Border.all(color: dotColor.withValues(alpha: 0.35)),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 4,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          ),
          Text(
            heaterOn ? 'Heater ON' : 'Heater OFF',
            style: AppTypography.labelSmall.copyWith(
              color: const Color(0xFF2D3436),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (lastTestLabel != null) ...[
            Text(
              '•',
              style: AppTypography.labelSmall.copyWith(
                color: const Color(0xFF2D3436).withValues(alpha: 0.4),
              ),
            ),
            Text(
              'Last test: $lastTestLabel',
              style: AppTypography.labelSmall.copyWith(
                color: const Color(0xFF2D3436).withValues(alpha: 0.65),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
