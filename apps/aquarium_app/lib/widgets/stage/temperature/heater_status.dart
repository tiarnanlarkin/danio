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
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF303435), Color(0xFF111314)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC89B3C).withValues(alpha: 0.72),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm2,
          vertical: AppSpacing.sm,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final title = Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      center: Alignment(-0.3, -0.35),
                      colors: [
                        Color(0xFFFFD983),
                        Color(0xFFC89B3C),
                        Color(0xFF50300C),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFFFFE0A0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.thermostat_rounded,
                    color: Color(0xFF102524),
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Temperature',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1.1,
                      shadows: const [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(0, 1),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
            final streakPlate = Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs2,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF0C0E0E),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: kTempAmberGold.withValues(alpha: 0.64),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '$streak-day streak',
                maxLines: 2,
                style: AppTypography.labelSmall.copyWith(
                  color: const Color(0xFFFFC861),
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 0.3,
                ),
              ),
            );

            if (streak <= 0) return title;
            if (constraints.maxWidth < 300) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  title,
                  const SizedBox(height: AppSpacing.xs),
                  Align(alignment: Alignment.centerRight, child: streakPlate),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: title),
                const SizedBox(width: AppSpacing.sm),
                streakPlate,
              ],
            );
          },
        ),
      ),
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
