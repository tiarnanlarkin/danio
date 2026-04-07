import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../navigation/app_routes.dart';
import '../../../models/log_entry.dart';
import '../../../theme/app_theme.dart';
import 'temperature_gauge.dart';

// ── Header ────────────────────────────────────────────────────────────────────

class TempHeader extends StatelessWidget {
  final int streak;

  const TempHeader({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
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
        Text(
          'Temperature',
          style: AppTypography.titleMedium.copyWith(
            color: kTempCharcoal,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        if (streak > 0)
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text(
                  '$streak-day streak',
                  style: AppTypography.labelSmall.copyWith(
                    color: kTempAmberGold,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
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
    final dotColor =
        heaterOn ? const Color(0xFFE67E22) : const Color(0xFF9E9E9E);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm2,
        vertical: AppSpacing.xs2,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: AppRadius.pillRadius,
        border: Border.all(color: dotColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          ),
          const SizedBox(width: 6),
          Text(
            heaterOn ? 'Heater ON' : 'Heater OFF',
            style: AppTypography.labelSmall.copyWith(
              color: const Color(0xFF2D3436),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (lastTestLabel != null) ...[
            const SizedBox(width: 8),
            Text('•',
                style: AppTypography.labelSmall.copyWith(
                  color: const Color(0xFF2D3436).withValues(alpha: 0.4),
                )),
            const SizedBox(width: 8),
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
