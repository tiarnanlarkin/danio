import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_profile.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_theme.dart';
import '../practice_screen.dart';

/// Practice mode card shown on the Learn screen when lessons need review.
class LearnPracticeCard extends ConsumerWidget {
  final UserProfile profile;

  const LearnPracticeCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weakLessons = ref
        .read(userProfileProvider.notifier)
        .getWeakestLessons();
    final weakCount = weakLessons.length;

    if (weakCount == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      child: Semantics(
        button: true,
        label:
            'Practice Mode. $weakCount lesson${weakCount == 1 ? '' : 's'} need review. Review before you forget!',
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PracticeScreen()),
            );
          },
          borderRadius: AppRadius.mediumRadius,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppOverlays.primary80],
              ),
              borderRadius: AppRadius.mediumRadius,
              boxShadow: const [
                BoxShadow(
                  color: AppOverlays.primary30,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppOverlays.white20,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: AppColors.onPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Practice Mode',
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: AppRadius.mediumRadius,
                            ),
                            child: Text(
                              '$weakCount',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '$weakCount lesson${weakCount == 1 ? '' : 's'} need review',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppOverlays.white90,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Review before you forget!',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppOverlays.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.onPrimary,
                  size: AppIconSizes.sm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
