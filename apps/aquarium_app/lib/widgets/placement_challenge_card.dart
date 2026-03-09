/// Optional placement test challenge card for the Learn tab.
/// Shown to intermediate/expert users who haven't taken or skipped the test.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../providers/user_profile_provider.dart';
import '../screens/onboarding/enhanced_placement_test_screen.dart';
import '../theme/app_theme.dart';

class PlacementChallengeCard extends ConsumerWidget {
  const PlacementChallengeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();
        if (profile.experienceLevel == ExperienceLevel.beginner) {
          return const SizedBox.shrink();
        }
        if (profile.hasCompletedPlacementTest ||
            profile.hasSkippedPlacementTest) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            0,
          ),
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppOverlays.accent10,
                AppOverlays.amber20,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(color: AppOverlays.accent30),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppOverlays.accent20,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.set_meal_rounded,
                      color: AppColors.accent,
                      size: AppIconSizes.md,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Test your knowledge',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'Take a quick placement test to unlock your level',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EnhancedPlacementTestScreen(
                              source: 'learn_tab',
                            ),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm2,
                        ),
                      ),
                      child: const Text('Take the test'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm2),
                  TextButton(
                    onPressed: () {
                      ref
                          .read(userProfileProvider.notifier)
                          .skipPlacementTest();
                    },
                    child: Text(
                      'Skip for now',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
