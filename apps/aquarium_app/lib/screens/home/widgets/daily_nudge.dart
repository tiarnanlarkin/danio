import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../theme/app_theme.dart';

/// Daily nudge banner shown when the user hasn't earned any XP today.
/// Only rebuilds when today's XP changes.
///
/// Positioned in the shared notification slot below the top bar. The
/// [topOffset] parameter is added to `MediaQuery.padding.top` so the parent
/// can keep multiple banners aligned on the same horizontal anchor.
class DailyNudgeBanner extends ConsumerWidget {
  final VoidCallback onDismiss;
  final double topOffset;

  const DailyNudgeBanner({
    super.key,
    required this.onDismiss,
    this.topOffset = 100,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayKey = DateTime.now().toIso8601String().split('T')[0];
    final todayXp = ref.watch(
      userProfileProvider.select((p) => p.value?.dailyXpHistory[todayKey] ?? 0),
    );
    final fishName = ref.watch(
      userProfileProvider.select((p) => p.value?.firstFishSpeciesId),
    );
    if (todayXp > 0) return const SizedBox.shrink();

    return Positioned(
      top: MediaQuery.of(context).padding.top + topOffset,
      left: AppSpacing.md,
      right: AppSpacing.md,
      child: Semantics(
        label: 'Dismiss daily nudge',
        button: true,
        child: GestureDetector(
          onTap: onDismiss,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm2,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryAlpha90,
              borderRadius: AppRadius.lg2Radius,
              boxShadow: AppShadows.medium,
            ),
            child: Row(
              children: [
                const Text(
                  '\u{1F3AF}',
                  style: TextStyle(fontSize: 22, height: 1),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    fishName != null
                        ? "Learn something new for $fishName today!"
                        : "Start a quick lesson to earn XP today!",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.onPrimary.withAlpha(180),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
