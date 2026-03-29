import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/core/app_button.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_page_routes.dart';
import '../../utils/navigation_throttle.dart';
import '../add_log_screen.dart';
import 'home_sheets_helpers.dart' show timeAgo, buildParamRow;

/// Feeding info bottom sheet with guidelines and recent feed count.
/// [logs] should be the already-watched value from logsProvider(tankId).
void showFeedingInfo(BuildContext context, List<LogEntry> logs, String? tankId) {
  if (tankId == null) return;

  final feedings = logs.where((l) => l.type == LogType.feeding).toList();
  final latestFeeding = feedings.isNotEmpty ? feedings.first : null;

  final today = DateTime.now();
  final feedingsToday = feedings
      .where((l) =>
          l.timestamp.year == today.year &&
          l.timestamp.month == today.month &&
          l.timestamp.day == today.day)
      .length;

  showAppBottomSheet(
    context: context,
    child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const Text('\u{1F3A3}', style: TextStyle(fontSize: 40)),
                const SizedBox(height: AppSpacing.sm),
                Semantics(
                  header: true,
                  child: Text('Feeding', style: AppTypography.headlineSmall),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm2),
            decoration: BoxDecoration(
              color: AppColors.secondary.withAlpha(20),
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: AppColors.secondary.withAlpha(60)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u{1F4CB} Feeding Guidelines',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Feed 2-3 times daily  |  Only what they eat in 2 min  |  Variety is key',
                  style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          buildParamRow(context, 'Fed today', '$feedingsToday time${feedingsToday == 1 ? '' : 's'}', '2-3x'),
          buildParamRow(context, 'Last fed', latestFeeding != null ? timeAgo(latestFeeding.timestamp) : 'Not yet', ''),
          const SizedBox(height: AppSpacing.md),
          Text(
            '\u{1F41F} What this means for your fish',
            style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Overfeeding is the #1 cause of water quality issues. Feed small amounts your fish can finish in 2 minutes.',
            style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            onPressed: () {
              Navigator.maybePop(context);
              NavigationThrottle.push(
                context,
                AddLogScreen(tankId: tankId, initialType: LogType.feeding),
                route: RoomSlideRoute(page: AddLogScreen(tankId: tankId, initialType: LogType.feeding)),
              );
            },
            label: 'Log Feeding',
            leadingIcon: Icons.restaurant,
            isFullWidth: true,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
  );
}

/// Plant care tips bottom sheet.
void showPlantInfo(BuildContext context) {
  showAppBottomSheet(
    context: context,
    child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const Text('\u{1FAB4}', style: TextStyle(fontSize: 40)),
                const SizedBox(height: AppSpacing.sm),
                Semantics(
                  header: true,
                  child: Text('Tank Plants', style: AppTypography.headlineSmall),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm2),
            decoration: BoxDecoration(
              color: DanioColors.emeraldGreen.withAlpha(20),
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: DanioColors.emeraldGreen.withAlpha(60)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u{2728} Plant Care Tips',
                  style: AppTypography.labelMedium.copyWith(
                    color: DanioColors.emeraldGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '8-10 hrs light daily  |  Trim dead leaves  |  Root tabs for heavy feeders',
                  style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '\u{1F41F} What this means for your fish',
            style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Live plants absorb nitrates, produce oxygen, and provide shelter. They are one of the best things you can add to any tank.',
            style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '\u{1F4A1} Pro tip: Use old tank water to water your houseplants — packed with nutrients!',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
  );
}
