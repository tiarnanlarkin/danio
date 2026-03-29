import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/spaced_repetition_provider.dart';
import '../../theme/app_theme.dart';
import '../spaced_repetition_practice_screen.dart';

/// Banner shown on the Learn screen when spaced repetition cards are due.
class LearnReviewBanner extends ConsumerWidget {
  const LearnReviewBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Select only dueCards to avoid rebuilds on card-list or session changes.
    final dueCount = ref.watch(
      spacedRepetitionProvider.select((s) => s.stats.dueCards),
    );

    if (dueCount == 0) return const SizedBox.shrink();

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
            'Time to Review! You have $dueCount card${dueCount == 1 ? '' : 's'} ready to review. Tap to start practicing.',
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SpacedRepetitionPracticeScreen(),
              ),
            );
          },
          borderRadius: AppRadius.mediumRadius,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accent, AppOverlays.accent80],
              ),
              borderRadius: AppRadius.mediumRadius,
              boxShadow: const [
                BoxShadow(
                  color: AppOverlays.accent30,
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
                    Icons.notifications_active,
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
                            '🔔 ',
                            style: Theme.of(context).textTheme.titleLarge!,
                          ),
                          Text(
                            'Time to Review!',
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'You have $dueCount card${dueCount == 1 ? '' : 's'} ready to review',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppOverlays.white90,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Tap to start practicing',
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
