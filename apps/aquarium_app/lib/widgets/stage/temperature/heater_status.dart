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
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3BBFB0), Color(0xFF2D7A94)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: kTempTeal.withAlpha(80),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
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
      child: ElevatedButton.icon(
        onPressed: () {
          AppRoutes.toAddLog(context, tankId, initialType: LogType.waterTest);
        },
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          'Log Temperature',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kTempAmberGold,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.md2Radius,
          ),
        ),
      ),
    );
  }
}
