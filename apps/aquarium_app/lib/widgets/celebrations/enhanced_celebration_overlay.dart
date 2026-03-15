/// Enhanced Celebration Overlay - Full overlay with share buttons and advanced animations
/// Displays celebrations anywhere in the app with social sharing support
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../../services/enhanced_celebration_service.dart';
import '../../theme/app_theme.dart';
import 'confetti_overlay.dart';

/// Global overlay widget that shows enhanced celebrations anywhere in the app
/// Wrap your MaterialApp's home with this widget
class EnhancedCelebrationOverlayWrapper extends ConsumerStatefulWidget {
  final Widget child;
  
  const EnhancedCelebrationOverlayWrapper({super.key, required this.child});
  
  @override
  ConsumerState<EnhancedCelebrationOverlayWrapper> createState() => 
      _EnhancedCelebrationOverlayWrapperState();
}

class _EnhancedCelebrationOverlayWrapperState 
    extends ConsumerState<EnhancedCelebrationOverlayWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppDurations.long3,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.elastic,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.standardAccelerate,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.emphasized,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final celebration = ref.watch(enhancedCelebrationProvider);
    
    // Trigger animation when celebration becomes active
    if (celebration.isActive && !_animationController.isAnimating) {
      _animationController.forward(from: 0);
    }
    
    return Stack(
      children: [
        widget.child,
        
        // Celebration overlay
        if (celebration.isActive && celebration.confettiController != null)
          _buildCelebrationOverlay(celebration),
      ],
    );
  }
  
  Widget _buildCelebrationOverlay(EnhancedCelebrationState celebration) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    // Determine colors based on celebration level
    final colors = _getCelebrationColors(celebration.level);
    
    // Determine blast type based on celebration level
    final blastType = _getBlastType(celebration.level);
    
    // Determine particle count based on celebration level
    final particleCount = _getParticleCount(celebration.level);
    
    final hasOverlay = celebration.level != CelebrationLevel.standard;

    // Reduced motion: show static badge card without animations
    if (reduceMotion) {
      if (!hasOverlay || celebration.title == null) {
        return const SizedBox.shrink();
      }
      return Positioned.fill(
        child: GestureDetector(
          onTap: () => ref.read(enhancedCelebrationProvider.notifier).dismiss(),
          child: Container(
            color: AppColors.blackAlpha05,
            child: Center(child: _buildCelebrationCard(celebration)),
          ),
        ),
      );
    }
    
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !hasOverlay,
        child: Stack(
          children: [
            // Semi-transparent backdrop for non-standard celebrations
            if (hasOverlay)
              GestureDetector(
                onTap: () => ref.read(enhancedCelebrationProvider.notifier).dismiss(),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    color: AppColors.blackAlpha05,
                  ),
                ),
              ),
            
            // Confetti overlay
            ConfettiOverlay(
              controller: celebration.confettiController,
              blastType: blastType,
              colors: colors,
              numberOfParticles: particleCount,
              particleShape: celebration.level == CelebrationLevel.epic
                  ? ConfettiParticleShape.stars
                  : ConfettiParticleShape.stars,
            ),
            
            // Text overlay for achievements/level ups
            if (hasOverlay && celebration.title != null)
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildCelebrationCard(celebration),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCelebrationCard(EnhancedCelebrationState celebration) {
    final gradientColors = _getGradientColors(celebration.level);
    final emoji = _getCelebrationEmoji(celebration.level);
    
    return GestureDetector(
      onTap: () => ref.read(enhancedCelebrationProvider.notifier).dismiss(),
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.xl),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: AppRadius.xlRadius,
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withAlpha(128),
              blurRadius: 40,
              spreadRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated emoji
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: AppCurves.elastic,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Transform.rotate(
                          angle: (1 - value) * 0.5,
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      emoji,
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontSize: 72),
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Title
                  Text(
                    celebration.title!,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  // Subtitle
                  if (celebration.subtitle != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      celebration.subtitle!,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: AppColors.whiteAlpha05,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  
                  // Share button (if shareable)
                  if (celebration.canShare) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _buildShareButton(),
                  ],
                ],
              ),
            ),
            
            // Tap to dismiss hint
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.blackAlpha05,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.xl),
                  bottomRight: Radius.circular(AppRadius.xl),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app,
                    color: AppColors.whiteAlpha05,
                    size: AppIconSizes.xs,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Tap anywhere to dismiss',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: AppColors.whiteAlpha05,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildShareButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        await ref.read(enhancedCelebrationProvider.notifier).shareAchievement();
      },
      icon: const Icon(Icons.share),
      label: const Text('Share Achievement'),
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.primary,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.largeRadius,
        ),
      ),
    );
  }
  
  /// Get celebration colors based on level
  List<Color> _getCelebrationColors(CelebrationLevel level) {
    return switch (level) {
      CelebrationLevel.standard => ConfettiColors.aquatic,
      CelebrationLevel.achievement => ConfettiColors.gold,
      CelebrationLevel.levelUp => ConfettiColors.levelUp,
      CelebrationLevel.milestone => ConfettiColors.rainbow,
      CelebrationLevel.epic => ConfettiColors.rainbow,
    };
  }
  
  /// Get blast type based on celebration level
  ConfettiBlastType _getBlastType(CelebrationLevel level) {
    return switch (level) {
      CelebrationLevel.standard => ConfettiBlastType.explosive,
      CelebrationLevel.achievement => ConfettiBlastType.corners,
      CelebrationLevel.levelUp => ConfettiBlastType.fountain,
      CelebrationLevel.milestone => ConfettiBlastType.corners,
      CelebrationLevel.epic => ConfettiBlastType.corners,
    };
  }
  
  /// Get particle count based on celebration level
  int _getParticleCount(CelebrationLevel level) {
    return switch (level) {
      CelebrationLevel.standard => 20,
      CelebrationLevel.achievement => 30,
      CelebrationLevel.levelUp => 35,
      CelebrationLevel.milestone => 40,
      CelebrationLevel.epic => 50,
    };
  }
  
  /// Get gradient colors based on celebration level
  List<Color> _getGradientColors(CelebrationLevel level) {
    return switch (level) {
      CelebrationLevel.levelUp => [
        const Color(0xFF2A3548), 
        const Color(0xFF8B6BAE),
      ],
      CelebrationLevel.achievement => [
        const Color(0xFFB45309), 
        const Color(0xFFE8A84A),
      ],
      CelebrationLevel.milestone => [
        AppColors.primary, 
        AppColors.secondary,
      ],
      CelebrationLevel.epic => [
        const Color(0xFFD946EF), 
        const Color(0xFF2A3548),
      ],
      CelebrationLevel.standard => [
        AppColors.primary, 
        AppColors.primaryLight,
      ],
    };
  }
  
  /// Get emoji based on celebration level
  String _getCelebrationEmoji(CelebrationLevel level) {
    return switch (level) {
      CelebrationLevel.levelUp => '⬆️',
      CelebrationLevel.achievement => '🏆',
      CelebrationLevel.milestone => '🎉',
      CelebrationLevel.epic => '👑',
      CelebrationLevel.standard => '✨',
    };
  }
}
