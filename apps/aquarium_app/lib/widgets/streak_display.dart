/// Streak display widget with fire emoji and pulsing animation
/// Shows current streak count with engaging animations

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';

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

class _StreakDisplayState extends ConsumerState<StreakDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 40,
      ),
    ]).animate(_controller);

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 0.8)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 0.3)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).value;
    
    if (profile == null) {
      return const SizedBox.shrink();
    }

    final hasStreak = profile.currentStreak > 0;

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Glow effect for active streaks
                  if (hasStreak)
                    Container(
                      width: widget.size * 1.4,
                      height: widget.size * 1.4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFFF6B35).withOpacity(_glowAnimation.value),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  
                  // Fire emoji with scale animation
                  Transform.scale(
                    scale: hasStreak ? _scaleAnimation.value : 1.0,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasStreak
                            ? Colors.orange.withOpacity(0.15)
                            : Colors.grey.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Text(
                          hasStreak ? '🔥' : '💤',
                          style: TextStyle(
                            fontSize: widget.size * 0.5,
                          ),
                        ),
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
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${profile.currentStreak}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          if (widget.showLabel) ...[
            const SizedBox(height: 6),
            Text(
              hasStreak
                  ? '${profile.currentStreak} day streak!'
                  : 'No streak yet',
              style: AppTypography.bodySmall.copyWith(
                color: hasStreak ? AppColors.textPrimary : AppColors.textHint,
                fontWeight: hasStreak ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            if (profile.longestStreak > profile.currentStreak)
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

  const StreakCard({
    super.key,
    this.onTap,
  });

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
        borderRadius: BorderRadius.circular(16),
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
              : Colors.white.withOpacity(0.6),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Streak display
                StreakDisplay(
                  size: 50,
                  showLabel: false,
                ),
                const SizedBox(width: 16),
                
                // Text info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasStreak
                            ? 'Keep it going!'
                            : 'Start a streak',
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: hasStreak
                              ? const Color(0xFFFF6B35)
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
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
                
                // Icon
                Icon(
                  hasStreak ? Icons.local_fire_department : Icons.flag,
                  color: hasStreak
                      ? const Color(0xFFFF6B35)
                      : AppColors.textHint,
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
