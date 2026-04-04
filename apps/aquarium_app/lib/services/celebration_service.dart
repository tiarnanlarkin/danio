/// Celebration Service - Global service for triggering celebrations app-wide
/// Provides methods for confetti bursts, achievements, level ups, etc.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/celebrations/confetti_overlay.dart';
import '../theme/app_theme.dart';
import '../providers/celebration_provider.dart';

// StateNotifier, state, enum, and provider declarations moved to providers/.
// This re-export preserves backward compatibility for existing imports.
export '../providers/celebration_provider.dart';

/// Global overlay widget that shows celebrations anywhere in the app
/// Wrap your MaterialApp's home with this widget
class CelebrationOverlayWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const CelebrationOverlayWrapper({super.key, required this.child});

  @override
  ConsumerState<CelebrationOverlayWrapper> createState() =>
      _CelebrationOverlayWrapperState();
}

class _CelebrationOverlayWrapperState
    extends ConsumerState<CelebrationOverlayWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final celebration = ref.watch(celebrationProvider);

    // Riverpod-idiomatic side-effect: use ref.listen inside build().
    // Riverpod guarantees this listener is registered once per watch cycle
    // and is safe for side effects (does NOT call setState directly).
    // We defer animation controller calls to addPostFrameCallback to avoid
    // "setState called during build" assertion errors.
    ref.listen<CelebrationState>(celebrationProvider, (previous, next) {
      if (next.isActive && !(previous?.isActive ?? false)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_animationController.isAnimating) {
            _animationController.forward(from: 0);
          }
        });
      } else if (!next.isActive && (previous?.isActive ?? false)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _animationController.reverse();
        });
      }
    });

    return Stack(
      children: [
        widget.child,

        // Celebration overlay
        if (celebration.isActive && celebration.confettiController != null)
          _buildCelebrationOverlay(celebration),
      ],
    );
  }

  Widget _buildCelebrationOverlay(CelebrationState celebration) {
    // Determine colors based on celebration level
    final colors = switch (celebration.level) {
      CelebrationLevel.standard => ConfettiColors.aquatic,
      CelebrationLevel.achievement => ConfettiColors.gold,
      CelebrationLevel.levelUp => ConfettiColors.levelUp,
      CelebrationLevel.milestone => ConfettiColors.rainbow,
    };

    // Determine blast type based on celebration level
    final blastType = switch (celebration.level) {
      CelebrationLevel.standard => ConfettiBlastType.explosive,
      CelebrationLevel.achievement => ConfettiBlastType.corners,
      CelebrationLevel.levelUp => ConfettiBlastType.fountain,
      CelebrationLevel.milestone => ConfettiBlastType.corners,
    };

    final hasOverlay = celebration.level != CelebrationLevel.standard;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !hasOverlay,
        child: Stack(
          children: [
            // Semi-transparent backdrop for non-standard celebrations
            if (hasOverlay)
              Semantics(
                label: 'Dismiss celebration',
                button: true,
                child: GestureDetector(
                  onTap: () => ref.read(celebrationProvider.notifier).dismiss(),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(color: AppColors.blackAlpha50),
                  ),
                ),
              ),

            // Confetti overlay
            ConfettiOverlay(
              controller: celebration.confettiController,
              blastType: blastType,
              colors: colors,
              numberOfParticles: celebration.level == CelebrationLevel.milestone
                  ? 40
                  : 25,
              particleShape: celebration.level == CelebrationLevel.levelUp
                  ? ConfettiParticleShape.stars
                  : ConfettiParticleShape.stars,
            ),

            // Text overlay for achievements/level ups
            if (hasOverlay && celebration.title != null)
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildCelebrationCard(celebration),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationCard(CelebrationState celebration) {
    final gradientColors = switch (celebration.level) {
      CelebrationLevel.levelUp => [
        const Color(0xFF6366F1),
        const Color(0xFF8B5CF6),
      ],
      CelebrationLevel.achievement => [
        const Color(0xFFFFB300),
        const Color(0xFFFFD700),
      ],
      CelebrationLevel.milestone => [AppColors.primary, AppColors.secondary],
      CelebrationLevel.standard => [AppColors.primary, AppColors.primaryLight],
    };

    final emoji = switch (celebration.level) {
      CelebrationLevel.levelUp => '⬆️',
      CelebrationLevel.achievement => '🏆',
      CelebrationLevel.milestone => '🎉',
      CelebrationLevel.standard => '✨',
    };

    return Semantics(
      label: 'Dismiss ${celebration.level.name} notification',
      button: true,
      child: GestureDetector(
        onTap: () => ref.read(celebrationProvider.notifier).dismiss(),
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.xl),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl2, vertical: AppSpacing.xl),
          decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: AppRadius.xlRadius,
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withAlpha(102),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium!.copyWith(fontSize: 64),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              celebration.title!,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (celebration.subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                celebration.subtitle!,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: AppColors.whiteAlpha90,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Tap to dismiss',
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: AppColors.whiteAlpha70),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

/// Extension for easy access to celebration service
extension CelebrationExtension on WidgetRef {
  /// Quick access to trigger confetti
  void celebrate() => read(celebrationProvider.notifier).confetti();

  /// Quick access to trigger achievement celebration
  void celebrateAchievement(String title, {String? subtitle}) =>
      read(celebrationProvider.notifier).achievement(title, subtitle: subtitle);

  /// Quick access to trigger level up celebration (basic)
  void celebrateLevelUp(int level, {String? levelTitle}) =>
      read(celebrationProvider.notifier).levelUp(level, levelTitle: levelTitle);

  /// Quick access to trigger enhanced level up overlay
  /// Requires BuildContext for the full-screen overlay
  void showLevelUpOverlay(
    BuildContext context,
    int level, {
    String? levelTitle,
  }) => read(
    celebrationProvider.notifier,
  ).showLevelUpOverlay(context, level, levelTitle: levelTitle);

  /// Quick access to trigger milestone celebration
  void celebrateMilestone(String title, {String? subtitle}) =>
      read(celebrationProvider.notifier).milestone(title, subtitle: subtitle);
}
