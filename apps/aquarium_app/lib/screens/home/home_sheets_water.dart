import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../widgets/core/app_button.dart';
import '../../providers/tank_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_page_routes.dart';
import '../../utils/navigation_throttle.dart';
import '../add_log_screen.dart';
import 'home_sheets_helpers.dart' show timeAgo, buildParamRow;

/// Water parameters bottom sheet with ideal ranges and latest test results.
void showWaterParams(BuildContext context, WidgetRef ref, String? tankId) {
  if (tankId == null) return;

  final logsAsync = ref.read(logsProvider(tankId));
  final logs = logsAsync.valueOrNull ?? [];

  final waterTests = logs
      .where((l) => l.type == LogType.waterTest && l.waterTest != null)
      .toList();
  final latestTest = waterTests.isNotEmpty ? waterTests.first : null;
  final wt = latestTest?.waterTest;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg2),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: AppRadius.largeRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const Text('\u{1F9EA}', style: TextStyle(fontSize: 40)),
                const SizedBox(height: AppSpacing.sm),
                Semantics(
                  header: true,
                  child: Text('Water Parameters', style: AppTypography.headlineSmall),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm2),
            decoration: BoxDecoration(
              color: AppColors.accent.withAlpha(20),
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: AppColors.accent.withAlpha(60)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u{2705} Ideal Ranges (Freshwater)',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'pH 6.5-7.5  |  Ammonia 0 ppm  |  Nitrite 0 ppm  |  Nitrate <40 ppm',
                  style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (wt == null || !wt.hasValues) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Column(
                  children: [
                    Text('No test results yet 🧪', style: AppTypography.bodyMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Log your first water test to see results here!',
                      style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            buildParamRow(context, 'pH', wt.ph?.toStringAsFixed(1) ?? '--', '6.5 - 7.5'),
            buildParamRow(context, 'Ammonia', wt.ammonia != null ? '${wt.ammonia!.toStringAsFixed(2)} ppm' : '--', '0 ppm'),
            buildParamRow(context, 'Nitrite', wt.nitrite != null ? '${wt.nitrite!.toStringAsFixed(2)} ppm' : '--', '0 ppm'),
            buildParamRow(context, 'Nitrate', wt.nitrate != null ? '${wt.nitrate!.toStringAsFixed(1)} ppm' : '--', '<40 ppm'),
            const Divider(height: AppSpacing.lg),
            Text(
              'Last tested: ${timeAgo(latestTest!.timestamp)}',
              style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            '\u{1F41F} What this means for your fish',
            style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Stable water parameters are the single most important factor in fish health. Test weekly and after any changes to your tank.',
            style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            onPressed: () {
              Navigator.maybePop(ctx);
              NavigationThrottle.push(
                context,
                AddLogScreen(tankId: tankId, initialType: LogType.waterTest),
                route: RoomSlideRoute(page: AddLogScreen(tankId: tankId, initialType: LogType.waterTest)),
              );
            },
            label: 'Log Water Test',
            leadingIcon: Icons.science,
            isFullWidth: true,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    ),
  );
}
