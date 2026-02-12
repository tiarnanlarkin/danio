/// Streak display widget with animated fire effect
/// Shows current streak count with engaging flame animations
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import 'animated_flame.dart';

class StreakDisplay extends ConsumerStatefulWidget {
  final double size;
  final bool showLabel;
  final VoidCallback? onTap;

  const StreakDisplay({
    super.key,
    this.size = 48,
    this.showLabel = true,
    this.onTap,
  });

  @override
  ConsumerState<StreakDisplay> createState() => _StreakDisplayState();
}

class _StreakDisplayState extends ConsumerState<StreakDisplay> {
  int? _previousStreak;
  bool _showCelebration = false;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).value;

    if (profile == null) {
      return const SizedBox.shrink();
    }

    final hasStreak = profile.currentStreak > 0;
    final currentStreak = profile.currentStreak;

    // Detect streak increment for celebration
    if (_previousStreak != null && currentStreak > _previousStreak!) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _showCelebration = true);
        }
      });
    }
    _previousStreak = currentStreak;

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (hasStreak)
                // Animated flame for active streaks
                AnimatedFlame(
                  size: widget.size,
                  streakCount: currentStreak,
                  showCelebration: _showCelebration,
                  onCelebrationComplete: () {
                    if (mounted) {
                      setState(() => _showCelebration = false);
                    }
                  },
                )
              else
                // Dormant state - no streak
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.1),
                  ),
                  child: Center(
                    child: Text(
                      '💤',
                      style: TextStyle(fontSize: widget.size * 0.5),
                    ),
                  ),
                ),

              // Streak count badge
              if (hasStreak)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                      ),
                      borderRadius: AppRadius.smallRadius,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppOverlays.black20,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '$currentStreak',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (widget.showLabel) ...[
            const SizedBox(height: 6),
            Text(
              hasStreak
                  ? '$currentStreak day streak!'
                  : 'No streak yet',
              style: AppTypography.bodySmall.copyWith(
                color: hasStreak ? AppColors.textPrimary : AppColors.textHint,
                fontWeight: hasStreak ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            if (profile.longestStreak > currentStreak)
              Text(
                'Best: ${profile.longestStreak} days',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textHint,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ],
      ),
    );
  }
}

/// Compact streak card for home screen
class StreakCard extends ConsumerWidget {
  final VoidCallback? onTap;

  const StreakCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;

    if (profile == null) {
      return const SizedBox.shrink();
    }

    final hasStreak = profile.currentStreak > 0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasStreak
              ? [
                  const Color(0xFFFF6B35).withOpacity(0.15),
                  const Color(0xFFF7931E).withOpacity(0.10),
                ]
              : [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.88),
                ],
        ),
        borderRadius: AppRadius.mediumRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: hasStreak
              ? const Color(0xFFFF6B35).withOpacity(0.3)
              : AppOverlays.white60,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mediumRadius,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Streak display
                StreakDisplay(size: 50, showLabel: false),
                const SizedBox(width: AppSpacing.md),

                // Text info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasStreak ? 'Keep it going!' : 'Start a streak',
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: hasStreak
                              ? const Color(0xFFFF6B35)
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        hasStreak
                            ? '${profile.currentStreak} day${profile.currentStreak == 1 ? '' : 's'} in a row'
                            : 'Complete your daily goal',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (profile.longestStreak > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Personal best: ${profile.longestStreak} days',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textHint,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Animated flame or flag icon
                if (hasStreak)
                  AnimatedFlame(
                    size: 32,
                    streakCount: profile.currentStreak,
                  )
                else
                  Icon(
                    Icons.flag,
                    color: AppColors.textHint,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
