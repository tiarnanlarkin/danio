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
      duration: const Duration(milliseconds: 800),
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
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
    // Determine colors based on celebration level
    final colors = _getCelebrationColors(celebration.level);
    
    // Determine blast type based on celebration level
    final blastType = _getBlastType(celebration.level);
    
    // Determine particle count based on celebration level
    final particleCount = _getParticleCount(celebration.level);
    
    final hasOverlay = celebration.level != CelebrationLevel.standard;
    
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
                    color: Colors.black.withOpacity(0.6),
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
        margin: const EdgeInsets.all(32),
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
              color: gradientColors.first.withOpacity(0.5),
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
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated emoji
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
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
                      style: const TextStyle(fontSize: 72),
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Title
                  Text(
                    celebration.title!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
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
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
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
                    color: Colors.white.withOpacity(0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tap anywhere to dismiss',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
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
        const Color(0xFF6366F1), 
        const Color(0xFF8B5CF6),
      ],
      CelebrationLevel.achievement => [
        const Color(0xFFFFB300), 
        const Color(0xFFFFD700),
      ],
      CelebrationLevel.milestone => [
        AppColors.primary, 
        AppColors.secondary,
      ],
      CelebrationLevel.epic => [
        const Color(0xFFD946EF), 
        const Color(0xFF6366F1),
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
