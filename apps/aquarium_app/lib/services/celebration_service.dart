/// Celebration Service - Global service for triggering celebrations app-wide
/// Provides methods for confetti bursts, achievements, level ups, etc.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../widgets/celebrations/confetti_overlay.dart';
import '../widgets/celebrations/level_up_overlay.dart';
import '../theme/app_theme.dart';
import '../providers/reduced_motion_provider.dart';

/// State for active celebrations
class CelebrationState {
  final bool isActive;
  final String? title;
  final String? subtitle;
  final CelebrationLevel level;
  final ConfettiController? confettiController;
  
  const CelebrationState({
    this.isActive = false,
    this.title,
    this.subtitle,
    this.level = CelebrationLevel.standard,
    this.confettiController,
  });
  
  CelebrationState copyWith({
    bool? isActive,
    String? title,
    String? subtitle,
    CelebrationLevel? level,
    ConfettiController? confettiController,
  }) {
    return CelebrationState(
      isActive: isActive ?? this.isActive,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      level: level ?? this.level,
      confettiController: confettiController ?? this.confettiController,
    );
  }
}

/// Levels of celebration intensity
enum CelebrationLevel {
  /// Quick confetti burst
  standard,
  
  /// Achievement unlocked - confetti + overlay
  achievement,
  
  /// Level up - special effects
  levelUp,
  
  /// Milestone - big celebration
  milestone,
}

/// Provider for celebration state
final celebrationProvider = StateNotifierProvider<CelebrationNotifier, CelebrationState>(
  (ref) => CelebrationNotifier(ref),
);

/// Notifier for managing celebrations
class CelebrationNotifier extends StateNotifier<CelebrationState> {
  CelebrationNotifier(this._ref) : super(const CelebrationState());
  
  final Ref _ref;
  ConfettiController? _controller;
  
  /// Trigger a standard confetti burst
  /// With reduced motion: skips confetti, shows simple success indicator
  void confetti({Duration duration = const Duration(seconds: 2)}) {
    final reducedMotion = _ref.read(reducedMotionProvider);
    
    if (reducedMotion.disableDecorativeAnimations) {
      // Skip confetti animation entirely for reduced motion
      return;
    }
    
    _disposeController();
    _controller = ConfettiController(duration: duration);
    
    state = CelebrationState(
      isActive: true,
      level: CelebrationLevel.standard,
      confettiController: _controller,
    );
    
    _controller!.play();
    
    // Auto-dismiss after duration
    Future.delayed(duration + const Duration(milliseconds: 500), () {
      if (mounted) {
        dismiss();
      }
    });
  }
  
  /// Trigger an achievement celebration with title overlay
  /// With reduced motion: simplified overlay, no confetti
  void achievement(String title, {String? subtitle}) {
    final reducedMotion = _ref.read(reducedMotionProvider);
    
    _disposeController();
    
    // Skip confetti for reduced motion, but still show title
    if (!reducedMotion.disableDecorativeAnimations) {
      _controller = ConfettiController(duration: const Duration(seconds: 3));
    }
    
    state = CelebrationState(
      isActive: true,
      title: title,
      subtitle: subtitle ?? 'Achievement Unlocked!',
      level: CelebrationLevel.achievement,
      confettiController: _controller,
    );
    
    _controller?.play();
    
    // Auto-dismiss after animation (shorter for reduced motion)
    final dismissDelay = reducedMotion.isEnabled
        ? const Duration(seconds: 2)
        : const Duration(seconds: 4);
    
    Future.delayed(dismissDelay, () {
      if (mounted) {
        dismiss();
      }
    });
  }
  
  /// Trigger a level up celebration (basic confetti version)
  /// For the enhanced overlay, use showLevelUpOverlay() with a BuildContext
  void levelUp(int level, {String? levelTitle}) {
    _disposeController();
    _controller = ConfettiController(duration: const Duration(seconds: 4));
    
    state = CelebrationState(
      isActive: true,
      title: 'Level $level!',
      subtitle: levelTitle ?? 'Keep up the great work! 🎉',
      level: CelebrationLevel.levelUp,
      confettiController: _controller,
    );
    
    _controller!.play();
    
    // Auto-dismiss after animation
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        dismiss();
      }
    });
  }
  
  /// Show enhanced level up overlay with full-screen animation
  /// This is the preferred method when a BuildContext is available
  void showLevelUpOverlay(BuildContext context, int level, {String? levelTitle}) {
    // Dismiss any existing celebration
    dismiss();
    
    // Show the enhanced level up overlay
    LevelUpOverlay.show(
      context,
      newLevel: level,
      levelTitle: levelTitle,
    );
  }
  
  /// Trigger a milestone celebration (big achievement)
  void milestone(String title, {String? subtitle}) {
    _disposeController();
    _controller = ConfettiController(duration: const Duration(seconds: 5));
    
    state = CelebrationState(
      isActive: true,
      title: title,
      subtitle: subtitle ?? 'Amazing milestone reached!',
      level: CelebrationLevel.milestone,
      confettiController: _controller,
    );
    
    _controller!.play();
    
    // Auto-dismiss after animation
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        dismiss();
      }
    });
  }
  
  /// Dismiss active celebration
  void dismiss() {
    _disposeController();
    state = const CelebrationState();
  }
  
  void _disposeController() {
    _controller?.dispose();
    _controller = null;
  }
  
  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }
}

/// Global overlay widget that shows celebrations anywhere in the app
/// Wrap your MaterialApp's home with this widget
class CelebrationOverlayWrapper extends ConsumerStatefulWidget {
  final Widget child;
  
  const CelebrationOverlayWrapper({super.key, required this.child});
  
  @override
  ConsumerState<CelebrationOverlayWrapper> createState() => _CelebrationOverlayWrapperState();
}

class _CelebrationOverlayWrapperState extends ConsumerState<CelebrationOverlayWrapper>
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
              GestureDetector(
                onTap: () => ref.read(celebrationProvider.notifier).dismiss(),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    color: Colors.black54,
                  ),
                ),
              ),
            
            // Confetti overlay
            ConfettiOverlay(
              controller: celebration.confettiController,
              blastType: blastType,
              colors: colors,
              numberOfParticles: celebration.level == CelebrationLevel.milestone ? 40 : 25,
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
      CelebrationLevel.levelUp => [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      CelebrationLevel.achievement => [const Color(0xFFFFB300), const Color(0xFFFFD700)],
      CelebrationLevel.milestone => [AppColors.primary, AppColors.secondary],
      CelebrationLevel.standard => [AppColors.primary, AppColors.primaryLight],
    };
    
    final emoji = switch (celebration.level) {
      CelebrationLevel.levelUp => '⬆️',
      CelebrationLevel.achievement => '🏆',
      CelebrationLevel.milestone => '🎉',
      CelebrationLevel.standard => '✨',
    };
    
    return GestureDetector(
      onTap: () => ref.read(celebrationProvider.notifier).dismiss(),
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.xl),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
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
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontSize: 64),
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
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: AppColors.whiteAlpha70,
              ),
            ),
          ],
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
  void showLevelUpOverlay(BuildContext context, int level, {String? levelTitle}) =>
      read(celebrationProvider.notifier).showLevelUpOverlay(context, level, levelTitle: levelTitle);
  
  /// Quick access to trigger milestone celebration
  void celebrateMilestone(String title, {String? subtitle}) =>
      read(celebrationProvider.notifier).milestone(title, subtitle: subtitle);
}
