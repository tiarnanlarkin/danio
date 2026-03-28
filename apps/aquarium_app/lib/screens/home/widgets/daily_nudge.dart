import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../theme/app_theme.dart';

/// Daily nudge banner shown when the user hasn't earned any XP today.
/// Only rebuilds when today's XP changes.
class DailyNudgeBanner extends ConsumerWidget {
  final VoidCallback onDismiss;

  const DailyNudgeBanner({super.key, required this.onDismiss});

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

    // P0-5 FIX: Push daily nudge below the streak/hearts overlay area
    // to prevent banner stacking at identical top positions.
    return Positioned(
      top: MediaQuery.of(context).padding.top + 100,
      left: 16,
      right: 16,
      child: Semantics(
        label: 'Dismiss daily nudge',
        button: true,
        child: GestureDetector(
        onTap: onDismiss,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm2,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryAlpha90,
            borderRadius: AppRadius.mediumRadius,
            boxShadow: [
              BoxShadow(
                color: AppOverlays.black20,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Text('\u{1F3AF}', style: Theme.of(context).textTheme.titleLarge!),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  fishName != null
                      ? "Learn something new for $fishName today!"
                      : "Start a quick lesson to earn XP today!",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                width: 48,
                height: 48,
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
